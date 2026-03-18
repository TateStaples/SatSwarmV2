# satswarm_core_bridge — AXI/DMA to satswarm_top

**Source:** [design/satswarm_core_bridge.sv](../../src/aws-fpga/hdk/cl/examples/cl_satswarm/design/satswarm_core_bridge.sv)

## Overview

The bridge maps AWS shell interfaces (AXI-Lite, AXI4-PCIS DMA, DDR4) to `satswarm_top`'s native ports. It implements the register map, cycle counter, and CNF load stream conversion.

## Parameters

| Parameter | Default | Description |
|-----------|---------|--------------|
| `GRID_X` | 1 | Grid X |
| `GRID_Y` | 1 | Grid Y |
| `MAX_VARS_PER_CORE` | 256 | Max variables per core |
| `MAX_CLAUSES_PER_CORE` | 512 | Max clauses per core |
| `MAX_LITS` | 1024 | Max literals |

## Register Map (AXI-Lite, OCL BAR)

| Addr | Access | Description |
|------|--------|-------------|
| 0x00 | W | bit[0] = host_start (auto-clears after one cycle) |
| 0x00 | R | {29'b0, host_unsat, host_sat, host_done} |
| 0x04 | R | cycle_counter[31:0] |
| 0x08 | R | version = 32'h53415431 ("SAT1") |
| 0x0C | W | bit[0] = soft_reset |
| 0x10 | W | debug_level |
| 0x10 | R | debug_level |

## DMA CNF Load (AXI4-PCIS writes)

| Address | Meaning |
|---------|---------|
| 0x1000 | Write literal, clause_end = 0 |
| 0x1004 | Write literal, clause_end = 1 |

- `pcis_wr_ready` = `host_load_ready` (backpressure from satswarm_top)

## Interface

### AXI-Lite (from cl_satswarm)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `axil_wr_valid` | input | `logic` | Write valid |
| `axil_wr_addr` | input | `logic [31:0]` | Write address |
| `axil_wr_data` | input | `logic [31:0]` | Write data |
| `axil_wr_ready` | output | `logic` | Write ready |
| `axil_rd_valid` | input | `logic` | Read valid |
| `axil_rd_addr` | input | `logic [31:0]` | Read address |
| `axil_rd_data` | output | `logic [31:0]` | Read data |
| `axil_rd_ready` | output | `logic` | Read ready |

### AXI4-PCIS DMA

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `pcis_wr_valid` | input | `logic` | Write valid |
| `pcis_wr_addr` | input | `logic [31:0]` | Write address |
| `pcis_wr_data` | input | `logic [31:0]` | Write data |
| `pcis_wr_ready` | output | `logic` | Write ready |

### DDR4 (to/from memory model)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `ddr_read_req` | output | `logic` | Read request |
| `ddr_read_addr` | output | `logic [31:0]` | Read address |
| `ddr_read_len` | output | `logic [7:0]` | Burst length |
| `ddr_read_grant` | input | `logic` | Read granted |
| `ddr_read_data` | input | `logic [31:0]` | Read data |
| `ddr_read_valid` | input | `logic` | Read data valid |
| `ddr_write_req` | output | `logic` | Write request |
| `ddr_write_addr` | output | `logic [31:0]` | Write address |
| `ddr_write_data` | output | `logic [31:0]` | Write data |
| `ddr_write_grant` | input | `logic` | Write granted |

## Internal Logic

### Reset

- `rst_n` = `rst_n_in & ~soft_reset`

### Cycle Counter

- Increments when `!host_done`; resets to 0 on `host_start`

### satswarm_top Instantiation

- All host/DDR ports connected to bridge internal signals

## Behavior (RTL Specification)

### Reset
rst_n = rst_n_in & ~soft_reset.

### AXI-Lite write (synchronous)
always_ff: if axil_wr_valid, case axil_wr_addr[7:0]: 8'h00: host_start <= axil_wr_data[0]. 8'h0C: soft_reset <= axil_wr_data[0]. 8'h10: debug_level <= axil_wr_data. host_start and soft_reset auto-clear next cycle. axil_wr_ready = 1.

### AXI-Lite read (combinational)
always_comb: axil_rd_ready = axil_rd_valid. case axil_rd_addr[7:0]: 8'h00: axil_rd_data = {29'b0, host_unsat, host_sat, host_done}. 8'h04: axil_rd_data = cycle_counter. 8'h08: axil_rd_data = 32'h53415431. 8'h10: axil_rd_data = debug_level. default: 32'hDEAD_BEEF.

### Cycle counter
always_ff: if !rst_n: cycle_counter <= 0. else if host_start: cycle_counter <= 0. else if !host_done: cycle_counter <= cycle_counter + 1.

### DMA → CNF load
always_ff: if pcis_wr_valid && pcis_wr_ready: host_load_valid <= 1, host_load_literal <= pcis_wr_data (signed), host_load_clause_end <= (pcis_wr_addr[15:0] == 16'h1004). pcis_wr_ready = host_load_ready.

### satswarm_top
All host_*, ddr_* ports connected to u_satswarm.

## References

- [satswarm_top](satswarm_top.md)
- [cl_satswarm](cl_satswarm.md)
