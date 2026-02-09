#!/usr/bin/env python3
import csv
import sys
import glob
import os

# Find latest CSV if not specified
if len(sys.argv) > 1:
    csvfile = sys.argv[1]
else:
    csvfiles = glob.glob("logs/benchmark_results/stability_50v_*.csv")
    if csvfiles:
        csvfile = max(csvfiles, key=os.path.getmtime)
    else:
        print("No CSV files found!")
        sys.exit(1)

print(f"Using: {csvfile}\n")

# Parse the data
data = {}
with open(csvfile, "r") as f:
    reader = csv.DictReader(f)
    for row in reader:
        fname = row["filename"]
        config = row["config"]
        cycles = int(row["cycles"]) if row["cycles"] and row["cycles"] != "0" else 0
        time_sec = float(row["time_sec"])
        result = row["result"]
        if fname not in data:
            data[fname] = {}
        data[fname][config] = {"cycles": cycles, "time": time_sec, "result": result}

# Check if we have valid cycle data
has_cycles = any(d.get("1x1", {}).get("cycles", 0) > 0 for d in data.values())
metric = "cycles" if has_cycles else "time"
unit = "" if has_cycles else "s"
print(
    f"Metric: {'CYCLES (accurate)' if has_cycles else 'WALL-CLOCK TIME (skewed by simulation overhead)'}\n"
)

# Calculate speedups
print("=" * 70)
print(f"SPEEDUP ANALYSIS (1x1 baseline) - Using {metric.upper()}")
print("=" * 70)
print(
    f"{'Test':<20} {'1x1':>10} {'2x2':>10} {'3x3':>10} {'2x2 spd':>10} {'3x3 spd':>10}"
)
print("-" * 70)

sat_1x1_total, sat_2x2_total, sat_3x3_total = 0, 0, 0
unsat_1x1_total, unsat_2x2_total, unsat_3x3_total = 0, 0, 0

for fname in sorted(data.keys()):
    d = data[fname]
    if "1x1" in d and "2x2" in d and "3x3" in d:
        t1 = d["1x1"][metric]
        t2 = d["2x2"][metric]
        t3 = d["3x3"][metric]
        r3 = d["3x3"]["result"]

        spd2 = t1 / t2 if t2 > 0 else 0
        spd3 = t1 / t3 if t3 > 0 and r3 != "TIMEOUT" else "T/O"

        if "uuf" in fname:
            unsat_1x1_total += t1
            unsat_2x2_total += t2
            if r3 != "TIMEOUT":
                unsat_3x3_total += t3
        else:
            sat_1x1_total += t1
            sat_2x2_total += t2
            sat_3x3_total += t3

        spd3_str = f"{spd3:.2f}x" if isinstance(spd3, float) else spd3
        t1_str = f"{int(t1):>10}" if has_cycles else f"{t1:>9.1f}s"
        t2_str = f"{int(t2):>10}" if has_cycles else f"{t2:>9.1f}s"
        t3_str = f"{int(t3):>10}" if has_cycles else f"{t3:>9.1f}s"
        print(f"{fname:<20} {t1_str} {t2_str} {t3_str} {spd2:>9.2f}x {spd3_str:>10}")

print("=" * 70)
print("SUMMARY")
print("-" * 70)
print(f"SAT Tests (10):")
print(
    f"  1x1 total: {sat_1x1_total:.1f}s, 2x2 total: {sat_2x2_total:.1f}s, 3x3 total: {sat_3x3_total:.1f}s"
)
print(f"  2x2 avg speedup: {sat_1x1_total / sat_2x2_total:.2f}x")
print(f"  3x3 avg speedup: {sat_1x1_total / sat_3x3_total:.2f}x")
print(f"UNSAT Tests (10):")
print(f"  1x1 total: {unsat_1x1_total:.1f}s, 2x2 total: {unsat_2x2_total:.1f}s")
print(f"  2x2 avg speedup: {unsat_1x1_total / unsat_2x2_total:.2f}x")
print("=" * 70)
print("NOTE: Speedup < 1.0 means SLOWER (negative scaling)")
