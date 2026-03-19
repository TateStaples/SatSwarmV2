# Verification And Debugging

This document is the guide for proving the RTL still behaves correctly and for deciding which verification step is worth the time. Use it before synthesis and whenever a change touches solver behavior, clause movement, host loading, or shell integration.

For HDK-specific simulation details (protocol checkers, wave dumping, SV/C test API), see [RTL_Simulation_Guide_for_HDK_Design_Flow.md](../src/aws-fpga/hdk/docs/RTL_Simulation_Guide_for_HDK_Design_Flow.md). See [HDK.md](HDK.md) for the full HDK doc index.

---

## Verification Ladder

Use the lightest check that answers your current question.


| Goal                                    | Best tool                                       | Typical cost            | When to use                                                                                                          |
| --------------------------------------- | ----------------------------------------------- | ----------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Understand expected solver behavior     | `sim/mega_sim.py` or `sim/scripts/gen_trace.py` | seconds                 | First pass when logic looks wrong and you need a readable golden trace                                               |
| Check one RTL scenario quickly          | single Verilator CNF run                        | seconds                 | Fast local iteration after a focused RTL change                                                                      |
| Validate one subsystem                  | `make test_vde_heap` or `run_unit_tests.sh`     | seconds to low minutes  | After changes isolated to a specific block                                                                           |
| Recheck single-core correctness broadly | `run_bigger_ladder.sh`                          | minutes                 | Before declaring a solver change safe                                                                                |
| Recheck multi-core soundness            | `make build_2x2` + one or more CNFs             | minutes                 | After touching NoC, clause sharing, or top-level wiring                                                              |
| Check shell bridge only                 | `run_xsim_bridge_test.sh`                       | about 30s after compile | When Verilator passes and you changed `satswarm_core_bridge` / shell-side load or status wiring                      |
| Check full AWS shell regression         | `run_aws_regression.sh`                         | slowest (hours)         | Final confidence before Vivado or after shell-facing changes. Use selectively when `run_bigger_ladder.sh has issues` |


If you are iterating quickly, stay on the first three rows. If you are already confident the change is probably correct, jump to `run_bigger_ladder.sh` and then XSim as appropriate.

---

## Verilator Development Loop

Run these workflows from `sim/`.

> **Prerequisite**: install Verilator once if needed.
>
> ```bash
> sudo apt-get install -y verilator
> ```

Most common setup:

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim
make build_1x1
ln -sfn obj_dir_1x1 obj_dir
```

Then run a single CNF directly:

```bash
./obj_dir_1x1/Vtb_satswarmv2 \
  +CNF=tests/generated_instances/sat_50v_215c_1.cnf \
  +EXPECT=SAT \
  +TIMEOUT=5000000 \
  +DEBUG=0
```

> **Critical**: the macro is `+EXPECT=`, not `+EXPECTED=`.

### Debug levels

- `+DEBUG=0` - fastest, no trace
- `+DEBUG=1` - FSM state changes, conflicts, decisions, learned clauses
- `+DEBUG=2` - full verbosity, including watch-list replacements

Use `+DEBUG=1` first. Only step up to `+DEBUG=2` when you already know roughly where the mismatch is.

---

## Golden-Trace Debugging With `mega_sim.py`

When the RTL looks wrong, start by establishing what the solver should be doing on the same CNF.

### Direct Python golden run

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim
python3 mega_sim.py tests/generated_instances/sat_20v_80c_1.cnf
```

`mega_sim.py` is useful because it emits a readable software trace of:

- assignments
- unit propagations
- conflicts
- learned clauses
- backtracks
- final result

It is not a cycle-accurate model of the RTL, but it is a good statement of intended solver behavior.

### Normalized trace output

If you want a more structured trace for comparison, use:

```bash
python3 scripts/gen_trace.py tests/generated_instances/sat_20v_80c_1.cnf
```

`gen_trace.py` emits a `mega_sim`-style tagged trace (`[mega_sim] [VDE] ...`, `[mega_sim] [PSE] ...`) that is often easier to diff against RTL debug logs than the raw `mega_sim.py` output.

### How to use it with RTL logs

Recommended pattern:

1. Run `mega_sim.py` or `gen_trace.py` on the CNF.
2. Run the RTL on the same CNF with `+DEBUG=1`.
3. Compare:
  - first decision
  - first propagation sequence
  - first conflict clause
  - learned clause and backtrack level
  - final SAT / UNSAT result

When the first mismatch appears, the responsible block is usually obvious:

- wrong first decision -> `vde.sv` / `vde_heap.sv`
- wrong unit propagation or missed conflict -> `pse.sv` / watch handling
- wrong learned clause or bad backtrack -> `cae.sv` / trail interaction

### Older helper

`sim/scripts/golden_trace.py` exists, but it is a simpler expectation generator. For most debugging, prefer `mega_sim.py` or `gen_trace.py`.

---

## Focused Fast Checks

### Single-CNF run

Best for fast iteration after a targeted change:

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim
bash scripts/run_cnf.sh tests/unit_tests/simple_sat1.cnf SAT
```

Or with more visibility:

```bash
bash scripts/run_cnf.sh tests/unit_tests/simple_unsat1.cnf UNSAT 2000000 +DEBUG=1
```

### Unit-test subset

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim
bash scripts/run_unit_tests.sh
```

Use this when the change is local and you do not want to pay for the whole ladder yet.

### Heap unit test

After any `vde_heap.sv` change:

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim
make test_vde_heap
```

---

## Full Single-Core Correctness

`run_bigger_ladder.sh` is the main "I think this change is correct" gate.

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim
ln -sfn obj_dir_1x1 obj_dir
bash scripts/run_bigger_ladder.sh
```

Expected ending:

```text
Total Tests: 98
Passed:      98
Failed:      0
ALL TESTS PASSED
```

> **Note**: `run_bigger_ladder.sh` hardcodes `obj_dir/Vtb_satswarmv2`, so the symlink matters.

For a wider sweep across small tests:

```bash
bash scripts/find_failures.sh
```

---

## Multi-Core Soundness

When the change could affect top-level wiring, mesh behavior, or clause sharing, build the 2×2 config and run at least a few representative CNFs.

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim
make build_2x2

./obj_dir_2x2/Vtb_satswarmv2 \
  +CNF=tests/generated_instances/sat_50v_215c_1.cnf \
  +EXPECT=SAT \
  +TIMEOUT=5000000 \
  +DEBUG=0
```

Do this after touching:

- `satswarm_top.sv`
- `mesh_interconnect.sv`
- clause sharing / injection logic
- host aggregation behavior

---

## AWS Shell Checks (XSim)

Verilator does not exercise the full AWS shell path. Use XSim once the solver itself already looks healthy. The HDK [RTL Simulation Guide](../src/aws-fpga/hdk/docs/RTL_Simulation_Guide_for_HDK_Design_Flow.md) covers protocol checkers, wave dumping, and the SV/C test API in detail.

### AWS BFM smoke test

```bash
cd $CL_DIR/verif/scripts
make TEST=test_satswarm_aws
```

Expected:

`TEST: test_satswarm_aws    RESULT: *** TEST PASSED ***`

### XSim AXI bridge smoke test

This is the best "medium-cost" shell check.

```bash
bash /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/hdk/cl/examples/cl_satswarm/verif/scripts/run_xsim_bridge_test.sh
```

Use it when:

- `run_bigger_ladder.sh` already passes
- you changed `satswarm_core_bridge`
- you changed shell-side control / status / load wiring
- you want confidence before Vivado

If the snapshot already exists:

```bash
bash /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/hdk/cl/examples/cl_satswarm/verif/scripts/run_xsim_bridge_test.sh --skip-compile
```

### Full AWS shell regression

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2
bash sim/scripts/run_aws_regression.sh
```

This is the most thorough shell-level check and the slowest. Use it sparingly.

> `run_aws_regression.sh` requires `$HDK_DIR` to be set. See `Synth.md`. The script calls `make_sim_dir` before compile and uses the `run` target (with `PLUSARGS` passed through) for xsim. The script calls `make_sim_dir` before compile and uses the `run` target (not `simulate_only`) so `PLUSARGS` are passed to xsim. If the script fails at compile, ensure `make_sim_dir` runs first; the Makefile uses target `run` (not `simulate_only`) so `PLUSARGS` are passed to xsim.

---

## Inference Validation

If you touched `pse.sv` or `trail_manager.sv`, check that memories still infer correctly instead of dissolving into flip-flops.

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2
bash deploy/check_inference.sh pse
```

For iterative work:

```bash
bash deploy/check_inference.sh -b -k pse
```

Look for the `Distributed RAM: Final Mapping Report`. Missing target arrays usually means inference regressed.

---

## Common Failure Modes

### Wrong answer / UNSAT for SAT

Start with:

1. `mega_sim.py` or `gen_trace.py` on the same CNF
2. RTL single-file run with `+DEBUG=1`

Then inspect:

- `cae.sv` for wrong backtrack or learned-clause behavior
- `pse.sv` / watch updates for lost propagation
- trail / reason handling when assignments are undone

### Hangs / timeouts

Check:

- timeout settings (`+TIMEOUT` / `+MAXCYCLES`)
- repeated propagation / conflict loops
- whether the first mismatch vs `mega_sim.py` is actually much earlier than the timeout

### Shell-only failures

If Verilator passes but XSim fails, suspect:

- `satswarm_core_bridge.sv`
- shell register decode
- status / reset / load-path wiring
- clock-domain crossing in the AWS wrapper

On real hardware, if the host hangs or gets no response, check for shell timeouts: run `fpga-describe-local-image -S 0 --metrics` and inspect `ocl-slave-timeout`, `dma-pcis-timeout`. See [How_To_Detect_Shell_Timeout.md](../src/aws-fpga/hdk/docs/How_To_Detect_Shell_Timeout.md).

---

## Recommended Pre-Synthesis Gate

When you want a strong but still practical gate before BuildAll:

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim

# 1. Build the binary you need
make build_1x1 && ln -sfn obj_dir_1x1 obj_dir

# 2. Focused unit test if relevant
make test_vde_heap

# 3. Main correctness gate
bash scripts/run_bigger_ladder.sh

# 4. If shell-facing logic changed
bash /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/hdk/cl/examples/cl_satswarm/verif/scripts/run_xsim_bridge_test.sh
```

Then switch to `Synth.md` for the synthesis / AFI flow.