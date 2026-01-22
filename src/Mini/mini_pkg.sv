// Package: common parameters and types for Mini DPLL Solver
// Simplified version without VSIDS activity, LBD, or learned clause structures
package mini_pkg;
    parameter int MAX_VARS       = 256;
    parameter int MAX_CLAUSES    = 256;
    parameter int MAX_LITS       = 2048;
    parameter int MAX_CLAUSE_LEN = 16;
    parameter int LEVEL_W        = 16;
    parameter int PTR_W          = 16;

    // Assignment encoding: 2'b00 = unassigned, 2'b01 = false, 2'b10 = true
    typedef enum logic [1:0] {
        VAL_UNDEF = 2'b00,
        VAL_FALSE = 2'b01,
        VAL_TRUE  = 2'b10
    } assign_val_t;

    // Decision tracking for chronological backtracking
    typedef struct packed {
        logic [31:0] var_id;       // Variable that was decided
        logic        tried_pos;    // Tried positive polarity
        logic        tried_neg;    // Tried negative polarity
    } decision_entry_t;

    // Solver states for main FSM
    typedef enum logic [3:0] {
        IDLE,
        LOAD_CLAUSE,
        INIT_WATCHES,
        DECIDE,
        PROPAGATE,
        CONFLICT,           // Conflict detected, attempt backtrack
        BACKTRACK,
        FLIP_DECISION,
        CLEAR_THEN_DECIDE,  // Wait for clear to complete then make decision
        SAT_DONE,
        UNSAT_DONE
    } solver_state_t;
    
endpackage
