#!/bin/bash
# benchmark_clause_sharing.sh — Compare 1x1 (no sharing) vs 2x2 (with sharing) across problem sizes
#
# Usage: ./benchmark_clause_sharing.sh [timeout_seconds]
#
# Outputs CSV to stdout and saves to logs/

set -euo pipefail

SCRIPT_DIR=$(dirname "$(realpath "$0")")
SIM_DIR=$(dirname "$SCRIPT_DIR")
cd "$SIM_DIR"

TIMEOUT=${1:-120}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR="$SIM_DIR/logs/benchmark_results"
mkdir -p "$LOG_DIR"
OUTFILE="$LOG_DIR/clause_sharing_benchmark_${TIMESTAMP}.csv"

VERILATOR_FLAGS="-Wall --timing --sv --cc --exe \
  -Wno-fatal -Wno-UNUSED -Wno-PINCONNECTEMPTY -Wno-UNOPTFLAT \
  -Wno-INITIALDLY -Wno-WIDTHTRUNC -Wno-WIDTHEXPAND -Wno-MODDUP \
  -Wno-BLKANDNBLK -Wno-WIDTH -Wno-BLKLOOPINIT -Wno-SYNCASYNCNET"

RTL_SRCS="../src/Mega/satswarmv2_pkg.sv ../src/Mega/mega_pkg.sv ../src/Mega/interface_unit.sv \
  ../src/Mega/mesh_interconnect.sv ../src/Mega/global_mem_arbiter.sv ../src/Mega/global_allocator.sv \
  ../src/Mega/solver_core.sv ../src/Mega/satswarm_top.sv ../src/Mega/pse.sv ../src/Mega/cae.sv \
  ../src/Mega/vde.sv ../src/Mega/vde.sv ../src/Mega/vde_heap.sv ../src/Mega/trail_manager.sv \
  ../src/Mega/shared_clause_buffer.sv ../src/Mega/utils/sfifo.sv ../src/Mega/utils/stack.sv"

COMMON="-CFLAGS \"-std=c++17 -Wno-unknown-warning-option\" -I../src/Mega --build -j 8"
SIZING="-GMAX_VARS_PER_CORE=256 -GMAX_CLAUSES_PER_CORE=2048 -GMAX_LITS=16384"

build_config() {
    local name=$1 grid_x=$2 grid_y=$3 sharing=$4 dir=$5
    echo "[BUILD] $name (${grid_x}x${grid_y}, sharing=$sharing)..."
    mkdir -p "$dir"

    local mc_flag=""
    if [ "$grid_x" -gt 1 ] || [ "$grid_y" -gt 1 ]; then
        mc_flag="-DMULTICORE"
    fi

    verilator $VERILATOR_FLAGS \
        sv/tb_regression_single.sv cpp/sim_regression_single.cpp $RTL_SRCS \
        --top-module tb_regression_single \
        -GGRID_X=$grid_x -GGRID_Y=$grid_y \
        $SIZING \
        -GCLAUSE_SHARING_MODE=$sharing \
        $mc_flag \
        -CFLAGS "-std=c++17 -Wno-unknown-warning-option" \
        -I../src/Mega \
        -Mdir "$dir" \
        --build -j 8 2>&1 | tail -1
}

# Build all 3 configs (skip if binary already exists)
echo "=== Building configurations ==="
[ -x "obj_dir_bench_1x1/Vtb_regression_single" ]     || build_config "1x1_baseline" 1 1 0 "obj_dir_bench_1x1"
[ -x "obj_dir_bench_2x2_off/Vtb_regression_single" ] || build_config "2x2_noshare"  2 2 0 "obj_dir_bench_2x2_off"
[ -x "obj_dir_bench_2x2_on/Vtb_regression_single" ]  || build_config "2x2_binary"   2 2 1 "obj_dir_bench_2x2_on"

BIN_1x1="$SIM_DIR/obj_dir_bench_1x1/Vtb_regression_single"
BIN_2x2_OFF="$SIM_DIR/obj_dir_bench_2x2_off/Vtb_regression_single"
BIN_2x2_ON="$SIM_DIR/obj_dir_bench_2x2_on/Vtb_regression_single"

echo ""
echo "=== Benchmarking clause sharing ==="
echo "config,sharing_mode,test_file,vars,clauses,expected,result,cycles,wall_ms" | tee "$OUTFILE"

# Timeout command
if command -v gtimeout &>/dev/null; then
    TIMEOUT_CMD="gtimeout ${TIMEOUT}s"
elif command -v timeout &>/dev/null; then
    TIMEOUT_CMD="timeout ${TIMEOUT}s"
else
    TIMEOUT_CMD=""
fi

millis() {
    python3 -c "import time; print(int(time.time()*1000))"
}

run_test() {
    local config=$1 sharing=$2 bin=$3 cnf=$4 expect=$5
    local basename=$(basename "$cnf")

    # Extract vars/clauses from CNF header
    local header
    header=$(grep "^p " "$cnf" 2>/dev/null | head -1 || echo "p cnf 0 0")
    local vars=$(echo "$header" | awk '{print $3}')
    local clauses=$(echo "$header" | awk '{print $4}')

    # Time the run
    local start_ms=$(millis)
    local output
    output=$($TIMEOUT_CMD "$bin" +CNF="$cnf" +EXPECT="$expect" 2>&1) || true
    local end_ms=$(millis)
    local wall_ms=$((end_ms - start_ms))

    # Extract result and cycles
    local result="TIMEOUT"
    local cycles="-1"

    if echo "$output" | grep -q "TEST PASSED"; then
        result="PASS"
    elif echo "$output" | grep -q "TEST FAILED"; then
        result="FAIL"
    fi

    cycles=$(echo "$output" | grep "Cycles:" | head -1 | awk '{print $2}')
    cycles=${cycles:--1}

    # Print sharing stats if present
    local sharing_stats
    sharing_stats=$(echo "$output" | grep "SHARING STATS" || true)
    if [ -n "$sharing_stats" ]; then
        echo "  $sharing_stats" >&2
    fi

    echo "${config},${sharing},${basename},${vars},${clauses},${expect},${result},${cycles},${wall_ms}" | tee -a "$OUTFILE"
}

# ============================================================
# Test sets by problem size
# ============================================================

echo "" >&2
echo "--- 20-variable instances ---" >&2
for cnf in tests/eval_set/uf20-0{1,2,3,4,5}.cnf; do
    [ -f "$cnf" ] || continue
    run_test "1x1" "off"    "$BIN_1x1"     "$cnf" "SAT"
    run_test "2x2" "off"    "$BIN_2x2_OFF" "$cnf" "SAT"
    run_test "2x2" "binary" "$BIN_2x2_ON"  "$cnf" "SAT"
done

echo "" >&2
echo "--- 50-variable instances ---" >&2
for cnf in tests/aim/aim-50-1_6-yes1-{1,2}.cnf tests/aim/aim-50-1_6-no-{1,2}.cnf; do
    [ -f "$cnf" ] || continue
    local_expect="SAT"
    if echo "$cnf" | grep -q "\-no-"; then local_expect="UNSAT"; fi
    run_test "1x1" "off"    "$BIN_1x1"     "$cnf" "$local_expect"
    run_test "2x2" "off"    "$BIN_2x2_OFF" "$cnf" "$local_expect"
    run_test "2x2" "binary" "$BIN_2x2_ON"  "$cnf" "$local_expect"
done

echo "" >&2
echo "--- 100-variable instances ---" >&2
for cnf in tests/sat_accel/uf100-010.cnf tests/sat_accel/CBS_k3_n100_m403_b10_1.cnf; do
    [ -f "$cnf" ] || continue
    run_test "1x1" "off"    "$BIN_1x1"     "$cnf" "SAT"
    run_test "2x2" "off"    "$BIN_2x2_OFF" "$cnf" "SAT"
    run_test "2x2" "binary" "$BIN_2x2_ON"  "$cnf" "SAT"
done

echo "" >&2
echo "--- 100-variable UNSAT instances ---" >&2
for cnf in tests/sat_accel/uuf100-02.cnf; do
    [ -f "$cnf" ] || continue
    run_test "1x1" "off"    "$BIN_1x1"     "$cnf" "UNSAT"
    run_test "2x2" "off"    "$BIN_2x2_OFF" "$cnf" "UNSAT"
    run_test "2x2" "binary" "$BIN_2x2_ON"  "$cnf" "UNSAT"
done

echo "" >&2
echo "--- 125-variable instances ---" >&2
for cnf in tests/sat_accel/uf125-01.cnf; do
    [ -f "$cnf" ] || continue
    run_test "1x1" "off"    "$BIN_1x1"     "$cnf" "SAT"
    run_test "2x2" "off"    "$BIN_2x2_OFF" "$cnf" "SAT"
    run_test "2x2" "binary" "$BIN_2x2_ON"  "$cnf" "SAT"
done
for cnf in tests/sat_accel/uuf125-05.cnf; do
    [ -f "$cnf" ] || continue
    run_test "1x1" "off"    "$BIN_1x1"     "$cnf" "UNSAT"
    run_test "2x2" "off"    "$BIN_2x2_OFF" "$cnf" "UNSAT"
    run_test "2x2" "binary" "$BIN_2x2_ON"  "$cnf" "UNSAT"
done

echo ""
echo "=== Benchmark complete ==="
echo "Results saved to: $OUTFILE"
echo ""

# Quick analysis
echo "=== Cycle Comparison (lower is better) ==="
echo ""
python3 -c "
import csv, sys
from collections import defaultdict

data = defaultdict(dict)
with open('$OUTFILE') as f:
    reader = csv.DictReader(f)
    for row in reader:
        key = row['test_file']
        config = f\"{row['config']}_{row['sharing_mode']}\"
        data[key][config] = int(row['cycles']) if row['cycles'] != '-1' else None

print(f\"{'Test File':40s} {'1x1_off':>10s} {'2x2_off':>10s} {'2x2_binary':>12s} {'Speedup':>8s}\")
print('-' * 84)
for test, configs in sorted(data.items()):
    c1 = configs.get('1x1_off')
    c2 = configs.get('2x2_off')
    c3 = configs.get('2x2_binary')
    speedup = ''
    if c1 and c3 and c3 > 0:
        speedup = f'{c1/c3:.2f}x'
    elif c1 and c2 and c2 > 0:
        speedup = f'{c1/c2:.2f}x (no share)'
    print(f'{test:40s} {str(c1):>10s} {str(c2):>10s} {str(c3):>12s} {speedup:>8s}')
" 2>&1 || echo "(Python analysis skipped)"
