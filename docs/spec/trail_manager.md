# trail_manager — Assignment Trail

**Source:** [src/Mega/trail_manager.sv](../../src/Mega/trail_manager.sv)

## Overview

The Trail Manager maintains the assignment trail with decision level markers for backtracking. The Trail is an ordered log of all assignments (decisions + propagations). Backtracking strictly removes the suffix of the trail down to the target level.

## Invariants

1. Trail is ordered log of ALL assignments (Decisions + Propagations)
2. Decision levels monotonically increasing
3. No variable appears more than once in active trail (0 to height-1)
4. Backtracking strictly removes suffix down to target level

## Parameters

| Parameter | Default | Description |
|-----------|---------|--------------|
| `MAX_VARS` | 256 | Max variables |

## Interface

### Push

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `push` | input | `logic` | Push assignment |
| `push_var` | input | `logic [31:0]` | Variable |
| `push_value` | input | `logic` | Value |
| `push_level` | input | `logic [15:0]` | Decision level |
| `push_is_decision` | input | `logic` | Mark decision point |
| `push_reason` | input | `logic [15:0]` | Reason clause ID |

### Query

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `height` | output | `logic [15:0]` | Trail height |
| `current_level` | output | `logic [15:0]` | Current decision level |
| `query_var` | input | `logic [31:0]` | Variable to query |
| `query_level` | output | `logic [15:0]` | Level at which var assigned |
| `query_valid` | output | `logic` | Variable is assigned |
| `query_value` | output | `logic` | Assignment value |
| `query_reason` | output | `logic [15:0]` | Reason clause ID |
| `query_valid_r` | output | `logic` | Registered query valid (1-cycle latency) |
| `query_level_r` | output | `logic [15:0]` | Registered query level |
| `query_value_r` | output | `logic` | Registered query value |
| `query_reason_r` | output | `logic [15:0]` | Registered query reason |

### Backtrack

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `backtrack_en` | input | `logic` | Start backtrack |
| `backtrack_to_level` | input | `logic [15:0]` | Target level |
| `backtrack_done` | output | `logic` | Backtrack complete |
| `backtrack_valid` | output | `logic` | Outputting assignment to clear |
| `backtrack_var` | output | `logic [31:0]` | Variable to clear |
| `backtrack_value` | output | `logic` | Value being cleared |
| `backtrack_is_decision` | output | `logic` | Was decision |

### Trail Read (for CAE)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `trail_read_idx` | input | `logic [15:0]` | Index (0=oldest, height-1=newest) |
| `trail_read_var` | output | `logic [31:0]` | Variable at index |
| `trail_read_value` | output | `logic` | Value at index |
| `trail_read_level` | output | `logic [15:0]` | Level at index |
| `trail_read_is_decision` | output | `logic` | Was decision |
| `trail_read_reason` | output | `logic [15:0]` | Reason at index |

### Other

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clear_all` | input | `logic` | Clear all |
| `truncate_en` | input | `logic` | O(1) instant truncate |
| `truncate_level_target` | input | `logic [15:0]` | Truncate target level |

## Internal Structure

### Lookup Tables (LUTRAM)

- `var_to_level[0:MAX_VARS]` — Variable → level
- `var_to_value[0:MAX_VARS]` — Variable → value
- `var_to_index[0:MAX_VARS]` — Variable → trail index
- `level_start[0:MAX_VARS]` — Level → trail index where level begins

### Trail Stack

- `trail[0:MAX_VARS-1]` — mega_pkg::trail_entry_t {variable, value, level, is_decision, reason}

### Backtrack FSM

- `bt_state_t`: IDLE, BACKTRACK_LOOP, BACKTRACK_COMPLETE

## Behavior (RTL Specification)

### Push
When push: trail[trail_height_q] = {push_var, push_value, push_level, push_is_decision, push_reason}. var_to_level[push_var] = push_level, var_to_value[push_var] = push_value, var_to_index[push_var] = trail_height_q. If push_is_decision: level_start[push_level] = trail_height_q, current_level_d = push_level. trail_height_d = trail_height_q + 1.

### Combinational query
If query_var in [1, MAX_VARS]: lvl = var_to_level[query_var], idx = var_to_index[query_var]. If lvl <= current_level_q and idx < trail_height_q and trail[idx].variable == query_var: query_valid = 1, query_level = lvl, query_value = var_to_value[query_var], query_reason = 16'h0. Else query_valid = 0.

### Registered query (1-cycle latency)
always_ff: query_valid_r <= query_valid, query_level_r <= query_level, query_value_r <= query_value, query_reason_r <= query_reason.

### Trail read (combinational)
If trail_read_idx < trail_height_q: trail_read_var = trail[trail_read_idx].variable, trail_read_value = trail[trail_read_idx].value, trail_read_level = trail[trail_read_idx].level, trail_read_is_decision = trail[trail_read_idx].is_decision, trail_read_reason = trail[trail_read_idx].reason.

### Backtrack FSM
IDLE: When backtrack_en: bt_target_d = level_start[backtrack_to_level], bt_index_d = trail_height_q - 1, transition to BACKTRACK_LOOP. BACKTRACK_LOOP: Each cycle output trail[bt_index_q] via backtrack_var, backtrack_value, backtrack_is_decision. Clear var_to_level[var], var_to_value[var], var_to_index[var] = 16'hFFFF. bt_index_d = bt_index_q - 1. When bt_index_q < bt_target_q: transition to BACKTRACK_COMPLETE. BACKTRACK_COMPLETE: backtrack_done = 1, trail_height_d = bt_target_q, current_level_d = backtrack_to_level. Transition to IDLE.

### Truncate
When truncate_en: trail_height_d = level_start[truncate_level_target], current_level_d = truncate_level_target. Clear var_to_* for all vars with level > truncate_level_target.

### Clear
When clear_all: trail_height_d = 0, current_level_d = 0, all var_to_* = 0.

## References

- [cae](cae.md)
- [solver_core](solver_core.md)
- mega_pkg::trail_entry_t
