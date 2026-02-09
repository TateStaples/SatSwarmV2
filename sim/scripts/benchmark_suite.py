#!/usr/bin/env python3
import os
import glob
import subprocess
import re
import math
import statistics

# Configuration
CONFIGS = {
    "1x1": "obj_dir_1x1/Vtb_satswarmv2",
    "2x2": "obj_dir_2x2/Vtb_satswarmv2",
    "3x3": "obj_dir_3x3/Vtb_satswarmv2",
}

TEST_DIR = "tests/sat_accel"


def run_test(exe, cnf_path):
    basename = os.path.basename(cnf_path).lower()
    expect = "UNSAT" if ("unsat" in basename or "hole" in basename) else "SAT"
    cmd = [exe, f"+CNF={cnf_path}", f"+EXPECT={expect}", "+DEBUG=0"]
    try:
        # TIMEOUT set to 30 seconds per test to keep total time reasonable
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)

        # Parse cycles
        match = re.search(r"Cycles: (\d+)", result.stdout)
        if match:
            return int(match.group(1))

        # Parse timeout or failure
        if "TIMEOUT" in result.stdout:
            return float("inf")

        return None
    except subprocess.TimeoutExpired:
        return float("inf")
    except Exception as e:
        return None


def main():
    # Find all CNF files
    files = glob.glob(os.path.join(TEST_DIR, "*.cnf"))
    files.sort()

    print(f"Found {len(files)} benchmark files.")
    print("-" * 80)
    print(
        f"{'Variables':<10} | {'Instance':<20} | {'1x1 Cycles':<12} | {'2x2 Speedup':<12} | {'3x3 Speedup':<12}"
    )
    print("-" * 80)

    # Group results by variable count
    stats_by_var = {}

    for cnf_file in files:
        basename = os.path.basename(cnf_file)

        # Extract Var Count from filename pattern (gen_sat_10v_1.cnf or sat_10v_40c_1.cnf)
        var_match = re.search(r"(\d+)v", basename)
        if not var_match:
            # Try patterns like uf100, uuf125, aim-200, hole7
            if "hole" in basename:
                n_vars = 56  # hole7 is 56 vars
            elif "uf" in basename or "uuf" in basename:
                match = re.search(r"(\d+)-", basename)
                n_vars = int(match.group(1)) if match else 20
            elif "aim-" in basename:
                match = re.search(r"-(\d+)-", basename)
                n_vars = int(match.group(1)) if match else 200
            else:
                n_vars = 0
        else:
            n_vars = int(var_match.group(1))

        print(f"Running {basename}...", end="", flush=True)

        if n_vars not in stats_by_var:
            stats_by_var[n_vars] = {"2x2": [], "3x3": []}

        # Run 1x1 Baseline
        cycles_1x1 = run_test(CONFIGS["1x1"], cnf_file)
        if cycles_1x1 is None or cycles_1x1 == float("inf"):
            # If 1x1 fails/timeouts, skip comparison
            continue

        # Run 2x2
        cycles_2x2 = run_test(CONFIGS["2x2"], cnf_file)
        speedup_2x2 = 0.0
        if cycles_2x2 and cycles_2x2 != float("inf"):
            speedup_2x2 = cycles_1x1 / cycles_2x2
            stats_by_var[n_vars]["2x2"].append(speedup_2x2)

        # Run 3x3
        cycles_3x3 = run_test(CONFIGS["3x3"], cnf_file)
        speedup_3x3 = 0.0
        if cycles_3x3 and cycles_3x3 != float("inf"):
            speedup_3x3 = cycles_1x1 / cycles_3x3
            stats_by_var[n_vars]["3x3"].append(speedup_3x3)

        # Print row (only for larger instances to avoid spam, e.g. >= 8 vars)
        if n_vars >= 8:
            s2 = f"{speedup_2x2:.2f}x" if speedup_2x2 > 0 else "-"
            s3 = f"{speedup_3x3:.2f}x" if speedup_3x3 > 0 else "-"
            print(
                f"{n_vars:<10} | {basename:<20} | {cycles_1x1:<12} | {s2:<12} | {s3:<12}"
            )

    print("-" * 80)
    print("\nSummary by Variable Count (Average Speedup):")
    print("-" * 60)
    print(f"{'Vars':<10} | {'Avg 2x2 Speedup':<20} | {'Avg 3x3 Speedup':<20}")
    print("-" * 60)

    sorted_vars = sorted(stats_by_var.keys())
    for v in sorted_vars:
        s2_list = stats_by_var[v]["2x2"]
        s3_list = stats_by_var[v]["3x3"]

        avg_2x2 = statistics.mean(s2_list) if s2_list else 0.0
        avg_3x3 = statistics.mean(s3_list) if s3_list else 0.0

        print(f"{v:<10} | {avg_2x2:.2f}x{' ':<16} | {avg_3x3:.2f}x")


if __name__ == "__main__":
    main()
