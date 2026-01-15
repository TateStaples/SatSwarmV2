// Global Memory Arbiter: AXI4-Lite / AXI4 Multiplexer for DDR4 Access
// Prioritizes READ requests (BCP/CAE) over WRITE requests (Learning).
module global_mem_arbiter #(
    parameter int NUM_CORES = 4
)(
    input  logic clk,
    input  logic rst_n,

    // Core read requests (burst-capable)
    input  logic        core_read_req     [0:NUM_CORES-1],
    input  logic [31:0] core_read_addr    [0:NUM_CORES-1],
    input  logic [7:0]  core_read_len     [0:NUM_CORES-1], // burst length
    output logic        core_read_grant   [0:NUM_CORES-1],
    output logic [31:0] core_read_data    [0:NUM_CORES-1],
    output logic        core_read_valid   [0:NUM_CORES-1],

    // Core write requests
    input  logic        core_write_req    [0:NUM_CORES-1],
    input  logic [31:0] core_write_addr   [0:NUM_CORES-1],
    input  logic [31:0] core_write_data   [0:NUM_CORES-1],
    output logic        core_write_grant  [0:NUM_CORES-1],

    // External DDR4 interface (AXI4 Master simplified)
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

    // Simplified fixed-priority arbiter: Round-robin among requesting cores
    // In hardware, use more sophisticated arbitration (weighted, LRU, etc.)
    
    localparam int ARB_W = (NUM_CORES > 1) ? $clog2(NUM_CORES) : 1;
    logic [ARB_W-1:0] read_arbiter_q, read_arbiter_d;
    logic [ARB_W-1:0] write_arbiter_q, write_arbiter_d;
    

    // READ arbitration: Fixed priority with round-robin
    always_comb begin
        read_arbiter_d = read_arbiter_q;
        ddr_read_req = 1'b0;
        ddr_read_addr = '0;
        ddr_read_len = '0;
        
        for (int i = 0; i < NUM_CORES; i = i + 1) begin
            core_read_grant[i] = 1'b0;
            core_read_data[i] = '0;
            core_read_valid[i] = 1'b0;
        end

        // Find next requesting core (round-robin)
        for (int i = 0; i < NUM_CORES; i = i + 1) begin
            if (core_read_req[(read_arbiter_q + i) % NUM_CORES]) begin
                core_read_grant[(read_arbiter_q + i) % NUM_CORES] = 1'b1;
                ddr_read_req = 1'b1;
                ddr_read_addr = core_read_addr[(read_arbiter_q + i) % NUM_CORES];
                ddr_read_len = core_read_len[(read_arbiter_q + i) % NUM_CORES];
                
                if (ddr_read_grant) begin
                    read_arbiter_d = ((read_arbiter_q + i) % NUM_CORES + 1) % NUM_CORES;
                end
                break;
            end
        end

        // Pass through read data (single core receives it)
        for (int i = 0; i < NUM_CORES; i = i + 1) begin
            if (core_read_grant[i]) begin
                core_read_data[i] = ddr_read_data;
                core_read_valid[i] = ddr_read_valid;
            end
        end
    end

    // WRITE arbitration: Lower priority, grant when no reads pending
    always_comb begin
        write_arbiter_d = write_arbiter_q;
        ddr_write_req = 1'b0;
        ddr_write_addr = '0;
        ddr_write_data = '0;
        
        for (int i = 0; i < NUM_CORES; i = i + 1) begin
            core_write_grant[i] = 1'b0;
        end

        // Only allow writes if no reads are pending
        if (!ddr_read_req) begin
            for (int i = 0; i < NUM_CORES; i = i + 1) begin
                if (core_write_req[(write_arbiter_q + i) % NUM_CORES]) begin
                    core_write_grant[(write_arbiter_q + i) % NUM_CORES] = 1'b1;
                    ddr_write_req = 1'b1;
                    ddr_write_addr = core_write_addr[(write_arbiter_q + i) % NUM_CORES];
                    ddr_write_data = core_write_data[(write_arbiter_q + i) % NUM_CORES];
                    
                    if (ddr_write_grant) begin
                        write_arbiter_d = ((write_arbiter_q + i) % NUM_CORES + 1) % NUM_CORES;
                    end
                    break;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_arbiter_q <= '0;
            write_arbiter_q <= '0;
        end else begin
            read_arbiter_q <= read_arbiter_d;
            write_arbiter_q <= write_arbiter_d;
        end
    end

endmodule
