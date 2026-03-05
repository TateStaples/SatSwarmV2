# Testing & Debugging (Verification.md)

SatSwarmV2 debugging workflows utilize native Verilator flows coupled with AWS-FPGA integration tools. To catch logic errors before they trigger hardware OOM bugs, these testbenches and simulations must be run prior to hitting Vivado CLI.

---

## Verilator Development Loop

The primary testing methodology relies heavily on Verilator. Run testing workflows from `/sim`.

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
cd sim
# To test the default baseline solver
BIN=$PWD/obj_dir_1x1/Vtb_satswarmv2 bash scripts/run_bigger_ladder.sh
```

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

# Rapidly grep through /tmp/synth_explore.log
grep -E "Finished Synthesis|Thrashing|Killed|ERROR" /tmp/synth_explore.log | tail -5
```
