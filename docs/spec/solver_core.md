# solver_core — Single CDCL Core

**Source:** [src/Mega/solver_core.sv](../../src/Mega/solver_core.sv)

## Overview

`solver_core` is the main CDCL processing unit. It orchestrates the strict VDE → PSE → CAE loop and manages the propagation FIFO, trail, clause store, and NoC interface.

## Invariants

1. **Strict Serial Loop:** The solver operates in a strict VDE → PSE → CAE sequence. Concurrency between these phases is not permitted.
2. **Trail Integrity:** The Trail is the single source of truth for assignments. PSE and VDE stay synchronized with the Trail.
3. **Rescan Safety:** If PSE produces a conflicting propagation against the Trail, `rescan_required_q` is set and PSE is restarted.

## Parameters

| Parameter | Default | Description |
|-----------|---------|--------------|
| `CORE_ID` | 0 | Core index in grid |
| `MAX_VARS` | 256 | Max variables |
| `MAX_CLAUSES` | 256 | Max clauses |
| `MAX_LITS` | 4096 | Max literals |
| `MAX_CLAUSE_LEN` | 32 | Max clause length |
| `GRID_X` | 1 | Grid X dimension |
| `GRID_Y` | 1 | Grid Y dimension |

## Interface

### Control

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `DEBUG` | input | `logic [31:0]` | Debug level |
| `clk` | input | `logic` | Clock |
| `rst_n` | input | `logic` | Active-low reset |
| `vde_phase_offset` | input | `logic [3:0]` | Phase offset for VDE (per-core diversification) |
| `start_solve` | input | `logic` | Start solve |
| `solve_done` | output | `logic` | Solve finished |
| `is_sat` | output | `logic` | SAT result |
| `is_unsat` | output | `logic` | UNSAT result |

### Host Load

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `load_valid` | input | `logic` | Literal valid |
| `load_literal` | input | `logic signed [31:0]` | Literal (signed) |
| `load_clause_end` | input | `logic` | End of clause |
| `load_ready` | output | `logic` | Ready for load |

### NoC (4 directions: N, S, E, W)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `rx_pkt[3:0]` | input | `noc_packet_t` | Received packets |
| `rx_valid[3:0]` | input | `logic` | RX valid |
| `rx_ready[3:0]` | output | `logic` | RX ready |
| `tx_pkt[3:0]` | output | `noc_packet_t` | Transmit packets |
| `tx_valid[3:0]` | output | `logic` | TX valid |
| `tx_ready[3:0]` | input | `logic` | TX ready |

### Global Memory

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `global_read_req` | output | `logic` | Read request |
| `global_read_addr` | output | `logic [31:0]` | Read address |
| `global_read_len` | output | `logic [7:0]` | Burst length |
| `global_read_grant` | input | `logic` | Read granted |
| `global_read_data` | input | `logic [31:0]` | Read data |
| `global_read_valid` | input | `logic` | Read data valid |
| `global_write_req` | output | `logic` | Write request |
| `global_write_addr` | output | `logic [31:0]` | Write address |
| `global_write_data` | output | `logic [31:0]` | Write data |
| `global_write_grant` | input | `logic` | Write granted |

## FSM States (core_state_t)

| State | Description |
|-------|--------------|
| `IDLE` | Waiting for start_solve |
| `VDE_PHASE` | Request decision from VDE |
| `VDE_FALLBACK` | Fallback scan for unassigned variable |
| `VDE_TRAIL_CHECK` | 1-cycle wait for trail query (VDE decision guard) |
| `PSE_PROP_CHECK` | 1-cycle wait for trail query (propagation guard) |
| `PSE_PHASE` | Wait for PSE propagation |
| `CONFLICT_ANALYSIS` | CAE analyzes conflict |
| `BACKTRACK_PHASE` | Backtrack to computed level |
| `BACKTRACK_UNDO` | Incremental unassign, append, push, start PSE |
| `FINAL_VERIFY` | Final propagation check |
| `SAT_CHECK` | Check if all assigned |
| `FINISH_SAT` | SAT result |
| `FINISH_UNSAT` | UNSAT result |
| `INJECT_RX_CLAUSE` | Inject received clause from NoC |

## Internal Structure

### Propagation FIFO

- `sfifo` (WIDTH=48: 16-bit reason + 32-bit lit), DEPTH=MAX_VARS
- Captures `pse_propagated_valid`, `pse_propagated_var`, `pse_propagated_reason`
- Flush on `start_solve` or `prop_flush`

### Submodules

| Module | Instance | Role |
|--------|----------|------|
| pse | u_pse | Propagation Search Engine |
| cae | u_cae | Conflict Analysis Engine |
| vde | u_vde | Variable Decision Engine |
| trail_manager | u_trail | Assignment trail + backtrack |
| interface_unit | u_iface | NoC packet handler |

### Trail Query Mux

- `muxed_trail_query_var` = CAE drives during `BACKTRACK_PHASE`/`CONFLICT_ANALYSIS`, else FSM `trail_query_var`

## Data Flow

1. **VDE_PHASE:** Request decision from VDE; on valid, push decision to trail, go to PSE_PHASE.
2. **PSE_PHASE:** Start PSE; PSE propagates, pushes to prop FIFO; on conflict, go to CONFLICT_ANALYSIS.
3. **CONFLICT_ANALYSIS:** CAE learns clause, computes backtrack_level; on unsat, go to FINISH_UNSAT.
4. **BACKTRACK_PHASE:** Trail manager backtracks; VDE clears; on done, go to BACKTRACK_UNDO.
5. **BACKTRACK_UNDO:** Pop prop FIFO, append learned clause to PSE, push to trail, restart PSE.

## Behavior (RTL Specification)

### IDLE
When `start_solve` asserted: trail_clear_all = 1, pse_clear_assignments = 1, vde_clear_all = 1, prop_fifo flush. Transition to VDE_PHASE.

### VDE_PHASE
vde_request = 1. trail_query_var = vde_decision_var (or abs of decision_lit_q). Transition to VDE_TRAIL_CHECK when vde_decision_valid.

### VDE_TRAIL_CHECK
One cycle: trail_query_var remains set. Read trail_query_valid_r, trail_query_level_r, trail_query_value_r. On next cycle transition to PSE_PROP_CHECK if VDE decision passes guard; else may loop to VDE_PHASE or VDE_FALLBACK.

### PSE_PROP_CHECK
One cycle: trail_query_var = propagated_var (from prop FIFO or decision). Read trail_query_valid_r. Transition to PSE_PHASE or BACKTRACK_UNDO based on whether prop already assigned.

### PSE_PHASE
pse_start = 1 (pulse). pse_assign_broadcast_valid = 1 when pushing to trail (decision or propagation). When pse_propagated_valid: push {reason, lit} to prop_fifo. When pse_conflict: capture conflict_clause_len, conflict_clause; transition to CONFLICT_ANALYSIS. When pse_done and no conflict: if prop_fifo not empty, transition to BACKTRACK_UNDO to drain; else transition to VDE_PHASE or SAT_CHECK.

### CONFLICT_ANALYSIS
cae_start = 1, decision_level = decision_level_q, conflict_len = conflict_clause_len_q, conflict_lits = conflict_clause_q. muxed_trail_query_var = cae_level_query_var. When cae_done: if cae_unsat, transition to FINISH_UNSAT. Else cae_direct_append_en = 1, cae_direct_append_len = learned_len, cae_direct_append_lits = learned_clause; transition to BACKTRACK_PHASE.

### BACKTRACK_PHASE
trail_backtrack_en = 1, trail_backtrack_to_level = cae_backtrack_level. vde_clear_valid = 1, vde_clear_var = trail_backtrack_var each cycle when trail_backtrack_valid. pse_clear_valid = 1, pse_clear_var = trail_backtrack_var. When trail_backtrack_done: transition to BACKTRACK_UNDO.

### BACKTRACK_UNDO
Pop prop_fifo. For each popped {reason, lit}: push to trail (trail_push = 1, trail_push_var = abs(lit), trail_push_value = lit>0, trail_push_reason = reason), pse_assign_broadcast_valid = 1. When prop_fifo empty: pse_start = 1, transition to PSE_PHASE.

### FINISH_SAT / FINISH_UNSAT
solve_done = 1, is_sat = 1 or is_unsat = 1. State holds.

## References

- [pse](pse.md)
- [cae](cae.md)
- [vde](vde.md)
- [trail_manager](trail_manager.md)
- [interface_unit](interface_unit.md)
