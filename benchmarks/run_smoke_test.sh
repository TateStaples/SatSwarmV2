#!/usr/bin/env bash
# run_smoke_test.sh — quick sanity check: runs uf50 and uuf50 (N instances each)
#
# Usage:
#   export GRID=1x1
#   bash benchmarks/run_smoke_test.sh

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BENCH_DIR="$REPO_ROOT/benchmarks/satlib_3sat"
HOST="${HOST:-$REPO_ROOT/hdk_cl_satswarm/host/satswarm_host}"
SLOT="${SLOT:-0}"
N="${N:-15}"
GRID="${GRID:-unknown}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUT_DIR="$REPO_ROOT/benchmarks/results/smoke_${TIMESTAMP}_${GRID}"

mkdir -p "$OUT_DIR"
RESULTS_MD="$OUT_DIR/results.md"
RESULTS_CSV="$OUT_DIR/results.csv"
RUN_LOG="$OUT_DIR/run.log"

DATASETS=(
  "sat/uf50:SAT:50:218:15"
  "unsat/uuf50:UNSAT:50:218:15"
)

if [[ ! -x "$HOST" ]]; then
  echo "ERROR: satswarm_host not found at: $HOST"
  exit 1
fi

cat > "$RESULTS_MD" <<EOF
# SatSwarm Smoke Test Results

- **Grid config**: $GRID
- **Run timestamp**: $TIMESTAMP
- **Instances per dataset**: $N
- **FPGA slot**: $SLOT

---

EOF

echo "dataset,subdir,instance,vars,clauses,expected,result,cycles,time_ms,wall_s,correct,timeout" > "$RESULTS_CSV"

echo "=== Smoke Test — $GRID — $(date) ===" | tee "$RUN_LOG"
echo ""

RUN_RESULT=""; RUN_CYCLES=""; RUN_TIME_MS=""; RUN_WALL_S=""; RUN_TIMEOUT=0

run_cnf() {
  local cnf_path="$1" timeout_sec="$2"
  RUN_RESULT=""; RUN_CYCLES=""; RUN_TIME_MS=""; RUN_WALL_S=""; RUN_TIMEOUT=0

  local t_start t_end
  t_start=$(date +%s%3N)
  local raw
  raw=$("$HOST" "$cnf_path" --slot "$SLOT" --timeout "$timeout_sec" --debug 0 2>&1 || true)
  t_end=$(date +%s%3N)
  RUN_WALL_S=$(echo "scale=3; ($t_end - $t_start) / 1000" | bc)

  echo "$raw" >> "$RUN_LOG"
  echo "" >> "$RUN_LOG"

  RUN_RESULT=$(printf "%s\n" "$raw" | sed -n 's/^Result:[[:space:]]*//p' | head -1 | tr -d '[:space:]')
  RUN_CYCLES=$(printf "%s\n" "$raw" | sed -n 's/^Cycles:[[:space:]]*//p' | head -1 | tr -d '[:space:]')

  [[ -z "$RUN_RESULT" ]] && RUN_RESULT="ERROR"
  [[ -z "$RUN_CYCLES" ]] && RUN_CYCLES="0"

  if printf "%s\n" "$raw" | grep -qi "timeout\|timed out"; then
    RUN_TIMEOUT=1; RUN_RESULT="TIMEOUT"
  fi

  if [[ "$RUN_CYCLES" =~ ^[0-9]+$ ]] && [[ "$RUN_CYCLES" -gt 0 ]]; then
    RUN_TIME_MS=$(echo "scale=3; $RUN_CYCLES / 15625" | bc)
  else
    RUN_TIME_MS="0"
  fi
}

TOTAL_CORRECT=0; TOTAL_RUN=0

for entry in "${DATASETS[@]}"; do
  IFS=':' read -r subdir expected vars clauses timeout_sec <<< "$entry"
  dataset_dir="$BENCH_DIR/$subdir"
  dataset_name=$(basename "$subdir")

  echo "━━━ $dataset_name ($expected, ${vars}v, ${clauses}c) ━━━" | tee -a "$RUN_LOG"

  if [[ ! -d "$dataset_dir" ]]; then
    echo "  SKIP — directory not found: $dataset_dir" | tee -a "$RUN_LOG"
    continue
  fi

  mapfile -t files < <(ls -1 "$dataset_dir"/*.cnf 2>/dev/null | sort -V | head -"$N")

  if [[ ${#files[@]} -eq 0 ]]; then
    echo "  SKIP — no .cnf files in $dataset_dir" | tee -a "$RUN_LOG"
    continue
  fi

  batch_correct=0; batch_timeout=0
  batch_cycles_sum=0; batch_cycles_count=0; batch_wall_sum=0
  table_rows=()

  for cnf_path in "${files[@]}"; do
    instance=$(basename "$cnf_path" .cnf)
    printf "  %-30s " "$instance" | tee -a "$RUN_LOG"

    run_cnf "$cnf_path" "$timeout_sec"

    correct=0
    if [[ "$RUN_RESULT" == "$expected" ]]; then
      correct=1; batch_correct=$((batch_correct + 1)); TOTAL_CORRECT=$((TOTAL_CORRECT + 1))
    fi
    [[ "$RUN_TIMEOUT" -eq 1 ]] && batch_timeout=$((batch_timeout + 1))

    if [[ "$RUN_TIMEOUT" -eq 0 && "$RUN_CYCLES" =~ ^[0-9]+$ && "$RUN_CYCLES" -gt 0 ]]; then
      batch_cycles_sum=$((batch_cycles_sum + RUN_CYCLES))
      batch_cycles_count=$((batch_cycles_count + 1))
    fi
    batch_wall_sum=$(echo "$batch_wall_sum + $RUN_WALL_S" | bc)

    status_icon="✓"; [[ "$correct" -eq 0 ]] && status_icon="✗"; [[ "$RUN_TIMEOUT" -eq 1 ]] && status_icon="T"
    printf "%s  result=%-8s  cycles=%-12s  time_ms=%-10s  wall=%.3fs\n" \
      "$status_icon" "$RUN_RESULT" "$RUN_CYCLES" "$RUN_TIME_MS" "$RUN_WALL_S" | tee -a "$RUN_LOG"

    TOTAL_RUN=$((TOTAL_RUN + 1))
    echo "$dataset_name,$subdir,$instance,$vars,$clauses,$expected,$RUN_RESULT,$RUN_CYCLES,$RUN_TIME_MS,$RUN_WALL_S,$correct,$RUN_TIMEOUT" >> "$RESULTS_CSV"
    table_rows+=("| $instance | $expected | $RUN_RESULT | $RUN_CYCLES | $RUN_TIME_MS | $RUN_WALL_S | $status_icon |")
  done

  mean_cycles="N/A"; mean_time_ms="N/A"
  if [[ "$batch_cycles_count" -gt 0 ]]; then
    mean_cycles=$(echo "$batch_cycles_sum / $batch_cycles_count" | bc)
    mean_time_ms=$(echo "scale=3; $mean_cycles / 15625" | bc)
  fi
  mean_wall=$(echo "scale=3; $batch_wall_sum / ${#files[@]}" | bc)
  n_run=${#files[@]}

  echo ""
  echo "  Summary: $batch_correct/$n_run correct, $batch_timeout timeouts, mean cycles=$mean_cycles" | tee -a "$RUN_LOG"
  echo ""

  {
    echo "## $dataset_name — $expected, ${vars} vars, ${clauses} clauses"
    echo ""
    echo "| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |"
    echo "|----------|----------|--------|--------|-----------|----------|-----|"
    for row in "${table_rows[@]}"; do echo "$row"; done
    echo ""
    echo "**Summary** — $batch_correct / $n_run correct &nbsp;|&nbsp; $batch_timeout timeouts &nbsp;|&nbsp; mean cycles: $mean_cycles &nbsp;|&nbsp; mean time: ${mean_time_ms} ms &nbsp;|&nbsp; mean wall: ${mean_wall}s"
    echo ""
    echo "---"
    echo ""
  } >> "$RESULTS_MD"
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "DONE — $TOTAL_CORRECT / $TOTAL_RUN correct"
echo "Results: $OUT_DIR"

{
  echo "## Overall"
  echo "- **Grid**: $GRID"
  echo "- **Total correct**: $TOTAL_CORRECT / $TOTAL_RUN"
  echo "- **Finished**: $(date)"
} >> "$RESULTS_MD"
