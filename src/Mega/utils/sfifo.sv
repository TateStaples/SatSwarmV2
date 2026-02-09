/**
 * Generic Synchronous FIFO (sfifo)
 * 
 * DESIGN OVERVIEW:
 * A standard circular buffer FIFO with synchronous read/write.
 * Provides FWFT-like behavior where 'pop_data' is valid whenever 'empty' is low.
 * 
 * PRE-CONDITIONS:
 * - Clock and Reset (rst_n) must be provided.
 * - Width and Depth should be positive integers.
 * 
 * POST-CONDITIONS:
 * - Data is emitted in the same order it was pushed.
 * - 'full' is asserted when count == DEPTH.
 * - 'empty' is asserted when count == 0.
 * - 'count' reflects the number of elements currently stored.
 * 
 * INVARIANTS:
 * - Simultaneous push and pop on a full FIFO results in a pop followed by a push,
 *   maintaining the 'full' state. (Optional: Check overflow/underflow protection).
 * - Flush clears all internal pointers and count in a single cycle.
 */
module sfifo #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 32
)(
    input  logic             clk,
    input  logic             rst_n,   // Active-low asynchronous reset
    
    // Write Interface
    input  logic             push,      // High to push push_data
    input  logic [WIDTH-1:0] push_data, // Data to be stored
    output logic             full,      // High when no more space
    
    // Read Interface
    input  logic             pop,       // High to consume pop_data
    output logic [WIDTH-1:0] pop_data,  // Current head of FIFO
    output logic             empty,     // High when no data available
    
    // Status
    output logic [$clog2(DEPTH):0] count, // Number of items in FIFO
    
    // Control
    input  logic             flush      // Synchronous clear (highest priority)
);

    localparam ADDR_W = $clog2(DEPTH);
    
    (* ram_style = "block" *) logic [WIDTH-1:0] mem [0:DEPTH-1];
    logic [ADDR_W-1:0] wr_ptr;
    logic [ADDR_W-1:0] rd_ptr;
    logic [ADDR_W:0]   cnt;
    
    assign count = cnt;
    assign full  = (cnt == DEPTH);
    assign empty = (cnt == 0);
    
    assign pop_data = mem[rd_ptr];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            cnt    <= '0;
        end else if (flush) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            cnt    <= '0;
        end else begin
            // Simultaneous push and pop
            if (push && !full && pop && !empty) begin
                mem[wr_ptr] <= push_data;
                wr_ptr <= (wr_ptr == DEPTH-1) ? '0 : wr_ptr + 1'b1;
                rd_ptr <= (rd_ptr == DEPTH-1) ? '0 : rd_ptr + 1'b1;
                // Count remains unchanged
            end else begin
                if (push && !full) begin
                    mem[wr_ptr] <= push_data;
                    wr_ptr <= (wr_ptr == DEPTH-1) ? '0 : wr_ptr + 1'b1;
                    cnt <= cnt + 1'b1;
                end
                if (pop && !empty) begin
                    rd_ptr <= (rd_ptr == DEPTH-1) ? '0 : rd_ptr + 1'b1;
                    cnt <= cnt - 1'b1;
                end
            end
        end
    end

endmodule
