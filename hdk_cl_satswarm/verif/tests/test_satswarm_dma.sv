// test_satswarm_dma.sv — DMA CNF load + solve verification
// Loads two CNF instances back-to-back (SAT then UNSAT) via DMA port
`timescale 1ns/1ps

module test_satswarm_dma;

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

    task do_reset();
        rst_n_in = 0;
        repeat (10) @(posedge clk);
        rst_n_in = 1;
        repeat (4) @(posedge clk);
    endtask

    task wait_for_done(output logic [31:0] status, input int max_cycles);
        int cnt = 0;
        status = 0;
        while (cnt < max_cycles) begin
            axil_read(32'h00, status);
            if (status[0]) return; // done
            cnt++;
        end
    endtask

    // ---- Main test ----
    int errors = 0;
    logic [31:0] status;
    logic [31:0] cycles;

    initial begin
        axil_wr_valid = 0; axil_rd_valid = 0;
        pcis_wr_valid = 0;

        // ============================
        // TEST 1: SAT instance (5 vars, 5 clauses)
        // p cnf 5 5
        //  1  2  0
        // -1  3  0
        // -2  4  0
        //  3  5  0
        // -4  5  0
        // SAT (e.g., all true)
        // ============================
        $display("\n=== DMA TEST 1: 5-var SAT instance ===");
        do_reset();

        dma_write_literal(32'd1, 0);  dma_write_literal(32'd2, 1);
        dma_write_literal(-32'sd1, 0); dma_write_literal(32'd3, 1);
        dma_write_literal(-32'sd2, 0); dma_write_literal(32'd4, 1);
        dma_write_literal(32'd3, 0);  dma_write_literal(32'd5, 1);
        dma_write_literal(-32'sd4, 0); dma_write_literal(32'd5, 1);

        repeat (4) @(posedge clk);
        axil_write(32'h00, 32'h1);

        wait_for_done(status, 200000);
        axil_read(32'h04, cycles);

        if (status[0] && status[1]) begin
            $display("PASS: SAT returned correctly (cycles=%0d)", cycles);
        end else begin
            $display("FAIL: Expected SAT, got status=0x%08X (cycles=%0d)", status, cycles);
            errors++;
        end

        // ============================
        // TEST 2: UNSAT instance (2 vars, 4 clauses)
        // p cnf 2 4
        //  1  0
        // -1  0
        //  2  0
        // -2  0
        // UNSAT (contradictory unit clauses)
        // ============================
        $display("\n=== DMA TEST 2: 2-var UNSAT instance ===");
        // Soft reset via AXI-Lite
        axil_write(32'h0C, 32'h1);
        repeat (10) @(posedge clk);

        dma_write_literal(32'd1, 1);        // clause {1}
        dma_write_literal(-32'sd1, 1);       // clause {-1}
        dma_write_literal(32'd2, 1);        // clause {2}
        dma_write_literal(-32'sd2, 1);       // clause {-2}

        repeat (4) @(posedge clk);
        axil_write(32'h00, 32'h1);

        wait_for_done(status, 200000);
        axil_read(32'h04, cycles);

        if (status[0] && status[2]) begin
            $display("PASS: UNSAT returned correctly (cycles=%0d)", cycles);
        end else begin
            $display("FAIL: Expected UNSAT, got status=0x%08X (cycles=%0d)", status, cycles);
            errors++;
        end

        // ============================
        // TEST 3: Verify cycle counter increments
        // ============================
        $display("\n=== DMA TEST 3: Cycle counter check ===");
        if (cycles > 0) begin
            $display("PASS: Cycle counter = %0d (non-zero)", cycles);
        end else begin
            $display("FAIL: Cycle counter = 0 (expected non-zero)");
            errors++;
        end

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
        #100_000_000; // 10ms sim time
        $display("GLOBAL TIMEOUT");
        $display("TEST FAILED");
        $finish;
    end

endmodule
