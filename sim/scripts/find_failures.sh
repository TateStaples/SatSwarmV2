#!/bin/bash
# Quick failure scanner
SIM_DIR="/home/ubuntu/src/project_data/SatSwarmV2/sim"
BIN="$SIM_DIR/obj_dir_1x1/Vtb_satswarmv2"
PATTERN="${1:-sat_5v_2*.cnf}"
MAXCYCLES="${2:-500000}"

for f in $SIM_DIR/tests/small_tests/$PATTERN; do
    OUT=$(timeout 10 "$BIN" +CNF="$f" +EXPECT=SAT +MAXCYCLES=$MAXCYCLES 2>&1)
    if echo "$OUT" | grep -q "TEST FAILED"; then
        echo "FAIL: $(basename $f)"
    fi
done
echo "=== SCAN COMPLETE ==="
