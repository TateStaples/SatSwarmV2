# =============================================================================
# SatSwarm AWS F1 Synthesis Script
# Target: Xilinx Virtex UltraScale+ VU9P (xcvu9p-flgb2104-2-i)
# Usage: vivado -mode batch -source synth_aws.tcl
#
# This produces a DCP that can be used with the AWS HDK build flow:
#   $HDK_DIR/common/shell_stable/build/scripts/aws_build_dcp_from_cl.sh
# =============================================================================

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
# AWS F1 FPGA part
set PART "xcvu9p-flgb2104-2-i"

# Project paths
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJECT_DIR [file normalize "$SCRIPT_DIR/../.."]
set SRC_DIR "$PROJECT_DIR/src/Mega"
set CL_DIR "$PROJECT_DIR/src/aws-fpga/hdk/cl/examples/cl_satswarm/design"
set CONSTRAINT_DIR "$SCRIPT_DIR/../constraints"
set OUTPUT_DIR "$SCRIPT_DIR/../output/aws_synth"

# Top module — the AWS shell wrapper
set TOP_MODULE "cl_satswarm_aws"

# Timestamp for unique output directory
set TIMESTAMP [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
set RUN_DIR "$OUTPUT_DIR/$TIMESTAMP"

puts "============================================="
puts "SatSwarm AWS F1 Synthesis"
puts "============================================="
puts "Part:       $PART"
puts "Top Module: $TOP_MODULE"
puts "Source:     $SRC_DIR"
puts "CL Design:  $CL_DIR"
puts "Output:     $RUN_DIR"
puts "============================================="

# -----------------------------------------------------------------------------
# Setup
# -----------------------------------------------------------------------------
file mkdir $RUN_DIR

# Check for --check-only flag
if {[lsearch -exact $::argv "--check-only"] >= 0} {
    puts "Syntax check mode - exiting successfully"
    exit 0
}

# -----------------------------------------------------------------------------
# Read Design Sources
# -----------------------------------------------------------------------------
puts "\n>>> Setup HDK Includes..."
if {[info exists ::env(HDK_DIR)]} {
    set hdk_inc "$::env(HDK_DIR)/common/design/interfaces"
    set_property include_dirs $hdk_inc [current_fileset]
    puts "  Added HDK Include: $hdk_inc"
} else {
    puts "  WARNING: HDK_DIR not found, compilation may fail if missing cl_ports.vh"
}

puts "\n>>> Reading SystemVerilog sources..."

# Package first
read_verilog -sv "$SRC_DIR/satswarmv2_pkg.sv"
puts "  Reading: satswarmv2_pkg.sv"

# Read all RTL modules (skip Yosys-specific and testbench files)
set sv_files [glob -nocomplain "$SRC_DIR/*.sv"]
set skip_files {satswarmv2_pkg.sv vde_heap_yosys.sv}
foreach f $sv_files {
    set tail [file tail $f]
    if {$tail in $skip_files || [string match "tb_*" $tail]} {
        puts "  Skipping: $tail"
        continue
    }
    puts "  Reading: $tail"
    read_verilog -sv $f
}

# Read utility modules (skip testbench utilities)
set util_files [glob -nocomplain "$SRC_DIR/utils/*.sv"]
foreach f $util_files {
    set tail [file tail $f]
    if {[string match "tb_*" $tail]} {
        puts "  Skipping: utils/$tail"
        continue
    }
    puts "  Reading: utils/$tail"
    read_verilog -sv $f
}

# Read CL wrapper and AWS wrapper
puts "  Reading: cl_satswarm.sv"
read_verilog -sv "$CL_DIR/cl_satswarm.sv"
puts "  Reading: cl_satswarm_aws.sv"
read_verilog -sv "$CL_DIR/cl_satswarm_aws.sv"

# -----------------------------------------------------------------------------
# Read Constraints
# -----------------------------------------------------------------------------
puts "\n>>> Reading constraints..."
if {[file exists "$CONSTRAINT_DIR/timing_aws.xdc"]} {
    read_xdc "$CONSTRAINT_DIR/timing_aws.xdc"
    puts "  Read: timing_aws.xdc"
}

# -----------------------------------------------------------------------------
# Synthesis
# -----------------------------------------------------------------------------
puts "\n>>> Running synthesis..."
synth_design \
    -top $TOP_MODULE \
    -part $PART \
    -flatten_hierarchy rebuilt \
    -directive PerformanceOptimized \
    -retiming \
    -fsm_extraction one_hot \
    -resource_sharing auto \
    -control_set_opt_threshold auto

# Post-synthesis optimization
puts "\n>>> Running post-synthesis optimization..."
opt_design -directive Explore

# -----------------------------------------------------------------------------
# Reports
# -----------------------------------------------------------------------------
puts "\n>>> Generating reports..."
report_utilization -file "$RUN_DIR/${TOP_MODULE}_utilization.rpt"
report_timing_summary -file "$RUN_DIR/${TOP_MODULE}_timing_summary.rpt" -max_paths 10
report_utilization -hierarchical -file "$RUN_DIR/${TOP_MODULE}_hier_utilization.rpt"
report_drc -file "$RUN_DIR/${TOP_MODULE}_drc.rpt"

puts "  Generated: utilization, timing, DRC reports"

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
puts "AWS F1 Synthesis Complete"
puts "============================================="
puts "Checkpoint: $RUN_DIR/${TOP_MODULE}_synth.dcp"
puts "Reports:    $RUN_DIR/"
puts ""
puts "Next steps:"
puts "  1. Copy DCP to AWS HDK build directory"
puts "  2. Run: \$HDK_DIR/common/shell_stable/build/scripts/aws_build_dcp_from_cl.sh"
puts "  3. Create AFI: aws ec2 create-fpga-image ..."
puts "============================================="

# Print key metrics
catch {
    set util_rpt [open "$RUN_DIR/${TOP_MODULE}_utilization.rpt" r]
    set util_content [read $util_rpt]
    close $util_rpt
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

exit 0
