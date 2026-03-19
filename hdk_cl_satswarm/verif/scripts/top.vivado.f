# Amazon FPGA Hardware Development Kit
#
# Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use
# this file except in compliance with the License. A copy of the License is
# located at
#
#    http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file. This file is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
# implied. See the License for the specific language governing permissions and
# limitations under the License.

-define VIVADO_SIM

-sourcelibext .v
-sourcelibext .sv
-sourcelibext .svh

-sourcelibdir ${CL_ROOT}/../common/design
-sourcelibdir ${CL_ROOT}/design
-sourcelibdir ${CL_ROOT}/verif/sv
-sourcelibdir ${SH_LIB_DIR}
-sourcelibdir ${SH_INF_DIR}
-sourcelibdir ${SH_SH_DIR}


-include ${CL_ROOT}/../common/design
-include ${CL_ROOT}/verif/sv
-include ${SH_LIB_DIR}
-include ${SH_INF_DIR}
-include ${SH_SH_DIR}
-include ${HDK_COMMON_DIR}/verif/include

-include ${HDK_COMMON_DIR}/ip/cl_ip/cl_ip.gen/sources_1/ip/axi_register_slice/hdl
-include ${HDK_COMMON_DIR}/ip/cl_ip/cl_ip.gen/sources_1/ip/axi_register_slice_light/hdl

${CL_ROOT}/../common/design/cl_common_defines.vh
-define CL_NAME=cl_satswarm
-sourcelibdir ${CL_ROOT}/../../../../../Mega
-include ${CL_ROOT}/../../../../../Mega



${HDK_COMMON_DIR}/ip/cl_ip/cl_ip.gen/sources_1/ip/axi_clock_converter_0/sim/axi_clock_converter_0.v
${CL_ROOT}/../../../../../Mega/satswarmv2_pkg.sv
${CL_ROOT}/../../../../../Mega/mega_pkg.sv
${CL_ROOT}/../../../../../Mega/interface_unit.sv
${CL_ROOT}/../../../../../Mega/mesh_interconnect.sv
${CL_ROOT}/../../../../../Mega/global_mem_arbiter.sv
${CL_ROOT}/../../../../../Mega/global_allocator.sv
${CL_ROOT}/../../../../../Mega/solver_core.sv
${CL_ROOT}/../../../../../Mega/pse.sv
${CL_ROOT}/../../../../../Mega/cae.sv
${CL_ROOT}/../../../../../Mega/vde.sv
${CL_ROOT}/../../../../../Mega/vde_heap.sv
${CL_ROOT}/../../../../../Mega/trail_manager.sv
${CL_ROOT}/../../../../../Mega/watch_manager.sv
${CL_ROOT}/../../../../../Mega/clause_store.sv
${CL_ROOT}/../../../../../Mega/shared_clause_buffer.sv
${CL_ROOT}/../../../../../Mega/stats_manager.sv
${CL_ROOT}/../../../../../Mega/utils/sfifo.sv
${CL_ROOT}/../../../../../Mega/utils/stack.sv
${CL_ROOT}/../../../../../Mega/satswarm_top.sv

${CL_ROOT}/design/satswarm_core_bridge.sv
${CL_ROOT}/design/cl_satswarm.sv

-f ${HDK_COMMON_DIR}/verif/tb/filelists/tb.${SIMULATOR}.f

${TEST_NAME}
