# Bug Report: False UNSAT on SAT Instances (Found 2026-04-05)

## Summary

The solver incorrectly reports SAT instances as UNSAT on difficult uf100/uf125 benchmarks. Root cause: the literal pool fills up, learned clauses are silently dropped, and the trail is poisoned with an invalid reason clause index — eventually causing a false level-0 conflict on the FPGA.

---

## Symptom

- 7 instances fail across both 1x1 AFI runs (April 2 and April 5)
- All failures are SAT→UNSAT, never UNSAT→SAT
- Only affects larger instances (uf100+); uf50/uf75 always pass
- Same instances fail reproducibly on the same configuration
- More cores → fewer failures (3x3-2clz: 1 failure; 1x1: 7 failures)

---

## Investigation Trail

### Step 1: Is it a regression from commit c48127f (watched literals update)?

No. Pre-commit runs (2x2-2clz and 3x3-2clz, March 24 AFIs, run at 03:39–03:49 UTC April 2 — 8 hours before c48127f) also had uf125 failures:

| Config | Failing uf125 instances |
|--------|------------------------|
| 2x2-2clz (pre-commit) | 02, 08, 09, 010, 014, 015 |
| 3x3-2clz (pre-commit) | 014 only |
| 1x1 (post-commit, April 2 + 5) | 04, 010, 011, 012, 013, 014 |

The `c48127f` changes are performance shortcuts for level-0 conflicts (skip full CAE analysis when `decision_level==0` since a level-0 conflict is definitionally UNSAT in CDCL). The `fin_found_sec_q` addition correctly places the sec_max_level literal at position 1 of each learned clause for 2-WL semantics. Neither change is the root cause.

### Step 2: The failures are search-path dependent

Different instances fail in different configurations. uf125-014 is the only instance that fails across every configuration tested. This rules out "these CNFs are broken" and points to a bug triggered by the search process — specifically, how far the solver gets before finding a solution.

### Step 3: Simulation reproduces the bug

Building the simulator with FPGA-matching parameters (`MAX_CLAUSES=8192`, `MAX_LITS=8192`):

```bash
make build_1x1_fpga
./obj_dir_1x1_fpga/Vtb_satswarmv2 +CNF=../benchmarks/satlib_3sat/sat/uf125/uf125-014.cnf +EXPECT=SAT +DEBUG=1 +MAXCYCLES=5000000
```

Final simulation output:
```
[TRAIL MANAGER] trail_height_q changed from 76 to 24
[CORE 0] BACKTRACK_UNDO complete: append+push+pse_start in one cycle
         (len=3, assert_lit=0, assert_var=0, level=13, reason=65535, accepted=0)
[ERROR] Hardware Limit Reached: Literal Count (8192) >= MAX_LITS (8192)
[ERROR] Simulation Terminated due to memory exhaustion.
```

---

## Root Cause

### The literal pool fills up

`pse.sv` maintains a flat literal pool of size `MAX_LITS`. Every learned clause appends its literals to this pool. For difficult uf125 instances on a 1x1 solver, the search explores enough conflicts to fill the pool to capacity.

### In simulation: assertion fires, clean termination

`pse.sv` lines 1284–1288 (`ifndef SYNTHESIS`):
```systemverilog
if (lit_count_q >= MAX_LITS - 2) begin
    $display("[ERROR] Hardware Limit Reached: ...");
    $finish;
end
```

This block does not exist in the synthesized FPGA bitstream.

### On FPGA: clause silently dropped, trail poisoned

When the pool is full, `cae_direct_append_accepted = 0`:

```systemverilog
assign cae_direct_append_accepted = cae_direct_append_en &&
    ...
    (lit_count_q + cae_direct_append_len) <= MAX_LITS;  // pse.sv:312
```

The solver detects this and sets `reason=0xFFFF` for the UIP being asserted (`solver_core.sv:1470`):

```systemverilog
trail_push_reason = pse_direct_append_accepted ? pse_clause_count : 16'hFFFF;
```

**The UIP is still pushed to the trail** — with no backing clause. From this point:

1. A variable in the trail carries `reason=65535`
2. A future conflict triggers CAE to resolve against that variable
3. CAE queries reason clause index `65535` — far out of bounds
4. Out-of-bounds clause memory read returns garbage
5. Garbage produces an incorrect learned clause
6. Eventually the corrupt clause fires a false unit propagation at level 0
7. False level-0 conflict → solver declares UNSAT

### Why more cores help

In 3x3-2clz, 9 cores share learned clauses and guide each other toward the solution. The search terminates before the literal pool fills. In 1x1, a single core searches alone and reliably exhausts the pool on certain hard instances.

---

## Affected Files

| File | Issue |
|------|-------|
| `src/Mega/pse.sv` | No graceful handling when `lit_count >= MAX_LITS`; simulation asserts but hardware silently continues |
| `src/Mega/solver_core.sv` | When `accepted=0`, still pushes UIP to trail with `reason=0xFFFF` — should trigger restart instead |

---

## Fix (Not Yet Implemented)

When `cae_direct_append_accepted = 0` (literal pool full), the solver must not continue with a poisoned trail entry. The correct response is a **restart**: clear all learned clauses, reset `lit_count` and `clause_count`, and restart the search from level 0.

Standard CDCL solvers (Minisat, Glucose) perform periodic clause database reduction before the DB fills. A simpler approach for this hardware implementation: trigger a full restart whenever `accepted=0` is observed after a conflict.

This ensures:
- The solver never operates with `reason=0xFFFF` in the trail
- Soundness is preserved (learned clauses are valid inferences, not required for completeness)
- The solver will eventually find SAT or prove UNSAT correctly
