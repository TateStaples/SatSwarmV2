// Conflict Analysis Engine (CAE)
// Implements full First-UIP clause learning algorithm with resolution.
// Walks the trail backward to find the Unique Implication Point.
//
// TIMING FIX: Replaced bulk combinatorial loops (64-wide scans over buffer)
// with incremental tracking registers and multi-cycle sequential iteration.
// Reference: VeriSAT (Tao & Cai, ICCAD 2025) pipelined CAE design.
//
// INVARIANT: First-UIP Clause Learning
// The learned clause MUST contain exactly one literal from the current decision level.
// This single literal is the First Unique Implication Point (UIP).
// All other literals in the learned clause must be from lower decision levels.
// This guarantees that after backtracking, the learned clause becomes Unit,
// forcing a new assignment and driving the search forward.
`timescale 1ns/1ps

module cae #(
    parameter int MAX_LITS = 16,
    parameter int LEVEL_W  = 16,
    parameter int MAX_VARS = MAX_LITS
)(
    input  logic [31:0]               DEBUG,
    input  logic                    clk,
    input  logic                    reset,

    // Start a conflict analysis round
    input  logic                    start,
    input  logic [LEVEL_W-1:0]      decision_level,

    // Conflict clause inputs
    input  logic [$clog2(MAX_LITS+1)-1:0]   conflict_len,
    input  logic signed [MAX_LITS-1:0][31:0] conflict_lits,

    // Learned clause outputs
    output logic                    learned_valid,
    output logic [$clog2(MAX_LITS+1)-1:0]   learned_len,
    output logic signed [MAX_LITS-1:0][31:0] learned_clause,

    // Backtrack info
    output logic [LEVEL_W-1:0]      backtrack_level,
    output logic                    unsat,
    output logic                    done,

    // Trail interface (for backward iteration)
    output logic [15:0]             trail_read_idx,
    input  logic [31:0]             trail_read_var,
    input  logic                    trail_read_value,
    input  logic [15:0]             trail_read_level,
    input  logic                    trail_read_is_decision,
    input  logic [15:0]             trail_read_reason,
    input  logic [15:0]             trail_height,

    // Reason clause interface (from PSE)
    output logic [31:0]             reason_query_var,
    input  logic [15:0]             reason_query_clause,
    input  logic                    reason_query_valid,

    // Clause read interface (from PSE)
    output logic [15:0]             clause_read_id,
    output logic [$clog2(MAX_LITS+1)-1:0]   clause_read_lit_idx,
    input  logic signed [31:0]      clause_read_literal,
    input  logic [15:0]             clause_read_len,
    
    // Level query interface (to Trail Manager)
    output logic [31:0]             level_query_var,
    input  logic [15:0]             level_query_levels
);

    typedef enum logic [3:0] {
        IDLE,
        INIT_CLAUSE,
        // CHECK_UIP removed: logic folded into INIT_CLAUSE and RESOLUTION end conditions
        FIND_RESOLVE_FETCH,  // Stage 1: present trail_scan_idx to trail_read_idx (pipeline fill)
        FIND_RESOLVE_CHECK,  // Stage 2: check registered trail data, decide match/skip
        RESOLUTION,
        FINALIZE_SCAN,
        FINALIZE_EMIT,
        DONE
    } state_e;

    state_e state_q, state_d;

    localparam int MAX_BUFFER = (MAX_VARS > 4 * MAX_LITS) ? MAX_VARS : 4 * MAX_LITS;
    localparam int BUF_COUNT_W = $clog2(MAX_BUFFER + 1);
    localparam int LEN_W = $clog2(MAX_LITS + 1);
    logic signed [31:0] buf_lits   [0:MAX_BUFFER-1];
    logic [LEVEL_W-1:0] buf_levels [0:MAX_BUFFER-1];
    logic [BUF_COUNT_W-1:0] buf_count_q, buf_count_d;

    localparam int VAR_W = $clog2(MAX_VARS + 1);
    logic [MAX_VARS:0] seen_q;          // "ever encountered" — for dedup, never cleared during resolution
    logic [MAX_VARS:0] active_in_buf_q; // "currently valid in buffer" — for FIND_RESOLVE, cleared on invalidation

    logic [MAX_BUFFER-1:0] buf_valid_q;

    logic [BUF_COUNT_W-1:0] valid_count_q, valid_count_d;

    // Incremental tracking registers (replace bulk combinatorial scans)
    logic [BUF_COUNT_W-1:0] count_at_level_q, count_at_level_d;
    logic [LEVEL_W-1:0]     sec_max_level_q, sec_max_level_d;

    // Resolution state
    logic [15:0] trail_scan_idx_q, trail_scan_idx_d;
    logic [$clog2(MAX_LITS+1)-1:0]  init_idx_q, init_idx_d;
    logic [$clog2(MAX_LITS+1)-1:0]  reason_lit_idx_q, reason_lit_idx_d;
    logic [15:0] reason_len_q, reason_len_d;
    logic [15:0] reason_clause_id_q, reason_clause_id_d;
    logic signed [31:0] resolve_lit_q, resolve_lit_d;
    logic [31:0] resolve_var_q, resolve_var_d;
    // Track if resolution added new decision-level literals that may be above scan position
    logic rescan_needed_q, rescan_needed_d;

    // FINALIZE_SCAN iteration state
    logic [BUF_COUNT_W-1:0] fin_scan_idx_q, fin_scan_idx_d;
    logic                   fin_found_uip_q, fin_found_uip_d;
    logic                   fin_found_sec_q, fin_found_sec_d;
    logic [LEN_W-1:0]       fin_out_idx_q, fin_out_idx_d;

    // Outputs
    logic [LEVEL_W-1:0] backtrack_d, backtrack_q;
    logic               unsat_d, unsat_q;
    logic               learned_valid_d, learned_valid_q;
    logic [LEN_W-1:0]   final_learned_len_q, final_learned_len_d;
    logic signed [31:0] output_clause_q [0:MAX_LITS-1];
    logic signed [31:0] output_clause_d [0:MAX_LITS-1];

    // Buffer overflow tracking
    logic               buf_overflow_q, buf_overflow_d;
    logic [15:0]        dropped_lits_q, dropped_lits_d;

    // Pipeline registers for trail read signals (breaks critical timing path)
    // trail_read_* from trail_manager are combinational; these registers add
    // 1 cycle latency but allow higher fmax at synthesis (targeting 125 MHz).
    logic [31:0] trail_read_var_r;
    logic        trail_read_value_r;
    logic [15:0] trail_read_level_r;
    logic        trail_read_is_decision_r;
    logic [15:0] trail_read_reason_r;

    integer i;

    function automatic logic [31:0] abs_lit(input logic signed [31:0] lit);
        abs_lit = (lit < 0) ? -lit : lit;
    endfunction

    // Temporary variables for always_comb
    logic signed [31:0] lit;
    logic [31:0]        var_idx;
    logic [31:0]        t_var;
    logic               found;
    logic signed [31:0] r_lit;
    logic [31:0]        r_var;
    logic               exists;

    always_comb begin
        state_d          = state_q;
        buf_count_d      = buf_count_q;
        valid_count_d    = valid_count_q;
        count_at_level_d = count_at_level_q;
        sec_max_level_d  = sec_max_level_q;
        trail_scan_idx_d = trail_scan_idx_q;
        init_idx_d       = init_idx_q;
        reason_lit_idx_d = reason_lit_idx_q;
        reason_len_d     = reason_len_q;
        reason_clause_id_d = reason_clause_id_q;
        resolve_lit_d    = resolve_lit_q;
        resolve_var_d    = resolve_var_q;
        rescan_needed_d  = rescan_needed_q;
        fin_scan_idx_d   = fin_scan_idx_q;
        fin_found_uip_d  = fin_found_uip_q;
        fin_found_sec_d  = fin_found_sec_q;
        fin_out_idx_d    = fin_out_idx_q;

        backtrack_d      = backtrack_q;
        unsat_d          = unsat_q;
        learned_valid_d  = learned_valid_q;
        buf_overflow_d   = buf_overflow_q;
        dropped_lits_d   = dropped_lits_q;
        final_learned_len_d = final_learned_len_q;
        for (int k=0; k<MAX_LITS; k++) output_clause_d[k] = output_clause_q[k];

        lit = '0;
        var_idx = '0;
        t_var = '0;
        found = 1'b0;
        r_lit = '0;
        r_var = '0;
        exists = 1'b0;

        done             = 1'b0;
        learned_valid    = learned_valid_q;
        learned_len      = final_learned_len_q;
        unsat            = unsat_q;

        for (int k=0; k<MAX_LITS; k++) learned_clause[k] = output_clause_q[k];

        trail_read_idx      = trail_scan_idx_q;
        reason_query_var    = resolve_var_q;
        clause_read_id      = reason_clause_id_q;
        clause_read_lit_idx = reason_lit_idx_q;

        // In FIND_RESOLVE_FETCH, override trail_read_idx to prefetch current scan position
        if (state_q == FIND_RESOLVE_FETCH)
            trail_read_idx = trail_scan_idx_q;

        if (state_q == INIT_CLAUSE) begin
            level_query_var = abs_lit(conflict_lits[init_idx_q]);
        end else begin
            level_query_var = abs_lit(clause_read_literal);
        end

        case (state_q)
            IDLE: begin
                if (start) begin
                    buf_count_d      = 0;
                    valid_count_d    = 0;
                    count_at_level_d = 0;
                    sec_max_level_d  = 0;
                    init_idx_d       = 0;
                    unsat_d          = 0;
                    learned_valid_d  = 0;
                    backtrack_d      = 0;
                    buf_overflow_d   = 0;
                    dropped_lits_d   = 0;
                    if (trail_height > 0)
                        trail_scan_idx_d = trail_height - 1;
                    else
                        trail_scan_idx_d = 0;
                    
                    if (decision_level == 0) begin
                        state_d = FINALIZE_EMIT;
                    end else begin
                        state_d = INIT_CLAUSE;
                    end
                end
            end

            INIT_CLAUSE: begin
                if (conflict_len == 0 || init_idx_q >= conflict_len) begin
                    // CHECK_UIP folded: count_at_level_q is final after all conflict literals processed
`ifndef SYNTHESIS
                    if (DEBUG >= 2) begin
                        $display("[CAE DBG] INIT_CLAUSE done: count_at_level=%0d dec_lvl=%0d buf_count=%0d", count_at_level_q, decision_level, buf_count_q);
                        for (int k=0; k<MAX_BUFFER; k++) begin
                            if (k < buf_count_q && buf_valid_q[k]) $display("  [CAE DBG]   buf[%0d]: lit=%0d lvl=%0d", k, buf_lits[k], buf_levels[k]);
                        end
                    end
`endif
                    if (count_at_level_q <= 1) begin
`ifndef SYNTHESIS
                        if (DEBUG >= 2) $display("[CAE DBG] UIP found after INIT: count_at_level=%0d", count_at_level_q);
`endif
                        fin_scan_idx_d  = 0;
                        fin_found_uip_d = 1'b0;
                        fin_found_sec_d = 1'b0;
                        fin_out_idx_d   = 1;
                        for (int k = 0; k < MAX_LITS; k++) output_clause_d[k] = 0;
                        state_d = FINALIZE_SCAN;
                    end else begin
                        state_d = FIND_RESOLVE_FETCH;
                    end
                end else begin
`ifndef SYNTHESIS
                    if (DEBUG >= 2 && init_idx_q == 0) $display("[CAE DBG] INIT_CLAUSE: Len=%0d Lits={%0d, %0d, %0d, ...} DecLvl=%0d", conflict_len, conflict_lits[0], conflict_lits[1], conflict_lits[2], decision_level);
`endif
                    // Buffer population + count_at_level/sec_max_level computed in always_ff (using level_query_levels)
                    init_idx_d = init_idx_q + 1;
                    state_d = INIT_CLAUSE;
                end
            end

            // FIND_RESOLVE pipeline: 2-stage (FETCH → CHECK) with registered trail reads.
            // Stage 1: present trail_scan_idx to trail_read_idx; data latched into _r regs.
            // Stage 2: use registered trail data to check for match.
            // This breaks the critical path through trail_manager async LUTRAM reads.
            FIND_RESOLVE_FETCH: begin
                // trail_read_idx = trail_scan_idx_q (set by default above)
                // Data will be available in trail_read_*_r next cycle.
                state_d = FIND_RESOLVE_CHECK;
            end

            FIND_RESOLVE_CHECK: begin
                // Use REGISTERED trail read data (latched from previous cycle)
                t_var = trail_read_var_r;
                found = 1'b0;

                if (t_var <= MAX_VARS && t_var != 0 &&
                    active_in_buf_q[t_var[VAR_W-1:0]] &&
                    trail_read_level_r == decision_level) begin
                    found = 1'b1;
                    resolve_var_d = t_var;
`ifndef SYNTHESIS
                    if (DEBUG >= 2) $display("[CAE DBG] FIND_RESOLVE_CHECK: Found resolve_var=%0d at trail_idx=%0d", t_var, trail_scan_idx_q);
`endif
                end

                if (found) begin
                    // FIX4: Override clause_read_id so PSE returns clause_read_len this same cycle,
                    // eliminating the FETCH_REASON + READ_REASON_LITS states (saves 2 cycles/resolution step)
                    clause_read_id = trail_read_reason_r;
                    if (trail_read_reason_r != 16'hFFFF) begin
                        reason_clause_id_d = trail_read_reason_r;
                        reason_len_d       = clause_read_len;  // Valid via overridden clause_read_id
                        reason_lit_idx_d   = 0;
                        rescan_needed_d    = 1'b0;  // Reset rescan flag for new resolution step
                        state_d = RESOLUTION;
                    end else begin
                        // Decision variable — no reason clause, finalize directly
                        fin_scan_idx_d  = 0;
                        fin_found_uip_d = 1'b0;
                        fin_found_sec_d = 1'b0;
                        fin_out_idx_d   = 1;
                        for (int k = 0; k < MAX_LITS; k++) output_clause_d[k] = 0;
                        state_d = FINALIZE_SCAN;
                    end
                end else begin
                    if (trail_scan_idx_q > 0) begin
                        trail_scan_idx_d = trail_scan_idx_q - 16'd1;
                        state_d = FIND_RESOLVE_FETCH;
                    end else begin
                        fin_scan_idx_d  = 0;
                        fin_found_uip_d = 1'b0;
                        fin_found_sec_d = 1'b0;
                        fin_out_idx_d   = 1;
                        for (int k = 0; k < MAX_LITS; k++) output_clause_d[k] = 0;
                        state_d = FINALIZE_SCAN;
                    end
                end
            end

            RESOLUTION: begin
                if (reason_lit_idx_q < reason_len_q) begin
                    r_lit = clause_read_literal;
                    r_var = abs_lit(r_lit);

                    if (r_var != resolve_var_q && r_var != 0) begin
                        exists = (r_var <= MAX_VARS) ? seen_q[r_var[VAR_W-1:0]] : 1'b0;

                        if (!exists) begin
                            if (buf_count_q < MAX_BUFFER) begin
                                buf_count_d = buf_count_q + 1;
                                valid_count_d = valid_count_q + 1;
                                // count_at_level and sec_max_level updated in always_ff
                            end else begin
                                buf_overflow_d = 1'b1;
                                dropped_lits_d = dropped_lits_q + 1;
`ifndef SYNTHESIS
                                $display("[CAE WARNING] Buffer overflow at cycle %0t: Dropped literal %0d. Total dropped: %0d", $time, r_var, dropped_lits_d);
`endif
                            end
                        end
                    end

                    reason_lit_idx_d = reason_lit_idx_q + 1;
                end else begin
                    // Done reading reason clause — CHECK_UIP folded inline
                    // The always_ff will decrement count_at_level_q by 1 this cycle
                    // (for the resolved variable). So effective count = count_at_level_q - 1.
                    // CHECK_UIP checks (effective <= 1), i.e., count_at_level_q <= 2.
                    if (count_at_level_q <= 2) begin
                        // UIP found after this resolution step
`ifndef SYNTHESIS
                        if (DEBUG >= 2) $display("[CAE DBG] UIP found after RESOLUTION: count_at_level=%0d (will be %0d)", count_at_level_q, count_at_level_q - 1);
`endif
                        fin_scan_idx_d  = 0;
                        fin_found_uip_d = 1'b0;
                        fin_found_sec_d = 1'b0;
                        fin_out_idx_d   = 1;
                        for (int k = 0; k < MAX_LITS; k++) output_clause_d[k] = 0;
                        state_d = FINALIZE_SCAN;
                    end else begin
                        state_d = FIND_RESOLVE_FETCH;
                    end

                    // FIX: If resolution added new decision-level literals, their trail
                    // positions may be ABOVE the current scan position (they may have been
                    // assigned later in the same BCP phase). Restart scan from the top
                    // to ensure they are found.
                    if (rescan_needed_q) begin
                        if (trail_height > 0)
                            trail_scan_idx_d = trail_height - 16'd1;
                        else
                            trail_scan_idx_d = 16'd0;
                    end else if (trail_scan_idx_q > 0) begin
                        trail_scan_idx_d = trail_scan_idx_q - 16'd1;
                    end
                end
            end

            // Multi-cycle sequential scan: one buffer entry per cycle
            FINALIZE_SCAN: begin
                if (fin_scan_idx_q < buf_count_q) begin
                    if (buf_valid_q[fin_scan_idx_q]) begin
                        if (abs_lit(buf_lits[fin_scan_idx_q]) != 0) begin
                            if (!fin_found_uip_q && buf_levels[fin_scan_idx_q] == decision_level) begin
                                output_clause_d[0] = buf_lits[fin_scan_idx_q];
                                fin_found_uip_d = 1'b1;
                            end else if (decision_level > 0 && !fin_found_sec_q && buf_levels[fin_scan_idx_q] == sec_max_level_q) begin
                                if (fin_out_idx_q > 1) begin
                                    output_clause_d[fin_out_idx_q] = output_clause_d[1];
                                    output_clause_d[1] = buf_lits[fin_scan_idx_q];
                                    fin_out_idx_d = fin_out_idx_q + 1;
                                end else begin
                                    output_clause_d[1] = buf_lits[fin_scan_idx_q];
                                    fin_out_idx_d = fin_out_idx_q + 1;
                                end
                                fin_found_sec_d = 1'b1;
                            end else begin
                                if (fin_out_idx_q < MAX_LITS) begin
                                    output_clause_d[fin_out_idx_q] = buf_lits[fin_scan_idx_q];
                                    fin_out_idx_d = fin_out_idx_q + 1;
                                end
                            end
                        end
                    end
                    fin_scan_idx_d = fin_scan_idx_q + 1;
                end else begin
                    final_learned_len_d = fin_out_idx_q;
                    state_d = FINALIZE_EMIT;
                end
            end

            FINALIZE_EMIT: begin
                unsat_d = (valid_count_q == 0) || (decision_level == 0);
                backtrack_d = sec_max_level_q;
                learned_valid_d = 1'b1;

`ifndef SYNTHESIS
                if (DEBUG >= 1) begin
                     $display("[hw_trace] [CAE] Learned Clause: [%0d, %0d, ...] Backtrack to: %0d Trail Height: %0d",
                              output_clause_d[0], ((fin_out_idx_q > 1) ? output_clause_d[1] : 0),
                              sec_max_level_q, trail_height);
                end
                // === CAE LEARNED CLAUSE VALIDATION ===
                if (decision_level > 0) begin
                    int uip_count_v;
                    int total_lits_v;
                    uip_count_v = 0;
                    total_lits_v = 0;
                    for (int k = 0; k < MAX_BUFFER; k++) begin
                        if (k < buf_count_q && buf_valid_q[k] && abs_lit(buf_lits[k]) != 0) begin
                            total_lits_v = total_lits_v + 1;
                            if (buf_levels[k] == decision_level)
                                uip_count_v = uip_count_v + 1;
                            if (buf_levels[k] > decision_level)
                                $display("[CAE VALIDATE ERROR] lit=%0d has level=%0d > decision_level=%0d!", buf_lits[k], buf_levels[k], decision_level);
                        end
                    end
                    if (uip_count_v != 1)
                        $display("[CAE VALIDATE ERROR] Expected exactly 1 UIP literal at decision_level=%0d, found %0d (total_lits=%0d, valid_count=%0d)", decision_level, uip_count_v, total_lits_v, valid_count_q);
                    if (total_lits_v != valid_count_q)
                        $display("[CAE VALIDATE WARN] total_lits=%0d != valid_count=%0d", total_lits_v, valid_count_q);
                    if (DEBUG >= 2) begin
                        $display("[CAE VALIDATE] Learned clause dump (dec_lvl=%0d, valid_count=%0d, buf_count=%0d):", decision_level, valid_count_q, buf_count_q);
                        for (int k = 0; k < MAX_BUFFER; k++) begin
                            if (k < buf_count_q && buf_valid_q[k])
                                $display("  buf[%0d]: lit=%0d level=%0d %s", k, buf_lits[k], buf_levels[k], (buf_levels[k] == decision_level) ? "<<UIP>>" : "");
                        end
                    end
                end
`endif
                state_d = DONE;
            end

            DONE: begin
                done = 1'b1;
                learned_len = final_learned_len_q;
                if (!start) state_d = IDLE;
            end

            default: state_d = IDLE;
        endcase
    end

    // Sequential block
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state_q <= IDLE;
            buf_count_q <= 0;
            seen_q <= '0;
            active_in_buf_q <= '0;
            buf_valid_q <= '0;
            valid_count_q <= 0;
            count_at_level_q <= 0;
            sec_max_level_q <= 0;
            trail_scan_idx_q <= 0;
            init_idx_q <= 0;
            reason_lit_idx_q <= 0;
            reason_len_q <= 0;
            reason_clause_id_q <= 0;
            resolve_lit_q <= 0;
            resolve_var_q <= 0;
            rescan_needed_q <= 0;
            fin_scan_idx_q <= 0;
            fin_found_uip_q <= 0;
            fin_found_sec_q <= 0;
            fin_out_idx_q <= 0;
            backtrack_q <= 0;
            unsat_q <= 0;
            learned_valid_q <= 0;
            final_learned_len_q <= 0;
            buf_overflow_q <= 1'b0;
            dropped_lits_q <= 16'b0;
            // Pipeline registers for trail read
            trail_read_var_r <= '0;
            trail_read_value_r <= 1'b0;
            trail_read_level_r <= '0;
            trail_read_is_decision_r <= 1'b0;
            trail_read_reason_r <= 16'hFFFF;
            for (int k = 0; k < MAX_BUFFER; k++) begin
                buf_lits[k] <= 0;
                buf_levels[k] <= 0;
            end
            for (int k = 0; k < MAX_LITS; k++) output_clause_q[k] <= 0;
        end else begin
            if (state_q == IDLE && start) begin
                seen_q <= '0;
                active_in_buf_q <= '0;
                buf_valid_q <= '0;
            end

            // Trail read pipeline registers: latch combinational trail outputs every cycle.
            // FIND_RESOLVE_FETCH presents the address; FIND_RESOLVE_CHECK reads these.
            trail_read_var_r         <= trail_read_var;
            trail_read_value_r       <= trail_read_value;
            trail_read_level_r       <= trail_read_level;
            trail_read_is_decision_r <= trail_read_is_decision;
            trail_read_reason_r      <= trail_read_reason;

            state_q <= state_d;
            buf_count_q <= buf_count_d;
            valid_count_q <= valid_count_d;
            count_at_level_q <= count_at_level_d;
            sec_max_level_q <= sec_max_level_d;
            trail_scan_idx_q <= trail_scan_idx_d;
            init_idx_q <= init_idx_d;
            reason_lit_idx_q <= reason_lit_idx_d;
            reason_len_q <= reason_len_d;
            reason_clause_id_q <= reason_clause_id_d;
            resolve_lit_q <= resolve_lit_d;
            resolve_var_q <= resolve_var_d;
            rescan_needed_q <= rescan_needed_d;
            fin_scan_idx_q <= fin_scan_idx_d;
            fin_found_uip_q <= fin_found_uip_d;
            fin_found_sec_q <= fin_found_sec_d;
            fin_out_idx_q <= fin_out_idx_d;
            backtrack_q <= backtrack_d;
            unsat_q <= unsat_d;
            learned_valid_q <= learned_valid_d;
            final_learned_len_q <= final_learned_len_d;
            buf_overflow_q <= buf_overflow_d;
            dropped_lits_q <= dropped_lits_d;
            for (int k = 0; k < MAX_LITS; k++) output_clause_q[k] <= output_clause_d[k];

            // --- INIT_CLAUSE: populate buffer with dedup, compute incremental counters ---
            if (state_q == INIT_CLAUSE && init_idx_q < conflict_len) begin
                 logic [31:0] v;
                 v = abs_lit(conflict_lits[init_idx_q]);
                 if (v <= MAX_VARS && v != 0 && !seen_q[v[VAR_W-1:0]]) begin
                     buf_lits[buf_count_q] <= conflict_lits[init_idx_q];
                     buf_levels[buf_count_q] <= level_query_levels;
                     buf_valid_q[buf_count_q] <= 1'b1;
                     seen_q[v[VAR_W-1:0]] <= 1'b1;
                     active_in_buf_q[v[VAR_W-1:0]] <= 1'b1;
                     
                     buf_count_q <= buf_count_q + 1;
                     valid_count_q <= valid_count_q + 1;
                     
                     if (level_query_levels == decision_level)
                         count_at_level_q <= count_at_level_q + 1;
                     else if (level_query_levels > sec_max_level_q)
                         sec_max_level_q <= level_query_levels;
                 end
            end

            // --- RESOLUTION: merge reason literals + invalidate resolved var ---
            else if (state_q == RESOLUTION) begin
                 if (reason_lit_idx_q < reason_len_q) begin
                     logic signed [31:0] r_lit_local;
                     logic [31:0] r_var_local;
                     logic exists_local;

                     r_lit_local = clause_read_literal;
                     r_var_local = abs_lit(r_lit_local);

                     if (r_var_local != resolve_var_q && r_var_local != 0) begin
                        exists_local = (r_var_local <= MAX_VARS) ? seen_q[r_var_local[VAR_W-1:0]] : 1'b0;

                        if (!exists_local) begin
                            if (buf_count_q < MAX_BUFFER) begin
                                buf_lits[buf_count_q] <= r_lit_local;
                                buf_levels[buf_count_q] <= level_query_levels;
                                buf_valid_q[buf_count_q] <= 1'b1;
                                seen_q[r_var_local[VAR_W-1:0]] <= 1'b1;
                                active_in_buf_q[r_var_local[VAR_W-1:0]] <= 1'b1;
`ifndef SYNTHESIS
                                if (DEBUG >= 2 && level_query_levels == decision_level)
                                    $display("[CAE FF] RESOLUTION ADD @dec_level: lit=%0d var=%0d level=%0d resolving_var=%0d clause=%0d lit_idx=%0d buf_idx=%0d",
                                             r_lit_local, r_var_local, level_query_levels, resolve_var_q, reason_clause_id_q, reason_lit_idx_q, buf_count_q);
`endif
                                if (level_query_levels == decision_level) begin
                                    count_at_level_q <= count_at_level_q + 1;
                                    rescan_needed_q <= 1'b1;  // May need to rescan trail for this new dec-level var
                                end else if (level_query_levels > sec_max_level_q)
                                    sec_max_level_q <= level_query_levels;
                            end else begin
                                buf_overflow_q <= 1'b1;
                                dropped_lits_q <= dropped_lits_q + 1;
`ifndef SYNTHESIS
                                $display("[CAE WARNING] Buffer overflow at cycle %0t: Dropped literal %0d. Total dropped: %0d", $time, r_var_local, dropped_lits_q + 1);
`endif
                            end
                        end
                    end
                 end else begin
                     // Invalidate resolved variable from buffer
                     for (int k = 0; k < MAX_BUFFER; k++) begin
                         if (k < buf_count_q && buf_valid_q[k] && abs_lit(buf_lits[k]) == resolve_var_q) begin
                             buf_valid_q[k] <= 1'b0;
                         end
                     end
                     // FIX: Clear active_in_buf_q but keep seen_q set.
                     // seen_q persists for the entire conflict analysis round (prevents
                     // re-addition of resolved variables from subsequent reason clauses).
                     // active_in_buf_q is cleared so FIND_RESOLVE won't try to re-resolve
                     // this variable.
                     if (resolve_var_q <= MAX_VARS && resolve_var_q != 0)
                         active_in_buf_q[resolve_var_q[VAR_W-1:0]] <= 1'b0;
                     if (valid_count_q > 0)
                         valid_count_q <= valid_count_q - 1;
                     // Resolved variable is always at decision_level
                     if (count_at_level_q > 0)
                         count_at_level_q <= count_at_level_q - 1;
                 end
            end

            // Overflow warning on finalize completion
`ifndef SYNTHESIS
            if (state_q == FINALIZE_EMIT && state_d == DONE && buf_overflow_q) begin
                $display("[CAE WARNING] Learned clause may be INCOMPLETE due to buffer overflow. Dropped %0d literals!", dropped_lits_q);
            end
            // CAE FSM resolution trace (always_ff, one per clock edge)
            if (DEBUG >= 2) begin
                if (state_q == FIND_RESOLVE_CHECK) begin
                    $display("[CAE FF] t=%0t FIND_CHECK: trail_var_r=%0d trail_lvl_r=%0d trail_reason_r=%h seen=%b count_at_level=%0d scan_idx=%0d",
                             $time, trail_read_var_r, trail_read_level_r, trail_read_reason_r,
                             (trail_read_var_r > 0 && trail_read_var_r <= MAX_VARS) ? seen_q[trail_read_var_r[VAR_W-1:0]] : 1'b0,
                             count_at_level_q, trail_scan_idx_q);
                end
                if (state_q == RESOLUTION && reason_lit_idx_q >= reason_len_q) begin
                    $display("[CAE FF] t=%0t RESOLVE_END: resolve_var=%0d count_at_level=%0d→%0d state_d=%s",
                             $time, resolve_var_q, count_at_level_q, count_at_level_q - 1,
                             (state_d == FINALIZE_SCAN) ? "FINALIZE" : "FIND_RESOLVE");
                end
            end
`endif
        end
    end

    assign backtrack_level = backtrack_q;

endmodule
