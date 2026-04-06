# DDR Glossary and File Index

This page is a quick index for DDR usage in this repo, especially for AWS F2 HDK integration.

## Start Here

- AWS Shell DDR interface rules: [src/aws-fpga/hdk/docs/AWS_Shell_Interface_Specification.md](../src/aws-fpga/hdk/docs/AWS_Shell_Interface_Specification.md)
- Supported DDR controller modes/macros: [src/aws-fpga/hdk/docs/Supported_DDR_Modes.md](../src/aws-fpga/hdk/docs/Supported_DDR_Modes.md)
- PCIe BAR map (host access path to DDR via BAR4/PCIS): [src/aws-fpga/hdk/docs/AWS_Fpga_Pcie_Memory_Map.md](../src/aws-fpga/hdk/docs/AWS_Fpga_Pcie_Memory_Map.md)
- Shell timeout behavior for DDR-heavy traffic: [src/aws-fpga/hdk/docs/How_To_Detect_Shell_Timeout.md](../src/aws-fpga/hdk/docs/How_To_Detect_Shell_Timeout.md)

## Key DDR Concepts

- SH_DDR:
  - AWS-provided DDR subsystem wrapper used in CL top-level RTL.
  - Must be instantiated even when DDR is disabled (use DDR_PRESENT=0).
  - Source: [src/aws-fpga/hdk/common/shell_stable/design/sh_ddr/synth/sh_ddr.sv](../src/aws-fpga/hdk/common/shell_stable/design/sh_ddr/synth/sh_ddr.sv)

- DDR_PRESENT:
  - Parameter passed to SH_DDR to enable/disable DDR controller internals while keeping required top-level structure.

- cl_sh_ddr_axi_*:
  - 512-bit AXI4 DDR data path between CL and SH_DDR.

- sh_cl_ddr_stat_* / cl_sh_ddr_stat_*:
  - Shell management/status interface required for DDR training/calibration flow.
  - If incorrectly wired, DDR may not function.

- sh_cl_ddr_is_ready:
  - DDR trained/ready signal from SH_DDR.
  - Gate DDR traffic until asserted.

- PCIS DDR mapping:
  - Host and shell DMA traffic enters via BAR4/PCIS and is decoded to DDR/HBM windows by CL interconnect logic.

## Primary Reference Examples

- CL_DRAM_HBM_DMA (best practical DDR integration reference):
  - Overview and memory map: [src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/README.md](../src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/README.md)
  - Top-level CL with SH_DDR integration: [src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/design/cl_dram_hbm_dma.sv](../src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/design/cl_dram_hbm_dma.sv)
  - PCIS address decode to DDR/HBM: [src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/design/cl_dma_pcis_slv.sv](../src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/design/cl_dma_pcis_slv.sv)
  - Runtime DMA test (DDR+HBM): [src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/software/runtime/test_dram_hbm_dma.c](../src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/software/runtime/test_dram_hbm_dma.c)

- CL_MEM_PERF (performance-oriented DDR/HBM reference):
  - Overview: [src/aws-fpga/hdk/cl/examples/cl_mem_perf/README.md](../src/aws-fpga/hdk/cl/examples/cl_mem_perf/README.md)
  - Top-level CL with SH_DDR integration and clocking strategy: [src/aws-fpga/hdk/cl/examples/cl_mem_perf/design/cl_mem_perf.sv](../src/aws-fpga/hdk/cl/examples/cl_mem_perf/design/cl_mem_perf.sv)
  - Defines/macros (including AP DDR mode comment): [src/aws-fpga/hdk/cl/examples/cl_mem_perf/design/cl_mem_perf_defines.vh](../src/aws-fpga/hdk/cl/examples/cl_mem_perf/design/cl_mem_perf_defines.vh)

## Build Script Files That Matter for DDR

- CL_DRAM_HBM_DMA synthesis (explicit DDR IP list): [src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/build/scripts/synth_cl_dram_hbm_dma.tcl](../src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/build/scripts/synth_cl_dram_hbm_dma.tcl)
- CL_MEM_PERF synthesis (reads multiple DDR XCI variants): [src/aws-fpga/hdk/cl/examples/cl_mem_perf/build/scripts/synth_cl_mem_perf.tcl](../src/aws-fpga/hdk/cl/examples/cl_mem_perf/build/scripts/synth_cl_mem_perf.tcl)
- Build level-1 flow (includes DDR training TCL):
  - [src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/build/scripts/build_level_1_cl.tcl](../src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/build/scripts/build_level_1_cl.tcl)
  - [src/aws-fpga/hdk/cl/examples/cl_mem_perf/build/scripts/build_level_1_cl.tcl](../src/aws-fpga/hdk/cl/examples/cl_mem_perf/build/scripts/build_level_1_cl.tcl)

## Constraint Files with DDR Placement/Timing Notes

- CL_DRAM_HBM_DMA user timing constraints: [src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/build/constraints/cl_timing_user.xdc](../src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/build/constraints/cl_timing_user.xdc)
- CL_DRAM_HBM_DMA pblock constraints: [src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/build/constraints/xdma_shell_cl_pnr_user.xdc](../src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/build/constraints/xdma_shell_cl_pnr_user.xdc)
- CL_MEM_PERF user timing constraints: [src/aws-fpga/hdk/cl/examples/cl_mem_perf/build/constraints/cl_timing_user.xdc](../src/aws-fpga/hdk/cl/examples/cl_mem_perf/build/constraints/cl_timing_user.xdc)
- CL_MEM_PERF pblock constraints: [src/aws-fpga/hdk/cl/examples/cl_mem_perf/build/constraints/xdma_shell_cl_pnr_user.xdc](../src/aws-fpga/hdk/cl/examples/cl_mem_perf/build/constraints/xdma_shell_cl_pnr_user.xdc)

## Typical Bring-Up Checklist (File-Oriented)

1. Confirm SH_DDR and stats wiring in CL top:
   - [src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/design/cl_dram_hbm_dma.sv](../src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/design/cl_dram_hbm_dma.sv)
   - [src/aws-fpga/hdk/cl/examples/cl_mem_perf/design/cl_mem_perf.sv](../src/aws-fpga/hdk/cl/examples/cl_mem_perf/design/cl_mem_perf.sv)
2. Confirm DDR mode macro strategy:
   - [src/aws-fpga/hdk/docs/Supported_DDR_Modes.md](../src/aws-fpga/hdk/docs/Supported_DDR_Modes.md)
   - [src/aws-fpga/hdk/cl/examples/cl_mem_perf/design/cl_mem_perf_defines.vh](../src/aws-fpga/hdk/cl/examples/cl_mem_perf/design/cl_mem_perf_defines.vh)
3. Confirm synthesis script includes matching DDR XCI(s):
   - [src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/build/scripts/synth_cl_dram_hbm_dma.tcl](../src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/build/scripts/synth_cl_dram_hbm_dma.tcl)
   - [src/aws-fpga/hdk/cl/examples/cl_mem_perf/build/scripts/synth_cl_mem_perf.tcl](../src/aws-fpga/hdk/cl/examples/cl_mem_perf/build/scripts/synth_cl_mem_perf.tcl)
4. Confirm PCIS address decode maps host BAR4 space into DDR range:
   - [src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/design/cl_dma_pcis_slv.sv](../src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/design/cl_dma_pcis_slv.sv)
5. Validate host runtime path with DMA test:
   - [src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/software/runtime/test_dram_hbm_dma.c](../src/aws-fpga/hdk/cl/examples/cl_dram_hbm_dma/software/runtime/test_dram_hbm_dma.c)

## Related Project Docs

- HDK overview in this project docs folder: [docs/HDK.md](HDK.md)
- Synthesis flow notes: [docs/Synth.md](Synth.md)
- FPGA deployment/testing notes: [docs/FPGA.md](FPGA.md)
- Verification notes: [docs/Verification.md](Verification.md)
