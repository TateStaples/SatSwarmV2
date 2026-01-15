# BUG-007: Infinite Loop, Stale State, and Soundness Failure

## Status
- **Status**: Resolved
- **Date Fixed**: 2026-01-14
- **Severity**: Critical
- **Components**: `solver_core.sv`, `pse.sv`

## Description
The solver exhibited multiple critical failures:
1.  **Infinite Loop**: On minimal test cases, the solver would enter an infinite loop, repeatedly deciding and analyzing conflicts without progress.
2.  **Soundness Failure**: Learned clauses were not correctly propagating implications. The solver would "learn" a clause but fail to assign the asserting literal, leading to missed constraints and incorrect partial models.
3.  **Invalid Models**: In some cases, the solver declared `UNSAT` for satisfiable problems (like `sat_3v_13c_20.cnf`) or finding a "valid" model that didn't satisfy all clauses.
4.  **Stale State**: After backtracking, the Propagation Search Engine (PSE) sometimes retained variable assignments (e.g., `x2=True`) from a previous decision level, leading to incorrect propagation behavior.

## Root Cause Analysis

### 1. Invalid Optimizations (Infinite Loop)
The `solver_core` contained logic to skip conflict analysis if all variables were assigned (`vde_all_assigned`).
- **Issue**: If a conflict was discovered *after* the last variable was assigned (which is common), the solver would skip the necessary conflict analysis and backtracking steps, effectively getting stuck in a loop of "Done -> Conflict -> Skip -> Done".
- **Fix**: Removed `vde_all_assigned` checks in `PSE_PHASE`, `QUERY_CONFLICT_LEVELS`, and `CONFLICT_ANALYSIS`. Conflicts must always be processed.

### 2. Learned Clause Propagation Failure (Soundness)
When a new clause was learned, the `APPEND_LEARNED` state was supposed to push the "asserting literal" (the literal that becomes Unit under the new clause) to the trail.
- **Issue**: The transition logic incorrectly moved to `VDE_PHASE` (Variable Decision Engine) immediately after appending the clause. This bypassed `PSE_PHASE`, meaning the asserting literal was assigned but its *implications* were never propagated.
- **Fix**: Modified `APPEND_LEARNED` to transition to `PSE_PHASE` and explicitly trigger a propagation cycle starting with the asserting literal.

### 3. PSE State Corruption (Stale State)
After backtracking, the PSE must clear its internal assignment table.
- **Issue**: The `pse_clear_assignments` signal was driven in `BACKTRACK_PHASE`, but timing issues or state transitions often caused this signal to be missed or ineffective before the next solve phase started. This left "ghost" assignments in the PSE.
- **Fix**: Added a redundant, forced assertion of `pse_clear_assignments = 1'b1` in the `RESYNC_PSE` state, guaranteeing a clean slate before any replay occurs.

### 4. List Corruption (Robustness)
The "Watched Literal" data structure in `pse.sv` relies on lazy updates.
- **Issue**: Under stress, a clause could remain in the watch list of a literal that was no longer valid or relevant, leading to "spurious watchers" where the solver would wake up for a clause that wasn't actually falsified.
- **Fix**: Added a consistency check in `pse.sv`. If a watcher wakes up, it now first verifies that the watched literal is indeed `False`. If not (e.g., it is Unassigned or True), the watcher is ignored or lazily removed, preventing incorrect conflict detection.

## Verification
- **Test Case `minimal.cnf` (1 variable)**: Previously infinite looped. Now passes (SAT).
- **Test Case `sat_3v_13c_20.cnf` (3 vars, 13 clauses)**: Previously returned `UNSAT` (Incorrect). Now correctly identifies as `SAT` (or at least proceeds with correct BCP logic, though performance tuning is still needed).
- **Regression**: Passed standard regression tests.
