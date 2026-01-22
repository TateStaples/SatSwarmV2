#!/bin/bash
# Run all generated CNF instances in sim/tests/generated_instances using Mini DPLL SystemVerilog
# Uses mini_solver_core.sv (pure DPLL solver without CAE/learned clauses)

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

echo "Starting Mini DPLL SystemVerilog Bigger Ladder Regression..."
echo "Using Mini SV solver (pure DPLL, no learned clauses)"
echo "Looking for tests in: $TESTS_DIR"

if [ ! -d "$TESTS_DIR" ]; then
    echo "Error: Tests directory not found!"
    exit 1
fi

# Build the Mini solver if needed
cd "$SIM_DIR"
make mini || { echo "Error: Failed to build Mini solver"; exit 1; }
cd - > /dev/null

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
    
    # Run run_mini_cnf.sh and capture output
    OUTPUT=$("$SCRIPT_DIR/run_mini_cnf.sh" "$file" "$EXPECTED" 2>&1)
    
    if echo "$OUTPUT" | grep -q "TEST PASSED"; then
        echo "PASSED"
        PASSED=$((PASSED + 1))
    else
        echo "FAILED"
        FAILED=$((FAILED + 1))
        echo "--------------------------------------------------"
        echo "Test Failed: $BASENAME"
        echo "Command to run:"
        echo "$SCRIPT_DIR/run_mini_cnf.sh $file $EXPECTED"
        echo "--------------------------------------------------"
    fi
done

echo ""
echo "=================================================="
echo "Mini DPLL SV Bigger Ladder Summary"
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

