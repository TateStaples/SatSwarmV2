`timescale 1ns/1ps
// Variable Decision Engine with Binary Heap (VDE Heap)
// Implements VSIDS-like selector with O(log N) decision using a Max-Heap.
// Based on VeriSAT spec: docs/specs/vde_heap_spec.md
module vde_heap #(
    parameter int MAX_VARS = 256,
    parameter int ACT_W    = 32,
    parameter int IDX_W    = $clog2(MAX_VARS) + 1
)(
    input  logic         clk,
    input  logic         reset,

    // Decision request
    input  logic         request,
    output logic         decision_valid,
    output logic [31:0]  decision_var,
    output logic         decision_phase,
    input  logic [3:0]   phase_offset,
    output logic         all_assigned,
    input  logic [31:0]  max_var,
    input  logic         clear_all,

    // Assignment bookkeeping (Hide = assign, Unhide = clear)
    input  logic         assign_valid,
    input  logic [31:0]  assign_var,
    input  logic         assign_value,
    input  logic         clear_valid,
    input  logic [31:0]  clear_var,

    // Activity updates
    input  logic         bump_valid,
    input  logic [31:0]  bump_var,
    
    // Multi-bump for learned clause (up to 8 vars)
    input  logic [3:0]   bump_count,
    input  logic [7:0][31:0] bump_vars,
    input  logic         decay,
    
    input  logic         unassign_all, // Reset assignments but KEEP SCORES

    // Status
    // Status
    output logic         busy,
    
    input  logic [31:0]    DEBUG
);

    // =========================================================================
    // Data Types
    // =========================================================================
    typedef struct packed {
        logic [ACT_W-1:0] score;
        logic [IDX_W-1:0] var_id;  // 1-indexed variable
    } heap_entry_t;

    typedef enum logic [3:0] {
        IDLE,
        DECIDE,
        HIDE_READ_POS,
        HIDE_SWAP,
        HIDE_BUBBLE_DOWN_READ,
        HIDE_BUBBLE_DOWN_SWAP,
        UNHIDE_READ_POS,
        UNHIDE_SWAP,
        UNHIDE_BUBBLE_UP_READ,
        UNHIDE_BUBBLE_UP_SWAP,
        BUMP_READ,
        BUMP_UPDATE,
        BUMP_BUBBLE_UP_READ,
        BUMP_BUBBLE_UP_SWAP,
        RESCALE,
        INIT_LOOP
    } state_e;

    // =========================================================================
    // Memory Arrays
    // =========================================================================
    localparam int ENTRY_W = ACT_W + IDX_W;
    // heap_entry_t heap_mem [0:MAX_VARS-1];
    // logic [$bits(heap_entry_t)-1:0] heap_mem [0:MAX_VARS-1];
    logic [ENTRY_W-1:0] heap_mem [0:MAX_VARS-1];
    logic [IDX_W-1:0] pos_mem [0:MAX_VARS-1];  // var_id (1-indexed) -> heap_index
    logic phase_hint [0:MAX_VARS-1];

    // =========================================================================
    // Registers
    // =========================================================================
    state_e state_q, state_d;
    logic [IDX_W-1:0] heap_size_q, heap_size_d;
    logic [IDX_W-1:0] idx_q, idx_d;        // Current index for bubble ops
    logic [IDX_W-1:0] target_idx;          // Parent/child index
    logic [31:0] pending_var_q, pending_var_d;
    logic pending_value_q, pending_value_d;

    // Bump queue for multi-bump
    logic [3:0] bump_queue_count_q, bump_queue_count_d;
    logic [7:0][31:0] bump_queue_q, bump_queue_d;

    // Lazy decay: bump increment
    logic [ACT_W-1:0] bump_increment_q, bump_increment_d;
    localparam logic [ACT_W-1:0] INITIAL_BUMP = 32'd10000;
    localparam logic [ACT_W-1:0] RESCALE_THRESHOLD = {ACT_W{1'b1}} - 32'd1000000; // Near overflow


    integer i;
    // Debug: count decisions to limit early instrumentation
    integer dbg_decision_count_q;


    // =========================================================================
    // Combinational Logic
    // =========================================================================
    always_comb begin
        state_d = state_q;
        heap_size_d = heap_size_q;
        idx_d = idx_q;
        pending_var_d = pending_var_q;
        pending_value_d = pending_value_q;
        bump_queue_count_d = bump_queue_count_q;
        bump_queue_d = bump_queue_q;
        bump_increment_d = bump_increment_q;
        top_entry = '0;
        
        // Hoisted temporaries to avoid latch inference and implicit declaration issues
        heap_entry_t top_entry;
        logic [IDX_W:0] c_left_idx, c_right_idx;
        logic [IDX_W-1:0] c_largest, c_parent_idx;
        logic c_swap_needed;
        heap_entry_t c_entry_left, c_entry_right, c_entry_largest, c_entry_parent, c_entry_current;

        c_left_idx = '0;
        c_right_idx = '0;
        c_largest = '0;
        c_parent_idx = '0;
        c_swap_needed = 0;
        c_entry_left = '0;
        c_entry_right = '0;
        c_entry_largest = '0;
        c_entry_parent = '0;
        c_entry_current = '0;
            

        decision_valid = 1'b0;
        decision_var = '0;
        decision_phase = 1'b0;
        all_assigned = 1'b0;
        busy = (state_q != IDLE);

        target_idx = '0;

        case (state_q)
            IDLE: begin
                if (unassign_all) begin
                    state_d = IDLE;
                end else if (assign_valid && assign_var != 0 && assign_var <= max_var) begin
                    // $display("VDE_DBG: IDLE -> Assign %0d", assign_var);
                    pending_var_d = assign_var;
                    pending_value_d = assign_value;
                    state_d = HIDE_READ_POS;
                end else if (clear_valid && clear_var != 0 && clear_var <= max_var) begin
                    pending_var_d = clear_var;
                    state_d = UNHIDE_READ_POS;
                end else if (bump_valid && bump_var != 0 && bump_var <= max_var) begin
                    pending_var_d = bump_var;
                    state_d = BUMP_READ;
                end else if (bump_count > 0) begin
                    bump_queue_d = bump_vars;
                    bump_queue_count_d = bump_count;
                    // Process first bump
                    pending_var_d = bump_vars[0];
                    state_d = BUMP_READ;
                end else if (request) begin
`ifndef SYNTHESIS
                    if (heap_size_q == 0) $strobe("VDE_DBG: Request received but heap_size=0. all_assigned will be high next cycle.");
`endif
                    state_d = DECIDE;
                end else if (decay) begin
                    bump_increment_d = bump_increment_q + (bump_increment_q >> 4);
                    if (bump_increment_d >= RESCALE_THRESHOLD) begin
                        state_d = RESCALE;
                        idx_d = '0;
                    end
                end
            end

            DECIDE: begin
                if (heap_size_q == 0) begin
                    all_assigned = 1'b1;
                    if (!request) state_d = IDLE;
                end else begin
                    // heap_entry_t top_entry; // Moved to module scope to avoid latch
                    top_entry = heap_mem[0];
                    decision_valid = 1'b1;
                    decision_var = top_entry.var_id;
                    // if (DEBUG >= 2) $display("VDE_DBG: DECIDE -> %0d (Score %0d)", decision_var, top_entry.score);
                    decision_phase = phase_hint[top_entry.var_id - 1] ^ phase_offset[0];
                    // Early decision instrumentation: print top candidates for first few decisions
                    if (dbg_decision_count_q < 5) begin
                        /*
                        int top_n;
                        int vh;
                        top_n = (heap_size_q < 6) ? heap_size_q : 6;
                        
                        if (DEBUG >= 2) $display("[VDE] Decide #%0d: var=%0d phase=%0d score=%0d heap_size=%0d",
                                 dbg_decision_count_q+1, decision_var, decision_phase, heap_mem[0].score, heap_size_q);
                        for (int k = 0; k < top_n; k++) begin
                            vh = heap_mem[k].var_id;
                            if (DEBUG >= 2) $display("[VDE]   Top[%0d]: var=%0d score=%0d phase_hint=%0d", k, vh, heap_mem[k].score, phase_hint[vh-1]);
                        end
                        */
                    end
                    if (!request) state_d = IDLE;
                end
            end

            // -----------------------------------------------------------------
            // HIDE (Assign) - O(log N)
            // -----------------------------------------------------------------
            HIDE_READ_POS: begin
                // Read position of variable to hide
                idx_d = pos_mem[pending_var_q - 1];
                if (pos_mem[pending_var_q - 1] < heap_size_q) begin
                    // $display("VDE_DBG: HIDE %0d. Pos %0d < Size %0d. Proceed.", pending_var_q, pos_mem[pending_var_q - 1], heap_size_q);
                    state_d = HIDE_SWAP;
                end else begin
                    // $display("VDE_DBG: HIDE %0d. Pos %0d >= Size %0d. Already hidden.", pending_var_q, pos_mem[pending_var_q - 1], heap_size_q);
                    state_d = IDLE;
                end
            end

            HIDE_SWAP: begin
                // Swap with last element, decrement size
                heap_size_d = heap_size_q - 1;
                // The bubble down will start from idx_q
                if (idx_q < heap_size_q - 1) begin
                    // Need to bubble down the swapped element
                    state_d = HIDE_BUBBLE_DOWN_READ;
                end else begin
                    state_d = IDLE;
                end
            end

            HIDE_BUBBLE_DOWN_READ: begin
                // Read children
                state_d = HIDE_BUBBLE_DOWN_SWAP;
            end

            HIDE_BUBBLE_DOWN_SWAP: begin
                // Compare and swap if needed
                c_left_idx = (idx_q << 1) + 1;
                c_right_idx = (idx_q << 1) + 2;
                c_largest = idx_q;

                // Read entries to temps first
                // Note: Indexing full array with dynamic index implies big MUX
                // If index out of bounds, result is undefined (X), which is fine for compare
                if (c_left_idx < MAX_VARS) c_entry_left = heap_mem[c_left_idx]; else c_entry_left = '0; 
                if (c_right_idx < MAX_VARS) c_entry_right = heap_mem[c_right_idx]; else c_entry_right = '0;
                if (c_largest < MAX_VARS) c_entry_largest = heap_mem[c_largest]; else c_entry_largest = '0;

                // Compare with Left Child
                if (c_left_idx < heap_size_d) begin
                    if (c_entry_left.score > c_entry_largest.score ||
                       (c_entry_left.score == c_entry_largest.score && 
                        c_entry_left.var_id < c_entry_largest.var_id)) begin
                        c_largest = c_left_idx[IDX_W-1:0];
                        // Update current largest entry for next comparison (Right)
                        c_entry_largest = c_entry_left;
                    end
                end

                // Compare with Right Child
                if (c_right_idx < heap_size_d) begin
                     if (c_entry_right.score > c_entry_largest.score ||
                        (c_entry_right.score == c_entry_largest.score && 
                         c_entry_right.var_id < c_entry_largest.var_id)) begin
                        c_largest = c_right_idx[IDX_W-1:0];
                    end
                end

                if (c_largest != idx_q) begin
                    idx_d = c_largest;
                    state_d = HIDE_BUBBLE_DOWN_READ;
                end else begin
                    state_d = IDLE;
                end
            end

            // -----------------------------------------------------------------
            // UNHIDE (Clear/Backtrack) - O(log N)
            // -----------------------------------------------------------------
            UNHIDE_READ_POS: begin
                idx_d = pos_mem[pending_var_q - 1];
                if (pos_mem[pending_var_q - 1] >= heap_size_q)
                    state_d = UNHIDE_SWAP;
                else
                    state_d = IDLE;
            end

            UNHIDE_SWAP: begin
                // Swap with element at heap_size, then increment size
                heap_size_d = heap_size_q + 1;
                // After swap, the unhidden var is at heap_size_q (old size), need bubble up
                idx_d = heap_size_q;
                state_d = UNHIDE_BUBBLE_UP_READ;
            end

            UNHIDE_BUBBLE_UP_READ: begin
                state_d = UNHIDE_BUBBLE_UP_SWAP;
            end

            UNHIDE_BUBBLE_UP_SWAP: begin
                if (idx_q > 0) begin
                    c_parent_idx = (idx_q - 1) >> 1;
                    c_swap_needed = 0;
                    
                    // Copy to temps to avoid dynamic indexing on struct fields
                    if (c_parent_idx < MAX_VARS) c_entry_parent = heap_mem[c_parent_idx]; else c_entry_parent = '0; 
                    if (idx_q < MAX_VARS) c_entry_current = heap_mem[idx_q]; else c_entry_current = '0;
                    
                    if (c_entry_parent.score < c_entry_current.score) c_swap_needed = 1;
                    else if (c_entry_parent.score == c_entry_current.score && 
                             c_entry_parent.var_id > c_entry_current.var_id) c_swap_needed = 1;

                    if (c_swap_needed) begin
                        idx_d = c_parent_idx;
                        state_d = UNHIDE_BUBBLE_UP_READ;
                    end else begin
                        state_d = IDLE;
                    end
                end else begin
                    state_d = IDLE;
                end
            end

            // -----------------------------------------------------------------
            // BUMP Activity - O(log N)
            // -----------------------------------------------------------------
            BUMP_READ: begin
                idx_d = pos_mem[pending_var_q - 1];
                state_d = BUMP_UPDATE;
            end

            BUMP_UPDATE: begin
                // Score is updated in sequential block
                // Only bubble up if in active region
                if (idx_q < heap_size_q) begin
                    state_d = BUMP_BUBBLE_UP_READ;
                end else begin
                    // Check bump queue
                    if (bump_queue_count_q > 1) begin
                        bump_queue_count_d = bump_queue_count_q - 1;
                        pending_var_d = bump_queue_q[1];
                        for (int j = 0; j < 7; j++) bump_queue_d[j] = bump_queue_q[j+1];
                        state_d = BUMP_READ;
                    end else begin
                        bump_queue_count_d = '0;
                        state_d = IDLE;
                    end
                end
            end

            BUMP_BUBBLE_UP_READ: begin
                state_d = BUMP_BUBBLE_UP_SWAP;
            end

            BUMP_BUBBLE_UP_SWAP: begin
                if (idx_q > 0) begin
                    c_parent_idx = (idx_q - 1) >> 1;
                    c_swap_needed = 0;
                    
                    if (c_parent_idx < MAX_VARS) c_entry_parent = heap_mem[c_parent_idx]; else c_entry_parent = '0; 
                    if (idx_q < MAX_VARS) c_entry_current = heap_mem[idx_q]; else c_entry_current = '0;
                    
                    if (c_entry_parent.score < c_entry_current.score) c_swap_needed = 1;
                    else if (c_entry_parent.score == c_entry_current.score && 
                             c_entry_parent.var_id > c_entry_current.var_id) c_swap_needed = 1;

                    if (c_swap_needed) begin
                        idx_d = c_parent_idx;
                        state_d = BUMP_BUBBLE_UP_READ;
                    end else begin
                        // Check bump queue
                        if (bump_queue_count_q > 1) begin
                            bump_queue_count_d = bump_queue_count_q - 1;
                            pending_var_d = bump_queue_q[1];
                            for (int j = 0; j < 7; j++) bump_queue_d[j] = bump_queue_q[j+1];
                            state_d = BUMP_READ;
                        end else begin
                            bump_queue_count_d = '0;
                            state_d = IDLE;
                        end
                    end
                end else begin
                    // At root
                    if (bump_queue_count_q > 1) begin
                        bump_queue_count_d = bump_queue_count_q - 1;
                        pending_var_d = bump_queue_q[1];
                        for (int j = 0; j < 7; j++) bump_queue_d[j] = bump_queue_q[j+1];
                        state_d = BUMP_READ;
                    end else begin
                        bump_queue_count_d = '0;
                        state_d = IDLE;
                    end
                end
            end

            // -----------------------------------------------------------------
            // RESCALE - O(N) but rare
            // -----------------------------------------------------------------
            RESCALE: begin
                if (idx_q < max_var) begin
                    idx_d = idx_q + 1;
                end else begin
                    bump_increment_d = INITIAL_BUMP;
                    state_d = IDLE;
                end
            end

            default: state_d = IDLE;
        endcase
    end

    // =========================================================================
    // Sequential Logic
    // =========================================================================
    
    // Temporaries (Moved to module scope to avoid Yosys implicit declaration issues)
    integer k_rot;
    integer v_ordered;
    
    // Temporaries for HIDE_SWAP
    logic [IDX_W-1:0] last_idx;
    heap_entry_t entry_at_idx, entry_at_last; 

    // Temporaries for HIDE_BUBBLE_DOWN_SWAP
    logic [IDX_W-1:0] s_left_idx, s_right_idx, s_largest;
    heap_entry_t s_entry_left, s_entry_right, s_entry_at_largest, s_entry_at_idx_hide;

    // Temporaries for UNHIDE_SWAP
    logic [IDX_W-1:0] s_size_idx;
    heap_entry_t s_entry_at_idx_unhide, s_entry_at_size;

    // Temporaries for UNHIDE_BUBBLE_UP_SWAP and BUMP_BUBBLE_UP_SWAP
    logic [IDX_W-1:0] s_parent_idx;
    logic s_swap_needed;
    heap_entry_t s_entry_parent, s_entry_current, s_entry_at_parent;

    // Temporaries for BUMP_UPDATE and RESCALE
    heap_entry_t temp_bump, temp_rescale;
    
    // Temporary for initialization loop
    heap_entry_t init_entry;

    always_ff @(posedge clk or posedge reset) begin
        // Declarations moved to module scope

        if (reset) begin
            state_q <= IDLE;
            // Start with empty heap - will be properly initialized by clear_all
            // when max_var is known (after CNF loading)
            heap_size_q <= '0;
            idx_q <= '0;
            pending_var_q <= '0;
            pending_value_q <= 1'b0;
            bump_queue_count_q <= '0;
            bump_increment_q <= INITIAL_BUMP;
            dbg_decision_count_q <= 0;

            // Reset: Only reset control registers. 
            // Memory arrays are too large to reset in one cycle and will be initialized by clear_all.
            // heap_size_q = 0 prevents invalid access.
        end else if (clear_all || unassign_all) begin
            // Re-initialize based on runtime max_var
            // CRITICAL: Only use max_var if it's valid (> 0 and <= MAX_VARS)
            // If max_var is 0 (not yet known), set heap_size to 0 to prevent
            // deciding on out-of-scope variables
            state_q <= IDLE;
            if (max_var > 0 && max_var <= MAX_VARS) begin
                heap_size_q <= max_var[IDX_W-1:0];
`ifndef SYNTHESIS
                if (DEBUG > 0) $strobe("[VDE HEAP] Unassign/Clear: max_var=%0d -> heap_size=%0d", max_var, max_var[IDX_W-1:0]);
`endif
            end else begin
                heap_size_q <= '0;  // Empty heap until max_var is known
`ifndef SYNTHESIS
                if (DEBUG > 0) $strobe("[VDE HEAP] Unassign/Clear ERROR: max_var=%0d is INVALID. Setting heap_size=0", max_var);
`endif
            end
            idx_q <= '0;
            pending_var_q <= '0;
            pending_value_q <= 1'b0;
            bump_queue_count_q <= '0;
            // Only reset scores if clear_all (not unassign_all)
            if (clear_all) begin
                bump_increment_q <= INITIAL_BUMP;
                dbg_decision_count_q <= 0;
            end 

            if (clear_all) begin
                // Start sequential initialization
                state_q <= INIT_LOOP;
                idx_q <= '0;
                
                if (max_var > 0 && max_var <= MAX_VARS) begin
                    heap_size_q <= max_var[IDX_W-1:0];
`ifndef SYNTHESIS
                    if (DEBUG > 0) $strobe("[VDE HEAP] Unassign/Clear: max_var=%0d -> heap_size=%0d. Starting INIT_LOOP.", max_var, max_var[IDX_W-1:0]);
`endif
                end else begin
                    heap_size_q <= '0;
`ifndef SYNTHESIS
                    if (DEBUG > 0) $strobe("[VDE HEAP] Unassign/Clear ERROR: max_var=%0d invalid. Clearing.", max_var);
`endif
                end
                
                bump_increment_q <= INITIAL_BUMP;
                dbg_decision_count_q <= 0;
            end else if (unassign_all) begin
                 // Just clear size, logic is handled above
            end
        end else begin
            state_q <= state_d;
            heap_size_q <= heap_size_d;
            idx_q <= idx_d;
            pending_var_q <= pending_var_d;
            pending_value_q <= pending_value_d;
            bump_queue_count_q <= bump_queue_count_d;
            bump_queue_q <= bump_queue_d;
            bump_increment_q <= bump_increment_d;
            // Increment debug decision counter when a decision occurs
            if (state_q == DECIDE && heap_size_q != 0) begin
                dbg_decision_count_q <= dbg_decision_count_q + 1;
            end

            // HIDE_SWAP: Swap heap[idx] with heap[heap_size-1]
            if (state_q == HIDE_SWAP) begin
                last_idx = heap_size_q - 1;
                entry_at_idx = heap_mem[idx_q];
                entry_at_last = heap_mem[last_idx];

                heap_mem[idx_q] <= entry_at_last;
                heap_mem[last_idx] <= entry_at_idx;
                pos_mem[entry_at_last.var_id - 1] <= idx_q;
                pos_mem[entry_at_idx.var_id - 1] <= last_idx;
                phase_hint[pending_var_q - 1] <= pending_value_q;
            end

            // HIDE_BUBBLE_DOWN_SWAP: Swap if needed
            if (state_q == HIDE_BUBBLE_DOWN_SWAP) begin
                s_left_idx = 2 * idx_q + 1;
                s_right_idx = 2 * idx_q + 2;
                s_largest = idx_q;
                
                // Copy to temps
                if (s_left_idx < MAX_VARS) s_entry_left = heap_mem[s_left_idx]; else s_entry_left = '0; 
                if (s_right_idx < MAX_VARS) s_entry_right = heap_mem[s_right_idx]; else s_entry_right = '0;
                if (s_largest < MAX_VARS) s_entry_at_largest = heap_mem[s_largest]; else s_entry_at_largest = '0;
                
                // Compare with Left Child
                if (s_left_idx < heap_size_d) begin
                    if (s_entry_left.score > s_entry_at_largest.score ||
                       (s_entry_left.score == s_entry_at_largest.score && s_entry_left.var_id < s_entry_at_largest.var_id)) begin
                        s_largest = s_left_idx;
                        s_entry_at_largest = s_entry_left;
                    end
                end

                // Compare with Right Child
                if (s_right_idx < heap_size_d) begin
                     if (s_entry_right.score > s_entry_at_largest.score ||
                        (s_entry_right.score == s_entry_at_largest.score && s_entry_right.var_id < s_entry_at_largest.var_id)) begin
                        s_largest = s_right_idx;
                    end
                end

                if (s_largest != idx_q) begin
                    s_entry_at_idx_hide = heap_mem[idx_q];
                    s_entry_at_largest = heap_mem[s_largest];
                    heap_mem[idx_q] <= s_entry_at_largest;
                    heap_mem[s_largest] <= s_entry_at_idx_hide;
                    pos_mem[s_entry_at_largest.var_id - 1] <= idx_q;
                    pos_mem[s_entry_at_idx_hide.var_id - 1] <= s_largest;
                end else begin
                end
            end

            // UNHIDE_SWAP: Swap heap[idx] with heap[heap_size]
            if (state_q == UNHIDE_SWAP) begin
                s_size_idx = heap_size_q;
                
                s_entry_at_idx_unhide = heap_mem[idx_q];
                s_entry_at_size = heap_mem[s_size_idx];

                heap_mem[idx_q] <= s_entry_at_size;
                heap_mem[s_size_idx] <= s_entry_at_idx_unhide;
                pos_mem[s_entry_at_size.var_id - 1] <= idx_q;
                pos_mem[s_entry_at_idx_unhide.var_id - 1] <= s_size_idx;
            end

            // UNHIDE_BUBBLE_UP_SWAP: Swap if parent < current
            // Parent is Worse if: Score Lower OR (Score Equal AND VarID Higher)
            if (state_q == UNHIDE_BUBBLE_UP_SWAP && idx_q > 0) begin
                s_parent_idx = (idx_q - 1) >> 1;
                s_swap_needed = 0;
                
                // Copy to temps
                if (s_parent_idx < MAX_VARS) s_entry_parent = heap_mem[s_parent_idx]; else s_entry_parent = '0; 
                if (idx_q < MAX_VARS) s_entry_current = heap_mem[idx_q]; else s_entry_current = '0;
                
                if (s_entry_parent.score < s_entry_current.score) s_swap_needed = 1;
                else if (s_entry_parent.score == s_entry_current.score && 
                         s_entry_parent.var_id > s_entry_current.var_id) s_swap_needed = 1;

                if (s_swap_needed) begin
                    s_entry_at_idx_unhide = s_entry_current; // Reuse temp or read again? Same.
                    s_entry_at_parent = s_entry_parent;
                    heap_mem[idx_q] <= s_entry_at_parent;
                    heap_mem[s_parent_idx] <= s_entry_at_idx_unhide;
                    pos_mem[s_entry_at_parent.var_id - 1] <= idx_q;
                    pos_mem[s_entry_at_idx_unhide.var_id - 1] <= s_parent_idx;
                end
            end

            // BUMP_UPDATE: Add bump_increment to score
            if (state_q == BUMP_UPDATE) begin
                temp_bump = heap_mem[idx_q];
                temp_bump.score = temp_bump.score + bump_increment_q;
                heap_mem[idx_q] <= temp_bump;
            end

            // BUMP_BUBBLE_UP_SWAP: Swap if parent < current
            if (state_q == BUMP_BUBBLE_UP_SWAP && idx_q > 0) begin
                s_parent_idx = (idx_q - 1) >> 1;
                s_swap_needed = 0;
                
                // Copy to temps
                if (s_parent_idx < MAX_VARS) s_entry_parent = heap_mem[s_parent_idx]; else s_entry_parent = '0; 
                if (idx_q < MAX_VARS) s_entry_current = heap_mem[idx_q]; else s_entry_current = '0;
                
                if (s_entry_parent.score < s_entry_current.score) s_swap_needed = 1;
                else if (s_entry_parent.score == s_entry_current.score && 
                         s_entry_parent.var_id > s_entry_current.var_id) s_swap_needed = 1;

                if (s_swap_needed) begin
                    s_entry_at_idx_unhide = s_entry_current;
                    s_entry_at_parent = s_entry_parent;
                    heap_mem[idx_q] <= s_entry_at_parent;
                    heap_mem[s_parent_idx] <= s_entry_at_idx_unhide;
                    pos_mem[s_entry_at_parent.var_id - 1] <= idx_q;
                    pos_mem[s_entry_at_idx_unhide.var_id - 1] <= s_parent_idx;
                end
            end

            // RESCALE: Divide all scores by large factor (shift right)
            if (state_q == RESCALE) begin
                temp_rescale = heap_mem[idx_q];
                temp_rescale.score = temp_rescale.score >> 16;
                heap_mem[idx_q] <= temp_rescale;
            end

            // INIT_LOOP: Sequential Initialization
            if (state_q == INIT_LOOP) begin
                // Perform one initialization step per cycle
                // init_entry moved to module scope
                init_entry.score = '0;
                
                // Effective MAX_VARS-1 check done by loop
                if (idx_q < MAX_VARS) begin
                    if (heap_size_q > 0) begin // Check if we have valid max_var (stored in heap_size_q during INIT)
                         // logic [IDX_W-1:0] k_rot; // Moved to module scope
                         // logic [IDX_W-1:0] v_ordered; // Moved to module scope
                         
                         if (idx_q < heap_size_q) begin
                             // Active
                             k_rot = (idx_q + (heap_size_q >> 2) * phase_offset[3:2]) % heap_size_q;
                             if (phase_offset[1]) v_ordered = heap_size_q - k_rot;
                             else v_ordered = k_rot + 1; // 1-based var_id
                             
                             init_entry.var_id = v_ordered[IDX_W-1:0];
                             heap_mem[idx_q] <= init_entry;
                             pos_mem[v_ordered - 1] <= idx_q;
                         end else begin
                             // Inactive
                             init_entry.var_id = (idx_q + 1);
                             heap_mem[idx_q] <= init_entry;
                             pos_mem[idx_q] <= idx_q;
                         end
                    end 
                    
                    phase_hint[idx_q] <= 1'b0;
                    
                    idx_q <= idx_q + 1;
                    if (idx_q == MAX_VARS - 1) begin
                        state_d = IDLE;
                    end
                end else begin
                    state_d = IDLE;
                end
            end
        end
    end


endmodule
