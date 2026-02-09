`timescale 1ns/1ps
// Mini 2-Core Mesh Testbench
// Tests work-stealing fork handshake between two cores
module tb_mini_mesh;
    logic clk;
    logic rst_n;

    // Parameters
    parameter int MAX_VARS = 32;
    parameter int MAX_CLAUSES = 64;
    parameter int MAX_LITS = 512;
    parameter int MAX_CLAUSE_LEN = 8;

    // Debug level
    int DEBUG = 1;

    // =========================================================================
    // Core 0 signals
    // =========================================================================
    logic               core0_load_valid;
    logic signed [31:0] core0_load_literal;
    logic               core0_load_clause_end;
    logic               core0_load_ready;
    logic               core0_start;
    logic               core0_done;
    logic               core0_sat;
    logic               core0_unsat;
    logic [31:0]        core0_conflict_count;
    logic [31:0]        core0_decision_count;
    
    // Work stealing (Core 0)
    logic                        core0_fork_valid;
    logic [2*MAX_VARS-1:0]       core0_fork_assignments;
    logic signed [31:0]          core0_fork_decision;
    logic                        core0_fork_ready;
    logic                        core0_idle;
    logic [2*MAX_VARS-1:0]       core0_my_assignments;
    logic signed [31:0]          core0_my_pending_decision;

    // =========================================================================
    // Core 1 signals
    // =========================================================================
    logic               core1_load_valid;
    logic signed [31:0] core1_load_literal;
    logic               core1_load_clause_end;
    logic               core1_load_ready;
    logic               core1_start;
    logic               core1_done;
    logic               core1_sat;
    logic               core1_unsat;
    logic [31:0]        core1_conflict_count;
    logic [31:0]        core1_decision_count;
    
    // Work stealing (Core 1)
    logic                        core1_fork_valid;
    logic [2*MAX_VARS-1:0]       core1_fork_assignments;
    logic signed [31:0]          core1_fork_decision;
    logic                        core1_fork_ready;
    logic                        core1_idle;
    logic [2*MAX_VARS-1:0]       core1_my_assignments;
    logic signed [31:0]          core1_my_pending_decision;

    // =========================================================================
    // Instantiate Core 0
    // =========================================================================
    mini_top #(
        .MAX_VARS(MAX_VARS),
        .MAX_CLAUSES(MAX_CLAUSES),
        .MAX_LITS(MAX_LITS),
        .MAX_CLAUSE_LEN(MAX_CLAUSE_LEN)
    ) core0 (
        .DEBUG(DEBUG),
        .clk(clk),
        .rst_n(rst_n),
        .start_solve(core0_start),
        .done(core0_done),
        .sat(core0_sat),
        .unsat(core0_unsat),
        .load_valid(core0_load_valid),
        .load_literal(core0_load_literal),
        .load_clause_end(core0_load_clause_end),
        .load_ready(core0_load_ready),
        .conflict_count(core0_conflict_count),
        .decision_count(core0_decision_count),
        // Work stealing
        .fork_valid(core0_fork_valid),
        .fork_assignments(core0_fork_assignments),
        .fork_decision(core0_fork_decision),
        .fork_ready(core0_fork_ready),
        .idle(core0_idle),
        .my_assignments(core0_my_assignments),
        .my_pending_decision(core0_my_pending_decision)
    );

    // =========================================================================
    // Instantiate Core 1
    // =========================================================================
    mini_top #(
        .MAX_VARS(MAX_VARS),
        .MAX_CLAUSES(MAX_CLAUSES),
        .MAX_LITS(MAX_LITS),
        .MAX_CLAUSE_LEN(MAX_CLAUSE_LEN)
    ) core1 (
        .DEBUG(DEBUG),
        .clk(clk),
        .rst_n(rst_n),
        .start_solve(core1_start),
        .done(core1_done),
        .sat(core1_sat),
        .unsat(core1_unsat),
        .load_valid(core1_load_valid),
        .load_literal(core1_load_literal),
        .load_clause_end(core1_load_clause_end),
        .load_ready(core1_load_ready),
        .conflict_count(core1_conflict_count),
        .decision_count(core1_decision_count),
        // Work stealing
        .fork_valid(core1_fork_valid),
        .fork_assignments(core1_fork_assignments),
        .fork_decision(core1_fork_decision),
        .fork_ready(core1_fork_ready),
        .idle(core1_idle),
        .my_assignments(core1_my_assignments),
        .my_pending_decision(core1_my_pending_decision)
    );

    // =========================================================================
    // Clock
    // =========================================================================
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz

    // =========================================================================
    // Fork controller - monitors Core 0's DECIDE state and forks to Core 1
    // =========================================================================
    logic fork_triggered;
    logic [31:0] fork_cycle;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            core1_fork_valid <= 1'b0;
            core1_fork_assignments <= '0;
            core1_fork_decision <= '0;
            fork_triggered <= 1'b0;
            fork_cycle <= '0;
        end else begin
            // Fork trigger: Core 1 is idle AND Core 0 is about to decide
            // We check core0's pending decision - if non-zero, fork!
            if (core1_idle && core1_fork_ready && 
                core0_my_pending_decision != 0 && !fork_triggered &&
                !core0_done) begin
                
                $display("[%0t] FORK: Core0 -> Core1", $time);
                $display("  Assignments: Core0 has %0d bits set", 
                    $countones(core0_my_assignments));
                $display("  Core0 takes: +%0d", 
                    (core0_my_pending_decision < 0) ? -core0_my_pending_decision : core0_my_pending_decision);
                $display("  Core1 takes: %0d", 
                    -core0_my_pending_decision);
                
                // Send fork to Core 1 (opposite polarity)
                core1_fork_valid <= 1'b1;
                core1_fork_assignments <= core0_my_assignments;
                core1_fork_decision <= -core0_my_pending_decision; // Opposite branch
                fork_triggered <= 1'b1;
                fork_cycle <= cycle_count;
            end else begin
                core1_fork_valid <= 1'b0;
            end
        end
    end

    // Core 0 doesn't receive forks in this simple test
    assign core0_fork_valid = 1'b0;
    assign core0_fork_assignments = '0;
    assign core0_fork_decision = '0;

    // Core 1 doesn't get direct start (only via fork)
    assign core1_start = 1'b0;
    assign core1_load_valid = 1'b0;
    assign core1_load_literal = '0;
    assign core1_load_clause_end = 1'b0;

    // =========================================================================
    // Test Control
    // =========================================================================
    longint unsigned cycle_count;
    longint unsigned max_cycles = 100000;

    task automatic push_literal_core0(input int lit, input bit clause_end);
    begin
        @(posedge clk);
        while (!core0_load_ready) @(posedge clk);
        core0_load_valid <= 1'b1;
        core0_load_literal <= lit;
        core0_load_clause_end <= clause_end;
        @(posedge clk);
        core0_load_valid <= 1'b0;
        core0_load_clause_end <= 1'b0;
    end
    endtask

    task automatic load_simple_cnf();
        // Simple SAT problem that requires decisions:
        // p cnf 4 4
        // 1 2 0
        // -1 -2 0
        // 3 4 0
        // -3 -4 0
        // Solution: x1=T, x2=F, x3=T, x4=F
    begin
        $display("Loading simple 4-var CNF...");
        push_literal_core0(1, 0); push_literal_core0(2, 1);   // Clause 1
        push_literal_core0(-1, 0); push_literal_core0(-2, 1); // Clause 2
        push_literal_core0(3, 0); push_literal_core0(4, 1);   // Clause 3
        push_literal_core0(-3, 0); push_literal_core0(-4, 1); // Clause 4
        $display("CNF loaded.");
    end
    endtask

    // =========================================================================
    // Main Test
    // =========================================================================
    initial begin
        $display("\n");
        $display("=====================================");
        $display("Mini 2-Core Mesh Testbench");
        $display("=====================================");
        $display("Testing work-stealing fork handshake");
        $display("Core 0: Primary solver, loads problem");
        $display("Core 1: Idle, receives fork from Core 0");
        $display("\n");

        // Reset
        rst_n = 0;
        core0_load_valid = 0;
        core0_load_literal = 0;
        core0_load_clause_end = 0;
        core0_start = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        // Load CNF to Core 0 only
        load_simple_cnf();

        // Start Core 0
        $display("[%0t] Starting Core 0 solve...", $time);
        @(posedge clk);
        core0_start <= 1'b1;
        @(posedge clk);
        core0_start <= 1'b0;

        // Run simulation
        cycle_count = 0;
        while (!(core0_done || core1_done) && cycle_count < max_cycles) begin
            @(posedge clk);
            cycle_count++;
            
            if (cycle_count % 1000 == 0) begin
                $display("[Cycle %0d] C0: done=%b sat=%b | C1: done=%b sat=%b idle=%b",
                    cycle_count, core0_done, core0_sat, core1_done, core1_sat, core1_idle);
            end
        end

        // Results
        $display("\n=====================================");
        $display("RESULTS");
        $display("=====================================");
        $display("Cycles: %0d", cycle_count);
        $display("Fork triggered: %s at cycle %0d", fork_triggered ? "YES" : "NO", fork_cycle);
        $display("");
        $display("Core 0: done=%b sat=%b unsat=%b conflicts=%0d decisions=%0d",
            core0_done, core0_sat, core0_unsat, core0_conflict_count, core0_decision_count);
        $display("Core 1: done=%b sat=%b unsat=%b conflicts=%0d decisions=%0d",
            core1_done, core1_sat, core1_unsat, core1_conflict_count, core1_decision_count);

        if (fork_triggered) begin
            $display("\n*** FORK HANDSHAKE SUCCESSFUL ***");
        end else begin
            $display("\n*** WARNING: No fork occurred ***");
        end

        if (core0_sat || core1_sat) begin
            $display("*** SAT FOUND ***");
        end else if (core0_unsat && core1_unsat) begin
            $display("*** UNSAT ***");
        end

        $display("=====================================\n");
        $finish;
    end

    // Timeout
    initial begin
        #100000000; // 100ms sim time
        $display("\n*** TIMEOUT ***");
        $finish;
    end

endmodule
