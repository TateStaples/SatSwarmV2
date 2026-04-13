#!/usr/bin/env python3
"""
plot_comparison_sat_unsat.py — Comparison bars for SAT vs UNSAT instances separately.

Creates two subplots:
1. SAT instances: 4 bars per problem size (1x1, 2x2, 3x3, VeriSAT)
2. UNSAT instances: 4 bars per problem size (1x1, 2x2, 3x3, VeriSAT)

Uses professional publication colors.

Usage:
    python3 benchmarks/plot_comparison_sat_unsat.py
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


def plot_bars(ax, problem_sizes, means_ms, stds_ms, verisat_times, title):
    """Helper function to plot bar chart."""
    configs_list = ["1x1", "2x2", "3x3"]
    x = np.arange(len(problem_sizes))
    width = 0.2

    # Plot 4 bars per problem size
    offset_map = {
        "1x1": -1.5 * width,
        "2x2": -0.5 * width,
        "3x3": 0.5 * width,
        "VeriSAT": 1.5 * width,
    }

    # SatSwarm bars
    for config in configs_list:
        offset = offset_map[config]
        ax.bar(
            x + offset,
            means_ms[config],
            width,
            yerr=stds_ms[config],
            label=config,
            color=COLORS[config],
            alpha=0.85,
            capsize=3,
            error_kw={"linewidth": 1.2},
            edgecolor="black",
            linewidth=0.7
        )

    # VeriSAT bars
    verisat_times_clean = [t if t is not None else 0 for t in verisat_times]
    ax.bar(
        x + offset_map["VeriSAT"],
        verisat_times_clean,
        width,
        label="VeriSAT@150MHz",
        color=COLORS["VeriSAT"],
        alpha=0.85,
        edgecolor="black",
        linewidth=0.7
    )

    # Formatting
    ax.set_xlabel("Problem Size (variables)", fontsize=12, fontweight="bold")
    ax.set_ylabel("Time to Solve (milliseconds)", fontsize=12, fontweight="bold")
    ax.set_title(title, fontsize=13, fontweight="bold")
    ax.set_xticks(x)
    ax.set_xticklabels([str(size) for size in problem_sizes], fontsize=11)
    ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f"{v:.1f}"))
    ax.grid(axis="y", alpha=0.3, linestyle='--')
    ax.set_yscale("log")


def main():
    parser = argparse.ArgumentParser(description="SAT vs UNSAT comparison bars.")
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
    size_groups_sat = defaultdict(lambda: {"1x1": [], "2x2": [], "3x3": []})
    for config_name in data_sat:
        for row in data_sat[config_name]:
            var_count = row["vars"]
            size_groups_sat[var_count][config_name].append(row["cycles"])

    # Group by problem size for UNSAT instances
    size_groups_unsat = defaultdict(lambda: {"1x1": [], "2x2": [], "3x3": []})
    for config_name in data_unsat:
        for row in data_unsat[config_name]:
            var_count = row["vars"]
            size_groups_unsat[var_count][config_name].append(row["cycles"])

    # Get all problem sizes
    all_sizes = sorted(set(list(size_groups_sat.keys()) + list(size_groups_unsat.keys())))

    # Prepare data for SAT
    configs_list = ["1x1", "2x2", "3x3"]
    means_ms_sat = {config: [] for config in configs_list}
    stds_ms_sat = {config: [] for config in configs_list}
    verisat_times_sat = []

    for size in all_sizes:
        for config in configs_list:
            cycles_list = size_groups_sat[size][config]
            if cycles_list:
                cycles_mean = np.mean(cycles_list)
                cycles_std = np.std(cycles_list)
                means_ms_sat[config].append(cycles_to_ms(cycles_mean))
                stds_ms_sat[config].append(cycles_to_ms(cycles_std))
            else:
                means_ms_sat[config].append(0)
                stds_ms_sat[config].append(0)

        # Get VeriSAT time for SAT
        if size in VERISAT_DATA_SAT:
            verisat_times_sat.append(VERISAT_DATA_SAT[size])
        else:
            verisat_times_sat.append(None)

    # Prepare data for UNSAT (VeriSAT data would be different, but we don't have it)
    # For now, we'll still use the UF data as approximate for UNSAT
    means_ms_unsat = {config: [] for config in configs_list}
    stds_ms_unsat = {config: [] for config in configs_list}

    for size in all_sizes:
        for config in configs_list:
            cycles_list = size_groups_unsat[size][config]
            if cycles_list:
                cycles_mean = np.mean(cycles_list)
                cycles_std = np.std(cycles_list)
                means_ms_unsat[config].append(cycles_to_ms(cycles_mean))
                stds_ms_unsat[config].append(cycles_to_ms(cycles_std))
            else:
                means_ms_unsat[config].append(0)
                stds_ms_unsat[config].append(0)

    # Create figure with 2 subplots (SAT and UNSAT)
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 12))

    # Plot SAT
    plot_bars(ax1, all_sizes, means_ms_sat, stds_ms_sat, verisat_times_sat,
              "SAT Instances: Solution Time Comparison")
    ax1.legend(fontsize=11, loc="upper left", framealpha=0.95, ncol=2)

    # Plot UNSAT with VeriSAT data
    configs_list_unsat = ["1x1", "2x2", "3x3"]
    x_unsat = np.arange(len(all_sizes))
    width = 0.2

    offset_map_unsat = {
        "1x1": -1.5 * width,
        "2x2": -0.5 * width,
        "3x3": 0.5 * width,
        "VeriSAT": 1.5 * width,
    }

    for config in configs_list_unsat:
        offset = offset_map_unsat[config]
        ax2.bar(
            x_unsat + offset,
            means_ms_unsat[config],
            width,
            yerr=stds_ms_unsat[config],
            label=config,
            color=COLORS[config],
            alpha=0.85,
            capsize=3,
            error_kw={"linewidth": 1.2},
            edgecolor="black",
            linewidth=0.7
        )

    # VeriSAT bars for UNSAT
    verisat_times_unsat = []
    for size in all_sizes:
        if size in VERISAT_DATA_UNSAT:
            verisat_times_unsat.append(VERISAT_DATA_UNSAT[size])
        else:
            verisat_times_unsat.append(None)

    verisat_times_unsat_clean = [t if t is not None else 0 for t in verisat_times_unsat]
    ax2.bar(
        x_unsat + offset_map_unsat["VeriSAT"],
        verisat_times_unsat_clean,
        width,
        label="VeriSAT@150MHz",
        color=COLORS["VeriSAT"],
        alpha=0.85,
        edgecolor="black",
        linewidth=0.7
    )

    ax2.set_xlabel("Problem Size (variables)", fontsize=12, fontweight="bold")
    ax2.set_ylabel("Time to Solve (milliseconds)", fontsize=12, fontweight="bold")
    ax2.set_title("UNSAT Instances: Solution Time Comparison",
                  fontsize=13, fontweight="bold")
    ax2.set_xticks(x_unsat)
    ax2.set_xticklabels([str(size) for size in all_sizes], fontsize=11)
    ax2.yaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f"{v:.1f}"))
    ax2.grid(axis="y", alpha=0.3, linestyle='--')
    ax2.set_yscale("log")
    ax2.legend(fontsize=11, loc="upper left", framealpha=0.95, ncol=2)

    fig.suptitle("SatSwarmV2 vs VeriSAT: SAT vs UNSAT Comparison",
                 fontsize=15, fontweight="bold", y=0.995)

    fig.tight_layout()
    out_path = out_dir / "comparison_bars_sat_unsat.png"
    fig.savefig(out_path, dpi=150, bbox_inches='tight')
    print(f"Saved: {out_path}")
    plt.close(fig)

    # Print summary stats
    print("\nSAT Instances Summary:")
    print("-" * 100)
    for size in all_sizes:
        if size_groups_sat[size]["1x1"]:
            m1x1 = np.mean(size_groups_sat[size]["1x1"])
            m2x2 = np.mean(size_groups_sat[size]["2x2"]) if size_groups_sat[size]["2x2"] else 0
            m3x3 = np.mean(size_groups_sat[size]["3x3"]) if size_groups_sat[size]["3x3"] else 0
            mverisat = VERISAT_DATA_SAT.get(size, 0)
            print(f"  {size}var: 1x1={cycles_to_ms(m1x1):.2f}ms, 2x2={cycles_to_ms(m2x2):.2f}ms, "
                  f"3x3={cycles_to_ms(m3x3):.2f}ms, VeriSAT={mverisat:.2f}ms")

    print("\nUNSAT Instances Summary:")
    print("-" * 100)
    for size in all_sizes:
        if size_groups_unsat[size]["1x1"]:
            m1x1 = np.mean(size_groups_unsat[size]["1x1"])
            m2x2 = np.mean(size_groups_unsat[size]["2x2"]) if size_groups_unsat[size]["2x2"] else 0
            m3x3 = np.mean(size_groups_unsat[size]["3x3"]) if size_groups_unsat[size]["3x3"] else 0
            mverisat = VERISAT_DATA_UNSAT.get(size, 0)
            print(f"  {size}var: 1x1={cycles_to_ms(m1x1):.2f}ms, 2x2={cycles_to_ms(m2x2):.2f}ms, "
                  f"3x3={cycles_to_ms(m3x3):.2f}ms, VeriSAT={mverisat:.2f}ms")

    print("\n✓ SAT vs UNSAT comparison plot generated")


if __name__ == "__main__":
    main()
