# SatSwarmv2: Hardware SAT Solver for FPGA

**A high-performance, hardware-optimized SAT solver implementation in SystemVerilog targeting the Xilinx ZU9EG FPGA.**

SatSwarmv2 implements the conflict-driven clause learning (CDCL) algorithm—the foundation of modern SAT solvers—directly in synthesizable hardware. It uses three alternating processing stages (Propagation, Conflict Analysis, Variable Decision) to efficiently solve Boolean satisfiability problems, with support for up to 16,384 variables and 1 million literals.

---

## Quick Facts

| Aspect | Value |
|--------|-------|
| **Target Platform** | Xilinx ZU9EG (UltraScale+) |
| **Clock Frequency** | 150 MHz |
| **Max Variables** | 16,384 |
| **Max Literals** | 1,048,576 |
| **Max Clauses** | 262,144 |
| **External Memory** | DDR4 via AXI4-Lite |
| **Memory Capacity** | 2 GB available |
| **Primary RTL Language** | SystemVerilog (Verilator 5.020+ compatible) |
| **Toolchain** | Vivado 2023.4 |
| **Simulation** | Verilator 5.044 |
| **Implementation Status** | ~95% complete, 75+ variable benchmarks validated |

---

## Quick Start

### Prerequisites

```bash
# macOS (Homebrew)
brew install verilator

# Ubuntu/Debian
sudo apt install verilator

# Verify installation
verilator --version  # Should be 5.0.0 or later
```

### Clone and Build

```bash
cd /path/to/SatSwarmv2
cd sim
make  # Compiles simulator with Verilator
```

### Run a Simple Test

```bash
# First test: very simple SAT instance (1 variable)
cd sim
./obj_dir/Vtb_verisat <<EOF
p cnf 1 2
1 0
-1 0
EOF
# Expected: UNSAT (contradictory clauses)

# Second test: satisfiable instance (2 variables)
./obj_dir/Vtb_verisat <<EOF
p cnf 2 3
1 2 0
-1 3 0
-2 3 0
EOF
# Expected: SAT (or similar satisfying assignment)
```

### Directory Structure

```
SatSwarmv2/
├── README.md                            # This file
├── SatSwarmv2.pdf                          # Original paper
├── .github/copilot-instructions.md      # Development guidelines
├── docs/
│   ├── README.md                        # Documentation navigation hub
│   ├── guides/
│   │   ├── ALGORITHM_IMPLEMENTATION.md  # Deep-dive: CDCL algorithm
│   │   ├── SYSTEMVERILOG_DESIGN.md      # Deep-dive: Hardware design
│   │   └── TESTING_VERIFICATION.md      # Deep-dive: Testing strategy
│   ├── status/                          # Project status tracking
│   └── archive/                         # Historical documentation
├── src/Mega/                            # Main RTL implementation (CDCL solver)
│   ├── satswarmv2_pkg.sv                # Package: parameters, types, NoC structures
│   ├── solver_core.sv                   # Top-level CDCL FSM orchestrator
│   ├── pse.sv                           # Propagation Search Engine (BCP)
│   ├── cae.sv                           # Conflict Analysis Engine (First-UIP)
│   ├── vde.sv                           # Variable Decision Engine (VSIDS)
│   ├── vde_heap.sv                      # Min-heap for VSIDS activity
│   ├── trail_manager.sv                 # Trail & backtracking logic
│   ├── watch_manager.sv                 # Watched literal management
│   ├── clause_store.sv                  # Clause database management
│   ├── shared_clause_buffer.sv          # Learned clause sharing buffer
│   ├── global_allocator.sv              # Memory allocation
│   ├── global_mem_arbiter.sv            # Memory arbitration
│   ├── resync_controller.sv             # PSE state resynchronization
│   ├── stats_manager.sv                 # Performance statistics
│   ├── interface_unit.sv                # NoC interface (Swarm)
│   ├── mesh_interconnect.sv             # 2D mesh routing
│   └── satswarm_top.sv                  # Top-level multi-core wrapper
├── src/Mini/                            # Lightweight DPLL solver (testing)
│   ├── mini_pkg.sv                      # Mini solver parameters
│   ├── mini_solver_core.sv              # Simplified DPLL FSM
│   ├── mini_pse.sv                      # Simplified propagation
│   └── mini_top.sv                      # Mini solver top-level
├── sim/
│   ├── Makefile                         # Build system
│   ├── tb_verisat.sv                    # Main testbench
│   ├── sim_main.cpp                     # Verilator harness
│   ├── obj_dir/                         # Compiled simulator (generated)
│   └── [test scripts]                   # Quick test utilities
├── tests/
│   ├── *.cnf                            # DIMACS CNF test instances
│   ├── gen_sat_*.cnf                    # Generated SAT instances
│   └── gen_unsat_*.cnf                  # Generated UNSAT instances
├── reference/
│   ├── SatSwarmv2.pdf                      # Original paper
│   ├── SatAccel/                        # UCLA-VAST HLS reference
│   └── [other references]               # Supporting materials
└── resource_estimation/
    ├── resource_report_*.md             # Area/power analysis
    └── [solver-specific reports]        # Per-implementation metrics
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
   - Uses First-UIP heuristic with pipelined DDR access

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
    -   **Criteria**:
        -   **Small Clauses**: Length $\le$ 2.
        -   **High Quality**: Low Literal Block Distance (LBD), inspired by the MallobSat approach.
3.  **Portfolio Approach**: Each core initializes with different random seeds/phases to explore different parts of the search space, maximizing the probability of finding a solution quickly (especially for SAT instances).

---

## Core Modules at a Glance

### Propagation Search Engine (`pse.sv`)

**Purpose**: Boolean Constraint Propagation via watched-literal scheme  
**Key Algorithm**: Unit clause detection + conflict discovery  
**FSM States**: 9 (IDLE → INIT_SCAN → FETCH_CLAUSE → CHECK_WLIT → SCAN_LITERALS → FIND_WATCHER → PROPAGATE → DONE)

**What It Does**:
- Scans watch lists concurrently (up to 4 cursors configurable)
- Evaluates literals against current variable assignments
- Enqueues unit propagations to variable table
- Broadcasts conflict clause on unsatisfiable state

**Resource Estimate**: 2,000–3,000 LUTs per cursor

### Conflict Analysis Engine (`cae.sv`)

**Purpose**: First-UIP clause learning with conflict-driven backjumping  
**Key Algorithm**: Resolution-based first unique implication point detection  
**FSM States**: 4 (IDLE → LOAD → SCAN → DONE)

**What It Does**:
- Walks resolution chain from conflict clause backward
- Tracks visited variables and decision levels
- Learns new clause that subsumes conflict
- Computes backtrack decision level (or detects UNSAT)
- Hides DDR latency with 4-cycle pipelined fetch

**Resource Estimate**: 1,500–2,000 LUTs

### Variable Decision Engine (`vde.sv`)

**Purpose**: VSIDS variable selection heuristic  
**Key Algorithm**: Activity scoring with exponential decay  
**Operations**: Bump activity on conflict, decay periodically, extract-min from heap

**What It Does**:
- Maintains per-variable activity score (32-bit)
- Decays all activities: $\text{activity}[v] \leftarrow \text{activity}[v] - (\text{activity}[v] >> 16)$ (≈0.9275 factor)
- Bumps conflicting variable: activity += 1000
- Returns variable with minimum activity from heap
- Saves/restores phase (polarity) around restarts

**Resource Estimate**: 1,000–1,500 LUTs

### Memory & Arbitration (`global_mem_arbiter.sv`)

**Purpose**: Coordinate reads/writes to on-chip BRAM and external DDR4  
**Scheme**:
- **On-Chip (BRAM/LUTRAM)**:
  - Clause table: 262K entries × 128 bits (cached watchers + LBD)
  - Variable table: 16K entries × 96 bits (assignment, level, reason, phase)
  - Trail queue: 16K FIFO × 32 bits
  - Activity/phase arrays: 16K × 32 bits each
- **External DDR4**:
  - Literal store: 1M × 32 bits (append-only)
  - AXI4-Lite interface (~4-cycle latency per access)

**Arbitration Strategy**: Fixed-priority mux for read requests; separate write queue

**Resource Estimate**: 500–800 LUTs

---

## Implementation Status

| Component | Status | Details |
|-----------|--------|---------|
| **Core CDCL Loop** | ✅ 100% | FSM orchestrates PSE → CAE → VDE alternation |
| **Propagation (PSE)** | ✅ 100% | Multi-cursor watch list with conflict detection, resync support |
| **Conflict Analysis (CAE)** | ✅ 100% | First-UIP learning + pipelined DDR fetch + literal filtering |
| **Variable Decision (VDE)** | ✅ 100% | Min-heap VSIDS with activity decay & phase saving |
| **Trail & Backtracking** | ✅ 100% | Level-based undo with divergence support (Swarm) |
| **Watch Manager** | ✅ 100% | Two-literal watching with efficient updates |
| **Clause Store** | ✅ 100% | Learned clause management with LBD tracking |
| **Memory Arbitration** | ✅ 90% | Fixed-priority arbiter with validation |
| **Resync Controller** | ✅ 100% | PSE state recovery after race conditions |
| **Distributed (Swarm)** | ✅ 100% | 1x1, 2x2, and 3x3 mesh topologies fully validated |
| **Clause Sharing** | ✅ 100% | Length-2 + LBD-based filtering (MallobSat-inspired) |
| **Restart Policy** | ⚠️ 50% | Basic LBD-based trigger; full policy deferred |
| **Host Driver (PS-side)** | ❌ 0% | DIMACS parsing, AXI control deferred (future) |

**Overall**: ~95% implementation complete, validated on 75+ variable SATLIB benchmarks

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

> **Note**: Even at 1/3rd the clock frequency, SatSwarm 2x2 and 3x3 configurations outperform VeriSAT in wall-clock time for SAT instances due to algorithmic efficiency and parallel search.

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
-   **Verdict**: The parallel swarm architecture successfully offsets the lower clock frequency (50 MHz vs 150 MHz), beating state-of-the-art performance on SAT problems.

---

## Resolved Issues

10+ critical bugs have been identified and fixed during development. Key fixes include:

| Bug | Severity | Issue | Status |
|-----|----------|-------|--------|
| BUG-011 | Critical | Invalid literal 0 in conflict analysis | ✅ Fixed |
| BUG-010 | Critical | CAE reason staleness causing false UNSATs | ✅ Fixed |
| BUG-007 | Critical | Infinite loop & soundness failure | ✅ Fixed |
| BUG-006 | High | Completeness failure (truncated clauses) | ✅ Fixed |
| BUG-005 | Critical | Single-core soundness (PSE race condition) | ✅ Fixed |
| BUG-003 | Critical | Sign inversion in learned clauses | ✅ Fixed |
| BUG-002 | High | Livelock in ACCUMULATE_PROPS | ✅ Fixed |

See [docs/bugs/BUG_TRACKER.md](docs/bugs/BUG_TRACKER.md) for complete details.

---

## Development Workflow

### Build & Simulate

```bash
cd sim
make clean        # Remove generated files
make              # Compile RTL with Verilator
make wave         # Run simulation + generate waveform (if gtkwave available)
make test         # Run quick regression suite
```

### Common Tasks

#### Add a New Test Case

```bash
# Create DIMACS file
cat > tests/my_test.cnf <<EOF
p cnf 3 4
1 2 0
1 -3 0
-1 2 0
-2 3 0
EOF

# Test it
./obj_dir/Vtb_verisat < tests/my_test.cnf
```

#### Modify VSIDS Decay Factor

Edit [src/Mega/vde.sv](src/Mega/vde.sv):
```systemverilog
// Change this line (line ~150)
activity_q[idx] <= activity_q[idx] - (activity_q[idx] >> 16);  // 0.9275 factor
// To a different shift for different decay rate
activity_q[idx] <= activity_q[idx] - (activity_q[idx] >> 15);  // ~0.9375 (faster decay)
```

#### Adjust Clause Cache Size

Edit [src/Mega/verisat_pkg.sv](src/Mega/verisat_pkg.sv):
```systemverilog
// Change parameter
parameter MAX_CLAUSES = 262144;  // Currently ~262K
// To your desired size (must be power of 2 for pointer width)
```

#### Profile Decision/Conflict Frequency

Modify [sim/tb_verisat.sv](sim/tb_verisat.sv) to add counters:
```systemverilog
always @(posedge clk) begin
    if (reset) begin
        decision_count <= 0;
        conflict_count <= 0;
    end else begin
        if (vde_decide_valid)
            decision_count <= decision_count + 1;
        if (pse_conflict_detected)
            conflict_count <= conflict_count + 1;
    end
end
```

### Debugging Tips

**Simulation hangs?**
- Check testbench timeout (default: 900,000 cycles)
- Increase in [sim/Makefile](sim/Makefile): `SIM_CYCLES ?= 5000000`
- Enable waveform to diagnose FSM state: `make wave`

**Wrong SAT/UNSAT answer?**
- Compare trail assignments against expected solution
- Verify CAE backtrack level computation (should point to highest non-UIP literal)
- Check arbitration didn't drop memory write (enable detailed logging in arbiter)

**Performance regression?**
- Count conflicts/decisions in waveform
- Compare against baseline regression suite
- Profile BRAM vs. DDR access ratio

---

## Contribution Guidelines

### Development Environment Setup

```bash
# 1. Clone repository
git clone https://github.com/[owner]/SatSwarmv2.git
cd SatSwarmv2

# 2. Install dependencies (macOS)
brew install verilator

# 3. Verify build
cd sim
make
```

### Code Style & Conventions

**SystemVerilog RTL**:
- Use explicit FSMs (prefer `enum` for states, not binary encoding)
- Parameterize hardcoded values (VAR_MAX, LIT_MAX, etc.)
- Comment arbitration logic and concurrency assumptions
- Keep modules synthesizable (no `initial`, no dynamic allocation)
- Use `always @(posedge clk)` for sequential, `always @(*)` for combinational

**Naming**:
- Signals: `snake_case` (e.g., `decision_valid`)
- Parameters: `UPPER_CASE` (e.g., `VAR_MAX`)
- State enum: `name_t` (e.g., `pse_state_t`)

**Documentation**:
- Header comment on each module (1-2 sentences)
- Complex FSM transitions: explain why (e.g., "stall on RAW hazard")
- Latency-critical paths: note expected cycle count

### Regression Testing

Before submitting a pull request, verify no performance regression:

```bash
cd sim
# Baseline (on main branch)
git checkout main
make test 2>&1 | tee baseline.txt

# Your changes
git checkout your-branch
make test 2>&1 | tee your-test.txt

# Compare (cycle counts should not increase >5%)
diff baseline.txt your-test.txt
```

### Pull Request Process

1. **Fork** the repository
2. **Branch** from `main`: `git checkout -b feature/your-feature`
3. **Implement** changes with clean commits
4. **Test** locally: `cd sim && make test` (must pass all tests)
5. **Document** changes in commit message (reference issue #123 if applicable)
6. **Submit** PR with:
   - Clear description of changes
   - Link to related issues
   - Performance impact (cycle count delta)
   - New tests (if applicable)
7. **Respond** to review feedback promptly

### Performance Regression Gates

Merge is blocked if:
- **Correctness**: Any test case returns wrong SAT/UNSAT answer
- **Performance**: Any benchmark instance >5% slower than baseline
- **Resource Usage**: Synthesis shows >10% area growth unexpectedly
- **Tests**: Regression suite has failures (see [Testing & Verification Guide](docs/guides/TESTING_VERIFICATION.md))

---

## Further Reading

For deeper understanding, consult the specialized documentation:

1. **[Algorithm Implementation Guide](docs/guides/ALGORITHM_IMPLEMENTATION.md)**
   - Detailed CDCL algorithm walkthrough
   - First-UIP clause learning with worked examples
   - VSIDS heuristic and activity decay mechanics
   - Memory data structures and access patterns

2. **[SystemVerilog Hardware Design Guide](docs/guides/SYSTEMVERILOG_DESIGN.md)**
   - Synthesizable SystemVerilog principles
   - Module-level design for each component
   - Arbitration and concurrency strategy
   - Resource estimation and optimization
   - Timing analysis and critical paths
   - Xilinx platform-specific details

3. **[Testing & Verification Guide](docs/guides/TESTING_VERIFICATION.md)**
   - Unit, integration, system test strategies
   - Testbench structure and benchmark methodology
   - Formal verification approach
   - CI/CD pipeline and regression gates
   - Debugging techniques

### Key References

- **[SatSwarmv2.pdf](reference/SatSwarmv2.pdf)** — Original paper describing the architecture
- **[MiniSat](http://minisat.se)** — Reference SAT solver (CDCL baseline)
- **[SatAccel](reference/SatAccel/)** — UCLA-VAST HLS reference implementation
- **IEEE/ACM papers** on DPLL, CDCL, VSIDS heuristics (see Algorithm Guide references)

---

## License & Attribution

**License**: [Specify your license: MIT, Apache 2.0, GPL-3.0, etc.]

**Author**: [Author name/organization]

**Acknowledgments**:
- Original SatSwarmv2.pdf authors [citation]
- SatAccel reference implementation (UCLA-VAST)
- MiniSat solver authors (Eén & Sörensson)
- Verilator simulator (Veripool)

---

## Frequently Asked Questions

**Q: How do I interpret the cycle count from simulation?**  
A: Cycle count in the waveform / simulator output represents real clock cycles at 150 MHz. To estimate wall-clock time: time (ms) = cycles / (150 × 10⁶). See [Testing Guide](docs/TESTING_VERIFICATION.md#performance-testing) for benchmarking methodology.

**Q: Can I run this on a different FPGA?**  
A: Yes, with modifications. Update parameters in [verisat_pkg.sv](src/Mega/verisat_pkg.sv) (VAR_MAX, LIT_MAX, etc.) and adjust BRAM/DDR4 interfaces for your platform. See [Hardware Design Guide](docs/SYSTEMVERILOG_DESIGN.md#target-platform-xilinx-zu9eg) for platform-specific considerations.

**Q: What's the difference between SatSwarmv2 and SatAccel?**  
A: SatSwarmv2 is the original paper-based implementation (src/Mega); SatAccel is a reference HLS implementation (reference/SatAccel). Both implement CDCL but with different trade-offs in parallelism and resource usage. See [Algorithm Guide](docs/ALGORITHM_IMPLEMENTATION.md#references) for detailed comparison.

**Q: How do I add support for incremental SAT (add/remove clauses)?**  
A: Incremental solving requires clause deletion and/or variable freezing. Refer to [Algorithm Guide § Clause Deletion Strategies](docs/ALGORITHM_IMPLEMENTATION.md#algorithmic-trade-offs) and design a clause GC module. This is a future enhancement (not currently implemented).

**Q: My simulation times out. What should I do?**  
A: See [Debugging Tips](#debugging-tips) above. Most likely causes: (1) infinite loop in PSE/CAE (check watch list traversal), (2) clause database saturated (increase MAX_CLAUSES), (3) timeout too short (increase SIM_CYCLES in Makefile). Use waveform (make wave) to inspect FSM states.

---

**For questions, issues, or contributions**: Please open a GitHub issue or start a discussion.

**Last Updated**: January 30, 2026  
**Documentation Version**: 2.0 (Post-Stabilization)
