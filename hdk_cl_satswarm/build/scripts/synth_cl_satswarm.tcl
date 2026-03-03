# =============================================================================
# SatSwarm CL Synthesis Script
#
# Follows the standard AWS HDK CL synthesis pattern.
# Adapted from CL_TEMPLATE/build/scripts/synth_CL_TEMPLATE.tcl
# =============================================================================


# Common header
source ${HDK_SHELL_DIR}/build/scripts/synth_cl_header.tcl


###############################################################################
print "Reading encrypted user source codes"
###############################################################################

# CL wrapper sources (copied from design/ by encrypt.tcl)
read_verilog -sv [glob ${src_post_enc_dir}/*.{s,}v]

# Defines header -- must be loaded as a global include so its macros
# (CL_NAME, FPGA_LESS_RST, etc.) are visible inside encrypted IP like sh_ddr.
# This mirrors the cl_dram_hbm_dma reference pattern.
read_verilog -sv ${src_post_enc_dir}/cl_satswarm_defines.vh
set_property file_type {Verilog Header} [get_files ${src_post_enc_dir}/cl_satswarm_defines.vh]
set_property is_global_include true     [get_files ${src_post_enc_dir}/cl_satswarm_defines.vh]

# SatSwarm RTL core sources
if {[info exists ::env(SATSWARM_RTL_DIR)]} {
    set rtl_dir $::env(SATSWARM_RTL_DIR)
} else {
    set rtl_dir [file normalize "/home/ubuntu/src/project_data/SatSwarmV2/src/Mega"]
}
print "Reading SatSwarm RTL from ${rtl_dir}"

# Package first
read_verilog -sv ${rtl_dir}/satswarmv2_pkg.sv

# All RTL modules (skip package and testbench files)
foreach f [glob -nocomplain ${rtl_dir}/*.sv] {
    set tail [file tail $f]
    if {$tail eq "satswarmv2_pkg.sv"}       { continue }
    if {[string match "tb_*" $tail]}        { continue }
    read_verilog -sv $f
}

# Utility modules
foreach f [glob -nocomplain ${rtl_dir}/utils/*.sv] {
    set tail [file tail $f]
    if {[string match "tb_*" $tail]} { continue }
    read_verilog -sv $f
}


###############################################################################
print "Reading CL IP blocks"
###############################################################################

## DDR IP -- loaded for sh_ddr elaboration even though DDR_PRESENT=0 (excludes the controller at elaboration time)
read_ip [ list \
  ${HDK_IP_SRC_DIR}/cl_ddr4/cl_ddr4.xci \
]

## Clocking IPs -- required for sh_ddr elaboration when SH_CL_ASYNC and SH_SDA
## are defined (matches cl_dram_hbm_dma and cl_mem_perf reference patterns)
read_ip [ list \
  $HDK_SHELL_DESIGN_DIR/../../ip/cl_ip/cl_ip.srcs/sources_1/ip/clk_mmcm_a/clk_mmcm_a.xci \
  $HDK_SHELL_DESIGN_DIR/../../ip/cl_ip/cl_ip.srcs/sources_1/ip/clk_mmcm_b/clk_mmcm_b.xci \
  $HDK_SHELL_DESIGN_DIR/../../ip/cl_ip/cl_ip.srcs/sources_1/ip/clk_mmcm_c/clk_mmcm_c.xci \
  $HDK_SHELL_DESIGN_DIR/../../ip/cl_ip/cl_ip.srcs/sources_1/ip/clk_mmcm_hbm/clk_mmcm_hbm.xci \
  $HDK_SHELL_DESIGN_DIR/../../ip/cl_ip/cl_ip.srcs/sources_1/ip/cl_clk_axil_xbar/cl_clk_axil_xbar.xci \
  $HDK_SHELL_DESIGN_DIR/../../ip/cl_ip/cl_ip.srcs/sources_1/ip/cl_sda_axil_xbar/cl_sda_axil_xbar.xci \
]

## AXI Register Slice IPs
## Note: cl_axi_register_slice_light is required by aws_clk_gen.sv (SLICE_AXIL_* instances).
## It lives in cl_ip.srcs (not HDK_IP_SRC_DIR which points to cl_ip.gen), so path is explicit.
read_ip [ list \
  ${HDK_IP_SRC_DIR}/axi_register_slice/axi_register_slice.xci \
  ${HDK_IP_SRC_DIR}/axi_register_slice_light/axi_register_slice_light.xci \
  ${HDK_IP_SRC_DIR}/cl_axi3_256b_reg_slice/cl_axi3_256b_reg_slice.xci \
  $HDK_SHELL_DESIGN_DIR/../../ip/cl_ip/cl_ip.srcs/sources_1/ip/cl_axi_register_slice_light/cl_axi_register_slice_light.xci \
  $HDK_SHELL_DESIGN_DIR/../../ip/cl_ip/cl_ip.srcs/sources_1/ip/cl_axi_register_slice/cl_axi_register_slice.xci \
]

## AXI Conversion IPs
read_ip [ list \
  ${HDK_IP_SRC_DIR}/cl_axi_clock_converter/cl_axi_clock_converter.xci \
  ${HDK_IP_SRC_DIR}/cl_axi_clock_converter_light/cl_axi_clock_converter_light.xci \
]

## AXI Utility IPs
read_ip [ list \
  ${HDK_IP_SRC_DIR}/cl_axi_interconnect_64G_ddr/cl_axi_interconnect_64G_ddr.xci \
]


###############################################################################
print "Reading user constraints"
###############################################################################

read_xdc [ list \
  ${constraints_dir}/cl_synth_user.xdc \
  ${constraints_dir}/cl_timing_user.xdc
]

set_property PROCESSING_ORDER LATE [get_files cl_synth_user.xdc]
set_property PROCESSING_ORDER LATE [get_files cl_timing_user.xdc]


###############################################################################
print "Starting synthesizing customer design ${CL}"
###############################################################################
update_compile_order -fileset sources_1

# Attempt 10: single worker + simplified timing model to minimize Tech Map memory
# (RuntimeOptimized reduces device-constant timing overhead; flatten rebuilt
#  limits cross-hierarchy cone analysis; 1 thread halves CoW process overhead)
set_param general.maxThreads 1

synth_design -mode out_of_context \
             -top ${CL} \
             -verilog_define XSDB_SLV_DIS \
             -part ${DEVICE_TYPE} \
             -keep_equivalent_registers \
             -global_retiming off \
             -flatten_hierarchy rebuilt \
             -directive RuntimeOptimized


###############################################################################
print "Connecting debug network"
###############################################################################

# No debug probes for now


# Common footer
source ${HDK_SHELL_DIR}/build/scripts/synth_cl_footer.tcl
