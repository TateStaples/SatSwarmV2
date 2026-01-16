#!/bin/bash
# Usage: ./run_cnf.sh <cnf_file> [final_expect: SAT|UNSAT] [max_cycles]

if [ -z "$1" ]; then
    echo "Usage: ./run_cnf.sh <cnf_file> [SAT|UNSAT] [max_cycles]"
    exit 1
fi

CNF_FILE=$(realpath "$1")
EXPECTED=$2
MAXCYCLES=${3:-5000000}

# Determine script directory to find Makefile
SCRIPT_DIR=$(dirname "$(realpath "$0")")
SIM_DIR=$(dirname "$SCRIPT_DIR")

echo "Running CNF: $CNF_FILE"
if [ ! -z "$EXPECTED" ]; then
    echo "Expected Result: $EXPECTED"
fi
echo "Max Cycles: $MAXCYCLES"

cd "$SIM_DIR"

# Build checks removed for speed. Assume binary exists.
"${VERILATOR:-verilator}" --version >/dev/null 2>&1 || true

# Prefer the satswarmv2 testbench if available, otherwise fall back to regression_single
BIN="./obj_dir/Vtb_satswarmv2"
if [ ! -x "$BIN" ]; then
    BIN="./obj_dir/Vtb_regression_single"
fi

# Run the single regression executable with +CNF arg and a 120s timeout
# Run the single regression executable with +CNF arg and a 120s timeout
# Check for gtimeout (mac) or timeout (linux)
# Pass $@ to allow +DEBUG_LEVEL etc overrides
if command -v gtimeout &> /dev/null; then
    gtimeout 120s "$BIN" +CNF="$CNF_FILE" +EXPECT=$EXPECTED +MAXCYCLES=$MAXCYCLES "$@"
elif command -v timeout &> /dev/null; then
    timeout 120s "$BIN" +CNF="$CNF_FILE" +EXPECT=$EXPECTED +MAXCYCLES=$MAXCYCLES "$@"
else
    echo "Warning: timeout not found. Running without timeout."
    "$BIN" +CNF="$CNF_FILE" +EXPECT=$EXPECTED +MAXCYCLES=$MAXCYCLES "$@"
fi
exit $?
