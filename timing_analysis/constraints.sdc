# =============================================================================
# VeriSAT SDC Timing Constraints for OpenSTA
# Derived from deploy/constraints/timing.xdc
# Target: Generic timing analysis
# Clock: 150 MHz (6.667 ns period)
# =============================================================================

# -----------------------------------------------------------------------------
# Primary Clock Definition
# -----------------------------------------------------------------------------
# Main system clock - 150 MHz
create_clock -period 6.667 -name sys_clk [get_ports clk]

# -----------------------------------------------------------------------------
# Input Delays
# -----------------------------------------------------------------------------
# AXI control interface inputs (estimated external delays)
set_input_delay -clock sys_clk -max 2.0 [all_inputs]
set_input_delay -clock sys_clk -min 0.5 [all_inputs]

# -----------------------------------------------------------------------------
# Output Delays  
# -----------------------------------------------------------------------------
# AXI control interface outputs
set_output_delay -clock sys_clk -max 2.0 [all_outputs]
set_output_delay -clock sys_clk -min 0.5 [all_outputs]

# -----------------------------------------------------------------------------
# False Paths
# -----------------------------------------------------------------------------
# Reset is asynchronous - no timing requirement
set_false_path -from [get_ports rst_n]

# -----------------------------------------------------------------------------
# Clock Uncertainty
# -----------------------------------------------------------------------------
# Add setup uncertainty for FPGA jitter/noise margins
set_clock_uncertainty 0.1 [get_clocks sys_clk]
