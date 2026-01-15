`timescale 1ns/1ps

module tb_cae;
    import satswarmv2_pkg::*;

    parameter int MAX_LITS = 8;
    parameter int LEVEL_W = 8;

    logic clk, reset;
    logic start;
    logic [LEVEL_W-1:0] decision_level;
    logic [3:0] conflict_len;
    logic signed [MAX_LITS-1:0][31:0] conflict_lits;
    logic [MAX_LITS-1:0][LEVEL_W-1:0] conflict_levels;
    logic learned_valid;
    logic [3:0] learned_len;
    logic signed [MAX_LITS-1:0][31:0] learned_clause;
    logic [LEVEL_W-1:0] backtrack_level;
    logic unsat;
    logic done;

    cae #(
        .MAX_LITS(MAX_LITS),
        .LEVEL_W(LEVEL_W)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .decision_level(decision_level),
        .conflict_len(conflict_len),
        .conflict_lits(conflict_lits),
        .conflict_levels(conflict_levels),
        .learned_valid(learned_valid),
        .learned_len(learned_len),
        .learned_clause(learned_clause),
        .backtrack_level(backtrack_level),
        .unsat(unsat),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("=== STARTING CAE UNIT TEST ===");
        reset = 1;
        start = 0;
        conflict_len = 0;
        conflict_lits = '0;
        conflict_levels = '0;
        
        repeat(2) @(posedge clk);
        reset = 0;
        repeat(2) @(posedge clk);
        
        // Test 1: Simple Conflict at Level 5
        // Conflict Clause: {Lit 10 (Lvl 5), Lit 11 (Lvl 3), Lit 12 (Lvl 2)}
        // Current Level: 5
        // Expected: UIP is Lit 10. Learned Clause should contain ~10, 11, 12?
        // Actually CAE logic:
        // Finds max level in conflict (5).
        // Finds first lit at max level -> UIP.
        // Backtrack level = max among OTHERS (3).
        
        $display("[Test 1] Direct First-UIP Calculation");
        start <= 1;
        decision_level <= 5;
        conflict_len <= 3;
        conflict_lits[0] <= 10; conflict_levels[0] <= 5;
        conflict_lits[1] <= 11; conflict_levels[1] <= 3;
        conflict_lits[2] <= 12; conflict_levels[2] <= 2;
        
        @(posedge clk);
        start <= 0;
        wait(done);
        
        $display("  Learned Len: %0d", learned_len);
        $display("  Backtrack Level: %0d", backtrack_level);
        $display("  UNSAT: %0d", unsat);
        
        if (backtrack_level != 3) $error("Expected Backtrack Level 3, Got %0d", backtrack_level);
        if (learned_len == 0) $error("No learned clause produced");
        
        @(posedge clk);
        
        // Test 2: UNSAT Condition (Conflict at Level 0)
        $display("[Test 2] Level 0 Conflict (UNSAT)");
        conflict_len <= 2;
        conflict_lits[0] <= 5; conflict_levels[0] <= 0;
        conflict_lits[1] <= 6; conflict_levels[1] <= 0;
        @(posedge clk);
        
        start <= 1;
        decision_level <= 0;
        
        @(posedge clk);
        start <= 0;
        wait(done);
        
        #1;
        if (!unsat) $error("Failed to detect UNSAT!");
        else $display("  UNSAT Correctly Detected");
        
        @(posedge clk);
        $display("=== CAE TEST COMPLETE ===");
        $finish;
    end
endmodule
