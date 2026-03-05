#!/usr/bin/env bash
# =============================================================================
# iterate_fix.sh — Background 3-gate verification pipeline
#
# Runs three verification gates sequentially, all in the background.
# Each gate writes status to /tmp/satswarm_gate{1,2,3}.status.
# If an upstream gate fails, downstream gates are skipped.
#
# Gate 1: BRAM/LUTRAM inference check (pse)        ~2 min fail / ~10 min pass
# Gate 2: Verilator build + 98-test regression     ~5 min
# Gate 3: Full AWS CL synthesis                    ~55+ min
#
# Usage:
#   bash deploy/iterate_fix.sh              # all 3 gates
#   bash deploy/iterate_fix.sh --no-synth   # gates 1+2 only (skip synthesis)
#   bash deploy/iterate_fix.sh --gate1-only # inference check only
#
# Monitor:
#   watch -n5 'for g in 1 2 3; do printf "Gate %s: %s\n" "$g" "$(cat /tmp/satswarm_gate${g}.status 2>/dev/null || echo NOT_STARTED)"; done'
#   # Or use: bash deploy/poll_status.sh
#
# Detailed logs:
#   Gate 1: /tmp/synth_pse.log
#   Gate 2: /tmp/satswarm_regression.log
#   Gate 3: /tmp/satswarm_synth.log
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

SKIP_SYNTH=0
GATE1_ONLY=0
MODULE="${MODULE:-pse}"

for arg in "$@"; do
    case "$arg" in
        --no-synth)   SKIP_SYNTH=1 ;;
        --gate1-only) GATE1_ONLY=1 ;;
        *)            MODULE="$arg" ;;
    esac
done

STATUS1="/tmp/satswarm_gate1.status"
STATUS2="/tmp/satswarm_gate2.status"
STATUS3="/tmp/satswarm_gate3.status"

LOG1="/tmp/synth_${MODULE}.log"
LOG2="/tmp/satswarm_regression.log"
LOG3="/tmp/satswarm_synth.log"

# Initialize status files
echo "RUNNING — inference check ($MODULE)" > "$STATUS1"
echo "WAITING — blocked on Gate 1"        > "$STATUS2"
echo "WAITING — blocked on Gate 2"        > "$STATUS3"

echo "[iterate_fix] Pipeline started at $(date '+%H:%M:%S')"
echo "[iterate_fix] Gate 1: inference ($MODULE)"
echo "[iterate_fix] Gate 2: build + regression"
echo "[iterate_fix] Gate 3: full synthesis $([ $SKIP_SYNTH -eq 1 ] && echo '(SKIPPED)' || echo '')"
echo ""

# ── Gate 1: Inference check ─────────────────────────────────────────────────
gate1_start=$(date +%s)

bash "$SCRIPT_DIR/check_inference.sh" -k "$MODULE" > "$LOG1" 2>&1
GATE1_EXIT=$?

gate1_elapsed=$(( $(date +%s) - gate1_start ))

# Check result — use the authoritative TCL RESULT line (not bash grep which can false-positive)
if [ $GATE1_EXIT -eq 0 ] && grep -q "^RESULT: PASS" "$LOG1" 2>/dev/null; then
    echo "PASS — inference OK (${gate1_elapsed}s)" > "$STATUS1"
    echo "[iterate_fix] Gate 1: PASS (${gate1_elapsed}s)"
elif grep -q "^RESULT: PASS" "$LOG1" 2>/dev/null; then
    echo "PASS — inference OK (${gate1_elapsed}s)" > "$STATUS1"
    echo "[iterate_fix] Gate 1: PASS (${gate1_elapsed}s)"
else
    # Try to extract the failure reason
    FAIL_REASON=$(grep -E "Synth 8-3390|Synth 8-3391|Synth 8-4767|dissolved" "$LOG1" 2>/dev/null | head -3)
    echo "FAIL — inference failed (${gate1_elapsed}s). Check $LOG1" > "$STATUS1"
    echo "[iterate_fix] Gate 1: FAIL (${gate1_elapsed}s)"
    [ -n "$FAIL_REASON" ] && echo "[iterate_fix]   $FAIL_REASON"
    echo "SKIPPED — Gate 1 failed" > "$STATUS2"
    echo "SKIPPED — Gate 1 failed" > "$STATUS3"
    exit 1
fi

if [ $GATE1_ONLY -eq 1 ]; then
    echo "SKIPPED — --gate1-only" > "$STATUS2"
    echo "SKIPPED — --gate1-only" > "$STATUS3"
    echo "[iterate_fix] Done (gate1-only mode)"
    exit 0
fi

# ── Gate 2: Verilator build + regression ────────────────────────────────────
echo "RUNNING — building + regression" > "$STATUS2"
gate2_start=$(date +%s)

cd "$PROJECT_DIR/sim"

# Build the binary first
echo "[iterate_fix] Gate 2: Building 1x1 binary..."
if ! make build_1x1 >> "$LOG2" 2>&1; then
    gate2_elapsed=$(( $(date +%s) - gate2_start ))
    echo "FAIL — build error (${gate2_elapsed}s). Check $LOG2" > "$STATUS2"
    echo "SKIPPED — Gate 2 failed" > "$STATUS3"
    echo "[iterate_fix] Gate 2: BUILD FAIL (${gate2_elapsed}s)"
    exit 1
fi

BIN="$PWD/obj_dir_1x1/Vtb_satswarmv2"
echo "[iterate_fix] Gate 2: Running 98-test regression..."
if BIN="$BIN" bash scripts/run_bigger_ladder.sh >> "$LOG2" 2>&1; then
    gate2_elapsed=$(( $(date +%s) - gate2_start ))
    # Extract summary line
    SUMMARY=$(grep -E "Passed:|Failed:" "$LOG2" | tail -2 | tr '\n' ' ')
    echo "PASS — regression OK (${gate2_elapsed}s) $SUMMARY" > "$STATUS2"
    echo "[iterate_fix] Gate 2: PASS (${gate2_elapsed}s)"
else
    gate2_elapsed=$(( $(date +%s) - gate2_start ))
    FAILURES=$(grep "FAILED" "$LOG2" | head -5)
    echo "FAIL — regression (${gate2_elapsed}s). Check $LOG2" > "$STATUS2"
    echo "SKIPPED — Gate 2 failed" > "$STATUS3"
    echo "[iterate_fix] Gate 2: FAIL (${gate2_elapsed}s)"
    [ -n "$FAILURES" ] && echo "[iterate_fix]   $FAILURES"
    exit 1
fi

if [ $SKIP_SYNTH -eq 1 ]; then
    echo "SKIPPED — --no-synth" > "$STATUS3"
    echo "[iterate_fix] Done (no-synth mode). Gates 1+2 passed."
    exit 0
fi

# ── Gate 3: Full synthesis ──────────────────────────────────────────────────
echo "RUNNING — full CL synthesis" > "$STATUS3"
gate3_start=$(date +%s)

echo "[iterate_fix] Gate 3: Launching full synthesis..."

# Start memory monitor in background
(
    while sleep 30; do
        rss=$(ps aux | grep "unwrapped.*vivado" | grep -v grep | awk '{print int($6/1024)}' | head -1)
        if [ -n "$rss" ] && [ "$rss" -gt 0 ] 2>/dev/null; then
            echo "$(date '+%H:%M:%S') RSS=${rss}MB" >> /tmp/satswarm_synth_mem.log
            if [ "$rss" -gt 25000 ] 2>/dev/null; then
                echo "RUNNING — synthesis in progress (WARNING: RSS=${rss}MB > 25GB)" > "$STATUS3"
            fi
        fi
    done
) &
MEM_MONITOR_PID=$!

cd "$PROJECT_DIR/deploy"
if bash run_synthesis.sh > "$LOG3" 2>&1; then
    gate3_elapsed=$(( $(date +%s) - gate3_start ))
    WNS=$(grep -E "WNS" "$LOG3" | tail -1)
    echo "PASS — synthesis complete (${gate3_elapsed}s) $WNS" > "$STATUS3"
    echo "[iterate_fix] Gate 3: PASS (${gate3_elapsed}s)"
else
    gate3_elapsed=$(( $(date +%s) - gate3_start ))
    FAIL_LINE=$(grep -E "ERROR|Killed|Thrashing" "$LOG3" | tail -3)
    echo "FAIL — synthesis (${gate3_elapsed}s). Check $LOG3" > "$STATUS3"
    echo "[iterate_fix] Gate 3: FAIL (${gate3_elapsed}s)"
    [ -n "$FAIL_LINE" ] && echo "[iterate_fix]   $FAIL_LINE"
fi

kill "$MEM_MONITOR_PID" 2>/dev/null || true

echo ""
echo "[iterate_fix] Pipeline completed at $(date '+%H:%M:%S')"
