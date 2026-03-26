#!/usr/bin/env bash
# run_benchmark.sh — SatSwarm SATLIB 3-SAT benchmark runner
#
# Usage:
#   export GRID=1x1   # label for this run (1x1, 2x2, 2x2-none, 2x2-2clz, etc.)
#   bash benchmarks/run_benchmark.sh
#
# Optional env vars:
#   SLOT=0            FPGA slot (default 0)
#   N=15              instances per dataset (default 15)
#   HOST=<path>       path to satswarm_host binary

set -uo pipefail

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BENCH_DIR="$REPO_ROOT/benchmarks/satlib_3sat"
HOST="${HOST:-$REPO_ROOT/hdk_cl_satswarm/host/satswarm_host}"
SLOT="${SLOT:-0}"
N="${N:-15}"
GRID="${GRID:-unknown}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUT_DIR="$REPO_ROOT/benchmarks/results/${TIMESTAMP}_${GRID}"

mkdir -p "$OUT_DIR"

RESULTS_MD="$OUT_DIR/results.md"
RESULTS_CSV="$OUT_DIR/results.csv"
RUN_LOG="$OUT_DIR/run.log"

# ---------------------------------------------------------------------------
# Dataset definitions: "subdir:expected:vars:clauses:timeout_sec"
# Order mirrors VeriSAT TABLE II then extends to 250 vars
# ---------------------------------------------------------------------------
DATASETS=(
  "sat/uf50:SAT:50:218:15"
  "unsat/uuf50:UNSAT:50:218:15"
  "sat/uf75:SAT:75:325:20"
  "unsat/uuf75:UNSAT:75:325:20"
  "sat/uf100:SAT:100:430:30"
  "unsat/uuf100:UNSAT:100:430:30"
  "sat/uf125:SAT:125:538:45"
  "unsat/uuf125:UNSAT:125:538:45"
  "sat/uf150:SAT:150:645:60"
  "unsat/uuf150:UNSAT:150:645:60"
  "sat/uf175:SAT:175:754:90"
  "unsat/uuf175:UNSAT:175:754:90"
  "sat/uf200:SAT:200:860:120"
  "unsat/uuf200:UNSAT:200:860:120"
  "sat/uf225:SAT:225:962:150"
  "unsat/uuf225:UNSAT:225:962:150"
  "sat/uf250:SAT:250:1065:180"
  "unsat/uuf250:UNSAT:250:1065:180"
)

# ---------------------------------------------------------------------------
# Sanity checks
# ---------------------------------------------------------------------------
if [[ ! -x "$HOST" ]]; then
  echo "ERROR: satswarm_host not found or not executable at: $HOST"
  echo "       Build it first: cd hdk_cl_satswarm/host && make"
  exit 1
fi

if [[ "$GRID" == "unknown" ]]; then
  echo "WARNING: GRID not set. Set 'export GRID=1x1' (or 2x2 etc.) before running."
fi

# ---------------------------------------------------------------------------
# Init output files
# ---------------------------------------------------------------------------
cat > "$RESULTS_MD" <<EOF
# SatSwarm Benchmark Results

- **Grid config**: $GRID
- **Run timestamp**: $TIMESTAMP
- **Instances per dataset**: $N
- **FPGA slot**: $SLOT
- **Host binary**: $HOST

---

EOF

echo "dataset,subdir,instance,vars,clauses,expected,result,cycles,time_ms,wall_s,correct,timeout" > "$RESULTS_CSV"

echo "=== SatSwarm Benchmark — $GRID — $(date) ===" | tee "$RUN_LOG"
echo "Output dir: $OUT_DIR" | tee -a "$RUN_LOG"
echo "" | tee -a "$RUN_LOG"

# ---------------------------------------------------------------------------
# Helper: run one CNF, return parsed fields via globals
# ---------------------------------------------------------------------------
RUN_RESULT=""
RUN_CYCLES=""
RUN_TIME_MS=""
RUN_WALL_S=""
RUN_TIMEOUT=0

run_cnf() {
  local cnf_path="$1"
  local timeout_sec="$2"

  RUN_RESULT=""
  RUN_CYCLES=""
  RUN_TIME_MS=""
  RUN_WALL_S=""
  RUN_TIMEOUT=0

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

  # Detect timeout: host prints TIMEOUT or result is missing
  if printf "%s\n" "$raw" | grep -q "TIMEOUT after\|Result:.*TIMEOUT"; then
    RUN_TIMEOUT=1
    RUN_RESULT="TIMEOUT"
  fi

  # Convert cycles to ms at 15.625 MHz: ms = cycles / 15625
  if [[ "$RUN_CYCLES" =~ ^[0-9]+$ ]] && [[ "$RUN_CYCLES" -gt 0 ]]; then
    RUN_TIME_MS=$(echo "scale=3; $RUN_CYCLES / 15625" | bc)
  else
    RUN_TIME_MS="0"
  fi
}

# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------
TOTAL_CORRECT=0
TOTAL_RUN=0

for entry in "${DATASETS[@]}"; do
  IFS=':' read -r subdir expected vars clauses timeout_sec <<< "$entry"
  dataset_dir="$BENCH_DIR/$subdir"
  dataset_name=$(basename "$subdir")

  echo "━━━ $dataset_name ($expected, ${vars}v, ${clauses}c) ━━━" | tee -a "$RUN_LOG"

  if [[ ! -d "$dataset_dir" ]]; then
    echo "  SKIP — directory not found: $dataset_dir" | tee -a "$RUN_LOG"
    echo "" | tee -a "$RUN_LOG"
    continue
  fi

  # Select first N files in numeric order
  mapfile -t files < <(ls -1 "$dataset_dir"/*.cnf 2>/dev/null | sort -V | head -"$N")

  if [[ ${#files[@]} -eq 0 ]]; then
    echo "  SKIP — no .cnf files found in $dataset_dir" | tee -a "$RUN_LOG"
    echo "" | tee -a "$RUN_LOG"
    continue
  fi

  # Per-batch accumulators
  batch_correct=0
  batch_timeout=0
  batch_cycles_sum=0
  batch_cycles_count=0
  batch_wall_sum=0

  # Collect rows for markdown table
  table_rows=()

  for cnf_path in "${files[@]}"; do
    instance=$(basename "$cnf_path" .cnf)

    printf "  %-30s " "$instance" | tee -a "$RUN_LOG"

    run_cnf "$cnf_path" "$timeout_sec"

    # Correctness
    correct=0
    if [[ "$RUN_RESULT" == "$expected" ]]; then
      correct=1
      batch_correct=$((batch_correct + 1))
      TOTAL_CORRECT=$((TOTAL_CORRECT + 1))
    fi
    [[ "$RUN_TIMEOUT" -eq 1 ]] && batch_timeout=$((batch_timeout + 1))

    # Accumulate for averages (only non-timeout, non-error)
    if [[ "$RUN_TIMEOUT" -eq 0 && "$RUN_CYCLES" =~ ^[0-9]+$ && "$RUN_CYCLES" -gt 0 ]]; then
      batch_cycles_sum=$((batch_cycles_sum + RUN_CYCLES))
      batch_cycles_count=$((batch_cycles_count + 1))
    fi
    batch_wall_sum=$(echo "$batch_wall_sum + $RUN_WALL_S" | bc)

    status_icon="✓"
    [[ "$correct" -eq 0 ]] && status_icon="✗"
    [[ "$RUN_TIMEOUT" -eq 1 ]] && status_icon="T"

    printf "%s  result=%-8s  cycles=%-12s  time_ms=%-10s  wall=%.3fs\n" \
      "$status_icon" "$RUN_RESULT" "$RUN_CYCLES" "$RUN_TIME_MS" "$RUN_WALL_S" | tee -a "$RUN_LOG"

    TOTAL_RUN=$((TOTAL_RUN + 1))

    # Append to CSV
    echo "$dataset_name,$subdir,$instance,$vars,$clauses,$expected,$RUN_RESULT,$RUN_CYCLES,$RUN_TIME_MS,$RUN_WALL_S,$correct,$RUN_TIMEOUT" >> "$RESULTS_CSV"

    # Collect table row
    table_rows+=("| $instance | $expected | $RUN_RESULT | $RUN_CYCLES | $RUN_TIME_MS | $RUN_WALL_S | $status_icon |")
  done

  # -------------------------------------------------------------------------
  # Per-dataset summary
  # -------------------------------------------------------------------------
  mean_cycles="N/A"
  mean_time_ms="N/A"
  if [[ "$batch_cycles_count" -gt 0 ]]; then
    mean_cycles=$(echo "$batch_cycles_sum / $batch_cycles_count" | bc)
    mean_time_ms=$(echo "scale=3; $mean_cycles / 15625" | bc)
  fi

  mean_wall=$(echo "scale=3; $batch_wall_sum / ${#files[@]}" | bc)
  n_run=${#files[@]}

  echo "" | tee -a "$RUN_LOG"
  echo "  Summary: $batch_correct/$n_run correct, $batch_timeout timeouts, mean cycles=$mean_cycles, mean time=${mean_time_ms}ms" | tee -a "$RUN_LOG"
  echo "" | tee -a "$RUN_LOG"

  # -------------------------------------------------------------------------
  # Append markdown table to results.md
  # -------------------------------------------------------------------------
  {
    echo "## $dataset_name — $expected, ${vars} vars, ${clauses} clauses"
    echo ""
    echo "| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |"
    echo "|----------|----------|--------|--------|-----------|----------|-----|"
    for row in "${table_rows[@]}"; do
      echo "$row"
    done
    echo ""
    echo "**Summary** — $batch_correct / $n_run correct &nbsp;|&nbsp; $batch_timeout timeouts &nbsp;|&nbsp; mean cycles: $mean_cycles &nbsp;|&nbsp; mean time: ${mean_time_ms} ms &nbsp;|&nbsp; mean wall: ${mean_wall}s"
    echo ""
    echo "---"
    echo ""
  } >> "$RESULTS_MD"

done

# ---------------------------------------------------------------------------
# Final summary
# ---------------------------------------------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$RUN_LOG"
echo "DONE — $TOTAL_CORRECT / $TOTAL_RUN correct across all datasets" | tee -a "$RUN_LOG"
echo "Results: $OUT_DIR" | tee -a "$RUN_LOG"

{
  echo "## Overall Summary"
  echo ""
  echo "- **Grid**: $GRID"
  echo "- **Total correct**: $TOTAL_CORRECT / $TOTAL_RUN"
  echo "- **Finished**: $(date)"
} >> "$RESULTS_MD"

echo ""
echo "Results written to:"
echo "  $RESULTS_MD"
echo "  $RESULTS_CSV"
echo "  $RUN_LOG"
