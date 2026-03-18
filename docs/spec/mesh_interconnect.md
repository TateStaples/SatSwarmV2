# mesh_interconnect — 2D NoC Routing

**Source:** [src/Mega/mesh_interconnect.sv](../../src/Mega/mesh_interconnect.sv)

## Overview

The mesh interconnect routes NoC packets between neighboring cores in a 2D grid. Uses dimension-order (X-Y) routing. Direct peer-to-peer pass-through; no pipelining. For 1x1 grid, no routing occurs (all ports default to no rx).

## Parameters

| Parameter | Default | Description |
|-----------|---------|--------------|
| `GRID_X` | 1 | Grid X dimension |
| `GRID_Y` | 1 | Grid Y dimension |

## Interface

### Port Indexing

- `[Y][X][port]` — port: [3]=North, [2]=South, [1]=East, [0]=West

### Transmit (from cores)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `core_tx` | input | `noc_packet_t [0:GRID_Y-1][0:GRID_X-1][3:0]` | noc_packet_t per core per direction |
| `core_tx_valid` | input | `logic [0:GRID_Y-1][0:GRID_X-1][3:0]` | TX valid |
| `core_tx_ready` | output | `logic [0:GRID_Y-1][0:GRID_X-1][3:0]` | TX ready (backpressure) |

### Receive (to cores)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `core_rx` | output | `noc_packet_t [0:GRID_Y-1][0:GRID_X-1][3:0]` | noc_packet_t per core per direction |
| `core_rx_valid` | output | `logic [0:GRID_Y-1][0:GRID_X-1][3:0]` | RX valid |
| `core_rx_ready` | input | `logic [0:GRID_Y-1][0:GRID_X-1][3:0]` | RX ready |

## Routing Rules

- **North neighbor's North output** → This core's **South** input (port 2)
- **South neighbor's South output** → This core's **North** input (port 3)
- **East neighbor's East output** → This core's **West** input (port 0)
- **West neighbor's West output** → This core's **East** input (port 1)

## Default (No Packet)

- `core_rx` = MSG_STATUS, payload/quality_metric/src_id/virtual_channel = 0
- `core_rx_valid` = 0
- `core_tx_ready` = 0

## Behavior (RTL Specification)

### Per-core routing (combinational, always_comb)
For each core [y][x], default: core_rx[y][x][0..3] = MSG_STATUS, payload/quality_metric/src_id/virtual_channel = 0; core_rx_valid = 0; core_tx_ready = 0. If y > 0 and core_tx_valid[y-1][x][3] (North neighbor's North): core_rx_valid[y][x][2] = 1, core_rx[y][x][2] = core_tx[y-1][x][3], core_tx_ready[y-1][x][3] = core_rx_ready[y][x][2]. If y < GRID_Y-1 and core_tx_valid[y+1][x][2]: core_rx_valid[y][x][3] = 1, core_rx[y][x][3] = core_tx[y+1][x][2], core_tx_ready[y+1][x][2] = core_rx_ready[y][x][3]. If x < GRID_X-1 and core_tx_valid[y][x+1][1]: core_rx_valid[y][x][0] = 1, core_rx[y][x][0] = core_tx[y][x+1][1], core_tx_ready[y][x+1][1] = core_rx_ready[y][x][0]. If x > 0 and core_tx_valid[y][x-1][0]: core_rx_valid[y][x][1] = 1, core_rx[y][x][1] = core_tx[y][x-1][0], core_tx_ready[y][x-1][0] = core_rx_ready[y][x][1].

## References

- [satswarmv2_pkg](satswarmv2_pkg.md) — noc_packet_t
- [satswarm_top](satswarm_top.md)
- [solver_core](solver_core.md)
