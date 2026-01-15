`timescale 1ns/1ps

module tb_satswarmv2;
    import satswarmv2_pkg::*;
    
    logic clk, rst_n;
    logic host_start;
    logic host_done, host_sat, host_unsat;
    logic host_load_valid, host_load_ready;
    logic signed [31:0] host_load_literal;
    logic host_load_clause_end;
    
    // DDR4 signals (mocked)
    logic ddr_read_req, ddr_read_valid;
    logic [31:0] ddr_read_addr, ddr_read_data;
    logic [7:0] ddr_read_len;
    logic ddr_write_req;
    logic [31:0] ddr_write_addr, ddr_write_data;
    logic ddr_read_grant, ddr_write_grant;

    satswarm_top #(
        .GRID_X(2),
        .GRID_Y(2),
        .MAX_VARS_PER_CORE(128),
        .MAX_CLAUSES_PER_CORE(128)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .host_start(host_start),
        .host_done(host_done),
        .host_sat(host_sat),
        .host_unsat(host_unsat),
        .host_load_valid(host_load_valid),
        .host_load_ready(host_load_ready),
        .host_load_literal(host_load_literal),
        .host_load_clause_end(host_load_clause_end),
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
    
    initial clk = 0;
    always #5 clk = ~clk;
    
    task run_test(input string name, input string cnf_file, input bit expected_sat, input int max_cycles);
        automatic int fd, num_vars, num_clauses, lit, clause_count=0, cycle_count=0;
        automatic string line;
        automatic bit done=0, result_correct;
        automatic longint start_time, end_time;
        
        $display("\n========================================");
        $display("TEST: %s", name);
        $display("========================================");
        
        // Load CNF
        fd = $fopen(cnf_file, "r");
        if (!fd) begin
            $display("ERROR: Could not open %s", cnf_file);
            $finish;
        end
        
        while (!$feof(fd)) begin
            void'($fgets(line, fd));
            if (line.len() > 0 && line[0] != "c") begin
                if (line[0] == "p") begin
                    void'($sscanf(line, "p cnf %d %d", num_vars, num_clauses));
                    $display("  Problem: %0d variables, %0d clauses", num_vars, num_clauses);
                    break;
                end
            end
        end
        
        @(posedge clk);
        while (!$feof(fd)) begin
            void'($fgets(line, fd));
            if (line.len() > 0 && line[0] != "c" && line[0] != "p") begin
                automatic string tokens[$];
                automatic int token_idx = 0;
                
                // Simple string parsing
                for (int i = 0; i < line.len(); i++) begin
                    if (line[i] != " " && line[i] != "\t" && line[i] != "\n") begin
                        automatic string token = "";
                        while (i < line.len() && line[i] != " " && line[i] != "\t" && line[i] != "\n") begin
                            token = {token, line[i]};
                            i++;
                        end
                        tokens.push_back(token);
                    end
                end
                
                foreach (tokens[i]) begin
                    lit = tokens[i].atoi();
                    if (lit != 0) begin
                        @(posedge clk);
                        while (!host_load_ready) @(posedge clk);
                        host_load_valid = 1;
                        host_load_literal = lit;
                        host_load_clause_end = 0;
                        @(posedge clk);
                        host_load_valid = 0;
                    end else begin
                        @(posedge clk);
                        while (!host_load_ready) @(posedge clk);
                        host_load_valid = 1;
                        host_load_clause_end = 1;
                        clause_count++;
                        @(posedge clk);
                        host_load_valid = 0;
                        host_load_clause_end = 0;
                    end
                end
            end
        end
        $fclose(fd);
        
        $display("  Loaded %0d clauses", clause_count);
        
        // Start solve
        @(posedge clk);
        host_start = 1;
        @(posedge clk);
        host_start = 0;
        
        start_time = $time;
        
        // Wait for result
        while (!host_done && cycle_count < max_cycles) begin
            @(posedge clk);
            cycle_count++;
        end
        
        end_time = $time;
        
        // Check result
        result_correct = (host_sat == expected_sat) && (host_unsat == !expected_sat);
        
        $display("\n=== RESULTS ===");
        $display("  Status: %s", host_sat ? "SAT" : (host_unsat ? "UNSAT" : "UNKNOWN"));
        $display("  Expected: %s", expected_sat ? "SAT" : "UNSAT");
        $display("  Result: %s", result_correct ? "PASS" : "FAIL");
        $display("  Cycles: %0d", cycle_count);
        
        if (!result_correct) begin
            $display("\n*** TEST FAILED ***\n");
            $finish(1);
        end else begin
            $display("\n*** TEST PASSED ***\n");
        end
    endtask
    
    initial begin
        rst_n = 0;
        host_start = 0;
        host_load_valid = 0;
        host_load_literal = 0;
        host_load_clause_end = 0;
        
        repeat(5) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);
        
        run_test("SATLIB uf20-08", "../tests/eval_set/uf20-08.cnf", 1'b1, 100000);
        run_test("SATLIB uf20-010", "../tests/eval_set/uf20-010.cnf", 1'b1, 100000);
        
        $display("\n=====================================");
        $display("ALL TESTS PASSED");
        $display("=====================================");
        $finish;
    end
endmodule
