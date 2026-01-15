#!/bin/bash
# =============================================================================
# VeriSAT Deployment Environment Setup
# Source this script to configure your environment for FPGA deployment
# Usage: source env.sh
# =============================================================================

# Ensure this script is sourced, not executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Please source this script to set environment variables:"
    echo "  source ${BASH_SOURCE[0]}"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export VERISAT_ROOT="$(dirname "$SCRIPT_DIR")"

# -----------------------------------------------------------------------------
# Vivado Configuration
# -----------------------------------------------------------------------------
# Common Vivado installation paths - adjust as needed
VIVADO_PATHS=(
    "/tools/Xilinx/Vivado/2023.4/settings64.sh"
    "/opt/Xilinx/Vivado/2023.4/settings64.sh"
    "/opt/xilinx/Vivado/2023.4/settings64.sh"
    "$HOME/Xilinx/Vivado/2023.4/settings64.sh"
    "/tools/Xilinx/Vivado/2022.2/settings64.sh"
    "/opt/Xilinx/Vivado/2022.2/settings64.sh"
)

# Try to find and source Vivado settings
VIVADO_FOUND=false
for VIVADO_SETTINGS in "${VIVADO_PATHS[@]}"; do
    if [[ -f "$VIVADO_SETTINGS" ]]; then
        echo "Sourcing Vivado: $VIVADO_SETTINGS"
        source "$VIVADO_SETTINGS"
        VIVADO_FOUND=true
        break
    fi
done

# Allow user override via XILINX_VIVADO environment variable
if [[ "$VIVADO_FOUND" == "false" && -n "${XILINX_VIVADO}" ]]; then
    if [[ -f "${XILINX_VIVADO}/settings64.sh" ]]; then
        echo "Sourcing Vivado: ${XILINX_VIVADO}/settings64.sh"
        source "${XILINX_VIVADO}/settings64.sh"
        VIVADO_FOUND=true
    fi
fi

# -----------------------------------------------------------------------------
# FPGA Part Configuration
# -----------------------------------------------------------------------------
# Default target part - Zynq UltraScale+ ZU9EG
# Common boards:
#   ZCU102: xczu9eg-ffvb1156-2-e
#   ZCU104: xczu7ev-ffvc1156-2-e
#   ZCU106: xczu7ev-ffvc1156-2-e
#   Custom: specify your part
export VERISAT_PART="${VERISAT_PART:-xczu9eg-ffvb1156-2-e}"

# -----------------------------------------------------------------------------
# Project Paths
# -----------------------------------------------------------------------------
export VERISAT_SRC="$VERISAT_ROOT/src/Mega"
export VERISAT_DEPLOY="$VERISAT_ROOT/deploy"
export VERISAT_OUTPUT="$VERISAT_ROOT/deploy/output"

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
# Add deploy directory to PATH for easy access
export PATH="$VERISAT_DEPLOY:$PATH"

# Aliases for common operations
alias verisat-synth="$VERISAT_DEPLOY/deploy.sh synth"
alias verisat-impl="$VERISAT_DEPLOY/deploy.sh impl"
alias verisat-program="$VERISAT_DEPLOY/deploy.sh program"
alias verisat-status="$VERISAT_DEPLOY/deploy.sh status"

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo ""
echo "VeriSAT Deployment Environment Configured"
echo "=========================================="
echo "  VERISAT_ROOT:   $VERISAT_ROOT"
echo "  VERISAT_PART:   $VERISAT_PART"
echo ""

if command -v vivado &> /dev/null; then
    echo "  Vivado:         $(which vivado)"
    echo "  Version:        $(vivado -version 2>/dev/null | head -1 | cut -d' ' -f2)"
else
    echo "  Vivado:         NOT FOUND"
    echo ""
    echo "  Please set XILINX_VIVADO to your Vivado installation:"
    echo "    export XILINX_VIVADO=/path/to/Vivado/2023.4"
    echo "    source $SCRIPT_DIR/env.sh"
fi

echo ""
echo "Available commands:"
echo "  ./deploy.sh synth    - Run synthesis"
echo "  ./deploy.sh impl     - Run implementation"
echo "  ./deploy.sh program  - Program FPGA"
echo "  ./deploy.sh all      - Complete flow"
echo ""
