module cae (
	DEBUG,
	clk,
	reset,
	start,
	decision_level,
	conflict_len,
	conflict_lits,
	conflict_levels,
	learned_valid,
	learned_len,
	learned_clause,
	learned_lbd,
	backtrack_level,
	unsat,
	done,
	trail_read_idx,
	trail_read_var,
	trail_read_value,
	trail_read_level,
	trail_read_is_decision,
	trail_read_reason,
	trail_height,
	reason_query_var,
	reason_query_clause,
	reason_query_valid,
	clause_read_id,
	clause_read_lit_idx,
	clause_read_literal,
	clause_read_len,
	level_query_var,
	level_query_levels
);
	reg _sv2v_0;
	parameter signed [31:0] MAX_LITS = 16;
	parameter signed [31:0] LEVEL_W = 16;
	input wire signed [31:0] DEBUG;
	input wire clk;
	input wire reset;
	input wire start;
	input wire [LEVEL_W - 1:0] decision_level;
	input wire [$clog2(MAX_LITS + 1) - 1:0] conflict_len;
	input wire signed [(MAX_LITS * 32) - 1:0] conflict_lits;
	input wire [(MAX_LITS * LEVEL_W) - 1:0] conflict_levels;
	output reg learned_valid;
	output reg [$clog2(MAX_LITS + 1) - 1:0] learned_len;
	output reg signed [(MAX_LITS * 32) - 1:0] learned_clause;
	output reg [7:0] learned_lbd;
	output wire [LEVEL_W - 1:0] backtrack_level;
	output reg unsat;
	output reg done;
	output reg [15:0] trail_read_idx;
	input wire [31:0] trail_read_var;
	input wire trail_read_value;
	input wire [15:0] trail_read_level;
	input wire trail_read_is_decision;
	input wire [15:0] trail_read_reason;
	input wire [15:0] trail_height;
	output reg [31:0] reason_query_var;
	input wire [15:0] reason_query_clause;
	input wire reason_query_valid;
	output reg [15:0] clause_read_id;
	output reg [$clog2(MAX_LITS + 1) - 1:0] clause_read_lit_idx;
	input wire signed [31:0] clause_read_literal;
	input wire [15:0] clause_read_len;
	output reg [31:0] level_query_var;
	input wire [15:0] level_query_levels;
	reg [3:0] state_q;
	reg [3:0] state_d;
	localparam signed [31:0] MAX_BUFFER = 2 * MAX_LITS;
	reg signed [31:0] buf_lits [0:MAX_BUFFER - 1];
	reg [LEVEL_W - 1:0] buf_levels [0:MAX_BUFFER - 1];
	reg [$clog2(MAX_LITS + 1) - 1:0] buf_count_q;
	reg [$clog2(MAX_LITS + 1) - 1:0] buf_count_d;
	reg [LEVEL_W - 1:0] backtrack_level_comb;
	reg [15:0] trail_scan_idx_q;
	reg [15:0] trail_scan_idx_d;
	reg [$clog2(MAX_LITS + 1) - 1:0] init_idx_q;
	reg [$clog2(MAX_LITS + 1) - 1:0] init_idx_d;
	reg [$clog2(MAX_LITS + 1) - 1:0] reason_lit_idx_q;
	reg [$clog2(MAX_LITS + 1) - 1:0] reason_lit_idx_d;
	reg [15:0] reason_len_q;
	reg [15:0] reason_len_d;
	reg [15:0] reason_clause_id_q;
	reg [15:0] reason_clause_id_d;
	reg signed [31:0] resolve_lit_q;
	reg signed [31:0] resolve_lit_d;
	reg [31:0] resolve_var_q;
	reg [31:0] resolve_var_d;
	reg [LEVEL_W - 1:0] backtrack_d;
	reg [LEVEL_W - 1:0] backtrack_q;
	reg unsat_d;
	reg unsat_q;
	reg learned_valid_d;
	reg learned_valid_q;
	reg [$clog2(MAX_LITS + 1) - 1:0] final_learned_len_q;
	reg [$clog2(MAX_LITS + 1) - 1:0] final_learned_len_d;
	reg signed [31:0] output_clause_q [0:MAX_LITS - 1];
	reg signed [31:0] output_clause_d [0:MAX_LITS - 1];
	reg [7:0] lbd_q;
	reg [7:0] lbd_d;
	reg buf_overflow_q;
	reg buf_overflow_d;
	reg [15:0] dropped_lits_q;
	reg [15:0] dropped_lits_d;
	integer i;
	function automatic [31:0] abs_lit;
		input reg signed [31:0] lit;
		abs_lit = (lit < 0 ? -lit : lit);
	endfunction
	reg signed [31:0] lit;
	reg [31:0] var_idx;
	reg signed [31:0] count;
	reg [31:0] t_var;
	reg found;
	reg signed [31:0] r_lit;
	reg [31:0] r_var;
	reg exists;
	reg [LEVEL_W - 1:0] max_lvl;
	reg [LEVEL_W - 1:0] sec_max_lvl;
	always @(*) begin : sv2v_autoblock_1
		reg [0:1] _sv2v_jump;
		_sv2v_jump = 2'b00;
		begin : sv2v_autoblock_2
			reg found_uip;
			reg signed [31:0] uip_lit;
			reg signed [31:0] out_idx;
			reg signed [31:0] next_count;
			if (_sv2v_0)
				;
			state_d = state_q;
			buf_count_d = buf_count_q;
			trail_scan_idx_d = trail_scan_idx_q;
			init_idx_d = init_idx_q;
			reason_lit_idx_d = reason_lit_idx_q;
			reason_len_d = reason_len_q;
			reason_clause_id_d = reason_clause_id_q;
			resolve_lit_d = resolve_lit_q;
			resolve_var_d = resolve_var_q;
			backtrack_d = backtrack_q;
			unsat_d = unsat_q;
			learned_valid_d = learned_valid_q;
			lbd_d = lbd_q;
			buf_overflow_d = buf_overflow_q;
			dropped_lits_d = dropped_lits_q;
			final_learned_len_d = final_learned_len_q;
			begin : sv2v_autoblock_3
				reg signed [31:0] k;
				for (k = 0; k < MAX_LITS; k = k + 1)
					output_clause_d[k] = output_clause_q[k];
			end
			lit = 1'sb0;
			var_idx = 1'sb0;
			count = 0;
			t_var = 1'sb0;
			found = 1'b0;
			r_lit = 1'sb0;
			r_var = 1'sb0;
			exists = 1'b0;
			max_lvl = 1'sb0;
			sec_max_lvl = 1'sb0;
			done = 1'b0;
			learned_valid = learned_valid_q;
			learned_len = buf_count_q;
			learned_lbd = lbd_q;
			unsat = unsat_q;
			backtrack_level_comb = backtrack_d;
			begin : sv2v_autoblock_4
				reg signed [31:0] k;
				for (k = 0; k < MAX_LITS; k = k + 1)
					learned_clause[k * 32+:32] = output_clause_q[k];
			end
			found_uip = 1'b0;
			uip_lit = 1'sb0;
			out_idx = 0;
			next_count = 0;
			trail_read_idx = trail_scan_idx_q;
			reason_query_var = resolve_var_q;
			clause_read_id = reason_clause_id_q;
			clause_read_lit_idx = reason_lit_idx_q;
			level_query_var = abs_lit(clause_read_literal);
			case (state_q)
				4'd0:
					if (start) begin
						buf_count_d = 0;
						init_idx_d = 0;
						unsat_d = 0;
						learned_valid_d = 0;
						backtrack_d = 0;
						if (trail_height > 0)
							trail_scan_idx_d = trail_height - 1;
						else
							trail_scan_idx_d = 0;
						state_d = 4'd1;
					end
				4'd1:
					if (conflict_len == 0)
						state_d = 4'd7;
					else begin
						buf_count_d = conflict_len;
						if (DEBUG >= 2)
							$display("[CAE DBG] INIT_CLAUSE: Len=%0d Lits={%0d, %0d, %0d, ...} Levels={%0d, %0d, %0d, ...} DecLvl=%0d", conflict_len, conflict_lits[0+:32], conflict_lits[32+:32], conflict_lits[64+:32], conflict_levels[0+:LEVEL_W], conflict_levels[LEVEL_W+:LEVEL_W], conflict_levels[2 * LEVEL_W+:LEVEL_W], decision_level);
						state_d = 4'd2;
					end
				4'd2: begin
					count = 0;
					begin : sv2v_autoblock_5
						reg signed [31:0] k;
						for (k = 0; k < MAX_BUFFER; k = k + 1)
							if ((k < buf_count_q) && (buf_levels[k] == decision_level))
								count = count + 1;
					end
					if (DEBUG >= 2)
						$display("[CAE DBG] COUNT: count=%0d dec_lvl=%0d buf_count=%0d", count, decision_level, buf_count_q);
					begin : sv2v_autoblock_6
						reg signed [31:0] k;
						for (k = 0; k < MAX_BUFFER; k = k + 1)
							if (k < buf_count_q) begin
								if (DEBUG >= 2)
									$display("  [CAE DBG]   buf[%0d]: lit=%0d lvl=%0d", k, buf_lits[k], buf_levels[k]);
							end
					end
					if (count <= 1)
						state_d = 4'd7;
					else
						state_d = 4'd3;
				end
				4'd3: begin
					t_var = trail_read_var;
					found = 1'b0;
					begin : sv2v_autoblock_7
						reg signed [31:0] k;
						for (k = 0; k < MAX_BUFFER; k = k + 1)
							if (((k < buf_count_q) && (abs_lit(buf_lits[k]) == t_var)) && (buf_levels[k] == decision_level)) begin
								found = 1'b1;
								resolve_lit_d = buf_lits[k];
								resolve_var_d = t_var;
							end
					end
					if (found)
						state_d = 4'd4;
					else if (trail_scan_idx_q > 0) begin
						trail_scan_idx_d = trail_scan_idx_q - 16'd1;
						state_d = 4'd3;
					end
					else
						state_d = 4'd7;
				end
				4'd4:
					if (trail_read_reason != 16'hffff) begin
						reason_clause_id_d = trail_read_reason;
						state_d = 4'd5;
						reason_lit_idx_d = 0;
					end
					else
						state_d = 4'd7;
				4'd5: begin
					reason_len_d = clause_read_len;
					state_d = 4'd6;
					reason_lit_idx_d = 0;
				end
				4'd6:
					if (reason_lit_idx_q < reason_len_q) begin
						r_lit = clause_read_literal;
						r_var = abs_lit(r_lit);
						if (r_var != resolve_var_q) begin
							exists = 1'b0;
							begin : sv2v_autoblock_8
								reg signed [31:0] k;
								for (k = 0; k < MAX_BUFFER; k = k + 1)
									if ((k < buf_count_q) && (abs_lit(buf_lits[k]) == r_var))
										exists = 1'b1;
							end
							if (!exists) begin
								if (buf_count_q < MAX_BUFFER)
									buf_count_d = buf_count_q + 1;
								else begin
									buf_overflow_d = 1'b1;
									dropped_lits_d = dropped_lits_q + 1;
									$display("[CAE WARNING] Buffer overflow at cycle %0t: Dropped literal %0d. Total dropped: %0d", $time, r_var, dropped_lits_d);
								end
							end
						end
						reason_lit_idx_d = reason_lit_idx_q + 1;
					end
					else begin
						next_count = 0;
						begin : sv2v_autoblock_9
							reg signed [31:0] k;
							for (k = 0; k < MAX_BUFFER; k = k + 1)
								if ((k < buf_count_q) && (abs_lit(buf_lits[k]) != resolve_var_q))
									next_count = next_count + 1;
						end
						state_d = 4'd2;
						buf_count_d = next_count;
						if (trail_scan_idx_q > 0)
							trail_scan_idx_d = trail_scan_idx_q - 16'd1;
					end
				4'd7: begin
					max_lvl = 0;
					sec_max_lvl = 0;
					unsat_d = (buf_count_q == 0) || (decision_level == 16'd0);
					begin : sv2v_autoblock_10
						reg signed [31:0] k;
						for (k = 0; k < MAX_BUFFER; k = k + 1)
							if (k < buf_count_q) begin
								if (buf_levels[k] > max_lvl)
									max_lvl = buf_levels[k];
							end
					end
					begin : sv2v_autoblock_11
						reg signed [31:0] k;
						for (k = 0; k < MAX_BUFFER; k = k + 1)
							if (k < buf_count_q) begin
								if ((buf_levels[k] != max_lvl) && (buf_levels[k] > sec_max_lvl))
									sec_max_lvl = buf_levels[k];
							end
					end
					begin : sv2v_autoblock_12
						reg [LEVEL_W - 1:0] seen_levels [0:MAX_BUFFER - 1];
						reg signed [31:0] num_distinct;
						reg already_seen;
						num_distinct = 0;
						begin : sv2v_autoblock_13
							reg signed [31:0] k;
							for (k = 0; k < MAX_BUFFER; k = k + 1)
								if (k < buf_count_q) begin
									already_seen = 1'b0;
									begin : sv2v_autoblock_14
										reg signed [31:0] j;
										for (j = 0; j < num_distinct; j = j + 1)
											if (seen_levels[j] == buf_levels[k])
												already_seen = 1'b1;
									end
									if (!already_seen && (num_distinct < MAX_BUFFER)) begin
										seen_levels[num_distinct] = buf_levels[k];
										num_distinct = num_distinct + 1;
									end
								end
						end
						lbd_d = (num_distinct > 255 ? 8'd255 : num_distinct[7:0]);
					end
					begin : sv2v_autoblock_15
						reg signed [31:0] k;
						for (k = 0; k < 8; k = k + 1)
							if (k < buf_count_q)
								;
					end
					found_uip = 1'b0;
					out_idx = 1;
					begin : sv2v_autoblock_16
						reg signed [31:0] k;
						for (k = 0; k < MAX_LITS; k = k + 1)
							output_clause_d[k] = 0;
					end
					begin : sv2v_autoblock_17
						reg signed [31:0] k;
						begin : sv2v_autoblock_18
							reg signed [31:0] _sv2v_value_on_break;
							for (k = 0; k < MAX_BUFFER; k = k + 1)
								if (_sv2v_jump < 2'b10) begin
									_sv2v_jump = 2'b00;
									if (k < buf_count_q) begin
										if (abs_lit(buf_lits[k]) == 0)
											_sv2v_jump = 2'b01;
										if (_sv2v_jump == 2'b00) begin
											if (!found_uip && (buf_levels[k] == max_lvl)) begin
												uip_lit = buf_lits[k];
												output_clause_d[0] = uip_lit;
												found_uip = 1'b1;
											end
											else if (out_idx < MAX_LITS) begin
												output_clause_d[out_idx] = buf_lits[k];
												out_idx = out_idx + 1;
											end
										end
									end
									_sv2v_value_on_break = k;
								end
							if (!(_sv2v_jump < 2'b10))
								k = _sv2v_value_on_break;
							if (_sv2v_jump != 2'b11)
								_sv2v_jump = 2'b00;
						end
					end
					if (_sv2v_jump == 2'b00) begin
						final_learned_len_d = out_idx;
						backtrack_d = sec_max_lvl;
						unsat_d = (buf_count_q == 0) || (decision_level == 0);
						if ((DEBUG >= 1) && learned_valid_d)
							$display("[hw_trace] [CAE] Learned Clause: [%0d, %0d, ...] Backtrack to: %0d Trail Height: %0d", (out_idx > 0 ? output_clause_d[0] : 0), (out_idx > 1 ? output_clause_d[1] : 0), sec_max_lvl, trail_height);
						learned_valid_d = 1'b1;
						state_d = 4'd8;
					end
				end
				4'd8: begin
					done = 1'b1;
					learned_len = final_learned_len_q;
					if (!start)
						state_d = 4'd0;
				end
				default: state_d = 4'd0;
			endcase
		end
	end
	always @(posedge clk or posedge reset)
		if (reset) begin
			state_q <= 4'd0;
			buf_count_q <= 0;
			trail_scan_idx_q <= 0;
			init_idx_q <= 0;
			reason_lit_idx_q <= 0;
			reason_len_q <= 0;
			reason_clause_id_q <= 0;
			resolve_lit_q <= 0;
			resolve_var_q <= 0;
			backtrack_q <= 0;
			unsat_q <= 0;
			learned_valid_q <= 0;
			final_learned_len_q <= 0;
			lbd_q <= 0;
			begin : sv2v_autoblock_19
				reg signed [31:0] k;
				for (k = 0; k < MAX_BUFFER; k = k + 1)
					begin
						buf_lits[k] <= 0;
						buf_levels[k] <= 0;
					end
			end
			begin : sv2v_autoblock_20
				reg signed [31:0] k;
				for (k = 0; k < MAX_LITS; k = k + 1)
					output_clause_q[k] <= 0;
			end
		end
		else begin
			state_q <= state_d;
			buf_count_q <= buf_count_d;
			trail_scan_idx_q <= trail_scan_idx_d;
			init_idx_q <= init_idx_d;
			reason_lit_idx_q <= reason_lit_idx_d;
			reason_len_q <= reason_len_d;
			reason_clause_id_q <= reason_clause_id_d;
			resolve_lit_q <= resolve_lit_d;
			resolve_var_q <= resolve_var_d;
			backtrack_q <= backtrack_d;
			unsat_q <= unsat_d;
			learned_valid_q <= learned_valid_d;
			final_learned_len_q <= final_learned_len_d;
			lbd_q <= lbd_d;
			begin : sv2v_autoblock_21
				reg signed [31:0] k;
				for (k = 0; k < MAX_LITS; k = k + 1)
					output_clause_q[k] <= output_clause_d[k];
			end
			if ((state_q == 4'd1) && (conflict_len > 0)) begin : sv2v_autoblock_22
				reg signed [31:0] idx;
				idx = 0;
				begin : sv2v_autoblock_23
					reg signed [31:0] k;
					for (k = 0; k < MAX_BUFFER; k = k + 1)
						if (k < conflict_len) begin : sv2v_autoblock_24
							reg is_dup;
							is_dup = 0;
							begin : sv2v_autoblock_25
								reg signed [31:0] j;
								for (j = 0; j < MAX_BUFFER; j = j + 1)
									if ((j < k) && (conflict_lits[j * 32+:32] == conflict_lits[k * 32+:32]))
										is_dup = 1;
							end
							if ((!is_dup && (idx < MAX_BUFFER)) && (conflict_lits[k * 32+:32] != 0)) begin
								buf_lits[idx] <= conflict_lits[k * 32+:32];
								buf_levels[idx] <= conflict_levels[k * LEVEL_W+:LEVEL_W];
								idx = idx + 1;
							end
						end
				end
				buf_count_q <= idx;
			end
			else if (state_q == 4'd6) begin
				if (reason_lit_idx_q < reason_len_q) begin : sv2v_autoblock_26
					reg signed [31:0] r_lit_local;
					reg [31:0] r_var_local;
					reg exists_local;
					r_lit_local = clause_read_literal;
					r_var_local = abs_lit(r_lit_local);
					if ((r_var_local != resolve_var_q) && (r_var_local != 0)) begin
						exists_local = 1'b0;
						begin : sv2v_autoblock_27
							reg signed [31:0] k;
							for (k = 0; k < MAX_BUFFER; k = k + 1)
								if ((k < buf_count_q) && (abs_lit(buf_lits[k]) == r_var_local))
									exists_local = 1'b1;
						end
						if (!exists_local) begin
							if (buf_count_q < MAX_BUFFER) begin
								buf_lits[buf_count_q] <= r_lit_local;
								buf_levels[buf_count_q] <= level_query_levels;
							end
							else begin
								buf_overflow_d <= 1'b1;
								dropped_lits_d <= dropped_lits_q + 1;
								$display("[CAE WARNING] Buffer overflow at cycle %0t: Dropped literal %0d. Total dropped: %0d", $time, r_var_local, dropped_lits_d);
							end
						end
					end
				end
				else begin : sv2v_autoblock_28
					reg signed [31:0] w_idx;
					w_idx = 0;
					begin : sv2v_autoblock_29
						reg signed [31:0] k;
						for (k = 0; k < MAX_BUFFER; k = k + 1)
							if (k < buf_count_q) begin
								if (abs_lit(buf_lits[k]) != resolve_var_q) begin
									buf_lits[w_idx] <= buf_lits[k];
									buf_levels[w_idx] <= buf_levels[k];
									w_idx = w_idx + 1;
								end
							end
					end
					buf_count_q <= w_idx;
				end
			end
		end
	always @(posedge clk or posedge reset)
		if (reset) begin
			buf_overflow_q <= 1'b0;
			dropped_lits_q <= 16'b0000000000000000;
		end
		else begin
			buf_overflow_q <= buf_overflow_d;
			dropped_lits_q <= dropped_lits_d;
			if ((state_q == 4'd7) && (state_q != state_d)) begin
				if (buf_overflow_q)
					$display("[CAE WARNING] Learned clause may be INCOMPLETE due to buffer overflow. Dropped %0d literals!", dropped_lits_q);
			end
		end
	assign backtrack_level = backtrack_q;
	initial _sv2v_0 = 0;
endmodule