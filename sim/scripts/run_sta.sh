#!/bin/bash
set -e

# Run Yosys synthesis
echo "Running Yosys synthesis..."
yosys -s sim/scripts/synth_opensta.ys
echo "Yosys finished with exit code $?"

# Run OpenSTA
echo "Running OpenSTA..."
if [ -f "./tools/OpenSTA/build/sta" ]; then
    ./tools/OpenSTA/build/sta sim/scripts/sta.tcl
else
    echo "ERROR: sta binary not found at ./tools/OpenSTA/build/sta"
    exit 1
fi
