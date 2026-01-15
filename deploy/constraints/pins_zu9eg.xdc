# =============================================================================
# VeriSAT FPGA Pin Constraints
# Target: Xilinx Zynq UltraScale+ ZU9EG
# Board: Generic / Placeholder - CUSTOMIZE FOR YOUR BOARD
# =============================================================================
#
# IMPORTANT: These are PLACEHOLDER pin assignments!
# You MUST update these for your specific development board:
#   - ZCU102: See UG1182 for pin mappings
#   - ZCU104: See UG1267 for pin mappings
#   - Custom board: Use your schematic
#
# =============================================================================

# -----------------------------------------------------------------------------
# System Clock
# -----------------------------------------------------------------------------
# ZCU102/104 typically use a PL-side clock from the PS or an external oscillator
# Example: 150 MHz clock on ZCU104 USER_SI570 clock

# Differential clock input (typical for high-speed clocks)
# set_property PACKAGE_PIN AL8  [get_ports clk_p]
# set_property PACKAGE_PIN AL7  [get_ports clk_n]
# set_property IOSTANDARD LVDS [get_ports clk_p]
# set_property IOSTANDARD LVDS [get_ports clk_n]

# Single-ended clock (alternative)
set_property PACKAGE_PIN F23  [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]

# -----------------------------------------------------------------------------
# Reset
# -----------------------------------------------------------------------------
# Active-high reset, directly from button or PS
set_property PACKAGE_PIN G25  [get_ports reset]
set_property IOSTANDARD LVCMOS18 [get_ports reset]

# -----------------------------------------------------------------------------
# Status LEDs
# -----------------------------------------------------------------------------
# Useful for debugging solver state
set_property PACKAGE_PIN AG14 [get_ports {status[0]}]
set_property PACKAGE_PIN AF13 [get_ports {status[1]}]
set_property PACKAGE_PIN AE13 [get_ports {status[2]}]
set_property PACKAGE_PIN AJ14 [get_ports {status[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {status[*]}]

# -----------------------------------------------------------------------------
# AXI4-Lite Control Interface (to PS or external controller)
# -----------------------------------------------------------------------------
# These pins connect to the Zynq PS via HP/HPC ports
# For ZCU102/104, the AXI interface is typically internal via PS-PL
# Below are example PL-side pins if using external AXI master

# AXI Write Address Channel
# set_property PACKAGE_PIN Y20  [get_ports {axi_awaddr[0]}]
# ... (repeat for all address bits)

# AXI Write Data Channel
# set_property PACKAGE_PIN AA20 [get_ports {axi_wdata[0]}]
# ... (repeat for all data bits)

# AXI Read Channels
# set_property PACKAGE_PIN AB20 [get_ports {axi_araddr[0]}]
# set_property PACKAGE_PIN AC20 [get_ports {axi_rdata[0]}]

# -----------------------------------------------------------------------------
# DDR4 Interface (if using external memory)
# -----------------------------------------------------------------------------
# NOTE: DDR4 pin assignments are board-specific and complex
# For ZCU102/104, use the MIG IP wizard to generate correct pinout
# The pins below are EXAMPLES ONLY and will NOT work without modification

# DDR4 Address (typically directly connected to DDR4 DIMM/chip)
# set_property PACKAGE_PIN AM12 [get_ports {ddr4_adr[0]}]
# set_property PACKAGE_PIN AL13 [get_ports {ddr4_adr[1]}]
# ... (continue for all address bits)

# DDR4 Data
# set_property PACKAGE_PIN AP3  [get_ports {ddr4_dq[0]}]
# set_property PACKAGE_PIN AP4  [get_ports {ddr4_dq[1]}]
# ... (continue for all 64/72 data bits)

# DDR4 Control
# set_property PACKAGE_PIN AN11 [get_ports ddr4_ck_p]
# set_property PACKAGE_PIN AN10 [get_ports ddr4_ck_n]
# set_property PACKAGE_PIN AM11 [get_ports ddr4_cs_n]
# set_property PACKAGE_PIN AL11 [get_ports ddr4_ras_n]
# set_property PACKAGE_PIN AK11 [get_ports ddr4_cas_n]
# set_property PACKAGE_PIN AJ11 [get_ports ddr4_we_n]
# set_property PACKAGE_PIN AH11 [get_ports ddr4_reset_n]

# set_property IOSTANDARD POD12_DCI [get_ports {ddr4_dq[*]}]
# set_property IOSTANDARD SSTL12_DCI [get_ports {ddr4_adr[*]}]

# -----------------------------------------------------------------------------
# UART Debug (optional)
# -----------------------------------------------------------------------------
set_property PACKAGE_PIN F13  [get_ports uart_tx]
set_property PACKAGE_PIN E13  [get_ports uart_rx]
set_property IOSTANDARD LVCMOS18 [get_ports uart_*]

# -----------------------------------------------------------------------------
# Configuration and Bitstream Settings
# -----------------------------------------------------------------------------
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]

# Bitstream compression (reduces programming time)
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# Enable bitstream encryption (optional, requires key)
# set_property BITSTREAM.ENCRYPTION.ENCRYPT YES [current_design]

# SPI flash configuration mode (for persistent configuration)
# set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
# set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
