`timescale 1ns/1ps

module tb_vde;
    import satswarmv2_pkg::*;

    // Parameters
    parameter int MAX_VARS = 16;
    parameter int ACT_W = 32;

    // Signals
    logic clk;
    logic reset;
    logic request;
    logic decision_valid;
    logic [31:0] decision_var;
    logic decision_phase;
    logic [3:0] phase_offset;
    logic all_assigned;
    logic [31:0] max_var;
    logic clear_all;
    logic assign_valid;
    logic [31:0] assign_var;
    logic assign_value;
    logic clear_valid;
    logic [31:0] clear_var;
    logic bump_valid;
    logic [31:0] bump_var;
    logic [3:0] bump_count;
    logic [7:0][31:0] bump_vars;
    logic decay;

    // DUT Instantiation
    vde #(
        .MAX_VARS(MAX_VARS),
        .ACT_W(ACT_W)
    ) dut (
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
        .assign_valid(assign_valid),
        .assign_var(assign_var),
        .assign_value(assign_value),
        .clear_valid(clear_valid),
        .clear_var(clear_var),
        .bump_valid(bump_valid),
        .bump_var(bump_var),
        .bump_count(bump_count),
        .bump_vars(bump_vars),
        .decay(decay)
    );

    // Clock Generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Test Procedure
    initial begin
        $display("=== STARTING VDE UNIT TEST ===");
        
        // Initialize Inputs
        reset = 1;
        request = 0;
        phase_offset = 0;
        max_var = 10;
        clear_all = 0;
        assign_valid = 0;
        assign_var = 0;
        assign_value = 0;
        clear_valid = 0;
        clear_var = 0;
        bump_valid = 0;
        bump_var = 0;
        bump_count = 0;
        bump_vars = '0;
        decay = 0;

        repeat (2) @(posedge clk);
        reset = 0;
        repeat (2) @(posedge clk);

        // Test 1: Initial Request (Should pick based on random seed)
        $display("[Test 1] Initial Decision Request");
        request = 1;
        wait(decision_valid || all_assigned);
        if (decision_valid) begin
            $display("  Decision: Var %0d, Phase %0d", decision_var, decision_phase);
            if (decision_var == 0 || decision_var > max_var) $error("  Invalid decision var!");
        end else begin
            $error("  No decision made!");
        end
        request = 0;
        @(posedge clk);

        // Test 2: Assign Variable and Verify it's not picked
        $display("[Test 2] Assign Var %0d and Request Again", decision_var);
        assign_valid = 1;
        assign_var = decision_var;
        assign_value = 1;
        @(posedge clk);
        assign_valid = 0;
        
        request = 1;
        wait(decision_valid || all_assigned);
        // Should pick a DIFFERENT variable
        if (decision_valid) begin
             $display("  Next Decision: Var %0d", decision_var);
             if (decision_var == assign_var) $error("  Selected already assigned variable!");
        end
        request = 0;
        @(posedge clk);

        // Test 3: Activity Bump
        // Bump a specific unassigned variable and see if it gets picked next
        // Pick a var that wasn't just decided. 
        // Let's bump var 5 (assuming it hasn't been picked yet, simplistic check)
        // If var 5 is assigned, we'll clear it first.
        
        $display("[Test 3] Verifying Activity Bump (Target: Var 5)");
        // Clear var 5 to be safe
        clear_valid = 1;
        clear_var = 5;
        @(posedge clk);
        clear_valid = 0;

        // Bump Var 5 multiple times to ensure it has highest activity
        repeat(5) begin
            bump_valid = 1;
            bump_var = 5;
            @(posedge clk);
        end
        bump_valid = 0;
        
        // Request decision
        request = 1;
        wait(decision_valid || all_assigned);
        $display("  Decision after bump: Var %0d", decision_var);
        if (decision_var != 5) $error("  Expected Var 5 but got Var %0d", decision_var);
        request = 0;
        @(posedge clk);

        // Test 4: Clear All and Check All Assigned logic
        $display("[Test 4] Check All Assigned");
        // Manually assign all vars 1..10
        for (int i=1; i<=10; i++) begin
            assign_valid = 1;
            assign_var = i;
            assign_value = 0;
            @(posedge clk);
        end
        assign_valid = 0;
        
        request = 1;
        wait(decision_valid || all_assigned);
        if (all_assigned) $display("  Correctly reported ALL ASSIGNED");
        else $error("  Expected ALL ASSIGNED, got decision %0d", decision_var);
        request = 0;
        @(posedge clk);
        
        // Final Clean
        $display("=== VDE TEST COMPLETE ===");
        $finish;
    end
    
    // Watchdog
    initial begin
        #100000;
        $error("TIMEOUT");
        $finish;
    end

endmodule
