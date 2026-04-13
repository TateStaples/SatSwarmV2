#!/usr/bin/env python3
"""
plot_comparison_with_verisat.py — Compare SatSwarm (1x1, 2x2, 3x3) with VeriSAT.

Shows time to solve (milliseconds) for different problem sizes.
SatSwarm: 15.625 MHz
VeriSAT: 150 MHz (data from paper)

Usage:
    python3 benchmarks/plot_comparison_with_verisat.py
    python3 benchmarks/plot_comparison_with_verisat.py --out plots/
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
    "1x1": "#757575",
    "2x2": "#2196F3",
    "3x3": "#4CAF50",
    "VeriSAT": "#FF6F00",
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
    parser = argparse.ArgumentParser(description="Compare SatSwarm vs VeriSAT by problem size.")
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

    # Create plot
    fig, ax = plt.subplots(figsize=(16, 7))

    x = np.arange(len(problem_sizes))
    width = 0.2

    # Plot bars for each config (SatSwarm configs)
    bars = {}
    for i, config in enumerate(configs_list):
        offset = (i - 1) * width
        bars[config] = ax.bar(
            x + offset,
            means_ms[config],
            width,
            yerr=stds_ms[config],
            label=config,
            color=COLORS[config],
            alpha=0.85,
            capsize=4,
            error_kw={"linewidth": 1.5}
        )

    # Plot VeriSAT bars
    verisat_times_clean = [t if t is not None else 0 for t in verisat_times]
    bars_verisat = ax.bar(
        x + 1.5 * width,
        verisat_times_clean,
        width,
        label="VeriSAT@150MHz",
        color=COLORS["VeriSAT"],
        alpha=0.85,
        edgecolor="black",
        linewidth=1
    )

    # Formatting
    ax.set_xlabel("Problem Size (variables)", fontsize=13, fontweight="bold")
    ax.set_ylabel("Time to Solve (milliseconds)", fontsize=13, fontweight="bold")
    ax.set_title("SatSwarmV2 vs VeriSAT: Time to Solve by Problem Size", fontsize=14, fontweight="bold")
    ax.set_xticks(x)
    ax.set_xticklabels([str(size) for size in problem_sizes], fontsize=12)
    ax.legend(fontsize=12, loc="upper left", ncol=2)
    ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f"{v:.1f}"))
    ax.grid(axis="y", alpha=0.3)
    ax.set_yscale("log")  # Log scale to see both small and large times

    # Add value annotations on bars
    for config in configs_list:
        for bar in bars[config]:
            height = bar.get_height()
            if height > 0:
                ax.text(
                    bar.get_x() + bar.get_width() / 2,
                    height * 1.3,
                    f"{height:.2f}ms",
                    ha="center",
                    va="bottom",
                    fontsize=8,
                    rotation=0
                )

    for bar in bars_verisat:
        height = bar.get_height()
        if height > 0:
            ax.text(
                bar.get_x() + bar.get_width() / 2,
                height * 1.3,
                f"{height:.2f}ms",
                ha="center",
                va="bottom",
                fontsize=8,
                rotation=0
            )

    fig.tight_layout()
    out_path = out_dir / "comparison_with_verisat.png"
    fig.savefig(out_path, dpi=150)
    print(f"Saved: {out_path}")
    plt.close(fig)

    # Print summary statistics
    print("\nTime Comparison (milliseconds, SAT instances only):")
    print("-" * 100)
    print(f"{'Size':>6} | {'1x1 (15.625MHz)':>20} | {'2x2 (15.625MHz)':>20} | {'3x3 (15.625MHz)':>20} | {'VeriSAT (150MHz)':>20}")
    print("-" * 100)
    for i, size in enumerate(problem_sizes):
        t1x1 = means_ms["1x1"][i] if means_ms["1x1"][i] > 0 else None
        t2x2 = means_ms["2x2"][i] if means_ms["2x2"][i] > 0 else None
        t3x3 = means_ms["3x3"][i] if means_ms["3x3"][i] > 0 else None
        tverisat = verisat_times[i]

        t1x1_str = f"{t1x1:.3f} ms" if t1x1 else "N/A"
        t2x2_str = f"{t2x2:.3f} ms" if t2x2 else "N/A"
        t3x3_str = f"{t3x3:.3f} ms" if t3x3 else "N/A"
        tverisat_str = f"{tverisat:.3f} ms" if tverisat else "N/A"

        print(f"{size:>6} | {t1x1_str:>20} | {t2x2_str:>20} | {t3x3_str:>20} | {tverisat_str:>20}")

    # Speedup vs VeriSAT
    print("\n\nSpeedup vs VeriSAT (1x1 baseline):")
    print("-" * 100)
    print(f"{'Size':>6} | {'1x1 vs VeriSAT':>20} | {'2x2 vs VeriSAT':>20} | {'3x3 vs VeriSAT':>20}")
    print("-" * 100)
    for i, size in enumerate(problem_sizes):
        t1x1 = means_ms["1x1"][i]
        t2x2 = means_ms["2x2"][i]
        t3x3 = means_ms["3x3"][i]
        tverisat = verisat_times[i]

        if tverisat and t1x1 > 0:
            speedup_1x1 = tverisat / t1x1
            speedup_1x1_str = f"{speedup_1x1:.2f}x faster" if speedup_1x1 > 1 else f"{1/speedup_1x1:.2f}x slower"
        else:
            speedup_1x1_str = "N/A"

        if tverisat and t2x2 > 0:
            speedup_2x2 = tverisat / t2x2
            speedup_2x2_str = f"{speedup_2x2:.2f}x faster" if speedup_2x2 > 1 else f"{1/speedup_2x2:.2f}x slower"
        else:
            speedup_2x2_str = "N/A"

        if tverisat and t3x3 > 0:
            speedup_3x3 = tverisat / t3x3
            speedup_3x3_str = f"{speedup_3x3:.2f}x faster" if speedup_3x3 > 1 else f"{1/speedup_3x3:.2f}x slower"
        else:
            speedup_3x3_str = "N/A"

        print(f"{size:>6} | {speedup_1x1_str:>20} | {speedup_2x2_str:>20} | {speedup_3x3_str:>20}")


if __name__ == "__main__":
    main()
