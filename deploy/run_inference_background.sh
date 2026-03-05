#!/usr/bin/env bash
# =============================================================================
# run_inference_background.sh — Run BRAM inference checks in background
#
# Launches check_inference.sh for one or more modules in background with
# --kill-on-fail. Synthesis runs until RAM failure is detected, then Vivado
# is killed (no full synthesis). Logs are written to /tmp/synth_<module>.log.
#
# Usage:
#   bash deploy/run_inference_background.sh [module...]
#
# Examples:
#   bash deploy/run_inference_background.sh pse
#   bash deploy/run_inference_background.sh pse trail_manager vde_heap
#
# Monitor: tail -f /tmp/synth_<module>.log
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES=("${@:-pse}")

echo "============================================================"
echo " SatSwarm BRAM Inference — Background (kill-on-fail)"
echo "============================================================"
echo " Modules : ${MODULES[*]}"
echo " Logs    : /tmp/synth_<module>.log"
echo "============================================================"
echo ""

for mod in "${MODULES[@]}"; do
    echo ">>> Starting $mod in background..."
    bash "$SCRIPT_DIR/check_inference.sh" -b -k "$mod" &
done

echo ""
echo "All jobs started. Monitor with:"
for mod in "${MODULES[@]}"; do
    echo "  tail -f /tmp/synth_${mod}.log"
done
echo ""
echo "Wait for completion: wait"
wait
