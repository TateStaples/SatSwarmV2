# SystemVerilog Hardware Design Guide: SatSwarmv2 Implementation

A comprehensive technical reference for hardware-specific design, synthesizability, timing, and resource optimization of the SatSwarmv2 FPGA SAT solver.

---

## 1. Design Principles for Synthesizable SystemVerilog

### 1.1 Synthesizable Subset

SatSwarmv2 adheres to IEEE Std 1364.1 (Verilog Synthesis) for Xilinx Vivado compatibility. Key rules:

| Feature | Synthesizable | Notes |
|---------|---|-------|
| `always @(posedge clk)` | ✅ | Sequential logic (registers) |
| `always @(*)` | ✅ | Combinational logic |
| `always @(*)` with blocking | ⚠️ | In comb. only; use ← (non-blocking) in seq. |
| `if-else`, `case` | ✅ | Preferred for mux/FSM |
| `for` loops | ⚠️ | Only if unrolled at compile-time; no `break` |
| `while`, `repeat` | ❌ | Not synthesizable |
| Dynamic arrays | ❌ | Use fixed-size arrays with `reg [WIDTH:0] array [DEPTH]` |
| `initial` blocks | ✅ | Only for initialization (converted to defaults) |
| `generate` blocks | ✅ | Parametric module instantiation |
| `function` / `task` | ⚠️ | Inlined; avoid state-holding tasks |
| Blocking assign `=` | ⚠️ | Comb. only; use `<=` (non-blocking) in seq. |

### 1.2 No Dynamic Allocation

**Rule**: All memory sizes set at elaboration (compile-time) via parameters.

**Bad**:
```systemverilog
// ❌ NOT SYNTHESIZABLE
reg [31:0] clause_list [];  // Dynamic array
initial clause_list = new [1000];
```

**Good**:
```systemverilog
// ✅ SYNTHESIZABLE
parameter MAX_CLAUSES = 262144;
reg [127:0] clause_table [MAX_CLAUSES];  // Fixed-size array
```

### 1.3 Explicit FSMs Preferred

**Rationale**: Hardware FSMs are determistic and verifiable; prefer explicit over behavioral.

**Template**:
```systemverilog
// Define states as enum (Verilog 2005+)
typedef enum logic [3:0] {
    IDLE, INIT_SCAN, FETCH_CLAUSE, CHECK_WLIT, SCAN_LITERALS,
    FIND_WATCHER, PROPAGATE, DONE
} pse_state_t;

pse_state_t state, next_state;

// Sequential: update state register
always @(posedge clk) begin
    if (reset)
        state <= IDLE;
    else
        state <= next_state;
end

// Combinational: compute next state and outputs
always @(*) begin
    next_state = state;  // Default: stay in same state
    case (state)
        IDLE: begin
            if (start) next_state = INIT_SCAN;
        end
        INIT_SCAN: begin
            next_state = FETCH_CLAUSE;
        end
        // ... more states ...
        DONE: begin
            if (!start) next_state = IDLE;
        end
    endcase
end

// Output logic (combinational)
always @(*) begin
    prop_valid = (state == PROPAGATE);
    conflict_detected = (state == DONE && found_conflict);
    // ...
end
```

### 1.4 Pipelined Dataflow for Timing

**Key Insight**: Sequential stages with registered intermediate values hide latency.

**Bad** (Combinational Critical Path):
```systemverilog
// ❌ Long combinational chain (fails timing)
wire [31:0] a, b, c, d, e;
assign a = input_signal;
assign b = f1(a);
assign c = f2(b);
assign d = f3(c);
assign e = f4(d);
assign result = e;  // Result may be too slow
```

**Good** (Pipelined):
```systemverilog
// ✅ Break into stages
reg [31:0] stage1_q, stage2_q, stage3_q, stage4_q;

always @(posedge clk) begin
    stage1_q <= f1(input_signal);
    stage2_q <= f2(stage1_q);
    stage3_q <= f3(stage2_q);
    stage4_q <= f4(stage3_q);
end

assign result = stage4_q;  // Safe combinational logic now short
```

### 1.5 Explicit Arbiter Design

**Rule**: No implicit priority (e.g., `priority always` or implicit `if-if-if` chains). Always use explicit mux with documented priority.

**Template** (Fixed-Priority Arbiter):
```systemverilog
parameter NUM_REQUESTERS = 4;

reg [NUM_REQUESTERS-1:0] req;  // Requests from PSE cursors
wire [NUM_REQUESTERS-1:0] grant;

// Fixed-priority: requester 0 > 1 > 2 > 3
assign grant[0] = req[0];
assign grant[1] = req[1] & ~req[0];
assign grant[2] = req[2] & ~req[1] & ~req[0];
assign grant[3] = req[3] & ~req[2] & ~req[1] & ~req[0];

always @(*) begin
    arbiter_result = '0;
    if (grant[0]) arbiter_result = data_0;
    if (grant[1]) arbiter_result = data_1;
    if (grant[2]) arbiter_result = data_2;
    if (grant[3]) arbiter_result = data_3;
end
```

---

## 2. Target Platform: Xilinx ZU9EG

### 2.1 Device Specifications

| Spec | Value | Notes |
|------|-------|-------|
| **Device** | XCZU9EG-1FFVB1156 | UltraScale+ (Zynq) |
| **LUTs** | 546,000 | FPGA fabric |
| **FFs (flip-flops)** | 1,092,000 | Registers |
| **BRAM18K** | 432 | 18 Kbit blocks; dual-port capable |
| **BRAM36K** | 216 | 36 Kbit blocks (combines 2×18K) |
| **DSPs** | 728 | 27×18 multipliers |
| **I/O Pins** | ~500 | Programmable speed |

### 2.2 Frequency Target

**Clock Frequency**: 150 MHz (assumed in design constraints)

**Timing Period**: $T_{clk} = 1/150\text{ MHz} = 6.67\text{ ns}$

**Routing Margin**: Typical 20–30% slack after placement & routing. Assumes post-route analysis; synthesis may report higher (incorrect) slack.

### 2.3 External Interfaces

**AXI4-Lite (PS ↔ PL)**:
- Master: ARM CPU (PS)
- Slave: PL solver
- Data width: 32 bits
- Address width: 32 bits
- Typical latency: 4–6 cycles (incl. DDR roundtrip)

**DDR4 (via AXI)**:
- Capacity: 2 GB available for solver
- Controller on PS; accessed via AXI4-Lite
- Bandwidth: Limited by AXI frequency (typically 100–150 MHz)
- Latency: ~20 ns (2–3 cycles @ 150 MHz)

### 2.4 Thermal & Power Constraints

| Constraint | Typical | Notes |
|-----------|---------|-------|
| **Tj (Junction Temp)** | < 85°C | Xilinx recommended max |
| **Power Budget** | 20–30 W | PL only (typical) |
| **Thermal Resistance** | ~0.8°C/W | PCB-dependent |

**Mitigation**: Monitor temperature during synthesis; may need reduced frequency or gating if thermal limit approached.

### 2.5 Vivado 2023.4 Synthesis Flow

**Steps**:
1. Elaborate (parse RTL, generate elaborated design)
2. Optimize (logic minimization, resource sharing)
3. Map (assign logic to LUTs/FFs)
4. Place (physical location assignment)
5. Route (interconnect)
6. Bitstream generation

**Key Settings** (in XDC constraints file):
```tcl
# Set clock frequency
create_clock -period 6.667 -name clk [get_ports clk]

# Set I/O voltage (if needed)
set_property IOSTANDARD LVCMOS33 [get_ports {input_port output_port}]

# Reduce optimization to improve timing closure
set_param synth.elaboration.rodinMoreOptions "set_param synth.flowEngineUseIncrementalCompile 1"
```

---

## 3. Module-Level Design Details

### 3.1 Propagation Search Engine (`pse.sv`)

#### FSM States (9 total)

| State | Purpose | Duration | Next State Condition |
|-------|---------|----------|----------------------|
| **IDLE** | Waiting for start signal | 1 cycle | start ← 1 → INIT_SCAN |
| **INIT_SCAN** | Initialize watch list pointers | 1 cycle | → FETCH_CLAUSE |
| **FETCH_CLAUSE** | Read clause entry from BRAM | 1–2 cycles | Clause fetched → CHECK_WLIT |
| **CHECK_WLIT** | Evaluate watched literals | 1 cycle | Both true → FETCH_CLAUSE (next) / One false → SCAN_LITERALS / Both false → DECIDE_PROP |
| **SCAN_LITERALS** | Scan clause literals for backup watcher | 4+ cycles | Found new watcher → FIND_WATCHER / No watcher → (conflict or unit) |
| **FIND_WATCHER** | Update watched literal in clause table | 1 cycle | → FETCH_CLAUSE (next) |
| **PROPAGATE** | Enqueue propagation to trail | 1 cycle | → FETCH_CLAUSE (next) |
| **DONE_STATE** | Signaled end of propagation | 1 cycle | → IDLE (if not conflicted) / CAE takes over (if conflicted) |

**Wall-Clock Time**: ~10 cycles per clause examined (assuming 4 literals per clause).

#### Port Details

**Inputs**:
- `clk`, `reset`
- `start`: Begin propagation phase
- `assignment[VAR_MAX]`: Current variable assignments (multi-read)
- `ct_rd_ptr`: Clause table read pointer (from state machine)

**Outputs**:
- `prop_valid`: Propagation is valid (enqueue to trail)
- `prop_lit`: Propagation literal (32 bits: var + polarity)
- `prop_reason`: Clause that caused propagation (32-bit pointer)
- `conflict_detected`: All literals in clause false
- `conflict_clause`: Pointer to conflicting clause

**Memory Arbitration**:
- Read: Clause table (dual-port BRAM), variable assignments (single-port LUTRAM)
- Write: Trail queue (enqueue propagations)
- Stall signals: If BRAM conflict or trail overflow

#### Resource Estimates

| Resource | Count | Notes |
|----------|-------|-------|
| **LUTs** | 2,000–3,000 | Varies with cursor count |
| **FFs** | 1,500–2,000 | FSM, counters, pipeline registers |
| **LUTRAM** | 2–4 | Small shift registers (pipelining) |
| **BRAM18K** | 0 (shared) | Clause table managed by arbiter |

**Critical Path**: Watch list lookup + literal evaluation ≈ 3 combinational levels → feasible @ 150 MHz with pipelining.

### 3.2 Conflict Analysis Engine (`cae.sv`)

#### FSM States (4 total)

| State | Purpose | Duration | Condition |
|-------|---------|----------|-----------|
| **IDLE** | Waiting for conflict signal | 1 cycle | conflict_detected ← 1 → LOAD |
| **LOAD** | Fetch conflict clause literals | 4 cycles (DDR latency) | Literals ready → SCAN |
| **SCAN** | Walk resolution chain (per conflict analysis algorithm) | Variable | UIP found → Compute backtrack → DONE |
| **DONE** | Assert learned clause + backtrack level | 1 cycle | PSE resumes (loop back to PSE/backtrack phase) |

**Wall-Clock Time**: ~20–50 cycles per conflict (depends on resolution chain depth).

#### Pipelined DDR Fetch Detail

```
Cycle 0: Issue DDR read for lit[addr_0], hold in request queue
Cycle 1: Data not ready yet; issue read for lit[addr_1]
Cycle 2: Data for addr_0 returns; latch to stage[0]
         Issue read for lit[addr_2]
Cycle 3: Data for addr_1 returns; shift: stage[1] ← stage[0], stage[0] ← new
         Issue read for lit[addr_3]
Cycle 4: Data for addr_2 returns; shiftrack
         CAE can now process stage[3] (4-cycle-old data, valid)

Shift registers: stage[0–3] each hold one literal
Multiplex: select which stage has valid data based on age counters
```

**Result**: 4-cycle DDR latency effectively hidden; CAE throughput ~1 literal/cycle after pipeline priming.

#### Port Details

**Inputs**:
- `clk`, `reset`
- `conflict_detected`: Start conflict analysis
- `conflict_clause`: Pointer to conflict clause
- `trail[VAR_MAX]`: Decision history (read-only)
- `var_decision_level[VAR_MAX]`: Per-variable decision level

**Outputs**:
- `learnt_valid`: Learned clause ready
- `learnt_lits[MAX_LEARN_LEN]`: Learned clause literals (array)
- `learnt_len`: Count of learned literals
- `backtrack_level`: Decision level to backtrack to (or -1 for UNSAT)
- `unsat`: Flag if UNSAT detected

#### Resource Estimates

| Resource | Count |
|----------|-------|
| **LUTs** | 1,500–2,000 |
| **FFs** | 2,000–2,500 |
| **LUTRAM** | 4–6 (shift registers, visited bitmap) |
| **BRAM18K** | 0 (shared clause table) |

**Critical Path**: Decision level comparison (combinational) ≈ 2 levels → safe @ 150 MHz.

### 3.3 Variable Decision Engine (`vde.sv`)

#### Min-Heap Operations

**Heap Structure** (array-based):
```
         [0] min activity
        /  \
      [1]   [2]
     / \    / \
   [3] [4][5] [6]
   ...
```

**Operations** (combinational or 1-cycle):

1. **Percolate-Up** (after activity bump):
   ```systemverilog
   for (int i = heap_idx; i > 0; i = parent(i)) begin
       if (activity[i] < activity[parent(i)])
           swap(i, parent(i));
       else break;
   end
   ```

2. **Percolate-Down** (after extract-min):
   ```systemverilog
   for (int i = 0; heap_size > 0; i = smallest_child(i)) begin
       j = smallest_child(i);
       if (j >= heap_size || activity[i] <= activity[j])
           break;
       swap(i, j);
   end
   ```

3. **Extract-Min** (O(log n)):
   - Return `heap[0]` (variable with min activity)
   - Move `heap[heap_size-1]` to `heap[0]`
   - Decrement heap_size
   - Percolate-down

#### Decay Mechanism

```systemverilog
parameter DECAY_INTERVAL = 512;  // Decay every 512 cycles

reg [15:0] decay_counter;
always @(posedge clk) begin
    if (reset) decay_counter <= 0;
    else if (bump_en) decay_counter <= decay_counter + 1;
    
    if (decay_counter == DECAY_INTERVAL) begin
        for (int v = 0; v < VAR_MAX; v++)
            activity[v] <= activity[v] - (activity[v] >> 16);  // Decay by ~0.9275
        decay_counter <= 0;
    end
end
```

**Effect**: Every 512 conflicts, all activities shrink by factor 0.9275, allowing fresh exploration.

#### Port Details

**Inputs**:
- `clk`, `reset`
- `bump_en`, `bump_var`: Activity bump request (from CAE)
- `decay_en`: Trigger decay (from FSM)
- `next_decision_req`: Request next variable (from solver_core)

**Outputs**:
- `decide_valid`: Next variable ready
- `decide_var`: Variable index to branch on
- `decide_phase`: Preferred polarity (true/false)

#### Resource Estimates

| Resource | Count |
|----------|-------|
| **LUTs** | 1,000–1,500 |
| **FFs** | 500–1,000 |
| **LUTRAM** | 1–2 (activity array, phase array, heap) |
| **BRAM18K** | 0 (if heap < 64 vars) or 1 (larger heap) |

### 3.4 Memory Hierarchy & Global Arbiter

#### On-Chip BRAM Layout

```
BRAM18K Usage (432 total on device):

Reserved:    ~250 BRAM18K  (PL DDR controller, AXI infrastructure)
Available:   ~182 BRAM18K

Allocated:
├─ Clause Table          ~22 BRAM18K  (262K × 128 bits)
├─ Variable Table         ~3 BRAM18K  (16K × 96 bits)
├─ Trail Queue           ~3 BRAM18K  (16K × 64 bits FIFO)
├─ Activity Array        ~1 BRAM18K  (16K × 32 bits)
├─ Phase Array           ~0.5 BRAM18K (16K × 1 bit)
├─ Misc (buffers, ctrl)  ~2 BRAM18K
└─ Headroom             ~150 BRAM18K  (available for optimization or expansion)
```

**Dual-Port BRAM Partitioning**:
- Clause Table: Port A (PSE write watcher updates), Port B (CAE read conflict clause)
- Variable Table: Port A (Trail updates assignment), Port B (CAE read decision level)
- Trail Queue: Dedicated FIFO (single effective port)

#### Arbitration Logic

**Fixed-Priority Mux**:
```systemverilog
// Request vector
logic [3:0] mem_req;
assign mem_req = {pse_clause_wr, cae_clause_rd, cae_lit_rd, vde_activity_rd};

// Grants (priority: PSE write > CAE clause > CAE lit > VDE)
logic [3:0] mem_grant;
assign mem_grant[0] = mem_req[0];
assign mem_grant[1] = mem_req[1] & ~mem_req[0];
assign mem_grant[2] = mem_req[2] & ~mem_req[1] & ~mem_req[0];
assign mem_grant[3] = mem_req[3] & ~mem_req[2] & ~mem_req[1] & ~mem_req[0];

// Stall signals
assign pse_stall = ~mem_grant[0] & mem_req[0];
assign cae_stall = ~mem_grant[1] & mem_req[1];
// ...
```

**DDR Request Queue** (AXI4-Lite):
- Small FIFO (8–16 entries) queues DDR requests
- Round-robin or priority selection among requesters
- Responses tagged with requester ID

---

## 4. Arbitration & Concurrency

### 4.1 Read Arbitration Strategy

**Scenario**: Multiple modules (PSE cursors, CAE, VDE) all want to read from same BRAM port.

**Solution**: Fixed-priority multiplexer + stall signals.

```
Priority: PSE0 > PSE1 > PSE2 > PSE3 > CAE > VDE

If PSE0 requests:
  Grant PSE0, stall everyone else

If PSE0 not requesting but PSE1 does:
  Grant PSE1, stall PSE2/3/CAE/VDE

...
```

**Stall Protocol**:
```systemverilog
// When stalled, module suspends and waits
always @(posedge clk) begin
    if (!module_stall) begin
        // Execute: read data, advance state
        rd_addr <= next_addr;
        rd_data_q <= rd_data;  // Latch result
    end
    // else: hold all state, no progress
end
```

### 4.2 Write Arbitration Strategy

**Rule**: At most one writer to any resource per cycle.

**Trail Queue Writes**:
- PSE enqueues propagations
- CAE does not write (no interaction)
- Result: Single writer → simple (no arbiter needed)

**Clause Table Writes** (watchers):
- PSE updates watched literals (2 per clause)
- CAE appends learned clauses (new entries)
- Fixed priority: PSE watcher update > CAE clause append

**Variable Table Writes**:
- PSE assigns variable (updates assignment + decision level)
- CAE updates activity (bump for conflict variables)
- VDE saves phase
- Priority: PSE assign > CAE bump > VDE phase (queued if needed)

### 4.3 Deadlock Prevention

**Potential Issue**: Module A waits for resource held by Module B, which waits for resource held by A.

**Prevention Strategy**:
1. **Acyclic dependency**: Ensure modules never form wait cycle
   - PSE → writes → Trail (PSE producer, CAE consumer; no cycle)
   - CAE → learns → DDR (CAE producer, PSE consumer; no cycle)
   
2. **Timeouts**: If stall > N cycles, report error (non-priority feature)

3. **Resource guarantees**: Ensure all modules eventually get access
   - Use **round-robin** within priority class if multiple requests at same priority

---

## 5. Timing Considerations

### 5.1 Critical Paths

**Path 1: Watch List Lookup → Conflict Detection**

```
input_signal
  ├─ Address generation (1 level)
  ├─ BRAM read (combinational if async, worst case adds 1 level)
  ├─ Literal evaluation (2 levels: AND tree)
  ├─ Update watcher index (1 level: mux)
  └─ Next-state logic (1 level: case)
═════════════════════════════════════════════
Total: ~5–6 levels combinational
Actual: Pipelined into 2–3 stages → safe @ 150 MHz
```

**Path 2: Decision Level Comparison (CAE)**

```
lit_assignment
  ├─ Index into decision_level array (1 level)
  ├─ BRAM read (1 level async)
  ├─ Compare for UIP detection (1 level)
  ├─ AND with seen bitmap (1 level)
  └─ Set next-state (1 level)
═════════════════════════════════════════════
Total: ~4–5 levels
Pipeline: Register decision levels at BRAM output → safe
```

**Path 3: Heap Percolate-Up (VDE)**

```
activity[idx]
  ├─ Compute parent_idx = (idx–1)/2 (shifter, 1 level)
  ├─ Compare activity[idx] < activity[parent] (1 level)
  ├─ Select idx or parent (mux, 1 level)
  ├─ Recursively percolate (unrolled 2–3 times for heaps ≤64 vars)
  └─ Store result (1 level, mux tree)
═════════════════════════════════════════════
Total: ~4–6 levels for full percolate-up (4-level heap)
Pipeline: Not pipelined (combinational) if heap small; FSM if large
```

**Slack Measurement** (Post-Route):
- Expected: 1.5–2.5 ns slack @ 150 MHz (6.67 ns period)
- If < 1.0 ns: Timing violation → need optimization
- If > 2.5 ns: Room for optimization or future features

### 5.2 Pipelining Strategy

**PSE Literal Fetch**:
```
Cycle 0: Issue DDR read request
Cycle 1: Request queued; PSE continues with watch list walk
Cycle 2: Data returns; latch to register
Cycle 3: PSE uses latched data for next scan step
```

Result: DDR latency hidden; PSE throughput maintained.

**CAE Conflict Resolution**:
```
Cycle 0: Start conflict analysis
Cycle 1: Issue read for reason clause
Cycle 2: Latch reason clause; issue next read
Cycle 3: Latch new literals; continue resolution loop
```

Result: Pipelined reads disguise DDR latency.

### 5.3 Clock Domain Crossing (if applicable)

**If PL clock ≠ PS clock**:
- CDC (Clock Domain Crossing) handshake required
- Use synchronizer flops (2-stage cascade) for level signals
- Use gray-code counters for FIFO pointers (safer)

**Current Design**: Assume PL clocked at 150 MHz; PS at lower frequency. AXI4-Lite handles async transfers (built-in).

---

## 6. Resource Estimation & Floor Planning

### 6.1 LUT Budget Breakdown

| Module | LUTs | FF | Estimate Basis |
|--------|------|-----|---|
| **PSE (1 cursor)** | 800–1000 | 400–600 | FSM (9 states), watch list logic, literal evaluation |
| **PSE (2 cursors)** | 1600–1800 | 800–1000 | Dual FSM, dual arbitration |
| **PSE (4 cursors)** | 2800–3500 | 1400–1800 | Quad FSM, complex arbiter |
| **CAE** | 1200–1500 | 1200–1500 | Resolution loop, pipelined DDR, UIP detection |
| **VDE** | 800–1200 | 500–800 | Heap operations, activity decay, phase table |
| **Global Mem Arbiter** | 400–600 | 300–400 | Mux, request queue, grant logic |
| **Solver Core FSM** | 200–300 | 100–150 | Top-level orchestration |
| **Control/Misc** | 800–1200 | 400–600 | Reset sequencing, interrupt logic, counters |
| **TOTAL (4-cursor)** | **8,000–10,000** | **5,000–7,000** | ~2–2.5% LUTs, ~1% FFs of XCZU9EG |

### 6.2 BRAM Budget Breakdown

| Table | Bits | BRAM18K | Notes |
|-------|------|---------|-------|
| Clause Table | 262K × 128 | ~22 | Dual-port (read/write separate ports) |
| Variable Table | 16K × 96 | ~3 | Dual-port |
| Trail Queue | 16K × 64 | ~3 | FIFO (can use LUTRAM alternative) |
| Activity | 16K × 32 | ~1 | Single-port |
| Phase | 16K × 1 | ~0.5 | Single-port, can use LUTRAM |
| Misc | — | ~2 | Buffers, status registers |
| **TOTAL** | — | **~32** | ~7% of 432 BRAM18K (plenty of headroom) |

### 6.3 DSP Budget

**DSPs Needed**: 0–2

- Shifts (activity decay): Implemented as combinational barrel shifters (no DSP)
- Comparisons: Implemented as LUT trees (no DSP)
- Future: If implementing floating-point activity scores, would need DSPs

**Current Status**: No DSPs used → can use them for future enhancements (e.g., more aggressive pipelining).

### 6.4 Floor Planning Recommendations

**Placement Regions** (Vivado):
```
┌─────────────────────────────────────┐
│         XCZU9EG Floorplan           │
├─────────────────────────────────────┤
│ PS (CPU, DDR controller, AXI) │     │  Always in lower half
├─────────────────────────────────────┤
│ PL Solver RTL                       │  Upper half (flexible)
│                                     │
│ ┌──────────────────────────────┐   │
│ │ Clause/Variable BRAM (core)  │   │  Central location (optimal routing)
│ │                              │   │
│ └──────────────────────────────┘   │
│                                     │
│ ┌──────────┐ ┌──────────┐          │
│ │   PSE    │ │   CAE    │          │  Left/Right halves
│ └──────────┘ └──────────┘          │
│                                     │
│      ┌──────────┐                   │
│      │   VDE    │                   │  Top (easier timing closure)
│      └──────────┘                   │
└─────────────────────────────────────┘
```

**Rationale**: 
- Core BRAM centrally located → minimize routing to/from PSE/CAE/VDE
- PSE/CAE distributed for load balancing
- VDE at top (smaller, less congestion)

---

## 7. Synthesizability Checklist

✅ All modules use synthesizable SystemVerilog (IEEE 1364.1)  
✅ No dynamic allocation; all sizes fixed via parameters  
✅ Explicit FSMs (prefer enum for states)  
✅ No blocking assignments in sequential logic  
✅ Clock and reset explicitly instantiated  
✅ All ports fully defined (width, direction)  
✅ Verilator 5.020 compatible (tested)  
✅ No `initial` blocks with procedural logic  
✅ All `for` loops unrolled or converted to FSM states  
✅ No `while`, `repeat`, or `do-while` loops  
✅ No `$random`, `$signed`, or other simulation-only constructs  

**Verification Tool**: 
```bash
verilator --lint-only -Wno-unused src/Mega/*.sv  # Dry-run syntax check
vivado -mode batch -source check_synth.tcl       # Actual synthesis test
```

---

## 8. Optimization Guidelines

### 8.1 For Speed (Timing Closure)

**Reduce Critical Path Length**:
1. **Add pipeline stages**: Break long combinational chains into multi-cycle paths
2. **Reduce watch list depth**: Use 2-watched (current) instead of all-watched
3. **Parallel comparisons**: Implement decision-level comparison as tree (log-depth) instead of sequential
4. **Clock gating**: Disable unused modules (e.g., VDE when PSE done) to reduce power+delay

**Example: Add Register Between Watch List Lookup & Literal Evaluation**
```systemverilog
// Before (long path):
wire [31:0] watch_lit = clause_table[clause_idx].watch_lit1;
assign wlit_value = assignment[watch_lit[31:1]];  // Long combinational chain

// After (pipelined):
reg [31:0] watch_lit_q;
always @(posedge clk)
    watch_lit_q <= clause_table[clause_idx].watch_lit1;
    
assign wlit_value = assignment[watch_lit_q[31:1]];  // Shorter path
```

### 8.2 For Area (Resource Usage)

**Reduce LUT Usage**:
1. **Single cursor**: Replace 4-cursor PSE with 1-cursor (saves ~2500 LUTs) at cost of throughput
2. **Compress data structures**: Remove LBD field from clause (saves 16 bits × 262K ≈ 1 BRAM18K)
3. **Shared arithmetic**: Reuse adders/comparators across modules (complex, low ROI)
4. **Memory sharing**: Use same BRAM for trail + activity (if access patterns don't conflict)

**Example: Single-Cursor PSE**
```systemverilog
parameter NUM_CURSORS = 1;  // Reduced from 4

// In PSE module: single FSM instead of parallel
// ~75% LUT reduction, ~50% FF reduction
```

### 8.3 For Power

**Dynamic Power Reduction**:
1. **Clock gating**: Gate PSE clocks when idle (requires clock gating cell)
2. **Reduce frequency**: Lower target from 150 MHz to 100 MHz (impacts performance)
3. **Activity factor**: Minimize spurious toggles (e.g., mux output even when not used)

**Static Power**: Primarily device leakage; minor impact from design choices.

---

## 9. Verification-Specific Considerations

### 9.1 Testbench Synthesis (Verilator Co-Simulation)

**Architecture**:
```
C++ Harness (sim_main.cpp)
  ├─ Parse DIMACS CNF file
  ├─ Instantiate Verilator module (Vtb_verisat)
  ├─ Drive clock, reset, data inputs
  ├─ Collect outputs, verify correctness
  └─ Print results (SAT/UNSAT, cycle count)

Verilator Generated Module
  ├─ DPI-C calls to C++ (for CNF parsing, file I/O)
  ├─ Cycle-accurate simulation
  ├─ Waveform generation (VCD format)
  └─ Code coverage collection
```

**Key Files**:
- [sim/tb_verisat.sv](../sim/tb_verisat.sv) — SystemVerilog testbench
- [sim/sim_main.cpp](../sim/sim_main.cpp) — C++ harness
- [sim/Makefile](../sim/Makefile) — Build rules

### 9.2 Assertion-Based Verification

**SVA (SystemVerilog Assertions)** embedded in RTL:

```systemverilog
// FSM invariant: can't transition from IDLE directly to SCAN
property valid_pse_transitions;
    @(posedge clk) (state == IDLE) |-> (next_state == INIT_SCAN);
endproperty

assert property(valid_pse_transitions)
    else $error("Invalid PSE transition from IDLE");
```

**Coverage Goals**:
- FSM state coverage: All states visited
- FSM transition coverage: All transitions taken
- Memory access coverage: All read/write combinations exercised

---

## 10. Real-World Hardware Deployment

### 10.1 AXI4-Lite Interfacing

**Register Map** (hypothetical):
```
Offset  | Width | Name              | Description
--------|-------|-------------------|----------------------------
0x00    | 32b   | CONTROL           | Start, reset, mode bits
0x04    | 32b   | STATUS            | READY, DONE, RESULT (SAT/UNSAT/TIMEOUT)
0x08    | 32b   | CYCLE_COUNT_LO    | Lower 32 bits of cycle counter
0x0C    | 32b   | CYCLE_COUNT_HI    | Upper 32 bits
0x10    | 32b   | CNF_ADDR          | Base address of CNF in DDR
0x14    | 32b   | CNF_SIZE          | Size of CNF (bytes)
0x18    | 32b   | SOLUTION_ADDR     | Write address for solution
0x1C    | 32b   | INTR_ENABLE       | Interrupt enable mask
--------|-------|-------------------|----------------------------
```

**Protocol**:
1. PS writes CONTROL = START (bit 0)
2. PL begins solving
3. PL asserts DONE when finished, sets RESULT (SAT=0, UNSAT=1, TIMEOUT=2)
4. PS reads STATUS to check DONE
5. PS reads solution from SOLUTION_ADDR (if SAT)

### 10.2 DDR4 Configuration

**Memory Controller Settings** (in Xilinx Vivado MIG wizard):
- Frequency: 300 MHz (DDR frequency; 150 MHz PL can access via AXI @ half-rate)
- Data width: 64 bits
- Refresh rate: Default (7.8 µs)
- ECC: Optional (adds latency)

**Bandwidth Calculation**:
- DDR4 @ 300 MHz: 300 MHz × 8 bytes/cycle = 2.4 GB/s
- AXI4-Lite @ 150 MHz: 150 MHz × 4 bytes/word = 600 MB/s
- Effective: Limited by AXI4-Lite narrower width & protocol overhead

**Latency Hiding**: Use pipelined DDR requests to maintain throughput despite round-trip latency.

### 10.3 Design Closure (Synthesis → Bitstream)

**Typical Flow**:
1. **Synthesis** (vivado -mode batch): RTL → netlist, ~10–30 min
2. **Place & Route** (vivado -mode batch): Netlist → physical design, ~30–60 min
3. **Timing Analysis**: Post-route timing report; if failed, optimize & retry
4. **Power Analysis**: Estimate power consumption
5. **Bitstream Generation**: Generate FPGA programming file, ~5 min

**Timing Closure Tips**:
- Add timing constraints in XDC file (clock period, I/O delays)
- Use `set_property KEEP TRUE [get_cells {hierarchy}]` to prevent optimization if needed
- Enable Vivado's auto-pipelining (Synthesis Settings > Pipeline Style)
- Run phys_opt to improve post-route timing

**Example XDC** (create_clock, set_property):
```tcl
# Constrain clock
create_clock -period 6.667 -name clk_pllsys [get_pins {pll/CLKOUT0}]

# I/O timing (if using external interfaces)
set_input_delay -clock clk_pllsys -min 2.0 [get_ports {data_in}]
set_input_delay -clock clk_pllsys -max 4.0 [get_ports {data_in}]
set_output_delay -clock clk_pllsys -min 1.0 [get_ports {data_out}]
set_output_delay -clock clk_pllsys -max 3.0 [get_ports {data_out}]
```

---

## 11. References

**Xilinx Documentation**:
- XCZU9EG Device Data Sheet
- Vivado Design Suite User Guide (Synthesis, Place & Route, Timing Closure)
- AXI4-Lite Interface Specification (AMBA AXI4 Protocol)

**Hardware Verification**:
- IEEE 1800 (SystemVerilog LRM)
- IEEE 1364.1 (Verilog Synthesis)
- SVA (SystemVerilog Assertions) Tutorial

**Performance Analysis**:
- Xilinx Power Analyzer Guide
- Timing Analysis Best Practices (Xilinx Application Notes)

---

**For detailed code examples**, refer to [src/Mega/](../src/Mega/) RTL files.

**Last Updated**: January 2026
