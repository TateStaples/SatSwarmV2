#!/bin/bash
# Run regression tests with multiple MAX_VARS settings

# Exit on error
set -e

cd "$(dirname "$0")/.."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM_DIR="$SCRIPT_DIR/.."
# Enable logging
if [ -z "$VERISAT_LOGGING" ]; then
    export VERISAT_LOGGING=1
    mkdir -p "$SIM_DIR/../logs"
    LOG_FILE="$SIM_DIR/../logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
    exec > >(tee -a "$LOG_FILE") 2>&1
fi

echo "Starting Regression Sweep..."

# Configurations "MAX_VARS:MAX_CLAUSES"
CONFIGS=(
    "32:256"
    "42:300"
    "64:512"
    "128:1024"
)

for config in "${CONFIGS[@]}"; do
    IFS=":" read -r size clauses <<< "$config"
    lits=$((clauses * 4))
    if [ $lits -lt 2048 ]; then
        lits=2048
    fi
    echo "========================================"
    echo "Running Regression with MAX_VARS=$size MAX_CLAUSES=$clauses MAX_LITS=$lits"
    echo "========================================"
    make regression_single MAX_VARS=$size MAX_CLAUSES=$clauses MAX_LITS=$lits
    
    # Check if log suggests failure
    if grep -q "FAIL" "logs/regression_single_$size.log"; then
        echo "FAILURE detected for MAX_VARS=$size MAX_CLAUSES=$clauses"
    else
        echo "SUCCESS for MAX_VARS=$size MAX_CLAUSES=$clauses"
    fi
    echo ""
done

echo "Sweep Complete."
