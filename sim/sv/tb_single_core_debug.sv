`timescale 1ns/1ps

// Single-core testbench with debug instrumentation
// Purpose: Isolate solver_core behavior without multicore mesh interference
module tb_single_core_debug;
  
  // Clock and reset
  logic clk;
  logic rst_n;
  
  // Solver core interface
  logic        start_solve;
  logic        solve_done;
  logic        is_sat;
  logic        is_unsat;
  
  // Load interface
  logic        load_valid;
  logic signed [31:0] load_literal;
  logic        load_clause_end;
  logic        load_ready;
  
  // NoC Interface (tied off for single core)
  satswarmv2_pkg::noc_packet_t rx_pkt [3:0];
  logic rx_valid [3:0];
  logic rx_ready [3:0];
  satswarmv2_pkg::noc_packet_t tx_pkt [3:0];
  logic tx_valid [3:0];
  logic tx_ready [3:0];
  
  // Global memory interface (simplified)
  logic        global_read_req;
  logic [31:0] global_read_addr;
  logic [7:0]  global_read_len;
  logic        global_read_grant;
  logic [31:0] global_read_data;
  logic        global_read_valid;
  logic        global_write_req;
  logic [31:0] global_write_addr;
  logic [31:0] global_write_data;
  logic        global_write_grant;
  
  // Parameters
  parameter int MAX_VARS = 128;
  parameter int MAX_CLAUSES = 256;
  parameter int MAX_LITS = 1024;
  
  // Test tracking
  int cycle_count;
  int clause_count;
  int var_count;
  int load_cycle_end;
  int pse_start_cycle;
  
  // Instantiate single solver core
  solver_core #(
    .CORE_ID(0),
    .MAX_VARS(MAX_VARS),
    .MAX_CLAUSES(MAX_CLAUSES),
    .MAX_LITS(MAX_LITS),
    .GRID_X(1),
    .GRID_Y(1)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .start_solve(start_solve),
    .solve_done(solve_done),
    .is_sat(is_sat),
    .is_unsat(is_unsat),
    .load_valid(load_valid),
    .load_literal(load_literal),
    .load_clause_end(load_clause_end),
    .load_ready(load_ready),
    .rx_pkt(rx_pkt),
    .rx_valid(rx_valid),
    .rx_ready(rx_ready),
    .tx_pkt(tx_pkt),
    .tx_valid(tx_valid),
    .tx_ready(tx_ready),
    .global_read_req(global_read_req),
    .global_read_addr(global_read_addr),
    .global_read_len(global_read_len),
    .global_read_grant(global_read_grant),
    .global_read_data(global_read_data),
    .global_read_valid(global_read_valid),
    .global_write_req(global_write_req),
    .global_write_addr(global_write_addr),
    .global_write_data(global_write_data),
    .global_write_grant(global_write_grant)
  );
  
  // Tie off NoC interface
  always_comb begin
    for (int i = 0; i < 4; i++) begin
      rx_pkt[i] = '0;
      rx_valid[i] = 1'b0;
      tx_ready[i] = 1'b1;
    end
  end
  
  // Simple memory model (grants immediately, returns dummy data)
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      global_read_grant <= 1'b0;
      global_read_valid <= 1'b0;
      global_read_data <= 32'h0;
      global_write_grant <= 1'b0;
    end else begin
      global_read_grant <= global_read_req;
      global_read_valid <= global_read_grant;
      global_read_data <= 32'hDEADBEEF;  // Dummy data
      global_write_grant <= global_write_req;
    end
  end
  
  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 100 MHz (10ns period)
  end
  
  // Cycle counter
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      cycle_count <= 0;
    else
      cycle_count <= cycle_count + 1;
  end
  
  // ============================================================================
  // DEBUG INSTRUMENTATION
  // ============================================================================
  
  // Local enum to match solver_core states
  typedef enum logic [4:0] {
    IDLE              = 5'd0,
    PROPAGATE         = 5'd1,
    ACCUMULATE_PROPS  = 5'd2,
    CONFLICT_ANALYSIS = 5'd3,
    BACKTRACK_PHASE   = 5'd4,
    BACKTRACK_UNDO    = 5'd5,
    SAT_CHECK         = 5'd6,
    FINISH_SAT        = 5'd7,
    FINISH_UNSAT      = 5'd8
  } core_state_t;
  
  // Track state changes
  logic [4:0] prev_state;
  always_ff @(posedge clk) begin
    if (dut.state_q != prev_state) begin
      $display("[Cycle %0d] STATE: %s -> %s", 
        cycle_count, 
        get_state_name(prev_state),
        get_state_name(dut.state_q));
      prev_state <= dut.state_q;
    end
  end
  
  // Track UNSAT triggers
  always_ff @(posedge clk) begin
    if (dut.state_q == BACKTRACK_PHASE && dut.cae_done) begin
      if (dut.cae_learned_len == 4'h0) begin
        $display("[Cycle %0d] *** UNSAT TRIGGER: Empty learned clause (cae_learned_len=0)", cycle_count);
      end else if (dut.cae_backtrack_level == 8'h00 || dut.decision_level_q == 0) begin
        $display("[Cycle %0d] Level-0 conflict detected (count=%0d/5000, backtrack_level=%0d, decision_level=%0d)",
          cycle_count, dut.level0_conflict_count_q, dut.cae_backtrack_level, dut.decision_level_q);
        if (dut.level0_conflict_count_q >= 16'd5000) begin
          $display("[Cycle %0d] *** UNSAT TRIGGER: Level-0 conflict threshold exceeded", cycle_count);
        end
      end
    end
  end
  
  // Track assignments
  always_ff @(posedge clk) begin
    if (dut.vde_assign_valid) begin
      $display("[Cycle %0d] ASSIGN: var=%0d value=%0d (decision_level=%0d)", 
        cycle_count, dut.vde_assign_var, dut.vde_assign_value, dut.decision_level_q);
    end
  end
  
  // Track decisions
  always_ff @(posedge clk) begin
    if (dut.vde_decision_valid) begin
      $display("[Cycle %0d] DECISION: var=%0d phase=%0d", 
        cycle_count, dut.vde_decision_var, dut.vde_decision_phase);
    end
    if (dut.vde_all_assigned) begin
      $display("[Cycle %0d] VDE: All variables assigned", cycle_count);
    end
  end
  
  // Track backtracking
  always_ff @(posedge clk) begin
    if (dut.trail_backtrack_en) begin
      $display("[Cycle %0d] BACKTRACK: to level %0d", cycle_count, dut.trail_backtrack_level);
    end
    if (dut.trail_backtrack_valid) begin
      $display("[Cycle %0d] BACKTRACK_UNDO: var=%0d value=%0d is_decision=%0d", 
        cycle_count, dut.trail_backtrack_var, dut.trail_backtrack_value, dut.trail_backtrack_is_decision);
    end
  end
  
  // Track PSE activity
  logic prev_pse_start;
  always_ff @(posedge clk) begin
    if (dut.pse_start && !prev_pse_start) begin
      $display("[Cycle %0d] PSE: Starting propagation", cycle_count);
      if (pse_start_cycle == 0) pse_start_cycle = cycle_count;
    end
    if (dut.pse_done && dut.pse_conflict) begin
      $display("[Cycle %0d] PSE: Conflict detected", cycle_count);
    end else if (dut.pse_done && !dut.pse_conflict) begin
      $display("[Cycle %0d] PSE: Propagation complete (no conflict)", cycle_count);
    end
    prev_pse_start <= dut.pse_start;
  end
  
  // Track CAE activity
  logic prev_cae_start;
  always_ff @(posedge clk) begin
    if (dut.cae_start && !prev_cae_start) begin
      $display("[Cycle %0d] CAE: Starting conflict analysis", cycle_count);
    end
    if (dut.cae_done) begin
      $display("[Cycle %0d] CAE: Analysis complete (len=%0d, backtrack_level=%0d, unsat=%0d)", 
        cycle_count, dut.cae_learned_len, dut.cae_backtrack_level, dut.cae_unsat);
    end
    prev_cae_start <= dut.cae_start;
  end
  
  // Track clause learning (if CAE produces learned clause)
  always_ff @(posedge clk) begin
    if (dut.cae_done && dut.cae_learned_len > 0) begin
      $display("[Cycle %0d] LEARNED_CLAUSE: CAE produced clause (len=%0d)", cycle_count, dut.cae_learned_len);
    end
  end
  
  // ============================================================================
  // CNF LOADING TASK
  // ============================================================================
  
  task automatic load_cnf_file(input string filename);
    int fd;
    string line;
    int lit;
    int scan_result;
    int num_vars, num_clauses;
    int literals[$];
    begin
      $display("\n========================================");
      $display("[Cycle %0d] Loading CNF: %s", cycle_count, filename);
      $display("========================================");
      
      fd = $fopen(filename, "r");
      if (fd == 0) begin
        $display("ERROR: Cannot open file %s", filename);
        $finish;
      end

      clause_count = 0;
      var_count = 0;

      while (!$feof(fd)) begin
        if ($fgets(line, fd)) begin
          // Skip comments
          if (line[0] == "c") continue;
          
          // Skip SATLIB terminator
          if (line[0] == "%") continue;

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
      load_cycle_end = cycle_count;
      $display("  Loaded %0d clauses at cycle %0d", clause_count, load_cycle_end);
      $display("========================================\n");
    end
  endtask
  
  task automatic push_literal(input int lit, input bit is_last);
    begin
      @(posedge clk);
      while (!load_ready) @(posedge clk);
      load_valid <= 1'b1;
      load_literal <= lit;
      load_clause_end <= is_last;
      @(posedge clk);
      load_valid <= 1'b0;
      load_clause_end <= 1'b0;
    end
  endtask
  
  // ============================================================================
  // TEST RUNNER
  // ============================================================================
  
  task automatic run_test(input string name, input string cnf_file, input bit expected_sat, input int max_cycles);
    int test_start_cycle;
    begin
      $display("\n");
      $display("========================================");
      $display("TEST: %s", name);
      $display("CNF: %s", cnf_file);
      $display("Expected: %s", expected_sat ? "SAT" : "UNSAT");
      $display("========================================");
      
      // Reset
      rst_n = 1'b0;
      start_solve = 1'b0;
      load_valid = 1'b0;
      load_literal = 32'h0;
      load_clause_end = 1'b0;
      load_cycle_end = 0;
      pse_start_cycle = 0;
      prev_state = 5'h1F;  // Invalid state
      
      repeat(10) @(posedge clk);
      rst_n = 1'b1;
      repeat(5) @(posedge clk);
      
      // Load CNF
      load_cnf_file(cnf_file);
      
      // Start solve
      test_start_cycle = cycle_count;
      $display("[Cycle %0d] Starting solve...", cycle_count);
      $display("CNF Load completed at cycle %0d", load_cycle_end);
      if (pse_start_cycle > 0) begin
        $display("PSE first started at cycle %0d (delta = %0d cycles after load)", 
          pse_start_cycle, pse_start_cycle - load_cycle_end);
      end
      
      @(posedge clk);
      start_solve = 1'b1;
      @(posedge clk);
      start_solve = 1'b0;
      
      // Wait for completion
      while (!solve_done && cycle_count < test_start_cycle + max_cycles) begin
        @(posedge clk);
        if (cycle_count % 100 == 0) begin
          $display("[Cycle %0d] Solving... (state=%s)", cycle_count, get_state_name(dut.state_q));
        end
      end
      
      // Check results
      $display("\n========================================");
      $display("RESULT:");
      $display("========================================");
      $display("Cycle: %0d", cycle_count);
      $display("Solve time: %0d cycles", cycle_count - test_start_cycle);
      $display("Done: %0d", solve_done);
      $display("SAT: %0d", is_sat);
      $display("UNSAT: %0d", is_unsat);
      $display("Expected SAT: %0d", expected_sat);
      
      if (!solve_done) begin
        $display("TIMEOUT after %0d cycles", max_cycles);
        $display("Final state: %s", get_state_name(dut.state_q));
      end else if ((is_sat && expected_sat) || (is_unsat && !expected_sat)) begin
        $display("PASS");
      end else begin
        $display("FAIL - Result mismatch!");
      end
      
      $display("========================================\n");
    end
  endtask
  
  // State name helper
  function string get_state_name(logic [4:0] state);
    case (state)
      5'd0: return "IDLE";
      5'd1: return "PROPAGATE";
      5'd2: return "ACCUMULATE_PROPS";
      5'd3: return "CONFLICT_ANALYSIS";
      5'd4: return "BACKTRACK_PHASE";
      5'd5: return "BACKTRACK_UNDO";
      5'd6: return "SAT_CHECK";
      5'd7: return "FINISH_SAT";
      5'd8: return "FINISH_UNSAT";
      default: return $sformatf("UNKNOWN(%0d)", state);
    endcase
  endfunction
  
  // ============================================================================
  // MAIN TEST
  // ============================================================================
  
  initial begin
    // Run uf20-08 test
    run_test(
      .name("uf20-08"),
      .cnf_file("../tests/satlib/sat/uf20-08.cnf"),
      .expected_sat(1'b1),
      .max_cycles(10000)
    );
    
    $display("\nSimulation complete");
    $finish;
  end
  
endmodule
