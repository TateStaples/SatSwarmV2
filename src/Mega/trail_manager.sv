// Trail Manager: Maintains assignment trail with decision level markers for backtracking
//
// INVARIANT: Trail Consistency
// 1. The Trail is an ordered log of ALL assignments (Decisions + Propagations).
// 2. Decision Levels must be monotonically increasing.
// 3. No variable may appear more than once in the active trail section (0 to height-1).
// 4. Backtracking strictly removes the suffix of the trail down to the target level.
module trail_manager #(
    parameter int MAX_VARS = 256
)(
    input  int           DEBUG,
    input  logic         clk,
    input  logic         reset,
    
    // Push assignment to trail
    input  logic         push,
    input  logic [31:0]  push_var,
    input  logic         push_value,
    input  logic [15:0]  push_level,
    input  logic         push_is_decision,  // Mark decision points
    input  logic [15:0]  push_reason,       // Reason Clause ID

    
    // Query trail state
    output logic [15:0]  height,
    output logic [15:0]  current_level,
    
    // Backtrack to a level
    input  logic         backtrack_en,
    input  logic [15:0]  backtrack_to_level,
    output logic         backtrack_done,
    output logic         backtrack_valid,      // High when outputting assignment to clear
    output logic [31:0]  backtrack_var,
    output logic         backtrack_value,     // Value of assignment being cleared
    output logic         backtrack_is_decision, // Whether this was a decision
    
    // Peek at decision levels
    // output logic [15:0]  level_markers [0:MAX_VARS-1],  // Trail index where each level starts
    
    // Query decision level for a specific variable (combinational)
    // Returns the decision level at which this variable was assigned, or 0 if unassigned
    input  logic [31:0]  query_var,
    output logic [15:0]  query_level,
    output logic         query_valid,  // High if query_var is currently assigned
    output logic         query_value,  // Value of assignment (if valid)
    output logic [15:0]  query_reason, // Reason for assignment

    
    // Trail read interface (for CAE backward iteration)
    input  logic [15:0]  trail_read_idx,        // Index to read (0 = oldest, height-1 = newest)
    output logic [31:0]  trail_read_var,        // Variable at that index
    output logic         trail_read_value,      // Value at that index
    output logic [15:0]  trail_read_level,      // Decision level at that index
    output logic         trail_read_is_decision, // Was this a decision?
    output logic [15:0]  trail_read_reason,      // Reason at that index

    
    // Clear all
    input  logic         clear_all,

    // Instant Truncate (O(1) Backtrack)
    input  logic         truncate_en,
    input  logic [15:0]  truncate_level_target
);

    typedef struct packed {
        logic [31:0] variable;
        logic        value;
        logic [15:0] level;
        logic        is_decision;
        logic [15:0] reason;
    } trail_entry_t;
    
    trail_entry_t trail [0:MAX_VARS-1];
    logic [15:0] trail_height_q, trail_height_d;
    logic [15:0] current_level_q, current_level_d;
    // logic [15:0] level_start [0:MAX_VARS-1];  // Index where each decision level starts
    
    // Lookup table: var_to_level[var_id] stores decision level of that variable
    // Index is var_id modulo MAX_VARS; requires careful collision handling
    // Alternative: Linear search through trail for correctness
    logic [15:0] var_to_level [0:MAX_VARS-1];  // Registered lookup table
    logic [15:0] var_to_level_d [0:MAX_VARS-1];  // Next-cycle version
    
    typedef enum logic [1:0] {IDLE, BACKTRACK_LOOP, BACKTRACK_COMPLETE} bt_state_t;
    bt_state_t bt_state_q, bt_state_d;
    logic [15:0] bt_index_q, bt_index_d;
    logic [15:0] bt_target_q, bt_target_d;
    
    assign height = trail_height_q;
    assign current_level = current_level_q;
    // assign level_markers = level_start;
    
    // Combinational query: Look up decision level for a given variable
    // Reverted to linear scan to ensure correctness and bypass potential LUT desync issues.
    always_comb begin
        logic [31:0] var_idx;
        trail_entry_t entry;

        var_idx = '0;
        entry = '0;
        
        query_level = 16'd0;
        query_valid = 1'b0;
        query_value = 1'b0;
        query_reason = 16'hFFFF;

        
        // Linear scan from newest to oldest (to find latest assignment)
        // Optimization: For small trail, this is fine. For large trail, LUT is needed.
        // Current issue suspect: LUT desync.
        // INVARIANT: Correctness over Performance
        // We use a linear scan (or trustworthy LUT) to ensure we NEVER return stale data.
        // Returning a stale "Unassigned" status when a variable is actually assigned
        // would break the solver's correctness (missed conflicts).
        for (int i = 0; i < MAX_VARS; i = i + 1) begin
            if (i < trail_height_q) begin
                // Reverse iterate? No, trail[i] has index i.
                // We want the most recent assignment. If variable appears multiple times (shouldn't), highest index wins?
                // Standard trail enforces unique variables.
                entry = trail[i];
                if (entry.variable == query_var) begin
                    query_valid = 1'b1;
                    query_level = entry.level;
                    query_value = entry.value;
                    query_reason = entry.reason;

                    // DEBUG QUERY
                     // if (query_var == 3) $display("[TRAIL DBG] Scan found Var 3 at Index %0d: Lvl=%0d", i, entry.level);
                end
            end
        end



        // Debug Log if Query Failed but we expected it to succeed (for Var 1)
        if (!query_valid && query_var == 1 && trail_height_q > 0) begin
             $display("[TRAIL DBG] Query Failed for Var 1. Height=%0d", trail_height_q);
             for(int k=0; k<20; k++) begin // limited dump
                 if (k < trail_height_q)
                     $display("   Trail[%0d]: Var=%0d Lvl=%0d", k, trail[k].variable, trail[k].level);
             end
        end

    end
    
    // Combinational trail read: Direct indexed access for CAE backward iteration
    always_comb begin
        // Initialize temps
        trail_entry_t entry;
        entry = '{default:'0};
        
        if (trail_read_idx < trail_height_q) begin
            trail_read_var        = trail[trail_read_idx].variable;
            trail_read_value      = trail[trail_read_idx].value;
            trail_read_level      = trail[trail_read_idx].level;
            trail_read_is_decision = trail[trail_read_idx].is_decision;
            trail_read_reason      = trail[trail_read_idx].reason;
        end else begin
            trail_read_var        = '0;
            trail_read_value      = 1'b0;
            trail_read_level      = '0;
            trail_read_is_decision = 1'b0;
            trail_read_reason      = 16'hFFFF;
        end
    end
    
    always_comb begin
        // Temporaries for BACKTRACK_LOOP (initialized to avoid latches)
        logic [15:0] bt_idx_tmp;
        trail_entry_t current_entry;

        trail_height_d = trail_height_q;
        current_level_d = current_level_q;
        bt_state_d = bt_state_q;
        bt_index_d = bt_index_q;
        bt_target_d = bt_target_q;
        
        // Initialize lookup table for next cycle (preserve current values)
        for (int j = 0; j < MAX_VARS; j = j + 1) begin
            var_to_level_d[j] = var_to_level[j];
        end
        
        backtrack_done = 1'b0;
        backtrack_valid = 1'b0;
        backtrack_var = '0;
        backtrack_value = 1'b0;
        backtrack_is_decision = 1'b0;
        backtrack_value = 1'b0;
        
        bt_idx_tmp = '0;
        current_entry = '{default:'0};
        
        // Push logic: update lookup table with new variable assignment
        if (push && trail_height_q < MAX_VARS) begin
            trail_height_d = trail_height_q + 1'b1;

            if (DEBUG >= 2) $strobe("[TRAIL] Push Var=%0d Value=%0d Level=%0d Reason=%04x", 
                    push_var, push_value, push_level, push_reason);

            // Update lookup table for this variable
            var_to_level_d[push_var % MAX_VARS] = push_level;

            if (push_is_decision) begin
                current_level_d = push_level;
            end
        end
        
        // Backtrack state machine
        case (bt_state_q)
            IDLE: begin
                if (backtrack_en) begin
                    bt_target_d = backtrack_to_level;
                    bt_index_d = trail_height_q;
                    bt_state_d = BACKTRACK_LOOP;
                end
            end
            

            
            BACKTRACK_LOOP: begin
                // Safe access with index check
                bt_idx_tmp = (bt_index_q > 0) ? bt_index_q - 1'b1 : 16'd0;
                current_entry = trail[bt_idx_tmp];
                
                if (bt_index_q > 0 && current_entry.level > bt_target_q) begin
                    bt_index_d = bt_index_q - 1'b1;
                    backtrack_valid = 1'b1;
                    backtrack_var = current_entry.variable;
                    backtrack_value = current_entry.value;
                    backtrack_is_decision = current_entry.is_decision;
                    // Clear lookup entry for undone variable (or set to level 0)
                    var_to_level_d[current_entry.variable % MAX_VARS] = 16'd0;
                end else begin
                    bt_state_d = BACKTRACK_COMPLETE;
                end
            end
            
            BACKTRACK_COMPLETE: begin
                trail_height_d = bt_index_q;
                current_level_d = bt_target_q;
                backtrack_done = 1'b1;
                bt_state_d = IDLE;
            end
            
            default: bt_state_d = IDLE;
        endcase
        
        if (clear_all) begin
            trail_height_d = '0;
            current_level_d = '0;
            bt_state_d = IDLE;
            for (int j = 0; j < MAX_VARS; j = j + 1) begin
                var_to_level_d[j] = 16'd0;
            end
        end else if (truncate_en) begin
            // O(1) Truncation Logic
            // We need to find the new height where level <= truncate_level_target.
            // Since the trail is sorted by level (monotonic), we can just scan/search.
            // For now, linear scan to find cut point.
            // Optimization: If we had a level_start array, this would be strictly O(1).
            // Current approach: Linear scan is O(N) combinational, BUT no cycles.
            
            trail_height_d = 0; // Default if all removed
            current_level_d = truncate_level_target;
            
            // Search backwards from current height
            for (int k = 0; k < MAX_VARS; k++) begin
                 // We want to find the LAST entry that has level <= target.
                 // So we search for the FIRST entry that has level > target?
                 // No, standard loop 0..height-1.
                 if (k < trail_height_q) begin
                     if (trail[k].level > truncate_level_target) begin
                         // This entry is invalid.
                         // The new height is k (exclusive of this entry).
                         // Since we want the first invalid index to be the new height.
                         // But we need to do this carefully.
                         // Let's iterate forward.
                         // If trail[k].level <= target, kept.
                         // If trail[k].level > target, cut here.
                         trail_height_d = k;
                         break; // Found cut point
                     end else begin
                         // This entry is valid, so new height is at least k+1
                         trail_height_d = k + 1;
                     end
                 end
            end
            
            // Reset Backtrack state just in case
            bt_state_d = IDLE;
        end
    end
    
    integer i, j;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            trail_height_q <= '0;
            current_level_q <= '0;
            bt_state_q <= IDLE;
            bt_index_q <= '0;
            bt_target_q <= '0;
            for (i = 0; i < MAX_VARS; i = i + 1) begin
                trail[i] <= '0;
                // level_start[i] <= '0;
                var_to_level[i] <= '0;
            end
        end else begin
            trail_height_q <= trail_height_d;
            current_level_q <= current_level_d;
            bt_state_q <= bt_state_d;
            bt_index_q <= bt_index_d;
            bt_target_q <= bt_target_d;
            
            // Update lookup table for next cycle
            for (i = 0; i < MAX_VARS; i = i + 1) begin
                var_to_level[i] <= var_to_level_d[i];
            end
            
            // CRITICAL: Use trail_height_q for the write index normally.
            // The combinational block already increments trail_height_d, so the sequential write
            // should happen at the CURRENT height (trail_height_q), not the next height (trail_height_d).
            // 
            // Exception: If backtrack completed THIS cycle (bt_state_q changes from BACKTRACK_COMPLETE to IDLE),
            // then trail_height_q is STALE and we need to use the new compacted height.
            // But since we're in @posedge, trail_height_q hasn't updated yet. We need to check if
            // backtrack is active and use bt_index_q as the write location.
            if (push && trail_height_q < MAX_VARS) begin
                // Compute effective write index: 
                // - If backtrack just ended this cycle, use the backtrack's final index
                // - Otherwise use current height
                logic [15:0] write_idx;
                if (bt_state_q == BACKTRACK_COMPLETE) begin
                    // Backtrack ending: write at the post-backtrack position
                    write_idx = bt_index_q;
                end else begin
                    // Normal push: write at current height
                    write_idx = trail_height_q;
                end
                
                for (int k = 0; k < MAX_VARS; k = k + 1) begin
                    if (k == write_idx) begin
                        trail[k].variable <= push_var;
                        trail[k].value <= push_value;
                        trail[k].level <= push_level;
                        trail[k].is_decision <= push_is_decision;
                        trail[k].reason <= push_reason;
                        $display("[TRAIL DBG] WRITING trail[%0d] <= Var %0d", k, push_var);
                    end
                end
            end

            if (clear_all) begin
                for (i = 0; i < MAX_VARS; i = i + 1) begin
                    // trail[i] <= '0;
                    // level_start[i] <= '0;
                    var_to_level[i] <= '0;
                end
            end
        end
    end

    // Aligned Debug Logging
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset for logging-specific signals if any
        end else begin
            if (push && trail_height_q < MAX_VARS) begin

            end
            // if (bt_state_q == BACKTRACK_LOOP && bt_index_q > 0 && trail[bt_index_q-1].level > bt_target_q) begin
            //      $display("[TRAIL DBG] Clearing Idx=%0d Var=%0d Lvl=%0d", bt_index_q - 1, trail[bt_index_q-1].variable, trail[bt_index_q-1].level);
            // end
        end
    end

endmodule
