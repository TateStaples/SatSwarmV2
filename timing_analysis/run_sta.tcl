# =============================================================================
# OpenSTA Timing Analysis Script for VeriSAT (interface_unit)
# Run with: ../tools/OpenSTA/build/sta -exit run_sta.tcl
# =============================================================================

puts "=============================================="
puts "VeriSAT Static Timing Analysis"
puts "=============================================="

# Read Liberty library (technology timing data)
puts "Reading Liberty library..."
read_liberty timing_analysis/nangate45_typ.lib

# Read the synthesized gate-level Verilog netlist
puts "Reading Verilog netlist..."
read_verilog timing_analysis/interface_unit_netlist.v

# Link the design
puts "Linking design..."
link_design interface_unit

# Read SDC timing constraints
puts "Reading SDC constraints..."
read_sdc timing_analysis/constraints.sdc

# =============================================================================
# Timing Reports
# =============================================================================

puts "\n=============================================="
puts "CRITICAL PATH ANALYSIS (Setup Timing)"
puts "==============================================\n"

# Report worst setup paths
report_checks -path_delay max -digits 3

puts "\n=============================================="
puts "HOLD TIMING ANALYSIS"
puts "==============================================\n"

# Report worst hold paths
report_checks -path_delay min -digits 3

puts "\n=============================================="
puts "TOP 10 WORST SETUP PATHS"
puts "==============================================\n"

report_checks -path_delay max -endpoint_count 10 -format short

puts "\n=============================================="
puts "TIMING SUMMARY"
puts "==============================================\n"

# Report WNS/TNS
report_wns
report_tns

puts "\nTiming analysis complete."
puts "For interactive analysis, run: ./tools/OpenSTA/build/sta"
