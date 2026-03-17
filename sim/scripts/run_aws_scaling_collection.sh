#!/usr/bin/env bash
# One-shot scaling data collection for AWS FPGA hosts.
#
# This script optionally builds requested configs and then runs the Python
# collector that generates raw benchmark data plus scaling projections.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="$(cd "$SIM_DIR/.." && pwd)"

CONFIGS="${CONFIGS:-1x1,2x2}"
RUNS_PER_TEST="${RUNS_PER_TEST:-1}"
MAX_TESTS="${MAX_TESTS:-0}"
TIMEOUT_SEC="${TIMEOUT_SEC:-180}"
MAX_CYCLES="${MAX_CYCLES:-5000000}"
TOPOLOGY="${TOPOLOGY:-mesh}"
SEED="${SEED:-12345}"
EXTRA_PLUSARGS="${EXTRA_PLUSARGS:-+DEBUG=0}"
SKIP_BUILD="${SKIP_BUILD:-0}"
SUITE_DIR="${SUITE_DIR:-tests/generated_instances}"
PROJECTION_CORES="${PROJECTION_CORES:-1,2,4,8,16,32,64,128,256,512}"
MIN_BASELINE_SAMPLES="${MIN_BASELINE_SAMPLES:-20}"
BENCHMARK_PROFILE="${BENCHMARK_PROFILE:-verisat_full}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --configs CSV           Config list (default: ${CONFIGS})
  --runs-per-test N       Runs per test per config (default: ${RUNS_PER_TEST})
  --max-tests N           Number of CNFs sampled (default: ${MAX_TESTS})
  --timeout-sec N         Timeout per run in seconds (default: ${TIMEOUT_SEC})
  --max-cycles N          +MAXCYCLES value (default: ${MAX_CYCLES})
  --suite-dir PATH        CNF suite path under sim/ (default: ${SUITE_DIR})
  --benchmark-profile P   verisat_full|generated_instances|custom_dir (default: ${BENCHMARK_PROFILE})
  --topology NAME         all_to_all|ring|tree|mesh (default: ${TOPOLOGY})
  --projection-cores CSV  Projection core counts (default: ${PROJECTION_CORES})
  --seed N                Random seed for sampling/MC (default: ${SEED})
  --min-baseline-samples N  Minimum 1x1 pass samples for fit (default: ${MIN_BASELINE_SAMPLES})
  --extra-plusargs STR    Extra plusargs (default: '${EXTRA_PLUSARGS}')
  --skip-build            Skip make build_<cfg>
  -h, --help              Show help

Environment variables can also be used for all options listed above.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --configs) CONFIGS="$2"; shift 2 ;;
    --runs-per-test) RUNS_PER_TEST="$2"; shift 2 ;;
    --max-tests) MAX_TESTS="$2"; shift 2 ;;
    --timeout-sec) TIMEOUT_SEC="$2"; shift 2 ;;
    --max-cycles) MAX_CYCLES="$2"; shift 2 ;;
    --suite-dir) SUITE_DIR="$2"; shift 2 ;;
    --benchmark-profile) BENCHMARK_PROFILE="$2"; shift 2 ;;
    --topology) TOPOLOGY="$2"; shift 2 ;;
    --projection-cores) PROJECTION_CORES="$2"; shift 2 ;;
    --seed) SEED="$2"; shift 2 ;;
    --min-baseline-samples) MIN_BASELINE_SAMPLES="$2"; shift 2 ;;
    --extra-plusargs) EXTRA_PLUSARGS="$2"; shift 2 ;;
    --skip-build) SKIP_BUILD=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

echo "=============================================================="
echo "AWS SAT Scaling Data Collection"
echo "=============================================================="
echo "Repo:        $REPO_DIR"
echo "Sim dir:     $SIM_DIR"
echo "Configs:     $CONFIGS"
echo "Suite:       $SUITE_DIR"
echo "Profile:     $BENCHMARK_PROFILE"
echo "Runs/test:   $RUNS_PER_TEST"
echo "Max tests:   $MAX_TESTS"
echo "Timeout:     ${TIMEOUT_SEC}s"
echo "Max cycles:  $MAX_CYCLES"
echo "Topology:    $TOPOLOGY"
echo "Seed:        $SEED"
echo "Min samples: $MIN_BASELINE_SAMPLES"
echo "Skip build:  $SKIP_BUILD"
echo "=============================================================="

if [[ "$SKIP_BUILD" != "1" ]]; then
  IFS=',' read -r -a cfgs <<< "$CONFIGS"
  for cfg in "${cfgs[@]}"; do
    cfg_trimmed="$(echo "$cfg" | xargs)"
    if [[ -z "$cfg_trimmed" ]]; then
      continue
    fi
    echo "[BUILD] make build_${cfg_trimmed}"
    (cd "$SIM_DIR" && make "build_${cfg_trimmed}")
  done
fi

echo "[RUN] Collecting benchmark data and projections"
(cd "$REPO_DIR" && \
  python3 "$SIM_DIR/scripts/collect_scaling_data.py" \
    --sim-dir "$SIM_DIR" \
    --suite-dir "$SUITE_DIR" \
    --benchmark-profile "$BENCHMARK_PROFILE" \
    --configs "$CONFIGS" \
    --runs-per-test "$RUNS_PER_TEST" \
    --max-tests "$MAX_TESTS" \
    --timeout-sec "$TIMEOUT_SEC" \
    --max-cycles "$MAX_CYCLES" \
    --topology "$TOPOLOGY" \
    --projection-cores "$PROJECTION_CORES" \
    --seed "$SEED" \
    --min-baseline-samples "$MIN_BASELINE_SAMPLES" \
    --extra-plusargs "$EXTRA_PLUSARGS")

echo "[DONE] Scaling data collection complete"
