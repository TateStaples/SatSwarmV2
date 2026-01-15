# Testing & Verification Guide: SAT Solver Validation & Benchmarking

A comprehensive strategy for unit testing, integration testing, system validation, regression testing, and performance benchmarking of the SatSwarmv2 FPGA SAT solver.

---

## 1. Testing Overview

### 1.1 Test Pyramid

```
                        ▲
                       / \
                      /   \   System Tests (Full Solver)
                     /     \  • Functional correctness on CNF instances
                    /       \ • SATCOMP/SATLIB benchmarks
                   /_________\
                  /           \
                 /             \ Integration Tests (Multi-Module)
                /               \ • PSE + Trail + Variable Table
               /                 \ • CAE + Clause Append
              /__________________\
             /                     \
            /                       \ Unit Tests (Single Module)
           /                         \ • PSE FSM state transitions
          /                           \ • CAE conflict resolution
         /_____________________________\ • VDE heap operations
                                        \ • Arbiter deadlock-free
        ┌─────────────────────────────────┐
        │  Regression Tests (Performance)  │
        │  • Baseline cycle counts          │
        │  • +5% variance threshold         │
        │  • Resource estimation accuracy   │
        └─────────────────────────────────┘
```

**Scope**:
- **Unit Tests**: Verify individual module behavior in isolation
- **Integration Tests**: Verify module interactions (e.g., PSE→CAE→VDE)
- **System Tests**: Verify end-to-end SAT solving on real CNF instances
- **Regression Tests**: Detect performance degradation in commits
- **Benchmarks**: Measure against industrial test suites (SATCOMP, SATLIB)

### 1.2 Test Infrastructure

**Verilator Simulation** (`sim/Makefile`):
```bash
make clean      # Remove compiled artifacts
make            # Compile RTL with Verilator 5.020
make test       # Run regression suite
make wave       # Generate waveform (VCD)
make profile    # Collect performance metrics
```

**Test Harness** (`sim/sim_main.cpp`):
- Parses DIMACS CNF input
- Instantiates Verilator-generated module
- Drives clock, reset, data inputs
- Collects outputs, validates results
- Reports cycle counts and performance

**Testbench** (`sim/tb_verisat.sv`):
- SystemVerilog wrapper
- Memory initialization
- Clock/reset generation
- Assertion monitoring
- Waveform capture

### 1.3 Acceptance Criteria

**Correctness**: Every test case must return correct SAT/UNSAT answer
- **SAT**: Verify proposed solution by substitution into all clauses
- **UNSAT**: Verify unsatisfiability via proof checker (future) or reference solver comparison

**Performance**: No regression beyond ±5% on baseline cycle counts
- Baseline established after each release
- Tracked per CNF instance

**Resource Usage**: Synthesis must meet area targets
- LUTs: < 15% of XCZU9EG (~80K)
- BRAMs: < 10% of 432 (~43)
- Power: < 25 W estimated

**Stress Testing**: Solver handles resource exhaustion gracefully
- Memory full → return UNSAT or timeout (not crash)
- Clause table overflow → handled cleanly
- Trail overflow → stall gracefully

---

## 2. Unit Testing

### 2.1 PSE (Propagation Search Engine)

#### Test: Unit Clause Detection

**Objective**: Verify PSE correctly identifies and propagates unit clauses.

**Setup**:
```
Clause 0: (x₁ ∨ x₂ ∨ x₃)     watch_lit1=x₁, watch_lit2=x₂
Clause 1: (¬x₁ ∨ x₃)          watch_lit1=¬x₁, watch_lit2=x₃
Clause 2: (x₂)                 watch_lit1=x₂, watch_lit2=0 (unit clause)

Assignments (input):
  x₁ = false, x₂ = unassigned, x₃ = false
```

**Execution**:
1. Start PSE
2. Scan clause 0: watch_lit1 (x₁) = false, watch_lit2 (x₂) = unassigned
   - Scan clause for backup watcher → find x₃ (false, no good)
   - Clause 0 still has unassigned → no propagation
3. Scan clause 1: watch_lit1 (¬x₁) = true → clause satisfied
4. Scan clause 2: watch_lit1 (x₂) = unassigned → unit clause
   - Enqueue propagation: x₂ ← true

**Verification**:
```systemverilog
assert (prop_valid && prop_lit == {2, 1})  // Variable 2, polarity 1 (true)
    else $error("Unit clause detection failed");
```

#### Test: Conflict Detection

**Objective**: Verify PSE detects unsatisfiable clauses.

**Setup**:
```
Clause 0: (x₁ ∨ x₂)      watch_lit1=x₁, watch_lit2=x₂

Assignments (input):
  x₁ = false, x₂ = false
```

**Expected**: PSE scans clause 0, finds both watched literals false, signals conflict.

**Verification**:
```systemverilog
assert (conflict_detected && conflict_clause == 0)
    else $error("Conflict detection failed");
```

#### Test: Cursor Arbitration Under Contention

**Objective**: Verify multiple cursors don't corrupt shared state.

**Setup**:
```
Cursor 0 reads clause 0, cursor 1 reads clause 1 (different clauses → no collision)
Cursor 0 writes watcher to clause 2, cursor 1 reads clause 2 (collision!)
```

**Expected**: Arbiter stalls cursor 1; cursor 0 write completes first; cursor 1 then reads updated value.

**Verification**:
```systemverilog
assert (!cursor1_valid_until cursor0_done)
    else $error("Cursor 1 got stale data");
```

#### Testbench File

Location: `sim/tb_pse_unit.sv` (to be generated)

```systemverilog
module tb_pse_unit ();
    parameter VAR_MAX = 16;
    parameter CLAUSE_MAX = 8;
    
    // Instantiate PSE
    pse #(.VAR_MAX(VAR_MAX), .PTR_W(3)) dut (
        .clk(clk), .reset(reset), .start(start),
        .assignment(assignment), 
        .prop_valid(prop_valid), .prop_lit(prop_lit),
        .conflict_detected(conflict_detected)
    );
    
    // Clock generation
    reg clk = 0;
    always #5 clk = ~clk;
    
    // Test: unit clause detection
    initial begin
        reset = 1; #20; reset = 0;
        // Load clause table...
        // Set assignments...
        start = 1; #10; start = 0;
        // Wait for result...
        @(posedge prop_valid);
        assert (prop_lit == expected) else $error("Test failed");
        $finish;
    end
endmodule
```

### 2.2 CAE (Conflict Analysis Engine)

#### Test: First-UIP Clause Learning

**Objective**: Verify CAE produces correct learned clause.

**Setup**: (From Algorithm Guide § 8.2 Worked Example)
```
Conflict clause: (¬x₃ ∨ ¬x₄)
Trail history: [x₁@L1(dec), x₂@L2(dec), x₃@L2(r:C2), x₄@L2(r:C3)]
Decision levels: x₁→L1, x₂→L2, x₃→L2, x₄→L2

Expected learned clause: (x₂ ∨ x₁) [approximately]
Expected backtrack level: 1
```

**Execution**:
1. CAE receives conflict clause
2. Walks implication graph (via trail + reason pointers)
3. Performs resolution (in simplified mode)
4. Identifies UIP (¬x₂ in this example)
5. Returns learned clause + backtrack level

**Verification**:
```systemverilog
assert (learnt_valid && learnt_len == 2 && backtrack_level == 1)
    else $error("First-UIP learning failed");
```

#### Test: Clause Minimization

**Objective**: Verify CAE removes redundant literals (simplified heuristic).

**Setup**:
```
Initial resolution clause: (l₁ ∨ l₂ ∨ l₃ ∨ l₄)
If l₃'s reason clause is subset of {l₁, l₂, l₄} → l₃ is redundant
```

**Expected**: CAE removes l₃ from learned clause.

**Verification**:
```systemverilog
assert (learnt_len < initial_len)  // At least one literal removed
    else $warning("Minimization may not be implemented");
```

#### Testbench File

Location: `sim/tb_cae_unit.sv`

### 2.3 VDE (Variable Decision Engine)

#### Test: Activity Scoring & Decay

**Objective**: Verify VSIDS activity updates and decay.

**Setup**:
```
Initial: activity[x₁] = 100, activity[x₂] = 50
Bump x₁: activity[x₁] should increase to 1100
Decay: activity[x₁] should decrease by ~0.9275 factor
```

**Expected**:
```
After bump: activity[x₁] = 1100
After decay: activity[x₁] ≈ 1100 - (1100 >> 16) ≈ 1099 (minimal change for large value)
```

**Verification**:
```systemverilog
// Bump test
@(posedge bump_trigger);
#1 assert (activity_updated > activity_before)
    else $error("Activity bump failed");

// Decay test
@(posedge decay_trigger);
#1 assert (activity_decayed < activity_before)
    else $error("Activity decay failed");
```

#### Test: Heap Operations (Extract-Min)

**Objective**: Verify heap maintains min-property after extract-min.

**Setup**:
```
Insert variables: x₁(act=100), x₂(act=50), x₃(act=200), x₄(act=75)
Expected heap: [50, 75, 200, 100] (roughly; exact depends on implementation)
```

**Extract-Min**:
```
extract_min() → returns x₂ (activity=50)
Heap reorganized → [75, 100, 200] (next min is x₄)
```

**Verification**:
```systemverilog
@(posedge extract_min);
#1 assert (returned_var == expected_min_var)
    else $error("Extract-min failed");
    
// Verify remaining heap is valid (parent ≤ child)
for (int i = 0; i < heap_size; i++)
    assert (activity[heap[i]] <= activity[heap[2*i+1]] &&
            activity[heap[i]] <= activity[heap[2*i+2]])
        else $error("Min-heap property violated");
```

### 2.4 Arbitration Unit Test

#### Test: Read Stall on RAW Hazard

**Objective**: Verify arbiter stalls readers when conflicting writes.

**Setup**:
```
PSE issues write to clause_table[5]
CAE issues read from clause_table[5] simultaneously
```

**Expected**: CAE receives stall signal; write completes; CAE reads updated value.

**Verification**:
```systemverilog
assert (cae_stall_until pse_write_done)
    else $error("Arbiter failed to prevent RAW hazard");
    
@(posedge pse_write_done);
assert (cae_data == written_value)
    else $error("CAE read stale data");
```

#### Test: No Deadlock

**Objective**: Verify arbiter never creates cyclic wait (A waits for B, B waits for A).

**Strategy**: Run multi-requestor scenario for 1000+ cycles; check no request stalls infinitely.

**Verification**:
```systemverilog
reg [31:0] stall_count [NUM_MODULES];
always @(posedge clk)
    for (int i = 0; i < NUM_MODULES; i++)
        if (module_stall[i])
            stall_count[i]++;
        else
            stall_count[i] <= 0;  // Reset on grant

assert (stall_count[i] < MAX_STALL_CYCLES)  // e.g., 100 cycles max
    else $error("Possible deadlock detected");
```

---

## 3. Integration Testing

### 3.1 PSE + Trail + Variable Table

**Objective**: Verify propagation updates trail correctly.

**Test Scenario**:
```
CNF: (x₁ ∨ x₂) ∧ (¬x₁ ∨ x₃) ∧ ...
Decision: x₁ ← false (L1)
Expected propagations: x₂ ← true, x₃ ← true (L1)
```

**Verification**:
1. PSE enqueues propagation: x₂ ← true
2. Trail queue stores: {x₂, true, level=1, is_prop=true, reason=clause_0}
3. Variable table updated: var_table[2] = {assigned=true, level=1, reason=clause_0}
4. Repeat for x₃

**Testbench**: `sim/tb_propagation_int.sv`

### 3.2 CAE + Clause Append + DDR

**Objective**: Verify learned clauses append to DDR and are discoverable.

**Test Scenario**:
```
Conflict triggers CAE
CAE learns clause: (¬x₂ ∨ x₁)
Clause appended to DDR at pointer = next_ptr (e.g., 1000)
PSE should be able to read learned clause later
```

**Verification**:
1. CAE issues DDR write (learned clause literals)
2. next_ptr increments
3. Clause table entry created with pointer = old next_ptr
4. Later PSE scan encounters learned clause, reads literals from DDR

**Testbench**: `sim/tb_learning_int.sv`

### 3.3 VDE + Activity Update (from CAE)

**Objective**: Verify CAE's activity bump reaches VDE correctly.

**Test Scenario**:
```
Conflict on variable x₃
CAE signals: bump_en = 1, bump_var = 3
VDE receives bump: activity[3] += 1000
Next extract-min should prefer x₃ if other activities lower
```

**Verification**:
```systemverilog
@(posedge bump_signal);
#1 @(posedge clk);
assert (activity[bump_var] > activity_before + 900)  // Allow some variation
    else $error("Activity bump not received by VDE");
```

**Testbench**: `sim/tb_decision_int.sv`

### 3.4 Full Solver FSM (PSE → CAE → VDE)

**Objective**: Verify correct state transitions and termination (SAT/UNSAT).

**Test Case 1**: Simple SAT instance
```
CNF: (x₁ ∨ x₂) with no conflicts
Expected: PSE propagates → no conflict → VDE decides → loop → SAT
```

**Test Case 2**: Simple UNSAT instance
```
CNF: (x₁) ∧ (¬x₁)
Expected: PSE detects conflict immediately → CAE backtrack level < 0 → UNSAT
```

**Verification**:
```systemverilog
assert (result == SAT || result == UNSAT || result == TIMEOUT)
    else $error("Invalid result");

if (result == SAT)
    verify_sat_solution();  // Substitute into all clauses
else if (result == UNSAT)
    verify_unsat_proof();   // (deferred feature)
```

**Testbench**: `sim/tb_solver_fsm_int.sv`

---

## 4. System Testing

### 4.1 Functional Correctness Tests

**Test Suite**:
```
tests/gen_sat_5v.cnf          5 variables, SAT
tests/gen_sat_10v_1.cnf       10 variables, SAT
tests/gen_unsat_6v_1.cnf      6 variables, UNSAT
tests/gen_unsat_10v_2.cnf     10 variables, UNSAT
tests/minimal.cnf             Minimal example (2-3 clauses)
tests/289-sat-6x30.cnf        Industrial SAT instance (720 vars, 27K clauses)
```

**Execution**:
```bash
for cnf in tests/*.cnf; do
    result=$(./obj_dir/Vtb_verisat < $cnf)
    expected=$(reference_solver $cnf)
    [ "$result" == "$expected" ] || echo "FAIL: $cnf"
done
```

**Pass Criteria**: All test cases return correct SAT/UNSAT answer.

### 4.2 Solution Verification (SAT)

**Algorithm**:
```
For each clause in CNF:
    For each literal in clause:
        Evaluate literal against solution
    If any literal true → clause satisfied
    Else → FAIL

If all clauses satisfied → PASS
```

**Code** (sim/sim_main.cpp):
```cpp
bool verify_sat_solution(const CNF& cnf, const Assignment& solution) {
    for (const auto& clause : cnf.clauses) {
        bool clause_satisfied = false;
        for (const auto& lit : clause) {
            int var = lit.var;
            bool polarity = lit.polarity;
            if (solution[var] == polarity) {
                clause_satisfied = true;
                break;
            }
        }
        if (!clause_satisfied) return false;  // Clause not satisfied
    }
    return true;  // All clauses satisfied
}
```

### 4.3 UNSAT Core Extraction (Future)

**Deferred Feature**: Verify unsatisfiability via proof extraction.

**Strategy**:
- CAE learns sequence of clauses
- Final learned clause is empty (contradiction)
- Trace back through resolution chain to original clauses
- Minimal set of original clauses forming UNSAT core

### 4.4 Performance Testing

**Metrics Collected**:
- Cycle count (from solver_core.cycle_counter)
- Decision count (from VDE)
- Conflict count (from CAE signals)
- Trail depth (from trail_manager)

**Profiling Code** (sim/tb_verisat.sv):
```systemverilog
reg [63:0] cycle_count, decision_count, conflict_count;

always @(posedge clk) begin
    if (solver_running) begin
        cycle_count <= cycle_count + 1;
        if (vde_decide_valid)
            decision_count <= decision_count + 1;
        if (cae_conflict_detected)
            conflict_count <= conflict_count + 1;
    end
end

// Print statistics
always @(solver_finished) begin
    $display("Cycles: %d, Decisions: %d, Conflicts: %d",
             cycle_count, decision_count, conflict_count);
end
```

### 4.5 Stress Testing

**Large Instances**:
```
tests/large_sat_500v_5k.cnf       500 variables, 5K clauses (generated or sourced)
tests/large_unsat_1k_10k.cnf      1000 variables, 10K clauses
```

**Extreme Conditions**:
- DDR memory near full (1M literals)
- Clause table near capacity (262K clauses)
- Trail saturated (16K assignments)

**Expected**: No overflow crashes; graceful timeout or UNSAT return.

---

## 5. Regression Testing

### 5.1 Regression Test Suite

**Size**: 20–30 representative CNF instances (mix of SAT/UNSAT, small/medium/large).

**Examples**:
```
tests/regression/uf20_01.cnf      20 vars, Random 3-SAT
tests/regression/uuf50_01.cnf     50 vars, Random 3-UNSAT
tests/regression/aim-200.cnf      200 vars, Application (AIM benchmark)
tests/regression/bmc_large.cnf    300 vars, Bounded Model Checking
...
```

**Baseline Establishment**:
```
Commit to main branch: Measure cycle counts for all 20–30 instances
Store in regression_baseline.txt with format:
  filename,cycles,decisions,conflicts
  uf20_01.cnf,1000,50,20
  uuf50_01.cnf,5000,200,150
  ...
```

### 5.2 Regression Gates (Performance)

**Threshold**: ±5% variance allowed per instance.

**Calculation**:
```
delta = (new_cycles - baseline_cycles) / baseline_cycles * 100%

If |delta| > 5%:
    PR BLOCKED until optimized or threshold raised with justification
```

**Example Gate Failure**:
```
uf20_01.cnf: baseline=1000, new=1100 → delta=+10% → FAIL
Recommendation: Profile PSE/CAE/VDE to identify bottleneck
```

### 5.3 Baseline Management

**Update Procedure** (Quarterly or on major release):
1. Establish consensus on main branch (all tests passing)
2. Run regression suite on stable build
3. Record cycle counts + environment (frequency, cursor count, decay rate, etc.)
4. Document baseline in CHANGELOG
5. Future regressions measured against this baseline

**Version Control**:
```
regression_baseline_v1.0.txt       (Release 1.0 baseline)
regression_baseline_v1.1.txt       (Release 1.1 baseline, e.g., +5% optimization)
regression_baseline_current.txt    (Working baseline for PRs)
```

---

## 6. Benchmark Testing

### 6.1 Benchmark Suites

#### SATCOMP (International SAT Competition)

**Instances**:
- Main track: 400–500 instances, 1-hour timeout
- Application track: Problems from real applications
- Incremental track: Sequence of SAT + add/delete clause

**Availability**: https://www.satcompetition.org/

**Subset for SatSwarmv2** (20–30 representative):
```
satcomp_2022/application/bmc_*.cnf              (Bounded Model Checking)
satcomp_2022/application/cata_*.cnf             (Constraint solving)
satcomp_2022/random/UF*.cnf                     (Random SAT)
satcomp_2022/random/UUF*.cnf                    (Random UNSAT)
```

#### SATLIB (SAT Library)

**Categories**:
- **UF/UUF**: Random satisfiable/unsatisfiable
- **BMC**: Bounded model checking
- **QG**: Quasigroup completion problems
- **LOGISTICS, PLANNING, HOLE, II, BATTLESHIP**: Structured benchmarks

**Access**: http://www.satlib.org/

**Subset for SatSwarmv2**:
```
satlib/uf/uf20_*.cnf               20 variables
satlib/uf/uf50_*.cnf               50 variables
satlib/uf/uf100_*.cnf              100 variables
satlib/uuf/uuf50_*.cnf             50 variables, UNSAT
satlib/bmc/bmc1*.cnf               BMC instances
```

### 6.2 Performance Metrics

**Per-Instance**:
- Solving time (wall-clock or cycles @ 150 MHz)
- Status (SAT, UNSAT, TIMEOUT)
- Decision count
- Conflict count
- Restart count
- Memory usage (trail depth, clause count)

**Aggregate**:
- **Solved**: Instances solved within timeout (e.g., 1 hour wall-clock, 10M cycles)
- **Mean/Median Solving Time** (across solved instances)
- **Timeout Rate**: % instances exceeding timeout
- **Cactus Plot**: Cumulative solving time (# instances vs. time)

**Example Output**:
```
Instance               | SAT/UNSAT | Cycles    | Decisions | Conflicts | Time (ms)
uf20_01.cnf            | SAT       | 5,234     | 42        | 18        | 35
uf50_02.cnf            | SAT       | 127,450   | 287       | 156       | 850
uuf50_03.cnf           | UNSAT     | 2,345,678 | 9,456     | 8,234     | 15,637
bmc_large.cnf          | TIMEOUT   | 10,000,000| —         | —         | 66,667
...
```

### 6.3 Comparison Against References

**MiniSat (Sequential Solver Baseline)**:
- Download: `apt install minisat` (Linux) or compile from source
- Run: `minisat input.cnf output.txt`
- Parse output for solving time

**SatAccel (Hardware Baseline)**:
- Simulation of HLS version in `reference/SatAccel/`
- Compare cycle counts for same instances

**Expected Results**:
- SatSwarmv2 should be faster than MiniSat on large instances (hardware advantage)
- Performance vs. SatAccel depends on design choices (single vs. multi-cursor, etc.)

**Benchmarking Script** (sim/run_benchmarks.sh):
```bash
#!/bin/bash
TIMEOUT=3600  # 1 hour in seconds

for cnf in benchmarks/*.cnf; do
    echo "Testing $cnf..."
    
    # SatSwarmv2
    /usr/bin/time -v ./obj_dir/Vtb_verisat < $cnf > /tmp/verisat_out.txt 2>&1
    verisat_time=$(grep "Wall clock" /tmp/verisat_out.txt)
    verisat_result=$(grep "SAT\|UNSAT" /tmp/verisat_out.txt)
    
    # MiniSat (reference)
    /usr/bin/time -v minisat $cnf > /tmp/minisat_out.txt 2>&1
    minisat_time=$(grep "Wall clock" /tmp/minisat_out.txt)
    minisat_result=$(grep "SAT\|UNSAT" /tmp/minisat_out.txt)
    
    echo "$cnf,$(basename $cnf),$verisat_result,$verisat_time,$minisat_result,$minisat_time"
done
```

### 6.4 Benchmark Reporting

**Output Format** (CSV):
```
instance,variables,clauses,verisat_result,verisat_cycles,verisat_time_ms,minisat_result,minisat_time_ms,speedup
uf20_01.cnf,20,86,SAT,5234,35,SAT,120,3.43x
...
```

**Analysis**:
1. Count solved instances (SAT/UNSAT within timeout)
2. Compute mean/median/stddev of solving times
3. Generate cactus plot (gnuplot)
4. Identify performance anomalies (very slow instances)

---

## 7. Formal Verification

### 7.1 Properties to Verify

#### FSM Invariants

| Property | Module | Assertion |
|----------|--------|-----------|
| Completeness | PSE, CAE, VDE | All states reachable from IDLE |
| Liveness | PSE, CAE, VDE | Always progress toward termination (no infinite loops) |
| No Deadlock | Arbiter | Requests always eventually get granted |
| Reset | All | After reset, FSM in IDLE, memory zeroed |

#### CDCL Correctness

| Property | Description |
|----------|-------------|
| Soundness | Learned clauses are valid (logical consequences) |
| Completeness | If UNSAT proven, formula is truly unsatisfiable |
| Confluence | Unit propagation deterministic (any order same result) |
| Implication Correctness | Reason clauses correctly explain assignments |

#### Hardware Safety

| Property | Description |
|----------|-------------|
| No RAW Hazards | Reads after writes always get updated values |
| No WAR Hazards | Writes don't corrupt concurrent reads |
| Append-Only | Clause table pointers never decrement |
| Trail Integrity | Trail always consistent with variable table |

### 7.2 Formal Proof Strategy

#### Bounded Model Checking (BMC)

**Tool**: Yosys sby (SMT-based) or Cadence xcelium (if available)

**Approach**:
1. Unfold FSM k steps
2. Add property as negation to input constraints
3. Check satisfiability with SMT solver (Z3, Boolector)
4. If UNSAT: property holds for k steps; k typically small (10–100)
5. For larger k: use induction or abstraction

**Example XDC** (sby file):
```
[tasks]
cover

[options]
depth 20
timeout 300

[engines]
smtbmc z3

[script]
read_verilog -sv pse.sv
prep -top pse

[files]
pse.sv
verisat_pkg.sv
```

#### Inductive Proofs

**Approach** (for liveness properties):
1. **Base case**: Prove property holds in initial state
2. **Inductive step**: Assume property true at step n; prove true at step n+1
3. **Conclusion**: Property holds for all reachable states

**Example** (Implication Graph Consistency):
- **Base**: Initially, trail empty → no implications → consistent
- **Inductive**: If consistent at step n, assume new propagation added
  - PSE checks current assignment before enqueuing
  - CAE sets reason clause correctly
  - Trail update is atomic
  - Result: still consistent at step n+1

### 7.3 Assertions in RTL

**Embedded SVA Assertions** (in RTL):

```systemverilog
// PSE: State machine completeness
property pse_valid_state;
    @(posedge clk) (state == IDLE || state == INIT_SCAN || ... || state == DONE);
endproperty
assert property(pse_valid_state) else $error("Invalid PSE state");

// CAE: Backtrack level sanity
property cae_backtrack_sanity;
    @(posedge cae_learn) (backtrack_level >= -1 && backtrack_level < VAR_MAX);
endproperty
assert property(cae_backtrack_sanity) else $error("Invalid backtrack level");

// Arbiter: No simultaneous grants on same port
property no_concurrent_writes;
    @(posedge clk) !(pse_wr_en && cae_wr_en && (pse_wr_addr == cae_wr_addr));
endproperty
assert property(no_concurrent_writes) else $error("Write conflict detected");
```

**Coverage Collection**:
```bash
verilator --coverage -sv pse.sv ... -o obj_dir/Vpse
./obj_dir/Vpse +cover=all
coverage merge ...
coverage report
```

---

## 8. Test Coverage Metrics

### 8.1 Code Coverage

**Statement Coverage** (all lines executed):
- Target: ≥90% for core modules (PSE, CAE, VDE)
- Target: ≥70% for arbitration & support logic
- Report: Line-by-line from Verilator

**Branch Coverage** (all conditional paths):
- FSM state transitions: all edges taken?
- If-else blocks: both branches executed?
- Case statements: all cases hit?

**Condition Coverage** (all boolean conditions):
- `(a && b)`: test a=true&b=true, a=true&b=false, a=false&...
- More stringent than branch coverage

**Tool & Report**:
```bash
verilator --coverage -Werror-UNCOVEREDMODULE sim/tb_verisat.sv ...
./obj_dir/Vtb_verisat
# Generate report
verilator_coverage --output report.txt obj_dir/Vtb_verisat.dat
# Visualize in web browser
verilator_coverage --output report.html obj_dir/Vtb_verisat.dat
```

### 8.2 Functional Coverage

**Scenario Coverage**:
- CDCL loop completions: How many full PSE→CAE→VDE cycles executed?
- Conflict detection: How many conflicts triggered?
- Restarts: How many restart events occurred?

**Data-Driven Coverage**:
- Variable counts: 1–10 vars, 10–100, 100–1000, >1000?
- Clause counts: 1–10 clauses, 10–100, 100–1000, >1000?
- Decision depths: depth 1, 2–5, 5–10, >10?

**Scorecard Example**:
```
Scenario                   | Target | Achieved | %
─────────────────────────────────────────────────
CDCL loop iterations      | 1000   | 1050     | 105% ✓
Conflicts detected        | 500    | 480      | 96% ✓
Unit propagations         | 2000   | 2150     | 108% ✓
Conflicts w/learn         | 100    | 105      | 105% ✓
UNSAT proofs             | 50     | 48       | 96% ✓
SAT solutions verified    | 100    | 100      | 100% ✓
```

---

## 9. Debugging & Diagnosis

### 9.1 Testbench Instrumentation

**Detailed Logging** (in C++ harness):
```cpp
// Log every PSE propagation
if (prev_prop_valid && !prop_valid) {
    cout << "PSE Prop: var=" << prop_var << " polarity=" << prop_polarity
         << " reason=" << prop_reason << endl;
}

// Log every conflict
if (conflict_detected) {
    cout << "Conflict at clause " << conflict_clause << endl;
}

// Log every decision
if (vde_decide_valid) {
    cout << "Decision: var=" << decide_var << " polarity=" << decide_phase << endl;
}
```

### 9.2 Waveform Inspection (GTKWave)

**Critical Signals to Monitor**:
```verilog
// PSE
pse_state, pse_start, conflict_detected, prop_valid

// CAE
cae_state, learnt_valid, backtrack_level, unsat

// VDE
vde_state, decide_valid, decide_var, decide_phase

// Memory
ct_rd_en, ct_rd_ptr, var_rd_idx, trail_enq

// Top-level
cycle_count, result
```

**Save Waveform**:
```bash
make wave  # Generates obj_dir/verisat.vcd
gtkwave obj_dir/verisat.vcd &
```

### 9.3 Common Failures & Diagnosis

| Symptom | Root Cause | Fix |
|---------|-----------|-----|
| Wrong SAT/UNSAT | PSE conflict detection error | Verify watched literal logic |
| Timeout on small CNF | Infinite loop in FSM | Check for deadlock (arbiter, stalls) |
| Memory overflow | Clause table full | Increase MAX_CLAUSES parameter |
| Incorrect solution | Trail inconsistency | Verify backtrack mechanism |
| Arbiter deadlock | Cyclic waits | Add timeouts, check priority ordering |

**Debugging Procedure**:
1. Run failing instance in simulation
2. Capture waveform (make wave)
3. Set breakpoint in gtkwave on relevant signal (e.g., conflict_detected)
4. Trace backward: which assignments led to conflict?
5. Compare against reference solver (MiniSat trace)
6. Identify discrepancy in logic

---

## 10. Continuous Integration / Continuous Deployment

### 10.1 Test Automation (GitHub Actions Example)

**File**: `.github/workflows/test.yml`

```yaml
name: SAT Solver CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install verilator
      
      - name: Build
        run: cd sim && make clean && make
      
      - name: Unit Tests
        run: cd sim && make test
      
      - name: Regression Tests
        run: |
          for cnf in tests/regression/*.cnf; do
              ./obj_dir/Vtb_verisat < $cnf > /tmp/out.txt
              expected=$(cat expected/$cnf.result)
              actual=$(grep "SAT\|UNSAT" /tmp/out.txt)
              [ "$actual" == "$expected" ] || exit 1
          done
      
      - name: Performance Check
        run: |
          cd sim && make profile 2>&1 | tee /tmp/profile.txt
          python3 check_regression.py regression_baseline_current.txt /tmp/profile.txt
```

### 10.2 Performance Tracking

**Baseline Comparison Script** (`check_regression.py`):
```python
import sys
baseline_file, current_file = sys.argv[1], sys.argv[2]

baseline = {}
with open(baseline_file) as f:
    for line in f:
        parts = line.strip().split(',')
        baseline[parts[0]] = int(parts[1])  # instance -> cycles

failures = []
with open(current_file) as f:
    for line in f:
        parts = line.strip().split(',')
        if not parts[0] in baseline:
            continue
        current_cycles = int(parts[1])
        base_cycles = baseline[parts[0]]
        delta = (current_cycles - base_cycles) / base_cycles * 100
        if abs(delta) > 5:
            failures.append((parts[0], delta))

if failures:
    print("REGRESSION DETECTED:")
    for instance, delta in failures:
        print(f"  {instance}: {delta:+.1f}%")
    sys.exit(1)
else:
    print("All tests within ±5% threshold")
    sys.exit(0)
```

### 10.3 PR Merge Gating

**Merge Requirements**:
1. ✅ All commits must have clean syntax (no lint errors)
2. ✅ Build must succeed (Verilator compilation)
3. ✅ All unit + integration tests pass (100%)
4. ✅ Regression suite passes (all instances, ±5% threshold)
5. ✅ Code review approval (≥1 maintainer)

**Blocking Conditions**:
- ❌ New failing test case
- ❌ Any instance >5% performance regression
- ❌ Resource usage > 10% increase (LUTs, BRAMs)
- ❌ Unresolved feedback from review

---

## 11. References

**Testing Standards**:
- IEEE 1367 (Functional Specification)
- DO-178C (Avionics software; rigorous testing)
- IEC 61508 (Functional safety)

**FPGA Verification**:
- Xilinx Design Advisor (synthesis validation)
- Vivado Simulator (ModelSim alternative)
- Synopsys VCS (professional simulator)

**SAT Benchmarks**:
- https://www.satcompetition.org/
- http://www.satlib.org/
- https://github.com/msoos/cryptominisat (modern reference)

**Tools**:
- Verilator: https://www.veripool.org/verilator/
- GTKWave: http://gtkwave.sourceforge.net/
- Yosys sby: https://yosyshq.net/sby/

---

**For detailed testbench examples**, consult [sim/](../sim/) directory files.

**Last Updated**: January 2026
