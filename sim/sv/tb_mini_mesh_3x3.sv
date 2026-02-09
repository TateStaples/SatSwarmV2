`timescale 1ns/1ps
// Mini 3x3 Mesh Testbench
// Tests work-stealing fork handshake across a 9-core mesh
module tb_mini_mesh_3x3;
    logic clk;
    logic rst_n;

    // Parameters
    parameter int MAX_VARS = 32;
    parameter int MAX_CLAUSES = 64;
    parameter int MAX_LITS = 512;
    parameter int MAX_CLAUSE_LEN = 8;
    parameter int GRID_X = 3;
    parameter int GRID_Y = 3;
    parameter int NUM_CORES = GRID_X * GRID_Y;

    // Debug level
    int DEBUG = 0;

    // =========================================================================
    // Core signals (for all 9 cores)
    // =========================================================================
    logic               core_load_valid   [NUM_CORES];
    logic signed [31:0] core_load_literal [NUM_CORES];
    logic               core_load_clause_end [NUM_CORES];
    logic               core_load_ready   [NUM_CORES];
    logic               core_start        [NUM_CORES];
    logic               core_done         [NUM_CORES];
    logic               core_sat          [NUM_CORES];
    logic               core_unsat        [NUM_CORES];
    logic [31:0]        core_conflict_count [NUM_CORES];
    logic [31:0]        core_decision_count [NUM_CORES];
    
    // Work stealing signals
    logic                        core_fork_valid      [NUM_CORES];
    logic [2*MAX_VARS-1:0]       core_fork_assignments[NUM_CORES];
    logic signed [31:0]          core_fork_decision   [NUM_CORES];
    logic                        core_fork_ready      [NUM_CORES];
    logic                        core_idle            [NUM_CORES];
    logic [2*MAX_VARS-1:0]       core_my_assignments  [NUM_CORES];
    logic signed [31:0]          core_my_pending_decision [NUM_CORES];

    // =========================================================================
    // Instantiate all 9 cores using generate
    // =========================================================================
    genvar gi;
    generate
        for (gi = 0; gi < NUM_CORES; gi++) begin : gen_cores
            mini_top #(
                .MAX_VARS(MAX_VARS),
                .MAX_CLAUSES(MAX_CLAUSES),
                .MAX_LITS(MAX_LITS),
                .MAX_CLAUSE_LEN(MAX_CLAUSE_LEN)
            ) core (
                .DEBUG(DEBUG),
                .clk(clk),
                .rst_n(rst_n),
                .start_solve(core_start[gi]),
                .done(core_done[gi]),
                .sat(core_sat[gi]),
                .unsat(core_unsat[gi]),
                .load_valid(core_load_valid[gi]),
                .load_literal(core_load_literal[gi]),
                .load_clause_end(core_load_clause_end[gi]),
                .load_ready(core_load_ready[gi]),
                .conflict_count(core_conflict_count[gi]),
                .decision_count(core_decision_count[gi]),
                .fork_valid(core_fork_valid[gi]),
                .fork_assignments(core_fork_assignments[gi]),
                .fork_decision(core_fork_decision[gi]),
                .fork_ready(core_fork_ready[gi]),
                .idle(core_idle[gi]),
                .my_assignments(core_my_assignments[gi]),
                .my_pending_decision(core_my_pending_decision[gi])
            );
        end
    endgenerate

    // =========================================================================
    // Clock
    // =========================================================================
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz

    // =========================================================================
    // Mesh Interconnect - Fork Controller
    // Grid layout:
    //   0 1 2
    //   3 4 5
    //   6 7 8
    // Each core can fork to its 4 neighbors (up, down, left, right)
    // =========================================================================
    
    // Track fork events
    int fork_count;
    
    // Get neighbor indices
    function automatic int get_neighbor_up(int idx);
        int y = idx / GRID_X;
        if (y > 0) return idx - GRID_X;
        else return -1;
    endfunction
    
    function automatic int get_neighbor_down(int idx);
        int y = idx / GRID_X;
        if (y < GRID_Y - 1) return idx + GRID_X;
        else return -1;
    endfunction
    
    function automatic int get_neighbor_left(int idx);
        int x = idx % GRID_X;
        if (x > 0) return idx - 1;
        else return -1;
    endfunction
    
    function automatic int get_neighbor_right(int idx);
        int x = idx % GRID_X;
        if (x < GRID_X - 1) return idx + 1;
        else return -1;
    endfunction

    // Mesh fork controller - looks for active cores with pending decisions
    // and idle neighbors to fork work to
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fork_count <= 0;
            for (int i = 0; i < NUM_CORES; i++) begin
                core_fork_valid[i] <= 1'b0;
                core_fork_assignments[i] <= '0;
                core_fork_decision[i] <= '0;
            end
        end else begin
            // Default: clear all fork_valid
            for (int i = 0; i < NUM_CORES; i++) begin
                core_fork_valid[i] <= 1'b0;
            end
            
            // Check each core for fork opportunities
            for (int src = 0; src < NUM_CORES; src++) begin
                // Source core must have a pending decision and not be done
                if (core_my_pending_decision[src] != 0 && !core_done[src]) begin
                    // Check neighbors in order: up, down, left, right
                    int neighbors[4];
                    neighbors[0] = get_neighbor_up(src);
                    neighbors[1] = get_neighbor_down(src);
                    neighbors[2] = get_neighbor_left(src);
                    neighbors[3] = get_neighbor_right(src);
                    
                    for (int n = 0; n < 4; n++) begin
                        int dst = neighbors[n];
                        if (dst >= 0 && dst < NUM_CORES) begin
                            if (core_idle[dst] && core_fork_ready[dst] && 
                                !core_fork_valid[dst]) begin
                                // Fork!
                                $display("[%0t] FORK: Core %0d -> Core %0d (decision %0d)",
                                    $time, src, dst, -core_my_pending_decision[src]);
                                core_fork_valid[dst] <= 1'b1;
                                core_fork_assignments[dst] <= core_my_assignments[src];
                                core_fork_decision[dst] <= -core_my_pending_decision[src];
                                fork_count <= fork_count + 1;
                            end
                        end
                    end
                end
            end
        end
    end

    // =========================================================================
    // All cores share the clause database (broadcast during load)
    // =========================================================================
    // Non-core-0 signals are driven by broadcast logic below

    // =========================================================================
    // Test Control
    // =========================================================================
    longint unsigned cycle_count;
    longint unsigned max_cycles = 500000;
    string cnf_file;
    int clause_count;
    int var_count;

    // Broadcast literal to ALL cores (shared clause DB)
    task automatic push_literal_all_cores(input int lit, input bit clause_end);
    begin
        @(posedge clk);
        // Wait for all cores to be ready
        while (!core_load_ready[0]) @(posedge clk);
        
        // Broadcast to all cores simultaneously
        for (int i = 0; i < NUM_CORES; i++) begin
            core_load_valid[i] <= 1'b1;
            core_load_literal[i] <= lit;
            core_load_clause_end[i] <= clause_end;
        end
        @(posedge clk);
        for (int i = 0; i < NUM_CORES; i++) begin
            core_load_valid[i] <= 1'b0;
            core_load_clause_end[i] <= 1'b0;
        end
    end
    endtask

    task automatic load_cnf_file(input string filename);
        int fd;
        string line;
        int lit;
        int scan_result;
        int num_vars, num_clauses;
        int literals[$];
    begin
        $display("[%0t] Loading CNF file: %s", $time, filename);
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
                                    push_literal_all_cores(literals[i], (i == literals.size()-1));
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

    // =========================================================================
    // Main Test
    // =========================================================================
    initial begin
        // Parse command line
        if (!$value$plusargs("CNF=%s", cnf_file)) begin
            cnf_file = "";  // Will use default test
        end
        
        if (!$value$plusargs("MAXCYCLES=%d", max_cycles)) begin
            max_cycles = 500000;
        end

        $display("\n");
        $display("=====================================");
        $display("Mini 3x3 Mesh Testbench (9 Cores)");
        $display("=====================================");
        $display("Grid layout:");
        $display("  0 1 2");
        $display("  3 4 5");
        $display("  6 7 8");
        if (cnf_file != "") $display("CNF: %s", cnf_file);
        $display("\n");

        // Reset
        rst_n = 0;
        core_load_valid[0] = 0;
        core_load_literal[0] = 0;
        core_load_clause_end[0] = 0;
        core_start[0] = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        // Load CNF to Core 0 only
        if (cnf_file != "") begin
            load_cnf_file(cnf_file);
        end else begin
            $display("ERROR: No CNF file specified. Use +CNF=<file>");
            $finish;
        end

        // Start Core 0
        $display("[%0t] Starting Core 0 solve...", $time);
        @(posedge clk);
        core_start[0] <= 1'b1;
        @(posedge clk);
        core_start[0] <= 1'b0;

        // Run simulation until any core finds SAT or all are done/UNSAT
        cycle_count = 0;
        begin
            bit sat_found_early = 0;
            bit all_unsat = 0;
            while (cycle_count < max_cycles && !sat_found_early && !all_unsat) begin
                @(posedge clk);
                cycle_count++;
                
                // Check for SAT
                for (int i = 0; i < NUM_CORES; i++) begin
                    if (core_sat[i]) begin
                        $display("\n[Cycle %0d] *** SAT FOUND by Core %0d ***", cycle_count, i);
                        sat_found_early = 1;
                    end
                end
                
                // Check for UNSAT (all done cores are UNSAT, and at least one is done)
                if (!sat_found_early) begin
                    int done_count = 0;
                    int unsat_count = 0;
                    for (int i = 0; i < NUM_CORES; i++) begin
                        if (core_done[i]) done_count++;
                        if (core_unsat[i]) unsat_count++;
                    end
                    // If all done cores are UNSAT and at least Core 0 is done
                    if (core_done[0] && done_count > 0 && done_count == unsat_count) begin
                        $display("\n[Cycle %0d] *** UNSAT: All active cores exhausted ***", cycle_count);
                        all_unsat = 1;
                    end
                end
                
                // Progress update with heartbeat tracking
                if (!sat_found_early && !all_unsat && cycle_count % 1000 == 0) begin
                    int active = 0;
                    int idle_cnt = 0;
                    int done_cnt = 0;
                    int total_decisions = 0;
                    int total_conflicts = 0;
                    for (int i = 0; i < NUM_CORES; i++) begin
                        if (!core_idle[i] && !core_done[i]) active++;
                        if (core_idle[i]) idle_cnt++;
                        if (core_done[i]) done_cnt++;
                        total_decisions += core_decision_count[i];
                        total_conflicts += core_conflict_count[i];
                    end
                    $display("[Cycle %0d] Active: %0d Idle: %0d Done: %0d Forks: %0d Dec: %0d Conf: %0d",
                        cycle_count, active, idle_cnt, done_cnt, fork_count, total_decisions, total_conflicts);
                end
            end
        end
        // Results
        $display("\n=====================================");
        $display("RESULTS");
        $display("=====================================");
        $display("Cycles: %0d", cycle_count);
        $display("Total Forks: %0d", fork_count);
        $display("");
        
        for (int i = 0; i < NUM_CORES; i++) begin
            $display("Core %0d: done=%b sat=%b unsat=%b conflicts=%0d decisions=%0d",
                i, core_done[i], core_sat[i], core_unsat[i], 
                core_conflict_count[i], core_decision_count[i]);
        end

        // Summary
        $display("");
        begin
            int sat_found = 0;
            int total_decisions = 0;
            int total_conflicts = 0;
            for (int i = 0; i < NUM_CORES; i++) begin
                if (core_sat[i]) sat_found = 1;
                total_decisions += core_decision_count[i];
                total_conflicts += core_conflict_count[i];
            end
            
            if (fork_count > 0) begin
                $display("*** MESH FORK SUCCESS: %0d forks executed ***", fork_count);
            end
            
            if (sat_found) begin
                $display("*** SAT FOUND ***");
            end
            
            $display("Total Decisions across mesh: %0d", total_decisions);
            $display("Total Conflicts across mesh: %0d", total_conflicts);
        end

        $display("=====================================\n");
        $finish;
    end

    // Timeout
    initial begin
        #200000000; // 200ms sim time
        $display("\n*** TIMEOUT ***");
        $finish;
    end

endmodule
