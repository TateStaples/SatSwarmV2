`timescale 1ns/1ps
module tb_unsat_tests;
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

  // Parameters for testing
  parameter int GRID_X = 1;
  parameter int GRID_Y = 1;
  parameter int MAX_VARS_PER_CORE = 128;
  parameter int MAX_CLAUSES_PER_CORE = 128;
  parameter int MAX_LITS = 512;

  // DUT - SatSwarm Top Level
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

  // Performance counters
  int cycle_count;
  int clause_count;
  int var_count;
  string test_name;

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
    begin
      $display("Loading: %s", filename);
      fd = $fopen(filename, "r");
      if (fd == 0) begin
        $display("ERROR: Cannot open file %s", filename);
        $finish;
      end

      clause_count = 0;
      var_count = 0;

      while (!$feof(fd)) begin
        if ($fgets(line, fd)) begin
          if (line[0] == "c") continue;
          if (line[0] == "p") begin
            scan_result = $sscanf(line, "p cnf %d %d", num_vars, num_clauses);
            if (scan_result == 2) begin
              var_count = num_vars;
              $display("  %0d variables, %0d clauses", num_vars, num_clauses);
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

  task run_test(input string name, input string cnf_file, input bit expected_sat, input int max_cycles);
    begin
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

      load_cnf_file(cnf_file);

      $display("Starting solve...");
      @(posedge clk);
      host_start <= 1'b1;
      @(posedge clk);
      host_start <= 1'b0;

      cycle_count = 0;
      while (!host_done && cycle_count < max_cycles) begin
        @(posedge clk);
        cycle_count++;
        if (cycle_count % 5000 == 0) begin
          $display("[Cycle %0d] done=%0d sat=%0d unsat=%0d", cycle_count, host_done, host_sat, host_unsat);
        end
      end

      if (host_done) begin
        $display("\n=== RESULTS ===");
        $display("  Status: %s", host_sat ? "SAT" : "UNSAT");
        $display("  Expected: %s", expected_sat ? "SAT" : "UNSAT");
        $display("  Result: %s", (host_sat == expected_sat) ? "PASS" : "FAIL");
        $display("  Cycles: %0d", cycle_count);
        $display("  Cycles/Clause: %.1f", real'(cycle_count) / real'(clause_count));
      end else begin
        $display("\n=== TIMEOUT ===");
        $display("  Exceeded %0d cycles", max_cycles);
        $display("  Result: TIMEOUT");
      end
    end
  endtask

  initial begin
    $display("\n========================================");
    $display("SATLIB UNSAT Benchmark Tests");
    $display("========================================\n");

    // Test uuf50 instances (50 variables)
    run_test("uuf50-01", "../tests/satlib/unsat/uuf50-01.cnf", 1'b0, 50000);
    run_test("uuf50-02", "../tests/satlib/unsat/uuf50-02.cnf", 1'b0, 50000);
    run_test("uuf50-03", "../tests/satlib/unsat/uuf50-03.cnf", 1'b0, 50000);
    run_test("uuf50-04", "../tests/satlib/unsat/uuf50-04.cnf", 1'b0, 50000);
    run_test("uuf50-05", "../tests/satlib/unsat/uuf50-05.cnf", 1'b0, 50000);
    run_test("uuf50-06", "../tests/satlib/unsat/uuf50-06.cnf", 1'b0, 50000);
    run_test("uuf50-07", "../tests/satlib/unsat/uuf50-07.cnf", 1'b0, 50000);
    run_test("uuf50-08", "../tests/satlib/unsat/uuf50-08.cnf", 1'b0, 50000);
    run_test("uuf50-09", "../tests/satlib/unsat/uuf50-09.cnf", 1'b0, 50000);
    run_test("uuf50-010", "../tests/satlib/unsat/uuf50-010.cnf", 1'b0, 50000);

    $display("\n========================================");
    $display("Tests Complete");
    $display("========================================");
    $finish;
  end

  // Timeout watchdog
  initial begin
    #2000000000; // 2 seconds sim time
    $display("\n*** GLOBAL TIMEOUT - ABORTING ***");
    $finish;
  end

endmodule
