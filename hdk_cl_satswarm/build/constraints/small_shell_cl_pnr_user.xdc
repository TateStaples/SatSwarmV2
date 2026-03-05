# =============================================================================
# SatSwarm V2 — small_shell_cl_pnr_user.xdc
#
# Floorplan constraints for BuildAll implementation phase.
# Required by build_level_1_cl.tcl (sourced unconditionally).
#
# SatSwarm has no DDR controllers or PCIe DMA logic that need SLR pinning.
# All solver logic is allowed to float freely across the CL pblock.
# Pblock definitions below are structural stubs that satisfy the HDK script
# without constraining any cells to specific SLRs.
# =============================================================================

###############################################################################
# Child Pblock — SLR2 (no cell assignments for SatSwarm)
###############################################################################
create_pblock pblock_CL_SLR2
resize_pblock pblock_CL_SLR2 -add {CLOCKREGION_X0Y8:CLOCKREGION_X7Y11}
set_property parent pblock_CL [get_pblocks pblock_CL_SLR2]

###############################################################################
# Child Pblock — SLR1 (no cell assignments for SatSwarm)
###############################################################################
create_pblock pblock_CL_SLR1
resize_pblock pblock_CL_SLR1 -add {CLOCKREGION_X0Y4:CLOCKREGION_X7Y7}
set_property parent pblock_CL [get_pblocks pblock_CL_SLR1]

###############################################################################
# Child Pblock — SLR0 (no cell assignments for SatSwarm)
###############################################################################
create_pblock pblock_CL_SLR0
resize_pblock pblock_CL_SLR0 -add {CLOCKREGION_X0Y0:CLOCKREGION_X7Y3}
set_property parent pblock_CL [get_pblocks pblock_CL_SLR0]
