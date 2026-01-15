/**
 * Professional Testbench for VeriSAT Utils (sfifo, stack)
 * 
 * DESIGN:
 * Uses separate tasks for driving and monitoring.
 * Scoreboards track expected state.
 */
module tb_utils_pro;

    localparam WIDTH = 32;
    localparam DEPTH = 16;
    localparam ITERATIONS = 1000;

    logic clk;
    logic rst_n;

    // --- Clock Generation ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // =========================================================================
    // 1. FIFO Testing
    // =========================================================================
    logic f_push, f_pop, f_full, f_empty, f_flush;
    logic [WIDTH-1:0] f_push_data, f_pop_data;
    logic [$clog2(DEPTH):0] f_count;

    sfifo #(.WIDTH(WIDTH), .DEPTH(DEPTH)) dut_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .push(f_push),
        .push_data(f_push_data),
        .pop(f_pop),
        .pop_data(f_pop_data),
        .full(f_full),
        .empty(f_empty),
        .count(f_count),
        .flush(f_flush)
    );

    // Scoreboard for FIFO
    logic [WIDTH-1:0] fifo_queue[$];
    
    // =========================================================================
    // 2. Stack Testing
    // =========================================================================
    logic s_push, s_pop, s_full, s_empty, s_clear;
    logic [WIDTH-1:0] s_push_data, s_pop_data, s_top_data;
    logic [$clog2(DEPTH):0] s_count;

    stack #(.WIDTH(WIDTH), .DEPTH(DEPTH)) dut_stack (
        .clk(clk),
        .rst_n(rst_n),
        .push(s_push),
        .push_data(s_push_data),
        .pop(s_pop),
        .pop_data(s_pop_data),
        .top_data(s_top_data),
        .full(s_full),
        .empty(s_empty),
        .count(s_count),
        .clear(s_clear)
    );

    // Scoreboard for Stack
    logic [WIDTH-1:0] stack_ref[$];

    // =========================================================================
    // Main Test Procedure
    // =========================================================================
    initial begin
        int i;
        logic push_fail, pop_fail;
        
        // Reset
        rst_n = 0;
        f_push = 0; f_pop = 0; f_flush = 0; f_push_data = 0;
        s_push = 0; s_pop = 0; s_clear = 0; s_push_data = 0;
        #20 rst_n = 1;
        @(posedge clk);

        $display("--- Starting Pro Utils Testbench ---");

        // --- Random Stress Test ---
        $display("Test 1: Randomized Stress Test (%0d iterations)", ITERATIONS);
        for (i = 0; i < ITERATIONS; i++) begin
            logic rand_f_push, rand_f_pop;
            logic rand_s_push, rand_s_pop;
            
            rand_f_push = $urandom_range(0, 10) < 7; // 70% chance to push
            rand_f_pop  = $urandom_range(0, 10) < 5; // 50% chance to pop
            rand_s_push = $urandom_range(0, 10) < 7;
            rand_s_pop  = $urandom_range(0, 10) < 5;

        // Drive FIFO
            f_push <= rand_f_push && !f_full;
            f_pop  <= rand_f_pop  && !f_empty;
            f_push_data <= $urandom;

            // Drive Stack
            s_push <= rand_s_push && !s_full;
            s_pop  <= rand_s_pop  && !s_empty;
            s_push_data <= f_push_data;

            @(posedge clk);
            #1; // Wait for non-blocking assignments to settle in both TB and DUT

            // Update models based on what was ACTUALLY applied (sampled at the edge)
            // We use the same signals because NBAs in TB are visible at #1
            // FIFO Model Update
            if (f_push && f_pop) begin
                void'(fifo_queue.pop_front());
                fifo_queue.push_back(f_push_data);
            end else if (f_push) begin
                fifo_queue.push_back(f_push_data);
            end else if (f_pop) begin
                void'(fifo_queue.pop_front());
            end

            // Stack Model Update
            if (s_push) begin
                stack_ref.push_back(s_push_data);
            end else if (s_pop) begin
                void'(stack_ref.pop_back());
            end

            // Verify
            if (f_count != fifo_queue.size()) begin
                $display("[ERROR] Cycle %0d: FIFO count mismatch! HW=%0d, SW=%0d", i, f_count, fifo_queue.size());
                $finish;
            end
            if (!f_empty && f_pop_data !== fifo_queue[0]) begin
                 $display("[ERROR] Cycle %0d: FIFO data mismatch! HW=%h, SW=%h", i, f_pop_data, fifo_queue[0]);
                 $finish;
            end
            
            if (s_count != stack_ref.size()) begin
                $display("[ERROR] Cycle %0d: Stack count mismatch! HW=%0d, SW=%0d", i, s_count, stack_ref.size());
                $finish;
            end
            if (!s_empty && s_top_data !== stack_ref[stack_ref.size()-1]) begin
                $display("[ERROR] Cycle %0d: Stack data mismatch! HW=%h, SW=%h", i, s_top_data, stack_ref[stack_ref.size()-1]);
                $finish;
            end
        end
        $display("Test 1 Passed.");
        
        f_push <= 0; f_pop <= 0; s_push <= 0; s_pop <= 0;
        @(posedge clk);

        // --- Flush/Clear Test ---
        $display("Test 2: Flush and Clear verification");
        while (!f_full) begin
            f_push <= 1; f_push_data <= $urandom;
            @(posedge clk);
        end
        f_push <= 0;
        @(posedge clk);
        
        f_flush <= 1;
        @(posedge clk);
        f_flush <= 0;
        fifo_queue.delete();
        @(posedge clk);
        #1;
        if (!f_empty || f_count != 0) begin
            $error("FIFO Flush failed! empty=%b, count=%0d", f_empty, f_count);
        end
        
        s_clear <= 1;
        @(posedge clk);
        s_clear <= 0;
        stack_ref.delete();
        @(posedge clk);
        #1;
        if (!s_empty || s_count != 0) begin
            $error("Stack Clear failed! empty=%b, count=%0d", s_empty, s_count);
        end
        
        $display("Test 2 Passed.");

        $display("--- All Utils Tests Passed Successfully ---");
        $finish;
    end

endmodule
