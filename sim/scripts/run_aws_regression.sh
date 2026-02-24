#!/bin/bash
# Run all generated CNF instances in sim/tests/generated_instances using the AWS fpga HDK simulator

# Exit on error
set -e

# Directory setup
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SIM_DIR="$(dirname "$SCRIPT_DIR")"
TESTS_DIR="$SIM_DIR/tests/generated_instances"

# Navigate to the AWS FPGA CL tests directory
AWS_FPGA_SIM_DIR="$(realpath "$SIM_DIR/../src/aws-fpga/hdk/cl/examples/cl_satswarm/verif/scripts")"

# Counters
TOTAL=0
PASSED=0
FAILED=0

echo "Starting AWS CL Regression..."
echo "Looking for tests in: $TESTS_DIR"
echo "Running in AWS Simulaton Dir: $AWS_FPGA_SIM_DIR"

if [ ! -d "$TESTS_DIR" ]; then
    echo "Error: Tests directory not found!"
    exit 1
fi

if [ ! -d "$AWS_FPGA_SIM_DIR" ]; then
    echo "Error: AWS HDK simulation directory not found at $AWS_FPGA_SIM_DIR"
    exit 1
fi

cd "$AWS_FPGA_SIM_DIR"

# Ensure the AWS environment is loaded
if [ -z "$HDK_DIR" ]; then
    echo "Warning: HDK_DIR is not set. You must source hdk_setup.sh before running this script."
    echo "Please run: cd src/aws-fpga && source hdk_setup.sh"
    exit 1
fi

# Set the Custom Logic directory if not already set
export CL_DIR="$(realpath "$AWS_FPGA_SIM_DIR/../..")"

# Precompile the regression testbench once (saves ~40s per test)
echo "Precompiling regression testbench..."
if ! make TEST=test_satswarm_regression compile_only > /tmp/aws_regression_compile.log 2>&1; then
    echo "Error: Precompilation failed! See /tmp/aws_regression_compile.log"
    exit 1
fi
echo "Precompilation done."

# Find all .cnf files
FILES=$(find "$TESTS_DIR" -name "*.cnf" | sort)

if [ -z "$FILES" ]; then
    echo "No .cnf files found."
    exit 0
fi

for file in $FILES; do
    BASENAME=$(basename "$file")
    
    # Determine expected result based on filename
    EXPECTED=""
    if [[ "$BASENAME" == *"unsat"* || "$BASENAME" == *"UNSAT"* ]]; then
        EXPECTED="UNSAT"
    elif [[ "$BASENAME" == *"sat"* || "$BASENAME" == *"SAT"* ]]; then
        EXPECTED="SAT"
    else
        continue
    fi
    
    TOTAL=$((TOTAL + 1))
    
    printf "  %-40s ... " "$BASENAME"
    
    # Run the AWS makefile, passing the CNF and EXPECT arguments using Vivado PLUSARGS
    # We grep for "TEST PASSED" which is printed by the tb_satswarm_regression.sv
    # By default AWS `make` is noisy, so redirect all stdout/stderr, unless it fails
    
    LOG_FILE="/tmp/aws_regression_${BASENAME}.log"
    
    # Timeout after 180s (XSIM is slower than Verilator)
    if timeout 180s make TEST=test_satswarm_regression simulate_only PLUSARGS="+CNF=$file +EXPECT=$EXPECTED +DEBUG=0" > "$LOG_FILE" 2>&1; then
        
        # Double check the pass was printed
        if grep -q "TEST PASSED" "$LOG_FILE"; then
            echo "PASSED"
            PASSED=$((PASSED + 1))
        else
            echo "FAILED (See $LOG_FILE)"
            FAILED=$((FAILED + 1))
        fi
        
    else
        echo "TIMEOUT or CRASH (See $LOG_FILE)"
        FAILED=$((FAILED + 1))
    fi

done

echo ""
echo "=================================================="
echo "AWS Sim Regression Summary"
echo "=================================================="
echo "Total Tests: $TOTAL"
echo "Passed:      $PASSED"
echo "Failed:      $FAILED"
echo "=================================================="

if [ $FAILED -eq 0 ]; then
    echo "ALL TESTS PASSED"
    exit 0
else
    echo "SOME TESTS FAILED"
    exit 1
fi
