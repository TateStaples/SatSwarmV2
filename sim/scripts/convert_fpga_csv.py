#!/usr/bin/env python3
"""
Convert one or more FPGA host-side CSVs into the raw_runs.csv schema used by
collect_scaling_data.py and refit_project.py.

Each --input argument is a "config:path" pair, e.g.:
  --input 1x1:logs/hw_1x1.csv
  --input 2x2:logs/hw_2x2.csv

The host-side CSV (produced by run_fpga_suite.sh) has columns:
  benchmark, expected, result, cycles, slot, timeout_sec, wall_sec, timed_out

The output raw_runs.csv has columns:
  benchmark, run_idx, config, cores, expected, result, cycles,
  wall_sec, timed_out, command

Column mapping:
  benchmark  -> pass through
  run_idx    -> always 1 (single run per CNF per config on hardware)
  config     -> from the "config:" prefix of --input
  cores      -> N*M derived from config string (e.g. "2x2" -> 4)
  expected   -> pass through
  result     -> pass through; TIMEOUT is preserved
  cycles     -> pass through
  wall_sec   -> from input CSV if present; else derived as cycles / (clock_mhz * 1e6)
  timed_out  -> from input CSV if present; else 1 when result == TIMEOUT
  command    -> reconstructed description string
"""

from __future__ import annotations

import argparse
import csv
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple


RAW_RUNS_FIELDS = [
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
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert FPGA host-side CSVs to raw_runs.csv schema",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Single config
  python3 convert_fpga_csv.py \\
    --input 1x1:logs/hw_1x1.csv \\
    --clock-mhz 15.625 \\
    --output logs/raw_runs.csv

  # Multiple configs
  python3 convert_fpga_csv.py \\
    --input 1x1:logs/hw_1x1.csv \\
    --input 2x2:logs/hw_2x2.csv \\
    --clock-mhz 15.625 \\
    --output logs/raw_runs.csv
""",
    )
    parser.add_argument(
        "--input",
        metavar="config:PATH",
        action="append",
        required=True,
        dest="inputs",
        help='config:path pair, e.g. "1x1:logs/hw_1x1.csv". Repeatable.',
    )
    parser.add_argument(
        "--output",
        required=True,
        metavar="PATH",
        help="Output raw_runs.csv path",
    )
    parser.add_argument(
        "--clock-mhz",
        type=float,
        default=15.625,
        metavar="F",
        help="FPGA clock frequency in MHz, used to derive wall_sec when absent (default: 15.625)",
    )
    return parser.parse_args()


def config_to_cores(config: str) -> int:
    parts = config.lower().split("x")
    if len(parts) != 2:
        raise ValueError(f"Cannot parse core count from config '{config}'. Expected NxM format.")
    try:
        return int(parts[0]) * int(parts[1])
    except ValueError:
        raise ValueError(f"Non-integer dimensions in config '{config}'.")


def parse_input_spec(spec: str) -> Tuple[str, Path]:
    """Split 'config:path' into (config, Path).  Path may itself contain colons."""
    idx = spec.index(":")
    config = spec[:idx].strip()
    path = Path(spec[idx + 1 :].strip())
    if not config:
        raise ValueError(f"Empty config in spec: '{spec}'")
    return config, path


def cycles_to_wall(cycles: int, clock_mhz: float) -> float:
    if clock_mhz <= 0:
        return 0.0
    return cycles / (clock_mhz * 1_000_000)


def read_input_csv(path: Path, config: str, clock_mhz: float) -> List[Dict[str, object]]:
    """Read one host-side CSV and return a list of raw_runs.csv row dicts."""
    if not path.exists():
        print(f"[ERROR] Input file not found: {path}", file=sys.stderr)
        sys.exit(2)

    cores = config_to_cores(config)
    rows: List[Dict[str, object]] = []

    with path.open(newline="") as f:
        reader = csv.DictReader(f)
        if reader.fieldnames is None:
            print(f"[ERROR] Empty or header-less CSV: {path}", file=sys.stderr)
            sys.exit(2)

        fields_lower = {fn.strip().lower() for fn in reader.fieldnames}
        has_wall = "wall_sec" in fields_lower
        has_timed_out = "timed_out" in fields_lower

        for lineno, raw in enumerate(reader, start=2):
            row = {k.strip().lower(): v.strip() for k, v in raw.items() if k is not None}

            benchmark = row.get("benchmark", "")
            expected = row.get("expected", "")
            result = row.get("result", "ERROR")
            cycles_str = row.get("cycles", "0")

            try:
                cycles = int(cycles_str)
            except ValueError:
                print(
                    f"[WARN] {path}:{lineno}: non-integer cycles '{cycles_str}', treating as 0",
                    file=sys.stderr,
                )
                cycles = 0

            # wall_sec: use from CSV if present; derive from cycles otherwise.
            if has_wall and row.get("wall_sec", ""):
                try:
                    wall_sec = float(row["wall_sec"])
                except ValueError:
                    wall_sec = cycles_to_wall(cycles, clock_mhz)
            else:
                wall_sec = cycles_to_wall(cycles, clock_mhz)

            # timed_out: use from CSV if present; derive from result otherwise.
            if has_timed_out and row.get("timed_out", "") != "":
                try:
                    timed_out = int(row["timed_out"]) != 0
                except ValueError:
                    timed_out = result.upper() == "TIMEOUT"
            else:
                timed_out = result.upper() == "TIMEOUT"

            slot = row.get("slot", "0")
            timeout_sec = row.get("timeout_sec", "")
            command = (
                f"satswarm_host {benchmark} --slot {slot} --timeout {timeout_sec} "
                f"[config={config}]"
            )

            rows.append(
                {
                    "benchmark": benchmark,
                    "run_idx": 1,
                    "config": config,
                    "cores": cores,
                    "expected": expected,
                    "result": result,
                    "cycles": cycles,
                    "wall_sec": f"{wall_sec:.6f}",
                    "timed_out": int(timed_out),
                    "command": command,
                }
            )

    return rows


def main() -> int:
    args = parse_args()

    all_rows: List[Dict[str, object]] = []
    seen_configs: Dict[str, int] = {}

    for spec in args.inputs:
        try:
            config, path = parse_input_spec(spec)
        except (ValueError, IndexError) as exc:
            print(f"[ERROR] Bad --input spec '{spec}': {exc}", file=sys.stderr)
            return 2

        try:
            cores = config_to_cores(config)
        except ValueError as exc:
            print(f"[ERROR] {exc}", file=sys.stderr)
            return 2

        print(f"[INFO] Reading config={config} ({cores} cores) from {path}")
        rows = read_input_csv(path, config, args.clock_mhz)
        print(f"[INFO]   -> {len(rows)} rows")
        all_rows.extend(rows)
        seen_configs[config] = seen_configs.get(config, 0) + len(rows)

    if not all_rows:
        print("[ERROR] No rows collected. Check that input CSVs are non-empty.", file=sys.stderr)
        return 2

    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    with out_path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=RAW_RUNS_FIELDS)
        writer.writeheader()
        writer.writerows(all_rows)

    print(f"[OK] Wrote {len(all_rows)} rows -> {out_path}")
    for cfg, count in sorted(seen_configs.items()):
        print(f"     config={cfg}: {count} rows")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
