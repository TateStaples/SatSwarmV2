# vde_heap — Binary Heap for VSIDS

**Source:** [src/Mega/vde_heap.sv](../../src/Mega/vde_heap.sv)

**Reference:** [docs/specs/vde_heap_spec.md](../specs/vde_heap_spec.md) (original specification)

## Overview

The Variable Decision Engine Heap implements VSIDS-like variable selection with O(log N) decision using a Max-Heap. The heap maintains the max-heap property based on variable activity scores.

## Data Structures

### heap_mem

- **Content:** `{activity_score, variable_id}` tuples
- **Indexing:** heap_index (0 to heap_size-1)
- **Size:** MAX_VARS depth
- **Width:** ACT_W + IDX_W (score + var_id)

### pos_mem

- **Content:** heap_index
- **Indexing:** variable_id (1-indexed)
- **Size:** MAX_VARS depth
- **Width:** IDX_W (clog2(MAX_VARS)+1)

### heap_size

- Tracks valid (unassigned) variables
- Assigned variables are "hidden" in region [heap_size, MAX_VARS-1]

## Parameters

| Parameter | Default | Description |
|-----------|---------|--------------|
| `MAX_VARS` | 256 | Max variables |
| `ACT_W` | 32 | Activity score width |
| `IDX_W` | $clog2(MAX_VARS)+1 | Index width |
| `BUMP_Q_SIZE` | 32 | Multi-bump queue size |

## Interface

### Decision

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `request` | input | `logic` | Request decision |
| `decision_valid` | output | `logic` | Decision valid |
| `decision_var` | output | `logic [31:0]` | Variable (1-indexed) |
| `decision_phase` | output | `logic` | Phase hint |
| `phase_offset` | input | `logic [3:0]` | Per-core phase offset |
| `all_assigned` | output | `logic` | Heap empty |
| `max_var` | input | `logic [31:0]` | Max variable |
| `clear_all` | input | `logic` | Reset |
| `busy` | output | `logic` | Heap busy |

### Assignment (Hide/Unhide)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `assign_valid` | input | `logic` | Hide variable (assign) |
| `assign_var` | input | `logic [31:0]` | Variable |
| `assign_value` | input | `logic` | Value |
| `clear_valid` | input | `logic` | Unhide (backtrack) |
| `clear_var` | input | `logic [31:0]` | Variable |
| `unassign_all` | input | `logic` | Reset assignments, keep scores |

### Activity (Bump)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `bump_valid` | input | `logic` | Bump single variable |
| `bump_var` | input | `logic [31:0]` | Variable |
| `bump_count` | input | `logic [$clog2(BUMP_Q_SIZE+1)-1:0]` | Multi-bump count |
| `bump_vars` | input | `logic [BUMP_Q_SIZE-1:0][31:0]` | Variables for multi-bump |
| `decay` | input | `logic` | Decay event |

## FSM States (state_e)

| State | Description |
|-------|--------------|
| `IDLE` | Waiting |
| `INIT_WRITE` | Initialization loop |
| `DECIDE_READ_0`, `DECIDE_READ_1`, `DECIDE` | Extract max |
| `HIDE_READ_POS`, `HIDE_CHECK_POS` | Hide: get position |
| `HIDE_SWAP_READ`, `HIDE_SWAP_WRITE` | Hide: swap with last |
| `HIDE_BUBBLE_DOWN_*` | Hide: bubble down |
| `UNHIDE_READ_POS`, `UNHIDE_CHECK_POS` | Unhide: get position |
| `UNHIDE_SWAP_READ`, `UNHIDE_SWAP_WRITE` | Unhide: swap with size |
| `UNHIDE_BUBBLE_UP_*` | Unhide: bubble up |
| `BUMP_READ_POS`, `BUMP_CHECK_POS` | Bump: get position |
| `BUMP_UPDATE_READ`, `BUMP_UPDATE_PIPE`, `BUMP_UPDATE_WRITE` | Bump: update score |
| `BUMP_BUBBLE_UP_*` | Bump: bubble up |
| `RESCALE_READ`, `RESCALE_WRITE` | Rescale on overflow |

## Operations

### Hide (Assignment)

1. Lookup idx = pos_mem[var]
2. Decrement heap_size, swap with last, bubble down

### Unhide (Backtrack)

1. Lookup idx = pos_mem[var]
2. Swap with heap_size, increment heap_size, bubble up

### Bump (Activity Update)

1. Lookup idx = pos_mem[var]
2. Read score, add bump_increment, write back
3. If active (idx < heap_size), bubble up

### Decay (Lazy)

- `bump_increment *= (1/decay_factor)` on decay event
- No O(N) rescaling of all scores

### Rescale

- Trigger: bump_increment near overflow
- Rescale all scores and bump_increment by small constant

## Behavior (RTL Specification)

### IDLE
When request and heap_size_q > 0: transition to DECIDE_READ_0. When assign_valid: pending_var_d = assign_var, pending_value_d = assign_value, transition to HIDE_READ_POS. When clear_valid: pending_var_d = clear_var, transition to UNHIDE_READ_POS. When bump_valid: pending_var_d = bump_var, transition to BUMP_READ_POS. When bump_count > 0: enqueue bump_vars into bump_queue_q, transition to BUMP_READ_POS when queue drained. When decay: bump_increment_d = bump_increment_q / decay_factor. When clear_all: transition to INIT_WRITE. When unassign_all: heap_size_d = max_var, transition to INIT_WRITE (reinit pos_mem, keep scores).

### INIT_WRITE
For k = 0 to max_var_init_q-1: heap_mem[k] = {INITIAL_BUMP, k+1}, pos_mem[k+1] = k. heap_size_d = max_var_init_q. Transition to IDLE when done.

### DECIDE_READ_0, DECIDE_READ_1, DECIDE
Read heap_mem[0] (root). decision_var = rdata.var_id, decision_phase = phase_hint[var], decision_valid = 1. Transition to IDLE.

### HIDE_READ_POS, HIDE_CHECK_POS
raddr_p1 = pending_var_q. idx_d = pos_mem[var]. Transition to HIDE_SWAP_READ.

### HIDE_SWAP_READ, HIDE_SWAP_WRITE
Swap heap_mem[idx_q] with heap_mem[heap_size_q-1]. Update pos_mem for both. heap_size_d = heap_size_q - 1. phase_hint[var] = pending_value_q. Transition to HIDE_BUBBLE_DOWN_READ_1.

### HIDE_BUBBLE_DOWN_*
idx_q = 0. Loop: read left child at 2*idx+1, right at 2*idx+2. Compare scores. If child score > current, swap; idx_d = child index. Write back via we_h1, we_h2. When no swap needed, transition to IDLE.

### UNHIDE_READ_POS through UNHIDE_BUBBLE_UP_WRITE
Lookup pos_mem[var]. Swap with heap_mem[heap_size_q]. heap_size_d = heap_size_q + 1. Bubble up: while parent score < current, swap with parent; idx = parent index. Write back. Transition to IDLE.

### BUMP_READ_POS through BUMP_UPDATE_WRITE
Lookup pos_mem[var]. Read heap_mem[idx] (rdata_h1). In BUMP_UPDATE_PIPE: bump_rdata_q = rdata_h1 (pipeline register). In BUMP_UPDATE_WRITE: new_score = bump_rdata_q.score + bump_increment_q. heap_mem[idx] = {new_score, var_id}. If idx < heap_size_q, transition to BUMP_BUBBLE_UP_READ_1; else IDLE.

### BUMP_BUBBLE_UP_*
Bubble up: while parent score < current, swap. Transition to IDLE when done.

### RESCALE_READ, RESCALE_WRITE
When bump_increment_q >= RESCALE_THRESHOLD: for each heap_mem[i], score = score / 2. bump_increment_d = bump_increment_q / 2. Transition to IDLE.

## References

- [vde](vde.md)
- [docs/specs/vde_heap_spec.md](../specs/vde_heap_spec.md)
