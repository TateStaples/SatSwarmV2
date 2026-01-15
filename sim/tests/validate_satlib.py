from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path
from typing import Iterable, List, Tuple

from pysat.solvers import Solver


def gather_instances(root: Path, pattern: str | None, limit: int | None) -> List[Tuple[Path, bool]]:
    labeled: List[Tuple[Path, bool]] = []
    for subdir, expected in (("sat", True), ("unsat", False)):
        folder = root / subdir
        if not folder.is_dir():
            continue
        for path in sorted(folder.glob("*.cnf")):
            if pattern and pattern not in path.name:
                continue
            labeled.append((path, expected))
    if limit is not None:
        labeled = labeled[:limit]
    return labeled


def parse_dimacs(path: Path) -> List[List[int]]:
    clauses: List[List[int]] = []
    with path.open() as fp:
        for raw in fp:
            line = raw.strip()
            if not line or line[0] in {"c", "p", "%"}:
                continue
            lits: List[int] = []
            for tok in line.split():
                if tok == "0":
                    break
                try:
                    lits.append(int(tok))
                except ValueError:
                    break
            if lits:
                clauses.append(lits)
    return clauses


def solve_instance(path: Path, solver_name: str) -> Tuple[bool | None, float]:
    start = time.perf_counter()
    try:
        clauses = parse_dimacs(path)
        with Solver(name=solver_name, bootstrap_with=clauses) as solver:
            result = solver.solve()
    except Exception:
        return None, time.perf_counter() - start
    return result, time.perf_counter() - start


def run_validation(
    instances: Iterable[Tuple[Path, bool]], solver_name: str, log_every: int, quiet: bool
) -> Tuple[int, int, int, List[str]]:
    total = 0
    mismatches = 0
    errors = 0
    bad_paths: List[str] = []

    for path, expected in instances:
        total += 1
        result, elapsed = solve_instance(path, solver_name)
        status = "SAT" if result else "UNSAT" if result is not None else "ERROR"

        should_log = (not quiet and (log_every <= 1 or total % log_every == 0)) or (
            result != expected or result is None
        )
        if should_log:
            print(f"[{total}] {path.name}: {status} ({elapsed:.3f}s)")

        if result is None:
            errors += 1
            bad_paths.append(f"ERROR {path}")
            continue

        if result != expected:
            mismatches += 1
            bad_paths.append(f"MISMATCH {path} expected {'SAT' if expected else 'UNSAT'} got {status}")

    return total, mismatches, errors, bad_paths


def parse_args(argv: List[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate SAT/UNSAT status for satlib instances using PySAT.")
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parent / "satlib",
        help="Path to satlib root containing sat/ and unsat/ folders.",
    )
    parser.add_argument("--solver", default="g3", help="PySAT solver name (e.g., g3, g4, m22, cadical124).")
    parser.add_argument("--pattern", default=None, help="Substring filter on file names (optional).")
    parser.add_argument("--limit", type=int, default=None, help="Stop after this many files (optional).")
    parser.add_argument(
        "--log-every",
        type=int,
        default=100,
        help="Print details every N instances; set to 1 for full logs.",
    )
    parser.add_argument("--quiet", action="store_true", help="Suppress per-instance logging except issues.")
    return parser.parse_args(argv)


def main(argv: List[str]) -> int:
    args = parse_args(argv)
    root = args.root
    instances = gather_instances(root, args.pattern, args.limit)

    if not instances:
        print(f"No CNF files found under {root} matching filter.")
        return 1

    print(f"Running {len(instances)} instances from {root} with solver '{args.solver}'...\n")
    start = time.perf_counter()
    total, mismatches, errors, bad_paths = run_validation(instances, args.solver, args.log_every, args.quiet)
    duration = time.perf_counter() - start

    print("\n=== Summary ===")
    print(f"Files checked: {total}")
    print(f"Mismatches   : {mismatches}")
    print(f"Errors       : {errors}")
    print(f"Elapsed      : {duration:.2f}s")

    if bad_paths:
        print("\nIssues:")
        for entry in bad_paths:
            print(f"  {entry}")

    return 0 if (mismatches == 0 and errors == 0) else 2


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
