# =============================================================================
# SatSwarm CL — XSim file list
# =============================================================================

-define CL_NAME=cl_satswarm
-define DISABLE_VJTAG_DEBUG

-include $CL_DIR/verif/tests
-f ${HDK_COMMON_DIR}/verif/tb/filelists/tb.${SIMULATOR}.f
${TEST_NAME}

-include ${CL_DIR}/design
-include ${HDK_COMMON_DIR}/verif/include
-include ${CL_DIR}/../../../../../Mega

${CL_DIR}/../../../../../Mega/satswarmv2_pkg.sv
${CL_DIR}/../../../../../Mega/mega_pkg.sv
${CL_DIR}/../../../../../Mega/interface_unit.sv
${CL_DIR}/../../../../../Mega/mesh_interconnect.sv
${CL_DIR}/../../../../../Mega/global_mem_arbiter.sv
${CL_DIR}/../../../../../Mega/global_allocator.sv
${CL_DIR}/../../../../../Mega/solver_core.sv
${CL_DIR}/../../../../../Mega/pse.sv
${CL_DIR}/../../../../../Mega/cae.sv
${CL_DIR}/../../../../../Mega/vde.sv
${CL_DIR}/../../../../../Mega/vde_heap.sv
${CL_DIR}/../../../../../Mega/trail_manager.sv
${CL_DIR}/../../../../../Mega/watch_manager.sv
${CL_DIR}/../../../../../Mega/clause_store.sv
${CL_DIR}/../../../../../Mega/shared_clause_buffer.sv
${CL_DIR}/../../../../../Mega/stats_manager.sv
${CL_DIR}/../../../../../Mega/utils/sfifo.sv
${CL_DIR}/../../../../../Mega/utils/stack.sv
${CL_DIR}/../../../../../Mega/satswarm_top.sv

${CL_DIR}/design/satswarm_core_bridge.sv
${CL_DIR}/design/cl_satswarm.sv
