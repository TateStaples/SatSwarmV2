# =============================================================================
# SatSwarm FPGA Timing Constraints
# Target: Xilinx Zynq UltraScale+ ZU9EG
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
# AXI-Lite control inputs (simplified interface)
set_input_delay -clock sys_clk -max 2.0 [get_ports {axil_wr_valid}]
set_input_delay -clock sys_clk -min 0.5 [get_ports {axil_wr_valid}]
set_input_delay -clock sys_clk -max 2.0 [get_ports {axil_wr_addr[*]}]
set_input_delay -clock sys_clk -min 0.5 [get_ports {axil_wr_addr[*]}]
set_input_delay -clock sys_clk -max 2.0 [get_ports {axil_wr_data[*]}]
set_input_delay -clock sys_clk -min 0.5 [get_ports {axil_wr_data[*]}]
set_input_delay -clock sys_clk -max 2.0 [get_ports {axil_rd_valid}]
set_input_delay -clock sys_clk -min 0.5 [get_ports {axil_rd_valid}]
set_input_delay -clock sys_clk -max 2.0 [get_ports {axil_rd_addr[*]}]
set_input_delay -clock sys_clk -min 0.5 [get_ports {axil_rd_addr[*]}]

# PCIS DMA inputs
set_input_delay -clock sys_clk -max 2.0 [get_ports {pcis_wr_valid}]
set_input_delay -clock sys_clk -min 0.5 [get_ports {pcis_wr_valid}]
set_input_delay -clock sys_clk -max 2.0 [get_ports {pcis_wr_addr[*]}]
set_input_delay -clock sys_clk -min 0.5 [get_ports {pcis_wr_addr[*]}]
set_input_delay -clock sys_clk -max 2.0 [get_ports {pcis_wr_data[*]}]
set_input_delay -clock sys_clk -min 0.5 [get_ports {pcis_wr_data[*]}]

# DDR4 read data path inputs
set_input_delay -clock sys_clk -max 2.0 [get_ports {ddr_read_grant}]
set_input_delay -clock sys_clk -min 0.5 [get_ports {ddr_read_grant}]
set_input_delay -clock sys_clk -max 2.0 [get_ports {ddr_read_data[*]}]
set_input_delay -clock sys_clk -min 0.5 [get_ports {ddr_read_data[*]}]
set_input_delay -clock sys_clk -max 2.0 [get_ports {ddr_read_valid}]
set_input_delay -clock sys_clk -min 0.5 [get_ports {ddr_read_valid}]
set_input_delay -clock sys_clk -max 2.0 [get_ports {ddr_write_grant}]
set_input_delay -clock sys_clk -min 0.5 [get_ports {ddr_write_grant}]

# Reset signal
set_input_delay -clock sys_clk -max 3.0 [get_ports rst_n_in]
set_input_delay -clock sys_clk -min 0.5 [get_ports rst_n_in]

# -----------------------------------------------------------------------------
# Output Delays
# -----------------------------------------------------------------------------
# AXI-Lite outputs
set_output_delay -clock sys_clk -max 2.0 [get_ports {axil_wr_ready}]
set_output_delay -clock sys_clk -min 0.5 [get_ports {axil_wr_ready}]
set_output_delay -clock sys_clk -max 2.0 [get_ports {axil_rd_data[*]}]
set_output_delay -clock sys_clk -min 0.5 [get_ports {axil_rd_data[*]}]
set_output_delay -clock sys_clk -max 2.0 [get_ports {axil_rd_ready}]
set_output_delay -clock sys_clk -min 0.5 [get_ports {axil_rd_ready}]

# PCIS DMA outputs
set_output_delay -clock sys_clk -max 2.0 [get_ports {pcis_wr_ready}]
set_output_delay -clock sys_clk -min 0.5 [get_ports {pcis_wr_ready}]

# DDR4 outputs
set_output_delay -clock sys_clk -max 2.0 [get_ports {ddr_read_req}]
set_output_delay -clock sys_clk -min 0.5 [get_ports {ddr_read_req}]
set_output_delay -clock sys_clk -max 2.0 [get_ports {ddr_read_addr[*]}]
set_output_delay -clock sys_clk -min 0.5 [get_ports {ddr_read_addr[*]}]
set_output_delay -clock sys_clk -max 2.0 [get_ports {ddr_read_len[*]}]
set_output_delay -clock sys_clk -min 0.5 [get_ports {ddr_read_len[*]}]
set_output_delay -clock sys_clk -max 2.0 [get_ports {ddr_write_req}]
set_output_delay -clock sys_clk -min 0.5 [get_ports {ddr_write_req}]
set_output_delay -clock sys_clk -max 2.0 [get_ports {ddr_write_addr[*]}]
set_output_delay -clock sys_clk -min 0.5 [get_ports {ddr_write_addr[*]}]
set_output_delay -clock sys_clk -max 2.0 [get_ports {ddr_write_data[*]}]
set_output_delay -clock sys_clk -min 0.5 [get_ports {ddr_write_data[*]}]

# -----------------------------------------------------------------------------
# False Paths
# -----------------------------------------------------------------------------
# Async reset — no timing requirement on input
set_false_path -from [get_ports rst_n_in]

# -----------------------------------------------------------------------------
# Multi-Cycle Paths
# -----------------------------------------------------------------------------
# DDR4 read path - 4 cycle latency as specified in design
# Uncomment when DDR4 interface is connected
# set_multicycle_path 4 -setup -from [get_clocks ddr4_clk] -to [get_clocks sys_clk]
# set_multicycle_path 3 -hold  -from [get_clocks ddr4_clk] -to [get_clocks sys_clk]

# -----------------------------------------------------------------------------
# Debug Hub (if using ILA)
# -----------------------------------------------------------------------------
# set_property C_CLK_INPUT_FREQ_HZ 150000000 [get_debug_cores dbg_hub]
# set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
