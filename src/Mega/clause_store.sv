module clause_store #(
    parameter int MAX_CLAUSES = 256,
    parameter int MAX_LITS = 2048
)(
    input  logic               clk,
    input  logic               rst_n,

    // Write interface (for loading)
    input  logic               wr_en,
    input  logic [15:0]        wr_clause_id,
    input  logic [15:0]        wr_lit_count,
    input  logic [15:0]        wr_clause_start,
    input  logic [15:0]        wr_clause_len,
    input  logic [15:0]        wr_lit_addr,
    input  logic signed [31:0] wr_literal,

    // Read interface
    input  logic [15:0]        rd_clause_id,
    input  logic [3:0]         rd_lit_idx,
    output logic signed [31:0] rd_literal,
    output logic [15:0]        rd_clause_len,
    output logic [15:0]        rd_clause_start,

    // Direct memory access (for scanning)
    input  logic [15:0]        mem_addr,
    output logic signed [31:0] mem_literal
);

    // Clause store
    logic [15:0] clause_len   [0:MAX_CLAUSES-1];
    logic [15:0] clause_start [0:MAX_CLAUSES-1];
    logic signed [31:0] lit_mem [0:MAX_LITS-1];

    always_ff @(posedge clk) begin
        if (wr_en) begin
            if (wr_clause_id < MAX_CLAUSES) begin
                clause_len[wr_clause_id]   <= wr_clause_len;
                clause_start[wr_clause_id] <= wr_clause_start;
            end
            if (wr_lit_addr < MAX_LITS) begin
                lit_mem[wr_lit_addr] <= wr_literal;
            end
        end
    end

    // Combinational reads
    assign rd_clause_len   = (rd_clause_id < MAX_CLAUSES) ? clause_len[rd_clause_id] : 16'd0;
    assign rd_clause_start = (rd_clause_id < MAX_CLAUSES) ? clause_start[rd_clause_id] : 16'd0;
    
    wire [15:0] abs_lit_addr = rd_clause_start + rd_lit_idx;
    assign rd_literal = (rd_clause_id < MAX_CLAUSES && rd_lit_idx < rd_clause_len && abs_lit_addr < MAX_LITS) 
                        ? lit_mem[abs_lit_addr] : 32'd0;

    assign mem_literal = (mem_addr < MAX_LITS) ? lit_mem[mem_addr] : 32'd0;

endmodule
