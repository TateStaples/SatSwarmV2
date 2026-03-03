
module shared_clause_buffer #(
    parameter int NUM_CORES = 4,
    parameter int DEPTH = 4096, // Must be power of 2
    parameter int PTR_W = $clog2(DEPTH)
)(
    input logic clk,
    input logic rst_n,

    // Write Interface (Arbitered)
    input logic [NUM_CORES-1:0] write_req,
    input  satswarmv2_pkg::shared_packet_t write_payload [NUM_CORES-1:0],
    output logic [NUM_CORES-1:0] write_grant,

    // Broadcast Interface (to all cores)
    output logic        bcast_valid,
    output satswarmv2_pkg::shared_packet_t bcast_payload
);

    // Shared Memory Storage — flattened from struct to logic bits.
    // Write and read ports are in SEPARATE always_ff @(posedge clk) blocks
    // with NO async-reset sensitivity.  This is Vivado's required SDP BRAM
    // inference template (UG901): one write process, one read process, both
    // purely clock-edge sensitive.
    localparam int DATA_W = $bits(satswarmv2_pkg::shared_packet_t); // 96
    (* ram_style = "block" *) logic [DATA_W-1:0] mem [0:DEPTH-1];

    logic [PTR_W-1:0] write_ptr;
    logic [PTR_W-1:0] read_ptr;

    // ---------------------------------------------------------
    // WRITE LOGIC (Round-Robin Arbiter)
    // ---------------------------------------------------------
    logic [($clog2(NUM_CORES) > 0 ? $clog2(NUM_CORES)-1 : 0):0] grant_idx;
    logic any_grant;

    logic [($clog2(NUM_CORES) > 0 ? $clog2(NUM_CORES)-1 : 0):0] rr_ptr;

    always_comb begin
        write_grant = '0;
        grant_idx = '0;
        any_grant = 1'b0;

        for (int i = 0; i < NUM_CORES; i++) begin
            int idx;
            idx = (rr_ptr + i) % NUM_CORES;
            if (write_req[idx]) begin
                write_grant[idx] = 1'b1;
                grant_idx = idx;
                any_grant = 1'b1;
                break;
            end
        end
    end

    // ---------------------------------------------------------
    // BRAM Write Port — posedge clk ONLY (no async reset).
    // Vivado SDP BRAM inference requires the write process to be
    // purely synchronous; including negedge rst_n in the sensitivity
    // list causes inference to fail even when mem is not reset.
    // ---------------------------------------------------------
    always_ff @(posedge clk) begin
        if (any_grant) begin
            mem[write_ptr] <= DATA_W'(write_payload[grant_idx]);
        end
    end

    // Write Control (with async reset for pointers only)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_ptr <= '0;
            rr_ptr    <= '0;
        end else begin
            if (any_grant) begin
                write_ptr <= write_ptr + 1;
                rr_ptr    <= (grant_idx + 1) % NUM_CORES;
            end
        end
    end

    // ---------------------------------------------------------
    // BRAM Read Port — posedge clk ONLY (no async reset).
    // Registered output is the SDP BRAM read template.
    // bcast_payload is driven combinationally from mem_rd_data;
    // bcast_valid gates validity so consumers never observe
    // uninitialised BRAM output during reset.
    // ---------------------------------------------------------
    logic [DATA_W-1:0] mem_rd_data;

    always_ff @(posedge clk) begin
        mem_rd_data <= mem[read_ptr];
    end

    assign bcast_payload = satswarmv2_pkg::shared_packet_t'(mem_rd_data);

    // Read / Broadcast Control (with async reset for pointers/valid only)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_ptr   <= '0;
            bcast_valid <= 1'b0;
        end else begin
            bcast_valid <= 1'b0;
            if (read_ptr != write_ptr) begin
                bcast_valid <= 1'b1;
                read_ptr    <= read_ptr + 1;
            end
        end
    end

endmodule
