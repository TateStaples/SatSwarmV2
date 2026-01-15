# BUG-006: Completeness Failure (False UNSAT)

## Status
**Resolved** (2026-01-13)

## Description
The solver incorrectly declared `UNSAT` for several small Satisfiable problems (e.g., `sat_3v_10c_29.cnf`). The solver would find conflicts but fail to learn effective clauses to prune the search space, eventually backtracking to level 0 and exhausting the search space falsely.

## Symptoms
- **False UNSAT:** Known SAT problems reported as UNSAT.
- **Repeated Conflicts:** Solver encountered conflicts but learned clauses that were identical to the conflict clauses, indicating no resolution was happening.
- **Truncated Clauses:** Debug logs showed conflict clauses of `Len=1` even when the conflict involved multiple literals.

## Root Causes

### 1. Width Mismatch (Critical Hardware Bug)
**Location:** `solver_core.sv`
**Details:** The signal `pse_conflict_clause_len` was declared as a **1-bit** wire, but connected to a **4-bit** output from PSE.
**Impact:** Any conflict clause with length > 1 (e.g., 3, binary `0011`) had its length truncated to 1 (`0001`). The CAE received invalid conflict data, treating multi-literal conflicts as unit conflicts at level 0, leading to immediate (false) UNSAT.

### 2. RESYNC Timing Race (Synchronization Bug)
**Location:** `solver_core.sv` -> `pse.sv` interface
**Details:** When the solver broadcasted trail assignments to PSE during `RESYNC_PSE`, it transitioned to `ACCUMULATE_PROPS` (starting the scan) in the same cycle as the last broadcast.
**Impact:** PSE's assignment state (updated on clock edge) would not yet reflect the final broadcast when scanning started, causing it to use stale `Unassigned` values for variables that were actually `True/False` on the trail.

### 3. Lack of First-UIP Resolution (Architectural Defect)
**Location:** `cae.sv`
**Details:** The original Conflict Analysis Engine (CAE) implementation **did not perform resolution**. It simply copied the conflict clause literals to the learned clause.
**Impact:** This is valid soundly but incomplete for CDCL progress. Without resolving against reason clauses to find the First Unique Implication Point (UIP), the solver learns "weak" clauses that do not effectively drive backtracking or assertion.

## Fixes Implemented

### 1. Hardware Fixes
- **Width Correction:** Changed `pse_conflict_clause_len` to `logic [3:0]`.
- **Timing Fix:** Added `RESYNC_PSE_SETTLE` state to `solver_core` FSM to insert a 1-cycle wait state after broadcasting assignments, ensuring PSE state consistency.

### 2. Architectural Overhaul (First-UIP)
- **New CAE:** Completely rewrote `cae.sv` to implement a robust First-UIP algorithm:
    - **Backward Trail Walk:** Iterates backwards through the trail to find the most recent conflicting literal.
    - **Resolution Loop:** Resolves the conflict clause with Reason Clauses (fetched from PSE) until only one literal remains at the current decision level.
    - **Clause Learning:** Generates proper asserting clauses.
- **Infrastructure Support:**
    - Updated `pse.sv` to store and provide "Reason Clauses" for every propagation.
    - Updated `trail_manager.sv` to allow random-access reading of the trail for the backward walk.
    - Updated `solver_core.sv` to wire the new Reason and Read interfaces between modules.

## Verification
- Verified on `sat_3v_*` test suite.
- Confirmed that `sat_3v_10c_29.cnf` (previously failing) now passes.
- Confirmed that proper resolution leads to effective learned clauses (e.g., learning binary clauses from ternary conflicts).
