# =============================================================================
# SatSwarm AWS F1 Timing Constraints
# Target: Xilinx Virtex UltraScale+ VU9P (AWS F1)
# Clock: 250 MHz clk_main_a0 provided by AWS Shell
# =============================================================================
#
# NOTE: The AWS Shell handles all external I/O, clocking, and PCIe.
# CL-specific constraints only - Shell constraints are provided by AWS HDK.
#

# -----------------------------------------------------------------------------
# Clock Domain Crossings
# -----------------------------------------------------------------------------
# If using additional clocks from the Shell (clk_extra_a1, etc.)
# set_clock_groups -asynchronous \
#     -group [get_clocks clk_main_a0] \
#     -group [get_clocks clk_extra_a1]

# -----------------------------------------------------------------------------
# False Paths
# -----------------------------------------------------------------------------
# Virtual LED/DIP — async status signals, no timing requirement
set_false_path -to   [get_cells -hierarchical -filter {NAME =~ *cl_sh_status_vled*}]
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *sh_cl_status_vdip*}]

# PCIe FLR handling — async to CL logic
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *flr_assert*}]

# -----------------------------------------------------------------------------
# Multi-Cycle Paths (CL-internal)
# -----------------------------------------------------------------------------
# DDR AXI4 read data path has multi-cycle latency
# The AXI protocol handles this via valid/ready handshaking, but hint the tool
# set_multicycle_path 2 -setup -through [get_pins -hierarchical -filter {NAME =~ *ddr_read*}]
# set_multicycle_path 1 -hold  -through [get_pins -hierarchical -filter {NAME =~ *ddr_read*}]

# -----------------------------------------------------------------------------
# Max Delay Constraints (Critical CL Paths)
# -----------------------------------------------------------------------------
# PSE watch-list traversal
# set_max_delay 3.5 -from [get_pins -hierarchical -filter {NAME =~ *pse_inst/cursor_*}] \
#                   -to   [get_pins -hierarchical -filter {NAME =~ *pse_inst/clause_data_*}]

# CAE conflict analysis
# set_max_delay 3.5 -from [get_pins -hierarchical -filter {NAME =~ *cae_inst/resolve_*}] \
#                   -to   [get_pins -hierarchical -filter {NAME =~ *cae_inst/learned_*}]

# VDE heap operations
# set_max_delay 3.0 -from [get_pins -hierarchical -filter {NAME =~ *vde_inst/heap_*}] \
#                   -to   [get_pins -hierarchical -filter {NAME =~ *vde_inst/min_var_*}]
