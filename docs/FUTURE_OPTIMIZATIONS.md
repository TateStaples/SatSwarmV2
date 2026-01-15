# Future Optimizations & Research Directions

This document outlines potential architectural and algorithmic optimizations for the SatSwarmv2 solver. These ideas are separated from the core strict-serial correctness model to preserve stability while enabling future performance exploration.

## 1. Architectural Optimizations

### 1.1 Speculative Variable Decision (Speculative VDE)
**Concept**: The strict serial loop (`PSE` → `VDE`) leaves the VDE idle while PSE is running.
**Idea**: Allow VDE to "speculatively" select the next decision variable *during* the PSE phase.
- If PSE completes without conflict: VDE has the decision ready immediately (0 cycle latency).
- If PSE detects conflict: VDE result is discarded (or used to update heuristics).
**Correctness**: Safe because VDE is read-only regarding assignment state (mostly). Must handle "hide/unhide" carefully if PSE assigns the speculative variable.

### 1.2 Multi-Cursor Propagation (Internal Parallelism)
**Concept**: As described in the `VeriSAT` paper, the PSE can use multiple cursors to scan independent watch lists in parallel.
**Current State**: Single-cursor implementation.
**Optimization**: Implement `N=4` cursors with a shared dispatcher.
- **Benefit**: Saturates DDR4 bandwidth, 3-4x speedup on Propagation.
- **Challenge**: Requires robust read/write arbitration for the assignment table (handled by atomic "Test-and-Set" or arbitration logic).

### 2.1 Pipelined Conflict Analysis
**Concept**: `CAE` currently processes literals sequentially/pipelined.
**Idea**: If we cache "Reason Clauses" in BRAM (for recent depth) instead of fetching all from DDR, we can speed up resolution.
- **Level 2 Cache**: Store small reason clauses in local BRAM.

## 2. Algorithmic Optimizations

### 2.1 Full LBD-Based Restarts
**Concept**: Use "Literals Blocks Distance" (LBD) to measure clause quality.
**Idea**:
- Compute LBD for every learned clause.
- Maintain a running average (`global_lbd`).
- If `recent_average_lbd > K * global_lbd`: Trigger Restart.
**Benefit**: Prevents solver from getting stuck in "hard" regions of the search space.

### 2.2 Advanced VDE Heuristics
**Current**: VSIDS (Variable State Independent Decaying Sum) via Binary Min-Heap.
**Idea**: **CHB (Conflict History Based)** or **LRB (Learning Rate Based)** heuristics.
- These modern heuristics (used in MapleSAT) reward variables based on their participation in *recent* conflict generation, not just counting.

### 2.3 Glue Clauses (Clause Deletion)
**Concept**: The clause database grows indefinitely.
**Idea**: Delete "useless" learned clauses periodically.
- **Metric**: Delete clauses with high LBD (> 5) that are not "Glue Clauses" (LBD=2).
- **Benefit**: Reduces memory usage and cache pollution.

### 2.4 Clause Minimization (Deep)
**Current**: Simplified minimization (subset check).
**Idea**: **Recursive Minimization**.
- If literal `p` is implied by `q`, and `q` is already in the learned clause, `p` can be removed.
- Recursively check reason graph.
- **Trade-off**: High compute cost vs. better clauses.

## 3. Hardware Optimizations

### 3.1 Burst Memory Access
**Concept**: Literals are fetched one-by-one.
**Idea**: Organize literals in DDR so that entire cache lines (64 bytes = 16 literals) are fetched in a burst.
- Requires: Aligning clauses in memory, custom memory allocator.

### 3.2 Dual-Port Trail Memory
**Concept**: Allow simultaneous access to Trail by PSE (push) and VDE (check).
- currently restricted by single arbiter.

---
*Note: Any implementation of these optimizations must undergo rigorous formal verification to ensure it does not violate the core CDCL correctness invariants.*
