#!/usr/bin/env python3
import csv
import sys
import glob
import os
import statistics

# VeriSAT Reference Data (Table II from VeriSAT.pdf)
VERISAT_UF50_CYCLES = 39240.15
VERISAT_UF50_TIME = 0.26

VERISAT_UUF50_CYCLES = 91667.29
VERISAT_UUF50_TIME = 0.61

# SatSwarm Clock Speed
CLOCK_FREQ_HZ = 50_000_000  # 50 MHz

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

print(f"Analyzing: {csvfile}")

data = {}
with open(csvfile, "r") as f:
    reader = csv.DictReader(f)
    for row in reader:
        fname = row["filename"]
        config = row["config"]
        cycles = int(row["cycles"]) if row["cycles"] and row["cycles"] != "0" else 0
        time_sec = float(row["time_sec"])
        result = row["result"]
        problem_type = row["type"]  # SAT or UNSAT

        if fname not in data:
            data[fname] = {"type": problem_type, "results": {}}

        data[fname]["results"][config] = {"cycles": cycles, "result": result}

sat_data = []
unsat_data = []

for fname, info in data.items():
    res = info["results"]
    if "1x1" not in res:
        continue
    base_val = res["1x1"]["cycles"]
    if base_val == 0:
        continue

    entry = {
        "name": fname,
        "1x1": base_val,
        "2x2": res.get("2x2", {}).get("cycles", None),
        "3x3": res.get("3x3", {}).get("cycles", None),
    }

    # Calculate speedups
    if entry["2x2"]:
        entry["spd_2x2"] = base_val / entry["2x2"]
    else:
        entry["spd_2x2"] = None

    if entry["3x3"]:
        entry["spd_3x3"] = base_val / entry["3x3"]
    else:
        entry["spd_3x3"] = None

    if info["type"] == "SAT":
        sat_data.append(entry)
    else:
        unsat_data.append(entry)


def cycles_to_ms(cycles):
    if cycles is None:
        return 0.0
    return (cycles / CLOCK_FREQ_HZ) * 1000


def analyze_group(group_name, group_data):
    lines = []
    lines.append(f"## {group_name} Results")

    # Filter for valid runs
    valid_2x2 = [e for e in group_data if e["spd_2x2"] is not None]
    valid_3x3 = [e for e in group_data if e["spd_3x3"] is not None]

    # Calculate Totals
    total_1x1 = sum(e["1x1"] for e in group_data)
    total_2x2 = sum(e["2x2"] for e in valid_2x2) if valid_2x2 else 0
    total_3x3 = sum(e["3x3"] for e in valid_3x3) if valid_3x3 else 0

    count = len(group_data)
    avg_1x1 = total_1x1 / count if count > 0 else 0
    avg_2x2 = total_2x2 / len(valid_2x2) if valid_2x2 else 0
    avg_3x3 = total_3x3 / len(valid_3x3) if valid_3x3 else 0

    # VeriSAT Comparison
    if "SAT" in group_name and "UNSAT" not in group_name:
        ref_cycles = VERISAT_UF50_CYCLES
        ref_time = VERISAT_UF50_TIME
        label = "UF50"
    else:
        ref_cycles = VERISAT_UUF50_CYCLES
        ref_time = VERISAT_UUF50_TIME
        label = "UUF50"

    # Calculate SatSwarm Times at 50MHz
    time_1x1 = cycles_to_ms(avg_1x1)
    time_2x2 = cycles_to_ms(avg_2x2)
    time_3x3 = cycles_to_ms(avg_3x3)

    lines.append(f"### Performance Comparison ({label})")
    lines.append(f"| Design | Raw Cycles | Time (ms) |")
    lines.append(f"|:-------|-----------:|----------:|")
    lines.append(f"| **VeriSAT** | {ref_cycles:,.2f} | {ref_time:.2f} |")
    lines.append(f"| **1x1** | {avg_1x1:,.2f} | {time_1x1:.3f} |")
    lines.append(f"| **2x2** | {avg_2x2:,.2f} | {time_2x2:.3f} |")
    lines.append(f"| **3x3** | {avg_3x3:,.2f} | {time_3x3:.3f} |")
    lines.append("")

    return "\n".join(lines)


report = []
report.append("# Benchmark Report")
report.append(f"**Assumption**: SatSwarm Clock = 50 MHz")
report.append("")

report.append(analyze_group("SAT (UF50)", sat_data))
report.append(analyze_group("UNSAT (UUF50)", unsat_data))

print("\n".join(report))
