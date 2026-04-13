#!/usr/bin/env python3
"""
plot_scaling_sat_unsat.py — Scaling line charts for SAT vs UNSAT separately.

Creates two subplots:
1. SAT instances: 3x3 vs VeriSAT scaling curve
2. UNSAT instances: 3x3 vs VeriSAT scaling curve

Uses blue, purple, magenta, red color scheme.

Usage:
    python3 benchmarks/plot_scaling_sat_unsat.py
"""

import argparse
import csv
import sys
from pathlib import Path
from collections import defaultdict
import numpy as np

try:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
except ImportError:
    print("ERROR: matplotlib is required. Run: pip install matplotlib")
    sys.exit(1)

# Benchmark directories
BENCHMARKS_DIR = Path("benchmarks/results")
CONFIGS = {
    "1x1": "20260412_183019_1x1",
    "2x2": "20260412_183903_2x2-3clz",
    "3x3": "20260412_184806_3x3-2clz",
}

# Viridis palette - Perceptually uniform, colorblind-friendly, sophisticated
# Darker Yellow highlights our proposed system (3x3) for publication impact
COLORS = {
    "1x1": "#440154",      # Deep Purple (Baseline)
    "2x2": "#31688E",      # Steel Blue
    "3x3": "#35B779",      # Seafoam Green
    "VeriSAT": "#E6D200",  # Darker Yellow (Proposed/Our Work)
}

SATSWARM_CLOCK_MHZ = 15.625

# VeriSAT data from paper (Time in ms @ 150MHz)
VERISAT_DATA_SAT = {
    20: 0.02,      # UF20 (SAT)
    50: 0.26,      # UF50 (SAT)
    75: 1.99,      # UF75 (SAT)
    100: 11.41,    # UF100 (SAT)
    125: 110.62,   # UF125 (SAT)
    150: 713.62,   # UF150 (SAT)
}

VERISAT_DATA_UNSAT = {
    50: 0.61,      # UUF50 (UNSAT)
    75: 4.23,      # UUF75 (UNSAT)
    100: 34.07,    # UUF100 (UNSAT)
    125: 260.35,   # UUF125 (UNSAT)
    150: 956.93,   # UUF150 (UNSAT)
}


def load_csv(config_name):
    """Load results.csv for a given config."""
    config_dir = BENCHMARKS_DIR / CONFIGS[config_name]
    csv_path = config_dir / "results.csv"

    if not csv_path.exists():
        print(f"ERROR: {csv_path} not found")
        return None

    rows = []
    with open(csv_path) as f:
        for row in csv.DictReader(f):
            row["cycles"] = int(row["cycles"])
            row["vars"] = int(row["vars"])
            row["correct"] = int(row["correct"])
            rows.append(row)
    return rows


def correct_only(rows):
    """Filter to correct results only, excluding 175-variable instances."""
    return [r for r in rows if r["correct"] == 1 and r["vars"] != 175]


def cycles_to_ms(cycles, freq_mhz=SATSWARM_CLOCK_MHZ):
    """Convert cycles to milliseconds."""
    return cycles / freq_mhz / 1000.0


def main():
    parser = argparse.ArgumentParser(description="SAT vs UNSAT scaling comparison.")
    parser.add_argument("--out", default="benchmarks/results/comparison",
                        help="Output directory (default: benchmarks/results/comparison)")
    args = parser.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    # Load all SatSwarm configs
    data = {}
    for config_name in ["1x1", "2x2", "3x3"]:
        rows = load_csv(config_name)
        if rows is None:
            sys.exit(1)
        data[config_name] = correct_only(rows)

    # Separate SAT and UNSAT
    data_sat = {}
    data_unsat = {}
    for config_name in data:
        data_sat[config_name] = [r for r in data[config_name] if r["expected"] == "SAT"]
        data_unsat[config_name] = [r for r in data[config_name] if r["expected"] == "UNSAT"]

    # Group by problem size for SAT instances
    size_groups_sat = defaultdict(lambda: {"3x3": []})
    for row in data_sat["3x3"]:
        var_count = row["vars"]
        size_groups_sat[var_count]["3x3"].append(row["cycles"])

    # Group by problem size for UNSAT instances
    size_groups_unsat = defaultdict(lambda: {"3x3": []})
    for row in data_unsat["3x3"]:
        var_count = row["vars"]
        size_groups_unsat[var_count]["3x3"].append(row["cycles"])

    # Get all problem sizes
    all_sizes_sat = sorted(size_groups_sat.keys())
    all_sizes_unsat = sorted(size_groups_unsat.keys())

    # Prepare data for SAT
    means_ms_sat = []
    for size in all_sizes_sat:
        cycles_list = size_groups_sat[size]["3x3"]
        if cycles_list:
            cycles_mean = np.mean(cycles_list)
            means_ms_sat.append(cycles_to_ms(cycles_mean))
        else:
            means_ms_sat.append(0)

    verisat_times_sat = [VERISAT_DATA_SAT.get(size, None) for size in all_sizes_sat]
    verisat_times_sat_clean = [t if t is not None else 0 for t in verisat_times_sat]

    # Prepare data for UNSAT
    means_ms_unsat = []
    for size in all_sizes_unsat:
        cycles_list = size_groups_unsat[size]["3x3"]
        if cycles_list:
            cycles_mean = np.mean(cycles_list)
            means_ms_unsat.append(cycles_to_ms(cycles_mean))
        else:
            means_ms_unsat.append(0)

    verisat_times_unsat = [VERISAT_DATA_UNSAT.get(size, None) for size in all_sizes_unsat]
    verisat_times_unsat_clean = [t if t is not None else 0 for t in verisat_times_unsat]

    # Create figure with 2 subplots (SAT and UNSAT)
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 12))

    # ===== SAT PLOT =====
    ax1.plot(all_sizes_sat, means_ms_sat,
            marker='o', markersize=12, linewidth=3,
            color=COLORS["3x3"], label="SatSwarm 3×3 (9 cores)",
            zorder=4)

    ax1.plot(all_sizes_sat, verisat_times_sat_clean,
            marker='s', markersize=12, linewidth=3,
            color=COLORS["VeriSAT"], label="VeriSAT@150MHz",
            zorder=4)

    ax1.set_xlabel("Problem Size (variables)", fontsize=12, fontweight="bold")
    ax1.set_ylabel("Time to Solve (milliseconds)", fontsize=12, fontweight="bold")
    ax1.set_title("SAT Instances: Scaling Comparison",
                 fontsize=13, fontweight="bold")
    ax1.legend(fontsize=11, loc="upper left", framealpha=0.95)
    ax1.grid(True, alpha=0.3, linestyle='--', which='both')
    ax1.set_yscale("log")
    ax1.set_xscale("linear")
    ax1.yaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f"{v:.1f}"))


    # ===== UNSAT PLOT =====
    ax2.plot(all_sizes_unsat, means_ms_unsat,
            marker='o', markersize=12, linewidth=3,
            color=COLORS["3x3"], label="SatSwarm 3×3 (9 cores)",
            zorder=4)

    ax2.plot(all_sizes_unsat, verisat_times_unsat_clean,
            marker='s', markersize=12, linewidth=3,
            color=COLORS["VeriSAT"], label="VeriSAT@150MHz",
            zorder=4)

    ax2.set_xlabel("Problem Size (variables)", fontsize=12, fontweight="bold")
    ax2.set_ylabel("Time to Solve (milliseconds)", fontsize=12, fontweight="bold")
    ax2.set_title("UNSAT Instances: Scaling Comparison",
                 fontsize=13, fontweight="bold")
    ax2.legend(fontsize=11, loc="upper left", framealpha=0.95)
    ax2.grid(True, alpha=0.3, linestyle='--', which='both')
    ax2.set_yscale("log")
    ax2.set_xscale("linear")
    ax2.yaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f"{v:.1f}"))


    fig.suptitle("SatSwarmV2 3×3 vs VeriSAT: SAT vs UNSAT Scaling",
                 fontsize=14, fontweight="bold")

    fig.tight_layout()
    out_path = out_dir / "scaling_sat_unsat.png"
    fig.savefig(out_path, dpi=150, bbox_inches='tight')
    print(f"Saved: {out_path}")
    plt.close(fig)

    print("\n✓ SAT vs UNSAT scaling comparison generated")


if __name__ == "__main__":
    main()
