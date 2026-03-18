# pse — Propagation Search Engine

**Source:** [src/Mega/pse.sv](../../src/Mega/pse.sv)

## Overview

The Propagation Search Engine (PSE) performs Boolean Constraint Propagation (BCP) using the two-watched-literal scheme. Only clauses whose watched literal is falsified are scanned, reducing propagation cost.

## Invariant: Watched Literal Scheme

Each clause maintains exactly two watched literals:

1. If a watched literal becomes False, the clause must be scanned to find a replacement.
2. If a replacement is found, update the watch.
3. If no replacement is found:
   - Other watched literal True → clause satisfied (ignore)
   - Other watched literal Unassigned → Unit clause (Propagate)
   - Other watched literal False → Conflict (Signal Conflict)

## Parameters

| Parameter | Default | Description |
|-----------|---------|--------------|
| `MAX_VARS` | 256 | Max variables |
| `MAX_CLAUSES` | 256 | Max clauses |
| `MAX_LITS` | 4096 | Max literals |
| `MAX_CLAUSE_LEN` | 32 | Max clause length |
| `CORE_ID` | 0 | Core ID |
| `PROP_QUEUE_DEPTH` | MAX_LITS | Propagation queue depth |

## Interface

### Clause Load

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `load_valid` | input | `logic` | Literal valid |
| `load_literal` | input | `logic signed [31:0]` | Literal (signed) |
| `load_clause_end` | input | `logic` | End of clause |
| `load_ready` | output | `logic` | Ready for load |

### Solve Control

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `start` | input | `logic` | Start propagation |
| `decision_var` | input | `logic signed [31:0]` | Current decision literal (for seeding) |
| `done` | output | `logic` | Propagation complete |
| `conflict_detected` | output | `logic` | Conflict found |
| `propagated_valid` | output | `logic` | Propagation valid |
| `propagated_var` | output | `logic signed [31:0]` | Propagated literal |
| `propagated_reason` | output | `logic [15:0]` | Clause ID causing propagation |
| `max_var_seen` | output | `logic [31:0]` | Max variable index seen |
| `clear_assignments` | input | `logic` | Clear all assignments |
| `clear_valid` | input | `logic` | Clear single variable |
| `clear_var` | input | `logic [31:0]` | Variable to clear |

### Assignment Broadcast (from solver_core)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `assign_broadcast_valid` | input | `logic` | New assignment this cycle |
| `assign_broadcast_var` | input | `logic [31:0]` | Variable assigned |
| `assign_broadcast_value` | input | `logic` | Assignment value |
| `assign_broadcast_reason` | input | `logic [15:0]` | Reason clause ID |

### Conflict Export (for CAE)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `conflict_clause_len` | output | `logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]` | Conflict clause length |
| `conflict_clause` | output | `logic signed [MAX_CLAUSE_LEN-1:0][31:0]` | Conflict clause literals |

### Clause Injection (from NoC RX)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `inject_valid` | input | `logic` | Inject request |
| `inject_lit1` | input | `logic signed [31:0]` | First literal |
| `inject_lit2` | input | `logic signed [31:0]` | Second literal |
| `inject_ready` | output | `logic` | Ready for inject |

### Reason Query (for CAE)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `reason_query_var` | input | `logic [31:0]` | Variable to query |
| `reason_query_clause` | output | `logic [15:0]` | Clause ID that implied var (0xFFFF if decision) |
| `reason_query_valid` | output | `logic` | Variable has reason |

### Clause Read (for CAE)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clause_read_id` | input | `logic [15:0]` | Clause ID |
| `clause_read_lit_idx` | input | `logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]` | Literal index |
| `clause_read_literal` | output | `logic signed [31:0]` | Literal value |
| `clause_read_len` | output | `logic [15:0]` | Clause length |

### Direct Append (from CAE)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `cae_direct_append_en` | input | `logic` | Append enable |
| `cae_direct_append_len` | input | `logic [$clog2(MAX_CLAUSE_LEN+1)-1:0]` | Learned clause length |
| `cae_direct_append_lits` | input | `logic signed [MAX_CLAUSE_LEN-1:0][31:0]` | Learned clause literals |

### Exposed State

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `current_clause_count` | output | `logic [15:0]` | Current number of clauses (next ID) |

## FSM States (state_e)

| State | Description |
|-------|--------------|
| `IDLE` | Waiting |
| `LOAD_CLAUSE` | Loading CNF |
| `RESET_WATCHES` | Clearing watch lists |
| `INIT_WATCHES` | Initializing watches |
| `APPEND_CLAUSE` | Serializing learned-clause write |
| `SEED_DECISION` | Seeding decision |
| `DEQ_PROP` | Dequeue propagation |
| `SCAN_WATCH` | Scan watch list |
| `SCAN_WATCH_EVAL` | Wait for registered truth |
| `SCAN_REPL` | Scan for replacement |
| `SCAN_REPL_EVAL` | Wait for replacement truth |
| `WATCH_REPL_CYCLE1` | Remove from old list |
| `WATCH_REPL_CYCLE2` | Add to new list |
| `COMPLETE` | Done |
| `INJECT_CLAUSE` | Insert foreign clause |

## Internal Structure

### Arrays (LUTRAM)

- `assign_state[0:MAX_VARS-1]` — 2'b00=unassigned, 2'b01=false, 2'b10=true
- `reason_clause[0:MAX_VARS-1]` — Clause ID per variable
- `clause_len`, `clause_start`, `lit_mem` — Clause store
- `watched_lit1`, `watched_lit2`, `watch_next1`, `watch_next2`, `watch_head1`, `watch_head2` — Watch lists

### Propagation Queue

- `sfifo` (WIDTH=32, DEPTH=PROP_QUEUE_DEPTH) for internal propagation queue

## Behavior (RTL Specification)

### IDLE
If load_valid && load_ready: cur_clause_len_d++, lit_count_d++, max_var_seen_d = max(max_var_seen_q, abs(load_literal)). If load_clause_end: clause_count_d++. Transition to LOAD_CLAUSE. If inject_valid: transition to INJECT_CLAUSE. If start: if cae_direct_append_en and space available, transition to APPEND_CLAUSE; else if initialized_q, transition to INIT_WATCHES or SEED_DECISION; else transition to RESET_WATCHES. If !prop_fifo_empty and !hold_q and !conflict_detected_q: transition to DEQ_PROP.

### LOAD_CLAUSE
Same as IDLE for load_fire. On load_fire: write lit_mem[lit_count_q] = load_literal, clause_len[clause_count_q], clause_start[clause_count_q] updated when load_clause_end. When !load_fire and start: same branch as IDLE. Else transition to IDLE.

### RESET_WATCHES
reset_idx_d = reset_idx_q + 1. When reset_idx_q >= MAX_CLAUSES + 2*MAX_VARS + MAX_VARS: transition to INIT_WATCHES. During reset: clear watch_head1/2, watch_next1/2, assign_state, reason_clause by indexed writes.

### INIT_WATCHES
For each clause init_clause_idx_q: link watched literals to watch lists. init_clause_idx_d++. When init_clause_idx_q >= clause_count_q: initialized_d = 1, transition to SEED_DECISION.

### APPEND_CLAUSE
Write append_lits_q[append_idx_q] to lit_mem[lit_count_q + append_idx_q]. clause_len[append_clause_id_q] = append_len_q, clause_start[append_clause_id_q] = lit_count_q. append_idx_d++. When append_idx_q + 1 >= append_len_q: clause_count_d++, lit_count_d += append_len_q, transition to INIT_WATCHES.

### SEED_DECISION
If decision_var != 0: assign_state[abs(decision_var)-1] = decision_var>0 ? 2'b10 : 2'b01, reason_clause[abs(decision_var)-1] = 16'hFFFF. Transition to DEQ_PROP.

### DEQ_PROP
prop_pop = 1. cur_prop_lit_d = prop_fifo_out. Transition to SCAN_WATCH with scan_clause_d = watch_head[old_head_idx], scan_prev_d = 16'hFFFF, scan_list_sel_d = which watcher was falsified.

### SCAN_WATCH
truth_query_a = watched_lit1[scan_clause_q], truth_query_b = watched_lit2[scan_clause_q]. Transition to SCAN_WATCH_EVAL.

### SCAN_WATCH_EVAL
Read truth_result_a_r, truth_result_b_r (registered from previous cycle). If watched literal is falsified: scan_other_truth = (lit > 0) ? (assign_state[v-1]==2'b10) : (assign_state[v-1]==2'b01). If other_truth == 2'b00 (unassigned): unit clause — prop_push = 1, prop_push_val = lit_other, assign_wr_en = 1, reason_wr_en = 1, reason_wr_clause = scan_clause_q. Transition to WATCH_REPL or COMPLETE. If other_truth == 2'b10 or 2'b01 (satisfied): transition to next clause. If other falsified: conflict_detected_d = 1, conflict_clause = clause literals, transition to COMPLETE.

### SCAN_REPL
Scan clause for replacement watcher. truth_query_a = lit at scan_idx. Transition to SCAN_REPL_EVAL.

### SCAN_REPL_EVAL
If found_repl: scan_repl_lit_q = repl_lit. Transition to WATCH_REPL_CYCLE1 with move_en, move_clause_id, move_new_w, move_old_idx, move_new_idx, move_prev_id. If !found_repl: unit or conflict (same as SCAN_WATCH_EVAL).

### WATCH_REPL_CYCLE1
Unlink clause from old watch list: watch_head1[old_idx] = watch_next1[clause_id] or watch_next1[prev_id] = watch_next1[clause_id]. Transition to WATCH_REPL_CYCLE2.

### WATCH_REPL_CYCLE2
Link clause to new watch list: watch_next1[clause_id] = watch_head1[new_idx], watch_head1[new_idx] = clause_id. watched_lit1[clause_id] = new_w. Transition to next clause or COMPLETE.

### lit_truth_raw
For literal lit: v = abs(lit). If assign_broadcast_valid and assign_broadcast_var == v: current_assign = assign_broadcast_value ? 2'b10 : 2'b01. Else current_assign = assign_state[v-1]. If lit < 0, flip polarity. Return current_assign.

### reason_query
If reason_query_var in [1, MAX_VARS]: reason_query_clause = reason_clause[reason_query_var-1], reason_query_valid = (reason_query_clause != 16'hFFFF). Else reason_query_clause = 16'hFFFF, reason_query_valid = 0.

## References

- [cae](cae.md)
- [solver_core](solver_core.md)
