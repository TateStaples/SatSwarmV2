`timescale 1ns/1ps
module tb_satswarmv2;
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

  // Parameters for testing - increased for sat_75v_325c benchmark
  parameter int GRID_X = 1;
  parameter int GRID_Y = 1;
  parameter int MAX_VARS_PER_CORE = 256;
  parameter int MAX_CLAUSES_PER_CORE = 4096;  // Large to allow significant learned clause accumulation
  parameter int MAX_LITS = 65536;  // Large literal pool

  // DUT - SatSwarm Top Level
  satswarm_top #(
    .GRID_X(GRID_X),
    .GRID_Y(GRID_Y),
    .MAX_VARS_PER_CORE(MAX_VARS_PER_CORE),
    .MAX_CLAUSES_PER_CORE(MAX_CLAUSES_PER_CORE),
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
  int debug_level = 0;  // 0=heartbeat+final, 1=architectural, 2=full microarch
  longint unsigned max_cycles_cfg = 5000000;  // default timeout cycles

  task push_literal(input int lit, input bit clause_end);
    begin
      if (debug_level >= 2) $display("[%0t] Pushing literal %0d (clause_end=%0d)", $time, lit, clause_end);
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
      if (debug_level >= 1) $display("[%0t] Loading CNF file: %s", $time, filename);
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
              if (debug_level >= 1) $display("  Problem: %0d variables, %0d clauses", num_vars, num_clauses);
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
      if (debug_level >= 1) $display("  Loaded %0d clauses", clause_count);
    end
  endtask

  // Model Verification Task (checks if the solver's internal state actually satisfies the CNF)
  task verify_model();
    int unsat_clauses = 0;
    logic [1:0] state;
    bit clause_sat;
    int winning_core_x = -1;
    int winning_core_y = -1;
    
    // Note: outer loop is y (cols label?), inner is x (rows label?).
    // Wait, satswarm_top: y is outer (labeled cols?), x is inner (labeled rows?).
    // Let's match the labels I just added: y->cols, x->rows.
    // So distinct path is dut.cols[y].rows[x].
    if (dut.cols[0].rows[0].u_core.is_sat) begin winning_core_x=0; winning_core_y=0; end
`ifdef MULTICORE
    if (GRID_X >= 2) begin
      if (dut.cols[0].rows[1].u_core.is_sat) begin winning_core_x=1; winning_core_y=0; end
    end
    if (GRID_Y >= 2) begin
      if (dut.cols[1].rows[0].u_core.is_sat) begin winning_core_x=0; winning_core_y=1; end
    end
    if (GRID_X >= 2 && GRID_Y >= 2) begin
      if (dut.cols[1].rows[1].u_core.is_sat) begin winning_core_x=1; winning_core_y=1; end
    end
`endif

    if (winning_core_x == -1) begin
        $display("  Error: host_sat is true but no core reports is_sat?");
        return;
    end


    if (debug_level >= 2) $display("  Verifying model from Core [%0d,%0d]...", winning_core_x, winning_core_y);

    foreach (clause_store[c]) begin
        clause_sat = 0;
        foreach (clause_store[c][l]) begin
            int lit = clause_store[c][l];
            int var_idx = (lit < 0) ? -lit : lit;
            
            // Read model from CORE TRAIL (source of truth)
            // CRITICAL: Only iterate up to actual trail_height to avoid reading uninitialized entries
            state = 2'b00; // default unassigned
            begin
                automatic int trail_h;
                automatic logic [31:0] tv;
                automatic logic val;
                
                // Get trail height for winning core
                if (winning_core_x == 0 && winning_core_y == 0) trail_h = dut.cols[0].rows[0].u_core.u_trail.trail_height_q;
`ifdef MULTICORE
                if (GRID_X >= 2) begin
                  if (winning_core_x == 1 && winning_core_y == 0) trail_h = dut.cols[0].rows[1].u_core.u_trail.trail_height_q;
                end
                if (GRID_Y >= 2) begin
                  if (winning_core_x == 0 && winning_core_y == 1) trail_h = dut.cols[1].rows[0].u_core.u_trail.trail_height_q;
                end
                if (GRID_X >= 2 && GRID_Y >= 2) begin
                  if (winning_core_x == 1 && winning_core_y == 1) trail_h = dut.cols[1].rows[1].u_core.u_trail.trail_height_q;
                end
`endif
                
                for (int i=0; i < trail_h && i < MAX_VARS_PER_CORE; i++) begin
                    if (winning_core_x == 0 && winning_core_y == 0) begin tv = dut.cols[0].rows[0].u_core.u_trail.trail[i].variable; val = dut.cols[0].rows[0].u_core.u_trail.trail[i].value; end
`ifdef MULTICORE
                    if (GRID_X >= 2) begin
                      if (winning_core_x == 1 && winning_core_y == 0) begin tv = dut.cols[0].rows[1].u_core.u_trail.trail[i].variable; val = dut.cols[0].rows[1].u_core.u_trail.trail[i].value; end
                    end
                    if (GRID_Y >= 2) begin
                      if (winning_core_x == 0 && winning_core_y == 1) begin tv = dut.cols[1].rows[0].u_core.u_trail.trail[i].variable; val = dut.cols[1].rows[0].u_core.u_trail.trail[i].value; end
                    end
                    if (GRID_X >= 2 && GRID_Y >= 2) begin
                      if (winning_core_x == 1 && winning_core_y == 1) begin tv = dut.cols[1].rows[1].u_core.u_trail.trail[i].variable; val = dut.cols[1].rows[1].u_core.u_trail.trail[i].value; end
                    end
`endif
                    
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
            if (debug_level >= 2 && unsat_clauses <= 5) $display("    Failed Clause %0d (No literals satisfied)", c);
        end
    end

    if (debug_level >= 2) begin
      if (unsat_clauses == 0) 
          $display("  MODEL VERIFIED: Valid functionality.");
      else 
          $display("  MODEL INVALID: %0d clauses not satisfied. SOUNDNESS BUG!", unsat_clauses);
    end

  endtask

  task run_test(input string name, input string cnf_file, input bit expected_sat);
    begin
      test_name = name;
      if (debug_level >= 1) begin
        $display("\n========================================");
        $display("TEST: %s", name);
        $display("========================================");
      end

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
      if (debug_level >= 1) $display("Starting solve at time %0t", $time);
      @(posedge clk);
      host_start <= 1'b1;
      @(posedge clk);
      host_start <= 1'b0;
      if (debug_level >= 1) $display("Started solve, now waiting for completion...");

      // Wait for completion
      cycle_count = 0;
      while (!host_done && cycle_count < max_cycles_cfg) begin
        @(posedge clk);
        cycle_count++;
        // Heartbeat: print periodically for DEBUG_LEVEL 0, detailed for levels 1-2
        if (debug_level == 0) begin
          if (cycle_count % 10000 == 0) begin
             // Access internal signal total_conflicts from Core 0 (assuming single core or interest in Core 0)
             $display("[Heartbeat] Cycle %0d | Conflicts: %0d", cycle_count, dut.cols[0].rows[0].u_core.total_conflicts);
          end
        end else if (debug_level >= 1) begin
          if (cycle_count == 1 || cycle_count == 2 || cycle_count == 3 || cycle_count % 100 == 0) begin
            $display("[Cycle %0d] done=%0d sat=%0d unsat=%0d state=%0d dlvl=%0d height=%0d pse_state=%0d pse_done=%0d pse_conflict=%0d", 
                     cycle_count, host_done, host_sat, host_unsat,
                     dut.cols[0].rows[0].u_core.state_q,
                     dut.cols[0].rows[0].u_core.decision_level_q,
                     dut.cols[0].rows[0].u_core.trail_height,
                     dut.cols[0].rows[0].u_core.u_pse.state_q,
                     dut.cols[0].rows[0].u_core.u_pse.done,
                     dut.cols[0].rows[0].u_core.u_pse.conflict_detected);
          end
        end
      end
      end_time = $realtime;
      if (debug_level >= 1) $display("[Final Cycle %0d] done=%0d sat=%0d unsat=%0d - TEST STOPPING", cycle_count, host_done, host_sat, host_unsat);

      // Report results
      if (host_done) begin
        real time_ms;
        real freq_mhz;
        real time_actual_ms;
        time_ms = (end_time - start_time) / 1000000.0;
        freq_mhz = 100.0; // 100 MHz clock
        time_actual_ms = cycle_count / (freq_mhz * 1000.0);
        
        // DEBUG_LEVEL 0: Minimal output
        if (debug_level == 0) begin
          $display("\n=== RESULTS ===");
          $display("  Result: %s", host_sat ? "SAT" : "UNSAT");
          $display("  Cycles: %0d", cycle_count);
        end else begin
          // DEBUG_LEVEL 1 & 2: Full results
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
        end
        
        if (host_sat && debug_level >= 2) begin
            verify_model();
        end

        if (debug_level >= 1) begin
          if (host_sat && !expected_sat) begin
             $display("  Note: Solver reported SAT, test expects UNSAT. Checking model validity above...");
          end
        end
        
        if (host_sat != expected_sat) begin
          $fatal(1, "\n*** TEST FAILED ***\n");
        end else begin
          $display("\n*** TEST PASSED ***\n");
        end
      end else begin
        $display("\n=== TIMEOUT ===");
        $display("  Exceeded %0d cycles", max_cycles_cfg);
        $display("  Status at timeout: done=%0d sat=%0d", host_done, host_sat);
        $fatal(1, "\n*** TEST FAILED ***\n");
      end
    end
  endtask

  initial begin
    string cnf_arg;
    string expected_str;
    bit has_cnf;
    bit expected_sat_arg;

    // Read DEBUG from plusargs (default 0)
    if (!$value$plusargs("DEBUG=%d", debug_level)) debug_level = 0;
    $display("[TB] RUNTIME DEBUG LEVEL: %0d", debug_level);
    
    // Read MAXCYCLES from plusargs (default 5,000,000)
    if (!$value$plusargs("MAXCYCLES=%d", max_cycles_cfg)) max_cycles_cfg = 5000000;

    if (debug_level != 0) begin
      $display("\n");
      $display("=====================================");
      $display("VeriSAT Testbench & Benchmark Suite");
      $display("=====================================");
      $display("Clock: 100 MHz (10ns period)");
      $display("Grid: %0dx%0d", GRID_X, GRID_Y);
      $display("Max Vars/Core: %0d", MAX_VARS_PER_CORE);
      $display("Max Clauses/Core: %0d", MAX_CLAUSES_PER_CORE);
      $display("\n");
    end

    has_cnf = $value$plusargs("CNF=%s", cnf_arg);
    if (has_cnf) begin
      if (!$value$plusargs("EXPECT=%s", expected_str)) expected_str = "SAT";
      expected_sat_arg = (expected_str == "SAT");
      run_test("PlusArgs", cnf_arg, expected_sat_arg);
    end else begin
      // === REGRESSION SUITE: Progressively Larger Problems ===

      run_test("SAT 5v #1", "../tests/generated_instances/sat_5v_10c_1.cnf", 1'b1);
      run_test("UNSAT 5v #1", "../tests/generated_instances/unsat_5v_10c_1.cnf", 1'b0);

      run_test("SAT 8v #1", "../tests/generated_instances/sat_8v_20c_1.cnf", 1'b1);
      run_test("UNSAT 8v #1", "../tests/generated_instances/unsat_8v_20c_1.cnf", 1'b0);

      run_test("SAT 10v #1", "../tests/generated_instances/sat_10v_30c_1.cnf", 1'b1);
      run_test("UNSAT 10v #1", "../tests/generated_instances/unsat_10v_30c_1.cnf", 1'b0);

      run_test("SAT 12v #1", "../tests/generated_instances/sat_12v_40c_1.cnf", 1'b1);
      run_test("UNSAT 12v #1", "../tests/generated_instances/unsat_12v_40c_1.cnf", 1'b0);

      run_test("SAT 15v #1", "../tests/generated_instances/sat_15v_50c_1.cnf", 1'b1);
      run_test("UNSAT 15v #1", "../tests/generated_instances/unsat_15v_50c_1.cnf", 1'b0);

      run_test("SAT 18v #1", "../tests/generated_instances/sat_18v_70c_1.cnf", 1'b1);
      run_test("UNSAT 18v #1", "../tests/generated_instances/unsat_18v_70c_1.cnf", 1'b0);

      run_test("SAT 20v #1", "../tests/generated_instances/sat_20v_80c_1.cnf", 1'b1);
      run_test("UNSAT 20v #1", "../tests/generated_instances/unsat_20v_80c_1.cnf", 1'b0);
    end

    if (debug_level >= 1) begin
      $display("\n");
      $display("=====================================");
      $display("ALL TESTS PASSED");
      $display("=====================================");
    end
    $finish;
  end

  // Timeout watchdog
  initial begin
    #900000000000; // ~15 minutes sim time budget
    $display("\n*** GLOBAL TIMEOUT - ABORTING ***");
    $finish;
  end
  // Debug output removed for faster simulation

endmodule
