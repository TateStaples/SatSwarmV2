# SatSwarmv2 Bug Tracker

## Active Issues

*(None)*

---

## Resolved Issues

### [FIXED] BUG-010: CAE Reason Staleness (Learned Clause Resolution)
- **Status**: Resolved
- **Fixed Date**: 2026-01-15
- **Severity**: Critical (Completeness)
- **Description**: Solver failed to resolve learned clauses correctly, leading to false UNSATs.
- **Root Cause**: CAE queried PSE for reason IDs (which were stale) instead of the Trail Manager (Source of Truth).
- **Report**: [BUG-010_CAE_Reason_Staleness.md](BUG-010_CAE_Reason_Staleness.md)

### [FIXED] BUG-007: Infinite Loop & Soundness Failure
- **Status**: Resolved
- **Fixed Date**: 2026-01-14
- **Severity**: Critical (Soundness & Livelock)
- **Description**: Solver hung in infinite loops, failed to propagate learned clause implications (soundness), and retained stale state.
- **Root Cause**: Invalid optimizations (`vde_all_assigned`), missing BCP transition in `APPEND_LEARNED`, and PSE state corruption.
- **Report**: [BUG-007_Infinite_Loop_and_Soundness.md](BUG-007_Infinite_Loop_and_Soundness.md)

### [FIXED] BUG-006: Completeness Failure (False UNSAT)
- **Status**: Resolved
- **Fixed Date**: 2026-01-13
- **Severity**: High (Completeness Bug)
- **Description**: Solver incorrectly reported `UNSAT` for satisfied problems due to truncated conflict clauses and lack of resolution logic.
- **Root Cause**: 1-bit truncation of `pse_conflict_clause_len` and missing First-UIP resolution in CAE.
- **Report**: [BUG-006_Completeness_Failure.md](BUG-006_Completeness_Failure.md)

### [FIXED] BUG-005: Single-Core Soundness (False SAT)
- **Status**: Resolved
- **Fixed Date**: 2026-01-12
- **Severity**: Critical (Soundness Bug)
- **Affected Tests**: `UNSAT 5v #1` (regression suite).
- **Symptoms**: 
  - The problem `UNSAT 5v #1` was correctly identified as `UNSAT` when running the simulation in isolation with debug prints.
  - However, it was incorrectly reported as `SAT` when running as part of the full regression suite.
  - Providing a valid proof of `SAT` (a satisfying assignment) failed model verification (`Clause 7` was unsatisfied).
- **Root Cause**: **PSE Initialization Race Condition**.
  - `solver_core` broadcasts initial assignments (from `Trail`) to `PSE` immediately after `Init`.
  - In regression runs, `PSE` was sometimes still in its `RESET` or `INIT` phase when these broadcasts occurred.
  - Consequently, `PSE` missed the assignment (e.g., `2=T`). It maintained the internal state for `2` as `Unassigned`.
  - When a later propagation (e.g., `5=T`) triggered a scan of `Clause 7 (-2 -5 -1)`, `PSE` saw `-2` as a valid watch candidate (because it thought `2` was unassigned), instead of recognizing a conflict or propagating `-1`.
  - This "silent failure" led the solver to believe it found a valid path.
- **Fix Implemented**:
  1.  **Robust Recovery**: Modified `solver_core.sv` state `ACCUMULATE_PROPS`. If the solver times out waiting for `PSE` (which happens during this race), it now forces a transition to `RESYNC_PSE`. This state manually re-broadcasts ALL assignments from the Trail to `PSE`, correcting any state mismatches.
  2.  **Aggressive Safety Net**: Modified `solver_core.sv` to detect if `PSE` attempts to propagate a variable that is *already assigned* in the Trail. If this happens, it triggers an immediate `RESCAN`, forcing `PSE` to retry with fresh state.
- **Report**: [BUG-005_Single_Core_Soundness.md](BUG-005_Single_Core_Soundness.md)

### [FIXED] BUG-002: Livelock in ACCUMULATE_PROPS
- **Status**: Resolved
- **Fixed Date**: 2026-01-12
- **Severity**: High (Livelock)
- **Description**: Solver entered infinite loop between `ACCUMULATE_PROPS` and `PROPAGATE` on 10v+ problems.
- **Root Cause**: Premature state transition before synchronization stability.
- **Report**: [BUG-002_Livelock.md](BUG-002_Livelock.md)

### [FIXED] BUG-003: Soundness Error (Sign Inversion in CAE)
- **Status**: Resolved
- **Fixed Date**: 2026-01-12
- **Severity**: Critical (Soundness)
- **Description**: Learned clauses had wrong literal signs, leading to invalid models and false SAT reports.
- **Root Cause**: Negation logic error in UIP literal construction in `cae.sv`.
- **Report**: [BUG-003_Soundness_Sign_Inversion.md](BUG-003_Soundness_Sign_Inversion.md)

### [FIXED] BUG-004: Robustness Failure at MAX_VARS=128
- **Status**: Resolved
- **Fixed Date**: 2026-01-12
- **Severity**: Medium (Robustness/Portability)
- **Description**: Solver failed on large parameter configurations due to timeout and capacity mismatches.
- **Root Cause**: Hardcoded timeout too short for large-core initialization; `MAX_LITS` scaling mismatch.
- **Report**: [BUG-004_Robustness_Large_Scale.md](BUG-004_Robustness_Large_Scale.md)
