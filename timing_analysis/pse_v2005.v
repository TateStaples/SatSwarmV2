module pse (
	DEBUG,
	clk,
	reset,
	load_valid,
	load_literal,
	load_clause_end,
	load_ready,
	start,
	decision_var,
	done,
	conflict_detected,
	propagated_valid,
	propagated_var,
	propagated_reason,
	max_var_seen,
	clear_assignments,
	clear_valid,
	clear_var,
	assign_broadcast_valid,
	assign_broadcast_var,
	assign_broadcast_value,
	assign_broadcast_reason,
	conflict_clause_len,
	conflict_clause,
	inject_valid,
	inject_lit1,
	inject_lit2,
	inject_is_ref,
	inject_addr,
	inject_len,
	inject_ready,
	global_read_req,
	global_read_addr,
	global_read_len,
	global_read_grant,
	global_read_data,
	global_read_valid,
	reason_query_var,
	reason_query_clause,
	reason_query_valid,
	clause_read_id,
	clause_read_lit_idx,
	clause_read_literal,
	clause_read_len,
	current_clause_count
);
	reg _sv2v_0;
	parameter signed [31:0] MAX_VARS = 256;
	parameter signed [31:0] MAX_CLAUSES = 256;
	parameter signed [31:0] MAX_LITS = 2048;
	parameter signed [31:0] MAX_CLAUSE_LEN = 32;
	parameter signed [31:0] CORE_ID = 0;
	input wire signed [31:0] DEBUG;
	input wire clk;
	input wire reset;
	input wire load_valid;
	input wire signed [31:0] load_literal;
	input wire load_clause_end;
	output wire load_ready;
	input wire start;
	input wire signed [31:0] decision_var;
	output reg done;
	output reg conflict_detected;
	output reg propagated_valid;
	output reg signed [31:0] propagated_var;
	output reg [15:0] propagated_reason;
	output wire [31:0] max_var_seen;
	input wire clear_assignments;
	input wire clear_valid;
	input wire [31:0] clear_var;
	input wire assign_broadcast_valid;
	input wire [31:0] assign_broadcast_var;
	input wire assign_broadcast_value;
	input wire [15:0] assign_broadcast_reason;
	output reg [$clog2(MAX_CLAUSE_LEN + 1) - 1:0] conflict_clause_len;
	output reg signed [(MAX_CLAUSE_LEN * 32) - 1:0] conflict_clause;
	input wire inject_valid;
	input wire signed [31:0] inject_lit1;
	input wire signed [31:0] inject_lit2;
	input wire inject_is_ref;
	input wire [31:0] inject_addr;
	input wire [15:0] inject_len;
	output reg inject_ready;
	output reg global_read_req;
	output reg [31:0] global_read_addr;
	output reg [7:0] global_read_len;
	input wire global_read_grant;
	input wire [31:0] global_read_data;
	input wire global_read_valid;
	input wire [31:0] reason_query_var;
	output reg [15:0] reason_query_clause;
	output reg reason_query_valid;
	input wire [15:0] clause_read_id;
	input wire [$clog2(MAX_CLAUSE_LEN + 1) - 1:0] clause_read_lit_idx;
	output reg signed [31:0] clause_read_literal;
	output reg [15:0] clause_read_len;
	output wire [15:0] current_clause_count;
	reg clause_is_remote [0:MAX_CLAUSES - 1];
	reg signed [31:0] fetch_buffer [0:MAX_CLAUSE_LEN - 1];
	reg [7:0] fetch_idx;
	reg [7:0] fetch_wait_count;
	reg [1:0] assign_state [0:MAX_VARS - 1];
	reg [15:0] reason_clause [0:MAX_VARS - 1];
	reg [15:0] clause_len [0:MAX_CLAUSES - 1];
	reg [15:0] clause_start [0:MAX_CLAUSES - 1];
	reg signed [31:0] lit_mem [0:MAX_LITS - 1];
	reg [15:0] watched_lit1 [0:MAX_CLAUSES - 1];
	reg [15:0] watched_lit2 [0:MAX_CLAUSES - 1];
	reg [15:0] watch_next1 [0:MAX_CLAUSES - 1];
	reg [15:0] watch_next2 [0:MAX_CLAUSES - 1];
	reg [15:0] watch_head1 [0:(2 * MAX_VARS) - 1];
	reg [15:0] watch_head2 [0:(2 * MAX_VARS) - 1];
	wire prop_fifo_empty;
	wire prop_fifo_full;
	wire [$clog2(MAX_LITS):0] prop_fifo_count;
	wire signed [31:0] prop_fifo_out;
	reg prop_pop;
	reg prop_push;
	reg signed [31:0] prop_push_val;
	reg [3:0] state_q;
	sfifo #(
		.WIDTH(32),
		.DEPTH(MAX_LITS)
	) u_prop_q_fifo(
		.clk(clk),
		.rst_n(!reset),
		.push(prop_push),
		.push_data(prop_push_val),
		.pop(prop_pop),
		.pop_data(prop_fifo_out),
		.full(prop_fifo_full),
		.empty(prop_fifo_empty),
		.count(prop_fifo_count),
		.flush(clear_assignments || ((state_q == 4'd0) && start))
	);
	wire cs_wr_en;
	wire [15:0] cs_wr_clause_id;
	wire [15:0] cs_wr_lit_count;
	wire [15:0] cs_wr_clause_start;
	wire [15:0] cs_wr_clause_len;
	wire [15:0] cs_wr_lit_addr;
	wire signed [31:0] cs_wr_literal;
	wire [15:0] cs_rd_clause_id;
	wire [$clog2(MAX_CLAUSE_LEN + 1) - 1:0] cs_rd_lit_idx;
	wire signed [31:0] cs_rd_literal;
	wire [15:0] cs_rd_clause_len;
	wire [15:0] cs_rd_clause_start;
	wire [15:0] cs_mem_addr;
	wire signed [31:0] cs_mem_literal;
	wire wm_clear_all;
	wire [15:0] wm_clear_idx;
	wire wm_link_en;
	wire [15:0] wm_link_clause_id;
	wire [15:0] wm_link_w1;
	wire [15:0] wm_link_w2;
	wire [15:0] wm_link_idx1;
	wire [15:0] wm_link_idx2;
	wire wm_move_en;
	wire [15:0] wm_move_clause_id;
	wire [15:0] wm_move_new_w;
	wire [15:0] wm_move_old_idx;
	wire [15:0] wm_move_new_idx;
	wire [15:0] wm_move_prev_id;
	wire wm_move_list_sel;
	wire [15:0] wm_rd_clause_id;
	wire [15:0] wm_rd_w1;
	wire [15:0] wm_rd_w2;
	wire [15:0] wm_next1;
	wire [15:0] wm_next2;
	wire [15:0] wm_rd_head_idx;
	wire [15:0] wm_head1;
	wire [15:0] wm_head2;
	reg [3:0] state_d;
	reg [15:0] clause_count_q;
	reg [15:0] clause_count_d;
	reg [15:0] lit_count_q;
	reg [15:0] lit_count_d;
	reg [15:0] cur_clause_len_q;
	reg [15:0] cur_clause_len_d;
	reg [15:0] init_clause_idx_q;
	reg [15:0] init_clause_idx_d;
	reg [31:0] max_var_seen_q;
	reg [31:0] max_var_seen_d;
	reg [15:0] reset_idx_q;
	reg [15:0] reset_idx_d;
	reg hold_q;
	reg hold_d;
	reg signed [31:0] cur_prop_lit_q;
	reg signed [31:0] cur_prop_lit_d;
	reg [0:0] scan_list_sel_q;
	reg [0:0] scan_list_sel_d;
	reg [15:0] scan_clause_q;
	reg [15:0] scan_clause_d;
	reg [15:0] scan_prev_q;
	reg [15:0] scan_prev_d;
	reg sampled_q;
	reg sampled_d;
	reg assign_wr_en;
	reg [15:0] assign_wr_idx;
	reg [1:0] assign_wr_val;
	reg initialized_q;
	reg initialized_d;
	reg conflict_detected_q;
	reg conflict_detected_d;
	reg [$clog2(MAX_CLAUSE_LEN + 1) - 1:0] conflict_clause_len_q;
	reg [$clog2(MAX_CLAUSE_LEN + 1) - 1:0] conflict_clause_len_d;
	reg signed [(MAX_CLAUSE_LEN * 32) - 1:0] conflict_clause_q;
	reg signed [(MAX_CLAUSE_LEN * 32) - 1:0] conflict_clause_d;
	reg reason_wr_en;
	reg [31:0] reason_wr_var;
	reg [15:0] reason_wr_clause;
	reg watch_wr_en;
	reg [15:0] watch_wr_clause_id;
	reg watch_wr_list_sel;
	reg [15:0] watch_wr_new_w;
	reg [15:0] watch_wr_old_idx;
	reg [15:0] watch_wr_new_idx;
	reg [15:0] watch_wr_prev_id;
	integer i;
	function automatic [1:0] lit_truth;
		input reg signed [31:0] lit;
		reg [31:0] v;
		reg [31:0] v_idx;
		reg [1:0] current_assign;
		begin
			v = (lit < 0 ? -lit : lit);
			if ((v == 0) || (v > MAX_VARS))
				lit_truth = 2'b00;
			else begin
				if (assign_broadcast_valid && (assign_broadcast_var == v))
					current_assign = (assign_broadcast_value ? 2'b10 : 2'b01);
				else
					current_assign = assign_state[v - 1];
				lit_truth = current_assign;
				if (lit < 0) begin
					if (lit_truth == 2'b01)
						lit_truth = 2'b10;
					else if (lit_truth == 2'b10)
						lit_truth = 2'b01;
				end
			end
		end
	endfunction
	function automatic [15:0] safe_lit_idx;
		input reg signed [31:0] lit;
		reg [31:0] v;
		reg [15:0] raw_idx;
		begin
			v = (lit < 0 ? -lit : lit);
			if ((v == 0) || (v > MAX_VARS))
				safe_lit_idx = 16'd0;
			else begin
				raw_idx = (lit > 0 ? (v - 1) * 2 : ((v - 1) * 2) + 1);
				safe_lit_idx = (raw_idx < (2 * MAX_VARS) ? raw_idx : 16'd0);
			end
		end
	endfunction
	assign load_ready = ((state_q == 4'd0) || (state_q == 4'd1)) || (state_q == 4'd7);
	wire load_fire = load_valid && load_ready;
	always @(*) begin
		if (_sv2v_0)
			;
		if ((reason_query_var > 0) && (reason_query_var <= MAX_VARS)) begin
			reason_query_clause = reason_clause[reason_query_var - 1];
			reason_query_valid = reason_query_clause != 16'hffff;
		end
		else begin
			reason_query_clause = 16'hffff;
			reason_query_valid = 1'b0;
		end
	end
	always @(*) begin
		if (_sv2v_0)
			;
		if (clause_read_id < clause_count_q) begin
			clause_read_len = clause_len[clause_read_id];
			if (clause_read_lit_idx < clause_read_len)
				clause_read_literal = lit_mem[clause_start[clause_read_id] + clause_read_lit_idx];
			else
				clause_read_literal = 1'sb0;
		end
		else begin
			clause_read_len = 1'sb0;
			clause_read_literal = 1'sb0;
		end
	end
	always @(assign_broadcast_var or assign_broadcast_var or assign_broadcast_value or assign_broadcast_var or assign_state or assign_broadcast_var or assign_broadcast_var or prop_push or assign_broadcast_valid or lit_count_q or clause_count_q or lit_count_q or clause_count_q or inject_lit2 or inject_lit1 or inject_lit1 or DEBUG or clause_count_q or inject_lit1 or inject_lit2 or inject_lit1 or inject_lit2 or DEBUG or clause_count_q or inject_lit2 or inject_lit2 or inject_lit1 or DEBUG or inject_lit2 or inject_lit1 or inject_lit2 or assign_state or inject_lit2 or inject_lit2 or inject_lit2 or inject_lit1 or assign_state or inject_lit1 or inject_lit1 or inject_lit1 or lit_count_q or clause_count_q or lit_count_q or clause_count_q or inject_is_ref or scan_clause_q or clause_len or fetch_idx or global_read_valid or global_read_len or global_read_grant or scan_clause_q or clause_len or lit_mem or scan_clause_q or clause_start or start or prop_fifo_empty or conflict_detected_q or clause_count_q or init_clause_idx_q or initialized_q or start or clause_count_q or load_clause_end or max_var_seen_q or load_literal or load_literal or load_literal or lit_count_q or cur_clause_len_q or load_fire or lit_mem or scan_clause_q or watch_next2 or scan_clause_q or watch_next1 or scan_list_sel_q or scan_clause_q or scan_clause_q or lit_mem or scan_list_sel_q or lit_mem or lit_mem or lit_mem or lit_mem or scan_clause_q or scan_clause_q or DEBUG or scan_clause_q or scan_clause_q or watch_next2 or scan_clause_q or watch_next1 or scan_list_sel_q or scan_prev_q or scan_list_sel_q or scan_clause_q or assign_state or assign_broadcast_value or assign_broadcast_var or assign_broadcast_valid or lit_mem or scan_clause_q or watch_next2 or scan_clause_q or watch_next1 or scan_list_sel_q or scan_clause_q or assign_state or assign_broadcast_value or assign_broadcast_var or assign_broadcast_valid or assign_state or assign_broadcast_value or assign_broadcast_var or assign_broadcast_valid or lit_mem or lit_mem or lit_mem or lit_mem or scan_list_sel_q or fetch_buffer[1] or fetch_buffer[0] or scan_clause_q or clause_is_remote or scan_clause_q or clause_len or scan_clause_q or clause_start or scan_clause_q or clause_start or scan_clause_q or watched_lit2 or scan_clause_q or watched_lit1 or scan_clause_q or watch_head2 or cur_prop_lit_q or scan_list_sel_q or scan_clause_q or watch_head1 or prop_fifo_out or prop_fifo_out or prop_fifo_empty or decision_var or decision_var or decision_var or decision_var or decision_var or decision_var or inject_valid or init_clause_idx_q or clause_count_q or init_clause_idx_q or reset_idx_q or reset_idx_q or clause_count_q or init_clause_idx_q or initialized_q or start or clause_count_q or load_clause_end or max_var_seen_q or load_literal or load_literal or load_literal or lit_count_q or cur_clause_len_q or load_fire or conflict_detected_q or hold_q or prop_fifo_empty or clause_count_q or init_clause_idx_q or initialized_q or start or inject_valid or clause_count_q or load_clause_end or max_var_seen_q or load_literal or load_literal or load_literal or lit_count_q or cur_clause_len_q or load_fire or state_q or conflict_clause_q or conflict_clause_len_q or conflict_detected_q or conflict_clause_q or start or conflict_clause_len_q or start or conflict_detected_q or start or hold_q or start or clear_assignments or max_var_seen_q or initialized_q or cur_prop_lit_q or scan_prev_q or scan_clause_q or scan_list_sel_q or reset_idx_q or init_clause_idx_q or cur_clause_len_q or lit_count_q or clause_count_q or state_q or clear_assignments or _sv2v_0) begin : sv2v_autoblock_1
		reg [31:0] v;
		reg signed [31:0] neg_lit;
		reg [15:0] idx;
		reg [15:0] w1;
		reg [15:0] w2;
		reg [15:0] idx1;
		reg [15:0] idx2;
		reg [15:0] base;
		reg [15:0] len;
		reg [15:0] repl_head_idx;
		reg [15:0] old_head_idx;
		reg signed [31:0] lit1;
		reg signed [31:0] lit2;
		reg signed [31:0] lit_watch;
		reg signed [31:0] lit_other;
		reg [1:0] other_truth;
		reg found_repl;
		reg [15:0] repl_idx;
		reg signed [31:0] repl_lit;
		reg [15:0] cstart;
		reg [15:0] clen;
		reg signed [31:0] l;
		reg [1:0] t;
		if (_sv2v_0)
			;
		state_d = (clear_assignments ? 4'd0 : state_q);
		clause_count_d = clause_count_q;
		lit_count_d = lit_count_q;
		cur_clause_len_d = cur_clause_len_q;
		init_clause_idx_d = init_clause_idx_q;
		reset_idx_d = reset_idx_q;
		scan_list_sel_d = scan_list_sel_q;
		scan_clause_d = scan_clause_q;
		scan_prev_d = scan_prev_q;
		cur_prop_lit_d = cur_prop_lit_q;
		initialized_d = initialized_q;
		max_var_seen_d = max_var_seen_q;
		global_read_req = 1'b0;
		global_read_addr = 1'sb0;
		global_read_len = 1'sb0;
		fetch_idx = 1'sb0;
		fetch_wait_count = 1'sb0;
		hold_d = (clear_assignments ? 1'b1 : (start ? 1'b0 : hold_q));
		conflict_detected_d = (start ? 1'b0 : conflict_detected_q);
		conflict_clause_len_d = (start ? {$clog2(MAX_CLAUSE_LEN + 1) {1'sb0}} : conflict_clause_len_q);
		conflict_clause_d = (start ? {MAX_CLAUSE_LEN * 32 {1'sb0}} : conflict_clause_q);
		sampled_d = 1'b0;
		prop_push = 1'b0;
		prop_push_val = 1'sb0;
		prop_pop = 1'b0;
		lit1 = 1'sb0;
		lit2 = 1'sb0;
		idx1 = 1'sb0;
		idx2 = 1'sb0;
		base = 1'sb0;
		len = 1'sb0;
		w1 = 1'sb0;
		w2 = 1'sb0;
		l = 1'sb0;
		t = 1'sb0;
		repl_idx = 1'sb0;
		found_repl = 1'sb0;
		repl_head_idx = 1'sb0;
		old_head_idx = 1'sb0;
		repl_lit = 1'sb0;
		v = 1'sb0;
		idx = 1'sb0;
		neg_lit = 1'sb0;
		repl_head_idx = 1'sb0;
		cstart = 1'sb0;
		clen = 1'sb0;
		lit_watch = 1'sb0;
		lit_other = 1'sb0;
		other_truth = 1'sb0;
		assign_wr_en = 1'b0;
		assign_wr_idx = 1'sb0;
		assign_wr_val = 2'b00;
		reason_wr_en = 1'b0;
		reason_wr_var = 1'sb0;
		reason_wr_clause = 16'hffff;
		watch_wr_en = 1'b0;
		watch_wr_clause_id = 1'sb0;
		watch_wr_list_sel = 1'b0;
		watch_wr_new_w = 1'sb0;
		watch_wr_old_idx = 1'sb0;
		watch_wr_new_idx = 1'sb0;
		watch_wr_prev_id = 1'sb0;
		propagated_valid = 1'b0;
		propagated_var = 1'sb0;
		propagated_reason = 16'hffff;
		done = 1'b0;
		inject_ready = 1'b0;
		conflict_detected = conflict_detected_q;
		conflict_clause_len = conflict_clause_len_q;
		conflict_clause = conflict_clause_q;
		case (state_q)
			4'd0:
				if (load_fire) begin
					cur_clause_len_d = cur_clause_len_q + 1'b1;
					lit_count_d = lit_count_q + 1'b1;
					v = (load_literal < 0 ? -load_literal : load_literal);
					if (v > max_var_seen_q)
						max_var_seen_d = v;
					if (load_clause_end) begin
						clause_count_d = clause_count_q + 1'b1;
						cur_clause_len_d = 1'sb0;
					end
					state_d = 4'd1;
				end
				else if (inject_valid)
					state_d = 4'd8;
				else if (start) begin
					if (initialized_q) begin
						if (init_clause_idx_q < clause_count_q)
							state_d = 4'd3;
						else
							state_d = 4'd4;
					end
					else begin
						reset_idx_d = 1'sb0;
						state_d = 4'd2;
					end
				end
				else if ((!prop_fifo_empty && !hold_q) && !conflict_detected_q)
					state_d = 4'd5;
			4'd1:
				if (load_fire) begin
					cur_clause_len_d = cur_clause_len_q + 1'b1;
					lit_count_d = lit_count_q + 1'b1;
					v = (load_literal < 0 ? -load_literal : load_literal);
					if (v > max_var_seen_q)
						max_var_seen_d = v;
					if (load_clause_end) begin
						clause_count_d = clause_count_q + 1'b1;
						cur_clause_len_d = 1'sb0;
					end
					state_d = 4'd1;
				end
				else if (start) begin
					if (initialized_q) begin
						if (init_clause_idx_q < clause_count_q)
							state_d = 4'd3;
						else
							state_d = 4'd4;
					end
					else begin
						reset_idx_d = 1'sb0;
						state_d = 4'd2;
					end
				end
				else
					state_d = 4'd0;
			4'd2:
				if (reset_idx_q < (MAX_CLAUSES + (2 * MAX_VARS)))
					reset_idx_d = reset_idx_q + 1'b1;
				else begin
					init_clause_idx_d = 1'sb0;
					state_d = 4'd3;
				end
			4'd3:
				if (init_clause_idx_q < clause_count_q)
					init_clause_idx_d = init_clause_idx_q + 1'b1;
				else begin
					initialized_d = 1'b1;
					state_d = 4'd4;
				end
			4'd4: begin
				if (inject_valid) begin
					inject_ready = 1'b1;
					state_d = 4'd8;
				end
				else if (decision_var != 0) begin
					v = (decision_var < 0 ? -decision_var : decision_var);
					if ((v != 0) && (v <= MAX_VARS)) begin
						assign_wr_en = 1'b1;
						assign_wr_idx = v - 1;
						assign_wr_val = (decision_var < 0 ? 2'b01 : 2'b10);
						prop_push = 1'b1;
						prop_push_val = decision_var;
						reason_wr_en = 1'b1;
						reason_wr_var = v;
						reason_wr_clause = 16'hffff;
					end
				end
				scan_list_sel_d = 1'b0;
				state_d = 4'd5;
			end
			4'd5:
				if (prop_fifo_empty) begin
					done = 1'b1;
					state_d = 4'd7;
				end
				else begin
					cur_prop_lit_d = prop_fifo_out;
					prop_pop = 1'b1;
					scan_list_sel_d = 1'b0;
					neg_lit = -prop_fifo_out;
					scan_clause_d = watch_head1[safe_lit_idx(neg_lit)];
					scan_prev_d = 16'hffff;
					state_d = 4'd6;
				end
			4'd6:
				if (scan_clause_q == 16'hffff) begin
					if (scan_list_sel_q == 1'b0) begin
						scan_list_sel_d = 1'b1;
						neg_lit = -cur_prop_lit_q;
						scan_clause_d = watch_head2[safe_lit_idx(neg_lit)];
						scan_prev_d = 16'hffff;
						state_d = 4'd6;
					end
					else
						state_d = 4'd5;
				end
				else if (scan_clause_q >= MAX_CLAUSES)
					state_d = 4'd7;
				else begin
					w1 = watched_lit1[scan_clause_q];
					w2 = watched_lit2[scan_clause_q];
					cstart = clause_start[scan_clause_q];
					cstart = clause_start[scan_clause_q];
					clen = clause_len[scan_clause_q];
					if (clause_is_remote[scan_clause_q]) begin
						lit_watch = fetch_buffer[0];
						lit_other = fetch_buffer[1];
					end
					else if (scan_list_sel_q == 1'b0) begin
						lit_watch = lit_mem[w1];
						lit_other = lit_mem[w2];
					end
					else begin
						lit_watch = lit_mem[w2];
						lit_other = lit_mem[w1];
					end
					other_truth = lit_truth(lit_other);
					if ((other_truth == 2'b10) || (lit_truth(lit_watch) != 2'b01)) begin
						scan_prev_d = scan_clause_q;
						scan_clause_d = (scan_list_sel_q == 1'b0 ? watch_next1[scan_clause_q] : watch_next2[scan_clause_q]);
					end
					else begin
						found_repl = 1'b0;
						repl_idx = 1'sb0;
						repl_lit = 1'sb0;
						begin : sv2v_autoblock_2
							reg signed [31:0] j;
							for (j = 0; j < MAX_CLAUSE_LEN; j = j + 1)
								if (!found_repl && ($unsigned(j) < $unsigned(clen))) begin
									if (((cstart + j) != w1) && ((cstart + j) != w2)) begin
										l = lit_mem[cstart + j];
										if (lit_truth(l) != 2'b01) begin
											found_repl = 1'b1;
											repl_idx = cstart + j;
											repl_lit = l;
										end
									end
								end
						end
						if (found_repl) begin
							watch_wr_en = 1'b1;
							watch_wr_clause_id = scan_clause_q;
							watch_wr_list_sel = scan_list_sel_q;
							watch_wr_new_w = repl_idx;
							watch_wr_old_idx = safe_lit_idx(lit_watch);
							watch_wr_new_idx = safe_lit_idx(repl_lit);
							watch_wr_prev_id = scan_prev_q;
							scan_clause_d = (scan_list_sel_q == 1'b0 ? watch_next1[scan_clause_q] : watch_next2[scan_clause_q]);
						end
						else if (other_truth == 2'b00) begin
							v = (lit_other < 0 ? -lit_other : lit_other);
							propagated_valid = 1'b1;
							propagated_var = lit_other;
							propagated_reason = scan_clause_q;
							if (DEBUG > 0)
								$display("[PSE TRACE] Unit %0d from Clause %0d (State SCAN_WATCH)", lit_other, scan_clause_q);
							if (lit_other == 0) begin
								$display("\n[PSE ERROR] Clause %0d implies Var 0! Dumping state:", scan_clause_q);
								$display("  w1=%0d (idx=%0d) lit=%0d", w1, safe_lit_idx(lit_mem[w1]), lit_mem[w1]);
								$display("  w2=%0d (idx=%0d) lit=%0d", w2, safe_lit_idx(lit_mem[w2]), lit_mem[w2]);
								$display("  scan_list_sel=%0d (0=w1 list, 1=w2 list)", scan_list_sel_q);
								$display("  cstart=%0d clen=%0d", cstart, clen);
								$display("  Literal Memory Dump for Clause:");
								begin : sv2v_autoblock_3
									reg signed [31:0] k;
									for (k = 0; k < 8; k = k + 1)
										$display("    lit[%0d] = %0d", k, lit_mem[cstart + k]);
								end
								$display("Fatal [%0t] src/Mega/pse.sv:605:33 - pse.<unnamed_block>.<unnamed_block>.<unnamed_block>.<unnamed_block>.<unnamed_block>.<unnamed_block>.<unnamed_block>\n msg: ", $time, "PSE Critical Error: Implied Var 0");

							end
							assign_wr_en = 1'b1;
							assign_wr_idx = v - 1;
							assign_wr_val = (lit_other < 0 ? 2'b01 : 2'b10);
							prop_push = 1'b1;
							prop_push_val = lit_other;
							reason_wr_en = 1'b1;
							reason_wr_var = v;
							reason_wr_clause = scan_clause_q;
							scan_prev_d = scan_clause_q;
							scan_clause_d = (scan_list_sel_q == 1'b0 ? watch_next1[scan_clause_q] : watch_next2[scan_clause_q]);
						end
						else begin
							conflict_detected_d = 1'b1;
							conflict_clause_len_d = clen[$clog2(MAX_CLAUSE_LEN + 1) - 1:0];
							begin : sv2v_autoblock_4
								reg signed [31:0] k;
								for (k = 0; k < MAX_CLAUSE_LEN; k = k + 1)
									if ($unsigned(k) < $unsigned(clen))
										conflict_clause_d[k * 32+:32] = lit_mem[cstart + k];
							end
							state_d = 4'd7;
						end
					end
				end
			4'd7: begin
				done = 1'b1;
				if (load_fire) begin
					cur_clause_len_d = cur_clause_len_q + 1'b1;
					lit_count_d = lit_count_q + 1'b1;
					v = (load_literal < 0 ? -load_literal : load_literal);
					if (v > max_var_seen_q)
						max_var_seen_d = v;
					if (load_clause_end) begin
						clause_count_d = clause_count_q + 1'b1;
						cur_clause_len_d = 1'sb0;
					end
					state_d = 4'd1;
				end
				else if (start) begin
					if (initialized_q) begin
						if (init_clause_idx_q < clause_count_q)
							state_d = 4'd3;
						else
							state_d = 4'd4;
					end
					else begin
						reset_idx_d = 1'sb0;
						state_d = 4'd2;
					end
				end
				else if (!conflict_detected_q && !prop_fifo_empty)
					state_d = 4'd5;
				else if (!start)
					state_d = 4'd0;
			end
			4'd9: begin : sv2v_autoblock_5
				reg [15:0] cs;
				reg [31:0] ddr_ptr;
				cs = clause_start[scan_clause_q];
				ddr_ptr = lit_mem[cs];
				global_read_req = 1'b1;
				global_read_addr = ddr_ptr;
				global_read_len = clause_len[scan_clause_q][7:0];
				if (global_read_grant) begin
					fetch_wait_count = global_read_len;
					state_d = 4'd10;
				end
			end
			4'd10:
				if (global_read_valid) begin
					if (fetch_idx == (clause_len[scan_clause_q] - 1))
						state_d = 4'd6;
				end
			4'd8: begin : sv2v_autoblock_6
				reg [1:0] t1;
				reg [1:0] t2;
				if (inject_is_ref) begin
					if ((clause_count_q < MAX_CLAUSES) && (lit_count_q < (MAX_LITS - 1))) begin
						clause_count_d = clause_count_q + 1'b1;
						lit_count_d = lit_count_q + 1'b1;
					end
				end
				else begin : sv2v_autoblock_7
					reg [31:0] v1;
					reg [31:0] v2;
					reg [1:0] a1;
					reg [1:0] a2;
					v1 = (inject_lit1 < 0 ? -inject_lit1 : inject_lit1);
					if ((v1 == 0) || (v1 > MAX_VARS))
						t1 = 2'b00;
					else begin
						a1 = assign_state[v1 - 1];
						t1 = a1;
						if (inject_lit1 < 0) begin
							if (t1 == 2'b01)
								t1 = 2'b10;
							else if (t1 == 2'b10)
								t1 = 2'b01;
						end
					end
					v2 = (inject_lit2 < 0 ? -inject_lit2 : inject_lit2);
					if ((v2 == 0) || (v2 > MAX_VARS))
						t2 = 2'b00;
					else begin
						a2 = assign_state[v2 - 1];
						t2 = a2;
						if (inject_lit2 < 0) begin
							if (t2 == 2'b01)
								t2 = 2'b10;
							else if (t2 == 2'b10)
								t2 = 2'b01;
						end
					end
					if ((t1 == 2'b01) && (t2 == 2'b01)) begin
						conflict_detected_d = 1'b1;
						conflict_clause_len_d = 4'd2;
						conflict_clause_d[0+:32] = inject_lit1;
						conflict_clause_d[32+:32] = inject_lit2;
						if (DEBUG > 0)
							$display("[PSE] IMMEDIATE CONFLICT on Injection: {%0d, %0d}", inject_lit1, inject_lit2);
					end
					else if ((t1 == 2'b01) && (t2 == 2'b00)) begin
						propagated_valid = 1'b1;
						propagated_var = inject_lit2;
						propagated_reason = clause_count_q;
						if (DEBUG > 0)
							$display("[PSE] IMMEDIATE UNIT on Injection: %0d from {%0d, %0d}", inject_lit2, inject_lit1, inject_lit2);
					end
					else if ((t1 == 2'b00) && (t2 == 2'b01)) begin
						propagated_valid = 1'b1;
						propagated_var = inject_lit1;
						propagated_reason = clause_count_q;
						if (DEBUG > 0)
							$display("[PSE] IMMEDIATE UNIT on Injection: %0d from {%0d, %0d}", inject_lit1, inject_lit1, inject_lit2);
					end
					if ((clause_count_q < MAX_CLAUSES) && (lit_count_q < (MAX_LITS - 2))) begin
						clause_count_d = clause_count_q + 1'b1;
						lit_count_d = lit_count_q + 2'd2;
					end
				end
				inject_ready = 1'b1;
				state_d = 4'd4;
			end
			default: state_d = 4'd0;
		endcase
		if (assign_broadcast_valid && !prop_push) begin
			if (((assign_broadcast_var > 0) && (assign_broadcast_var <= MAX_VARS)) && (assign_state[assign_broadcast_var - 1] == 2'b00)) begin
				prop_push = 1'b1;
				prop_push_val = (assign_broadcast_value ? $signed(assign_broadcast_var) : -$signed(assign_broadcast_var));
			end
		end
	end
	always @(posedge clk or posedge reset)
		if (reset) begin
			state_q <= 4'd0;
			clause_count_q <= 1'sb0;
			lit_count_q <= 1'sb0;
			cur_clause_len_q <= 1'sb0;
			init_clause_idx_q <= 1'sb0;
			reset_idx_q <= 1'sb0;
			max_var_seen_q <= 1'sb0;
			scan_list_sel_q <= 1'sb0;
			scan_clause_q <= 16'hffff;
			scan_prev_q <= 16'hffff;
			cur_prop_lit_q <= 1'sb0;
			initialized_q <= 1'b0;
			hold_q <= 1'b0;
			for (i = 0; i < MAX_VARS; i = i + 1)
				begin
					assign_state[i] <= 2'b00;
					reason_clause[i] <= 16'hffff;
				end
			for (i = 0; i < (2 * MAX_VARS); i = i + 1)
				begin
					watch_head1[i] <= 16'hffff;
					watch_head2[i] <= 16'hffff;
				end
			conflict_detected_q <= 1'b0;
			conflict_clause_len_q <= 1'sb0;
			conflict_clause_q <= 1'sb0;
		end
		else begin
			state_q <= state_d;
			clause_count_q <= clause_count_d;
			lit_count_q <= lit_count_d;
			cur_clause_len_q <= cur_clause_len_d;
			init_clause_idx_q <= init_clause_idx_d;
			reset_idx_q <= reset_idx_d;
			if (reset_idx_q < MAX_CLAUSES)
				clause_is_remote[reset_idx_q] <= 1'b0;
			if (($time % 10000) == 0)
				;
			max_var_seen_q <= max_var_seen_d;
			scan_list_sel_q <= scan_list_sel_d;
			scan_clause_q <= scan_clause_d;
			scan_prev_q <= scan_prev_d;
			cur_prop_lit_q <= cur_prop_lit_d;
			sampled_q <= sampled_d;
			initialized_q <= initialized_d;
			hold_q <= hold_d;
			conflict_detected_q <= conflict_detected_d;
			conflict_clause_len_q <= conflict_clause_len_d;
			conflict_clause_q <= conflict_clause_d;
			if (load_fire) begin
				lit_mem[lit_count_q] <= load_literal;
				if (load_clause_end) begin
					clause_start[clause_count_q] <= lit_count_q - cur_clause_len_q;
					clause_len[clause_count_q] <= cur_clause_len_q + 1'b1;
					clause_is_remote[clause_count_q] <= 1'b0;
					if (DEBUG >= 2)
						$display("[PSE DEBUG] LOAD_CLAUSE end: c_idx=%0d, total_len=%0d", clause_count_q, cur_clause_len_q + 1);
				end
			end
			if (state_q == 4'd8) begin
				if (inject_is_ref) begin
					lit_mem[lit_count_q] <= inject_addr;
					clause_start[clause_count_q] <= lit_count_q;
					clause_len[clause_count_q] <= inject_len;
					clause_is_remote[clause_count_q] <= 1'b1;
					if (DEBUG > 0)
						$display("[PSE] Injecting Remote Ref: id=%0d ptr=%h len=%0d", clause_count_q, inject_addr, inject_len);
				end
				else if ((clause_count_q < MAX_CLAUSES) && (lit_count_q < (MAX_LITS - 2))) begin
					lit_mem[lit_count_q] <= inject_lit1;
					lit_mem[lit_count_q + 1] <= inject_lit2;
					clause_start[clause_count_q] <= lit_count_q;
					clause_len[clause_count_q] <= 16'd2;
					clause_is_remote[clause_count_q] <= 1'b0;
					if (DEBUG > 0)
						$display("[PSE] Injecting Local 2-Lit: id=%0d {%0d, %0d}", clause_count_q, inject_lit1, inject_lit2);
				end
			end
			if ((state_q == 4'd10) && global_read_valid) begin
				if (fetch_idx < MAX_CLAUSE_LEN) begin
					fetch_buffer[fetch_idx] <= $signed(global_read_data);
					fetch_idx <= fetch_idx + 1;
				end
			end
			if (state_q == 4'd9)
				fetch_idx <= 1'sb0;
			if (state_q == 4'd2) begin
				if (reset_idx_q < MAX_CLAUSES) begin
					watched_lit1[reset_idx_q] <= 16'hffff;
					watched_lit2[reset_idx_q] <= 16'hffff;
					watch_next1[reset_idx_q] <= 16'hffff;
					watch_next2[reset_idx_q] <= 16'hffff;
				end
				else if (reset_idx_q < (MAX_CLAUSES + (2 * MAX_VARS))) begin
					watch_head1[reset_idx_q - MAX_CLAUSES] <= 16'hffff;
					watch_head2[reset_idx_q - MAX_CLAUSES] <= 16'hffff;
				end
				reset_idx_q <= reset_idx_q + 1'b1;
			end
			if ((state_q == 4'd3) && (init_clause_idx_q < clause_count_q)) begin : sv2v_autoblock_8
				reg [15:0] c;
				reg [15:0] b;
				reg [15:0] l;
				reg [15:0] w1;
				reg [15:0] w2;
				reg [15:0] idx1;
				reg [15:0] idx2;
				c = init_clause_idx_q;
				b = clause_start[c];
				l = clause_len[c];
				w1 = b;
				w2 = (l > 1 ? b + 1 : b);
				idx1 = safe_lit_idx(lit_mem[w1]);
				idx2 = safe_lit_idx(lit_mem[w2]);
				watched_lit1[c] <= w1;
				watched_lit2[c] <= w2;
				watch_next1[c] <= watch_head1[idx1];
				watch_head1[idx1] <= c;
				watch_next2[c] <= watch_head2[idx2];
				watch_head2[idx2] <= c;
				if (DEBUG >= 2)
					$display("[MEM] Adding Watch List for %0d and %0d to clause %0d", lit_mem[w1], lit_mem[w2], c);
			end
			if (watch_wr_en) begin
				if (watch_wr_list_sel == 1'b0) begin
					if (DEBUG >= 2)
						$display("[hw_trace] [PSE] Replaced watcher %0d with %0d for clause %0d", lit_mem[watched_lit1[watch_wr_clause_id]], lit_mem[watch_wr_new_w], watch_wr_clause_id);
					watched_lit1[watch_wr_clause_id] <= watch_wr_new_w;
					if (watch_wr_prev_id == 16'hffff)
						watch_head1[watch_wr_old_idx] <= watch_next1[watch_wr_clause_id];
					else
						watch_next1[watch_wr_prev_id] <= watch_next1[watch_wr_clause_id];
					watch_next1[watch_wr_clause_id] <= watch_head1[watch_wr_new_idx];
					watch_head1[watch_wr_new_idx] <= watch_wr_clause_id;
				end
				else begin
					if (DEBUG >= 2)
						$display("[hw_trace] [PSE] Replaced watcher %0d with %0d for clause %0d", lit_mem[watched_lit2[watch_wr_clause_id]], lit_mem[watch_wr_new_w], watch_wr_clause_id);
					watched_lit2[watch_wr_clause_id] <= watch_wr_new_w;
					if (watch_wr_prev_id == 16'hffff)
						watch_head2[watch_wr_old_idx] <= watch_next2[watch_wr_clause_id];
					else
						watch_next2[watch_wr_prev_id] <= watch_next2[watch_wr_clause_id];
					watch_next2[watch_wr_clause_id] <= watch_head2[watch_wr_new_idx];
					watch_head2[watch_wr_new_idx] <= watch_wr_clause_id;
				end
			end
			if (clear_assignments) begin
				for (i = 0; i < MAX_VARS; i = i + 1)
					begin
						assign_state[i] <= 2'b00;
						reason_clause[i] <= 16'hffff;
					end
				conflict_detected_q <= 1'b0;
				conflict_clause_len_q <= 4'd0;
				state_q <= 4'd0;
			end
			else begin
				if (assign_wr_en)
					assign_state[assign_wr_idx] <= assign_wr_val;
				if ((reason_wr_en && (reason_wr_var > 0)) && (reason_wr_var <= MAX_VARS))
					reason_clause[reason_wr_var - 1] <= reason_wr_clause;
				if ((assign_broadcast_valid && (assign_broadcast_var > 0)) && (assign_broadcast_var <= MAX_VARS)) begin
					assign_state[assign_broadcast_var - 1] <= (assign_broadcast_value ? 2'b10 : 2'b01);
					if (!reason_wr_en || (reason_wr_var != assign_broadcast_var))
						reason_clause[assign_broadcast_var - 1] <= assign_broadcast_reason;
				end
				if ((clear_valid && (clear_var > 0)) && (clear_var <= MAX_VARS)) begin
					assign_state[clear_var - 1] <= 2'b00;
					reason_clause[clear_var - 1] <= 16'hffff;
				end
			end
		end
	assign max_var_seen = max_var_seen_q;
	assign current_clause_count = clause_count_q;
	reg conflict_detected_r_q;
	reg propagated_valid_r_q;
	reg [31:0] reason_query_var_r_q;
	always @(posedge clk or posedge reset)
		if (reset) begin
			conflict_detected_r_q <= 1'b0;
			propagated_valid_r_q <= 1'b0;
			reason_query_var_r_q <= 1'sb0;
		end
		else begin
			if (propagated_valid && !propagated_valid_r_q) begin
				if (DEBUG >= 1)
					$display("[hw_trace] [PSE] Propagating Unit %0d from Clause %0d", propagated_var, scan_clause_q);
			end
			if (conflict_detected_q && !conflict_detected_r_q) begin
				if (DEBUG >= 1)
					$display("[hw_trace] [PSE] Conflict detected in Clause %0d: [%0d, %0d, ...]", scan_clause_q, conflict_clause_q[0+:32], conflict_clause_q[32+:32]);
			end
			if ((reason_query_var != 0) && (reason_query_var != reason_query_var_r_q)) begin
				if (DEBUG >= 2)
					$display("[PSE QUERY] Var=%0d -> Reason=%h Valid=%b", reason_query_var, reason_query_clause, reason_query_valid);
			end
			conflict_detected_r_q <= conflict_detected_q;
			propagated_valid_r_q <= propagated_valid;
			reason_query_var_r_q <= reason_query_var;
		end
	always @(posedge clk) begin
		if (clause_count_q >= MAX_CLAUSES) begin
			$display("\n[ERROR] Hardware Limit Reached: Clause Count (%0d) >= MAX_CLAUSES (%0d)", clause_count_q, MAX_CLAUSES);
			$display("[ERROR] Simulation Terminated due to memory exhaustion.");
			
		end
		if (lit_count_q >= (MAX_LITS - 2)) begin
			$display("\n[ERROR] Hardware Limit Reached: Literal Count (%0d) >= MAX_LITS (%0d)", lit_count_q, MAX_LITS);
			$display("[ERROR] Simulation Terminated due to memory exhaustion.");
			
		end
	end
	initial _sv2v_0 = 0;
endmodule