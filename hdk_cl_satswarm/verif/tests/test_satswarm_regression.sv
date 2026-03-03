// test_satswarm_regression.sv — File-driven CNF regression test
// Reads +CNF=<path> and +EXPECT=SAT|UNSAT plusargs to run a single test
// Called by run_aws_regression.sh for all 98 instances
`timescale 1ns/1ps

module test_satswarm_regression;

    logic clk = 0;
    always #5 clk = ~clk; // 100 MHz

    logic rst_n_in;

    // AXI-Lite
    logic        axil_wr_valid, axil_wr_ready;
    logic [31:0] axil_wr_addr, axil_wr_data;
    logic        axil_rd_valid, axil_rd_ready;
    logic [31:0] axil_rd_addr, axil_rd_data;

    // PCIS DMA
    logic        pcis_wr_valid, pcis_wr_ready;
    logic [31:0] pcis_wr_addr, pcis_wr_data;

    // DDR4
    logic        ddr_read_req, ddr_read_grant, ddr_read_valid;
    logic [31:0] ddr_read_addr, ddr_read_data;
    logic [7:0]  ddr_read_len;
    logic        ddr_write_req, ddr_write_grant;
    logic [31:0] ddr_write_addr, ddr_write_data;

    // DUT
    cl_satswarm #(
        .GRID_X(1), .GRID_Y(1),
        .MAX_VARS_PER_CORE(256),
        .MAX_CLAUSES_PER_CORE(512),
        .MAX_LITS(1024)
    ) dut (.*);

    // DDR4 mock
    always @(posedge clk) begin
        ddr_read_grant <= ddr_read_req;
        ddr_read_valid <= ddr_read_req;
        ddr_read_data  <= 32'h0;
        ddr_write_grant <= ddr_write_req;
    end

    // ---- Helper tasks ----
    task axil_write(input logic [31:0] addr, input logic [31:0] data);
        @(posedge clk);
        axil_wr_valid <= 1'b1;
        axil_wr_addr  <= addr;
        axil_wr_data  <= data;
        @(posedge clk);
        axil_wr_valid <= 1'b0;
    endtask

    task axil_read(input logic [31:0] addr, output logic [31:0] data);
        @(posedge clk);
        axil_rd_valid <= 1'b1;
        axil_rd_addr  <= addr;
        @(posedge clk);
        data = axil_rd_data;
        axil_rd_valid <= 1'b0;
    endtask

    task dma_write_literal(input int lit, input bit clause_end);
        @(posedge clk);
        while (!pcis_wr_ready) @(posedge clk);
        pcis_wr_valid <= 1'b1;
        pcis_wr_data  <= lit;
        pcis_wr_addr  <= clause_end ? 32'h0000_1004 : 32'h0000_1000;
        @(posedge clk);
        pcis_wr_valid <= 1'b0;
    endtask

    // ---- CNF file loader (via DMA) ----
    task automatic load_cnf_file(input string filename);
        int fd;
        string line;
        int lit;
        int scan_result;
        int num_vars, num_clauses;
        int literals[$];
        int clause_count;

        $display("[%0t] Loading CNF file: %s", $time, filename);
        fd = $fopen(filename, "r");
        if (fd == 0) begin
            $display("ERROR: Cannot open file %s", filename);
            $finish;
        end

        clause_count = 0;

        while (!$feof(fd)) begin
            if ($fgets(line, fd)) begin
                // Skip comments
                if (line[0] == "c") continue;

                // Parse problem line
                if (line[0] == "p") begin
                    scan_result = $sscanf(line, "p cnf %d %d", num_vars, num_clauses);
                    if (scan_result == 2)
                        $display("  Problem: %0d variables, %0d clauses", num_vars, num_clauses);
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
                                // End of clause
                                foreach (literals[i]) begin
                                    dma_write_literal(literals[i], (i == literals.size()-1));
                                end
                                clause_count++;
                                break;
                            end else begin
                                literals.push_back(lit);
                            end
                            // Advance position past current number
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
    endtask

    // ---- Main test ----
    string cnf_file;
    string expect_str;
    bit expect_sat;
    int debug_level;
    logic [31:0] status;
    logic [31:0] cycles;

    initial begin
        axil_wr_valid = 0; axil_rd_valid = 0;
        pcis_wr_valid = 0;

        // Parse plusargs
        if (!$value$plusargs("CNF=%s", cnf_file)) begin
            $display("ERROR: Must provide +CNF=<filename>");
            $display("TEST FAILED");
            $finish;
        end

        expect_sat = 0;
        if ($value$plusargs("EXPECT=%s", expect_str)) begin
            if (expect_str == "SAT" || expect_str == "sat")
                expect_sat = 1;
        end

        debug_level = 0;
        if ($value$plusargs("DEBUG=%d", debug_level)) begin
            // Set debug level via AXI-Lite after reset
        end

        $display("\n=== REGRESSION TEST ===");
        $display("CNF:    %s", cnf_file);
        $display("EXPECT: %s", expect_sat ? "SAT" : "UNSAT");

        // Reset
        rst_n_in = 0;
        repeat (10) @(posedge clk);
        rst_n_in = 1;
        repeat (4) @(posedge clk);

        // Set debug level
        if (debug_level > 0)
            axil_write(32'h10, debug_level);

        // Load CNF via DMA
        load_cnf_file(cnf_file);

        // Start solve
        repeat (4) @(posedge clk);
        axil_write(32'h00, 32'h1);

        // Wait for done (up to 5M cycles)
        begin
            int timeout = 5000000;
            while (timeout > 0) begin
                axil_read(32'h00, status);
                if (status[0]) break;
                timeout--;
            end
        end

        axil_read(32'h04, cycles);

        // Check result
        if (!status[0]) begin
            $display("TIMEOUT after poll limit");
            $display("TEST FAILED");
            $finish;
        end

        begin
            bit got_sat  = status[1];
            bit got_unsat = status[2];
            $display("Result: %s (cycles=%0d)", got_sat ? "SAT" : "UNSAT", cycles);

            if (got_sat == expect_sat) begin
                $display("TEST PASSED");
            end else begin
                $display("Expected %s but got %s", expect_sat ? "SAT" : "UNSAT", got_sat ? "SAT" : "UNSAT");
                $display("TEST FAILED");
            end
        end

        $finish;
    end

    // Global timeout
    initial begin
        #500_000_000; // 50ms sim time budget
        $display("GLOBAL TIMEOUT");
        $display("TEST FAILED");
        $finish;
    end

endmodule
