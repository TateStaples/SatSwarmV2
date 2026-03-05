#!/usr/bin/env bash
# =============================================================================
# iterate_inference.sh — Run inference check + regression with timeouts
#
# For RTL iteration: runs check_inference (with timeout) then run_bigger_ladder
# (with timeout). All calls use timeouts so nothing blocks indefinitely.
#
# Usage:
#   bash deploy/iterate_inference.sh [module]
#
# Examples:
#   bash deploy/iterate_inference.sh           # pse + ladder
#   bash deploy/iterate_inference.sh pse      # pse + ladder
#   bash deploy/iterate_inference.sh cae      # cae + ladder
#
# Timeouts (override with env):
#   INFERENCE_TIMEOUT=300   (default 5 min for synthesis)
#   LADDER_TIMEOUT=600      (default 10 min for 98-test regression)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MODULE="${1:-pse}"
INFERENCE_TIMEOUT="${INFERENCE_TIMEOUT:-300}"
LADDER_TIMEOUT="${LADDER_TIMEOUT:-600}"

echo "============================================================"
echo " SatSwarm Iterate — inference + regression (with timeouts)"
echo "============================================================"
echo " Module  : $MODULE"
echo " Inference timeout : ${INFERENCE_TIMEOUT}s"
echo " Ladder timeout    : ${LADDER_TIMEOUT}s"
echo "============================================================"
echo ""

# 1. Inference check (with timeout)
echo ">>> [1/2] Inference check (timeout ${INFERENCE_TIMEOUT}s)..."
if bash "$SCRIPT_DIR/check_inference.sh" -t "$INFERENCE_TIMEOUT" -k "$MODULE" 2>&1; then
    echo ""
    echo ">>> Inference: PASS"
else
    INF_EXIT=$?
    echo ""
    echo ">>> Inference: FAIL (exit $INF_EXIT)"
    echo "    Check /tmp/synth_${MODULE}.log for RAM messages"
    exit 1
fi

echo ""
echo ">>> [2/2] 98-test regression (timeout ${LADDER_TIMEOUT}s)..."
cd "$PROJECT_DIR/sim"
BIN="$PWD/obj_dir_1x1/Vtb_satswarmv2"
if [[ ! -x "$BIN" ]]; then
    echo "ERROR: Binary not found. Run: make build_1x1"
    exit 1
fi
if timeout "$LADDER_TIMEOUT" bash scripts/run_bigger_ladder.sh 2>&1; then
    echo ""
    echo ">>> Regression: PASS"
else
    echo ""
    echo ">>> Regression: FAIL"
    exit 1
fi

echo ""
echo "============================================================"
echo " Iterate complete: inference OK, regression OK"
echo "============================================================"
