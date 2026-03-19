#!/usr/bin/env bash
# Run a directory of DIMACS CNF files through satswarm_host and emit a CSV.
#
# Usage:
#   run_fpga_suite.sh --suite-dir <path> --out <csv> [options]
#
# The output CSV has columns:
#   benchmark, expected, result, cycles, slot, timeout_sec, wall_sec, timed_out
#
# Expected SAT/UNSAT is inferred from the file name:
#   - contains "unsat" or starts with "uuf"  -> UNSAT
#   - contains "sat"  or starts with "uf"    -> SAT
#   - parent directory named "sat" or "unsat" is also consulted
# Files whose expected result cannot be inferred are skipped with a warning.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_HOST="$SCRIPT_DIR/../host/satswarm_host"

SUITE_DIR=""
OUT_CSV=""
SLOT=0
TIMEOUT=15
DEBUG=0
HOST="$DEFAULT_HOST"
MAX_TESTS=0   # 0 = unlimited

usage() {
  cat <<EOF
Usage: $(basename "$0") --suite-dir <path> --out <csv> [options]

Required:
  --suite-dir PATH   Directory containing .cnf / .dimacs files (searched recursively)
  --out PATH         Output CSV file path

Options:
  --slot N           FPGA slot (default: ${SLOT})
  --timeout N        Per-run timeout in seconds (default: ${TIMEOUT})
  --debug N          Debug verbosity passed to host (default: ${DEBUG})
  --max-tests N      Stop after N files (0 = all, default: ${MAX_TESTS})
  --host PATH        Path to satswarm_host binary (default: auto-detected)
  -h, --help         Show this help

Examples:
  # Run generated_instances suite, 30-second timeout:
  $(basename "$0") \\
    --suite-dir sim/tests/generated_instances \\
    --out logs/hw_generated.csv \\
    --timeout 30

  # Run SATLIB uf50 subset:
  $(basename "$0") \\
    --suite-dir sim/tests/satlib \\
    --out logs/hw_satlib.csv \\
    --timeout 60
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --suite-dir)  SUITE_DIR="$2";  shift 2 ;;
    --out)        OUT_CSV="$2";    shift 2 ;;
    --slot)       SLOT="$2";       shift 2 ;;
    --timeout)    TIMEOUT="$2";    shift 2 ;;
    --debug)      DEBUG="$2";      shift 2 ;;
    --max-tests)  MAX_TESTS="$2";  shift 2 ;;
    --host)       HOST="$2";       shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ -z "$SUITE_DIR" ]]; then
  echo "Error: --suite-dir is required." >&2
  usage; exit 2
fi
if [[ -z "$OUT_CSV" ]]; then
  echo "Error: --out is required." >&2
  usage; exit 2
fi
if [[ ! -d "$SUITE_DIR" ]]; then
  echo "Error: suite directory not found: $SUITE_DIR" >&2
  exit 2
fi
if [[ ! -x "$HOST" ]]; then
  echo "Error: satswarm_host binary not found or not executable: $HOST" >&2
  echo "Build it first: cd $(dirname "$HOST") && make" >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Infer expected SAT/UNSAT from file name and parent directory.
# Returns "SAT", "UNSAT", or "" (unknown).
# ---------------------------------------------------------------------------
infer_expected() {
  local filepath="$1"
  local name
  name="$(basename "$filepath")"
  local lname="${name,,}"       # lowercase filename
  local lpath="${filepath,,}"   # lowercase full path

  # Filename heuristics (higher priority than directory)
  if [[ "$lname" == *unsat* ]] || [[ "$lname" == uuf* ]]; then
    echo "UNSAT"; return
  fi
  if [[ "$lname" == *sat* ]] || [[ "$lname" == uf* ]]; then
    echo "SAT"; return
  fi

  # Parent directory heuristics
  if [[ "$lpath" == */unsat/* ]]; then
    echo "UNSAT"; return
  fi
  if [[ "$lpath" == */sat/* ]]; then
    echo "SAT"; return
  fi

  echo ""
}

# ---------------------------------------------------------------------------
# Collect CNF files
# ---------------------------------------------------------------------------
mapfile -t ALL_FILES < <(find "$SUITE_DIR" -type f \( -iname "*.cnf" -o -iname "*.dimacs" \) | sort)

if [[ "${#ALL_FILES[@]}" -eq 0 ]]; then
  echo "Error: no .cnf or .dimacs files found under $SUITE_DIR" >&2
  exit 2
fi

if [[ "$MAX_TESTS" -gt 0 && "${#ALL_FILES[@]}" -gt "$MAX_TESTS" ]]; then
  ALL_FILES=("${ALL_FILES[@]:0:$MAX_TESTS}")
fi

TOTAL="${#ALL_FILES[@]}"

# ---------------------------------------------------------------------------
# Set up output
# ---------------------------------------------------------------------------
mkdir -p "$(dirname "$OUT_CSV")"
echo "benchmark,expected,result,cycles,slot,timeout_sec,wall_sec,timed_out" > "$OUT_CSV"

echo "============================================================"
echo "FPGA Suite Runner"
echo "============================================================"
echo "Suite dir:  $SUITE_DIR"
echo "Output CSV: $OUT_CSV"
echo "Slot:       $SLOT"
echo "Timeout:    ${TIMEOUT}s"
echo "Files:      $TOTAL"
echo "Host:       $HOST"
echo "============================================================"

PASS=0
FAIL=0
TIMEOUT_COUNT=0
SKIP=0
IDX=0

for cnf in "${ALL_FILES[@]}"; do
  IDX=$((IDX + 1))
  name="$(basename "$cnf")"
  expected="$(infer_expected "$cnf")"

  if [[ -z "$expected" ]]; then
    echo "[SKIP] [$IDX/$TOTAL] $name (cannot infer SAT/UNSAT)"
    SKIP=$((SKIP + 1))
    continue
  fi

  printf "[RUN ] [%d/%d] %-40s  expected=%s\n" "$IDX" "$TOTAL" "$name" "$expected"

  t_start=$(date +%s%N)
  raw_output=""
  timed_out=0

  # Run with a shell-level timeout guard in addition to the host's own timeout.
  if raw_output=$(timeout "$((TIMEOUT + 5))" "$HOST" "$cnf" \
        --slot "$SLOT" --timeout "$TIMEOUT" --debug "$DEBUG" 2>&1); then
    :
  else
    rc=$?
    if [[ $rc -eq 124 ]]; then
      timed_out=1
    fi
  fi

  t_end=$(date +%s%N)
  wall_ns=$((t_end - t_start))
  wall_sec=$(awk "BEGIN { printf \"%.6f\", $wall_ns / 1000000000 }")

  result=$(printf "%s\n" "$raw_output" | sed -n 's/^Result:[[:space:]]*//p' | head -1)
  cycles=$(printf "%s\n" "$raw_output" | sed -n 's/^Cycles:[[:space:]]*//p' | head -1)

  if [[ -z "$result" && "$timed_out" -eq 1 ]]; then
    result="TIMEOUT"
  fi
  [[ -z "$result" ]] && result="ERROR"
  [[ -z "$cycles" ]] && cycles=0

  if [[ "$result" == "TIMEOUT" ]]; then
    timed_out=1
    TIMEOUT_COUNT=$((TIMEOUT_COUNT + 1))
    printf "       -> TIMEOUT  cycles=%s  wall=%.2fs\n" "$cycles" "$wall_sec"
  elif [[ "$result" == "$expected" ]]; then
    PASS=$((PASS + 1))
    printf "       -> %-6s    cycles=%s  wall=%.2fs\n" "$result" "$cycles" "$wall_sec"
  else
    FAIL=$((FAIL + 1))
    printf "       -> %-6s    cycles=%s  wall=%.2fs  (expected %s)\n" \
      "$result" "$cycles" "$wall_sec" "$expected"
  fi

  printf "%s,%s,%s,%s,%s,%s,%s,%s\n" \
    "$name" "$expected" "$result" "$cycles" \
    "$SLOT" "$TIMEOUT" "$wall_sec" "$timed_out" >> "$OUT_CSV"
done

echo "============================================================"
echo "Done."
echo "  Pass:    $PASS / $TOTAL"
echo "  Fail:    $FAIL / $TOTAL"
echo "  Timeout: $TIMEOUT_COUNT / $TOTAL"
echo "  Skipped: $SKIP / $TOTAL"
echo "  CSV:     $OUT_CSV"
echo "============================================================"
