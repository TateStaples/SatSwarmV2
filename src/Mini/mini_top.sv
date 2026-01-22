// Mini DPLL Top Level
// Standalone DPLL SAT solver without CAE (learned clauses) or multi-core support
`timescale 1ns/1ps

import mini_pkg::*;

module mini_top #(
    parameter int MAX_VARS = 256,
    parameter int MAX_CLAUSES = 256,
    parameter int MAX_LITS = 2048,
    parameter int MAX_CLAUSE_LEN = 16
)(
    input  int   DEBUG,
    input  logic clk,
    input  logic rst_n,

    // Control interface
    input  logic        start_solve,
    output logic        done,
    output logic        sat,
    output logic        unsat,

    // Clause loading interface
    input  logic               load_valid,
    input  logic signed [31:0] load_literal,
    input  logic               load_clause_end,
    output logic               load_ready,

    // Statistics
    output logic [31:0] conflict_count,
    output logic [31:0] decision_count
);

    mini_solver_core #(
        .MAX_VARS(MAX_VARS),
        .MAX_CLAUSES(MAX_CLAUSES),
        .MAX_LITS(MAX_LITS),
        .MAX_CLAUSE_LEN(MAX_CLAUSE_LEN)
    ) u_solver (
        .DEBUG(DEBUG),
        .clk(clk),
        .rst_n(rst_n),
        
        .start_solve(start_solve),
        .done(done),
        .sat(sat),
        .unsat(unsat),
        
        .load_valid(load_valid),
        .load_literal(load_literal),
        .load_clause_end(load_clause_end),
        .load_ready(load_ready),
        
        .conflict_count(conflict_count),
        .decision_count(decision_count)
    );

endmodule
