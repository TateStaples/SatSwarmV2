# Testing & Debugging (Verification.md)

SatSwarmV2 debugging workflows utilize native Verilator flows coupled with AWS-FPGA integration tools. To catch logic errors before they trigger hardware OOM bugs, these testbenches and simulations must be run prior to hitting Vivado CLI.

---

## Verilator Development Loop

The primary testing methodology relies heavily on Verilator. Run testing workflows from `/sim`.

> **Prerequisite**: Verilator is not pre-installed on this machine. Install once with:
> ```bash
> sudo apt-get install -y verilator
> ```
> Version 5.020 confirmed working.

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim

# 1. Clean generated files
make clean

# 2. Compile RTL wrapper into Verilator binary
make build_1x1

# 3. Simulate specific SAT test cases
./obj_dir_1x1/Vtb_satswarmv2 +CNF=tests/generated_instances/sat_50v_215c_1.cnf +EXPECT=SAT +TIMEOUT=5000000 +DEBUG=0
```

*CRITICAL WARNING: The macro argument is `+EXPECT=`, NOT `+EXPECTED=`. A typo here implicitly assigns `SAT`.*

### Setting Debug Output

Pass the `+DEBUG` parameter to view Verilator cycle-by-cycle logging:

- `+DEBUG=0`: No trace output (fastest).
- `+DEBUG=1`: Log FSM state changes, conflict variables, deciding paths, and learned-clauses.
- `+DEBUG=2`: Full verbosity. Emits watch list replacements internally.

### Regression Ladder

Run the core testing suite (98 distinct test-files, ranging from 4v to 75v setups).

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim

# run_bigger_ladder.sh expects the binary at obj_dir/Vtb_satswarmv2.
# Create the symlink once after building:
ln -sfn obj_dir_1x1 obj_dir

# Run the full regression:
bash scripts/run_bigger_ladder.sh
```

> **Note**: The `BIN=` env var override works for `run_cnf.sh` but **not** for `run_bigger_ladder.sh`, which hardcodes `$SIM_DIR/obj_dir/Vtb_satswarmv2`. The symlink above is the correct workaround.

To run an exhaustive parameter/instance sweep across all small-tests:
```bash
bash scripts/find_failures.sh
```

---

## AWS Shell Integration (XSim)

To ensure that the AWS Shell interconnect wrapper module connects AXI successfully, run a mock BFM (Bus Functional Model) test prior to synthesis.

```bash
cd $CL_DIR/verif/scripts
make TEST=test_satswarm_aws
# Alternatively: make C_TEST=test_satswarm_aws
```

A successful output resembles:
`TEST: test_satswarm_aws    RESULT: *** TEST PASSED ***    Time: 11380 ns`

---

## XSim AXI Bridge Smoke Test

Run this when the Verilator regression is 98/98 and you have high confidence the RTL is ready. It verifies that `satswarm_core_bridge` — the AXI-Lite / PCIS DMA bridge between the AWS shell and `satswarm_top` — is correctly wired for both SAT and UNSAT cases. This layer is completely bypassed by Verilator.

The test compiles once (xvlog + xelab, ~5-10 seconds), then runs xsim on **6 fixed instances** (3 SAT + 3 UNSAT, ~30 seconds total). It is not a correctness suite; correctness over the full instance set is the Verilator ladder's job.

```bash
# From the project root (hdk_setup.sh cannot be sourced — the script sets env vars manually):
bash /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/hdk/cl/examples/cl_satswarm/verif/scripts/run_xsim_bridge_test.sh
```

Expected output:
```
=============================================
 SatSwarm XSim AXI Bridge Smoke Test
=============================================
[1/3] Compiling RTL (xvlog)...
[2/3] Elaborating snapshot (xelab)...
[3/3] Running 6 bridge tests...

  sat_5v_10c_1.cnf     [SAT]    PASS (cycles=1568)
  sat_20v_80c_1.cnf    [SAT]    PASS (cycles=5219)
  sat_50v_215c_1.cnf   [SAT]    PASS (cycles=30209)
  unsat_5v_10c_1.cnf   [UNSAT]  PASS (cycles=1875)
  unsat_20v_80c_1.cnf  [UNSAT]  PASS (cycles=8011)
  unsat_32v_136c_1.cnf [UNSAT]  PASS (cycles=19322)

=============================================
 Bridge Test Results
=============================================
  6/6 PASSED — AXI bridge OK
```

If the snapshot already exists from a prior run, skip recompile with `--skip-compile`:
```bash
bash .../run_xsim_bridge_test.sh --skip-compile
```

> **Note**: The testbench instantiates `satswarm_core_bridge` (simplified AXI port interface) directly — not `cl_satswarm` (full AWS `cl_ports.vh` interface). This correctly exercises the AXI bridge and solver logic without the AWS shell BFM overhead. The `MAX_LITS=1024` parameter keeps simulation memory low; the larger 50v UNSAT instances are excluded from this test for that reason.

---

## BRAM / LUTRAM Inference Validation

Often, Vivado fails Technology Mapping due to RAM being dissolved into excessive Flip-Flops. Validate inference early on any modification to `pse.sv` or `trail_manager.sv` using check-scripts instead of large syntheses:

```bash
# Run foreground inference check
bash deploy/check_inference.sh pse

# Background iterative development (returns terminal control, kills vivado upon fail)
bash deploy/check_inference.sh -b -k pse
```

Refer to `/tmp/synth_pse.log` internally, looking for:
`Distributed RAM: Final Mapping Report`
Any absent arrays were converted into Flip-Flops and indicate a failed implementation requiring rewrite.

---

## Debugging

**Wrong Answer / UNSAT for SAT:**
1. Check Backtrack computation in `cae.sv` (Should correctly traverse back across non-UIP variables).
2. Trace the arbitration logic. A dropped literal write can cause missing knowledge in `lit_mem`.

**Waveform Hanging:**
1. Review TIMEOUT threshold limits (`SIM_CYCLES`). Ensure instances <256 variables parse within 5 Million cycles.
2. Confirm the Infinite-Loop protections inside the Pipelined `CAE` logic.

**Vivado Synthesis Process Monitoring:**
```bash
# Check running background processes
ps aux | grep "unwrapped.*vivado" | grep -v grep | awk '{printf "PID=%s CPU=%s RSS_MB=%.0f\n", $2, $3, $6/1024}'

# Monitor the active build log (logs go to /home/ubuntu/buildall_*.log)
tail -20 /home/ubuntu/buildall_*.log | tail -20

# Check major phase milestones and errors
grep -E "^AWS FPGA:|ERROR|WNS" /home/ubuntu/buildall_*.log | tail -20
```

---

## Pre-Synthesis Verification Workflow

Run these gates in order before every Vivado build. Each step catches different classes of errors in seconds-to-minutes vs the hours a Vivado build costs.

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim

# 1. Build Verilator binary (once, or after any RTL change)
make build_1x1 && ln -sfn obj_dir_1x1 obj_dir

# 2. Heap unit test (after any vde_heap.sv change)
make test_vde_heap

# 3. Full correctness regression — 98 files (seconds each)
bash scripts/run_bigger_ladder.sh              # must be 98/98

# 4. BRAM inference check (after any pse.sv / trail_manager.sv change)
bash /home/ubuntu/src/project_data/SatSwarmV2/deploy/check_inference.sh pse

# 5. AXI bridge smoke test — 6 fixed instances via XSim (~30s)
#    Run this when Verilator is 98/98 and you're ready to commit to Vivado.
#    Exercises satswarm_core_bridge AXI path that Verilator bypasses.
bash /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/hdk/cl/examples/cl_satswarm/verif/scripts/run_xsim_bridge_test.sh

# All pass → proceed to Vivado BuildAll (see Deploy.md)
```
