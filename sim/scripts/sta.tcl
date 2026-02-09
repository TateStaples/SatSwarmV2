# OpenSTA script

# Read Liberty file
read_liberty timing_analysis/nangate45_typ.lib

# Read synthesized netlist
read_verilog synth.v

# Link design
link_design solver_core

# Create clock constraint (assuming 1GHz for normalized slack analysis, or adjust as needed)
# 1000ps period = 1GHz
create_clock -name clk -period 1000 [get_ports clk]

# Propagate clocks
set_propagated_clock [all_clocks]

# Check timing
report_checks -path_delay max -fields {slew cap input nets fanout} -format full_clock_expanded -digits 4
report_worst_slack -max
report_tns
report_wns

# Report power (optional)
report_power
