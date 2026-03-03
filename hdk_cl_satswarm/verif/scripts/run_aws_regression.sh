#!/bin/bash
# =============================================================================
# SatSwarm AWS FPGA Regression Runner
# Runs the Verilator RTL binary against all CNF files in sim/tests/.
# Uses sim/obj_dir_1x1/Vtb_satswarmv2 — much faster than XSim per-test.
# For the full AWS shell BFM integration test, see: make TEST=test_satswarm_aws
#
# Usage:
#   ./run_aws_regression.sh                          # Run all CNF files
#   ./run_aws_regression.sh --quick                  # Run ~10 small instances
#   ./run_aws_regression.sh -j 4                     # 4 parallel jobs
#   ./run_aws_regression.sh --dir /path/to/cnf       # Custom CNF directory
#   ./run_aws_regression.sh --verilator /path/to/bin # Custom Verilator binary
# =============================================================================
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(echo "$SCRIPT_DIR" | sed 's|/src/aws-fpga/.*||')"
CNF_DIR="${PROJECT_ROOT}/sim/tests/generated_instances"
LOG_DIR="$SCRIPT_DIR/logs/regression"
JOBS=1
QUICK=0
CUSTOM_DIR=""

# Verilator binary: much faster than XSim (seconds vs minutes per test)
VERILATOR_BIN="${PROJECT_ROOT}/sim/obj_dir_1x1/Vtb_satswarmv2"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
    echo "Usage: $0 [--quick] [-j N] [--dir PATH] [--verilator PATH]"
    echo "  --quick      Run only ~10 small CNF instances"
    echo "  -j N         Run N tests in parallel (default: 1)"
    echo "  --dir        Custom CNF directory (default: sim/tests)"
    echo "  --verilator  Custom Verilator binary path"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)      QUICK=1; shift ;;
        -j)           JOBS="$2"; shift 2 ;;
        --dir)        CUSTOM_DIR="$2"; shift 2 ;;
        --verilator)  VERILATOR_BIN="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

if [[ ! -x "$VERILATOR_BIN" ]]; then
    echo -e "${RED}ERROR: Verilator binary not found or not executable: $VERILATOR_BIN${NC}"
    echo "  Build it with: cd ${PROJECT_ROOT}/sim && make build_1x1"
    exit 1
fi

if [[ -n "$CUSTOM_DIR" ]]; then
    CNF_DIR="$CUSTOM_DIR"
fi

mkdir -p "$LOG_DIR"

# Determine expected result from filename
get_expected() {
    local f="$1"
    local base
    base=$(basename "$f")
    # AIM benchmarks: "yes" in name = SAT, "no" in name = UNSAT
    if [[ "$base" == *"-yes"* ]]; then echo "SAT"; return; fi
    if [[ "$base" == *"-no"* ]]; then echo "UNSAT"; return; fi
    # Uniform random 3-SAT: uf = SAT, uuf = UNSAT
    if [[ "$base" == uuf* ]]; then echo "UNSAT"; return; fi
    if [[ "$base" == uf* ]]; then echo "SAT"; return; fi
    # Pigeon hole: always UNSAT
    if [[ "$base" == hole* ]]; then echo "UNSAT"; return; fi
    # CBS benchmarks: check for _sat or _unsat in name
    if [[ "$base" == *"_unsat"* ]]; then echo "UNSAT"; return; fi
    if [[ "$base" == *"_sat"* ]]; then echo "SAT"; return; fi
    # Generated instances: unsat_* prefix
    if [[ "$base" == unsat_* ]]; then echo "UNSAT"; return; fi
    if [[ "$base" == sat_* ]]; then echo "SAT"; return; fi
    # Default: SAT (assume satisfiable if can't determine)
    echo "SAT"
}

# Collect CNF files
mapfile -t ALL_CNF < <(find "$CNF_DIR" -name "*.cnf" -type f | sort)

if [[ ${#ALL_CNF[@]} -eq 0 ]]; then
    echo -e "${RED}ERROR: No .cnf files found in $CNF_DIR${NC}"
    exit 1
fi

echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN} SatSwarm Regression Test Runner${NC}"
echo -e "${CYAN}=============================================${NC}"
echo "CNF directory: $CNF_DIR"
echo "Total files:   ${#ALL_CNF[@]}"

# Quick mode: select ~10 small instances
if [[ $QUICK -eq 1 ]]; then
    QUICK_CNF=()
    for f in "${ALL_CNF[@]}"; do
        base=$(basename "$f")
        # Pick small instances: aim-50 and uf100
        if [[ "$base" == aim-50-* ]] || [[ "$base" == uf100-* ]] || [[ "$base" == uuf100-* ]]; then
            QUICK_CNF+=("$f")
        fi
        [[ ${#QUICK_CNF[@]} -ge 10 ]] && break
    done
    ALL_CNF=("${QUICK_CNF[@]}")
    echo "Quick mode:    ${#ALL_CNF[@]} instances selected"
fi

echo "Parallelism:   $JOBS"
echo ""

# Results tracking
RESULTS_FILE="$LOG_DIR/results_$(date +%Y%m%d_%H%M%S).txt"
PASS_COUNT=0
FAIL_COUNT=0
TIMEOUT_COUNT=0
ERROR_COUNT=0
TOTAL=${#ALL_CNF[@]}

# Run a single test
run_one() {
    local cnf_file="$1"
    local base
    base=$(basename "$cnf_file" .cnf)
    local expected
    expected=$(get_expected "$cnf_file")
    local log_file="$LOG_DIR/${base}.log"

    # Run via Verilator binary directly — orders of magnitude faster than XSim
    # Note: +EXPECT= not +EXPECTED= (critical: wrong name silently defaults to SAT)
    "$VERILATOR_BIN" "+CNF=${cnf_file}" "+EXPECT=${expected}" \
        +MAXCYCLES=10000000 +DEBUG=0 \
        > "$log_file" 2>&1

    # Parse result
    local result="ERROR"
    if grep -q "TEST PASSED" "$log_file"; then
        result="PASS"
    elif grep -q "TEST FAILED" "$log_file"; then
        if grep -q "TIMEOUT" "$log_file"; then
            result="TIMEOUT"
        else
            result="FAIL"
        fi
    fi

    # Extract cycle count (Verilator outputs "  Cycles: N")
    local cycles=""
    cycles=$(grep -oP 'Cycles: \K[0-9]+' "$log_file" 2>/dev/null | tail -1)

    echo "${result} ${base} expected=${expected} cycles=${cycles:-N/A}"
}

echo -e "${CYAN}Running ${TOTAL} tests...${NC}"
echo ""

# Sequential or parallel execution
if [[ $JOBS -eq 1 ]]; then
    IDX=0
    for cnf_file in "${ALL_CNF[@]}"; do
        IDX=$((IDX + 1))
        base=$(basename "$cnf_file" .cnf)
        expected=$(get_expected "$cnf_file")
        printf "[%3d/%3d] %-50s " "$IDX" "$TOTAL" "$base"

        output=$(run_one "$cnf_file")
        result=$(echo "$output" | awk '{print $1}')

        case $result in
            PASS)    echo -e "${GREEN}PASS${NC} ($(echo "$output" | grep -oP 'cycles=\S+'))"; PASS_COUNT=$((PASS_COUNT + 1)) ;;
            FAIL)    echo -e "${RED}FAIL${NC}"; FAIL_COUNT=$((FAIL_COUNT + 1)) ;;
            TIMEOUT) echo -e "${YELLOW}TIMEOUT${NC}"; TIMEOUT_COUNT=$((TIMEOUT_COUNT + 1)) ;;
            *)       echo -e "${RED}ERROR${NC}"; ERROR_COUNT=$((ERROR_COUNT + 1)) ;;
        esac

        echo "$output" >> "$RESULTS_FILE"
    done
else
    export -f run_one get_expected
    export SCRIPT_DIR LOG_DIR VERILATOR_BIN
    printf '%s\n' "${ALL_CNF[@]}" | xargs -P "$JOBS" -I {} bash -c 'run_one "$@"' _ {} | tee -a "$RESULTS_FILE" | while read -r line; do
        result=$(echo "$line" | awk '{print $1}')
        name=$(echo "$line" | awk '{print $2}')
        case $result in
            PASS)    echo -e "${GREEN}PASS${NC} $name"; PASS_COUNT=$((PASS_COUNT + 1)) ;;
            FAIL)    echo -e "${RED}FAIL${NC} $name"; FAIL_COUNT=$((FAIL_COUNT + 1)) ;;
            TIMEOUT) echo -e "${YELLOW}TIMEOUT${NC} $name"; TIMEOUT_COUNT=$((TIMEOUT_COUNT + 1)) ;;
            *)       echo -e "${RED}ERROR${NC} $name"; ERROR_COUNT=$((ERROR_COUNT + 1)) ;;
        esac
    done
    # Recount from results file for parallel mode
    PASS_COUNT=$(grep "^PASS" "$RESULTS_FILE" 2>/dev/null | wc -l)
    FAIL_COUNT=$(grep "^FAIL" "$RESULTS_FILE" 2>/dev/null | wc -l)
    TIMEOUT_COUNT=$(grep "^TIMEOUT" "$RESULTS_FILE" 2>/dev/null | wc -l)
    ERROR_COUNT=$(grep "^ERROR" "$RESULTS_FILE" 2>/dev/null | wc -l)
fi

# Summary
echo ""
echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN} Regression Results${NC}"
echo -e "${CYAN}=============================================${NC}"
echo -e "  ${GREEN}PASS:    ${PASS_COUNT}${NC}"
echo -e "  ${RED}FAIL:    ${FAIL_COUNT}${NC}"
echo -e "  ${YELLOW}TIMEOUT: ${TIMEOUT_COUNT}${NC}"
echo -e "  ${RED}ERROR:   ${ERROR_COUNT}${NC}"
echo    "  TOTAL:   ${TOTAL}"
echo ""
echo "Results: $RESULTS_FILE"

# Failed tests detail
if [[ $FAIL_COUNT -gt 0 ]] || [[ $TIMEOUT_COUNT -gt 0 ]] || [[ $ERROR_COUNT -gt 0 ]]; then
    echo ""
    echo "Failed/Timeout/Error tests:"
    grep -E "^(FAIL|TIMEOUT|ERROR)" "$RESULTS_FILE" 2>/dev/null | while read -r line; do
        echo "  $line"
    done
fi

echo -e "${CYAN}=============================================${NC}"

# Exit with failure if any test failed
if [[ $FAIL_COUNT -gt 0 ]] || [[ $ERROR_COUNT -gt 0 ]]; then
    exit 1
fi
exit 0
