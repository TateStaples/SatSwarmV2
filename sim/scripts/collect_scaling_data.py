#!/usr/bin/env python3
"""
Collect SAT solver scaling data and build order-statistics projections.

This script is designed to run on AWS FPGA hosts (or any Linux host with the
sim binaries available). It executes benchmark CNFs across multiple hardware
configurations, stores raw measurements, fits runtime distributions, and
projects speedup to larger core counts.

Outputs are written to logs/benchmark_results/scaling_<timestamp>/:
- raw_runs.csv
- aggregate_by_config.csv
- fit_summary.json
- scaling_projection.csv
- summary.txt
"""

from __future__ import annotations

import argparse
import csv
import fnmatch
import json
import math
import os
import random
import re
import statistics
import subprocess
import time
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path
from typing import Callable, Dict, Iterable, List, Optional, Tuple


PASS_MARKER = "*** TEST PASSED ***"
CYCLES_RE = re.compile(r"Cycles:\s*([0-9]+)")


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
    command: str


@dataclass
class DistFit:
    name: str
    params: Dict[str, float]
    loglik: float
    aic: float


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Collect SAT scaling data and project speedup")
    parser.add_argument(
        "--sim-dir",
        default="sim",
        help="Simulation directory containing tests/ and obj_dir_* binaries",
    )
    parser.add_argument(
        "--suite-dir",
        default="tests/generated_instances",
        help="CNF suite directory, relative to sim-dir unless absolute",
    )
    parser.add_argument(
        "--benchmark-profile",
        choices=["verisat_full", "generated_instances", "custom_dir"],
        default="verisat_full",
        help="Benchmark source profile",
    )
    parser.add_argument(
        "--max-tests",
        type=int,
        default=0,
        help="Max files to sample (0 means all discovered files)",
    )
    parser.add_argument("--runs-per-test", type=int, default=10, help="Runs per benchmark per config")
    parser.add_argument("--timeout-sec", type=int, default=180, help="Timeout per run")
    parser.add_argument("--max-cycles", type=int, default=5_000_000, help="MAXCYCLES plusarg")
    parser.add_argument(
        "--configs",
        default="1x1,2x2",
        help="Comma-separated list from {1x1,2x2,3x3}",
    )
    parser.add_argument(
        "--projection-cores",
        default="1,2,4,8,16,32,64,128,256,512",
        help="Comma-separated core counts for projection",
    )
    parser.add_argument(
        "--topology",
        choices=["all_to_all", "ring", "tree", "mesh"],
        default="mesh",
        help="Communication overhead model topology",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=12345,
        help="Seed for benchmark sampling and Monte Carlo projection",
    )
    parser.add_argument(
        "--extra-plusargs",
        default="",
        help="Extra plusargs appended to each run, e.g. '+DEBUG=0'",
    )
    parser.add_argument(
        "--output-root",
        default="logs/benchmark_results",
        help="Output root directory relative to sim-dir unless absolute",
    )
    parser.add_argument(
        "--min-baseline-samples",
        type=int,
        default=20,
        help="Minimum successful 1x1 samples required before distribution fitting",
    )
    return parser.parse_args()


def expected_from_name(name: str) -> Optional[str]:
    lname = name.lower()
    if "unsat" in lname or lname.startswith("uuf"):
        return "UNSAT"
    if "sat" in lname or lname.startswith("uf"):
        return "SAT"
    return None


def expected_from_path(path: Path) -> Optional[str]:
    expected = expected_from_name(path.name)
    if expected is not None:
        return expected

    parts = [p.lower() for p in path.parts]
    if "unsat" in parts:
        return "UNSAT"
    if "sat" in parts:
        return "SAT"
    return None


def discover_verisat_full_tests(sim_dir: Path) -> Tuple[List[Path], Dict[str, int]]:
    tests_root = (sim_dir / "tests").resolve()
    if not tests_root.exists():
        return [], {}

    all_candidates = [
        p
        for p in tests_root.rglob("*")
        if p.is_file() and p.suffix.lower() in {".cnf", ".dimacs"}
    ]

    family_patterns = {
        "UF20": ["uf20-*.cnf", "uf20*.dimacs"],
        "UF50": ["uf50-*.cnf"],
        "UF75": ["uf75-*.cnf"],
        "UF100": ["uf100-*.cnf"],
        "UF125": ["uf125-*.cnf"],
        "UF150": ["uf150-*.cnf"],
        "UUF50": ["uuf50-*.cnf"],
        "UUF75": ["uuf75-*.cnf"],
        "UUF100": ["uuf100-*.cnf"],
        "UUF125": ["uuf125-*.cnf"],
        "UUF150": ["uuf150-*.cnf"],
        "QG": ["qg*.cnf", "qg*.dimacs"],
        "BMC": ["bmc*.cnf", "bmc*.dimacs"],
        "HOLE": ["hole*.cnf", "hole*.dimacs"],
        "II": ["ii*.cnf", "ii*.dimacs", "*ii*.cnf", "*ii*.dimacs"],
        "LOGISTICS": ["logistics*.cnf", "logistics*.dimacs", "*logistics*.cnf", "*logistics*.dimacs"],
        "PLANNING": ["planning*.cnf", "planning*.dimacs", "*planning*.cnf", "*planning*.dimacs"],
        "BATTLESHIP": ["battleship*.cnf", "battleship*.dimacs", "*battleship*.cnf", "*battleship*.dimacs"],
    }

    selected: Dict[Path, str] = {}
    counts: Dict[str, int] = {k: 0 for k in family_patterns}

    for family, patterns in family_patterns.items():
        for p in all_candidates:
            name = p.name.lower()
            if any(fnmatch.fnmatch(name, pat.lower()) for pat in patterns):
                selected[p] = family

    # Prefer one file per benchmark filename to avoid counting mirrored copies.
    # Priority order favors canonical SATLIB and SAT_test_cases paths.
    priority_tokens = [
        f"{os.sep}satlib{os.sep}",
        f"{os.sep}sat_test_cases{os.sep}",
        f"{os.sep}sat_accel{os.sep}",
    ]
    by_name: Dict[str, Path] = {}
    for p in sorted(selected.keys()):
        key = p.name.lower()
        if key not in by_name:
            by_name[key] = p
            continue
        cur = str(by_name[key]).lower()
        nxt = str(p).lower()

        def prio(s: str) -> int:
            for idx, tok in enumerate(priority_tokens):
                if tok in s:
                    return idx
            return len(priority_tokens)

        if prio(nxt) < prio(cur):
            by_name[key] = p

    selected = {p: selected[p] for p in by_name.values()}

    for family in selected.values():
        counts[family] += 1

    return sorted(selected.keys()), counts


def discover_custom_tests(sim_dir: Path, suite_dir: Path) -> List[Path]:
    if not suite_dir.exists():
        return []
    return sorted(
        p for p in suite_dir.rglob("*") if p.is_file() and p.suffix.lower() in {".cnf", ".dimacs"}
    )


def find_binary(sim_dir: Path, config: str) -> Optional[Path]:
    mapping = {
        "1x1": sim_dir / "obj_dir_1x1" / "Vtb_satswarmv2",
        "2x2": sim_dir / "obj_dir_2x2" / "Vtb_satswarmv2",
        "3x3": sim_dir / "obj_dir_3x3" / "Vtb_satswarmv2",
    }
    path = mapping.get(config)
    if path is None or not path.exists():
        return None
    return path


def config_to_cores(config: str) -> int:
    xy = config.split("x")
    if len(xy) != 2:
        raise ValueError(f"Invalid config: {config}")
    return int(xy[0]) * int(xy[1])


def growth_fn(topology: str) -> Callable[[int], float]:
    if topology == "all_to_all":
        return lambda n: float(n * n)
    if topology == "ring":
        return lambda n: float(n)
    if topology == "tree":
        return lambda n: float(n * math.log2(max(2, n)))
    if topology == "mesh":
        return lambda n: float(math.sqrt(n))
    raise ValueError(f"Unsupported topology {topology}")


def run_one(
    bin_path: Path,
    cnf_file: Path,
    expected: str,
    timeout_sec: int,
    max_cycles: int,
    extra_plusargs: str,
) -> RunRecord:
    cmd = [
        str(bin_path),
        f"+CNF={str(cnf_file.resolve())}",
        f"+EXPECT={expected}",
        f"+MAXCYCLES={max_cycles}",
    ]
    if extra_plusargs.strip():
        cmd.extend(extra_plusargs.strip().split())

    t0 = time.perf_counter()
    timed_out = False
    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout_sec,
            cwd=str(bin_path.parent.parent),
        )
        out = (proc.stdout or "") + "\n" + (proc.stderr or "")
        rc = proc.returncode
    except subprocess.TimeoutExpired as exc:
        out = (exc.stdout or "") + "\n" + (exc.stderr or "")
        rc = 124
        timed_out = True
    wall = time.perf_counter() - t0

    cycles = 0
    m = CYCLES_RE.search(out)
    if m:
        cycles = int(m.group(1))

    if timed_out:
        result = "TIMEOUT"
    elif PASS_MARKER in out:
        result = "PASS"
    else:
        result = f"FAIL(rc={rc})"

    return RunRecord(
        benchmark=cnf_file.name,
        run_idx=-1,
        config="",
        cores=0,
        expected=expected,
        result=result,
        cycles=cycles,
        wall_sec=wall,
        timed_out=timed_out,
        command=" ".join(cmd),
    )


def write_csv(path: Path, rows: Iterable[Dict[str, object]], fieldnames: List[str]) -> None:
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow(row)


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

    # Grid search x0 in [0, dmin*(1-eps)] for stable MLE.
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
        # Fall back to a tiny shift from minimum.
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

    # Shape k grid; scale lambda(k) has closed-form MLE for fixed k.
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
        # Conservative fallback.
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
        # Python uses alpha=scale, beta=shape.
        return rng.weibullvariate(p["scale"], p["shape"])
    raise ValueError(f"Unknown fit {fit.name}")


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


def main() -> int:
    args = parse_args()
    rng = random.Random(args.seed)

    sim_dir = Path(args.sim_dir).resolve()
    suite_dir = Path(args.suite_dir)
    if not suite_dir.is_absolute():
        suite_dir = sim_dir / suite_dir
    suite_dir = suite_dir.resolve()

    output_root = Path(args.output_root)
    if not output_root.is_absolute():
        output_root = (sim_dir / output_root).resolve()

    timestamp = datetime.now(UTC).strftime("%Y%m%d_%H%M%S")
    out_dir = output_root / f"scaling_{timestamp}"
    out_dir.mkdir(parents=True, exist_ok=True)

    configs = [c.strip() for c in args.configs.split(",") if c.strip()]
    projection_cores = [int(x.strip()) for x in args.projection_cores.split(",") if x.strip()]

    # Resolve binaries.
    bins: Dict[str, Path] = {}
    for cfg in configs:
        b = find_binary(sim_dir, cfg)
        if b is None:
            print(f"[WARN] Missing binary for config {cfg}, skipping")
            continue
        bins[cfg] = b

    if "1x1" not in bins:
        print("[ERROR] 1x1 binary is required for baseline fitting")
        return 2

    if not suite_dir.exists():
        print(f"[ERROR] Suite directory not found: {suite_dir}")
        return 2

    if args.benchmark_profile == "verisat_full":
        discovered, family_counts = discover_verisat_full_tests(sim_dir)
        for fam in sorted(family_counts.keys()):
            print(f"[INFO] VeriSAT family {fam}: {family_counts[fam]} files discovered")
    elif args.benchmark_profile == "generated_instances":
        discovered = sorted(p for p in suite_dir.glob("*.cnf") if p.is_file())
    else:
        discovered = discover_custom_tests(sim_dir, suite_dir)

    if not discovered:
        print("[ERROR] No benchmark files discovered for selected profile")
        return 2

    rng.shuffle(discovered)
    if args.max_tests > 0:
        selected = discovered[: min(args.max_tests, len(discovered))]
    else:
        selected = discovered

    print(f"[INFO] sim_dir: {sim_dir}")
    print(f"[INFO] benchmark_profile: {args.benchmark_profile}")
    print(f"[INFO] suite_dir: {suite_dir}")
    print(f"[INFO] selected tests: {len(selected)} / {len(discovered)}")
    print(f"[INFO] configs: {', '.join(sorted(bins.keys()))}")
    print(f"[INFO] runs_per_test: {args.runs_per_test}")

    records: List[RunRecord] = []

    for idx, cnf in enumerate(sorted(selected), start=1):
        expected = expected_from_path(cnf)
        if expected is None:
            print(f"[WARN] Could not infer expected SAT/UNSAT for {cnf.name}, skipping")
            continue

        print(f"[INFO] [{idx}/{len(selected)}] {cnf.name}")
        for cfg, bin_path in bins.items():
            cores = config_to_cores(cfg)
            rec = run_one(
                bin_path=bin_path,
                cnf_file=cnf,
                expected=expected,
                timeout_sec=args.timeout_sec,
                max_cycles=args.max_cycles,
                extra_plusargs=args.extra_plusargs,
            )
            rec.config = cfg
            rec.cores = cores
            rec.run_idx = 1
            records.append(rec)

    raw_csv = out_dir / "raw_runs.csv"
    write_csv(
        raw_csv,
        (
            {
                "benchmark": r.benchmark,
                "run_idx": r.run_idx,
                "config": r.config,
                "cores": r.cores,
                "expected": r.expected,
                "result": r.result,
                "cycles": r.cycles,
                "wall_sec": f"{r.wall_sec:.6f}",
                "timed_out": int(r.timed_out),
                "command": r.command,
            }
            for r in records
        ),
        [
            "benchmark",
            "run_idx",
            "config",
            "cores",
            "expected",
            "result",
            "cycles",
            "wall_sec",
            "timed_out",
            "command",
        ],
    )

    # Aggregate by config.
    by_cfg: Dict[str, List[RunRecord]] = {}
    for r in records:
        by_cfg.setdefault(r.config, []).append(r)

    agg_rows = []
    mean_cycles_by_cfg: Dict[str, float] = {}
    success_rate_by_cfg: Dict[str, float] = {}

    for cfg in sorted(by_cfg.keys()):
        rows = by_cfg[cfg]
        success = [r for r in rows if r.result == "PASS" and r.cycles > 0]
        success_rate = len(success) / len(rows) if rows else 0.0
        cycles = [float(r.cycles) for r in success]
        walls = [r.wall_sec for r in success]

        mean_cycles = statistics.fmean(cycles) if cycles else float("nan")
        median_cycles = statistics.median(cycles) if cycles else float("nan")
        mean_wall = statistics.fmean(walls) if walls else float("nan")

        mean_cycles_by_cfg[cfg] = mean_cycles
        success_rate_by_cfg[cfg] = success_rate

        agg_rows.append(
            {
                "config": cfg,
                "cores": config_to_cores(cfg),
                "runs_total": len(rows),
                "runs_pass": len(success),
                "success_rate": f"{success_rate:.6f}",
                "mean_cycles": f"{mean_cycles:.3f}" if cycles else "",
                "median_cycles": f"{median_cycles:.3f}" if cycles else "",
                "mean_wall_sec": f"{mean_wall:.6f}" if walls else "",
            }
        )

    agg_csv = out_dir / "aggregate_by_config.csv"
    write_csv(
        agg_csv,
        agg_rows,
        [
            "config",
            "cores",
            "runs_total",
            "runs_pass",
            "success_rate",
            "mean_cycles",
            "median_cycles",
            "mean_wall_sec",
        ],
    )

    baseline = [
        float(r.cycles)
        for r in records
        if r.config == "1x1" and r.result == "PASS" and r.cycles > 0
    ]

    if len(baseline) < args.min_baseline_samples:
        print(
            "[ERROR] Not enough successful 1x1 samples for distribution fitting "
            f"({len(baseline)} < {args.min_baseline_samples})"
        )
        return 3

    fits = [
        exp_fit(baseline),
        shifted_exp_fit(baseline),
        lognormal_fit(baseline),
        weibull_fit(baseline),
    ]
    fits.sort(key=lambda f: f.aic)
    best_fit = fits[0]

    # Estimate communication overhead alpha from measured multi-core points.
    growth = growth_fn(args.topology)
    base_mean = mean_cycles_by_cfg.get("1x1", float("nan"))

    # Monte Carlo for independent portfolio expected speedup at measured n.
    mc_rng = random.Random(args.seed + 101)

    alpha_estimates: List[float] = []
    measured_speedups: Dict[int, float] = {}

    for cfg in sorted(mean_cycles_by_cfg.keys()):
        if cfg == "1x1":
            continue
        mean_c = mean_cycles_by_cfg[cfg]
        if not (math.isfinite(base_mean) and math.isfinite(mean_c) and mean_c > 0):
            continue

        n = config_to_cores(cfg)
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

    # Projection to requested core counts.
    proj_rows = []
    mc_rng = random.Random(args.seed + 202)

    for n in sorted(set(projection_cores)):
        indep_en = expected_min_mc(best_fit, n=n, draws=5000, rng=mc_rng)
        indep_speedup = base_mean / indep_en

        # Beta defaults to 1.0 (no explicit clause-sharing uplift in this script).
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
        [
            "cores",
            "independent_speedup",
            "beta",
            "sharing_speedup",
            "overhead_fraction",
            "projected_actual_speedup",
        ],
    )

    fit_json = out_dir / "fit_summary.json"
    fit_payload = {
        "timestamp_utc": timestamp,
        "args": vars(args),
        "num_records": len(records),
        "num_baseline_samples": len(baseline),
        "baseline_mean_cycles": base_mean,
        "fits_ranked_by_aic": [
            {
                "name": f.name,
                "params": f.params,
                "loglik": f.loglik,
                "aic": f.aic,
            }
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
        "measured_speedups": measured_speedups,
        "success_rate_by_cfg": success_rate_by_cfg,
    }
    with fit_json.open("w") as f:
        json.dump(fit_payload, f, indent=2)

    summary_txt = out_dir / "summary.txt"
    with summary_txt.open("w") as f:
        f.write("SAT Scaling Data Collection Summary\n")
        f.write("==================================\n")
        f.write(f"Output directory: {out_dir}\n")
        f.write(f"Records: {len(records)}\n")
        f.write(f"Baseline samples (1x1 PASS): {len(baseline)}\n")
        f.write(f"Best fit: {best_fit.name} params={best_fit.params}\n")
        f.write(f"Topology: {args.topology}\n")
        f.write(f"Estimated alpha: {alpha:.8f}\n")
        f.write("\nMeasured speedups:\n")
        for n in sorted(measured_speedups):
            f.write(f"  n={n}: {measured_speedups[n]:.4f}x\n")
        f.write("\nProjection files:\n")
        f.write(f"  - {proj_csv}\n")
        f.write(f"  - {fit_json}\n")

    print(f"[OK] Raw runs: {raw_csv}")
    print(f"[OK] Aggregates: {agg_csv}")
    print(f"[OK] Fit summary: {fit_json}")
    print(f"[OK] Projection: {proj_csv}")
    print(f"[OK] Summary: {summary_txt}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
