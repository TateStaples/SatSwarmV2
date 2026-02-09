
module solver_core #(
    parameter int CORE_ID = 0,
    parameter int MAX_VARS = 256,
    parameter int MAX_CLAUSES = 256,
    parameter int MAX_LITS = 2048,
    parameter int MAX_CLAUSE_LEN = 32,
    parameter int GRID_X = 1,
    parameter int GRID_Y = 1
)(
    input  int   DEBUG, 
    input  logic clk,  // Clock
    input  logic rst_n,  // TODO: document what this is 
    input  logic [3:0] vde_phase_offset,// TODO: document what this is 

    // Control
    input  logic        start_solve,
    output logic        solve_done,
    output logic        is_sat,
    output logic        is_unsat,

    // ------ Multicore Interface ------ //
    // Host load interface (from top level) -> Temporarily disable until we get to mesh testing
     input  logic        load_valid,
     input  logic signed [31:0] load_literal,
     input  logic        load_clause_end,
     output logic        load_ready,

        // NoC Interface (4 directions: N, S, E, W)
    `ifdef SYNTHESIS
        input  satswarmv2_pkg::noc_packet_t rx_pkt_0,
        input  satswarmv2_pkg::noc_packet_t rx_pkt_1,
        input  satswarmv2_pkg::noc_packet_t rx_pkt_2,
        input  satswarmv2_pkg::noc_packet_t rx_pkt_3,
        input  logic rx_valid_0,
        input  logic rx_valid_1,
        input  logic rx_valid_2,
        input  logic rx_valid_3,
        output logic rx_ready_0,
        output logic rx_ready_1,
        output logic rx_ready_2,
        output logic rx_ready_3,

        output satswarmv2_pkg::noc_packet_t tx_pkt_0,
        output satswarmv2_pkg::noc_packet_t tx_pkt_1,
        output satswarmv2_pkg::noc_packet_t tx_pkt_2,
        output satswarmv2_pkg::noc_packet_t tx_pkt_3,
        output logic tx_valid_0,
        output logic tx_valid_1,
        output logic tx_valid_2,
        output logic tx_valid_3,
        input  logic tx_ready_0,
        input  logic tx_ready_1,
        input  logic tx_ready_2,
        input  logic tx_ready_3,
    `else
        input  satswarmv2_pkg::noc_packet_t rx_pkt [3:0],
        input  logic rx_valid [3:0],
        output logic rx_ready [3:0],

        output satswarmv2_pkg::noc_packet_t tx_pkt [3:0],
        output logic tx_valid [3:0],
        input  logic tx_ready [3:0],
    `endif

    // ------ Global memory interface (to arbiter) ------ //
    output logic        global_read_req,
    output logic [31:0] global_read_addr,
    output logic [7:0]  global_read_len,
    input  logic        global_read_grant,
    input  logic [31:0] global_read_data,
    input  logic        global_read_valid,

    output logic        global_write_req,
    output logic [31:0] global_write_addr,
    output logic [31:0] global_write_data,
    input  logic        global_write_grant
);

`ifdef SYNTHESIS
    // Rebuild 4-port arrays for internal logic under Yosys
    satswarmv2_pkg::noc_packet_t rx_pkt [3:0];
    logic rx_valid [3:0];
    logic rx_ready [3:0];
    satswarmv2_pkg::noc_packet_t tx_pkt [3:0];
    logic tx_valid [3:0];
    logic tx_ready [3:0];

    assign rx_pkt[0] = rx_pkt_0;
    assign rx_pkt[1] = rx_pkt_1;
    assign rx_pkt[2] = rx_pkt_2;
    assign rx_pkt[3] = rx_pkt_3;
    assign rx_valid[0] = rx_valid_0;
    assign rx_valid[1] = rx_valid_1;
    assign rx_valid[2] = rx_valid_2;
    assign rx_valid[3] = rx_valid_3;
    assign rx_ready_0 = rx_ready[0];
    assign rx_ready_1 = rx_ready[1];
    assign rx_ready_2 = rx_ready[2];
    assign rx_ready_3 = rx_ready[3];

    assign tx_pkt_0 = tx_pkt[0];
    assign tx_pkt_1 = tx_pkt[1];
    assign tx_pkt_2 = tx_pkt[2];
    assign tx_pkt_3 = tx_pkt[3];
    assign tx_valid_0 = tx_valid[0];
    assign tx_valid_1 = tx_valid[1];
    assign tx_valid_2 = tx_valid[2];
    assign tx_valid_3 = tx_valid[3];
    assign tx_ready[0] = tx_ready_0;
    assign tx_ready[1] = tx_ready_1;
    assign tx_ready[2] = tx_ready_2;
    assign tx_ready[3] = tx_ready_3;
`endif

    // =========================================================================
    // TOP-LEVEL INVARIANTS:
    // 1. Strict Serial Loop: The solver operates in a strict VDE -> PSE -> CAE loop.
    //    Concurrency is NOT permitted between these phases to ensure correctness.
    //    - VDE selects a decision.
    //    - PSE propagates implications until stable or conflict.
    //    - CAE analyzes conflicts (if any) and computes backtrack level.
    // 2. Trail Integrity: The Trail is the single source of truth for assignments.
    //    PSE and VDE must stay synchronized with the Trail.
    // 3. Resync Safety: If PSE's internal state diverges from the Trail (e.g., due to
    //    a race condition or stale cache), a full RESYNC_PSE is triggered to restore consistency.
    // =========================================================================

    // Core FSM
    typedef enum logic [4:0] {
        IDLE,
        // INVARIANT: VDE runs only when PSE is done and no conflict exists.
        VDE_PHASE,              // Renamed from PROPAGATE: Request decision from VDE
        VDE_FALLBACK,           // Fallback scan for unassigned variable
        // INVARIANT: PSE runs to completion. Logic must handle "Redundant" vs "Conflicting" props.
        PSE_PHASE,              // Renamed from ACCUMULATE_PROPS: Wait for PSE propagation
        QUERY_CONFLICT_LEVELS,  // NEW: Query decision levels for conflict clause (one per cycle)
        // INVARIANT: CAE runs only after a conflict is confirmed and levels are queried.
        CONFLICT_ANALYSIS,
        BUMP_LEARNED_VARS,      // NEW: Bump activity for all variables in learned clause
        // INVARIANT: Learned clauses are appended to the clause database and immediately used for Resync.
        APPEND_LEARNED,
        APPEND_PUSH,            // NEW: Stable push state to decouple calculation from trail updates
        BACKTRACK_PHASE,
        RESYNC_PSE,
        RESYNC_PSE_SETTLE,
        FINAL_VERIFY,
        SAT_CHECK,
        FINISH_SAT,
        FINISH_UNSAT,
        PSE_START_AFTER_LEARN,
        INJECT_RX_CLAUSE
    } core_state_t;

    core_state_t state_q, state_d;

    // Counters and state
    logic [31:0] cycle_count_q, cycle_count_d;
    logic [15:0] decision_level_q, decision_level_d;
    // PSE Propagation FIFO (Robust Capture)
    // Size to MAX_VARS to avoid dropping propagations in large UNSAT chains.
    localparam int FIFO_DEPTH = MAX_VARS;
    localparam int FIFO_WIDTH = $clog2(FIFO_DEPTH);
    // prop_fifo array removed
    // prop_wr_ptr, prop_rd_ptr removed
    logic prop_fifo_empty;
    logic prop_pop;  // Control signal from FSM
    logic prop_flush; // Flush signal from FSM
    logic signed [47:0] prop_fifo_out; // Output from sfifo (48-bit: 16-bit reason + 32-bit lit)
    logic prop_fifo_full;
    logic [FIFO_WIDTH:0] prop_fifo_count;

    sfifo #(
        .WIDTH(48),
        .DEPTH(FIFO_DEPTH)
    ) u_prop_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .push(pse_propagated_valid && pse_propagated_var != 0),
        .push_data({pse_propagated_reason, pse_propagated_var}),
        .pop(prop_pop),
        .pop_data(prop_fifo_out),
        .full(prop_fifo_full),
        .empty(prop_fifo_empty),
        .count(prop_fifo_count),
        .flush((state_q == IDLE && start_solve) || prop_flush) // Auto-flush on start
    );
    
    logic [3:0]  prop_count_q, prop_count_d;
    logic        conflict_seen_q, conflict_seen_d;
    // Resync iterator for rebuilding PSE assign_state from trail
    logic [31:0] resync_idx_q, resync_idx_d;
    logic        resync_started_q, resync_started_d;
    logic        resync_append_learned_q, resync_append_learned_d;
    
    // Track whether we've started PSE in this propagation round
    // to avoid checking stale conflict_detected from prior rounds
    logic        pse_started_q, pse_started_d;
    
    // Track if we're currently in final SAT verification
    logic        final_verify_mode_q, final_verify_mode_d;
    
    // Edge detection for CAE done signal (since done is a combinatorial pulse)
    logic        cae_done_r_q, cae_done_r_d;
    logic        cae_done_edge;
    
    // Track last decision for backtracking
    logic [31:0] last_decision_var_q, last_decision_var_d;
    logic        last_decision_phase_q, last_decision_phase_d;
    logic        tried_both_phases_q, tried_both_phases_d;
    
    // Count level-0 conflicts to detect UNSAT
    logic [15:0] level0_conflict_count_q, level0_conflict_count_d;
    // Restart counter to avoid livelock in difficult UNSAT cases
    logic [15:0] conflict_counter_q, conflict_counter_d;
    logic [15:0] restart_count_q, restart_count_d;
    logic        verify_mode_q, verify_mode_d;
    // Restart flag asserted when conflict counter crosses threshold
    logic        restart_pending_q, restart_pending_d;

    // Simple conflict-triggered restart threshold (tunable)
    localparam int RESTART_CONFLICT_THRESHOLD = 16'd64; // Enable restarts for long SAT runs
    
    // Loop counter for QUERY_CONFLICT_LEVELS state
    logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]  query_index_q, query_index_d;
    
    // Trail Manager Control
    logic        trail_push;
    logic [31:0] trail_push_var;
    logic        trail_push_value;
    logic [15:0] trail_push_level;
    logic        trail_push_is_decision;
    logic [15:0] trail_push_reason;
    // =========================================================================
    // TRAIL HEIGHT VS DECISION LEVEL
    //
    // Trail Height (`trail_height`):
    //   Represents the total number of variables that are currently assigned
    //   (decided or propagated) on the trail. This is the "length" of the
    //   assignment trail.
    //
    // Decision Level (`decision_level_q`):
    //   Represents the specific depth of the decision tree. It counts how
    //   many "decisions" (guesses) were made to reach the current state.
    //   Variables assigned via propagation at a given decision level do not
    //   increase the decision level, but they DO increase the trail height.
    //
    //   Example:
    //     Level 0: 5 fact propagations (Trail Height = 5)
    //     Level 1: 1 decision + 3 propagations (Trail Height = 9)
    //     Level 2: 1 decision + 0 propagations (Trail Height = 10)
    // =========================================================================
    logic [15:0] trail_height;
    logic [15:0] trail_current_level;
    logic        trail_backtrack_en; // Still used? No, removed in favor of Truncate. Keeping wire for now to avoid breaking inst until updated. 
    logic [15:0] trail_backtrack_level;
    logic        trail_backtrack_done;
    logic        trail_backtrack_valid;
    logic [31:0] trail_backtrack_var;
    logic        trail_backtrack_value;
    logic        trail_backtrack_is_decision;
    
    // NEW: Instant Backtrack Signals
    logic        trail_truncate_en;
    logic [15:0] trail_truncate_level;
    
    logic [31:0] trail_query_var;
    logic [15:0] trail_query_level;
    logic        trail_query_valid;
    logic        trail_query_value;
    logic        trail_clear_all;
    logic [15:0] trail_query_reason; // NEW
    
    // Muxing logic for trail read index (Shared by CAE and RESYNC logic)
    logic [15:0] muxed_trail_read_idx;
    
    // logic [31:0] cae_trail_read_var; // Moved below
    // logic        cae_trail_read_value;
    // logic [15:0] cae_trail_read_level;
    // logic        cae_trail_read_is_decision;
    // logic [15:0] cae_trail_read_reason;
    
    // VDE Control
    logic        vde_request;
    logic        vde_decision_valid;
    logic [31:0] vde_decision_var;
    logic        vde_decision_phase;
    logic [31:0] vde_decision_phase_offset;
    logic        vde_all_assigned;
    logic        vde_assign_valid;
    logic [31:0] vde_assign_var;
    logic        vde_assign_value;
    logic        vde_clear_valid;
    logic [31:0] vde_clear_var;
    logic [31:0] vde_max_var;
    logic        vde_clear_all;
    logic        vde_unassign_all; // NEW: Reset assignments but keep scores

    // Interface unit connection (connect to NoC)
    logic        iface_diverge_req;
    logic [3:0]  iface_diverge_target;
    logic signed [31:0] iface_diverge_lit;
    logic        iface_diverge_ack;

    logic        iface_force_valid;
    logic signed [31:0] iface_force_lit;
    logic        iface_force_ready;

    // PSE module signals
    logic        pse_start;
    logic        pse_done;
    logic        pse_conflict;
    logic        pse_propagated_valid;
    logic signed [31:0] pse_propagated_var;
    logic [31:0] pse_max_var;
    logic        pse_clear_assignments;
    logic        pse_clear_valid;
    logic [31:0] pse_clear_var;
    logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]  pse_conflict_clause_len;
    logic signed [MAX_CLAUSE_LEN-1:0][31:0] pse_conflict_clause;
    logic        pse_inject_req;
    logic signed [31:0] pse_inject_lit1;
    logic signed [31:0] pse_inject_lit2;
    logic        pse_inject_ready;
    
    // PSE assignment broadcast
    logic        pse_assign_broadcast_valid;
    logic [31:0] pse_assign_broadcast_var;
    logic        pse_assign_broadcast_value;
    logic [15:0] pse_assign_broadcast_reason;
    
    // Registered conflict clause (captured when conflict detected)
    logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]  conflict_clause_len_q, conflict_clause_len_d;
    logic signed [MAX_CLAUSE_LEN-1:0][31:0] conflict_clause_q;
    logic signed [MAX_CLAUSE_LEN-1:0][31:0] conflict_clause_d;
    
    // Decision levels for conflict clause literals (queried from trail manager)
    // Decision levels for conflict clause literals (queried from trail manager)
    logic [MAX_CLAUSE_LEN-1:0][15:0] conflict_levels_q;  // Registered decision levels
    logic [MAX_CLAUSE_LEN-1:0][15:0] conflict_levels_d;  // Next-cycle decision levels
    
    // Rescan flag for handling conflicting propagations
    logic        rescan_required_q, rescan_required_d;

    // VDE repeat-decision guard (avoid livelock on already-assigned vars)
    logic [5:0]  vde_repeat_count_q, vde_repeat_count_d;
    logic [31:0] vde_repeat_var_q, vde_repeat_var_d;

    // Fallback scan index for unassigned variable search
    logic [31:0] fallback_idx_q, fallback_idx_d;


    // Learned clause append iterator and muxed host/learned load to PSE
    logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]  learn_idx_q, learn_idx_d;
    logic        learn_load_valid;
    logic signed [31:0] learn_load_literal;
    logic        learn_load_clause_end;
    logic        load_valid_mux;
    logic signed [31:0] load_literal_mux;
    logic        load_clause_end_mux;

    // CAE module signals
    logic        cae_start;
    logic        cae_done;
    logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]  cae_learned_len;
    logic signed [MAX_CLAUSE_LEN-1:0][31:0] cae_learned_lits;
    logic        cae_unsat;
    
    // CAE-PSE Reason Interface
    logic [31:0] cae_reason_query_var;
    logic [15:0] cae_reason_query_clause;
    logic        cae_reason_query_valid;
    
    // CAE-PSE Clause Read Interface
    logic [15:0] cae_clause_read_id;
    logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]  cae_clause_read_idx;
    logic signed [31:0] cae_clause_read_lit;
    logic [15:0] cae_clause_read_len;
    
    // CAE-Trail Read Interface
    // CAE-Trail Read Interface - signals already declared above at lines 188-192

    
    // CAE-Trail Read Interface
    logic [15:0] cae_trail_read_idx;
    logic [31:0] cae_trail_read_var;
    logic        cae_trail_read_value;
    logic [15:0] cae_trail_read_level;
    logic        cae_trail_read_is_decision;
    logic [15:0] cae_trail_read_reason;

    // CAE-Trail Level Query Interface
    logic [31:0] cae_level_query_var;
    logic [15:0] cae_level_query_levels;
    
    // Muxed Trail Query Var (Driven by FSM or CAE)
    logic [31:0] muxed_trail_query_var;
    // Note: trail_query_level output goes to both (or registered)

    // VDE signals
    logic        vde_bump_valid;
    logic [31:0] vde_bump_var;
    logic [4:0]  vde_bump_count;
    logic [15:0][31:0] vde_bump_vars;
    logic        vde_decay;
    logic        vde_busy;
    logic        vde_pending_ops;

    // Current decision literal (signed, includes phase)
    logic signed [31:0] decision_lit_q, decision_lit_d;

    // Bind PSE-observed max variable index into VDE search window
    // This ensures VDE only considers variables that appear in the formula
    assign vde_max_var = pse_max_var;

    // Stats Manager Controls
    logic        stats_inc_cycle, stats_inc_conflict, stats_inc_decision, stats_inc_restart, stats_inc_learned;
    logic        stats_inc_l0_conflict, stats_clear_l0_conflicts;
    logic        stats_clear_restart_counter;
    logic        stats_restart_pending;
    logic [31:0] total_cycles, total_conflicts, total_decisions, total_restarts, total_learned;
    logic [15:0] conflict_counter, level0_conflict_count;

    stats_manager u_stats (
        .clk(clk),
        .rst_n(rst_n),
        .clear_stats(1'b0),
        .inc_cycle(stats_inc_cycle),
        .inc_conflict(stats_inc_conflict),
        .inc_decision(stats_inc_decision),
        .inc_restart(stats_inc_restart),
        .inc_learned(stats_inc_learned),
        .inc_level0_conflict(stats_inc_l0_conflict),
        .clear_level0_conflicts(stats_clear_l0_conflicts),
        .restart_threshold(RESTART_CONFLICT_THRESHOLD),
        .clear_restart_counter(stats_clear_restart_counter),
        .restart_pending(stats_restart_pending),
        .total_cycles(total_cycles),
        .total_conflicts(total_conflicts),
        .total_decisions(total_decisions),
        .total_restarts(total_restarts),
        .total_learned(total_learned),
        .conflict_counter(conflict_counter),
        .level0_conflict_count(level0_conflict_count)
    );

    // Resync Controller Controls
    logic        resync_start, resync_done;
    logic [15:0] resync_trail_rd_idx;
    logic        resync_clear_shadows, resync_fifo_flush;
    logic        resync_valid;
    logic [31:0] resync_var;
    logic        resync_value;

    resync_controller u_resync (
        .clk(clk),
        .rst_n(rst_n),
        .start(resync_start),
        .trail_height(trail_height),
        .done(resync_done),
        .trail_rd_idx(resync_trail_rd_idx),
        .trail_rd_var(cae_trail_read_var),
        .trail_rd_value(cae_trail_read_value),
        .clear_shadows(resync_clear_shadows),
        .fifo_flush(resync_fifo_flush),
        .resync_valid(resync_valid),
        .resync_var(resync_var),
        .resync_value(resync_value)
    );

    // VDE instantiation
    vde #(
        .MAX_VARS(MAX_VARS)
    ) u_vde (
        .DEBUG(DEBUG),
        .clk(clk),
        .reset(!rst_n),
        .request(vde_request),
        .decision_valid(vde_decision_valid),
        .decision_var(vde_decision_var),
        .decision_phase(vde_decision_phase),
        .phase_offset(vde_phase_offset),
        .all_assigned(vde_all_assigned),
        .max_var(vde_max_var),
        .clear_all(vde_clear_all),
        .unassign_all(vde_unassign_all), // NEW
        
        .assign_valid(vde_assign_valid),
        .assign_var(vde_assign_var),
        .assign_value(vde_assign_value),
        
        .clear_valid(vde_clear_valid),
        .clear_var(vde_clear_var),
        
        .bump_valid(vde_bump_valid),
        .bump_var(vde_bump_var),
        .bump_count(vde_bump_count),
        .bump_vars(vde_bump_vars),
        .decay(vde_decay),
        .busy(vde_busy),
        .pending_ops(vde_pending_ops)
    );

    // Architectural Trace: VDE Decision
    always_ff @(posedge clk) begin
        if (DEBUG > 0 && vde_decision_valid) begin
             // Note: Decision Level? trail_current_level available from trail_manager (but laggy?)
             // vde_decision_var is the variable. vde_decision_phase is the sign?
             // vde_decision_phase: 0=Negative (confusing naming? Usually phase=val). 
             // Let's assume standard phase: 1=True, 0=False.
             // But wait, vde decides a literal usually.
             // In vde.sv: output [31:0] decision_var (unsigned index).
             // output decision_phase.
             // We can reconstruct the literal.
             int lit;
             lit = vde_decision_phase ? int'(vde_decision_var) : -int'(vde_decision_var);
             $display("[hw_trace] [VDE] Decided: %0d at Level %0d", lit, trail_current_level + 1); 
             // +1 because decision pushes to next level?
             // mega_sim.py says: len(self.mem.trail_lim) + 1.
        end
    end

    // Muxed Trail Query Var
    // Trail manager query is driven by internal FSM logic usually (trail_query_var).
    // During conflict analysis resolution (BACKTRACK_PHASE), CAE drives it (cae_level_query_var).
    assign muxed_trail_query_var = (state_q == BACKTRACK_PHASE || state_q == CONFLICT_ANALYSIS) ? cae_level_query_var : trail_query_var;
    assign cae_level_query_levels = trail_query_level; // Fanout result to CAE
    
    // MUX Trail Read Index
    // During RESYNC_PSE, the FSM drives the read index via u_resync.
    // Otherwise (IDLE/CONFLICT), CAE drives it.
    assign muxed_trail_read_idx = (state_q == RESYNC_PSE) ? resync_idx_q[15:0] : cae_trail_read_idx;

    // Trail Manager instantiation
    trail_manager #(
        .MAX_VARS(MAX_VARS)
    ) u_trail (
        .DEBUG(DEBUG),
        .clk(clk),
        .reset(!rst_n),
        .push(trail_push),
        .push_var(trail_push_var),
        .push_value(trail_push_value),
        .push_level(trail_push_level),
        .push_is_decision(trail_push_is_decision),
        .push_reason(trail_push_reason),
        .height(trail_height),
        .current_level(trail_current_level),
        .backtrack_en(trail_backtrack_en),
        .backtrack_to_level(trail_backtrack_level),
        .backtrack_done(trail_backtrack_done),
        .backtrack_valid(trail_backtrack_valid),
        .backtrack_var(trail_backtrack_var),
        .backtrack_value(trail_backtrack_value),
        .backtrack_is_decision(trail_backtrack_is_decision),
        .query_var(muxed_trail_query_var),   // MUXED
        .query_level(trail_query_level),     // Output goes to FSM and CAE
        .query_valid(trail_query_valid),
        .query_value(trail_query_value),
        .query_reason(trail_query_reason), // Connect new reason
        .trail_read_idx(muxed_trail_read_idx),        // UPDATED: Muxed source
        .trail_read_var(cae_trail_read_var),
        .trail_read_value(cae_trail_read_value),
        .trail_read_level(cae_trail_read_level),
        .trail_read_is_decision(cae_trail_read_is_decision),
        .trail_read_reason(cae_trail_read_reason), // Connect new reason
        .clear_all(trail_clear_all),
        .truncate_en(trail_truncate_en),           // NEW
        .truncate_level_target(trail_truncate_level) // NEW
    );

    // PSE instantiation
    pse #(
        .MAX_VARS(MAX_VARS),
        .MAX_CLAUSES(MAX_CLAUSES),
        .MAX_LITS(MAX_LITS),
        .MAX_CLAUSE_LEN(MAX_CLAUSE_LEN),
        .CORE_ID(CORE_ID)
    ) u_pse (
        .DEBUG(DEBUG),
        .clk(clk),
        .reset(!rst_n),
        .load_valid(load_valid_mux),
        .load_literal(load_literal_mux),
        .load_clause_end(load_clause_end_mux),
        .load_ready(load_ready),
        .start(pse_start),
        .decision_var(decision_lit_q),
        .done(pse_done),
        .conflict_detected(pse_conflict),
        .propagated_valid(pse_propagated_valid),
        .propagated_var(pse_propagated_var),
        .propagated_reason(pse_propagated_reason), // Connect new output
        .max_var_seen(pse_max_var),
        .clear_assignments(pse_clear_assignments),
        .clear_valid(pse_clear_valid),
        .clear_var(pse_clear_var),
        .assign_broadcast_valid(pse_assign_broadcast_valid),
        .assign_broadcast_var(pse_assign_broadcast_var),
        .assign_broadcast_value(pse_assign_broadcast_value),
        .assign_broadcast_reason(pse_assign_broadcast_reason), // New: Explicit reason
        .conflict_clause_len(pse_conflict_clause_len),
        .conflict_clause(pse_conflict_clause),
        .inject_valid(pse_inject_req),
        .inject_lit1(pse_inject_lit1),
        .inject_lit2(pse_inject_lit2),
        .inject_ready(pse_inject_ready),
        .reason_query_var(cae_reason_query_var),       // NEW: Reason query
        .reason_query_clause(cae_reason_query_clause),
        .reason_query_valid(cae_reason_query_valid),
        .clause_read_id(cae_clause_read_id),           // NEW: Clause read
        .clause_read_lit_idx(cae_clause_read_idx),
        .clause_read_literal(cae_clause_read_lit),
        .clause_read_len(cae_clause_read_len),
        .current_clause_count(pse_clause_count)      // Connect exposed clause count
    );

    logic [15:0] pse_propagated_reason; // NEW wire for reason
    logic [15:0] pse_clause_count; // Signal from PSE
    logic cae_learned_valid;
    logic cae_done_actual;
    logic [15:0] cae_backtrack_level; // Explicit declaration to fix implicit warning
    cae #(
        .MAX_LITS(MAX_CLAUSE_LEN),
        .LEVEL_W(16)
    ) u_cae (
        .DEBUG(DEBUG),
        .clk(clk),
        .reset(!rst_n),
        .start(cae_start),
        .decision_level(decision_level_q),
        .conflict_len(conflict_clause_len_q),
        .conflict_lits(conflict_clause_q),
        .conflict_levels(conflict_levels_q),
        .learned_valid(cae_learned_valid),
        .learned_len(cae_learned_len),
        .learned_clause(cae_learned_lits),
        .backtrack_level(cae_backtrack_level),
        .unsat(cae_unsat),
        .done(cae_done),
        .trail_read_idx(cae_trail_read_idx),        // NEW: Trail interface
        .trail_read_var(cae_trail_read_var),
        .trail_read_value(cae_trail_read_value),
        .trail_read_level(cae_trail_read_level),
        .trail_read_is_decision(cae_trail_read_is_decision),
        .trail_read_reason(cae_trail_read_reason),  // Connect new reason
        .trail_height(trail_height),                // Needed to init scan
        .reason_query_var(cae_reason_query_var),    // NEW: Reason interface
        .reason_query_clause(cae_reason_query_clause),
        .reason_query_valid(cae_reason_query_valid),
        .clause_read_id(cae_clause_read_id),        // NEW: Clause read
        .clause_read_lit_idx(cae_clause_read_idx),
        .clause_read_literal(cae_clause_read_lit),
        .clause_read_len(cae_clause_read_len),
        .level_query_var(cae_level_query_var),      // NEW: Level query
        .level_query_levels(cae_level_query_levels)
    );

    // Interface Unit Control
    logic        iface_clause_bcast_req;
    logic [7:0]  iface_clause_lbd;
    logic [63:0] iface_clause_ptr;
    logic        iface_clause_bcast_ack;
    
    logic        iface_clause_rx_valid;
    logic [7:0]  iface_clause_rx_lbd;
    logic [63:0] iface_clause_rx_ptr;
    logic        iface_clause_rx_ready;

    interface_unit #(
        .CORE_ID(CORE_ID),
        .CORE_ID_W(satswarmv2_pkg::CORE_ID_W)
    ) u_iface (
        .clk(clk),
        .rst_n(rst_n),
        .rx_pkt_n(rx_pkt[3]),
        .rx_pkt_s(rx_pkt[2]),
        .rx_pkt_e(rx_pkt[1]),
        .rx_pkt_w(rx_pkt[0]),
        .rx_valid_n(rx_valid[3]),
        .rx_valid_s(rx_valid[2]),
        .rx_valid_e(rx_valid[1]),
        .rx_valid_w(rx_valid[0]),
        .rx_ready_n(rx_ready[3]),
        .rx_ready_s(rx_ready[2]),
        .rx_ready_e(rx_ready[1]),
        .rx_ready_w(rx_ready[0]),
        .tx_pkt_n(tx_pkt[3]),
        .tx_pkt_s(tx_pkt[2]),
        .tx_pkt_e(tx_pkt[1]),
        .tx_pkt_w(tx_pkt[0]),
        .tx_valid_n(tx_valid[3]),
        .tx_valid_s(tx_valid[2]),
        .tx_valid_e(tx_valid[1]),
        .tx_valid_w(tx_valid[0]),
        .tx_ready_n(tx_ready[3]),
        .tx_ready_s(tx_ready[2]),
        .tx_ready_e(tx_ready[1]),
        .tx_ready_w(tx_ready[0]),
        .diverge_req(iface_diverge_req),
        .diverge_target(iface_diverge_target),
        .diverge_lit(iface_diverge_lit),
        .diverge_ack(iface_diverge_ack),
        .force_valid(iface_force_valid),
        .force_lit(iface_force_lit),
        .force_ready(iface_force_ready),
        .clause_bcast_req(iface_clause_bcast_req),
        .clause_lbd(iface_clause_lbd),
        .clause_ptr(iface_clause_ptr),
        .clause_bcast_ack(iface_clause_bcast_ack),
        .clause_rx_valid(iface_clause_rx_valid),
        .clause_rx_lbd(iface_clause_rx_lbd),
        .clause_rx_ptr(iface_clause_rx_ptr),
        .clause_rx_ready(iface_clause_rx_ready)
    );

    // RX Arbitration Pointer (Sequential)
    logic [1:0] rr_ptr_q, rr_ptr_d;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) rr_ptr_q <= 2'b00;
        else        rr_ptr_q <= rr_ptr_d;
    end

    // Main FSM
    always_comb begin
        // Declare temporary variables to avoid synthesis/lint errors (must be at top of block)
        logic signed [31:0] lit;
        logic [31:0] var_idx;
        logic [31:0] prop_var;
        logic       prop_already_assigned;
        logic       existing_value;
        logic       new_value;

        logic [31:0]        assert_var;
        logic signed [31:0] final_assert_lit;
        logic               skip_broadcast;
        
        // NEW: Pull up FIFO temporaries to avoid latches
        logic signed [31:0] fifo_lit;
        logic [15:0]        fifo_reason;

        state_d          = state_q;
        decision_level_d = decision_level_q;
        prop_count_d     = prop_count_q;
        conflict_seen_d  = conflict_seen_q;
        decision_lit_d   = decision_lit_q;
        pse_started_d    = pse_started_q;
        last_decision_var_d = last_decision_var_q;
        last_decision_phase_d = last_decision_phase_q;
        tried_both_phases_d = tried_both_phases_q;
        verify_mode_d           = verify_mode_q;
        final_verify_mode_d     = final_verify_mode_q;
        
        // Fix Latches by assigning defaults
        cycle_count_d           = cycle_count_q;
        resync_started_d        = resync_started_q;
        resync_append_learned_d = resync_append_learned_q;
        resync_idx_d            = resync_idx_q;
        restart_pending_d       = restart_pending_q;
        restart_count_d         = restart_count_q;
        conflict_counter_d      = conflict_counter_q;
        level0_conflict_count_d = level0_conflict_count_q;

        // Default MUX behavior (Passthrough external load interface)
        load_valid_mux          = load_valid;
        load_literal_mux        = load_literal;
        load_clause_end_mux     = load_clause_end;
        
        query_index_d           = query_index_q;
        learn_idx_d             = learn_idx_q;
        conflict_clause_len_d   = conflict_clause_len_q;
        for (int k=0; k<MAX_CLAUSE_LEN; k++) begin
             conflict_levels_d[k] = conflict_levels_q[k];
             conflict_clause_d[k] = conflict_clause_q[k];
        end
        rescan_required_d       = rescan_required_q;
        
        cae_start               = 1'b0; // Pulse default
        pse_start               = 1'b0; // Pulse default
        cae_done_r_d = cae_done;
        cae_done_edge = cae_done && !cae_done_r_q;  // Rising edge
        
        query_index_d = query_index_q;  // Default: preserve
        learn_idx_d = learn_idx_q;  // Default: preserve
        rescan_required_d = rescan_required_q;
        conflict_clause_len_d = conflict_clause_len_q;
        for (int k = 0; k < 8; k++) begin
            conflict_clause_d[k] = conflict_clause_q[k];
            conflict_levels_d[k] = conflict_levels_q[k];  // Default: preserve current
        end

        // Stats Manager Defaults
        stats_inc_cycle             = (state_q != IDLE);
        stats_inc_conflict          = 1'b0;
        stats_inc_decision          = 1'b0;
        stats_inc_restart           = 1'b0;
        stats_inc_learned           = 1'b0;
        stats_inc_l0_conflict       = 1'b0;
        stats_clear_l0_conflicts    = 1'b0;
        stats_clear_restart_counter = 1'b0;

        // Resync Controller Defaults
        resync_start = 1'b0;

        // VDE repeat-decision guard defaults
        vde_repeat_count_d = vde_repeat_count_q;
        vde_repeat_var_d   = vde_repeat_var_q;
        fallback_idx_d     = fallback_idx_q;

        // Initialize temporary variables (prevent latches)
        lit = '0;
        var_idx = '0;
        prop_var = '0;
        prop_already_assigned = 1'b0;
        existing_value = 1'b0;
        new_value = 1'b0;
        assert_var = '0;
        final_assert_lit = '0;
        skip_broadcast = 1'b0;
        fifo_lit = 32'd0;
        fifo_reason = 16'd0;

        solve_done       = 1'b0;
        is_sat           = 1'b0;
        is_unsat         = 1'b0;

        pse_start        = 1'b0;
        cae_start        = 1'b0;
        
        // Trail manager defaults (query is combinational, always active)
        trail_push = 1'b0;
        trail_push_var = '0;
        trail_push_value = 1'b0;
        trail_push_level = decision_level_q;
        trail_push_is_decision = 1'b0;
        trail_push_reason = 16'hFFFF; // Default reason (decision/unknown)
        trail_backtrack_en = 1'b0;
        trail_backtrack_level = '0;
        trail_clear_all = 1'b0;
        trail_truncate_en = 1'b0;
        trail_truncate_level = '0;
        trail_query_var = '0;  
        
        // PSE assignment broadcast: announce all assignments (decisions + propagations)
        pse_assign_broadcast_valid = 1'b0;
        pse_assign_broadcast_var = '0;
        pse_assign_broadcast_value = 1'b0;
        pse_assign_broadcast_reason = 16'hFFFF;

        // Learned clause load defaults
        learn_load_valid      = 1'b0;
        learn_load_literal    = '0;
        learn_load_clause_end = 1'b0;

        // Global memory stubs
        global_read_req        = 1'b0;
        global_read_addr       = '0;
        global_read_len        = '0;
        global_write_req       = 1'b0;
        global_write_addr      = '0;
        global_write_data      = '0;

        // NoC stubs
        for (int i = 0; i < 4; i++) begin
            tx_valid[i] = 1'b0;
            tx_pkt[i]   = '0;
        end
        
        // RX Arbitration and Injection Logic (Managed by u_iface)
        rr_ptr_d = rr_ptr_q + 1'b1;
        
        pse_inject_req  = 1'b0;
        pse_inject_lit1 = '0;
        pse_inject_lit2 = '0;
        
        pse_clear_valid = 1'b0;
        pse_clear_var = '0;
        
        pse_clear_assignments = resync_clear_shadows;
        
        iface_clause_rx_ready = 1'b0;
        iface_force_ready     = 1'b0; 
        
        // If we are IDLE or PROPAGATE, we can accept a new clause
        if (state_q == IDLE || state_q == VDE_PHASE || state_q == PSE_PHASE) begin
            if (iface_clause_rx_valid) begin
                // Preview the clause - if we are in PSE_PHASE, we can inject it
                // after the current scan finishes or by jumping to INJECT_RX_CLAUSE.
                // For simplicity, we trigger injection via state machine.
            end
        end

        // Interface stubs
        iface_diverge_req      = 1'b0;
        iface_diverge_target   = 4'h0;
        iface_diverge_lit      = 32'h0;
        iface_force_ready      = 1'b1;
        iface_clause_bcast_req = 1'b0;
        iface_clause_lbd       = 8'h0;
        iface_clause_ptr       = 64'h0;

        // VDE defaults
        vde_request       = 1'b0;
        vde_assign_valid  = 1'b0;
        vde_assign_var    = '0;
        vde_assign_value  = 1'b0;
        vde_clear_all     = 1'b0;
        vde_clear_valid   = 1'b0;
        vde_clear_var     = '0;
        vde_bump_valid    = 1'b0;
        vde_bump_var      = '0;
        vde_bump_count    = '0;
        for (int k = 0; k < 16; k++) begin
            vde_bump_vars[k] = '0;
        end
        vde_decay         = 1'b0;
        vde_unassign_all  = 1'b0; // Default low
        pse_clear_assignments = 1'b0;
        
        // FIFO control defaults
        prop_pop = 1'b0;
        prop_flush = 1'b0;
        // prop_fifo_empty is driven by sfifo module

        case (state_q)
            IDLE: begin
                trail_clear_all = 1'b1; // Maintain reset state while IDLE
                vde_clear_all = 1'b1;
                pse_clear_assignments = 1'b1;
                resync_append_learned_d = 1'b0;
                vde_repeat_count_d = '0;
                vde_repeat_var_d   = '0;
                fallback_idx_d     = 32'd1;
                if (start_solve) begin
                    state_d = VDE_PHASE;
                    decision_level_d = '0;
                    prop_count_d = '0;
                    conflict_seen_d = 1'b0;
                    pse_started_d = 1'b0; // Clear PSE started flag for new solve
                    tried_both_phases_d = 1'b0;
                    level0_conflict_count_d = '0; // Reset conflict counter
                    conflict_counter_d = '0;
                    restart_pending_d = 1'b0;
                    trail_clear_all = 1'b1;
                    vde_clear_all = 1'b1;
                    pse_clear_assignments = 1'b1;
                    resync_append_learned_d = 1'b0;
                    $strobe("[CORE %0d] Starting Solve. max_var=%0d, clauses=%0d", CORE_ID, vde_max_var, pse_clause_count);
                    verify_mode_d = 1'b0;
                end
            end

            // STRICT SERIALIZATION: VDE runs only when PSE is done and no conflict
            // INVARIANT: VDE is the only source of "Decision" assignments.
            // All other assignments must clearly originate from Propagation (PSE) or Learning (CAE).
            VDE_PHASE: begin
                conflict_seen_d = 1'b0; // reset conflict latch for new round
                prop_count_d    = '0;
                pse_started_d   = 1'b0; // Reset for this propagation round
                
                // Check if we need to RESCAN the current decision due to a conflicting propagation
                // This happens when PSE generates a prop that conflicts with the trail (e.g. 1=T, Prop=-1)
                // This indicates a conflict that PSE missed because it acted on stale assignment state.
                // Restarting the scan (with current assignment state) will force PSE to see the conflict.
                if (stats_restart_pending) begin
                    // Conflict-driven restart: backtrack to level 0 and resync
                    stats_inc_restart = 1'b1;
                    stats_clear_restart_counter = 1'b1;
                    decision_level_d = 16'd0;
                    trail_truncate_en = 1'b1;
                    trail_truncate_level = 16'd0;
                    vde_unassign_all = 1'b1;
                    pse_clear_assignments = 1'b1;
                    resync_started_d = 1'b0;
                    resync_idx_d     = 32'd0;
                    resync_append_learned_d = 1'b0;
                    rescan_required_d = 1'b0;
                    prop_flush = 1'b1;
                    state_d = RESYNC_PSE;
                end else if (rescan_required_q) begin
                     resync_started_d  = 1'b0;
                     resync_idx_d       = 32'd0;
                     rescan_required_d  = 1'b0; // Clear flag
                     resync_append_learned_d = 1'b0;
                     state_d            = RESYNC_PSE;
                end else begin
                    // Request a decision from VDE
                    vde_request = !vde_pending_ops;
    
                    if (vde_decision_valid) begin
                        // Guard: If VDE returns a var already assigned on the trail,
                        // sync VDE (and optionally PSE) and request a new decision
                        trail_query_var = vde_decision_var;
                        if (trail_query_valid) begin
                            vde_request = 1'b0; // Pause decision requests to let VDE absorb assignments

                            // Track repeat decisions to avoid livelock
                            if (vde_decision_var == vde_repeat_var_q) begin
                                vde_repeat_count_d = vde_repeat_count_q + 1'b1;
                            end else begin
                                vde_repeat_var_d   = vde_decision_var;
                                vde_repeat_count_d = 6'd1;
                            end

                            if (vde_repeat_count_q >= 6'd16) begin
                                // Fallback to a direct scan for an unassigned variable
                                vde_repeat_count_d = '0;
                                vde_repeat_var_d   = '0;
                                fallback_idx_d     = 32'd1;
                                state_d = VDE_FALLBACK;
                            end else begin
                                vde_assign_valid = 1'b1;
                                vde_assign_var   = vde_decision_var;
                                vde_assign_value = trail_query_value;

                                // Keep PSE in sync if its shadow state is stale
                                pse_assign_broadcast_valid = 1'b1;
                                pse_assign_broadcast_var   = vde_decision_var;
                                pse_assign_broadcast_value = trail_query_value;

                                state_d = VDE_PHASE;
                            end
                        end else begin
                            vde_repeat_count_d = '0;
                            vde_repeat_var_d   = '0;
                            // Capture decision literal with saved phase
                            decision_lit_d = vde_decision_phase ? $signed(vde_decision_var) : -$signed(vde_decision_var);

                            // [DEBUG TRACE] Log moved to always_ff

                            // Track this decision for potential backtracking
                            last_decision_var_d = vde_decision_var;
                            last_decision_phase_d = vde_decision_phase;
                            
                            // Broadcast decision to PSE so it stays in sync
                            pse_assign_broadcast_valid = 1'b1;
                            pse_assign_broadcast_var   = vde_decision_var;
                            pse_assign_broadcast_value = vde_decision_phase;
                            
                            // Mark decision assignment in VDE
                            vde_assign_valid = 1'b1;
                            vde_assign_var   = vde_decision_var;
                            vde_assign_value = vde_decision_phase;
                            
                            // Push decision to trail at INCREMENTED level
                            // This allows level 0 for unit propagations, and first decision at level 1
                            trail_push = 1'b1;

                            trail_push_var = vde_decision_var;
                            trail_push_value = vde_decision_phase;
                            trail_push_level = decision_level_q + 1'b1;
                            trail_push_is_decision = 1'b1;
                            
                            // Increment decision level immediately
                            decision_level_d = decision_level_q + 1'b1;
                            
                            // Start PSE propagation with chosen decision
                            pse_start     = 1'b1;
                            pse_started_d = 1'b1; // Mark that we've started PSE in this round
                            cycle_count_d = '0;
                            state_d       = PSE_PHASE; // CRITICAL FIX: Transition to PSE scanning!
                        end
                    end else if (vde_all_assigned) begin
                        vde_repeat_count_d = '0;
                        vde_repeat_var_d   = '0;
                        // Nothing left to decide; run final verification
                        $strobe("[CORE %0d] VDE_PHASE: All assigned, max_var=%0d", CORE_ID, vde_max_var);
                        state_d = FINAL_VERIFY;
                    end else begin
                        // Wait for VDE to issue a decision
                        state_d = VDE_PHASE;
                    end
                end
            end

            // Fallback: linear scan for an unassigned variable if VDE repeats
            VDE_FALLBACK: begin
                // Default to start at 1 if uninitialized
                if (fallback_idx_q == 0) begin
                    fallback_idx_d = 32'd1;
                end

                if (vde_max_var == 0) begin
                    // No variables known, move to final verify
                    state_d = FINAL_VERIFY;
                end else if (fallback_idx_q > vde_max_var) begin
                    // All vars assigned
                    state_d = FINAL_VERIFY;
                    fallback_idx_d = 32'd1;
                end else begin
                    trail_query_var = fallback_idx_q;
                    if (!trail_query_valid) begin
                        // Use fallback decision with positive phase
                        decision_lit_d = $signed(fallback_idx_q);
                        last_decision_var_d = fallback_idx_q;
                        last_decision_phase_d = 1'b1;

                        // Broadcast decision to PSE and update VDE
                        pse_assign_broadcast_valid = 1'b1;
                        pse_assign_broadcast_var   = fallback_idx_q;
                        pse_assign_broadcast_value = 1'b1;

                        vde_assign_valid = 1'b1;
                        vde_assign_var   = fallback_idx_q;
                        vde_assign_value = 1'b1;

                        // Push decision to trail
                        trail_push = 1'b1;
                        trail_push_var = fallback_idx_q;
                        trail_push_value = 1'b1;
                        trail_push_level = decision_level_q + 1'b1;
                        trail_push_is_decision = 1'b1;

                        decision_level_d = decision_level_q + 1'b1;
                        pse_start     = 1'b1;
                        pse_started_d = 1'b1;
                        cycle_count_d = '0;
                        state_d       = PSE_PHASE;
                        fallback_idx_d = 32'd1;
                    end else begin
                        // Move to next var
                        fallback_idx_d = fallback_idx_q + 1'b1;
                        state_d = VDE_FALLBACK;
                    end
                end
            end

            // STRICT SERIALIZATION: PSE runs while VDE is waiting (vde_request=0)
            // INVARIANT: PSE output must be checked against Trail.
            // - If PropVar is Unassigned: Valid propagation.
            // - If PropVar is Assigned Same Value: Redundant (safe).
            // - If PropVar is Assigned Diff Value: Conflict (must trigger Resync).
            PSE_PHASE: begin
                // CRITICAL FIX: Only check pse_conflict if we've started PSE in this round
                // This prevents checking stale conflict_detected from prior propagation rounds
                if (state_q == FINAL_VERIFY || state_q == RESYNC_PSE_SETTLE) begin
                    $strobe("[CORE %0d] PSE_PHASE from %s, pse_done=%b, pse_conflict=%b", 
                             CORE_ID, (state_q == FINAL_VERIFY ? "FINAL_VERIFY" : "RESYNC_PSE_SETTLE"), pse_done, pse_conflict);
                end
                if (pse_started_q && pse_conflict) begin
//                    $strobe("[CORE %0d Cycle %0d] Conflict from PSE detected! Len=%0d Lits={%0d, %0d, %0d, ...}", 
//                             CORE_ID, cycle_count_q, pse_conflict_clause_len, 
//                             pse_conflict_clause[0], pse_conflict_clause[1], pse_conflict_clause[2]);
                    conflict_seen_d = 1'b1;
                    // Capture conflict clause from PSE immediately
                    conflict_clause_len_d = pse_conflict_clause_len;
                    for (int k = 0; k < 8; k++) begin
                        conflict_clause_d[k] = pse_conflict_clause[k];
                    end
                end

                // Accumulate propagated literals from PSE (Using FIFO)
                if (!prop_fifo_empty) begin
                    // CRITICAL FIX: Check if variable is already assigned before propagating
                    // Use FIFO output
                    // prop_var, others declared at top level
                    // logic signed [31:0] fifo_lit; // MOVED TO TOP
                    // logic [15:0] fifo_reason;     // MOVED TO TOP
                    
                    fifo_lit = prop_fifo_out[31:0];
                    fifo_reason = prop_fifo_out[47:32];
                    
                    prop_var = (fifo_lit < 0) ? -fifo_lit[31:0] : fifo_lit[31:0];
                    
                    // Consume from FIFO
                    prop_pop = 1'b1;

                    // Guard: ignore invalid literal 0 entries (should never occur)
                    if (prop_var == 0) begin
                        // Do not propagate or update trail on invalid literal
                    end else begin
                    
                    // Query trail to see if this variable is already assigned
                    trail_query_var = prop_var;
                    prop_already_assigned = trail_query_valid;
                    
                    if (!prop_already_assigned) begin
                        // Variable not yet assigned, proceed with propagation
                        // accumulated_props update removed/dead
                        prop_count_d = prop_count_q + 1'b1;
                        // $strobe("[CORE %0d] Propagation %0d: var=%0d", CORE_ID, fifo_lit);
                        
                        // Inform VDE of assignment
                        vde_assign_valid = 1'b1;
                        vde_assign_var   = prop_var;
                        vde_assign_value = (fifo_lit > 0);
                        
                        // Push propagation to trail
                        trail_push = 1'b1;
                        trail_push_var = prop_var;
                        trail_push_value = (fifo_lit > 0);
                        trail_push_level = decision_level_q;
                        trail_push_is_decision = 1'b0;
                        trail_push_reason = fifo_reason; // Use reason from PSE
                        if (DEBUG > 0) $strobe("[CORE %0d] Pushing Prop %0d (Var %0d) @ Level %0d. DecLvlQ=%0d", CORE_ID, fifo_lit, prop_var, trail_push_level, decision_level_q);


                        // IMPORTANT: We do NOT broadcast back to PSE here.
                        // PSE already knows its own propagation.
                        // Sending it back during a scan can cause races.
                    end else begin
                        // Variable already assigned. 
                        // CRITICAL FIX: Distinguish between Redundant and Conflicting propagations.
                        
                         // existing_value, new_value declared at top level
                        existing_value = trail_query_value;
                        new_value     = (fifo_lit > 0);
                        
                        if (existing_value == new_value) begin
                            // REDUNDANT: Variable already has this value.
                            // Keep PSE in sync if its shadow state is stale.
                            pse_assign_broadcast_valid  = 1'b1;
                            pse_assign_broadcast_var    = prop_var;
                            pse_assign_broadcast_value  = existing_value;
                            pse_assign_broadcast_reason = fifo_reason;
                        end else begin
                            // CONFLICT: PSE wants to set X to !V, but Trail says X=V.
                            // This implies the clause generating this propagation is actually a CONFLICT clause.
                            // PSE missed this because it had stale state (thought X was unassigned).
                            // ACTION: Force re-broadcast of the TRUE value to PSE, then RESCAN.
                            // The Rescan will force PSE to re-evaluate the clause with the correct value, raising a conflict.
                            // synopsys translate_off
                            if (DEBUG > 0) $strobe("[CORE %0d] CONFLICT PROP: var=%0d existing=%0d new=%0d reason=%0d", CORE_ID, prop_var, existing_value, new_value, fifo_reason);
                            // synopsys translate_on
                            
                            // Re-broadcast the correct existing value to PSE
                            pse_assign_broadcast_valid = 1'b1;
                            pse_assign_broadcast_var   = prop_var;
                            pse_assign_broadcast_value = existing_value;
                            
                            // Trigger full rescan to catch the conflict
                            rescan_required_d = 1'b1;
                        end
                    end
                    end
                end
                
                cycle_count_d = cycle_count_q + 1'b1;
                
                // If PSE is done or timeout, check if we need to continue propagating
                // UPDATED: Wait for FIFO to be empty as well!
                if ((pse_done && prop_fifo_empty) || cycle_count_q > 1000000) begin
                    if (state_q == FINAL_VERIFY || state_q == RESYNC_PSE_SETTLE) begin
                         $strobe("[CORE %0d Cycle %0d] PSE_PHASE exit: pse_done=%b, fifo_empty=%b, vde_all_assigned=%b, conflict=%b", 
                                  CORE_ID, cycle_count_q, pse_done, prop_fifo_empty, vde_all_assigned, pse_conflict);
                    end
                    
                    // Multi-core: Check if any neighbor sent us a clause during propagation
                    if (iface_clause_rx_valid) begin
                        state_d = INJECT_RX_CLAUSE;
                    end else if (final_verify_mode_q && !pse_conflict && !conflict_seen_q) begin
                        // Final verification passed: no conflicts during last PSE scan
                        state_d = SAT_CHECK;
                    end else if (vde_all_assigned && pse_done && !pse_conflict && !conflict_seen_q) begin
                        // All vars assigned, PSE done, no conflicts -> Now run final verification
                        state_d = FINAL_VERIFY;
                        // Removed buggy vde_all_assigned "short circuit" block
                        // Conflicts must be processed even if all vars are assigned.
                        // Valid completion is handled by the check above (line 988 in original).

                    end else if (pse_started_q && (conflict_seen_q || pse_conflict)) begin
                        // Conflict detected and variables remain unassigned
                        // $strobe("[CORE %0d] Conflict detected in ACCUMULATE. pse_started=%d seen=%d conflict=%d", CORE_ID, pse_started_q, conflict_seen_q, pse_conflict);
                        state_d = QUERY_CONFLICT_LEVELS;
                        query_index_d = 4'd0;
                    end else begin
                        if (cycle_count_q > 1000000) begin
                            // Timeout: Force RESYNC to ensure PSE state is clean before next decision
//                            $strobe("[CORE %0d] Timeout: Resyncing PSE state before continuing.", CORE_ID);
                            resync_started_d = 1'b0;
                            resync_idx_d     = 32'd0;
                            resync_append_learned_d = 1'b0;
                            state_d          = RESYNC_PSE;
                        end else begin
                            // PSE finished cleanly with no actions -> Ready for next decision
                            state_d = VDE_PHASE;
                        end
                    end
                end
            end

            QUERY_CONFLICT_LEVELS: begin
                // Sequentially query decision levels for each conflict clause literal
                if (query_index_q < conflict_clause_len_q) begin
                    logic signed [31:0] q_lit;
                    logic [31:0] q_var;
                    
                    // Local variables for clarity
                    q_lit = conflict_clause_q[query_index_q];
                    q_var = (q_lit < 0) ? $unsigned(-q_lit) : $unsigned(q_lit);
                    
                    // Drive Query Interface
                    trail_query_var = q_var;
                    
                    // Capture Result
                    if (trail_query_valid) begin
                        conflict_levels_d[query_index_q] = trail_query_level;
                        if (DEBUG > 0) $strobe("[CORE %0d] QUERY_LEVEL: Lit=%0d Var=%0d -> Level=%0d", 
                                CORE_ID, q_lit, q_var, trail_query_level);
                        // Advance
                        query_index_d = query_index_q + 4'd1;
                    end else begin
                        // If not found in trail, assume current level (should not happen for valid conflict)
                        // Or if 0, implies unassigned?
                        if (DEBUG > 0) $strobe("[CORE %0d] QUERY_LEVEL: Lit=%0d Var=%0d -> INVALID (Using DecLvl=%0d)", 
                                CORE_ID, q_lit, q_var, decision_level_q);
                        conflict_levels_d[query_index_q] = decision_level_q;
                        query_index_d = query_index_q + 4'd1;
                    end
                    
                    state_d = QUERY_CONFLICT_LEVELS; // Stay in loop
                end else begin
                    // All queries done
                    query_index_d = 4'd0;
                    state_d = CONFLICT_ANALYSIS;
                end
            end

            // INVARIANT: CAE must resolve the conflict until the First UIP is found.
            // This guarantees that the learned clause is empowering (prevents the same search path).
            CONFLICT_ANALYSIS: begin
                // Removed buggy vde_all_assigned block. Backtracking is required.
                begin
                // Start CAE to analyze conflict with populated conflict_levels_q from queries
                // Log moved to always_ff
/*
                for (int k = 0; k < 8; k++) begin
                    if (k < conflict_clause_len_q)
                        $strobe("[CORE %0d]   Lit[%0d]=%0d level=%0d", CORE_ID, k, conflict_clause_q[k], conflict_levels_q[k]);
                end
*/
                
                cae_start = 1'b1;
                stats_inc_conflict = 1'b1; // Fix: Increment conflict counter
                conflict_seen_d = 1'b0;
                prop_count_d = '0;
                state_d = BACKTRACK_PHASE;
                end  // Close the else (vde_all_assigned)
            end

            // INVARIANT: Backtracking must clear ALL assignments above the target level.
            // The Trail is the authority; PSE/VDE caches are cleared in sync.
            BACKTRACK_PHASE: begin
                // Wait for CAE to complete
                if (cae_done_edge) begin
                    // Check for UNSAT
                    if (cae_unsat || cae_learned_len == 4'h0 || (conflict_clause_q[0] == 0 && conflict_clause_q[1] == 0)) begin
                        state_d = FINISH_UNSAT;
                    end else begin
                        // Flush FIFO
                        prop_flush = 1'b1;

                        // Bump variables
                        vde_bump_count = cae_learned_len;
                        for (int i = 0; i < 16; i++) begin
                            if (i < cae_learned_len) begin
                                vde_bump_vars[i] = (cae_learned_lits[i] < 0) ? 
                                                  $unsigned(-cae_learned_lits[i]) : 
                                                  $unsigned(cae_learned_lits[i]);
                            end else begin
                                vde_bump_vars[i] = '0;
                            end
                        end
                        vde_decay = 1'b1;

                        // INSTANT BACKTRACK
                        decision_level_d = cae_backtrack_level;
                        trail_truncate_en = 1'b1;
                        trail_truncate_level = cae_backtrack_level;
                        vde_unassign_all = 1'b1;
                        pse_clear_assignments = 1'b1;

                        // Replay
                        resync_started_d = 1'b0;
                        resync_idx_d     = 32'd0;
                        learn_idx_d      = 4'd0; // CRITICAL FIX: Reset learned clause index
                        rescan_required_d = 1'b0;
                        resync_append_learned_d = 1'b1;
                        state_d          = RESYNC_PSE;
                    end
                end
            end

            // Stream learned clause into PSE via internal load interface (append-only)
            APPEND_LEARNED: begin
                if (DEBUG > 0) $strobe("[CORE %0d] Entering APPEND_LEARNED. Len=%0d Idx=%0d", CORE_ID, cae_learned_len, learn_idx_q);
                if (learn_idx_q < cae_learned_len) begin
                    // Respect PSE load_ready before sending next literal
                    if (load_ready) begin
                        learn_load_valid      = 1'b1;
                        learn_load_literal    = cae_learned_lits[learn_idx_q];
                        learn_load_clause_end = (learn_idx_q == (cae_learned_len - 4'd1));
                        learn_idx_d           = learn_idx_q + 4'd1;
                        if (DEBUG > 0) $strobe("[CORE %0d] APPEND_LEARNED[%0d/%0d]: lit=%0d end=%0d ready=%0d mux=%0d", CORE_ID, learn_idx_q, cae_learned_len, cae_learned_lits[learn_idx_q], learn_load_clause_end, load_ready, load_valid_mux);
                    end else begin
                        if (DEBUG > 0) $strobe("[CORE %0d] APPEND_LEARNED waiting for load_ready (idx=%0d len=%0d)", CORE_ID, learn_idx_q, cae_learned_len);
                    end
                    state_d = APPEND_LEARNED;
                end else begin : append_complete_block
                    // logic [31:0] assert_var;
                    // logic signed [31:0] final_assert_lit;
                    // logic skip_broadcast;
                    
                    final_assert_lit = (cae_learned_len > 0) ? cae_learned_lits[0] : decision_lit_q;
                    if (DEBUG > 0) $strobe("[CORE %0d] APPEND_LEARNED_CALC: Len=%0d Lit0=%0d DecLit=%0d", CORE_ID, cae_learned_len, cae_learned_lits[0], decision_lit_q);
                    assert_var = (final_assert_lit < 0) ? $unsigned(-final_assert_lit) : $unsigned(final_assert_lit);
                    
                    // Skip broadcast for 1x1 grid (no neighbors to receive)
                    skip_broadcast = (GRID_X == 1 && GRID_Y == 1);
                    
                    // ATOMIC BROADCAST TRIGGER
                    // If learned clause is length 2 AND we have neighbors, broadcast it to mesh
                    // ATOMIC BROADCAST TRIGGER
                    // If learned clause is length 2 AND we have neighbors, broadcast it to mesh
                    if (cae_learned_len == 16'd2 && !skip_broadcast) begin
                        iface_clause_bcast_req = 1'b1;
                        iface_clause_lbd       = 8'd2; // Binary clauses are high quality
                        iface_clause_ptr       = {cae_learned_lits[0], cae_learned_lits[1]}; // Pack 2 lits
                        
                        // Wait for ack if mesh is back-pressured (multi-cycle tx)
                        if (!iface_clause_bcast_ack) begin
                             state_d = APPEND_LEARNED;
                        end else begin
                             // Broadcast Executed. Proceed to PUSH state.
                             // Latch inputs now to decouple from combinational glitches
                             decision_lit_d = final_assert_lit;
                             
                             if (DEBUG > 0) $strobe("[CORE %0d] APPEND_LEARNED_CALC (Broadcast): Len=%0d Lit0=%0d DecLit=%0d -> Pushing To Register", 
                                     CORE_ID, cae_learned_len, cae_learned_lits[0], decision_lit_q);
                             
                             state_d = APPEND_PUSH;
                             cycle_count_d = '0; 
                             restart_pending_d = 1'b0;
                        end
                    end else begin
                        // No Broadcast needed. Proceed to PUSH state.
                        decision_lit_d = final_assert_lit;
                        
                        if (DEBUG > 0) $strobe("[CORE %0d] APPEND_LEARNED_CALC (Local): Len=%0d Lit0=%0d DecLit=%0d -> Pushing To Register", 
                                CORE_ID, cae_learned_len, cae_learned_lits[0], decision_lit_q);

                        state_d = APPEND_PUSH;
                        cycle_count_d = '0; 
                        restart_pending_d = 1'b0;
                    end
                end
            end
            
            // NEW STATE: APPEND_PUSH
            // Executes one cycle after APPEND_LEARNED
            // Uses STABLE register values (decision_lit_q) driven from previous cycle.
            // Glitch-free by design.
            APPEND_PUSH: begin
                 logic [31:0] stable_var;
                 logic        stable_val;
                 
                 stable_var = (decision_lit_q < 0) ? $unsigned(-decision_lit_q) : $unsigned(decision_lit_q);
                 stable_val = (decision_lit_q > 0);
                 
                 // GUARD: Only execute push ONCE (when cycle_count is 0)
                 // This prevents duplicate pushes if the FSM stalls or executes twice.
                 if (cycle_count_q == 0) begin
                     if (DEBUG > 0) $strobe("[CORE %0d] APPEND_PUSH: Executing Push with Stable Lit %0d (Var %0d)", CORE_ID, decision_lit_q, stable_var);
                     
                     // 1. Start PSE for BCP
                     state_d = PSE_PHASE;
                     pse_start = 1'b1;
                     pse_started_d = 1'b1;
                     
                     // 2. Drive Trail & VDE & PSE Broadcast
                     // Explicitly set trail_push_reason to the new learned clause ID
                     if (stable_var != 0) begin
                         trail_push = 1'b1;
                         trail_push_var = stable_var;
                         trail_push_value = stable_val;
                         trail_push_level = decision_level_q;
                         trail_push_is_decision = 1'b0;
                         trail_push_reason = pse_clause_count - 16'd1; // Valid Learned Clause ID
                         
                         vde_assign_valid = 1'b1;
                         vde_assign_var = stable_var;
                         vde_assign_value = stable_val;
                         
                         pse_assign_broadcast_valid = 1'b1;
                         pse_assign_broadcast_var = stable_var;
                         pse_assign_broadcast_value = stable_val;
                     end else begin
                         // EmerGen/Abort if var is 0 (Unexpected, but safe)
                         $display("[CORE %0d] ERROR: APPEND_PUSH derived Var 0 from Lit %0d", CORE_ID, decision_lit_q);
                     end
                     
                     // Increment cycle count so we don't push again if we stay in this state
                     cycle_count_d = 32'd1;
                 end else begin
                     // Retrying/Stuck in state. Force transition.
                     state_d = PSE_PHASE;
                     pse_start = 1'b1;
                     pse_started_d = 1'b1;
                 end
            end

// Merged into first BACKTRACK_PHASE block
            
            // BACKTRACK_UNDO STATE REMOVED - Logic merged into BACKTRACK_PHASE + RESYNC_PSE

            PSE_START_AFTER_LEARN: begin
                // Force full resync to ensure PSE is 100% consistent with Trail
                // including the newly appended literal.
                resync_started_d = 1'b0;
                resync_idx_d     = 32'd0;
                rescan_required_d = 1'b0;
                resync_append_learned_d = 1'b1;
                state_d          = RESYNC_PSE;
            end
            
            // INVARIANT: When RESYNC_PSE is triggered, PSE's internal assignment state
            // is wiped and rebuilt exclusively from the Trail's current valid entries.
            RESYNC_PSE: begin
                if (!resync_started_q) begin
                    // Initialize resync scan
                    resync_started_d = 1'b1;
                    resync_idx_d     = 32'd0; 
                    state_d          = RESYNC_PSE;
                    pse_clear_assignments = 1'b1; // CRITICAL: Ensure PSE clears state before replay!
                    // Note: PSE/VDE cleared in previous state (BACKTRACK_PHASE or PSE_START_AFTER_LEARN)
                    // If driven here, we need to assert them again? 
                    // No, "clear" is a 1-cycle pulse. We asserted it in the transitions INTO this state
                    // (BACKTRACK_PHASE). If entered from elsewhere, we might need to clear?
                    // Safe approach: The clear happens in the Transition state.
                    
                    // Flush FIFO to avoid re-injecting old props
                    prop_flush = 1'b1;
                end else begin
                    // Iterate through TRAIL entries (0 to height-1)
                    // This replays the valid history.
                    
                    // Note: resync_idx_q is used as trail_read_idx via mux
                    if (resync_idx_q < trail_height) begin
                         // Read trail[resync_idx_q] is already happening combinatorially via muxed_trail_read_idx -> cae_trail_read_var/val
                         // Note: trail_manager outputs trail_read_var based on input idx.
                         
                         // Broadcast replay to PSE and VDE
                                                                 // However, for decision making and conflict analysis, we rely on the TRAIL.
                                                                 // The PSE/VDE shadow copies are mainly for "Is Assigned?" checks.
                                                                 // So reason 0xFFFF is safe.
                         
                         vde_assign_valid = 1'b1;
                         vde_assign_var   = cae_trail_read_var;
                         vde_assign_value = cae_trail_read_value;

                         // FIX: Broadcast to PSE as well!
                         pse_assign_broadcast_valid = 1'b1;
                         pse_assign_broadcast_var   = cae_trail_read_var;
                         pse_assign_broadcast_value = cae_trail_read_value;
                         pse_assign_broadcast_reason = 16'hFFFF; // Safe default for replay

                         // synopsys translate_off
                         if (DEBUG > 0) $strobe("[CORE %0d] RESYNC[%0d/%0d] var=%0d val=%0d", CORE_ID, resync_idx_q, trail_height, cae_trail_read_var, cae_trail_read_value);
                         // synopsys translate_on

                         resync_idx_d = resync_idx_q + 1;
                    end else begin
                        // Done Replaying
                        if (resync_append_learned_q) begin
                            state_d = APPEND_LEARNED;
                        end else begin
                            state_d = RESYNC_PSE_SETTLE;
                        end
                        resync_append_learned_d = 1'b0;
                        
                        // Wait! If this was called from PSE_START_AFTER_LEARN, we shouldn't append learned again?
                        // PSE_START_AFTER_LEARN is effectively dead code or used for re-sync.
                        // Let's check where PSE_START_AFTER_LEARN comes from. 
                        // It is NOT used in the main loop anymore.
                        // But BACKTRACK_PHASE usually transitioned to APPEND_LEARNED.
                        // So yes, after replaying the trail, we go to APPEND_LEARNED to add the NEW implication.
                    end
                end
            end
            
            RESYNC_PSE_SETTLE: begin
                // 1-cycle delay: PSE's assign_state has now registered all broadcast updates.
                // Now safe to start PSE for scanning with consistent state.
                pse_start     = 1'b1;
                pse_started_d = 1'b1;  // CRITICAL: Mark PSE as started for conflict detection in PSE_PHASE
                state_d       = PSE_PHASE;
                cycle_count_d = '0;
            end

            INJECT_RX_CLAUSE: begin
                // Handle incoming binary clause from NoC mailbox
                if (iface_clause_rx_valid) begin
                    // 1. Pass literals to PSE
                    pse_inject_req  = 1'b1;
                    // Literal packing format: [63:32]=lit1, [31:0]=lit2
                    pse_inject_lit1 = $signed(iface_clause_rx_ptr[63:32]);
                    pse_inject_lit2 = $signed(iface_clause_rx_ptr[31:0]);
                    
                    if (pse_inject_ready) begin
                        iface_clause_rx_ready = 1'b1; // Consume packet
//                        $strobe("[CORE %0d] RX Clause Injected: {%0d, %0d}", CORE_ID, pse_inject_lit1, pse_inject_lit2);
                        state_d = PSE_PHASE; // BCP the new clause
                        cycle_count_d = '0; // Reset budget for new clause
                    end
                end else begin
                    state_d = VDE_PHASE;
                end
            end

            FINAL_VERIFY: begin
                // One final full PSE scan to confirm all clauses are satisfied under current trail.
                // This catches any races or stale state issues that may have caused early SAT declaration.

                pse_start     = 1'b1;
                pse_started_d = 1'b1;
                final_verify_mode_d = 1'b1;  // Track that we're in verification mode
                state_d       = PSE_PHASE;  // Run PSE one more time, will re-enter this state checker
                cycle_count_d = '0;
            end

            SAT_CHECK: begin
                // SAT only if the final PSE verification found no conflicts
                if (!pse_conflict && !conflict_seen_q) begin
                    state_d = FINISH_SAT;
                end else begin
                    // False positive: conflict found during final verification
                    conflict_clause_len_d = pse_conflict_clause_len;
                    for (int k = 0; k < 8; k++) begin
                        conflict_clause_d[k] = pse_conflict_clause[k];
                    end
                    state_d = QUERY_CONFLICT_LEVELS;
                    query_index_d = 4'd0;
                end
                final_verify_mode_d = 1'b0; // Always clear verification flag here
            end

            FINISH_SAT: begin
                is_sat = 1'b1;
                solve_done = 1'b1;
                final_verify_mode_d = 1'b0;  // Clear verification flag on SAT conclusion
                // Stay in FINISH_SAT until reset or new solve request
                state_d = FINISH_SAT;
            end

            FINISH_UNSAT: begin
                is_unsat = 1'b1;
                solve_done = 1'b1;
                final_verify_mode_d = 1'b0;  // Clear verification flag on UNSAT conclusion
                // Log moved to always_ff
                // Stay in FINISH_UNSAT until reset or new solve request
                state_d = FINISH_UNSAT;
            end

            default: state_d = IDLE;
        endcase

        // Host vs learned clause mux to PSE - MUST be at end so learn_load_valid has final result
        load_valid_mux      = (learn_load_valid) ? 1'b1 : load_valid;
        load_literal_mux    = (learn_load_valid) ? learn_load_literal : load_literal;
        load_clause_end_mux = (learn_load_valid) ? learn_load_clause_end : load_clause_end;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q          <= IDLE;
            cycle_count_q    <= '0;
            decision_level_q <= '0;
            prop_count_q     <= '0;
            conflict_seen_q  <= 1'b0;
            decision_lit_q   <= '0;
            pse_started_q    <= 1'b0;
            cae_done_r_q     <= 1'b0;
            last_decision_var_q   <= '0;
            last_decision_phase_q <= 1'b0;
            tried_both_phases_q   <= 1'b0;
            level0_conflict_count_q <= '0;
            conflict_counter_q <= '0;
            restart_count_q    <= '0;
            verify_mode_q      <= 1'b0;
            restart_pending_q  <= 1'b0;
            final_verify_mode_q <= 1'b0;
            query_index_q      <= '0;
            learn_idx_q        <= '0;
            resync_idx_q       <= '0;
            resync_started_q   <= 1'b0;
            resync_append_learned_q <= 1'b0;
            rescan_required_q  <= 1'b0;
            vde_repeat_count_q <= '0;
            vde_repeat_var_q   <= '0;
            fallback_idx_q     <= 32'd1;
            conflict_clause_len_q <= '0;
            for (int i = 0; i < 16; i++) begin
                conflict_clause_q[i] <= '0;
                conflict_levels_q[i] <= '0;
            end
        end else begin
            state_q          <= state_d;
            cycle_count_q    <= cycle_count_d;
            decision_level_q <= decision_level_d;
            prop_count_q     <= prop_count_d;
            conflict_seen_q  <= conflict_seen_d;
            decision_lit_q   <= decision_lit_d;
            pse_started_q    <= pse_started_d;
            cae_done_r_q     <= cae_done_r_d;
            last_decision_var_q   <= last_decision_var_d;
            last_decision_phase_q <= last_decision_phase_d;
            tried_both_phases_q   <= tried_both_phases_d;
            level0_conflict_count_q <= level0_conflict_count_d;
            conflict_counter_q <= conflict_counter_d;
            restart_count_q    <= restart_count_d;
            verify_mode_q      <= verify_mode_d;
            restart_pending_q  <= restart_pending_d;
            final_verify_mode_q <= final_verify_mode_d;
            query_index_q      <= query_index_d;
            learn_idx_q        <= learn_idx_d;
            resync_idx_q       <= resync_idx_d;
            resync_started_q   <= resync_started_d;
            resync_append_learned_q <= resync_append_learned_d;
            rescan_required_q  <= rescan_required_d;
            vde_repeat_count_q <= vde_repeat_count_d;
            vde_repeat_var_q   <= vde_repeat_var_d;
            fallback_idx_q     <= fallback_idx_d;
            conflict_clause_len_q <= conflict_clause_len_d;
            for (int i = 0; i < 16; i++) begin
                conflict_clause_q[i] <= conflict_clause_d[i];
                conflict_levels_q[i] <= conflict_levels_d[i];
            end

            // PSE PROPAGATION CAPTURE FIFO
            // Handled by u_prop_fifo instance (including capture and pointers)
            if (pse_propagated_valid) begin
                 if (pse_propagated_var == 0) begin
                     // Still keep a small alert if 0 is about to be pushed (it shouldn't due to guard)
                     $display("[CORE %0d] ERROR: PSE triggered Var 0 propagation!", CORE_ID);
                 end
            end
            
            // FIFO Flush logging
            if ((state_q == IDLE && start_solve) || prop_flush) begin
                 if (prop_flush && DEBUG > 0) $display("[CORE %0d] FIFO FLUSHED.", CORE_ID);
            end
        end
    end

    // --- ROBUST TRACE LOGGING ---
    logic vde_decision_valid_r_q;
    logic cae_done_edge_r_q;
    logic [5:0] state_r_q;
    logic trail_backtrack_valid_r_q;
    logic resync_started_r_q;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vde_decision_valid_r_q <= 1'b0;
            cae_done_edge_r_q <= 1'b0;
            state_r_q <= IDLE;
            trail_backtrack_valid_r_q <= 1'b0;
            resync_started_r_q <= 1'b0;
        end else begin
            vde_decision_valid_r_q <= vde_decision_valid && (state_q == VDE_PHASE);
            cae_done_edge_r_q <= cae_done_edge;
            state_r_q <= state_q;
            trail_backtrack_valid_r_q <= trail_backtrack_valid;
            resync_started_r_q <= resync_started_q;
            
            // TRACE MONITOR RESYNC
            if (state_q == RESYNC_PSE && $time % 1000 == 0) begin
            end
        end
    end

    // Sequential Aligned Logging (Merged for async reset consistency)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset for logging-specific signals if any (none currently)
        end else begin
            // State Transition Logs
            if (state_q != state_r_q) begin
                if (state_q == FINAL_VERIFY) $display("[CORE %0d] STATE: FINAL_VERIFY - Running final PSE verification", CORE_ID);
                if (state_q == FINISH_SAT)   $display("[SYS] Result: SAT");
                if (state_q == FINISH_UNSAT) $display("[SYS] Result: UNSAT");
                if (state_q == QUERY_CONFLICT_LEVELS && final_verify_mode_q) 
                    $display("[CORE %0d] WARNING: Conflict during final SAT verification. Re-analyzing...", CORE_ID);
                if (state_q == RESYNC_PSE && !resync_started_r_q)
                    $display("[CORE %0d] Starting RESYNC_PSE. Asserting pse_clear_assignments. Trail height=%0d", CORE_ID, trail_height);
                if (state_q == FINAL_VERIFY && vde_all_assigned)
                    $display("[CORE %0d Cycle %0d] Conflict_Analysis phase: All variables assigned -> Skipping CAE, going to SAT verification", CORE_ID, cycle_count_q);
                if (state_q == BACKTRACK_PHASE && !vde_all_assigned && state_r_q == CONFLICT_ANALYSIS)
                    if (DEBUG >= 1) $display("[CORE %0d] Conflict Analysis Summary: Len=%0d", CORE_ID, conflict_clause_len_q);
                if (state_q == FINISH_UNSAT && (cae_unsat || cae_learned_len == 4'h0 || (conflict_clause_q[0] == 0 && conflict_clause_q[1] == 0)))
                    $display("[CORE %0d Cycle %0d] *** UNSAT: CAE_UNSAT=%b, Learned_Len=%0d, Clause=[%0d,%0d]", 
                             CORE_ID, cycle_count_q, cae_unsat, cae_learned_len, conflict_clause_q[0], conflict_clause_q[1]);
                if (state_q == FINISH_UNSAT && decision_level_q == 1 && cae_backtrack_level == 8'h00)
                    $display("[CORE %0d Cycle %0d] *** UNSAT: Conflict at level 1, backtrack to 0 (no valid assignment)", CORE_ID, cycle_count_q);

            end

            // Backtrack logging
            // Backtrack logging removed


        end
    end

endmodule
