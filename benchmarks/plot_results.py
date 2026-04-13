#!/usr/bin/env python3
"""
plot_results.py — Visualize SatSwarm benchmark cycles for correct results.

Usage:
    python3 benchmarks/plot_results.py benchmarks/results/<timestamp_grid>/results.csv
    python3 benchmarks/plot_results.py benchmarks/results/<timestamp_grid>/results.csv --out my_plot.png
"""

import argparse
import csv
import sys
from pathlib import Path
from collections import defaultdict

try:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np
except ImportError:
    print("ERROR: matplotlib and numpy are required. Run: pip install matplotlib numpy")
    sys.exit(1)


CLOCK_MHZ = 15.625


def load_csv(path):
    rows = []
    with open(path) as f:
        for row in csv.DictReader(f):
            row["cycles"] = int(row["cycles"])
            row["vars"] = int(row["vars"])
            row["correct"] = int(row["correct"])
            rows.append(row)
    return rows


def correct_only(rows):
    return [r for r in rows if r["correct"] == 1]


def dataset_order(rows):
    """Return datasets sorted by (vars, expected) for consistent axis order."""
    seen = {}
    for r in rows:
        key = r["dataset"]
        if key not in seen:
            seen[key] = (r["vars"], r["expected"])
    return sorted(seen.keys(), key=lambda k: seen[k])


def cycles_to_ms(cycles):
    return cycles / CLOCK_MHZ / 1000.0


def plot_scatter(rows, out_path, grid_label):
    """Cycles scatter per instance, coloured by SAT/UNSAT, correct only."""
    correct = correct_only(rows)
    datasets = dataset_order(correct)

    sat_x, sat_y, sat_labels = [], [], []
    unsat_x, unsat_y, unsat_labels = [], [], []

    for r in correct:
        x = r["vars"]
        y = r["cycles"]
        if r["expected"] == "SAT":
            sat_x.append(x)
            sat_y.append(y)
            sat_labels.append(r["instance"])
        else:
            unsat_x.append(x)
            unsat_y.append(y)
            unsat_labels.append(r["instance"])

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.scatter(sat_x, sat_y, color="#2196F3", alpha=0.7, s=40, label="SAT (correct)")
    ax.scatter(unsat_x, unsat_y, color="#F44336", alpha=0.7, s=40, label="UNSAT (correct)")

    # Mean line per vars/expected group
    groups = defaultdict(list)
    for r in correct:
        groups[(r["vars"], r["expected"])].append(r["cycles"])
    for (v, exp), cycs in sorted(groups.items()):
        mean = np.mean(cycs)
        color = "#1565C0" if exp == "SAT" else "#B71C1C"
        ax.plot(v, mean, marker="D", markersize=8, color=color, zorder=5)

    ax.set_xlabel("Problem size (variables)", fontsize=12)
    ax.set_ylabel("Cycles", fontsize=12)
    ax.set_title(f"SatSwarm [{grid_label}] — Cycles per instance (correct only)", fontsize=13)
    ax.legend(fontsize=10)
    ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f"{int(v):,}"))

    # Secondary y-axis in ms
    ax2 = ax.twinx()
    y_min, y_max = ax.get_ylim()
    ax2.set_ylim(cycles_to_ms(y_min), cycles_to_ms(y_max))
    ax2.set_ylabel("Time @ 15.625 MHz (ms)", fontsize=11)

    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    print(f"Saved: {out_path}")
    plt.close(fig)


def plot_mean_bar(rows, out_path, grid_label):
    """Mean cycles per dataset, correct only, with std dev error bars."""
    correct = correct_only(rows)
    datasets = dataset_order(correct)

    means, stds, colors, labels = [], [], [], []
    for ds in datasets:
        cycs = [r["cycles"] for r in correct if r["dataset"] == ds]
        if not cycs:
            continue
        means.append(np.mean(cycs))
        stds.append(np.std(cycs))
        # first row for this dataset to get expected
        exp = next(r["expected"] for r in correct if r["dataset"] == ds)
        colors.append("#2196F3" if exp == "SAT" else "#F44336")
        labels.append(ds)

    x = np.arange(len(labels))
    fig, ax = plt.subplots(figsize=(11, 6))
    bars = ax.bar(x, means, yerr=stds, color=colors, alpha=0.85, capsize=4, width=0.6)

    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=30, ha="right", fontsize=10)
    ax.set_ylabel("Mean cycles (correct instances)", fontsize=12)
    ax.set_title(f"SatSwarm [{grid_label}] — Mean cycles per dataset (correct only)", fontsize=13)
    ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f"{int(v):,}"))

    sat_patch = mpatches.Patch(color="#2196F3", label="SAT")
    unsat_patch = mpatches.Patch(color="#F44336", label="UNSAT")
    ax.legend(handles=[sat_patch, unsat_patch], fontsize=10)

    # Annotate bars with mean value
    for bar, mean in zip(bars, means):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() * 1.01,
                f"{int(mean):,}", ha="center", va="bottom", fontsize=8)

    # Secondary y-axis in ms
    ax2 = ax.twinx()
    y_min, y_max = ax.get_ylim()
    ax2.set_ylim(cycles_to_ms(y_min), cycles_to_ms(y_max))
    ax2.set_ylabel("Time @ 15.625 MHz (ms)", fontsize=11)

    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    print(f"Saved: {out_path}")
    plt.close(fig)


def plot_box(rows, out_path, grid_label):
    """Box plot of cycle distribution per dataset, correct only."""
    correct = correct_only(rows)
    datasets = dataset_order(correct)

    data, labels, colors = [], [], []
    for ds in datasets:
        cycs = [r["cycles"] for r in correct if r["dataset"] == ds]
        if not cycs:
            continue
        data.append(cycs)
        exp = next(r["expected"] for r in correct if r["dataset"] == ds)
        colors.append("#2196F3" if exp == "SAT" else "#F44336")
        labels.append(ds)

    fig, ax = plt.subplots(figsize=(11, 6))
    bp = ax.boxplot(data, patch_artist=True, widths=0.5)
    for patch, color in zip(bp["boxes"], colors):
        patch.set_facecolor(color)
        patch.set_alpha(0.75)

    ax.set_xticks(range(1, len(labels) + 1))
    ax.set_xticklabels(labels, rotation=30, ha="right", fontsize=10)
    ax.set_ylabel("Cycles (correct instances)", fontsize=12)
    ax.set_title(f"SatSwarm [{grid_label}] — Cycle distribution per dataset (correct only)", fontsize=13)
    ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f"{int(v):,}"))

    sat_patch = mpatches.Patch(color="#2196F3", label="SAT")
    unsat_patch = mpatches.Patch(color="#F44336", label="UNSAT")
    ax.legend(handles=[sat_patch, unsat_patch], fontsize=10)

    ax2 = ax.twinx()
    y_min, y_max = ax.get_ylim()
    ax2.set_ylim(cycles_to_ms(y_min), cycles_to_ms(y_max))
    ax2.set_ylabel("Time @ 15.625 MHz (ms)", fontsize=11)

    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    print(f"Saved: {out_path}")
    plt.close(fig)


def plot_multiplier(rows, out_path, grid_label):
    """Step multiplier between consecutive problem sizes (mean cycles ratio)."""
    correct = correct_only(rows)

    groups = defaultdict(list)
    for r in correct:
        groups[(r["vars"], r["expected"])].append(r["cycles"])

    sat_data = sorted([(v, np.mean(c)) for (v, exp), c in groups.items() if exp == "SAT"])
    unsat_data = sorted([(v, np.mean(c)) for (v, exp), c in groups.items() if exp == "UNSAT"])

    def compute_multipliers(data):
        xs, ys, labels = [], [], []
        for i in range(1, len(data)):
            v_prev, m_prev = data[i - 1]
            v_curr, m_curr = data[i]
            mult = m_curr / m_prev if m_prev > 0 else 0
            xs.append(i)
            ys.append(mult)
            labels.append(f"{v_prev}→{v_curr} vars")
        return xs, ys, labels

    fig, ax = plt.subplots(figsize=(9, 6))

    if len(sat_data) >= 2:
        xs, ys, labels = compute_multipliers(sat_data)
        ax.plot(xs, ys, color="#2196F3", marker="o", linewidth=2, label="SAT")
        for x, y, lbl in zip(xs, ys, labels):
            ax.annotate(f"{y:.2f}×", (x, y), textcoords="offset points",
                        xytext=(0, 8), ha="center", fontsize=10, color="#1565C0")

    if len(unsat_data) >= 2:
        xs, ys, labels = compute_multipliers(unsat_data)
        ax.plot(xs, ys, color="#F44336", marker="s", linewidth=2, label="UNSAT")
        for x, y, lbl in zip(xs, ys, labels):
            ax.annotate(f"{y:.2f}×", (x, y), textcoords="offset points",
                        xytext=(0, -16), ha="center", fontsize=10, color="#B71C1C")

    # Use the SAT labels for x-ticks (same steps)
    if len(sat_data) >= 2:
        _, _, tick_labels = compute_multipliers(sat_data)
        ax.set_xticks(range(1, len(tick_labels) + 1))
        ax.set_xticklabels(tick_labels, fontsize=11)

    ax.axhline(1.0, color="gray", linestyle="--", linewidth=1, alpha=0.6)
    ax.set_ylabel("Cycle multiplier (step-over-step)", fontsize=12)
    ax.set_xlabel("Problem size step", fontsize=12)
    ax.set_title(f"SatSwarm [{grid_label}] — Cycle increase between problem sizes", fontsize=13)
    ax.legend(fontsize=10)

    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    print(f"Saved: {out_path}")
    plt.close(fig)


def plot_scaling(rows, out_path, grid_label):
    """Mean cycles vs vars (scaling curve), SAT and UNSAT separately."""
    correct = correct_only(rows)

    groups = defaultdict(list)
    for r in correct:
        groups[(r["vars"], r["expected"])].append(r["cycles"])

    sat_vars, sat_means, sat_stds = [], [], []
    unsat_vars, unsat_means, unsat_stds = [], [], []

    for (v, exp), cycs in sorted(groups.items()):
        if exp == "SAT":
            sat_vars.append(v)
            sat_means.append(np.mean(cycs))
            sat_stds.append(np.std(cycs))
        else:
            unsat_vars.append(v)
            unsat_means.append(np.mean(cycs))
            unsat_stds.append(np.std(cycs))

    fig, ax = plt.subplots(figsize=(9, 6))

    if sat_vars:
        ax.errorbar(sat_vars, sat_means, yerr=sat_stds,
                    color="#2196F3", marker="o", linewidth=2, capsize=4, label="SAT (mean ± std)")
    if unsat_vars:
        ax.errorbar(unsat_vars, unsat_means, yerr=unsat_stds,
                    color="#F44336", marker="s", linewidth=2, capsize=4, label="UNSAT (mean ± std)")

    ax.set_xlabel("Problem size (variables)", fontsize=12)
    ax.set_ylabel("Mean cycles (correct instances)", fontsize=12)
    ax.set_title(f"SatSwarm [{grid_label}] — Scaling: mean cycles vs problem size", fontsize=13)
    ax.legend(fontsize=10)
    ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f"{int(v):,}"))

    ax2 = ax.twinx()
    y_min, y_max = ax.get_ylim()
    ax2.set_ylim(cycles_to_ms(y_min), cycles_to_ms(y_max))
    ax2.set_ylabel("Time @ 15.625 MHz (ms)", fontsize=11)

    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    print(f"Saved: {out_path}")
    plt.close(fig)


def main():
    parser = argparse.ArgumentParser(description="Plot SatSwarm benchmark results.")
    parser.add_argument("csv", help="Path to results.csv")
    parser.add_argument("--out", default=None,
                        help="Output directory (default: same dir as CSV)")
    args = parser.parse_args()

    csv_path = Path(args.csv)
    if not csv_path.exists():
        print(f"ERROR: {csv_path} not found")
        sys.exit(1)

    out_dir = Path(args.out) if args.out else csv_path.parent
    out_dir.mkdir(parents=True, exist_ok=True)

    rows = load_csv(csv_path)
    grid_label = csv_path.parent.name  # e.g. 20260405_173817_1x1

    n_total = len(rows)
    n_correct = sum(1 for r in rows if r["correct"] == 1)
    print(f"Loaded {n_total} rows, {n_correct} correct")

    plot_scatter(rows, out_dir / "cycles_scatter.png", grid_label)
    plot_mean_bar(rows, out_dir / "cycles_mean_bar.png", grid_label)
    plot_box(rows, out_dir / "cycles_box.png", grid_label)
    plot_scaling(rows, out_dir / "cycles_scaling.png", grid_label)
    plot_multiplier(rows, out_dir / "cycles_multiplier.png", grid_label)

    print(f"\nAll plots written to: {out_dir}")


if __name__ == "__main__":
    main()
