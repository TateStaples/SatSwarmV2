// Propagation Search Engine (PSE)
// Watched-literal BCP over a local clause store.
// Only clauses whose watched literal is falsified are scanned, cutting propagation cost.
//
// INVARIANT: Watched Literal Scheme
// Each clause maintains exactly two "watched" literals.
// 1. If a watched literal becomes False, we MUST scan the clause to find a replacement.
// 2. If a replacement is found, we update the watch.
// 3. If no replacement is found:
//    - If the other watched literal is True, the clause is satisfied (ignore).
//    - If the other watched literal is Unassigned, it becomes Unit (Propagate).
//    - If the other watched literal is False, the clause is Conflicted (Signal Conflict).
module pse #(
    parameter int MAX_VARS    = 256,
    parameter int MAX_CLAUSES = 256,
    parameter int MAX_LITS    = 2048,
    parameter int MAX_CLAUSE_LEN = 32,
    parameter int CORE_ID     = 0,
    parameter int PROP_QUEUE_DEPTH = MAX_LITS
)(
    input  int                 DEBUG,
    input  logic               clk,
    input  logic               reset,

    // Clause load stream
    input  logic               load_valid,
    input  logic signed [31:0] load_literal,
    input  logic               load_clause_end,
    output logic               load_ready,

    // Solve control
    input  logic               start,
    input  logic signed [31:0] decision_var,
    output logic               done,
    output logic               conflict_detected,
    output logic               propagated_valid,
    output logic signed [31:0] propagated_var,
    output logic [15:0]        propagated_reason, // New: Clause ID causing propagation
    output logic [31:0]        max_var_seen,
    input  logic               clear_assignments,
    input  logic               clear_valid,
    input  logic [31:0]        clear_var,

    // Assignment broadcast from solver_core
    input  logic               assign_broadcast_valid,
    input  logic [31:0]        assign_broadcast_var,
    input  logic               assign_broadcast_value,
    input  logic [15:0]        assign_broadcast_reason, // New: Explicit reason from solver_core

    // Conflict clause export (for CAE)
    output logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]         conflict_clause_len,
    output logic signed [MAX_CLAUSE_LEN-1:0][31:0] conflict_clause,

    // Clause Injection Interface (from Solver Core RX)
    input  logic               inject_valid,
    input  logic signed [31:0] inject_lit1,
    input  logic signed [31:0] inject_lit2,
    output logic               inject_ready,
    
    // Reason clause lookup interface (for CAE First-UIP)
    input  logic [31:0]        reason_query_var,      // Variable to query reason for
    output logic [15:0]        reason_query_clause,   // Clause ID that implied this var (0xFFFF if decision)
    output logic               reason_query_valid,    // High if variable has a reason clause
    
    // Clause literal read interface (for CAE to read clause contents)
    input  logic [15:0]        clause_read_id,        // Clause ID to read
    input  logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]         clause_read_lit_idx,   // Literal index within clause
    output logic signed [31:0] clause_read_literal,   // Literal value
    output logic [15:0]        clause_read_len,       // Clause length
    
    // Exposed state for Solver Core
    output logic [15:0]        current_clause_count   // Current number of clauses (next ID)
);

    typedef enum logic [3:0] {
        IDLE,
        LOAD_CLAUSE,
        RESET_WATCHES,
        INIT_WATCHES,
        SEED_DECISION,
        DEQ_PROP,
        SCAN_WATCH,
        SCAN_REPL,
        COMPLETE,
        INJECT_CLAUSE  // New state for inserting foreign clauses
    } state_e;

    // Assignment encoding: 2'b00 = unassigned, 2'b01 = false, 2'b10 = true
    // Assignments and Reasons
    (* ram_style = "block" *) logic [1:0]  assign_state [0:MAX_VARS-1];
    (* ram_style = "block" *) logic [15:0] reason_clause [0:MAX_VARS-1];

    // Clause Store (Local Arrays)
    (* ram_style = "block" *) logic [15:0] clause_len    [0:MAX_CLAUSES-1];
    (* ram_style = "block" *) logic [15:0] clause_start  [0:MAX_CLAUSES-1];
    (* ram_style = "block" *) logic signed [31:0] lit_mem [0:MAX_LITS-1];

    // Watch Lists (Local Arrays)
    (* ram_style = "block" *) logic [15:0] watched_lit1  [0:MAX_CLAUSES-1];
    (* ram_style = "block" *) logic [15:0] watched_lit2  [0:MAX_CLAUSES-1];
    (* ram_style = "block" *) logic [15:0] watch_next1   [0:MAX_CLAUSES-1];
    (* ram_style = "block" *) logic [15:0] watch_next2   [0:MAX_CLAUSES-1];
    (* ram_style = "block" *) logic [15:0] watch_head1   [0:2*MAX_VARS-1];
    (* ram_style = "block" *) logic [15:0] watch_head2   [0:2*MAX_VARS-1];

    // Propagation queue
    logic prop_fifo_empty, prop_fifo_full;
    logic [($clog2(PROP_QUEUE_DEPTH)):0] prop_fifo_count;
    logic signed [31:0] prop_fifo_out;
    logic prop_pop;

    sfifo #(
        .WIDTH(32),
        .DEPTH(PROP_QUEUE_DEPTH)
    ) u_prop_q_fifo (
        .clk(clk),
        .rst_n(!reset),
        .push(prop_push),
        .push_data(prop_push_val),
        .pop(prop_pop),
        .pop_data(prop_fifo_out),
        .full(prop_fifo_full),
        .empty(prop_fifo_empty),
        .count(prop_fifo_count),
        .flush(clear_assignments || (state_q == IDLE && start))
    );

    // Clause Store Interface Signals
    logic        cs_wr_en;
    logic [15:0] cs_wr_clause_id;
    logic [15:0] cs_wr_lit_count;
    logic [15:0] cs_wr_clause_start;
    logic [15:0] cs_wr_clause_len;
    logic [15:0] cs_wr_lit_addr;
    logic signed [31:0] cs_wr_literal;
    
    logic [15:0] cs_rd_clause_id;
    logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]  cs_rd_lit_idx;
    logic signed [31:0] cs_rd_literal;
    logic [15:0] cs_rd_clause_len;
    logic [15:0] cs_rd_clause_start;
    logic [15:0] cs_mem_addr;
    logic signed [31:0] cs_mem_literal;

    // Watch Manager Interface Signals
    logic        wm_clear_all;
    logic [15:0] wm_clear_idx;
    logic        wm_link_en;
    logic [15:0] wm_link_clause_id, wm_link_w1, wm_link_w2, wm_link_idx1, wm_link_idx2;
    logic        wm_move_en;
    logic [15:0] wm_move_clause_id, wm_move_new_w, wm_move_old_idx, wm_move_new_idx, wm_move_prev_id;
    logic        wm_move_list_sel;
    logic [15:0] wm_rd_clause_id, wm_rd_w1, wm_rd_w2, wm_next1, wm_next2;
    logic [15:0] wm_rd_head_idx, wm_head1, wm_head2;

    // Bookkeeping
    state_e      state_q, state_d;
    logic [15:0] clause_count_q, clause_count_d;
    logic [15:0] lit_count_q, lit_count_d;
    logic [15:0] cur_clause_len_q, cur_clause_len_d;
    logic [15:0] init_clause_idx_q, init_clause_idx_d;
    logic [31:0] max_var_seen_q, max_var_seen_d;
    logic [15:0] reset_idx_q, reset_idx_d;  // Counter for RESET_WATCHES state
    logic        hold_q, hold_d;            // Hold-off scanning while resyncing results from trail

    // Scan state for current watch list traversal
    logic signed [31:0] cur_prop_lit_q, cur_prop_lit_d;
    logic [0:0]        scan_list_sel_q, scan_list_sel_d; // 0 -> watch1 list, 1 -> watch2 list
    logic [15:0]       scan_clause_q, scan_clause_d;
    logic [15:0]       scan_prev_q, scan_prev_d;
    logic              sampled_q, sampled_d;
    logic [15:0]       scan_cstart_q, scan_cstart_d;
    logic [15:0]       scan_clen_q, scan_clen_d;
    logic [15:0]       scan_w1_q, scan_w1_d;
    logic [15:0]       scan_w2_q, scan_w2_d;
    logic signed [31:0] scan_lit_watch_q, scan_lit_watch_d;
    logic signed [31:0] scan_lit_other_q, scan_lit_other_d;
    logic [1:0]        scan_other_truth_q, scan_other_truth_d;
    logic [15:0]       scan_idx_q, scan_idx_d;

    // Local assignment write request
    logic        assign_wr_en;
    logic [15:0] assign_wr_idx;
    logic [1:0]  assign_wr_val;

    // Propagation queue write helper
    logic        prop_push;
    logic signed [31:0] prop_push_val;
    logic               initialized_q, initialized_d;

    logic        conflict_detected_q, conflict_detected_d;
    logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]  conflict_clause_len_q, conflict_clause_len_d;
    logic signed [MAX_CLAUSE_LEN-1:0][31:0] conflict_clause_q, conflict_clause_d;
    
    // Reason clause write request
    logic        reason_wr_en;          // Enable write to reason table
    logic [31:0] reason_wr_var;         // Variable to write reason for
    logic [15:0] reason_wr_clause;      // Clause ID that caused this propagation (0xFFFF for decision)

    // Watch update write requests
    logic        watch_wr_en;
    logic [15:0] watch_wr_clause_id;
    logic        watch_wr_list_sel;
    logic [15:0] watch_wr_new_w;
    logic [15:0] watch_wr_old_idx;
    logic [15:0] watch_wr_new_idx;
    logic [15:0] watch_wr_prev_id;

    integer i;

    function automatic logic [1:0] lit_truth_raw(input logic signed [31:0] lit);
        logic [31:0] v;
        logic [31:0] v_idx;
        logic [1:0]  current_assign;
        
        v = (lit < 0) ? -lit : lit;
        if (v == 0 || v > MAX_VARS) begin
            lit_truth_raw = 2'b00;
        end else begin
            // COMBINATIONAL BYPASS: If solver_core is broadcasting a new value THIS cycle, use it!
            // This prevents race conditions where PSE thinks a var is False (old), but Solver 
            // has just forced it True (Correct), causing False Conflicts on satisfied clauses.
            if (assign_broadcast_valid && assign_broadcast_var == v) begin
                current_assign = assign_broadcast_value ? 2'b10 : 2'b01;
            end else begin
                current_assign = assign_state[v-1];
            end
            
            lit_truth_raw = current_assign;
            if (lit < 0) begin
                if (lit_truth_raw == 2'b01) lit_truth_raw = 2'b10;
                else if (lit_truth_raw == 2'b10) lit_truth_raw = 2'b01;
            end
        end
    endfunction

    logic signed [31:0] truth_query_a;
    logic signed [31:0] truth_query_b;
    logic [1:0]         truth_result_a;
    logic [1:0]         truth_result_b;

    always_comb begin
        truth_result_a = lit_truth_raw(truth_query_a);
        truth_result_b = lit_truth_raw(truth_query_b);
    end

    // Safe literal-to-watch-head-index conversion with bounds clamping
    function automatic logic [15:0] safe_lit_idx(input logic signed [31:0] lit);
        logic [31:0] v;
        logic [15:0] raw_idx;
        v = (lit < 0) ? -lit : lit;
        if (v == 0 || v > MAX_VARS) begin
            safe_lit_idx = 16'd0;
        end else begin
            raw_idx = (lit > 0) ? (v - 1) * 2 : (v - 1) * 2 + 1;
            safe_lit_idx = (raw_idx < 2*MAX_VARS) ? raw_idx : 16'd0;
        end
    endfunction

    assign load_ready = (state_q == IDLE || state_q == LOAD_CLAUSE || state_q == COMPLETE);
    wire load_fire = load_valid && load_ready;
    
    // Reason query: Combinational lookup of reason clause for a variable
    always_comb begin
        if (reason_query_var > 0 && reason_query_var <= MAX_VARS) begin
            reason_query_clause = reason_clause[reason_query_var - 1];
            reason_query_valid = (reason_query_clause != 16'hFFFF);
        end else begin
            reason_query_clause = 16'hFFFF;
            reason_query_valid = 1'b0;
        end
    end
    
    // Clause literal read
    always_comb begin
        if (clause_read_id < clause_count_q) begin
            clause_read_len = clause_len[clause_read_id];
            if (clause_read_lit_idx < clause_read_len) begin
                clause_read_literal = lit_mem[clause_start[clause_read_id] + clause_read_lit_idx];
            end else begin
                clause_read_literal = '0;
            end
        end else begin
            clause_read_len = '0;
            clause_read_literal = '0;
        end
    end

    always_comb begin
        // Declare temporary variables 
        logic [31:0] v;
        logic signed [31:0] neg_lit;
        logic [15:0] idx;
        logic [15:0] w1, w2;
        logic [15:0] idx1, idx2;
        logic [15:0] base, len;
        logic [15:0] repl_head_idx, old_head_idx;
        logic signed [31:0] lit1, lit2;
        logic signed [31:0] lit_watch, lit_other;
        logic [1:0] other_truth;
        logic found_repl;
        logic [15:0] repl_idx;
        logic signed [31:0] repl_lit;
        logic [15:0] cstart, clen;
        logic signed [31:0] l;
        logic [1:0] t;
        logic [15:0] next_clause;

        // Initialize defaults
        state_d            = clear_assignments ? IDLE : state_q;
        clause_count_d     = clause_count_q;
        lit_count_d        = lit_count_q;
        cur_clause_len_d   = cur_clause_len_q;
        init_clause_idx_d  = init_clause_idx_q;
        reset_idx_d        = reset_idx_q;
        scan_list_sel_d    = scan_list_sel_q;
        scan_clause_d      = scan_clause_q;
        scan_prev_d        = scan_prev_q;
        cur_prop_lit_d     = cur_prop_lit_q;
        initialized_d      = initialized_q;
        max_var_seen_d     = max_var_seen_q;
        scan_cstart_d      = scan_cstart_q;
        scan_clen_d        = scan_clen_q;
        scan_w1_d          = scan_w1_q;
        scan_w2_d          = scan_w2_q;
        scan_lit_watch_d   = scan_lit_watch_q;
        scan_lit_other_d   = scan_lit_other_q;
        scan_other_truth_d = scan_other_truth_q;
        scan_idx_d         = scan_idx_q;

        hold_d             = clear_assignments ? 1'b1 : (start ? 1'b0 : hold_q);
        conflict_detected_d = start ? 1'b0 : conflict_detected_q;
        conflict_clause_len_d = start ? '0 : conflict_clause_len_q;
        conflict_clause_d = start ? '0 : conflict_clause_q;
        sampled_d         = 1'b0;

        prop_push          = 1'b0;
        prop_push_val      = '0;
        prop_pop           = 1'b0;

        // Read Defaults
        // Read Defaults - REMOVED (Handled by separate always_comb)
        // cs_rd_clause_id = clause_read_id;
        // cs_rd_lit_idx = clause_read_lit_idx;
        // clause_read_literal = cs_rd_literal;

        // Temp Defaults
        lit1 = '0; lit2 = '0; idx1 = '0; idx2 = '0;
        base = '0; len = '0; w1 = '0; w2 = '0;
        l = '0; t = '0; repl_idx = '0; found_repl = '0;
        repl_head_idx = '0; old_head_idx = '0; repl_lit = '0;
        v = '0;
        idx = '0; neg_lit = '0;
        repl_head_idx = '0;
        cstart = '0; clen = '0;
        lit_watch = '0; lit_other = '0; other_truth = '0;
        truth_query_a = '0;
        truth_query_b = '0;
        next_clause = 16'hFFFF;
        
        assign_wr_en       = 1'b0;
        assign_wr_idx      = '0;
        assign_wr_val      = 2'b00;

        reason_wr_en       = 1'b0;
        reason_wr_var      = '0;
        reason_wr_clause   = 16'hFFFF;

        watch_wr_en        = 1'b0;
        watch_wr_clause_id = '0;
        watch_wr_list_sel  = 1'b0;
        watch_wr_new_w     = '0;
        watch_wr_old_idx   = '0;
        watch_wr_new_idx   = '0;
        watch_wr_prev_id   = '0;

        propagated_valid   = 1'b0;
        propagated_var     = '0;
        propagated_reason  = 16'hFFFF;
        done               = 1'b0;
        inject_ready       = 1'b0;
        
        conflict_detected   = conflict_detected_q;
        conflict_clause_len = conflict_clause_len_q;
        conflict_clause     = conflict_clause_q;

        case (state_q)
            IDLE: begin
                // TRACE IDLE
                // Only print occasionally to avoid flood? No, flood is fine for short hangs.
                
                if (load_fire) begin
                    cur_clause_len_d = cur_clause_len_q + 1'b1;
                    lit_count_d      = lit_count_q + 1'b1;
                    v = (load_literal < 0) ? -load_literal : load_literal;
                    if (v > max_var_seen_q) max_var_seen_d = v;
                    
                    if (load_clause_end) begin
                        clause_count_d     = clause_count_q + 1'b1;
                        cur_clause_len_d   = '0;
                    end
                    state_d   = LOAD_CLAUSE;
                end else if (inject_valid) begin
                    state_d = INJECT_CLAUSE;
                end else if (start) begin
                    if (initialized_q) begin
                        if (init_clause_idx_q < clause_count_q) state_d = INIT_WATCHES;
                        else state_d = SEED_DECISION;
                    end else begin
                        reset_idx_d = '0;
                        state_d = RESET_WATCHES;
                    end
                end else if (!prop_fifo_empty && !hold_q && !conflict_detected_q) begin
                    state_d = DEQ_PROP;
                end
            end

            LOAD_CLAUSE: begin
                if (load_fire) begin
                    cur_clause_len_d = cur_clause_len_q + 1'b1;
                    lit_count_d      = lit_count_q + 1'b1;
                    v = (load_literal < 0) ? -load_literal : load_literal;
                    if (v > max_var_seen_q) max_var_seen_d = v;
                    
                    if (load_clause_end) begin
                        clause_count_d   = clause_count_q + 1'b1;
                        cur_clause_len_d = '0;
                    end
                    state_d = LOAD_CLAUSE;
                end else if (start) begin
                    if (initialized_q) begin
                        if (init_clause_idx_q < clause_count_q) state_d = INIT_WATCHES;
                        else state_d = SEED_DECISION;
                    end else begin
                        reset_idx_d = '0;
                        state_d = RESET_WATCHES;
                    end
                end else begin
                    state_d = IDLE;
                end
            end

            RESET_WATCHES: begin
                if (reset_idx_q < MAX_CLAUSES + 2*MAX_VARS) begin
                    reset_idx_d = reset_idx_q + 1'b1;
                end else begin
                    init_clause_idx_d = '0;
                    state_d = INIT_WATCHES;
                end
            end

            INIT_WATCHES: begin
                if (init_clause_idx_q < clause_count_q) begin
                    init_clause_idx_d = init_clause_idx_q + 1'b1;
                end else begin
                    initialized_d = 1'b1;
                    state_d       = SEED_DECISION;
                end
            end

            SEED_DECISION: begin
                if (inject_valid) begin
                    inject_ready = 1'b1;
                    state_d = INJECT_CLAUSE;
                end else if (decision_var != 0) begin
                    v = (decision_var < 0) ? -decision_var : decision_var;
                    if (v != 0 && v <= MAX_VARS) begin
                        assign_wr_en  = 1'b1;
                        assign_wr_idx = v - 1;
                        assign_wr_val = (decision_var < 0) ? 2'b01 : 2'b10;
                        prop_push     = 1'b1;
                        prop_push_val = decision_var;
                        reason_wr_en     = 1'b1;
                        reason_wr_var    = v;
                        reason_wr_clause = 16'hFFFF;
                    end
                end
                scan_list_sel_d = 1'b0;
                state_d = DEQ_PROP;
            end

            DEQ_PROP: begin
                if (prop_fifo_empty) begin
                    done = 1'b1;
                    state_d = COMPLETE;
                end else begin
                    // TRACE DEQ
                    
                    cur_prop_lit_d = prop_fifo_out;
                    prop_pop       = 1'b1;
                    scan_list_sel_d = 1'b0;
                    neg_lit = -prop_fifo_out;
                    scan_clause_d   = watch_head1[safe_lit_idx(neg_lit)];
                    scan_prev_d     = 16'hFFFF;
                    state_d = SCAN_WATCH;
                end
            end

            SCAN_WATCH: begin
                if (scan_clause_q == 16'hFFFF) begin
                    // TRACE FFFF

                    if (scan_list_sel_q == 1'b0) begin
                        scan_list_sel_d = 1'b1;
                        neg_lit = -cur_prop_lit_q;
                        scan_clause_d   = watch_head2[safe_lit_idx(neg_lit)];
                        scan_prev_d     = 16'hFFFF;
                        state_d = SCAN_WATCH;
                    end else begin
                        state_d = DEQ_PROP;
                    end
                end else if (scan_clause_q >= MAX_CLAUSES) begin
                    state_d = COMPLETE;
                end else begin

                    
                    w1 = watched_lit1[scan_clause_q];
                    w2 = watched_lit2[scan_clause_q];
                    cstart = clause_start[scan_clause_q];
                    clen   = clause_len[scan_clause_q];
                    
                    if (scan_clause_q == 16'd2) begin
                    end

                    if (scan_list_sel_q == 1'b0) begin
                        lit_watch = lit_mem[w1];
                        lit_other = lit_mem[w2];
                    end else begin
                        lit_watch = lit_mem[w2];
                        lit_other = lit_mem[w1];
                    end

                    truth_query_a = lit_other;
                    truth_query_b = lit_watch;
                    other_truth = truth_result_a;

                    if (other_truth == 2'b10 || truth_result_b != 2'b01) begin
                        scan_prev_d   = scan_clause_q;
                        next_clause = (scan_list_sel_q == 1'b0) ? watch_next1[scan_clause_q] : watch_next2[scan_clause_q];
                        if (next_clause == scan_clause_q || (scan_prev_q != 16'hFFFF && next_clause == scan_prev_q))
                            scan_clause_d = 16'hFFFF;
                        else
                            scan_clause_d = next_clause;
                    end else begin
                        scan_cstart_d      = cstart;
                        scan_clen_d        = clen;
                        scan_w1_d          = w1;
                        scan_w2_d          = w2;
                        scan_lit_watch_d   = lit_watch;
                        scan_lit_other_d   = lit_other;
                        scan_other_truth_d = other_truth;
                        scan_idx_d         = 16'd0;
                        state_d            = SCAN_REPL;
                    end
                end
            end

            SCAN_REPL: begin
                if (scan_idx_q < scan_clen_q) begin
                    l = lit_mem[scan_cstart_q + scan_idx_q];
                    if ((scan_cstart_q + scan_idx_q != scan_w1_q) && (scan_cstart_q + scan_idx_q != scan_w2_q)) begin
                        if (lit_truth_raw(l) != 2'b01 && safe_lit_idx(l) != safe_lit_idx(scan_lit_watch_q)) begin
                            watch_wr_en        = 1'b1;
                            watch_wr_clause_id = scan_clause_q;
                            watch_wr_list_sel  = scan_list_sel_q;
                            watch_wr_new_w     = scan_cstart_q + scan_idx_q;
                            watch_wr_old_idx   = safe_lit_idx(scan_lit_watch_q);
                            watch_wr_new_idx   = safe_lit_idx(l);
                            watch_wr_prev_id   = scan_prev_q;

                            scan_prev_d   = scan_clause_q;
                            next_clause = (scan_list_sel_q == 1'b0) ? watch_next1[scan_clause_q] : watch_next2[scan_clause_q];
                            if (next_clause == scan_clause_q || (scan_prev_q != 16'hFFFF && next_clause == scan_prev_q))
                                scan_clause_d = 16'hFFFF;
                            else
                                scan_clause_d = next_clause;

                            state_d = SCAN_WATCH;
                        end else begin
                            scan_idx_d = scan_idx_q + 1'b1;
                        end
                    end else begin
                        scan_idx_d = scan_idx_q + 1'b1;
                    end
                end else begin
                    if (scan_other_truth_q == 2'b00) begin
                        v = (scan_lit_other_q < 0) ? -scan_lit_other_q : scan_lit_other_q;
                        propagated_valid  = 1'b1;
                        propagated_var    = scan_lit_other_q;
                        propagated_reason = scan_clause_q;
                        if (DEBUG > 0) $display("[PSE TRACE] Unit %0d from Clause %0d (State SCAN_REPL)", scan_lit_other_q, scan_clause_q);

                        // Debug Trap for Var 0
                        `ifndef SYNTHESIS
                        if (scan_lit_other_q == 0) begin
                            $display("\n[PSE ERROR] Clause %0d implies Var 0! Dumping state:", scan_clause_q);
                            $display("  w1=%0d (idx=%0d) lit=%0d", scan_w1_q, safe_lit_idx(lit_mem[scan_w1_q]), lit_mem[scan_w1_q]);
                            $display("  w2=%0d (idx=%0d) lit=%0d", scan_w2_q, safe_lit_idx(lit_mem[scan_w2_q]), lit_mem[scan_w2_q]);
                            $display("  scan_list_sel=%0d (0=w1 list, 1=w2 list)", scan_list_sel_q);
                            $display("  cstart=%0d clen=%0d", scan_cstart_q, scan_clen_q);
                            $display("  Literal Memory Dump for Clause:");
                            for (int k=0; k<8; k++) begin // just dump first 8
                                 $display("    lit[%0d] = %0d", k, lit_mem[scan_cstart_q+k]);
                            end
                            $fatal(1, "PSE Critical Error: Implied Var 0");
                        end
                        `endif

                        assign_wr_en  = 1'b1;
                        assign_wr_idx = v - 1;
                        assign_wr_val = (scan_lit_other_q < 0) ? 2'b01 : 2'b10;
                        prop_push     = 1'b1;
                        prop_push_val = scan_lit_other_q;
                        reason_wr_en  = 1'b1;
                        reason_wr_var = v;
                        reason_wr_clause = scan_clause_q;

                        scan_prev_d   = scan_clause_q;
                        next_clause = (scan_list_sel_q == 1'b0) ? watch_next1[scan_clause_q] : watch_next2[scan_clause_q];
                        if (next_clause == scan_clause_q || (scan_prev_q != 16'hFFFF && next_clause == scan_prev_q))
                            scan_clause_d = 16'hFFFF;
                        else
                            scan_clause_d = next_clause;

                        state_d = SCAN_WATCH;
                    end else begin
                        conflict_detected_d = 1'b1;
                        conflict_clause_len_d = scan_clen_q[$clog2(MAX_CLAUSE_LEN+1)-1:0];
                        for (int k = 0; k < MAX_CLAUSE_LEN; k++) begin
                            if ($unsigned(k) < $unsigned(scan_clen_q))
                                conflict_clause_d[k] = lit_mem[scan_cstart_q + k];
                        end
                        state_d = COMPLETE;
                    end
                end
            end

            COMPLETE: begin
                done = 1'b1;
                if (load_fire) begin
                    cur_clause_len_d = cur_clause_len_q + 1'b1;
                    lit_count_d      = lit_count_q + 1'b1;
                    v = (load_literal < 0) ? -load_literal : load_literal;
                    if (v > max_var_seen_q) max_var_seen_d = v;
                    if (load_clause_end) begin
                        clause_count_d   = clause_count_q + 1'b1;
                        cur_clause_len_d = '0;
                    end
                    state_d   = LOAD_CLAUSE;
                end else if (start) begin
                    if (initialized_q) begin
                        if (init_clause_idx_q < clause_count_q) state_d = INIT_WATCHES;
                        else state_d = SEED_DECISION;
                    end else begin
                        reset_idx_d = '0;
                        state_d = RESET_WATCHES;
                    end
                end else if (!conflict_detected_q && !prop_fifo_empty) begin
                    state_d = DEQ_PROP;
                end else if (!start) begin
                    state_d = IDLE;
                end
            end

            INJECT_CLAUSE: begin
                // Simplified injection for 2-lits
                if (clause_count_q < MAX_CLAUSES && lit_count_q < MAX_LITS - 2) begin
                    // This state would need always_ff logic to actually write lit_mem
                    clause_count_d = clause_count_q + 1'b1;
                    lit_count_d    = lit_count_q + 2'd2;
                end
                inject_ready = 1'b1;
                state_d = SEED_DECISION;
            end

            default: state_d = IDLE;
        endcase

        if (assign_broadcast_valid && !prop_push && !prop_fifo_full) begin
            if (assign_broadcast_var > 0 && assign_broadcast_var <= MAX_VARS && assign_state[assign_broadcast_var-1] == 2'b00) begin
                prop_push     = 1'b1;
                prop_push_val = assign_broadcast_value ? $signed(assign_broadcast_var) : -$signed(assign_broadcast_var);
            end
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state_q          <= IDLE;
            clause_count_q   <= '0;
            lit_count_q      <= '0;
            cur_clause_len_q <= '0;
            init_clause_idx_q<= '0;
            reset_idx_q      <= '0;
            max_var_seen_q   <= '0;
            scan_list_sel_q  <= '0;
            scan_clause_q    <= 16'hFFFF;
            scan_prev_q      <= 16'hFFFF;
            cur_prop_lit_q   <= '0;
            initialized_q    <= 1'b0;
            hold_q           <= 1'b0;
            scan_cstart_q     <= '0;
            scan_clen_q       <= '0;
            scan_w1_q         <= '0;
            scan_w2_q         <= '0;
            scan_lit_watch_q  <= '0;
            scan_lit_other_q  <= '0;
            scan_other_truth_q<= '0;
            scan_idx_q        <= '0;
            for (i = 0; i < MAX_VARS; i = i + 1) begin
                assign_state[i] <= 2'b00;
                reason_clause[i] <= 16'hFFFF;
            end
            for (i = 0; i < 2*MAX_VARS; i = i + 1) begin
                watch_head1[i] <= 16'hFFFF;
                watch_head2[i] <= 16'hFFFF;
            end
            conflict_detected_q   <= 1'b0;
            conflict_clause_len_q <= '0;
            conflict_clause_q     <= '0;
        end else begin
            state_q          <= state_d;
            clause_count_q   <= clause_count_d;
            lit_count_q      <= lit_count_d;
            cur_clause_len_q <= cur_clause_len_d;
            init_clause_idx_q<= init_clause_idx_d;
            reset_idx_q      <= reset_idx_d;
            
            // TRACE MONITOR
            if ($time % 10000 == 0) begin
            end
            
            max_var_seen_q   <= max_var_seen_d;
            scan_list_sel_q  <= scan_list_sel_d;
            scan_clause_q    <= scan_clause_d;
            scan_prev_q      <= scan_prev_d;
            cur_prop_lit_q   <= cur_prop_lit_d;
            sampled_q        <= sampled_d;
            initialized_q    <= initialized_d;
            hold_q           <= hold_d;
            scan_cstart_q     <= scan_cstart_d;
            scan_clen_q       <= scan_clen_d;
            scan_w1_q         <= scan_w1_d;
            scan_w2_q         <= scan_w2_d;
            scan_lit_watch_q  <= scan_lit_watch_d;
            scan_lit_other_q  <= scan_lit_other_d;
            scan_other_truth_q<= scan_other_truth_d;
            scan_idx_q        <= scan_idx_d;
            conflict_detected_q <= conflict_detected_d;
            conflict_clause_len_q <= conflict_clause_len_d;
            conflict_clause_q <= conflict_clause_d;

            if (load_fire) begin
                lit_mem[lit_count_q] <= load_literal;
                if (load_clause_end) begin
                    clause_start[clause_count_q] <= lit_count_q - cur_clause_len_q;
                    clause_len[clause_count_q]   <= cur_clause_len_q + 1'b1;
                    if (DEBUG >= 2) $display("[PSE DEBUG] LOAD_CLAUSE end: c_idx=%0d, total_len=%0d", clause_count_q, cur_clause_len_q+1);
                end
            end

            if (state_q == RESET_WATCHES) begin
                if (reset_idx_q < MAX_CLAUSES) begin
                    watched_lit1[reset_idx_q] <= 16'hFFFF;
                    watched_lit2[reset_idx_q] <= 16'hFFFF;
                    watch_next1[reset_idx_q]  <= 16'hFFFF;
                    watch_next2[reset_idx_q]  <= 16'hFFFF;
                end else if (reset_idx_q < MAX_CLAUSES + 2*MAX_VARS) begin
                    watch_head1[reset_idx_q - MAX_CLAUSES] <= 16'hFFFF;
                    watch_head2[reset_idx_q - MAX_CLAUSES] <= 16'hFFFF;
                end
                reset_idx_q <= reset_idx_q + 1'b1;
            end

            if (state_q == INIT_WATCHES && init_clause_idx_q < clause_count_q) begin
                logic [15:0] c;
                logic [15:0] b;
                logic [15:0] l;
                logic [15:0] w1;
                logic [15:0] w2;
                logic [15:0] idx1;
                logic [15:0] idx2;

                c = init_clause_idx_q;
                b = clause_start[c];
                l = clause_len[c];
                w1 = b;
                w2 = (l > 1) ? b + 1 : b;
                idx1 = safe_lit_idx(lit_mem[w1]);
                idx2 = safe_lit_idx(lit_mem[w2]);
                
                watched_lit1[c] <= w1;
                watched_lit2[c] <= w2;
                watch_next1[c]  <= watch_head1[idx1];
                watch_head1[idx1] <= c;
                watch_next2[c]  <= watch_head2[idx2];
                watch_head2[idx2] <= c;

                if (DEBUG >= 2) $display("[MEM] Adding Watch List for %0d and %0d to clause %0d", lit_mem[w1], lit_mem[w2], c);
            end


            
            if (watch_wr_en) begin
                if (watch_wr_list_sel == 1'b0) begin
                    if (DEBUG >= 2) $display("[hw_trace] [PSE] Replaced watcher %0d with %0d for clause %0d", lit_mem[watched_lit1[watch_wr_clause_id]], lit_mem[watch_wr_new_w], watch_wr_clause_id);
                    watched_lit1[watch_wr_clause_id] <= watch_wr_new_w;

                    if (watch_wr_prev_id == 16'hFFFF)
                        watch_head1[watch_wr_old_idx] <= watch_next1[watch_wr_clause_id];
                    else
                        watch_next1[watch_wr_prev_id] <= watch_next1[watch_wr_clause_id];
                    
                    watch_next1[watch_wr_clause_id] <= watch_head1[watch_wr_new_idx];
                    watch_head1[watch_wr_new_idx] <= watch_wr_clause_id;
                end else begin
                    if (DEBUG >= 2) $display("[hw_trace] [PSE] Replaced watcher %0d with %0d for clause %0d", lit_mem[watched_lit2[watch_wr_clause_id]], lit_mem[watch_wr_new_w], watch_wr_clause_id);
                    watched_lit2[watch_wr_clause_id] <= watch_wr_new_w;
                    if (watch_wr_prev_id == 16'hFFFF)
                        watch_head2[watch_wr_old_idx] <= watch_next2[watch_wr_clause_id];
                    else
                        watch_next2[watch_wr_prev_id] <= watch_next2[watch_wr_clause_id];
                    
                    watch_next2[watch_wr_clause_id] <= watch_head2[watch_wr_new_idx];
                    watch_head2[watch_wr_new_idx] <= watch_wr_clause_id;
                end
            end

            if (clear_assignments) begin
                for (i = 0; i < MAX_VARS; i = i + 1) begin
                    assign_state[i] <= 2'b00;
                    reason_clause[i] <= 16'hFFFF;
                end
                conflict_detected_q <= 1'b0;
                conflict_clause_len_q <= 4'd0;
                state_q             <= IDLE;
            end else begin
                if (assign_wr_en) assign_state[assign_wr_idx] <= assign_wr_val;
                if (reason_wr_en && reason_wr_var > 0 && reason_wr_var <= MAX_VARS)
                    reason_clause[reason_wr_var-1] <= reason_wr_clause;
                if (assign_broadcast_valid && assign_broadcast_var > 0 && assign_broadcast_var <= MAX_VARS) begin
                    assign_state[assign_broadcast_var-1] <= assign_broadcast_value ? 2'b10 : 2'b01;
                    if (!reason_wr_en || reason_wr_var != assign_broadcast_var)
                        reason_clause[assign_broadcast_var-1] <= assign_broadcast_reason;
                end
                if (clear_valid && clear_var > 0 && clear_var <= MAX_VARS) begin
                    assign_state[clear_var-1] <= 2'b00;
                    reason_clause[clear_var-1] <= 16'hFFFF;
                end
            end
        end
    end

    assign max_var_seen = max_var_seen_q;
    assign current_clause_count = clause_count_q;

    logic conflict_detected_r_q;
    logic propagated_valid_r_q;
    logic [31:0] reason_query_var_r_q;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            conflict_detected_r_q <= 1'b0;
            propagated_valid_r_q  <= 1'b0;
            reason_query_var_r_q  <= '0;
        end else begin
            if (propagated_valid && !propagated_valid_r_q)
                if (DEBUG >= 1) $display("[hw_trace] [PSE] Propagating Unit %0d from Clause %0d", propagated_var, scan_clause_q);
            if (conflict_detected_q && !conflict_detected_r_q)
                if (DEBUG >= 1) $display("[hw_trace] [PSE] Conflict detected in Clause %0d: [%0d, %0d, ...]", scan_clause_q, conflict_clause_q[0], conflict_clause_q[1]);
            if (reason_query_var != 0 && reason_query_var != reason_query_var_r_q)
                 if (DEBUG >= 2) $display("[PSE QUERY] Var=%0d -> Reason=%h Valid=%b", reason_query_var, reason_query_clause, reason_query_valid);
            conflict_detected_r_q <= conflict_detected_q;
            propagated_valid_r_q  <= propagated_valid;
            reason_query_var_r_q  <= reason_query_var;
        end
    end

        // SIMULATION ONLY: Check for hardware limit breaches
        `ifndef SYNTHESIS
        always @(posedge clk) begin
           if (clause_count_q >= MAX_CLAUSES) begin
               $display("\n[ERROR] Hardware Limit Reached: Clause Count (%0d) >= MAX_CLAUSES (%0d)", clause_count_q, MAX_CLAUSES);
               $display("[ERROR] Simulation Terminated due to memory exhaustion.");
               $finish;
           end
           // Check loosely against MAX_LITS - 32 to warn before it's absolutely critical, 
           // or strictly against MAX_LITS. user said "warn when one of the limits is breached".
           // The INJECT logic checks (lit_count_q < MAX_LITS - 2).
           if (lit_count_q >= MAX_LITS - 2) begin 
               $display("\n[ERROR] Hardware Limit Reached: Literal Count (%0d) >= MAX_LITS (%0d)", lit_count_q, MAX_LITS);
               $display("[ERROR] Simulation Terminated due to memory exhaustion.");
               $finish;
           end
        end
        `endif

endmodule
