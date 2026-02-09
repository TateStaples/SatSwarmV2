// SatSwarm Top-Level: Integrates solver grid, mesh, and memory arbiter
module satswarm_top #(
    parameter int GRID_X = 1,
    parameter int GRID_Y = 1,
    parameter int MAX_VARS_PER_CORE = 256,
    parameter int MAX_CLAUSES_PER_CORE = 256,
    parameter int MAX_LITS = 2048,
    parameter int NUM_CORES = GRID_X * GRID_Y
)(
    input  int  DEBUG, // Runtime Debug Level
    input  logic clk,
    input  logic rst_n,

    // Host control interface (AXI4-Lite simplified)
    input  logic        host_start,
    output logic        host_done,
    output logic        host_sat,
    output logic        host_unsat,

    // Host load interface (stream CNF)
    input  logic        host_load_valid,
    input  logic signed [31:0] host_load_literal,
    input  logic        host_load_clause_end,
    output logic        host_load_ready,

    // External DDR4 interface (AXI4 Master)
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

    // Mesh interconnect signals
    satswarmv2_pkg::noc_packet_t core_tx [0:GRID_Y-1][0:GRID_X-1][3:0];
    logic core_tx_valid [0:GRID_Y-1][0:GRID_X-1][3:0];
    logic core_tx_ready [0:GRID_Y-1][0:GRID_X-1][3:0];

    satswarmv2_pkg::noc_packet_t core_rx [0:GRID_Y-1][0:GRID_X-1][3:0];
    logic core_rx_valid [0:GRID_Y-1][0:GRID_X-1][3:0];
    logic core_rx_ready [0:GRID_Y-1][0:GRID_X-1][3:0];

    // Global memory arbiter signals
    logic        core_read_req [0:NUM_CORES-1];
    logic [31:0] core_read_addr [0:NUM_CORES-1];
    logic [7:0]  core_read_len [0:NUM_CORES-1];
    logic        core_read_grant [0:NUM_CORES-1];
    logic [31:0] core_read_data [0:NUM_CORES-1];
    logic        core_read_valid [0:NUM_CORES-1];

    logic        core_write_req [0:NUM_CORES-1];
    logic [31:0] core_write_addr [0:NUM_CORES-1];
    logic [31:0] core_write_data [0:NUM_CORES-1];
    logic        core_write_grant [0:NUM_CORES-1];

    // Shared Clause Memory Signals
    logic [NUM_CORES-1:0] shared_write_req;
    satswarmv2_pkg::shared_packet_t shared_write_payload [NUM_CORES-1:0];
    logic [NUM_CORES-1:0] shared_write_grant;
    
    logic        shared_bcast_valid;
    satswarmv2_pkg::shared_packet_t shared_bcast_payload;

    // Global Allocator signals (for DDR learned clause region)
    logic [NUM_CORES-1:0]       alloc_req;
    logic [15:0]                alloc_size [NUM_CORES-1:0];
    logic [NUM_CORES-1:0]       alloc_grant;
    logic [31:0]                alloc_addr;

    // Per-core signals
    logic solve_done_core [0:NUM_CORES-1];
    logic is_sat_core [0:NUM_CORES-1];
    logic is_unsat_core [0:NUM_CORES-1];
    logic load_ready_core [0:NUM_CORES-1];

    // Mesh Interconnect
    mesh_interconnect #(
        .GRID_X(GRID_X),
        .GRID_Y(GRID_Y)
    ) u_mesh (
        .clk(clk),
        .rst_n(rst_n),
        .core_tx(core_tx),
        .core_tx_valid(core_tx_valid),
        .core_tx_ready(core_tx_ready),
        .core_rx(core_rx),
        .core_rx_valid(core_rx_valid),
        .core_rx_ready(core_rx_ready)
    );

    // Global Memory Arbiter
    global_mem_arbiter #(
        .NUM_CORES(NUM_CORES)
    ) u_arbiter (
        .clk(clk),
        .rst_n(rst_n),
        .core_read_req(core_read_req),
        .core_read_addr(core_read_addr),
        .core_read_len(core_read_len),
        .core_read_grant(core_read_grant),
        .core_read_data(core_read_data),
        .core_read_valid(core_read_valid),
        .core_write_req(core_write_req),
        .core_write_addr(core_write_addr),
        .core_write_data(core_write_data),
        .core_write_grant(core_write_grant),
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


    // Shared Clause Memory
    shared_clause_buffer #(
        .NUM_CORES(NUM_CORES),
        .DEPTH(4096)
    ) u_shared_mem (
        .clk(clk),
        .rst_n(rst_n),
        .write_req(shared_write_req),
        .write_payload(shared_write_payload),
        .write_grant(shared_write_grant),
        .bcast_valid(shared_bcast_valid),
        .bcast_payload(shared_bcast_payload)
    );

    // Global Allocator for DDR Learned Clause Region
    global_allocator #(
        .NUM_CORES(NUM_CORES),
        .ADDR_WIDTH(32),
        .BASE_ADDR(32'h4000_0000)  // Learned clauses start after original CNF
    ) u_allocator (
        .clk(clk),
        .rst_n(rst_n),
        .alloc_req(alloc_req),
        .alloc_size(alloc_size),
        .alloc_grant(alloc_grant),
        .alloc_addr(alloc_addr),
        .current_ptr()  // Debug output, unused
    );
    // Solver Core Grid
    genvar y, x;
    generate
        for (y = 0; y < GRID_Y; y = y + 1) begin : cols
            for (x = 0; x < GRID_X; x = x + 1) begin : rows
                localparam int CORE_IDX = y * GRID_X + x;
                
                // Local arrays for each core's 4-neighbor ports
                satswarmv2_pkg::noc_packet_t u_core_rx_pkt [3:0]; // Keep unpacked (internal fixup later)
                logic u_core_rx_valid [3:0];
                logic u_core_rx_ready [3:0];
                satswarmv2_pkg::noc_packet_t u_core_tx_pkt [3:0]; // Keep unpacked
                logic u_core_tx_valid [3:0];
                logic u_core_tx_ready [3:0];

                // Map grid neighbors to local 4-port view
                assign u_core_rx_pkt[3]  = core_rx[y][x][3];  // North
                assign u_core_rx_pkt[2]  = core_rx[y][x][2];  // South
                assign u_core_rx_pkt[1]  = core_rx[y][x][1];  // East
                assign u_core_rx_pkt[0]  = core_rx[y][x][0];  // West
                assign u_core_rx_valid[3] = core_rx_valid[y][x][3];
                assign u_core_rx_valid[2] = core_rx_valid[y][x][2];
                assign u_core_rx_valid[1] = core_rx_valid[y][x][1];
                assign u_core_rx_valid[0] = core_rx_valid[y][x][0];
                assign core_rx_ready[y][x][3] = u_core_rx_ready[3];
                assign core_rx_ready[y][x][2] = u_core_rx_ready[2];
                assign core_rx_ready[y][x][1] = u_core_rx_ready[1];
                assign core_rx_ready[y][x][0] = u_core_rx_ready[0];

                assign core_tx[y][x][3]  = u_core_tx_pkt[3];
                assign core_tx[y][x][2]  = u_core_tx_pkt[2];
                assign core_tx[y][x][1]  = u_core_tx_pkt[1];
                assign core_tx[y][x][0]  = u_core_tx_pkt[0];
                assign core_tx_valid[y][x][3] = u_core_tx_valid[3];
                assign core_tx_valid[y][x][2] = u_core_tx_valid[2];
                assign core_tx_valid[y][x][1] = u_core_tx_valid[1];
                assign core_tx_valid[y][x][0] = u_core_tx_valid[0];
                assign u_core_tx_ready[3] = core_tx_ready[y][x][3];
                assign u_core_tx_ready[2] = core_tx_ready[y][x][2];
                assign u_core_tx_ready[1] = core_tx_ready[y][x][1];
                assign u_core_tx_ready[0] = core_tx_ready[y][x][0];
                
                solver_core #(
                    .CORE_ID(CORE_IDX),
                    .MAX_VARS(MAX_VARS_PER_CORE),
                    .MAX_CLAUSES(MAX_CLAUSES_PER_CORE),
                    .MAX_LITS(MAX_LITS),
                    .GRID_X(GRID_X),
                    .GRID_Y(GRID_Y)
                ) u_core (
                    .DEBUG(DEBUG),
                    .clk(clk),
                    .rst_n(rst_n),
                    .vde_phase_offset(CORE_IDX[3:0]),
                    .start_solve(host_start),  // All cores start simultaneously
                    .solve_done(solve_done_core[CORE_IDX]),
                    .is_sat(is_sat_core[CORE_IDX]),
                    .is_unsat(is_unsat_core[CORE_IDX]),
                    .load_valid(host_load_valid),  // Broadcast CNF to all cores
                    .load_literal(host_load_literal),
                    .load_clause_end(host_load_clause_end),
                    .load_ready(load_ready_core[CORE_IDX]),  // Per-core ready
                    .rx_pkt(u_core_rx_pkt),
                    .rx_valid(u_core_rx_valid),
                    .rx_ready(u_core_rx_ready),
                    .tx_pkt(u_core_tx_pkt),
                    .tx_valid(u_core_tx_valid),
                    .tx_ready(u_core_tx_ready),
                    .global_read_req(core_read_req[CORE_IDX]),
                    .global_read_addr(core_read_addr[CORE_IDX]),
                    .global_read_len(core_read_len[CORE_IDX]),
                    .global_read_grant(core_read_grant[CORE_IDX]),
                    .global_read_data(core_read_data[CORE_IDX]),
                    .global_read_valid(core_read_valid[CORE_IDX]),
                    .global_write_req(core_write_req[CORE_IDX]),
                    .global_write_addr(core_write_addr[CORE_IDX]),
                    .global_write_data(core_write_data[CORE_IDX]),
                    .global_write_grant(core_write_grant[CORE_IDX])
                );
            end
        end
    endgenerate

    // Host load_ready: AND-reduce all cores' ready signals
    always_comb begin
        host_load_ready = 1'b1;
        for (int i = 0; i < NUM_CORES; i = i + 1) begin
            host_load_ready = host_load_ready & load_ready_core[i];
        end
    end

    // Host result aggregation
    always_comb begin
        host_done = 1'b0;
        host_sat = 1'b0;
        host_unsat = 1'b0;

        for (int i = 0; i < NUM_CORES; i = i + 1) begin
            if (solve_done_core[i]) begin
                host_done = 1'b1;
                if (is_sat_core[i]) host_sat = 1'b1;
                if (is_unsat_core[i]) host_unsat = 1'b1;
            end
        end
    end

    logic host_done_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) host_done_r <= 1'b0;
        else        host_done_r <= host_done;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset for logging-specific signals if any
        end else begin
            if (host_done && !host_done_r) begin
                for (int i = 0; i < NUM_CORES; i = i + 1) begin
                    if (solve_done_core[i]) begin
                        if (DEBUG >= 0) $display("[CORE %0d Result] done=%b sat=%b unsat=%b", i, solve_done_core[i], is_sat_core[i], is_unsat_core[i]);
                    end
                end
            end
        end
    end

endmodule
