# =============================================================================
# Vivado TCL Script for Full VeriSAT Timing Analysis
# Use with: vivado -mode tcl -source timing_analysis/vivado_timing.tcl
# =============================================================================

# Create in-memory project
create_project -in_memory -part xczu9eg-ffvb1156-2-e

# Read RTL sources
read_verilog -sv [glob src/Mega/satswarmv2_pkg.sv]
read_verilog -sv [glob src/Mega/utils/*.sv]
read_verilog -sv [glob src/Mega/*.sv]

# Set top-level module
set_property top solver_core [current_fileset]

# Set parameters for synthesis
# Note: Vivado handles parameterized designs natively

# Synthesize
synth_design -top solver_core -mode out_of_context

# Apply timing constraints
read_xdc deploy/constraints/timing.xdc

# Report timing (Setup)
puts "=============================================="
puts "SETUP TIMING ANALYSIS (WNS)"
puts "=============================================="
report_timing_summary -delay_type max -max_paths 10

# Report timing (Hold)
puts "\n=============================================="
puts "HOLD TIMING ANALYSIS"  
puts "=============================================="
report_timing_summary -delay_type min -max_paths 5

# Critical path details
puts "\n=============================================="
puts "CRITICAL PATHS DETAIL"
puts "=============================================="
report_timing -delay_type max -max_paths 5 -sort_by slack

# Write reports to file
report_timing_summary -file timing_analysis/vivado_timing_summary.rpt
report_timing -delay_type max -max_paths 20 -file timing_analysis/vivado_critical_paths.rpt

puts "\nTiming reports written to timing_analysis/"
