#!/bin/bash
# Usage: ./run_mini_cnf.sh <cnf_file> [final_expect: SAT|UNSAT] [max_cycles]
# Runs the Mini DPLL SystemVerilog solver

if [ -z "$1" ]; then
    echo "Usage: ./run_mini_cnf.sh <cnf_file> [SAT|UNSAT] [max_cycles]"
    exit 1
fi

CNF_FILE=$(realpath "$1")
EXPECTED=$2
MAXCYCLES=${3:-5000000}

# Determine script directory to find Makefile
SCRIPT_DIR=$(dirname "$(realpath "$0")")
SIM_DIR=$(dirname "$SCRIPT_DIR")

echo "Running Mini DPLL on CNF: $CNF_FILE"
if [ ! -z "$EXPECTED" ]; then
    echo "Expected Result: $EXPECTED"
fi
echo "Max Cycles: $MAXCYCLES"

cd "$SIM_DIR"

# Build if needed
BIN="$SIM_DIR/obj_dir_mini/Vtb_mini"
if [ ! -x "$BIN" ]; then
    echo "Building Mini DPLL simulator..."
    make mini
fi

if [ ! -x "$BIN" ]; then
    echo "ERROR: Failed to build Mini DPLL simulator"
    exit 1
fi

# Run the Mini testbench with a 120s timeout
if command -v gtimeout &> /dev/null; then
    gtimeout 120s "$BIN" +CNF="$CNF_FILE" +EXPECT=$EXPECTED +MAXCYCLES=$MAXCYCLES +DEBUG=0 "$@"
elif command -v timeout &> /dev/null; then
    timeout 120s "$BIN" +CNF="$CNF_FILE" +EXPECT=$EXPECTED +MAXCYCLES=$MAXCYCLES +DEBUG=0 "$@"
else
    echo "Warning: timeout not found. Running without timeout."
    "$BIN" +CNF="$CNF_FILE" +EXPECT=$EXPECTED +MAXCYCLES=$MAXCYCLES +DEBUG=0 "$@"
fi
exit $?
