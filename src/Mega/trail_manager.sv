// Trail Manager: Maintains assignment trail with decision level markers for backtracking
//
// INVARIANT: Trail Consistency
// 1. The Trail is an ordered log of ALL assignments (Decisions + Propagations).
// 2. Decision Levels must be monotonically increasing.
// 3. No variable may appear more than once in the active trail section (0 to height-1).
// 4. Backtracking strictly removes the suffix of the trail down to the target level.
//
// Memory: var_to_* / level_start / trail use ram_style="block" (BRAM). All reads are
// synchronous (1+ cycle). Query and trail_read ports are registered; consumers must
// pipeline addresses accordingly (see solver_core / cae).

import mega_pkg::*;

module trail_manager #(
    parameter int MAX_VARS = 256
)(
    input  logic [31:0]    DEBUG,
    input  logic         clk,
    input  logic         reset,
    
    input  logic         push,
    input  logic [31:0]  push_var,
    input  logic         push_value,
    input  logic [15:0]  push_level,
    input  logic         push_is_decision,
    input  logic [15:0]  push_reason,

    output logic [15:0]  height,
    output logic [15:0]  current_level,
    
    input  logic         backtrack_en,
    input  logic [15:0]  backtrack_to_level,
    output logic         backtrack_done,
    output logic         backtrack_valid,
    output logic [31:0]  backtrack_var,
    output logic         backtrack_value,
    output logic         backtrack_is_decision,
    
    input  logic [31:0]  query_var,
    output logic [15:0]  query_level,
    output logic         query_valid,
    output logic         query_value,
    output logic [15:0]  query_reason,
    output logic         query_valid_r,
    output logic [15:0]  query_level_r,
    output logic         query_value_r,
    output logic [15:0]  query_reason_r,
    
    input  logic [15:0]  trail_read_idx,
    output logic [31:0]  trail_read_var,
    output logic         trail_read_value,
    output logic [15:0]  trail_read_level,
    output logic         trail_read_is_decision,
    output logic [15:0]  trail_read_reason,
    
    input  logic         clear_all,

    input  logic         truncate_en,
    input  logic [15:0]  truncate_level_target
);

    // -------------------------------------------------------------------------
    // RAM arrays (BRAM inference; fully synchronous reads in always_ff below)
    // -------------------------------------------------------------------------
    (* ram_style = "block" *) logic [15:0] var_to_level [0:MAX_VARS];
    (* ram_style = "block" *) logic        var_to_value [0:MAX_VARS];
    (* ram_style = "block" *) logic [15:0] var_to_index [0:MAX_VARS];
    (* ram_style = "block" *) logic [15:0] level_start      [0:MAX_VARS];

`ifdef SYNTHESIS
    localparam int TRAIL_W = $bits(mega_pkg::trail_entry_t);
    (* ram_style = "block" *) logic [TRAIL_W-1:0] trail [0:MAX_VARS-1];
`else
    mega_pkg::trail_entry_t trail [0:MAX_VARS-1];
    localparam int TRAIL_W = $bits(mega_pkg::trail_entry_t);
`endif

    mega_pkg::trail_entry_t new_entry_push;
    logic [15:0] trail_height_q, trail_height_d;
    logic [15:0] current_level_q, current_level_d;

    // Truncate FSM (BRAM read for level_start — addr @en, sample next cycle, apply after)
    logic [1:0]             trunc_phase_q;
    logic [15:0]            trunc_h_res_q;
    logic [15:0]            trunc_lvl_hold_q;
    logic [15:0]            trunc_old_height_q;
    logic [15:0]            trunc_ls_addr_q;

    typedef enum logic [2:0] {
        BT_IDLE,
        BT_LOOP_FETCH,
        BT_LOOP_WAIT,
        BT_LOOP_ACT,
        BT_COMPLETE
    } bt_state_t;
    bt_state_t bt_state_q, bt_state_d;
    logic [15:0] bt_index_q, bt_index_d;
    logic [15:0] bt_target_q, bt_target_d;

    // Registered trail peek (2-cycle path: FETCH addr -> WAIT BRAM -> ACT consume)
    logic [15:0] bt_rd_idx_q;
    logic [TRAIL_W-1:0] bt_rd_word_q;
    mega_pkg::trail_entry_t bt_peek_entry;

    // Trail read port pipeline (addr @T, data valid end of T+1 for downstream regs)
    logic [15:0]  trd_addr_q;
    logic [TRAIL_W-1:0] trd_word_q;

    // Query pipeline — align var/height/level snapshots with BRAM latency
    logic [31:0] qv1;
    logic [15:0] qh1, qcl1;
    logic [31:0] qv2;
    logic [15:0] ix2, lv2, th2, cl2;
    logic        val2;
    logic [TRAIL_W-1:0] q_trail_word3;
    logic        q_valid3;
    logic [31:0] qv3;
    logic [15:0] lv3, th3, cl3;
    logic        val3;

    assign height = trail_height_q;
    assign current_level = current_level_q;

    // Combinational outputs mirror registered (no asynchronous read paths)
    assign query_valid   = query_valid_r;
    assign query_level   = query_level_r;
    assign query_value   = query_value_r;
    assign query_reason  = query_reason_r;

    function automatic mega_pkg::trail_entry_t unpack_trail(input logic [TRAIL_W-1:0] w);
        unpack_trail = trail_entry_t'(w);
    endfunction

`ifndef SYNTHESIS
    // Initialize var_to_index to sentinel 16'hFFFF so dup_var_on_trail never
    // sees an X index on the first push (xsim doesn't short-circuit && on X).
    initial begin
        for (int i = 0; i <= MAX_VARS; i++)
            var_to_index[i] = 16'hFFFF;
    end

    function automatic logic dup_var_on_trail(
        input logic [15:0] dup_lvl,
        input logic [15:0] dup_idx,
        input logic [31:0] pvar
    );
        // Extra bounds guard: even if dup_idx is somehow out of range, prevent
        // the trail[] access rather than crashing xsim with out-of-bounds read.
        if (dup_idx >= MAX_VARS[15:0]) begin
            dup_var_on_trail = 1'b0;
        end else begin
            dup_var_on_trail = (dup_lvl <= current_level_q && dup_idx < trail_height_q &&
                                trail[dup_idx].variable == pvar);
        end
    endfunction
`endif

    // Registered trail read outputs (1-cycle BRAM latency from trail_read_idx)
    always_comb begin
        mega_pkg::trail_entry_t te;
        te = unpack_trail(trd_word_q);
        trail_read_var         = te.variable;
        trail_read_value       = te.value;
        trail_read_level       = te.level;
        trail_read_is_decision = te.is_decision;
        trail_read_reason      = te.reason;
    end

    // Query result registers (3-cycle latency from query_var change)
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            query_valid_r  <= 1'b0;
            query_level_r  <= 16'd0;
            query_value_r  <= 1'b0;
            query_reason_r <= 16'h0;
        end else begin
            query_valid_r  <= q_valid3;
            query_level_r  <= lv3;
            query_value_r  <= val3;
            query_reason_r <= unpack_trail(q_trail_word3).reason;
        end
    end

    // Stage 0: capture query + trail context
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            qv1  <= '0;
            qh1  <= '0;
            qcl1 <= '0;
        end else begin
            qv1  <= query_var;
            qh1  <= trail_height_q;
            qcl1 <= current_level_q;
        end
    end

    // Stage 1: parallel BRAM read var_to_* (address = qv1)
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            qv2  <= '0;
            ix2  <= 16'hFFFF;
            lv2  <= '0;
            val2 <= 1'b0;
            th2  <= '0;
            cl2  <= '0;
        end else begin
            qv2  <= qv1;
            th2  <= qh1;
            cl2  <= qcl1;
            if (qv1 > 0 && qv1 <= MAX_VARS) begin
                ix2  <= var_to_index[qv1];
                lv2  <= var_to_level[qv1];
                val2 <= var_to_value[qv1];
            end else begin
                ix2  <= 16'hFFFF;
                lv2  <= 16'd0;
                val2 <= 1'b0;
            end
        end
    end

    // Stage 2: bounds + trail cross-check (filters stale var_to_index metadata)
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            q_valid3     <= 1'b0;
            qv3          <= '0;
            lv3          <= '0;
            val3         <= 1'b0;
            th3          <= '0;
            cl3          <= '0;
            q_trail_word3<= '0;
        end else begin
            logic [TRAIL_W-1:0] q_trail_word_now;
            mega_pkg::trail_entry_t q_trail_entry_now;

            qv3   <= qv2;
            lv3   <= lv2;
            val3  <= val2;
            th3   <= th2;
            cl3   <= cl2;

            q_trail_word_now = '0;
            q_trail_entry_now = '0;

            if (qv2 > 0 && qv2 <= MAX_VARS && lv2 <= cl2 && ix2 < th2) begin
`ifdef SYNTHESIS
                q_trail_word_now = trail[ix2];
`else
                q_trail_word_now = trail_entry_t'(trail[ix2]);
`endif
                q_trail_entry_now = unpack_trail(q_trail_word_now);
                if (q_trail_entry_now.variable == qv2) begin
                    q_valid3      <= 1'b1;
                    q_trail_word3 <= q_trail_word_now;
                end else begin
                    q_valid3      <= 1'b0;
                    q_trail_word3 <= '0;
                end
            end else begin
                q_valid3      <= 1'b0;
                q_trail_word3 <= '0;
            end
        end
    end

    // Trail read port (synchronous BRAM)
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            trd_addr_q <= '0;
        else
            trd_addr_q <= trail_read_idx;
    end

    always_ff @(posedge clk) begin
`ifdef SYNTHESIS
        trd_word_q <= trail[trd_addr_q];
`else
        trd_word_q <= trail_entry_t'(trail[trd_addr_q]);
`endif
    end

    // Main control comb (height / backtrack) — truncate handled in sequential FSM
    always_comb begin
        trail_height_d    = trail_height_q;
        current_level_d   = current_level_q;
        bt_state_d        = bt_state_q;
        bt_index_d        = bt_index_q;
        bt_target_d       = bt_target_q;
        backtrack_done    = 1'b0;
        backtrack_valid   = 1'b0;
        backtrack_var     = '0;
        backtrack_value   = 1'b0;
        backtrack_is_decision = 1'b0;
        bt_peek_entry     = '0;

        if (push && trail_height_q < MAX_VARS) begin
            trail_height_d = trail_height_q + 1'b1;
            if (push_is_decision)
                current_level_d = push_level;
        end

        if (clear_all) begin
            trail_height_d  = '0;
            current_level_d = '0;
            bt_state_d      = BT_IDLE;
`ifndef SYNTHESIS
            if (DEBUG >= 1) $display("[TRAIL MANAGER] trail_height_d=0 via clear_all");
`endif
        end else begin
            case (bt_state_q)
                BT_IDLE: begin
                    if (backtrack_en) begin
                        bt_target_d = backtrack_to_level;
                        bt_index_d  = trail_height_q;
                        bt_state_d  = BT_LOOP_FETCH;
                    end
                end
                BT_LOOP_FETCH: begin
                    if (bt_index_q > 0)
                        bt_state_d = BT_LOOP_WAIT;
                    else
                        bt_state_d = BT_COMPLETE;
                end
                BT_LOOP_WAIT: begin
                    bt_state_d = BT_LOOP_ACT;
                end
                BT_LOOP_ACT: begin
                    bt_peek_entry = unpack_trail(bt_rd_word_q);
                    if (bt_index_q > 0 && bt_peek_entry.level > bt_target_q) begin
                        backtrack_valid       = 1'b1;
                        backtrack_var         = bt_peek_entry.variable;
                        backtrack_value       = bt_peek_entry.value;
                        backtrack_is_decision = bt_peek_entry.is_decision;
                        bt_index_d            = bt_index_q - 1'b1;
                        bt_state_d            = BT_LOOP_FETCH;
`ifndef SYNTHESIS
                        if (DEBUG >= 1) $display("[TRAIL MANAGER] ITERATIVE UNASSIGN: var=%0d level=%0d target=%0d idx=%0d",
                            bt_peek_entry.variable, bt_peek_entry.level, bt_target_q, bt_index_q);
`endif
                    end else
                        bt_state_d = BT_COMPLETE;
                end
                BT_COMPLETE: begin
                    if (push && bt_index_q < MAX_VARS)
                        trail_height_d = bt_index_q + 16'd1;
                    else
                        trail_height_d = bt_index_q;
                    current_level_d = bt_target_q;
`ifndef SYNTHESIS
                    if (DEBUG >= 1) $display("[TRAIL MANAGER] trail_height_d=%0d BT_COMPLETE (push=%0b)", trail_height_d, push);
`endif
                    backtrack_done = 1'b1;
                    bt_state_d     = BT_IDLE;
                end
                default: bt_state_d = BT_IDLE;
            endcase
        end
    end

    // Sequential: height, current_level, backtrack regs; truncate apply
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            trail_height_q       <= '0;
            current_level_q      <= '0;
            bt_state_q           <= BT_IDLE;
            bt_index_q           <= '0;
            bt_target_q          <= '0;
            trunc_phase_q        <= '0;
            trunc_h_res_q        <= '0;
            trunc_lvl_hold_q     <= '0;
            trunc_old_height_q   <= '0;
            trunc_ls_addr_q      <= '0;
            bt_rd_idx_q          <= '0;
        end else if (clear_all) begin
            trunc_phase_q   <= '0;
            trail_height_q  <= '0;
            current_level_q <= '0;
            bt_state_q      <= BT_IDLE;
            bt_index_q      <= '0;
            bt_target_q     <= '0;
        end else begin
            // Truncate: 0 idle, 1 wait BRAM, 2 latch level_start, 3 apply height/level
            if (trunc_phase_q == 2'h1) begin
                trunc_phase_q <= 2'h2;
            end else if (trunc_phase_q == 2'h2) begin
                trunc_h_res_q <= level_start[trunc_ls_addr_q];
                trunc_phase_q <= 2'h3;
            end else if (trunc_phase_q == 2'h3) begin
                if (trunc_h_res_q <= trunc_old_height_q)
                    trail_height_q <= trunc_h_res_q;
                current_level_q <= trunc_lvl_hold_q;
                trunc_phase_q <= 2'h0;
            end else if (truncate_en) begin
                trunc_ls_addr_q    <= truncate_level_target + 16'd1;
                trunc_lvl_hold_q   <= truncate_level_target;
                trunc_old_height_q <= trail_height_q;
                trunc_phase_q      <= 2'h1;
            end else begin
                trail_height_q  <= trail_height_d;
                current_level_q <= current_level_d;
            end

            bt_state_q  <= bt_state_d;
            bt_index_q  <= bt_index_d;
            bt_target_q <= bt_target_d;
`ifndef SYNTHESIS
            if (DEBUG >= 1 && trail_height_q != trail_height_d && trunc_phase_q == 0 && !truncate_en)
                $display("[TRAIL MANAGER] trail_height_q changed from %0d to %0d", trail_height_q, trail_height_d);
`endif
        end
    end

    // Backtrack peek BRAM read
    always_ff @(posedge clk) begin
        if (bt_state_q == BT_LOOP_FETCH && bt_index_q > 0)
            bt_rd_idx_q <= bt_index_q - 1'b1;
    end

    always_ff @(posedge clk) begin
`ifdef SYNTHESIS
        bt_rd_word_q <= trail[bt_rd_idx_q];
`else
        bt_rd_word_q <= trail_entry_t'(trail[bt_rd_idx_q]);
`endif
    end

    // trail[] writes
    always_ff @(posedge clk) begin
        if (push && trail_height_q < MAX_VARS) begin
`ifndef SYNTHESIS
            if (push_var > 0 && push_var <= MAX_VARS) begin
                logic [15:0] dup_lvl, dup_idx;
                dup_lvl = var_to_level[push_var];
                dup_idx = var_to_index[push_var];
                if (dup_var_on_trail(dup_lvl, dup_idx, push_var))
                    $display("[TRAIL DUP-VALIDATE] ERROR: Pushing var=%0d already on trail idx=%0d",
                             push_var, dup_idx);
            end
`endif
            begin : trail_wr_blk
                logic [15:0] widx;
                widx = (bt_state_q == BT_COMPLETE) ? bt_index_q : trail_height_q;
`ifdef SYNTHESIS
                trail[widx] <= {push_var, push_value, push_level, push_is_decision, push_reason};
`else
                new_entry_push.variable    = push_var;
                new_entry_push.value       = push_value;
                new_entry_push.level       = push_level;
                new_entry_push.is_decision = push_is_decision;
                new_entry_push.reason      = push_reason;
                trail[widx] <= new_entry_push;
`endif
            end
        end
    end

    always_ff @(posedge clk) begin
        if (push && trail_height_q < MAX_VARS) begin
            var_to_level[push_var] <= push_level;
            var_to_value[push_var] <= push_value;
        end else if (bt_state_q == BT_LOOP_ACT && backtrack_valid) begin
            var_to_level[backtrack_var] <= 16'd0;
            var_to_value[backtrack_var] <= 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (push && trail_height_q < MAX_VARS) begin
            var_to_index[push_var] <= (bt_state_q == BT_COMPLETE) ? bt_index_q : trail_height_q;
        end else if (bt_state_q == BT_LOOP_ACT && backtrack_valid) begin
            var_to_index[backtrack_var] <= 16'hFFFF;
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            level_start[0] <= 16'd0;
            level_start[1] <= 16'd0;
        end else if (clear_all) begin
            level_start[0] <= 16'd0;
            level_start[1] <= 16'd0;
        end else if (push && trail_height_q < MAX_VARS) begin
            level_start[push_level + 1] <= (bt_state_q == BT_COMPLETE) ? (bt_index_q + 1'b1) : (trail_height_q + 1'b1);
        end
    end

`ifndef SYNTHESIS
    always_ff @(posedge clk or posedge reset) begin
        if (!reset && DEBUG >= 3 && truncate_en) begin
            $display("[TRAIL FF TRUNC] t=%0t to_level=%0d (async path via trunc FSM)",
                $time, truncate_level_target);
        end
    end
`endif

endmodule
