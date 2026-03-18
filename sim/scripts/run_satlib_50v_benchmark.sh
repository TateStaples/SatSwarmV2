#!/bin/bash
# Run all SATLIB problems with <=50 variables on 1x1, 2x1, and 2x2 configurations
# and store the number of cycles for each run in a CSV file.
#
# Usage:
#   ./run_satlib_50v_benchmark.sh [TIMEOUT_SEC]
#
#   TIMEOUT_SEC  Wall-clock timeout per test (default: 120)
#
# Output:
#   logs/benchmark_results/satlib_50v_<timestamp>.csv
#   logs/benchmark_results/satlib_50v_<timestamp>.log

set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
cd "$SCRIPT_DIR/.." || exit 1
SIM_DIR=$(pwd)

TIMEOUT=${1:-120}   # Timeout per test in seconds

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_DIR="$SIM_DIR/../logs/benchmark_results"
mkdir -p "$RESULTS_DIR"
LOG_FILE="$RESULTS_DIR/satlib_50v_$TIMESTAMP.log"
CSV_FILE="$RESULTS_DIR/satlib_50v_$TIMESTAMP.csv"

echo "================================================================" | tee "$LOG_FILE"
echo "  SATLIB <=50-Variable Benchmark: 1x1, 2x1, 2x2" | tee -a "$LOG_FILE"
echo "================================================================" | tee -a "$LOG_FILE"
echo "Timestamp:  $TIMESTAMP" | tee -a "$LOG_FILE"
echo "Timeout:    ${TIMEOUT}s per test" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# ── Build binaries if missing ─────────────────────────────────────────────────
echo "Checking / building configurations..." | tee -a "$LOG_FILE"
for cfg in 1x1 2x1 2x2; do
    obj="$SIM_DIR/obj_dir_$cfg"
    if [ -x "$obj/Vtb_satswarmv2" ]; then
        echo "  ✓ $cfg binary ready" | tee -a "$LOG_FILE"
    else
        echo "  ✗ $cfg binary missing – building..." | tee -a "$LOG_FILE"
        (cd "$SIM_DIR" && make "build_$cfg") 2>&1 | tee -a "$LOG_FILE"
        if [ ! -x "$obj/Vtb_satswarmv2" ]; then
            echo "ERROR: Failed to build $cfg" | tee -a "$LOG_FILE"
            exit 1
        fi
        echo "  ✓ $cfg build complete" | tee -a "$LOG_FILE"
    fi
done
echo "" | tee -a "$LOG_FILE"

# ── Discover test files (<=50 variables) ─────────────────────────────────────
CNF_LIST=$(mktemp)
find tests/satlib tests/focused_satlib -name "*.cnf" 2>/dev/null | sort | while read -r f; do
    base=$(basename "$f")
    # Only process standard SATLIB naming: uf<N>-*.cnf / uuf<N>-*.cnf
    if [[ "$base" == uuf* ]]; then
        stub="${base#uuf}"
    elif [[ "$base" == uf* ]]; then
        stub="${base#uf}"
    else
        continue
    fi
    vars="${stub%%-*}"
    if [[ "$vars" =~ ^[0-9]+$ ]] && [ "$vars" -le 50 ]; then
        echo "$f"
    fi
done > "$CNF_LIST"

TOTAL=$(wc -l < "$CNF_LIST" | tr -d ' ')
echo "Found $TOTAL CNF files with <=50 variables." | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

if [ "$TOTAL" -eq 0 ]; then
    echo "No test files found under tests/satlib or tests/focused_satlib." | tee -a "$LOG_FILE"
    rm -f "$CNF_LIST"
    exit 1
fi

# ── CSV header ────────────────────────────────────────────────────────────────
echo "filename,type,vars,clauses,config,result,cycles" > "$CSV_FILE"

# ── Helper: run one (file, config) pair; prints cycles to stdout ──────────────
run_test() {
    local cnf_file="$1"
    local expected="$2"
    local config="$3"
    local obj_dir="$SIM_DIR/obj_dir_$config"
    local abs_cnf=$(realpath "$cnf_file")

    local output exit_code
    output=$(timeout "${TIMEOUT}s" \
        "$obj_dir/Vtb_satswarmv2" \
        +CNF="$abs_cnf" +EXPECT="$expected" +MAXCYCLES=5000000 +DEBUG=0 \
        2>&1) || exit_code=$?
    exit_code=${exit_code:-0}

    local result cycles
    if [ "$exit_code" -eq 124 ]; then
        result="TIMEOUT"
        cycles="0"
    elif echo "$output" | grep -q "TEST PASSED"; then
        result="PASS"
        cycles=$(echo "$output" | grep -oE "Cycles:[[:space:]]*[0-9]+" | head -1 | grep -oE "[0-9]+$")
        [ -z "$cycles" ] && cycles="0"
    else
        result="FAIL"
        cycles="0"
    fi

    echo "$result $cycles"
}

# ── Main loop ─────────────────────────────────────────────────────────────────
echo "================================================================" | tee -a "$LOG_FILE"
echo "  Running Tests" | tee -a "$LOG_FILE"
echo "================================================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

test_num=0
while IFS= read -r cnf_file; do
    test_num=$((test_num + 1))
    filename=$(basename "$cnf_file")

    # Determine expected result from filename prefix
    if [[ "$filename" == uuf* ]]; then
        expected="UNSAT"
        type_label="UNSAT"
    else
        expected="SAT"
        type_label="SAT"
    fi

    # Extract vars / clauses from the CNF header
    header=$(grep "^p cnf" "$cnf_file" 2>/dev/null | head -1)
    vars=$(echo "$header" | awk '{print $3}')
    clauses=$(echo "$header" | awk '{print $4}')

    printf "[%4d/%4d] %-26s " "$test_num" "$TOTAL" "$filename" | tee -a "$LOG_FILE"

    row=""
    for cfg in 1x1 2x1 2x2; do
        read -r result cycles <<< "$(run_test "$cnf_file" "$expected" "$cfg")"
        echo "$filename,$type_label,$vars,$clauses,$cfg,$result,$cycles" >> "$CSV_FILE"
        row="$row $cfg:${cycles}(${result})"
    done

    echo "$row" | tee -a "$LOG_FILE"
done < "$CNF_LIST"

rm -f "$CNF_LIST"

# ── Footer ────────────────────────────────────────────────────────────────────
echo "" | tee -a "$LOG_FILE"
echo "================================================================" | tee -a "$LOG_FILE"
echo "  Done" | tee -a "$LOG_FILE"
echo "================================================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Tests run:  $test_num (each on 1x1, 2x1, 2x2)" | tee -a "$LOG_FILE"
echo "CSV output: $CSV_FILE" | tee -a "$LOG_FILE"
echo "Log:        $LOG_FILE" | tee -a "$LOG_FILE"
