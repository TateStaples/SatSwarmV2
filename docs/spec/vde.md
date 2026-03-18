# vde — Variable Decision Engine

**Source:** [src/Mega/vde.sv](../../src/Mega/vde.sv)

## Overview

The Variable Decision Engine (VDE) is a wrapper around `vde_heap` that buffers inputs to handle latency. The VDE Heap is slow (multi-cycle); the core FSM is fast. The command FIFO absorbs this speed mismatch.

## Invariant: Latency Isolation

All activity updates and assignments must pass through the FIFO to ensure the Heap eventually reflects the correct state.
Op encoding: `OP_ASSIGN`, `OP_CLEAR`, `OP_BUMP`

## Parameters

| Parameter | Default | Description |
|-----------|---------|--------------|
| `MAX_VARS` | 256 | Max variables |
| `ACT_W` | 32 | Activity score width |
| `BUMP_Q_SIZE` | 32 | Multi-bump queue size |

## Interface

### Decision Request

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `request` | input | `logic` | Request decision |
| `decision_valid` | output | `logic` | Decision valid |
| `decision_var` | output | `logic [31:0]` | Variable to decide |
| `decision_phase` | output | `logic` | Phase (polarity) |
| `phase_offset` | input | `logic [3:0]` | Per-core phase offset |
| `all_assigned` | output | `logic` | All variables assigned |
| `max_var` | input | `logic [31:0]` | Max variable |
| `clear_all` | input | `logic` | Clear all |
| `unassign_all` | input | `logic` | Reset assignments, keep scores |

### Assignment Bookkeeping

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `assign_valid` | input | `logic` | Assign variable |
| `assign_var` | input | `logic [31:0]` | Variable |
| `assign_value` | input | `logic` | Value |
| `clear_valid` | input | `logic` | Clear (unassign) |
| `clear_var` | input | `logic [31:0]` | Variable to clear |

### Activity Updates

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `bump_valid` | input | `logic` | Bump single variable |
| `bump_var` | input | `logic [31:0]` | Variable |
| `bump_count` | input | `logic [$clog2(BUMP_Q_SIZE+1)-1:0]` | Multi-bump count |
| `bump_vars` | input | `logic [BUMP_Q_SIZE-1:0][31:0]` | Variables for multi-bump |
| `decay` | input | `logic` | Decay event |

### Status

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `busy` | output | `logic` | VDE busy |
| `pending_ops` | output | `logic` | Pending operations in FIFO |

## Internal Structure

### Command FIFO

- `sfifo` (WIDTH=entry, DEPTH=256)
- Op encoding: `OP_ASSIGN`, `OP_CLEAR`, `OP_BUMP`
- Flush on `clear_all` or `unassign_all`

### vde_heap Integration

- VDE drives `vde_heap` with assign/clear/bump operations
- `heap_busy` from vde_heap; `busy` = heap_busy or !fifo_empty

## Behavior (RTL Specification)

### FIFO Write
When assign_valid: fifo_push = 1, fifo_in = {OP_ASSIGN, assign_var, assign_value}. When clear_valid (and !assign_valid): fifo_push = 1, fifo_in = {OP_CLEAR, clear_var, 0}. When bump_valid (and !assign_valid, !clear_valid): fifo_push = 1, fifo_in = {OP_BUMP, bump_var, 0}. FIFO flush on clear_all or unassign_all.

### held_bump
When bump_count > 0: held_bump_valid = 1, held_bump_count = bump_count, held_bump_vars = bump_vars. When ack_bump: held_bump_valid = 0. held_decay: set on decay, cleared on ack_decay.

### Arbiter (when !heap_busy)
Priority 1: If !fifo_empty: fifo_pop = 1. If fifo_out.op == OP_ASSIGN: h_assign_valid = 1, h_assign_var = fifo_out.var_id, h_assign_value = fifo_out.val. If OP_CLEAR: h_clear_valid = 1, h_clear_var = fifo_out.var_id. If OP_BUMP: h_bump_valid = 1, h_bump_var = fifo_out.var_id. Priority 2: Else if held_bump_valid: ack_bump = 1, h_bump_count = held_bump_count, h_bump_vars = held_bump_vars (multi-bump passed to heap; FIFO not used). Priority 3: Else if held_decay: ack_decay = 1, h_decay = 1.

### Outputs
busy = heap_busy. pending_ops = !fifo_empty || held_bump_valid || held_decay || heap_busy.

## References

- [vde_heap](vde_heap.md)
- [solver_core](solver_core.md)
