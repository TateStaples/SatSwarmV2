#!/bin/bash
# Run all generated CNF instances in sim/tests/generated_instances

# Exit on error
set -e

# Directory setup
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SIM_DIR="$(dirname "$SCRIPT_DIR")"
TESTS_DIR="$SIM_DIR/tests/generated_instances"

# Counters
TOTAL=0
PASSED=0
FAILED=0

echo "Starting Bigger Ladder Regression..."
echo "Looking for tests in: $TESTS_DIR"

if [ ! -d "$TESTS_DIR" ]; then
    echo "Error: Tests directory not found!"
    exit 1
fi

# Find all .cnf files
FILES=$(find "$TESTS_DIR" -name "*.cnf" | sort)

if [ -z "$FILES" ]; then
    echo "No .cnf files found."
    exit 0
fi

for file in $FILES; do
    BASENAME=$(basename "$file")
    
    # Determine expected result based on filename
    EXPECTED=""
    if [[ "$BASENAME" == *"unsat"* || "$BASENAME" == *"UNSAT"* ]]; then
        EXPECTED="UNSAT"
    elif [[ "$BASENAME" == *"sat"* || "$BASENAME" == *"SAT"* ]]; then
        EXPECTED="SAT"
    else
        echo "Warning: Could not determine expected result for $BASENAME. Skipping."
        continue
    fi
    
    TOTAL=$((TOTAL + 1))
    
    printf "  %-40s ... " "$BASENAME"
    
    # Run the test, capturing output
    OUTPUT=$("$SCRIPT_DIR/run_cnf.sh" "$file" "$EXPECTED" 2>&1)
    
    if echo "$OUTPUT" | grep -q "TEST PASSED"; then
        echo "PASSED"
        PASSED=$((PASSED + 1))
    else
        echo "FAILED"
        FAILED=$((FAILED + 1))
        echo "--------------------------------------------------"
        echo "Test Failed: $BASENAME"
        echo "Command to run:"
        echo "$SCRIPT_DIR/run_cnf.sh $file $EXPECTED"
        echo "--------------------------------------------------"
        # Optionally exit on first failure if desired, but user didn't strictly specify.
        # run_ladder_tests.sh exits on first failure. I'll keep running for now as it's a "bigger" ladder, maybe we want to see all failures?
        # But commonly ladders stop on break. I'll stick to running all for now unless requested otherwise, adhering to "run all the files" from original request.
    fi
done

echo ""
echo "=================================================="
echo "Bigger Ladder Summary"
echo "=================================================="
echo "Total Tests: $TOTAL"
echo "Passed:      $PASSED"
echo "Failed:      $FAILED"
echo "=================================================="

if [ $FAILED -eq 0 ]; then
    echo "ALL TESTS PASSED"
    exit 0
else
    echo "SOME TESTS FAILED"
    exit 1
fi
