# BUG-008: Missed Propagation Due to Watcher Corruption

## Status
- **Status**: Resolved
- **Date Closed**: 2026-01-15
- **Date Reported**: 2026-01-14
- **Severity**: Critical
- **Components**: `pse.sv`, `solver_core.sv`

## Description
The solver fails to propagate unit implications after backtracking, leading to divergent behavior compared to the golden model (Python) and potential soundness/completeness issues.

Specific instance observed in `sat_3v_13c_20.cnf`:
1.  Solver backtracks to Level 1.
2.  Assigns `2` (True).
3.  **Clause 2** (`[1, -3, -2]`) should become Unit (`-3` implied) because `1` is False and `2` is True (so `-2` is False).
4.  **Hardware Failure**: The solver *misses* this propagation and instead proceeds to decide `-3` at the next decision level.
5.  **Golden Model**: Correctly propagates `-3` and subsequently detects a conflict in Clause 3.

## Root Cause Analysis
The issue appears to be corruption or incorrect management of the **Watched Literal** data structure in `pse.sv`.

-   **Log Evidence**:
    -   `[PSE] Replaced watcher 1 with -2 for clause 2` (Correct initial update).
    -   Later trace shows Clause 2 is visited but with `w1=6` (Literal 3) instead of `w1=5` (Literal -2).
    -   This suggests the update to watch `-2` was either lost, overwritten, or never correctly committed to the watcher memory.

## Reproduction Steps
1.  Run `./sim/scripts/run_cnf.sh sim/tests/small_tests/sat_3v_13c_20.cnf SAT`
2.  Observed output shows `Decided: -3 at Level 2` following the assignment of `2`, instead of propagating `-3` at Level 1.

## Proposed Fix
Investigate `pse.sv` watcher update logic:
1.  Verify write enable signals for watcher memory during `REPLACE_WATCHER` state.
2.  Check for race conditions or address collisions when multiple watchers are updated.
3.  Ensure the "Shadow Match" or lazy update mechanism is correctly invalidating old entries.

## Resolution
- **Root Cause**: A temporary debug statement in `pse.sv` (lines 664-670) was inadvertently forcing a write to `watched_lit1[2]` with an invalid index (`55`) whenever Clause 2 was scanned. This corrupted the linked list and caused the watcher to point to garbage, missing future propagations.
- **Fix**: Removed the debug code block.
- **Verified**: `sat_3v_13c_20.cnf` now passes regression testing (after also fixing the VDE Phase Reset bug described in BUG-009).
