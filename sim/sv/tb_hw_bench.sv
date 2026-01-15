`timescale 1ns/1ps
module tb_hw_bench;
  logic clk;
  logic rst_n;
  logic start_solve, solve_done, is_sat, is_unsat;
  logic load_valid;
  logic signed [31:0] load_literal;
  logic load_clause_end, load_ready;
  
  satswarmv2_pkg::noc_packet_t rx_pkt [3:0];
  logic rx_valid [3:0], rx_ready [3:0];
  satswarmv2_pkg::noc_packet_t tx_pkt [3:0];
  logic tx_valid [3:0], tx_ready [3:0];
  
  logic global_read_req, global_read_grant, global_read_valid;
  logic [31:0] global_read_addr, global_read_data;
  logic [7:0] global_read_len;
  logic global_write_req, global_write_grant;
  logic [31:0] global_write_addr, global_write_data;
  
  parameter int MAX_VARS = 64;
  parameter int MAX_CLAUSES = 192;
  parameter int MAX_LITS = 516;
  
  int cycle_count;
  int decision_count, conflict_count;
  
  solver_core #(
    .CORE_ID(0), .MAX_VARS(MAX_VARS), .MAX_CLAUSES(MAX_CLAUSES),
    .MAX_LITS(MAX_LITS), .GRID_X(1), .GRID_Y(1)
  ) dut (
    .clk(clk), .rst_n(rst_n), .start_solve(start_solve),
    .solve_done(solve_done), .is_sat(is_sat), .is_unsat(is_unsat),
    .load_valid(load_valid), .load_literal(load_literal),
    .load_clause_end(load_clause_end), .load_ready(load_ready),
    .rx_pkt(rx_pkt), .rx_valid(rx_valid), .rx_ready(rx_ready),
    .tx_pkt(tx_pkt), .tx_valid(tx_valid), .tx_ready(tx_ready),
    .global_read_req(global_read_req), .global_read_addr(global_read_addr),
    .global_read_len(global_read_len), .global_read_grant(global_read_grant),
    .global_read_data(global_read_data), .global_read_valid(global_read_valid),
    .global_write_req(global_write_req), .global_write_addr(global_write_addr),
    .global_write_data(global_write_data), .global_write_grant(global_write_grant)
  );
  
  always_comb begin
    for (int i = 0; i < 4; i++) begin
      rx_pkt[i] = '0; rx_valid[i] = 1'b0; tx_ready[i] = 1'b1;
    end
  end
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      global_read_grant <= 1'b0; global_read_valid <= 1'b0;
      global_read_data <= 32'h0; global_write_grant <= 1'b0;
    end else begin
      global_read_grant <= global_read_req;
      global_read_valid <= global_read_grant;
      global_read_data <= 32'hDEADBEEF;
      global_write_grant <= global_write_req;
    end
  end
  
  initial begin clk = 0; forever #5 clk = ~clk; end
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) cycle_count <= 0;
    else cycle_count <= cycle_count + 1;
  end
  
  // Count decisions
  always_ff @(posedge clk) begin
    if (dut.vde_decision_valid && dut.vde_request) decision_count <= decision_count + 1;
    if (dut.pse_conflict && dut.pse_started_q) conflict_count <= conflict_count + 1;
  end
  
  task automatic load_cnf_file(input string filename);
    int fd; string line; int lit, scan_result, num_vars, num_clauses;
    int literals[$];
    begin
      fd = $fopen(filename, "r");
      if (fd == 0) begin $display("ERROR: Cannot open %s", filename); $finish; end
      while (!$feof(fd)) begin
        if ($fgets(line, fd)) begin
          if (line[0] == "c" || line[0] == "%") continue;
          if (line[0] == "p") continue;
          begin
            int pos = 0; literals.delete();
            while (pos < line.len()) begin
              scan_result = $sscanf(line.substr(pos, line.len()-1), "%d", lit);
              if (scan_result == 1) begin
                if (lit == 0) begin
                  foreach (literals[i]) begin
                    @(posedge clk); while (!load_ready) @(posedge clk);
                    load_valid <= 1'b1; load_literal <= literals[i];
                    load_clause_end <= (i == literals.size()-1);
                    @(posedge clk); load_valid <= 1'b0; load_clause_end <= 1'b0;
                  end
                  break;
                end else literals.push_back(lit);
                while (pos < line.len() && (line[pos] == " " || line[pos] == "\t")) pos++;
                if (lit < 0) pos++;
                while (pos < line.len() && line[pos] >= "0" && line[pos] <= "9") pos++;
              end else break;
            end
          end
        end
      end
      $fclose(fd);
    end
  endtask
  
  initial begin
    decision_count = 0; conflict_count = 0;
    rst_n = 1'b0; start_solve = 1'b0; load_valid = 1'b0;
    load_literal = 32'h0; load_clause_end = 1'b0;
    repeat(10) @(posedge clk); rst_n = 1'b1; repeat(5) @(posedge clk);
    
    load_cnf_file("/Users/tatestaples/Code/VeriSAT/sim/../tests/benchmark_test.cnf");
    
    @(posedge clk); start_solve = 1'b1; @(posedge clk); start_solve = 1'b0;
    
    while (!solve_done && cycle_count < 10000000) @(posedge clk);
    
    $display("RESULT:%s", is_sat ? "SAT" : (is_unsat ? "UNSAT" : "TIMEOUT"));
    $display("CYCLES:%0d", cycle_count);
    $display("DECISIONS:%0d", decision_count);
    $display("CONFLICTS:%0d", conflict_count);
    $finish;
  end
endmodule
