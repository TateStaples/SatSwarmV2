#!/bin/bash
# Benchmark SatSwarmv2 SystemVerilog on tests/generated_instances
# Tests single-core (1x1), 2x2 mesh, and 3x3 mesh configurations
#
# Usage: ./benchmark_mega_mesh.sh [--rebuild] [--timeout SECONDS] [--tests COUNT]

set -e

# Configuration
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SIM_DIR="$(dirname "$SCRIPT_DIR")"
TESTS_DIR="$SIM_DIR/tests/generated_instances"
RESULTS_DIR="$SIM_DIR/../logs/benchmark_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="$RESULTS_DIR/mega_sv_benchmark_$TIMESTAMP.csv"
SUMMARY_FILE="$RESULTS_DIR/mega_sv_benchmark_$TIMESTAMP.txt"

# Default settings
REBUILD=0
TIMEOUT=120
TEST_COUNT=0  # 0 = all tests
DEBUG_LEVEL=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --rebuild)
            REBUILD=1
            shift
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --tests)
            TEST_COUNT="$2"
            shift 2
            ;;
        --debug)
            DEBUG_LEVEL="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--rebuild] [--timeout SECONDS] [--tests COUNT] [--debug LEVEL]"
            exit 1
            ;;
    esac
done

# Create results directory
mkdir -p "$RESULTS_DIR"

echo "=============================================================="
echo "SatSwarmv2 SystemVerilog Mega Benchmark"
echo "=============================================================="
echo "Timestamp: $TIMESTAMP"
echo "Timeout:   ${TIMEOUT}s per test"
echo "Tests Dir: $TESTS_DIR"
echo ""

cd "$SIM_DIR"

# Build all configurations if needed or requested
build_config() {
    local config=$1
    local obj_dir="obj_dir_$config"
    local binary="$obj_dir/Vtb_satswarmv2"
    
    if [[ $REBUILD -eq 1 ]] || [[ ! -x "$binary" ]]; then
        echo "Building $config configuration..."
        make "build_$config" 2>&1 | tail -5
        if [[ ! -x "$binary" ]]; then
            echo "ERROR: Failed to build $config configuration"
            return 1
        fi
        echo "  ✓ Built $config"
    else
        echo "  ✓ Using existing $config binary"
    fi
    return 0
}

echo "Checking/Building configurations..."
build_config "1x1" || exit 1
build_config "2x2" || exit 1
build_config "3x3" || exit 1
echo ""

# Get list of test files
if [[ ! -d "$TESTS_DIR" ]]; then
    echo "ERROR: Tests directory not found: $TESTS_DIR"
    exit 1
fi

FILES=$(find "$TESTS_DIR" -name "*.cnf" | sort)
TOTAL_FILES=$(echo "$FILES" | wc -l | tr -d ' ')

if [[ -z "$FILES" ]]; then
    echo "ERROR: No CNF files found in $TESTS_DIR"
    exit 1
fi

# Apply test count limit
if [[ $TEST_COUNT -gt 0 ]]; then
    FILES=$(echo "$FILES" | head -n "$TEST_COUNT")
    echo "Running $TEST_COUNT tests (limited from $TOTAL_FILES available)"
else
    echo "Running all $TOTAL_FILES tests"
fi
echo ""

# Initialize CSV
echo "filename,vars,clauses,expected,1x1_result,1x1_cycles,1x1_time,2x2_result,2x2_cycles,2x2_time,3x3_result,3x3_cycles,3x3_time" > "$RESULTS_FILE"

# Counters for each configuration (using simple variables instead of associative arrays)
PASSED_1x1=0; FAILED_1x1=0; TIMEOUTS_1x1=0; TOTAL_CYCLES_1x1=0; TOTAL_TIME_1x1=0
PASSED_2x2=0; FAILED_2x2=0; TIMEOUTS_2x2=0; TOTAL_CYCLES_2x2=0; TOTAL_TIME_2x2=0
PASSED_3x3=0; FAILED_3x3=0; TIMEOUTS_3x3=0; TOTAL_CYCLES_3x3=0; TOTAL_TIME_3x3=0

TESTS_RUN=0

# Run benchmark for a single file and configuration
run_test() {
    local cnf_file=$1
    local config=$2
    local expected=$3
    local binary="$SIM_DIR/obj_dir_$config/Vtb_satswarmv2"
    
    local start_time=$(python3 -c "import time; print(time.time())")
    
    # Run with timeout
    local output
    if command -v gtimeout &> /dev/null; then
        output=$(gtimeout "${TIMEOUT}s" "$binary" +CNF="$cnf_file" +EXPECT="$expected" +MAXCYCLES=10000000 +DEBUG=$DEBUG_LEVEL 2>&1) || true
    elif command -v timeout &> /dev/null; then
        output=$(timeout "${TIMEOUT}s" "$binary" +CNF="$cnf_file" +EXPECT="$expected" +MAXCYCLES=10000000 +DEBUG=$DEBUG_LEVEL 2>&1) || true
    else
        output=$("$binary" +CNF="$cnf_file" +EXPECT="$expected" +MAXCYCLES=10000000 +DEBUG=$DEBUG_LEVEL 2>&1) || true
    fi
    
    local end_time=$(python3 -c "import time; print(time.time())")
    local elapsed=$(python3 -c "print(f'{$end_time - $start_time:.3f}')")
    
    # Parse result
    local result="ERROR"
    local cycles=0
    
    if echo "$output" | grep -q "TEST PASSED"; then
        result="PASS"
    elif echo "$output" | grep -q "TEST FAILED"; then
        result="FAIL"
    elif echo "$output" | grep -q "TIMEOUT\|timeout"; then
        result="TIMEOUT"
    fi
    
    # Extract cycles if available
    local cycles_line=$(echo "$output" | grep -i "cycles\|Cycle count" | tail -1)
    if [[ -n "$cycles_line" ]]; then
        cycles=$(echo "$cycles_line" | grep -oE '[0-9]+' | head -1)
    fi
    
    # Also try to extract from "Solved in X cycles" pattern
    if [[ -z "$cycles" ]] || [[ "$cycles" -eq 0 ]]; then
        cycles=$(echo "$output" | grep -oE "Solved in [0-9]+" | grep -oE '[0-9]+' | head -1)
        cycles=${cycles:-0}
    fi
    
    echo "$result,$cycles,$elapsed"
}

# Main benchmark loop
echo "=============================================================="
echo "Running Benchmarks"
echo "=============================================================="
echo ""

for cnf_file in $FILES; do
    TESTS_RUN=$((TESTS_RUN + 1))
    BASENAME=$(basename "$cnf_file")
    
    # Determine expected result
    EXPECTED=""
    if [[ "$BASENAME" == *"unsat"* ]] || [[ "$BASENAME" == *"UNSAT"* ]]; then
        EXPECTED="UNSAT"
    elif [[ "$BASENAME" == *"sat"* ]] || [[ "$BASENAME" == *"SAT"* ]]; then
        EXPECTED="SAT"
    else
        echo "  ⚠ Skipping $BASENAME (unknown expected result)"
        continue
    fi
    
    # Parse CNF header for vars/clauses
    HEADER=$(grep "^p cnf" "$cnf_file" 2>/dev/null || echo "p cnf 0 0")
    VARS=$(echo "$HEADER" | awk '{print $3}')
    CLAUSES=$(echo "$HEADER" | awk '{print $4}')
    
    printf "[%3d] %-35s (%3dv, %4dc) %s\n" "$TESTS_RUN" "$BASENAME" "$VARS" "$CLAUSES" "$EXPECTED"
    
    # Run each configuration
    CSV_LINE="$BASENAME,$VARS,$CLAUSES,$EXPECTED"
    
    for config in 1x1 2x2 3x3; do
        printf "      $config: "
        
        RESULT_LINE=$(run_test "$cnf_file" "$config" "$EXPECTED")
        RESULT=$(echo "$RESULT_LINE" | cut -d',' -f1)
        CYCLES=$(echo "$RESULT_LINE" | cut -d',' -f2)
        TIME=$(echo "$RESULT_LINE" | cut -d',' -f3)
        
        CSV_LINE="$CSV_LINE,$RESULT,$CYCLES,$TIME"
        
        case "$RESULT" in
            PASS)
                printf "✓ %-7s %10s cycles  %7ss\n" "PASS" "$CYCLES" "$TIME"
                eval "PASSED_$config=\$((PASSED_$config + 1))"
                eval "TOTAL_CYCLES_$config=\$((TOTAL_CYCLES_$config + ${CYCLES:-0}))"
                ;;
            FAIL)
                printf "✗ %-7s %10s cycles  %7ss\n" "FAIL" "$CYCLES" "$TIME"
                eval "FAILED_$config=\$((FAILED_$config + 1))"
                ;;
            TIMEOUT)
                printf "⏱ %-7s                    %7ss\n" "TIMEOUT" "$TIME"
                eval "TIMEOUTS_$config=\$((TIMEOUTS_$config + 1))"
                ;;
            *)
                printf "? %-7s\n" "$RESULT"
                eval "FAILED_$config=\$((FAILED_$config + 1))"
                ;;
        esac
        
        # Accumulate time
        eval "TOTAL_TIME_$config=\$(python3 -c \"print(f'{float(\${TOTAL_TIME_$config}) + $TIME:.3f}')\")"
    done
    
    echo "$CSV_LINE" >> "$RESULTS_FILE"
    echo ""
done

# Generate summary
echo "=============================================================="
echo "Benchmark Summary"
echo "=============================================================="
echo ""

{
    echo "SatSwarmv2 SystemVerilog Mega Benchmark Summary"
    echo "================================================"
    echo "Timestamp: $TIMESTAMP"
    echo "Total Tests: $TESTS_RUN"
    echo "Timeout: ${TIMEOUT}s"
    echo ""
} | tee "$SUMMARY_FILE"

printf "%-12s %8s %8s %8s %12s %10s\n" "Config" "Passed" "Failed" "Timeout" "Avg Cycles" "Total Time" | tee -a "$SUMMARY_FILE"
printf "%-12s %8s %8s %8s %12s %10s\n" "------" "------" "------" "-------" "----------" "----------" | tee -a "$SUMMARY_FILE"

for config in 1x1 2x2 3x3; do
    eval "passed=\$PASSED_$config"
    eval "failed=\$FAILED_$config"
    eval "timeouts=\$TIMEOUTS_$config"
    eval "total_cycles=\$TOTAL_CYCLES_$config"
    eval "total_time=\$TOTAL_TIME_$config"
    
    if [[ $passed -gt 0 ]]; then
        avg_cycles=$((total_cycles / passed))
    else
        avg_cycles=0
    fi
    
    printf "%-12s %8d %8d %8d %12d %10.2fs\n" "$config" "$passed" "$failed" "$timeouts" "$avg_cycles" "$total_time" | tee -a "$SUMMARY_FILE"
done

echo "" | tee -a "$SUMMARY_FILE"
echo "Results CSV: $RESULTS_FILE" | tee -a "$SUMMARY_FILE"
echo "Summary: $SUMMARY_FILE" | tee -a "$SUMMARY_FILE"

# Report overall status
TOTAL_PASSED=$((PASSED_1x1 + PASSED_2x2 + PASSED_3x3))
TOTAL_FAILED=$((FAILED_1x1 + FAILED_2x2 + FAILED_3x3))
TOTAL_TIMEOUTS=$((TIMEOUTS_1x1 + TIMEOUTS_2x2 + TIMEOUTS_3x3))

echo ""
if [[ $TOTAL_FAILED -eq 0 ]] && [[ $TOTAL_TIMEOUTS -eq 0 ]]; then
    echo "✓ ALL TESTS PASSED"
    exit 0
else
    echo "⚠ Some tests failed or timed out"
    exit 1
fi
