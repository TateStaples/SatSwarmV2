#!/bin/bash
# Benchmark script comparing 1-core vs 4-core SAT solver performance
# Measures actual hardware cycles on identical CNF problems

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SIM_DIR="$(dirname "$SCRIPT_DIR")"

# Binaries
SINGLE_CORE="$SIM_DIR/obj_dir/Vtb_single_core_debug"
MULTI_CORE="$SIM_DIR/obj_dir/Vtb_satswarmv2"

# Test files to benchmark (mix of sizes)
TESTS=(
    "tests/generated_instances/sat_10v_30c_1.cnf:SAT"
    "tests/generated_instances/sat_20v_80c_1.cnf:SAT"  
    "tests/generated_instances/sat_42v_178c_1.cnf:SAT"
)

MAX_CYCLES=500000

echo "=============================================="
echo "SAT Solver Benchmark: 1-Core vs 4-Core"
echo "=============================================="
echo ""

printf "%-30s %15s %15s %10s\n" "Problem" "1-Core Cycles" "4-Core Cycles" "Speedup"
printf "%-30s %15s %15s %10s\n" "-------" "-------------" "-------------" "-------"

for test_entry in "${TESTS[@]}"; do
    CNF_FILE="${test_entry%%:*}"
    EXPECT="${test_entry##*:}"
    BASENAME=$(basename "$CNF_FILE")
    
    cd "$SIM_DIR"
    
    # Run 1-core benchmark
    SINGLE_OUTPUT=$("$SINGLE_CORE" +CNF="$CNF_FILE" +EXPECT=$EXPECT +MAXCYCLES=$MAX_CYCLES 2>&1 || true)
    SINGLE_CYCLES=$(echo "$SINGLE_OUTPUT" | grep -o "Solve time: [0-9]*" | grep -o "[0-9]*" || echo "TIMEOUT")
    
    # Run 4-core benchmark  
    MULTI_OUTPUT=$("$MULTI_CORE" +CNF="$CNF_FILE" +EXPECT=$EXPECT +MAXCYCLES=$MAX_CYCLES +DEBUG=0 2>&1 || true)
    MULTI_CYCLES=$(echo "$MULTI_OUTPUT" | grep "Cycles:" | grep -o "[0-9]*" || echo "TIMEOUT")
    
    # Calculate speedup
    if [[ "$SINGLE_CYCLES" != "TIMEOUT" && "$MULTI_CYCLES" != "TIMEOUT" && "$MULTI_CYCLES" != "0" ]]; then
        SPEEDUP=$(echo "scale=2; $SINGLE_CYCLES / $MULTI_CYCLES" | bc)
    else
        SPEEDUP="N/A"
    fi
    
    printf "%-30s %15s %15s %10s\n" "$BASENAME" "$SINGLE_CYCLES" "$MULTI_CYCLES" "${SPEEDUP}x"
done

echo ""
echo "=============================================="
echo "Notes:"
echo "  - 'Cycles' = hardware clock cycles from start_solve to solve_done"
echo "  - Speedup > 1.0x means multi-core is faster"  
echo "  - Speedup < 1.0x means single-core is faster (overhead)"
echo "=============================================="
