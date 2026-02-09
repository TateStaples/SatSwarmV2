#!/bin/bash
# Speedup benchmark for 50-variable SATLIB instances
# Compares 2x2 and 3x3 configurations against 1x1 baseline

set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
cd "$SCRIPT_DIR/.." || exit 1
SIM_DIR=$(pwd)

# Configuration
NUM_TESTS=${1:-10}  # Number of tests per category (SAT/UNSAT)
TIMEOUT=${2:-180}   # Timeout per test in seconds

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_DIR="$SIM_DIR/../logs/benchmark_results"
mkdir -p "$RESULTS_DIR"
LOG_FILE="$RESULTS_DIR/speedup_50v_$TIMESTAMP.log"
CSV_FILE="$RESULTS_DIR/speedup_50v_$TIMESTAMP.csv"

echo "================================================================" | tee "$LOG_FILE"
echo "  50-Variable Speedup Benchmark" | tee -a "$LOG_FILE"
echo "================================================================" | tee -a "$LOG_FILE"
echo "Timestamp: $TIMESTAMP" | tee -a "$LOG_FILE"
echo "Tests per category: $NUM_TESTS SAT + $NUM_TESTS UNSAT" | tee -a "$LOG_FILE"
echo "Timeout: ${TIMEOUT}s per test" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Check binaries exist
echo "Checking configurations..." | tee -a "$LOG_FILE"
for cfg in 1x1 2x2 3x3; do
    obj="obj_dir_$cfg"
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
    head -n "$NUM_TESTS" "$SAT_FILES.all" > "$SAT_FILES"
    head -n "$NUM_TESTS" "$UNSAT_FILES.all" > "$UNSAT_FILES"
fi
rm -f "$SAT_FILES.all" "$UNSAT_FILES.all"

# CSV header
echo "filename,type,vars,clauses,1x1_cycles,2x2_cycles,3x3_cycles,2x2_speedup,3x3_speedup" > "$CSV_FILE"

# Arrays for aggregate statistics
declare -a ALL_2x2_SPEEDUPS
declare -a ALL_3x3_SPEEDUPS
declare -a SAT_2x2_SPEEDUPS
declare -a SAT_3x3_SPEEDUPS
declare -a UNSAT_2x2_SPEEDUPS
declare -a UNSAT_3x3_SPEEDUPS

run_single_test() {
    local cnf_file="$1"
    local expected="$2"
    local config="$3"
    local obj_dir="obj_dir_$config"
    
    local abs_cnf_file=$(realpath "$cnf_file")
    
    # Run test with timeout
    local output
    output=$(timeout "${TIMEOUT}s" "$SIM_DIR/$obj_dir/Vtb_satswarmv2" +CNF="$abs_cnf_file" +EXPECT="$expected" +MAXCYCLES=5000000 +DEBUG=0 2>&1)
    local exit_code=$?
    
    # Parse cycles from output
    local cycles="0"
    if [ $exit_code -ne 124 ] && echo "$output" | grep -q "TEST PASSED"; then
        # Try to extract cycles - format is "Cycles: XXXX"
        cycles=$(echo "$output" | grep -E "Cycles:" | head -1 | sed 's/.*Cycles:[[:space:]]*//' | tr -d ' ')
        [ -z "$cycles" ] && cycles="0"
    fi
    
    echo "$cycles"
}

echo "" | tee -a "$LOG_FILE"
echo "================================================================" | tee -a "$LOG_FILE"
echo "  Running Speedup Tests" | tee -a "$LOG_FILE"
echo "================================================================" | tee -a "$LOG_FILE"

test_num=0
total_tests=$((NUM_TESTS * 2))

run_test_set() {
    local file_list="$1"
    local expected="$2"
    local type_name="$3"
    
    while IFS= read -r cnf_file; do
        test_num=$((test_num + 1))
        filename=$(basename "$cnf_file")
        
        # Extract vars/clauses
        local header=$(grep "^p cnf" "$cnf_file" 2>/dev/null | head -1)
        local vars=$(echo "$header" | awk '{print $3}')
        local clauses=$(echo "$header" | awk '{print $4}')
        
        printf "[%2d/%2d] %-22s " "$test_num" "$total_tests" "$filename" | tee -a "$LOG_FILE"
        
        # Run all three configurations
        cycles_1x1=$(run_single_test "$cnf_file" "$expected" "1x1")
        cycles_2x2=$(run_single_test "$cnf_file" "$expected" "2x2")
        cycles_3x3=$(run_single_test "$cnf_file" "$expected" "3x3")
        
        # Calculate speedups
        if [ "$cycles_1x1" -gt 0 ] && [ "$cycles_2x2" -gt 0 ]; then
            speedup_2x2=$(echo "scale=2; $cycles_1x1 / $cycles_2x2" | bc)
        else
            speedup_2x2="N/A"
        fi
        
        if [ "$cycles_1x1" -gt 0 ] && [ "$cycles_3x3" -gt 0 ]; then
            speedup_3x3=$(echo "scale=2; $cycles_1x1 / $cycles_3x3" | bc)
        else
            speedup_3x3="N/A"
        fi
        
        # Store for aggregation
        if [ "$speedup_2x2" != "N/A" ]; then
            ALL_2x2_SPEEDUPS+=("$speedup_2x2")
            if [ "$expected" = "SAT" ]; then
                SAT_2x2_SPEEDUPS+=("$speedup_2x2")
            else
                UNSAT_2x2_SPEEDUPS+=("$speedup_2x2")
            fi
        fi
        
        if [ "$speedup_3x3" != "N/A" ]; then
            ALL_3x3_SPEEDUPS+=("$speedup_3x3")
            if [ "$expected" = "SAT" ]; then
                SAT_3x3_SPEEDUPS+=("$speedup_3x3")
            else
                UNSAT_3x3_SPEEDUPS+=("$speedup_3x3")
            fi
        fi
        
        # Output results
        printf "1x1:%6d  2x2:%6d (%.2fx)  3x3:%6d (%.2fx)\n" \
            "$cycles_1x1" "$cycles_2x2" "$speedup_2x2" "$cycles_3x3" "$speedup_3x3" | tee -a "$LOG_FILE"
        
        # CSV
        echo "$filename,$expected,$vars,$clauses,$cycles_1x1,$cycles_2x2,$cycles_3x3,$speedup_2x2,$speedup_3x3" >> "$CSV_FILE"
        
    done < "$file_list"
}

echo "" | tee -a "$LOG_FILE"
echo "--- SAT Tests (uf50-*) ---" | tee -a "$LOG_FILE"
run_test_set "$SAT_FILES" "SAT" "SAT"

echo "" | tee -a "$LOG_FILE"
echo "--- UNSAT Tests (uuf50-*) ---" | tee -a "$LOG_FILE"
run_test_set "$UNSAT_FILES" "UNSAT" "UNSAT"

# Cleanup
rm -f "$SAT_FILES" "$UNSAT_FILES"

# Calculate average speedups
calc_avg() {
    local arr=("$@")
    if [ ${#arr[@]} -eq 0 ]; then
        echo "N/A"
        return
    fi
    local sum=0
    for v in "${arr[@]}"; do
        sum=$(echo "$sum + $v" | bc)
    done
    echo "scale=2; $sum / ${#arr[@]}" | bc
}

avg_2x2_all=$(calc_avg "${ALL_2x2_SPEEDUPS[@]}")
avg_3x3_all=$(calc_avg "${ALL_3x3_SPEEDUPS[@]}")
avg_2x2_sat=$(calc_avg "${SAT_2x2_SPEEDUPS[@]}")
avg_3x3_sat=$(calc_avg "${SAT_3x3_SPEEDUPS[@]}")
avg_2x2_unsat=$(calc_avg "${UNSAT_2x2_SPEEDUPS[@]}")
avg_3x3_unsat=$(calc_avg "${UNSAT_3x3_SPEEDUPS[@]}")

# Summary
echo "" | tee -a "$LOG_FILE"
echo "================================================================" | tee -a "$LOG_FILE"
echo "  Speedup Summary (relative to 1x1 single-core)" | tee -a "$LOG_FILE"
echo "================================================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
printf "%-12s %12s %12s\n" "Category" "2x2 Speedup" "3x3 Speedup" | tee -a "$LOG_FILE"
printf "%-12s %12s %12s\n" "--------" "-----------" "-----------" | tee -a "$LOG_FILE"
printf "%-12s %11sx %11sx\n" "SAT" "$avg_2x2_sat" "$avg_3x3_sat" | tee -a "$LOG_FILE"
printf "%-12s %11sx %11sx\n" "UNSAT" "$avg_2x2_unsat" "$avg_3x3_unsat" | tee -a "$LOG_FILE"
printf "%-12s %11sx %11sx\n" "Overall" "$avg_2x2_all" "$avg_3x3_all" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Core count context
echo "Configuration details:" | tee -a "$LOG_FILE"
echo "  1x1: 1 core  (baseline)" | tee -a "$LOG_FILE"
echo "  2x2: 4 cores (ideal speedup: 4.0x)" | tee -a "$LOG_FILE"
echo "  3x3: 9 cores (ideal speedup: 9.0x)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

if [ "$avg_2x2_all" != "N/A" ]; then
    eff_2x2=$(echo "scale=1; $avg_2x2_all * 100 / 4" | bc)
    echo "  2x2 efficiency: ${eff_2x2}% of ideal" | tee -a "$LOG_FILE"
fi
if [ "$avg_3x3_all" != "N/A" ]; then
    eff_3x3=$(echo "scale=1; $avg_3x3_all * 100 / 9" | bc)
    echo "  3x3 efficiency: ${eff_3x3}% of ideal" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"
echo "Results CSV: $CSV_FILE" | tee -a "$LOG_FILE"
echo "Full log: $LOG_FILE" | tee -a "$LOG_FILE"
