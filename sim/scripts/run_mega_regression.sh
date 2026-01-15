#!/bin/bash
# Run all generated CNF instances in sim/tests/generated_instances using mega_sim.py

# Exit on error
set -e

# Directory setup
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SIM_DIR="$(dirname "$SCRIPT_DIR")"
TESTS_DIR="$SIM_DIR/tests/generated_instances"
MEGA_SIM="$SIM_DIR/mega_sim.py"

# Counters
TOTAL=0
PASSED=0
FAILED=0

echo "Starting Mega Sim Regression..."
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
        # Default to SAT if not specified, or skip? 
        # Most of these are structured. 
        continue
    fi
    
    TOTAL=$((TOTAL + 1))
    
    printf "  %-40s ... " "$BASENAME"
    
    # Run mega_sim.py, capturing only the Final Result line
    # Timeout after 30s to prevent hanging on new regressions
    RESULT=$(timeout 30s python3 "$MEGA_SIM" "$file" 2>/dev/null | grep "Final Result:" | awk '{print $3}') || RESULT="TIMEOUT"
    
    if [ "$RESULT" == "$EXPECTED" ]; then
        echo "PASSED"
        PASSED=$((PASSED + 1))
    else
        echo "FAILED (Got: $RESULT, Expected: $EXPECTED)"
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo "=================================================="
echo "Mega Sim Regression Summary"
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
