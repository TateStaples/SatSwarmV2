# BUG-005: Single-Core Soundness (Invalid Model / False SAT)

## Status
**Resolved** (2026-01-13)

## Description
The single-core solver (1x1 grid) repeatedly reported `SAT` for test cases where the provided model did not actually satisfy the problem, or reported `SAT` for unsatisfiable problems. This affected even small verification instances (5 variables, 8 variables).

## Symptoms
- **False SAT:** Solver claimed a solution existed but `verify_model` in the testbench showed unsatisfied clauses.
- **Model Invalid:** Trail contained all variables assigned but the assignment was not a valid solution.
- **Empty Learned Clause Warning:** Debug logs consistently showed `[CORE 0] WARNING: Empty learned clause, retrying` prior to the erroneous SAT declaration.

## Root Cause
The failure was due to a combination of a hardware race condition in the Propagation Search Engine (PSE) and a software-like livelock in the Solver Core logic.

1.  **PSE Data Race:** 
    - The `conflict_detected` signal from `pse.sv` was correctly driven by combinational logic, flagging a conflict immediately.
    - However, the associated data (`conflict_clause_len`, `conflict_clause_lits`) was driven by registered (`_q`) signals.
    - **Outcome:** The `solver_core` would detect the conflict in cycle `N`, but read the conflict data from cycle `N-1` (which was typically empty/zero). The Conflict Analysis Engine (CAE) would then receive an invalid 0-length conflict clause.

2.  **Solver Core Livelock:**
    - When `solver_core` received the 0-length "Empty" conflict loop, it treated it as a recoverable anomaly.
    - The code path logged a warning and resumed propagation *without backtracking*.
    - Since the solver was already deep in the search tree (often with all variables assigned), resuming propagation led it to the `SAT_CHECK` state. 
    - **Outcome:** The solver ignored the conflict (due to the empty clause) and proceeded to declare SAT based on its current invalid assignment.

## Fix
1.  **Synchronized PSE Outputs:** Modified `pse.sv` to drive `conflict_clause_len` and `conflict_clause` combinationally from the `state_q` block, ensuring they align with `conflict_detected`.
2.  **Safety Backtrack:** Modified `solver_core.sv` to treat "Empty learned clause" not as a retry-able warning, but as a critical state requiring a full backtrack to decision level 0.

## Verification
- Validated on `SAT 5v` and `SAT 8v` instances.
- Logs confirm solver now correctly backtracks when conflicts are found.
- `tb_single_core_only` now passes with confirmed valid models.
