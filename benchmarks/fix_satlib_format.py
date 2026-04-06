#!/usr/bin/env python3
"""
Fix SATLIB .cnf files so satswarm_host can parse them.

Problems fixed:
  1. Leading 'c ...' comment lines  -> removed
  2. Trailing '% / 0' end-of-file marker -> removed
  3. Trailing whitespace on the 'p cnf' line -> stripped
  4. Extra internal whitespace in 'p cnf' header -> normalized

Usage:
  python3 benchmarks/fix_satlib_format.py [--dry-run] [--dir PATH]
"""

import argparse
import pathlib
import sys


def fix_file(path: pathlib.Path, dry_run: bool) -> str:
    """
    Returns 'fixed', 'ok' (already clean), or 'error:<msg>'.
    """
    try:
        lines = path.read_text(encoding="ascii", errors="replace").splitlines(keepends=True)
    except Exception as e:
        return f"error:{e}"

    original = list(lines)

    # 1. Remove comment lines (start with 'c')
    lines = [l for l in lines if not l.startswith("c")]

    # 2. Remove trailing blank lines, '%', and '0' end-of-file markers
    while lines and lines[-1].strip() in ("", "%", "0"):
        lines.pop()

    # 3. Normalize the 'p cnf' line
    for i, l in enumerate(lines):
        if l.startswith("p cnf"):
            parts = l.split()
            if len(parts) >= 4:
                lines[i] = f"p cnf {parts[2]} {parts[3]}\n"
            break

    if lines == original:
        return "ok"

    if not dry_run:
        path.write_text("".join(lines), encoding="ascii")
    return "fixed"


def main():
    parser = argparse.ArgumentParser(description="Fix SATLIB CNF formatting for satswarm_host")
    parser.add_argument("--dir", default="benchmarks/satlib_3sat",
                        help="Root directory to search (default: benchmarks/satlib_3sat)")
    parser.add_argument("--dry-run", action="store_true",
                        help="Report what would change without writing files")
    args = parser.parse_args()

    root = pathlib.Path(args.dir)
    if not root.exists():
        print(f"ERROR: directory not found: {root}", file=sys.stderr)
        sys.exit(1)

    files = sorted(root.rglob("*.cnf"))
    if not files:
        print(f"No .cnf files found under {root}", file=sys.stderr)
        sys.exit(1)

    fixed = ok = errors = 0
    for f in files:
        result = fix_file(f, dry_run=args.dry_run)
        if result == "fixed":
            fixed += 1
            if args.dry_run:
                print(f"  would fix: {f}")
        elif result == "ok":
            ok += 1
        else:
            errors += 1
            print(f"  ERROR {f}: {result}", file=sys.stderr)

    label = "Would fix" if args.dry_run else "Fixed"
    print(f"\n{label}: {fixed}  Already clean: {ok}  Errors: {errors}  Total: {len(files)}")


if __name__ == "__main__":
    main()
