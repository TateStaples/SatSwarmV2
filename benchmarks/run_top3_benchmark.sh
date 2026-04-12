#!/usr/bin/env bash
# run_top3_benchmark.sh — Run run_benchmark.sh across the three newest available AFIs:
#
#   #1  1×1  none   agfi-00ff7949dc2bafd1a  (2026_04_02-161326)
#   #2  2×2  3clz   agfi-0a0bef585e35a4855  (2026_04_01-004349)
#   #3  3×3  2clz   agfi-019b6ef57d1bb5553  (2026_03_31-175343)
#
# Usage:
#   source src/aws-fpga/sdk_setup.sh
#   bash benchmarks/run_top3_benchmark.sh [--slot N] [--n N] [--skip-load]
#
# Optional env vars / flags:
#   --slot N      FPGA slot (default 0)
#   --n N         Instances per dataset (default 15)
#   --skip-load   Skip fpga-load-local-image (AFI already loaded; only runs first config)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BENCH_SCRIPT="$REPO_ROOT/benchmarks/run_benchmark.sh"
HOST="${HOST:-$REPO_ROOT/hdk_cl_satswarm/host/satswarm_host}"
SLOT=0
N=15
SKIP_LOAD=0

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --slot)       SLOT="$2";   shift 2 ;;
    --n)          N="$2";      shift 2 ;;
    --skip-load)  SKIP_LOAD=1; shift   ;;
    -h|--help)
      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Config: label, agfi, grid descriptor
# ---------------------------------------------------------------------------
LABELS=("1x1"              "2x2-3clz"             "3x3-2clz")
AGFIS=( "agfi-00ff7949dc2bafd1a" "agfi-0a0bef585e35a4855" "agfi-019b6ef57d1bb5553")
TAGS=(  "2026_04_02-161326"      "2026_04_01-004349"      "2026_03_31-175343")

# ---------------------------------------------------------------------------
# Sanity checks
# ---------------------------------------------------------------------------
if [[ ! -x "$HOST" ]]; then
  echo "ERROR: satswarm_host not found or not executable at: $HOST"
  echo "       Build it first: cd hdk_cl_satswarm/host && make"
  exit 1
fi

if [[ ! -f "$BENCH_SCRIPT" ]]; then
  echo "ERROR: run_benchmark.sh not found at: $BENCH_SCRIPT"
  exit 1
fi

if [[ "$SKIP_LOAD" -eq 0 ]]; then
  for cmd in fpga-clear-local-image fpga-load-local-image fpga-describe-local-image; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "ERROR: '$cmd' not found. Source sdk_setup.sh first:"
      echo "  source $REPO_ROOT/src/aws-fpga/sdk_setup.sh"
      exit 1
    fi
  done
fi

# ---------------------------------------------------------------------------
# Helper: wait for slot to reach StatusName=loaded
# ---------------------------------------------------------------------------
wait_for_loaded() {
  local slot="$1"
  local agfi="$2"
  local deadline=$((SECONDS + 120))
  echo "[LOAD] Waiting for $agfi on slot $slot ..."
  while [[ $SECONDS -lt $deadline ]]; do
    local status
    status=$(sudo fpga-describe-local-image -S "$slot" 2>&1 || true)
    if echo "$status" | grep -q "StatusName: loaded"; then
      echo "[LOAD] Slot $slot is loaded."
      return 0
    fi
    sleep 3
  done
  echo "ERROR: timed out waiting for slot $slot to load $agfi" >&2
  return 1
}

# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------
echo "================================================================"
echo "SatSwarm top-3 AFI benchmark sweep"
echo "Slot: $SLOT  |  Instances per dataset: $N"
echo "================================================================"

for i in 0 1 2; do
  label="${LABELS[$i]}"
  agfi="${AGFIS[$i]}"
  tag="${TAGS[$i]}"

  echo ""
  echo "----------------------------------------------------------------"
  echo "Config $((i+1))/3 — $label  ($tag)"
  echo "AGFI: $agfi"
  echo "----------------------------------------------------------------"

  if [[ "$SKIP_LOAD" -eq 0 ]]; then
    echo "[LOAD] Clearing slot $SLOT ..."
    sudo fpga-clear-local-image -S "$SLOT"
    echo "[LOAD] Loading $agfi ..."
    sudo fpga-load-local-image -S "$SLOT" -I "$agfi"
    wait_for_loaded "$SLOT" "$agfi"
    sudo fpga-describe-local-image -S "$SLOT" -H
  else
    echo "[LOAD] Skipping AFI load (--skip-load set)."
  fi

  echo "[RUN] Starting benchmark for GRID=$label ..."
  GRID="$label" SLOT="$SLOT" N="$N" HOST="$HOST" bash "$BENCH_SCRIPT"
done

echo ""
echo "================================================================"
echo "All 3 configs complete. Results in benchmarks/results/"
echo "================================================================"
