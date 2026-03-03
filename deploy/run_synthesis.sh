#!/bin/bash
# =============================================================================
# SatSwarm FPGA Synthesis Launcher
# Runs aws_build_dcp_from_cl.py for the cl_satswarm CL.
#
# Usage: ./run_synthesis.sh [extra_args...]
#
# Clock domain architecture:
#   Shell:  clk_main_a0 = 250 MHz (fixed by AWS shell, not affected by recipe)
#   Solver: gen_clk_extra_a1 = 15.625 MHz via aws_clk_gen (Clock Recipe A2)
#   Three AXI CDC converters bridge the two domains (OCL, PCIS, DDR paths).
#
# Clock recipes used:
#   A2 = gen_clk_extra_a1 @ 15.625 MHz (solver domain — deeply conservative)
#   B0 = default B group (unused by solver)
#   C0 = default C group (unused by solver)
#   H0 = HBM clock (unused by solver)
# =============================================================================
set -e

AWS_FPGA_REPO_DIR=/home/ubuntu/src/project_data/aws-fpga
export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

echo "=== Sourcing HDK setup ==="
cd "$AWS_FPGA_REPO_DIR"
source hdk_setup.sh

export CL_DIR=$HDK_DIR/cl/examples/cl_satswarm

echo ""
echo "=== Environment ==="
echo "  HDK_DIR=$HDK_DIR"
echo "  CL_DIR=$CL_DIR"
echo "  VIVADO_TOOL_VERSION=$VIVADO_TOOL_VERSION"
echo ""

SYNTH_SCRIPT="$HDK_DIR/common/shell_stable/build/scripts/aws_build_dcp_from_cl.py"

if [[ ! -f "$SYNTH_SCRIPT" ]]; then
    echo "ERROR: Synthesis script not found: $SYNTH_SCRIPT"
    exit 1
fi

BUILD_DIR="$CL_DIR/build/scripts"
if [[ ! -d "$BUILD_DIR" ]]; then
    echo "ERROR: Build scripts dir not found: $BUILD_DIR"
    exit 1
fi

echo "=== Launching Synthesis ==="
echo "  Script: $SYNTH_SCRIPT"
echo "  CL: cl_satswarm"
echo "  Strategy: SynthCL"
echo ""

cd "$BUILD_DIR"

python3 "$SYNTH_SCRIPT" \
    -c cl_satswarm \
    -f SynthCL \
    --no-encrypt \
    --aws_clk_gen \
    --clock_recipe_a A2 \
    --clock_recipe_b B0 \
    --clock_recipe_c C0 \
    --clock_recipe_hbm H0 \
    -o Explore \
    "$@"

echo ""
echo "=== Synthesis script returned: $? ==="
