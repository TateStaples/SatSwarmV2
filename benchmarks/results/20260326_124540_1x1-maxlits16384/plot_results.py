#!/usr/bin/env python3
"""
Visualizations for SatSwarm 1x1-maxlits16384 benchmark results.
Generates plots in the same directory as this script.

Usage:
  python3 benchmarks/results/20260326_040718_2x2-none/plot_results.py
"""

import pathlib
import csv
import collections
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

SCRIPT_DIR = pathlib.Path(__file__).parent
CSV_PATH = SCRIPT_DIR / "results.csv"
OUT_DIR = SCRIPT_DIR

# ── Load data ────────────────────────────────────────────────────────────────

rows = []
with open(CSV_PATH) as f:
    for row in csv.DictReader(f):
        row["cycles"] = int(row["cycles"]) if row["cycles"].isdigit() else 0
        row["vars"] = int(row["vars"])
        row["correct"] = int(row["correct"])
        row["timeout"] = int(row["timeout"])
        rows.append(row)

# Group by dataset
datasets = list(dict.fromkeys(r["dataset"] for r in rows))
by_dataset = {d: [r for r in rows if r["dataset"] == d] for d in datasets}

# Ordered by vars (sat then unsat interleaved)
sat_datasets   = [d for d in datasets if not d.startswith("uuf")]
unsat_datasets = [d for d in datasets if d.startswith("uuf")]

COLORS = {"SAT": "#4C72B0", "UNSAT": "#DD8452"}

# ── Plot 1: Accuracy by dataset ───────────────────────────────────────────────

fig, ax = plt.subplots(figsize=(12, 4))
x = np.arange(len(datasets))
accuracy = [100 * sum(r["correct"] for r in by_dataset[d]) / len(by_dataset[d])
            for d in datasets]
colors = [COLORS["SAT"] if not d.startswith("uuf") else COLORS["UNSAT"] for d in datasets]
bars = ax.bar(x, accuracy, color=colors, edgecolor="white", linewidth=0.5)
ax.set_xticks(x)
ax.set_xticklabels(datasets, rotation=45, ha="right", fontsize=8)
ax.set_ylabel("Accuracy (%)")
ax.set_title("Accuracy by Dataset — 1×1-maxlits16384")
ax.set_ylim(0, 110)
ax.axhline(100, color="gray", linestyle="--", linewidth=0.8, alpha=0.5)
for bar, acc in zip(bars, accuracy):
    ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 1,
            f"{acc:.0f}%", ha="center", va="bottom", fontsize=7)
ax.legend(handles=[
    mpatches.Patch(color=COLORS["SAT"],   label="SAT instances"),
    mpatches.Patch(color=COLORS["UNSAT"], label="UNSAT instances"),
])
fig.tight_layout()
fig.savefig(OUT_DIR / "accuracy_by_dataset.png", dpi=150)
plt.close(fig)
print("Saved: accuracy_by_dataset.png")

# ── Plot 2: Mean cycles by dataset (SAT vs UNSAT side by side) ───────────────

fig, ax = plt.subplots(figsize=(12, 4))
sat_means, unsat_means, var_labels = [], [], []
for s, u in zip(sat_datasets, unsat_datasets):
    sat_cycles  = [r["cycles"] for r in by_dataset[s] if r["cycles"] > 0]
    unsat_cycles = [r["cycles"] for r in by_dataset[u] if r["cycles"] > 0]
    sat_means.append(np.mean(sat_cycles) if sat_cycles else 0)
    unsat_means.append(np.mean(unsat_cycles) if unsat_cycles else 0)
    var_labels.append(str(by_dataset[s][0]["vars"]))

x = np.arange(len(var_labels))
w = 0.35
ax.bar(x - w/2, sat_means,   w, label="SAT",   color=COLORS["SAT"],   edgecolor="white")
ax.bar(x + w/2, unsat_means, w, label="UNSAT", color=COLORS["UNSAT"], edgecolor="white")
ax.set_xticks(x)
ax.set_xticklabels([f"{v} vars" for v in var_labels])
ax.set_ylabel("Mean Cycles")
ax.set_title("Mean Solve Cycles — SAT vs UNSAT — 1×1-maxlits16384")
ax.legend()
ax.yaxis.set_major_formatter(matplotlib.ticker.FuncFormatter(lambda v, _: f"{v/1000:.0f}k" if v >= 1000 else str(int(v))))
fig.tight_layout()
fig.savefig(OUT_DIR / "mean_cycles_by_vars.png", dpi=150)
plt.close(fig)
print("Saved: mean_cycles_by_vars.png")

# ── Plot 3: Cycle distribution box plots ─────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 5), sharey=False)
for ax, dset_list, label, color in [
    (axes[0], sat_datasets,   "SAT",   COLORS["SAT"]),
    (axes[1], unsat_datasets, "UNSAT", COLORS["UNSAT"]),
]:
    filtered = [(d, [r["cycles"] for r in by_dataset[d] if r["cycles"] > 0])
                for d in dset_list]
    filtered = [(d, c) for d, c in filtered if c]
    data   = [c for _, c in filtered]
    labels = [str(by_dataset[d][0]["vars"]) + "v" for d, _ in filtered]
    bp = ax.boxplot(data, tick_labels=labels, patch_artist=True,
                    medianprops=dict(color="black", linewidth=1.5))
    for patch in bp["boxes"]:
        patch.set_facecolor(color)
        patch.set_alpha(0.7)
    ax.set_xlabel("Problem size")
    ax.set_ylabel("Cycles")
    ax.set_title(f"{label} instances")
    ax.yaxis.set_major_formatter(matplotlib.ticker.FuncFormatter(
        lambda v, _: f"{v/1000:.0f}k" if v >= 1000 else str(int(v))))

fig.suptitle("Cycle Distribution by Problem Size — 1×1-maxlits16384", fontsize=12)
fig.tight_layout()
fig.savefig(OUT_DIR / "cycle_distribution.png", dpi=150)
plt.close(fig)
print("Saved: cycle_distribution.png")

# ── Plot 4: Scaling — median cycles vs vars ───────────────────────────────────

fig, ax = plt.subplots(figsize=(8, 5))
for dset_list, label, color, marker in [
    (sat_datasets,   "SAT",   COLORS["SAT"],   "o"),
    (unsat_datasets, "UNSAT", COLORS["UNSAT"], "s"),
]:
    xs, ys, yerr_lo, yerr_hi = [], [], [], []
    for d in dset_list:
        cycles = sorted(r["cycles"] for r in by_dataset[d] if r["cycles"] > 0)
        if not cycles:
            continue
        med = np.median(cycles)
        xs.append(by_dataset[d][0]["vars"])
        ys.append(med)
        yerr_lo.append(med - np.percentile(cycles, 25))
        yerr_hi.append(np.percentile(cycles, 75) - med)
    ax.errorbar(xs, ys, yerr=[yerr_lo, yerr_hi], fmt=f"{marker}-",
                color=color, label=f"{label} (median ± IQR)", capsize=4, linewidth=1.5)

ax.set_xlabel("Number of Variables")
ax.set_ylabel("Cycles (median)")
ax.set_title("Scaling: Solve Cycles vs Problem Size — 1×1-maxlits16384")
ax.legend()
ax.yaxis.set_major_formatter(matplotlib.ticker.FuncFormatter(
    lambda v, _: f"{v/1000:.0f}k" if v >= 1000 else str(int(v))))
fig.tight_layout()
fig.savefig(OUT_DIR / "scaling.png", dpi=150)
plt.close(fig)
print("Saved: scaling.png")

# ── Plot 5: Correct vs incorrect breakdown ────────────────────────────────────

fig, ax = plt.subplots(figsize=(12, 4))
x = np.arange(len(datasets))
correct   = [sum(r["correct"] for r in by_dataset[d]) for d in datasets]
incorrect = [len(by_dataset[d]) - c for d, c in zip(datasets, correct)]
ax.bar(x, correct,   label="Correct",   color="#2ca02c", edgecolor="white")
ax.bar(x, incorrect, bottom=correct, label="Wrong", color="#d62728", edgecolor="white")
ax.set_xticks(x)
ax.set_xticklabels(datasets, rotation=45, ha="right", fontsize=8)
ax.set_ylabel("Instances")
ax.set_title("Correct vs Wrong Answers by Dataset — 1×1-maxlits16384")
ax.legend()
fig.tight_layout()
fig.savefig(OUT_DIR / "correct_vs_wrong.png", dpi=150)
plt.close(fig)
print("Saved: correct_vs_wrong.png")

print("\nAll plots saved to:", OUT_DIR)
