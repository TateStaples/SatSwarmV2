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
SRC_DIR = os.path.join(PROJECT_ROOT, "src", "Mini")
EST_DIR = os.path.dirname(os.path.abspath(__file__))
PKG_FILE = os.path.join(SRC_DIR, "mini_pkg.sv")
RESULTS_FILE = os.path.join(EST_DIR, "resource_estimation_mini.csv")

# Parameter sweep
# Mini is simpler, so we can try slightly larger sizes to see BRAM usage
VAR_STEPS = [256, 512, 1024]
CLAUSE_FACTOR = 10


def create_temp_pkg(run_id, var_max):
    clause_max = var_max * CLAUSE_FACTOR
    lit_max = clause_max * 4

    # Read original package
    with open(PKG_FILE, "r") as f:
        content = f.read()

    # Replace parameters
    content = re.sub(
        r"parameter int MAX_VARS\s*=\s*\d+;",
        f"parameter int MAX_VARS = {var_max};",
        content,
    )
    content = re.sub(
        r"parameter int MAX_CLAUSES\s*=\s*\d+;",
        f"parameter int MAX_CLAUSES = {clause_max};",
        content,
    )
    content = re.sub(
        r"parameter int MAX_LITS\s*=\s*\d+;",
        f"parameter int MAX_LITS = {lit_max};",
        content,
    )

    temp_pkg_path = os.path.join(EST_DIR, f"temp_pkg_mini_{run_id}.sv")
    with open(temp_pkg_path, "w") as f:
        f.write(content)
    return temp_pkg_path


def run_synthesis(run_id, var_max, temp_pkg_path):
    clause_max = var_max * CLAUSE_FACTOR
    lit_max = clause_max * 4

    ys_filename = os.path.join(EST_DIR, f"synth_mini_{run_id}.ys")
    log_filename = os.path.join(EST_DIR, f"yosys_mini_{run_id}.log")

    # Yosys script content
    ys_content = f"""
    # Read modified package and memory estimation file
    read_verilog -sv {temp_pkg_path} {os.path.join(EST_DIR, "mini_memory_estimation.sv")}
    
    # Override top module parameters
    chparam -set MAX_VARS {var_max} mini_memory_estimation
    chparam -set MAX_CLAUSES {clause_max} mini_memory_estimation
    chparam -set MAX_LITS {lit_max} mini_memory_estimation
    
    # Synthesis
    hierarchy -check -top mini_memory_estimation
    proc
    opt -fast
    # memory -nomap
    opt -fast
    
    # Flatten helps with estimation accuracy for generic cell counts
    synth_xilinx -family xcu -top mini_memory_estimation
    
    # Report
    stat
    """

    with open(ys_filename, "w") as f:
        f.write(ys_content)

    print(f"Running synthesis for MAX_VARS={var_max}...")
    start_time = time.time()
    try:
        with open(log_filename, "w") as logfile:
            # 10 minute timeout per run
            subprocess.run(
                ["yosys", ys_filename],
                stdout=logfile,
                stderr=subprocess.STDOUT,
                check=True,
                timeout=600,
            )
    except subprocess.TimeoutExpired:
        print(f"Error: Synthesis timed out for {var_max} after 600s.")
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
        "MAX_VARS": var_max,
        "LUT": 0,
        "FD": 0,  # Flip-flops
        "BRAM": 0,
        "URAM": 0,
        "DSP": 0,
    }

    if not log_path or not os.path.exists(log_path):
        return stats

    with open(log_path, "r") as f:
        content = f.read()

    luts = re.findall(r"\s+(\d+)\s+LUT\d+", content)
    stats["LUT"] = sum(int(x) for x in luts)

    fds = re.findall(r"\s+(\d+)\s+FD\w+", content)
    stats["FD"] = sum(int(x) for x in fds)

    brams = re.findall(r"\s+(\d+)\s+RAMB\w+", content)
    stats["BRAM"] = sum(int(x) for x in brams)

    urams = re.findall(r"\s+(\d+)\s+URAM\w+", content)
    stats["URAM"] = sum(int(x) for x in urams)

    dsps = re.findall(r"\s+(\d+)\s+DSP\w+", content)
    stats["DSP"] = sum(int(x) for x in dsps)

    return stats


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--quick", action="store_true", help="Run only one small point for testing"
    )
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
            if os.path.exists(pkg_path):
                os.remove(pkg_path)
        except:
            pass

    # Write to CSV
    keys = ["MAX_VARS", "LUT", "FD", "DSP", "BRAM", "URAM"]
    with open(RESULTS_FILE, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=keys, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(results)

    print(f"Done. Results written to {RESULTS_FILE}")

    # Define Available Resources for XC7VX690T (Representative Large FPGA)
    # Using Virtex-7 690T since it is common in SAT literature, or XCVU9P if URAM is desired.
    # User requested URAM, so we will use XCVU9P (UltraScale+) as reference.
    # Device: XCVU9P-L2-FLGA2104E
    AVAILABLE = {
        "LUT": 1182240,
        "FD": 2364480,
        "DSP": 6840,
        "BRAM": 2160,  # 36Kb blocks
        "URAM": 960,  # 288Kb blocks
    }

    # Print formatted table matching VeriSAT style
    print("\n" + "=" * 85)
    print(f" Resource Utilization Report (Target Reference: XCVU9P)")
    print("=" * 85)
    header = (
        f"{'Resource':<10} | {'Used':<10} | {'Available':<15} | {'Utilization %':<15}"
    )
    print(header)
    print("-" * 85)

    # Only print the last result (largest variable count) or all?
    # Users typically want the summary for the largest case verified.
    if results:
        r = results[-1]
        print(f" MAX_VARS: {r['MAX_VARS']}")
        print("-" * 85)
        for res in ["LUT", "FD", "DSP", "BRAM", "URAM"]:
            used = r.get(res, 0)
            avail = AVAILABLE.get(res, 1)
            pct = (used / avail) * 100.0
            print(f" {res:<10} | {used:<10} | {avail:<15} | {pct:<15.4f}")
    print("=" * 85 + "\n")


if __name__ == "__main__":
    main()
