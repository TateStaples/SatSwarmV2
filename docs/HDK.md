# AWS HDK Reference

This document points to relevant AWS FPGA HDK documentation bundled in this repository. Use it when working on shell integration, clocks, synthesis, or debugging hardware issues. For SatSwarm-specific workflows, see `Synth.md`, `Verification.md`, and `FPGA.md`.

All paths below are relative to the project root. The HDK lives under `src/aws-fpga/`.

---

## Shell Interface & Constraints

| Document | Path | Purpose |
|----------|------|---------|
| **AWS Shell Interface Specification** | [src/aws-fpga/hdk/docs/AWS_Shell_Interface_Specification.md](src/aws-fpga/hdk/docs/AWS_Shell_Interface_Specification.md) | Authoritative spec for Shell–CL interfaces: OCL, SDA, PCIS, PCIM, clocks, resets, timeouts. |
| **AWS Shell ERRATA** | [src/aws-fpga/hdk/docs/AWS_Shell_ERRATA.md](src/aws-fpga/hdk/docs/AWS_Shell_ERRATA.md) | Implementation restrictions: 4K address boundary, 8 µs timeout, 32 outstanding reads, 64B AxSIZE for PCIM/DMA. |
| **PCIe Memory Map** | [src/aws-fpga/hdk/docs/AWS_Fpga_Pcie_Memory_Map.md](src/aws-fpga/hdk/docs/AWS_Fpga_Pcie_Memory_Map.md) | BAR layout: BAR0 (OCL, 64 MiB), BAR4 (PCIS, 128 GiB), prefetchable behavior. |

---

## Clocks & Build

| Document | Path | Purpose |
|----------|------|---------|
| **Clock Recipes User Guide** | [src/aws-fpga/hdk/docs/Clock_Recipes_User_Guide.md](src/aws-fpga/hdk/docs/Clock_Recipes_User_Guide.md) | F2 clock recipe tables (A/B/C/H groups), build-time `--clock_recipe_*` options, runtime dynamic config. SatSwarm uses A2 (15.625 MHz). |
| **AWS_CLK_GEN Spec** | [src/aws-fpga/hdk/docs/AWS_CLK_GEN_spec.md](src/aws-fpga/hdk/docs/AWS_CLK_GEN_spec.md) | Clock generator IP: address space, registers (ID_REG, VER_REG, MMCM_LOCK_REG), reset control. |

---

## Debugging & Troubleshooting

| Document | Path | Purpose |
|----------|------|---------|
| **How to Detect Shell Timeout** | [src/aws-fpga/hdk/docs/How_To_Detect_Shell_Timeout.md](src/aws-fpga/hdk/docs/How_To_Detect_Shell_Timeout.md) | Use `fpga-describe-local-image -S 0 --metrics` to check `ocl-slave-timeout`, `dma-pcis-timeout`, offending addresses. After timeout, AFI must be re-loaded. |

---

## Simulation

| Document | Path | Purpose |
|----------|------|---------|
| **RTL Simulation Guide** | [src/aws-fpga/hdk/docs/RTL_Simulation_Guide_for_HDK_Design_Flow.md](src/aws-fpga/hdk/docs/RTL_Simulation_Guide_for_HDK_Design_Flow.md) | XSim/VCS/Questa setup, protocol checkers, wave dumping, SV/C test API reference. |

---

## AFI & Deployment

| Document | Path | Purpose |
|----------|------|---------|
| **Amazon FPGA Images (AFIs) Guide** | [src/aws-fpga/hdk/docs/Amazon_FPGA_Images_Afis_Guide.md](src/aws-fpga/hdk/docs/Amazon_FPGA_Images_Afis_Guide.md) | AFI lifecycle, creation, loading. |
| **AFI Manifest** | [src/aws-fpga/hdk/docs/AFI_Manifest.md](src/aws-fpga/hdk/docs/AFI_Manifest.md) | Manifest format and metadata. |
| **AWS CLI FPGA Commands** | [src/aws-fpga/hdk/docs/AWS_CLI_FPGA_Commands.md](src/aws-fpga/hdk/docs/AWS_CLI_FPGA_Commands.md) | `aws ec2 create-fpga-image`, `describe-fpga-images`, etc. |

---

## Other HDK Docs

| Document | Path | Purpose |
|----------|------|---------|
| **Supported DDR Modes** | [src/aws-fpga/hdk/docs/Supported_DDR_Modes.md](src/aws-fpga/hdk/docs/Supported_DDR_Modes.md) | DDR configuration options if using external memory. |
| **Virtual JTAG (XVC)** | [src/aws-fpga/hdk/docs/Virtual_JTAG_XVC.md](src/aws-fpga/hdk/docs/Virtual_JTAG_XVC.md) | Remote debug via Virtual JTAG. |
| **XDMA Install** | [src/aws-fpga/hdk/docs/XDMA_Install.md](src/aws-fpga/hdk/docs/XDMA_Install.md) | XDMA driver setup (if using XDMA instead of shell DMA). |
| **IPI GUI** | [IPI-GUI-Flows](src/aws-fpga/hdk/docs/IPI-GUI-Flows.md), [IPI-GUI-AWS-IP](src/aws-fpga/hdk/docs/IPI-GUI-AWS-IP.md), [IPI-GUI-Vivado-Setup](src/aws-fpga/hdk/docs/IPI-GUI-Vivado-Setup.md) | IP Integrator GUI flows for CL design. |
| **Shell Floorplan** | [src/aws-fpga/hdk/docs/shell_floorplan.md](src/aws-fpga/hdk/docs/shell_floorplan.md) | Shell floorplan reference. |
