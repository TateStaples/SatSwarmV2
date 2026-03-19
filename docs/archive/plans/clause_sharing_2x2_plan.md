## Plan: Enable Minimal 2x2 Clause Sharing

Enable a conservative, binary-clause-only sharing path in 2x2 by driving existing NoC clause signals from learned clauses, adding simple throttling/filters to avoid flooding, and validating with targeted correctness + behavior tests before benchmarking.

**Steps**
1. Add a feature gate and minimal send policy in [SatSwarmV2/src/Mega/solver_core.sv](SatSwarmV2/src/Mega/solver_core.sv): define a compile-time/runtime enable for clause sharing, default off for safety.
2. Implement transmit trigger in [SatSwarmV2/src/Mega/solver_core.sv](SatSwarmV2/src/Mega/solver_core.sv): in BACKTRACK_UNDO after CAE completes, assert clause broadcast request only when learned clause length is 2 and solver is not UNSAT, pack two literals into the existing 64-bit payload, and map a simple quality byte (initially fixed low LBD or derived from learned length).
3. Add retry/backpressure handling in [SatSwarmV2/src/Mega/solver_core.sv](SatSwarmV2/src/Mega/solver_core.sv): hold a one-entry pending clause register and keep request asserted until interface ack is observed so single-cycle stalls do not silently drop share attempts. Depends on step 2.
4. Add receive-side safety filtering in [SatSwarmV2/src/Mega/solver_core.sv](SatSwarmV2/src/Mega/solver_core.sv): before INJECT_RX_CLAUSE append, reject trivial invalid clauses (zero literals, x and -x tautology, duplicate pair), and optionally reject if local clause count near configured cap. Parallel with step 3.
5. Add lightweight observability counters in [SatSwarmV2/src/Mega/solver_core.sv](SatSwarmV2/src/Mega/solver_core.sv): tx_attempt, tx_acked, tx_dropped, rx_seen, rx_injected, rx_rejected to make behavior debuggable in 2x2 runs. Parallel with steps 3-4.
6. Keep topology minimal in 2x2: do not change mesh router logic in [SatSwarmV2/src/Mega/mesh_interconnect.sv](SatSwarmV2/src/Mega/mesh_interconnect.sv) and do not introduce shared_clause_buffer routing changes yet in [SatSwarmV2/src/Mega/satswarm_top.sv](SatSwarmV2/src/Mega/satswarm_top.sv). This explicitly limits scope to existing NoC clause path.
7. Add/extend simulation checks for 2x2 in [SatSwarmV2/sim/sv/quick_test.sv](SatSwarmV2/sim/sv/quick_test.sv) and existing benchmark/regression scripts to validate both correctness and sharing activity. Depends on steps 2-5.

**Relevant files**
- [SatSwarmV2/src/Mega/solver_core.sv](SatSwarmV2/src/Mega/solver_core.sv) — currently owns learned clause data, clause tx/rx interface wiring, and INJECT_RX_CLAUSE path.
- [SatSwarmV2/src/Mega/interface_unit.sv](SatSwarmV2/src/Mega/interface_unit.sv) — clause broadcast/ack handshake and clause rx extraction behavior.
- [SatSwarmV2/src/Mega/mesh_interconnect.sv](SatSwarmV2/src/Mega/mesh_interconnect.sv) — keep unchanged in this phase; documents current simplified transport constraints.
- [SatSwarmV2/sim/sv/quick_test.sv](SatSwarmV2/sim/sv/quick_test.sv) — 2x2 testbench entry for targeted clause-sharing assertions.
- [SatSwarmV2/sim/scripts/benchmark_mega_mesh.sh](SatSwarmV2/sim/scripts/benchmark_mega_mesh.sh) — correctness/perf smoke in 1x1 vs 2x2.
- [SatSwarmV2/sim/scripts/stability_test_50v.sh](SatSwarmV2/sim/scripts/stability_test_50v.sh) — repetition/stability checks under 2x2.
- [SatSwarmV2/sim/scripts/run_aws_scaling_collection.sh](SatSwarmV2/sim/scripts/run_aws_scaling_collection.sh) — optional 1x1/2x2 data collection once sharing-on is stable.

**Verification**
1. Handshake unit checks (2x2): with sharing enabled and synthetic forced learned binaries, verify tx_attempt > 0 and tx_acked > 0 while rx_seen/rx_injected increment on neighbors; confirm no share when gate disabled.
2. Correctness parity set: run a small SAT/UNSAT corpus in 1x1 and 2x2 with sharing off vs on, require identical SAT/UNSAT outcomes and no increase in wrong-result count.
3. Safety filter checks: inject malformed payloads (0 literal, tautology pair, duplicate pair) and verify rx_rejected increments with no append side effects.
4. Backpressure check: hold one tx_ready low intermittently in simulation, confirm pending clause retries until ack and no permanent deadlock.
5. Stability run: execute [SatSwarmV2/sim/scripts/stability_test_50v.sh](SatSwarmV2/sim/scripts/stability_test_50v.sh) focused on 2x2 for multiple seeds/runs, compare timeout/error deltas sharing-off vs sharing-on.
6. Performance sanity (not final benchmark): run [SatSwarmV2/sim/scripts/benchmark_mega_mesh.sh](SatSwarmV2/sim/scripts/benchmark_mega_mesh.sh) on a short subset; expect modest cycle/time movement but preserved correctness.

**Decisions**
- Include now: binary-clause sharing only, single pending tx slot, basic receive filtering, counters, 2x2-only verification.
- Exclude now: generalized k-literal serialization, global dedup tables, advanced LBD/usage heuristics, router redesign, shared_clause_buffer integration into core datapath.
- Rationale: starts sharing quickly with bounded risk and measurable behavior.

**Further Considerations**
1. Gate control recommendation: start with compile-time parameter + plusarg override so CI can run both sharing-off and sharing-on paths deterministically.
2. Initial filter recommendation: share only len==2 and avoid sending asserting literal pairs that are tautological or already unit-satisfied locally.
3. Exit criterion recommendation: promote beyond 2x2 only after parity correctness is unchanged and tx/rx counters show sustained nonzero activity without timeout regression.
