#!/usr/bin/env python3
"""
plot_speedup_by_size.py — Show speedup by problem size.

X-axis: Problem size (50, 75, 100, 125 variables)
Y-axis: Speedup (vs 1x1 baseline)
Bars: 2x2 and 3x3 speedup at each size

Usage:
    python3 benchmarks/plot_speedup_by_size.py
    python3 benchmarks/plot_speedup_by_size.py --out plots/
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
    "2x2": "#DE8F05",      # Vibrant orange
    "3x3": "#029E73",      # Vibrant green
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


def compute_speedup(baseline, other):
    """Compute speedup (baseline / other)."""
    if baseline == 0 or other == 0:
        return 0
    return baseline / other


def main():
    parser = argparse.ArgumentParser(description="Plot speedup by problem size.")
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

    # Compute speedups
    speedups_2x2 = []
    speedups_3x3 = []
    efficiency_2x2 = []
    efficiency_3x3 = []

    for size in problem_sizes:
        cycles_1x1 = size_groups[size]["1x1"]
        cycles_2x2 = size_groups[size]["2x2"]
        cycles_3x3 = size_groups[size]["3x3"]

        if cycles_1x1 and cycles_2x2 and cycles_3x3:
            mean_1x1 = np.mean(cycles_1x1)
            mean_2x2 = np.mean(cycles_2x2)
            mean_3x3 = np.mean(cycles_3x3)

            speedup_2x2 = compute_speedup(mean_1x1, mean_2x2)
            speedup_3x3 = compute_speedup(mean_1x1, mean_3x3)

            speedups_2x2.append(speedup_2x2)
            speedups_3x3.append(speedup_3x3)
            efficiency_2x2.append((speedup_2x2 / 4) * 100)
            efficiency_3x3.append((speedup_3x3 / 9) * 100)

    # Create plot with two subplots: speedup and efficiency
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))

    x = np.arange(len(problem_sizes))
    width = 0.35

    # Speedup plot
    bars1_1 = ax1.bar(x - width/2, speedups_2x2, width, label="2×2 (4 cores)",
                      color=COLORS["2x2"], alpha=0.85, edgecolor="black", linewidth=1)
    bars1_2 = ax1.bar(x + width/2, speedups_3x3, width, label="3×3 (9 cores)",
                      color=COLORS["3x3"], alpha=0.85, edgecolor="black", linewidth=1)

    # Reference lines for linear speedup
    ax1.axhline(4.0, color=COLORS["2x2"], linestyle=":", linewidth=2, alpha=0.4, label="Linear (2×2)")
    ax1.axhline(9.0, color=COLORS["3x3"], linestyle=":", linewidth=2, alpha=0.4, label="Linear (3×3)")
    ax1.axhline(1.0, color="gray", linestyle="--", linewidth=1, alpha=0.5)

    ax1.set_xlabel("Problem Size (variables)", fontsize=13, fontweight="bold")
    ax1.set_ylabel("Speedup (vs 1×1)", fontsize=13, fontweight="bold")
    ax1.set_title("Speedup by Problem Size", fontsize=14, fontweight="bold")
    ax1.set_xticks(x)
    ax1.set_xticklabels([str(size) for size in problem_sizes], fontsize=12)
    ax1.legend(fontsize=11, loc="upper right")
    ax1.grid(axis="y", alpha=0.3)
    ax1.set_ylim([0, max(10, max(speedups_3x3) * 1.1)])

    # Annotate speedup values
    for bar in bars1_1:
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width() / 2, height + 0.1,
                f'{height:.2f}x', ha='center', va='bottom', fontsize=10, fontweight='bold')

    for bar in bars1_2:
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width() / 2, height + 0.1,
                f'{height:.2f}x', ha='center', va='bottom', fontsize=10, fontweight='bold')

    # Efficiency plot
    bars2_1 = ax2.bar(x - width/2, efficiency_2x2, width, label="2×2 (4 cores)",
                      color=COLORS["2x2"], alpha=0.85, edgecolor="black", linewidth=1)
    bars2_2 = ax2.bar(x + width/2, efficiency_3x3, width, label="3×3 (9 cores)",
                      color=COLORS["3x3"], alpha=0.85, edgecolor="black", linewidth=1)

    ax2.axhline(100.0, color="gray", linestyle="--", linewidth=1.5, alpha=0.6, label="Perfect (100%)")
    ax2.axhline(50.0, color="gray", linestyle=":", linewidth=1, alpha=0.4)
    ax2.axhline(11.1, color="gray", linestyle=":", linewidth=1, alpha=0.4)

    ax2.set_xlabel("Problem Size (variables)", fontsize=13, fontweight="bold")
    ax2.set_ylabel("Parallel Efficiency (%)", fontsize=13, fontweight="bold")
    ax2.set_title("Parallel Efficiency by Problem Size", fontsize=14, fontweight="bold")
    ax2.set_xticks(x)
    ax2.set_xticklabels([str(size) for size in problem_sizes], fontsize=12)
    ax2.legend(fontsize=11, loc="upper right")
    ax2.grid(axis="y", alpha=0.3)
    ax2.set_ylim([0, 110])

    # Annotate efficiency values
    for bar in bars2_1:
        height = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width() / 2, height + 1,
                f'{height:.1f}%', ha='center', va='bottom', fontsize=10, fontweight='bold')

    for bar in bars2_2:
        height = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width() / 2, height + 1,
                f'{height:.1f}%', ha='center', va='bottom', fontsize=10, fontweight='bold')

    fig.tight_layout()
    out_path = out_dir / "speedup_by_size.png"
    fig.savefig(out_path, dpi=150)
    print(f"Saved: {out_path}")
    plt.close(fig)

    # Print summary
    print("\nSpeedup & Efficiency Summary:")
    print("-" * 90)
    print(f"{'Size':>6} | {'2×2 Speedup':>14} | {'2×2 Efficiency':>18} | {'3×3 Speedup':>14} | {'3×3 Efficiency':>18}")
    print("-" * 90)
    for i, size in enumerate(problem_sizes):
        print(f"{size:>6} | {speedups_2x2[i]:>10.2f}x | {efficiency_2x2[i]:>14.1f}% | {speedups_3x3[i]:>10.2f}x | {efficiency_3x3[i]:>14.1f}%")


if __name__ == "__main__":
    main()
