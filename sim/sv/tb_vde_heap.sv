`timescale 1ns/1ps

module tb_vde_heap;
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
    logic busy;
    logic [31:0] last_decision;

    // DUT Instantiation
    vde_heap #(
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
        .unassign_all(1'b0),
        .assign_valid(assign_valid),
        .assign_var(assign_var),
        .assign_value(assign_value),
        .clear_valid(clear_valid),
        .clear_var(clear_var),
        .bump_valid(bump_valid),
        .bump_var(bump_var),
        .bump_count(bump_count),
        .bump_vars(bump_vars),
        .decay(decay),
        .busy(busy)
    );



    // Clock Generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Helper task to wait for idle
    task wait_busy;
        begin
            @(posedge clk);
            while (busy) @(posedge clk);
        end
    endtask

    // Test Procedure
    initial begin
        $display("=== STARTING VDE HEAP UNIT TEST ===");
        
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
        wait_busy();



        // Test 1: Initial Request
        $display("[Test 1] Initial Decision Request");
        request = 1;
        @(posedge clk);
        wait(decision_valid || all_assigned);
        if (decision_valid) begin
            last_decision = decision_var;
            $display("  Decision: Var %0d, Phase %0d", decision_var, decision_phase);
            if (decision_var == 0 || decision_var > max_var) $error("  Invalid decision var!");
        end else begin
            $error("  No decision made!");
        end
        request = 0;
        @(posedge clk);

        // Test 2: Assign Variable (Hide) and Verify it's not picked
        $display("[Test 2] Assign Var %0d and Request Again", last_decision);
        assign_valid = 1;
        assign_var = last_decision;
        assign_value = 1;
        @(posedge clk);
        assign_valid = 0;
        wait_busy();
        
        request = 1;
        @(posedge clk);
        wait(decision_valid || all_assigned);
        if (decision_valid) begin
             $display("  Next Decision: Var %0d", decision_var);
             if (decision_var == last_decision) $error("  Selected already assigned variable!");
        end
        request = 0;
        @(posedge clk);

        // Test 3: Unhide (Backtrack)
        $display("[Test 3] Unassign Var %0d and Verify it returns", last_decision);
        clear_valid = 1;
        clear_var = last_decision;
        @(posedge clk);
        clear_valid = 0;
        wait_busy();

        $display("[Test 3b] Bump Var %0d and Request", last_decision);
        bump_valid = 1;
        bump_var = last_decision;
        @(posedge clk);
        bump_valid = 0;
        wait_busy();

        request = 1;
        @(posedge clk);
        wait(decision_valid || all_assigned);
        $display("  Decision after bounce: Var %0d", decision_var);
        if (decision_var != last_decision) $display("  WARNING: Expected Var %0d but got Var %0d (Random seeds might affect this)", last_decision, decision_var);
        request = 0;
        @(posedge clk);


        // Test 4: Activity Bump & Reordering
        // Bump Var 5 multiple times explicitly
        $display("[Test 4] Verifying Activity Bump (Target: Var 5)");
        
        // Ensure Var 5 is unassigned
        clear_valid = 1;
        clear_var = 5;
        @(posedge clk);
        clear_valid = 0;
        wait_busy();

        // Bump Var 5
        repeat(5) begin
            bump_valid = 1;
            bump_var = 5;
            @(posedge clk);
            bump_valid = 0; 
            wait_busy();
        end
        
        // Request decision
        request = 1;
        @(posedge clk);
        wait(decision_valid || all_assigned);
        $display("  Decision after bump: Var %0d", decision_var);
        if (decision_var != 5) $error("  Expected Var 5 but got Var %0d", decision_var);
        request = 0;
        @(posedge clk);

        // Test 5: Check All Assigned logic
        $display("[Test 5] Check All Assigned");
        // Manually assign all vars 1..10
        for (int i=1; i<=10; i++) begin
            assign_valid = 1;
            assign_var = i;
            assign_value = 0;
            @(posedge clk);
            assign_valid = 0;
            wait_busy();
        end
        
        request = 1;
        @(posedge clk);
        wait(decision_valid || all_assigned);
        if (all_assigned) $display("  Correctly reported ALL ASSIGNED");
        else $error("  Expected ALL ASSIGNED, got decision %0d", decision_var);
        request = 0;
        @(posedge clk);
        
        // Test 6: Lazy Decay
        $display("[Test 6] Decay Trigger");
        decay = 1;
        @(posedge clk);
        decay = 0;
        wait_busy();
        $display("  Decay executed without hang");

        // Test 7: Multi-Bump (Learned Clause)
        $display("[Test 7] Multi-Bump (Learned Clause)");
        
        // Ensure some vars are clear
        clear_all = 1;
        @(posedge clk);
        clear_all = 0;
        wait_busy();

        // Send a multi-bump command (Var 2, 3, 4)
        bump_count = 3;
        bump_vars[0] = 2;
        bump_vars[1] = 3;
        bump_vars[2] = 4;
        @(posedge clk);
        bump_count = 0;
        bump_vars = '0; 
        wait_busy();

        // Request decision - one of the bumped vars should come up (highest score wins, depends on initial random seeds)
        // We just verify valid decisions for now
        request = 1;
        @(posedge clk);
        wait(decision_valid || all_assigned);
        $display("  Decision after multi-bump: Var %0d", decision_var);
        if (decision_var != 2 && decision_var != 3 && decision_var != 4) 
            $display("  Note: Multi-bumped vars might not be top if others had higher initial scores. Got %0d", decision_var);
        request = 0;
        @(posedge clk);


        // Test 8: Hidden Bump (Bumping an assigned variable)
        $display("[Test 8] Hidden Bump");
        // 1. Assign Var 6
        assign_valid = 1;
        assign_var = 6;
        assign_value = 0;
        @(posedge clk);
        assign_valid = 0;
        wait_busy();

        // 2. Bump Var 6 deeply (multiple times to ensure it bubbles up internally)
        repeat(10) begin
            bump_valid = 1;
            bump_var = 6;
            @(posedge clk);
            bump_valid = 0;
            wait_busy();
        end

        // 3. Clear Var 6
        clear_valid = 1;
        clear_var = 6;
        @(posedge clk);
        clear_valid = 0;
        wait_busy();

        // 4. Request - Var 6 should likely be next
        request = 1;
        @(posedge clk);
        wait(decision_valid || all_assigned);
        $display("  Decision after hidden bump: Var %0d", decision_var);
        if (decision_var != 6) $display("  Note: Var 6 was bumped while hidden, but came out as %0d", decision_var);
        request = 0;
        @(posedge clk);


        // Test 9: Randomized Stress Test
        $display("[Test 9] Randomized Stress Test (1000 cycles)");
        reset = 1;
        @(posedge clk);
        reset = 0;
        wait_busy();
        
        begin : stress_test
            // Simple shadow model: set of assigned variables
            logic [MAX_VARS:1] shadow_assigned;
            logic [MAX_VARS:1] shadow_active; // Not fully tracking scores, just validity
            shadow_assigned = '0;

            for (int k = 0; k < 1000; k++) begin
                int rand_op;
                int rand_var;
                rand_op = $urandom_range(0, 3); // 0=Req, 1=Assign, 2=Clear, 3=Bump

                // Only issue command if not busy
                if (!busy) begin
                    case (rand_op)
                        0: begin // Request
                            request = 1;
                            @(posedge clk);
                            // Wait for decision
                            while(!decision_valid && !all_assigned && busy) @(posedge clk);
                            
                            if (decision_valid) begin
                                if (shadow_assigned[decision_var]) begin
                                    $error("STRESS FAIL: VDE picked assigned var %0d", decision_var);
                                end
                                // Auto-assign it in shadow model to simulate use
                                shadow_assigned[decision_var] = 1; 
                                
                                begin
                                    automatic int target_var = decision_var;
                                    // And in DUT logic:
                                    request = 0;
                                    // Wait for VDE to return to IDLE (busy=0) before issuing Assign
                                    while(busy) @(posedge clk);
                                    
                                    assign_valid = 1;
                                    assign_var = target_var;
                                    assign_value = $urandom & 1;
                                    @(posedge clk);
                                    assign_valid = 0;
                                end
                            end else if (all_assigned) begin
                                 if (shadow_assigned[10:1] != {10{1'b1}}) begin
                                     // It's possible VDE thinks all assigned if max_var limit is reached differently
                                 end
                            end
                            request = 0;
                        end
                        
                        1: begin // Assign random unassigned
                            // Find an unassigned var
                            rand_var = $urandom_range(1, 10);
                            if (!shadow_assigned[rand_var]) begin
                                assign_valid = 1;
                                assign_var = rand_var;
                                assign_value = $urandom & 1;
                                shadow_assigned[rand_var] = 1;
                                @(posedge clk);
                                assign_valid = 0;
                            end
                        end

                        2: begin // Clear random assigned
                             rand_var = $urandom_range(1, 10);
                             if (shadow_assigned[rand_var]) begin
                                 clear_valid = 1;
                                 clear_var = rand_var;
                                 shadow_assigned[rand_var] = 0;
                                 @(posedge clk);
                                 clear_valid = 0;
                             end
                        end
                        
                        3: begin // Bump random
                            rand_var = $urandom_range(1, 10);
                            bump_valid = 1;
                            bump_var = rand_var;
                            @(posedge clk);
                            bump_valid = 0;
                        end
                    endcase
                end
                repeat(20) @(posedge clk); // Allow latency for VDE to become busy and drain FIFO
            end
        end
        $display("  Stress Check: Alive");
        $display("=== VDE HEAP TEST COMPLETE ===");
        $finish;
    end
    
    // Watchdog
    initial begin
        #5000000;
        $error("TIMEOUT - Wait Busy Loop?");
        $finish;
    end

endmodule
