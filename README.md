# SatSwarmv2: Hardware SAT Solver for FPGA

**A high-performance, hardware-optimized SAT solver implementation in SystemVerilog targeting the Xilinx VU47P FPGA (AWS F2 instance).**

SatSwarmV2 implements the conflict-driven clause learning (CDCL) algorithm—the foundation of modern SAT solvers—directly in synthesizable hardware. It uses three alternating processing stages (Propagation, Conflict Analysis, Variable Decision) to efficiently solve Boolean satisfiability problems.

---

## Quick Facts

| Aspect | Value |
|--------|-------|
| **Target Platform** | Xilinx VU47P (AWS F2 Instance) |
| **Solver Clock** | 15.625 MHz (Clock Recipe A2) |
| **Max Variables** | 256 |
| **Max Clauses** | 4,096 |
| **Max Literals** | 65,536 |
| **Target Clause Length** | 32 |
| **Primary Base Language** | SystemVerilog |
| **Toolchain** | Vivado 2025.2, AWS HDK v2.3.0 |
| **Simulation** | Verilator 5.044 |

---

## Repository Structure

- **`src/Mega/`** — Core RTL solver implementation (all SystemVerilog)
- **`src/Mini/`** — Simplified solver for development/debugging
- **`sim/`** — Verilator-based simulation (see [Verification.md](Verification.md))
- **`hdk_cl_satswarm/`** — **AWS HDK wrapper, Git-tracked**
  - Contains: design (RTL), verif (tests), build/ (synthesis scripts), host/ (C code)
  - Files are copied from/symlinked to `$HDK_DIR/cl/examples/cl_satswarm/` during setup
- **`tools/`** — CUDD (BDD library), OpenSTA (unversioned build tools)
- **`resource_estimation/`** — Area/timing analysis
- **`docs/`** — Design specs, meeting notes, reference materials
- **`deploy/`** — Deployment scripts (FPGA image generation, runtime setup)

### RTL Hierarchy (`src/Mega/`)

```
satswarm_top
  └── solver_core  (one per grid cell, parameterized GRID_X × GRID_Y)
        ├── cae.sv              — Conflict Analysis Engine (First-UIP learning)
        ├── pse.sv              — Propagation Search Engine (BCP / unit propagation)
        ├── vde.sv              — Variable Decision Engine (VSIDS heuristic wrapper)
        │     └── vde_heap.sv   — Binary max-heap for O(log N) variable selection
        ├── trail_manager.sv    — Decision/implication trail storage
        ├── clause_store.sv     — Clause database (watch lists, learned clause storage)
        ├── watch_manager.sv    — Two-watched-literal scheme
        └── shared_clause_buffer.sv
  ├── mesh_interconnect.sv      — Inter-core learned clause sharing
  ├── global_allocator.sv       — Shared clause ID allocation
  ├── global_mem_arbiter.sv     — DDR4 access arbiter
  ├── interface_unit.sv         — Host interface (AXI-Lite / literal loading)

satswarmv2_pkg.sv               — Global parameters and types (included by all modules)
```

### AWS CL wrapper (`hdk_cl_satswarm/design/`)

```
cl_satswarm.sv          — HDK top-level; full cl_ports.vh interface, sh_ddr instantiation
satswarm_core_bridge.sv — Adapts AWS shell buses to satswarm_top simplified interface
```

---

## Setup & Installation

### Development Environment Setup

```bash
# 1. Clone repositories (AWS HDK and SatSwarmV2)
git clone https://github.com/aws/aws-fpga.git
cd aws-fpga && git checkout v2.3.0
source hdk_setup.sh

# 2. Clone SatSwarmV2 (if not already done)
cd /path/to/workdir
git clone <satswarmv2-repo-url> SatSwarmV2

# 3. Link HDK CL directory
# Option A: Symlink (recommended for development)
ln -s /path/to/SatSwarmV2/hdk_cl_satswarm $HDK_DIR/cl/examples/cl_satswarm

# Option B: Copy (recommended for isolation)
cp -r /path/to/SatSwarmV2/hdk_cl_satswarm $HDK_DIR/cl/examples/cl_satswarm

# 4. Verify the setup
ls $HDK_DIR/cl/examples/cl_satswarm  # Should show: design/, build/, verif/, host/
```

### Simulation Prerequisites

```bash
# macOS (Homebrew)
brew install verilator

# Ubuntu/Debian
sudo apt install verilator

# Verify installation
verilator --version  # Should be 5.0.0 or later
```

---

## Architecture Overview

### High-Level Block Diagram

```
┌─────────────────────────────────────────────────────────┐
│          CDCL SAT Solver (solver_core.sv)               │
│                                                         │
│   ┌─ PSE ──────┐  ┌─ CAE ──────┐  ┌─ VDE ──────┐     │
│   │ Propagate  │  │ Analyze    │  │ Decide     │     │
│   │ Assignment │→ │ Conflict   │→ │ Variable   │     │
│   │ (BCP)      │  │ (Learning) │  │ (VSIDS)    │     │
│   └─ ─ ─ ─ ───┘  └─ ─ ─ ─ ───┘  └─ ─ ─ ─ ───┘     │
│                      │                                 │
│                      ├─→ Backtrack on conflict         │
│                      └─→ Learn new clause              │
│                                                         │
│   Memory Subsystem:                                     │
│   ┌─────────────────┬─────────────┬──────────────┐   │
│   │ On-Chip (BRAM)  │ On-Chip     │ External     │   │
│   ├─────────────────┼─────────────┼──────────────┤   │
│   │ Clause Table    │ Arbitrator  │ DDR4 Literal │   │
│   │ Variable Table  │             │ Store        │   │
│   │ Trail Queue     │             │              │   │
│   │ Activity/Phase  │             │              │   │
│   └─────────────────┴─────────────┴──────────────┘   │
│                                                         │
│   Output: SAT (solution) | UNSAT (proof) | TIMEOUT    │
└─────────────────────────────────────────────────────────┘
```

### Three-Phase CDCL Loop

1. **Propagation Search Engine (PSE)** — Performs unit propagation using watched-literal scheme
   - Input: Current variable assignments, clause database
   - Output: New unit propagations or conflict clause
   - Runs in ~10 cycles per clause examined

2. **Conflict Analysis Engine (CAE)** — Analyzes conflicts and learns new clauses
   - Input: Conflict clause, implication graph (trail + reasons)
   - Output: Learned clause, backtrack decision level
   - Uses First-UIP heuristic

3. **Variable Decision Engine (VDE)** — Selects next variable to branch on
   - Input: Current variable activities, assignment state
   - Output: Next decision variable + phase (polarity)
   - Implements VSIDS heuristic with min-heap

**Key Design Principle**: Strict alternation (PSE → CAE → VDE → repeat) preserves CDCL correctness without requiring speculative parallelism.

### Parallel / Swarm Architecture

SatSwarmV2 scales beyond a single core using a Network-on-Chip (NoC) based mesh interconnect:

1.  **Mesh Topology**: Cores are arranged in a 2D mesh (e.g., 2x2, 3x3) using dimension-ordered routing X-Y.
2.  **Clause Sharing Strategy**:
    -   To minimize network congestion, only high-quality clauses are shared between cores.
    -   **Criteria**: Small Clauses (Length $\le$ 2) and High Quality (Low Literal Block Distance).
3.  **Portfolio Approach**: Each core initializes with different random seeds/phases to explore different parts of the search space.

---

## Core Modules at a Glance

### Propagation Search Engine (`pse.sv`)

**Purpose**: Boolean Constraint Propagation via watched-literal scheme  
**Key Algorithm**: Unit clause detection + conflict discovery  
**What It Does**:
- Scans watch lists concurrently
- Evaluates literals against current variable assignments
- Enqueues unit propagations to variable table
- Broadcasts conflict clause on unsatisfiable state

### Conflict Analysis Engine (`cae.sv`)

**Purpose**: First-UIP clause learning with conflict-driven backjumping  
**Key Algorithm**: Resolution-based first unique implication point detection  
**What It Does**:
- Walks resolution chain from conflict clause backward
- Tracks visited variables and decision levels
- Learns new clause that subsumes conflict
- Computes backtrack decision level (or detects UNSAT)

### Variable Decision Engine (`vde.sv`)

**Purpose**: VSIDS variable selection heuristic  
**Key Algorithm**: Activity scoring with exponential decay  
**What It Does**:
- Maintains per-variable activity score
- Decays all activities periodically
- Bumps conflicting variable activity
- Returns variable with minimum activity from heap
- Saves/restores phase (polarity) around restarts

### Memory & Arbitration (`global_mem_arbiter.sv`)

**Purpose**: Coordinate reads/writes to on-chip BRAM and external DDR4  
**Arbitration Strategy**: Fixed-priority mux for read requests; separate write queue

---

## Benchmark Results

The solver has been validated against **UF50 (SAT)** and **UUF50 (UNSAT)** benchmarks from SATLIB. Results compare SatSwarmV2 (running at 50 MHz) against the state-of-the-art VeriSAT solver (running at 150 MHz).

### SAT Results (UF50)

| Design | Frequency | Raw Cycles (Avg) | Time (ms) | Speedup (vs 1x1) |
| :--- | :--- | :--- | :--- | :--- |
| **VeriSAT** | 150 MHz | 39,240 | 0.26 | N/A |
| **SatSwarm 1x1** | 50 MHz | 24,772 | 0.495 | 1.0x |
| **SatSwarm 2x2** | 50 MHz | 12,158 | 0.243 | **2.03x** |
| **SatSwarm 3x3** | 50 MHz | 8,300 | 0.166 | **2.98x** |

### UNSAT Results (UUF50)

| Design | Frequency | Raw Cycles (Avg) | Time (ms) | Speedup (vs 1x1) |
| :--- | :--- | :--- | :--- | :--- |
| **VeriSAT** | 150 MHz | 91,667 | 0.61 | N/A |
| **SatSwarm 1x1** | 50 MHz | 55,740 | 1.115 | 1.0x |
| **SatSwarm 2x2** | 50 MHz | 45,774 | 0.915 | 1.22x |
| **SatSwarm 3x3** | 50 MHz | 38,011 | 0.760 | 1.47x |

### Performance Analysis
-   **Cycle Efficiency**: SatSwarmV2 requires significantly fewer cycles per problem than VeriSAT (e.g., ~24k vs ~39k for SAT), validating the architectural efficiency.
-   **Scaling**: The 3x3 configuration achieves near-linear speedup on SAT instances (~3x speedup with 9 cores implies strong portfolio effect) and moderate speedup on UNSAT instances.

---

## Documentation Navigation

This documentation has been split into focused chunks to make navigation easier:

- **[README.md](README.md)** (You are here): Architecture overview, repository structure, and quick-start instructions.
- **[Deploy.md](Deploy.md)**: Details the AWS HDK synthesis methodology. Includes Vivado settings, quick-check steps, and DDR/clock domain crossing setup.
- **[FPGA.md](FPGA.md)**: Final bitstream details and Amazon FPGA Image (AFI) creation instructions.
- **[Verification.md](Verification.md)**: Testing and debugging guide. Details Verilator simulation targets, regression scripts, XSim integration sweeps, and Vivado BRAM inference checks.
- **[Changes.md](Changes.md)**: Historical log of bug fixes, synthesis attempts, memory profiling, and major architectural design shifts over time.
- **[HANDOFF.md](HANDOFF.md)**: Living document updating the current state of the design, latest development blockers, key parameters, and actionable next steps. Must be updated by any departing developer (or AI agent).

---

## License & Attribution

**License**: [Specify your license: MIT, Apache 2.0, GPL-3.0, etc.]

**Author**: [Author name/organization]

**Acknowledgments**:
- Original SatSwarmv2.pdf authors [citation]
- SatAccel reference implementation (UCLA-VAST)
- MiniSat solver authors (Eén & Sörensson)
- Verilator simulator (Veripool)

## Frequently Asked Questions

**Q: Can I run this on a different FPGA?**  
A: Yes, with modifications. Update parameters in `satswarmv2_pkg.sv` (VAR_MAX, LIT_MAX, etc.) and adjust BRAM/DDR4 interfaces for your platform.

**Q: How do I add support for incremental SAT (add/remove clauses)?**  
A: Incremental solving requires clause deletion and/or variable freezing. Refer to Algorithm Guides and design a clause GC module. This is a future enhancement.
