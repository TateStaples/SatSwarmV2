# BUG-011: Invalid Literal 0 (Phantom Variable)

**Date:** 2026-01-16
**Status:** FIXED
**Severity:** CRITICAL
**Component:** Conflict Analysis Engine (CAE) / Propagation Search Engine (PSE)

## Description
The solver crashed during regression testing of `sat_75v_325c_1.cnf` (and potentially other hard instances). The crash manifested as an assertion failure in `pse.sv`:
```
[PSE ERROR] Clause 362 implies Var 0! Dumping state:
  w1=1245 (idx=0) lit=0 ...
```
This indicated that a clause containing `lit=0` (Variable 0) was generated and stored in the clause database. Variable 0 is reserved/invalid in DIMACS and internal solver logic.

## Root Cause
The Conflict Analysis Engine (`cae.sv`) failed to filter out `0` literals during the conflict resolution process.
1. `pse.sv` occasionally returns `0` as a literal value during clause reading (e.g., if reading out of bounds or invalid default).
2. `cae.sv` (Resolution State) merged this `0` literal into the conflict buffer (`buf_lits`).
3. The `0` literal persisted through the UIP calculation.
4. `cae.sv` generated a "learned clause" containing `0`, e.g., `[60, 0, -50]`.
5. When `pse.sv` attempted to propagate this clause later, it read `0` as an implied or watched literal, triggering the fatal assertion.

## Fix
Modified `src/Mega/cae.sv` to explicitly filter `0` literals at two ingress points:
1. **INIT_CLAUSE**: When loading the initial conflict clause.
2. **RESOLUTION**: When merging literals from the reason clause.

```systemverilog
// src/Mega/cae.sv
if (!is_dup && idx < MAX_BUFFER && conflict_lits[k] != 0) begin ...

if (r_var_local != resolve_var_q && r_var_local != 0) begin ...
```

## Additional Changes (Deterministic VDE)
To assist in debugging this issue, the Variable Decision Engine (`vde_heap.sv`) was modified to remove random initialization.
- **Before:** VSIDS scores initialized with LCG random values.
- **After:** VSIDS scores initialized to `0`.
- **Impact:** Solver behavior is now fully deterministic and matches the Python reference model (`mega_sim.py`) logic (though efficiency differs due to search depth). This allows consistent reproduction of bugs.

## Verification
- `sat_75v_325c_1.cnf`: Previously crashed. Now runs stably (though hits 16k literal limit due to high complexity).
- `uuf50-0410.cnf`: Passed (UNSAT).
- Regression Suite: Verified no regressions in SATLIB or Ladder tests.
