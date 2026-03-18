# shared_clause_buffer — Multi-Core Clause Broadcast

**Source:** [src/Mega/shared_clause_buffer.sv](../../src/Mega/shared_clause_buffer.sv)

## Overview

The shared clause buffer provides a FIFO for learned clauses from multiple cores. Cores write via a round-robin arbiter; the buffer broadcasts entries to all cores. Used for clause sharing in the swarm topology.

## Parameters

| Parameter | Default | Description |
|-----------|---------|--------------|
| `NUM_CORES` | 4 | Number of cores |
| `DEPTH` | 4096 | Buffer depth (power of 2) |
| `PTR_W` | $clog2(DEPTH) | Pointer width |

## Interface

### Write (Arbitrated)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `write_req` | input | `logic [NUM_CORES-1:0]` | Per-core write request |
| `write_payload` | input | `shared_packet_t [NUM_CORES-1:0]` | Per-core shared_packet_t |
| `write_grant` | output | `logic [NUM_CORES-1:0]` | Per-core grant |

### Broadcast

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `bcast_valid` | output | `logic` | Broadcast valid |
| `bcast_payload` | output | `shared_packet_t` | shared_packet_t |

## Internal Structure

### Storage

- `mem[0:DEPTH-1]` — BRAM (ram_style="block"), DATA_W=96 (shared_packet_t)
- SDP BRAM: write and read in separate posedge clk blocks (no async reset in write/read processes)

### Round-Robin Arbiter

- `rr_ptr` — Round-robin pointer
- One core granted per cycle when `write_req` asserted

### Pointers

- `write_ptr` — Write position
- `read_ptr` — Read position
- `bcast_valid` when read_ptr != write_ptr

## shared_packet_t Fields

- `lbd` — LBD score (0-255)
- `is_ref` — 1=Reference (Pointer), 0=Value (Literals)
- `length` — Clause length
- `payload` — {Lit1, Lit2} OR {Pointer}

## Behavior (RTL Specification)

### Round-robin arbiter (combinational)
For i = 0 to NUM_CORES-1: idx = (rr_ptr + i) % NUM_CORES. If write_req[idx]: write_grant[idx] = 1, grant_idx = idx, any_grant = 1, break.

### Write (synchronous)
always_ff @(posedge clk): if any_grant: mem[write_ptr] <= write_payload[grant_idx]. Write control (with async rst_n): if !rst_n: write_ptr <= 0, rr_ptr <= 0. Else if any_grant: write_ptr <= write_ptr + 1, rr_ptr <= (grant_idx + 1) % NUM_CORES.

### Read (synchronous)
always_ff @(posedge clk): mem_rd_data <= mem[read_ptr]. bcast_payload = mem_rd_data (combinational assign). Read control (with async rst_n): if !rst_n: read_ptr <= 0, bcast_valid <= 0. Else: bcast_valid <= 0; if read_ptr != write_ptr: bcast_valid <= 1, read_ptr <= read_ptr + 1.

## References

- [satswarmv2_pkg](satswarmv2_pkg.md) — shared_packet_t
- [satswarm_top](satswarm_top.md)
