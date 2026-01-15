#!/bin/bash
# Usage: ./run_cnf.sh <cnf_file> [final_expect: SAT|UNSAT]

if [ -z "$1" ]; then
    echo "Usage: ./run_cnf.sh <cnf_file> [SAT|UNSAT]"
    exit 1
fi

CNF_FILE=$(realpath "$1")
EXPECTED=$2

# Determine script directory to find Makefile
SCRIPT_DIR=$(dirname "$(realpath "$0")")
SIM_DIR=$(dirname "$SCRIPT_DIR")

echo "Running CNF: $CNF_FILE"
if [ ! -z "$EXPECTED" ]; then
    echo "Expected Result: $EXPECTED"
fi

cd "$SIM_DIR"

# Build if needed (simples way is to rely on Make, but we want to just run the executable if possible to save time?
# Actually, calling make regression_single will recompile only if needed.
# But we need to pass args to the EXECUTABLE, not make.
# Build the regression target to ensure we have the correct executable
make regression_single > /dev/null

# Run the single regression executable with +CNF arg and a 10s timeout
# Simply run it directly - let timeout at bash level handle if needed
# The test should finish in <1s anyway

# Check for gtimeout
if command -v gtimeout &> /dev/null; then
    gtimeout 15s ./obj_dir/Vtb_regression_single +CNF="$CNF_FILE" +EXPECT="$EXPECTED"
else
    echo "Warning: gtimeout not found. Running without timeout."
    ./obj_dir/Vtb_regression_single +CNF="$CNF_FILE" +EXPECT="$EXPECTED"
fi
exit $?
