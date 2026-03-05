#!/usr/bin/env bash
# =============================================================================
# check_inference.sh — fast per-module BRAM/LUTRAM inference verification
#
# Synthesizes a single RTL module out-of-context on xcvu47p-fsvh2892-2-e and
# reports whether Vivado successfully inferred the intended RAM primitives, or
# whether arrays dissolved into flip-flops (the root cause of Technology
# Mapping OOMs in the full CL synthesis).
#
# Typical runtime: 5-15 minutes (vs 55+ min for the full CL synthesis).
#
# Usage:
#   bash deploy/check_inference.sh [options] <module_name> [rtl_dir]
#
# Options:
#   -b, --background   Run Vivado in background; monitor log with tail -f.
#   -k, --kill-on-fail When RAM failure (Synth 8-3390/8-3391) is seen, kill
#                      Vivado immediately — no need to run full synthesis.
#   -t N, --timeout N  Kill Vivado after N seconds (for iteration; default: none).
#
# Examples:
#   bash deploy/check_inference.sh pse
#   bash deploy/check_inference.sh -b pse              # background + monitor
#   bash deploy/check_inference.sh -b -k pse            # background, kill on RAM fail
#   bash deploy/check_inference.sh -t 300 pse           # 5 min timeout (for iteration)
#   bash deploy/check_inference.sh trail_manager
#
# Arguments:
#   module_name  — RTL module to synthesize (maps to src/Mega/<module>.sv)
#   rtl_dir      — optional: override path to src/Mega directory
#
# Output:
#   /tmp/synth_<module_name>.log  — full Vivado transcript
#   /tmp/synth_module_<module>/   — Vivado utilization reports
# =============================================================================

set -euo pipefail

# ── Argument handling ────────────────────────────────────────────────────────
BACKGROUND=0
KILL_ON_FAIL=0
TIMEOUT_SEC=""
MODULE_NAME=""
RTL_DIR_ARG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--background)   BACKGROUND=1; shift ;;
        -k|--kill-on-fail) KILL_ON_FAIL=1; shift ;;
        -t|--timeout)
            shift
            [[ $# -gt 0 ]] || { echo "ERROR: --timeout requires N"; exit 1; }
            TIMEOUT_SEC="$1"; shift
            ;;
        -*) echo "ERROR: Unknown option $1"; exit 1 ;;
        *)
            if [[ -z "$MODULE_NAME" ]]; then
                MODULE_NAME="$1"
            else
                RTL_DIR_ARG="$1"
            fi
            shift
            ;;
    esac
done

if [[ -z "$MODULE_NAME" ]]; then
    echo "ERROR: module name required."
    echo "Usage: bash deploy/check_inference.sh [options] <module_name> [rtl_dir]"
    echo ""
    echo "Options: -b/--background  -k/--kill-on-fail  -t N/--timeout N"
    echo ""
    echo "Common targets: pse trail_manager vde_heap shared_clause_buffer cae"
    exit 1
fi

# ── Paths ────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TCL_SCRIPT="$SCRIPT_DIR/tcl/synth_module.tcl"

RTL_DIR="${RTL_DIR_ARG:-$PROJECT_DIR/src/Mega}"
LOG_FILE="/tmp/synth_${MODULE_NAME}.log"
VIVADO_SETTINGS="/opt/Xilinx/2025.2/Vivado/settings64.sh"

# ── Verify prerequisites ─────────────────────────────────────────────────────
if [[ ! -f "$VIVADO_SETTINGS" ]]; then
    echo "ERROR: Vivado settings not found at: $VIVADO_SETTINGS"
    echo "       Adjust VIVADO_SETTINGS in this script if Vivado is installed elsewhere."
    exit 1
fi

if [[ ! -f "$TCL_SCRIPT" ]]; then
    echo "ERROR: TCL script not found: $TCL_SCRIPT"
    exit 1
fi

if [[ ! -f "$RTL_DIR/${MODULE_NAME}.sv" ]]; then
    echo "ERROR: RTL source not found: $RTL_DIR/${MODULE_NAME}.sv"
    echo "       Available modules in $RTL_DIR:"
    ls "$RTL_DIR"/*.sv 2>/dev/null | xargs -n1 basename | sed 's/\.sv$//' | sed 's/^/  /' || true
    exit 1
fi

# ── Source Vivado ────────────────────────────────────────────────────────────
# Xilinx settings64.sh (and its Vitis sub-script) references variables like
# PYTHONPATH without a default value, which triggers bash's nounset error.
# Temporarily relax -u around the source so the script runs cleanly.
# shellcheck source=/dev/null
set +u
source "$VIVADO_SETTINGS"
set -u

# ── Run synthesis ────────────────────────────────────────────────────────────
echo "============================================================"
echo " SatSwarm BRAM Inference Check"
echo "============================================================"
echo " Module  : $MODULE_NAME"
echo " RTL dir : $RTL_DIR"
echo " Log     : $LOG_FILE"
echo " Reports : /tmp/synth_module_${MODULE_NAME}/"
[[ "$BACKGROUND" -eq 1 ]] && echo " Mode    : background (monitor with tail -f $LOG_FILE)"
[[ "$KILL_ON_FAIL" -eq 1 ]] && echo " Mode    : kill Vivado on first RAM failure"
[[ -n "$TIMEOUT_SEC" ]] && echo " Timeout : ${TIMEOUT_SEC}s"
echo "============================================================"
echo ""

run_vivado() {
    if [[ -n "$TIMEOUT_SEC" ]]; then
        timeout "$TIMEOUT_SEC" vivado -mode batch \
               -nojournal -nolog \
               -source "$TCL_SCRIPT" \
               -tclargs "$MODULE_NAME" "$RTL_DIR" \
               2>&1 | tee "$LOG_FILE"
    else
        vivado -mode batch \
               -nojournal -nolog \
               -source "$TCL_SCRIPT" \
               -tclargs "$MODULE_NAME" "$RTL_DIR" \
               2>&1 | tee "$LOG_FILE"
    fi
}

if [[ "$BACKGROUND" -eq 1 ]]; then
    # Run Vivado in background — non-blocking; returns immediately
    echo "Starting Vivado in background..."
    : > "$LOG_FILE"  # truncate log
    (
        if [[ "$KILL_ON_FAIL" -eq 1 ]]; then
            # Subshell: run vivado, monitor log, kill on RAM failure
            run_vivado &
            VPID=$!
            while kill -0 "$VPID" 2>/dev/null; do
                if grep -qE "Synth 8-3390|Synth 8-3391|dissolved into registers|Trying to implement RAM in registers" "$LOG_FILE" 2>/dev/null; then
                    echo "" >> "$LOG_FILE"
                    echo ">>> [check_inference] RAM failure detected — killing Vivado" >> "$LOG_FILE"
                    kill "$VPID" 2>/dev/null || true
                    break
                fi
                sleep 2
            done
            wait "$VPID" 2>/dev/null || true
        else
            run_vivado
        fi
    ) &
    VIVADO_PID=$!
    echo "Vivado PID: $VIVADO_PID"
    echo ""
    echo "Monitor: tail -f $LOG_FILE"
    echo "Check result later: grep -E 'Synth 8-3390|Synth 8-3391|RESULT:' $LOG_FILE"
    echo ""
    exit 0
else
    echo "Running Vivado OOC synthesis... (this takes 5-15 min)"
    echo ""
    set +e
    run_vivado
    VIVADO_EXIT=$?
    set -e
fi

echo ""
echo "============================================================"
echo " Post-run inference summary"
echo "============================================================"

# ── Extract key lines from the log ──────────────────────────────────────────
echo ""
echo "--- RAM inference messages ---"
grep -E "Synth 8-4767|Synth 8-13159|Synth 8-3390|Synth 8-3391|dissolved into|Trying to implement RAM|INFERENCE_CHECK|RESULT:" \
    "$LOG_FILE" || echo "  (none found)"

echo ""
echo "--- Utilization snapshot (RAM primitives) ---"
if [[ -f "/tmp/synth_module_${MODULE_NAME}/utilization.rpt" ]]; then
    grep -E "RAMB|RAM16|RAM32|LUT RAM|LUTRAM|CLB LUT|CLB Reg|Block RAM" \
        "/tmp/synth_module_${MODULE_NAME}/utilization.rpt" || echo "  (no RAM rows found in report)"
else
    echo "  (utilization report not generated — synthesis may have failed)"
fi

echo ""
echo "--- Errors / Critical warnings ---"
grep -c "^ERROR:" "$LOG_FILE" | xargs -I{} echo "  Errors:           {}" || true
grep -c "CRITICAL WARNING" "$LOG_FILE" | xargs -I{} echo "  Critical warnings: {}" || true

echo ""

# ── Final verdict ─────────────────────────────────────────────────────────────
FAIL_COUNT=$(grep -cE "Synth 8-3390|Synth 8-3391|dissolved into registers|Trying to implement RAM in registers" "$LOG_FILE" || true)

if [[ "$VIVADO_EXIT" -ne 0 || "$FAIL_COUNT" -gt 0 ]]; then
    echo "RESULT: FAIL"
    echo ""
    if [[ "$FAIL_COUNT" -gt 0 ]]; then
        echo "  $FAIL_COUNT RAM(s) dissolved into FFs or have multi-port write conflicts."
        echo "  Fix the always_ff write patterns in $MODULE_NAME.sv and re-run."
    fi
    if [[ "$VIVADO_EXIT" -ne 0 ]]; then
        if [[ "$VIVADO_EXIT" -eq 124 ]] && [[ -n "$TIMEOUT_SEC" ]]; then
            echo "  Timeout — synthesis killed after ${TIMEOUT_SEC}s."
        else
            echo "  Vivado exited with code $VIVADO_EXIT — check $LOG_FILE for details."
        fi
    fi
    echo ""
    echo "Full log: $LOG_FILE"
    exit 1
else
    echo "RESULT: PASS — No RAM dissolution errors detected in $MODULE_NAME."
    echo ""
    echo "Full log : $LOG_FILE"
    echo "Reports  : /tmp/synth_module_${MODULE_NAME}/"
    exit 0
fi
