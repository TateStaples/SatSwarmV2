// Conflict Analysis Engine (CAE)
// Implements full First-UIP clause learning algorithm with resolution.
// Walks the trail backward to find the Unique Implication Point.
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
    input  logic [4:0]              conflict_len,
    input  logic signed [MAX_LITS-1:0][31:0] conflict_lits,
    input  logic [MAX_LITS-1:0][LEVEL_W-1:0] conflict_levels,

    // Learned clause outputs
    output logic                    learned_valid,
    output logic [4:0]              learned_len,
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
    // We assume valid bit is not strictly needed if we trust the logic, 
    // or we can add it. Trail manager provides query_level.
);

    typedef enum logic [3:0] {
        IDLE,
        INIT_CLAUSE,
        COUNT_AT_LEVEL,
        FIND_RESOLVE,
        FETCH_REASON,
        READ_REASON_LITS,
        RESOLUTION,
        FINALIZE,
        DONE
    } state_e;

    state_e state_q, state_d;

    // Internal storage
    // Use a slightly larger buffer for resolution intermediate steps if needed,
    // but ultimately valid clauses must fit in MAX_LITS
    localparam int MAX_BUFFER = 2 * MAX_LITS;
    localparam int BUF_COUNT_W = $clog2(MAX_BUFFER + 1);
    localparam int LEN_W = $clog2(MAX_LITS + 1);
    logic signed [31:0] buf_lits   [0:MAX_BUFFER-1];
    logic [LEVEL_W-1:0] buf_levels [0:MAX_BUFFER-1];
    logic [BUF_COUNT_W-1:0] buf_count_q, buf_count_d;
    
    // Intermediate combinatorial wire for backtrack level
    logic [LEVEL_W-1:0] backtrack_level_comb;
    
    // Seen bit-vector: one bit per variable for O(1) exists-check
    localparam int VAR_W = $clog2(MAX_VARS + 1);
    logic [MAX_VARS:0] seen_q;
    
    // Buffer valid bits: replaces shift-compaction with invalidation
    logic [MAX_BUFFER-1:0] buf_valid_q;
    
    // Valid entry count (separate from buf_count_q which is now a high-water mark)
    logic [BUF_COUNT_W-1:0] valid_count_q, valid_count_d;
    
    // Resolution state
    logic [15:0] trail_scan_idx_q, trail_scan_idx_d;
    logic [$clog2(MAX_LITS+1)-1:0]  init_idx_q, init_idx_d;
    logic [$clog2(MAX_LITS+1)-1:0]  reason_lit_idx_q, reason_lit_idx_d;
    logic [15:0] reason_len_q, reason_len_d;
    logic [15:0] reason_clause_id_q, reason_clause_id_d;
    logic signed [31:0] resolve_lit_q, resolve_lit_d;
    logic [31:0] resolve_var_q, resolve_var_d;
    
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

    integer i;

    // Helper: Absolute value
    function automatic logic [31:0] abs_lit(input logic signed [31:0] lit);
        abs_lit = (lit < 0) ? -lit : lit;
    endfunction

    // Temporary variables for always_comb
    logic signed [31:0] lit;
    logic [31:0]        var_idx;
    int                 count;
    logic [31:0]        t_var;
    logic               found;
    logic signed [31:0] r_lit;
    logic [31:0]        r_var;
    logic               exists;
    logic [LEVEL_W-1:0] max_lvl, sec_max_lvl;

    always_comb begin
        // NEW: Pull up temporaries to avoid latches
        logic found_uip;
        logic signed [31:0] uip_lit;
        int out_idx;
        int next_count;

        state_d          = state_q;
        buf_count_d      = buf_count_q;
        valid_count_d    = valid_count_q;
        trail_scan_idx_d = trail_scan_idx_q;
        init_idx_d       = init_idx_q;
        reason_lit_idx_d = reason_lit_idx_q;
        reason_len_d     = reason_len_q;
        reason_clause_id_d = reason_clause_id_q;
        resolve_lit_d    = resolve_lit_q;
        resolve_var_d    = resolve_var_q;
        
        backtrack_d      = backtrack_q;
        unsat_d          = unsat_q;
        learned_valid_d  = learned_valid_q;
        buf_overflow_d   = buf_overflow_q;
        dropped_lits_d   = dropped_lits_q;
        final_learned_len_d = final_learned_len_q;
        for (int k=0; k<MAX_LITS; k++) output_clause_d[k] = output_clause_q[k];

        // Initialize temporary variables
        lit = '0;
        var_idx = '0;
        count = 0;
        t_var = '0;
        found = 1'b0;
        r_lit = '0;
        r_var = '0;
        exists = 1'b0;
        max_lvl = '0;
        sec_max_lvl = '0;
        
        // MOVED TO TOP

        // Default constraints
        done             = 1'b0;
        learned_valid    = learned_valid_q;
        learned_len      = final_learned_len_q; // Use finalized length (stable after DONE)
        unsat            = unsat_q;
        backtrack_level_comb = backtrack_d;
        // $display("[CAE OUTPUT] backtrack_level_comb=%0d, backtrack_d=%0d, backtrack_q=%0d, state_q=%0d", backtrack_level_comb, backtrack_d, backtrack_q, state_q);
        
        // Output clause mapping - use REGISTERED value for proper timing
        for (int k=0; k<MAX_LITS; k++) learned_clause[k] = output_clause_q[k];

        // Default values for temporaries
        found_uip = 1'b0;
        uip_lit = '0;
        out_idx = 0;
        next_count = 0;

        // Default interface values
        trail_read_idx   = trail_scan_idx_q;
        reason_query_var = resolve_var_q;
        clause_read_id   = reason_clause_id_q;
        clause_read_lit_idx = reason_lit_idx_q;
        
        // Drive level query from the literal we are currently reading in resolution
        // (Only relevant in RESOLUTION state, but safe to drive always)
        level_query_var = abs_lit(clause_read_literal);

        case (state_q)
            IDLE: begin
                if (start) begin
                    buf_count_d = 0;
                    valid_count_d = 0;
                    init_idx_d = 0;
                    unsat_d = 0;
                    learned_valid_d = 0;
                    backtrack_d = 0;
                    // Prepare to scan trail from newest to oldest
                    if (trail_height > 0)
                        trail_scan_idx_d = trail_height - 1;
                    else
                        trail_scan_idx_d = 0;
                        
                    // $strobe("[CAE INIT] Start Conflict Analysis: dec_lvl=%0d trail_height=%0d scan_start=%0d", decision_level, trail_height, (trail_height > 0) ? trail_height - 1 : 0);

                    state_d = INIT_CLAUSE;
                end
            end

            INIT_CLAUSE: begin
                // Copy conflict inputs to internal buffer
                // We can do this in one cycle if MAX_LITS is small (16)
                // For simplicity/safety, let's just do it combinationally
                // assuming conflict_lits is valid.
                
                // FIX: Check for empty conflict (shouldn't happen in valid flow but safe to handle)
                if (conflict_len == 0) begin
                    state_d = FINALIZE;
                end else begin
                    buf_count_d = conflict_len;
`ifndef SYNTHESIS
                    if (DEBUG >= 2) $display("[CAE DBG] INIT_CLAUSE: Len=%0d Lits={%0d, %0d, %0d, ...} Levels={%0d, %0d, %0d, ...} DecLvl=%0d", conflict_len, conflict_lits[0], conflict_lits[1], conflict_lits[2], conflict_levels[0], conflict_levels[1], conflict_levels[2], decision_level);
`endif
                    // Logic to set buf_lits moved to always_ff to avoid mixed drivers
                    state_d = COUNT_AT_LEVEL;
                end
            end

            COUNT_AT_LEVEL: begin
                // INVARIANT: Termination Condition
                // We stop resolution when 'count' == 1. This means only one literal
                // in the conflict buffer belongs to the current decision level (the UIP).
                // Count how many literals in buf are at current decision_level
                count = 0;
                for (int k = 0; k < MAX_BUFFER; k++) begin
                    if (k < buf_count_q && buf_valid_q[k] && buf_levels[k] == decision_level) begin
                        count++;
                    end
                end
                
`ifndef SYNTHESIS
                if (DEBUG >= 2) $display("[CAE DBG] COUNT: count=%0d dec_lvl=%0d buf_count=%0d", count, decision_level, buf_count_q);
                for (int k=0; k<MAX_BUFFER; k++) begin
                    if (k < buf_count_q && buf_valid_q[k]) if (DEBUG >= 2) $display("  [CAE DBG]   buf[%0d]: lit=%0d lvl=%0d", k, buf_lits[k], buf_levels[k]);
                end
`endif

    //            $display("[CAE DEBUG] count_at_level: count=%0d, dec_lvl=%0d, buf_count=%0d", count, decision_level, buf_count_q);
    /*
            for (int k = 0; k < 8; k++) begin
                if (k < buf_count_q)
                    $display("[CAE DEBUG]   Buf[%0d]: lit=%0d lvl=%0d", k, buf_lits[k], buf_levels[k]);
            end
*/
                if (count <= 1) begin
                    // 0 or 1 literal at max level -> First UIP found OR empty/unit conflict
        //            $display("[CAE DEBUG] Stopping analysis: count=%0d", count);
                    state_d = FINALIZE;
                end else begin
                    // Need resolution
                    state_d = FIND_RESOLVE;
                end
            end

            FIND_RESOLVE: begin
                // Walk trail backward to find the literal that was assigned most recently
                // and exists in our conflict buffer at the current decision level.
                t_var = trail_read_var;
                found = 1'b0;

                for (int k = 0; k < MAX_BUFFER; k++) begin
                    if (k < buf_count_q && buf_valid_q[k] &&
                        abs_lit(buf_lits[k]) == t_var && 
                        buf_levels[k] == decision_level) begin
                        found = 1'b1;
                        resolve_lit_d = buf_lits[k];
                        resolve_var_d = t_var;
                    end
                end

                if (found) begin
                   // $strobe("[CAE] Found candidate for resolution: var=%0d (lit=%0d) at index %0d", t_var, resolve_lit_d, trail_scan_idx_q);
                    state_d = FETCH_REASON;
                end else begin
                    // Debug scan
                    // $strobe("[CAE SCAN] idx=%0d var=%0d (looking in buffer for lvl %0d)", trail_scan_idx_q, t_var, decision_level);
                    
                    // Not found, step back in trail
                    if (trail_scan_idx_q > 0) begin
                        trail_scan_idx_d = trail_scan_idx_q - 16'd1;
                        state_d = FIND_RESOLVE;
                    end else begin
                        // Reached end of trail (index 0) without resolving down to 1 UIP.
                        // $strobe("[CAE] WARNING: Reached start of trail during resolution. buf_count=%0d dec_lvl=%0d", buf_count_q, decision_level);
                        
                        state_d = FINALIZE;
                    end
                end
            end

            FETCH_REASON: begin
                // Query PSE for reason clause
                // reason_query_var driven by resolve_var_q
                
                // CRITICAL FIX: Use Trail Manager as the Source of Truth for reasons.
                // PSE wipes the reason for "Decisions" (including Learned Clause pushes),
                // so directly querying PSE returns FFFF (Invalid) for learned variables.
                // The Trail always stores the correct reason provided during the push.
                if (trail_read_reason != 16'hFFFF) begin
                    reason_clause_id_d = trail_read_reason;
                    state_d = READ_REASON_LITS;
                    reason_lit_idx_d = 0;
                    
                    // Note: We still use reason_query mechanism to fetch LITERALS later?
                    // No, READ_REASON_LITS uses clause_read interface with clause_id.
                    // So we just needed the ID here.
                end else begin
                    // No reason clause (e.g. decision var, but we shouldn't be resolving decisions)
                    // Or error in tracking.
                    // $strobe("[CAE ERROR] Aborting resolution for var %0d: No reason clause (trail_reason=%h)", resolve_var_q, trail_read_reason);
                    state_d = FINALIZE;
                end
            end

            READ_REASON_LITS: begin
                // Read propagation clause length first
                // clause_read_id is set to reason_clause_id_q
                reason_len_d = clause_read_len;
                state_d = RESOLUTION;
                reason_lit_idx_d = 0;
            end

            RESOLUTION: begin
                // Iterate through reason clause literals and merge
                if (reason_lit_idx_q < reason_len_q) begin
                    r_lit = clause_read_literal;
                    r_var = abs_lit(r_lit);

                    // Ignore the resolved variable itself
                    if (r_var != resolve_var_q && r_var != 0) begin
                        // O(1) exists check via seen bit-vector
                        exists = (r_var <= MAX_VARS) ? seen_q[r_var[VAR_W-1:0]] : 1'b0;

                        if (!exists) begin
                            if (buf_count_q < MAX_BUFFER) begin
                                // Add to buffer
                                // buf_lits/buf_levels/seen_q/buf_valid_q updates in always_ff
                                
                                buf_count_d = buf_count_q + 1;
                                valid_count_d = valid_count_q + 1;
                            end else begin
                                // Buffer overflow: literal dropped
                                buf_overflow_d = 1'b1;
                                dropped_lits_d = dropped_lits_q + 1;
`ifndef SYNTHESIS
                                $display("[CAE WARNING] Buffer overflow at cycle %0t: Dropped literal %0d. Total dropped: %0d", $time, r_var, dropped_lits_d);
`endif
                            end
                        end
                    end
                    
                    // Increment and READ NEXT
                    reason_lit_idx_d = reason_lit_idx_q + 1;
                    // clause_read_lit_idx follows this next cycle
                end else begin
                    // Done merging reason literals.
                    // Invalidation of resolved variable handled in always_ff.
                    // buf_count_q stays as high-water mark (no compaction).
                    
                    state_d = COUNT_AT_LEVEL;
                    
                    // IMPORTANT: Advance trail scan pointer so we don't try to resolve 
                    // the same variable again (even though it's gone from the buffer, 
                    // wasting a cycle).
                    if (trail_scan_idx_q > 0)
                        trail_scan_idx_d = trail_scan_idx_q - 16'd1;
                end
            end

            FINALIZE: begin
                // $strobe("[CAE STATE] Entering FINALIZE state. state_q=%0d, decision_level=%0d", state_q, decision_level);
                // Identify UIP (literal at decision_level)
                max_lvl = 0;
                sec_max_lvl = 0;
                
                // UNSAT condition: when we can't backtrack further and still have a conflict
                // - Empty clause (valid_count_q == 0)
                // - OR Decision Level is 0 (Root Level Conflict). Any conflict at root is UNSAT.
                unsat_d = (valid_count_q == 0) || (decision_level == 16'd0);

                // First pass: find max level (should be decision_level)
                for (int k = 0; k < MAX_BUFFER; k++) begin
                    if (k < buf_count_q && buf_valid_q[k]) begin
                       if (buf_levels[k] > max_lvl) max_lvl = buf_levels[k];
                    end
                end

                // Second pass: find second max level (backtrack target)
                for (int k = 0; k < MAX_BUFFER; k++) begin
                    if (k < buf_count_q && buf_valid_q[k]) begin
                        if (buf_levels[k] != max_lvl && buf_levels[k] > sec_max_lvl)
                            sec_max_lvl = buf_levels[k];
                    end
                end

                // Debug: Print buffer contents during FINALIZE
                // $strobe("[CAE DEBUG FINALIZE] buf_count_q=%0d, max_lvl=%0d, sec_max_lvl=%0d", buf_count_q, max_lvl, sec_max_lvl);
                for (int k = 0; k < 8; k++) begin
                    if (k < buf_count_q && buf_valid_q[k]) begin
                        // $strobe("[CAE DEBUG FINALIZE]   buf[%0d]: lit=%0d lvl=%0d", k, buf_lits[k], buf_levels[k]);
                    end
                end

                // CRITICAL: Find UIP (literal at max_lvl), NEGATE it, place FIRST
                // Then copy remaining literals
                begin
                    // logic found_uip;     // MOVED TO TOP
                    // logic signed [31:0] uip_lit; // MOVED TO TOP
                    // int out_idx;             // MOVED TO TOP
                    
                    found_uip = 1'b0;
                    out_idx = 1;  // Start at 1, UIP goes at 0
                    
                    // Initialize output
                    for (int k = 0; k < MAX_LITS; k++) output_clause_d[k] = 0;
                    
                    for (int k = 0; k < MAX_BUFFER; k++) begin
                        if (k < buf_count_q && buf_valid_q[k]) begin
                            // GUARD: Skip Var 0 (should never appear)
                            if (abs_lit(buf_lits[k]) != 0) begin
                                if (!found_uip && buf_levels[k] == max_lvl) begin
                                    // This is the UIP - KEEP it and place first
                                    uip_lit = buf_lits[k];
                                    output_clause_d[0] = uip_lit;  // Keep as-is (already correct asserting form)
                                    found_uip = 1'b1;
                                    // $strobe("[CAE DEBUG FINALIZE] UIP found: lit=%0d (kept)", uip_lit);
                                end else begin
                                    // Non-UIP literals go after
                                    if (out_idx < MAX_LITS) begin
                                        output_clause_d[out_idx] = buf_lits[k];
                                        out_idx = out_idx + 1;
                                    end
                                end
                            end
                        end
                    end
                    
                    // Store the actual learned clause length
                    final_learned_len_d = out_idx;
                end
                
                // $strobe("[CAE DEBUG FINALIZE] output_clause_d: [%0d, %0d, ...] (UIP first)", output_clause_d[0], output_clause_d[1]);
                
                backtrack_d = sec_max_lvl;
                // $strobe("[CAE DEBUG FINALIZE] Setting backtrack_d = %0d", sec_max_lvl);
                // UNSAT condition: Empty clause OR Conflict at Level 0
                // If we have a conflict (valid entries > 0) but we are at decision_level 0,
                // it implies the conflict relies only on Level 0 assignments (facts).
                // This means the formula is UNSAT.
                unsat_d = (valid_count_q == 0) || (decision_level == 0);
                
                // [DEBUG] Detailed Conflict Info matching software format
`ifndef SYNTHESIS
                if (DEBUG >= 1 && learned_valid_d) begin
                     $display("[hw_trace] [CAE] Learned Clause: [%0d, %0d, ...] Backtrack to: %0d Trail Height: %0d", 
                              ((out_idx > 0) ? output_clause_d[0] : 0), ((out_idx > 1) ? output_clause_d[1] : 0), 
                              sec_max_lvl, trail_height);
                end
`endif
                // Note: Trail Length not directly available in CAE, using decision_level as proxy for depth context
                // $strobe("[CONFLICT_DEBUG] Conflict Clause: (resolved buf) | Learned UIP: %0d | Asserting Level: %0d | Current Level: %0d", 
                         // ((buf_count_q > 0) ? output_clause_d[0] : 0), sec_max_lvl, decision_level);

                // If we resolved, it's valid learning
                learned_valid_d = 1'b1;

                // Instead of immediately driving done=1 combinatorially, transition to intermediate state
                // that will drive done=1 on the NEXT cycle after values have been latched.
                state_d = DONE;
            end

            DONE: begin
                // Values have been latched, now drive done signal
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
            buf_valid_q <= '0;
            valid_count_q <= 0;
            trail_scan_idx_q <= 0;
            init_idx_q <= 0;
            reason_lit_idx_q <= 0;
            reason_len_q <= 0;
            reason_clause_id_q <= 0;
            resolve_lit_q <= 0;
            resolve_var_q <= 0;
            backtrack_q <= 0;
            unsat_q <= 0;
            learned_valid_q <= 0;
            final_learned_len_q <= 0;
            for (int k = 0; k < MAX_BUFFER; k++) begin
                buf_lits[k] <= 0;
                buf_levels[k] <= 0;
            end
            for (int k = 0; k < MAX_LITS; k++) output_clause_q[k] <= 0;
        end else begin
            state_q <= state_d;
            buf_count_q <= buf_count_d;
            valid_count_q <= valid_count_d;
            trail_scan_idx_q <= trail_scan_idx_d;
            init_idx_q <= init_idx_d;
            reason_lit_idx_q <= reason_lit_idx_d;
            reason_len_q <= reason_len_d;
            reason_clause_id_q <= reason_clause_id_d;
            resolve_lit_q <= resolve_lit_d;
            resolve_var_q <= resolve_var_d;
            backtrack_q <= backtrack_d;
            unsat_q <= unsat_d;
            learned_valid_q <= learned_valid_d;
            final_learned_len_q <= final_learned_len_d;
            for (int k = 0; k < MAX_LITS; k++) output_clause_q[k] <= output_clause_d[k];
            
            // Only update buffers in relevant states to save power/logic?
            // For now, always update (simplest logic)
            // But buffer write is indexed... 
            // NOTE: The `buf_lits[buf_count_q] = ...` in always_comb implies latches if not fully specified?
            // No, SV array assignment in always_comb is tricky.
            // Better to handle array updates sequentially.
            // Converting buffer updates to sequential:
            
                if (state_q == INIT_CLAUSE && conflict_len > 0) begin
                     int idx;
                     logic [MAX_VARS:0] seen_local;
                     logic [MAX_BUFFER-1:0] valid_local;
                     seen_local = '0;
                     valid_local = '0;
                     idx = 0;
                     for (int k = 0; k < MAX_BUFFER; k++) begin
                         if (k < conflict_len && conflict_lits[k] != 0) begin
                            logic [31:0] v;
                            v = abs_lit(conflict_lits[k]);
                            // O(1) dedup via seen_local bit-vector
                            if (v <= MAX_VARS && v != 0 && !seen_local[v[VAR_W-1:0]]) begin
                                buf_lits[idx] <= conflict_lits[k];
                                buf_levels[idx] <= conflict_levels[k];
                                valid_local[idx] = 1'b1;
                                seen_local[v[VAR_W-1:0]] = 1'b1;
                                idx++;
                            end
                         end
                     end
                     seen_q <= seen_local;
                     buf_valid_q <= valid_local;
                     buf_count_q <= idx;
                     valid_count_q <= idx;
                end else if (state_q == RESOLUTION) begin
                     if (reason_lit_idx_q < reason_len_q) begin
                         // Merge Logic
                         logic signed [31:0] r_lit_local;
                         logic [31:0] r_var_local;
                         logic exists_local;
                         
                         r_lit_local = clause_read_literal;
                         r_var_local = abs_lit(r_lit_local);
                         
                         if (r_var_local != resolve_var_q && r_var_local != 0) begin
                            // O(1) exists check via seen bit-vector
                            exists_local = (r_var_local <= MAX_VARS) ? seen_q[r_var_local[VAR_W-1:0]] : 1'b0;
                            
                            if (!exists_local) begin
                                if (buf_count_q < MAX_BUFFER) begin
                                    buf_lits[buf_count_q] <= r_lit_local;
                                    buf_levels[buf_count_q] <= level_query_levels;
                                    buf_valid_q[buf_count_q] <= 1'b1;
                                    seen_q[r_var_local[VAR_W-1:0]] <= 1'b1;
                                    // Note: count updates handled in always_comb
                                end else begin
                                    // Buffer overflow detected
                                    buf_overflow_q <= 1'b1;
                                    dropped_lits_q <= dropped_lits_q + 1;
`ifndef SYNTHESIS
                                    $display("[CAE WARNING] Buffer overflow at cycle %0t: Dropped literal %0d. Total dropped: %0d", $time, r_var_local, dropped_lits_q + 1);
`endif
                                end
                            end
                            // $display("[CAE SEQ] RESOLUTION merge: Adding lit=%0d at idx=%0d, level=%0d", r_lit_local, buf_count_q, level_query_levels);
                        end
                     end else begin
                         // Invalidate entries matching resolved variable (replaces shift-compaction)
                         for (int k = 0; k < MAX_BUFFER; k++) begin
                             if (k < buf_count_q && buf_valid_q[k] && abs_lit(buf_lits[k]) == resolve_var_q) begin
                                 buf_valid_q[k] <= 1'b0;
                             end
                         end
                         // Clear seen bit for resolved variable
                         if (resolve_var_q <= MAX_VARS && resolve_var_q != 0)
                             seen_q[resolve_var_q[VAR_W-1:0]] <= 1'b0;
                         // Decrement valid count (resolved var appears exactly once due to dedup)
                         if (valid_count_q > 0)
                             valid_count_q <= valid_count_q - 1;
                         // buf_count_q unchanged (high-water mark)
                     end
                end
        end
    end

    // Sequential Aligned Logging
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            buf_overflow_q <= 1'b0;
            dropped_lits_q <= 16'b0;
        end else begin
            buf_overflow_q <= buf_overflow_d;
            dropped_lits_q <= dropped_lits_d;
            
            if (state_q == FINALIZE && state_q != state_d) begin
                if (buf_overflow_q) begin
`ifndef SYNTHESIS
                    $display("[CAE WARNING] Learned clause may be INCOMPLETE due to buffer overflow. Dropped %0d literals!", dropped_lits_q);
`endif
                end
            end
        end
    end

    // Drive backtrack_level output from REGISTERED value (not combinatorial)
    // This ensures solver_core reads the correct value after it's been latched
    assign backtrack_level = backtrack_q;

endmodule
