// cl_satswarm.sv -- AWS F2 HDK Shell wrapper for SatSwarm SAT solver
//
// Bridges the AWS Shell interfaces to satswarm_core_bridge's simplified interface.
// This module is the CL top-level for AWS F2 deployment.
//
// Interfaces used:
//   - OCL AXI-Lite (AppPF BAR0): Register reads/writes (status, control)
//   - DMA_PCIS AXI4 (512-bit): CNF literal loading via DMA
//   - DDR4 AXI4 via sh_ddr: Clause database memory
//
// Interfaces tied off:
//   - SDA, PCIM, HBM, PCIe EP/RP, JTAG

`timescale 1ns/1ps

module cl_satswarm #(
    parameter int GRID_X               = 1,
    parameter int GRID_Y               = 1,
    parameter int MAX_VARS_PER_CORE    = 256,
    parameter int MAX_CLAUSES_PER_CORE = 512,
    parameter int MAX_LITS             = 1024
)(
    `include "cl_ports.vh"
);

`include "cl_id_defines.vh"
`include "cl_satswarm_defines.vh"

    // =========================================================================
    // Reset synchronization
    // =========================================================================
    logic rst_main_n_sync;

    lib_pipe #(.WIDTH(1), .STAGES(4)) RST_PIPE (
        .clk     (clk_main_a0),
        .rst_n   (1'b1),
        .in_bus  (rst_main_n),
        .out_bus (rst_main_n_sync)
    );

    // =========================================================================
    // Global tie-offs
    // =========================================================================
    always_comb begin
        cl_sh_flr_done    = 1'b1;
        cl_sh_id0         = `CL_SH_ID0;
        cl_sh_id1         = `CL_SH_ID1;
        cl_sh_status0     = 32'b0;
        cl_sh_status1     = 32'b0;
        cl_sh_status2     = 32'b0;
        cl_sh_dma_wr_full = 1'b0;
        cl_sh_dma_rd_full = 1'b0;
    end

    // =========================================================================
    // Internal signals to satswarm_core_bridge
    // =========================================================================
    logic        axil_wr_valid, axil_wr_ready;
    logic [31:0] axil_wr_addr, axil_wr_data;
    logic        axil_rd_valid, axil_rd_ready;
    logic [31:0] axil_rd_addr, axil_rd_data;

    logic        pcis_wr_valid, pcis_wr_ready;
    logic [31:0] pcis_wr_addr, pcis_wr_data;

    logic        ddr_read_req, ddr_read_grant, ddr_read_valid;
    logic [31:0] ddr_read_addr, ddr_read_data;
    logic [7:0]  ddr_read_len;
    logic        ddr_write_req, ddr_write_grant;
    logic [31:0] ddr_write_addr, ddr_write_data;

    // =========================================================================

    // =========================================================================
    // Clocking IP (AWS_CLK_GEN)
    // =========================================================================
    logic gen_clk_main_a0;
    logic gen_clk_extra_a1;
    logic gen_clk_extra_a2;
    logic gen_clk_extra_a3;
    logic gen_rst_main_n;
    logic gen_rst_a1_n;
    logic gen_rst_a2_n;
    logic gen_rst_a3_n;

    aws_clk_gen #(
        .CLK_GRP_A_EN(1),
        .CLK_GRP_B_EN(0),
        .CLK_GRP_C_EN(0),
        .CLK_HBM_EN  (0)
    ) AWS_CLK_GEN (
        .i_clk_main_a0         (clk_main_a0),
        .i_rst_main_n          (rst_main_n_sync),
        .i_clk_hbm_ref         (1'b0),
        .s_axil_ctrl_awvalid   (1'b0),
        .s_axil_ctrl_wvalid    (1'b0),
        .s_axil_ctrl_bready    (1'b0),
        .s_axil_ctrl_arvalid   (1'b0),
        .s_axil_ctrl_rready    (1'b0),
        .s_axil_ctrl_awaddr    (32'h0),
        .s_axil_ctrl_wdata     (32'h0),
        .s_axil_ctrl_wstrb     (4'h0),
        .s_axil_ctrl_araddr    (32'h0),
        .o_clk_main_a0         (gen_clk_main_a0),
        .o_clk_extra_a1        (gen_clk_extra_a1),
        .o_clk_extra_a2        (gen_clk_extra_a2),
        .o_clk_extra_a3        (gen_clk_extra_a3),
        .o_cl_rst_a1_n         (gen_rst_a1_n),
        .o_cl_rst_a2_n         (gen_rst_a2_n),
        .o_cl_rst_a3_n         (gen_rst_a3_n),
        .o_cl_rst_main_n       (gen_rst_main_n)
    );

    // =========================================================================
    // AXI CDC for OCL (AXI-Lite)
    // =========================================================================
    logic        slv_ocl_awvalid, slv_ocl_awready;
    logic [31:0] slv_ocl_awaddr;
    logic        slv_ocl_wvalid,  slv_ocl_wready;
    logic [31:0] slv_ocl_wdata;
    logic [3:0]  slv_ocl_wstrb;
    logic [1:0]  slv_ocl_bresp;
    logic        slv_ocl_bvalid,  slv_ocl_bready;
    logic        slv_ocl_arvalid, slv_ocl_arready;
    logic [31:0] slv_ocl_araddr;
    logic [31:0] slv_ocl_rdata;
    logic [1:0]  slv_ocl_rresp;
    logic        slv_ocl_rvalid,  slv_ocl_rready;

    cl_axi_clock_converter_light OCL_CDC (
        .s_axi_aclk    (clk_main_a0),
        .s_axi_aresetn (rst_main_n_sync),
        .s_axi_awaddr  (ocl_cl_awaddr),
        .s_axi_awprot  (3'h0),
        .s_axi_awvalid (ocl_cl_awvalid),
        .s_axi_awready (cl_ocl_awready),
        .s_axi_wdata   (ocl_cl_wdata),
        .s_axi_wstrb   (ocl_cl_wstrb),
        .s_axi_wvalid  (ocl_cl_wvalid),
        .s_axi_wready  (cl_ocl_wready),
        .s_axi_bresp   (cl_ocl_bresp),
        .s_axi_bvalid  (cl_ocl_bvalid),
        .s_axi_bready  (ocl_cl_bready),
        .s_axi_araddr  (ocl_cl_araddr),
        .s_axi_arprot  (3'h0),
        .s_axi_arvalid (ocl_cl_arvalid),
        .s_axi_arready (cl_ocl_arready),
        .s_axi_rdata   (cl_ocl_rdata),
        .s_axi_rresp   (cl_ocl_rresp),
        .s_axi_rvalid  (cl_ocl_rvalid),
        .s_axi_rready  (ocl_cl_rready),

        .m_axi_aclk    (gen_clk_extra_a1),
        .m_axi_aresetn (gen_rst_a1_n),
        .m_axi_awaddr  (slv_ocl_awaddr),
        .m_axi_awprot  (),
        .m_axi_awvalid (slv_ocl_awvalid),
        .m_axi_awready (slv_ocl_awready),
        .m_axi_wdata   (slv_ocl_wdata),
        .m_axi_wstrb   () /*slv_ocl_wstrb*/,
        .m_axi_wvalid  (slv_ocl_wvalid),
        .m_axi_wready  (slv_ocl_wready),
        .m_axi_bresp   (slv_ocl_bresp),
        .m_axi_bvalid  (slv_ocl_bvalid),
        .m_axi_bready  (slv_ocl_bready),
        .m_axi_araddr  (slv_ocl_araddr),
        .m_axi_arprot  (),
        .m_axi_arvalid (slv_ocl_arvalid),
        .m_axi_arready (slv_ocl_arready),
        .m_axi_rdata   (slv_ocl_rdata),
        .m_axi_rresp   (slv_ocl_rresp),
        .m_axi_rvalid  (slv_ocl_rvalid),
        .m_axi_rready  (slv_ocl_rready)
    );

    // =========================================================================
    // AXI CDC for PCIS (512-bit)
    // =========================================================================
    logic        slv_pcis_awvalid, slv_pcis_awready;
    logic [63:0] slv_pcis_awaddr;
    logic [15:0] slv_pcis_awid;
    logic [7:0]  slv_pcis_awlen;
    logic        slv_pcis_wvalid,  slv_pcis_wready, slv_pcis_wlast;
    logic [511:0] slv_pcis_wdata;
    logic [63:0] slv_pcis_wstrb;
    logic [15:0] slv_pcis_bid;
    logic [1:0]  slv_pcis_bresp;
    logic        slv_pcis_bvalid,  slv_pcis_bready;

    cl_axi_clock_converter PCIS_CDC (
        .s_axi_aclk    (clk_main_a0),
        .s_axi_aresetn (rst_main_n_sync),
        .s_axi_awid    (sh_cl_dma_pcis_awid),
        .s_axi_awaddr  (sh_cl_dma_pcis_awaddr),
        .s_axi_awlen   (sh_cl_dma_pcis_awlen),
        .s_axi_awsize  (sh_cl_dma_pcis_awsize),
        .s_axi_awburst (2'h1),
        .s_axi_awlock  (1'b0),
        .s_axi_awcache (4'h0),
        .s_axi_awprot  (3'h0),
        .s_axi_awregion(4'h0),
        .s_axi_awqos   (4'h0),
        .s_axi_awuser  (19'h0),
        .s_axi_awvalid (sh_cl_dma_pcis_awvalid),
        .s_axi_awready (cl_sh_dma_pcis_awready),
        .s_axi_wdata   (sh_cl_dma_pcis_wdata),
        .s_axi_wstrb   (sh_cl_dma_pcis_wstrb),
        .s_axi_wlast   (sh_cl_dma_pcis_wlast),
        .s_axi_wvalid  (sh_cl_dma_pcis_wvalid),
        .s_axi_wready  (cl_sh_dma_pcis_wready),
        .s_axi_bid     (cl_sh_dma_pcis_bid),
        .s_axi_bresp   (cl_sh_dma_pcis_bresp),
        .s_axi_bvalid  (cl_sh_dma_pcis_bvalid),
        .s_axi_bready  (sh_cl_dma_pcis_bready),
        .s_axi_arid    (sh_cl_dma_pcis_arid),
        .s_axi_araddr  (sh_cl_dma_pcis_araddr),
        .s_axi_arlen   (sh_cl_dma_pcis_arlen),
        .s_axi_arsize  (sh_cl_dma_pcis_arsize),
        .s_axi_arburst (2'h1),
        .s_axi_arlock  (1'b0),
        .s_axi_arcache (4'h0),
        .s_axi_arprot  (3'h0),
        .s_axi_arregion(4'h0),
        .s_axi_arqos   (4'h0),
        .s_axi_aruser  (19'h0),
        .s_axi_arvalid (sh_cl_dma_pcis_arvalid),
        .s_axi_arready (cl_sh_dma_pcis_arready),
        .s_axi_rid     (cl_sh_dma_pcis_rid),
        .s_axi_rdata   (cl_sh_dma_pcis_rdata),
        .s_axi_rresp   (cl_sh_dma_pcis_rresp),
        .s_axi_rlast   (cl_sh_dma_pcis_rlast),
        .s_axi_rvalid  (cl_sh_dma_pcis_rvalid),
        .s_axi_rready  (sh_cl_dma_pcis_rready),

        .m_axi_aclk    (gen_clk_extra_a1),
        .m_axi_aresetn (gen_rst_a1_n),
        .m_axi_awid    (slv_pcis_awid),
        .m_axi_awaddr  (slv_pcis_awaddr),
        .m_axi_awlen   (slv_pcis_awlen),
        .m_axi_awsize  (),
        .m_axi_awburst (),
        .m_axi_awlock  (),
        .m_axi_awcache (),
        .m_axi_awprot  (),
        .m_axi_awregion(),
        .m_axi_awqos   (),
        .m_axi_awuser  (),
        .m_axi_awvalid (slv_pcis_awvalid),
        .m_axi_awready (slv_pcis_awready),
        .m_axi_wdata   (slv_pcis_wdata),
        .m_axi_wstrb   () /*slv_pcis_wstrb*/,
        .m_axi_wlast   (slv_pcis_wlast),
        .m_axi_wvalid  (slv_pcis_wvalid),
        .m_axi_wready  (slv_pcis_wready),
        .m_axi_bid     (slv_pcis_bid),
        .m_axi_bresp   (slv_pcis_bresp),
        .m_axi_bvalid  (slv_pcis_bvalid),
        .m_axi_bready  (slv_pcis_bready),
        .m_axi_arid    (),
        .m_axi_araddr  (),
        .m_axi_arlen   (),
        .m_axi_arsize  (),
        .m_axi_arburst (),
        .m_axi_arlock  (),
        .m_axi_arcache (),
        .m_axi_arprot  (),
        .m_axi_arregion(),
        .m_axi_arqos   (),
        .m_axi_aruser  (),
        .m_axi_arvalid (),
        .m_axi_arready (1'b0),
        .m_axi_rid     (),
        .m_axi_rdata   (),
        .m_axi_rresp   (),
        .m_axi_rlast   (),
        .m_axi_rvalid  (),
        .m_axi_rready  (1'b1)
    );

    // =========================================================================
    // AXI CDC for DDR
    // =========================================================================
    logic        m_ddr_axi_awvalid, m_ddr_axi_awready;
    logic [63:0] m_ddr_axi_awaddr;
    logic [15:0] m_ddr_axi_awid;
    logic [7:0]  m_ddr_axi_awlen;
    logic [2:0]  m_ddr_axi_awsize;
    logic [1:0]  m_ddr_axi_awburst;
    logic         m_ddr_axi_wvalid, m_ddr_axi_wready;
    logic [511:0] m_ddr_axi_wdata;
    logic [63:0]  m_ddr_axi_wstrb;
    logic         m_ddr_axi_wlast;
    logic [15:0] m_ddr_axi_bid;
    logic [1:0]  m_ddr_axi_bresp;
    logic        m_ddr_axi_bvalid, m_ddr_axi_bready;
    logic        m_ddr_axi_arvalid, m_ddr_axi_arready;
    logic [63:0] m_ddr_axi_araddr;
    logic [15:0] m_ddr_axi_arid;
    logic [7:0]  m_ddr_axi_arlen;
    logic [2:0]  m_ddr_axi_arsize;
    logic [1:0]  m_ddr_axi_arburst;
    logic [15:0]  m_ddr_axi_rid;
    logic [511:0] m_ddr_axi_rdata;
    logic [1:0]   m_ddr_axi_rresp;
    logic         m_ddr_axi_rlast;
    logic         m_ddr_axi_rvalid, m_ddr_axi_rready;

    cl_axi_clock_converter DDR_CDC (
        .s_axi_aclk    (gen_clk_extra_a1),
        .s_axi_aresetn (gen_rst_a1_n),
        .s_axi_awid    (m_ddr_axi_awid),
        .s_axi_awaddr  (m_ddr_axi_awaddr),
        .s_axi_awlen   (m_ddr_axi_awlen),
        .s_axi_awsize  (m_ddr_axi_awsize),
        .s_axi_awburst (m_ddr_axi_awburst),
        .s_axi_awlock  (1'b0),
        .s_axi_awcache (4'h0),
        .s_axi_awprot  (3'h0),
        .s_axi_awregion(4'h0),
        .s_axi_awqos   (4'h0),
        .s_axi_awuser  (19'h0),
        .s_axi_awvalid (m_ddr_axi_awvalid),
        .s_axi_awready (m_ddr_axi_awready),
        .s_axi_wdata   (m_ddr_axi_wdata),
        .s_axi_wstrb   (m_ddr_axi_wstrb),
        .s_axi_wlast   (m_ddr_axi_wlast),
        .s_axi_wvalid  (m_ddr_axi_wvalid),
        .s_axi_wready  (m_ddr_axi_wready),
        .s_axi_bid     (m_ddr_axi_bid),
        .s_axi_bresp   (m_ddr_axi_bresp),
        .s_axi_bvalid  (m_ddr_axi_bvalid),
        .s_axi_bready  (m_ddr_axi_bready),
        .s_axi_arid    (m_ddr_axi_arid),
        .s_axi_araddr  (m_ddr_axi_araddr),
        .s_axi_arlen   (m_ddr_axi_arlen),
        .s_axi_arsize  (m_ddr_axi_arsize),
        .s_axi_arburst (m_ddr_axi_arburst),
        .s_axi_arlock  (1'b0),
        .s_axi_arcache (4'h0),
        .s_axi_arprot  (3'h0),
        .s_axi_arregion(4'h0),
        .s_axi_arqos   (4'h0),
        .s_axi_aruser  (19'h0),
        .s_axi_arvalid (m_ddr_axi_arvalid),
        .s_axi_arready (m_ddr_axi_arready),
        .s_axi_rid     (m_ddr_axi_rid),
        .s_axi_rdata   (m_ddr_axi_rdata),
        .s_axi_rresp   (m_ddr_axi_rresp),
        .s_axi_rlast   (m_ddr_axi_rlast),
        .s_axi_rvalid  (m_ddr_axi_rvalid),
        .s_axi_rready  (m_ddr_axi_rready),

        .m_axi_aclk    (clk_main_a0),
        .m_axi_aresetn (rst_main_n_sync),
        .m_axi_awid    (ddr_axi_awid),
        .m_axi_awaddr  (ddr_axi_awaddr),
        .m_axi_awlen   (ddr_axi_awlen),
        .m_axi_awsize  (ddr_axi_awsize),
        .m_axi_awburst (ddr_axi_awburst),
        .m_axi_awlock  (),
        .m_axi_awcache (),
        .m_axi_awprot  (),
        .m_axi_awregion(),
        .m_axi_awqos   (),
        .m_axi_awuser  (),
        .m_axi_awvalid (ddr_axi_awvalid),
        .m_axi_awready (ddr_axi_awready),
        .m_axi_wdata   (ddr_axi_wdata),
        .m_axi_wstrb   (ddr_axi_wstrb),
        .m_axi_wlast   (ddr_axi_wlast),
        .m_axi_wvalid  (ddr_axi_wvalid),
        .m_axi_wready  (ddr_axi_wready),
        .m_axi_bid     (ddr_axi_bid),
        .m_axi_bresp   (ddr_axi_bresp),
        .m_axi_bvalid  (ddr_axi_bvalid),
        .m_axi_bready  (ddr_axi_bready),
        .m_axi_arid    (ddr_axi_arid),
        .m_axi_araddr  (ddr_axi_araddr),
        .m_axi_arlen   (ddr_axi_arlen),
        .m_axi_arsize  (ddr_axi_arsize),
        .m_axi_arburst (ddr_axi_arburst),
        .m_axi_arlock  (),
        .m_axi_arcache (),
        .m_axi_arprot  (),
        .m_axi_arregion(),
        .m_axi_arqos   (),
        .m_axi_aruser  (),
        .m_axi_arvalid (ddr_axi_arvalid),
        .m_axi_arready (ddr_axi_arready),
        .m_axi_rid     (ddr_axi_rid),
        .m_axi_rdata   (ddr_axi_rdata),
        .m_axi_rresp   (ddr_axi_rresp),
        .m_axi_rlast   (ddr_axi_rlast),
        .m_axi_rvalid  (ddr_axi_rvalid),
        .m_axi_rready  (ddr_axi_rready)
    );

    // OCL AXI-Lite (AppPF BAR0) -- Simplified AXI-Lite
    // =========================================================================

    // Write Channel
    logic ocl_wr_pending;
    logic [31:0] ocl_wr_addr_q;
    logic [31:0] ocl_wr_data_q;

    always_ff @(posedge gen_clk_extra_a1) begin
        if (!gen_rst_a1_n) begin
            ocl_wr_pending   <= 1'b0;
            axil_wr_valid    <= 1'b0;
            ocl_wr_addr_q    <= 32'h0;
            ocl_wr_data_q    <= 32'h0;
        end else begin
            axil_wr_valid <= 1'b0;
            if (slv_ocl_awvalid && slv_ocl_awready && slv_ocl_wvalid && slv_ocl_wready) begin
                axil_wr_valid <= 1'b1;
                axil_wr_addr  <= slv_ocl_awaddr;
                axil_wr_data  <= slv_ocl_wdata;
            end else if (slv_ocl_awvalid && slv_ocl_awready) begin
                ocl_wr_addr_q  <= slv_ocl_awaddr;
                ocl_wr_pending <= 1'b1;
            end
            if (ocl_wr_pending && slv_ocl_wvalid && slv_ocl_wready) begin
                axil_wr_valid  <= 1'b1;
                axil_wr_addr   <= ocl_wr_addr_q;
                axil_wr_data   <= slv_ocl_wdata;
                ocl_wr_pending <= 1'b0;
            end
        end
    end

    assign slv_ocl_awready = gen_rst_a1_n;
    assign slv_ocl_wready  = gen_rst_a1_n;

    // B channel
    logic ocl_bvalid_q;
    always_ff @(posedge gen_clk_extra_a1) begin
        if (!gen_rst_a1_n)
            ocl_bvalid_q <= 1'b0;
        else if (axil_wr_valid)
            ocl_bvalid_q <= 1'b1;
        else if (slv_ocl_bready)
            ocl_bvalid_q <= 1'b0;
    end
    assign slv_ocl_bvalid = ocl_bvalid_q;
    assign slv_ocl_bresp  = 2'b00;

    // Read Channel
    always_ff @(posedge gen_clk_extra_a1) begin
        if (!gen_rst_a1_n) begin
            axil_rd_valid <= 1'b0;
            axil_rd_addr  <= 32'h0;
        end else begin
            axil_rd_valid <= 1'b0;
            if (slv_ocl_arvalid && slv_ocl_arready) begin
                axil_rd_valid <= 1'b1;
                axil_rd_addr  <= slv_ocl_araddr;
            end
        end
    end

    logic ocl_rd_pending;
    assign slv_ocl_arready = gen_rst_a1_n && !ocl_rd_pending;

    logic ocl_rvalid_q;
    logic [31:0] ocl_rdata_q;
    always_ff @(posedge gen_clk_extra_a1) begin
        if (!gen_rst_a1_n) begin
            ocl_rvalid_q   <= 1'b0;
            ocl_rdata_q    <= 32'h0;
            ocl_rd_pending <= 1'b0;
        end else begin
            if (axil_rd_valid && axil_rd_ready) begin
                ocl_rvalid_q   <= 1'b1;
                ocl_rdata_q    <= axil_rd_data;
                ocl_rd_pending <= 1'b0;
            end else if (slv_ocl_rready) begin
                ocl_rvalid_q <= 1'b0;
            end
            if (slv_ocl_arvalid && slv_ocl_arready)
                ocl_rd_pending <= 1'b1;
        end
    end
    assign slv_ocl_rvalid = ocl_rvalid_q;
    assign slv_ocl_rdata  = ocl_rdata_q;
    assign slv_ocl_rresp  = 2'b00;

    // =========================================================================
    // DMA PCIS AXI4 (512-bit) -- Simplified 32-bit Literal Load
    // =========================================================================

    logic        pcis_aw_pending;
    logic [63:0] pcis_aw_addr_q;
    logic [7:0]  pcis_aw_len_q;

    assign slv_pcis_awready = gen_rst_a1_n && !pcis_aw_pending;

    always_ff @(posedge gen_clk_extra_a1) begin
        if (!gen_rst_a1_n) begin
            pcis_aw_pending <= 1'b0;
            pcis_aw_addr_q  <= 64'h0;
            pcis_aw_len_q   <= 8'h0;
        end else begin
            if (slv_pcis_awvalid && slv_pcis_awready) begin
                pcis_aw_pending <= 1'b1;
                pcis_aw_addr_q  <= slv_pcis_awaddr;
                pcis_aw_len_q   <= slv_pcis_awlen;
            end
            if (pcis_aw_pending && slv_pcis_wvalid && slv_pcis_wready && slv_pcis_wlast)
                pcis_aw_pending <= 1'b0;
        end
    end

    assign slv_pcis_wready = gen_rst_a1_n && pcis_aw_pending && pcis_wr_ready;

    always_ff @(posedge gen_clk_extra_a1) begin
        if (!gen_rst_a1_n) begin
            pcis_wr_valid <= 1'b0;
            pcis_wr_data  <= 32'h0;
            pcis_wr_addr  <= 32'h0;
        end else begin
            pcis_wr_valid <= 1'b0;
            if (slv_pcis_wvalid && slv_pcis_wready) begin
                pcis_wr_valid <= 1'b1;
                pcis_wr_data  <= slv_pcis_wdata[31:0];
                pcis_wr_addr  <= pcis_aw_addr_q[31:0];
            end
        end
    end

    // PCIS B response
    logic pcis_bvalid_q;
    logic [15:0] pcis_bid_q;
    always_ff @(posedge gen_clk_extra_a1) begin
        if (!gen_rst_a1_n) begin
            pcis_bvalid_q <= 1'b0;
            pcis_bid_q    <= 16'h0;
        end else begin
            if (slv_pcis_wvalid && slv_pcis_wready && slv_pcis_wlast) begin
                pcis_bvalid_q <= 1'b1;
                pcis_bid_q    <= slv_pcis_awid;
            end else if (slv_pcis_bready) begin
                pcis_bvalid_q <= 1'b0;
            end
        end
    end
    assign slv_pcis_bvalid = pcis_bvalid_q;
    assign slv_pcis_bresp  = 2'b00;
    assign slv_pcis_bid    = pcis_bid_q;

    // PCIS read channels: tied off (write-only)
    assign slv_pcis_arready = 1'b0;
    assign slv_pcis_rvalid  = 1'b0;
    assign slv_pcis_rdata   = 512'h0;
    assign slv_pcis_rresp   = 2'b00;
    assign slv_pcis_rlast   = 1'b0;
    assign slv_pcis_rid     = 16'h0;
    assign slv_pcis_ruser   = 64'h0;

    // =========================================================================
    // DDR4 via sh_ddr -- Bridge solver simple DDR interface to AXI4
    // =========================================================================
    logic        m_ddr_axi_awvalid, m_ddr_axi_awready;
    logic [63:0] m_ddr_axi_awaddr;
    logic [15:0] m_ddr_axi_awid;
    logic [7:0]  m_ddr_axi_awlen;
    logic [2:0]  m_ddr_axi_awsize;
    logic [1:0]  m_ddr_axi_awburst;
    logic        m_ddr_axi_awuser;

    logic         m_ddr_axi_wvalid, m_ddr_axi_wready;
    logic [511:0] m_ddr_axi_wdata;
    logic [63:0]  m_ddr_axi_wstrb;
    logic         m_ddr_axi_wlast;

    logic [15:0] m_ddr_axi_bid;
    logic [1:0]  m_ddr_axi_bresp;
    logic        m_ddr_axi_bvalid, m_ddr_axi_bready;

    logic        m_ddr_axi_arvalid, m_ddr_axi_arready;
    logic [63:0] m_ddr_axi_araddr;
    logic [15:0] m_ddr_axi_arid;
    logic [7:0]  m_ddr_axi_arlen;
    logic [2:0]  m_ddr_axi_arsize;
    logic [1:0]  m_ddr_axi_arburst;
    logic        m_ddr_axi_aruser;

    logic [15:0]  m_ddr_axi_rid;
    logic [511:0] m_ddr_axi_rdata;
    logic [1:0]   m_ddr_axi_rresp;
    logic         m_ddr_axi_rlast;
    logic         m_ddr_axi_rvalid, m_ddr_axi_rready;

    logic         ddr_is_ready;

    // DDR AXI4 bridge FSM
    typedef enum logic [2:0] {
        DDR_IDLE,
        DDR_RD_ADDR,
        DDR_RD_DATA,
        DDR_WR_ADDR,
        DDR_WR_DATA,
        DDR_WR_RESP
    } ddr_state_t;

    ddr_state_t ddr_state;
    logic [31:0] ddr_rd_addr_q;
    logic [7:0]  ddr_rd_len_q;
    logic [7:0]  ddr_rd_cnt;

    always_ff @(posedge gen_clk_extra_a1) begin
        if (!gen_rst_a1_n) begin
            ddr_state       <= DDR_IDLE;
            ddr_read_grant  <= 1'b0;
            ddr_read_valid  <= 1'b0;
            ddr_read_data   <= 32'h0;
            ddr_write_grant <= 1'b0;
            ddr_rd_addr_q   <= 32'h0;
            ddr_rd_len_q    <= 8'h0;
            ddr_rd_cnt      <= 8'h0;
        end else begin
            ddr_read_grant  <= 1'b0;
            ddr_read_valid  <= 1'b0;
            ddr_write_grant <= 1'b0;

            case (ddr_state)
                DDR_IDLE: begin
                    if (ddr_read_req) begin
                        ddr_state      <= DDR_RD_ADDR;
                        ddr_rd_addr_q  <= ddr_read_addr;
                        ddr_rd_len_q   <= ddr_read_len;
                        ddr_rd_cnt     <= 8'h0;
                        ddr_read_grant <= 1'b1;
                    end else if (ddr_write_req) begin
                        ddr_state       <= DDR_WR_ADDR;
                        ddr_write_grant <= 1'b1;
                    end
                end

                DDR_RD_ADDR: begin
                    if (m_ddr_axi_arready)
                        ddr_state <= DDR_RD_DATA;
                end

                DDR_RD_DATA: begin
                    if (m_ddr_axi_rvalid && m_ddr_axi_rready) begin
                        ddr_read_valid <= 1'b1;
                        ddr_read_data  <= m_ddr_axi_rdata[31:0];
                        ddr_rd_cnt     <= ddr_rd_cnt + 1;
                        if (m_ddr_axi_rlast || (ddr_rd_cnt >= ddr_rd_len_q))
                            ddr_state <= DDR_IDLE;
                    end
                end

                DDR_WR_ADDR: begin
                    if (m_ddr_axi_awready)
                        ddr_state <= DDR_WR_DATA;
                end

                DDR_WR_DATA: begin
                    if (m_ddr_axi_wready)
                        ddr_state <= DDR_WR_RESP;
                end

                DDR_WR_RESP: begin
                    if (m_ddr_axi_bvalid)
                        ddr_state <= DDR_IDLE;
                end

                default: ddr_state <= DDR_IDLE;
            endcase
        end
    end

    assign m_ddr_axi_arvalid = (ddr_state == DDR_RD_ADDR);
    assign m_ddr_axi_araddr  = {32'h0, ddr_rd_addr_q};
    assign m_ddr_axi_arlen   = ddr_rd_len_q;
    assign m_ddr_axi_arsize  = 3'b010;
    assign m_ddr_axi_arburst = 2'b01;
    assign m_ddr_axi_arid    = 16'h0;
    assign m_ddr_axi_aruser  = 1'b0;
    assign m_ddr_axi_rready  = (ddr_state == DDR_RD_DATA);

    assign m_ddr_axi_awvalid = (ddr_state == DDR_WR_ADDR);
    assign m_ddr_axi_awaddr  = {32'h0, ddr_write_addr};
    assign m_ddr_axi_awlen   = 8'h0;
    assign m_ddr_axi_awsize  = 3'b010;
    assign m_ddr_axi_awburst = 2'b01;
    assign m_ddr_axi_awid    = 16'h0;
    assign m_ddr_axi_awuser  = 1'b0;

    assign m_ddr_axi_wvalid  = (ddr_state == DDR_WR_DATA);
    assign m_ddr_axi_wdata   = {480'h0, ddr_write_data};
    assign m_ddr_axi_wstrb   = 64'h000000000000000F;
    assign m_ddr_axi_wlast   = 1'b1;
    assign m_ddr_axi_bready  = (ddr_state == DDR_WR_RESP);

    // =========================================================================
    // sh_ddr instantiation
    // =========================================================================
    sh_ddr #(
        // DDR_PRESENT=0: DDR4 IP excluded to reduce Technology Mapping memory.
        // The solver uses on-chip BRAM (lit_mem) and never drives global_read_req/
        // global_write_req, so DDR is functionally unused. Restore to 1 when
        // migrating to VeriSAT-style external literal storage (see HANDOFF §5).
        .DDR_PRESENT(0)
    ) SH_DDR (
        .clk                       (clk_main_a0),
        .rst_n                     (rst_main_n_sync),
        .stat_clk                  (clk_main_a0),
        .stat_rst_n                (rst_main_n_sync),

        .CLK_DIMM_DP               (CLK_DIMM_DP),
        .CLK_DIMM_DN               (CLK_DIMM_DN),
        .M_ACT_N                   (M_ACT_N),
        .M_MA                      (M_MA),
        .M_BA                      (M_BA),
        .M_BG                      (M_BG),
        .M_CKE                     (M_CKE),
        .M_ODT                     (M_ODT),
        .M_CS_N                    (M_CS_N),
        .M_CLK_DN                  (M_CLK_DN),
        .M_CLK_DP                  (M_CLK_DP),
        .M_PAR                     (M_PAR),
        .M_DQ                      (M_DQ),
        .M_ECC                     (M_ECC),
        .M_DQS_DP                  (M_DQS_DP),
        .M_DQS_DN                  (M_DQS_DN),
        .cl_RST_DIMM_N             (RST_DIMM_N),

        .cl_sh_ddr_axi_awid        (ddr_axi_awid),
        .cl_sh_ddr_axi_awaddr      (ddr_axi_awaddr),
        .cl_sh_ddr_axi_awlen       (ddr_axi_awlen),
        .cl_sh_ddr_axi_awsize      (ddr_axi_awsize),
        .cl_sh_ddr_axi_awvalid     (ddr_axi_awvalid),
        .cl_sh_ddr_axi_awburst     (ddr_axi_awburst),
        .cl_sh_ddr_axi_awuser      (ddr_axi_awuser),
        .cl_sh_ddr_axi_awready     (ddr_axi_awready),

        .cl_sh_ddr_axi_wdata       (ddr_axi_wdata),
        .cl_sh_ddr_axi_wstrb       (ddr_axi_wstrb),
        .cl_sh_ddr_axi_wlast       (ddr_axi_wlast),
        .cl_sh_ddr_axi_wvalid      (ddr_axi_wvalid),
        .cl_sh_ddr_axi_wready      (ddr_axi_wready),

        .cl_sh_ddr_axi_bid         (ddr_axi_bid),
        .cl_sh_ddr_axi_bresp       (ddr_axi_bresp),
        .cl_sh_ddr_axi_bvalid      (ddr_axi_bvalid),
        .cl_sh_ddr_axi_bready      (ddr_axi_bready),

        .cl_sh_ddr_axi_arid        (ddr_axi_arid),
        .cl_sh_ddr_axi_araddr      (ddr_axi_araddr),
        .cl_sh_ddr_axi_arlen       (ddr_axi_arlen),
        .cl_sh_ddr_axi_arsize      (ddr_axi_arsize),
        .cl_sh_ddr_axi_arvalid     (ddr_axi_arvalid),
        .cl_sh_ddr_axi_arburst     (ddr_axi_arburst),
        .cl_sh_ddr_axi_aruser      (ddr_axi_aruser),
        .cl_sh_ddr_axi_arready     (ddr_axi_arready),

        .cl_sh_ddr_axi_rid         (ddr_axi_rid),
        .cl_sh_ddr_axi_rdata       (ddr_axi_rdata),
        .cl_sh_ddr_axi_rresp       (ddr_axi_rresp),
        .cl_sh_ddr_axi_rlast       (ddr_axi_rlast),
        .cl_sh_ddr_axi_rvalid      (ddr_axi_rvalid),
        .cl_sh_ddr_axi_rready      (ddr_axi_rready),

        .sh_ddr_stat_bus_addr      (sh_cl_ddr_stat_addr),
        .sh_ddr_stat_bus_wdata     (sh_cl_ddr_stat_wdata),
        .sh_ddr_stat_bus_wr        (sh_cl_ddr_stat_wr),
        .sh_ddr_stat_bus_rd        (sh_cl_ddr_stat_rd),
        .sh_ddr_stat_bus_ack       (cl_sh_ddr_stat_ack),
        .sh_ddr_stat_bus_rdata     (cl_sh_ddr_stat_rdata),

        .ddr_sh_stat_int           (cl_sh_ddr_stat_int),
        .sh_cl_ddr_is_ready        (ddr_is_ready)
    );

    // =========================================================================
    // PCIM -- tied off (CL does not master PCIe transactions)
    // =========================================================================
    always_comb begin
        cl_sh_pcim_awid    = 'b0;
        cl_sh_pcim_awaddr  = 'b0;
        cl_sh_pcim_awlen   = 'b0;
        cl_sh_pcim_awsize  = 'b0;
        cl_sh_pcim_awburst = 'b0;
        cl_sh_pcim_awcache = 'b0;
        cl_sh_pcim_awlock  = 'b0;
        cl_sh_pcim_awprot  = 'b0;
        cl_sh_pcim_awqos   = 'b0;
        cl_sh_pcim_awuser  = 'b0;
        cl_sh_pcim_awvalid = 'b0;

        cl_sh_pcim_wid     = 'b0;
        cl_sh_pcim_wdata   = 'b0;
        cl_sh_pcim_wstrb   = 'b0;
        cl_sh_pcim_wlast   = 'b0;
        cl_sh_pcim_wuser   = 'b0;
        cl_sh_pcim_wvalid  = 'b0;

        cl_sh_pcim_bready  = 1'b1;

        cl_sh_pcim_arid    = 'b0;
        cl_sh_pcim_araddr  = 'b0;
        cl_sh_pcim_arlen   = 'b0;
        cl_sh_pcim_arsize  = 'b0;
        cl_sh_pcim_arburst = 'b0;
        cl_sh_pcim_arcache = 'b0;
        cl_sh_pcim_arlock  = 'b0;
        cl_sh_pcim_arprot  = 'b0;
        cl_sh_pcim_arqos   = 'b0;
        cl_sh_pcim_aruser  = 'b0;
        cl_sh_pcim_arvalid = 'b0;

        cl_sh_pcim_rready  = 'b0;
    end

    // =========================================================================
    // SDA AXI-Lite (MgmtPF BAR4) -- tied off
    // =========================================================================
    always_comb begin
        cl_sda_awready = 1'b1;
        cl_sda_wready  = 1'b1;
        cl_sda_bvalid  = 1'b0;
        cl_sda_bresp   = 2'b00;
        cl_sda_arready = 1'b1;
        cl_sda_rvalid  = 1'b0;
        cl_sda_rdata   = 32'h0;
        cl_sda_rresp   = 2'b00;
    end

    // =========================================================================
    // Virtual LED / DIP
    // =========================================================================
    wire solver_done, solver_sat, solver_unsat;
    assign cl_sh_status_vled = {13'b0, solver_unsat, solver_sat, solver_done};

    // =========================================================================
    // Interrupts -- tied off
    // =========================================================================
    always_comb begin
        cl_sh_apppf_irq_req = 16'h0;
    end

    // =========================================================================
    // Virtual JTAG -- tied off
    // =========================================================================
    always_comb begin
        tdo = 1'b0;
    end

    // =========================================================================
    // HBM Monitor IO -- tied off
    // =========================================================================
    always_comb begin
        hbm_apb_paddr_1   = 'b0;
        hbm_apb_pprot_1   = 'b0;
        hbm_apb_psel_1    = 'b0;
        hbm_apb_penable_1 = 'b0;
        hbm_apb_pwrite_1  = 'b0;
        hbm_apb_pwdata_1  = 'b0;
        hbm_apb_pstrb_1   = 'b0;
        hbm_apb_pready_1  = 'b0;
        hbm_apb_prdata_1  = 'b0;
        hbm_apb_pslverr_1 = 'b0;

        hbm_apb_paddr_0   = 'b0;
        hbm_apb_pprot_0   = 'b0;
        hbm_apb_psel_0    = 'b0;
        hbm_apb_penable_0 = 'b0;
        hbm_apb_pwrite_0  = 'b0;
        hbm_apb_pwdata_0  = 'b0;
        hbm_apb_pstrb_0   = 'b0;
        hbm_apb_pready_0  = 'b0;
        hbm_apb_prdata_0  = 'b0;
        hbm_apb_pslverr_0 = 'b0;
    end

    // =========================================================================
    // PCIe EP/RP -- tied off
    // =========================================================================
    always_comb begin
        PCIE_EP_TXP    = 'b0;
        PCIE_EP_TXN    = 'b0;

        PCIE_RP_PERSTN = 'b0;
        PCIE_RP_TXP    = 'b0;
        PCIE_RP_TXN    = 'b0;
    end

    // =========================================================================
    // Instantiate satswarm_core_bridge
    // =========================================================================
    satswarm_core_bridge #(
        .GRID_X             (GRID_X),
        .GRID_Y             (GRID_Y),
        .MAX_VARS_PER_CORE  (MAX_VARS_PER_CORE),
        .MAX_CLAUSES_PER_CORE(MAX_CLAUSES_PER_CORE),
        .MAX_LITS           (MAX_LITS)
    ) u_core_bridge (
        .clk             (gen_clk_extra_a1),
        .rst_n_in        (gen_rst_a1_n),

        .axil_wr_valid   (axil_wr_valid),
        .axil_wr_addr    (axil_wr_addr),
        .axil_wr_data    (axil_wr_data),
        .axil_wr_ready   (axil_wr_ready),
        .axil_rd_valid   (axil_rd_valid),
        .axil_rd_addr    (axil_rd_addr),
        .axil_rd_data    (axil_rd_data),
        .axil_rd_ready   (axil_rd_ready),

        .pcis_wr_valid   (pcis_wr_valid),
        .pcis_wr_addr    (pcis_wr_addr),
        .pcis_wr_data    (pcis_wr_data),
        .pcis_wr_ready   (pcis_wr_ready),

        .ddr_read_req    (ddr_read_req),
        .ddr_read_addr   (ddr_read_addr),
        .ddr_read_len    (ddr_read_len),
        .ddr_read_grant  (ddr_read_grant),
        .ddr_read_data   (ddr_read_data),
        .ddr_read_valid  (ddr_read_valid),
        .ddr_write_req   (ddr_write_req),
        .ddr_write_addr  (ddr_write_addr),
        .ddr_write_data  (ddr_write_data),
        .ddr_write_grant (ddr_write_grant)
    );

    assign solver_done  = axil_rd_data[0];
    assign solver_sat   = axil_rd_data[1];
    assign solver_unsat = axil_rd_data[2];

endmodule
