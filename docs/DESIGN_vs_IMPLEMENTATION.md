# Design vs Implementation Analysis

This document catalogs the discrepancies between the architectural specification (as described in `ALGORITHM_IMPLEMENTATION.md` and `vde_heap_spec.md`) and the current SystemVerilog implementation in `src/Mega/`.

## 1. Variable Decision Engine (VDE)

| Feature | Specification (`vde_heap_spec.md`) | Current Implementation (`vde.sv`) | Deviation Status |
| :--- | :--- | :--- | :--- |
| **Data Structure** | Binary Min-Heap | Linear Scan Array | **CRITICAL** |
| **Complexity** | O(log N) for Decision & Update | O(N) Linear Scan | **CRITICAL** |
| **Activity Decay** | Global resize / increment | O(N) Iterative Subtraction | **Inefficient** |
| **Activity Init** | Zero / Random | Deterministic Hash (Swarm Divergence) | **Intentional** |

**Impact**: The O(N) linear scan in `vde.sv` will cause significant performance degradation as `MAX_VARS` increases. This is the primary bottleneck for scaling the solver.

## 2. Propagation Search Engine (PSE)

| Feature | Specification (`ALGORITHM_IMPLEMENTATION.md`) | Current Implementation (`pse.sv`) | Deviation Status |
| :--- | :--- | :--- | :--- |
| **Parallelism** | Multi-Cursor (4 concurrent scanners) | Single-Cursor (Sequential FSM) | **Major** |
| **Memory Access** | Shared Memory Arbiter / Pipelined DDR | Local BRAM / Register Arrays | **Simplified** |
| **Restart Policy** | LBD-based (Literals Blocks Distance) | Disabled / Manual Threshold | **Missing** |

**Impact**: The absence of multi-cursor scanning limits the BCP throughput. The current single-cursor implementation is functional but does not leverage the FPGA's potential for parallelism.

## 3. Conflict Analysis Engine (CAE)

| Feature | Specification (`ALGORITHM_IMPLEMENTATION.md`) | Current Implementation (`cae.sv`) | Deviation Status |
| :--- | :--- | :--- | :--- |
| **Algorithm** | First-UIP with Resolution (Implication Graph) | Conflict Clause Minimization / Pass-Through | **CRITICAL** |
| **Learning** | Derives new clause from resolution | Re-uses conflict clause (subsetting literals) | **Soundness Risk** |
| **Memory** | Read Reason Clauses from Trail | No access to Reason Clauses | **Limitation** |

**Impact**: 
1.  **Soundness**: `cae.sv` claims to implement "Simplified First-UIP", but without access to reason clauses, it cannot perform resolution. It appears to essentially perform a "Backjump" based on the conflict clause itself, which is valid for backtracking but weak for *learning*.
2.  **Convergence**: Without true clause learning (creating new implications), the solver reduces to a fancy backtracker and may not converge on hard instances.

## 4. Architectural Control

| Feature | Specification | Current Implementation | Deviation Status |
| :--- | :--- | :--- | :--- |
| **Loop Control** | PSE -> Conflict? -> CAE -> VDE | `solver_core.sv` orchestrates everything including `QUERY_CONFLICT_LEVELS` | **Evolved** |
| **DDR Interface** | External DDR4 for Clauses | On-chip BRAM (implied by array sizes) | **Scale Limit** |

**Impact**: The current design assumes all clauses and variables fit in BRAM (`MAX_CLAUSES=256`, `MAX_VARS=256`). This restricts the problem size significantly compared to a DDR-backed design.

## Recommendations

1.  **VDE**: Prioritize implementing the Binary Heap (`vde_heap_spec.md`) as the linear scan is O(N).
2.  **CAE**: Implement true First-UIP resolution. This requires `cae.sv` to read the Trail and Reason Clauses to resolve the conflict.
3.  **PSE**: Multi-cursor support can be deferred until correctness and VDE efficiency are solved.
