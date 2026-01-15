# BUG-009: Simulation Hang due to VDE_PHASE Infinite Loop

## Status
- **Status**: Resolved
- **Date Reported**: 2026-01-15
- **Date Closed**: 2026-01-15
- **Severity**: Critical
- **Components**: `solver_core.sv`

## Description
The simulation for `sat_3v_10c_13.cnf` (and others) would hang indefinitely. Instrumentation revealed that the `PSE` module was entering an infinite loop where it kept popping `-1` from its propagation FIFO, but the source of these `-1`s was a massive flood of broadcast events from `solver_core`.

The `solver_core` FSM was observed to be stuck in the `VDE_PHASE`. It would correctly request a decision from VDE, receive it, and broadcast it to PSE. However, instead of transitioning to `PSE_PHASE` to allow propagation to occur, it remained in `VDE_PHASE`. Because the VDE's decision validity is combinatorial, the FSM would re-sample the *same* decision in the next cycle, re-broadcast it, and repeat this forever.

## Root Cause Analysis
- **Missing State Transition**: In `solver_core.sv`, the `VDE_PHASE` block had logic to handle a valid decision (`if (vde_decision_valid) ...`). It updated the `pse_started_d` flag and `cycle_count_d`, but **failed to assign `state_d = PSE_PHASE;`**.
- **Result**: The `state_d` defaulted to `state_q` (implied or via default assignment), causing the FSM to re-enter `VDE_PHASE` on the next clock cycle.
- **Side Effect**: The infinite broadcast of the same decision literal saturated the PSE's FIFO and interface, preventing any forward progress.

## Reproduction Steps
1.  Run `./sim/scripts/run_cnf.sh sim/tests/small_tests/sat_3v_10c_13.cnf SAT`
2.  observe the simulation time limit exceeded or infinite loop if no timeout set.

## Resolution
- **Fix**: Added `state_d = PSE_PHASE;` to the `VDE_PHASE` decision handling block in `solver_core.sv`.
- **Verified**: The infinite loop is resolved, and `sat_3v_10c_13.cnf` passes successfully.
