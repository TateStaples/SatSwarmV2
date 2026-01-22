// Mini DPLL Solver Core
// Pure DPLL without learned clauses - uses chronological backtracking
// Simplified version of solver_core.sv without CAE, VDE heap, trail manager complexity
`timescale 1ns/1ps

import mini_pkg::*;


module mini_solver_core #(
    parameter int MAX_VARS = 256,
    parameter int MAX_CLAUSES = 256,
    parameter int MAX_LITS = 2048,
    parameter int MAX_CLAUSE_LEN = 16
)(
    input  int   DEBUG,
    input  logic clk,
    input  logic rst_n,

    // Control
    input  logic        start_solve,
    output logic        done,
    output logic        sat,
    output logic        unsat,

    // Clause load stream
    input  logic               load_valid,
    input  logic signed [31:0] load_literal,
    input  logic               load_clause_end,
    output logic               load_ready,

    // Stats output
    output logic [31:0] conflict_count,
    output logic [31:0] decision_count
);


    // =========================================================================
    // DPLL FSM States
    // =========================================================================
    mini_pkg::solver_state_t state_q, state_d;

    // =========================================================================
    // Decision Stack for Chronological Backtracking
    // Each entry tracks: variable, tried_positive, tried_negative
    // =========================================================================
    (* ram_style = "block" *) logic [31:0] decision_var_stack [0:MAX_VARS-1];
    logic [MAX_VARS-1:0] decision_tried_pos;
    logic [MAX_VARS-1:0] decision_tried_neg;
    logic [15:0] decision_level_q, decision_level_d;
    
    // Trail markers for each decision level
    (* ram_style = "block" *) logic [15:0] trail_lim [0:MAX_VARS-1];

    // Helper: Clamped indices to prevent OOB access if level grows uncheck
    // This allows the solver to recover via backtracking instead of getting stuck
    localparam IDX_W = $clog2(MAX_VARS);
    logic [IDX_W-1:0] idx_curr;
    logic [IDX_W-1:0] idx_prev;
    
    assign idx_curr = decision_level_q[IDX_W-1:0];
    assign idx_prev = (decision_level_q - 1'b1); // Slice happens automatically

    // =========================================================================
    // PSE Instance
    // =========================================================================
    logic        pse_start;
    logic        pse_done;
    logic        pse_conflict;
    logic signed [31:0] pse_decision_var;
    logic [31:0] pse_max_var_seen;
    logic        pse_undo_enable;
    logic [15:0] pse_undo_to_height;
    logic [15:0] pse_trail_height;
    logic        pse_propagated_valid;
    logic signed [31:0] pse_propagated_var;

    mini_pse #(
        .MAX_VARS(MAX_VARS),
        .MAX_CLAUSES(MAX_CLAUSES),
        .MAX_LITS(MAX_LITS),
        .MAX_CLAUSE_LEN(MAX_CLAUSE_LEN)
    ) u_pse (
        .DEBUG(DEBUG),
        .clk(clk),
        .reset(!rst_n),
        
        .load_valid(load_valid),
        .load_literal(load_literal),
        .load_clause_end(load_clause_end),
        .load_ready(load_ready),
        
        .start(pse_start),
        .decision_var(pse_decision_var),
        .done(pse_done),
        .conflict_detected(pse_conflict),
        .propagated_valid(pse_propagated_valid),
        .propagated_var(pse_propagated_var),
        .max_var_seen(pse_max_var_seen),
        .undo_enable(pse_undo_enable),
        .undo_to_height(pse_undo_to_height),
        .trail_height(pse_trail_height)
    );

    // =========================================================================
    // Variable Selection - Simple Sequential
    // =========================================================================
    logic [31:0] next_var;
    logic        all_assigned;

    always_comb begin
        next_var = 0;
        all_assigned = 1'b1;
        for (int v = 1; v <= MAX_VARS; v++) begin
            if (v <= pse_max_var_seen && u_pse.assign_state[v-1] == 2'b00 && next_var == 0) begin
                next_var = v;
                all_assigned = 1'b0;
            end
        end
    end

    // =========================================================================
    // Counters
    // =========================================================================
    logic [31:0] conflict_count_q, conflict_count_d;
    logic [31:0] decision_count_q, decision_count_d;

    assign conflict_count = conflict_count_q;
    assign decision_count = decision_count_q;

    // =========================================================================
    // Main FSM
    // =========================================================================
    always_comb begin
        state_d = state_q;
        decision_level_d = decision_level_q;
        conflict_count_d = conflict_count_q;
        decision_count_d = decision_count_q;
        
        pse_start = 1'b0;
        pse_decision_var = 0;
        pse_undo_enable = 1'b0;
        pse_undo_to_height = 16'h0000;
        
        done = 1'b0;
        sat = 1'b0;
        unsat = 1'b0;

        case (state_q)
            IDLE: begin
                if (DEBUG > 0) $display("[CORE] State: %d Level: %0d", state_q, decision_level_q);
                if (start_solve) begin
                    decision_level_d = 0;
                    conflict_count_d = 0;
                    decision_count_d = 0;
                    pse_start = 1'b1;
                    state_d = PROPAGATE;
                end
            end

            PROPAGATE: begin
                if (pse_done) begin
                    if (pse_conflict) begin
                        conflict_count_d = conflict_count_q + 1;
                        state_d = CONFLICT;
                    end else if (all_assigned) begin
                        state_d = SAT_DONE;
                    end else begin
                        state_d = DECIDE;
                    end
                end
            end

            DECIDE: begin
                if (next_var != 0) begin
                    // Store decision info
                    decision_level_d = decision_level_q + 1;
                    decision_count_d = decision_count_q + 1;
                    
                    // Try negative polarity first
                    pse_decision_var = -$signed(next_var);
                    pse_start = 1'b1;
                    
                    if (DEBUG >= 1) $display("[DPLL] Decided: %0d at Level %0d (NextVar: %0d MaxSeen: %0d)", -$signed(next_var), decision_level_q + 1, next_var, pse_max_var_seen);
                    
                    state_d = PROPAGATE;
                end else begin
                    state_d = SAT_DONE;
                end
            end

            CONFLICT: begin
                // DPLL Chronological Backtracking
                if (decision_level_q == 0) begin
                    // No decisions to undo -> UNSAT
                    state_d = UNSAT_DONE;
                end else begin
                    // Check if we can flip the current decision
                    if (DEBUG >= 1) $display("[DPLL] Conflict at Level %0d. Tried Pos[%0d] = %b", decision_level_q, decision_level_q-1, decision_tried_pos[idx_prev]);
                    if (!decision_tried_pos[idx_prev]) begin
                        // Flip to positive polarity
                        state_d = FLIP_DECISION;
                    end else begin
                        // Already tried both polarities, backtrack further
                        state_d = BACKTRACK;
                    end
                end
            end

            FLIP_DECISION: begin
                // Undo to the trail height at this decision level
                pse_undo_enable = 1'b1;
                pse_undo_to_height = trail_lim[idx_prev];
                
                
                if (DEBUG >= 1) $display("[DPLL] Flipping to: %0d at Level %0d (undo to %0d). WRITE tried_pos[%0d] <= 1", decision_var_stack[idx_prev], decision_level_q, trail_lim[idx_prev], decision_level_q-1);

                
                // Go to intermediate state to pulse start after undo completes
                state_d = CLEAR_THEN_DECIDE;
            end

            CLEAR_THEN_DECIDE: begin
                // Keep undoing while trail_height > undo_to_height
                if (pse_trail_height > trail_lim[idx_prev]) begin
                    pse_undo_enable = 1'b1;
                    pse_undo_to_height = trail_lim[idx_prev];
                end else begin
                    // Undo complete, transition to WAIT_FOR_PSE_IDLE to start handshake
                    state_d = WAIT_FOR_PSE_IDLE;
                end
            end

            WAIT_FOR_PSE_IDLE: begin
                // Stage 1: Wait for PSE to settle in IDLE (load_ready=1)
                // This ensures PSE has finished UNDO state transition
                if (load_ready) begin
                    state_d = RESTART_WAIT;
                end
            end

            RESTART_WAIT: begin
                // Stage 2: Assert start and wait for PSE acceptance
                pse_decision_var = $signed(decision_var_stack[idx_prev]);
                pse_start = 1'b1;
                
                // Wait for load_ready to go LOW, indicating PSE moved to SEED_DECISION
                if (!load_ready) begin
                    state_d = PROPAGATE;
                end
            end

            BACKTRACK: begin
                // Undo current decision level
                pse_undo_enable = 1'b1;
                pse_undo_to_height = trail_lim[idx_prev];
                decision_level_d = decision_level_q - 1;
                
                if (decision_level_d == 0) begin
                    state_d = UNSAT_DONE;
                end else begin
                    state_d = CONFLICT;  // Re-evaluate at previous level
                end
            end

            SAT_DONE: begin
                done = 1'b1;
                sat = 1'b1;
                if (DEBUG >= 1) $display("[DPLL] Result: SAT");
            end

            UNSAT_DONE: begin
                done = 1'b1;
                unsat = 1'b1;
                if (DEBUG >= 1) $display("[DPLL] Result: UNSAT");
            end

            default: state_d = IDLE;
        endcase
    end

    // =========================================================================
    // Sequential Logic
    // =========================================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q <= IDLE;
            decision_level_q <= 0;
            conflict_count_q <= 0;
            decision_count_q <= 0;
            
            for (int i = 0; i < MAX_VARS; i++) begin
                decision_var_stack[i] <= 0;
                decision_tried_pos[i] <= 1'b0;
                decision_tried_neg[i] <= 1'b0;
                trail_lim[i] <= 0;
            end
        end else begin
            if (DEBUG > 0) $display("[CORE] State: %d Level: %0d", state_q, decision_level_q);
            state_q <= state_d;
            decision_level_q <= decision_level_d;
            conflict_count_q <= conflict_count_d;
            decision_count_q <= decision_count_d;
            
            // Record decision when making one - capture trail height for backtracking
            if (state_q == DECIDE && next_var != 0) begin
                decision_var_stack[idx_curr] <= next_var;
                decision_tried_pos[idx_curr] <= 1'b0;
                decision_tried_neg[idx_curr] <= 1'b1;
                trail_lim[idx_curr] <= pse_trail_height;  // Record trail height before this decision
            end
            
            // Mark positive tried when flipping
            if (state_q == FLIP_DECISION) begin
                decision_tried_pos[idx_prev] <= 1'b1;
            end
            // Reset decision tracking when backtracking
            if (state_q == BACKTRACK) begin
                decision_tried_pos[idx_prev] <= 1'b0;
                decision_tried_neg[idx_prev] <= 1'b0;
            end
        end
    end

endmodule
