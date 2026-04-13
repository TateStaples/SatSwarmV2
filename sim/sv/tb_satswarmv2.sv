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

  // Clause sharing mode (overridable via Verilator -G)
  parameter int CLAUSE_SHARING_MODE = 0;
  // Restart threshold (overridable; 0 = disabled)
  parameter int RESTART_CONFLICT_THRESHOLD = 64;

  // DUT - SatSwarm Top Level
  satswarm_top #(
    .GRID_X(GRID_X),
    .GRID_Y(GRID_Y),
    .MAX_VARS_PER_CORE(MAX_VARS_PER_CORE),
    .MAX_CLAUSES_PER_CORE(MAX_CLAUSES_PER_CORE),
    .MAX_LITS(MAX_LITS),
    .CLAUSE_SHARING_MODE(CLAUSE_SHARING_MODE),
    .RESTART_CONFLICT_THRESHOLD(RESTART_CONFLICT_THRESHOLD)
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
  int flat_clause_store[MAX_LITS];
  int clause_starts[MAX_CLAUSES_PER_CORE * 4];
  int clause_lengths[MAX_CLAUSES_PER_CORE * 4];
  int _clause_store_idx = 0;
  int _clause_count_idx = 0;
  int debug_level = 0;  // 0=heartbeat+final, 1=architectural, 2=full microarch
  longint unsigned max_cycles_cfg = 5000000;  // default timeout cycles

  // ── Debug tracking variables for buffer/capacity analysis ──
  int dbg_prev_state;
  int dbg_max_clause_watermark;
  int dbg_max_lit_watermark;
  int dbg_max_trail_watermark;
  int dbg_max_dlvl_watermark;
  int dbg_total_clause_drops;
  int dbg_prev_conflict_count;

  // ── Learned clause validation against known solution ──
  bit solution_loaded = 0;
  bit solution_values [0:511];  // solution_values[var] = 1 if var is true
  int dbg_invalid_learned_count = 0;
  int dbg_valid_learned_count = 0;
  int dbg_prev_cae_state = 0;
  int dbg_prev_lit_count = 0;
  bit dbg_lit_overflow_detected = 0;

  task automatic push_literal(input int lit, input bit clause_end);
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

  task automatic load_cnf_file(input string filename);
    int fd;
    string line;
    int lit;
    int scan_result;
    int num_vars, num_clauses;
    int literals[$];
    int clause_copy[$];
    begin
      if (debug_level >= 1) $display("[%0t] Loading CNF file: %s", $time, filename);
      fd = $fopen(filename, "r");
      if (fd == 0) begin
        $display("ERROR: Cannot open file %s", filename);
        $finish;
      end

      clause_count = 0;
      _clause_store_idx = 0; _clause_count_idx = 0;
      var_count = 0;
      _clause_store_idx = 0; _clause_count_idx = 0;

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
                  clause_starts[_clause_count_idx] = _clause_store_idx;
                  clause_lengths[_clause_count_idx] = literals.size();
                  for (int j = 0; j < literals.size(); j++) begin
                      flat_clause_store[_clause_store_idx] = literals[j];
                      _clause_store_idx++;
                  end
                  _clause_count_idx++;
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
  task automatic verify_model();
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

    for (int c = 0; c < _clause_count_idx; c++) begin
        int start_idx = clause_starts[c];
        int len = clause_lengths[c];
        clause_sat = 0;
        
            for (int l = 0; l < len; l++) begin
                int __idx = start_idx + l;
                int lit = flat_clause_store[__idx];
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

  task automatic run_test(input string name, input string cnf_file, input bit expected_sat);
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

      // Reset tracking variables
      dbg_prev_state = 0;
      dbg_max_clause_watermark = 0;
      dbg_max_lit_watermark = 0;
      dbg_max_trail_watermark = 0;
      dbg_max_dlvl_watermark = 0;
      dbg_total_clause_drops = 0;
      dbg_prev_conflict_count = 0;

      while (!host_done && cycle_count < max_cycles_cfg) begin
        @(posedge clk);
        cycle_count++;

        // ── EVENT: State transition to FINISH_UNSAT — full forensics ──
        if (dut.cols[0].rows[0].u_core.state_q == 12 && dbg_prev_state != 12) begin // FINISH_UNSAT = 12
          $display("[UNSAT-TRIGGER Cycle %0d] *** FINISH_UNSAT entered ***", cycle_count);
          $display("  came_from_state=%0d  decision_level=%0d  trail_height=%0d",
                   dbg_prev_state,
                   dut.cols[0].rows[0].u_core.decision_level_q,
                   dut.cols[0].rows[0].u_core.trail_height);
          $display("  cae_unsat=%0b  cae_learned_len=%0d  conflict_clause[0]=%0d  conflict_clause[1]=%0d",
                   dut.cols[0].rows[0].u_core.cae_unsat,
                   dut.cols[0].rows[0].u_core.cae_learned_len,
                   dut.cols[0].rows[0].u_core.conflict_clause_q[0],
                   dut.cols[0].rows[0].u_core.conflict_clause_q[1]);
          $display("  cae_backtrack_level=%0d  cae_buf_overflow=%0b  cae_dropped_lits=%0d",
                   dut.cols[0].rows[0].u_core.u_cae.backtrack_q,
                   dut.cols[0].rows[0].u_core.u_cae.buf_overflow_q,
                   dut.cols[0].rows[0].u_core.u_cae.dropped_lits_q);
          $display("  total_conflicts=%0d  total_restarts=%0d  total_learned=%0d  total_decisions=%0d",
                   dut.cols[0].rows[0].u_core.total_conflicts,
                   dut.cols[0].rows[0].u_core.total_restarts,
                   dut.cols[0].rows[0].u_core.total_learned,
                   dut.cols[0].rows[0].u_core.total_decisions);
          $display("  pse_clause_count=%0d/%0d  pse_lit_count=%0d/%0d",
                   dut.cols[0].rows[0].u_core.u_pse.clause_count_q, MAX_CLAUSES_PER_CORE,
                   dut.cols[0].rows[0].u_core.u_pse.lit_count_q, MAX_LITS);
          $display("  prop_fifo_count=%0d  prop_fifo_full=%0b",
                   dut.cols[0].rows[0].u_core.prop_fifo_count,
                   dut.cols[0].rows[0].u_core.prop_fifo_full);
          // Determine which UNSAT condition fired
          if (dbg_prev_state == 7) begin // BACKTRACK_PHASE = 7
            if (dut.cols[0].rows[0].u_core.cae_unsat)
              $display("  >>> UNSAT reason: cae_unsat (conflict at decision level 0)");
            else if (dut.cols[0].rows[0].u_core.cae_learned_len == 0)
              $display("  >>> UNSAT reason: cae_learned_len == 0 (empty learned clause)");
            else if (dut.cols[0].rows[0].u_core.conflict_clause_q[0] == 0 &&
                     dut.cols[0].rows[0].u_core.conflict_clause_q[1] == 0)
              $display("  >>> UNSAT reason: conflict_clause[0:1] == {0,0} (zeroed conflict clause)");
          end else if (dbg_prev_state == 5) begin // PSE_PHASE = 5
            $display("  >>> UNSAT reason: conflict at decision_level 0 during PSE propagation");
          end
        end

        // ── EVENT: Entering CONFLICT_ANALYSIS ──
        if (dut.cols[0].rows[0].u_core.state_q == 6 && dbg_prev_state != 6) begin // CONFLICT_ANALYSIS = 6
          if (debug_level >= 1 || (cycle_count % 100000 == 0))
            $display("[CONFLICT Cycle %0d] dlvl=%0d trail=%0d pse_clauses=%0d pse_lits=%0d conflicts=%0d",
                     cycle_count,
                     dut.cols[0].rows[0].u_core.decision_level_q,
                     dut.cols[0].rows[0].u_core.trail_height,
                     dut.cols[0].rows[0].u_core.u_pse.clause_count_q,
                     dut.cols[0].rows[0].u_core.u_pse.lit_count_q,
                     dut.cols[0].rows[0].u_core.total_conflicts);
        end

        // ── EVENT: Learned clause dropped (PSE rejected append) ──
        if (dut.cols[0].rows[0].u_core.state_q == 8 && dbg_prev_state == 7) begin // BACKTRACK_UNDO from BACKTRACK_PHASE
          if (!dut.cols[0].rows[0].u_core.pse_direct_append_accepted &&
              dut.cols[0].rows[0].u_core.cae_direct_append_en) begin
            dbg_total_clause_drops++;
            if (dbg_total_clause_drops <= 20 || dbg_total_clause_drops % 100 == 0)
              $display("[CLAUSE-DROP Cycle %0d] Learned clause REJECTED by PSE (clauses=%0d/%0d, lits=%0d/%0d) total_drops=%0d",
                       cycle_count,
                       dut.cols[0].rows[0].u_core.u_pse.clause_count_q, MAX_CLAUSES_PER_CORE,
                       dut.cols[0].rows[0].u_core.u_pse.lit_count_q, MAX_LITS,
                       dbg_total_clause_drops);
          end
        end

        // ── EVENT: Propagation FIFO full ──
        if (dut.cols[0].rows[0].u_core.prop_fifo_full)
          $display("[FIFO-FULL Cycle %0d] Propagation FIFO full! count=%0d",
                   cycle_count, dut.cols[0].rows[0].u_core.prop_fifo_count);

        // ── EVENT: Validate learned clause against known solution ──
        if (solution_loaded && dut.cols[0].rows[0].u_core.cae_done_edge &&
            dut.cols[0].rows[0].u_core.cae_learned_len > 0 &&
            !dut.cols[0].rows[0].u_core.cae_unsat) begin
          automatic int llen = dut.cols[0].rows[0].u_core.cae_learned_len;
          automatic bit clause_sat = 0;
          automatic string lit_str = "";
          for (int i = 0; i < llen && i < 256; i++) begin
            automatic int signed slit = dut.cols[0].rows[0].u_core.cae_learned_lits[i];
            automatic int uvar = (slit < 0) ? -slit : slit;
            automatic bit lit_true;
            if (slit > 0)
              lit_true = solution_values[uvar];
            else
              lit_true = !solution_values[uvar];
            if (lit_true) clause_sat = 1;
            $sformat(lit_str, "%s %0d", lit_str, slit);
          end
          if (!clause_sat) begin
            dbg_invalid_learned_count++;
            $display("[INVALID-LEARNED Cycle %0d] Conflict #%0d: Learned clause (len=%0d) NOT satisfied by known solution!",
                     cycle_count, dut.cols[0].rows[0].u_core.total_conflicts, llen);
            $display("  Lits:%s", lit_str);
            $display("  dlvl=%0d trail=%0d backtrack_to=%0d",
                     dut.cols[0].rows[0].u_core.decision_level_q,
                     dut.cols[0].rows[0].u_core.trail_height,
                     dut.cols[0].rows[0].u_core.u_cae.backtrack_q);
            // Print the truth values for each literal
            for (int i = 0; i < llen && i < 256; i++) begin
              automatic int signed slit2 = dut.cols[0].rows[0].u_core.cae_learned_lits[i];
              automatic int uvar2 = (slit2 < 0) ? -slit2 : slit2;
              $display("    lit=%0d var=%0d sol_val=%0b => lit_true=%0b",
                       slit2, uvar2, solution_values[uvar2],
                       (slit2 > 0) ? solution_values[uvar2] : !solution_values[uvar2]);
            end
          end else begin
            dbg_valid_learned_count++;
          end
        end

        // ── High-water-mark tracking ──
        if (dut.cols[0].rows[0].u_core.u_pse.clause_count_q > dbg_max_clause_watermark)
          dbg_max_clause_watermark = dut.cols[0].rows[0].u_core.u_pse.clause_count_q;
        if (dut.cols[0].rows[0].u_core.u_pse.lit_count_q > dbg_max_lit_watermark)
          dbg_max_lit_watermark = dut.cols[0].rows[0].u_core.u_pse.lit_count_q;
        if (dut.cols[0].rows[0].u_core.trail_height > dbg_max_trail_watermark)
          dbg_max_trail_watermark = dut.cols[0].rows[0].u_core.trail_height;
        if (dut.cols[0].rows[0].u_core.decision_level_q > dbg_max_dlvl_watermark)
          dbg_max_dlvl_watermark = dut.cols[0].rows[0].u_core.decision_level_q;

        dbg_prev_state = dut.cols[0].rows[0].u_core.state_q;

        // ── Lit count overflow detection ──
        begin
          int cur_lit_count;
          cur_lit_count = dut.cols[0].rows[0].u_core.u_pse.lit_count_q;
          if (cur_lit_count < dbg_prev_lit_count && dbg_prev_lit_count > 60000 && !dbg_lit_overflow_detected) begin
            $display("[LIT-OVERFLOW Cycle %0d] *** lit_count wrapped: %0d -> %0d (clauses=%0d) ***",
                     cycle_count, dbg_prev_lit_count, cur_lit_count,
                     dut.cols[0].rows[0].u_core.u_pse.clause_count_q);
            dbg_lit_overflow_detected = 1;
          end
          dbg_prev_lit_count = cur_lit_count;
        end

        // ── Periodic heartbeat ──
        if (debug_level == 0) begin
          if (cycle_count % 10000 == 0) begin
             $display("[Heartbeat] Cycle %0d | Conflicts: %0d | Decisions: %0d | Restarts: %0d | Learned: %0d | Clauses: %0d/%0d | Lits: %0d/%0d | Trail: %0d | DLvl: %0d",
                      cycle_count,
                      dut.cols[0].rows[0].u_core.total_conflicts,
                      dut.cols[0].rows[0].u_core.total_decisions,
                      dut.cols[0].rows[0].u_core.total_restarts,
                      dut.cols[0].rows[0].u_core.total_learned,
                      dut.cols[0].rows[0].u_core.u_pse.clause_count_q, MAX_CLAUSES_PER_CORE,
                      dut.cols[0].rows[0].u_core.u_pse.lit_count_q, MAX_LITS,
                      dut.cols[0].rows[0].u_core.trail_height,
                      dut.cols[0].rows[0].u_core.decision_level_q);
          end
        end else if (debug_level >= 1) begin
          if (cycle_count == 1 || cycle_count == 2 || cycle_count == 3 || cycle_count % 100 == 0) begin
            $display("[Cycle %0d] done=%0d sat=%0d unsat=%0d state=%0d dlvl=%0d height=%0d pse_state=%0d pse_done=%0d pse_conflict=%0d clauses=%0d lits=%0d",
                     cycle_count, host_done, host_sat, host_unsat,
                     dut.cols[0].rows[0].u_core.state_q,
                     dut.cols[0].rows[0].u_core.decision_level_q,
                     dut.cols[0].rows[0].u_core.trail_height,
                     dut.cols[0].rows[0].u_core.u_pse.state_q,
                     dut.cols[0].rows[0].u_core.u_pse.done,
                     dut.cols[0].rows[0].u_core.u_pse.conflict_detected,
                     dut.cols[0].rows[0].u_core.u_pse.clause_count_q,
                     dut.cols[0].rows[0].u_core.u_pse.lit_count_q);
          end
        end
      end
      end_time = $realtime;

      // ── Post-run capacity summary ──
      $display("\n=== CAPACITY SUMMARY ===");
      $display("  Clause high-water: %0d / %0d (%0d%%)", dbg_max_clause_watermark, MAX_CLAUSES_PER_CORE,
               (dbg_max_clause_watermark * 100) / MAX_CLAUSES_PER_CORE);
      $display("  Literal high-water: %0d / %0d (%0d%%)", dbg_max_lit_watermark, MAX_LITS,
               (dbg_max_lit_watermark * 100) / MAX_LITS);
      $display("  Trail high-water: %0d", dbg_max_trail_watermark);
      $display("  Decision level high-water: %0d", dbg_max_dlvl_watermark);
      $display("  Learned clause drops: %0d", dbg_total_clause_drops);
      $display("  Final stats: conflicts=%0d decisions=%0d restarts=%0d learned=%0d",
               dut.cols[0].rows[0].u_core.total_conflicts,
               dut.cols[0].rows[0].u_core.total_decisions,
               dut.cols[0].rows[0].u_core.total_restarts,
               dut.cols[0].rows[0].u_core.total_learned);
      $display("  CAE buf_overflow=%0b dropped_lits=%0d",
               dut.cols[0].rows[0].u_core.u_cae.buf_overflow_q,
               dut.cols[0].rows[0].u_core.u_cae.dropped_lits_q);
      if (solution_loaded) begin
        $display("=== LEARNED CLAUSE VALIDATION ===");
        $display("  Valid learned clauses: %0d", dbg_valid_learned_count);
        $display("  INVALID learned clauses: %0d", dbg_invalid_learned_count);
        if (dbg_invalid_learned_count > 0)
          $display("  >>> BUG CONFIRMED: %0d learned clauses violated the known satisfying assignment!", dbg_invalid_learned_count);
        else
          $display("  All learned clauses are consistent with the known solution.");
      end
      $display("  Restart threshold: %0d", RESTART_CONFLICT_THRESHOLD);
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

    // Load known satisfying assignment for learned clause validation
    begin
      string sol_file;
      if ($value$plusargs("SOLUTION=%s", sol_file)) begin
        int fd;
        string line;
        fd = $fopen(sol_file, "r");
        if (fd) begin
          // Skip "SAT" line
          void'($fgets(line, fd));
          // Parse assignment line: space-separated signed ints ending with 0
          begin
            int sval;
            // Initialize all to 0
            for (int i = 0; i < 512; i++) solution_values[i] = 0;
            while ($fscanf(fd, "%d", sval) == 1) begin
              if (sval == 0) break;
              if (sval > 0) solution_values[sval] = 1;
              else solution_values[-sval] = 0;
            end
          end
          $fclose(fd);
          solution_loaded = 1;
          $display("[TB] Loaded known solution from %s for learned clause validation", sol_file);
        end else begin
          $display("[TB] WARNING: Could not open solution file: %s", sol_file);
        end
      end
    end

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
    #(64'd7200_000_000_000); // 2 hour sim time budget
    $display("\n*** GLOBAL TIMEOUT - ABORTING ***");
    $finish;
  end
  // Debug output removed for faster simulation

endmodule
