#!/bin/bash
# Run the full generated_instances ladder under multiple core configs.
# Usage: ./run_multicore_ladder.sh [timeout_secs]
# Timeout per test defaults to 60s (UNSAT tests are slow; they'll be reported as TIMEOUT).

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SIM_DIR="$(dirname "$SCRIPT_DIR")"
TESTS_DIR="$SIM_DIR/tests/generated_instances"
TIMEOUT_S="${1:-60}"

# Core configs: "label:binary_path:build_target"
CONFIGS=(
    "1x1:$SIM_DIR/obj_dir_1x1/Vtb_satswarmv2:build_1x1"
    "2x2:$SIM_DIR/obj_dir_2x2/Vtb_satswarmv2:build_2x2"
)

LOGDIR="$SIM_DIR/logs/multicore_ladder_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$LOGDIR"

echo "================================================================"
echo "  SatSwarm Multi-Core Regression Ladder"
echo "  Tests dir : $TESTS_DIR"
echo "  Timeout   : ${TIMEOUT_S}s per test"
echo "  Log dir   : $LOGDIR"
echo "================================================================"
echo ""

# Step 1: Ensure all binaries are built.
for cfg in "${CONFIGS[@]}"; do
    label="${cfg%%:*}"; rest="${cfg#*:}"; bin="${rest%%:*}"; target="${rest##*:}"
    if [ ! -x "$bin" ]; then
        echo "[BUILD] $label — $target ..."
        (cd "$SIM_DIR" && make "$target" 2>&1) | tee "$LOGDIR/build_${label}.log"
        echo "[BUILD] $label done."
    else
        echo "[BUILD] $label — binary already exists, skipping rebuild."
    fi
done

echo ""

# Collect test files.
FILES=( $(find "$TESTS_DIR" -name "*.cnf" | sort) )
TOTAL=${#FILES[@]}
echo "Found $TOTAL test files."
echo ""

# Step 2: Run each config's ladder sequentially (configs in parallel via subshell).
run_ladder() {
    local label="$1"
    local bin="$2"
    local logfile="$LOGDIR/ladder_${label}.log"
    local pass=0 fail=0 timeout_count=0 skip=0

    {
        echo "========================================================"
        echo "  Config: $label"
        echo "  Binary: $bin"
        echo "  Started: $(date)"
        echo "========================================================"
        echo ""

        for file in "${FILES[@]}"; do
            bname=$(basename "$file")
            expected=""
            if [[ "$bname" == *unsat* || "$bname" == *UNSAT* ]]; then
                expected="UNSAT"
            elif [[ "$bname" == *sat* || "$bname" == *SAT* ]]; then
                expected="SAT"
            else
                echo "  SKIP  $bname (unknown result type)"
                skip=$((skip+1)); continue
            fi

            printf "  %-45s " "$bname"

            # Run with wall-clock timeout; propagate MAXCYCLES to avoid internal timeout noise
            exit_sig=0
            output=$(timeout "${TIMEOUT_S}s" "$bin" \
                +CNF="$file" +EXPECT="$expected" +MAXCYCLES=50000000 2>&1) || exit_sig=$?

            if echo "$output" | grep -q "TEST PASSED"; then
                echo "PASS"
                pass=$((pass+1))
            elif [ $exit_sig -eq 124 ]; then
                echo "TIMEOUT (>${TIMEOUT_S}s)"
                timeout_count=$((timeout_count+1))
            elif echo "$output" | grep -q "TEST FAILED"; then
                echo "FAIL (wrong answer)"
                fail=$((fail+1))
                echo "$output" >> "$LOGDIR/failures_${label}.log"
            else
                echo "FAIL (no result)"
                fail=$((fail+1))
                echo "$output" >> "$LOGDIR/failures_${label}.log"
            fi
        done

        echo ""
        echo "========================================================"
        echo "  Config: $label  SUMMARY"
        echo "========================================================"
        echo "  Total   : $TOTAL"
        echo "  PASS    : $pass"
        echo "  FAIL    : $fail   (wrong answer / crash)"
        echo "  TIMEOUT : $timeout_count  (>${TIMEOUT_S}s — performance, not correctness)"
        echo "  SKIP    : $skip"
        echo "  Finished: $(date)"
        echo "========================================================"
    } | tee "$logfile"
}

# Launch all config ladders in parallel.
pids=()
for cfg in "${CONFIGS[@]}"; do
    label="${cfg%%:*}"; rest="${cfg#*:}"; bin="${rest%%:*}"
    run_ladder "$label" "$bin" &
    pids+=($!)
done

# Wait for all to complete.
all_ok=true
for pid in "${pids[@]}"; do
    wait "$pid" || all_ok=false
done

echo ""
echo "================================================================"
echo "  ALL CONFIGS DONE — see $LOGDIR/"
echo "================================================================"

# Print final summary across all configs.
for cfg in "${CONFIGS[@]}"; do
    label="${cfg%%:*}"
    logfile="$LOGDIR/ladder_${label}.log"
    if [ -f "$logfile" ]; then
        echo ""
        echo "--- $label ---"
        grep -E "PASS|FAIL|TIMEOUT|SKIP" "$logfile" | tail -6
    fi
done

$all_ok && exit 0 || exit 1
