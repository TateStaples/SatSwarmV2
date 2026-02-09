#!/bin/bash
# Comprehensive benchmark comparing 1-core, 4-core, and 9-core SAT solver
# Outputs CSV for statistical analysis

set -e

SIM_DIR="/Users/tatestaples/Code/SatSwarmV2/sim"
SINGLE_CORE="$SIM_DIR/obj_dir/Vtb_single_core_debug"
MULTI_4="$SIM_DIR/obj_dir/Vtb_satswarmv2"
MULTI_9="$SIM_DIR/obj_dir_3x3/Vtb_satswarmv2"

MAX_CYCLES=100000
TIMEOUT_SEC=120

# Test files grouped by size
TESTS=(
    # Small (5-10 vars)
    "sat_5v_10c_1.cnf"
    "sat_5v_10c_2.cnf"
    "sat_8v_20c_1.cnf"
    "sat_8v_20c_2.cnf"
    "sat_10v_30c_1.cnf"
    "sat_10v_30c_2.cnf"
    # Medium (12-20 vars)
    "sat_12v_40c_1.cnf"
    "sat_12v_40c_2.cnf"
    "sat_15v_50c_1.cnf"
    "sat_15v_50c_2.cnf"
    "sat_18v_70c_1.cnf"
    "sat_18v_70c_2.cnf"
    "sat_20v_80c_1.cnf"
    "sat_20v_80c_2.cnf"
    # Large (32+ vars)
    "sat_32v_136c_1.cnf"
    "sat_42v_178c_1.cnf"
    "sat_50v_215c_1.cnf"
    "sat_50v_215c_2.cnf"
    "sat_60v_258c_1.cnf"
    "sat_75v_325c_1.cnf"
)

cd "$SIM_DIR"

echo "benchmark,vars,1core_cycles,4core_cycles,9core_cycles,speedup_4v1,speedup_9v1,speedup_9v4"

for cnf in "${TESTS[@]}"; do
    CNF_PATH="tests/generated_instances/$cnf"
    
    # Extract var count from filename
    VARS=$(echo "$cnf" | grep -oE '[0-9]+v' | grep -oE '[0-9]+')
    
    # Run 1-core
    SINGLE_OUT=$(timeout ${TIMEOUT_SEC}s "$SINGLE_CORE" +CNF="$CNF_PATH" +EXPECT=SAT +MAXCYCLES=$MAX_CYCLES 2>&1 || true)
    SINGLE_CYCLES=$(echo "$SINGLE_OUT" | grep -o "Solve time: [0-9]*" | grep -o "[0-9]*" || echo "-1")
    
    # Run 4-core
    MULTI4_OUT=$(timeout ${TIMEOUT_SEC}s "$MULTI_4" +CNF="$CNF_PATH" +EXPECT=SAT +MAXCYCLES=$MAX_CYCLES +DEBUG=0 2>&1 || echo "TIMEOUT_OR_FAIL")
    if [[ "$MULTI4_OUT" == *"TIMEOUT_OR_FAIL"* ]]; then
         # Try capturing failure reason to a log (last few lines)
         echo "FAIL 4CORE $cnf: $MULTI4_OUT" >> logs/benchmark_failures.log
    fi
    MULTI4_CYCLES=$(echo "$MULTI4_OUT" | grep -o "Cycles: [0-9]*" | awk '{print $2}' || echo "-1")
    if [[ -z "$MULTI4_CYCLES" ]]; then MULTI4_CYCLES="-1"; fi
    
    # Run 9-core
    MULTI9_OUT=$(timeout ${TIMEOUT_SEC}s "$MULTI_9" +CNF="$CNF_PATH" +EXPECT=SAT +MAXCYCLES=$MAX_CYCLES +DEBUG=0 2>&1 || echo "TIMEOUT_OR_FAIL")
     if [[ "$MULTI9_OUT" == *"TIMEOUT_OR_FAIL"* ]]; then
         echo "FAIL 9CORE $cnf: $MULTI9_OUT" >> logs/benchmark_failures.log
    fi
    MULTI9_CYCLES=$(echo "$MULTI9_OUT" | grep -o "Cycles: [0-9]*" | awk '{print $2}' || echo "-1")
    if [[ -z "$MULTI9_CYCLES" ]]; then MULTI9_CYCLES="-1"; fi
    
    # Calculate speedups
    if [[ "$SINGLE_CYCLES" != "-1" && "$MULTI4_CYCLES" != "-1" && "$MULTI4_CYCLES" != "0" ]]; then
        SPEEDUP_4v1=$(echo "scale=2; $SINGLE_CYCLES / $MULTI4_CYCLES" | bc)
    else
        SPEEDUP_4v1="-"
    fi
    
    if [[ "$SINGLE_CYCLES" != "-1" && "$MULTI9_CYCLES" != "-1" && "$MULTI9_CYCLES" != "0" ]]; then
        SPEEDUP_9v1=$(echo "scale=2; $SINGLE_CYCLES / $MULTI9_CYCLES" | bc)
    else
        SPEEDUP_9v1="-"
    fi
    
    if [[ "$MULTI4_CYCLES" != "-1" && "$MULTI9_CYCLES" != "-1" && "$MULTI9_CYCLES" != "0" ]]; then
        SPEEDUP_9v4=$(echo "scale=2; $MULTI4_CYCLES / $MULTI9_CYCLES" | bc)
    else
        SPEEDUP_9v4="-"
    fi
    
    echo "$cnf,$VARS,$SINGLE_CYCLES,$MULTI4_CYCLES,$MULTI9_CYCLES,$SPEEDUP_4v1,$SPEEDUP_9v1,$SPEEDUP_9v4"
done
