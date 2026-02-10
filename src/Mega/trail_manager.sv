// Trail Manager: Maintains assignment trail with decision level markers for backtracking
//
// INVARIANT: Trail Consistency
// 1. The Trail is an ordered log of ALL assignments (Decisions + Propagations).
// 2. Decision Levels must be monotonically increasing.
// 3. No variable may appear more than once in the active trail section (0 to height-1).
// 4. Backtracking strictly removes the suffix of the trail down to the target level.

import mega_pkg::*;

module trail_manager #(
    parameter int MAX_VARS = 256
)(
    input  logic [31:0]    DEBUG,
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
    // logic [15:0] next_lvl_idx, // REMOVED BAD PORT
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


    
    // Module-scope temporaries to avoid synthesis warnings
    logic [15:0] next_lvl_idx; // Added declaration
    mega_pkg::trail_entry_t entry_query;
    mega_pkg::trail_entry_t entry_read;
    mega_pkg::trail_entry_t current_entry;
    mega_pkg::trail_entry_t trunc_search_entry;
    mega_pkg::trail_entry_t trail0_entry; // For trail[0] access
    mega_pkg::trail_entry_t new_entry_push;
    mega_pkg::trail_entry_t bt_peek_entry; // For backtrack peek
    logic [15:0] trail_height_q, trail_height_d;
    logic [15:0] current_level_q, current_level_d;
    // logic [15:0] level_start [0:MAX_VARS-1];  // Index where each decision level starts
    
    // Lookup tables: variable -> level/value
    // Index is 1-based variable ID; 0 is unused.
    // Small arrays — inferred as registers at synthesis scale, LUTRAM at full scale
    logic [15:0] var_to_level [0:MAX_VARS];
    logic        var_to_value [0:MAX_VARS];
    logic [15:0] var_to_index [0:MAX_VARS];

    // Inferred LUTRAM for Level Start Indices
    // Tracks the starting trail index for each decision level
    // level_start[L] = index in 'trail' where level L begins.
    logic [15:0] level_start [0:MAX_VARS]; // Max levels = Max vars

    // Trail Stack (Inferred BRAM/LUTRAM depending on size)
    // We do NOT reset the whole array, allowing inference.
    // "trail" is read asynchronously (line 182) so it will infer DistRAM or BRAM with read-first/async logic.
    // If BRAM is required, read must be synchronous. Current usage (line 182) implies async read.
    // Given MAX_VARS is small (256), DistRAM is fine. For larger, we need to pipeline reads.
    // VeriSAT uses OCM (BRAM). For that, we'd need to change the read interface to be synchronous.
    // For now, let's stick to DistRAM for the trail as well unless we want to fix correct BRAM inference.
    // To fix BRAM inference, we must register the read address. But "trail_read_idx" comes from input.
    // Let's rely on DistRAM for now (simpler change) but remove the reset loop.
    // Trail Stack (Inferred BRAM/LUTRAM depending on size)
    // We do NOT reset the whole array, allowing inference.
    // "trail" is read asynchronously (line 182) so it will infer DistRAM or BRAM with read-first/async logic.
    // Use Struct for Verilator/Simulation compatibility (Testbench accesses members)
    mega_pkg::trail_entry_t trail [0:MAX_VARS-1];

    // logic [15:0] trail_height_q, trail_height_d; // Removed duplicate
    // logic [15:0] current_level_q, current_level_d; // Removed duplicate

    typedef enum logic [1:0] {IDLE, BACKTRACK_LOOP, BACKTRACK_COMPLETE} bt_state_t;
    bt_state_t bt_state_q, bt_state_d;
    logic [15:0] bt_index_q, bt_index_d;
    logic [15:0] bt_target_q, bt_target_d;

    assign height = trail_height_q;
    assign current_level = current_level_q;

    // Combinational query: Look up decision level for a given variable
    // Uses LUTRAM asynchronous read (O(1))
    always_comb begin
        query_level = 16'd0;
        query_valid = 1'b0;
        query_value = 1'b0;
        query_reason = 16'h0;
        entry_query = '0;

        if (query_var > 0 && query_var <= MAX_VARS) begin
            logic [15:0] lvl;
            logic [15:0] idx;
            lvl = var_to_level[query_var];
            idx = var_to_index[query_var];
            
            // Check for stale data:
            // If the recorded level is greater than current level, it's from a backtracked future.
            // NOTE: Do NOT check `lvl != 0` here — variables assigned at decision level 0
            // (e.g. unit propagations after learning) are valid and must return query_valid=1.
            // Stale/unassigned entries are already caught by:
            //   - idx >= trail_height_q (truncated or never-assigned garbage index)
            //   - lvl > current_level_q (from a backtracked future level)
            //   - trail[idx].variable != query_var (cross-check against actual trail contents)
            //   - Iterative backtrack sets var_to_index to 16'hFFFF (always >= trail_height)
            if (lvl <= current_level_q && idx < trail_height_q) begin
                entry_query = trail[idx];
                if (entry_query.variable == query_var) begin
                    query_valid = 1'b1;
                    query_level = lvl;
                    // Value/Reason would need separate LUTRAMs. 
                    query_value = var_to_value[query_var];
                    query_reason = 16'h0;
                end
`ifndef SYNTHESIS
                else if (DEBUG >= 3) begin
                    $display("[TRAIL QUERY] var=%0d FAIL trail_crosscheck: trail[%0d].variable=%0d != %0d (lvl=%0d cur_lvl=%0d height=%0d)", 
                        query_var, idx, entry_query.variable, query_var, lvl, current_level_q, trail_height_q);
                end
`endif
            end
`ifndef SYNTHESIS
            else if (DEBUG >= 3 && query_var > 0) begin
                $display("[TRAIL QUERY] var=%0d FAIL bounds: lvl=%0d cur_lvl=%0d idx=%0d height=%0d (lvl_ok=%b idx_ok=%b)", 
                    query_var, lvl, current_level_q, idx, trail_height_q, (lvl <= current_level_q), (idx < trail_height_q));
            end
`endif
        end
    end
    
    // Combinational trail read for external access
    always_comb begin
        logic [65:0] trail_read_raw; // Flattened temp (32+1+16+1+16 = 66 bits)
        
        entry_read = '0;
        trail_read_raw = '0;
        
        if (trail_read_idx < trail_height_q) begin
            entry_read = trail[trail_read_idx];            // Assign from struct array
            trail_read_raw = entry_read; // Pack for output if needed? Wait. trail_read_raw is local temp.
            // Actually trail_read_raw was used to unpack.
            // Now we read struct directly.
            
            trail_read_var        = entry_read.variable;
            trail_read_value      = entry_read.value;
            trail_read_level      = entry_read.level;
            trail_read_is_decision = entry_read.is_decision;
            trail_read_reason      = entry_read.reason;
        end else begin
            trail_read_var        = '0;
            trail_read_value      = 1'b0;
            trail_read_level      = '0;
            trail_read_is_decision = 1'b0;
            trail_read_reason      = 16'hFFFF;
        end
    end
    
    // Main Control Logic
    always_comb begin
        // default next state
        trail_height_d = trail_height_q;
        current_level_d = current_level_q;
        bt_state_d = bt_state_q;
        bt_index_d = bt_index_q;
        bt_target_d = bt_target_q;
        
        backtrack_done = 1'b0;
        backtrack_valid = 1'b0;
        backtrack_var = '0;
        backtrack_value = 1'b0;
        backtrack_is_decision = 1'b0;
        
        // Initialize module-scope temporaries
        bt_peek_entry = '0;
        next_lvl_idx = '0; // Initialize

        
        // Push Logic
        if (push && trail_height_q < MAX_VARS) begin
            trail_height_d = trail_height_q + 1'b1;
            if (push_is_decision) begin
                current_level_d = push_level;
            end
        end
        
        // Backtrack / Truncate Logic
        if (clear_all) begin
            trail_height_d = '0;
            current_level_d = '0;
            bt_state_d = IDLE;
        end else if (truncate_en) begin
            // O(1) Truncate using level_start array
            // We want to keep all assignments <= truncate_level_target.
            // The first assignment of level (target+1) starts at level_start[target+1].
            // So we set height to that start index.
            // Careful: if target+1 doesn't exist yet, level_start[target+1] might be junk?
            // "level_start" for current_level+1 is always valid (it's the current height pointer if we started a new level).
            // Actually, level_start[L] should point to where level L begins.
            // If we truncate to level T, the new height is the end of level T.
            // Which is level_start[T+1].
            
            // Robustness check: Ensure we don't read out of bounds or junk.
            // When we push a decision level change, we update level_start?
            
            current_level_d = truncate_level_target;
            
            // Use level_start to find new height instantly
             // We need start of (target + 1)
            // logic [15:0] next_lvl_idx; // Moved to top
            next_lvl_idx = level_start[truncate_level_target + 1];
            
            // Sanity bound: new height cannot exceed old height
            if (next_lvl_idx > trail_height_q) begin
                trail_height_d = trail_height_q; // Should not happen if level_start is correct
            end else begin
                trail_height_d = next_lvl_idx;
            end
            
            // Trigger background cleanup if needed? 
            // For now, we rely on "lvl <= current_level" check in query to handle stale var_to_level entries.
            // We do NOT trigger manual backtrack loop here to keep it O(1).
            bt_state_d = IDLE;
             
        end else begin
             // Standard Iterative Backtrack
             case (bt_state_q)
                 IDLE: begin
                     if (backtrack_en) begin
                         bt_target_d = backtrack_to_level;
                         bt_index_d = trail_height_q;
                         bt_state_d = BACKTRACK_LOOP;
                     end
                 end
                 
                 BACKTRACK_LOOP: begin
                     logic [15:0] idx;
                     logic [65:0] bt_peek_raw;
                     
                     idx = '0;
                     bt_peek_entry = '0;
                     bt_peek_raw = '0;
                     
                     idx = (bt_index_q > 0) ? bt_index_q - 1'b1 : 16'd0;
                     bt_peek_raw = trail[idx]; // Read as bits
                     bt_peek_entry = bt_peek_raw; // Assign to struct
                     
                     // Peek at the entry we are about to remove
                     if (bt_index_q > 0 && bt_peek_entry.level > bt_target_q) begin
                         bt_index_d = idx; // Decrement index
                         backtrack_valid = 1'b1;
                         backtrack_var = bt_peek_entry.variable;
                         backtrack_value = bt_peek_entry.value;
                         backtrack_is_decision = bt_peek_entry.is_decision;
                         // var_to_level cleanup happens in always_ff
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
             endcase
        end
    end
    
    // Sequential Logic (Writes)
    integer i;
    always_ff @(posedge clk) begin
        if (reset) begin
            trail_height_q <= '0;
            current_level_q <= '0;
            bt_state_q <= IDLE;
            bt_index_q <= '0;
            bt_target_q <= '0;
            // Note: We do NOT reset var_to_level or trail to allow RAM inference.
            // level_start[0] should be 0.
             level_start[0] <= 16'd0;
             level_start[1] <= 16'd0; // Initialize next potential
        end else begin
            trail_height_q <= trail_height_d;
            current_level_q <= current_level_d;
            bt_state_q <= bt_state_d;
            bt_index_q <= bt_index_d;
            bt_target_q <= bt_target_d;

            // --- Trail Write Logic ---
            if (push && trail_height_q < MAX_VARS) begin
                 // Write new entry
                 // Write new entry using temporary variable to satisfy Yosys
                 new_entry_push.variable = push_var;
                 new_entry_push.value = push_value;
                 new_entry_push.level = push_level;
                 new_entry_push.is_decision = push_is_decision;
                 new_entry_push.reason = push_reason;
                 trail[trail_height_q] <= new_entry_push;
                 
                 // Update var_to_level/value (Synchronous Write)
                 var_to_level[push_var] <= push_level;
                 var_to_value[push_var] <= push_value;
                 var_to_index[push_var] <= trail_height_q;
                 
                 // Update level_start logic
                 // If we are starting a NEW level (first assignment of level L),
                 // record its start index.
                 // We know it's a new level if push_is_decision is true?
                 // Or if push_level != current_level?
                 // Usually decision starts the level.
                 
                 // If this is the FIRST assignment of push_level...
                 // Complication: The "start" of level L is where level L-1 ended.
                 // Easier: Update level_start[push_level + 1] to "trail_height_q + 1".
                 // So that if we later truncate to push_level, we know where it ends.
                 // Yes: level_start[L+1] tracks the END of level L (or start of L+1).
                 
                 // We proactively update the pointer for the NEXT level.
                 level_start[push_level + 1] <= trail_height_q + 1'b1;
            end
            
            // --- Backtrack Cleanup Logic ---
            // If in BACKTRACK_LOOP, we are removing 'backtrack_var'.
            // We should clear its var_to_level entry.
            if (bt_state_q == BACKTRACK_LOOP && backtrack_valid) begin
                var_to_level[backtrack_var] <= 16'd0;
                var_to_value[backtrack_var] <= 1'b0;
                var_to_index[backtrack_var] <= 16'hFFFF;
            end
            
            // Clear All reset logic (Iterative? No, reset signal usually implies global)
            // But we can't global reset RAM.
            // Since clear_all resets height to 0, current_level to 0.
            // query logic checks (lvl <= current_level). 0 <= 0 is true.
            // But lvl 0 is usually "unassigned" or "root".
            // If we use lvl 0 for assignments, we have a problem.
            // Assuming levels start at 1?
            // Code assumes level 0 is root?
            // If clear_all is used, we might need a "generation" or just rely on overwrites.
            if (clear_all) begin
                level_start[0] <= 16'd0;
                level_start[1] <= 16'd0;
                // Cannot clear var_to_level array efficiently here.
                // Assuming system logic handles consistency.
            end
        end
    end

    // Aligned Debug Logging
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset for logging-specific signals if any
        end else begin
`ifndef SYNTHESIS
            if (DEBUG >= 3 && query_var > 0 && query_var <= 3) begin
                $display("[TRAIL FF] t=%0t query_var=%0d -> valid=%b level=%0d | var_to_level=%0d var_to_index=%0d cur_lvl=%0d height=%0d trail[idx].var=%0d",
                    $time, query_var, query_valid, query_level,
                    var_to_level[query_var], var_to_index[query_var], current_level_q, trail_height_q,
                    (var_to_index[query_var] < trail_height_q) ? trail[var_to_index[query_var]].variable : 32'hDEAD);
            end
            if (DEBUG >= 3 && push && trail_height_q < MAX_VARS) begin
                $display("[TRAIL FF PUSH] t=%0t var=%0d val=%b level=%0d idx=%0d is_dec=%b", 
                    $time, push_var, push_value, push_level, trail_height_q, push_is_decision);
            end
            if (DEBUG >= 3 && truncate_en) begin
                $display("[TRAIL FF TRUNC] t=%0t to_level=%0d level_start[%0d]=%0d new_height=%0d old_height=%0d",
                    $time, truncate_level_target, truncate_level_target+1, level_start[truncate_level_target+1], trail_height_d, trail_height_q);
            end
`endif
        end
    end

endmodule
