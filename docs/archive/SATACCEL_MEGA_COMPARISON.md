# SatAccel vs Mega Implementation Comparison

## Overview
This document compares the **SatAccel** reference implementation (HLS C++/Vivado platform) with the **Mega** implementation (SystemVerilog RTL) in SatSwarmv2. Both implement FPGA-accelerated SAT solvers but with different design philosophies.

---

## Architecture Comparison

### SatAccel (Reference/HLS-based)
- **Language**: HLS C++ (Xilinx Vitis HLS)
- **Platform**: Xilinx U55C FPGA, 235 MHz
- **Design Approach**: High-Level Synthesis from C++ to RTL
- **Components**: Modular C++ functions synthesized to hardware pipelines
- **Memory**: Mix of on-chip (BRAM/URAM) and external DDR4 via AXI4

### Mega (Hardware RTL)
- **Language**: SystemVerilog (synthesizable RTL)
- **Platform**: Xilinx ZU9EG (UltraScale+), target 150 MHz
- **Design Approach**: Direct RTL with explicit FSM control
- **Components**: Decoupled modules (PSE, CAE, VDE, Trail Manager)
- **Memory**: Hybrid on-chip (BRAM/LUTRAM) and external DDR4 via global arbiter
- **Multicore**: Mesh-based distributed architecture (default 2x2, scalable)

---

## Key Modules and Implementations

### 1. Propagation Engine (BCP / Unit Propagation)

**SatAccel**:
- File: `hls/src/discover.cpp`
- Functions: `discover()`, `updateStatesForward()`, `controlSink()`, `bcp_discover_dataflow_wrapper()`
- Features:
  - Clause state partitioning (8 partitions for parallelism)
  - Color-based clause assignment tracking
  - AXI stream-based data flow between pipeline stages
  - Conflict detection via control packets
- Data Structures:
  - `clsState[_FPGA_CLS_STATES_PARTITION][clauses]`: Partitioned clause metadata
  - `bcpPacket`: Format for propagation results
  - `clsStateControlPacket`: Format for control flow

**Mega** (src/Mega/pse.sv):
- Module: `pse` (Propagation Search Engine)
- Approach: Cursor-based watch list scanning
- Features:
  - Multiple cursors (configurable) scan watch lists concurrently
  - Dispatcher assigns literals to cursors
  - Cursor lifecycle: scan → detect conflict/propagation → return
  - Read/write arbitration for BRAM/DDR access
  - Explicit FSM states (IDLE, SCAN, WAIT_DDR, CONFLICT)
- Status: ✅ IMPLEMENTED

### 2. Conflict Analysis and Learning

**SatAccel**:
- File: `hls/src/learn.cpp`
- Functions: `learn()`, related minimize/resolution functions
- Features:
  - Resolution-based learning (implies pivot expansion)
  - Minimize external function for learned clause reduction
  - Handle cache for clause/literal references
- Data Structures:
  - Stream-based pipelined learning pipeline
  - Message stream for control

**Mega** (src/Mega/cae.sv):
- Module: `cae` (Conflict Analysis Engine)
- Approach: First-UIP learning with inlined minimization
- Features:
  - Algorithm 2: First-UIP with inlined clause minimization (per paper)
  - Pipelined clause fetches (4-cycle DDR latency hidden)
  - Delayed shift register for literal validation
  - Combinational decision level comparison
  - Detects backtrack level and learns new clause
- Status: ✅ IMPLEMENTED with pipelined DDR access

### 3. Variable Decision / VSIDS

**SatAccel**:
- File: `hls/src/priority_queue_functions.cpp`, `hls/src/decide.cpp`
- Functions: `loadPositioning()`, `swapLower()`, `swapHigher()`, decision heap management
- Features:
  - Min-heap for activity-based variable selection
  - Heap operations pipelined
  - Activity decay and bumping
- Data Structures:
  - `pqData[2][_FPGA_MAX_LITERALS]`: Priority queue array
  - `pqPosition[_FPGA_MAX_LITERALS]`: Position mapping

**Mega** (src/Mega/vde.sv):
- Module: `vde` (Variable Decision Engine)
- Approach: Min-heap with activity tracking
- Features:
  - VSIDS with decay factor 0.9275 via fixed-point (x >> 16)
  - Phase saving around restarts
  - Heap maintenance (non-blocking, wait if busy)
  - Confluent scan to handle concurrent access
- Status: ✅ IMPLEMENTED

### 4. Backtracking & Trail Management

**SatAccel**:
- File: `hls/src/backtrack.cpp`
- Functions: Backtrack coordination
- Features:
  - Stack-based trail management
  - Clause removal/cleanup on backtrack

**Mega** (src/Mega/trail_manager.sv):
- Module: `trail_manager`
- Features:
  - Dual-port BRAM for trail storage
  - Backtrack via level-based undo
  - Support for divergence-forced assignments (Swarm feature)
  - Query interface for decision level lookup
  - Single-cycle trail pop/push
- Status: ✅ IMPLEMENTED

### 5. Memory & I/O

**SatAccel**:
- Literal store: External DDR via AXI4 Master (`litStore`)
- Clause state: Partitioned on-chip BRAM/URAM
- Metadata: On-chip URAM
- Control: AXI-Lite slave for host commands
- Streams: Host-to-kernel parameter passing via HLS streams

**Mega**:
- Literal store: External DDR via global arbiter
- Clause headers: On-chip BRAM/LUTRAM (append-only)
- Variable metadata: LUTRAM for 1-cycle access
- Watch lists: Linked lists in clause table
- Global arbiter: Multiplexes all DDR requests (PSE, CAE, VDE, learned clause append)
- Status: ⚠️ PARTIALLY IMPLEMENTED (global arbiter exists but may need refinement)

### 6. Distributed Architecture (Mesh/Swarm)

**SatAccel**:
- Single-core design on U55C
- No distributed coordination

**Mega** (Swarm extension):
- Default 2x2 mesh of solver cores
- Divergence propagation: Active nodes force neighbors to explore $\neg X$
- Interface Unit: NoC packet wrapper for inter-core communication
- Mesh Interconnect: Network-on-Chip (not explicitly in src/Mega but referenced)
- Features:
  - `noc_packet_t` protocol for Divergence, Clause Sharing, Status
  - Per-core variable metadata + trail
  - Shared global memory (DDR4)
  - Phase restoration after divergence backtrack
- Status: ⚠️ PARTIALLY IMPLEMENTED (interface_unit.sv exists, full mesh tests needed)

---

## File Correspondence Matrix

| SatAccel File | Purpose | Mega Equivalent | Status |
|---|---|---|---|
| `hls/src/discover.cpp` | BCP / Propagation | `pse.sv` | ✅ RTL |
| `hls/src/learn.cpp` | Conflict Analysis | `cae.sv` | ✅ RTL |
| `hls/src/priority_queue_functions.cpp` | VSIDS Heap Ops | `vde.sv` | ✅ RTL |
| `hls/src/decide.cpp` | Variable Decision | `vde.sv` | ✅ RTL |
| `hls/src/backtrack.cpp` | Backtracking | `trail_manager.sv` | ✅ RTL |
| `hls/src/minimize.cpp` | Clause Minimization | `cae.sv` (inlined) | ✅ RTL |
| `hls/src/restart.cpp` | Restart/LBD Logic | *(in solver_core FSM)* | ⚠️ Basic impl |
| `hls/src/solver.cpp` | Main kernel | `solver_core.sv` | ✅ RTL with FSM |
| `hls/src/location_handler.cpp` | DDR management | `global_mem_arbiter.sv` | ⚠️ Basic impl |
| `include/fpga_solver.h` | Parameter defs | `verisat_pkg.sv` | ✅ Converted to SV |
| `host/src/host.cpp` | PS driver | *(sim/sim_main.cpp, tb)* | ⚠️ Test harness |
| — | NoC / Divergence | `interface_unit.sv` | ⚠️ Swarm feature |

---

## Implementation Status by Module

### ✅ Fully Implemented (RTL Complete)

1. **PSE (Propagation Search Engine)**
   - Multi-cursor concurrent scanning
   - Watch list traversal
   - Conflict detection
   - Arbitration for DDR/BRAM access
   - File: `src/Mega/pse.sv`

2. **CAE (Conflict Analysis Engine)**
   - First-UIP learning algorithm
   - Inlined clause minimization
   - Pipelined DDR fetch with 4-cycle latency hiding
   - Backtrack level computation
   - File: `src/Mega/cae.sv`

3. **VDE (Variable Decision Engine)**
   - Min-heap VSIDS
   - Activity bump on learned clauses
   - Phase saving/restore
   - File: `src/Mega/vde.sv`

4. **Trail Manager**
   - Dual-port BRAM for trail storage
   - Backtrack support with level-based undo
   - Query interface for decision level
   - Divergence flag support (Swarm)
   - File: `src/Mega/trail_manager.sv`

5. **Solver Core (FSM)**
   - CDCL loop orchestration (alternates PSE/CAE/VDE)
   - State machine with 12+ states
   - Conflict accumulation and analysis routing
   - SAT/UNSAT detection
   - File: `src/Mega/solver_core.sv`

6. **Package Definitions**
   - Data types and struct definitions
   - Parameter set matching SatAccel
   - File: `src/Mega/verisat_pkg.sv`

### ⚠️ Partially Implemented

1. **Global Memory Arbiter**
   - Fixed-priority arbitration for multiple requestors
   - DDR read/write sequencing
   - File: `src/Mega/global_mem_arbiter.sv`
   - **Needs**: Validation against DDR bandwidth assumptions, port count verification

2. **Restart / LBD-based Policies**
   - Basic restart trigger in solver_core
   - **Missing**: Full LBD histogram tracking, restart scheduling algorithm
   - **Reference**: SatAccel's `restart.cpp` implements full policy

3. **Interface Unit (Swarm NoC)**
   - Packet parsing and routing for divergence/clause sharing
   - File: `src/Mega/interface_unit.sv`
   - **Needs**: Full test of packet in/out, virtual channel deadlock avoidance

4. **Mesh Interconnect**
   - Referenced but not explicitly found in src/Mega
   - **Missing**: Full mesh topology implementation

### ❌ Not Implemented / Deferred

1. **Host Driver (PS Side)**
   - SatAccel has full host.cpp with DIMACS parsing
   - Mega has testbench stubs but no production PS driver
   - **Status**: Deferred to integration phase

2. **Minimize Split Optimization**
   - SatAccel has advanced parallel minimize pipeline
   - Mega inlines basic minimization in CAE
   - **Status**: Acceptable for current phase

---

## Parameter & Configuration Comparison

### SatAccel Parameters (from `include/fpga_solver.h`)

```cpp
#define _FPGA_MAX_LITERALS      (8192*4)           // 32,768 literals
#define _FPGA_MAX_CLAUSES       131072             // 131K clauses
#define _FPGA_MAX_TREE_HEIGHT   32                 // Backtrack depth
#define _FPGA_MAX_LBD_BUCKETS   10                 // Learned clause diversity
#define _FPGA_CLS_STATES_PARTITION  8              // Parallelism factor
#define _FPGA_MAX_LEARN_ELE     1024               // Max learned clause length
#define _FPGA_MAX_LITERAL_ELEMENTS  (256*4096)     // DDR literal store
#define _FPGA_PARALLEL_MINIMIZE 2                  // Minimize pipelines
```

### Mega Parameters (from `verisat_pkg.sv`)

```systemverilog
parameter int VAR_MAX        = 16384;              // Half SatAccel capacity
parameter int LIT_MAX        = 1048576;            // ~4x SatAccel effective
parameter int CLAUSE_MAX     = 262144;             // 2x SatAccel
parameter int CURSOR_COUNT   = 4;                  // PSE parallelism
parameter int GRID_X         = 2;                  // Mesh rows
parameter int GRID_Y         = 2;                  // Mesh cols
```

**Notes**:
- SatAccel: 235 MHz, ~32K vars, ~131K clauses
- Mega: 150 MHz (target), 16K vars (scalable), 262K clauses (designed for DDR overflow)

---

## Key Differences and Design Philosophy

### 1. Sequential vs. Pipelined
- **SatAccel**: HLS-synthesized dataflow pipelines; multiple stages operate concurrently
- **Mega**: FSM-based sequencing with pipelined sub-blocks; CDCL loop alternates PSE/CAE/VDE to preserve correctness

### 2. Arbitration Strategy
- **SatAccel**: Implicit through Vivado HLS dataflow/stream scheduling
- **Mega**: Explicit fixed-priority arbiter in `global_mem_arbiter.sv`

### 3. Memory Access Patterns
- **SatAccel**: Streams and implicit handshakes
- **Mega**: Explicit grants/valid signals; decoupled read/write paths

### 4. Scalability
- **SatAccel**: Single-core on U55C
- **Mega**: Mesh of cores with Divergence Propagation (Swarm architecture)

### 5. Clause Minimization
- **SatAccel**: Dedicated pipeline (`minimize.cpp`)
- **Mega**: Inlined in CAE with pipelined literal fetches

---

## Validation Checklist: src/Mega Completeness

### Architectural Items from SatAccel

- [x] **Unit Propagation (BCP)**
  - [x] Multi-cursor watch list scanning
  - [x] Conflict detection per cursor
  - [x] Broadcast halt on conflict
  - Implementation: `pse.sv`

- [x] **Conflict Analysis**
  - [x] First-UIP algorithm
  - [x] Clause minimization
  - [x] Backtrack level computation
  - [x] Learned clause append
  - Implementation: `cae.sv`

- [x] **Variable Decision (VSIDS)**
  - [x] Min-heap maintenance
  - [x] Activity decay (0.95 in pkg, 0.9275 in comments)
  - [x] Phase saving
  - Implementation: `vde.sv`

- [x] **Trail & Backtrack**
  - [x] Stack-based trail
  - [x] Level-based undo
  - [x] Decision/reason metadata
  - Implementation: `trail_manager.sv`

- [x] **Main Solver Loop**
  - [x] Alternating PSE/CAE/VDE
  - [x] SAT/UNSAT detection
  - [x] Cycle counting
  - Implementation: `solver_core.sv`

- ⚠️ **Memory Management**
  - [x] DDR literal store
  - [x] On-chip clause headers
  - ⚠️ Arbiter validation needed
  - Implementation: `global_mem_arbiter.sv` (basic)

- ⚠️ **Restart & LBD Policies**
  - ⚠️ Basic restart trigger
  - [ ] Full LBD histogram
  - [ ] Adaptive restart schedule
  - Reference: `restart.cpp` not fully ported

- ⚠️ **Swarm Distribution**
  - ⚠️ Interface unit (basic)
  - [ ] Full mesh interconnect
  - [ ] Divergence protocol
  - Implementation: `interface_unit.sv` (partial)

- ⚠️ **Host Integration**
  - [ ] DIMACS parser
  - [ ] AXI4-Lite driver
  - [ ] Result reporting
  - Deferred to integration phase

---

## Recommendations for Completion

### High Priority

1. **Validate Global Memory Arbiter**
   - Verify fixed-priority arbitration doesn't cause starvation
   - Check DDR bandwidth assumptions (8 vs 16 bytes per cycle?)
   - Simulate with realistic PSE/CAE/VDE access patterns

2. **Complete LBD-based Restart**
   - Implement LBD histogram tracking in CAE
   - Add exponential/periodic restart policy in solver_core
   - Reference: Paper's Section 4.3

3. **Full Mesh Interconnect**
   - If Swarm is target, implement complete NoC
   - Add virtual channel deadlock avoidance
   - Route divergence, clause sharing, status packets

### Medium Priority

1. **Host Driver (PS Side)**
   - DIMACS CNF parser
   - AXI4-Lite register interface
   - Status polling and result retrieval

2. **Testbench Expansion**
   - Multi-core Swarm tests
   - Divergence propagation validation
   - Performance benchmarking vs. SatAccel reference

3. **Optimization Pass**
   - Timing closure at 150 MHz
   - Area reduction if needed
   - Power analysis

### Low Priority (Deferred)

1. Advanced minimize pipeline (inlining acceptable)
2. Adaptive clause reduction strategy
3. Incremental solving (assuming single-shot for now)

---

## Summary

**Mega is architecturally complete** for single-core CDCL solving with most SatAccel reference items implemented:

| Aspect | Status | Notes |
|---|---|---|
| Core CDCL Loop | ✅ | All three modules + solver FSM |
| Propagation Engine | ✅ | Multi-cursor, arbiter ready |
| Conflict Analysis | ✅ | First-UIP + inlined minimize |
| VSIDS Decision | ✅ | Min-heap + phase saving |
| Trail/Backtrack | ✅ | Level-based, divergence-aware |
| Memory Hierarchy | ⚠️ | Arbiter basic; needs validation |
| Restart/LBD Policy | ⚠️ | Trigger exists; full policy deferred |
| Swarm Distribution | ⚠️ | Interface partial; mesh deferred |
| Host Integration | ❌ | Deferred to next phase |

**Next Steps**:
1. Run comparative tests: Mega vs. SatAccel on SATLIB benchmarks
2. Validate memory arbiter under realistic load
3. Implement full LBD restart policy
4. Begin host driver integration if Swarm deployment required

