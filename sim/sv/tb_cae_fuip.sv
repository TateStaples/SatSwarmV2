`timescale 1ns/1ps

module tb_cae_fuip;
    // Parameters
    parameter int MAX_LITS = 8;
    parameter int LEVEL_W = 16;
    parameter int MAX_VARS = 256;

    // Signals
    logic clk;
    logic reset;
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
    logic found_uip;

    // New Interfaces
    logic [15:0] trail_read_idx;
    logic [31:0] trail_read_var;
    logic        trail_read_value;
    logic [15:0] trail_read_level;
    logic        trail_read_is_decision;
    logic [15:0] trail_height;

    logic [31:0] reason_query_var;
    logic [15:0] reason_query_clause;
    logic        reason_query_valid;

    logic [15:0] clause_read_id;
    logic [3:0]  clause_read_lit_idx;
    logic signed [31:0] clause_read_literal;
    logic [15:0] clause_read_len;

    logic [31:0] level_query_var;
    logic [15:0] level_query_levels;

    // MOCK STORAGE
    logic [31:0] trail_vars [0:MAX_VARS-1];
    logic [15:0] trail_levels_list [0:MAX_VARS-1]; // Level at trail pos
    logic [15:0] var_level [0:MAX_VARS-1];         // Level of var
    logic [15:0] reason_map [0:MAX_VARS-1];        // Reason clause ID for var
    logic signed [31:0] clauses [0:255][0:7];      // Clause store
    logic [15:0] clause_lens [0:255];
    
    // DUT Instantiation
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
        .done(done),
        // Interface wiring
        .trail_read_idx(trail_read_idx),
        .trail_read_var(trail_read_var),
        .trail_read_value(trail_read_value),
        .trail_read_level(trail_read_level),
        .trail_read_is_decision(trail_read_is_decision),
        .trail_height(trail_height),
        .reason_query_var(reason_query_var),
        .reason_query_clause(reason_query_clause),
        .reason_query_valid(reason_query_valid),
        .clause_read_id(clause_read_id),
        .clause_read_lit_idx(clause_read_lit_idx),
        .clause_read_literal(clause_read_literal),
        .clause_read_len(clause_read_len),
        .level_query_var(level_query_var),
        .level_query_levels(level_query_levels)
    );

    // Mock Logic
    always_comb begin
        // Trail Read
        if (trail_read_idx < trail_height) begin
            trail_read_var = trail_vars[trail_read_idx];
            trail_read_level = trail_levels_list[trail_read_idx];
            trail_read_value = 0; // Value not critical for resolution search usually?
            trail_read_is_decision = (reason_map[trail_read_var] == 16'hFFFF);
        end else begin
            trail_read_var = 0;
            trail_read_level = 0;
            trail_read_value = 0;
            trail_read_is_decision = 0;
        end

        // Reason Query
        if (reason_query_var < MAX_VARS) begin
            reason_query_clause = reason_map[reason_query_var];
            reason_query_valid = 1;
        end else begin
            reason_query_clause = 16'hFFFF;
            reason_query_valid = 0;
        end

        // Clause Read
        clause_read_len = clause_lens[clause_read_id];
        if (clause_read_lit_idx < clause_read_len)
            clause_read_literal = clauses[clause_read_id][clause_read_lit_idx];
        else
            clause_read_literal = 0;

        // Level Query
        if (level_query_var < MAX_VARS)
            level_query_levels = var_level[level_query_var];
        else
            level_query_levels = 0;
    end

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Helper to set up trail and var
    function void push_trail(int var_idx, int level, int reason_id);
        trail_vars[trail_height] = var_idx;
        trail_levels_list[trail_height] = level;
        var_level[var_idx] = level;
        reason_map[var_idx] = reason_id;
        trail_height++;
    endfunction

    // Helper to define clause
    function void set_clause(int id, int len, int l0, int l1, int l2=0, int l3=0, int l4=0);
        clause_lens[id] = len;
        clauses[id][0] = l0;
        clauses[id][1] = l1;
        clauses[id][2] = l2;
        clauses[id][3] = l3;
        clauses[id][4] = l4;
    endfunction

    initial begin
        $display("=== TB_CAE_FUIP START TEST ===");
        reset = 1;
        start = 0;
        trail_height = 0;
        for (int i=0; i<MAX_VARS; i++) begin
            trail_vars[i] = 0;
            var_level[i] = 0;
            reason_map[i] = 16'hFFFF;
        end
        repeat(5) @(posedge clk);
        reset = 0;
        repeat(2) @(posedge clk);

        // Scenario 1: Needs Resolution
        // Current Level = 5
        // Trail: 
        //   Lvl 2: Var 4 (Dec)
        //   Lvl 3: Var 5 (Dec)
        //   Lvl 5: Var 6 (Dec)
        //   Lvl 5: Var 1 (Implied by C1: {1, -6}) -> Reason C1
        //   Lvl 5: Var 2 (Implied by C2: {2, -1}) -> Reason C2
        //   Lvl 5: Var 3 (Implied by C3: {3, -2}) -> Reason C3
        // Conflict Clause: {-4, -5, -3} (Lvl 2, 3, 5) -> Conflict at Var 3
        // Order on trail (oldest->newest): 4, 5, 6, 1, 2, 3
        
        // Setup Trail
        trail_height = 0;
        push_trail(4, 2, 16'hFFFF); // Dec
        push_trail(5, 3, 16'hFFFF); // Dec
        push_trail(6, 5, 16'hFFFF); // Dec (UIP candidates start here)
        push_trail(1, 5, 101);      // Implied by C101
        push_trail(2, 5, 102);      // Implied by C102
        push_trail(3, 5, 103);      // Implied by C103

        // Setup Clauses
        // C101: {1, -6} (Reason for 1) - Note: stored as literals. 1 is var 1. -6 is lit.
        set_clause(101, 2, 1, -6);
        // C102: {2, -1} (Reason for 2)
        set_clause(102, 2, 2, -1);
        // C103: {3, -2} (Reason for 3)
        // But conflict is caused by C_conflict: {-4, -5, -3}
        // Conflict clause lits passed to CAE: -4, -5, -3.
        
        // Start CAE
        start <= 1;
        decision_level <= 5;
        conflict_len <= 3;
        // Conflict: {-3, -5, -4}. -3 is Lvl 5. -5 is Lvl 3. -4 is Lvl 2.
        conflict_lits[0] <= -3; conflict_levels[0] <= 5;
        conflict_lits[1] <= -5; conflict_levels[1] <= 3;
        conflict_lits[2] <= -4; conflict_levels[2] <= 2;

        @(posedge clk);
        start <= 0;

        // Monitor
        wait(done);
        $display("Done! Learned Len: %0d", learned_len);
        for(int k=0; k<learned_len; k++) $display("  Lit[%0d]: %0d", k, learned_clause[k]);
        $display("Backtrack Level: %0d", backtrack_level);
        $display("UNSAT: %0d", unsat);
        $display("Valid: %0d", learned_valid);

        // Verification
        // Resolution Trace:
        // 1. Conflict {-3, -5, -4}. Level 5 vars: {-3}. Count=1.
        // Wait, if Count=1 immediately, no resolution needed?
        // Ah, First-UIP: Stop when ONE literal at max level remains.
        // Here, {-3} is the only one at Level 5.
        // So UIP is -3.
        // Result: {-3, -5, -4}.
        // This stops immediately. We want it to resolve!
        // We need MULTIPLE literals at Level 5 in conflict.
        
        // Let's Retry Scenario 2: Two Lvl 5 lits.
        // Conflict: {-3, -2, -5}
        // -3 is Lvl 5. -2 is Lvl 5. -5 is Lvl 3.
        // Count=2.
        // Trail Order (newest): 3, 2, 1, 6...
        // Most recent in conflict: 3.
        // Resolve 3 with Reason(3)=C103={3, -2}.
        // Resolve(-3, {3, -2}) -> {-2, -5}.
        // Now literals: {-2, -5}.
        // -2 is Lvl 5. -5 is Lvl 3.
        // Count at Lvl 5: 1 (only -2).
        // UIP Found: -2.
        // Done.
        // Result: {-2, -5}.
        
        reset = 1; trail_height = 0;
        repeat(2) @(posedge clk); reset=0;
        
        // Re-setup same trail
        push_trail(4, 2, 16'hFFFF);
        push_trail(5, 3, 16'hFFFF);
        push_trail(6, 5, 16'hFFFF);
        push_trail(1, 5, 101);
        push_trail(2, 5, 102);
        push_trail(3, 5, 103);
        
        // Clauses same
        set_clause(101, 2, 1, -6);
        set_clause(102, 2, 2, -1);
        set_clause(103, 2, 3, -2); // Reason for 3 is {3, -2}

        $display("\n[Scenario 2] Two Level 5 literals");
        start <= 1;
        decision_level <= 5;
        conflict_len <= 3;
        // Conflict: {-3, -2, -5}
        conflict_lits[0] <= -3; conflict_levels[0] <= 5;
        conflict_lits[1] <= -2; conflict_levels[1] <= 5;
        conflict_lits[2] <= -5; conflict_levels[2] <= 3;

        @(posedge clk);
        start <= 0;
        wait(done);
        
        $display("Learned: ");
        for(int k=0; k<learned_len; k++) $display(" %0d", learned_clause[k]);
        
        // Check
        // Expected: {-2, -5} (or equivalent). -2 is UIP.
        // Actually, resolve -3 with {3, -2}. -> {-2, -5}.
        // Does {-2} appear in conflict? Yes.
        // Merging {3,-2} with {-3, -2, -5}.
        // -3 removes 3 (or vice versa).
        // -2 duplicates.
        // Result {-2, -5}.
        
        if (learned_len == 2) begin
             if (learned_clause[0] == -2 || learned_clause[1] == -2) 
                 $display("PASS: Found UIP -2");
             else $error("FAIL: Did not find UIP -2");
        end else $error("FAIL: Length mismatch. Exp 2, Got %0d", learned_len);

        // Verification of Deep Resolution
        // Scenario 3: 6 -> 1 -> 2 -> 3.  And 6 -> 7.
        // Conflict {-3, -2, -1, -7, -5}.
        // -3, -2, -1 resolve to -6 eventually (as seen before).
        // -7 resolves to -6 (derived from {7, -6}).
        // Result should be {-6, -5}. -6 is the First UIP.
        
        $display("\n[Scenario 3] Deep Resolution (Diamond Graph)");
         reset = 1; repeat(2) @(posedge clk); reset=0;
         
         // Setup Trail with Var 7
         trail_height = 0;
         push_trail(4, 2, 16'hFFFF);
         push_trail(5, 3, 16'hFFFF);
         push_trail(6, 5, 16'hFFFF); // Dec
         push_trail(7, 5, 104);      // Implied by C104 {7, -6}
         push_trail(1, 5, 101);
         push_trail(2, 5, 102);
         push_trail(3, 5, 103);
         
         // Add Clause 104
         set_clause(104, 2, 7, -6);
         
         // Restore others (reset clears trail but not clauses/memory? 
         // My testbench logic resets trail_height and clearing usage, but clauses array persists.
         // But need to ensure C101, C102, C103 are still there. They are.
         
         start <= 1;
         conflict_len <= 5;
         decision_level <= 5;
         conflict_lits[0] <= -3; conflict_levels[0] <= 5;
         conflict_lits[1] <= -2; conflict_levels[1] <= 5;
         conflict_lits[2] <= -1; conflict_levels[2] <= 5;
         conflict_lits[3] <= -7; conflict_levels[3] <= 5;
         conflict_lits[4] <= -5; conflict_levels[4] <= 3;
         
         @(posedge clk); start <= 0; wait(done);
         
         $display("Learned: ");
         for(int k=0; k<learned_len; k++) $display(" %0d", learned_clause[k]);

         // Expect {-6, -5}
         found_uip = 0;
         for(int k=0; k<learned_len; k++) if(learned_clause[k] == -6) found_uip=1;
         
         if (found_uip && learned_len==2) $display("PASS: Resolved to UIP -6");
         else $error("FAIL: Expected {-6, -5}");

        $display("=== TEST COMPLETE ===");
        $finish;
    end
endmodule
