#!/bin/bash

SAT_DIR="tests/small_tests"
SOLVER="./obj_dir_mini/Vtb_mini"
MAXCAYCLES=5000

echo "Building Simulator..."
make mini > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi
echo "Build successful."

pass_sat=0
fail_sat=0
pass_unsat=0
fail_unsat=0

echo "Running 3v SAT Tests..."
for f in $SAT_DIR/sat_3v_10c_*.cnf; do
    out=$($SOLVER +CNF=$f +MAXCYCLES=$MAXCAYCLES)
    if echo "$out" | grep -q "Result: SAT"; then
        ((pass_sat++))
        printf "."
    else
        ((fail_sat++))
        printf "F"
        echo "\nFailed: $f"
        echo "$out" | grep "Result"
        echo "$out" | grep "Conflict" | tail -1
    fi
done
echo ""

echo "Running 3v UNSAT Tests..."
for f in $SAT_DIR/unsat_3v_10c_*.cnf; do
    out=$($SOLVER +CNF=$f +MAXCYCLES=$MAXCAYCLES)
    if echo "$out" | grep -q "Result: UNSAT"; then
        ((pass_unsat++))
        printf "."
    else
        ((fail_unsat++))
        printf "F"
        echo "\nFailed: $f"
        echo "$out" | grep "Result"
    fi
done
echo ""

echo "------------------------------------------------"
echo "Results:"
echo "SAT Tests:   $pass_sat PASSED, $fail_sat FAILED"
echo "UNSAT Tests: $pass_unsat PASSED, $fail_unsat FAILED"
echo "------------------------------------------------"

if [ $fail_sat -eq 0 ] && [ $fail_unsat -eq 0 ]; then
    exit 0
else
    exit 1
fi
