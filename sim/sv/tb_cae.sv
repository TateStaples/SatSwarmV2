`timescale 1ns/1ps

module tb_cae;

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

    logic [15:0] trail_read_idx;
    logic [15:0] trail_height_sig;
    logic [31:0] reason_query_var;
    logic [15:0] clause_read_id;
    logic [$clog2(MAX_LITS+1)-1:0] clause_read_lit_idx;
    logic [31:0] level_query_var;

    assign trail_height_sig = 0;

    cae #(
        .MAX_LITS(MAX_LITS),
        .LEVEL_W(LEVEL_W),
        .MAX_VARS(256)
    ) dut (
        .DEBUG(32'd0),
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
        .done(done),
        .trail_read_idx(trail_read_idx),
        .trail_read_var(32'd0),
        .trail_read_value(1'b0),
        .trail_read_level(16'd0),
        .trail_read_is_decision(1'b0),
        .trail_read_reason(16'hFFFF),
        .trail_height(trail_height_sig),
        .reason_query_var(reason_query_var),
        .reason_query_clause(16'd0),
        .reason_query_valid(1'b0),
        .clause_read_id(clause_read_id),
        .clause_read_lit_idx(clause_read_lit_idx),
        .clause_read_literal(32'sd0),
        .clause_read_len(16'd0),
        .level_query_var(level_query_var),
        .level_query_levels(16'd0)
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
        // Only one literal at decision level -> immediate UIP
        // UIP = Lit 10, backtrack to level 3 (second-highest)
        
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
