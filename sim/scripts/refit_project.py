#!/usr/bin/env python3
"""
Fit runtime distributions and project scaling speedup from an existing raw_runs.csv.

This script re-runs the distribution-fitting and Monte Carlo projection steps
from collect_scaling_data.py without executing any benchmarks.  Use it when
you already have a raw_runs.csv (from either the simulation pipeline or
convert_fpga_csv.py) and want to regenerate the model outputs.

Outputs (written to --output-dir):
  aggregate_by_config.csv
  fit_summary.json
  scaling_projection.csv
  summary.txt

Usage:
  python3 refit_project.py \\
    --input logs/raw_runs.csv \\
    --output-dir logs/refit_out \\
    --projection-cores 1,2,4,8,16,32,64,128,256,512 \\
    --topology mesh \\
    --min-baseline-samples 10
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import random
import statistics
import sys
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path
from typing import Callable, Dict, List, Optional, Tuple


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class RunRecord:
    benchmark: str
    run_idx: int
    config: str
    cores: int
    expected: str
    result: str
    cycles: int
    wall_sec: float
    timed_out: bool


@dataclass
class DistFit:
    name: str
    params: Dict[str, float]
    loglik: float
    aic: float


# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Fit runtime distributions and project scaling from raw_runs.csv",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Refit from a simulation-generated raw_runs.csv:
  python3 refit_project.py \\
    --input sim/logs/benchmark_results/scaling_20260318_163435/raw_runs.csv \\
    --output-dir logs/refit_sim

  # Refit from an FPGA hardware raw_runs.csv:
  python3 refit_project.py \\
    --input logs/fpga_scaling_results/scaling_20260319_120000/raw_runs.csv \\
    --output-dir logs/refit_fpga \\
    --min-baseline-samples 5
""",
    )
    parser.add_argument(
        "--input",
        required=True,
        metavar="PATH",
        help="Path to raw_runs.csv",
    )
    parser.add_argument(
        "--output-dir",
        required=True,
        metavar="PATH",
        help="Directory to write output files",
    )
    parser.add_argument(
        "--projection-cores",
        default="1,2,4,8,16,32,64,128,256,512",
        metavar="CSV",
        help="Comma-separated core counts for projection (default: 1,2,4,8,16,32,64,128,256,512)",
    )
    parser.add_argument(
        "--topology",
        choices=["all_to_all", "ring", "tree", "mesh"],
        default="mesh",
        help="Communication overhead model topology (default: mesh)",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=12345,
        help="Random seed for Monte Carlo projection (default: 12345)",
    )
    parser.add_argument(
        "--min-baseline-samples",
        type=int,
        default=10,
        help="Minimum successful 1x1 samples required for fitting (default: 10)",
    )
    parser.add_argument(
        "--baseline-config",
        default="1x1",
        metavar="CONFIG",
        help="Config name to use as the single-core baseline (default: 1x1)",
    )
    parser.add_argument(
        "--mc-draws",
        type=int,
        default=5000,
        help="Monte Carlo draws per core count for projection (default: 5000)",
    )
    return parser.parse_args()


# ---------------------------------------------------------------------------
# CSV reading
# ---------------------------------------------------------------------------

def read_raw_runs(path: Path) -> List[RunRecord]:
    records: List[RunRecord] = []
    with path.open(newline="") as f:
        reader = csv.DictReader(f)
        for lineno, row in enumerate(reader, start=2):
            try:
                cycles = int(row.get("cycles", 0) or 0)
                wall_sec_str = row.get("wall_sec", "0") or "0"
                wall_sec = float(wall_sec_str) if wall_sec_str else 0.0
                timed_out_raw = row.get("timed_out", "0") or "0"
                timed_out = bool(int(timed_out_raw))
                cores_str = row.get("cores", "1") or "1"
                cores = int(cores_str)
            except (ValueError, TypeError) as exc:
                print(
                    f"[WARN] {path}:{lineno}: parse error ({exc}), skipping row",
                    file=sys.stderr,
                )
                continue

            records.append(
                RunRecord(
                    benchmark=row.get("benchmark", ""),
                    run_idx=int(row.get("run_idx", 1) or 1),
                    config=row.get("config", ""),
                    cores=cores,
                    expected=row.get("expected", ""),
                    result=row.get("result", ""),
                    cycles=cycles,
                    wall_sec=wall_sec,
                    timed_out=timed_out,
                )
            )
    return records


# ---------------------------------------------------------------------------
# Distribution fitting (identical to collect_scaling_data.py)
# ---------------------------------------------------------------------------

def exp_fit(data: List[float]) -> DistFit:
    mean = statistics.fmean(data)
    lam = 1.0 / mean
    ll = len(data) * math.log(lam) - lam * sum(data)
    aic = 2 * 1 - 2 * ll
    return DistFit("exponential", {"lambda": lam}, ll, aic)


def shifted_exp_fit(data: List[float]) -> DistFit:
    n = len(data)
    dmin = min(data)
    best: Optional[DistFit] = None

    for frac in [i / 100.0 for i in range(0, 95)]:
        x0 = dmin * frac
        shifted = [x - x0 for x in data]
        if any(s <= 0 for s in shifted):
            continue
        lam = 1.0 / statistics.fmean(shifted)
        ll = n * math.log(lam) - lam * sum(shifted)
        aic = 2 * 2 - 2 * ll
        fit = DistFit("shifted_exponential", {"x0": x0, "lambda": lam}, ll, aic)
        if best is None or fit.aic < best.aic:
            best = fit

    if best is None:
        x0 = max(0.0, dmin * 0.5)
        shifted = [max(1e-9, x - x0) for x in data]
        lam = 1.0 / statistics.fmean(shifted)
        ll = n * math.log(lam) - lam * sum(shifted)
        aic = 2 * 2 - 2 * ll
        best = DistFit("shifted_exponential", {"x0": x0, "lambda": lam}, ll, aic)

    return best


def lognormal_fit(data: List[float]) -> DistFit:
    logs = [math.log(x) for x in data]
    mu = statistics.fmean(logs)
    var = statistics.pvariance(logs)
    sigma = max(math.sqrt(var), 1e-12)

    ll = 0.0
    for x in data:
        z = (math.log(x) - mu) / sigma
        ll += -math.log(x * sigma * math.sqrt(2 * math.pi)) - 0.5 * z * z

    aic = 2 * 2 - 2 * ll
    return DistFit("lognormal", {"mu": mu, "sigma": sigma}, ll, aic)


def weibull_fit(data: List[float]) -> DistFit:
    n = len(data)
    logs = [math.log(x) for x in data]
    best: Optional[DistFit] = None

    for k in [0.3 + i * 0.05 for i in range(95)]:
        yk = [x ** k for x in data]
        lam = (sum(yk) / n) ** (1.0 / k)
        if lam <= 0:
            continue
        ll = n * math.log(k) - n * k * math.log(lam) + (k - 1.0) * sum(logs)
        ll -= sum((x / lam) ** k for x in data)
        aic = 2 * 2 - 2 * ll
        fit = DistFit("weibull", {"shape": k, "scale": lam}, ll, aic)
        if best is None or fit.aic < best.aic:
            best = fit

    if best is None:
        mean = statistics.fmean(data)
        best = DistFit("weibull", {"shape": 1.0, "scale": mean}, float("-inf"), float("inf"))
    return best


def sample_from_fit(rng: random.Random, fit: DistFit) -> float:
    p = fit.params
    if fit.name == "exponential":
        return rng.expovariate(p["lambda"])
    if fit.name == "shifted_exponential":
        return p["x0"] + rng.expovariate(p["lambda"])
    if fit.name == "lognormal":
        return rng.lognormvariate(p["mu"], p["sigma"])
    if fit.name == "weibull":
        return rng.weibullvariate(p["scale"], p["shape"])
    raise ValueError(f"Unknown fit: {fit.name}")


def expected_min_mc(fit: DistFit, n: int, draws: int, rng: random.Random) -> float:
    mins = []
    for _ in range(draws):
        m = float("inf")
        for _ in range(n):
            x = sample_from_fit(rng, fit)
            if x < m:
                m = x
        mins.append(m)
    return statistics.fmean(mins)


# ---------------------------------------------------------------------------
# Topology overhead
# ---------------------------------------------------------------------------

def growth_fn(topology: str) -> Callable[[int], float]:
    if topology == "all_to_all":
        return lambda n: float(n * n)
    if topology == "ring":
        return lambda n: float(n)
    if topology == "tree":
        return lambda n: float(n * math.log2(max(2, n)))
    if topology == "mesh":
        return lambda n: float(math.sqrt(n))
    raise ValueError(f"Unsupported topology: {topology}")


# ---------------------------------------------------------------------------
# CSV writing
# ---------------------------------------------------------------------------

def write_csv(path: Path, rows: List[Dict], fieldnames: List[str]) -> None:
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    args = parse_args()

    in_path = Path(args.input)
    if not in_path.exists():
        print(f"[ERROR] Input file not found: {in_path}", file=sys.stderr)
        return 2

    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    projection_cores = [int(x.strip()) for x in args.projection_cores.split(",") if x.strip()]

    print(f"[INFO] Reading {in_path}")
    records = read_raw_runs(in_path)
    if not records:
        print("[ERROR] No records found in input CSV.", file=sys.stderr)
        return 2
    print(f"[INFO] Loaded {len(records)} records")

    timestamp = datetime.now(UTC).strftime("%Y%m%d_%H%M%S")

    # --- Aggregate by config ---
    by_cfg: Dict[str, List[RunRecord]] = {}
    for r in records:
        by_cfg.setdefault(r.config, []).append(r)

    agg_rows = []
    mean_cycles_by_cfg: Dict[str, float] = {}
    success_rate_by_cfg: Dict[str, float] = {}

    for cfg in sorted(by_cfg.keys()):
        rows = by_cfg[cfg]
        # A row is "successful" if result matches expected and cycles > 0.
        success = [
            r for r in rows
            if r.result.upper() in {"PASS", "SAT", "UNSAT"}
            and r.result.upper() == r.expected.upper()
            and r.cycles > 0
        ]
        # Also accept rows where result is SAT or UNSAT (hardware returns these directly).
        if not success:
            success = [r for r in rows if not r.timed_out and r.cycles > 0]

        success_rate = len(success) / len(rows) if rows else 0.0
        cycles_list = [float(r.cycles) for r in success]
        walls = [r.wall_sec for r in success]

        mean_cycles = statistics.fmean(cycles_list) if cycles_list else float("nan")
        median_cycles = statistics.median(cycles_list) if cycles_list else float("nan")
        mean_wall = statistics.fmean(walls) if walls else float("nan")

        mean_cycles_by_cfg[cfg] = mean_cycles
        success_rate_by_cfg[cfg] = success_rate

        cores = success[0].cores if success else rows[0].cores if rows else 0
        agg_rows.append(
            {
                "config": cfg,
                "cores": cores,
                "runs_total": len(rows),
                "runs_pass": len(success),
                "success_rate": f"{success_rate:.6f}",
                "mean_cycles": f"{mean_cycles:.3f}" if cycles_list else "",
                "median_cycles": f"{median_cycles:.3f}" if cycles_list else "",
                "mean_wall_sec": f"{mean_wall:.6f}" if walls else "",
            }
        )

    agg_csv = out_dir / "aggregate_by_config.csv"
    write_csv(
        agg_csv,
        agg_rows,
        ["config", "cores", "runs_total", "runs_pass", "success_rate",
         "mean_cycles", "median_cycles", "mean_wall_sec"],
    )
    print(f"[OK] Aggregates: {agg_csv}")

    # --- Baseline distribution fitting ---
    baseline_cfg = args.baseline_config
    baseline_rows = by_cfg.get(baseline_cfg, [])

    # Accept SAT/UNSAT directly from hardware; also accept PASS from simulation.
    baseline_success = [
        r for r in baseline_rows
        if not r.timed_out and r.cycles > 0
        and r.result.upper() not in {"FAIL", "ERROR", "TIMEOUT"}
        and not r.result.upper().startswith("FAIL(")
    ]
    baseline = [float(r.cycles) for r in baseline_success]

    if len(baseline) < args.min_baseline_samples:
        print(
            f"[ERROR] Not enough successful {baseline_cfg} samples for fitting "
            f"({len(baseline)} < {args.min_baseline_samples}). "
            f"Lower --min-baseline-samples or collect more data.",
            file=sys.stderr,
        )
        return 3

    print(f"[INFO] Fitting distributions from {len(baseline)} baseline samples (config={baseline_cfg})")

    fits = [
        exp_fit(baseline),
        shifted_exp_fit(baseline),
        lognormal_fit(baseline),
        weibull_fit(baseline),
    ]
    fits.sort(key=lambda f: f.aic)
    best_fit = fits[0]
    print(f"[INFO] Best fit: {best_fit.name}  AIC={best_fit.aic:.2f}  params={best_fit.params}")

    base_mean = mean_cycles_by_cfg.get(baseline_cfg, float("nan"))
    growth = growth_fn(args.topology)

    # --- Estimate alpha from measured multi-core points ---
    mc_rng = random.Random(args.seed + 101)
    alpha_estimates: List[float] = []
    measured_speedups: Dict[int, float] = {}

    for cfg in sorted(mean_cycles_by_cfg.keys()):
        if cfg == baseline_cfg:
            continue
        mean_c = mean_cycles_by_cfg[cfg]
        if not (math.isfinite(base_mean) and math.isfinite(mean_c) and mean_c > 0):
            continue

        n = by_cfg[cfg][0].cores if by_cfg[cfg] else 1
        measured = base_mean / mean_c
        measured_speedups[n] = measured

        indep_en = expected_min_mc(best_fit, n=n, draws=2000, rng=mc_rng)
        indep_speedup = base_mean / indep_en

        if measured > 0 and indep_speedup > measured:
            f_n = indep_speedup / measured - 1.0
            g_n = growth(n)
            if g_n > 0 and f_n >= 0:
                alpha_estimates.append(f_n / g_n)

    alpha = statistics.fmean(alpha_estimates) if alpha_estimates else 0.0

    # --- Project to requested core counts ---
    proj_rows = []
    proj_rng = random.Random(args.seed + 202)

    for n in sorted(set(projection_cores)):
        indep_en = expected_min_mc(best_fit, n=n, draws=args.mc_draws, rng=proj_rng)
        indep_speedup = base_mean / indep_en
        beta = 1.0
        sharing_speedup = beta * indep_speedup
        overhead = alpha * growth(n)
        actual_speedup = sharing_speedup / (1.0 + overhead)

        proj_rows.append(
            {
                "cores": n,
                "independent_speedup": f"{indep_speedup:.6f}",
                "beta": f"{beta:.6f}",
                "sharing_speedup": f"{sharing_speedup:.6f}",
                "overhead_fraction": f"{overhead:.6f}",
                "projected_actual_speedup": f"{actual_speedup:.6f}",
            }
        )

    proj_csv = out_dir / "scaling_projection.csv"
    write_csv(
        proj_csv,
        proj_rows,
        ["cores", "independent_speedup", "beta", "sharing_speedup",
         "overhead_fraction", "projected_actual_speedup"],
    )
    print(f"[OK] Projection: {proj_csv}")

    # --- Fit summary JSON ---
    fit_json = out_dir / "fit_summary.json"
    fit_payload = {
        "timestamp_utc": timestamp,
        "input": str(in_path),
        "num_records": len(records),
        "baseline_config": baseline_cfg,
        "num_baseline_samples": len(baseline),
        "baseline_mean_cycles": base_mean,
        "fits_ranked_by_aic": [
            {"name": f.name, "params": f.params, "loglik": f.loglik, "aic": f.aic}
            for f in fits
        ],
        "best_fit": {
            "name": best_fit.name,
            "params": best_fit.params,
            "loglik": best_fit.loglik,
            "aic": best_fit.aic,
        },
        "topology": args.topology,
        "alpha_estimate": alpha,
        "alpha_estimates": alpha_estimates,
        "measured_speedups": {str(k): v for k, v in measured_speedups.items()},
        "success_rate_by_cfg": success_rate_by_cfg,
    }
    with fit_json.open("w") as f:
        json.dump(fit_payload, f, indent=2)
    print(f"[OK] Fit summary: {fit_json}")

    # --- Summary text ---
    summary_txt = out_dir / "summary.txt"
    with summary_txt.open("w") as f:
        f.write("SAT Scaling Refit/Projection Summary\n")
        f.write("=====================================\n")
        f.write(f"Input:            {in_path}\n")
        f.write(f"Output directory: {out_dir}\n")
        f.write(f"Records:          {len(records)}\n")
        f.write(f"Baseline config:  {baseline_cfg}\n")
        f.write(f"Baseline samples: {len(baseline)}\n")
        f.write(f"Best fit:         {best_fit.name}  params={best_fit.params}\n")
        f.write(f"Topology:         {args.topology}\n")
        f.write(f"Estimated alpha:  {alpha:.8f}\n")
        f.write("\nMeasured speedups:\n")
        for n in sorted(measured_speedups):
            f.write(f"  n={n}: {measured_speedups[n]:.4f}x\n")
        f.write("\nProjection:\n")
        for row in proj_rows:
            f.write(
                f"  n={row['cores']:>5}: indep={row['independent_speedup']}  "
                f"actual={row['projected_actual_speedup']}\n"
            )
        f.write(f"\nProjection CSV: {proj_csv}\n")
        f.write(f"Fit JSON:       {fit_json}\n")
    print(f"[OK] Summary: {summary_txt}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
