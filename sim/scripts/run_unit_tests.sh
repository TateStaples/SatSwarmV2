#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM_DIR="$SCRIPT_DIR/.."
SRC_DIR="$SIM_DIR/../src/Mega"

# Helper function to run a test
run_test() {
    local TB_NAME=$1
    shift
    local SRC_FILES=("$@")
    
    echo "----------------------------------------"
    echo "Running $TB_NAME (Verilator)..."
    
    # Generate C++ Wrapper
    cat <<EOF > "$SIM_DIR/cpp/sim_${TB_NAME}.cpp"
#include "V${TB_NAME}.h"
#include "verilated.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    V${TB_NAME}* top = new V${TB_NAME}{contextp};

    while (!contextp->gotFinish()) {
        contextp->timeInc(1);
        top->eval();
    }
    
    // Check if test passed (exit code usually 0, but we parse output)
    delete top;
    delete contextp;
    return 0;
}
EOF

    # Compile with Verilator
    # Note: We include all source files to be safe, or just the ones needed.
    # Verilator finds modules automatically if we provide include paths (-I).
    # But we need to specify the TOP module file explicitly.
    
    if ! verilator --cc --exe --timing \
        --Wno-fatal --Wno-UNUSED --Wno-PINCONNECTEMPTY --Wno-UNOPTFLAT \
        --Wno-INITIALDLY --Wno-WIDTHTRUNC --Wno-WIDTHEXPAND --Wno-MODDUP \
        --Wno-BLKANDNBLK --Wno-WIDTH \
        -CFLAGS "-std=c++17" \
        -I"$SRC_DIR" \
        --top-module "$TB_NAME" \
        -o "${TB_NAME}" \
        --Mdir "$SIM_DIR/obj_dir/${TB_NAME}_dir" \
        "$SIM_DIR/sv/$TB_NAME.sv" \
        "$SIM_DIR/cpp/sim_${TB_NAME}.cpp" \
        "$SRC_DIR/satswarmv2_pkg.sv" \
        "${SRC_FILES[@]}" \
        --build -j 4 > "$SIM_DIR/logs/${TB_NAME}_compile.log" 2>&1; then
        echo "COMPILATION FAILED"
        cat "$SIM_DIR/logs/${TB_NAME}_compile.log"
        return 1
    fi

    # Run simulation
    if ! "$SIM_DIR/obj_dir/${TB_NAME}_dir/${TB_NAME}" > "$SIM_DIR/logs/$TB_NAME.log"; then
        echo "SIMULATION FAILED (Runtime Error)"
        return 1
    fi
    
    # Check output
    if grep -q "ERROR" "$SIM_DIR/logs/$TB_NAME.log" || grep -q "Failed" "$SIM_DIR/logs/$TB_NAME.log" || grep -q "Error" "$SIM_DIR/logs/$TB_NAME.log" || grep -q "TIMEOUT" "$SIM_DIR/logs/$TB_NAME.log"; then
        echo "FAIL"
        cat "$SIM_DIR/logs/$TB_NAME.log"
        return 1
    else
        echo "PASS"
    fi
}

mkdir -p "$SIM_DIR/logs"
mkdir -p "$SIM_DIR/cpp"

# Run tests with specific dependencies
FAIL=0
run_test "tb_vde" "$SRC_DIR/vde.sv" || FAIL=1
run_test "tb_trail_manager" "$SRC_DIR/trail_manager.sv" || FAIL=1
run_test "tb_cae" "$SRC_DIR/cae.sv" || FAIL=1
