# Bug Fixes

## CAE `MAX_CLAUSE_LEN` too small — false UNSAT on SAT instances ≥ uf125

### Symptom

Benchmark run `20260401_231855_unknown` (hardware F2, 1×1 AFI `afi-058e8c5c1e2864659`):

| Dataset | SAT correct | SAT incorrect |
|---------|-------------|---------------|
| uf50    | 15/15       | 0             |
| uf75    | 15/15       | 0             |
| uf100   | 15/15       | 0             |
| uf125   | 9/15        | **6**         |
| uf150   | 6/15        | **9**         |
| uf175   | 2/15        | **13**        |

All UNSAT instances across every dataset returned the correct answer. Only SAT
instances at ≥125 variables produced wrong (UNSAT) answers, and the failure rate
worsened with problem size.

### Root Cause

The **Conflict Analysis Engine (CAE)** allocates its internal working-clause
buffers as `logic signed [MAX_LITS-1:0][31:0]`, where `MAX_LITS` is the
`MAX_CLAUSE_LEN` parameter passed at instantiation time.

`solver_core.sv` hardcoded `parameter int MAX_CLAUSE_LEN = 32` and
`satswarm_top.sv` never overrode it — it passed `MAX_VARS`, `MAX_CLAUSES`, and
`MAX_LITS` (clause-store size) but omitted `MAX_CLAUSE_LEN`.

During First-UIP resolution the working clause grows as literals from reason
clauses are merged in. For ≥125-variable problems this frontier regularly exceeds
32 literals. Because SystemVerilog does not bounds-check packed arrays, writes
beyond index 31 are silently discarded, producing truncated/corrupted learned
clauses.

**Why only SAT instances fail:** A corrupted learned clause that encodes a
false contradiction will cause the solver to derive the empty clause and declare
UNSAT. UNSAT instances are unaffected because the true contradictions still
propagate correctly even with noise in the learned-clause database.

### Files Changed

| File | Change |
|------|--------|
| `src/mega/solver_core.sv` | `MAX_CLAUSE_LEN` default changed from `32` to `MAX_VARS` so any standalone instantiation is safe |
| `src/mega/satswarm_top.sv` | Added `MAX_CLAUSE_LEN` parameter (defaults to `MAX_VARS_PER_CORE = 256`); wired it through to the `solver_core` instantiation |

### Fix

```diff
// src/mega/solver_core.sv
-    parameter int MAX_CLAUSE_LEN = 32,
+    parameter int MAX_CLAUSE_LEN = MAX_VARS,  // CAE buffer; was 32 (too small for vars > ~50)

// src/mega/satswarm_top.sv  (parameter list)
     parameter int SHARE_MAX_LEN = 2
+    parameter int MAX_CLAUSE_LEN = MAX_VARS_PER_CORE  // CAE working-clause buffer

// src/mega/satswarm_top.sv  (solver_core instantiation)
     solver_core #(
         ...
+        .MAX_CLAUSE_LEN(MAX_CLAUSE_LEN),
         ...
     )
```

`MAX_VARS_PER_CORE = 256` is a safe upper bound: a First-UIP clause can contain
at most one literal per variable, so the working clause never exceeds `n_vars`
literals.

### How to Verify (Simulation)

```bash
cd sim
make build_1x1   # rebuilds with the fix

# Re-run a previously failing instance (expected SAT, was returning UNSAT)
bash scripts/run_cnf.sh sim/tests/satlib/sat/uf125/uf125-02.cnf SAT 5000000
bash scripts/run_cnf.sh sim/tests/satlib/sat/uf150/uf150-01.cnf SAT 5000000
bash scripts/run_cnf.sh sim/tests/satlib/sat/uf175/uf175-01.cnf SAT 5000000
```

All three should now return `SAT` (correct).

### FPGA / AFI Impact

The existing AFIs were synthesised with `MAX_CLAUSE_LEN = 32`. A new synthesis
run with the corrected RTL is required before the fix takes effect on hardware.
Use `deploy/run_grid_sharing_builds.sh` (or the equivalent Synth.md flow) to
produce a new bitstream and AFI. Until then, hardware results for problems with
≥125 variables remain unreliable for SAT instances.

---

## `CLAUSE_RX_FIFO_DEPTH` not wired through — clause dropping in multicore grids

### Problem

`interface_unit.sv` has a `CLAUSE_RX_FIFO_DEPTH` parameter controlling the
per-core incoming clause FIFO, but `solver_core.sv` never passed it at
instantiation time and `satswarm_top.sv` had no such parameter at all. The FIFO
was permanently stuck at 4 entries regardless of any override attempt.

In a 2×2 or 3×3 grid with clause sharing active, all neighbors can broadcast
simultaneously. With only 4 entries buffered, any burst of >4 clauses would be
silently dropped, degrading shared learning.

### Fix

`CLAUSE_RX_FIFO_DEPTH = 16` is now the default at every level and is correctly
threaded:

```
satswarm_top(CLAUSE_RX_FIFO_DEPTH=16)
  → solver_core(.CLAUSE_RX_FIFO_DEPTH(CLAUSE_RX_FIFO_DEPTH))
    → interface_unit(.CLAUSE_RX_FIFO_DEPTH(CLAUSE_RX_FIFO_DEPTH))
```
