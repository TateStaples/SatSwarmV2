# Design Overview

`SatSwarmV2` is a hardware CDCL SAT solver organized as a swarm of solver cores behind an AWS F2 shell wrapper. This document is intentionally high level: it describes what the design is trying to achieve, what invariants must stay true, and how the major blocks fit together. For module-by-module behavior and interfaces, use the files in `docs/spec/`.

---

## Goals

- Implement a **correct CDCL solver in synthesizable hardware**, not just a BCP accelerator.
- Keep the **single-core semantics simple and auditable** so correctness debugging is tractable.
- Scale from **1×1** to multi-core grids by adding clause-sharing and NoC structure without changing the host-visible programming model.
- Preserve a clean boundary between:
  - **Solver intent**: `satswarm_top`, `solver_core`, and the core subsystems.
  - **AWS shell adaptation**: `satswarm_core_bridge` and `cl_satswarm`.
- Favor structures that map well to FPGA resources:
  - explicit FSMs
  - bounded memories
  - narrow, local interfaces
  - simple host control/status

## Non-goals

- This document is **not** a reimplementation guide.
- This document does **not** define every register, FSM state, or pipeline stage.
- This document does **not** replace the detailed RTL specs under `docs/spec/`.

---

## Top-Level Picture

At a high level, the design has three layers:

1. **AWS wrapper**  
   `cl_satswarm` terminates the full AWS HDK shell interfaces and bridges them into a simpler local interface. See `docs/spec/cl_satswarm.md`.

2. **Bridge / host adaptation**  
   `satswarm_core_bridge` turns AXI-Lite control and PCIS literal loading into the `satswarm_top` control/load interface. See `docs/spec/satswarm_core_bridge.md`.

3. **Solver fabric**  
   `satswarm_top` instantiates the solver grid, NoC, shared-clause path, and global memory infrastructure. See `docs/spec/satswarm_top.md`.

The spec hierarchy in `docs/spec/README.md` is the authoritative map:

- `docs/spec/satswarm_top.md`
- `docs/spec/solver_core.md`
- `docs/spec/pse.md`
- `docs/spec/cae.md`
- `docs/spec/vde.md`
- `docs/spec/vde_heap.md`
- `docs/spec/trail_manager.md`
- `docs/spec/watch_manager.md`
- `docs/spec/shared_clause_buffer.md`
- `docs/spec/mesh_interconnect.md`
- `docs/spec/global_mem_arbiter.md`
- `docs/spec/global_allocator.md`
- `docs/spec/cl_satswarm.md`
- `docs/spec/satswarm_core_bridge.md`

---

## Core Design Invariants

These are the main ideas future changes should preserve.

### 1. Strict CDCL phase ordering

The solver core is built around a strict **VDE -> PSE -> CAE** alternation. The point is not maximum micro-parallelism inside one core; the point is preserving a simple and debuggable CDCL execution model.

This invariant is stated explicitly in `docs/spec/solver_core.md` and `docs/spec/README.md`.

### 2. The trail is the source of truth

Assignments live in the trail machinery. Other blocks may cache or query assignment state, but they must not invent a conflicting parallel notion of truth.

The practical consequence is:

- propagation must agree with trail state
- backtracking must cleanly roll trail-visible state back
- decision logic must choose only from trail-unassigned variables

See `docs/spec/solver_core.md` and `docs/spec/trail_manager.md`.

### 3. Propagation dominates the design

Most of the solver's runtime pressure sits in propagation and watched-literal maintenance. That is why the design invests heavily in:

- explicit watch structures
- bounded clause storage
- simple request/response memory interfaces
- careful treatment of rescan and conflict cases

See `docs/spec/pse.md`, `docs/spec/watch_manager.md`, and `docs/spec/clause_store.md`.

### 4. Conflict analysis must stay logically authoritative

Clause learning is not an optional optimization here; it is part of the core algorithm. `cae` is responsible for First-UIP style learning and for producing the backtrack level that restores a consistent search state.

See `docs/spec/cae.md`.

### 5. Multi-core scaling must not break single-core semantics

The swarm architecture is an extension of the 1×1 solver, not a different solver. Clause sharing, mesh routing, and host aggregation should only improve search coverage and sharing opportunities; they must not change the meaning of "solve this CNF."

This means:

- the host still loads one CNF image
- each core still runs the same core algorithm
- the top-level result aggregation stays simple
- shared-clause traffic must remain subordinate to solver correctness

See `docs/spec/satswarm_top.md`, `docs/spec/mesh_interconnect.md`, and `docs/spec/shared_clause_buffer.md`.

### 6. Host behavior should be simple and uniform

The host model is intentionally narrow:

- stream literals into the design
- assert start
- wait for done
- read SAT / UNSAT / cycles / status

All higher-level complexity belongs either in the solver fabric or in host-side scripts, not in a complex runtime protocol.

See `docs/spec/satswarm_core_bridge.md` and `docs/spec/cl_satswarm.md`.

---

## Major Blocks And Responsibilities

### `solver_core`

`solver_core` is the unit of search. It owns one CDCL search context and coordinates:

- decisions
- propagation
- conflict analysis
- backtracking
- received clause injection

Read `docs/spec/solver_core.md` first when reasoning about correctness.

### `satswarm_top`

`satswarm_top` composes the grid and defines the shared fabric:

- one `solver_core` per grid coordinate
- host CNF broadcast to all cores
- done / SAT / UNSAT aggregation
- mesh routing between cores
- shared clause fanout
- global memory arbitration

Read `docs/spec/satswarm_top.md`.

### NoC and sharing path

The multi-core design assumes clause sharing is selective and subordinate to local search progress. The interconnect is a transport mechanism, not the algorithm itself.

- `mesh_interconnect` provides topology-aware packet movement
- `interface_unit` packages clause traffic
- `shared_clause_buffer` supports shared-clause broadcast / buffering

Read `docs/spec/mesh_interconnect.md`, `docs/spec/interface_unit.md`, and `docs/spec/shared_clause_buffer.md`.

### Global memory infrastructure

The design keeps the memory side explicit:

- `global_mem_arbiter` serializes shared DDR access
- `global_allocator` assigns learned-clause address space

This separation matters because scaling pressure often comes from memory organization rather than pure control logic.

Read `docs/spec/global_mem_arbiter.md` and `docs/spec/global_allocator.md`.

### AWS shell boundary

The AWS-facing code should stay a boundary layer:

- `cl_satswarm` deals with HDK shell plumbing, resets, CDC, and shell-visible status
- `satswarm_core_bridge` exposes a solver-friendly view of control/load/status

Solver behavior should remain understandable without reading every line of shell glue. The authoritative Shell–CL interface spec is [AWS_Shell_Interface_Specification.md](../src/aws-fpga/hdk/docs/AWS_Shell_Interface_Specification.md). See [HDK.md](HDK.md) for the full HDK doc index.

Read `docs/spec/cl_satswarm.md` and `docs/spec/satswarm_core_bridge.md`.

---

## What "Correct" Means Here

A change is aligned with the design if it preserves these outcomes:

- A valid DIMACS stream loads the same logical problem into the solver.
- `SAT` means the produced assignment satisfies the clauses.
- `UNSAT` means the search has derived inconsistency at the root level.
- Clause learning and backtracking only strengthen or prune search; they do not corrupt the search state.
- Scaling to more cores changes performance characteristics, not problem semantics.

In practice, the main correctness risks are:

- trail / propagation disagreement
- missed or duplicated watched-literal updates
- bad learned clauses or wrong backtrack levels
- host / shell wiring that silently changes load or status behavior

---

## Design Reading Order

For future agents or contributors, this is the most efficient reading order:

1. `docs/spec/README.md`
2. `docs/spec/solver_core.md`
3. `docs/spec/satswarm_top.md`
4. `docs/spec/pse.md`
5. `docs/spec/cae.md`
6. `docs/spec/vde.md`
7. `docs/spec/cl_satswarm.md`
8. `docs/spec/satswarm_core_bridge.md`

Then use:

- `Verification.md` for how to test and debug
- `Synth.md` for synthesis / AFI creation
- `FPGA.md` for on-F2 use after an AFI already exists
- `Model.md` for converting measured data into scaling projections
