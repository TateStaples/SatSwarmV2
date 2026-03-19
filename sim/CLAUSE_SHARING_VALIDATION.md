# Binary Clause Sharing — Validation Report

## Stability (Soundness)

All **98 / 98** tests in `run_bigger_ladder` pass with the 2×2 (4-core) build that has
binary clause sharing enabled.  Both SAT and UNSAT instances produce correct results;
the testbench's model-checker (enabled at `+DEBUG=2`) independently verifies every SAT
assignment.

```
==================================================
Bigger Ladder Summary
==================================================
Total Tests: 98
Passed:      98
Failed:      0
==================================================
ALL TESTS PASSED
```

---

## Feature Activation (Proof of Triggering)

Running `unsat_50v_215c_2.cnf` at `+DEBUG=2` shows the feature end-to-end:

1. A core learns a binary clause and **broadcasts** it (`BACKTRACK_UNDO … len=2`).
2. Each neighbouring core **receives and injects** the clause (`INJECT_RX_CLAUSE`).

```
[CORE 0] BACKTRACK_UNDO complete: append+push+pse_start in one cycle (len=2, assert_lit=2, assert_var=2, level=1, reason=224)
[CORE 2] INJECT_RX_CLAUSE: appending {2, 1} via cae_direct_append
[CORE 1] INJECT_RX_CLAUSE: appending {2, 1} via cae_direct_append
[CORE 2] BACKTRACK_UNDO complete: append+push+pse_start in one cycle (len=2, assert_lit=1, assert_var=1, level=1, reason=232)
[CORE 0] INJECT_RX_CLAUSE: appending {1, 50} via cae_direct_append
[CORE 3] INJECT_RX_CLAUSE: appending {1, 50} via cae_direct_append
[CORE 3] BACKTRACK_UNDO complete: append+push+pse_start in one cycle (len=2, assert_lit=-1, assert_var=1, level=1, reason=228)
[CORE 2] INJECT_RX_CLAUSE: appending {-1, -50} via cae_direct_append
[CORE 1] INJECT_RX_CLAUSE: appending {-1, -50} via cae_direct_append
```

Across this single run: **12 binary clauses broadcast**, **24 peer injections**.

---

## Speed Improvement (Cycle Counts)

Comparison between a single-core build (1×1, no sharing) and the 4-core build (2×2,
binary clause sharing active).  Lower cycles = faster convergence.

| Test instance            | 1×1 cycles | 2×2 cycles | Speedup |
|--------------------------|------------|------------|---------|
| unsat_32v_136c_1.cnf     | 18 896     | 15 499     | 1.22×   |
| unsat_42v_178c_1.cnf     | 55 925     | 45 640     | 1.23×   |
| unsat_50v_215c_2.cnf     | 53 154     | 32 722     | 1.62×   |
| sat_75v_325c_1.cnf       | 164 760    | 51 250     | 3.21×   |

Cycle counts measure simulated hardware clock cycles, not wall-time, so the speedup
is architecture-level and independent of simulation host speed.
