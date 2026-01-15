#!/bin/bash
# Replaces run_satlib.py. Runs SATLIB instances with filtering and defaults.

# Defaults
CMD="./sim/scripts/run_cnf.sh"
MAX_VARS=50
TEST_COUNT=""
DRY_RUN=0

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
    *)
      # Assume it's the command if not a flag, but we default CMD already.
      # If user passes a command, use it.
      if [[ "$1" != -* ]]; then
          CMD="$1"
          shift
      else
          echo "Unknown option: $1"
          exit 1
      fi
      ;;
  esac
done

echo "Searching for CNF files in sim/tests/satlib and sim/tests/focused_satlib..."
echo "Filtering for <= $MAX_VARS variables..."

# Find files
# We look in both directories.
# We need to filter by variable count. Filenames are like uuf50-218.cnf or uf20-01.cnf
# We use a loop to process files potentially cleanly.

# Collect all candidates
candidates=()
# We use find to get paths. 
# Notes: 
# - Mac `find` doesn't support regex cleanly without -E usually.
# - We can pipe to awk or grep to filter.



# Find all .cnf files in the target dirs
# We process line by line.
list_file=$(mktemp)
find sim/tests/satlib sim/tests/focused_satlib -name "*.cnf" 2>/dev/null | sort > "$list_file.raw"


filtered_files=()

while IFS= read -r f; do
    filename="${f##*/}"
    # Extract number. Filenames are like uf20-01.cnf or uuf50-01.cnf or sat_... (satlib usually uf/uuf)
    # Fast string manipulation
    # Remove prefix 'u' if present (uuf -> uf)
    if [[ "$filename" == uuf* ]]; then
        stub="${filename#uuf}"
    elif [[ "$filename" == uf* ]]; then
        stub="${filename#uf}"
    else
        # Not a logical match for SATLIB standard naming (uuf/uf)
        continue
    fi
    # Now should be '50-01.cnf...' or similar. 
    # Extract vars: everything before the first '-'
    vars="${stub%%-*}"
    
    # Check if vars is a number
    if [[ "$vars" =~ ^[0-9]+$ ]]; then
        if [ "$vars" -le "$MAX_VARS" ]; then
            echo "$f" >> "$list_file"
        fi
    fi
done < "$list_file.raw"
rm "$list_file.raw"

total_found=$(wc -l < "$list_file" | xargs)
echo "Found $total_found files with <= $MAX_VARS variables."

if [ "$total_found" -eq 0 ]; then
    echo "No files found."
    exit 0
fi

# Randomize and Limit


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
    # Fallback for generic Mac/BSD without coreutils: perl explicit shuffle or just sort -R (not perfect random on all systems but okay for tests)
    # Using perl for reliable shuffle if available (standard on Mac)
    if command -v perl > /dev/null; then
         perl -MList::Util=shuffle -e 'print shuffle(<STDIN>);' < "$list_file" > "$list_file.tmp" && mv "$list_file.tmp" "$list_file"
    else
         echo "Warning: No 'shuf' or 'perl' found. Running tests in order."
    fi
fi

# Apply count limit
if [ ! -z "$TEST_COUNT" ]; then
    echo "Randomly selecting $TEST_COUNT files..."
    head -n "$TEST_COUNT" "$list_file" > "$list_file.tmp" && mv "$list_file.tmp" "$list_file"
    count=$(wc -l < "$list_file" | xargs)
    echo "Running $count tests..."
else
    echo "Running all $total_found tests..."
fi

echo "----------------------------------------"

PASSED=0
FAILED=0
TOTAL=0

while IFS= read -r f; do
    TOTAL=$((TOTAL + 1))
    
    # Auto-detect expectation
    filename="${f##*/}"
    EXPECT=""
    if [[ "$filename" == uuf* ]]; then
        EXPECT="UNSAT"
    elif [[ "$filename" == uf* ]]; then
        EXPECT="SAT"
    fi
    
    # Construct command
    # Assuming run_cnf.sh takes args: <file> [EXPECT]
    # The default CMD is "./sim/scripts/run_cnf.sh"
    
    # If the user provided a custom command (e.g. echo, or some other script), 
    # we might just append the file. 
    # But for our default usage, we want to append EXPECT as well if possible.
    # The python script appended it.
    
    FULL_CMD="$CMD $f"
    if [ ! -z "$EXPECT" ] && [[ "$CMD" == *"run_cnf.sh"* ]]; then
        FULL_CMD="$CMD $f $EXPECT"
    fi
    
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "[$TOTAL] Would run: $FULL_CMD"
    else
        # Nice formatting
        printf "  %-50s ... " "$filename"
        
        # Run it and capture output
        OUTPUT=$($FULL_CMD 2>&1)
        RET=$?
        
        if [ $RET -eq 0 ]; then
            echo "PASSED"
            PASSED=$((PASSED + 1))
        else
            echo "FAILED"
            echo "--------------------------------------------------------"
            echo "Test Failed: $filename"
            echo "Command: $FULL_CMD"
            echo "Output:"
            echo "$OUTPUT"
            echo "--------------------------------------------------------"
            FAILED=$((FAILED + 1))
        fi
    fi
    
done < "$list_file"

rm "$list_file"

if [ "$DRY_RUN" -eq 0 ]; then
    echo "----------------------------------------"
    echo "Summary: $PASSED passed, $FAILED failed out of $TOTAL tests."
    if [ $FAILED -gt 0 ]; then
        exit 1
    fi
fi
