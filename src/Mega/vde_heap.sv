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
    
    input  int           DEBUG
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
        RESCALE
    } state_e;

    // =========================================================================
    // Memory Arrays
    // =========================================================================
    heap_entry_t heap_mem [0:MAX_VARS-1];
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
                    if (heap_size_q == 0) $strobe("VDE_DBG: Request received but heap_size=0. all_assigned will be high next cycle.");
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
                    decision_valid = 1'b1;
                    decision_var = heap_mem[0].var_id;
                    // if (DEBUG >= 2) $display("VDE_DBG: DECIDE -> %0d (Score %0d)", decision_var, heap_mem[0].score);
                    decision_phase = phase_hint[heap_mem[0].var_id - 1] ^ phase_offset[0];
                    // Early decision instrumentation: print top candidates for first few decisions
                    if (dbg_decision_count_q < 5) begin
                        automatic int top_n = (heap_size_q < 6) ? heap_size_q : 6;
                        if (DEBUG >= 2) $display("[VDE] Decide #%0d: var=%0d phase=%0d score=%0d heap_size=%0d",
                                 dbg_decision_count_q+1, decision_var, decision_phase, heap_mem[0].score, heap_size_q);
                        for (int k = 0; k < top_n; k++) begin
                            automatic int vh = heap_mem[k].var_id;
                            if (DEBUG >= 2) $display("[VDE]   Top[%0d]: var=%0d score=%0d phase_hint=%0d", k, vh, heap_mem[k].score, phase_hint[vh-1]);
                        end
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
                logic [IDX_W:0] left_idx = (idx_q << 1) + 1;
                logic [IDX_W:0] right_idx = (idx_q << 1) + 2;
                logic [IDX_W-1:0] largest = idx_q;

                // Compare with Left Child
                // Better if: Score Higher OR (Score Equal AND VarID Lower)
                if (left_idx < heap_size_d) begin
                    /*
                    if (DEBUG >= 2) $display("[VDE DBG] BubbleDown: Idx=%0d (Var=%0d Sc=%0d) vs Left=%0d (Var=%0d Sc=%0d)", 
                       idx_q, heap_mem[idx_q].var_id, heap_mem[idx_q].score,
                       left_idx, heap_mem[left_idx].var_id, heap_mem[left_idx].score);
                    */
                    if (heap_mem[left_idx].score > heap_mem[largest].score ||
                       (heap_mem[left_idx].score == heap_mem[largest].score && 
                        heap_mem[left_idx].var_id < heap_mem[largest].var_id)) begin
                        largest = left_idx[IDX_W-1:0];
                        // if (DEBUG >= 2) $display("[VDE DBG]   -> Selecting Left (Better)");
                    end
                end

                // Compare with Right Child
                if (right_idx < heap_size_d) begin
                    /*
                    if (DEBUG >= 2) $display("[VDE DBG] BubbleDown: Largest=%0d (Var=%0d Sc=%0d) vs Right=%0d (Var=%0d Sc=%0d)", 
                       largest, heap_mem[largest].var_id, heap_mem[largest].score,
                       right_idx, heap_mem[right_idx].var_id, heap_mem[right_idx].score);
                    */
                     if (heap_mem[right_idx].score > heap_mem[largest].score ||
                        (heap_mem[right_idx].score == heap_mem[largest].score && 
                         heap_mem[right_idx].var_id < heap_mem[largest].var_id)) begin
                        largest = right_idx[IDX_W-1:0];
                        // if (DEBUG >= 2) $display("[VDE DBG]   -> Selecting Right (Better)");
                    end
                end

                if (largest != idx_q) begin
                    idx_d = largest;
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
                    logic [IDX_W-1:0] parent_idx = (idx_q - 1) >> 1;
                    logic swap_needed = 0;
                    
                    if (heap_mem[parent_idx].score < heap_mem[idx_q].score) swap_needed = 1;
                    else if (heap_mem[parent_idx].score == heap_mem[idx_q].score && 
                             heap_mem[parent_idx].var_id > heap_mem[idx_q].var_id) swap_needed = 1;

                    if (swap_needed) begin
                        idx_d = parent_idx;
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
                    logic [IDX_W-1:0] parent_idx = (idx_q - 1) >> 1;
                    logic swap_needed = 0;
                    
                    if (heap_mem[parent_idx].score < heap_mem[idx_q].score) swap_needed = 1;
                    else if (heap_mem[parent_idx].score == heap_mem[idx_q].score && 
                             heap_mem[parent_idx].var_id > heap_mem[idx_q].var_id) swap_needed = 1;

                    if (swap_needed) begin
                        idx_d = parent_idx;
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
    always_ff @(posedge clk or posedge reset) begin
        if (reset || clear_all) begin
            state_q <= IDLE;
            heap_size_q <= (max_var < MAX_VARS) ? max_var[IDX_W-1:0] : MAX_VARS[IDX_W-1:0];
            idx_q <= '0;
            pending_var_q <= '0;
            pending_value_q <= 1'b0;
            bump_queue_count_q <= '0;
            bump_increment_q <= INITIAL_BUMP;
            dbg_decision_count_q <= 0;

            for (i = 0; i < MAX_VARS; i = i + 1) begin
                heap_mem[i].score <= '0;
                heap_mem[i].var_id <= i + 1;
                pos_mem[i] <= i;
                phase_hint[i] <= 1'b0;
            end
        end else if (unassign_all) begin
            state_q <= IDLE;
            heap_size_q <= (max_var < MAX_VARS) ? max_var[IDX_W-1:0] : MAX_VARS[IDX_W-1:0];
            idx_q <= '0;
            pending_var_q <= '0;
            pending_value_q <= 1'b0;
            bump_queue_count_q <= '0;
            // Preserve scores and hints, but reset decision counter
            dbg_decision_count_q <= 0;
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
                logic [IDX_W-1:0] last_idx = heap_size_q - 1;
                heap_entry_t entry_at_idx = heap_mem[idx_q];
                heap_entry_t entry_at_last = heap_mem[last_idx];

                heap_mem[idx_q] <= entry_at_last;
                heap_mem[last_idx] <= entry_at_idx;
                pos_mem[entry_at_last.var_id - 1] <= idx_q;
                pos_mem[entry_at_idx.var_id - 1] <= last_idx;
                phase_hint[pending_var_q - 1] <= pending_value_q;
            end

            // HIDE_BUBBLE_DOWN_SWAP: Swap if needed
            if (state_q == HIDE_BUBBLE_DOWN_SWAP) begin
                logic [IDX_W-1:0] left_idx = 2 * idx_q + 1;
                logic [IDX_W-1:0] right_idx = 2 * idx_q + 2;
                logic [IDX_W-1:0] largest = idx_q;
                
                // Compare with Left Child
                // Better if: Score Higher OR (Score Equal AND VarID Lower)
                if (left_idx < heap_size_d) begin
                    /*
                    if (DEBUG >= 2) $display("[VDE DBG] BubbleDown: Idx=%0d (Var=%0d Sc=%0d) vs Left=%0d (Var=%0d Sc=%0d)", 
                       idx_q, heap_mem[idx_q].var_id, heap_mem[idx_q].score,
                       left_idx, heap_mem[left_idx].var_id, heap_mem[left_idx].score);
                    */

                    if (heap_mem[left_idx].score > heap_mem[largest].score ||
                       (heap_mem[left_idx].score == heap_mem[largest].score && heap_mem[left_idx].var_id < heap_mem[largest].var_id)) begin
                        largest = left_idx;
                        // if (DEBUG >= 2) $display("[VDE DBG]   -> Selecting Left (Better)");
                    end
                end

                // Compare with Right Child
                if (right_idx < heap_size_d) begin
                    /*
                     if (DEBUG >= 2) $display("[VDE DBG] BubbleDown: Largest=%0d (Var=%0d Sc=%0d) vs Right=%0d (Var=%0d Sc=%0d)", 
                       largest, heap_mem[largest].var_id, heap_mem[largest].score,
                       right_idx, heap_mem[right_idx].var_id, heap_mem[right_idx].score);
                    */

                     if (heap_mem[right_idx].score > heap_mem[largest].score ||
                       (heap_mem[right_idx].score == heap_mem[largest].score && heap_mem[right_idx].var_id < heap_mem[largest].var_id)) begin
                        largest = right_idx;
                        // if (DEBUG >= 2) $display("[VDE DBG]   -> Selecting Right (Better)");
                    end
                end

                if (largest != idx_q) begin
                    heap_entry_t entry_at_idx = heap_mem[idx_q];
                    heap_entry_t entry_at_largest = heap_mem[largest];
                    // if (DEBUG >= 2) $display("[VDE DBG] Swapping %0d (Var %0d) with %0d (Var %0d)", idx_q, entry_at_idx.var_id, largest, entry_at_largest.var_id);
                    heap_mem[idx_q] <= entry_at_largest;
                    heap_mem[largest] <= entry_at_idx;
                    pos_mem[entry_at_largest.var_id - 1] <= idx_q;
                    pos_mem[entry_at_idx.var_id - 1] <= largest;
                end else begin
                    // if (DEBUG >= 2) $display("[VDE DBG] No Swap (Settled at %0d)", idx_q);
                end
            end

            // UNHIDE_SWAP: Swap heap[idx] with heap[heap_size]
            if (state_q == UNHIDE_SWAP) begin
                logic [IDX_W-1:0] size_idx = heap_size_q;
                heap_entry_t entry_at_idx = heap_mem[idx_q];
                heap_entry_t entry_at_size = heap_mem[size_idx];

                heap_mem[idx_q] <= entry_at_size;
                heap_mem[size_idx] <= entry_at_idx;
                pos_mem[entry_at_size.var_id - 1] <= idx_q;
                pos_mem[entry_at_idx.var_id - 1] <= size_idx;
            end

            // UNHIDE_BUBBLE_UP_SWAP: Swap if parent < current
            // Parent is Worse if: Score Lower OR (Score Equal AND VarID Higher)
            if (state_q == UNHIDE_BUBBLE_UP_SWAP && idx_q > 0) begin
                logic [IDX_W-1:0] parent_idx = (idx_q - 1) >> 1;
                logic swap_needed;
                
                swap_needed = 0;
                if (heap_mem[parent_idx].score < heap_mem[idx_q].score) swap_needed = 1;
                else if (heap_mem[parent_idx].score == heap_mem[idx_q].score && 
                         heap_mem[parent_idx].var_id > heap_mem[idx_q].var_id) swap_needed = 1;

                if (swap_needed) begin
                    heap_entry_t entry_at_idx = heap_mem[idx_q];
                    heap_entry_t entry_at_parent = heap_mem[parent_idx];
                    heap_mem[idx_q] <= entry_at_parent;
                    heap_mem[parent_idx] <= entry_at_idx;
                    pos_mem[entry_at_parent.var_id - 1] <= idx_q;
                    pos_mem[entry_at_idx.var_id - 1] <= parent_idx;
                end
            end

            // BUMP_UPDATE: Add bump_increment to score
            if (state_q == BUMP_UPDATE) begin
                heap_mem[idx_q].score <= heap_mem[idx_q].score + bump_increment_q;
            end

            // BUMP_BUBBLE_UP_SWAP: Swap if parent < current
            if (state_q == BUMP_BUBBLE_UP_SWAP && idx_q > 0) begin
                logic [IDX_W-1:0] parent_idx = (idx_q - 1) >> 1;
                logic swap_needed;
                
                swap_needed = 0;
                if (heap_mem[parent_idx].score < heap_mem[idx_q].score) swap_needed = 1;
                else if (heap_mem[parent_idx].score == heap_mem[idx_q].score && 
                         heap_mem[parent_idx].var_id > heap_mem[idx_q].var_id) swap_needed = 1;

                if (swap_needed) begin
                    heap_entry_t entry_at_idx = heap_mem[idx_q];
                    heap_entry_t entry_at_parent = heap_mem[parent_idx];
                    heap_mem[idx_q] <= entry_at_parent;
                    heap_mem[parent_idx] <= entry_at_idx;
                    pos_mem[entry_at_parent.var_id - 1] <= idx_q;
                    pos_mem[entry_at_idx.var_id - 1] <= parent_idx;
                end
            end

            // RESCALE: Divide all scores by large factor (shift right)
            if (state_q == RESCALE) begin
                heap_mem[idx_q].score <= heap_mem[idx_q].score >> 16;
            end
        end
    end


endmodule
