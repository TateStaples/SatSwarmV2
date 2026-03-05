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
    // FIX5: Registered (pipelined) versions for 125 MHz fmax — 1 cycle latency vs combinational versions above
    output logic         query_valid_r,
    output logic [15:0]  query_level_r,
    output logic         query_value_r,
    output logic [15:0]  query_reason_r,

    
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
    // ram_style="distributed" forces LUTRAM; without this hint Vivado dissolves these
    // into individual flip-flops.
    (* ram_style = "distributed" *) logic [15:0] var_to_level [0:MAX_VARS];
    (* ram_style = "distributed" *) logic        var_to_value [0:MAX_VARS];
    (* ram_style = "distributed" *) logic [15:0] var_to_index [0:MAX_VARS];

    // LUTRAM for Level Start Indices
    // level_start[L] = index in 'trail' where level L begins.
    (* ram_style = "distributed" *) logic [15:0] level_start [0:MAX_VARS];

    // Trail Stack — synthesis uses logic bits so Vivado can infer LUTRAM (async reads
    // prevent BRAM; struct arrays prevent LUTRAM inference without this split).
    // Simulation keeps the struct so debug `\`ifndef SYNTHESIS` blocks can access
    // .variable / .level etc. directly without casts.
    // Implicit packed SV assignment converts between the two representations wherever
    // entry_query/entry_read/new_entry_push (all trail_entry_t) are assigned from trail[].
`ifdef SYNTHESIS
    localparam int TRAIL_W = $bits(mega_pkg::trail_entry_t); // 66
    (* ram_style = "distributed" *) logic [TRAIL_W-1:0] trail [0:MAX_VARS-1];
`else
    mega_pkg::trail_entry_t trail [0:MAX_VARS-1];
`endif

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

    // FIX5: Registered (pipelined) query outputs — breaks the LUTRAM→comparator→BRAM→comparator
    // combinatorial chain for 125 MHz fmax. Consumer must issue query 1 cycle before reading _r result.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            query_valid_r  <= 1'b0;
            query_level_r  <= 16'd0;
            query_value_r  <= 1'b0;
            query_reason_r <= 16'h0;
        end else begin
            query_valid_r  <= query_valid;
            query_level_r  <= query_level;
            query_value_r  <= query_value;
            query_reason_r <= query_reason;
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
`ifndef SYNTHESIS
            if (DEBUG >= 1) $display("[TRAIL MANAGER] trail_height_d=0 via clear_all");
`endif
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
`ifndef SYNTHESIS
                         if (DEBUG >= 1) $display("[TRAIL MANAGER] ITERATIVE UNASSIGN: var=%0d level=%0d target=%0d idx=%0d", 
                                 bt_peek_entry.variable, bt_peek_entry.level, bt_target_q, bt_index_q);
`endif
                         // var_to_level cleanup happens in always_ff
                     end else begin
                         bt_state_d = BACKTRACK_COMPLETE;
                     end
                 end
                 
                 BACKTRACK_COMPLETE: begin
                     // If push fires simultaneously (folded APPEND_PUSH), account
                     // for the pushed entry: height = bt_index_q + 1.
                     if (push && bt_index_q < MAX_VARS) begin
                         trail_height_d = bt_index_q + 16'd1;
                     end else begin
                         trail_height_d = bt_index_q;
                     end
                     current_level_d = bt_target_q;
`ifndef SYNTHESIS
                     if (DEBUG >= 1) $display("[TRAIL MANAGER] trail_height_d=%0d via BACKTRACK_COMPLETE (push=%0b)", 
                                              (push && bt_index_q < MAX_VARS) ? bt_index_q + 16'd1 : bt_index_q, push);
                     if (DEBUG >= 1) $display("[TRAIL MANAGER] BACKTRACK_COMPLETE: current_level_d = %0d target = %0d idx = %0d", 
                                              bt_target_q, bt_target_q, bt_index_q);
`endif
                     backtrack_done = 1'b1;
                     bt_state_d = IDLE;
                 end
             endcase
        end
    end
    
    // ─── Sequential Logic ──────────────────────────────────────────────────────
    // Control registers (trail_height, bt_state, etc.) — no memory arrays here.
    always_ff @(posedge clk) begin
        if (reset) begin
            trail_height_q  <= '0;
            current_level_q <= '0;
            bt_state_q      <= IDLE;
            bt_index_q      <= '0;
            bt_target_q     <= '0;
        end else begin
            trail_height_q  <= trail_height_d;
            current_level_q <= current_level_d;
            bt_state_q      <= bt_state_d;
            bt_index_q      <= bt_index_d;
            bt_target_q     <= bt_target_d;
`ifndef SYNTHESIS
            if (DEBUG >= 1 && trail_height_q != trail_height_d)
                $display("[TRAIL MANAGER] trail_height_q changed from %0d to %0d",
                         trail_height_q, trail_height_d);
`endif
        end
    end

    // ─── trail[] write — dedicated block for BRAM/LUTRAM inference ────────────
    // Single write address per cycle; no async reset; no other arrays here.
    always_ff @(posedge clk) begin
        if (push && trail_height_q < MAX_VARS) begin
`ifndef SYNTHESIS
            // VALIDATION: Check for duplicate trail pushes (simulation only)
            if (push_var > 0 && push_var <= MAX_VARS) begin
                logic [15:0] dup_lvl, dup_idx;
                dup_lvl = var_to_level[push_var];
                dup_idx = var_to_index[push_var];
                if (dup_lvl <= current_level_q && dup_idx < trail_height_q &&
                    trail[dup_idx].variable == push_var)
                    $display("[TRAIL DUP-VALIDATE] ERROR: Pushing var=%0d but already on trail at idx=%0d lvl=%0d (current push lvl=%0d height=%0d)",
                             push_var, dup_idx, dup_lvl, push_level, trail_height_q);
            end
`endif
            // Compute single write address (post-backtrack or normal).
            begin : trail_wr_blk
                logic [15:0] widx;
                widx = (bt_state_q == BACKTRACK_COMPLETE) ? bt_index_q : trail_height_q;
`ifdef SYNTHESIS
                // Inline packed concatenation — no struct temp so Vivado infers LUTRAM.
                // Bit layout matches trail_entry_t packed order:
                //   [65:34] variable  [33] value  [32:17] level
                //   [16]    is_decision  [15:0] reason
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

    // ─── var_to_level[] / var_to_value[] — dedicated block ───────────────────
    // Push and backtrack write to the same variable address (never simultaneously),
    // so this remains single-port and infers as LUTRAM.
    always_ff @(posedge clk) begin
        if (push && trail_height_q < MAX_VARS) begin
            var_to_level[push_var] <= push_level;
            var_to_value[push_var] <= push_value;
        end else if (bt_state_q == BACKTRACK_LOOP && backtrack_valid) begin
            var_to_level[backtrack_var] <= 16'd0;
            var_to_value[backtrack_var] <= 1'b0;
        end
    end

    // ─── var_to_index[] — dedicated block ────────────────────────────────────
    always_ff @(posedge clk) begin
        if (push && trail_height_q < MAX_VARS) begin
            var_to_index[push_var] <=
                (bt_state_q == BACKTRACK_COMPLETE) ? bt_index_q : trail_height_q;
        end else if (bt_state_q == BACKTRACK_LOOP && backtrack_valid) begin
            var_to_index[backtrack_var] <= 16'hFFFF;
        end
    end

    // ─── level_start[] — dedicated block ─────────────────────────────────────
    // Writes: push (single address = push_level+1) and clear_all (index 0 and 1).
    // Reset initialises index 0/1 to 0.
    always_ff @(posedge clk) begin
        if (reset) begin
            level_start[0] <= 16'd0;
            level_start[1] <= 16'd0;
        end else if (clear_all) begin
            level_start[0] <= 16'd0;
            level_start[1] <= 16'd0;
        end else if (push && trail_height_q < MAX_VARS) begin
            level_start[push_level + 1] <=
                (bt_state_q == BACKTRACK_COMPLETE) ? bt_index_q + 1'b1 : trail_height_q + 1'b1;
        end
    end
    // ─────────────────────────────────────────────────────────────────────────

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
