module tb_utils;

    localparam WIDTH = 32;
    localparam DEPTH = 4;

    logic clk;
    logic rst_n;

    // FIFO signals
    logic fifo_push, fifo_pop, fifo_full, fifo_empty, fifo_flush;
    logic [WIDTH-1:0] fifo_push_data, fifo_pop_data;
    logic [$clog2(DEPTH):0] fifo_count;

    // Stack signals
    logic stack_push, stack_pop, stack_full, stack_empty, stack_clear;
    logic [WIDTH-1:0] stack_push_data, stack_pop_data, stack_top_data;
    logic [$clog2(DEPTH):0] stack_count;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // DUT Instantiation
    sfifo #(.WIDTH(WIDTH), .DEPTH(DEPTH)) u_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .push(fifo_push),
        .push_data(fifo_push_data),
        .pop(fifo_pop),
        .pop_data(fifo_pop_data),
        .full(fifo_full),
        .empty(fifo_empty),
        .count(fifo_count),
        .flush(fifo_flush)
    );

    stack #(.WIDTH(WIDTH), .DEPTH(DEPTH)) u_stack (
        .clk(clk),
        .rst_n(rst_n),
        .push(stack_push),
        .push_data(stack_push_data),
        .pop(stack_pop),
        .pop_data(stack_pop_data),
        .top_data(stack_top_data),
        .full(stack_full),
        .empty(stack_empty),
        .count(stack_count),
        .clear(stack_clear)
    );

    // Tests
    initial begin
        // Initialize
        rst_n = 0;
        fifo_push = 0; fifo_pop = 0; fifo_push_data = 0; fifo_flush = 0;
        stack_push = 0; stack_pop = 0; stack_push_data = 0; stack_clear = 0;
        
        #20 rst_n = 1;
        #10;

        $display("Starting Utils Test...");

        // --- FIFO TEST ---
        $display("Testing FIFO...");
        
        // Push 1
        fifo_push = 1; fifo_push_data = 32'hAAAA_AAAA;
        #10;
        fifo_push = 0;
        assert(fifo_empty == 0) else $error("FIFO should not be empty");
        assert(fifo_count == 1) else $error("FIFO count should be 1");
        
        // Push 2
        fifo_push = 1; fifo_push_data = 32'hBBBB_BBBB;
        #10;
        fifo_push = 0;
        
        // Pop 1
        assert(fifo_pop_data == 32'hAAAA_AAAA) else $error("FIFO peek mismatch: %h", fifo_pop_data);
        fifo_pop = 1;
        #10;
        fifo_pop = 0;
        
        // Flush
        fifo_flush = 1;
        #10;
        fifo_flush = 0;
        assert(fifo_empty == 1) else $error("FIFO should be empty after flush");
        
        $display("FIFO Test Passed.");


        // --- STACK TEST ---
        $display("Testing Stack...");
        
        // Push 1
        stack_push = 1; stack_push_data = 32'h1111_1111;
        #10;
        stack_push = 0;
        assert(stack_top_data == 32'h1111_1111) else $error("Stack top mismatch 1");

        // Push 2
        stack_push = 1; stack_push_data = 32'h2222_2222;
        #10;
        stack_push = 0;
        assert(stack_top_data == 32'h2222_2222) else $error("Stack top mismatch 2");
        
        // Pop 1 (Should get last pushed)
        assert(stack_pop_data == 32'h2222_2222) else $error("Stack pop data mismatch: %h", stack_pop_data);
        stack_pop = 1;
        #10;
        stack_pop = 0;
        assert(stack_top_data == 32'h1111_1111) else $error("Stack top mismatch after pop");
        
        // Clear
        stack_clear = 1;
        #10;
        stack_clear = 0;
        assert(stack_empty == 1) else $error("Stack should be empty after clear");

        $display("Stack Test Passed.");

        $finish;
    end

endmodule
