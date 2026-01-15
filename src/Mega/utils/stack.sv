/**
 * Generic Stack (LIFO)
 * 
 * DESIGN OVERVIEW:
 * A simple Last-In-First-Out data structure.
 * 
 * PRE-CONDITIONS:
 * - Clock and Reset (rst_n) must be provided.
 * 
 * POST-CONDITIONS:
 * - 'pop_data' and 'top_data' reflect the most recently pushed item.
 * - 'full' is asserted when count == DEPTH.
 * - 'empty' is asserted when count == 0.
 * 
 * INVARIANTS:
 * - Push while full is ignored.
 * - Pop while empty is ignored.
 * - Clear resets the stack pointer instantly.
 */
module stack #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 32
)(
    input  logic             clk,
    input  logic             rst_n,
    
    // Interface
    input  logic             push,
    input  logic [WIDTH-1:0] push_data,
    input  logic             pop,
    output logic [WIDTH-1:0] pop_data,  // Redundant with top_data, for consistency
    output logic [WIDTH-1:0] top_data, // Peek at current top
    
    output logic             full,
    output logic             empty,
    output logic [$clog2(DEPTH):0] count,
    input  logic             clear
);

    localparam ADDR_W = $clog2(DEPTH);

    logic [WIDTH-1:0] mem [0:DEPTH-1];
    logic [ADDR_W:0]  cnt; // Points to next empty slot (also represents count)

    assign count    = cnt;
    assign full     = (cnt == DEPTH);
    assign empty    = (cnt == 0);
    
    // Top data is at cnt-1 (if not empty)
    assign top_data = (cnt > 0) ? mem[cnt-1] : '0;
    // Pop data is also at cnt-1
    assign pop_data = (cnt > 0) ? mem[cnt-1] : '0;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            cnt <= '0;
        end else if (clear) begin
            cnt <= '0;
        end else begin
             if (push && !full) begin
                 mem[cnt] <= push_data;
                 cnt <= cnt + 1'b1;
             end else if (pop && !empty) begin
                 cnt <= cnt - 1'b1;
             end
        end
    end

endmodule
