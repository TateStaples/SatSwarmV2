#!/usr/bin/env bash
# Benchmark clause sharing aggressiveness levels on 2x2 grid.
# Configs: mode0 (disabled), mode1/len2 (binary only), mode2/len3 (up to ternary), mode2/len4 (up to length 4)
# Runs each config on a range of problem sizes and reports cycle counts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SIM_DIR="$(dirname "$SCRIPT_DIR")"
cd "$SIM_DIR"

# Configs: label, obj_dir
declare -a CONFIGS=(
    "1x1_baseline|obj_dir"
    "2x2_disabled|obj_dir_sharing_2x2_m0_l2"
    "2x2_binary|obj_dir_sharing_2x2_m1_l2"
    "2x2_up3lit|obj_dir_sharing_2x2_m2_l3"
    "2x2_up4lit|obj_dir_sharing_2x2_m2_l4"
)

# Test instances: label|cnf_path|expected|timeout_cycles
declare -a TESTS=(
    # Small SAT (should see little benefit from sharing)
    "sat_20v_01|tests/eval_set/uf20-01.cnf|SAT|500000"
    "sat_20v_02|tests/eval_set/uf20-02.cnf|SAT|500000"
    "sat_20v_03|tests/eval_set/uf20-03.cnf|SAT|500000"
    "sat_20v_04|tests/eval_set/uf20-04.cnf|SAT|500000"
    "sat_20v_05|tests/eval_set/uf20-05.cnf|SAT|500000"
    # Medium SAT
    "sat_50v_1.6|tests/aim/aim-50-1_6-yes1-1.cnf|SAT|5000000"
    "sat_50v_2.0|tests/aim/aim-50-2_0-yes1-1.cnf|SAT|5000000"
    "sat_50v_3.4|tests/aim/aim-50-3_4-yes1-1.cnf|SAT|5000000"
    # Large SAT
    "sat_100v_a|tests/sat_accel/uf100-010.cnf|SAT|20000000"
    "sat_100v_b|tests/sat_accel/CBS_k3_n100_m403_b10_1.cnf|SAT|20000000"
    # UNSAT (typically more conflicts, sharing should help more)
    "unsat_50v_1.6|tests/aim/aim-50-1_6-no-1.cnf|UNSAT|5000000"
    "unsat_50v_2.0|tests/aim/aim-50-2_0-no-1.cnf|UNSAT|5000000"
)

RESULTS_FILE="$SIM_DIR/sharing_aggressiveness_results.csv"
echo "test,config,result,cycles,tx_attempts,tx_sent,rx_injected" > "$RESULTS_FILE"

echo ""
echo "================================================================="
echo " Clause Sharing Aggressiveness Benchmark (2x2 grid)"
echo " Configs: 1x1_baseline, 2x2_disabled, 2x2_binary, 2x2_up3lit, 2x2_up4lit"
echo " $(date)"
echo "================================================================="
echo ""

for test_entry in "${TESTS[@]}"; do
    IFS='|' read -r test_label cnf_path expected timeout <<< "$test_entry"

    if [ ! -f "$cnf_path" ]; then
        echo "SKIP: $test_label ($cnf_path not found)"
        continue
    fi

    echo "--- $test_label ($cnf_path) ---"

    for config_entry in "${CONFIGS[@]}"; do
        IFS='|' read -r config_label obj_dir <<< "$config_entry"

        binary="$obj_dir/Vtb_regression_single"
        if [ ! -x "$binary" ]; then
            echo "  $config_label: SKIP (binary not built)"
            echo "$test_label,$config_label,SKIP,0,0,0,0" >> "$RESULTS_FILE"
            continue
        fi

        # Run with timeout
        output=$("$binary" "+CNF=$cnf_path" "+EXPECT=$expected" "+TIMEOUT=$timeout" 2>&1) || true

        # Parse results (macOS-compatible sed instead of grep -oP)
        cycles=$(echo "$output" | sed -n 's/.*Cycles: \([0-9]*\).*/\1/p' | head -1)
        cycles=${cycles:-0}
        result=$(echo "$output" | sed -n 's/.*Result: \(PASS\).*/\1/p' | head -1)
        result=${result:-UNKNOWN}
        tx_att=$(echo "$output" | sed -n 's/.*tx_attempts=\([0-9]*\).*/\1/p' | head -1)
        tx_att=${tx_att:-0}
        tx_sent=$(echo "$output" | sed -n 's/.*tx_sent=\([0-9]*\).*/\1/p' | head -1)
        tx_sent=${tx_sent:-0}
        rx_inj=$(echo "$output" | sed -n 's/.*rx_injected=\([0-9]*\).*/\1/p' | head -1)
        rx_inj=${rx_inj:-0}

        # Check for timeout
        if echo "$output" | grep -q "TIMEOUT"; then
            result="TIMEOUT"
            cycles="$timeout"
        fi

        printf "  %-14s: %-7s %10s cycles  (tx=%s sent=%s rx=%s)\n" \
            "$config_label" "$result" "$cycles" "$tx_att" "$tx_sent" "$rx_inj"

        echo "$test_label,$config_label,$result,$cycles,$tx_att,$tx_sent,$rx_inj" >> "$RESULTS_FILE"
    done
    echo ""
done

echo "================================================================="
echo " Results saved to: $RESULTS_FILE"
echo "================================================================="

# Print summary table
echo ""
echo "=== CYCLE COUNT COMPARISON ==="
echo ""
printf "%-20s" "Test"
for config_entry in "${CONFIGS[@]}"; do
    IFS='|' read -r config_label _ <<< "$config_entry"
    printf "%14s" "$config_label"
done
printf "%14s\n" "best_delta%"

# Process CSV to build summary
tail -n +2 "$RESULTS_FILE" | while IFS= read -r line; do
    echo "$line"
done | awk -F',' '
{
    tests[$1] = 1
    data[$1][$2] = $4
}
END {
    for (t in tests) {
        printf "%-20s", t
        base = data[t]["2x2_disabled"]
        best = base
        for (c in data[t]) {
            v = data[t][c]
            printf "%14s", v
            if (v+0 < best+0 && v+0 > 0) best = v
        }
        if (base+0 > 0) {
            delta = (best - base) * 100.0 / base
            printf "%13.1f%%", delta
        }
        printf "\n"
    }
}
'
