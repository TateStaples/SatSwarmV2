# =============================================================================
# Amazon FPGA Hardware Development Kit
#
# Copyright 2024 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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
# =============================================================================

# -----------------------------------------------------------------------------
# Solver domain clock: CL-owned MMCME4_ADV
#   clk_main_a0 (250 MHz) -> MMCM -> clk_solver (15.625 MHz)
#
# Vivado auto-propagates a generated clock through the MMCM primitive based
# on its CLKFBOUT_MULT_F and CLKOUT0_DIVIDE_F parameters. No manual
# create_generated_clock is needed; the auto-generated clock is referenced
# by pin in the false-path exceptions below.
#
# Verification after any build:
#   report_clocks          — confirm MMCM-derived clock at ~64 ns
#   check_timing           — no unconstrained solver endpoints
#   report_clock_interaction — false paths cover all CDC crossings
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# CDC false paths: every crossing between clk_main_a0 and the MMCM-derived
# solver clock uses a 2-FF synchronizer or AXI clock converter, so Vivado
# must not attempt single-cycle timing analysis across the domain boundary.
# -----------------------------------------------------------------------------
set_false_path -from [get_clocks clk_main_a0] \
    -to [get_clocks -of_objects [get_pins u_mmcm_solver/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_solver/CLKOUT0]] \
    -to [get_clocks clk_main_a0]
