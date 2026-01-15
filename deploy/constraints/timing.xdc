# =============================================================================
# VeriSAT FPGA Timing Constraints
# Target: Xilinx Zynq UltraScale+ ZU9EG
# Clock: 150 MHz (6.667 ns period)
# =============================================================================

# -----------------------------------------------------------------------------
# Primary Clock Definition
# -----------------------------------------------------------------------------
# Main system clock - 150 MHz
# Adjust the clock pin based on your board's clock source
create_clock -period 6.667 -name sys_clk [get_ports clk]

# -----------------------------------------------------------------------------
# Generated Clocks (if applicable)
# -----------------------------------------------------------------------------
# DDR4 interface clock - typically 300 MHz (derived from PLL)
# create_generated_clock -name ddr4_clk -source [get_pins mmcm_inst/CLKOUT0] \
#     -divide_by 1 [get_pins ddr4_phy/clk]

# -----------------------------------------------------------------------------
# Clock Groups
# -----------------------------------------------------------------------------
# Asynchronous clock domains (if multiple clock sources)
# set_clock_groups -asynchronous \
#     -group [get_clocks sys_clk] \
#     -group [get_clocks ddr4_clk]

# -----------------------------------------------------------------------------
# Input Delays
# -----------------------------------------------------------------------------
# AXI control interface inputs
# Adjust values based on actual board trace delays
set_input_delay -clock sys_clk -max 2.0 [get_ports {axi_*_tdata[*]}]
set_input_delay -clock sys_clk -min 0.5 [get_ports {axi_*_tdata[*]}]
set_input_delay -clock sys_clk -max 2.0 [get_ports {axi_*_tvalid}]
set_input_delay -clock sys_clk -min 0.5 [get_ports {axi_*_tvalid}]

# Reset signal
set_input_delay -clock sys_clk -max 3.0 [get_ports reset]
set_input_delay -clock sys_clk -min 0.5 [get_ports reset]

# -----------------------------------------------------------------------------
# Output Delays
# -----------------------------------------------------------------------------
# AXI control interface outputs
set_output_delay -clock sys_clk -max 2.0 [get_ports {axi_*_tready}]
set_output_delay -clock sys_clk -min 0.5 [get_ports {axi_*_tready}]

# Status outputs
set_output_delay -clock sys_clk -max 2.0 [get_ports {status[*]}]
set_output_delay -clock sys_clk -min 0.5 [get_ports {status[*]}]

# -----------------------------------------------------------------------------
# False Paths
# -----------------------------------------------------------------------------
# Reset synchronizer - async reset, no timing requirement on input
set_false_path -from [get_ports reset]

# Configuration/static signals (if any)
# set_false_path -from [get_cells {config_reg[*]}]

# -----------------------------------------------------------------------------
# Multi-Cycle Paths
# -----------------------------------------------------------------------------
# DDR4 read path - 4 cycle latency as specified in design
# Uncomment when DDR4 interface is connected
# set_multicycle_path 4 -setup -from [get_clocks ddr4_clk] -to [get_clocks sys_clk]
# set_multicycle_path 3 -hold  -from [get_clocks ddr4_clk] -to [get_clocks sys_clk]

# Activity decay in VDE (happens once per 1000+ cycles)
# set_multicycle_path 2 -setup -through [get_pins vde_inst/decay_*]
# set_multicycle_path 1 -hold  -through [get_pins vde_inst/decay_*]

# -----------------------------------------------------------------------------
# Max Delay Constraints (Critical Paths)
# -----------------------------------------------------------------------------
# PSE watch-list traversal - ensure single-cycle reads
# set_max_delay 6.0 -from [get_pins pse_inst/cursor_*] -to [get_pins pse_inst/clause_data_*]

# CAE conflict analysis - pipelined but tight timing
# set_max_delay 6.0 -from [get_pins cae_inst/resolve_*] -to [get_pins cae_inst/learned_*]

# VDE heap operations
# set_max_delay 5.5 -from [get_pins vde_inst/heap_*] -to [get_pins vde_inst/min_var_*]

# -----------------------------------------------------------------------------
# Physical Constraints
# -----------------------------------------------------------------------------
# Pblock for solver core (optional, for large designs)
# create_pblock pblock_solver
# add_cells_to_pblock [get_pblocks pblock_solver] [get_cells solver_core_inst]
# resize_pblock [get_pblocks pblock_solver] -add {CLOCKREGION_X0Y0:CLOCKREGION_X3Y3}

# -----------------------------------------------------------------------------
# Debug Hub (if using ILA)
# -----------------------------------------------------------------------------
# set_property C_CLK_INPUT_FREQ_HZ 150000000 [get_debug_cores dbg_hub]
# set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
