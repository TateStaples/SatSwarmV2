# cl_satswarm — AWS HDK CL Top

**Source:** [design/cl_satswarm.sv](../../src/aws-fpga/hdk/cl/examples/cl_satswarm/design/cl_satswarm.sv)

## Overview

`cl_satswarm` is the AWS F2 HDK Customer Logic (CL) top-level. It bridges the AWS Shell interfaces to `satswarm_core_bridge`'s simplified interface. Uses `cl_ports.vh` for the full port list.

## Interfaces Used

- **OCL AXI-Lite (AppPF BAR0):** Register reads/writes (status, control)
- **DMA_PCIS AXI4 (512-bit):** CNF literal loading via DMA
- **DDR4 AXI4 via sh_ddr:** Clause database memory

## Interfaces Tied Off

- SDA, PCIM, HBM, PCIe EP/RP, JTAG, Virtual JTAG, HBM Monitor, Interrupts

## Parameters

| Parameter | Default | Description |
|-----------|---------|--------------|
| `GRID_X` | 1 | Grid X |
| `GRID_Y` | 1 | Grid Y |
| `MAX_VARS_PER_CORE` | 256 | Max variables per core |
| `MAX_CLAUSES_PER_CORE` | 512 | Max clauses per core |
| `MAX_LITS` | 1024 | Max literals |

## Internal Structure

### Reset

- `lib_pipe` (4 stages) for `rst_main_n` synchronization to `clk_main_a0`

### Clocking (AWS_CLK_GEN)

- `aws_clk_gen` — CLK_GRP_A_EN=1, others 0, HBM_EN=0
- Outputs: `gen_clk_main_a0`, `gen_clk_extra_a1/a2/a3`, `gen_rst_main_n`, `gen_rst_a1_n` etc.
- `i_clk_hbm_ref` = `clk_hbm_ref` (REQP-123 fix)

### AXI Clock Domain Crossing

- **OCL_CDC:** clk_main_a0 → gen_clk_extra_a1 (AXI-Lite)
- **PCIS_CDC:** clk_main_a0 → gen_clk_extra_a1 (DMA 512-bit)
- **DDR_CDC:** gen_clk_extra_a1 → clk_main_a0 (DDR to shell)

### OCL AXI-Lite Handling

- Write/Read channel logic drives `axil_wr_valid`, `axil_wr_addr`, `axil_wr_data`, `axil_rd_valid`, `axil_rd_addr`; receives `axil_rd_data`, `axil_rd_ready` from bridge

### DMA PCIS → CNF Load

- Writes to 0x1000 (literal, clause_end=0) and 0x1004 (literal, clause_end=1) mapped to bridge's `pcis_wr_*`

### Status LED (cl_sh_status_vled)

- `solver_done`, `solver_sat`, `solver_unsat` from bridge status (host_done, host_sat, host_unsat)
- **CDC:** `xpm_cdc_single` (DEST_SYNC_FF=2) for each bit: user clock (gen_clk_extra_a1) → clk_main_a0
- `cl_sh_status_vled` = {13'b0, solver_unsat_sync, solver_sat_sync, solver_done_sync}

### satswarm_core_bridge

- Instantiated with `gen_clk_extra_a1`, `gen_rst_a1_n`
- Connects to OCL, PCIS, DDR interfaces

## Behavior (RTL Specification)

### Reset
lib_pipe (4 stages) synchronizes rst_main_n to clk_main_a0 → rst_main_n_sync.

### Clocking
aws_clk_gen: i_clk_main_a0, i_rst_main_n, i_clk_hbm_ref (must be toggling; REQP-123). Outputs gen_clk_main_a0, gen_clk_extra_a1/a2/a3, gen_rst_main_n, gen_rst_a1_n, etc.

### OCL CDC
cl_axi_clock_converter_light: clk_main_a0 → gen_clk_extra_a1. Maps ocl_cl_* to slv_ocl_*.

### PCIS CDC
cl_axi_clock_converter_light: clk_main_a0 → gen_clk_extra_a1. Maps DMA write channel to pcis_wr_*.

### DMA address decode
Writes to 0x1000: literal, clause_end=0. Writes to 0x1004: literal, clause_end=1. pcis_wr_data → host_load_literal (signed).

### Status LED
solver_done/sat/unsat from bridge. xpm_cdc_single (DEST_SYNC_FF=2) per bit: gen_clk_extra_a1 → clk_main_a0. cl_sh_status_vled = {13'b0, solver_unsat_sync, solver_sat_sync, solver_done_sync}.

### satswarm_core_bridge
Instantiated with gen_clk_extra_a1, gen_rst_a1_n. Connects axil_*, pcis_*, ddr_* to bridge ports.

## References

- [satswarm_core_bridge](satswarm_core_bridge.md)
- AWS HDK cl_ports.vh, cl_id_defines.vh
- [HANDOFF.md](../HANDOFF.md) — REQP-123, CDC fix
