#!/usr/bin/env bash
# =============================================================================
# poll_status.sh — Monitor the iterate_fix.sh verification pipeline
#
# Displays gate status, live synthesis RSS, and tail of active log.
# Runs once and exits (intended for use with: watch -n5 bash deploy/poll_status.sh)
#
# Usage:
#   watch -n5 bash deploy/poll_status.sh          # auto-refresh every 5s
#   bash deploy/poll_status.sh                     # one-shot
#   bash deploy/poll_status.sh --tail              # include last 5 lines of active log
# =============================================================================

SHOW_TAIL=0
[[ "${1:-}" == "--tail" ]] && SHOW_TAIL=1

echo "═══════════════════════════════════════════════════"
echo " SatSwarm Verification Pipeline — $(date '+%H:%M:%S')"
echo "═══════════════════════════════════════════════════"

for g in 1 2 3; do
    STATUS=$(cat "/tmp/satswarm_gate${g}.status" 2>/dev/null || echo "NOT_STARTED")
    case "$STATUS" in
        PASS*)    ICON="✅" ;;
        FAIL*)    ICON="❌" ;;
        RUNNING*) ICON="🔄" ;;
        WAITING*) ICON="⏳" ;;
        SKIPPED*) ICON="⏭️ " ;;
        *)        ICON="  " ;;
    esac
    printf " %s Gate %d: %s\n" "$ICON" "$g" "$STATUS"
done

echo "═══════════════════════════════════════════════════"

# Show Vivado process if running
VIVADO_INFO=$(ps aux | grep "unwrapped.*vivado" | grep -v grep | awk '{printf "PID=%s CPU=%s%% RSS=%.0fMB\n", $2, $3, $6/1024}' | head -1)
if [ -n "$VIVADO_INFO" ]; then
    echo " Vivado: $VIVADO_INFO"
fi

# Show memory pressure
FREE_MEM=$(free -m | awk '/^Mem:/ {printf "RAM: %dMB/%dMB used", $3, $2}')
SWAP_INFO=$(free -m | awk '/^Swap:/ {printf "Swap: %dMB/%dMB", $3, $2}')
echo " $FREE_MEM  $SWAP_INFO"

echo "═══════════════════════════════════════════════════"

# Determine which log to tail
if [ $SHOW_TAIL -eq 1 ]; then
    ACTIVE_GATE=""
    for g in 1 2 3; do
        STATUS=$(cat "/tmp/satswarm_gate${g}.status" 2>/dev/null || echo "")
        if [[ "$STATUS" == RUNNING* ]]; then
            ACTIVE_GATE=$g
            break
        fi
    done

    case "$ACTIVE_GATE" in
        1) LOG="/tmp/synth_pse.log" ;;
        2) LOG="/tmp/satswarm_regression.log" ;;
        3) LOG="/tmp/satswarm_synth.log" ;;
        *) LOG="" ;;
    esac

    if [ -n "$LOG" ] && [ -f "$LOG" ]; then
        echo " Last 5 lines of $LOG:"
        tail -5 "$LOG" | sed 's/^/   /'
        echo "═══════════════════════════════════════════════════"
    fi
fi
