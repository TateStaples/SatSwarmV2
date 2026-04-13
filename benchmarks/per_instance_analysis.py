#!/usr/bin/env python3
"""
per_instance_analysis.py — Detailed per-instance speedup analysis.

Shows which instances benefit most from parallelization.

Usage:
    python3 benchmarks/per_instance_analysis.py
    python3 benchmarks/per_instance_analysis.py --output instance_analysis.txt
    python3 benchmarks/per_instance_analysis.py --plot  # Generate per-instance scatter plot
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
    matplotlib = None

# Benchmark directories
BENCHMARKS_DIR = Path("benchmarks/results")
CONFIGS = {
    "1x1": "20260412_183019_1x1",
    "2x2": "20260412_183903_2x2-3clz",
    "3x3": "20260412_184806_3x3-2clz",
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


def match_instances(data_all):
    """Match instances across configs and compute speedups."""
    # Key: (instance, expected), value: {config: cycles}
    instances = defaultdict(dict)

    for config_name in data_all:
        for row in data_all[config_name]:
            key = (row["instance"], row["expected"])
            instances[key][config_name] = row["cycles"]

    return instances


def compute_speedup(baseline, other):
    """Compute speedup."""
    if baseline == 0 or other == 0:
        return 0
    return baseline / other


def main():
    parser = argparse.ArgumentParser(description="Analyze per-instance speedup.")
    parser.add_argument("--output", default=None, help="Output text file")
    parser.add_argument("--plot", action="store_true", help="Generate scatter plots")
    args = parser.parse_args()

    # Load all configs
    data = {}
    for config_name in ["1x1", "2x2", "3x3"]:
        data[config_name] = load_csv(config_name)
        if data[config_name] is None:
            sys.exit(1)
        data[config_name] = correct_only(data[config_name])

    # Match instances
    instances = match_instances(data)

    # Filter to instances that have all 3 configs
    complete_instances = {k: v for k, v in instances.items() if len(v) == 3}

    lines = []
    lines.append("=" * 110)
    lines.append("Per-Instance Speedup Analysis")
    lines.append("=" * 110)
    lines.append("")
    lines.append(f"Total instances with all 3 configs: {len(complete_instances)}")
    lines.append("")

    # Compute per-instance speedups
    speedups_2x2 = []
    speedups_3x3 = []
    instance_names = []

    for (instance, expected), cycles_dict in sorted(complete_instances.items()):
        speedup_2x2 = compute_speedup(cycles_dict["1x1"], cycles_dict["2x2"])
        speedup_3x3 = compute_speedup(cycles_dict["1x1"], cycles_dict["3x3"])

        speedups_2x2.append(speedup_2x2)
        speedups_3x3.append(speedup_3x3)
        instance_names.append(f"{instance} ({expected})")

    # Statistics
    lines.append("2×2 SPEEDUP STATISTICS:")
    lines.append(f"  Mean:     {np.mean(speedups_2x2):.3f}x")
    lines.append(f"  Median:   {np.median(speedups_2x2):.3f}x")
    lines.append(f"  Std Dev:  {np.std(speedups_2x2):.3f}")
    lines.append(f"  Min:      {np.min(speedups_2x2):.3f}x")
    lines.append(f"  Max:      {np.max(speedups_2x2):.3f}x")
    lines.append("")

    lines.append("3×3 SPEEDUP STATISTICS:")
    lines.append(f"  Mean:     {np.mean(speedups_3x3):.3f}x")
    lines.append(f"  Median:   {np.median(speedups_3x3):.3f}x")
    lines.append(f"  Std Dev:  {np.std(speedups_3x3):.3f}")
    lines.append(f"  Min:      {np.min(speedups_3x3):.3f}x")
    lines.append(f"  Max:      {np.max(speedups_3x3):.3f}x")
    lines.append("")

    # Best and worst cases
    sorted_2x2 = sorted(zip(instance_names, speedups_2x2), key=lambda x: x[1], reverse=True)
    sorted_3x3 = sorted(zip(instance_names, speedups_3x3), key=lambda x: x[1], reverse=True)

    lines.append("BEST SPEEDUP (2×2):")
    for name, speedup in sorted_2x2[:5]:
        lines.append(f"  {speedup:.3f}x - {name}")
    lines.append("")

    lines.append("WORST SPEEDUP (2×2):")
    for name, speedup in sorted_2x2[-5:]:
        lines.append(f"  {speedup:.3f}x - {name}")
    lines.append("")

    lines.append("BEST SPEEDUP (3×3):")
    for name, speedup in sorted_3x3[:5]:
        lines.append(f"  {speedup:.3f}x - {name}")
    lines.append("")

    lines.append("WORST SPEEDUP (3×3):")
    for name, speedup in sorted_3x3[-5:]:
        lines.append(f"  {speedup:.3f}x - {name}")
    lines.append("")

    lines.append("=" * 110)

    output = "\n".join(lines)

    if args.output:
        with open(args.output, "w") as f:
            f.write(output)
        print(f"Analysis written to: {args.output}")
    else:
        print(output)

    # Generate plots if requested
    if args.plot:
        if matplotlib is None:
            print("ERROR: matplotlib required for --plot. Run: pip install matplotlib")
            sys.exit(1)

        out_dir = Path("benchmarks/results/comparison")
        out_dir.mkdir(parents=True, exist_ok=True)

        # Scatter: 1x1 vs 2x2
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

        cycles_1x1 = [cycles_dict["1x1"] for cycles_dict in complete_instances.values()]
        cycles_2x2 = [cycles_dict["2x2"] for cycles_dict in complete_instances.values()]
        cycles_3x3 = [cycles_dict["3x3"] for cycles_dict in complete_instances.values()]

        ax1.scatter(cycles_1x1, cycles_2x2, alpha=0.6, s=50, color="#2196F3")
        ax1.set_xlabel("1×1 Cycles", fontsize=12)
        ax1.set_ylabel("2×2 Cycles", fontsize=12)
        ax1.set_title("1×1 vs 2×2 Cycles per Instance", fontsize=13)
        ax1.grid(True, alpha=0.3)

        # Add diagonal for reference (no speedup)
        max_val = max(max(cycles_1x1), max(cycles_2x2))
        ax1.plot([0, max_val], [0, max_val], 'r--', alpha=0.3, label="No speedup")
        ax1.legend()

        ax2.scatter(cycles_1x1, cycles_3x3, alpha=0.6, s=50, color="#4CAF50")
        ax2.set_xlabel("1×1 Cycles", fontsize=12)
        ax2.set_ylabel("3×3 Cycles", fontsize=12)
        ax2.set_title("1×1 vs 3×3 Cycles per Instance", fontsize=13)
        ax2.grid(True, alpha=0.3)

        max_val = max(max(cycles_1x1), max(cycles_3x3))
        ax2.plot([0, max_val], [0, max_val], 'r--', alpha=0.3, label="No speedup")
        ax2.legend()

        fig.tight_layout()
        fig.savefig(out_dir / "instance_cycles_scatter.png", dpi=150)
        print(f"\nPlot saved to: {out_dir / 'instance_cycles_scatter.png'}")
        plt.close(fig)

        # Histogram: speedup distribution
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

        ax1.hist(speedups_2x2, bins=15, color="#2196F3", alpha=0.7, edgecolor='black')
        ax1.axvline(np.mean(speedups_2x2), color='red', linestyle='--', linewidth=2, label=f'Mean: {np.mean(speedups_2x2):.2f}x')
        ax1.set_xlabel("Speedup", fontsize=12)
        ax1.set_ylabel("Number of Instances", fontsize=12)
        ax1.set_title("2×2 Speedup Distribution", fontsize=13)
        ax1.legend()
        ax1.grid(True, alpha=0.3, axis='y')

        ax2.hist(speedups_3x3, bins=15, color="#4CAF50", alpha=0.7, edgecolor='black')
        ax2.axvline(np.mean(speedups_3x3), color='red', linestyle='--', linewidth=2, label=f'Mean: {np.mean(speedups_3x3):.2f}x')
        ax2.set_xlabel("Speedup", fontsize=12)
        ax2.set_ylabel("Number of Instances", fontsize=12)
        ax2.set_title("3×3 Speedup Distribution", fontsize=13)
        ax2.legend()
        ax2.grid(True, alpha=0.3, axis='y')

        fig.tight_layout()
        fig.savefig(out_dir / "speedup_distribution.png", dpi=150)
        print(f"Plot saved to: {out_dir / 'speedup_distribution.png'}")
        plt.close(fig)


if __name__ == "__main__":
    main()
