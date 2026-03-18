# global_mem_arbiter — DDR Read/Write Arbitration

**Source:** [src/Mega/global_mem_arbiter.sv](../../src/Mega/global_mem_arbiter.sv)

## Overview

The global memory arbiter multiplexes DDR4 access from multiple solver cores. It prioritizes READ requests (BCP/CAE) over WRITE requests (learning). Round-robin arbitration among requesting cores.

## Parameters

| Parameter | Default | Description |
|-----------|---------|--------------|
| `NUM_CORES` | 4 | Number of cores |

## Interface

### Core Read

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `core_read_req` | input | `logic` (per core) | Per-core read request |
| `core_read_addr` | input | `logic [31:0]` (per core) | Per-core address |
| `core_read_len` | input | `logic [7:0]` (per core) | Burst length |
| `core_read_grant` | output | `logic` (per core) | Per-core grant |
| `core_read_data` | output | `logic [31:0]` (per core) | Per-core read data |
| `core_read_valid` | output | `logic` (per core) | Per-core read valid |

### Core Write

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `core_write_req` | input | `logic` (per core) | Per-core write request |
| `core_write_addr` | input | `logic [31:0]` (per core) | Per-core address |
| `core_write_data` | input | `logic [31:0]` (per core) | Per-core data |
| `core_write_grant` | output | `logic` (per core) | Per-core grant |

### DDR4 (External)

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

## Arbitration

### Read Priority

- Round-robin among cores with `core_read_req`
- `read_arbiter_q` advances on `ddr_read_grant`
- Read data passed through to granted core

### Write Priority

- Writes only when no read pending (`!ddr_read_req`)
- Round-robin among cores with `core_write_req`
- `write_arbiter_q` advances on `ddr_write_grant`

## Behavior (RTL Specification)

### Read arbitration (combinational)
read_arbiter_d = read_arbiter_q. For i = 0 to NUM_CORES-1: core_idx = (read_arbiter_q + i) % NUM_CORES. If core_read_req[core_idx]: core_read_grant[core_idx] = 1, ddr_read_req = 1, ddr_read_addr = core_read_addr[core_idx], ddr_read_len = core_read_len[core_idx]. If ddr_read_grant: read_arbiter_d = (core_idx + 1) % NUM_CORES. break. For granted core: core_read_data[i] = ddr_read_data, core_read_valid[i] = ddr_read_valid.

### Write arbitration (combinational)
write_arbiter_d = write_arbiter_q. Only if !ddr_read_req: For i = 0 to NUM_CORES-1: core_idx = (write_arbiter_q + i) % NUM_CORES. If core_write_req[core_idx]: core_write_grant[core_idx] = 1, ddr_write_req = 1, ddr_write_addr = core_write_addr[core_idx], ddr_write_data = core_write_data[core_idx]. If ddr_write_grant: write_arbiter_d = (core_idx + 1) % NUM_CORES. break.

### Sequential
always_ff: read_arbiter_q <= read_arbiter_d, write_arbiter_q <= write_arbiter_d.

## References

- [satswarm_top](satswarm_top.md)
- [solver_core](solver_core.md)
