#!/usr/bin/env python3
"""
plot_comparison_improved.py — Two comparison charts:

1. Bar chart: 4 bars per problem size (1x1, 2x2, 3x3, VeriSAT)
2. Line chart: 3x3 vs VeriSAT scaling across problem sizes

Uses professional publication colors.

Usage:
    python3 benchmarks/plot_comparison_improved.py
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
VERISAT_DATA = {
    50: 0.26,      # UF50
    75: 1.99,      # UF75
    100: 11.41,    # UF100
    125: 110.62,   # UF125
    150: 713.62,   # UF150
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
    parser = argparse.ArgumentParser(description="Improved SatSwarm vs VeriSAT comparison.")
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

    # Group by problem size for each config
    size_groups = defaultdict(lambda: {"1x1": [], "2x2": [], "3x3": []})

    for config_name in data:
        for row in data[config_name]:
            var_count = row["vars"]
            size_groups[var_count][config_name].append(row["cycles"])

    # Sort problem sizes
    problem_sizes = sorted(size_groups.keys())

    # Prepare data for plotting (convert cycles to ms)
    configs_list = ["1x1", "2x2", "3x3"]
    means_ms = {config: [] for config in configs_list}
    stds_ms = {config: [] for config in configs_list}
    verisat_times = []

    for size in problem_sizes:
        for config in configs_list:
            cycles_list = size_groups[size][config]
            if cycles_list:
                cycles_mean = np.mean(cycles_list)
                cycles_std = np.std(cycles_list)
                means_ms[config].append(cycles_to_ms(cycles_mean))
                stds_ms[config].append(cycles_to_ms(cycles_std))
            else:
                means_ms[config].append(0)
                stds_ms[config].append(0)

        # Get VeriSAT time
        if size in VERISAT_DATA:
            verisat_times.append(VERISAT_DATA[size])
        else:
            verisat_times.append(None)

    # ===== PLOT 1: Grouped Bar Chart (4 bars per problem size) =====
    fig, ax = plt.subplots(figsize=(14, 7))

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
    ax.set_xlabel("Problem Size (variables)", fontsize=13, fontweight="bold")
    ax.set_ylabel("Time to Solve (milliseconds)", fontsize=13, fontweight="bold")
    ax.set_title("SatSwarmV2 vs VeriSAT: Solution Time Comparison",
                 fontsize=14, fontweight="bold")
    ax.set_xticks(x)
    ax.set_xticklabels([str(size) for size in problem_sizes], fontsize=12)
    ax.legend(fontsize=12, loc="upper left", framealpha=0.95, ncol=2)
    ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f"{v:.1f}"))
    ax.grid(axis="y", alpha=0.3, linestyle='--')
    ax.set_yscale("log")

    fig.tight_layout()
    out_path = out_dir / "comparison_bars.png"
    fig.savefig(out_path, dpi=150, bbox_inches='tight')
    print(f"Saved: {out_path}")
    plt.close(fig)

    # ===== PLOT 2: Line Chart (3x3 vs VeriSAT) =====
    fig, ax = plt.subplots(figsize=(12, 7))

    # Plot scaling lines
    ax.plot(problem_sizes, means_ms["3x3"],
            marker='o', markersize=12, linewidth=3,
            color=COLORS["3x3"], label="SatSwarm 3×3 (9 cores)",
            zorder=4)

    ax.plot(problem_sizes, verisat_times_clean,
            marker='s', markersize=12, linewidth=3,
            color=COLORS["VeriSAT"], label="VeriSAT@150MHz",
            zorder=4)

    # Formatting
    ax.set_xlabel("Problem Size (variables)", fontsize=13, fontweight="bold")
    ax.set_ylabel("Time to Solve (milliseconds)", fontsize=13, fontweight="bold")
    ax.set_title("Scaling Comparison: SatSwarm 3×3 vs VeriSAT",
                 fontsize=14, fontweight="bold")
    ax.legend(fontsize=12, loc="upper left", framealpha=0.95)
    ax.grid(True, alpha=0.3, linestyle='--', which='both')
    ax.set_yscale("log")
    ax.set_xscale("linear")
    ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f"{v:.1f}"))

    # Annotate with actual values at each point
    for xval, y3x3, yverisat in zip(problem_sizes, means_ms["3x3"], verisat_times_clean):
        ax.annotate(f'{y3x3:.1f}',
                   xy=(xval, y3x3),
                   xytext=(0, 10),
                   textcoords='offset points',
                   ha='center', fontsize=9,
                   color=COLORS["3x3"], fontweight='bold')
        ax.annotate(f'{yverisat:.1f}',
                   xy=(xval, yverisat),
                   xytext=(0, -15),
                   textcoords='offset points',
                   ha='center', fontsize=9,
                   color=COLORS["VeriSAT"], fontweight='bold')

    fig.tight_layout()
    out_path = out_dir / "scaling_comparison.png"
    fig.savefig(out_path, dpi=150, bbox_inches='tight')
    print(f"Saved: {out_path}")
    plt.close(fig)

    print("\n✓ Comparison plots generated successfully")


if __name__ == "__main__":
    main()
