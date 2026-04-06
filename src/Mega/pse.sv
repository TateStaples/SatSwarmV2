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
    parameter int MAX_LITS    = 4096,
    parameter int MAX_CLAUSE_LEN = 32,
    parameter int CORE_ID     = 0,
    parameter int PROP_QUEUE_DEPTH = MAX_LITS
)(
    input  logic [31:0]          DEBUG,
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
    output logic [15:0]        current_clause_count,  // Current number of clauses (next ID)

    // Direct learned-clause append interface (bypasses load stream; single-cycle write)
    input  logic                                        cae_direct_append_en,
    input  logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]        cae_direct_append_len,
    input  logic signed [MAX_CLAUSE_LEN-1:0][31:0]     cae_direct_append_lits,
    // 1 if the append will be accepted this cycle (capacity check passed); 0 if silently dropped
    output logic                                        cae_direct_append_accepted
);

    typedef enum logic [3:0] {
        IDLE,
        LOAD_CLAUSE,
        RESET_WATCHES,
        INIT_WATCHES,
        APPEND_CLAUSE,   // serialize learned-clause write, one lit/cycle
        SEED_DECISION,
        DEQ_PROP,
        SCAN_WATCH,
        SCAN_WATCH_EVAL,    // FIX5: wait for registered truth results after SCAN_WATCH
        SCAN_REPL,
        SCAN_REPL_EVAL,     // FIX5: wait for registered truth result in replacement scan
        WATCH_REPL_CYCLE1,  // Serialized watcher replacement: remove from old list (1 write/array)
        WATCH_REPL_CYCLE2,  // Serialized watcher replacement: add to new list (1 write/array)
        COMPLETE,
        INJECT_CLAUSE  // New state for inserting foreign clauses
    } state_e;

    // Assignment encoding: 2'b00 = unassigned, 2'b01 = false, 2'b10 = true
    // Assignments and Reasons — ram_style hints force LUTRAM inference on UltraScale+.
    // BCP reads multiple arrays per cycle (assign_state, lit_mem, watch_head*, watch_next*)
    // simultaneously, which prevents BRAM (single read port) but is fine for LUTRAM
    // (async multi-read).
    (* ram_style = "distributed" *) logic [1:0]  assign_state [0:MAX_VARS-1];
    (* ram_style = "distributed" *) logic [15:0] reason_clause [0:MAX_VARS-1];

    // Clause Store (Local Arrays)
    (* ram_style = "distributed" *) logic [15:0] clause_len    [0:MAX_CLAUSES-1];
    (* ram_style = "distributed" *) logic [15:0] clause_start  [0:MAX_CLAUSES-1];
    (* ram_style = "distributed" *) logic signed [31:0] lit_mem [0:MAX_LITS-1];

    // Watch Lists (Local Arrays)
    (* ram_style = "distributed" *) logic [15:0] watched_lit1  [0:MAX_CLAUSES-1];
    (* ram_style = "distributed" *) logic [15:0] watched_lit2  [0:MAX_CLAUSES-1];
    (* ram_style = "distributed" *) logic [15:0] watch_next1   [0:MAX_CLAUSES-1];
    (* ram_style = "distributed" *) logic [15:0] watch_next2   [0:MAX_CLAUSES-1];
    (* ram_style = "distributed" *) logic [15:0] watch_head1   [0:2*MAX_VARS-1];
    (* ram_style = "distributed" *) logic [15:0] watch_head2   [0:2*MAX_VARS-1];

    // Watcher replacement staging (2-cycle serialize for BRAM inference)
    logic [15:0] watch_repl_clause_id_q;
    logic        watch_repl_list_sel_q;
    logic [15:0] watch_repl_new_w_q;
    logic [15:0] watch_repl_old_idx_q;
    logic [15:0] watch_repl_new_idx_q;
    logic [15:0] watch_repl_prev_id_q;
    logic [15:0] watch_repl_next_clause_q;

    // Clause-append staging registers (used in APPEND_CLAUSE serializer)
    logic signed [MAX_CLAUSE_LEN-1:0][31:0]    append_lits_q;
    logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]       append_len_q;
    logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]       append_idx_q, append_idx_d;
    logic [15:0]                                append_clause_base_q; // lit_count at capture
    logic [15:0]                                append_clause_id_q;   // clause_count at capture

    // Propagation queue
    logic prop_fifo_empty, prop_fifo_full;
    logic [($clog2(PROP_QUEUE_DEPTH)):0] prop_fifo_count;
    logic signed [31:0] prop_fifo_out;
    logic prop_pop;
    logic        prop_push;
    logic signed [31:0] prop_push_val;
    state_e      state_q, state_d;

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
    logic [15:0]       scan_steps_q, scan_steps_d; // Safety counter to detect circular watch lists

    // Local assignment write request
    logic        assign_wr_en;
    logic [15:0] assign_wr_idx;
    logic [1:0]  assign_wr_val;

    logic               initialized_q, initialized_d;

    logic        conflict_detected_q, conflict_detected_d;
    logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]  conflict_clause_len_q, conflict_clause_len_d;
    logic signed [MAX_CLAUSE_LEN-1:0][31:0] conflict_clause_q, conflict_clause_d;
    
    // Reason clause write request
    logic        reason_wr_en;          // Enable write to reason table
    logic [31:0] reason_wr_var;         // Variable to write reason for
    logic [15:0] reason_wr_clause;      // Clause ID that caused this propagation (0xFFFF for decision)

    // Watch update write requests
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

    // FIX5: Registered (pipelined) truth results — breaks the combinational chain
    // lit_mem[] → assign_state[] → broadcast_mux → polarity_flip that limits fmax.
    // SCAN_WATCH issues queries, SCAN_WATCH_EVAL reads registered results.
    logic [1:0]         truth_result_a_r;
    logic [1:0]         truth_result_b_r;

    // FIX5: Saved replacement literal across SCAN_REPL → SCAN_REPL_EVAL wait
    logic signed [31:0] scan_repl_lit_q, scan_repl_lit_d;

    always_comb begin
        truth_result_a = lit_truth_raw(truth_query_a);
        truth_result_b = lit_truth_raw(truth_query_b);
    end

    // FIX5: Pipeline register for truth results (posedge latch)
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            truth_result_a_r <= 2'b00;
            truth_result_b_r <= 2'b00;
            scan_repl_lit_q  <= '0;
        end else begin
            truth_result_a_r <= truth_result_a;
            truth_result_b_r <= truth_result_b;
            scan_repl_lit_q  <= scan_repl_lit_d;
        end
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

    // Combinational: 1 if an append requested this cycle will be accepted (not dropped due to overflow)
    assign cae_direct_append_accepted = cae_direct_append_en &&
        (state_q == IDLE || state_q == LOAD_CLAUSE || state_q == COMPLETE) &&
        clause_count_q < MAX_CLAUSES &&
        (lit_count_q + cae_direct_append_len) <= MAX_LITS;
    
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
        scan_steps_d       = scan_steps_q;
        scan_repl_lit_d    = scan_repl_lit_q; // FIX5: default preserve
        append_idx_d       = append_idx_q;

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
                    if (cae_direct_append_en &&
                        clause_count_q < MAX_CLAUSES &&
                        (lit_count_q + cae_direct_append_len) <= MAX_LITS) begin
                        append_idx_d = '0;
                        state_d = APPEND_CLAUSE;
                    end else if (initialized_q) begin
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
                    if (cae_direct_append_en &&
                        clause_count_q < MAX_CLAUSES &&
                        (lit_count_q + cae_direct_append_len) <= MAX_LITS) begin
                        append_idx_d = '0;
                        state_d = APPEND_CLAUSE;
                    end else if (initialized_q) begin
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
                // Extended range: +MAX_VARS cycles to also clear assign_state/reason_clause.
                if (reset_idx_q < MAX_CLAUSES + 2*MAX_VARS + MAX_VARS) begin
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

            APPEND_CLAUSE: begin
                // Serial write: one literal per cycle from append_lits_q.
                // When the last literal is written, update counters and metadata,
                // set init_clause_idx to the new clause, then go to INIT_WATCHES.
                if (append_idx_q + 1 >= append_len_q) begin
                    // Final literal being written this cycle (sync block below).
                    clause_count_d    = clause_count_q + 1'b1;
                    lit_count_d       = lit_count_q + {1'b0, append_len_q};
                    init_clause_idx_d = append_clause_id_q; // watch only the new clause
                    state_d           = INIT_WATCHES;
                end else begin
                    append_idx_d = append_idx_q + 1'b1;
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
                    scan_steps_d    = 16'd0;
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
                end else if (scan_steps_q > clause_count_q) begin
                    // Safety valve: visited more clauses than exist — circular list detected
`ifndef SYNTHESIS
                    $display("[PSE WARN] Circular watch list detected for lit %0d (steps=%0d > clauses=%0d). Breaking.",
                             cur_prop_lit_q, scan_steps_q, clause_count_q);
`endif
                    if (scan_list_sel_q == 1'b0) begin
                        scan_list_sel_d = 1'b1;
                        neg_lit = -cur_prop_lit_q;
                        scan_clause_d   = watch_head2[safe_lit_idx(neg_lit)];
                        scan_prev_d     = 16'hFFFF;
                        scan_steps_d    = 16'd0;
                    end else begin
                        state_d = DEQ_PROP;
                    end
                end else begin

                    
                    scan_steps_d = scan_steps_q + 16'd1;

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

                    // FIX5: Issue truth queries; registered results read in SCAN_WATCH_EVAL
                    truth_query_a = lit_other;
                    truth_query_b = lit_watch;

                    // Save clause metadata for SCAN_WATCH_EVAL / SCAN_REPL
                    scan_cstart_d      = cstart;
                    scan_clen_d        = clen;
                    scan_w1_d          = w1;
                    scan_w2_d          = w2;
                    scan_lit_watch_d   = lit_watch;
                    scan_lit_other_d   = lit_other;
                    state_d            = SCAN_WATCH_EVAL;
                end
            end

            // FIX5: Evaluate registered truth results from previous SCAN_WATCH cycle
            SCAN_WATCH_EVAL: begin
                other_truth = truth_result_a_r;

                if (other_truth == 2'b10 || truth_result_b_r != 2'b01) begin
                    // Clause satisfied by other literal, or watched literal not false — skip
                    scan_prev_d   = scan_clause_q;
                    next_clause = (scan_list_sel_q == 1'b0) ? watch_next1[scan_clause_q] : watch_next2[scan_clause_q];
                    if (next_clause == scan_clause_q || (scan_prev_q != 16'hFFFF && next_clause == scan_prev_q))
                        scan_clause_d = 16'hFFFF;
                    else
                        scan_clause_d = next_clause;
                    state_d = SCAN_WATCH;
                end else begin
                    // Watched literal is false and other is not true — need replacement
                    scan_other_truth_d = other_truth;
                    scan_idx_d         = 16'd0;
                    state_d            = SCAN_REPL;
                end
            end

            SCAN_REPL: begin
                if (scan_idx_q < scan_clen_q) begin
                    l = lit_mem[scan_cstart_q + scan_idx_q];
                    // Accumulate conflict clause literals one-per-cycle to avoid
                    // multi-read for-loop that would create >16 read ports on lit_mem.
                    conflict_clause_d[scan_idx_q] = l;
                    if ((scan_cstart_q + scan_idx_q != scan_w1_q) && (scan_cstart_q + scan_idx_q != scan_w2_q)) begin
                        // FIX5: Issue truth query for candidate literal, wait for registered result
                        truth_query_a   = l;
                        scan_repl_lit_d = l;
                        state_d = SCAN_REPL_EVAL;
                    end else begin
                        scan_idx_d = scan_idx_q + 1'b1;
                    end
                end else begin
                    if (scan_other_truth_q == 2'b00) begin
                        v = (scan_lit_other_q < 0) ? -scan_lit_other_q : scan_lit_other_q;
`ifndef SYNTHESIS
                        // VALIDATION: Check that other literal is STILL unassigned now
                        if (lit_truth_raw(scan_lit_other_q) != 2'b00) begin
                            $display("[PSE UNIT-VALIDATE] WARNING: Clause %0d other_lit=%0d saved_truth=00 but current_truth=%0b (stale!)",
                                     scan_clause_q, scan_lit_other_q, lit_truth_raw(scan_lit_other_q));
                        end
                        // COMPREHENSIVE VALIDATION: Check ALL clause literals
                        for (int vk = 0; vk < MAX_CLAUSE_LEN; vk++) begin
                            if ($unsigned(vk) < $unsigned(scan_clen_q)) begin
                                logic signed [31:0] vl;
                                logic [1:0] vt;
                                vl = lit_mem[scan_cstart_q + vk];
                                vt = lit_truth_raw(vl);
                                if (vl == scan_lit_other_q) begin
                                    // This is the unit literal — should be unassigned
                                    if (vt != 2'b00)
                                        $display("[PSE PROP-VALIDATE] ERROR: Clause %0d unit_lit=%0d (idx %0d) truth=%0b expected 00",
                                                 scan_clause_q, vl, vk, vt);
                                end else begin
                                    // All other literals should be FALSE
                                    if (vt != 2'b01)
                                        $display("[PSE PROP-VALIDATE] ERROR: Clause %0d non-unit lit=%0d (idx %0d) truth=%0b expected 01 (FALSE). Unit=%0d",
                                                 scan_clause_q, vl, vk, vt, scan_lit_other_q);
                                end
                            end
                        end
`endif
                        propagated_valid  = 1'b1;
                        propagated_var    = scan_lit_other_q;
                        propagated_reason = scan_clause_q;
`ifndef SYNTHESIS
                        if (DEBUG > 0) $display("[PSE TRACE] Unit %0d from Clause %0d (State SCAN_REPL)", scan_lit_other_q, scan_clause_q);
`endif

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
                        // conflict_clause_d already accumulated during SCAN_REPL iterations.
`ifndef SYNTHESIS
                        // VALIDATION: Verify all literals in conflict clause are actually false
                        for (int k = 0; k < MAX_CLAUSE_LEN; k++) begin
                            if ($unsigned(k) < $unsigned(scan_clen_q)) begin
                                if (lit_truth_raw(lit_mem[scan_cstart_q + k]) != 2'b01) begin
                                    $display("[PSE CONFLICT-VALIDATE] ERROR: Clause %0d lit[%0d]=%0d has truth=%0b (expected FALSE=01) at cstart=%0d clen=%0d",
                                             scan_clause_q, k, lit_mem[scan_cstart_q + k], 
                                             lit_truth_raw(lit_mem[scan_cstart_q + k]),
                                             scan_cstart_q, scan_clen_q);
                                end
                            end
                        end
`endif
                        state_d = COMPLETE;
                    end
                end
            end

            // FIX5: Evaluate registered truth result for SCAN_REPL candidate literal
            SCAN_REPL_EVAL: begin
                if (truth_result_a_r != 2'b01 &&
                    safe_lit_idx(scan_repl_lit_q) != safe_lit_idx(scan_lit_watch_q) &&
                    safe_lit_idx(scan_repl_lit_q) != safe_lit_idx(scan_lit_other_q)) begin
                    // Found a suitable replacement — latch params and go to 2-cycle serialized write
                    next_clause = (scan_list_sel_q == 1'b0) ? watch_next1[scan_clause_q] : watch_next2[scan_clause_q];
                    state_d = WATCH_REPL_CYCLE1;
                end else begin
                    // Candidate not suitable, advance to next position
                    scan_idx_d = scan_idx_q + 1'b1;
                    state_d    = SCAN_REPL;
                end
            end

            WATCH_REPL_CYCLE1: begin
                // Cycle 1: remove from old list only (single write per array)
                state_d = WATCH_REPL_CYCLE2;
            end

            WATCH_REPL_CYCLE2: begin
                // Cycle 2: add to new list; then resume SCAN_WATCH
                scan_clause_d = watch_repl_next_clause_q;
                // Continue traversing the OLD list from the clause after the moved
                // node. The previous node in that old list remains the original
                // predecessor, not the moved clause itself.
                scan_prev_d   = watch_repl_prev_id_q;
                state_d       = SCAN_WATCH;
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
                    if (cae_direct_append_en &&
                        clause_count_q < MAX_CLAUSES &&
                        (lit_count_q + cae_direct_append_len) <= MAX_LITS) begin
                        append_idx_d = '0;
                        state_d = APPEND_CLAUSE;
                    end else if (initialized_q) begin
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
            scan_steps_q      <= '0;
            // NOTE: Memory array reset moved to separate sync-only block (below)
            // to enable BRAM/LUTRAM inference. Async reset on memory blocks inference.
            conflict_detected_q   <= 1'b0;
            conflict_clause_len_q <= '0;
            conflict_clause_q     <= '0;
            append_lits_q        <= '0;
            append_len_q         <= '0;
            append_idx_q         <= '0;
            append_clause_base_q <= '0;
            append_clause_id_q   <= '0;
        end else begin
            state_q          <= state_d;
            clause_count_q   <= clause_count_d;
            lit_count_q      <= lit_count_d;

            // Latch incoming clause on the cycle we enter APPEND_CLAUSE.
            if (state_d == APPEND_CLAUSE && state_q != APPEND_CLAUSE) begin
                append_lits_q        <= cae_direct_append_lits;
                append_len_q         <= cae_direct_append_len;
                append_clause_base_q <= lit_count_q;
                append_clause_id_q   <= clause_count_q;
                append_idx_q         <= '0;
            end else begin
                append_idx_q <= append_idx_d;
            end

            // Latch watcher replacement params when entering WATCH_REPL_CYCLE1.
            if (state_d == WATCH_REPL_CYCLE1 && state_q == SCAN_REPL_EVAL) begin
                logic [15:0] nc;
                watch_repl_clause_id_q <= scan_clause_q;
                watch_repl_list_sel_q  <= scan_list_sel_q;
                watch_repl_new_w_q     <= scan_cstart_q + scan_idx_q;
                watch_repl_old_idx_q   <= safe_lit_idx(scan_lit_watch_q);
                watch_repl_new_idx_q   <= safe_lit_idx(scan_repl_lit_q);
                watch_repl_prev_id_q   <= scan_prev_q;
                nc = (scan_list_sel_q == 1'b0) ? watch_next1[scan_clause_q] : watch_next2[scan_clause_q];
                watch_repl_next_clause_q <= (nc == scan_clause_q || (scan_prev_q != 16'hFFFF && nc == scan_prev_q))
                    ? 16'hFFFF : nc;
            end

            cur_clause_len_q <= cur_clause_len_d;
            init_clause_idx_q<= init_clause_idx_d;
            reset_idx_q      <= reset_idx_d;

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
            scan_steps_q      <= scan_steps_d;
            conflict_detected_q <= conflict_detected_d;
            conflict_clause_len_q <= conflict_clause_len_d;
            conflict_clause_q <= conflict_clause_d;

            // NOTE: RESET_WATCHES counter increment stays here (control); memory writes moved below.
            if (state_q == RESET_WATCHES) begin
                reset_idx_q <= reset_idx_q + 1'b1;
            end

            // NOTE: clear_assignments control signals only; memory writes moved to sync-only block.
            if (clear_assignments) begin
                conflict_detected_q   <= 1'b0;
                conflict_clause_len_q <= 4'd0;
                state_q               <= IDLE;
            end
        end
    end

    // ── Combinational read helpers: enables LUTRAM inference for watch arrays ──
    // Async reads see the pre-write (pre-posedge) value — identical semantics to
    // SystemVerilog non-blocking assignment RHS evaluation.
    logic [15:0] iw_w1, iw_w2, iw_idx1, iw_idx2;
    logic [15:0] iw_head1_val, iw_head2_val;
    always_comb begin
        iw_w1        = clause_start[init_clause_idx_q];
        iw_w2        = (clause_len[init_clause_idx_q] > 1)
                       ? clause_start[init_clause_idx_q] + 1
                       : clause_start[init_clause_idx_q];
        iw_idx1      = safe_lit_idx(lit_mem[iw_w1]);
        iw_idx2      = safe_lit_idx(lit_mem[iw_w2]);
        iw_head1_val = watch_head1[iw_idx1];
        iw_head2_val = watch_head2[iw_idx2];
    end

    // Pre-read watch_next for WATCH_REPL_CYCLE1
    logic [15:0] repl_next1_val, repl_next2_val;
    assign repl_next1_val = watch_next1[watch_repl_clause_id_q];
    assign repl_next2_val = watch_next2[watch_repl_clause_id_q];

    // Pre-read watch_head for WATCH_REPL_CYCLE2
    logic [15:0] repl_head1_val, repl_head2_val;
    assign repl_head1_val = watch_head1[watch_repl_new_idx_q];
    assign repl_head2_val = watch_head2[watch_repl_new_idx_q];

    // ─── Block A: Clause store (lit_mem, clause_start, clause_len) ──────────
    // NO async reset — enables LUTRAM inference.
    always_ff @(posedge clk) begin
        if (state_q == APPEND_CLAUSE) begin
            lit_mem[append_clause_base_q + append_idx_q] <= append_lits_q[append_idx_q];
            if (append_idx_q + 1 >= append_len_q) begin
                clause_start[append_clause_id_q] <= append_clause_base_q;
                clause_len[append_clause_id_q]   <= {1'b0, append_len_q};
            end
        end else if (load_fire) begin
            lit_mem[lit_count_q] <= load_literal;
            if (load_clause_end) begin
                clause_start[clause_count_q] <= lit_count_q - cur_clause_len_q;
                clause_len[clause_count_q]   <= cur_clause_len_q + 1'b1;
`ifndef SYNTHESIS
                if (DEBUG >= 2) $display("[PSE DEBUG] LOAD_CLAUSE end: c_idx=%0d, total_len=%0d", clause_count_q, cur_clause_len_q+1);
`endif
            end
        end
    end

    // ─── Block B: Watch list 1 (watched_lit1, watch_next1, watch_head1) ─────
    // Write-mux pattern: single always_comb priority encoder per array,
    // single-write always_ff. Enables Vivado LUTRAM inference.

    // -- watch_head1 write mux --
    logic        wh1_we;
    logic [15:0] wh1_waddr, wh1_wdata;
    always_comb begin
        wh1_we    = 1'b0;
        wh1_waddr = '0;
        wh1_wdata = 16'hFFFF;
        if (state_q == WATCH_REPL_CYCLE1 && !watch_repl_list_sel_q &&
            watch_repl_prev_id_q == 16'hFFFF) begin
            wh1_we    = 1'b1;
            wh1_waddr = watch_repl_old_idx_q;
            wh1_wdata = repl_next1_val;
        end else if (state_q == WATCH_REPL_CYCLE2 && !watch_repl_list_sel_q) begin
            wh1_we    = 1'b1;
            wh1_waddr = watch_repl_new_idx_q;
            wh1_wdata = watch_repl_clause_id_q;
        end else if (state_q == RESET_WATCHES &&
                    reset_idx_q >= MAX_CLAUSES &&
                    reset_idx_q < MAX_CLAUSES + 2*MAX_VARS) begin
            wh1_we    = 1'b1;
            wh1_waddr = reset_idx_q - MAX_CLAUSES;
            wh1_wdata = 16'hFFFF;
        end else if (state_q == INIT_WATCHES && init_clause_idx_q < clause_count_q) begin
            wh1_we    = 1'b1;
            wh1_waddr = iw_idx1;
            wh1_wdata = init_clause_idx_q;
        end
    end
    always_ff @(posedge clk) if (wh1_we) watch_head1[wh1_waddr] <= wh1_wdata;

    // -- watch_next1 write mux --
    logic        wn1_we;
    logic [15:0] wn1_waddr, wn1_wdata;
    always_comb begin
        wn1_we    = 1'b0;
        wn1_waddr = '0;
        wn1_wdata = 16'hFFFF;
        if (state_q == WATCH_REPL_CYCLE1 && !watch_repl_list_sel_q &&
            watch_repl_prev_id_q != 16'hFFFF) begin
            wn1_we    = 1'b1;
            wn1_waddr = watch_repl_prev_id_q;
            wn1_wdata = repl_next1_val;
        end else if (state_q == WATCH_REPL_CYCLE2 && !watch_repl_list_sel_q) begin
            wn1_we    = 1'b1;
            wn1_waddr = watch_repl_clause_id_q;
            wn1_wdata = repl_head1_val;
        end else if (state_q == RESET_WATCHES && reset_idx_q < MAX_CLAUSES) begin
            wn1_we    = 1'b1;
            wn1_waddr = reset_idx_q;
            wn1_wdata = 16'hFFFF;
        end else if (state_q == INIT_WATCHES && init_clause_idx_q < clause_count_q) begin
            wn1_we    = 1'b1;
            wn1_waddr = init_clause_idx_q;
            wn1_wdata = iw_head1_val;
        end
    end
    always_ff @(posedge clk) if (wn1_we) watch_next1[wn1_waddr] <= wn1_wdata;

    // -- watched_lit1 write mux --
    logic        wl1_we;
    logic [15:0] wl1_waddr, wl1_wdata;
    always_comb begin
        wl1_we    = 1'b0;
        wl1_waddr = '0;
        wl1_wdata = 16'hFFFF;
        if (state_q == WATCH_REPL_CYCLE2 && !watch_repl_list_sel_q) begin
            wl1_we    = 1'b1;
            wl1_waddr = watch_repl_clause_id_q;
            wl1_wdata = watch_repl_new_w_q;
        end else if (state_q == RESET_WATCHES && reset_idx_q < MAX_CLAUSES) begin
            wl1_we    = 1'b1;
            wl1_waddr = reset_idx_q;
            wl1_wdata = 16'hFFFF;
        end else if (state_q == INIT_WATCHES && init_clause_idx_q < clause_count_q) begin
            wl1_we    = 1'b1;
            wl1_waddr = init_clause_idx_q;
            wl1_wdata = iw_w1;
        end
    end
    always_ff @(posedge clk) if (wl1_we) watched_lit1[wl1_waddr] <= wl1_wdata;

`ifndef SYNTHESIS
    always_ff @(posedge clk) begin
        if (state_q == INIT_WATCHES && init_clause_idx_q < clause_count_q)
            if (DEBUG >= 2) $display("[MEM] Adding Watch List for %0d and %0d to clause %0d", lit_mem[iw_w1], lit_mem[iw_w2], init_clause_idx_q);
    end
`endif

    // ─── Block C: Watch list 2 (watched_lit2, watch_next2, watch_head2) ─────
    // Write-mux pattern: mirror of Block B for list 2.

    // -- watch_head2 write mux --
    logic        wh2_we;
    logic [15:0] wh2_waddr, wh2_wdata;
    always_comb begin
        wh2_we    = 1'b0;
        wh2_waddr = '0;
        wh2_wdata = 16'hFFFF;
        if (state_q == WATCH_REPL_CYCLE1 && watch_repl_list_sel_q &&
            watch_repl_prev_id_q == 16'hFFFF) begin
            wh2_we    = 1'b1;
            wh2_waddr = watch_repl_old_idx_q;
            wh2_wdata = repl_next2_val;
        end else if (state_q == WATCH_REPL_CYCLE2 && watch_repl_list_sel_q) begin
            wh2_we    = 1'b1;
            wh2_waddr = watch_repl_new_idx_q;
            wh2_wdata = watch_repl_clause_id_q;
        end else if (state_q == RESET_WATCHES &&
                    reset_idx_q >= MAX_CLAUSES &&
                    reset_idx_q < MAX_CLAUSES + 2*MAX_VARS) begin
            wh2_we    = 1'b1;
            wh2_waddr = reset_idx_q - MAX_CLAUSES;
            wh2_wdata = 16'hFFFF;
        end else if (state_q == INIT_WATCHES && init_clause_idx_q < clause_count_q) begin
            wh2_we    = 1'b1;
            wh2_waddr = iw_idx2;
            wh2_wdata = init_clause_idx_q;
        end
    end
    always_ff @(posedge clk) if (wh2_we) watch_head2[wh2_waddr] <= wh2_wdata;

    // -- watch_next2 write mux --
    logic        wn2_we;
    logic [15:0] wn2_waddr, wn2_wdata;
    always_comb begin
        wn2_we    = 1'b0;
        wn2_waddr = '0;
        wn2_wdata = 16'hFFFF;
        if (state_q == WATCH_REPL_CYCLE1 && watch_repl_list_sel_q &&
            watch_repl_prev_id_q != 16'hFFFF) begin
            wn2_we    = 1'b1;
            wn2_waddr = watch_repl_prev_id_q;
            wn2_wdata = repl_next2_val;
        end else if (state_q == WATCH_REPL_CYCLE2 && watch_repl_list_sel_q) begin
            wn2_we    = 1'b1;
            wn2_waddr = watch_repl_clause_id_q;
            wn2_wdata = repl_head2_val;
        end else if (state_q == RESET_WATCHES && reset_idx_q < MAX_CLAUSES) begin
            wn2_we    = 1'b1;
            wn2_waddr = reset_idx_q;
            wn2_wdata = 16'hFFFF;
        end else if (state_q == INIT_WATCHES && init_clause_idx_q < clause_count_q) begin
            wn2_we    = 1'b1;
            wn2_waddr = init_clause_idx_q;
            wn2_wdata = iw_head2_val;
        end
    end
    always_ff @(posedge clk) if (wn2_we) watch_next2[wn2_waddr] <= wn2_wdata;

    // -- watched_lit2 write mux --
    logic        wl2_we;
    logic [15:0] wl2_waddr, wl2_wdata;
    always_comb begin
        wl2_we    = 1'b0;
        wl2_waddr = '0;
        wl2_wdata = 16'hFFFF;
        if (state_q == WATCH_REPL_CYCLE2 && watch_repl_list_sel_q) begin
            wl2_we    = 1'b1;
            wl2_waddr = watch_repl_clause_id_q;
            wl2_wdata = watch_repl_new_w_q;
        end else if (state_q == RESET_WATCHES && reset_idx_q < MAX_CLAUSES) begin
            wl2_we    = 1'b1;
            wl2_waddr = reset_idx_q;
            wl2_wdata = 16'hFFFF;
        end else if (state_q == INIT_WATCHES && init_clause_idx_q < clause_count_q) begin
            wl2_we    = 1'b1;
            wl2_waddr = init_clause_idx_q;
            wl2_wdata = iw_w2;
        end
    end
    always_ff @(posedge clk) if (wl2_we) watched_lit2[wl2_waddr] <= wl2_wdata;

    // ─── Block D: Assignment shadow (assign_state, reason_clause) ───────────
    // Write-mux pattern: single priority encoder per array.

    // -- assign_state write mux --
    logic        as_we;
    logic [15:0] as_waddr;
    logic [1:0]  as_wdata;
    always_comb begin
        as_we    = 1'b0;
        as_waddr = '0;
        as_wdata = 2'b00;
        if (state_q == RESET_WATCHES &&
            reset_idx_q >= MAX_CLAUSES + 2*MAX_VARS &&
            reset_idx_q < MAX_CLAUSES + 2*MAX_VARS + MAX_VARS) begin
            as_we    = 1'b1;
            as_waddr = reset_idx_q - MAX_CLAUSES - 2*MAX_VARS;
            as_wdata = 2'b00;
        end else if (!clear_assignments) begin
            if (clear_valid && clear_var > 0 && clear_var <= MAX_VARS) begin
                as_we    = 1'b1;
                as_waddr = clear_var[15:0] - 1;
                as_wdata = 2'b00;
            end else if (assign_broadcast_valid && assign_broadcast_var > 0 &&
                         assign_broadcast_var <= MAX_VARS) begin
                as_we    = 1'b1;
                as_waddr = assign_broadcast_var[15:0] - 1;
                as_wdata = assign_broadcast_value ? 2'b10 : 2'b01;
            end else if (assign_wr_en) begin
                as_we    = 1'b1;
                as_waddr = assign_wr_idx;
                as_wdata = assign_wr_val;
            end
        end
    end
    always_ff @(posedge clk) if (as_we) assign_state[as_waddr] <= as_wdata;

    // -- reason_clause write mux --
    logic        rc_we;
    logic [15:0] rc_waddr, rc_wdata;
    always_comb begin
        rc_we    = 1'b0;
        rc_waddr = '0;
        rc_wdata = 16'hFFFF;
        if (state_q == RESET_WATCHES &&
            reset_idx_q >= MAX_CLAUSES + 2*MAX_VARS &&
            reset_idx_q < MAX_CLAUSES + 2*MAX_VARS + MAX_VARS) begin
            rc_we    = 1'b1;
            rc_waddr = reset_idx_q - MAX_CLAUSES - 2*MAX_VARS;
            rc_wdata = 16'hFFFF;
        end else if (!clear_assignments) begin
            if (clear_valid && clear_var > 0 && clear_var <= MAX_VARS) begin
                rc_we    = 1'b1;
                rc_waddr = clear_var[15:0] - 1;
                rc_wdata = 16'hFFFF;
            end else if (assign_broadcast_valid && assign_broadcast_var > 0 &&
                         assign_broadcast_var <= MAX_VARS) begin
                if (!reason_wr_en || reason_wr_var != assign_broadcast_var) begin
                    rc_we    = 1'b1;
                    rc_waddr = assign_broadcast_var[15:0] - 1;
                    rc_wdata = assign_broadcast_reason;
                end
            end else if (reason_wr_en && reason_wr_var > 0 && reason_wr_var <= MAX_VARS) begin
                rc_we    = 1'b1;
                rc_waddr = reason_wr_var[15:0] - 1;
                rc_wdata = reason_wr_clause;
            end
        end
    end
    always_ff @(posedge clk) if (rc_we) reason_clause[rc_waddr] <= rc_wdata;
    // ────────────────────────────────────────────────────────────────────────────

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
`ifndef SYNTHESIS
            if (propagated_valid && !propagated_valid_r_q)
                if (DEBUG >= 1) $display("[hw_trace] [PSE] Propagating Unit %0d from Clause %0d", propagated_var, scan_clause_q);
            if (conflict_detected_q && !conflict_detected_r_q)
                if (DEBUG >= 1) $display("[hw_trace] [PSE] Conflict detected in Clause %0d: [%0d, %0d, ...]", scan_clause_q, conflict_clause_q[0], conflict_clause_q[1]);
            if (reason_query_var != 0 && reason_query_var != reason_query_var_r_q)
                 if (DEBUG >= 2) $display("[PSE QUERY] Var=%0d -> Reason=%h Valid=%b", reason_query_var, reason_query_clause, reason_query_valid);
`endif
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
