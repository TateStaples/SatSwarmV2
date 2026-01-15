# BUG-002: Livelock in ACCUMULATE_PROPS

## Status
**RESOLVED**

## Description
The solver entered a livelock state where it oscillated between `ACCUMULATE_PROPS` and `PROPAGATE` indefinitely without making progress or increasing the decision level. This resulted in test timeouts.

## Symptoms
- Waveform showed repeating state pattern.
- `cycle_count` increased but `decision_level` remained static.
- Occurred on `SAT 10v #1` and `UNSAT 10v #1`.

## Root Cause
The `ACCUMULATE_PROPS` state logic prematurely transitioned to `PROPAGATE` before all propagations were synchronized. Specifically, if a propagation occurred late in the cycle or if `new_propagations` was asserted while `vde_all_assigned` was fluctuating, the solver would attempt to propagate, find nothing, return to accumulate, and repeat.

## Fix
Modified `solver_core.sv` to enforce stricter exit conditions for `ACCUMULATE_PROPS`.
- Added logic to loop within `ACCUMULATE_PROPS` until `pse_done` is true AND `vde_all_assigned` (or not) is stable.
- Ensured `rescan_required` logic triggers a full resync if state is ambiguous.

## Verification
- `SAT 10v #1` passed.
- Regression tests confirmed no regression on smaller problems.
