`timescale 1ns/1ps
// True Single-Core Testbench (GRID_X=1, GRID_Y=1)
// Purpose: Validate solver correctness with single core only, no multi-core mesh
module tb_single_core_only;
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

  // Parameters - SINGLE CORE ONLY (matching tb_satswarmv2 2x2)
  parameter int GRID_X = 1;
  parameter int GRID_Y = 1;
  parameter int MAX_VARS_PER_CORE = 42;
  parameter int MAX_CLAUSES_PER_CORE = 104;
  parameter int MAX_LITS = 416;

  // DUT - SatSwarm Top Level (1x1 grid = single core)
  satswarm_top #(
    .GRID_X(GRID_X),
    .GRID_Y(GRID_Y),
    .MAX_VARS_PER_CORE(MAX_VARS_PER_CORE),
    .MAX_CLAUSES_PER_CORE(MAX_CLAUSES_PER_CORE),
    .MAX_LITS(MAX_LITS)
  ) dut (
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

  // Performance counters and clause storage for verification
  longint unsigned cycle_count;
  int clause_count;
  int var_count;
  string test_name;
  real start_time;
  real end_time;
  int clause_store[$][];
  int passed_tests = 0;
  int failed_tests = 0;

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

  // Model Verification - SINGLE CORE ONLY (uses cols[0].rows[0])
  task verify_model(output bit valid);
    int unsat_clauses = 0;
    logic [1:0] state;
    bit clause_sat;
    automatic int trail_h;
    automatic logic [31:0] tv;
    automatic logic val;

    $display("  Verifying model from single core...");
    
    // Get trail height from the single core (cols[0].rows[0])
    trail_h = dut.cols[0].rows[0].u_core.u_trail.trail_height_q;
    // $display("  Trail Height: %0d", trail_h);
    
    // DEBUG: Print all trail entries - COMMENTED OUT FOR REGRESSION
    /*
    $display("  Trail Contents:");
    for (int i=0; i < trail_h && i < MAX_VARS_PER_CORE && i < 20; i++) begin
      tv = dut.cols[0].rows[0].u_core.u_trail.trail[i].variable;
      val = dut.cols[0].rows[0].u_core.u_trail.trail[i].value;
      $display("    trail[%0d]: var=%0d val=%0d", i, tv, val);
    end
    */
    
    foreach (clause_store[c]) begin
      clause_sat = 0;
      foreach (clause_store[c][l]) begin
        int lit = clause_store[c][l];
        int var_idx = (lit < 0) ? -lit : lit;
        
        state = 2'b00; // default unassigned
        for (int i=0; i < trail_h && i < MAX_VARS_PER_CORE; i++) begin
          tv = dut.cols[0].rows[0].u_core.u_trail.trail[i].variable;
          val = dut.cols[0].rows[0].u_core.u_trail.trail[i].value;
          if (tv == var_idx) begin
            state = val ? 2'b10 : 2'b01;
            break;
          end
        end

        if (lit > 0 && state == 2'b10) clause_sat = 1;
        if (lit < 0 && state == 2'b01) clause_sat = 1;
      end
      if (!clause_sat) begin
        unsat_clauses++;
        if (unsat_clauses <= 5) begin
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
      $display("  MODEL INVALID: %0d clauses not satisfied. SOUNDNESS BUG!", unsat_clauses);
      valid = 1'b0;
    end
  endtask

  task run_test(input string name, input string cnf_file, input bit expected_sat, input longint unsigned max_cycles);
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
      load_cnf_file(cnf_file);

      $display("Starting solve at time %0t", $time);
      @(posedge clk);
      host_start <= 1'b1;
      @(posedge clk);
      host_start <= 1'b0;

      cycle_count = 0;
      while (!host_done && cycle_count < max_cycles) begin
        @(posedge clk);
        cycle_count++;
        if (cycle_count % 50000 == 0) begin
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
        $display("  Expected: %s", expected_sat ? "SAT" : "UNSAT");
        $display("  Cycles: %0d", cycle_count);
        $display("  Sim Time: %.3f ms", time_ms);
        
        if (host_sat) begin
          verify_model(model_valid);
        end

        if ((host_sat == expected_sat) && model_valid) begin
          $display("\n*** TEST PASSED ***\n");
          passed_tests++;
        end else begin
          $display("\n*** TEST FAILED ***\n");
          failed_tests++;
        end
      end else begin
        $display("\n=== TIMEOUT ===");
        $display("  Exceeded %0d cycles", max_cycles);
        $display("\n*** TEST FAILED ***\n");
        failed_tests++;
      end
    end
  endtask

  initial begin
    $display("\n");
    $display("=====================================");
    $display("VeriSAT SINGLE CORE Regression Suite");
    $display("=====================================");
    $display("Clock: 100 MHz (10ns period)");
    $display("Grid: %0dx%0d (SINGLE CORE)", GRID_X, GRID_Y);
    $display("Max Vars/Core: %0d", MAX_VARS_PER_CORE);
    $display("Max Clauses/Core: %0d", MAX_CLAUSES_PER_CORE);
    $display("\n");

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

    $display("\n");
    $display("=====================================");
    $display("SINGLE CORE REGRESSION SUMMARY");
    $display("=====================================");
    $display("PASSED: %0d", passed_tests);
    $display("FAILED: %0d", failed_tests);
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
