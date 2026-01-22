`timescale 1ns/1ps
// Mini DPLL Testbench
// Tests the pure DPLL solver (no CAE/learned clauses)
module tb_mini;
    logic clk;
    logic rst_n;
    logic host_load_valid;
    logic signed [31:0] host_load_literal;
    logic host_load_clause_end;
    logic host_start;
    logic host_load_ready;
    logic host_done;
    logic host_sat;
    logic host_unsat;
    logic [31:0] conflict_count;
    logic [31:0] decision_count;

    // Parameters
    parameter int MAX_VARS = 256;
    parameter int MAX_CLAUSES = 256;
    parameter int MAX_LITS = 2048;
    parameter int MAX_CLAUSE_LEN = 16;

    // Debug level from command line
    int DEBUG = 0;

    // DUT - Mini DPLL Top Level
    mini_top #(
        .MAX_VARS(MAX_VARS),
        .MAX_CLAUSES(MAX_CLAUSES),
        .MAX_LITS(MAX_LITS),
        .MAX_CLAUSE_LEN(MAX_CLAUSE_LEN)
    ) dut (
        .DEBUG(DEBUG),
        .clk(clk),
        .rst_n(rst_n),
        .start_solve(host_start),
        .done(host_done),
        .sat(host_sat),
        .unsat(host_unsat),
        .load_valid(host_load_valid),
        .load_literal(host_load_literal),
        .load_clause_end(host_load_clause_end),
        .load_ready(host_load_ready),
        .conflict_count(conflict_count),
        .decision_count(decision_count)
    );

    initial clk = 0;
    always #5 clk = ~clk; // 100MHz

    // Performance counters
    longint unsigned cycle_count;
    int clause_count;
    int var_count;
    string test_name;
    real start_time;
    real end_time;
    int clause_store[$][];
    int passed_tests = 0;
    int failed_tests = 0;

    // Command line args
    string cnf_file;
    string expect_str;
    bit expected_sat;
    longint unsigned max_cycles;

    task push_literal(input int lit, input bit clause_end);
    begin
        @(posedge clk);
        while (!host_load_ready) @(posedge clk);
        host_load_valid <= 1'b1;
        host_load_literal <= lit;
        host_load_clause_end <= clause_end;
        host_start <= 1'b0;
        @(posedge clk);
        host_load_valid <= 1'b0;
        host_load_clause_end <= 1'b0;
    end
    endtask

    task load_cnf_file(input string filename);
        int fd;
        string line;
        int lit;
        int scan_result;
        int num_vars, num_clauses;
        int literals[$];
        int clause_copy[];
    begin
        $display("[%0t] Loading CNF file: %s", $time, filename);
        $display("[DEBUG] host_load_ready = %0d", host_load_ready);
        fd = $fopen(filename, "r");
        if (fd == 0) begin
            $display("ERROR: Cannot open file %s", filename);
            $finish;
        end

        clause_count = 0;
        clause_store.delete();
        var_count = 0;

        while (!$feof(fd)) begin
            if ($fgets(line, fd)) begin
                if (line[0] == "c") continue;
                if (line[0] == "p") begin
                    scan_result = $sscanf(line, "p cnf %d %d", num_vars, num_clauses);
                    if (scan_result == 2) begin
                        var_count = num_vars;
                        $display("  Problem: %0d variables, %0d clauses", num_vars, num_clauses);
                    end
                    continue;
                end
                begin
                    int pos = 0;
                    literals.delete();
                    while (pos < line.len()) begin
                        scan_result = $sscanf(line.substr(pos, line.len()-1), "%d", lit);
                        if (scan_result == 1) begin
                            if (lit == 0) begin
                                foreach (literals[i]) begin
                                    push_literal(literals[i], (i == literals.size()-1));
                                end
                                clause_copy = literals;
                                clause_store.push_back(clause_copy);
                                clause_count++;
                                break;
                            end else begin
                                literals.push_back(lit);
                            end
                            while (pos < line.len() && (line[pos] == " " || line[pos] == "\t")) pos++;
                            if (lit < 0) pos++;
                            while (pos < line.len() && line[pos] >= "0" && line[pos] <= "9") pos++;
                        end else begin
                            break;
                        end
                    end
                end
            end
        end

        $fclose(fd);
        $display("  Loaded %0d clauses", clause_count);
    end
    endtask

    // Model verification using PSE assignment state
    task verify_model(output bit valid);
        int unsat_clauses = 0;
        logic [1:0] state;
        bit clause_sat;
    begin
        $display("  Verifying model...");
        
        foreach (clause_store[c]) begin
            clause_sat = 0;
            foreach (clause_store[c][l]) begin
                int lit = clause_store[c][l];
                int var_idx = (lit < 0) ? -lit : lit;
                
                // Read assignment from PSE
                if (var_idx > 0 && var_idx <= MAX_VARS) begin
                    state = dut.u_solver.u_pse.assign_state[var_idx-1];
                end else begin
                    state = 2'b00;
                end

                if (lit > 0 && state == 2'b10) clause_sat = 1;
                if (lit < 0 && state == 2'b01) clause_sat = 1;
            end
            if (!clause_sat) begin
                unsat_clauses++;
                if (unsat_clauses <= 3) begin
                    $display("    Failed Clause %0d: {", c);
                    foreach (clause_store[c][l]) begin
                        $display("      lit=%0d", clause_store[c][l]);
                    end
                    $display("    }");
                end
            end
        end

        if (unsat_clauses == 0) begin
            $display("  MODEL VERIFIED: Valid.");
            valid = 1'b1;
        end else begin
            $display("  MODEL INVALID: %0d clauses not satisfied.", unsat_clauses);
            valid = 1'b0;
        end
    end
    endtask

    task run_test(input string name, input string cnf_file_arg, input bit expected_sat_arg, input longint unsigned max_cycles_arg);
        bit model_valid;
    begin
        model_valid = 1'b1;
        test_name = name;
        $display("\n========================================");
        $display("TEST: %s", name);
        $display("========================================");

        rst_n = 0;
        host_load_valid = 0;
        host_load_literal = 0;
        host_load_clause_end = 0;
        host_start = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        start_time = $realtime;
        load_cnf_file(cnf_file_arg);

        $display("Starting solve at time %0t", $time);
        @(posedge clk);
        host_start <= 1'b1;
        @(posedge clk);
        host_start <= 1'b0;

        cycle_count = 0;
        while (!host_done && cycle_count < max_cycles_arg) begin
            @(posedge clk);
            cycle_count++;
            if (cycle_count % 100000 == 0) begin
                $display("[Cycle %0d] done=%0d sat=%0d unsat=%0d", cycle_count, host_done, host_sat, host_unsat);
            end
        end
        end_time = $realtime;
        $display("[Final Cycle %0d] done=%0d sat=%0d unsat=%0d", cycle_count, host_done, host_sat, host_unsat);

        if (host_done) begin
            real time_ms;
            time_ms = (end_time - start_time) / 1000000.0;
            
            $display("\n=== RESULTS ===");
            $display("  Status: %s", host_sat ? "SAT" : "UNSAT");
            $display("  Expected: %s", expected_sat_arg ? "SAT" : "UNSAT");
            $display("  Cycles: %0d", cycle_count);
            $display("  Conflicts: %0d", conflict_count);
            $display("  Decisions: %0d", decision_count);
            $display("  Sim Time: %.3f ms", time_ms);
            
            if (host_sat) begin
                verify_model(model_valid);
            end

            if ((host_sat == expected_sat_arg) && model_valid) begin
                $display("\n*** TEST PASSED ***\n");
                passed_tests++;
            end else begin
                $display("\n*** TEST FAILED ***\n");
                failed_tests++;
            end
        end else begin
            $display("\n=== TIMEOUT ===");
            $display("  Exceeded %0d cycles", max_cycles_arg);
            $display("\n*** TEST FAILED ***\n");
            failed_tests++;
        end
    end
    endtask

    initial begin
        // Parse command line arguments
        if (!$value$plusargs("CNF=%s", cnf_file)) begin
            $display("ERROR: No +CNF argument provided");
            $display("Usage: ./Vtb_mini +CNF=<file.cnf> +EXPECT=<SAT|UNSAT> [+MAXCYCLES=N] [+DEBUG=N]");
            $finish;
        end
        
        if (!$value$plusargs("EXPECT=%s", expect_str)) begin
            expect_str = "";
        end
        expected_sat = (expect_str == "SAT");
        
        if (!$value$plusargs("MAXCYCLES=%d", max_cycles)) begin
            max_cycles = 5000000;
        end
        
        if (!$value$plusargs("DEBUG=%d", DEBUG)) begin
            DEBUG = 0;
        end
        $display("DEBUG ARG VALUE: %d", DEBUG);

        $display("\n");
        $display("=====================================");
        $display("Mini DPLL Testbench");
        $display("=====================================");
        $display("Clock: 100 MHz (10ns period)");
        $display("Max Vars: %0d", MAX_VARS);
        $display("Max Clauses: %0d", MAX_CLAUSES);
        $display("CNF File: %s", cnf_file);
        $display("Expected: %s", expect_str);
        $display("Max Cycles: %0d", max_cycles);
        $display("\n");

        run_test("CNF Test", cnf_file, expected_sat, max_cycles);

        $display("\n");
        $display("=====================================");
        $display("MINI DPLL TEST SUMMARY");
        $display("=====================================");
        $display("PASSED: %0d", passed_tests);
        $display("FAILED: %0d", failed_tests);
        $display("=====================================");
        
        if (passed_tests > 0 && failed_tests == 0) begin
            $display("TEST PASSED");
        end
        
        $finish;
    end

    // Timeout watchdog
    initial begin
        #300000000000; // ~5 minutes sim time budget
        $display("\n*** GLOBAL TIMEOUT - ABORTING ***");
        $finish;
    end

endmodule
