# DEBUG_LEVEL Usage Guide

The testbench `tb_satswarmv2.sv` now supports a `DEBUG_LEVEL` parameter to control the verbosity of simulation output.

## Parameter: DEBUG_LEVEL

- **Type**: Integer (0, 1, or 2)
- **Default**: 2
- **Passed via**: `+DEBUG_LEVEL=<value>` argument to the simulator

## Usage

### DEBUG_LEVEL = 0 (Minimal / Heartbeat Only)

Prints only:
- Heartbeat messages every 10,000 cycles (during solving)
- Final result (SAT/UNSAT)
- Cycle count
- Test failure/timeout messages

**Use case**: High-performance batch testing, long-running benchmarks

```bash
./sim/scripts/run_cnf.sh <cnf_file> <expected> <max_cycles> +DEBUG_LEVEL=0
```

**Example output:**
```
[Heartbeat] Cycle 10000
[Heartbeat] Cycle 20000

=== RESULTS ===
  Result: SAT
  Cycles: 25430
```

### DEBUG_LEVEL = 1 (Architectural Level)

Prints architecture-level information that matches `mega_sim.py` output:
- Test header
- CNF loading info (problem size)
- Starting solve message
- Cycle progress (cycles 1-3, then every 100 cycles)
- Test results (SAT/UNSAT, PASS/FAIL)
- Cycle count and timing info
- Final test completion status

**Use case**: Standard testing, regression suites, architectural verification

```bash
./sim/scripts/run_cnf.sh <cnf_file> <expected> <max_cycles> +DEBUG_LEVEL=1
```

**Example output:**
```
========================================
TEST: SAT 5v #1
========================================
Loading CNF file: ../tests/generated_instances/sat_5v_10c_1.cnf
  Problem: 5 variables, 10 clauses
  Loaded 10 clauses
Starting solve at time 55000
Started solve, now waiting for completion...
[Cycle 1] done=0 sat=0 unsat=0
[Cycle 2] done=0 sat=0 unsat=0
[Cycle 3] done=0 sat=0 unsat=0
[Cycle 100] done=0 sat=0 unsat=0
[Cycle 200] done=0 sat=0 unsat=0
[Final Cycle 25430] done=1 sat=1 unsat=0 - TEST STOPPING

=== RESULTS ===
  Status: SAT
  Expected: SAT
  Result: PASS
  Cycles: 25430
  Sim Time: 254.30 ms
  Est. Real Time @ 100MHz: 254.30 ms
  Clauses: 10
  Variables: 5
  Result: SAT

*** TEST PASSED ***
```

### DEBUG_LEVEL = 2 (Full Microarchitectural Details) [DEFAULT]

Prints all available debugging information:
- Everything from DEBUG_LEVEL=1
- Literal push operations
- Model verification details
- Unsatisfied clause details (if verification fails)
- All microarchitectural operations

**Use case**: Debugging, detailed analysis, verification

```bash
./sim/scripts/run_cnf.sh <cnf_file> <expected> <max_cycles> +DEBUG_LEVEL=2
# or (default)
./sim/scripts/run_cnf.sh <cnf_file> <expected> <max_cycles>
```

**Example output:**
```
[Additional details from DEBUG_LEVEL=1, plus:]
[Pushing literal 1 (clause_end=0)]
[Pushing literal 2 (clause_end=1)]
...
[Verifying model from Core [0,0]...]
[MODEL VERIFIED: Valid functionality.]
```

## Implementation Details

The `debug_level` variable is:
1. **Declared** as a module variable with default value of 2
2. **Read** from plusargs at simulation start: `$value$plusargs("DEBUG_LEVEL=%d", debug_level)`
3. **Used** to conditionally gate `$display` statements throughout the testbench

### Guarded Regions

Different sections of the code are guarded by different conditions:

- **Header/Init**: `if (debug_level != 0)` - skipped only at level 0
- **Architectural info** (CNF loading, test start): `if (debug_level >= 1)` - shown at levels 1 and 2
- **Microarchitectural** (literal pushing, verification): `if (debug_level >= 2)` - shown only at level 2
- **Cycle progress**: 
  - Level 0: Heartbeat every 10,000 cycles
  - Level 1: Detailed at cycles 1-3, then every 100 cycles
  - Level 2: Same as level 1
- **Results**: 
  - Level 0: Minimal (Result and Cycles only)
  - Levels 1-2: Full details (Status, Expected, PASS/FAIL, Timing, Clauses, Variables)

## Performance Impact

- **DEBUG_LEVEL=0**: Minimal I/O, best for timing-critical tests
- **DEBUG_LEVEL=1**: Moderate I/O, good balance between visibility and performance
- **DEBUG_LEVEL=2**: Maximum I/O, may impact simulation performance on large instances
