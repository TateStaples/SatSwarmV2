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

- `aws_clk_gen` — Instantiated for HDK elaboration with **all groups disabled** (`CLK_GRP_A_EN=0`, `CLK_GRP_B_EN=0`, `CLK_GRP_C_EN=0`, `CLK_HBM_EN=0`). No MMCMs are active; extra-clock outputs are tied to 0.
- `i_clk_hbm_ref` = `1'b0` (safe because no MMCM groups are enabled)

See [AWS_CLK_GEN_spec.md](../../src/aws-fpga/hdk/docs/AWS_CLK_GEN_spec.md) and [Clock_Recipes_User_Guide.md](../../src/aws-fpga/hdk/docs/Clock_Recipes_User_Guide.md).

### Solver Clock (CL-owned MMCM)

- **MMCME4_ADV** (`u_mmcm_solver`) — Takes `clk_main_a0` (250 MHz), produces 15.625 MHz via VCO=1250 MHz, CLKOUT0_DIVIDE_F=80. Output drives BUFG → `clk_solver`.
- Solver domain runs on `clk_solver`; shell-facing logic on `clk_main_a0`.
- Solver reset (`rst_solver_n`) is gated on `mmcm_solver_locked` — solver stays in reset until the MMCM locks.

### AXI Clock Domain Crossing

- **OCL_CDC:** clk_main_a0 (shell) ↔ clk_solver (solver)
- **PCIS_CDC:** clk_main_a0 (shell) ↔ clk_solver (solver)
- **DDR_CDC:** clk_solver (solver) ↔ clk_main_a0 (shell)

### OCL AXI-Lite Handling

- Write/Read channel logic drives `axil_wr_valid`, `axil_wr_addr`, `axil_wr_data`, `axil_rd_valid`, `axil_rd_addr`; receives `axil_rd_data`, `axil_rd_ready` from bridge

### DMA PCIS → CNF Load

- Writes to 0x1000 (literal, clause_end=0) and 0x1004 (literal, clause_end=1) mapped to bridge's `pcis_wr_*`

### Status LED (cl_sh_status_vled)

- `solver_done`, `solver_sat`, `solver_unsat` from bridge status (host_done, host_sat, host_unsat)
- **CDC:** 2-FF synchronizer per bit: clk_solver → clk_main_a0
- `cl_sh_status_vled` = {13'b0, solver_unsat_sync, solver_sat_sync, solver_done_sync}

### satswarm_core_bridge

- Instantiated with `clk_solver`, `rst_solver_n`
- Connects to OCL, PCIS, DDR interfaces

## Behavior (RTL Specification)

### Reset
lib_pipe (4 stages) synchronizes rst_main_n to clk_main_a0 → rst_main_n_sync.

### Clocking
aws_clk_gen: all groups disabled (CLK_GRP_A_EN=0). CL-owned MMCME4_ADV (`u_mmcm_solver`): clk_main_a0 (250 MHz) -> VCO 1250 MHz -> CLKOUT0/80 = 15.625 MHz -> BUFG -> clk_solver. Solver reset gated on MMCM lock.

### OCL CDC
cl_axi_clock_converter_light: clk_main_a0 ↔ clk_solver. Maps ocl_cl_* to slv_ocl_*.

### PCIS CDC
cl_axi_clock_converter_light: clk_main_a0 ↔ clk_solver. Maps DMA write channel to pcis_wr_*.

### DMA address decode
Writes to 0x1000: literal, clause_end=0. Writes to 0x1004: literal, clause_end=1. pcis_wr_data → host_load_literal (signed).

### Status LED
solver_done/sat/unsat from bridge. 2-FF synchronizer per bit: clk_solver → clk_main_a0. cl_sh_status_vled = {13'b0, solver_unsat_sync, solver_sat_sync, solver_done_sync}.

### satswarm_core_bridge
Instantiated with clk_solver, rst_solver_n. Connects axil_*, pcis_*, ddr_* to bridge ports.

## References

- [satswarm_core_bridge](satswarm_core_bridge.md)
- AWS HDK cl_ports.vh, cl_id_defines.vh
- [HANDOFF.md](../HANDOFF.md) — REQP-123, CDC fix
- [AWS Shell Interface Specification](../../src/aws-fpga/hdk/docs/AWS_Shell_Interface_Specification.md)
- [HDK.md](../HDK.md) — index of HDK docs
