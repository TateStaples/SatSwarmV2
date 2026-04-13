#!/usr/bin/env python3
"""
plot_comparison_by_size.py — Compare 1x1, 2x2, 3x3 cycles by problem size.

X-axis: Problem size (50, 75, 100, 125 variables)
Y-axis: Cycles (mean ± std dev)
Bars: Three bars per problem size (1x1, 2x2, 3x3)

Usage:
    python3 benchmarks/plot_comparison_by_size.py
    python3 benchmarks/plot_comparison_by_size.py --out plots/
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
    import matplotlib.patches as mpatches
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

COLORS = {
    "1x1": "#0173B2",      # Vibrant blue
    "2x2": "#DE8F05",      # Vibrant orange
    "3x3": "#029E73",      # Vibrant green
}

CLOCK_MHZ = 15.625


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


def cycles_to_ms(cycles):
    """Convert cycles to milliseconds at CLOCK_MHZ."""
    return cycles / CLOCK_MHZ / 1000.0


def main():
    parser = argparse.ArgumentParser(description="Plot cycles by problem size for all configs.")
    parser.add_argument("--out", default="benchmarks/results/comparison",
                        help="Output directory (default: benchmarks/results/comparison)")
    args = parser.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    # Load all configs
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

    # Prepare data for plotting
    configs_list = ["1x1", "2x2", "3x3"]
    means = {config: [] for config in configs_list}
    stds = {config: [] for config in configs_list}

    for size in problem_sizes:
        for config in configs_list:
            cycles_list = size_groups[size][config]
            if cycles_list:
                means[config].append(np.mean(cycles_list))
                stds[config].append(np.std(cycles_list))
            else:
                means[config].append(0)
                stds[config].append(0)

    # Create plot
    fig, ax = plt.subplots(figsize=(14, 7))

    x = np.arange(len(problem_sizes))
    width = 0.25

    # Plot bars for each config
    bars = {}
    for i, config in enumerate(configs_list):
        offset = (i - 1) * width
        bars[config] = ax.bar(
            x + offset,
            means[config],
            width,
            yerr=stds[config],
            label=config,
            color=COLORS[config],
            alpha=0.85,
            capsize=4,
            error_kw={"linewidth": 1.5}
        )

    # Formatting
    ax.set_xlabel("Problem Size (variables)", fontsize=13, fontweight="bold")
    ax.set_ylabel("Mean Cycles (correct instances only)", fontsize=13, fontweight="bold")
    ax.set_title("SatSwarmV2: Cycles by Problem Size (UF50 + UUF50 combined)", fontsize=14, fontweight="bold")
    ax.set_xticks(x)
    ax.set_xticklabels([str(size) for size in problem_sizes], fontsize=12)
    ax.legend(fontsize=12, loc="upper left")
    ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f"{int(v):,}"))
    ax.grid(axis="y", alpha=0.3)

    # Add value annotations on bars
    for config in configs_list:
        for bar in bars[config]:
            height = bar.get_height()
            if height > 0:
                ax.text(
                    bar.get_x() + bar.get_width() / 2,
                    height * 1.01,
                    f"{int(height):,}",
                    ha="center",
                    va="bottom",
                    fontsize=9
                )

    # Secondary y-axis in ms
    ax2 = ax.twinx()
    y_min, y_max = ax.get_ylim()
    ax2.set_ylim(cycles_to_ms(y_min), cycles_to_ms(y_max))
    ax2.set_ylabel("Time @ 15.625 MHz (ms)", fontsize=13, fontweight="bold")

    fig.tight_layout()
    out_path = out_dir / "cycles_by_size.png"
    fig.savefig(out_path, dpi=150)
    print(f"Saved: {out_path}")
    plt.close(fig)

    # Print summary statistics
    print("\nSummary Statistics (mean ± std):")
    print("-" * 80)
    for size in problem_sizes:
        print(f"\n{size} variables:")
        for config in configs_list:
            cycles_list = size_groups[size][config]
            if cycles_list:
                m = np.mean(cycles_list)
                s = np.std(cycles_list)
                ms = cycles_to_ms(m)
                print(f"  {config:3s}: {m:>10,.0f} ± {s:>10,.0f} cycles ({ms:>8.3f} ms)")


if __name__ == "__main__":
    main()
