# global_allocator — DDR Learned-Clause Address Allocation

**Source:** [src/Mega/global_allocator.sv](../../src/Mega/global_allocator.sv)

## Overview

The global allocator provides single-cycle atomic bump-pointer allocation for the DDR learned clause region. Cores request allocation with a size; the winner receives `alloc_addr` the same cycle. Only one core receives grant per cycle (round-robin).

## Invariant

Only one core receives grant per cycle. Round-robin arbitration ensures fairness.

## Parameters

| Parameter | Default | Description |
|-----------|---------|--------------|
| `NUM_CORES` | 4 | Number of cores |
| `ADDR_WIDTH` | 32 | Address width |
| `BASE_ADDR` | 32'h4000_0000 | Start of learned clause region |

## Interface

### Allocation Request

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `alloc_req` | input | `logic [NUM_CORES-1:0]` | Per-core request |
| `alloc_size` | input | `logic [15:0]` (per core) | Per-core size (32-bit words) |

### Allocation Grant

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `alloc_grant` | output | `logic [NUM_CORES-1:0]` | Per-core grant (same cycle as request) |
| `alloc_addr` | output | `logic [ADDR_WIDTH-1:0]` | Allocated base address (shared; only winner uses) |

### Status

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `current_ptr` | output | `logic [ADDR_WIDTH-1:0]` | Current bump pointer (debug) |

## Internal Structure

### Bump Pointer

- `bump_ptr_q` — Sequential state
- On grant: `bump_ptr_q += winner_size * 4` (words to bytes)

### Round-Robin Arbiter

- `rr_idx_q` — Arbiter state
- Find first requesting core from rr_idx_q; grant; advance rr_idx_q

## Usage

1. Core asserts `alloc_req` with `alloc_size` (in words)
2. Same cycle: `alloc_grant` high, `alloc_addr` contains base
3. Next cycle: bump_ptr advances by size, ready for next allocation

## Behavior (RTL Specification)

### Arbiter (combinational)
alloc_addr = bump_ptr_q. any_request = |alloc_req. For i = 0 to NUM_CORES-1: idx = (rr_idx_q + i) % NUM_CORES. If alloc_req[idx]: alloc_grant[idx] = 1, winner_idx = idx, winner_size = alloc_size[idx], break.

### Sequential update
always_ff @(posedge clk or negedge rst_n): if !rst_n: bump_ptr_q <= BASE_ADDR, rr_idx_q <= 0. Else if any_request: bump_ptr_q <= bump_ptr_q + {winner_size, 2'b00}, rr_idx_q <= (winner_idx + 1) % NUM_CORES.

### Outputs
current_ptr = bump_ptr_q.

## References

- [satswarm_top](satswarm_top.md)
- [global_mem_arbiter](global_mem_arbiter.md)
