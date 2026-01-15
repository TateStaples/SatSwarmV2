#!/usr/bin/env python3
"""
VeriSAT Hardware Benchmark Script
Tests hardware simulation on different problem sizes by:
1. Generating a CNF file
2. Updating the testbench to load it
3. Rebuilding and running
4. Measuring cycles and wall time
"""

import os
import sys
import time
import random
import subprocess
import shutil

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)) + '/../tests')
from pysat.solvers import Glucose3

SIM_DIR = os.path.dirname(os.path.abspath(__file__))
TEST_CNF = os.path.join(SIM_DIR, '../tests/benchmark_test.cnf')

def generate_cnf(k, n, m, seed=None):
    """Generates a random k-SAT instance."""
    if seed is not None:
        random.seed(seed)
    vars_list = list(range(1, n + 1))
    clauses = []
    for _ in range(m):
        rand_vars = random.sample(vars_list, min(k, n))
        clause = []
        for var in rand_vars:
            if random.randint(0, 1) == 1:
                clause.append(-var)
            else:
                clause.append(var)
        clauses.append(clause)
    return clauses

def save_cnf(filename, clauses, n, m):
    with open(filename, 'w') as f:
        f.write(f"p cnf {n} {m}\n")
        for clause in clauses:
            f.write(" ".join(map(str, clause)) + " 0\n")

def check_sat_glucose(clauses):
    """Check SAT/UNSAT using Glucose3."""
    with Glucose3(bootstrap_with=clauses) as solver:
        return solver.solve()

def run_python_sim(cnf_file, timeout=60):
    """Run Python simulation."""
    gen_trace = os.path.join(SIM_DIR, 'gen_trace.py')
    start = time.time()
    try:
        result = subprocess.run(
            ['python3', gen_trace, cnf_file],
            capture_output=True, text=True, timeout=timeout
        )
        elapsed = time.time() - start
        output = result.stdout
        
        # Parse decisions count
        import re
        match = re.search(r'Decisions: (\d+)', output)
        decisions = int(match.group(1)) if match else 0
        
        if 'Final Result: SAT' in output:
            return 'SAT', elapsed, decisions
        elif 'Final Result: UNSAT' in output:
            return 'UNSAT', elapsed, decisions
        return 'ERROR', elapsed, 0
    except subprocess.TimeoutExpired:
        return 'TIMEOUT', timeout, 0

def create_hw_testbench(n_vars, n_clauses, cnf_path):
    """Create a hardware testbench for the given CNF file."""
    # Adjust MAX_VARS and MAX_CLAUSES based on problem size
    max_vars = max(64, ((n_vars // 32) + 1) * 32)
    max_clauses = max(128, ((n_clauses // 64) + 1) * 64)
    max_lits = max(512, n_clauses * 4)
    
    # Calculate timeout cycles based on estimated complexity
    # Simple heuristic: 1000 cycles per variable at exponential
    timeout_cycles = min(10000000, 1000 * (2 ** min(n_vars, 15)))
    
    testbench = f'''`timescale 1ns/1ps
module tb_hw_bench;
  logic clk;
  logic rst_n;
  logic start_solve, solve_done, is_sat, is_unsat;
  logic load_valid;
  logic signed [31:0] load_literal;
  logic load_clause_end, load_ready;
  
  verisat_pkg::noc_packet_t rx_pkt [3:0];
  logic rx_valid [3:0], rx_ready [3:0];
  verisat_pkg::noc_packet_t tx_pkt [3:0];
  logic tx_valid [3:0], tx_ready [3:0];
  
  logic global_read_req, global_read_grant, global_read_valid;
  logic [31:0] global_read_addr, global_read_data;
  logic [7:0] global_read_len;
  logic global_write_req, global_write_grant;
  logic [31:0] global_write_addr, global_write_data;
  
  parameter int MAX_VARS = {max_vars};
  parameter int MAX_CLAUSES = {max_clauses};
  parameter int MAX_LITS = {max_lits};
  
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
                while (pos < line.len() && (line[pos] == " " || line[pos] == "\\t")) pos++;
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
    
    load_cnf_file("{cnf_path}");
    
    @(posedge clk); start_solve = 1'b1; @(posedge clk); start_solve = 1'b0;
    
    while (!solve_done && cycle_count < {timeout_cycles}) @(posedge clk);
    
    $display("RESULT:%s", is_sat ? "SAT" : (is_unsat ? "UNSAT" : "TIMEOUT"));
    $display("CYCLES:%0d", cycle_count);
    $display("DECISIONS:%0d", decision_count);
    $display("CONFLICTS:%0d", conflict_count);
    $finish;
  end
endmodule
'''
    
    tb_path = os.path.join(SIM_DIR, 'tb_hw_bench.sv')
    with open(tb_path, 'w') as f:
        f.write(testbench)
    return tb_path

def build_and_run_hw(cnf_path, n_vars, n_clauses, timeout=120):
    """Build and run hardware simulation."""
    
    # Create testbench
    tb_path = create_hw_testbench(n_vars, n_clauses, cnf_path)
    
    # Create C++ driver
    cpp_driver = os.path.join(SIM_DIR, 'sim_hw_bench.cpp')
    with open(cpp_driver, 'w') as f:
        f.write('''#include "Vtb_hw_bench.h"
#include "verilated.h"
#include <memory>
int main(int argc, char** argv) {
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    contextp->commandArgs(argc, argv);
    const std::unique_ptr<Vtb_hw_bench> tb{new Vtb_hw_bench{contextp.get()}};
    while (!contextp->gotFinish()) {
        tb->eval_step(); tb->eval_end_step(); contextp->timeInc(1);
        if (contextp->time() > 100000000) break;
    }
    tb->final(); return 0;
}
''')
    
    # Build
    rtl_srcs = ' '.join([
        os.path.abspath(os.path.join(SIM_DIR, f'../src/Mega/{f}'))
        for f in ['verisat_pkg.sv', 'interface_unit.sv', 'mesh_interconnect.sv',
                  'global_mem_arbiter.sv', 'solver_core.sv', 'satswarm_top.sv',
                  'pse.sv', 'cae.sv', 'vde.sv', 'trail_manager.sv']
    ])
    
    build_cmd = f'''cd {SIM_DIR} && rm -rf obj_dir_bench && verilator -Wall --timing --sv --cc --exe \
        --Wno-fatal --Wno-UNUSED --Wno-PINCONNECTEMPTY --Wno-UNOPTFLAT \
        --Wno-INITIALDLY --Wno-WIDTHTRUNC --Wno-WIDTHEXPAND --Wno-MODDUP \
        --Wno-BLKANDNBLK --Wno-WIDTH \
        tb_hw_bench.sv sim_hw_bench.cpp {rtl_srcs} \
        --top-module tb_hw_bench -CFLAGS "-std=c++17" -I../src/Mega \
        --Mdir obj_dir_bench --build -j 8 2>&1'''
    
    build_result = subprocess.run(build_cmd, shell=True, capture_output=True, text=True)
    if build_result.returncode != 0:
        return 'BUILD_ERROR', 0, 0
    
    # Run
    start = time.time()
    try:
        run_result = subprocess.run(
            [os.path.join(SIM_DIR, 'obj_dir_bench/Vtb_hw_bench')],
            capture_output=True, text=True, timeout=timeout,
            cwd=SIM_DIR
        )
        elapsed = time.time() - start
        
        output = run_result.stdout
        import re
        
        result_match = re.search(r'RESULT:(\w+)', output)
        cycles_match = re.search(r'CYCLES:(\d+)', output)
        decisions_match = re.search(r'DECISIONS:(\d+)', output)
        
        result = result_match.group(1) if result_match else 'ERROR'
        cycles = int(cycles_match.group(1)) if cycles_match else 0
        decisions = int(decisions_match.group(1)) if decisions_match else 0
        
        return result, elapsed, cycles, decisions
        
    except subprocess.TimeoutExpired:
        return 'TIMEOUT', timeout, 0, 0

def benchmark_hw_size(n_vars, n_clauses, k=3, num_trials=2):
    """Benchmark hardware on a specific problem size."""
    print(f"\n{'='*60}")
    print(f"HW Benchmark: {n_vars} vars, {n_clauses} clauses (3-SAT)")
    print(f"{'='*60}")
    
    for trial in range(num_trials):
        seed = 12345 + trial * 1000 + n_vars * 100
        clauses = generate_cnf(k, n_vars, n_clauses, seed=seed)
        
        # Check with Glucose
        is_sat = check_sat_glucose(clauses)
        expected = 'SAT' if is_sat else 'UNSAT'
        print(f"  Trial {trial+1}: Expected={expected}")
        
        # Save CNF
        save_cnf(TEST_CNF, clauses, n_vars, n_clauses)
        
        # Run Python first as sanity check
        py_result, py_time, py_decisions = run_python_sim(TEST_CNF, timeout=60)
        if py_result == 'TIMEOUT':
            print(f"    Python: TIMEOUT (problem is hard, skipping hardware)")
            continue
        print(f"    Python: {py_result} in {py_time:.2f}s ({py_decisions} decisions)")
        
        # Run hardware
        hw_result = build_and_run_hw(TEST_CNF, n_vars, n_clauses, timeout=120)
        if len(hw_result) == 4:
            result, hw_time, cycles, decisions = hw_result
            print(f"    Hardware: {result} in {hw_time:.2f}s ({cycles} cycles, {decisions} decisions)")
            if cycles > 0:
                print(f"    Cycles/decision: {cycles/max(decisions,1):.1f}")
        else:
            print(f"    Hardware: {hw_result}")

def main():
    print("="*60)
    print("VeriSAT Hardware Scalability Benchmark")
    print("="*60)
    
    # Test increasing sizes
    test_configs = [
        (10, 43),   # 10 vars
        (15, 65),   # 15 vars
        (20, 86),   # 20 vars
        (25, 108),  # 25 vars
        (30, 129),  # 30 vars
    ]
    
    for n_vars, n_clauses in test_configs:
        benchmark_hw_size(n_vars, n_clauses, k=3, num_trials=2)
    
    print("\n" + "="*60)
    print("Benchmark Complete")
    print("="*60)

if __name__ == "__main__":
    main()
