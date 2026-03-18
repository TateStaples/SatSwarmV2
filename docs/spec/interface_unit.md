# interface_unit — NoC Packet Handler

**Source:** [src/Mega/interface_unit.sv](../../src/Mega/interface_unit.sv)

## Overview

The interface unit manages incoming and outgoing NoC packets. It handles divergence force handshake and clause broadcasts. Routes incoming packets by msg_type (MSG_DIVERGE, MSG_CLAUSE) to the appropriate core interface.

## Parameters

| Parameter | Default | Description |
|-----------|---------|--------------|
| `CORE_ID` | 0 | Core ID |
| `CORE_ID_W` | satswarmv2_pkg::CORE_ID_W | Core ID width |

## Interface

### Incoming (from neighbors)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `rx_pkt_n/s/e/w` | input | `noc_packet_t` | noc_packet_t per direction |
| `rx_valid_n/s/e/w` | input | `logic` | RX valid |
| `rx_ready_n/s/e/w` | output | `logic` | RX ready |

### Outgoing (to neighbors)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `tx_pkt_n/s/e/w` | output | `noc_packet_t` | noc_packet_t per direction |
| `tx_valid_n/s/e/w` | output | `logic` | TX valid |
| `tx_ready_n/s/e/w` | input | `logic` | TX ready |

### Divergence (Core → Neighbors)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `diverge_req` | input | `logic` | Core wants to force neighbor |
| `diverge_target` | input | `logic [3:0]` | Bitmask [3]=N, [2]=S, [1]=E, [0]=W |
| `diverge_lit` | input | `logic signed [31:0]` | Literal to force |
| `diverge_ack` | output | `logic` | Acknowledged (all targets ready) |

### Incoming Divergence (Neighbors → Core)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `force_valid` | output | `logic` | Incoming force valid |
| `force_lit` | output | `logic signed [31:0]` | Literal to force |
| `force_ready` | input | `logic` | Core ready |

### Clause Broadcast (Core → Neighbors)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clause_bcast_req` | input | `logic` | Broadcast learned clause |
| `clause_lbd` | input | `logic [7:0]` | LBD |
| `clause_ptr` | input | `logic [63:0]` | Pointer (64-bit) |
| `clause_bcast_ack` | output | `logic` | All directions ready |

### Incoming Clause (Neighbors → Core)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clause_rx_valid` | output | `logic` | Incoming clause valid |
| `clause_rx_lbd` | output | `logic [7:0]` | LBD |
| `clause_rx_ptr` | output | `logic [63:0]` | Pointer |
| `clause_rx_ready` | input | `logic` | Core ready |

## Packet Routing (Incoming)

- **Priority 1:** MSG_DIVERGE → `force_valid`, `force_lit`
- **Priority 2:** MSG_CLAUSE → `clause_rx_valid`, `clause_rx_lbd`, `clause_rx_ptr`

## Outgoing Packet Construction

- **diverge_req:** MSG_DIVERGE to diverge_target directions
- **clause_bcast_req:** MSG_CLAUSE to all four directions

## Acknowledgment

- `diverge_ack` = diverge_req && all target directions tx_ready
- `clause_bcast_ack` = clause_bcast_req && all four tx_ready

## Behavior (RTL Specification)

### Incoming packet routing (combinational)
Default: rx_ready_n/s/e/w = 0, diverge_rx_valid = 0, clause_rx_fifo_valid = 0. Priority 1 (MSG_DIVERGE): If rx_valid_n and rx_pkt_n.msg_type == MSG_DIVERGE: diverge_rx_valid = 1, diverge_rx_lit = rx_pkt_n.payload[31:0], rx_ready_n = 1. Else if rx_valid_s and rx_pkt_s.msg_type == MSG_DIVERGE: same for S. Else if rx_valid_e and rx_pkt_e.msg_type == MSG_DIVERGE: same for E. Else if rx_valid_w and rx_pkt_w.msg_type == MSG_DIVERGE: same for W. Priority 2 (MSG_CLAUSE): Else if rx_valid_n and rx_pkt_n.msg_type == MSG_CLAUSE: clause_rx_fifo_valid = 1, clause_rx_fifo_lbd = rx_pkt_n.quality_metric, clause_rx_fifo_ptr = rx_pkt_n.payload, rx_ready_n = 1. Same for S, E, W. force_valid = diverge_rx_valid, force_lit = diverge_rx_lit. clause_rx_valid = clause_rx_fifo_valid, clause_rx_lbd = clause_rx_fifo_lbd, clause_rx_ptr = clause_rx_fifo_ptr.

### Outgoing packet construction (combinational)
If diverge_req: For each diverge_target[i]: tx_valid = 1, tx_pkt.msg_type = MSG_DIVERGE, tx_pkt.payload = {32'd0, diverge_lit}, tx_pkt.src_id = CORE_ID. Else if clause_bcast_req: tx_valid_n/s/e/w = 1, tx_pkt.msg_type = MSG_CLAUSE, tx_pkt.payload = clause_ptr, tx_pkt.quality_metric = clause_lbd, tx_pkt.src_id = CORE_ID for all four directions.

### Acknowledgments
diverge_ack = diverge_req && (!diverge_target[3] || tx_ready_n) && (!diverge_target[2] || tx_ready_s) && (!diverge_target[1] || tx_ready_e) && (!diverge_target[0] || tx_ready_w). clause_bcast_ack = clause_bcast_req && tx_ready_n && tx_ready_s && tx_ready_e && tx_ready_w.

## References

- [solver_core](solver_core.md)
- [mesh_interconnect](mesh_interconnect.md)
- [satswarmv2_pkg](satswarmv2_pkg.md)
