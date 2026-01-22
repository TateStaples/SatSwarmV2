#!/bin/bash
# Mini DPLL SystemVerilog version of run_satlib.sh
# Runs SATLIB instances with mini_solver_core.sv (pure DPLL, no learned clauses)

# Defaults
CMD="./sim/scripts/run_mini_cnf.sh"
MAX_VARS=50
TEST_COUNT=""
DRY_RUN=0
# Quiet by default: only print failures and final summary
QUIET=1
RESULT_LOG="sim/scripts/mini_satlib_results.log"

SCRIPT_DIR=$(dirname "$(realpath "$0")")
# Go to repo root
cd "$SCRIPT_DIR/../.." || exit 1
REPO_ROOT=$(pwd)

# Parse Arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -vars|--vars)
      MAX_VARS="$2"
      shift 2
      ;;
    -tests|--tests)
      TEST_COUNT="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --quiet)
        QUIET=1
        shift
        ;;
    --verbose)
        QUIET=0
        shift
        ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Build the Mini solver if needed
cd sim
make mini || { echo "Error: Failed to build Mini solver"; exit 1; }
cd ..

if [ "$QUIET" -eq 0 ]; then
    echo "Mini DPLL SystemVerilog SATLIB Regression"
    echo "Using Mini SV solver (pure DPLL, no learned clauses)"
    echo "Searching for CNF files in sim/tests/satlib and sim/tests/focused_satlib..."
    echo "Filtering for <= $MAX_VARS variables..."
fi

# Find files
list_file=$(mktemp)
find sim/tests/satlib sim/tests/focused_satlib -name "*.cnf" 2>/dev/null | sort > "$list_file.raw"

filtered_count=0
while IFS= read -r f; do
    filename="${f##*/}"
    # Extract number. Filenames are like uf20-01.cnf or uuf50-01.cnf
    if [[ "$filename" == uuf* ]]; then
        stub="${filename#uuf}"
    elif [[ "$filename" == uf* ]]; then
        stub="${filename#uf}"
    else
        continue
    fi
    # Extract vars: everything before the first '-'
    vars="${stub%%-*}"
    
    if [[ "$vars" =~ ^[0-9]+$ ]]; then
        if [ "$vars" -le "$MAX_VARS" ]; then
            echo "$f" >> "$list_file"
            filtered_count=$((filtered_count + 1))
        fi
    fi
done < "$list_file.raw"
rm "$list_file.raw"

if [ "$QUIET" -eq 0 ]; then
    echo "Found $filtered_count files with <= $MAX_VARS variables."
fi

if [ "$filtered_count" -eq 0 ]; then
    echo "No files found."
    rm "$list_file"
    exit 0
fi

# Shuffle
if command -v gshuf > /dev/null; then
    shuffled_file=$(mktemp)
    gshuf "$list_file" > "$shuffled_file"
    mv "$shuffled_file" "$list_file"
elif command -v shuf > /dev/null; then
    shuffled_file=$(mktemp)
    shuf "$list_file" > "$shuffled_file"
    mv "$shuffled_file" "$list_file"
else
    # Fallback to perl if available
    if command -v perl > /dev/null; then
         perl -MList::Util=shuffle -e 'print shuffle(<STDIN>);' < "$list_file" > "$list_file.tmp" && mv "$list_file.tmp" "$list_file"
    fi
fi

# Apply count limit
if [ ! -z "$TEST_COUNT" ]; then
    if [ "$QUIET" -eq 0 ]; then
        echo "Randomly selecting $TEST_COUNT files..."
    fi
    head -n "$TEST_COUNT" "$list_file" > "$list_file.tmp" && mv "$list_file.tmp" "$list_file"
fi

total_to_run=$(wc -l < "$list_file" | xargs)
if [ "$QUIET" -eq 0 ]; then
    echo "Running $total_to_run tests..."
    echo "----------------------------------------"
fi

PASSED=0
FAILED=0
TOTAL=0

while IFS= read -r f; do
    TOTAL=$((TOTAL + 1))
    filename="${f##*/}"
    
    # Auto-detect expectation
    EXPECT=""
    if [[ "$filename" == uuf* ]]; then
        EXPECT="UNSAT"
    elif [[ "$filename" == uf* ]]; then
        EXPECT="SAT"
    fi
    
    if [ "$DRY_RUN" -eq 1 ]; then
        if [ "$QUIET" -eq 0 ]; then
            echo "[$TOTAL] Would run: $CMD $f $EXPECT"
        fi
    else
        if [ "$QUIET" -eq 0 ]; then
            printf "  %-50s ... " "$filename"
        fi
        
        # Run run_mini_cnf.sh and capture output
        OUTPUT=$($CMD "$f" "$EXPECT" 2>&1)
        
        # Check for TEST PASSED in output
        if echo "$OUTPUT" | grep -q "TEST PASSED"; then
            if [ "$QUIET" -eq 0 ]; then
                echo "PASSED"
            fi
            PASSED=$((PASSED + 1))
        else
            if [ "$QUIET" -eq 0 ]; then
                echo "FAILED"
            else
                echo "FAILED: $filename"
            fi
            
            {
                echo "--------------------------------------------------------"
                echo "Test Failed: $filename"
                echo "Command: $CMD $f $EXPECT"
                echo "--------------------------------------------------------"
            } >> "$RESULT_LOG"
            FAILED=$((FAILED + 1))
        fi
    fi
    
done < "$list_file"

rm "$list_file"

if [ "$DRY_RUN" -eq 0 ]; then
    if [ "$QUIET" -eq 0 ]; then
        echo "----------------------------------------"
    fi
    echo "Mini DPLL SV Summary: $PASSED passed, $FAILED failed out of $TOTAL tests."
    if [ $FAILED -gt 0 ]; then
        echo "Detailed failure logs can be found in: $RESULT_LOG"
        exit 1
    fi
fi

