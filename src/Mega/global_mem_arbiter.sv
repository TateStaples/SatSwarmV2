// Global Memory Arbiter
// ======================
// Purpose: multiplex NUM_CORES solver cores onto a single DDR4 master port with fair,
// registered sequencing.  All outputs are registered to avoid combinatorial paths to
// the AXI bridge.
//
// Read path  (ARB_IDLE → ARB_RD_WAIT_GRANT → ARB_RD_DATA → ARB_IDLE):
//   Round-robin picks the first requesting core (starting from rr_q), asserts
//   ddr_read_req toward the bridge, and holds it until ddr_read_grant fires.
//   Then it counts ddr_read_valid beats (up to latched_len+1) and forwards each
//   beat to the winning core only.  rr_q advances past the winner so the next
//   read round-robin starts from the next core.
//
// Write path  (ARB_IDLE → ARB_WR_WAIT_GRANT → ARB_IDLE):
//   Single-beat writes only (solver cores write one 32-bit word per request).
//   The arbiter asserts ddr_write_req toward the bridge and immediately pulses
//   core_write_grant back to the winning core (optimistic: the core is free to
//   de-assert its request and move on before the DDR bridge has finished).
//   The arbiter stays in ARB_WR_WAIT_GRANT until ddr_write_grant comes back from
//   the bridge, then returns to ARB_IDLE.
//
// write_active_q — BRESP serialization guard (P0-B fix):
//   Problem: the bridge takes several cycles to complete an AXI4 write
//   (DDR_WR_ADDR → DDR_WR_DATA → DDR_WR_RESP).  Without a guard, the arbiter
//   could return to ARB_IDLE, pick the next pending write from a *different* core,
//   and overwrite ddr_write_addr/ddr_write_data while the bridge is still driving
//   those values on the AXI bus — corrupting the in-flight transaction.
//
//   Solution: write_active_q is set when the bridge accepts the write
//   (ddr_write_grant fires) and cleared only when the bridge signals BRESP
//   completion via ddr_write_done (a one-cycle pulse from cl_satswarm).
//   ARB_IDLE refuses to start a new write while write_active_q is high, ensuring
//   at most one write is in-flight through the bridge at any time.
//
//   In simulation the testbench fires ddr_write_done one cycle after
//   ddr_write_grant.  On the FPGA, cl_satswarm fires it one cycle after bvalid
//   is seen in DDR_WR_RESP.
`timescale 1ns/1ps

module global_mem_arbiter #(
    parameter int NUM_CORES = 4
)(
    input  logic        clk,
    input  logic        rst_n,

    input  logic        core_read_req     [0:NUM_CORES-1],
    input  logic [31:0] core_read_addr    [0:NUM_CORES-1],
    input  logic [7:0]  core_read_len     [0:NUM_CORES-1],
    output logic        core_read_grant   [0:NUM_CORES-1],
    output logic [31:0] core_read_data    [0:NUM_CORES-1],
    output logic        core_read_valid   [0:NUM_CORES-1],

    input  logic        core_write_req    [0:NUM_CORES-1],
    input  logic [31:0] core_write_addr   [0:NUM_CORES-1],
    input  logic [31:0] core_write_data   [0:NUM_CORES-1],
    output logic        core_write_grant  [0:NUM_CORES-1],

    output logic        ddr_read_req,
    output logic [31:0] ddr_read_addr,
    output logic [7:0]  ddr_read_len,
    input  logic        ddr_read_grant,
    input  logic [31:0] ddr_read_data,
    input  logic        ddr_read_valid,

    output logic        ddr_write_req,
    output logic [31:0] ddr_write_addr,
    output logic [31:0] ddr_write_data,
    input  logic        ddr_write_grant,

    // Pulsed by cl_satswarm bridge for one cycle when BRESP is received.
    // Clears write_active_q so the next write can be issued.
    input  logic        ddr_write_done
);

    localparam int ARB_W = (NUM_CORES > 1) ? $clog2(NUM_CORES) : 1;
    localparam logic [ARB_W-1:0] CORE_LAST = ARB_W'(NUM_CORES - 1);

    typedef enum logic [2:0] {
        ARB_IDLE,
        ARB_RD_WAIT_GRANT,
        ARB_RD_DATA,
        ARB_WR_WAIT_GRANT
    } arb_st_e;

    arb_st_e st;
    logic [ARB_W-1:0] rr_q;
    logic [ARB_W-1:0] active_core;
    logic [7:0]       latched_len;
    logic [7:0]       beats_left;
    logic [ARB_W-1:0] rd_pick;
    logic [ARB_W-1:0] wr_pick;
    // Set when a write is forwarded to the bridge; cleared when ddr_write_done fires.
    // Prevents issuing a new write while the bridge is still processing the previous one.
    logic write_active_q;

    always_comb begin
        rd_pick = pick_read_core();
        wr_pick = pick_write_core();
    end

    // Pick next requesting core (round-robin from rr_q)
    function automatic logic [ARB_W-1:0] pick_read_core;
        pick_read_core = '0;
        for (int i = 0; i < NUM_CORES; i++) begin
            if (core_read_req[(rr_q + i) % NUM_CORES]) begin
                pick_read_core = (rr_q + i) % NUM_CORES;
                break;
            end
        end
    endfunction

    function automatic logic [ARB_W-1:0] pick_write_core;
        pick_write_core = '0;
        for (int i = 0; i < NUM_CORES; i++) begin
            if (core_write_req[(rr_q + i) % NUM_CORES]) begin
                pick_write_core = (rr_q + i) % NUM_CORES;
                break;
            end
        end
    endfunction

    logic any_rd, any_wr;
    always_comb begin
        any_rd = 1'b0;
        any_wr = 1'b0;
        for (int i = 0; i < NUM_CORES; i++) begin
            if (core_read_req[i]) any_rd = 1'b1;
            if (core_write_req[i]) any_wr = 1'b1;
        end
    end

    integer k;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            st            <= ARB_IDLE;
            rr_q          <= '0;
            active_core   <= '0;
            latched_len   <= '0;
            beats_left    <= '0;
            write_active_q <= 1'b0;
            ddr_read_req   <= 1'b0;
            ddr_read_addr  <= '0;
            ddr_read_len   <= '0;
            ddr_write_req  <= 1'b0;
            ddr_write_addr <= '0;
            ddr_write_data <= '0;
            for (k = 0; k < NUM_CORES; k++) begin
                core_read_grant[k]  <= 1'b0;
                core_read_data[k]   <= '0;
                core_read_valid[k]  <= 1'b0;
                core_write_grant[k] <= 1'b0;
            end
        end else begin
            // write_active_q tracks whether the bridge is still processing a write.
            // Set when the bridge accepts the write (ddr_write_grant); cleared on BRESP.
            if (ddr_write_grant)      write_active_q <= 1'b1;
            else if (ddr_write_done)  write_active_q <= 1'b0;
            for (k = 0; k < NUM_CORES; k++) begin
                core_read_grant[k]  <= 1'b0;
                core_read_valid[k]  <= 1'b0;
                core_write_grant[k] <= 1'b0;
            end
            ddr_read_req  <= 1'b0;
            ddr_write_req <= 1'b0;

            case (st)
                ARB_IDLE: begin
                    if (any_rd) begin
                        active_core <= rd_pick;
                        ddr_read_req  <= 1'b1;
                        ddr_read_addr <= core_read_addr[rd_pick];
                        ddr_read_len  <= core_read_len[rd_pick];
                        latched_len   <= core_read_len[rd_pick];
                        st            <= ARB_RD_WAIT_GRANT;
                    end else if (any_wr && !write_active_q) begin
                        // Guard: do not issue a new write while the bridge is still
                        // processing the previous one (write_active_q clears on BRESP).
                        active_core    <= wr_pick;
                        ddr_write_req  <= 1'b1;
                        ddr_write_addr <= core_write_addr[wr_pick];
                        ddr_write_data <= core_write_data[wr_pick];
                        core_write_grant[wr_pick] <= 1'b1;
                        st             <= ARB_WR_WAIT_GRANT;
                    end
                end
                ARB_RD_WAIT_GRANT: begin
                    ddr_read_req  <= 1'b1;
                    ddr_read_addr <= core_read_addr[active_core];
                    ddr_read_len  <= core_read_len[active_core];
                    core_read_grant[active_core] <= 1'b1;
                    if (ddr_read_grant) begin
                        beats_left <= latched_len + 8'd1;
                        st         <= ARB_RD_DATA;
                    end
                end
                ARB_RD_DATA: begin
                    core_read_grant[active_core] <= 1'b1;
                    if (ddr_read_valid) begin
                        core_read_data[active_core]  <= ddr_read_data;
                        core_read_valid[active_core] <= 1'b1;
                        if (beats_left == 8'd1) begin
                            rr_q <= (active_core == CORE_LAST) ? '0 : (active_core + 1'b1);
                            st <= ARB_IDLE;
                        end else
                            beats_left <= beats_left - 8'd1;
                    end
                end
                ARB_WR_WAIT_GRANT: begin
                    ddr_write_req  <= 1'b1;
                    ddr_write_addr <= core_write_addr[active_core];
                    ddr_write_data <= core_write_data[active_core];
                    if (ddr_write_grant) begin
                        rr_q <= (active_core == CORE_LAST) ? '0 : (active_core + 1'b1);
                        st   <= ARB_IDLE;
                    end
                end
                default: st <= ARB_IDLE;
            endcase
        end
    end

endmodule
