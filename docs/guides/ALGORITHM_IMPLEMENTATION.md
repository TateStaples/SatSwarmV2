# Algorithm Implementation Guide: CDCL SAT Solving in Hardware

A comprehensive technical deep-dive into the conflict-driven clause learning (CDCL) algorithm as implemented in SatSwarmv2, covering theory, practice, and hardware-specific optimizations.

---

## 1. Introduction to SAT Solving

### 1.1 The Boolean Satisfiability Problem

A Boolean formula in conjunctive normal form (CNF) consists of variables and clauses:
- **Variables**: $x_1, x_2, \ldots, x_n$ (Boolean: true or false)
- **Clauses**: Disjunctions (OR) of literals, e.g., $(x_1 \vee \neg x_2 \vee x_3)$
- **Formula**: Conjunction (AND) of clauses, e.g., $(x_1 \vee \neg x_2) \wedge (\neg x_1 \vee x_3) \wedge \ldots$

**Problem Statement**: Given a CNF formula, determine if there exists an assignment of variables such that all clauses evaluate to true. If yes, return a satisfying assignment; if no, prove unsatisfiability.

**Computational Complexity**: NP-complete (hardest decision problems in CS). Yet practical solvers solve millions-variable instances in seconds via clever heuristics.

### 1.2 From DPLL to CDCL

**DPLL (Davis-Putnam-Logemann-Loveland, 1960s)**:
1. Pick an unassigned variable
2. Assign it a truth value
3. Simplify formula (unit propagation)
4. Recurse until formula is empty (SAT) or contradiction (backtrack)

**CDCL (Conflict-Driven Clause Learning, 1996 Marques-Silva/Sakallah)**:
- Extends DPLL with **clause learning**: when a conflict occurs, analyze why and learn a new clause that prevents the same conflict
- **Backjumping**: Don't backtrack one level; jump to the highest level that avoids the conflict
- **Variable heuristics**: VSIDS dynamically prioritizes variables that cause recent conflicts

**Empirical Speedup**: 100–1000× on industrial instances vs. DPLL alone.

### 1.3 Why CDCL for Hardware?

**Advantages**:
- **Explicit finite-state machine**: CDCL's phases (BCP, learn, decide) map directly to hardware FSM states
- **Regular memory access**: Watch-list scheme enables efficient BRAM/DDR prefetching
- **Pipelineable**: Conflict analysis latency can be hidden with shift registers
- **Parallelizable**: Watched-literal scanning suits multi-cursor concurrent access

**Disadvantages**:
- **Memory-intensive**: Clause database requires external DDR4
- **Sequential bottleneck**: Strict FSM prevents full parallelism (trade-off: correctness vs. throughput)
- **Complex heuristics**: VSIDS heap and activity decay add resource overhead

---

## 2. CDCL Loop Architecture

### 2.1 The "Hardware CDCL" Loop
The solver operates in a strict **Serial Loop** to guarantee correctness, as mandated by the VeriSAT architectural specification. The three main engines—PSE, CAE, and VDE—hand off control explicitly. Concurrency exists *within* the PSE (via multiple cursors) but the macro-level loop is sequential.

1.  **PSE (Propagation Search Engine)**:
    *   State: **Active**
    *   Task: Consumes assignments, propagates implications until stable or conflict.
    *   Exit: `Done` (go to VDE) or `Conflict` (go to CAE).

2.  **CAE (Conflict Analysis Engine)**:
    *   State: **Active** (only after Conflict)
    *   Task: Analyzes conflict graph, learns clause, computes backtrack level.
    *   Intermediate States: `QUERY_CONFLICT_LEVELS` (preparing trail data) and `APPEND_LEARNED` (loading results into PSE).
    *   Exit: `Backtrack` (update state, return to PSE).

3.  **VDE (Variable Decision Engine)**:
    *   State: **Active** (only after PSE completion)
    *   Task: Selects next decision variable.
    *   Exit: `Decision` (pass to PSE).

### 2.2 Microarchitectural Safety: RESCAN REQUIRED
In a concurrent or high-throughput environment, the PSE may act on stale assignment data. The SatSwarmv2 implementation includes a `RESCAN REQUIRED` mechanism in `solver_core.sv`.
- **Trigger**: When a propagation targets a variable already assigned a different value, or when a broadcasted assignment arrives during an active scan.
- **Action**: The solver enters a `RESYNC_PSE` state, re-synchronizes the assignment state, and forces a full PSE rescan.
- **Guarantee**: Ensures that no conflict is missed due to race conditions or latency.

> **[!IMPORTANT] Strict Serialization**
> Any overlap between these phases (e.g. VDE running while PSE propagates) violates the CDCL state invariants and is strictly forbidden in the current design.

See `docs/FUTURE_OPTIMIZATIONS.md` for potential architectural enhancements like speculative execution.
        └──────────────────────────────┘
                        │
              ┌─────────┴─────────┐
              │  Backtrack Level? │
              │                   │
            <0           ≥0
              │           │
              ▼           ▼
           Return      Enqueue
           UNSAT      Decisions,
                      Restart(?)
                      Loop back
                      to PSE

### 2.3 Why Strict Alternation?

**Key Insight**: The CDCL algorithm relies on *confluence*—unit propagation produces the same result regardless of clause evaluation order. Parallelizing PSE/CAE/VDE risks:
- **Speculative decisions** that may become invalid due to learned clauses
- **Implication graph corruption** if decisions and propagations interleave unsafely
- **Memory consistency issues** without complex synchronization

**Hardware Benefit**: Alternation enables simple, determistic handshakes:
1. PSE runs to completion → outputs conflict or "all propagations done"
2. CAE runs (if needed) → outputs learned clause + backtrack level
3. VDE runs → outputs next decision variable + polarity
4. Loop repeats

**Correctness**: By construction, CDCL correctness properties hold trivially.

### 2.4 Termination Conditions

**SAT**: When PSE finds no more propagations and no conflict, all variables are assigned → return current assignment as witness.

**UNSAT**: When CAE computes backtrack level < 0, no clause can be satisfied → return UNSAT proof (learned clause is empty or unit from top level).

**Resource Exhaustion** (timeout, memory full): Abort with incomplete status (implementation-specific).

---

## 3. Boolean Constraint Propagation (PSE)

### 3.1 Watched-Literal Scheme

**Standard Approach**: For each variable, maintain occurrence lists (all clauses containing $x$ or $\neg x$). On assignment, scan all clauses—expensive.

**Watched-Literal Optimization**:
- Cache **exactly two literals per clause** (the "watched" literals)
- On variable assignment $v \leftarrow b$, only examine clauses where a watched literal becomes false
- If both watched literals remain possibly true → no action
- If one watched literal false, other true → clause satisfied (skip)
- If both watched literals false → impossible (conflict!) or find new watcher

**Hardware Advantage**: Watch lists are sparse, enabling efficient BRAM/DDR prefetching.

### 3.2 Unit Clause Detection

**Definition**: A clause is unit if exactly one literal is unassigned and all others are false.

**Detection in PSE**:
```
For each clause C with watched literals (w1, w2):
  eval_w1 = current_assignment[var(w1)] == polarity(w1)
  eval_w2 = current_assignment[var(w2)] == polarity(w2)
  
  if eval_w1 || eval_w2:
    clause_satisfied → skip
  else:
    scan literals in C for a non-false literal L
    if found L != both false → update watcher to L
    else → unit clause found! (or conflict if no watcher)
```

**Hardware Implementation** (in [pse.sv](src/Mega/pse.sv)):
- Fetch watched literals from clause table (cached, 1 cycle)
- Evaluate against variable assignment table (1 cycle, LUTRAM access)
- On false watched literal, scan clause literals from DDR (4 cycles with pipelining)
- Update clause watchers atomically (1 cycle write)

### 3.3 Conflict Detection

**Scenario**: All literals in a clause are false → clause is unsatisfied.

**Hardware Signal**: When scanning clause and all literals evaluated false → assert `conflict_detected`, pass clause index to CAE.

**Implication**: Current partial assignment leads to contradiction; CAE must analyze and backtrack.

### 3.4 Multi-Cursor Concurrent Scanning (Internal)

> **[!NOTE] Optimization Status**
> The VeriSAT paper describes a **Concurrent Propagation Engine** using multiple cursors. However, the current hardware implementation in `pse.sv` uses a **Single-Cursor** scanner for simplicity and verified correctness. Multi-cursor support is a planned future optimization for throughput.

**Design**: Instead of single sequential scanner, multiple cursors independently traverse watch lists.

**Architecture**:
```
┌─ Cursor 0 ─────────────────────────────┐
│ State: IDLE → INIT_SCAN → ... → DONE   │
│ Reads: Watch list, clause table, DDR   │
│ Outputs: Propagations or conflict      │
└────────────────────────────────────────┘

┌─ Cursor 1 ─────────────────────────────┐
│ (Same as Cursor 0)                      │
└────────────────────────────────────────┘

    ...

┌─ Cursor N (default N=4) ────────────────┐
│ (Same as Cursor 0)                      │
└────────────────────────────────────────┘

Shared Resources:
├─ Variable assignment table (multi-read BRAM)
├─ Clause table (multi-read BRAM, single write)
├─ Trail queue (single write)
└─ Literal store in DDR (multi-read via AXI4-Lite)
```

**Synchronization**: Arbiter prevents:
- **Read-After-Write hazards**: If cursor 0 writes assignment, cursor 1 may read stale value (stall cursor 1)
- **Clause write conflicts**: Multiple cursors may generate conflicting watcher updates (mux to serialize)

**Confluence Property**: Unit propagation is deterministic (any order yields same result). Multi-cursor exploit this: each cursor scans independent watch list in parallel, merging results is safe.

### 3.5 Performance Considerations

**Throughput**: Single cursor: ~1 clause checked per 2–3 cycles (BRAM + DDR latency). With 4 cursors: ~4 clauses per 2–3 cycles (3–4× speedup if DDR bandwidth available).

**Bottleneck**: DDR latency (4–6 cycles round-trip for literal fetch). Pipelining and prefetch can hide this.

**Heuristic**: **BerkMin's dynamic branching** (future enhancement): prioritize watch lists by recent conflict proximity.

---

## 4. Conflict Analysis & Learning (CAE)

### 4.1 First-UIP Clause Learning Algorithm

> **[!IMPORTANT] Current Implementation**
> The current `cae.sv` implements the **Full First-UIP Clause Learning** algorithm with resolution. It walks the implication graph (via the trail and reason clauses) to identify the closest Unique Implication Point to the conflict, ensuring higher-quality learned clauses.

**Goal**: When PSE detects conflict, analyze implication graph to produce new learned clause and backtrack level.

**Goal**: When PSE detects conflict, analyze implication graph to produce new learned clause and backtrack level.

**Implication Graph**:
- **Nodes**: Literals (variable assignments)
- **Edges**: If clause $(a \vee b \vee c)$ and $\neg b, \neg c$ are assigned, then $a$ was implied by this clause
- **Root nodes**: Decision assignments (no incoming edges)

**Algorithm (Simplified First-UIP)**:

```
Input: conflict_clause C (all literals false)
Output: learned_clause L, backtrack_level β

1. Initialize: L ← C, seen ← {}, level_count ← {}

2. While |literals in L assigned at current decision level| > 1:
     a. Pick a literal p in L from current decision level with reason clause D
     b. Remove p from L; add literals of D to L (excluding p)
     c. For each literal q in D ∩ L:
          - Mark seen[var(q)] ← true
          - If decision_level[var(q)] = current_level: level_count++

3. Return L as learned clause
   Backtrack level β = max decision level of literals in L \ {~p}
```

**Example Walkthrough**:

```
CNF: (x₁ ∨ x₂) ∧ (¬x₂ ∨ x₃) ∧ (¬x₁ ∨ x₄) ∧ (¬x₃ ∨ ¬x₄)

Decisions:
  Level 1: x₁ ← true (decision)
  Level 2: x₂ ← true (decision)
  Level 2: x₃ ← true (propagated by clause 2: ¬x₂ ∨ x₃)
  Level 2: x₄ ← true (propagated by clause 3: ¬x₁ ∨ x₄)
  
Conflict at Level 2: Clause 4 (¬x₃ ∨ ¬x₄) has both literals false.

Conflict Analysis:
  L ← {¬x₃, ¬x₄}
  
  Both ¬x₃ and ¬x₄ at level 2 → need to resolve one
  Reason for x₃: clause (¬x₂ ∨ x₃), resolve with L:
    L ← {¬x₂, ¬x₄}
  
  Only ¬x₄ at level 2 now → can stop
  Reason for x₄: clause (¬x₁ ∨ x₄), but x₁ at level 1
  
  Learned Clause: (x₂ ∨ x₄) [approximately; actual clause: ¬x₂ ∨ ¬x₄ with watcher update]
  Backtrack Level: 1 (highest level in learned clause excluding UIP)
```

### 4.2 First-UIP Definition

**Unique Implication Point (UIP)**: A variable that dominates all paths in the implication graph from the decision at current level to the conflict.

**First-UIP** (closest to conflict): The UIP nearest the conflict node in the DAG.

**Hardware Benefit**: Learned clauses with low literals (closer to root) enable larger backjumps and faster resolution.

### 4.3 Pipelined DDR Literal Fetching

**Challenge**: Literal store lives in external DDR4; each literal fetch ~4 cycles latency. If CAE waits synchronously, throughput collapses.

**Solution**: Pipelined fetch with delayed shift registers.

```
Cycle 0: Issue DDR read for literal[addr_0]
Cycle 1: Issue DDR read for literal[addr_1]; hold addr_0
Cycle 2: Issue DDR read for literal[addr_2]; latch data[addr_0]
Cycle 3: Issue DDR read for literal[addr_3]; latch data[addr_1]
Cycle 4: Latch data[addr_2]
         Now can process literal[addr_2] while issuing read[addr_4]

Shift Register Taps:
  shift_data[0] ← new DDR data (1 cycle old)
  shift_data[1] ← shift_data[0] (2 cycles old)
  shift_data[2] ← shift_data[1] (3 cycles old)
  shift_data[3] ← shift_data[2] (4 cycles old)
  
CAE logic selects tap based on which literal "matures" (valid):
  if addr == addr_3_cycles_ago:
    current_literal ← shift_data[3]  (4-cycle-old data, now valid)
```

**Hardware**: Shift register implemented as register chain (minimal area).

### 4.4 Learned Clause Minimization

**Observation**: Some literals in the learned clause may be redundant.

**Minimization Heuristic**: If literal $p$ in learned clause is implied by other literals at higher decision levels, remove $p$.

**Hardware Implementation** (simplified in current SatSwarmv2):
- Check if each literal's reason clause literals are also in learned clause
- If yes, can remove (with care for circular dependencies)
- Trade-off: full minimization is expensive; many solvers use heuristic approximation

**Current Status**: Inlined in CAE but not fully tested. See [src/Mega/cae.sv](src/Mega/cae.sv) for details.

### 4.5 Backtrack Level Computation

**Definition**: The second-highest decision level among literals in the learned clause (highest is the UIP, which becomes unit clause).

**Example**:
```
Learned clause: (x₁ ∨ ¬x₃ ∨ x₅)
  x₁ assigned at level 1
  x₃ assigned at level 3
  x₅ assigned at level 2

Backtrack level = 2 (second-highest)
After backtrack: only level 1 remains assigned, clause becomes unit in x₁
```

**Hardware**: Combinational logic compares decision levels—no latency penalty.

### 4.6 UNSAT Detection

**Condition**: Learned clause contains only the UIP at top decision level → empty clause learned → UNSAT.

**Hardware Signal**: `backtrack_level < 0` → propagate to solver_core, terminate with UNSAT result.

---

## 5. Variable Selection Heuristics (VDE)

### 5.1 VSIDS: Variable State Independent Decaying Sum

**Motivation**: Which variable should we branch on next? Naive choice: first unassigned variable → poor heuristic.

**VSIDS Insight** (Eén & Sörensson, 2003): 
- Prioritize variables that appeared in recent conflicts
- Decay priorities over time to avoid old conflicts dominating

**Scoring**:
- Activity score for each variable: `activity[v]` (32-bit)
- On conflict involving variable $v$: `activity[v] += 1000`
- Periodically decay all activities: `activity[v] -= activity[v] >> 16` (approximately 0.9275 factor)

**Why Decay?**: Allows solver to escape from local neighborhoods dominated by old conflicts and explore fresh parts of search space.

### 5.2 Fixed-Point Decay Implementation

**Mathematical Goal**: Multiply all activities by 0.9275 periodically.

**Hardware Efficient Approximation**: 
$$\text{activity}[v] \leftarrow \text{activity}[v] - (\text{activity}[v] >> 16)$$

**Justification**: $x - (x >> 16) \approx x \cdot (1 - 2^{-16}) = x \cdot 0.9999847...$

This is slightly different from 0.9275, but achieves similar effect (more frequent decay). Trade-off: exact factor vs. hardware simplicity (single shift → no multiplier needed).

**Hardware** (in [src/Mega/vde.sv](src/Mega/vde.sv)):
```systemverilog
always @(posedge clk) begin
    if (decay_en) begin
        for (int i = 0; i < VAR_MAX; i++)
            activity[i] <= activity[i] - (activity[i] >> 16);
    end
end
```

### 5.3 Variable Selection Strategy

> **[!IMPORTANT] Current Implementation**
> The current `vde.sv` uses a **Binary Min-Heap** (implemented in `vde_heap.sv`) to efficiently track variable activities. The `vde.sv` module acts as a wrapper that handles buffering for assignments, clears, and activity "bumps" to manage the heap's pipelined latency.

**Goal**: Extract variable with highest activity among unassigned variables.

**Target Data Structure**: Min-heap (binary tree where parent ≤ children).

**Goal**: Extract variable with highest activity among unassigned variables.

**Data Structure**: Min-heap (binary tree where parent ≤ children).

**Operations**:
- **Insert**: Add variable to bottom, percolate-up (O(log n))
- **Extract-Min**: Return root, promote bottom element, percolate-down (O(log n))
- **Decrease-Key**: Update priority, percolate-up (O(log n))

**Hardware Implementation**:
- Array-based heap (indices 0 to heap_size-1)
- Parent of index $i$: $(i-1)/2$
- Children of index $i$: $2i+1$, $2i+2$

**Percolate-up** (combinational):
```systemverilog
always @(*) begin
    idx = current_pos;
    while (idx > 0) begin
        parent_idx = (idx - 1) / 2;
        if (activity[idx] < activity[parent_idx]) begin
            swap(idx, parent_idx);
            idx = parent_idx;
        end else
            break;
    end
end
```

**Hardware**: Can be synthesized to iterative hardware or multi-cycle FSM. Current SatSwarmv2 uses FSM with ~log(VAR_MAX) cycles per operation.

### 5.4 Phase Saving & Restoration

**Observation**: When we backtrack and later re-decide variable $v$, assigning it the same polarity as before often leads to similar implication graph → better heuristic.

**Phase Array**: `phase[v]` ∈ {true, false} stores preferred polarity for variable $v$.

**Save Phase**: When $v$ is decided to value $b$, set `phase[v] ← b`.

**Restore Phase**: When $v$ is re-decided (after backtracking), prefer `phase[v]` as initial assignment.

**Hardware** (in [src/Mega/vde.sv](src/Mega/vde.sv)):
```systemverilog
always @(posedge clk) begin
    if (save_phase_en)
        phase[save_phase_var] <= save_phase_val;
end

assign decide_phase = phase[decide_var];  // combinational
```

### 5.5 Restart Heuristics

> **[!IMPORTANT] Current Implementation**
> The current `solver_core.sv` uses a **Fixed-Interval Restart** policy (triggering a restart every 1000 conflicts). While LBD-based adaptive policies are supported by the hardware's LBD computation, they are currently disabled to ensure stable convergence and prevent livelocks during the current development phase.

---

## 6. Memory Scheme & Data Structures

### 6.1 Clause Representation

**Format** (in clause table):
```
Clause Entry (128 bits):
├─ Watched Literal 1 (32 bits): variable + polarity
├─ Watched Literal 2 (32 bits): variable + polarity
├─ Clause Address in DDR (32 bits): pointer to literal list
├─ LBD (Literals Blocks Distance) (16 bits): heuristic for restart/deletion
├─ Learned Flag (1 bit): original clause vs. learned
├─ Deleted Flag (1 bit): marked for GC (future)
└─ Padding (14 bits)
```

**Literal List (in DDR literal store)**:
```
Sequential array of 32-bit words:
[lit_0, lit_1, ..., lit_{k-1}, 0]  ← null-terminated list
```

Where each literal is: `(variable << 1) | polarity`.

### 6.2 Variable State

**Format** (in variable table):
```
Variable Entry (96 bits):
├─ Current Assignment (2 bits): UNASSIGNED | TRUE | FALSE | RESERVED
├─ Decision Level (8 bits): 0–255 levels supported
├─ Reason Clause (32 bits): pointer to clause that implied this variable
│   (value 0 = decision variable, no reason)
├─ Phase (1 bit): preferred polarity (true/false)
├─ Bump Enable (1 bit): VSIDS bump requested from CAE
├─ Reserved (12 bits)
└─ Padding (?) for alignment
```

### 6.3 Trail: Implication History

**Purpose**: Track the order of assignments (decisions and propagations) and their decision levels.

**Structure**:
```
Trail FIFO (16K entries, on-chip LUTRAM):
  Entry i: {variable, assigned_value, decision_level, is_decision}

Example:
  [Level 0] (empty)
  [Level 1] x₁ ← true  (decision)
  [Level 1] x₂ ← false (propagated)
  [Level 2] x₃ ← true  (decision)
  [Level 2] x₄ ← false (propagated)
  [Level 2] x₅ ← true  (propagated)
  ...
```

**Access Pattern**:
- **Push** (PSE/VDE): Enqueue new assignment
- **Read** (CAE): Walk trail to find reason clauses
- **Pop** (backtrack): Remove assignments above decision level

### 6.4 On-Chip Storage Allocation

**BRAM/LUTRAM Budget** (Xilinx ZU9EG has 432 BRAM18K):

| Table | Size | Count | Type | Notes |
|-------|------|-------|------|-------|
| Clause Table | 262K × 128 bits | ~22 BRAM18K | BRAM | Watched lits cached |
| Variable Table | 16K × 96 bits | ~3 BRAM18K | BRAM | Per-var state |
| Trail Queue | 16K × 64 bits | ~3 BRAM18K | LUTRAM | FIFO structure |
| Activity Array | 16K × 32 bits | ~1 BRAM18K | LUTRAM | VSIDS scores |
| Phase Array | 16K × 1 bit | ~0.5 BRAM18K | LUTRAM | Phase hints |
| Misc (arbiter, control) | — | ~2 BRAM18K | — | Buffer/status regs |
| **Total** | — | **~32 BRAM18K** | — | ≈7% of device (feasible) |

### 6.5 External DDR4 Management

**Literal Store**:
- Sequential append: literals added at `next_ptr`, pointer incremented
- Reads: Random access via AXI4-Lite (latency ~4–6 cycles)
- Capacity: 1M literals × 32 bits = 4 MB (well within 2 GB available)

**Access Arbitration**:
- Multiple readers (PSE, CAE): queue requests, multiplex responses
- Single writer (PSE, CAE): append-only, atomic operations
- Stall mechanism: If reader's address matches pending write, stall reader

---

## 7. Algorithmic Trade-offs & Optimizations

### 7.1 Watched Literals vs. Occurrence Lists

| Aspect | Watched | Occurrence Lists |
|--------|---------|-------------------|
| Memory | 2 per clause (compact) | All occurrences (sparse list) |
| BCP Scan | Only false watches | All clauses with variable |
| Watcher Update | Fast (2 per clause) | Expensive (relink all) |
| FPGA Fit | Excellent | Good (if table large) |

**SatSwarmv2 Choice**: Watched literals (more efficient for hardware).

### 7.2 Resolution vs. Minimization Trade-off

**Full Resolution Loop** (MiniSat):
- Walk entire implication graph
- Recursively resolve clauses
- Produces minimal clause (sometimes)
- Cost: O(num_literals²) per conflict

**Minimization Heuristic** (SatAccel):
- Limited resolution depth
- Fast approximation
- Trade-off: may keep redundant literals
- Cost: O(num_literals) per conflict

**SatSwarmv2**: Hybrid (minimization is simplified, full resolution deferred).

### 7.3 Restart Policies

| Policy | Trigger | Effect |
|--------|---------|--------|
| **No Restart** | Never | Explores single tree branch; may timeout |
| **Fixed Interval** | Every N conflicts | Simple, predictable; may restart too soon |
| **Adaptive (LBD)** | When LBD > threshold | Targets actual search difficulty; more complex |
| **Luby Sequence** | Exponential backoff | Proven worst-case bounds; practical variant |

**SatSwarmv2 Status**: Basic fixed-interval trigger (every 1000 conflicts). LBD-based deferred.

### 7.4 Clause Deletion & Reduction

**Problem**: Learned clauses accumulate; eventually saturate memory.

**Solution**: Periodically delete clauses with high LBD (less useful) or low activity.

**SatSwarmv2 Status**: Append-only clause database (no deletion currently). Future enhancement: GC based on LBD + age.

### 7.5 LBD: Literals Blocks Distance

> **[!NOTE] Current Implementation**
> LBD computation is implemented in the interface unit but the generic restart policy based on LBD is currently **disabled** in `solver_core.sv` to prevent livelocks during debugging.

**Definition**: Number of distinct decision levels present in a clause.

**Definition**: Number of distinct decision levels present in a clause.

**Motivation**: Low LBD ↔ recent learning ↔ high-quality clause (likely to help).

**Hardware Computation**:
```
For clause (l₁, l₂, ..., lₖ):
  levels ← set of decision_level[var(lᵢ)] for i ∈ [1, k]
  LBD = |levels|
```

**SatSwarmv2 Implementation**: Computed in CAE during learning; used for restart heuristic (future).

---

## 8. Concrete Examples

### 8.1 Unit Propagation Walkthrough

**CNF**:
```
1. (x₁ ∨ x₂)
2. (¬x₂ ∨ x₃)
3. (¬x₃ ∨ ¬x₁)
4. (¬x₁)
```

**Execution**:
```
Decision: x₁ ← true (Level 1)
  PSE scans clause 4: (¬x₁)
    ¬x₁ is false (since x₁ = true)
    Only literal in clause → Unit clause!
    Enqueue: x₁ is already assigned (reason: clause 4)

Decision: Need next variable
  Try x₂ ← true (Level 2)
  PSE scans clause 2: (¬x₂ ∨ x₃)
    ¬x₂ is false (since x₂ = true)
    x₃ is unassigned → Find new watcher? Need to scan literal list
    But in this simplified example, let's assume ¬x₂ is second watched literal
    → Unit clause detected: x₃ must be true
    Enqueue propagation: x₃ ← true (reason: clause 2, decision level 2)

  PSE continues: Clause 3 (¬x₃ ∨ ¬x₁)
    x₃ = true → ¬x₃ is false (watched lit 1)
    x₁ = true → ¬x₁ is false (watched lit 2)
    Both watched literals false!
    → CONFLICT detected: clause 3 unsatisfiable
    Signal conflict to CAE, pass clause 3 index
```

### 8.2 Conflict Analysis & Backjump

Continuing above example:

```
Conflict at clause 3: (¬x₃ ∨ ¬x₁)
  Both literals false

CAE Analysis:
  L ← {¬x₃, ¬x₁}
  
  ¬x₃: assigned at Level 2 (reason: clause 2)
  ¬x₁: assigned at Level 1 (reason: decision)
  
  Both at different levels; resolve with reason of level 2 literal (¬x₃)
  Reason clause: (¬x₂ ∨ x₃)
  Resolve L with reason: Remove x₃, add (¬x₂)
  L ← {¬x₁, ¬x₂}
  
  ¬x₂ at Level 2 (decision)
  ¬x₁ at Level 1
  
  Only one at current level (2) → UIP found (¬x₂)
  
  Learned clause: (x₂ ∨ x₁)  [negation of {¬x₂, ¬x₁}]
  Backtrack level: 1 (highest non-UIP literal is ¬x₁)
  
Backtrack:
  Pop assignments from trail until Level 1:
    Remove x₃ ← true (propagated)
    Remove x₂ ← true (decision)
  
  Add learned clause 5: (x₂ ∨ x₁) to clause table
  Set x₁ as reason for this clause
  
Next Decision:
  VDE selects next unassigned variable (not x₂, since just backtracked)
  Could try x₃ with opposite phase
  
Propagate:
  Clause 5 (x₂ ∨ x₁) with x₁ = true → satisfied
  No new propagations
  
  Try x₃ ← false (decision)
  PSE checks all clauses with x₃:
    Clause 2: (¬x₂ ∨ x₃)
      x₃ = false → ¬x₂ must be true
      Unit clause: x₂ ← false (reason: clause 2)
    
    Clause 3: (¬x₃ ∨ ¬x₁)
      ¬x₃ = true (satisfied) ✓
  
  Continue...
```

---

## 9. Correctness Properties

### 9.1 DPLL/CDCL Soundness Invariants

**Invariant 1** (Sound Propagation): If a literal is propagated, it's consequence of formula + current assignments.

**Invariant 2** (No Conflicted Trail): Trail never contains both $x$ and $\neg x$ for any variable $x$.

**Invariant 3** (Learned Clauses Valid): Every learned clause is logical consequence of original formula (via resolution).

**Invariant 4** (Correct Backtrack Level): Backtrack level correctly points to decision level where conflict can be avoided.

### 9.2 Confluence Property

**Statement**: Unit propagation is deterministic—any order of propagations yields same final state.

**Implication**: Multi-cursor PSE can safely process independent watch lists in parallel; merging results preserves correctness.

### 9.3 Termination Guarantee

**Statement**: CDCL terminates (finds SAT or UNSAT) in finite time.

**Proof Sketch**:
1. Search space is finite (2^n possible assignments)
2. Backtracking always makes progress (learned clauses exclude visited parts)
3. Restart (if used) prevents infinite loops
4. Resource limits (timeout, memory) guarantee bounded execution

### 9.4 Hardware-Specific Correctness

**Arbitration Safety**: Fixed-priority arbiter ensures no data race on shared memory.

**FSM Correctness**: Explicit state machine matches CDCL semantics (no speculative transitions).

**Synchronization**: Handshakes between PSE/CAE/VDE prevent instruction reordering.

---

## 10. References

**Foundational Papers**:
- Davis, Putnam (1960): "A computing procedure for quantification theory." J. ACM.
- Davis, Logemann, Loveland (1962): "A machine program for theorem-proving." Comm. ACM.
- Marques-Silva, Sakallah (1999): "GRASP: A search algorithm for propositional satisfiability." IEEE Trans. Comput.

**Modern Heuristics**:
- Eén, Sörensson (2003): "An extensible SAT-solver." SAT Competition paper (VSIDS variant).
- Audemard, Simon (2009): "Predicting learnt clauses quality in modern SAT solvers." IJCAI.

**Hardware SAT**:
- SatSwarmv2.pdf (referenced in repo)
- SatAccel paper (UCLA-VAST)
- FPGA SAT surveys

**Related Systems**:
- MiniSat: http://minisat.se (reference implementation)
- CaDiCaL, CaDiCaL, Kissat: Modern competitive solvers
- SATCOMP/SATLIB benchmarks: https://www.satcompetition.org/

---

**For questions on algorithmic details**, refer to SatSwarmv2.pdf or consult the code in [src/Mega/](../src/Mega/).

**Last Updated**: January 2026
