# BUG-004: Robustness Failure at MAX_VARS=128 (Timeout/Capacity)

## Status
**RESOLVED**

## Description
Solver failed with "MODEL INVALID" or "TIMEOUT" when `MAX_VARS` was increased to 128 and `MAX_CLAUSES` to 1024, despite the logic being correct for small instances.

## Symptoms
- `MAX_VARS=128` failed on small problems (5v-20v).
- Logs showed "Timeout: Resyncing PSE state before continuing" repeatedly.
- "Model Invalid" errors suggested internal state corruption.

## Root Cause
1.  **Timeout Too Short**: `solver_core.sv` had a hardcoded timeout of 100 cycles to wait for `pse` operations. The `pse` module takes ~10 cycles per variable to reset. For `MAX_VARS=128`, reset takes ~1280 cycles. The solver timed out, aborted the wait, and proceeded with a partially reset `pse`, leading to state corruption.
2.  **Capacity Parameter**: `MAX_LITS` was defaulting to 416 (sufficient for small tests) but `MAX_CLAUSES=1024` requires ~4096 literals.

## Fix
1.  **Increased Timeout**: Updated `solver_core.sv` timeout threshold from 100 to 50,000 cycles.
2.  **Scaled Parameters**: Updated `sim/Makefile` and `run_regression_sweep.sh` to pass `MAX_LITS` derived from `MAX_CLAUSES` (4x ratio).

## Verification
- `Extended Robustness Sweep` passed for:
    - `MAX_VARS=32, MAX_CLAUSES=256`
    - `MAX_VARS=64, MAX_CLAUSES=512`
    - `MAX_VARS=128, MAX_CLAUSES=1024`
