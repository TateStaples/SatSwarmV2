// test_satswarm_basic.sv — Basic AXI-Lite register and small SAT solve test
`timescale 1ns/1ps

module test_satswarm_basic;

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

    // ---- Main test ----
    int errors = 0;
    logic [31:0] rd_data;

    initial begin
        // Init
        rst_n_in = 0;
        axil_wr_valid = 0; axil_rd_valid = 0;
        pcis_wr_valid = 0;
        repeat (10) @(posedge clk);
        rst_n_in = 1;
        repeat (4) @(posedge clk);

        $display("\n=== TEST 1: Version Register ===");
        axil_read(32'h08, rd_data);
        if (rd_data !== 32'h53415431) begin
            $display("FAIL: Version = 0x%08X (expected 0x53415431)", rd_data);
            errors++;
        end else begin
            $display("PASS: Version = 0x%08X", rd_data);
        end

        $display("\n=== TEST 2: Status after reset ===");
        axil_read(32'h00, rd_data);
        if (rd_data[0] !== 1'b0) begin
            $display("FAIL: host_done should be 0 after reset, got 0x%08X", rd_data);
            errors++;
        end else begin
            $display("PASS: Status = 0x%08X (done=0)", rd_data);
        end

        $display("\n=== TEST 3: Small SAT solve (2 vars, 2 clauses) ===");
        // CNF: p cnf 2 2
        //   1 2 0      → clause {1, 2}
        //  -1 2 0      → clause {-1, 2}
        // SAT: x2=true satisfies both
        dma_write_literal(32'd1, 0);        // lit 1
        dma_write_literal(32'd2, 1);        // lit 2, clause end
        dma_write_literal(-32'sd1, 0);      // lit -1
        dma_write_literal(32'd2, 1);        // lit 2, clause end

        // Start solve
        repeat (4) @(posedge clk);
        axil_write(32'h00, 32'h1);  // host_start

        // Wait for done (up to 100k cycles)
        begin
            int timeout = 100000;
            while (timeout > 0) begin
                axil_read(32'h00, rd_data);
                if (rd_data[0]) break; // done
                timeout--;
            end
        end

        axil_read(32'h00, rd_data);
        if (rd_data[0] && rd_data[1]) begin
            $display("PASS: Solver returned SAT (status=0x%08X)", rd_data);
        end else begin
            $display("FAIL: Expected SAT, got status=0x%08X", rd_data);
            errors++;
        end

        // Read cycle count
        axil_read(32'h04, rd_data);
        $display("INFO: Cycle count = %0d", rd_data);

        // ---- Final verdict ----
        $display("\n========================================");
        if (errors == 0) begin
            $display("TEST PASSED (%0d subtests ok)", 3);
        end else begin
            $display("TEST FAILED (%0d errors)", errors);
        end
        $display("========================================\n");
        $finish;
    end

    // Global timeout
    initial begin
        #50_000_000; // 5ms sim time
        $display("GLOBAL TIMEOUT");
        $display("TEST FAILED");
        $finish;
    end

endmodule
