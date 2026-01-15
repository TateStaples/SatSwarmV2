module vde #(
    parameter int MAX_VARS = 256,
    parameter int ACT_W    = 32
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
    input  logic         unassign_all,

    // Assignment bookkeeping
    input  logic         assign_valid,
    input  logic [31:0]  assign_var,
    input  logic         assign_value,
    input  logic         clear_valid,
    input  logic [31:0]  clear_var,

    // Activity updates
    input  logic         bump_valid,
    input  logic [31:0]  bump_var,
    
    // Multi-bump for learned clause
    input  logic [3:0]   bump_count,
    input  logic [7:0][31:0] bump_vars,
    input  logic         decay
);

    // =========================================================================
    // VDE Heap Integation Wrapper
    // Buffers inputs to handle vde_heap latency.
    // =========================================================================

    logic heap_busy;
    
    // -------------------------------------------------------------------------
    // 1. Command FIFO for Assignments & Clears
    // -------------------------------------------------------------------------
    // INVARIANT: Latency Isolation
    // The VDE Heap is slow (multi-cycle operations). The Core FSM is fast.
    // This FIFO absorbs the speed mismatch to prevent stalling the Core.
    // All activity updates and assignments must pass through here to ensure
    // the Heap eventually reflects the correct state.
    // Op encoding: 00=Assign, 01=Clear, 10=Bump(Scalar)
    typedef enum logic [1:0] { OP_ASSIGN, OP_CLEAR, OP_BUMP } vde_op_e;
    
    typedef struct packed {
        vde_op_e op;
        logic [31:0] var_id;
        logic val;
    } fifo_entry_t;

    localparam FIFO_DEPTH = 256;
    localparam CNT_W = $clog2(FIFO_DEPTH+1);
    localparam ENTRY_W = $bits(fifo_entry_t);

    logic [CNT_W:0] count; // Note count width check
    logic fifo_full, fifo_empty;
    logic fifo_push, fifo_pop;
    fifo_entry_t fifo_in, fifo_out;
    logic [ENTRY_W-1:0] fifo_push_bits, fifo_pop_bits;
    
    assign fifo_push_bits = fifo_in;
    assign fifo_out       = fifo_entry_t'(fifo_pop_bits);

    sfifo #(
        .WIDTH(ENTRY_W),
        .DEPTH(FIFO_DEPTH)
    ) u_vde_fifo (
        .clk(clk),
        .rst_n(!reset), // Note: reset is active high in generic? No, vde uses 'reset' which is usually posedge?
                        // solver_core uses !rst_n. 
                        // vde port has input logic reset.
                        // vde line 96: posedge reset. So reset is active high.
                        // sfifo uses rst_n (active low).
                        // So I should pass !reset.
        .push(fifo_push),
        .push_data(fifo_push_bits),
        .pop(fifo_pop),
        .pop_data(fifo_pop_bits),
        .full(fifo_full),
        .empty(fifo_empty),
        .count(count), // Adjust width if needed
        .flush(clear_all)
    );

    // FIFO Write Logic
    always_comb begin
        fifo_push = 1'b0;
        fifo_in   = '0;
        
        // Priority: Assign > Clear > Bump (scalar) results in serial stream
        // Note: bump_valid (scalar) is rarely used now, mostly bump_vars (vector)
        if (assign_valid) begin
            fifo_push = 1'b1;
            fifo_in.op = OP_ASSIGN;
            fifo_in.var_id = assign_var;
            fifo_in.val = assign_value;
        end else if (clear_valid) begin
            fifo_push = 1'b1;
            fifo_in.op = OP_CLEAR;
            fifo_in.var_id = clear_var;
        end else if (bump_valid) begin
            fifo_push = 1'b1;
            fifo_in.op = OP_BUMP;
            fifo_in.var_id = bump_var;
        end
    end

    // FIFO Sequential
    // FIFO Sequential removed (handled by sfifo)
    // Old fifo_out assignment removed
    // assign fifo_out = fifo_mem[rd_ptr]; is replaced by line 71 assign

    // -------------------------------------------------------------------------
    // 2. Multi-Bump Holding Register
    // -------------------------------------------------------------------------
    logic [3:0]       held_bump_count;
    logic [7:0][31:0] held_bump_vars;
    logic             held_bump_valid;
    logic             ack_bump;

    always_ff @(posedge clk or posedge reset) begin
        if (reset || clear_all) begin
            held_bump_valid <= 1'b0;
            held_bump_count <= '0;
            held_bump_vars  <= '0;
        end else begin
            if (bump_count > 0) begin
                held_bump_valid <= 1'b1;
                held_bump_count <= bump_count;
                held_bump_vars  <= bump_vars;
            end else if (ack_bump) begin
                held_bump_valid <= 1'b0;
            end
        end
    end
    
    logic held_decay;
    logic ack_decay;
    always_ff @(posedge clk or posedge reset) begin
        if (reset || clear_all) held_decay <= 1'b0;
        else if (decay) held_decay <= 1'b1;
        else if (ack_decay) held_decay <= 1'b0;
    end


    // -------------------------------------------------------------------------
    // 3. Arbiter to Drive VDE Heap
    // -------------------------------------------------------------------------
    // Signals to VDE Heap
    logic h_assign_valid, h_clear_valid, h_bump_valid;
    logic [31:0] h_assign_var, h_clear_var, h_bump_var;
    logic h_assign_value;
    logic [3:0] h_bump_count;
    logic [7:0][31:0] h_bump_vars;
    logic h_decay;
    
    always_comb begin
        h_assign_valid = 1'b0;
        h_assign_var   = '0;
        h_assign_value = 1'b0;
        h_clear_valid  = 1'b0;
        h_clear_var    = '0;
        h_bump_valid   = 1'b0;
        h_bump_var     = '0;
        h_bump_count   = '0;
        h_bump_vars    = '0;
        h_decay        = 1'b0;
        
        fifo_pop = 1'b0;
        ack_bump = 1'b0;
        ack_decay = 1'b0;

        // Only drive if Heap is NOT busy
        // Note: 'heap_busy' is combinational in vde_heap based on state. 
        // If we drive signals now, state will change next cycle -> busy next cycle.
        if (!heap_busy) begin
            // Priority: FIFO > Multi-Bump > Decay
            if (!fifo_empty) begin
                fifo_pop = 1'b1;
                case (fifo_out.op)
                    OP_ASSIGN: begin
                        h_assign_valid = 1'b1;
                        h_assign_var   = fifo_out.var_id;
                        h_assign_value = fifo_out.val;
                    end
                    OP_CLEAR: begin
                        h_clear_valid = 1'b1;
                        h_clear_var   = fifo_out.var_id;
                    end
                    OP_BUMP: begin
                        h_bump_valid = 1'b1;
                        h_bump_var   = fifo_out.var_id;
                    end
                    default: ;
                endcase
            end else if (held_bump_valid) begin
                ack_bump = 1'b1;
                h_bump_count = held_bump_count;
                h_bump_vars  = held_bump_vars;
            end else if (held_decay) begin
                ack_decay = 1'b1;
                h_decay = 1'b1;
            end
        end
    end

    // -------------------------------------------------------------------------
    // 4. VDE Heap Instance
    // -------------------------------------------------------------------------
    vde_heap #(
        .MAX_VARS(MAX_VARS),
        .ACT_W(ACT_W)
    ) u_heap (
        .clk(clk),
        .reset(reset),
        .request(request),
        .decision_valid(decision_valid),
        .decision_var(decision_var),
        .decision_phase(decision_phase),
        .phase_offset(phase_offset),
        .all_assigned(all_assigned),
        .max_var(max_var),
        .clear_all(clear_all),
        .unassign_all(unassign_all),
        
        .assign_valid(h_assign_valid),
        .assign_var(h_assign_var),
        .assign_value(h_assign_value),
        
        .clear_valid(h_clear_valid),
        .clear_var(h_clear_var),
        
        .bump_valid(h_bump_valid),
        .bump_var(h_bump_var),
        
        .bump_count(h_bump_count),
        .bump_vars(h_bump_vars),
        .decay(h_decay),
        
        .busy(heap_busy)
    );

endmodule
