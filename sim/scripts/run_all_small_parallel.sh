#!/bin/bash

TESTS_DIR="tests/small_tests"
SOLVER="./obj_dir_mini/Vtb_mini"
MAXCYCLES=1000000
LOGFILE="logs/small_tests_results_parallel.log"
CPU_CORES=8

echo "Building Simulator..."
make mini > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi
echo "Build successful."

echo "Running tests in $TESTS_DIR with $CPU_CORES parallel jobs..."
echo "Logging to $LOGFILE"
echo "Test Name,Expected,Result,Cycles,Status" > $LOGFILE

# Function to run a single test (exported for xargs)
run_test() {
    f=$1
    SOLVER=$2
    MAXCYCLES=$3
    
    bn=$(basename $f)
    if [[ $bn == sat_* ]]; then
        expect="SAT"
        expect_arg="SAT"
    else
        expect="UNSAT"
        expect_arg="UNSAT"
    fi
    
    # Run solver
    out=$($SOLVER +CNF=$f +EXPECT=$expect_arg +MAXCYCLES=$MAXCYCLES)
    
    # Check result
    if echo "$out" | grep -F -q "*** TEST PASSED ***"; then
        result=$expect
        status="PASS"
        cycles=$(echo "$out" | grep "Cycles:" | awk '{print $2}')
        echo "$bn,$expect,$result,$cycles,$status"
    else
        status="FAIL"
        
        # Determine what happened
        if echo "$out" | grep -q "TIMEOUT"; then
            result="TIMEOUT"
        elif echo "$out" | grep -q "Result: SAT"; then
            result="SAT"
        elif echo "$out" | grep -q "Result: UNSAT"; then
            result="UNSAT"
        else
            result="ERROR"
        fi
        cycles=$(echo "$out" | grep "Cycles:" | awk '{print $2}')
        echo "$bn,$expect,$result,$cycles,$status"
        echo "FAILED: $bn (Exp: $expect, Got: $result)" >&2
    fi
}

export -f run_test

# Find files and run with xargs
find $TESTS_DIR -name "*.cnf" | \
    xargs -P $CPU_CORES -I {} bash -c "run_test '{}' '$SOLVER' '$MAXCYCLES'" >> $LOGFILE

# Analyze results
pass_cnt=$(grep -c ",PASS" $LOGFILE)
fail_cnt=$(grep -c ",FAIL" $LOGFILE)
total_cnt=$((pass_cnt + fail_cnt))

echo "------------------------------------------------"
echo "Final Results (Parallel Run):"
echo "Total: $total_cnt"
echo "Passed: $pass_cnt"
echo "Failed: $fail_cnt"
echo "------------------------------------------------"

# Print failures if any
if [ $fail_cnt -gt 0 ]; then
    echo "Failures:"
    grep ",FAIL" $LOGFILE
    exit 1
else
    exit 0
fi
