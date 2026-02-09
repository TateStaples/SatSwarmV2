// Mini Propagation Search Engine (PSE)
// Watched-literal BCP - simplified version without reason tracking or clause injection
// Based on mega PSE but stripped down for pure DPLL
`timescale 1ns/1ps

module mini_pse #(
    parameter int MAX_VARS    = 256,
    parameter int MAX_CLAUSES = 256,
    parameter int MAX_LITS    = 2048,
    parameter int MAX_CLAUSE_LEN = 16
)(
    input  int                 DEBUG,
    input  logic               clk,
    input  logic               reset,

    // Clause load stream
    input  logic               load_valid,
    input  logic signed [31:0] load_literal,
    input  logic               load_clause_end,
    output logic               load_ready,

    // Solve control
    input  logic               start,
    input  logic signed [31:0] decision_var,
    output logic               done,
    output logic               conflict_detected,
    output logic               propagated_valid,
    output logic signed [31:0] propagated_var,
    output logic [31:0]        max_var_seen,
    
    // Backtracking control
    input  logic               undo_enable,          // Enable undo operation
    input  logic [15:0]        undo_to_height,       // Undo trail to this height
    output logic [15:0]        trail_height          // Current trail height for solver tracking
);

    typedef enum logic [3:0] {
        IDLE,
        LOAD_CLAUSE,
        RESET_WATCHES,
        INIT_WATCHES,
        SEED_DECISION,
        WAIT_PROP,      // Wait one cycle for prop_queue update
        DEQ_PROP,
        SCAN_WATCH,
        COMPLETE,
        UNDO_ASSIGNMENTS
    } state_e;

    // Assignment encoding: 2'b00 = unassigned, 2'b01 = false, 2'b10 = true
    logic [1:0] assign_state [0:MAX_VARS-1];

    // Clause Store
    (* ram_style = "block" *) logic [15:0] clause_len    [0:MAX_CLAUSES-1];
    (* ram_style = "block" *) logic [15:0] clause_start  [0:MAX_CLAUSES-1];
    (* ram_style = "block" *) logic signed [31:0] lit_mem [0:MAX_LITS-1];

    // Watch Lists
    (* ram_style = "block" *) logic [15:0] watched_lit1  [0:MAX_CLAUSES-1];
    (* ram_style = "block" *) logic [15:0] watched_lit2  [0:MAX_CLAUSES-1];
    logic [15:0] watch_next1   [0:MAX_CLAUSES-1];
    logic [15:0] watch_next2   [0:MAX_CLAUSES-1];
    (* ram_style = "block" *) logic [15:0] watch_head1   [0:2*MAX_VARS-1];
    (* ram_style = "block" *) logic [15:0] watch_head2   [0:2*MAX_VARS-1];

    // Propagation queue - simple array-based FIFO
    (* ram_style = "block" *) logic signed [31:0] prop_queue [0:MAX_LITS-1];
    logic [15:0] prop_wr_ptr, prop_rd_ptr;
    logic prop_empty;
    
    assign prop_empty = (prop_wr_ptr == prop_rd_ptr);

    // Trail for backtracking - stores literals in assignment order
    (* ram_style = "block" *) logic signed [31:0] trail_mem [0:MAX_VARS-1];
    logic [15:0] trail_height_q;

    // State registers
    state_e      state_q, state_d;
    logic [15:0] clause_count_q, clause_count_d;
    logic [15:0] lit_count_q, lit_count_d;
    logic [15:0] cur_clause_len_q, cur_clause_len_d;
    logic [15:0] init_clause_idx_q, init_clause_idx_d;
    logic [31:0] max_var_seen_q, max_var_seen_d;
    logic [15:0] reset_idx_q, reset_idx_d;
    logic        initialized_q, initialized_d;

    // Scan state
    logic signed [31:0] cur_prop_lit_q, cur_prop_lit_d;
    logic [0:0]        scan_list_sel_q, scan_list_sel_d;
    logic [15:0]       scan_clause_q, scan_clause_d;
    logic [15:0]       scan_prev_q, scan_prev_d;

    // Registered decision variable (captured when start is high)
    logic signed [31:0] registered_decision_q;

    // Conflict tracking
    logic        conflict_detected_q, conflict_detected_d;

    integer i;

    // Helper function: literal truth value
    function automatic logic [1:0] lit_truth(input logic signed [31:0] lit);
        logic [31:0] v;
        v = (lit < 0) ? -lit : lit;
        if (v == 0 || v > MAX_VARS) begin
            lit_truth = 2'b00;
        end else begin
            lit_truth = assign_state[v-1];
            if (lit < 0) begin
                if (lit_truth == 2'b01) lit_truth = 2'b10;
                else if (lit_truth == 2'b10) lit_truth = 2'b01;
            end
        end
    endfunction

    // Literal to watch head index
    function automatic logic [15:0] safe_lit_idx(input logic signed [31:0] lit);
        logic [31:0] v;
        logic [15:0] raw_idx;
        v = (lit < 0) ? -lit : lit;
        if (v == 0 || v > MAX_VARS) begin
            safe_lit_idx = 16'd0;
        end else begin
            raw_idx = (lit > 0) ? (v - 1) * 2 : (v - 1) * 2 + 1;
            safe_lit_idx = (raw_idx < 2*MAX_VARS) ? raw_idx : 16'd0;
        end
    endfunction

    assign load_ready = (state_q == IDLE || state_q == LOAD_CLAUSE || state_q == COMPLETE);
    wire load_fire = load_valid && load_ready;

    // Yosys synthesis fix: intermediate signals for INIT_WATCHES and SECTION_DECISION
    // to avoid automatic variables inside always_ff
    logic [15:0] init_c;
    logic [15:0] init_b;
    logic [15:0] init_l;
    logic [15:0] init_w1_addr;
    logic [15:0] init_w2_addr;
    logic [15:0] init_idx1;
    logic [15:0] init_idx2;
    
    assign init_c = init_clause_idx_q;
    assign init_b = clause_start[init_c];
    assign init_l = clause_len[init_c];
    assign init_w1_addr = init_b;
    assign init_w2_addr = (init_l > 1) ? init_b + 1 : init_b;
    assign init_idx1 = safe_lit_idx(lit_mem[init_w1_addr]);
    assign init_idx2 = safe_lit_idx(lit_mem[init_w2_addr]);

    logic [31:0] seed_v;
    assign seed_v = (registered_decision_q < 0) ? -registered_decision_q : registered_decision_q;

    logic [31:0] prop_v;
    assign prop_v = (propagated_var < 0) ? -propagated_var : propagated_var;

    // Undo helper signals (continuous assignment for single-port read)
    logic signed [31:0] undo_raw_var;
    logic [31:0] undo_var_idx;
    assign undo_raw_var = trail_mem[trail_height_q - 1]; // Use trail_height_q from FF
    assign undo_var_idx = (undo_raw_var < 0) ? -undo_raw_var : undo_raw_var;

    // Main combinational logic
    always_comb begin
        logic [31:0] v;
        logic signed [31:0] neg_lit;
        logic [15:0] w1, w2, cstart, clen;
        logic signed [31:0] lit_watch, lit_other, l;
        logic [1:0] other_truth, t;
        logic found_repl;
        logic [15:0] repl_idx;
        logic signed [31:0] repl_lit;

        // Initialize locals to avoid latches
        v = '0;
        neg_lit = '0;
        w1 = '0; w2 = '0; cstart = '0; clen = '0;
        lit_watch = '0; lit_other = '0; l = '0;
        other_truth = 2'b00; t = 2'b00;
        found_repl = 1'b0;
        repl_idx = '0;
        repl_lit = '0;

        // Defaults - undo_enable forces state back to IDLE for undo processing
        // Defaults
        state_d            = state_q;
        clause_count_d     = clause_count_q;
        lit_count_d        = lit_count_q;
        cur_clause_len_d   = cur_clause_len_q;
        init_clause_idx_d  = init_clause_idx_q;
        reset_idx_d        = reset_idx_q;
        scan_list_sel_d    = scan_list_sel_q;
        scan_clause_d      = scan_clause_q;
        scan_prev_d        = scan_prev_q;
        cur_prop_lit_d     = cur_prop_lit_q;
        initialized_d      = initialized_q;
        max_var_seen_d     = max_var_seen_q;
        conflict_detected_d = start ? 1'b0 : conflict_detected_q;

        propagated_valid   = 1'b0;
        propagated_var     = '0;
        done               = 1'b0;
        conflict_detected  = conflict_detected_q;

        case (state_q)
            IDLE: begin
                if (load_fire) begin
                    cur_clause_len_d = cur_clause_len_q + 1'b1;
                    lit_count_d      = lit_count_q + 1'b1;
                    v = (load_literal < 0) ? -load_literal : load_literal;
                    if (v > max_var_seen_q) max_var_seen_d = v;
                    
                    if (load_clause_end) begin
                        clause_count_d     = clause_count_q + 1'b1;
                        cur_clause_len_d   = '0;
                    end
                    state_d = LOAD_CLAUSE;
                end else if (start) begin
                    if (initialized_q) begin
                        if (init_clause_idx_q < clause_count_q) state_d = INIT_WATCHES;
                        else state_d = SEED_DECISION;
                    end else begin
                        reset_idx_d = '0;
                        state_d = RESET_WATCHES;
                    end
                end
            end

            LOAD_CLAUSE: begin
                if (load_fire) begin
                    cur_clause_len_d = cur_clause_len_q + 1'b1;
                    lit_count_d      = lit_count_q + 1'b1;
                    v = (load_literal < 0) ? -load_literal : load_literal;
                    if (v > max_var_seen_q) max_var_seen_d = v;
                    
                    if (load_clause_end) begin
                        clause_count_d   = clause_count_q + 1'b1;
                        cur_clause_len_d = '0;
                    end
                end else if (start) begin
                    if (initialized_q) state_d = SEED_DECISION;
                    else begin
                        reset_idx_d = '0;
                        state_d = RESET_WATCHES;
                    end
                end else begin
                    state_d = IDLE;
                end
            end

            RESET_WATCHES: begin
                $display("[PSE] RESET Idx: %0d Limit: %0d", reset_idx_q, MAX_CLAUSES + 2*MAX_VARS);
                if (reset_idx_q < MAX_CLAUSES + 2*MAX_VARS) begin
                    reset_idx_d = reset_idx_q + 1'b1;
                    state_d = RESET_WATCHES;
                end else begin
                    init_clause_idx_d = '0;
                    state_d = INIT_WATCHES;
                end
            end

            INIT_WATCHES: begin
                if (init_clause_idx_q < clause_count_q) begin
                    $display("[PSE] INIT Idx: %0d Count: %0d", init_clause_idx_q, clause_count_q);
                    init_clause_idx_d = init_clause_idx_q + 1'b1;
                    state_d = INIT_WATCHES;
                end else begin
                    initialized_d = 1'b1;
                    state_d = SEED_DECISION;
                end
            end

            SEED_DECISION: begin
                // Use registered_decision_q captured when start was high
                if (registered_decision_q != 0) begin
                    v = (registered_decision_q < 0) ? -registered_decision_q : registered_decision_q;
                    if (v != 0 && v <= MAX_VARS) begin
                        // Assignment happens in always_ff
                    end
                end
                scan_list_sel_d = 1'b0;
                // Wait one cycle for prop_wr_ptr to update before checking prop_empty
                state_d = WAIT_PROP;
            end

            WAIT_PROP: begin
                // Now prop_queue should be updated, move to dequeue
                state_d = DEQ_PROP;
            end

            DEQ_PROP: begin
                if (prop_empty) begin
                    done = 1'b1;
                    state_d = COMPLETE;
                end else begin
                    cur_prop_lit_d = prop_queue[prop_rd_ptr];
                    scan_list_sel_d = 1'b0;
                    neg_lit = -prop_queue[prop_rd_ptr];
                    scan_clause_d = watch_head1[safe_lit_idx(neg_lit)];
                    scan_prev_d = 16'hFFFF;
                    state_d = SCAN_WATCH;
                end
            end

            SCAN_WATCH: begin
                if (scan_clause_q == 16'hFFFF) begin
                    if (scan_list_sel_q == 1'b0) begin
                        scan_list_sel_d = 1'b1;
                        neg_lit = -cur_prop_lit_q;
                        scan_clause_d = watch_head2[safe_lit_idx(neg_lit)];
                        scan_prev_d = 16'hFFFF;
                    end else begin
                        state_d = DEQ_PROP;
                    end
                end else if (scan_clause_q >= MAX_CLAUSES) begin
                    state_d = COMPLETE;
                end else begin
                    w1 = watched_lit1[scan_clause_q];
                    w2 = watched_lit2[scan_clause_q];
                    cstart = clause_start[scan_clause_q];
                    clen = clause_len[scan_clause_q];

                    if (scan_list_sel_q == 1'b0) begin
                        lit_watch = lit_mem[w1];
                        lit_other = lit_mem[w2];
                    end else begin
                        lit_watch = lit_mem[w2];
                        lit_other = lit_mem[w1];
                    end

                    other_truth = lit_truth(lit_other);

                    if (other_truth == 2'b10 || lit_truth(lit_watch) != 2'b01) begin
                        scan_prev_d = scan_clause_q;
                        scan_clause_d = (scan_list_sel_q == 1'b0) ? watch_next1[scan_clause_q] : watch_next2[scan_clause_q];
                    end else begin
                        found_repl = 1'b0;
                        repl_idx = '0;
                        repl_lit = '0;
                        
                        for (int j = 0; j < MAX_CLAUSE_LEN; j++) begin
                            if (!found_repl && $unsigned(j) < $unsigned(clen)) begin
                                if (cstart + j != w1 && cstart + j != w2) begin
                                    l = lit_mem[cstart + j];
                                    if (lit_truth(l) != 2'b01) begin
                                        found_repl = 1'b1;
                                        repl_idx = cstart + j;
                                        repl_lit = l;
                                    end
                                end
                            end
                        end

                        if (found_repl) begin
                            // Watch replacement handled in always_ff.
                            // BUT if other watched literal is false, clause is now unit on repl_lit!
                            if (other_truth == 2'b01) begin
                                // Other watched is FALSE, propagate the replacement literal
                                propagated_valid = 1'b1;
                                propagated_var = repl_lit;
                                if (DEBUG >= 1) $display("[PSE] Unit %0d from Clause %0d (after repl)", repl_lit, scan_clause_q);
                            end
                            scan_clause_d = (scan_list_sel_q == 1'b0) ? watch_next1[scan_clause_q] : watch_next2[scan_clause_q];
                        end else if (other_truth == 2'b00) begin
                            // Unit propagation
                            propagated_valid = 1'b1;
                            propagated_var = lit_other;
                            if (DEBUG >= 1) $display("[PSE] Unit %0d from Clause %0d", lit_other, scan_clause_q);
                            scan_prev_d = scan_clause_q;
                            scan_clause_d = (scan_list_sel_q == 1'b0) ? watch_next1[scan_clause_q] : watch_next2[scan_clause_q];
                        end else begin
                            // Conflict
                            conflict_detected_d = 1'b1;
                            if (DEBUG >= 1) $display("[PSE] Conflict in Clause %0d", scan_clause_q);
                            state_d = COMPLETE;
                        end
                    end
                end
            end

            COMPLETE: begin
                done = 1'b1;
                if (start) begin
                    if (initialized_q) state_d = SEED_DECISION;
                    else begin
                        reset_idx_d = '0;
                        state_d = RESET_WATCHES;
                    end
                end else if (!conflict_detected_q && !prop_empty) begin
                    state_d = DEQ_PROP;
                end else if (!start) begin
                    state_d = IDLE;
                end
            end

            UNDO_ASSIGNMENTS: begin
                // State transitions handled by always_ff override for sequential logic
                // But we default to holding state here
                state_d = UNDO_ASSIGNMENTS;
            end

            default: state_d = IDLE;
        endcase
    end

    // Sequential logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state_q <= IDLE;
            clause_count_q <= '0;
            lit_count_q <= '0;
            cur_clause_len_q <= '0;
            init_clause_idx_q <= '0;
            reset_idx_q <= '0;
            max_var_seen_q <= '0;
            scan_list_sel_q <= '0;
            scan_clause_q <= 16'hFFFF;
            scan_prev_q <= 16'hFFFF;
            cur_prop_lit_q <= '0;
            initialized_q <= 1'b0;
            conflict_detected_q <= 1'b0;
            prop_wr_ptr <= '0;
            prop_rd_ptr <= '0;
            registered_decision_q <= '0;
            trail_height_q <= '0;
            
            // RAM inference optimization: Remove async reset for large arrays
            // assign_state and watch_heads are cleared in RESET_WATCHES state
        end else begin
            $display("[PSE] State: %d Scan: %0d", state_q, scan_clause_q);
            state_q <= state_d;
            clause_count_q <= clause_count_d;
            lit_count_q <= lit_count_d;
            cur_clause_len_q <= cur_clause_len_d;
            init_clause_idx_q <= init_clause_idx_d;
            reset_idx_q <= reset_idx_d;
            max_var_seen_q <= max_var_seen_d;
            scan_list_sel_q <= scan_list_sel_d;
            scan_clause_q <= scan_clause_d;
            scan_prev_q <= scan_prev_d;
            cur_prop_lit_q <= cur_prop_lit_d;
            initialized_q <= initialized_d;
            conflict_detected_q <= conflict_detected_d;

            // Capture decision_var when start is high (before transitioning to SEED_DECISION)
            if (start) begin
                registered_decision_q <= decision_var;
            end

            // Load clause literals
            if (load_fire) begin
                lit_mem[lit_count_q] <= load_literal;
                if (load_clause_end) begin
                    clause_start[clause_count_q] <= lit_count_q - cur_clause_len_q;
                    clause_len[clause_count_q] <= cur_clause_len_q + 1'b1;
                end
            end

            // Reset watches
            // Reset watches and state
            if (state_q == RESET_WATCHES) begin
                // Clear assignment state sequentially (enables RAM inference)
                if (reset_idx_q < MAX_VARS) begin
                    assign_state[reset_idx_q] <= 2'b00;
                end
                
                if (reset_idx_q < MAX_CLAUSES) begin
                    watched_lit1[reset_idx_q] <= 16'hFFFF;
                    watched_lit2[reset_idx_q] <= 16'hFFFF;
                    watch_next1[reset_idx_q] <= 16'hFFFF;
                    watch_next2[reset_idx_q] <= 16'hFFFF;
                end else if (reset_idx_q < MAX_CLAUSES + 2*MAX_VARS) begin
                    watch_head1[reset_idx_q - MAX_CLAUSES] <= 16'hFFFF;
                    watch_head2[reset_idx_q - MAX_CLAUSES] <= 16'hFFFF;
                end
            end

            // Initialize watches
            if (state_q == INIT_WATCHES && init_clause_idx_q < clause_count_q) begin
                watched_lit1[init_c] <= init_w1_addr;
                watched_lit2[init_c] <= init_w2_addr;
                watch_next1[init_c] <= watch_head1[init_idx1];
                watch_head1[init_idx1] <= init_c;
                watch_next2[init_c] <= watch_head2[init_idx2];
                watch_head2[init_idx2] <= init_c;
            end

            // Seed decision - add to prop queue, assign, and record in trail
            if (state_q == SEED_DECISION && registered_decision_q != 0) begin
                if (seed_v > 0 && seed_v <= MAX_VARS && assign_state[seed_v-1] == 2'b00) begin
                    assign_state[seed_v-1] <= (registered_decision_q < 0) ? 2'b01 : 2'b10;
                    prop_queue[prop_wr_ptr] <= registered_decision_q;
                    prop_wr_ptr <= prop_wr_ptr + 1;
                    // Record in trail for backtracking
                    trail_mem[trail_height_q] <= registered_decision_q;
                    trail_height_q <= trail_height_q + 1;
                end
            end

            // Pop from prop queue
            if (state_q == DEQ_PROP && !prop_empty) begin
                prop_rd_ptr <= prop_rd_ptr + 1;
            end

            // Unit propagation - assign, enqueue, and record in trail
            if (propagated_valid) begin
                if (prop_v > 0 && prop_v <= MAX_VARS && assign_state[prop_v-1] == 2'b00) begin
                    assign_state[prop_v-1] <= (propagated_var < 0) ? 2'b01 : 2'b10;
                    prop_queue[prop_wr_ptr] <= propagated_var;
                    prop_wr_ptr <= prop_wr_ptr + 1;
                    // Record in trail for backtracking
                    trail_mem[trail_height_q] <= propagated_var;
                    trail_height_q <= trail_height_q + 1;
                end
            end

            // Undo assignments to specific height (level-aware backtracking)
            // This undoes ALL assignments above target height in one cycle
            // Sequential Undo Logic
            // If undo requested, take control and switch to UNDO_ASSIGNMENTS
            if (undo_enable && trail_height_q > undo_to_height && state_q != UNDO_ASSIGNMENTS) begin
                state_q <= UNDO_ASSIGNMENTS;
                conflict_detected_q <= 1'b0;
                prop_wr_ptr <= '0;
                prop_rd_ptr <= '0;
                // initialized_q <= 1'b0; // Force watch reinitialization
            end

            // Perform sequential undo (one variable per cycle)
            if (state_q == UNDO_ASSIGNMENTS) begin
                if (trail_height_q > undo_to_height) begin
                    // Read trail and clear assignment
                    // Uses pre-calculated undo_var_idx from continuous assignment
                    
                    if (undo_var_idx > 0 && undo_var_idx <= MAX_VARS) begin
                        assign_state[undo_var_idx - 1] <= 2'b00;
                    end
                    trail_height_q <= trail_height_q - 1;
                    
                    // Stay in UNDO state until done
                    state_q <= UNDO_ASSIGNMENTS; 
                end else begin
                    // Done
                    state_q <= IDLE;
                end
            end
        end
    end

    assign max_var_seen = max_var_seen_q;
    assign trail_height = trail_height_q;

endmodule
