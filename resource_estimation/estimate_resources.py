#!/usr/bin/env python3
import os
import subprocess
import re
import math
import csv
import sys
import argparse
import time

# Configuration
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SRC_DIR = os.path.join(PROJECT_ROOT, "src", "Mega")
EST_DIR = os.path.dirname(os.path.abspath(__file__))
PKG_FILE = os.path.join(SRC_DIR, "satswarmv2_pkg.sv")
RESULTS_FILE = os.path.join(EST_DIR, "resource_estimation.csv")

# Parameter sweep - Reduced for reasonable runtime/estimation
VAR_STEPS = [4, 8, 16] 
CLAUSE_FACTOR = 10 

def create_temp_pkg(run_id, var_max):
    clause_max = var_max * CLAUSE_FACTOR
    lit_max = clause_max * 4
    # Ensure reasonable bounds for synthesis
    declevel_w = int(math.ceil(math.log2(var_max + 1))) + 1
    
    # Read original package
    with open(PKG_FILE, 'r') as f:
        content = f.read()
    
    # Replace parameters
    # Note: Regex allows for comments or spacing variations
    content = re.sub(r'parameter int VAR_MAX\s*=\s*\d+;', f'parameter int VAR_MAX = {var_max};', content)
    content = re.sub(r'parameter int LIT_MAX\s*=\s*\d+;', f'parameter int LIT_MAX = {lit_max};', content)
    content = re.sub(r'parameter int CLAUSE_MAX\s*=\s*\d+;', f'parameter int CLAUSE_MAX = {clause_max};', content)
    content = re.sub(r'parameter int DECLEVEL_W\s*=\s*\d+;', f'parameter int DECLEVEL_W = {declevel_w};', content)
    
    temp_pkg_path = os.path.join(EST_DIR, f"temp_pkg_{run_id}.sv")
    with open(temp_pkg_path, 'w') as f:
        f.write(content)
    return temp_pkg_path

def run_synthesis(run_id, var_max, temp_pkg_path):
    clause_max = var_max * CLAUSE_FACTOR
    lit_max = clause_max * 4
    
    ys_filename = os.path.join(EST_DIR, f"synth_{run_id}.ys")
    log_filename = os.path.join(EST_DIR, f"yosys_{run_id}.log")
    
    # Yosys script content
    # Note: Using -flatten and -abc9 to speed up logic synthesis
    ys_content = f"""
    # Read modified package FIRST
    read_verilog -sv {temp_pkg_path}
    
    # Read other source files
    read_verilog -sv {os.path.join(SRC_DIR, "interface_unit.sv")}
    read_verilog -sv {os.path.join(SRC_DIR, "trail_manager.sv")}
    read_verilog -sv {os.path.join(SRC_DIR, "vde.sv")}
    read_verilog -sv {os.path.join(SRC_DIR, "pse.sv")}
    read_verilog -sv {os.path.join(SRC_DIR, "cae.sv")}
    read_verilog -sv {os.path.join(SRC_DIR, "solver_core.sv")}
    
    # Override top module parameters
    chparam -set MAX_VARS {var_max} solver_core
    chparam -set MAX_CLAUSES {clause_max} solver_core
    chparam -set MAX_LITS {lit_max} solver_core
    
    # Synthesis
    hierarchy -check -top solver_core
    proc
    opt -fast
    memory -nomap
    opt -fast
    
    # Flatten helps with estimation accuracy for generic cell counts
    synth_xilinx -family xc7 -top solver_core -flatten -abc9
    
    # Report
    stat
    """
    
    with open(ys_filename, 'w') as f:
        f.write(ys_content)
        
    print(f"Running synthesis for VAR_MAX={var_max}...")
    start_time = time.time()
    try:
        with open(log_filename, 'w') as logfile:
            # 5 minute timeout per run
            subprocess.run(["yosys", ys_filename], stdout=logfile, stderr=subprocess.STDOUT, check=True, timeout=300)
    except subprocess.TimeoutExpired:
        print(f"Error: Synthesis timed out for {var_max} after 300s.")
        return None
    except subprocess.CalledProcessError as e:
        print(f"Error running synthesis for {var_max}. Check {log_filename}")
        return None
        
    duration = time.time() - start_time
    print(f"  Finished in {duration:.1f}s")
    return log_filename

def parse_results(run_id, log_path, var_max):
    # Parse the log file for area statistics
    stats = {
        'VAR_MAX': var_max,
        'LUT': 0,
        'FD': 0, # Flip-flops
        'BRAM': 0,
        'DSP': 0
    }
    
    if not log_path or not os.path.exists(log_path):
        return stats

    with open(log_path, 'r') as f:
        content = f.read()
        
    # Look for the final stat output
    # Printing statistics.
    # ...
    #   Number of LUT4 ...
    
    # Simple regex for summation
    # Xilinx synthesis usually outputs LUT1, LUT2, LUT3, LUT4, LUT5, LUT6
    luts = re.findall(r'Number of LUT\d+\s+(\d+)', content)
    stats['LUT'] = sum(int(x) for x in luts)
    
    # Flip-Flops: FDRE, FDSE, FDCE, FDPE
    fds = re.findall(r'Number of FD\w+\s+(\d+)', content)
    stats['FD'] = sum(int(x) for x in fds)
    
    # BRAM: RAMB18, RAMB36
    brams = re.findall(r'Number of RAMB\w+\s+(\d+)', content)
    stats['BRAM'] = sum(int(x) for x in brams)
    
    # DSP: DSP48
    dsps = re.findall(r'Number of DSP\w+\s+(\d+)', content)
    stats['DSP'] = sum(int(x) for x in dsps)
    
    return stats

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--quick', action='store_true', help='Run only one small point for testing')
    args = parser.parse_args()
    
    steps = [4] if args.quick else VAR_STEPS
    
    results = []
    
    for i, var_max in enumerate(steps):
        run_id = f"run_{i}"
        pkg_path = create_temp_pkg(run_id, var_max)
        log_path = run_synthesis(run_id, var_max, pkg_path)
        if log_path:
            data = parse_results(run_id, log_path, var_max)
            results.append(data)
        
        # Cleanup temp files
        try:
            if os.path.exists(pkg_path): os.remove(pkg_path)
        except: pass
        
    # Write to CSV
    keys = ['VAR_MAX', 'LUT', 'FD', 'BRAM', 'DSP']
    with open(RESULTS_FILE, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=keys, extrasaction='ignore')
        writer.writeheader()
        writer.writerows(results)
        
    print(f"Done. Results written to {RESULTS_FILE}")
    
    # Print simple table
    print(f"{'VAR_MAX':<10} | {'LUT':<10} | {'FD':<10} | {'BRAM':<10}")
    print("-" * 46)
    for r in results:
        print(f"{r['VAR_MAX']:<10} | {r['LUT']:<10} | {r['FD']:<10} | {r['BRAM']:<10}")

if __name__ == "__main__":
    main()
