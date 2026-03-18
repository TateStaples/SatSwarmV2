# satswarm_top — Top-Level Solver Grid

**Source:** [src/Mega/satswarm_top.sv](../../src/Mega/satswarm_top.sv)

## Overview

`satswarm_top` integrates the solver core grid, mesh interconnect, global memory arbiter, shared clause buffer, and global allocator. It is the top-level RTL module for the SatSwarm solver (below the AWS HDK wrapper).

## Parameters

| Parameter | Default | Description |
|-----------|---------|--------------|
| `GRID_X` | 1 | Grid X dimension |
| `GRID_Y` | 1 | Grid Y dimension |
| `MAX_VARS_PER_CORE` | 256 | Max variables per solver core |
| `MAX_CLAUSES_PER_CORE` | 256 | Max clauses per core |
| `MAX_LITS` | 4096 | Max literals |
| `NUM_CORES` | GRID_X * GRID_Y | Total core count |

## Interface

### Control

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `DEBUG` | input | `logic [31:0]` | Runtime debug level |
| `clk` | input | `logic` | Clock |
| `rst_n` | input | `logic` | Active-low reset |
| `host_start` | input | `logic` | Start solve |
| `host_done` | output | `logic` | Any core finished |
| `host_sat` | output | `logic` | Any core found SAT |
| `host_unsat` | output | `logic` | Any core found UNSAT |

### Host Load (CNF Stream)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `host_load_valid` | input | `logic` | Literal valid |
| `host_load_literal` | input | `logic signed [31:0]` | Literal value (signed) |
| `host_load_clause_end` | input | `logic` | End of clause marker |
| `host_load_ready` | output | `logic` | AND of all cores' load_ready |

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

## Internal Structure

### Signal Arrays

- **Mesh:** `core_tx`, `core_rx` — `[0:GRID_Y-1][0:GRID_X-1][3:0]` (port: N=3, S=2, E=1, W=0)
- **Global memory:** `core_read_req`, `core_read_addr`, `core_read_len`, `core_read_grant`, `core_read_data`, `core_read_valid` — per core
- **Global memory write:** `core_write_req`, `core_write_addr`, `core_write_data`, `core_write_grant` — per core
- **Shared clause:** `shared_write_req`, `shared_write_payload`, `shared_write_grant` — per core
- **Allocator:** `alloc_req`, `alloc_size`, `alloc_grant`, `alloc_addr`
- **Per-core results:** `solve_done_core`, `is_sat_core`, `is_unsat_core`, `load_ready_core`

### Submodules

| Module | Instance | Role |
|--------|----------|------|
| mesh_interconnect | u_mesh | Routes NoC packets between cores |
| global_mem_arbiter | u_arbiter | DDR read/write arbitration |
| shared_clause_buffer | u_shared_mem | Multi-core clause broadcast (DEPTH=4096) |
| global_allocator | u_allocator | DDR learned-clause address allocation (BASE=0x4000_0000) |
| solver_core | u_core (per grid cell) | CDCL solver |

### Grid Mapping

- Port indexing: `[3]=North`, `[2]=South`, `[1]=East`, `[0]=West`
- `CORE_IDX = y * GRID_X + x`

## Host Aggregation

- `host_load_ready` = AND of all `load_ready_core[i]`
- `host_done` = OR of all `solve_done_core[i]`
- `host_sat` = OR of all `is_sat_core[i]` where `solve_done_core[i]`
- `host_unsat` = OR of all `is_unsat_core[i]` where `solve_done_core[i]`

## Behavior (RTL Specification)

### Host load
host_load_valid, host_load_literal, host_load_clause_end broadcast to all solver_core instances. host_load_ready = AND(load_ready_core[i]) for all i.

### Host aggregation
host_done = OR(solve_done_core[i]). host_sat = OR(is_sat_core[i] where solve_done_core[i]). host_unsat = OR(is_unsat_core[i] where solve_done_core[i]).

### Mesh interconnect
u_mesh: core_tx[y][x][3]=North, [2]=South, [1]=East, [0]=West. Connects core_tx/core_rx/core_tx_valid/core_rx_valid/core_tx_ready/core_rx_ready.

### Global memory arbiter
u_arbiter: core_read_req/addr/len/grant/data/valid, core_write_req/addr/data/grant per core. ddr_* pass-through.

### Shared clause buffer
u_shared_mem: shared_write_req/payload/grant per core. shared_bcast_valid, shared_bcast_payload.

### Global allocator
u_allocator: alloc_req, alloc_size per core. alloc_grant, alloc_addr shared.

### solver_core (generate)
For each (y,x): CORE_IDX = y*GRID_X+x. load_valid = host_load_valid, load_literal = host_load_literal, load_clause_end = host_load_clause_end. vde_phase_offset = CORE_IDX (or similar). core_tx/rx from mesh. core_read_*, core_write_* from arbiter. solve_done, is_sat, is_unsat, load_ready to host aggregation.

## References

- [solver_core](solver_core.md)
- [mesh_interconnect](mesh_interconnect.md)
- [global_mem_arbiter](global_mem_arbiter.md)
- [shared_clause_buffer](shared_clause_buffer.md)
- [global_allocator](global_allocator.md)
