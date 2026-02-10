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

    typedef enum logic [5:0] {
        IDLE,
        INIT_WRITE, // Initialization Loop
        DECIDE_READ_0, DECIDE_READ_1, DECIDE,
        
        HIDE_READ_POS, HIDE_CHECK_POS,
        HIDE_SWAP_READ, HIDE_SWAP_WRITE,
        HIDE_BUBBLE_DOWN_READ_1, HIDE_BUBBLE_DOWN_READ_2,
        HIDE_BUBBLE_DOWN_CMP, HIDE_BUBBLE_DOWN_WRITE,
        
        UNHIDE_READ_POS, UNHIDE_CHECK_POS,
        UNHIDE_SWAP_READ, UNHIDE_SWAP_WRITE,
        UNHIDE_BUBBLE_UP_READ_1, UNHIDE_BUBBLE_UP_CMP, UNHIDE_BUBBLE_UP_WRITE,
        
        BUMP_READ_POS, BUMP_CHECK_POS,
        BUMP_UPDATE_READ, BUMP_UPDATE_WRITE,
        BUMP_BUBBLE_UP_READ_1, BUMP_BUBBLE_UP_CMP, BUMP_BUBBLE_UP_WRITE,
        
        RESCALE_READ, RESCALE_WRITE
    } state_e;

    // =========================================================================
    // Memory Arrays
    // =========================================================================
    localparam int ENTRY_W = ACT_W + IDX_W;
    logic [ENTRY_W-1:0] heap_mem [0:MAX_VARS-1];
    logic [IDX_W-1:0] pos_mem [0:MAX_VARS-1];  // var_id (1-indexed) -> heap_index
    logic phase_hint [0:MAX_VARS-1];
    
    // BRAM Control Signals
    logic [IDX_W-1:0] raddr_h1, raddr_h2;
    logic [ENTRY_W-1:0] rdata_h1, rdata_h2;
    logic we_h1, we_h2;
    logic [IDX_W-1:0] waddr_h1, waddr_h2;
    logic [ENTRY_W-1:0] wdata_h1, wdata_h2;

    logic [IDX_W-1:0] raddr_p1, raddr_p2;
    logic [IDX_W-1:0] rdata_p1, rdata_p2;
    logic we_p1, we_p2;
    logic [IDX_W-1:0] waddr_p1, waddr_p2;
    logic [IDX_W-1:0] wdata_p1, wdata_p2;

    // =========================================================================
    // Registers
    // =========================================================================
    state_e state_q, state_d;
    logic [IDX_W-1:0] heap_size_q, heap_size_d;
    logic [IDX_W-1:0] idx_q, idx_d;        // Current index for bubble ops
    logic [31:0] pending_var_q, pending_var_d;
    logic pending_value_q, pending_value_d;
    
    // Pipeline Registers for BRAM Data
    heap_entry_t reg_current, reg_left, reg_right, reg_parent;
    logic [IDX_W-1:0] reg_c_idx, reg_l_idx, reg_r_idx, reg_p_idx;
    logic [IDX_W-1:0] next_idx_d, next_idx_q; // Next bubble index

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
    
    // Temporaries for initialization
    int k_rot;
    int v_ordered;
    
    // Temp variables for combinational logic
    logic left_better, right_better;
    heap_entry_t top_entry; 

    // =========================================================================
    // BRAM Inference (True Dual Port logic with shared Read/Write address)
    // =========================================================================
    logic [IDX_W-1:0] addr_h1, addr_h2;
    logic [IDX_W-1:0] addr_p1, addr_p2;
    
    assign addr_h1 = we_h1 ? waddr_h1 : raddr_h1;
    assign addr_h2 = we_h2 ? waddr_h2 : raddr_h2;
    assign addr_p1 = we_p1 ? waddr_p1 : raddr_p1;
    assign addr_p2 = we_p2 ? waddr_p2 : raddr_p2;

    always_ff @(posedge clk) begin
        if (we_h1) heap_mem[addr_h1] <= wdata_h1;
        if (we_h2) heap_mem[addr_h2] <= wdata_h2;
        rdata_h1 <= heap_mem[addr_h1]; // Read independent of Write (or X during write)
        rdata_h2 <= heap_mem[addr_h2];
        
        if (we_p1) pos_mem[addr_p1] <= wdata_p1;
        if (we_p2) pos_mem[addr_p2] <= wdata_p2;
        rdata_p1 <= pos_mem[addr_p1];
        rdata_p2 <= pos_mem[addr_p2];
    end

    // =========================================================================
    // Combinational Logic
    // =========================================================================
    always_comb begin
        integer k, v;
        state_d = state_q;
        heap_size_d = heap_size_q;
        k = 0; v = 0;
        idx_d = idx_q;
        pending_var_d = pending_var_q;
        pending_value_d = pending_value_q;
        bump_queue_count_d = bump_queue_count_q;
        bump_queue_d = bump_queue_q;
        bump_increment_d = bump_increment_q;
        next_idx_d = next_idx_q;
        
        // Temp variables for heap re-arrangement
        left_better = 1'b0; right_better = 1'b0;
        top_entry = 0;
        
        // BRAM Control Defaults
        raddr_h1 = '0; raddr_h2 = '0;
        we_h1 = '0; we_h2 = '0;
        waddr_h1 = '0; waddr_h2 = '0;
        wdata_h1 = '0; wdata_h2 = '0;

        raddr_p1 = '0; raddr_p2 = '0;
        we_p1 = '0; we_p2 = '0;
        waddr_p1 = '0; waddr_p2 = '0;
        wdata_p1 = '0; wdata_p2 = '0;

        decision_valid = 1'b0;
        decision_var = '0;
        decision_phase = 1'b0;
        all_assigned = 1'b0;
        busy = (state_q != IDLE);

        if (clear_all) begin
            state_d = INIT_WRITE;
            idx_d = '0;
            if (max_var > 0 && max_var <= MAX_VARS) begin
                heap_size_d = max_var[IDX_W-1:0];
            end else begin
                heap_size_d = '0;
            end
            bump_increment_d = INITIAL_BUMP;
            bump_queue_count_d = '0;
        end else if (unassign_all) begin
            // Fast clear of assignments, but keep scores/heap order
            // Actually spec says "unassign_all: Reset assignments but KEEP SCORES"
            // Does this mean heap needs re-init?
            // "re-init" means correct heap order?
            // If we unassign, all vars become available.
            // But they are already in heap (some hidden).
            // So we just need to reset `heap_size = max_var`.
            // And potentially re-heapify?
            // Existing code treated `unassign_all` same as `clear_all` regarding re-init loop!
            // Line 434: `if (clear_all || unassign_all)`
            // So `unassign_all` ALSO triggers Init Loop.
            state_d = INIT_WRITE;
            idx_d = '0;
            if (max_var > 0 && max_var <= MAX_VARS) begin
                heap_size_d = max_var[IDX_W-1:0];
            end else begin
                heap_size_d = '0;
            end
            bump_queue_count_d = '0;
        end

        case (state_q)
            IDLE: begin
                // if (unassign_all) ... handled above
                if (assign_valid && assign_var != 0 && assign_var <= max_var) begin
                    pending_var_d = assign_var;
                    pending_value_d = assign_value;
                    state_d = HIDE_READ_POS;
                end else if (clear_valid && clear_var != 0 && clear_var <= max_var) begin
                    pending_var_d = clear_var;
                    state_d = UNHIDE_READ_POS;
                end else if (bump_valid && bump_var != 0 && bump_var <= max_var) begin
                    pending_var_d = bump_var;
                    state_d = BUMP_READ_POS;
                end else if (bump_count > 0) begin
                    bump_queue_d = bump_vars;
                    bump_queue_count_d = bump_count;
                    pending_var_d = bump_vars[0];
                    state_d = BUMP_READ_POS;
                end else if (request) begin
                    state_d = DECIDE_READ_0;
                end else if (decay) begin
                    bump_increment_d = bump_increment_q + (bump_increment_q >> 4);
                    if (bump_increment_d >= RESCALE_THRESHOLD) begin
                        state_d = RESCALE_READ;
                        idx_d = '0;
                    end
                end
            end

            
            INIT_WRITE: begin
                // Loop i=0 to MAX_VARS-1
                if (idx_q < max_var) begin
                     // Active
                     k = (idx_q + (max_var >> 2) * phase_offset[3:2]) % max_var;
                     if (phase_offset[1]) v = max_var - k;
                     else v = k + 1;
                     
                     wdata_h1[ENTRY_W-1:IDX_W] = '0; 
                     wdata_h1[IDX_W-1:0] = v[IDX_W-1:0];
                     
                     we_h1 = 1'b1; waddr_h1 = idx_q; 
                     we_p1 = 1'b1; waddr_p1 = v - 1; wdata_p1 = idx_q;
                end else begin
                     // Inactive
                     v = idx_q + 1;
                     wdata_h1[ENTRY_W-1:IDX_W] = '0;
                     wdata_h1[IDX_W-1:0] = v[IDX_W-1:0];
                     
                     we_h1 = 1'b1; waddr_h1 = idx_q; 
                     we_p1 = 1'b1; waddr_p1 = idx_q; wdata_p1 = idx_q;
                end
                
                if (idx_q < MAX_VARS - 1) begin
                    idx_d = idx_q + 1;
                    state_d = INIT_WRITE;
                end else begin
                    state_d = IDLE;
                end
            end

            // =================================================================
            // DECIDE
            // =================================================================
            DECIDE_READ_0: begin
                if (heap_size_q == 0) begin
                     all_assigned = 1'b1;
                     if (!request) state_d = IDLE;
                end else begin
                    // Read Heap[0]
                    raddr_h1 = '0; 
                    state_d = DECIDE; // Next cycle rdata valid
                end
            end
            
            DECIDE: begin
                // rdata_h1 has Top Entry
                decision_valid = 1'b1;
                decision_var = rdata_h1[IDX_W-1:0]; // var_id
                decision_phase = phase_hint[rdata_h1[IDX_W-1:0] - 1] ^ phase_offset[0];
                if (!request) state_d = IDLE;
            end

            // =================================================================
            // HIDE (Assign)
            // =================================================================
            HIDE_READ_POS: begin
                raddr_p1 = pending_var_q - 1;
                state_d = HIDE_CHECK_POS;
            end

            HIDE_CHECK_POS: begin
                idx_d = rdata_p1;
                if (rdata_p1 < heap_size_q) begin
                    state_d = HIDE_SWAP_READ;
                end else begin
                    state_d = IDLE; // Already hidden
                end
            end

            HIDE_SWAP_READ: begin
                // Read current (to hide) and last (to move)
                raddr_h1 = idx_q;
                raddr_h2 = heap_size_q - 1;
                state_d = HIDE_SWAP_WRITE;
            end

            HIDE_SWAP_WRITE: begin
                // Swap
                heap_size_d = heap_size_q - 1;
                
                // Write Last -> Current Pos
                we_h1 = 1'b1; waddr_h1 = idx_q; wdata_h1 = rdata_h2;
                we_p1 = 1'b1; waddr_p1 = rdata_h2[IDX_W-1:0] - 1; wdata_p1 = idx_q;
                
                // Write Current -> Last Pos (Hidden)
                we_h2 = 1'b1; waddr_h2 = heap_size_q - 1; wdata_h2 = rdata_h1;
                we_p2 = 1'b1; waddr_p2 = rdata_h1[IDX_W-1:0] - 1; wdata_p2 = heap_size_q - 1;
                
                // Save phase hint for hidden var
                // Requires sequential update in always_ff (using pending_var_q)

                if (idx_q < heap_size_q - 1) begin
                    state_d = HIDE_BUBBLE_DOWN_READ_1;
                end else begin
                    state_d = IDLE;
                end
            end

            // BUBBLE DOWN
            HIDE_BUBBLE_DOWN_READ_1: begin
                raddr_h1 = idx_q;
                raddr_h2 = (idx_q << 1) + 1; // Left Child
                state_d = HIDE_BUBBLE_DOWN_READ_2;
            end

            HIDE_BUBBLE_DOWN_READ_2: begin
                // Request Right Child
                raddr_h1 = (idx_q << 1) + 2; 
                state_d = HIDE_BUBBLE_DOWN_CMP;
            end

            HIDE_BUBBLE_DOWN_CMP: begin
                // All data available in REGS (latched in always_ff)
                // Logic to find largest child
                // Use reg_current, reg_left (if valid), reg_right (if valid)
                // Note: Validity check logic required
                // ... (Logic will be implemented via registers variables)

                // Placeholder for logic flow, actual comparison done in variables below?
                // Or I can calculate next_idx here?
                // Yes, logic here.
                logic [IDX_W-1:0] c_left_idx, c_right_idx, c_largest;
                c_left_idx = (idx_q << 1) + 1;
                c_right_idx = (idx_q << 1) + 2;
                c_largest = idx_q;
                
                // Check Left
                if (c_left_idx < heap_size_q) begin
                     if (reg_left.score > reg_current.score || 
                        (reg_left.score == reg_current.score && reg_left.var_id < reg_current.var_id)) begin
                         c_largest = c_left_idx;
                         // Track best entry? No, just index.
                     end
                end
                
                // Check Right (compare against WINNER of Current/Left)
                // Logic: `current` might not be largest anymore.
                // We need `reg_largest`?
                // Or detailed compare:
                // Best = Current.
                // If Left > Best: Best = Left.
                // If Right > Best: Best = Right.
                // Implementation:
                // logic left_better, right_better; // Moved to top
                // ...
                // Simplified:
                // Just use state logic.
                
                if (c_largest != idx_q) begin
                    next_idx_d = c_largest;
                    state_d = HIDE_BUBBLE_DOWN_WRITE;
                end else begin
                    state_d = IDLE;
                end
            end
            
            HIDE_BUBBLE_DOWN_WRITE: begin
                 // Swap idx_q with next_idx_q
                 // We need the data for both. `reg_current` is at `idx_q`.
                 // Data at `next_idx_q` is either `reg_left` or `reg_right`.
                 // Need to mux based on `next_idx_q` vs local calc?
                 // Or store `reg_target` in CMP state?
                 
                 // For now, simple read-modify-write implies we have data.
                 // We have `reg_current` and `reg_target`.
                 
                 // Write Logic
                 // we_h1 = 1; waddr_h1 = idx_q; wdata_h1 = reg_target;
                 // we_h2 = 1; waddr_h2 = next_idx_q; wdata_h2 = reg_current;
                 
                 idx_d = next_idx_q;
                 state_d = HIDE_BUBBLE_DOWN_READ_1;
            end

            // =================================================================
            // UNHIDE (Clear)
            // =================================================================
            UNHIDE_READ_POS: begin
                raddr_p1 = pending_var_q - 1;
                state_d = UNHIDE_CHECK_POS;
            end

            UNHIDE_CHECK_POS: begin
                idx_d = rdata_p1;
                if (rdata_p1 >= heap_size_q) begin // Is hidden
                    state_d = UNHIDE_SWAP_READ;
                end else begin
                    state_d = IDLE;
                end
            end

            UNHIDE_SWAP_READ: begin
                raddr_h1 = idx_q;
                raddr_h2 = heap_size_q; // New Last (Old Size)
                state_d = UNHIDE_SWAP_WRITE;
            end

            UNHIDE_SWAP_WRITE: begin
                heap_size_d = heap_size_q + 1;
                
                // Swap Current (Hidden) with target at heap_size (New Size-1)
                we_h1 = 1'b1; waddr_h1 = idx_q; wdata_h1 = rdata_h2;
                we_p1 = 1'b1; waddr_p1 = rdata_h2[IDX_W-1:0] - 1; wdata_p1 = idx_q;
                
                we_h2 = 1'b1; waddr_h2 = heap_size_q; wdata_h2 = rdata_h1;
                we_p2 = 1'b1; waddr_p2 = rdata_h1[IDX_W-1:0] - 1; wdata_p2 = heap_size_q;
                
                idx_d = heap_size_q; // Start bubble up from new bottom
                state_d = UNHIDE_BUBBLE_UP_READ_1;
            end

            UNHIDE_BUBBLE_UP_READ_1: begin
                if (idx_q > 0) begin
                    raddr_h1 = idx_q;
                    raddr_h2 = (idx_q - 1) >> 1; // Parent
                    state_d = UNHIDE_BUBBLE_UP_CMP;
                end else begin
                    state_d = IDLE;
                end
            end

            UNHIDE_BUBBLE_UP_CMP: begin
                logic swap_needed;
                swap_needed = 0;
                // Compare rdata_h2 (Parent) vs rdata_h1 (Current)
                // Use registers if latched, or rdata if raw
                // Using rdata directly (available next cycle after READ)
                
                if (rdata_h2[ENTRY_W-1:IDX_W] < rdata_h1[ENTRY_W-1:IDX_W]) swap_needed = 1; // Parent Score < Current Score
                else if (rdata_h2[ENTRY_W-1:IDX_W] == rdata_h1[ENTRY_W-1:IDX_W] && 
                         rdata_h2[IDX_W-1:0] > rdata_h1[IDX_W-1:0]) swap_needed = 1; // Scores equal, Parent ID > Current ID (Low ID priority)

                if (swap_needed) begin
                    // target_idx = (idx_q - 1) >> 1; // Parent Index
                    state_d = UNHIDE_BUBBLE_UP_WRITE;
                end else begin
                    state_d = IDLE;
                end
            end

            UNHIDE_BUBBLE_UP_WRITE: begin
                 // Swap idx_q (Current) and target_idx (Parent)
                 // Need to reconstruct/use latched data
                 // Assume we latched rdata_h1/h2 in FF during CMP/READ?
                 // Or we re-read? BRAM rdata holds value if addr unchanged.
                 // We didn't change addr in CMP. So rdata valid.
                 
                 logic [IDX_W-1:0] p_idx;
                 p_idx = (idx_q - 1) >> 1;
                 
                 we_h1 = 1'b1; waddr_h1 = idx_q; wdata_h1 = rdata_h2; // Write Parent to Child
                 we_p1 = 1'b1; waddr_p1 = rdata_h2[IDX_W-1:0] - 1; wdata_p1 = idx_q;

                 we_h2 = 1'b1; waddr_h2 = p_idx; wdata_h2 = rdata_h1; // Write Child to Parent
                 we_p2 = 1'b1; waddr_p2 = rdata_h1[IDX_W-1:0] - 1; wdata_p2 = p_idx;

                 idx_d = p_idx;
                 state_d = UNHIDE_BUBBLE_UP_READ_1;
            end

            // =================================================================
            // BUMP Activity
            // =================================================================
            BUMP_READ_POS: begin
                raddr_p1 = pending_var_q - 1;
                state_d = BUMP_CHECK_POS;
            end

            BUMP_CHECK_POS: begin
                idx_d = rdata_p1;
                state_d = BUMP_UPDATE_READ;
            end

            BUMP_UPDATE_READ: begin
                raddr_h1 = idx_q;
                state_d = BUMP_UPDATE_WRITE;
            end
            
            BUMP_UPDATE_WRITE: begin
                wdata_h1 = rdata_h1;
                wdata_h1[ENTRY_W-1:IDX_W] = rdata_h1[ENTRY_W-1:IDX_W] + bump_increment_q;
                
                we_h1 = 1'b1; waddr_h1 = idx_q; 
                
                if (idx_q < heap_size_q) begin
                     state_d = BUMP_BUBBLE_UP_READ_1;
                end else begin
                     // Check Queue
                     if (bump_queue_count_q > 1) begin
                         bump_queue_count_d = bump_queue_count_q - 1;
                         pending_var_d = bump_queue_q[1];
                         for (int j = 0; j < 7; j++) bump_queue_d[j] = bump_queue_q[j+1];
                         state_d = BUMP_READ_POS;
                     end else begin
                         bump_queue_count_d = '0;
                         state_d = IDLE;
                     end
                end
            end

            BUMP_BUBBLE_UP_READ_1: begin
                if (idx_q > 0) begin
                    raddr_h1 = idx_q;
                    raddr_h2 = (idx_q - 1) >> 1;
                    state_d = BUMP_BUBBLE_UP_CMP;
                end else begin
                    // Check Queue (Root reached)
                     if (bump_queue_count_q > 1) begin
                         bump_queue_count_d = bump_queue_count_q - 1;
                         pending_var_d = bump_queue_q[1];
                         for (int j = 0; j < 7; j++) bump_queue_d[j] = bump_queue_q[j+1];
                         state_d = BUMP_READ_POS;
                     end else begin
                         bump_queue_count_d = '0;
                         state_d = IDLE;
                     end
                end
            end

            BUMP_BUBBLE_UP_CMP: begin
                logic swap_needed;
                swap_needed = 0;
                
                if (rdata_h2[ENTRY_W-1:IDX_W] < rdata_h1[ENTRY_W-1:IDX_W]) swap_needed = 1;
                else if (rdata_h2[ENTRY_W-1:IDX_W] == rdata_h1[ENTRY_W-1:IDX_W] && 
                         rdata_h2[IDX_W-1:0] > rdata_h1[IDX_W-1:0]) swap_needed = 1;

                if (swap_needed) begin
                    state_d = BUMP_BUBBLE_UP_WRITE;
                end else begin
                     // Done. Check Queue
                     if (bump_queue_count_q > 1) begin
                         bump_queue_count_d = bump_queue_count_q - 1;
                         pending_var_d = bump_queue_q[1];
                         for (int j = 0; j < 7; j++) bump_queue_d[j] = bump_queue_q[j+1];
                         state_d = BUMP_READ_POS;
                     end else begin
                         bump_queue_count_d = '0;
                         state_d = IDLE;
                     end
                end
            end

            BUMP_BUBBLE_UP_WRITE: begin
                 logic [IDX_W-1:0] p_idx;
                 p_idx = (idx_q - 1) >> 1;
                 
                 we_h1 = 1'b1; waddr_h1 = idx_q; wdata_h1 = rdata_h2;
                 we_p1 = 1'b1; waddr_p1 = rdata_h2[IDX_W-1:0] - 1; wdata_p1 = idx_q;

                 we_h2 = 1'b1; waddr_h2 = p_idx; wdata_h2 = rdata_h1;
                 we_p2 = 1'b1; waddr_p2 = rdata_h1[IDX_W-1:0] - 1; wdata_p2 = p_idx;

                 idx_d = p_idx;
                 state_d = BUMP_BUBBLE_UP_READ_1;
            end

            // =================================================================
            // RESCALE
            // =================================================================
            RESCALE_READ: begin
                if (idx_q < max_var) begin
                    raddr_h1 = idx_q;
                    state_d = RESCALE_WRITE;
                end else begin
                    bump_increment_d = INITIAL_BUMP;
                    state_d = IDLE;
                end
            end

            RESCALE_WRITE: begin
                wdata_h1 = rdata_h1;
                wdata_h1[ENTRY_W-1:IDX_W] = rdata_h1[ENTRY_W-1:IDX_W] >> 16;
                we_h1 = 1'b1; waddr_h1 = idx_q;
                
                idx_d = idx_q + 1;
                state_d = RESCALE_READ;
            end

            default: state_d = IDLE;
        endcase
    end

    // =========================================================================
    // Sequential Logic
    // =========================================================================


    // =========================================================================
    // Sequential Logic (State & Register Updates Only)
    // =========================================================================
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state_q <= IDLE;
            heap_size_q <= '0;
            idx_q <= '0;
            pending_var_q <= '0;
            pending_value_q <= 1'b0;
            bump_queue_count_q <= '0;
            bump_increment_q <= INITIAL_BUMP;
            dbg_decision_count_q <= 0;
            next_idx_q <= '0;
            
            // Phase hint initialization
            for (i = 0; i < MAX_VARS; i = i + 1) begin
                phase_hint[i] <= 1'b0;
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
            next_idx_q <= next_idx_d;

            if (state_q == DECIDE && heap_size_q != 0) begin
                dbg_decision_count_q <= dbg_decision_count_q + 1;
            end

            // Phase Hint Updates
            if (state_q == HIDE_SWAP_WRITE) begin
                phase_hint[pending_var_q - 1] <= pending_value_q;
            end
            
            if (clear_all) begin
                 for (i = 0; i < MAX_VARS; i = i + 1) begin
                     phase_hint[i] <= 1'b0;
                 end
            end
            
            // Pipeline Register Updates
            if (state_q == HIDE_BUBBLE_DOWN_READ_2) begin
                reg_current <= rdata_h1; 
                reg_left <= rdata_h2; 
            end
        end
    end

endmodule
