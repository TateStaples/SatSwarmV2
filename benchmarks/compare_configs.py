#!/usr/bin/env python3
"""
compare_configs.py — Compare benchmark statistics across different grid configurations.

Compares 1x1 baseline against 2x2 and 3x3 to show speedup and efficiency.

Usage:
    python3 benchmarks/compare_configs.py
    python3 benchmarks/compare_configs.py --output comparison_report.txt
"""

import argparse
import csv
import sys
from pathlib import Path
from collections import defaultdict
import numpy as np

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


def compute_stats(rows, dataset=None):
    """Compute statistics for rows, optionally filtered by dataset."""
    if dataset:
        rows = [r for r in rows if r["dataset"] == dataset]

    if not rows:
        return None

    cycles = [r["cycles"] for r in rows]
    return {
        "count": len(cycles),
        "mean": np.mean(cycles),
        "median": np.median(cycles),
        "std": np.std(cycles),
        "min": np.min(cycles),
        "max": np.max(cycles),
    }


def format_stats(stats):
    """Format statistics dict as readable string."""
    if stats is None:
        return "N/A"
    return (f"Count: {stats['count']:3d} | "
            f"Mean: {stats['mean']:>10,.0f} | "
            f"Median: {stats['median']:>10,.0f} | "
            f"Std: {stats['std']:>10,.0f}")


def cycles_to_ms(cycles):
    """Convert cycles to milliseconds at CLOCK_MHZ."""
    return cycles / CLOCK_MHZ / 1000.0


def compute_speedup(baseline_cycles, other_cycles):
    """Compute speedup relative to baseline."""
    if baseline_cycles == 0 or other_cycles == 0:
        return 0
    return baseline_cycles / other_cycles


def main():
    parser = argparse.ArgumentParser(description="Compare SatSwarm configuration statistics.")
    parser.add_argument("--output", default=None, help="Output file (default: stdout)")
    args = parser.parse_args()

    # Load all configs
    data = {}
    for config_name in ["1x1", "2x2", "3x3"]:
        data[config_name] = load_csv(config_name)
        if data[config_name] is None:
            print(f"ERROR: Failed to load {config_name}")
            sys.exit(1)

    # Filter to correct results only
    for config_name in data:
        data[config_name] = correct_only(data[config_name])

    # Build output
    lines = []
    lines.append("=" * 120)
    lines.append("SatSwarmV2 Configuration Comparison (UF50 & UUF50)")
    lines.append("=" * 120)
    lines.append("")

    # Overall statistics
    lines.append("OVERALL STATISTICS (all correct results)")
    lines.append("-" * 120)
    for config_name in ["1x1", "2x2", "3x3"]:
        stats = compute_stats(data[config_name])
        lines.append(f"{config_name:6s}: {format_stats(stats)}")
    lines.append("")

    # Per-dataset breakdown
    lines.append("PER-DATASET STATISTICS")
    lines.append("-" * 120)

    datasets = set()
    for config_name in data:
        for row in data[config_name]:
            datasets.add(row["dataset"])

    for dataset in sorted(datasets):
        lines.append(f"\n{dataset.upper()}:")
        for config_name in ["1x1", "2x2", "3x3"]:
            stats = compute_stats(data[config_name], dataset=dataset)
            if stats:
                lines.append(f"  {config_name:6s}: {format_stats(stats)}")

    lines.append("")
    lines.append("")

    # Speedup analysis
    lines.append("=" * 120)
    lines.append("SPEEDUP ANALYSIS (vs 1x1 baseline)")
    lines.append("=" * 120)
    lines.append("")

    # Overall speedup
    stats_1x1 = compute_stats(data["1x1"])
    lines.append("OVERALL SPEEDUP:")
    for config_name in ["2x2", "3x3"]:
        stats_other = compute_stats(data[config_name])
        speedup_mean = compute_speedup(stats_1x1["mean"], stats_other["mean"])
        speedup_median = compute_speedup(stats_1x1["median"], stats_other["median"])
        cores = 4 if config_name == "2x2" else 9
        efficiency = (speedup_mean / cores) * 100
        lines.append(f"  {config_name} ({cores} cores): {speedup_mean:6.2f}x speedup (mean), "
                    f"{speedup_median:6.2f}x (median), Efficiency: {efficiency:5.1f}%")
    lines.append("")

    # Per-dataset speedup
    lines.append("PER-DATASET SPEEDUP:")
    for dataset in sorted(datasets):
        lines.append(f"\n  {dataset.upper()}:")
        stats_1x1_ds = compute_stats(data["1x1"], dataset=dataset)

        for config_name in ["2x2", "3x3"]:
            stats_other_ds = compute_stats(data[config_name], dataset=dataset)
            if stats_1x1_ds and stats_other_ds:
                speedup_mean = compute_speedup(stats_1x1_ds["mean"], stats_other_ds["mean"])
                cores = 4 if config_name == "2x2" else 9
                efficiency = (speedup_mean / cores) * 100
                lines.append(f"    {config_name}: {speedup_mean:6.2f}x speedup, Efficiency: {efficiency:5.1f}%")

    lines.append("")
    lines.append("")

    # Per-instance analysis (SAT vs UNSAT)
    lines.append("=" * 120)
    lines.append("SAT vs UNSAT ANALYSIS")
    lines.append("=" * 120)
    lines.append("")

    for result_type in ["SAT", "UNSAT"]:
        lines.append(f"\n{result_type} instances:")

        for config_name in ["1x1", "2x2", "3x3"]:
            rows = [r for r in data[config_name] if r["expected"] == result_type]
            stats = compute_stats(rows)
            if stats:
                lines.append(f"  {config_name:6s}: {format_stats(stats)}")

        # Speedup for this result type
        stats_1x1_type = compute_stats([r for r in data["1x1"] if r["expected"] == result_type])
        if stats_1x1_type:
            lines.append(f"\n  Speedup:")
            for config_name in ["2x2", "3x3"]:
                rows_other = [r for r in data[config_name] if r["expected"] == result_type]
                stats_other_type = compute_stats(rows_other)
                if stats_other_type:
                    speedup = compute_speedup(stats_1x1_type["mean"], stats_other_type["mean"])
                    cores = 4 if config_name == "2x2" else 9
                    efficiency = (speedup / cores) * 100
                    lines.append(f"    {config_name}: {speedup:6.2f}x speedup, Efficiency: {efficiency:5.1f}%")

    lines.append("")
    lines.append("")

    # Correctness summary
    lines.append("=" * 120)
    lines.append("CORRECTNESS SUMMARY")
    lines.append("=" * 120)
    lines.append("")

    for config_name in ["1x1", "2x2", "3x3"]:
        all_rows = load_csv(config_name)
        correct_count = sum(1 for r in all_rows if r["correct"] == 1)
        total_count = len(all_rows)
        success_rate = (correct_count / total_count * 100) if total_count > 0 else 0
        lines.append(f"  {config_name}: {correct_count:3d}/{total_count:3d} correct ({success_rate:5.1f}%)")

    lines.append("")
    lines.append("=" * 120)

    output = "\n".join(lines)

    if args.output:
        with open(args.output, "w") as f:
            f.write(output)
        print(f"Report written to: {args.output}")
    else:
        print(output)


if __name__ == "__main__":
    main()
