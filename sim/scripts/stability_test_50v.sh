#!/bin/bash
# Stability test for 50-variable SATLIB instances across 1x1, 2x2, 3x3 configurations
# Tests both SAT (uf50-*) and UNSAT (uuf50-*) instances

set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
cd "$SCRIPT_DIR/.." || exit 1
SIM_DIR=$(pwd)

# Configuration
NUM_TESTS=${1:-10}  # Number of tests per category (SAT/UNSAT) - default 10
TIMEOUT=${2:-120}   # Timeout per test in seconds - default 120s

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_DIR="$SIM_DIR/../logs/benchmark_results"
mkdir -p "$RESULTS_DIR"
LOG_FILE="$RESULTS_DIR/stability_50v_$TIMESTAMP.log"
CSV_FILE="$RESULTS_DIR/stability_50v_$TIMESTAMP.csv"

echo "================================================================" | tee "$LOG_FILE"
echo "  50-Variable Stability Test - All Configurations" | tee -a "$LOG_FILE"
echo "================================================================" | tee -a "$LOG_FILE"
echo "Timestamp: $TIMESTAMP" | tee -a "$LOG_FILE"
echo "Tests per category: $NUM_TESTS SAT + $NUM_TESTS UNSAT = $((NUM_TESTS * 2)) total" | tee -a "$LOG_FILE"
echo "Timeout: ${TIMEOUT}s per test" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Check binaries exist
echo "Checking configurations..." | tee -a "$LOG_FILE"
CONFIGS=("1x1" "2x2" "3x3")
OBJ_DIRS=("obj_dir_1x1" "obj_dir_2x2" "obj_dir_3x3")

for i in 0 1 2; do
    cfg="${CONFIGS[$i]}"
    obj="${OBJ_DIRS[$i]}"
    if [ -x "$SIM_DIR/$obj/Vtb_satswarmv2" ]; then
        echo "  ✓ $cfg binary ready" | tee -a "$LOG_FILE"
    else
        echo "  ✗ $cfg binary missing - building..." | tee -a "$LOG_FILE"
        make build_${cfg} > /dev/null 2>&1
    fi
done

# Find test files
SAT_FILES=$(mktemp)
UNSAT_FILES=$(mktemp)

find tests/satlib/sat -name "uf50*.cnf" 2>/dev/null | sort > "$SAT_FILES.all"
find tests/satlib/unsat -name "uuf50*.cnf" 2>/dev/null | sort > "$UNSAT_FILES.all"

# Shuffle and select
if command -v gshuf > /dev/null; then
    gshuf "$SAT_FILES.all" | head -n "$NUM_TESTS" > "$SAT_FILES"
    gshuf "$UNSAT_FILES.all" | head -n "$NUM_TESTS" > "$UNSAT_FILES"
elif command -v shuf > /dev/null; then
    shuf "$SAT_FILES.all" | head -n "$NUM_TESTS" > "$SAT_FILES"
    shuf "$UNSAT_FILES.all" | head -n "$NUM_TESTS" > "$UNSAT_FILES"
else
    # Fallback: just take first N
    head -n "$NUM_TESTS" "$SAT_FILES.all" > "$SAT_FILES"
    head -n "$NUM_TESTS" "$UNSAT_FILES.all" > "$UNSAT_FILES"
fi
rm -f "$SAT_FILES.all" "$UNSAT_FILES.all"

SAT_COUNT=$(wc -l < "$SAT_FILES" | tr -d ' ')
UNSAT_COUNT=$(wc -l < "$UNSAT_FILES" | tr -d ' ')
echo "" | tee -a "$LOG_FILE"
echo "Selected: $SAT_COUNT SAT + $UNSAT_COUNT UNSAT tests" | tee -a "$LOG_FILE"

# CSV header
echo "filename,type,vars,clauses,config,result,cycles,time_sec" > "$CSV_FILE"

# Statistics arrays
declare -a PASS_1x1 PASS_2x2 PASS_3x3
declare -a FAIL_1x1 FAIL_2x2 FAIL_3x3
declare -a TIMEOUT_1x1 TIMEOUT_2x2 TIMEOUT_3x3

for cfg in 1x1 2x2 3x3; do
    eval "PASS_$cfg=0"
    eval "FAIL_$cfg=0"
    eval "TIMEOUT_$cfg=0"
done

run_single_test() {
    local cnf_file="$1"
    local expected="$2"
    local config="$3"
    local obj_dir="obj_dir_$config"
    local filename=$(basename "$cnf_file")
    
    # Get absolute path
    local abs_cnf_file=$(realpath "$cnf_file")
    
    # Extract vars/clauses from file
    local header=$(grep "^p cnf" "$cnf_file" 2>/dev/null | head -1)
    local vars=$(echo "$header" | awk '{print $3}')
    local clauses=$(echo "$header" | awk '{print $4}')
    
    # Run test with timeout using correct argument format
    local start_time=$(date +%s.%N)
    local output
    output=$(timeout "${TIMEOUT}s" "$SIM_DIR/$obj_dir/Vtb_satswarmv2" +CNF="$abs_cnf_file" +EXPECT="$expected" +MAXCYCLES=5000000 +DEBUG=0 2>&1)
    local exit_code=$?
    local end_time=$(date +%s.%N)
    local elapsed=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
    
    # Parse cycles (always attempt to capture raw count if present)
    local cycles="0"
    cycles=$(echo "$output" | grep -oE "Cycles: [0-9]+" | head -1 | awk '{print $2}')
    [ -z "$cycles" ] && cycles=$(echo "$output" | grep -oE "cycles=[0-9]+" | head -1 | cut -d= -f2)
    
    # Parse result
    local result="UNKNOWN"
    if [ $exit_code -eq 124 ]; then
        result="TIMEOUT"
    elif echo "$output" | grep -q "TEST PASSED"; then
        result="PASS"
    else
        result="FAIL"
    fi
    
    [ -z "$cycles" ] && cycles="0"
    
    # Output CSV
    echo "$filename,$expected,$vars,$clauses,$config,$result,$cycles,$elapsed" >> "$CSV_FILE"
    
    # Return result
    echo "$result"
}

echo "" | tee -a "$LOG_FILE"
echo "================================================================" | tee -a "$LOG_FILE"
echo "  Running Tests" | tee -a "$LOG_FILE"
echo "================================================================" | tee -a "$LOG_FILE"

test_num=0
total_tests=$((SAT_COUNT + UNSAT_COUNT))

# Run SAT tests
echo "" | tee -a "$LOG_FILE"
echo "--- SAT Tests (uf50-*) ---" | tee -a "$LOG_FILE"
while IFS= read -r cnf_file; do
    test_num=$((test_num + 1))
    filename=$(basename "$cnf_file")
    printf "[%2d/%2d] %-25s " "$test_num" "$total_tests" "$filename" | tee -a "$LOG_FILE"
    
    results=""
    for cfg in 1x1 2x2 3x3; do
        result=$(run_single_test "$cnf_file" "SAT" "$cfg")
        
        case "$result" in
            PASS)    
                results="$results $cfg:✓"
                eval "PASS_$cfg=\$((PASS_$cfg + 1))"
                ;;
            FAIL)    
                results="$results $cfg:✗"
                eval "FAIL_$cfg=\$((FAIL_$cfg + 1))"
                ;;
            TIMEOUT) 
                results="$results $cfg:T"
                eval "TIMEOUT_$cfg=\$((TIMEOUT_$cfg + 1))"
                ;;
            *)       
                results="$results $cfg:?"
                eval "FAIL_$cfg=\$((FAIL_$cfg + 1))"
                ;;
        esac
    done
    echo "$results" | tee -a "$LOG_FILE"
done < "$SAT_FILES"

# Run UNSAT tests
echo "" | tee -a "$LOG_FILE"
echo "--- UNSAT Tests (uuf50-*) ---" | tee -a "$LOG_FILE"
while IFS= read -r cnf_file; do
    test_num=$((test_num + 1))
    filename=$(basename "$cnf_file")
    printf "[%2d/%2d] %-25s " "$test_num" "$total_tests" "$filename" | tee -a "$LOG_FILE"
    
    results=""
    for cfg in 1x1 2x2 3x3; do
        result=$(run_single_test "$cnf_file" "UNSAT" "$cfg")
        
        case "$result" in
            PASS)    
                results="$results $cfg:✓"
                eval "PASS_$cfg=\$((PASS_$cfg + 1))"
                ;;
            FAIL)    
                results="$results $cfg:✗"
                eval "FAIL_$cfg=\$((FAIL_$cfg + 1))"
                ;;
            TIMEOUT) 
                results="$results $cfg:T"
                eval "TIMEOUT_$cfg=\$((TIMEOUT_$cfg + 1))"
                ;;
            *)       
                results="$results $cfg:?"
                eval "FAIL_$cfg=\$((FAIL_$cfg + 1))"
                ;;
        esac
    done
    echo "$results" | tee -a "$LOG_FILE"
done < "$UNSAT_FILES"

# Cleanup
rm -f "$SAT_FILES" "$UNSAT_FILES"

# Summary
echo "" | tee -a "$LOG_FILE"
echo "================================================================" | tee -a "$LOG_FILE"
echo "  Stability Test Summary" | tee -a "$LOG_FILE"
echo "================================================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Total tests: $total_tests ($SAT_COUNT SAT + $UNSAT_COUNT UNSAT)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

printf "%-8s %8s %8s %8s %10s\n" "Config" "Passed" "Failed" "Timeout" "Pass Rate" | tee -a "$LOG_FILE"
printf "%-8s %8s %8s %8s %10s\n" "------" "------" "------" "-------" "---------" | tee -a "$LOG_FILE"

all_passed=1
for cfg in 1x1 2x2 3x3; do
    eval "p=\$PASS_$cfg"
    eval "f=\$FAIL_$cfg"
    eval "t=\$TIMEOUT_$cfg"
    
    if [ $((p + f + t)) -gt 0 ]; then
        rate=$(echo "scale=1; $p * 100 / ($p + $f + $t)" | bc)
    else
        rate="0.0"
    fi
    
    printf "%-8s %8d %8d %8d %9s%%\n" "$cfg" "$p" "$f" "$t" "$rate" | tee -a "$LOG_FILE"
    
    if [ "$f" -gt 0 ] || [ "$t" -gt 0 ]; then
        all_passed=0
    fi
done

echo "" | tee -a "$LOG_FILE"
echo "Results: $CSV_FILE" | tee -a "$LOG_FILE"
echo "Log: $LOG_FILE" | tee -a "$LOG_FILE"

if [ "$all_passed" -eq 1 ]; then
    echo "" | tee -a "$LOG_FILE"
    echo "✓ ALL CONFIGURATIONS STABLE - 100% pass rate" | tee -a "$LOG_FILE"
    exit 0
else
    echo "" | tee -a "$LOG_FILE"
    echo "✗ STABILITY ISSUES DETECTED" | tee -a "$LOG_FILE"
    exit 1
fi
