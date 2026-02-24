
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

    // Shared Memory Storage (Binary Phrases)
    // Using simple inferred BRAM style
    satswarmv2_pkg::shared_packet_t mem [0:DEPTH-1];

    logic [PTR_W-1:0] write_ptr;
    logic [PTR_W-1:0] read_ptr;
    logic [PTR_W:0]   count; // Track occupancy

    // ---------------------------------------------------------
    // WRITE LOGIC (Round-Robin Arbiter)
    // ---------------------------------------------------------
    logic [31:0] arb_cnt;
    logic [$clog2(NUM_CORES)-1:0] grant_idx;
    logic any_grant;

    // Simple round-robin pointer
    logic [$clog2(NUM_CORES)-1:0] rr_ptr;

    always_comb begin
        write_grant = '0;
        grant_idx = '0;
        any_grant = 1'b0;

        // Scan for request starting from rr_ptr
        for (int i = 0; i < NUM_CORES; i++) begin
            int idx;
            idx = (rr_ptr + i) % NUM_CORES;
            if (write_req[idx]) begin
                write_grant[idx] = 1'b1;
                grant_idx = idx;
                any_grant = 1'b1;
                break; // Found one
            end
        end
    end

    // Sequential Write Process
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_ptr <= '0;
            rr_ptr <= '0;
        end else begin
            if (any_grant) begin
                // Perform Write
                mem[write_ptr] <= write_payload[grant_idx];
                
                // Advance Pointers
                write_ptr <= write_ptr + 1;
                
                // Update Arbiter to favor next core
                rr_ptr <= (grant_idx + 1) % NUM_CORES;
            end
        end
    end

    // ---------------------------------------------------------
    // READ / BROADCAST LOGIC
    // ---------------------------------------------------------
    // The "Radio Station": Continuously broadcasts valid clauses from the buffer.
    // If empty, it waits. If it falls behind write_ptr, it catches up.
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_ptr <= '0;
            bcast_valid <= 1'b0;
            bcast_payload <= '0;
        end else begin
            // Default off
            bcast_valid <= 1'b0;
            
            // Check if there is data to broadcast
            // Note: In circular buffer overwrite scenario, read_ptr might point to old data
            // that is being overwritten. Complex handling skipped for FPGA simplicity.
            // Assumption: Reading is faster than writing or buffer large enough.
            
            if (read_ptr != write_ptr) begin
                bcast_valid <= 1'b1;
                bcast_payload <= mem[read_ptr];
                read_ptr <= read_ptr + 1;
            end
        end
    end

endmodule
