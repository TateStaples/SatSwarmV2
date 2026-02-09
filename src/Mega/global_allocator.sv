// Global Allocator: Single-Cycle Atomic Bump Pointer for DDR Clause Region
// Provides contention-free address allocation for multi-core learned clause storage.
//
// USAGE:
//   Core asserts alloc_req with alloc_size (in words).
//   Same cycle: alloc_grant goes high, alloc_addr contains allocated base address.
//   Next cycle: bump_ptr advances by size, ready for next allocation.
//
// INVARIANT: Only one core receives grant per cycle (round-robin arbitration).

module global_allocator #(
    parameter int NUM_CORES = 4,
    parameter int ADDR_WIDTH = 32,
    parameter int BASE_ADDR = 32'h4000_0000  // Start of learned clause region (after original CNF)
)(
    input  logic clk,
    input  logic rst_n,

    // Allocation requests from cores
    input  logic [NUM_CORES-1:0]       alloc_req,      // Core requests allocation
    input  logic [15:0]                alloc_size [NUM_CORES-1:0], // Size in 32-bit words
    
    // Allocation grants (active same cycle as request)
    output logic [NUM_CORES-1:0]       alloc_grant,    // Granted this cycle
    output logic [ADDR_WIDTH-1:0]      alloc_addr,     // Allocated base address (shared, only winner uses)
    
    // Status
    output logic [ADDR_WIDTH-1:0]      current_ptr     // Current bump pointer (for debug)
);

    // The Bump Pointer (Sequential State)
    logic [ADDR_WIDTH-1:0] bump_ptr_q;

    // Round-Robin Arbiter State
    localparam int RR_WIDTH = (NUM_CORES > 1) ? $clog2(NUM_CORES) : 1;
    logic [RR_WIDTH-1:0] rr_idx_q;

    // Winner selection (combinational)
    logic [RR_WIDTH-1:0] winner_idx;
    logic any_request;
    logic [15:0] winner_size;

    always_comb begin
        alloc_grant = '0;
        alloc_addr = bump_ptr_q;  // Current pointer goes to winner
        winner_idx = '0;
        winner_size = '0;
        any_request = |alloc_req;

        // Round-robin: find first requesting core starting from rr_idx_q
        for (int i = 0; i < NUM_CORES; i++) begin
            int idx;
            idx = (rr_idx_q + i) % NUM_CORES;
            if (alloc_req[idx]) begin
                alloc_grant[idx] = 1'b1;
                winner_idx = idx[RR_WIDTH-1:0];
                winner_size = alloc_size[idx];
                break;  // Only one winner per cycle
            end
        end
    end

    // Sequential: Update pointer on grant
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bump_ptr_q <= BASE_ADDR;
            rr_idx_q <= '0;
        end else if (any_request) begin
            // Bump the pointer by the winner's requested size (words -> bytes: *4)
            bump_ptr_q <= bump_ptr_q + {winner_size, 2'b00};
            // Advance round-robin to be fair
            rr_idx_q <= (winner_idx + 1) % NUM_CORES;
        end
    end

    assign current_ptr = bump_ptr_q;

endmodule
