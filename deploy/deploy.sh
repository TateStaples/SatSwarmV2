#!/bin/bash
# =============================================================================
# SatSwarmv2 FPGA Deployment Script
# Master script for synthesis, implementation, and programming
# Usage: ./deploy.sh [synth|impl|bitstream|program|all]
# =============================================================================

set -e

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TCL_DIR="$SCRIPT_DIR/tcl"
OUTPUT_DIR="$SCRIPT_DIR/output"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default FPGA part (Zynq UltraScale+ ZU9EG)
export SATSWARMV2_PART="${SATSWARMV2_PART:-xczu9eg-ffvb1156-2-e}"

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------
print_header() {
    echo ""
    echo -e "${CYAN}=============================================${NC}"
    echo -e "${CYAN} $1${NC}"
    echo -e "${CYAN}=============================================${NC}"
}

print_status() {
    echo -e "${BLUE}>>> $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

check_vivado() {
    if ! command -v vivado &> /dev/null; then
        print_error "Vivado not found in PATH"
        echo ""
        echo "Please source Vivado settings first:"
        echo "  source /tools/Xilinx/Vivado/2023.4/settings64.sh"
        echo ""
        echo "Or use the environment setup script:"
        echo "  source $SCRIPT_DIR/env.sh"
        exit 1
    fi
    
    VIVADO_VERSION=$(vivado -version | head -1)
    print_status "Using: $VIVADO_VERSION"
}

show_usage() {
    echo "SatSwarmv2 FPGA Deployment Script"
    echo ""
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  synth     Run synthesis only"
    echo "  impl      Run full implementation (synth + place + route)"
    echo "  bitstream Generate bitstream (runs impl if needed)"
    echo "  program   Program FPGA with latest bitstream"
    echo "  all       Complete flow: synth → impl → program"
    echo "  clean     Remove all generated outputs"
    echo "  status    Show output directories and files"
    echo ""
    echo "Environment Variables:"
    echo "  SATSWARMV2_PART   Target FPGA part (default: xczu9eg-ffvb1156-2-e)"
    echo ""
    echo "Examples:"
    echo "  $0 synth                    # Run synthesis"
    echo "  SATSWARMV2_PART=xczu7ev... $0 synth  # Use different part"
    echo "  $0 all                      # Complete flow"
}

# -----------------------------------------------------------------------------
# Commands
# -----------------------------------------------------------------------------
do_synth() {
    print_header "SatSwarmv2 Synthesis"
    print_status "Target: $SATSWARMV2_PART"
    
    check_vivado
    
    mkdir -p "$OUTPUT_DIR/synth"
    
    print_status "Running synthesis..."
    vivado -mode batch -nojournal -log "$OUTPUT_DIR/synth/vivado_synth.log" \
           -source "$TCL_DIR/synth.tcl"
    
    if [ $? -eq 0 ]; then
        print_success "Synthesis completed successfully"
        
        # Show latest checkpoint
        LATEST_DCP=$(find "$OUTPUT_DIR/synth" -name "*_synth.dcp" -type f | sort -r | head -1)
        if [ -n "$LATEST_DCP" ]; then
            echo ""
            echo "Checkpoint: $LATEST_DCP"
        fi
    else
        print_error "Synthesis failed"
        exit 1
    fi
}

do_impl() {
    print_header "SatSwarmv2 Implementation"
    print_status "Target: $SATSWARMV2_PART"
    
    check_vivado
    
    # Check for synthesis checkpoint
    SYNTH_DCP=$(find "$OUTPUT_DIR/synth" -name "*_synth.dcp" -type f 2>/dev/null | sort -r | head -1)
    if [ -z "$SYNTH_DCP" ]; then
        print_warning "No synthesis checkpoint found, running synthesis first..."
        do_synth
        SYNTH_DCP=$(find "$OUTPUT_DIR/synth" -name "*_synth.dcp" -type f | sort -r | head -1)
    fi
    
    print_status "Using checkpoint: $SYNTH_DCP"
    
    mkdir -p "$OUTPUT_DIR/impl"
    
    print_status "Running implementation..."
    vivado -mode batch -nojournal -log "$OUTPUT_DIR/impl/vivado_impl.log" \
           -source "$TCL_DIR/impl.tcl" -tclargs "$SYNTH_DCP"
    
    if [ $? -eq 0 ]; then
        print_success "Implementation completed successfully"
        
        # Show bitstream
        LATEST_BIT=$(find "$OUTPUT_DIR/impl" -name "*.bit" -type f | sort -r | head -1)
        if [ -n "$LATEST_BIT" ]; then
            echo ""
            echo "Bitstream: $LATEST_BIT"
            echo "Size: $(du -h "$LATEST_BIT" | cut -f1)"
        fi
    else
        print_error "Implementation failed"
        exit 1
    fi
}

do_bitstream() {
    # Implementation already generates bitstream, just run impl
    do_impl
}

do_program() {
    print_header "SatSwarmv2 FPGA Programming"
    
    check_vivado
    
    # Find latest bitstream
    BITSTREAM=$(find "$OUTPUT_DIR/impl" -name "*.bit" -type f 2>/dev/null | sort -r | head -1)
    if [ -z "$BITSTREAM" ]; then
        print_error "No bitstream found. Run 'impl' first."
        exit 1
    fi
    
    print_status "Programming with: $BITSTREAM"
    
    # Check if hw_server is running
    if ! pgrep -x "hw_server" > /dev/null; then
        print_warning "hw_server not running, attempting to start..."
        hw_server &
        sleep 2
    fi
    
    vivado -mode batch -nojournal -log "$OUTPUT_DIR/vivado_program.log" \
           -source "$TCL_DIR/program.tcl" -tclargs "$BITSTREAM"
    
    if [ $? -eq 0 ]; then
        print_success "Programming completed successfully"
    else
        print_error "Programming failed"
        exit 1
    fi
}

do_all() {
    print_header "SatSwarmv2 Full Deployment Flow"
    
    do_synth
    do_impl
    do_program
    
    print_header "Deployment Complete"
    print_success "SatSwarmv2 is now running on FPGA"
}

do_clean() {
    print_header "Cleaning Output Directories"
    
    if [ -d "$OUTPUT_DIR" ]; then
        print_status "Removing: $OUTPUT_DIR"
        rm -rf "$OUTPUT_DIR"
        print_success "Cleaned"
    else
        print_status "Nothing to clean"
    fi
}

do_status() {
    print_header "Deployment Status"
    
    echo ""
    echo "Project: $PROJECT_DIR"
    echo "Part:    $SATSWARMV2_PART"
    echo ""
    
    # Synthesis checkpoints
    echo -e "${BLUE}Synthesis Checkpoints:${NC}"
    find "$OUTPUT_DIR/synth" -name "*_synth.dcp" -type f 2>/dev/null | while read f; do
        echo "  $(basename "$(dirname "$f")")/$(basename "$f")"
    done
    [ $(find "$OUTPUT_DIR/synth" -name "*_synth.dcp" -type f 2>/dev/null | wc -l) -eq 0 ] && echo "  (none)"
    
    echo ""
    
    # Implementation outputs
    echo -e "${BLUE}Implementation Outputs:${NC}"
    find "$OUTPUT_DIR/impl" -name "*.bit" -type f 2>/dev/null | while read f; do
        echo "  $(basename "$(dirname "$f")")/$(basename "$f") ($(du -h "$f" | cut -f1))"
    done
    [ $(find "$OUTPUT_DIR/impl" -name "*.bit" -type f 2>/dev/null | wc -l) -eq 0 ] && echo "  (none)"
    
    echo ""
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
case "${1:-}" in
    synth)
        do_synth
        ;;
    impl)
        do_impl
        ;;
    bitstream)
        do_bitstream
        ;;
    program)
        do_program
        ;;
    all)
        do_all
        ;;
    clean)
        do_clean
        ;;
    status)
        do_status
        ;;
    -h|--help|help)
        show_usage
        ;;
    "")
        show_usage
        exit 1
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac
