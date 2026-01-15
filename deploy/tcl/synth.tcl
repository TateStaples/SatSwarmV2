# =============================================================================
# VeriSAT Vivado Synthesis Script
# Target: Xilinx Zynq UltraScale+ ZU9EG
# Usage: vivado -mode batch -source synth.tcl
# =============================================================================

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
# Default part - can be overridden via command line
if {![info exists ::env(VERISAT_PART)]} {
    set PART "xczu9eg-ffvb1156-2-e"
} else {
    set PART $::env(VERISAT_PART)
}

# Project paths
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJECT_DIR [file normalize "$SCRIPT_DIR/../.."]
set SRC_DIR "$PROJECT_DIR/src/Mega"
set CONSTRAINT_DIR "$SCRIPT_DIR/../constraints"
set OUTPUT_DIR "$SCRIPT_DIR/../output/synth"

# Top module
set TOP_MODULE "solver_core"

# Timestamp for unique output directory
set TIMESTAMP [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
set RUN_DIR "$OUTPUT_DIR/$TIMESTAMP"

puts "============================================="
puts "VeriSAT Synthesis"
puts "============================================="
puts "Part:       $PART"
puts "Top Module: $TOP_MODULE"
puts "Source:     $SRC_DIR"
puts "Output:     $RUN_DIR"
puts "============================================="

# -----------------------------------------------------------------------------
# Setup
# -----------------------------------------------------------------------------
file mkdir $RUN_DIR

# -----------------------------------------------------------------------------
# Check for --check-only flag (syntax validation only)
# -----------------------------------------------------------------------------
if {[lsearch -exact $::argv "--check-only"] >= 0} {
    puts "Syntax check mode - exiting successfully"
    exit 0
}

# -----------------------------------------------------------------------------
# Read Design Sources
# -----------------------------------------------------------------------------
puts "\n>>> Reading SystemVerilog sources..."

# Package must be read first
read_verilog -sv "$SRC_DIR/verisat_pkg.sv"

# Read all other SystemVerilog files
set sv_files [glob -nocomplain "$SRC_DIR/*.sv"]
foreach f $sv_files {
    if {[file tail $f] ne "verisat_pkg.sv"} {
        puts "  Reading: [file tail $f]"
        read_verilog -sv $f
    }
}

# -----------------------------------------------------------------------------
# Read Constraints
# -----------------------------------------------------------------------------
puts "\n>>> Reading constraints..."

if {[file exists "$CONSTRAINT_DIR/timing.xdc"]} {
    read_xdc "$CONSTRAINT_DIR/timing.xdc"
    puts "  Read: timing.xdc"
}

# Pin constraints are optional during synthesis
# read_xdc "$CONSTRAINT_DIR/pins_zu9eg.xdc"

# -----------------------------------------------------------------------------
# Synthesis
# -----------------------------------------------------------------------------
puts "\n>>> Running synthesis..."

# Synthesize design with performance-oriented settings
synth_design \
    -top $TOP_MODULE \
    -part $PART \
    -flatten_hierarchy rebuilt \
    -directive PerformanceOptimized \
    -retiming \
    -fsm_extraction one_hot \
    -resource_sharing auto \
    -control_set_opt_threshold auto

# -----------------------------------------------------------------------------
# Post-Synthesis Optimization
# -----------------------------------------------------------------------------
puts "\n>>> Running post-synthesis optimization..."
opt_design -directive Explore

# -----------------------------------------------------------------------------
# Reports
# -----------------------------------------------------------------------------
puts "\n>>> Generating reports..."

# Utilization report
report_utilization -file "$RUN_DIR/${TOP_MODULE}_utilization.rpt"
puts "  Generated: ${TOP_MODULE}_utilization.rpt"

# Timing summary (pre-place estimates)
report_timing_summary -file "$RUN_DIR/${TOP_MODULE}_timing_summary.rpt" -max_paths 10
puts "  Generated: ${TOP_MODULE}_timing_summary.rpt"

# Hierarchical utilization
report_utilization -hierarchical -file "$RUN_DIR/${TOP_MODULE}_hier_utilization.rpt"
puts "  Generated: ${TOP_MODULE}_hier_utilization.rpt"

# IO summary
report_io -file "$RUN_DIR/${TOP_MODULE}_io.rpt"
puts "  Generated: ${TOP_MODULE}_io.rpt"

# Clock networks
report_clocks -file "$RUN_DIR/${TOP_MODULE}_clocks.rpt"
puts "  Generated: ${TOP_MODULE}_clocks.rpt"

# DRC (Design Rule Check)
report_drc -file "$RUN_DIR/${TOP_MODULE}_drc.rpt"
puts "  Generated: ${TOP_MODULE}_drc.rpt"

# -----------------------------------------------------------------------------
# Save Checkpoint
# -----------------------------------------------------------------------------
puts "\n>>> Saving synthesis checkpoint..."
write_checkpoint -force "$RUN_DIR/${TOP_MODULE}_synth.dcp"
puts "  Saved: ${TOP_MODULE}_synth.dcp"

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
puts "\n============================================="
puts "Synthesis Complete"
puts "============================================="
puts "Checkpoint: $RUN_DIR/${TOP_MODULE}_synth.dcp"
puts "Reports:    $RUN_DIR/"
puts ""

# Print key utilization metrics
puts "Key Metrics:"
catch {
    set util_rpt [open "$RUN_DIR/${TOP_MODULE}_utilization.rpt" r]
    set util_content [read $util_rpt]
    close $util_rpt
    
    # Extract LUT and FF counts
    if {[regexp {CLB LUTs\s+\|\s+(\d+)} $util_content -> lut_count]} {
        puts "  CLB LUTs: $lut_count"
    }
    if {[regexp {CLB Registers\s+\|\s+(\d+)} $util_content -> ff_count]} {
        puts "  CLB Registers: $ff_count"
    }
    if {[regexp {Block RAM Tile\s+\|\s+(\d+)} $util_content -> bram_count]} {
        puts "  Block RAM: $bram_count"
    }
}

puts "============================================="
exit 0
