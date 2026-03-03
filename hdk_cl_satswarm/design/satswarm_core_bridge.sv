// satswarm_core_bridge.sv — Bridge between AWS shell interface and SatSwarm core
// Maps AXI-Lite (control), AXI4-PCIS (DMA CNF load), and DDR4 (PCIM) 
// interfaces to the satswarm_top native ports.
//
// Register Map (AXI-Lite, OCL BAR):
//   0x00 (W): bit[0] = host_start (auto-clears)
//   0x00 (R): {29'b0, host_unsat, host_sat, host_done}
//   0x04 (R): cycle_counter[31:0]
//   0x08 (R): version = 32'h53415431 ("SAT1")
//   0x0C (W): soft_reset (bit[0] = 1 to reset)
//
// DMA CNF Load (AXI4-PCIS writes):
//   Address 0x1000: write literal (host_load_literal), clause_end = 0
//   Address 0x1004: write literal (host_load_literal), clause_end = 1

`timescale 1ns/1ps

module satswarm_core_bridge #(
    parameter int GRID_X              = 1,
    parameter int GRID_Y              = 1,
    parameter int MAX_VARS_PER_CORE   = 256,
    parameter int MAX_CLAUSES_PER_CORE= 512,
    parameter int MAX_LITS            = 1024
)(
    input  logic clk,
    input  logic rst_n_in,

    // === AXI-Lite OCL BAR (simplified) ===
    input  logic        axil_wr_valid,
    input  logic [31:0] axil_wr_addr,
    input  logic [31:0] axil_wr_data,
    output logic        axil_wr_ready,

    input  logic        axil_rd_valid,
    input  logic [31:0] axil_rd_addr,
    output logic [31:0] axil_rd_data,
    output logic        axil_rd_ready,

    // === AXI4-PCIS DMA (simplified) ===
    input  logic        pcis_wr_valid,
    input  logic [31:0] pcis_wr_addr,
    input  logic [31:0] pcis_wr_data,
    output logic        pcis_wr_ready,

    // === DDR4 PCIM (memory model interface) ===
    output logic        ddr_read_req,
    output logic [31:0] ddr_read_addr,
    output logic [7:0]  ddr_read_len,
    input  logic        ddr_read_grant,
    input  logic [31:0] ddr_read_data,
    input  logic        ddr_read_valid,

    output logic        ddr_write_req,
    output logic [31:0] ddr_write_addr,
    output logic [31:0] ddr_write_data,
    input  logic        ddr_write_grant
);

    // ---------------------------------------------------------------
    // Internal signals
    // ---------------------------------------------------------------
    logic        rst_n;
    logic        soft_reset;
    logic        host_start;
    logic        host_done;
    logic        host_sat;
    logic        host_unsat;
    logic        host_load_valid;
    logic signed [31:0] host_load_literal;
    logic        host_load_clause_end;
    logic        host_load_ready;
    logic [31:0] cycle_counter;
    logic [31:0] debug_level;

    // Combined reset: external OR soft
    assign rst_n = rst_n_in & ~soft_reset;

    // ---------------------------------------------------------------
    // AXI-Lite Register Logic
    // ---------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n_in) begin
        if (!rst_n_in) begin
            host_start  <= 1'b0;
            soft_reset  <= 1'b0;
            debug_level <= 32'd0;
        end else begin
            // Auto-clear start after one cycle
            if (host_start) host_start <= 1'b0;
            if (soft_reset) soft_reset <= 1'b0;

            if (axil_wr_valid) begin
                case (axil_wr_addr[7:0])
                    8'h00: host_start  <= axil_wr_data[0];
                    8'h0C: soft_reset  <= axil_wr_data[0];
                    8'h10: debug_level <= axil_wr_data;
                    default: ;
                endcase
            end
        end
    end

    assign axil_wr_ready = 1'b1;

    // AXI-Lite Read
    always_comb begin
        axil_rd_data = 32'h0;
        axil_rd_ready = axil_rd_valid;
        case (axil_rd_addr[7:0])
            8'h00: axil_rd_data = {29'b0, host_unsat, host_sat, host_done};
            8'h04: axil_rd_data = cycle_counter;
            8'h08: axil_rd_data = 32'h53415431; // "SAT1"
            8'h10: axil_rd_data = debug_level;
            default: axil_rd_data = 32'hDEAD_BEEF;
        endcase
    end

    // ---------------------------------------------------------------
    // Cycle Counter
    // ---------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cycle_counter <= 32'h0;
        else if (host_start)
            cycle_counter <= 32'h0;
        else if (!host_done)
            cycle_counter <= cycle_counter + 1;
    end

    // ---------------------------------------------------------------
    // DMA / PCIS → CNF Load
    // ---------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            host_load_valid      <= 1'b0;
            host_load_literal    <= 32'sd0;
            host_load_clause_end <= 1'b0;
        end else begin
            host_load_valid <= 1'b0;
            if (pcis_wr_valid && pcis_wr_ready) begin
                host_load_valid   <= 1'b1;
                host_load_literal <= $signed(pcis_wr_data);
                // Address 0x1004 = clause end marker
                host_load_clause_end <= (pcis_wr_addr[15:0] == 16'h1004);
            end
        end
    end

    assign pcis_wr_ready = host_load_ready;

    // ---------------------------------------------------------------
    // SatSwarm Core
    // ---------------------------------------------------------------
    satswarm_top #(
        .GRID_X             (GRID_X),
        .GRID_Y             (GRID_Y),
        .MAX_VARS_PER_CORE  (MAX_VARS_PER_CORE),
        .MAX_CLAUSES_PER_CORE(MAX_CLAUSES_PER_CORE),
        .MAX_LITS           (MAX_LITS)
    ) u_satswarm (
        .DEBUG              (debug_level),
        .clk                (clk),
        .rst_n              (rst_n),
        .host_start         (host_start),
        .host_done          (host_done),
        .host_sat           (host_sat),
        .host_unsat         (host_unsat),
        .host_load_valid    (host_load_valid),
        .host_load_literal  (host_load_literal),
        .host_load_clause_end(host_load_clause_end),
        .host_load_ready    (host_load_ready),
        .ddr_read_req       (ddr_read_req),
        .ddr_read_addr      (ddr_read_addr),
        .ddr_read_len       (ddr_read_len),
        .ddr_read_grant     (ddr_read_grant),
        .ddr_read_data      (ddr_read_data),
        .ddr_read_valid     (ddr_read_valid),
        .ddr_write_req      (ddr_write_req),
        .ddr_write_addr     (ddr_write_addr),
        .ddr_write_data     (ddr_write_data),
        .ddr_write_grant    (ddr_write_grant)
    );

endmodule
