# SatSwarmv2 Swarm Architecture Migration Status

## Completed (Phase 1: Infrastructure)

### ✅ Module Creation
- **verisat_pkg.sv**: Updated with swarm types
  - Added GRID_X, GRID_Y, CORE_ID_W parameters
  - Created `msg_type_t` enum: MSG_DIVERGE, MSG_CLAUSE, MSG_STATUS
  - Created `noc_packet_t` struct: msg_type, payload_lit, quality_metric, src_id, virtual_channel
  - Extended `var_metadata_t` with assumption field
  - Extended `clause_metadata_t` with global_ptr field
  - Extended `trail_entry_t` with is_forced field

- **interface_unit.sv** (150 lines): Per-core NoC packet handler
  - Packet muxing: MSG_DIVERGE > MSG_CLAUSE > MSG_STATUS priority
  - Divergence force handling: receives forced literals from neighbors
  - Ready/valid flow control on 4 incoming/outgoing ports
  - Neighbor status tracking

- **mesh_interconnect.sv** (60 lines): 2D mesh packet router
  - 4-port per-core (N/S/E/W on indices [3:2:1:0])
  - X-Y dimension order routing
  - Direct peer-to-peer connectivity (no pipelining in this version)
  - Pass-through operation for minimal latency

- **global_mem_arbiter.sv** (90 lines): AXI4-style DDR4 multiplexer
  - Read arbiter (higher priority) with round-robin scheduling
  - Write arbiter (lower priority) stalled during reads
  - Per-core read_grant/read_data/read_valid
  - Per-core write_grant

- **solver_core.sv** (184 lines): Cooperative solver instance
  - Local memory: var_table, clause_header_table, trail (stubs; will be populated by PSE/CAE/VDE)
  - FSM: IDLE → INIT → DECISION → {BCP, CONFLICT, BACKTRACK, CHECK_SAT, UNSAT_STATE}
  - interface_unit instantiated and connected
  - PSE/CAE/VDE currently stubs (all return done=1 with no conflict/UNSAT)
  - Support for divergence via interface_unit signals

- **satswarm_top.sv** (180 lines): Top-level 2x2 grid integration
  - Generates 4 solver_core instances [Y][X]
  - Instantiates mesh_interconnect and global_mem_arbiter
  - Connects cores bidirectionally via 4-port mesh
  - Aggregates results from all cores (any_done, any_sat, any_unsat)
  - Host I/O interface (load CNF, read results)

### ✅ Compilation & Testing
- Clean Verilator compilation with Vivado 2023.4 synthesis warnings only (no errors)
- Testbench updated to work with new satswarm_top
- Test suite runs on new architecture
  - simple_sat1 (1 var, 1 unit clause): **PASS** (correctly reports SAT)
  - simple_unsat1 (2 clauses with contradiction): **FAIL** (reports SAT due to stub PSE/CAE)
  - Other tests pending PSE/CAE/VDE integration

### ✅ Bug Fixes Applied
1. **Enum initialization error**: Replaced `'{default: '0}` with explicit field assignments in mesh_interconnect to avoid implicit enum conversion
2. **Multi-driver on load_ready**: Ensured consistent assignment across all cores
3. **Latch inference**: Added default initializations in solver_core always_comb for all internal signals
4. **Integer variable scoping**: Added `integer i` declarations inside always_comb blocks in global_mem_arbiter

---

## In Progress (Phase 2: Core Integration)

### 🟡 PSE/CAE/VDE Integration
- [ ] Instantiate actual pse, cae, vde modules inside solver_core
- [ ] Connect PSE propagation outputs to solver_core state management
- [ ] Connect CAE learned clause outputs to local clause_header_table
- [ ] Connect VDE decision outputs to trail and decision_level management
- [ ] Remove stubs; implement real FSM control signals

---

## Not Started (Phase 3: Cooperative Features)

### ⏳ Divergence Propagation
- [ ] When VDE makes a decision (e.g., x=1), multicast forced literal (x∨¬x) to idle neighbors
- [ ] Receiving core applies forced literal to all clauses (shortcut BCP)
- [ ] Track assumption field in var_metadata_t to distinguish forced vs. decided vars

### ⏳ Clause Sharing
- [ ] CAE broadcasts learned clauses with LBD to all neighbors after conflict analysis
- [ ] Receiving cores import high-quality clauses (LBD < threshold) into local clause store
- [ ] Track global_ptr in clause_metadata_t to reference shared literals in DDR4

### ⏳ Restart & Phase Saving
- [ ] Implement LBD-based restart policy (reference spec.md Algorithm 1)
- [ ] Implement phase saving around restarts for faster re-exploration

---

## Build & Test Status

### Compilation
```
Verilator 5.044
Source: 0.970 MB (18 modules)
Build time: ~2.6s (on M1 Mac)
Status: ✅ CLEAN (no errors, 8 warnings for stubs)
```

### Test Results (Current)
| Test | Expected | Actual | Status |
|------|----------|--------|--------|
| simple_sat1 | SAT | SAT | ✅ PASS |
| simple_unsat1 | UNSAT | SAT | ❌ FAIL (stub) |
| simple_sat2 | SAT | ? | ⏳ Pending |
| simple_sat3 | SAT | ? | ⏳ Pending |
| simple_unsat2 | UNSAT | ? | ⏳ Pending |

---

## Directory Structure

```
src/rtl/
├── verisat_pkg.sv              ✅ Updated with swarm types
├── interface_unit.sv           ✅ NEW: NoC packet handler
├── mesh_interconnect.sv        ✅ NEW: 2D router
├── global_mem_arbiter.sv       ✅ NEW: DDR4 arbitration
├── solver_core.sv              ✅ NEW: Cooperative solver core
├── satswarm_top.sv             ✅ NEW: 2x2 grid integration
├── pse.sv                       (existing; to be wired into solver_core)
├── cae.sv                       (existing; to be wired into solver_core)
├── vde.sv                       (existing; to be wired into solver_core)
└── (other existing modules)

sim/
├── tb_verisat.sv               ✅ Updated for satswarm_top
├── Makefile                    ✅ Updated to include new RTL
└── sim_main.cpp                (existing test harness)

tests/
├── simple_sat*.cnf             (3 SAT test cases)
├── simple_unsat*.cnf           (2 UNSAT test cases)
└── (benchmarks)
```

---

## Next Steps (Recommended Order)

### 1. Verify Single-Core Operation
- [ ] Wire PSE/CAE/VDE into solver_core FSM
- [ ] Run simple_sat1 and simple_unsat1 to confirm correct SAT/UNSAT detection
- [ ] Verify trail updates and backtracking work correctly

### 2. Validate Multi-Core Grid
- [ ] Confirm mesh routing connects all 4 cores bidirectionally
- [ ] Verify global_mem_arbiter handles simultaneous read/write requests
- [ ] Check no_packet drops or deadlocks in NoC

### 3. Implement Divergence Propagation
- [ ] Test forced literals reach idle neighbors
- [ ] Verify assumption tracking in var_metadata_t
- [ ] Validate divergence helps solve harder problems faster

### 4. Implement Clause Sharing
- [ ] Test learned clauses broadcast correctly
- [ ] Verify import of high-LBD clauses improves search
- [ ] Benchmark multi-core solving vs. single-core

---

## Key Design Decisions

1. **Hybrid Memory Model**: Per-core local tables + shared global DDR4 for literals
2. **Stubbed Approach**: PSE/CAE/VDE are "null" implementations initially; can integrate real modules later
3. **2x2 Grid (Configurable)**: Easy to extend to 4x4 or larger with GRID_X/GRID_Y parameters
4. **Dimension-Order Routing**: Simplifies mesh logic; prevents deadlock without virtual channels
5. **Cooperative Search**: Divergence + clause sharing = faster SAT/UNSAT detection

---

## Notes

- All modules synthesizable with Xilinx Vivado 2023.4
- Target: XCZU9EG @ 150 MHz (currently simulated at 100 MHz)
- Testbench uses mock DDR4 (always grants reads/writes)
- Full PSE/CAE/VDE implementations available in src/rtl/ for integration
