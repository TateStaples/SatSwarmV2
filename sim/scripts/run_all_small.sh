#!/bin/bash

TESTS_DIR="tests/small_tests"
SOLVER="./obj_dir_mini/Vtb_mini"
MAXCYCLES=1000000
LOGFILE="logs/small_tests_results.log"

echo "Building Simulator..."
make mini > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi
echo "Build successful."

echo "Running tests in $TESTS_DIR..."
echo "Logging to $LOGFILE"
echo "Test Name,Expected,Result,Cycles,Status" > $LOGFILE

pass_cnt=0
fail_cnt=0
total_cnt=0

# Create temp list
ls $TESTS_DIR/*.cnf > small_tests_list.txt

while read f; do
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
        ((pass_cnt++))
    else
        status="FAIL"
        ((fail_cnt++))
        
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
        echo "FAILED: $bn (Exp: $expect, Got: $result)"
    fi
    
    cycles=$(echo "$out" | grep "Cycles:" | awk '{print $2}')
    echo "$bn,$expect,$result,$cycles,$status" >> $LOGFILE
    
    ((total_cnt++))
    if (( total_cnt % 50 == 0 )); then
        echo "Progress: $total_cnt tests run ($pass_cnt Pass, $fail_cnt Fail)"
    fi
    
done < small_tests_list.txt

echo "------------------------------------------------"
echo "Final Results:"
echo "Total: $total_cnt"
echo "Passed: $pass_cnt"
echo "Failed: $fail_cnt"
echo "Check $LOGFILE for details."
echo "------------------------------------------------"

if [ $fail_cnt -eq 0 ]; then
    exit 0
else
    exit 1
fi
