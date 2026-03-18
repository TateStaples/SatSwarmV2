# cae — Conflict Analysis Engine

**Source:** [src/Mega/cae.sv](../../src/Mega/cae.sv)

## Overview

The Conflict Analysis Engine (CAE) implements the First-UIP clause learning algorithm with resolution. It walks the trail backward to find the Unique Implication Point.

## Invariant: First-UIP Clause Learning

The learned clause MUST contain exactly one literal from the current decision level (the First UIP). All other literals must be from lower decision levels. After backtracking, the learned clause becomes Unit, forcing a new assignment.

## Parameters

| Parameter | Default | Description |
|-----------|---------|--------------|
| `MAX_LITS` | 16 | Max conflict/learned clause length |
| `LEVEL_W` | 16 | Decision level width |
| `MAX_VARS` | MAX_LITS | Max variables |

## Interface

### Control

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `start` | input | `logic` | Start conflict analysis |
| `decision_level` | input | `logic [LEVEL_W-1:0]` | Current decision level |

### Conflict Inputs

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `conflict_len` | input | `logic [$clog2(MAX_LITS+1)-1:0]` | Conflict clause length |
| `conflict_lits` | input | `logic signed [MAX_LITS-1:0][31:0]` | Conflict clause literals |

### Learned Outputs

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `learned_valid` | output | `logic` | Learned clause valid |
| `learned_len` | output | `logic [$clog2(MAX_LITS+1)-1:0]` | Learned clause length |
| `learned_clause` | output | `logic signed [MAX_LITS-1:0][31:0]` | Learned clause literals |

### Backtrack

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `backtrack_level` | output | `logic [LEVEL_W-1:0]` | Level to backtrack to |
| `unsat` | output | `logic` | UNSAT detected |
| `done` | output | `logic` | Analysis complete |

### Trail Interface

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `trail_read_idx` | output | `logic [15:0]` | Index to read |
| `trail_read_var` | input | `logic [31:0]` | Variable at index |
| `trail_read_value` | input | `logic` | Value at index |
| `trail_read_level` | input | `logic [15:0]` | Level at index |
| `trail_read_is_decision` | input | `logic` | Is decision |
| `trail_read_reason` | input | `logic [15:0]` | Reason clause ID |
| `trail_height` | input | `logic [15:0]` | Trail height |

### Reason Query (to PSE)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `reason_query_var` | output | `logic [31:0]` | Variable to query |
| `reason_query_clause` | input | `logic [15:0]` | Clause ID |
| `reason_query_valid` | input | `logic` | Has reason |

### Clause Read (to PSE)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clause_read_id` | output | `logic [15:0]` | Clause ID |
| `clause_read_lit_idx` | output | `logic [$clog2(MAX_LITS+1)-1:0]` | Literal index |
| `clause_read_literal` | input | `logic signed [31:0]` | Literal value |
| `clause_read_len` | input | `logic [15:0]` | Clause length |

### Level Query (to Trail Manager)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `level_query_var` | output | `logic [31:0]` | Variable to query |
| `level_query_levels` | input | `logic [15:0]` | Level result |

## FSM States (state_e)

| State | Description |
|-------|--------------|
| `IDLE` | Waiting |
| `INIT_CLAUSE` | Initialize buffer from conflict |
| `FIND_RESOLVE_FETCH` | Present trail_scan_idx to trail |
| `FIND_RESOLVE_CHECK` | Check registered trail data |
| `RESOLUTION` | Resolve with reason clause |
| `FINALIZE_SCAN` | Scan for UIP |
| `FINALIZE_EMIT` | Emit learned clause |
| `DONE` | Complete |

## Internal Structure

### Resolution Buffer

- `buf_lits`, `buf_levels` — Literal and level arrays
- `buf_count_q`, `buf_valid_q` — Buffer state
- `seen_q`, `active_in_buf_q` — Dedup tracking

### Incremental Tracking

- `count_at_level_q`, `sec_max_level_q` — Replace bulk combinatorial scans
- Pipeline registers for trail read (1-cycle latency for timing)

## Behavior (RTL Specification)

### IDLE
When `start` is asserted: `buf_count_d` = 0, `valid_count_d` = 0, `count_at_level_d` = 0, `sec_max_level_d` = 0, `init_idx_d` = 0, `unsat_d` = 0, `learned_valid_d` = 0, `backtrack_d` = 0, `buf_overflow_d` = 0, `dropped_lits_d` = 0. If `trail_height` > 0 then `trail_scan_idx_d` = trail_height - 1, else 0. Transition to INIT_CLAUSE.

### INIT_CLAUSE
For each conflict literal at index `init_idx_q`: `level_query_var` = abs(conflict_lits[init_idx_q]). The always_ff block uses `level_query_levels` to update `buf_lits`, `buf_levels`, `buf_valid_q`, `count_at_level_q`, `sec_max_level_q`, `seen_q`, `active_in_buf_q`. `init_idx_d` = init_idx_q + 1. When init_idx_q >= conflict_len: if count_at_level_q <= 1, transition to FINALIZE_SCAN with fin_scan_idx_d=0, fin_found_uip_d=0, fin_out_idx_d=1, output_clause_d=0. Else transition to FIND_RESOLVE_FETCH.

### FIND_RESOLVE_FETCH
`trail_read_idx` = trail_scan_idx_q. Trail data is latched into trail_read_var_r, trail_read_value_r, trail_read_level_r, trail_read_is_decision_r, trail_read_reason_r on the next posedge. Transition to FIND_RESOLVE_CHECK.

### FIND_RESOLVE_CHECK
If trail_read_var_r is in active_in_buf_q, at decision_level, and trail_read_reason_r != 16'hFFFF: set resolve_var_d = trail_read_var_r, reason_clause_id_d = trail_read_reason_r, reason_len_d = clause_read_len (clause_read_id is overridden to trail_read_reason_r this cycle), reason_lit_idx_d = 0, transition to RESOLUTION. If trail_read_reason_r == 16'hFFFF (decision variable): transition to FINALIZE_SCAN. Else if trail_scan_idx_q > 0: trail_scan_idx_d = trail_scan_idx_q - 1, transition to FIND_RESOLVE_FETCH. Else transition to FINALIZE_SCAN.

### RESOLUTION
For each literal in the reason clause (reason_lit_idx_q < reason_len_q): clause_read_id = reason_clause_id_q, clause_read_lit_idx = reason_lit_idx_q. If clause_read_literal's variable != resolve_var_q and not in seen_q: add to buffer (buf_count_d++, buf_lits[buf_count_q] = clause_read_literal, buf_levels[buf_count_q] from level_query, etc.); if buf_count_q >= MAX_BUFFER, set buf_overflow_d, dropped_lits_d++. reason_lit_idx_d = reason_lit_idx_q + 1. When reason_lit_idx_q >= reason_len_q: decrement count_at_level (for resolved var); if count_at_level <= 2, UIP found, transition to FINALIZE_SCAN. Else trail_scan_idx_d = trail_scan_idx_q - 1, transition to FIND_RESOLVE_FETCH.

### FINALIZE_SCAN
Iterate over buffer indices. If buf_valid_q[fin_scan_idx_q] and literal at decision_level: set fin_found_uip_d, output_clause_d[0] = that literal, fin_out_idx_d = 1. fin_scan_idx_d++. When done, transition to FINALIZE_EMIT.

### FINALIZE_EMIT
Copy valid buffer literals (from lower levels) into output_clause_d[0] through output_clause_d[fin_out_idx_q-1]. final_learned_len_d = fin_out_idx_q. sec_max_level_q gives backtrack_level. If backtrack_level == 0 and learned clause empty, unsat_d = 1. learned_valid_d = 1. Transition to DONE.

### DONE
done = 1. learned_valid, learned_len, learned_clause, backtrack_level, unsat hold their values. State remains DONE until next start.

## References

- [pse](pse.md)
- [trail_manager](trail_manager.md)
- [solver_core](solver_core.md)
