
// This module contains ONLY the large memory arrays from Mini Solver
// to verify that they fit into BRAM/URAM on the target device.
// It uses simple read/write ports to force inference.

module mini_memory_estimation #(
    parameter int MAX_VARS       = 256,
    parameter int MAX_CLAUSES    = 2560,
    parameter int MAX_LITS       = 10240
) (
    input logic clk,
    input logic rst,
    input logic we,
    input logic [$clog2(MAX_VARS)-1:0]    addr_vars,
    input logic [$clog2(MAX_CLAUSES)-1:0] addr_clauses,
    input logic [$clog2(MAX_LITS)-1:0]    addr_lits,
    input logic [$clog2(2*MAX_VARS)-1:0]  addr_watch_head,
    
    input logic [31:0] wdata,
    output logic [31:0] rdata_xor
);

    // =========================================================================
    // Mini PSE Memories
    // =========================================================================

    // Assignment State (2 bits) - likely distributed RAM
    (* ram_style = "registers" *) logic [1:0] assign_state [0:MAX_VARS-1];

    // Clause Store - Large -> Block RAM
    (* ram_style = "block" *) logic [15:0] clause_len    [0:MAX_CLAUSES-1];
    (* ram_style = "block" *) logic [15:0] clause_start  [0:MAX_CLAUSES-1];
    (* ram_style = "block" *) logic signed [31:0] lit_mem [0:MAX_LITS-1];

    // Watch Lists - Large -> Block RAM
    (* ram_style = "block" *) logic [15:0] watched_lit1  [0:MAX_CLAUSES-1];
    (* ram_style = "block" *) logic [15:0] watched_lit2  [0:MAX_CLAUSES-1];
    (* ram_style = "block" *) logic [15:0] watch_head1   [0:2*MAX_VARS-1];
    (* ram_style = "block" *) logic [15:0] watch_head2   [0:2*MAX_VARS-1];

    // Propagation Queue (FIFO) - Large -> Block RAM
    (* ram_style = "block" *) logic signed [31:0] prop_queue [0:MAX_LITS-1];

    // Trail - Medium -> Auto/Block
    logic signed [31:0] trail_mem [0:MAX_VARS-1];

    // =========================================================================
    // Mini Solver Core Memories
    // =========================================================================
    logic [31:0] decision_var_stack [0:MAX_VARS-1];
    logic [31:0] trail_lim          [0:MAX_VARS-1];


    // =========================================================================
    // Explicit Read Registers for BRAM Inference
    // =========================================================================
    logic [1:0]  r_assign_state;
    logic [15:0] r_clause_len;
    logic [15:0] r_clause_start;
    logic [31:0] r_lit_mem;
    logic [15:0] r_watched_lit1, r_watched_lit2;
    logic [15:0] r_watch_head1, r_watch_head2;
    logic [31:0] r_prop_queue;
    logic [31:0] r_trail_mem;
    logic [31:0] r_decision_var_stack;
    logic [31:0] r_trail_lim;

    always_ff @(posedge clk) begin
        if (we) begin
            assign_state[addr_vars]      <= wdata[1:0];
            clause_len[addr_clauses]     <= wdata[15:0];
            clause_start[addr_clauses]   <= wdata[15:0];
            lit_mem[addr_lits]           <= wdata;
            
            watched_lit1[addr_clauses]   <= wdata[15:0];
            watched_lit2[addr_clauses]   <= wdata[15:0];
            watch_head1[addr_watch_head] <= wdata[15:0];
            watch_head2[addr_watch_head] <= wdata[15:0];
            
            prop_queue[addr_lits]        <= wdata;
            trail_mem[addr_vars]         <= wdata;
            
            decision_var_stack[addr_vars] <= wdata;
            trail_lim[addr_vars]          <= wdata;
        end
        
        // Explicit Synchronous Read
        r_assign_state      <= assign_state[addr_vars];
        r_clause_len        <= clause_len[addr_clauses];
        r_clause_start      <= clause_start[addr_clauses];
        r_lit_mem           <= lit_mem[addr_lits];
        r_watched_lit1      <= watched_lit1[addr_clauses];
        r_watched_lit2      <= watched_lit2[addr_clauses];
        r_watch_head1       <= watch_head1[addr_watch_head];
        r_watch_head2       <= watch_head2[addr_watch_head];
        r_prop_queue        <= prop_queue[addr_lits];
        r_trail_mem         <= trail_mem[addr_vars];
        r_decision_var_stack<= decision_var_stack[addr_vars];
        r_trail_lim         <= trail_lim[addr_vars];
    end

    // Combinatorial Output
    assign rdata_xor = {30'b0, r_assign_state} ^
                       {16'b0, r_clause_len} ^
                       {16'b0, r_clause_start} ^
                       r_lit_mem ^
                       {16'b0, r_watched_lit1} ^
                       {16'b0, r_watched_lit2} ^
                       {16'b0, r_watch_head1} ^
                       {16'b0, r_watch_head2} ^
                       r_prop_queue ^
                       r_trail_mem ^
                       r_decision_var_stack ^
                       r_trail_lim;

endmodule
