#!/bin/bash
# Runs tests in tests/small_tests grouped by variable count, ascending.
# Stops on first failure to encourage debugging on smallest identifiable case.

SCRIPT_DIR=$(dirname "$(realpath "$0")")
SIM_DIR=$(dirname "$SCRIPT_DIR")
TESTS_DIR="$SIM_DIR/tests/small_tests"

# Enable logging
if [ -z "$VERISAT_LOGGING" ]; then
    export VERISAT_LOGGING=1
    mkdir -p "$SIM_DIR/../logs"
    LOG_FILE="$SIM_DIR/../logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
    exec > >(tee -a "$LOG_FILE") 2>&1
fi

echo "=== SatSwarmv2 Regression Ladder Tests ==="
echo "Running tests in $TESTS_DIR"

if [ ! -d "$TESTS_DIR" ]; then
    echo "Error: tests/small_tests directory not found at $TESTS_DIR"
    exit 1
fi

# Get all unique variable counts (v sizes) present in the directory
v_counts=$(ls "$TESTS_DIR"/*.cnf 2>/dev/null | grep -o '[0-9]\+v' | sed 's/v//' | sort -un)

if [ -z "$v_counts" ]; then
    echo "No .cnf files found in $TESTS_DIR"
    exit 1
fi

total_passed=0
total_failed=0

for v in $v_counts; do
    echo ""
    echo "--- Testing ${v}v instances ---"
    
    # Get all tests for this v count
    tests_for_v=$(ls "$TESTS_DIR"/*_${v}v_*.cnf)
    num_tests=$(echo "$tests_for_v" | wc -l)
    
    echo "Found $num_tests instances."
    
    for test_file in $tests_for_v; do
        filename=$(basename "$test_file")
        
        # Auto-detect expectation from filename
        expect=""
        if [[ "$filename" == sat_* ]]; then
            expect="SAT"
        elif [[ "$filename" == unsat_* ]]; then
            expect="UNSAT"
        fi
        
        printf "  %-40s ... " "$filename"
        output=$("$SCRIPT_DIR/run_cnf.sh" "$test_file" "$expect")
        
        if echo "$output" | grep -q "TEST PASSED"; then
            echo "PASSED"
            total_passed=$((total_passed + 1))
        else
            echo "FAILED!"
            echo "--------------------------------------------------------"
            echo "STOPPING: Ladder test failed at ${v}v."
            echo "Debug the smallest failing case: $filename"
            echo "Run single test to debug: ./scripts/run_cnf.sh $test_file $expect"
            echo "--------------------------------------------------------"
            exit 1
        fi
    done
done

echo ""
echo "=== Ladder Test Summary ==="
echo "All tested instances passed!"
echo "Total Passed: $total_passed"
echo "VERIFICATION SUCCESSFUL"
