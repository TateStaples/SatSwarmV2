#!/usr/bin/env bash
# Hardware-side scaling data collection for F2 instances.
#
# Mirrors sim/scripts/run_aws_scaling_collection.sh but drives the real FPGA
# via satswarm_host instead of simulation binaries.
#
# For each config:agfi pair:
#   1. Load the AFI on the specified slot (requires sudo).
#   2. Run the CNF suite through satswarm_host -> per-config CSV.
# After all configs:
#   3. Convert per-config CSVs into raw_runs.csv via convert_fpga_csv.py.
#   4. Fit distributions and project scaling via refit_project.py.
#
# Usage:
#   run_fpga_scaling_collection.sh \
#     --afis "1x1:agfi-0f933cb959906a494,2x2:agfi-0193eda3eade22ae4" \
#     --suite-dir sim/tests/generated_instances \
#     [options]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SIM_DIR="$REPO_DIR/sim"

DEFAULT_HOST="$SCRIPT_DIR/../host/satswarm_host"

AFIS=""
SUITE_DIR="sim/tests/generated_instances"
SLOT=0
TIMEOUT_SEC=30
MAX_TESTS=0
CLOCK_MHZ=15.625
PROJECTION_CORES="1,2,4,8,16,32,64,128,256,512"
TOPOLOGY="mesh"
SEED=12345
MIN_BASELINE_SAMPLES=10
OUTPUT_ROOT="logs/fpga_scaling_results"
HOST="$DEFAULT_HOST"
SKIP_LOAD=0

usage() {
  cat <<EOF
Usage: $(basename "$0") --afis <pairs> [options]

Required:
  --afis PAIRS        Comma-separated config:agfi pairs, e.g.
                      "1x1:agfi-0f933cb959906a494,2x2:agfi-0193eda3eade22ae4"
                      At least one pair is required. The 1x1 config is needed
                      for baseline distribution fitting.

Options:
  --suite-dir PATH    CNF directory, relative to repo root (default: ${SUITE_DIR})
  --slot N            FPGA slot number (default: ${SLOT})
  --timeout-sec N     Per-run timeout in seconds (default: ${TIMEOUT_SEC})
  --max-tests N       Limit number of CNF files (0 = all, default: ${MAX_TESTS})
  --clock-mhz F       FPGA clock frequency for wall_sec estimation (default: ${CLOCK_MHZ})
  --projection-cores  Comma-separated core counts for projection (default: ${PROJECTION_CORES})
  --topology NAME     all_to_all|ring|tree|mesh (default: ${TOPOLOGY})
  --seed N            Random seed (default: ${SEED})
  --min-baseline-samples N
                      Min 1x1 pass samples for fit (default: ${MIN_BASELINE_SAMPLES})
  --output-root PATH  Output root, relative to repo root (default: ${OUTPUT_ROOT})
  --host PATH         Path to satswarm_host binary (default: auto-detected)
  --skip-load         Skip fpga-load-local-image (AFI already loaded on slot)
  -h, --help          Show this help

This script requires sudo access for fpga-{clear,load,describe}-local-image.
Source sdk_setup.sh before running:
  source /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/sdk_setup.sh

Example:
  source src/aws-fpga/sdk_setup.sh
  bash hdk_cl_satswarm/scripts/$(basename "$0") \\
    --afis "1x1:agfi-0f933cb959906a494,2x2:agfi-0193eda3eade22ae4" \\
    --suite-dir sim/tests/generated_instances \\
    --timeout-sec 30
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --afis)                  AFIS="$2";                  shift 2 ;;
    --suite-dir)             SUITE_DIR="$2";             shift 2 ;;
    --slot)                  SLOT="$2";                  shift 2 ;;
    --timeout-sec)           TIMEOUT_SEC="$2";           shift 2 ;;
    --max-tests)             MAX_TESTS="$2";             shift 2 ;;
    --clock-mhz)             CLOCK_MHZ="$2";             shift 2 ;;
    --projection-cores)      PROJECTION_CORES="$2";      shift 2 ;;
    --topology)              TOPOLOGY="$2";              shift 2 ;;
    --seed)                  SEED="$2";                  shift 2 ;;
    --min-baseline-samples)  MIN_BASELINE_SAMPLES="$2";  shift 2 ;;
    --output-root)           OUTPUT_ROOT="$2";           shift 2 ;;
    --host)                  HOST="$2";                  shift 2 ;;
    --skip-load)             SKIP_LOAD=1;                shift   ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage; exit 2
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Validate inputs
# ---------------------------------------------------------------------------
if [[ -z "$AFIS" ]]; then
  echo "Error: --afis is required." >&2
  usage; exit 2
fi

if [[ ! -x "$HOST" ]]; then
  echo "Error: satswarm_host binary not found: $HOST" >&2
  echo "Build it: cd hdk_cl_satswarm/host && make" >&2
  exit 2
fi

SUITE_PATH="$REPO_DIR/$SUITE_DIR"
if [[ ! -d "$SUITE_PATH" ]]; then
  echo "Error: suite directory not found: $SUITE_PATH" >&2
  exit 2
fi

if [[ "$SKIP_LOAD" -eq 0 ]]; then
  for cmd in fpga-clear-local-image fpga-load-local-image fpga-describe-local-image; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "Error: '$cmd' not found. Source sdk_setup.sh first:" >&2
      echo "  source $REPO_DIR/src/aws-fpga/sdk_setup.sh" >&2
      exit 2
    fi
  done
fi

CONVERT_PY="$SIM_DIR/scripts/convert_fpga_csv.py"
REFIT_PY="$SIM_DIR/scripts/refit_project.py"
SUITE_RUNNER="$SCRIPT_DIR/run_fpga_suite.sh"

for f in "$CONVERT_PY" "$REFIT_PY" "$SUITE_RUNNER"; do
  if [[ ! -f "$f" ]]; then
    echo "Error: required script not found: $f" >&2
    exit 2
  fi
done

# ---------------------------------------------------------------------------
# Set up output directory
# ---------------------------------------------------------------------------
TIMESTAMP=$(date -u +%Y%m%d_%H%M%S)
OUT_DIR="$REPO_DIR/$OUTPUT_ROOT/scaling_${TIMESTAMP}"
mkdir -p "$OUT_DIR"

echo "=============================================================="
echo "FPGA Scaling Collection"
echo "=============================================================="
echo "Repo:        $REPO_DIR"
echo "Suite:       $SUITE_PATH"
echo "Output:      $OUT_DIR"
echo "Slot:        $SLOT"
echo "Timeout:     ${TIMEOUT_SEC}s"
echo "Clock:       ${CLOCK_MHZ} MHz"
echo "Topology:    $TOPOLOGY"
echo "Seed:        $SEED"
echo "Min samples: $MIN_BASELINE_SAMPLES"
echo "AFIs:        $AFIS"
echo "=============================================================="

# ---------------------------------------------------------------------------
# Parse config:agfi pairs
# ---------------------------------------------------------------------------
declare -a CONFIGS=()
declare -A AGFI_MAP=()

IFS=',' read -r -a PAIRS <<< "$AFIS"
for pair in "${PAIRS[@]}"; do
  pair="$(echo "$pair" | xargs)"
  cfg="${pair%%:*}"
  agfi="${pair#*:}"
  if [[ -z "$cfg" || -z "$agfi" || "$cfg" == "$agfi" ]]; then
    echo "Error: malformed config:agfi pair: '$pair'" >&2
    exit 2
  fi
  CONFIGS+=("$cfg")
  AGFI_MAP["$cfg"]="$agfi"
done

# ---------------------------------------------------------------------------
# Helper: wait for AFI to load on the slot
# ---------------------------------------------------------------------------
wait_for_loaded() {
  local slot="$1"
  local agfi="$2"
  local deadline=$((SECONDS + 120))
  echo "[LOAD] Waiting for $agfi on slot $slot to reach StatusName=loaded ..."
  while [[ $SECONDS -lt $deadline ]]; do
    local status
    status=$(sudo fpga-describe-local-image -S "$slot" 2>&1 || true)
    if echo "$status" | grep -q "StatusName: loaded"; then
      echo "[LOAD] Slot $slot is loaded."
      return 0
    fi
    if echo "$status" | grep -q "StatusName: busy"; then
      sleep 3
      continue
    fi
    echo "[WARN] Unexpected fpga-describe output:" >&2
    echo "$status" >&2
    sleep 5
  done
  echo "Error: timed out waiting for slot $slot to load $agfi" >&2
  return 1
}

# ---------------------------------------------------------------------------
# Collect data for each config
# ---------------------------------------------------------------------------
CONVERT_ARGS=()
MAX_TESTS_ARG=""
if [[ "$MAX_TESTS" -gt 0 ]]; then
  MAX_TESTS_ARG="--max-tests $MAX_TESTS"
fi

for cfg in "${CONFIGS[@]}"; do
  agfi="${AGFI_MAP[$cfg]}"
  per_cfg_csv="$OUT_DIR/raw_${cfg}.csv"

  echo ""
  echo "[CFG] ===== Config: $cfg  AGFI: $agfi ====="

  if [[ "$SKIP_LOAD" -eq 0 ]]; then
    echo "[LOAD] Clearing slot $SLOT ..."
    sudo fpga-clear-local-image -S "$SLOT"
    echo "[LOAD] Loading $agfi on slot $SLOT ..."
    sudo fpga-load-local-image -S "$SLOT" -l "$agfi"
    wait_for_loaded "$SLOT" "$agfi"
    sudo fpga-describe-local-image -S "$SLOT" -H
  else
    echo "[LOAD] Skipping AFI load (--skip-load set)."
  fi

  echo "[RUN] Starting suite for config $cfg ..."
  # shellcheck disable=SC2086
  bash "$SUITE_RUNNER" \
    --suite-dir "$SUITE_PATH" \
    --out "$per_cfg_csv" \
    --slot "$SLOT" \
    --timeout "$TIMEOUT_SEC" \
    --host "$HOST" \
    ${MAX_TESTS_ARG}

  CONVERT_ARGS+=("--input" "${cfg}:${per_cfg_csv}")
done

# ---------------------------------------------------------------------------
# Convert per-config CSVs into raw_runs.csv
# ---------------------------------------------------------------------------
RAW_CSV="$OUT_DIR/raw_runs.csv"
echo ""
echo "[CONVERT] Merging per-config CSVs into raw_runs.csv ..."
python3 "$CONVERT_PY" \
  "${CONVERT_ARGS[@]}" \
  --clock-mhz "$CLOCK_MHZ" \
  --output "$RAW_CSV"

echo "[CONVERT] Wrote: $RAW_CSV"

# ---------------------------------------------------------------------------
# Fit distributions and project scaling
# ---------------------------------------------------------------------------
echo ""
echo "[FIT] Running distribution fitting and scaling projection ..."
python3 "$REFIT_PY" \
  --input "$RAW_CSV" \
  --output-dir "$OUT_DIR" \
  --projection-cores "$PROJECTION_CORES" \
  --topology "$TOPOLOGY" \
  --seed "$SEED" \
  --min-baseline-samples "$MIN_BASELINE_SAMPLES"

echo ""
echo "=============================================================="
echo "FPGA Scaling Collection complete."
echo "Output directory: $OUT_DIR"
echo "  raw_runs.csv"
echo "  aggregate_by_config.csv"
echo "  fit_summary.json"
echo "  scaling_projection.csv"
echo "  summary.txt"
echo "=============================================================="
