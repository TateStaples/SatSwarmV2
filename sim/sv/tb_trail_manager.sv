`timescale 1ns/1ps

module tb_trail_manager;
    import satswarmv2_pkg::*;

    parameter int MAX_VARS = 16;
    
    logic clk;
    logic reset;
    logic push;
    logic [31:0] push_var;
    logic push_value;
    logic [15:0] push_level;
    logic push_is_decision;
    logic [15:0] height;
    logic [15:0] current_level;
    logic backtrack_en;
    logic [15:0] backtrack_to_level;
    logic backtrack_done;
    logic backtrack_valid;
    logic [31:0] backtrack_var;
    logic backtrack_value;
    logic backtrack_is_decision;
    logic [31:0] query_var;
    logic [15:0] query_level;
    logic query_valid;
    logic query_value;
    logic clear_all;

    trail_manager #(
        .MAX_VARS(MAX_VARS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .push(push),
        .push_var(push_var),
        .push_value(push_value),
        .push_level(push_level),
        .push_is_decision(push_is_decision),
        .height(height),
        .current_level(current_level),
        .backtrack_en(backtrack_en),
        .backtrack_to_level(backtrack_to_level),
        .backtrack_done(backtrack_done),
        .backtrack_valid(backtrack_valid),
        .backtrack_var(backtrack_var),
        .backtrack_value(backtrack_value),
        .backtrack_is_decision(backtrack_is_decision),
        .query_var(query_var),
        .query_level(query_level),
        .query_valid(query_valid),
        .query_value(query_value),
        .clear_all(clear_all)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("=== STARTING TRAIL MANAGER UNIT TEST ===");
        
        reset = 1;
        push = 0;
        backtrack_en = 0;
        clear_all = 0;
        
        repeat(2) @(posedge clk);
        reset = 0;
        repeat(2) @(posedge clk);
        
        // Test 1: Push assignments
        $display("[Test 1] Pushing assignments");
        
        // Level 1 Decision: Var 1 = 1
        push = 1; push_var=1; push_value=1; push_level=1; push_is_decision=1;
        @(posedge clk);
        
        // Level 1 Prop: Var 2 = 0
        push = 1; push_var=2; push_value=0; push_level=1; push_is_decision=0;
        @(posedge clk);
        
        // Level 2 Decision: Var 3 = 1
        push = 1; push_var=3; push_value=1; push_level=2; push_is_decision=1;
        @(posedge clk);
        push = 0;
        
        @(posedge clk);
        if (height != 3) $error("Height mismatch: Expected 3, Got %0d", height);
        if (current_level != 2) $error("Current Level mismatch: Expected 2, Got %0d", current_level);
        
        // Test 2: Query
        $display("[Test 2] Query Variables");
        query_var = 1;
        #1;
        if (!query_valid || query_level != 1 || query_value != 1) 
            $error("Query Var 1 Failed: Valid=%0d, Lvl=%0d, Val=%0d", query_valid, query_level, query_value);
            
        query_var = 3;
        #1;
        if (!query_valid || query_level != 2 || query_value != 1)
             $error("Query Var 3 Failed");
             
        query_var = 5; // Unassigned
        #1;
        if (query_valid) $error("Query Var 5 Should be invalid");

        // Test 3: Backtrack to Level 1
        $display("[Test 3] Backtrack to Level 1");
        @(posedge clk);
        backtrack_en <= 1;
        backtrack_to_level <= 1;
        @(posedge clk);
        backtrack_en <= 0;
        
        // Monitor popping
        // Should pop Var 3 (Level 2)
        wait(backtrack_done);
        
        // Check state
        @(posedge clk);
        #1;
        if (height != 2) $error("Height after backtrack wrong: Expected 2, Got %0d", height);
        if (current_level != 1) $error("Current Level after backtrack wrong: Expected 1, Got %0d", current_level);
        
        // Query Var 3 should now be invalid
        query_var = 3;
        #1;
        if (query_valid) $error("Var 3 should have been cleared!");
        
        $display("=== TRAIL MANAGER TEST COMPLETE ===");
        $finish;
    end
    // Watchdog
    initial begin
        repeat(1000) @(posedge clk);
        $display("TIMEOUT: Testbench stuck.");
        $finish;
    end

endmodule
