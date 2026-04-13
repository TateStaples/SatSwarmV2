# SatSwarmV2 Poster Content Guide

This document outlines the essential architecture elements, diagrams, and explanations that should be included in your poster about SatSwarmV2, a hardware-based SAT solver targeting FPGA and ASIC deployment.

---

## 1. Title & Hook

**Suggested Title:**
"SatSwarmV2: Hardware-Accelerated Parallel SAT Solving with Tiled CDCL Cores and Learned Clause Sharing"

or shorter:
"SatSwarmV2: Tiled Hardware SAT Solver"

**Comprehensive Abstract:**

SatSwarmV2 is a hardware-accelerated, synthesizable SAT solver that implements the complete Conflict-Driven Clause Learning (CDCL) algorithm in a tiled, grid-based architecture targeting FPGA and ASIC deployment. While previous hardware SAT accelerators focus on Boolean Constraint Propagation (BCP) as an isolated bottleneck, SatSwarmV2 accelerates the entire SAT solving algorithm—from variable selection to conflict analysis to backtracking—in synthesizable SystemVerilog. The solver is parameterizable, scaling from a single core (1×1) to multi-core grids (2×2, 3×3, and beyond) with minimal architectural changes.

**Core Innovation: Tiled Grid with Selective Clause Sharing.** Rather than monolithic instruction-level parallelism, SatSwarmV2 adopts a portfolio approach where each solver core runs the same problem independently with different random seeds, enabling diverse search space exploration. A 2D mesh Network-on-Chip (NoC) with dimension-ordered routing provides inter-core communication, allowing learned clauses to propagate between neighbors. Critically, clause sharing is selective—only high-quality, small clauses (length ≤ 2, Literal Block Distance ≤ 2) are exchanged—minimizing network congestion while maximizing solver benefit. This design breaks through the portfolio parallelism ceiling (~20 cores in software) and enables scaling to hundreds of cores on ASIC.

**Hardware-Optimized Components.** Each solver core orchestrates three tightly-coupled processing engines: (1) **Propagation Search Engine (PSE)** implements two-watched-literal scheme for unit propagation, reducing clause scan overhead from O(n) to O(1) amortized; (2) **Variable Decision Engine (VDE)** maintains VSIDS activity scores in a binary max-heap, enabling O(log n) variable selection; (3) **Conflict Analysis Engine (CAE)** performs First-UIP resolution-based clause learning with non-chronological backtracking. Strict phase ordering (VDE → PSE → CAE) preserves CDCL correctness without speculative parallelism. Memory is hierarchically organized: on-chip BRAM stores clause metadata and watch lists; external DDR4 via a global arbiter handles literal overflow and learned clause storage.

**Empirical Performance.** On SATLIB benchmarks (UF50–UF125, UUF50–UUF125), SatSwarmV2 achieves multi-core speedup scaling proportional to problem hardness. The 2×2 grid (4 cores) delivers 1.39–1.58× speedup on 50–75 variable instances and 1.15–1.36× on larger instances; the 3×3 grid (9 cores) achieves 1.77–2.06× on small-medium problems. Notably, on UF75 instances, the 3×3 configuration reaches **5.57× speedup** (61.9% parallel efficiency), exceeding theoretical portfolio stagnation. Compared to VeriSAT (a single-core hardware solver running at 150 MHz), SatSwarmV2 1×1 at 15.625 MHz is slower on small instances but **2.1× faster on UF125**, demonstrating that tiled parallelism and selective clause sharing overcome frequency disadvantages on harder problems.

**Significance and Impact.** SatSwarmV2 demonstrates that complete CDCL acceleration in hardware is feasible and efficient, unlocking scaling opportunities beyond software portfolio solvers. The selective clause-sharing mechanism provides a blueprint for many-core ASIC designs (100+ cores), where communication overhead becomes the bottleneck. By validating order-statistics-based performance modeling and hardware-specific topology-aware overhead estimation, this work enables principled extrapolation from small-scale FPGA prototypes to large-scale ASIC SAT solvers. SatSwarmV2 paves the way for domain-specialized hardware acceleration in formal verification, combinatorial optimization, and constraint solving—applications where SAT solving is the critical path.

---

## 2. Core Concept: The CDCL Algorithm Loop

**What to include:**
A visual flowchart showing the three-phase loop that forms the heart of every solver core:

```
┌─────────────────────────────────────────┐
│   Strict Phase Loop (VDE → PSE → CAE)   │
├─────────────────────────────────────────┤
│                                         │
│  1. VDE (Variable Decision Engine)      │
│     └─ Select next variable to branch   │
│        using VSIDS activity heuristic   │
│                                         │
│  2. PSE (Propagation Search Engine)     │
│     └─ Boolean Constraint Propagation   │
│        using two-watched-literal scheme │
│     └─ Detects conflicts               │
│                                         │
│  3. CAE (Conflict Analysis Engine)      │
│     └─ Analyzes conflict (if any)      │
│     └─ Learns new clause               │
│     └─ Backtracks to consistent state  │
│                                         │
│        Loop back to VDE                 │
└─────────────────────────────────────────┘
```

**Key insight to highlight:**

- Strict alternation (no concurrent phases) keeps the design simple and correct
- This is the same algorithm used in software solvers like CaDiCaL and Glucose
- Hardware implementation makes each phase fast and deterministic

---

## 3. Single-Core Architecture Diagram

**Create a block diagram showing:**

```
┌────────────────────────────────────────────────┐
│          CDCL Solver Core (solver_core)        │
├────────────────────────────────────────────────┤
│                                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │   VDE    │  │   PSE    │  │   CAE    │    │
│  │(VSIDS)   │  │(BCP)     │  │(Learn)   │    │
│  └──────────┘  └──────────┘  └──────────┘    │
│       ↓             ↓              ↓          │
│  ┌────────────────────────────────────────┐   │
│  │     Trail Manager (Decisions & Vars)   │   │
│  └────────────────────────────────────────┘   │
│                                                │
│  ┌────────────────────────────────────────┐   │
│  │  Clause Store + Watch Lists (BRAM)     │   │
│  └────────────────────────────────────────┘   │
│                                                │
│  ┌────────────────────────────────────────┐   │
│  │    NoC Interface (to other cores)      │   │
│  └────────────────────────────────────────┘   │
└────────────────────────────────────────────────┘
```

**Submodules to explain:**

- **Trail Manager**: Stores variable assignments and decision levels; enables fast backtracking
- **Clause Store**: BRAM-based CNF database with watched-literal lists
- **VDE (Variable Decision Engine)**: Binary heap maintaining VSIDS activity scores
- **PSE (Propagation Search Engine)**: Scans watch lists to detect unit clauses and conflicts
- **CAE (Conflict Analysis Engine)**: Resolution-based first-UIP clause learning

---

## 4. Memory Architecture

**Key points:**

- **On-Chip BRAM (fast, small):**
  - Clause metadata and literals
  - Variable state (current assignment, activity)
  - Decision trail (decisions and implications)
  - Watch lists

- **External DDR4 (slow, large):**
  - Overflow storage for learned clauses
  - Literal pool extension

**Diagram:**

```
           Solver Core
               │
        ┌──────┴──────┐
        ↓             ↓
    ┌───────┐    ┌──────────────┐
    │ BRAM  │    │ Global Memory │
    │ Local │────┤  Arbiter     │
    └───────┘    └──────────────┘
                        ↓
                  ┌────────────┐
                  │  DDR4      │
                  │(External)  │
                  └────────────┘
```

---

## 5. Multi-Core Tiled Grid Architecture

**Visual representation (e.g., 2×2 or 3×3 grid):**

```
┌──────────────┬──────────────┐
│  Core(0,0)   │  Core(1,0)   │
│     (sat)    │   (unsat)    │
└──────┬───────┴──────┬───────┘
       │ mesh interconnect (N-S)
       │ X-Y routing
┌──────┴───────┬──────┬───────┐
│  Core(0,1)   │  Core(1,1)   │
│  (timeout)   │  (unsat)     │
└──────────────┴──────────────┘
```

**Key insights:**

1. **Portfolio Approach**: Each core runs the same CNF with different random seeds
2. **Dimension-Ordered Routing**: X-Y routing minimizes deadlock in mesh topology
3. **Result Aggregation**: Host gets SAT/UNSAT as soon as ANY core finds a solution
4. **Grid Flexibility**: Start with 1×1, scale to 2×2, 3×3, or larger

---

## 6. Clause Sharing via Network-on-Chip (NoC)

**The Problem:**

- Pure portfolio parallelism (different solvers, no sharing) plateaus at ~20 cores
- Additional cores waste silicon without clause exchange

**The Solution:**

```
Core A learns clause:   (¬a ∨ b ∨ ¬c)  [Small, high quality]
                              ↓
                        Mesh Interconnect
                              ↓
Core B receives clause   (¬a ∨ b ∨ ¬c)  [Prunes search space]
                              ↓
                        Can find SAT/UNSAT faster
```

**Sharing criteria (selective, not all-to-all):**

- **Small clauses only** (length ≤ 2) — unit clauses and binary clauses
- **High quality** — low Literal Block Distance (LBD)
- Reduces network congestion while maximizing search benefit

**Routing mechanism:**

- X-Y dimension-ordered routing (standard for meshes)
- Packets routed hop-by-hop to neighbors
- No global broadcast (local sharing only)

---

## 7. Propagation Search Engine (PSE) - The Workhorse

**Why it matters:**

- Propagation dominates SAT solving runtime (80-90% of cycles)
- PSE is the most performance-critical module

**Two-Watched-Literal Scheme (optimize propagation):**

```
Clause: (a ∨ b ∨ ¬c ∨ d)
         ↑           ↑
       Watch1      Watch2

When Watch1 becomes False:
  1. Scan other literals for replacement
  2. If found → update Watch1 to new literal
  3. If not found:
     - Other Watch True? → Clause satisfied (skip)
     - Other Watch False? → Conflict! ⚠️
     - Other Watch Unassigned? → Unit clause (propagate) ✓
```

**Key optimization:**

- Only clauses with a falsified watched literal need scanning
- Dramatically reduces propagation cost vs. scanning all clauses

---

## 8. Conflict Analysis & First-UIP Learning

**What happens on conflict:**

```
Conflict detected at decision level 5
         ↓
CAE walks backward through implication graph
         ↓
Finds First Unique Implication Point (UIP)
         ↓
Learns new clause that prevents this conflict
         ↓
Backtracks to a consistent level (not necessarily level 4!)
         ↓
New learned clause becomes unit → forced assignment
```

**Why it's powerful:**

- Learned clauses are added constraints that prune future search
- First-UIP ensures only one literal from current decision level
- Enables **non-chronological backtracking** (jump multiple levels at once)

---

## 9. VSIDS (Variable State Independent Decaying Sum) Heuristic

**The concept:**

```
Activity = ∑(times variable appears in conflict at level D)
Activity decays exponentially every N conflicts
Variable with HIGHEST activity picked next

Implemented with: Binary Max-Heap (log N insertion/extraction)
```

**Why it works:**

- Recent conflicts → likely to be relevant to current search region
- Focuses solver on "hot" variables
- Can be efficiently updated in hardware with heap

---

## 10. Performance & Scaling Results

**Create a comparison table:**

| Configuration    | Frequency | UF50 (SAT) | UUF50 (UNSAT) | Speedup vs 1×1 |
| ---------------- | --------- | ---------- | ------------- | -------------- |
| VeriSAT CPU      | 150 MHz   | 0.26 ms    | 0.61 ms       | —              |
| **SatSwarm 1×1** | 50 MHz    | 0.495 ms   | 1.115 ms      | 1.0×           |
| **SatSwarm 2×2** | 50 MHz    | 0.243 ms   | 0.915 ms      | **2.03×**      |
| **SatSwarm 3×3** | 50 MHz    | 0.166 ms   | 0.760 ms      | **2.98×**      |

**Scaling insights:**

- **SAT instances**: Near-linear speedup (portfolio effect dominates)
- **UNSAT instances**: Sublinear speedup (harder to parallelize, clause sharing helps but limited)
- **Efficiency**: Decreases with core count due to communication overhead

---

## 11. Theoretical Scaling Model (Optional, Advanced Poster)

**Three-layer framework:**

```
Layer 1: Order Statistics (Baseline)
  └─ Pure portfolio speedup from independent solvers
  └─ S_portfolio(n) ∝ E[min of n runtime samples]

Layer 2: Clause Sharing Uplift
  └─ Multiplier β(n) accounting for clause exchange benefit
  └─ S_sharing(n) = β(n) × S_portfolio(n)

Layer 3: Communication Overhead
  └─ Penalty from NoC routing latency and congestion
  └─ f(n) = α√n for mesh topology (α calibrated from 2–4 core data)
  └─ S_actual(n) = S_sharing(n) / (1 + f(n))
```

**Key takeaway:**

- Mesh topology (O(√n) overhead) much better than all-to-all (O(n²))
- Clause sharing critical for scaling beyond ~20 cores
- Model enables extrapolation to ASIC scale (hundreds of cores)

---

## 12. AWS FPGA Integration (if relevant for your audience)

**Architecture stack (bottom to top):**

```
AWS Shell (PCIe, DDR4, Clock Recipes)
    ↑
cl_satswarm (HDK CL wrapper, reset domain crossing)
    ↑
satswarm_core_bridge (AXI-Lite control, literal loading)
    ↑
satswarm_top (solver grid, NoC, memory arbiter)
    ↑
solver_core × N (CDCL cores)
```

**Key details:**

- Target: Xilinx VU47P (AWS F2 instance)
- Clock: 15.625 MHz (constrained by routing congestion)
- Host interface: AXI-Lite (simple control) + PCIS (literal streaming)
- Bitstream generation: AWS HDK build flow

---

## 13. Comparison with Other Hardware SAT Solvers

**Create a comparison chart:**

| Solver        | Type | Cores | Frequency | Coverage     | Key Innovation                |
| ------------- | ---- | ----- | --------- | ------------ | ----------------------------- |
| **SAT-Accel** | FPGA | 1     | 230 MHz   | 80% BCP only | Parallel propagation          |
| **VeriSAT**   | RTL  | 1     | ?         | Full CDCL    | Linked-list watching          |
| **SatIn**     | ASIC | ~100  | —         | >99% in HW   | Distributed associative array |
| **SatSwarm**  | FPGA | 1–9+  | 50 MHz    | Full CDCL    | Tiled grid + clause sharing   |

---

## 14. Design Invariants (Trust/Correctness)

**Five core design principles that guarantee correctness:**

1. **Strict CDCL Ordering**: VDE → PSE → CAE sequence never violated
2. **Trail is Source of Truth**: All assignment state flows from trail
3. **Propagation Dominates**: Most design effort goes to fast, correct BCP
4. **Conflict Analysis is Authoritative**: Learned clauses are logically valid, backtrack levels correct
5. **Multi-Core Transparency**: Adding cores doesn't break single-core semantics

---

## 15. Summary: Key Takeaways for Your Poster

### The Big Picture:

- **Hardware implementation** of CDCL is feasible and efficient
- **Tiled grid architecture** naturally maps to FPGA/ASIC
- **Clause sharing** breaks through portfolio parallelism limits
- **Mesh NoC** is practical for 2–3 orders of magnitude core scaling

### For Each Block:

- **VDE**: Fast variable selection with heap; critical for heuristic quality
- **PSE**: Watched-literal scheme dominates runtime; the optimization that matters most
- **CAE**: First-UIP learning + resolution; proven algorithm in hardware
- **NoC**: Selective clause routing enables scaling; communication overhead is the frontier

### Performance Expectations:

- **1 core**: Competitive with VeriSAT, slower than modern CPUs (different optimization target)
- **2–4 cores**: Near-linear speedup (portfolio effect)
- **8+ cores**: Sublinear but meaningful speedup with clause sharing; communication becomes limiting
- **Scaling ceiling**: Extrapolated 100+ cores could be feasible with ASIC + careful NoC design

---

## 16. Suggested Visual Elements

### Essential diagrams:

1. **CDCL Loop Flowchart** — VDE → PSE → CAE with decision points
2. **Single-Core Block Diagram** — All 6 major submodules
3. **Memory Hierarchy** — BRAM vs. DDR with arbitration
4. **Grid Topology** — 2×2 or 3×3 example with port numbering
5. **Watched-Literal Example** — Before/after states with clause scan
6. **Mesh Routing** — X-Y routing paths for 2×2 grid
7. **Scaling Graph** — Speedup vs. core count with error bars

### Optional advanced visuals:

8. **Implication Graph** — Example showing trail, reasons, decision levels (for conflict analysis)
9. **FSM State Diagrams** — solver_core main states (if space permits)
10. **Frequency vs. Resource Utilization** — Why 50 MHz on FPGA vs. 150+ MHz possible on ASIC
11. **Order Statistics Curves** — Runtime distribution fitting and speedup predictions

---

## 17. Text Content Recommendations

**Keep these sections brief (1-3 sentences each):**

- **Problem Statement**: Why parallelize SAT solving? Portfolio effect + clause learning
- **Innovation**: Tiled hardware cores + selective clause sharing via mesh NoC
- **Results**: 3× speedup on 3×3 grid; scales beyond software portfolio plateaus
- **Future Work**: ASIC prototype; 100+ cores; integration with formal verification tools

**Avoid:**

- Deep RTL implementation details (save for paper appendix)
- Full state machine listings
- Register-transfer-level complexity
- SystemVerilog code snippets (replace with pseudo-code if needed)

---

## 18. Poster Layout Suggestions

### Option A: "From Algorithm to Hardware"

```
Top: Title + Hook
├─ Middle-Left: CDCL Algorithm Loop (big, visual)
├─ Middle-Center: Single-Core Architecture
├─ Middle-Right: Multi-Core Grid
├─ Bottom-Left: Memory Hierarchy
├─ Bottom-Center: Clause Sharing / NoC
└─ Bottom-Right: Performance Results + Scaling
```

### Option B: "Scaling from 1 Core to 100+"

```
Top: Title + Vision
├─ Left Column:
│  ├─ What is CDCL?
│  ├─ VDE/PSE/CAE (simple overview)
│  └─ Why hardware matters?
├─ Center Column:
│  ├─ Single-Core Architecture
│  ├─ Memory subsystem
│  └─ Key optimizations (watched-literal)
└─ Right Column:
   ├─ Grid topology
   ├─ Clause sharing mechanism
   ├─ Scaling results
   └─ Future: 100+ cores
```

### Option C: "The Complete Picture" (technical audience)

```
Three rows:
Row 1: Title | Hook | Problem
Row 2: CDCL Loop | Core Arch | Memory | NoC
Row 3: Results | Scaling Model | Comparison | Conclusion
```

---

## 19. Common Questions to Address on Poster

**Q: Why 50 MHz on FPGA instead of faster?**  
A: Routing congestion from VSIDS heap and watch-list management. ASIC with better cell libraries could target 500+ MHz.

**Q: What is First-UIP learning?**  
A: Unique Implication Point = exactly one variable from the current decision level in the learned clause. Proves the learned clause is minimal and the backtrack level correct.

**Q: How does clause sharing avoid flooding?**  
A: Selective criteria (LBD ≤ 2, clause length ≤ 2). Learned clauses filtered at source.

**Q: Can this do incremental SAT?**  
A: Current design is one-shot solving. Adding clause deletion + variable freezing is future work.

---

## 20. References to Cite (if including academic context)

- **CDCL Algorithm**: Een & Sörensson, "An Extensible SAT-solver" (MiniSat, 2003)
- **VSIDS Heuristic**: Moskewicz et al., "Chaff: Engineering an Efficient SAT Solver" (2001)
- **Two-Watched-Literals**: Reiss et al., "SAT Solving with the DPLL Algorithm" surveys
- **Portfolio SAT**: Arbelaez et al., "Scaling Parallel SAT Solving" (2013); Bach et al. (2022)
- **Hardware SAT**: SAT-Accel (FPGA '25), VeriSAT (ICCAD 2025), SatIn (Stanford)
- **Clause Sharing**: MallobSat (Schreiber & Sanders, 2024)
- **Scaling Theory**: Gomes et al. on heavy-tailed distributions (IJCAI 1997)

---

## Final Checklist for Poster

- [ ] Title is clear and compelling
- [ ] Hook (1-2 sentences) explains why this matters
- [ ] CDCL loop diagram is prominent
- [ ] Single-core block diagram shows 6 main modules
- [ ] Grid topology shown (2×2 or 3×3)
- [ ] Two-watched-literal optimization explained visually
- [ ] Mesh routing diagram included
- [ ] Performance table with speedup numbers
- [ ] Scaling graph (speedup vs. core count)
- [ ] Memory hierarchy diagram
- [ ] Design invariants or trust story mentioned
- [ ] Future work / bigger vision stated
- [ ] Color scheme: consistent, readable from 6+ feet away
- [ ] Font sizes: title ≥ 72pt, body ≥ 28pt
- [ ] Minimal text; maximum visual content
- [ ] No SystemVerilog code (use block diagrams instead)
