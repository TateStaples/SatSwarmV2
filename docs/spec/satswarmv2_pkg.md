# satswarmv2_pkg — Global Package

**Source:** [src/Mega/satswarmv2_pkg.sv](../../src/Mega/satswarmv2_pkg.sv)

## Overview

`satswarmv2_pkg` defines global parameters, types, and structs used across all SatSwarm RTL modules. It is included by every module in the design.

## Parameters

| Parameter | Default | Description |
|-----------|---------|--------------|
| `VAR_MAX` | 16384 | Maximum variables per problem |
| `LIT_MAX` | 1048576 | Maximum literals |
| `CLAUSE_MAX` | 262144 | Clause table entries |
| `CURSOR_COUNT` | 4 | Cursor count |
| `DECLEVEL_W` | 15 | Decision level width (supports up to VAR_MAX levels) |
| `LBD_W` | 8 | Literal Block Distance width |
| `PTR_W` | 32 | Pointer width |
| `ACT_W` | 32 | Activity score width |
| `HEAP_W` | 16 | Heap width |
| `GRID_X` | 2 | Grid X dimension (default 2x2) |
| `GRID_Y` | 2 | Grid Y dimension |
| `CORE_ID_W` | 4 | Core ID width (max 16 cores) |
| `VC_BITS` | 2 | Virtual channel bits (4 channels for deadlock avoidance) |

## Message Types

```systemverilog
typedef enum logic [1:0] {
  MSG_DIVERGE,   // Force neighbor to assume payload_lit
  MSG_CLAUSE,    // Broadcast global pointer to learned clause
  MSG_STATUS     // Report idle/busy/sat/unsat state
} msg_type_t;
```

## Types

### noc_packet_t

NoC communication packet for mesh interconnect.

| Field | Type | Description |
|-------|------|--------------|
| `msg_type` | `msg_type_t` | Packet type |
| `payload` | `logic [63:0]` | Divergence literal (bottom 32) OR two clause literals |
| `quality_metric` | `logic [LBD_W-1:0]` | LBD for clauses |
| `src_id` | `logic [CORE_ID_W-1:0]` | Originating core ID |
| `virtual_channel` | `logic [VC_BITS-1:0]` | Deadlock avoidance |

### var_metadata_t

Single-core variable metadata (local per core).

| Field | Type | Description |
|-------|------|--------------|
| `assigned` | `logic` | Variable is assigned |
| `value` | `logic` | Current assignment (0=false, 1=true) |
| `level` | `logic [DECLEVEL_W-1:0]` | Decision level when assigned |
| `reason` | `logic [PTR_W-1:0]` | Clause ID that implied this (0 if decision) |
| `activity` | `logic [ACT_W-1:0]` | VSIDS activity score |
| `phase` | `logic` | Phase saving hint |
| `assumption` | `logic` | True if forced by neighbor divergence |

### clause_metadata_t

Clause metadata (hybrid: header local, literals in global DDR).

| Field | Type | Description |
|-------|------|--------------|
| `global_ptr` | `logic [PTR_W-1:0]` | Pointer to literal array in DDR4 |
| `length` | `logic [15:0]` | Clause length |
| `wlit0` | `logic signed [31:0]` | Cached watched literal 0 |
| `wlit1` | `logic signed [31:0]` | Cached watched literal 1 |
| `lbd` | `logic [LBD_W-1:0]` | Literal Block Distance |
| `learnable` | `logic` | Deletion candidate |
| `next_watch0` | `logic [PTR_W-1:0]` | Watch list link for wlit0 |
| `next_watch1` | `logic [PTR_W-1:0]` | Watch list link for wlit1 |

### trail_entry_t

Trail entry with divergence flag.

| Field | Type | Description |
|-------|------|--------------|
| `literal` | `logic signed [31:0]` | Assigned literal |
| `level` | `logic [DECLEVEL_W-1:0]` | Decision level |
| `is_forced` | `logic` | Flag if forced by neighbor divergence |

### propagation_t

| Field | Type | Description |
|-------|------|--------------|
| `valid` | `logic` | Valid propagation |
| `lit` | `logic signed [31:0]` | Literal |
| `clause_ptr` | `logic [PTR_W-1:0]` | Clause pointer |

### conflict_t

| Field | Type | Description |
|-------|------|--------------|
| `conflict` | `logic` | Conflict detected |
| `clause_ptr` | `logic [PTR_W-1:0]` | Conflict clause pointer |

### shared_packet_t

Shared clause broadcast packet.

| Field | Type | Description |
|-------|------|--------------|
| `lbd` | `logic [7:0]` | LBD score (0-255) |
| `is_ref` | `logic` | 1=Reference (Pointer), 0=Value (Literals) |
| `reserved` | `logic [6:0]` | Padding/future use |
| `length` | `logic [15:0]` | Clause length |
| `payload` | `logic [63:0]` | Data: {Lit1, Lit2} OR {Pointer} |

### clause_ref_t

| Field | Type | Description |
|-------|------|--------------|
| `ptr` | `logic [PTR_W-1:0]` | Pointer |
| `len` | `logic [15:0]` | Length |

## Behavior (RTL Specification)

Package has no runtime behavior. It declares compile-time parameters and types.

### Parameters
VAR_MAX, LIT_MAX, CLAUSE_MAX, CURSOR_COUNT, DECLEVEL_W, LBD_W, PTR_W, ACT_W, HEAP_W, GRID_X, GRID_Y, CORE_ID_W, VC_BITS (see table above).

### Enums
msg_type_t: MSG_DIVERGE, MSG_CLAUSE, MSG_STATUS.

### Structs (typedef struct packed)
noc_packet_t: msg_type, payload[63:0], quality_metric[LBD_W-1:0], src_id[CORE_ID_W-1:0], virtual_channel[VC_BITS-1:0]. var_metadata_t, clause_metadata_t, trail_entry_t, propagation_t, conflict_t, shared_packet_t, clause_ref_t (see Types section for field lists). Bit order in packed structs is declaration order (MSB first).

## References

- Used by all modules in `src/Mega/`
- `mega_pkg` (trail_entry_t) used by trail_manager
