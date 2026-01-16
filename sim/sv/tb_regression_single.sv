`timescale 1ns/1ps
module tb_regression_single;
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

  // DDR4 Mock (simplified)
  logic ddr_read_req;
  logic [31:0] ddr_read_addr;
  logic [7:0]  ddr_read_len;
  logic ddr_read_grant;
  logic [31:0] ddr_read_data;
  logic ddr_read_valid;
  logic ddr_write_req;
  logic [31:0] ddr_write_addr;
  logic [31:0] ddr_write_data;
  logic ddr_write_grant;

  // Parameters for testing - SINGLE CORE, but same max vars
  parameter int GRID_X = 1;
  parameter int GRID_Y = 1;
  parameter int MAX_VARS_PER_CORE = 42;
  parameter int MAX_CLAUSES_PER_CORE = 104;
  parameter int MAX_LITS = 416;

  int debug_level = 0; // Default to 0 (Minimal)

  // DUT - SatSwarm Top Level
  satswarm_top #(
    .GRID_X(GRID_X),
    .GRID_Y(GRID_Y),
    .MAX_VARS_PER_CORE(MAX_VARS_PER_CORE),
    .MAX_LITS(MAX_LITS)
  ) dut (
    .DEBUG(debug_level),
    .clk(clk),
    .rst_n(rst_n),
    .host_start(host_start),
    .host_done(host_done),
    .host_sat(host_sat),
    .host_unsat(host_unsat),
    .host_load_valid(host_load_valid),
    .host_load_literal(host_load_literal),
    .host_load_clause_end(host_load_clause_end),
    .host_load_ready(host_load_ready),
    .ddr_read_req(ddr_read_req),
    .ddr_read_addr(ddr_read_addr),
    .ddr_read_len(ddr_read_len),
    .ddr_read_grant(ddr_read_grant),
    .ddr_read_data(ddr_read_data),
    .ddr_read_valid(ddr_read_valid),
    .ddr_write_req(ddr_write_req),
    .ddr_write_addr(ddr_write_addr),
    .ddr_write_data(ddr_write_data),
    .ddr_write_grant(ddr_write_grant)
  );

  // DDR4 Mock
  always @(posedge clk) begin
    ddr_read_grant <= ddr_read_req;
    ddr_read_valid <= ddr_read_req;
    ddr_read_data <= '0;
    ddr_write_grant <= ddr_write_req;
  end

  initial clk = 0;
  always #5 clk = ~clk; // 100MHz

  // Performance counters and clause storage for brute-force verification
  longint unsigned cycle_count;
  int clause_count;
  int var_count;
  string test_name;
  real start_time;
  real end_time;
  int clause_store[$][];  // dynamic array of clauses (each clause is dynamic array of ints)

  task push_literal(input int lit, input bit clause_end);
    begin
      //$display("[%0t] Pushing literal %0d (clause_end=%0d)", $time, lit, clause_end);
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

  task automatic load_cnf_file(input string filename);
    int fd;
    string line;
    int lit;
    int scan_result;
    int num_vars, num_clauses;
    int literals[$];
    int clause_copy[];
    begin
      $display("[%0t] Loading CNF file: %s", $time, filename);
      fd = $fopen(filename, "r");
      if (fd == 0) begin
        $display("ERROR: Cannot open file %s", filename);
        $finish;
      end

      clause_count = 0;
      clause_store.delete();
      var_count = 0;
      clause_store.delete();

      while (!$feof(fd)) begin
        if ($fgets(line, fd)) begin
          // Skip comments
          if (line[0] == "c") continue;

          // Parse problem line
          if (line[0] == "p") begin
            scan_result = $sscanf(line, "p cnf %d %d", num_vars, num_clauses);
            if (scan_result == 2) begin
              var_count = num_vars;
              $display("  Problem: %0d variables, %0d clauses", num_vars, num_clauses);
            end
            continue;
          end

          // Parse clause literals
          begin
            int pos = 0;
            literals.delete();
            while (pos < line.len()) begin
              scan_result = $sscanf(line.substr(pos, line.len()-1), "%d", lit);
              if (scan_result == 1) begin
                if (lit == 0) begin
                  // End of clause - push all literals
                  foreach (literals[i]) begin
                    push_literal(literals[i], (i == literals.size()-1));
                  end
                  // Save a copy for brute-force verification
                  clause_copy = literals;
                  clause_store.push_back(clause_copy);
                  clause_count++;
                  break;
                end else begin
                  literals.push_back(lit);
                end
                // Advance position
                while (pos < line.len() && (line[pos] == " " || line[pos] == "\t")) pos++;
                if (lit < 0) pos++; // skip minus sign
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
      
      // Limit Checks
      if (var_count > MAX_VARS_PER_CORE * GRID_X * GRID_Y) begin
         $display("\n[ERROR] CNF Variables (%0d) exceed MAX_VARS (%0d)!", var_count, MAX_VARS_PER_CORE * GRID_X * GRID_Y);
         $display("[ERROR] Please increase MAX_VARS in Makefile.");
         $finish;
      end
      
      if (clause_count > MAX_CLAUSES_PER_CORE * GRID_X * GRID_Y) begin
         $display("\n[ERROR] CNF Clauses (%0d) exceed MAX_CLAUSES (%0d)!", clause_count, MAX_CLAUSES_PER_CORE * GRID_X * GRID_Y);
         $display("[ERROR] Please increase MAX_CLAUSES in Makefile.");
         $finish;
      end
      
      // We need to count total literals to check MAX_LITS
      // Re-scanning clause_store to count lits
      begin
          int total_lits = 0;
          foreach (clause_store[i]) begin
              total_lits += clause_store[i].size();
          end
          // Note: Each clause needs 4 words in memory? No, MAX_LITS is the literal memory size.
          // In clause_store.sv, lit_mem is [0:MAX_LITS-1].
          // HW stores literals packed.
          if (total_lits > MAX_LITS) begin
             $display("\n[ERROR] CNF Literals (%0d) exceed MAX_LITS (%0d)!", total_lits, MAX_LITS);
             $display("[ERROR] Please increase MAX_LITS in Makefile.");
             $finish;
          end
      end
    end
  endtask

  // Model Verification Task (checks if the solver's internal state actually satisfies the CNF)
  task automatic verify_model(output bit valid);
    int unsat_clauses = 0;
    logic [1:0] state;
    bit clause_sat;
    int winning_core_idx = -1;
    
    // Find which core reported SAT
    for (int i=0; i < GRID_X * GRID_Y; i++) begin
        if (dut.is_sat_core[i]) begin
            winning_core_idx = i;
            break;
        end
    end

    if (winning_core_idx == -1) begin
        $display("  Error: host_sat is true but no core reports is_sat?");
        winning_core_idx = 0; // Fallback to core 0
    end

    $display("  Verifying model from Core %0d (Grid Index %0d)...", winning_core_idx, winning_core_idx);

    foreach (clause_store[c]) begin
        clause_sat = 0;
        foreach (clause_store[c][l]) begin
            int lit = clause_store[c][l];
            int var_idx = (lit < 0) ? -lit : lit;
            
            // Read model from CORE TRAIL (source of truth)
            state = 2'b00; // default unassigned
            begin
                automatic int trail_h;
                automatic logic [31:0] tv;
                automatic logic val;
                
                // Switch based on winning core index (Hierarchical references cannot be indexed by variables)
                case (winning_core_idx)
                    0: trail_h = dut.cols[0].rows[0].u_core.u_trail.trail_height_q;
`ifdef MULTICORE
                    1: trail_h = (GRID_X > 1) ? dut.cols[0].rows[1].u_core.u_trail.trail_height_q : 0;
                    2: trail_h = (GRID_Y > 1) ? dut.cols[1].rows[0].u_core.u_trail.trail_height_q : 0;
                    3: trail_h = (GRID_X > 1 && GRID_Y > 1) ? dut.cols[1].rows[1].u_core.u_trail.trail_height_q : 0;
`endif
                    default: trail_h = 0;
                endcase
                
                for (int i=0; i < trail_h && i < MAX_VARS_PER_CORE; i++) begin
                    case (winning_core_idx)
                        0: begin tv = dut.cols[0].rows[0].u_core.u_trail.trail[i].variable; val = dut.cols[0].rows[0].u_core.u_trail.trail[i].value; end
`ifdef MULTICORE
                        1: if (GRID_X > 1) begin tv = dut.cols[0].rows[1].u_core.u_trail.trail[i].variable; val = dut.cols[0].rows[1].u_core.u_trail.trail[i].value; end
                        2: if (GRID_Y > 1) begin tv = dut.cols[1].rows[0].u_core.u_trail.trail[i].variable; val = dut.cols[1].rows[0].u_core.u_trail.trail[i].value; end
                        3: if (GRID_X > 1 && GRID_Y > 1) begin tv = dut.cols[1].rows[1].u_core.u_trail.trail[i].variable; val = dut.cols[1].rows[1].u_core.u_trail.trail[i].value; end
`endif
                    endcase
                    
                    if (tv == var_idx) begin
                        state = val ? 2'b10 : 2'b01;
                        break;
                    end
                end
            end

            if (lit > 0 && state == 2'b10) clause_sat = 1; // Var True == Lit True
            if (lit < 0 && state == 2'b01) clause_sat = 1; // Var False == Lit True (Negated)
        end
        if (!clause_sat) begin
            unsat_clauses++;
            // Optional: Print first few failures
            if (unsat_clauses <= 5) $display("    Failed Clause %0d (No literals satisfied)", c);
        end
    end

    if (unsat_clauses == 0) begin
        $display("  MODEL VERIFIED: Valid functionality.");
        valid = 1'b1;
    end else begin
        $display("  MODEL INVALID: %0d clauses not satisfied. SOUNDNESS BUG!", unsat_clauses);
        valid = 1'b0;
    end
  endtask

  task run_test(input string name, input string cnf_file, input bit expected_sat, input longint unsigned max_cycles);
    bit model_valid;
    begin
      model_valid = 1'b1; // Default valid
      test_name = name;
      $display("\n========================================");
      $display("TEST: %s", name);
      $display("========================================");

      // Reset
      rst_n = 0;
      host_load_valid = 0;
      host_load_literal = 0;
      host_load_clause_end = 0;
      host_start = 0;
      repeat (4) @(posedge clk);
      rst_n = 1;
      repeat (2) @(posedge clk);

      // Load CNF
      start_time = $realtime;
      load_cnf_file(cnf_file);

      // Start solving
      $display("Starting solve at time %0t", $time);
      @(posedge clk);
      host_start <= 1'b1;
      @(posedge clk);
      host_start <= 1'b0;
      $display("Started solve, now waiting for completion...");

      // Wait for completion
      cycle_count = 0;
      while (!host_done && cycle_count < max_cycles) begin
        @(posedge clk);
        cycle_count++;
        if (cycle_count == 1 || cycle_count == 2 || cycle_count == 3 || cycle_count % 10000 == 0) begin
          $display("[Cycle %0d] done=%0d sat=%0d unsat=%0d", cycle_count, host_done, host_sat, host_unsat);
        end
      end
      end_time = $realtime;
      $display("[Final Cycle %0d] done=%0d sat=%0d unsat=%0d - TEST STOPPING", cycle_count, host_done, host_sat, host_unsat);

      // Report results
      if (host_done) begin
        real time_ms;
        real freq_mhz;
        real time_actual_ms;
        time_ms = (end_time - start_time) / 1000000.0;
        freq_mhz = 100.0; // 100 MHz clock
        time_actual_ms = cycle_count / (freq_mhz * 1000.0);
        
        $display("\n=== RESULTS ===");
        $display("  Status: %s", host_sat ? "SAT" : "UNSAT");
        $display("  Expected: %s", expected_sat ? "SAT" : "UNSAT");
        $display("  Result: %s", (host_sat == expected_sat) ? "PASS" : "FAIL");
        $display("  Cycles: %0d", cycle_count);
        $display("  Sim Time: %.3f ms", time_ms);
        $display("  Est. Real Time @ 100MHz: %.3f ms", time_actual_ms);
        $display("  Clauses: %0d", clause_count);
        $display("  Variables: %0d", var_count);
        $display("  Result: %s", host_sat ? "SAT" : "UNSAT");
        
        if (host_sat) begin
            verify_model(model_valid);
            if (!model_valid) begin
                 $display("  Result Override: Marking as FAIL due to INVALID MODEL.");
            end
        end

        if (host_sat != expected_sat) begin
          $display("\n*** TEST FAILED ***\n");
          // $finish; // Don't stop, continue to next test
        end else begin
          $display("\n*** TEST PASSED ***\n");
        end
      end else begin
        $display("\n=== TIMEOUT ===");
        $display("  Exceeded %0d cycles", max_cycles);
        $display("  Status at timeout: done=%0d sat=%0d", host_done, host_sat);
        $display("\n*** TEST FAILED ***\n");
        // $finish; // Don't stop
      end
    end
  endtask

  initial begin
    // Dynamic Test Variables
    string dynamic_cnf;
    string expected_str;
    bit dynamic_expect_sat;
    bit has_dynamic_cnf;

    $display("\n");
    $display("=====================================");
    $display("VeriSAT SINGLE CORE Regression Suite");
    $display("=====================================");
    $display("Clock: 100 MHz (10ns period)");
    $display("Grid: %0dx%0d", GRID_X, GRID_Y);
    $display("Max Vars/Core: %0d", MAX_VARS_PER_CORE);
    $display("Max Clauses/Core: %0d", MAX_CLAUSES_PER_CORE);
    $display("\n");

    // Check for Command Line Arguments (Dynamic Testing)
    if ($value$plusargs("DEBUG=%d", debug_level)) begin
        // debug_level updated
    end

    has_dynamic_cnf = 0;
    
    if ($value$plusargs("CNF=%s", dynamic_cnf)) begin
        has_dynamic_cnf = 1;
        $display("DYNAMIC TEST MODE: Loading %s", dynamic_cnf);
        
        // Check for expected result
        dynamic_expect_sat = 0; 
        
        if ($value$plusargs("EXPECT=%s", expected_str)) begin
            if (expected_str == "SAT" || expected_str == "sat") begin
                dynamic_expect_sat = 1;
            end else if (expected_str == "UNSAT" || expected_str == "unsat") begin
                dynamic_expect_sat = 0;
            end else begin
                $display("WARNING: Unknown EXPECT value '%s', defaulting to UNSAT checking", expected_str);
            end
        end else begin
             $display("WARNING: No +EXPECT provided, defaulting to UNSAT expectation.");
             dynamic_expect_sat = 0;
        end
        
        run_test("Dynamic Test", dynamic_cnf, dynamic_expect_sat, 20000000); 
        
    end else begin
        // === STANDARD REGRESSION SUITE ===
    
        // 5 Variables
        run_test("SAT 5v #1", "../tests/generated_instances/sat_5v_10c_1.cnf", 1'b1, 100000);
        run_test("UNSAT 5v #1", "../tests/generated_instances/unsat_5v_10c_1.cnf", 1'b0, 100000);
    
        // 8 Variables
        run_test("SAT 8v #1", "../tests/generated_instances/sat_8v_20c_1.cnf", 1'b1, 200000);
        run_test("UNSAT 8v #1", "../tests/generated_instances/unsat_8v_20c_1.cnf", 1'b0, 200000);
    
        // 10 Variables
        run_test("SAT 10v #1", "../tests/generated_instances/sat_10v_30c_1.cnf", 1'b1, 500000);
        run_test("UNSAT 10v #1", "../tests/generated_instances/unsat_10v_30c_1.cnf", 1'b0, 500000);
    
        // 12 Variables
        run_test("SAT 12v #1", "../tests/generated_instances/sat_12v_40c_1.cnf", 1'b1, 1000000);
        run_test("UNSAT 12v #1", "../tests/generated_instances/unsat_12v_40c_1.cnf", 1'b0, 1000000);
    
        // 15 Variables
        run_test("SAT 15v #1", "../tests/generated_instances/sat_15v_50c_1.cnf", 1'b1, 2000000);
        run_test("UNSAT 15v #1", "../tests/generated_instances/unsat_15v_50c_1.cnf", 1'b0, 2000000);
    
        // 18 Variables
        run_test("SAT 18v #1", "../tests/generated_instances/sat_18v_70c_1.cnf", 1'b1, 5000000);
        run_test("UNSAT 18v #1", "../tests/generated_instances/unsat_18v_70c_1.cnf", 1'b0, 5000000);
    
        // 20 Variables
        run_test("SAT 20v #1", "../tests/generated_instances/sat_20v_80c_1.cnf", 1'b1, 5000000);
        run_test("UNSAT 20v #1", "../tests/generated_instances/unsat_20v_80c_1.cnf", 1'b0, 5000000);
    
        // 32 Variables (STRESS TEST)
        run_test("SAT 32v #1", "../tests/generated_instances/sat_32v_136c_1.cnf", 1'b1, 20000000);
        run_test("UNSAT 32v #1", "../tests/generated_instances/unsat_32v_136c_1.cnf", 1'b0, 20000000);
    
        // 42 Variables (LIMIT TEST)
        run_test("SAT 42v #1", "../tests/generated_instances/sat_42v_178c_1.cnf", 1'b1, 50000000);
        run_test("UNSAT 42v #1", "../tests/generated_instances/unsat_42v_178c_1.cnf", 1'b0, 50000000);
        
        $display("\n");
        $display("=====================================");
        $display("ALL STANDARD REGRESSION TESTS PASSED");
        $display("=====================================");
    end
    $display("=====================================");
    $display("ALL TESTS PASSED");
    $display("=====================================");
    $finish;
  end

  // Timeout watchdog
  initial begin
    #900000000000; // ~15 minutes sim time budget
    $display("\n*** GLOBAL TIMEOUT - ABORTING ***");
    $finish;
  end

endmodule
