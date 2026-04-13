#!/usr/bin/env python3
"""
plot_speedup.py — Generate speedup and efficiency comparison plots.

Compares 1x1 baseline against 2x2 and 3x3 configurations.

Usage:
    python3 benchmarks/plot_speedup.py
    python3 benchmarks/plot_speedup.py --out plots/
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


def compute_speedup(baseline_cycles, other_cycles):
    """Compute speedup relative to baseline."""
    if baseline_cycles == 0 or other_cycles == 0:
        return 0
    return baseline_cycles / other_cycles


def plot_speedup_per_dataset(data_all, out_path):
    """Bar chart: speedup per dataset (SAT vs UNSAT)."""
    datasets = set()
    for config_name in data_all:
        for row in data_all[config_name]:
            datasets.add(row["dataset"])

    datasets = sorted(datasets)
    speedup_2x2 = []
    speedup_3x3 = []
    dataset_labels = []

    for dataset in datasets:
        rows_1x1 = [r for r in data_all["1x1"] if r["dataset"] == dataset]
        rows_2x2 = [r for r in data_all["2x2"] if r["dataset"] == dataset]
        rows_3x3 = [r for r in data_all["3x3"] if r["dataset"] == dataset]

        if rows_1x1 and rows_2x2 and rows_3x3:
            mean_1x1 = np.mean([r["cycles"] for r in rows_1x1])
            mean_2x2 = np.mean([r["cycles"] for r in rows_2x2])
            mean_3x3 = np.mean([r["cycles"] for r in rows_3x3])

            speedup_2x2.append(compute_speedup(mean_1x1, mean_2x2))
            speedup_3x3.append(compute_speedup(mean_1x1, mean_3x3))
            dataset_labels.append(dataset)

    x = np.arange(len(dataset_labels))
    width = 0.35

    fig, ax = plt.subplots(figsize=(12, 6))
    bars1 = ax.bar(x - width/2, speedup_2x2, width, label="2×2 (4 cores)", color=COLORS["2x2"], alpha=0.85)
    bars2 = ax.bar(x + width/2, speedup_3x3, width, label="3×3 (9 cores)", color=COLORS["3x3"], alpha=0.85)

    ax.axhline(1.0, color="gray", linestyle="--", linewidth=1, alpha=0.5, label="No speedup (baseline)")
    ax.axhline(4.0, color="#2196F3", linestyle=":", linewidth=1, alpha=0.3, label="Linear (2×2)")
    ax.axhline(9.0, color="#4CAF50", linestyle=":", linewidth=1, alpha=0.3, label="Linear (3×3)")

    ax.set_xlabel("Dataset", fontsize=12)
    ax.set_ylabel("Speedup (vs 1×1)", fontsize=12)
    ax.set_title("SatSwarmV2: Speedup by Dataset", fontsize=13)
    ax.set_xticks(x)
    ax.set_xticklabels(dataset_labels, rotation=30, ha="right")
    ax.legend(fontsize=10)
    ax.grid(axis="y", alpha=0.3)

    # Annotate bars
    for bars in [bars1, bars2]:
        for bar in bars:
            height = bar.get_height()
            ax.text(bar.get_x() + bar.get_width()/2., height,
                    f'{height:.2f}x',
                    ha='center', va='bottom', fontsize=9)

    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    print(f"Saved: {out_path}")
    plt.close(fig)


def plot_efficiency_curve(data_all, out_path):
    """Line plot: parallel efficiency vs core count."""
    datasets = set()
    for config_name in data_all:
        for row in data_all[config_name]:
            datasets.add(row["dataset"])

    datasets = sorted(datasets)

    # Compute average speedup across all datasets
    speedup_2x2_list = []
    speedup_3x3_list = []

    for dataset in datasets:
        rows_1x1 = [r for r in data_all["1x1"] if r["dataset"] == dataset]
        rows_2x2 = [r for r in data_all["2x2"] if r["dataset"] == dataset]
        rows_3x3 = [r for r in data_all["3x3"] if r["dataset"] == dataset]

        if rows_1x1 and rows_2x2 and rows_3x3:
            mean_1x1 = np.mean([r["cycles"] for r in rows_1x1])
            mean_2x2 = np.mean([r["cycles"] for r in rows_2x2])
            mean_3x3 = np.mean([r["cycles"] for r in rows_3x3])

            speedup_2x2_list.append(compute_speedup(mean_1x1, mean_2x2))
            speedup_3x3_list.append(compute_speedup(mean_1x1, mean_3x3))

    # Compute efficiency
    speedup_2x2_avg = np.mean(speedup_2x2_list)
    speedup_3x3_avg = np.mean(speedup_3x3_list)
    efficiency_2x2 = (speedup_2x2_avg / 4) * 100
    efficiency_3x3 = (speedup_3x3_avg / 9) * 100

    core_counts = [1, 4, 9]
    speedups = [1.0, speedup_2x2_avg, speedup_3x3_avg]
    efficiencies = [100.0, efficiency_2x2, efficiency_3x3]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Speedup plot
    ax1.plot(core_counts, speedups, marker="o", linewidth=2.5, markersize=10, color="#1565C0", label="Measured")
    ax1.plot(core_counts, core_counts, marker="s", linewidth=2, markersize=8, linestyle="--",
             color="#E53935", alpha=0.7, label="Linear (ideal)")
    ax1.fill_between(core_counts, 1, core_counts, alpha=0.1, color="#E53935")

    ax1.set_xlabel("Core Count", fontsize=12)
    ax1.set_ylabel("Speedup (vs 1×1)", fontsize=12)
    ax1.set_title("Speedup Scaling", fontsize=13)
    ax1.set_xticks(core_counts)
    ax1.grid(True, alpha=0.3)
    ax1.legend(fontsize=10)

    # Annotate speedup points
    for x, y in zip(core_counts[1:], speedups[1:]):
        ax1.annotate(f'{y:.2f}x', (x, y), textcoords="offset points",
                    xytext=(0, 8), ha='center', fontsize=10, fontweight='bold')

    # Efficiency plot
    ax2.plot(core_counts, efficiencies, marker="o", linewidth=2.5, markersize=10, color="#2E7D32", label="Measured")
    ax2.axhline(100.0, color="gray", linestyle="--", linewidth=1, alpha=0.5, label="100% (perfect)")

    ax2.set_xlabel("Core Count", fontsize=12)
    ax2.set_ylabel("Parallel Efficiency (%)", fontsize=12)
    ax2.set_title("Parallel Efficiency", fontsize=13)
    ax2.set_xticks(core_counts)
    ax2.set_ylim([0, 110])
    ax2.grid(True, alpha=0.3)
    ax2.legend(fontsize=10)

    # Annotate efficiency points
    for x, y in zip(core_counts, efficiencies):
        ax2.annotate(f'{y:.1f}%', (x, y), textcoords="offset points",
                    xytext=(0, 8), ha='center', fontsize=10, fontweight='bold')

    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    print(f"Saved: {out_path}")
    plt.close(fig)


def plot_sat_vs_unsat(data_all, out_path):
    """Bar chart: speedup for SAT vs UNSAT instances."""
    speedups_2x2 = {"SAT": [], "UNSAT": []}
    speedups_3x3 = {"SAT": [], "UNSAT": []}

    for result_type in ["SAT", "UNSAT"]:
        rows_1x1 = [r for r in data_all["1x1"] if r["expected"] == result_type]
        rows_2x2 = [r for r in data_all["2x2"] if r["expected"] == result_type]
        rows_3x3 = [r for r in data_all["3x3"] if r["expected"] == result_type]

        if rows_1x1 and rows_2x2 and rows_3x3:
            mean_1x1 = np.mean([r["cycles"] for r in rows_1x1])
            mean_2x2 = np.mean([r["cycles"] for r in rows_2x2])
            mean_3x3 = np.mean([r["cycles"] for r in rows_3x3])

            speedups_2x2[result_type] = compute_speedup(mean_1x1, mean_2x2)
            speedups_3x3[result_type] = compute_speedup(mean_1x1, mean_3x3)

    x = np.arange(2)
    width = 0.35

    fig, ax = plt.subplots(figsize=(10, 6))
    bars1 = ax.bar(x - width/2, [speedups_2x2["SAT"], speedups_2x2["UNSAT"]], width,
                   label="2×2 (4 cores)", color=COLORS["2x2"], alpha=0.85)
    bars2 = ax.bar(x + width/2, [speedups_3x3["SAT"], speedups_3x3["UNSAT"]], width,
                   label="3×3 (9 cores)", color=COLORS["3x3"], alpha=0.85)

    ax.axhline(1.0, color="gray", linestyle="--", linewidth=1, alpha=0.5)
    ax.set_ylabel("Speedup (vs 1×1)", fontsize=12)
    ax.set_title("SatSwarmV2: Speedup by Problem Type", fontsize=13)
    ax.set_xticks(x)
    ax.set_xticklabels(["SAT", "UNSAT"])
    ax.legend(fontsize=10)
    ax.grid(axis="y", alpha=0.3)

    # Annotate
    for bars in [bars1, bars2]:
        for bar in bars:
            height = bar.get_height()
            ax.text(bar.get_x() + bar.get_width()/2., height,
                    f'{height:.2f}x',
                    ha='center', va='bottom', fontsize=10, fontweight='bold')

    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    print(f"Saved: {out_path}")
    plt.close(fig)


def main():
    parser = argparse.ArgumentParser(description="Plot SatSwarm speedup and efficiency.")
    parser.add_argument("--out", default="benchmarks/results/comparison",
                        help="Output directory (default: benchmarks/results/comparison)")
    args = parser.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    # Load all configs
    data = {}
    for config_name in ["1x1", "2x2", "3x3"]:
        data[config_name] = load_csv(config_name)
        if data[config_name] is None:
            sys.exit(1)
        data[config_name] = correct_only(data[config_name])

    print(f"Generating comparison plots in: {out_dir}")
    plot_speedup_per_dataset(data, out_dir / "speedup_per_dataset.png")
    plot_efficiency_curve(data, out_dir / "efficiency_scaling.png")
    plot_sat_vs_unsat(data, out_dir / "speedup_sat_vs_unsat.png")

    print(f"\nAll plots written to: {out_dir}")


if __name__ == "__main__":
    main()
