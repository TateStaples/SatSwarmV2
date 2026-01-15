# =============================================================================
# VeriSAT Vivado Implementation Script
# Target: Xilinx Zynq UltraScale+ ZU9EG
# Usage: vivado -mode batch -source impl.tcl -tclargs <synth_checkpoint>
# =============================================================================

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJECT_DIR [file normalize "$SCRIPT_DIR/../.."]
set CONSTRAINT_DIR "$SCRIPT_DIR/../constraints"
set OUTPUT_DIR "$SCRIPT_DIR/../output/impl"

# Top module name
set TOP_MODULE "solver_core"

# Get synthesis checkpoint from command line or find latest
if {$argc > 0 && [lindex $argv 0] ne "--check-only"} {
    set SYNTH_DCP [lindex $argv 0]
} else {
    # Find latest synthesis checkpoint
    set synth_dirs [lsort -decreasing [glob -nocomplain "$SCRIPT_DIR/../output/synth/*"]]
    if {[llength $synth_dirs] > 0} {
        set latest_synth [lindex $synth_dirs 0]
        set SYNTH_DCP "$latest_synth/${TOP_MODULE}_synth.dcp"
    } else {
        puts "ERROR: No synthesis checkpoint found. Run synth.tcl first."
        exit 1
    }
}

# Timestamp for unique output directory
set TIMESTAMP [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
set RUN_DIR "$OUTPUT_DIR/$TIMESTAMP"

puts "============================================="
puts "VeriSAT Implementation"
puts "============================================="
puts "Checkpoint: $SYNTH_DCP"
puts "Output:     $RUN_DIR"
puts "============================================="

# -----------------------------------------------------------------------------
# Check for --check-only flag
# -----------------------------------------------------------------------------
if {[lsearch -exact $::argv "--check-only"] >= 0} {
    puts "Syntax check mode - exiting successfully"
    exit 0
}

# -----------------------------------------------------------------------------
# Setup
# -----------------------------------------------------------------------------
file mkdir $RUN_DIR

# Log file for timing loop
set LOG_FILE "$RUN_DIR/vivado_impl.log"

# -----------------------------------------------------------------------------
# Load Synthesis Checkpoint
# -----------------------------------------------------------------------------
puts "\n>>> Loading synthesis checkpoint..."
if {![file exists $SYNTH_DCP]} {
    puts "ERROR: Checkpoint not found: $SYNTH_DCP"
    exit 1
}
open_checkpoint $SYNTH_DCP

# -----------------------------------------------------------------------------
# Read Pin Constraints (required for implementation)
# -----------------------------------------------------------------------------
puts "\n>>> Reading pin constraints..."
if {[file exists "$CONSTRAINT_DIR/pins_zu9eg.xdc"]} {
    read_xdc "$CONSTRAINT_DIR/pins_zu9eg.xdc"
    puts "  Read: pins_zu9eg.xdc"
} else {
    puts "WARNING: No pin constraints found. Implementation may fail."
}

# -----------------------------------------------------------------------------
# Logic Optimization
# -----------------------------------------------------------------------------
puts "\n>>> Running logic optimization..."
opt_design -directive ExploreWithRemap

# Report timing after opt
report_timing_summary -file "$RUN_DIR/${TOP_MODULE}_post_opt_timing.rpt" -max_paths 10

# -----------------------------------------------------------------------------
# Placement
# -----------------------------------------------------------------------------
puts "\n>>> Running placement..."
place_design -directive ExtraPostPlacementOpt

# Report timing after place
report_timing_summary -file "$RUN_DIR/${TOP_MODULE}_post_place_timing.rpt" -max_paths 10

# Check for timing violations
set WNS [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
puts "  Post-Place WNS: $WNS ns"

# -----------------------------------------------------------------------------
# Physical Optimization (Timing Closure Loop)
# -----------------------------------------------------------------------------
puts "\n>>> Running physical optimization..."

# Physical optimization loop for timing closure
set NLOOPS 5
set TNS_PREV 0

if {$WNS < 0.000} {
    puts "  Timing violations detected, running optimization loop..."
    
    for {set i 0} {$i < $NLOOPS} {incr i} {
        puts "  Iteration $i: WNS = $WNS ns"
        
        # Aggressive exploration
        phys_opt_design -directive AggressiveExplore
        set WNS [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
        set TNS [get_property SLACK [get_timing_paths -max_paths 1000 -setup]]
        
        if {$WNS >= 0.000} {
            puts "  Timing closure achieved!"
            break
        }
        
        if {$TNS == $TNS_PREV && $i > 0} {
            puts "  No improvement, stopping optimization loop"
            break
        }
        set TNS_PREV $TNS
        
        # Fanout optimization
        phys_opt_design -directive AggressiveFanoutOpt
        set WNS [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
        
        if {$WNS >= 0.000} {
            puts "  Timing closure achieved!"
            break
        }
        
        # Replication
        phys_opt_design -directive AlternateReplication
        set WNS [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
    }
}

# Report timing after phys_opt
report_timing_summary -file "$RUN_DIR/${TOP_MODULE}_post_phys_opt_timing.rpt" -max_paths 100

# -----------------------------------------------------------------------------
# Routing
# -----------------------------------------------------------------------------
puts "\n>>> Running routing..."
route_design -directive AggressiveExplore

# Report timing after route
report_timing_summary -file "$RUN_DIR/${TOP_MODULE}_post_route_timing.rpt" -max_paths 100

# Final timing check
set WNS_FINAL [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
puts "  Post-Route WNS: $WNS_FINAL ns"

# -----------------------------------------------------------------------------
# Post-Route Optimization (if still failing timing)
# -----------------------------------------------------------------------------
if {$WNS_FINAL < 0.000} {
    puts "\n>>> Running post-route optimization..."
    phys_opt_design -directive AggressiveExplore
    route_design -directive MoreGlobalIterations
    
    set WNS_FINAL [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
    puts "  Final WNS: $WNS_FINAL ns"
}

# -----------------------------------------------------------------------------
# Reports
# -----------------------------------------------------------------------------
puts "\n>>> Generating final reports..."

# Utilization
report_utilization -file "$RUN_DIR/${TOP_MODULE}_utilization.rpt"
report_utilization -hierarchical -file "$RUN_DIR/${TOP_MODULE}_hier_utilization.rpt"
puts "  Generated: utilization reports"

# Timing
report_timing_summary -file "$RUN_DIR/${TOP_MODULE}_timing_summary.rpt" -max_paths 100
report_timing -file "$RUN_DIR/${TOP_MODULE}_timing.rpt" -max_paths 50 -slack_lesser_than 0
puts "  Generated: timing reports"

# Power estimation
report_power -file "$RUN_DIR/${TOP_MODULE}_power.rpt"
puts "  Generated: power report"

# DRC
report_drc -file "$RUN_DIR/${TOP_MODULE}_drc.rpt"
puts "  Generated: DRC report"

# Clock utilization
report_clock_utilization -file "$RUN_DIR/${TOP_MODULE}_clock_util.rpt"
puts "  Generated: clock utilization report"

# -----------------------------------------------------------------------------
# Save Checkpoint
# -----------------------------------------------------------------------------
puts "\n>>> Saving implementation checkpoint..."
write_checkpoint -force "$RUN_DIR/${TOP_MODULE}_impl.dcp"
puts "  Saved: ${TOP_MODULE}_impl.dcp"

# -----------------------------------------------------------------------------
# Generate Bitstream
# -----------------------------------------------------------------------------
puts "\n>>> Generating bitstream..."
write_bitstream -force "$RUN_DIR/${TOP_MODULE}.bit"
puts "  Generated: ${TOP_MODULE}.bit"

# Generate debug probes file (if ILA present)
catch {
    write_debug_probes -force "$RUN_DIR/${TOP_MODULE}.ltx"
    puts "  Generated: ${TOP_MODULE}.ltx"
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
puts "\n============================================="
puts "Implementation Complete"
puts "============================================="
puts "Bitstream:  $RUN_DIR/${TOP_MODULE}.bit"
puts "Checkpoint: $RUN_DIR/${TOP_MODULE}_impl.dcp"
puts "Reports:    $RUN_DIR/"
puts ""
puts "Timing Status:"
if {$WNS_FINAL >= 0.000} {
    puts "  PASSED - All timing constraints met (WNS: $WNS_FINAL ns)"
} else {
    puts "  FAILED - Timing violations exist (WNS: $WNS_FINAL ns)"
    puts "  Review: $RUN_DIR/${TOP_MODULE}_timing.rpt"
}
puts "============================================="

exit 0
