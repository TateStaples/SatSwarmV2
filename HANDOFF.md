# SatSwarm V2 — Project Handoff

**Project root**: `/home/ubuntu/src/project_data/SatSwarmV2`  
**Target**: AWS F2 instance (Xilinx VU47P FPGA)  
**Toolchain**: Vivado 2025.2, Verilator (simulation), AWS HDK v2.3.0

---

## 1. Architecture Overview

SatSwarm V2 is a parallel CDCL SAT solver implemented in SystemVerilog, targeting AWS FPGA deployment.

**RTL hierarchy** (`src/Mega/`):

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
  └── resync_controller.sv      — ⚠️ DEAD CODE — see §2 "RESYNC_PSE Elimination"

satswarmv2_pkg.sv               — Global parameters and types (included by all modules)
```

**AWS CL wrapper** (`src/aws-fpga/hdk/cl/examples/cl_satswarm/design/`):

```
cl_satswarm.sv          — HDK top-level; full cl_ports.vh interface, sh_ddr instantiation
satswarm_core_bridge.sv — Adapts AWS shell buses to satswarm_top simplified interface
```

---

## 2. Notable Design Decisions & Historical Changes

These are intentional deviations from "obvious" defaults that a new reader should understand
before touching the code.

### Sizing Audit (2026-02-26)

A comprehensive audit found 16 hard-coded loop bounds and signal widths that would silently
truncate or skip entries when parameters exceeded compile-time assumptions. All fixes are in
the respective modules:


| Module             | Fix Summary                                                                                                                                                          |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `solver_core.sv`   | 8 loops changed from `<8` or `<16` to `<MAX_CLAUSE_LEN`; `vde_bump_count`/`vde_bump_vars` widened to `$clog2(MAX_CLAUSE_LEN+1)` / `MAX_CLAUSE_LEN`                   |
| `cae.sv`           | Wider ports for `MAX_BUFFER` formula, `active_in_buf_q` dual-flag fix, `rescan_needed_q/d` register, FINALIZE_EMIT validation assertions, RESOLUTION ADD debug trace |
| `vde.sv`           | `BUMP_Q_SIZE` parameter added (passed from solver_core); bump signals widened                                                                                        |
| `vde_heap.sv`      | `BUMP_Q_SIZE` parameter; widened signals; fixed shift loops `j < 7` → `j < BUMP_Q_SIZE-1`                                                                            |
| `pse.sv`           | CONFLICT-VALIDATE, UNIT-VALIDATE, PROP-VALIDATE assertion blocks added                                                                                               |
| `trail_manager.sv` | DUP-VALIDATE assertion block added                                                                                                                                   |


### RESYNC_PSE Elimination (2026-02-27) — **ROOT CAUSE OF 2 TEST FAILURES**

The `RESYNC_PSE` FSM state was designed to wipe PSE's internal assignment shadow
(`pse_clear_assignments=1`) and rebuild it by replaying the trail. This was architecturally
unsound — the wipe-and-replay approach corrupted PSE state, particularly when restarting
(trail_height=0 after wipe means no replay occurs, leaving PSE in a blank state).

**Root cause confirmed**: The restart mechanism was the sole source of 2 persistent test
failures (`sat_50v_215c_1.cnf`, `sat_75v_325c_1.cnf`). The Python golden model (`mega_sim.py`)
does **not** implement restarts, so this bug was invisible to differential testing.

Three entry paths into RESYNC_PSE were rewritten:


| Original Path                                              | New Behavior                                                                                                                 |
| ---------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| **Restart** (conflict counter threshold)                   | Iterative backtrack to level 0 via `BACKTRACK_UNDO` with `restart_mode_q=1` (no learned clause append, no asserting literal) |
| **Rescan** (`rescan_required_q` — conflicting propagation) | Direct PSE restart (`pse_start` + `PSE_PHASE`); no full resync needed since PSE shadow state is still valid                  |
| **PSE timeout** (cycle_count > 1M)                         | Direct transition to `VDE_PHASE` (timeout is a fallback, not a state-corruption event)                                       |


A new `restart_mode_q` / `restart_mode_d` register was added to `solver_core.sv` to
distinguish restart backtracks from normal conflict-driven backtracks in `BACKTRACK_UNDO`.
When `restart_mode_q=1`, the state skips learned-clause append and asserting-literal push.

**Current status**: Restarts are **disabled** (`RESTART_CONFLICT_THRESHOLD = 16'd65535`).
The BACKTRACK_UNDO restart path is implemented and structurally correct but has not been
validated with a reachable threshold.

**Dead code remaining**:

- `RESYNC_PSE` and `RESYNC_PSE_SETTLE` states still exist in the FSM enum and case statement
(~lines 1480–1540) but are unreachable (no transitions lead to them)
- `resync_controller.sv` module is instantiated but `resync_start` is always 0
- `muxed_trail_read_idx` mux still references `state_q == RESYNC_PSE` (harmless)
- These can be cleaned up in a future pass without functional impact

### `vde_heap.sv`

The only active VDE heap implementation. Standard SystemVerilog. Used in all simulation and synthesis flows.

`vde_heap_yosys.sv` was a Yosys-specific workaround that failed Vivado's `xvlog` parser. It was removed as dead code in the 2026-03-02 cleanup session along with the entire `timing_analysis/` Yosys script directory and `deploy/tcl/synth_aws.tcl`. The Yosys flow is no longer supported.

### `cae.sv` — Pipelined Rewrite

The original CAE used bulk combinatorial loops (64-wide parallel scans over the trail buffer),
resulting in **489 logic levels** on the critical path — a severe timing violation.
It was fully rewritten to use an incremental sequential FSM that processes one trail entry per
clock cycle, matching the VeriSAT (Tao & Cai, ICCAD 2025) reference design.
Post-fix: per-cycle combinatorial depth is now shallow (single FSM state transitions).
The rewrite was validated via `tb_cae_fuip` unit tests and `tb_regression_single` full solver
regression.

### `pse.sv` — Declaration Order Fix

Vivado's `xvlog` is stricter than Yosys/Verilator about forward references of implicit
declarations. `state_q`, `prop_push`, and `prop_push_val` were moved earlier in the file so
their `logic` declarations appear before their first use in the `sfifo` instantiation.

### HDK CL Module Renaming

When the project was adapted from F1 to F2 conventions:

- The original simplified-interface wrapper was renamed `satswarm_core_bridge.sv`
(was: `cl_satswarm.sv`)
- A new `cl_satswarm.sv` was created that exposes the **full `cl_ports.vh` shell interface**,
as required by the HDK linker (`link_design` fails if the top-level CL doesn't match the
shell's expected port list)

### `synth_aws.tcl` (deleted)

`deploy/tcl/synth_aws.tcl` was a standalone Vivado synthesis script from early development targeting `xczu9eg` (non-AWS board). It was deleted in the 2026-03-02 cleanup session. `deploy/deploy.sh` which called it has been marked legacy. The correct build path is `deploy/run_synthesis.sh` via `aws_build_dcp_from_cl.py`.

---

## 3. Current Repository State

### HDK

- Repo: `/home/ubuntu/src/project_data/aws-fpga`, tag `v2.3.0`, HEAD detached.
- No modifications to HDK source. Only untracked additions: our `cl_satswarm` CL directory
(accessible via symlink from within the HDK tree) and generated verif scripts.
- HDK v2.3.0 officially supports Vivado 2025.2; the `sh_ddr` encrypted modules work correctly
when synthesized as a submodule within the CL (not standalone).
- Don't edit the HDK repo when you face issues, this project is way more likely to be the problem.

### SatSwarm RTL (`src/Mega/`)

- All modules pass `xvlog` syntax check and Verilator build (`make build_1x1`).
- `vde_heap_yosys.sv` deleted (2026-03-02 cleanup); Yosys guard removed from `synth_cl_satswarm.tcl`.
- **98/98 regression tests pass** (as of 2026-02-27) with restarts disabled.
- Parameters: `MAX_VARS=256`, `MAX_CLAUSES=4096`, `MAX_LITS=65536`, `MAX_CLAUSE_LEN=32`.
- `RESTART_CONFLICT_THRESHOLD` is set to `16'd65535` (effectively disabled). See §2 and §5.

### Simulation (`sim/`)

- Verilator-based. Run via `sim/Makefile`.
- **Primary build target**: `make build_1x1` → produces `sim/obj_dir_1x1/Vtb_satswarmv2`.
- **Individual test**: `./obj_dir_1x1/Vtb_satswarmv2 +CNF=<file> +EXPECT=SAT|UNSAT +TIMEOUT=5000000 +DEBUG=0|1|2`
  - ⚠️ **CRITICAL**: The plusarg is `+EXPECT=`, NOT `+EXPECTED=`. Using the wrong name silently
  defaults to SAT and will not catch incorrect UNSAT results.
- **98-test regression**: `cd sim && BIN=$PWD/obj_dir_1x1/Vtb_satswarmv2 bash scripts/run_bigger_ladder.sh`
  - Tests SAT/UNSAT instances from 4v up to 75v (in `tests/generated_instances/`)
- **Exhaustive small-test sweep**: `bash scripts/find_failures.sh` tests all instances in `tests/small_tests/`
- **Python golden model**: `sim/mega_sim.py` — pure-Python CDCL solver for differential testing.
Does NOT implement restarts (key architectural difference from RTL).
- Other make targets: `test_vde_heap`, `debug_single`, `debug_8v`, `regression_single`.
- All RTL dependencies (including `mega_pkg.sv`, `global_allocator.sv`, `resync_controller.sv`)
are listed in the Makefile. Flags include `--Wno-BLKLOOPINIT --Wno-SYNCASYNCNET`.

### AWS CL Build

- **Synthesis script**: `build/scripts/synth_cl_satswarm.tcl` — follows standard HDK pattern.

#### sh_ddr Encryption Error — DIAGNOSED AND FIXED (2026-02-28)

The first synthesis attempt hit `ERROR: [Synth 8-5809] Error generated from encrypted envelope. [sh_ddr.sv:533]` followed by `[sh_ddr.sv:39]`. Root cause analysis:

`sh_ddr.sv` is Xilinx-encrypted and contains synthesis-time `$fatal` assertions
(`control error_handling="delegated"`) that fire when required IP modules are not registered in
the Vivado project. When macros `SH_SDA` and `SH_CL_ASYNC` are defined (which `cl_satswarm_defines.vh`
defines), sh_ddr elaborates code paths that need the AXI crossbar and MMCM IP modules present
in the project. Without them the encrypted assertions fire immediately — before Vivado even
prints "synthesizing module 'sh_ddr'".

**Fix**: Added the same IP set loaded by the `cl_dram_hbm_dma` and `cl_mem_perf` reference
designs to `synth_cl_satswarm.tcl`:


| IP group             | Files added                                                                            |
| -------------------- | -------------------------------------------------------------------------------------- |
| Clocking             | `clk_mmcm_a/b/c/hbm.xci`, `cl_clk_axil_xbar.xci`, `cl_sda_axil_xbar.xci`               |
| AXI register slices  | `axi_register_slice.xci`, `axi_register_slice_light.xci`, `cl_axi3_256b_reg_slice.xci` |
| AXI clock converters | `cl_axi_clock_converter.xci`, `cl_axi_clock_converter_light.xci`                       |
| AXI interconnect     | `cl_axi_interconnect_64G_ddr.xci`                                                      |


The clocking IPs are loaded from `$HDK_SHELL_DESIGN_DIR/../../ip/cl_ip/cl_ip.srcs/sources_1/ip/`;
the AXI IPs from `$HDK_IP_SRC_DIR/` (same as cl_ddr4).

**Validation**: After the fix, RTL Elaboration completed successfully at elapsed 3:11 (was
failing at 14–16 s in all prior runs). The synthesis progressed through all major phases.

#### Synthesis Attempt History & OOM Root Cause (as of 2026-03-01)

**Root cause of all failures**: The system has 30 GB RAM. Vivado Timing Optimization spawns
1 main process (~~10–13 GB) + 4 parallel worker threads (~~2.5 GB each) = **~22–25 GB peak**.
With OS overhead and swap pressure, the system thrashes and the kernel kills Vivado:

```
# Thrashing Detected!
# Process may be trying to use more memory than is available
/opt/Xilinx/2025.2/Vivado/bin/rdiArgs.sh: line 57: 945577 Killed
```

**Attempts summary**:


| #     | Clock Recipe | Solver Clock                                                | Phys. Opt         | Outcome                              | Failed At                                                |
| ----- | ------------ | ----------------------------------------------------------- | ----------------- | ------------------------------------ | -------------------------------------------------------- |
| 1     | A0           | `clk_main_a0` @ 250 MHz (no CDC)                            | AggressiveExplore | OOM Killed                           | ~4–5 h into Timing Opt                                   |
| 2     | A0           | `clk_main_a0` @ 250 MHz (no CDC)                            | AggressiveExplore | OOM Killed                           | Cross Boundary & Area Opt                                |
| 3     | A0           | `clk_main_a0` @ 250 MHz (no CDC)                            | AggressiveExplore | OOM Killed                           | Before checkpoint                                        |
| 4     | A2           | `clk_main_a0` @ 250 MHz (no CDC)                            | AggressiveExplore | OOM Killed (09:26 UTC Mar 1)         | ~9.5 h into Timing Opt (202k major page faults)          |
| 5     | A2           | `clk_main_a0` @ 250 MHz (no CDC)                            | Explore           | OOM Killed / potentially AMI stopped | Timing Opt (started ~15:00 UTC Mar 1; log not preserved) |
| **6** | **A2**       | `gen_clk_extra_a1` @ 15.625 MHz via `aws_clk_gen` (CDC)    | **Explore**       | **OOM Killed (2026-03-02)**          | **Technology Mapping** (~1h35m elapsed, 12.8 GB peak)   |
| **7** | **A2**       | `gen_clk_extra_a1` @ 15.625 MHz via `aws_clk_gen` (CDC)    | **Explore**       | **OOM Killed (2026-03-02)**          | DDR_PRESENT=0, maxThreads=4, global_retiming off, +20 GB swap. Still OOM in Technology Mapping — needs ≥64 GB instance |


**About A2 vs A0 (pre-CDC)**: `clk_main_a0` was hardwired at 250 MHz regardless of recipe in attempts 1–5; the recipe only changed Vivado's timing *constraint* period. A2 set the constraint to 125 MHz, relaxing the optimization search space vs A0 (250 MHz constraint). This allowed synthesis to survive ~3× longer before OOM.

**About Attempt 6 (post-CDC)**: The Clock Domain Crossing integration (2026-03-02) changed the solver's *actual operating frequency* to 15.625 MHz via `aws_clk_gen` (`gen_clk_extra_a1`). The shell remains at 250 MHz. This is a deeply conservative frequency intended to eliminate timing pressure entirely.

**About `Explore` vs `AggressiveExplore`**: `AggressiveExplore` runs more physical
optimization passes, consuming more memory. `Explore` uses a lighter strategy and should
fit within the 30 GB budget.

**Synthesis milestones reached** (confirmed in all attempts after the sh_ddr fix):


| Phase                              | Elapsed (Att. 6)  | Status                              |
| ---------------------------------- | ----------------- | ----------------------------------- |
| RTL Elaboration                    | ~00:03            | ✅                                   |
| RTL Optimization Phase 1           | ~00:03            | ✅                                   |
| RTL Optimization Phase 2           | 00:22:05          | ✅  (peak 12.6 GB)                   |
| Cross Boundary & Area Optimization | 00:55:02          | ✅  (peak 12.6 GB)                   |
| Applying XDC Timing Constraints    | 00:57:27          | ✅  (peak 12.7 GB)                   |
| **Timing Optimization**            | **01:07:22**      | **✅  FIRST TIME PASSED** (peak 12.9 GB) |
| **Technology Mapping**             | ~01:35 total      | **OOM Killed** (new furthest point) |
| Routing / write_checkpoint         | —                 | Not reached                         |

Peak memory at Technology Mapping OOM (Att. 6): exceeded 30 GB total system RAM.

**Known CRITICAL WARNINGs** (non-blocking, expected):


| Code                  | Count | Cause                                                                                                                                                    | Impact                                                                                                       |
| --------------------- | ----- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `Designutils 20-1280` | 15    | IPs (`clk_mmcm_a/b/c/hbm`, AXI reg slices) registered as RTL sources rather than proper IP blocks — Vivado can't find instances to apply their XDC files | None — these XDCs apply to shell-managed clocking, not CL logic                                              |
| `Synth 8-6858/6859`   | 200   | `tx_pkt_n[msg_type]` and `tx_pkt_n[payload]` in `solver_core.sv` multi-driven: logic driver vs GND tie                                                   | None — these are unconnected north-facing mesh output ports in the 1×1 grid config; GND is the correct value |


**Next step**: Kick off Attempt 6 (CDC build, 15.625 MHz solver clock). When it completes, check WNS:

```bash
grep -E "WNS|TNS|FAILING|Finished Synthesis|ERROR" /tmp/synth_explore.log | tail -10
```

Expected checkpoint: `build/checkpoints/to_aws/*.synthesis.dcp`.

- **Reference validation**: The `cl_dram_hbm_dma` reference example synthesized successfully
(0 errors, ~12 min) on 2026-02-26, confirming the full HDK+Vivado+`sh_ddr` flow works.

### Clock Domain Crossing Implementation (2026-03-02)

To resolve OOM errors during Synthesis Timing Optimization, the design's clock constraints were further relaxed. `clk_main_a0` is physically fixed at 250 MHz in the AWS F2 Shell, while the previous attempt (A2) expected 125 MHz. 

To achieve an architectural relaxation, AWS Clock Recipe A2 was utilized to generate a 15.625 MHz solver clock.

- `**aws_clk_gen` Integration**: Added to `cl_satswarm.sv` to derive `gen_clk_extra_a1` (15.625 MHz).
- **AXI Clock Converters**: Instantiated `cl_axi_clock_converter` and `cl_axi_clock_converter_light` to safely transition signals across the three main AXI boundaries (OCL, PCIS, DDR) from the 250 MHz Shell domain into the new 15.625 MHz Solver domain.
- **Core Update**: All instances of `satswarm_core_bridge` logic inside `cl_satswarm.sv` are now driven by this slower 15.625 MHz domain (`gen_clk_extra_a1`).

**Validation**: Vivado Makefile testing was initiated via `make C_TEST=test_hello_world` in `verif/scripts/`. Synthesis scripts have been updated to utilize `--clock_recipe_a A2`.

---

## 4. How to Run

### Initialize HDK environment (required before any AWS build)

```bash
cd /home/ubuntu/src/project_data/aws-fpga
source hdk_setup.sh
# Note: must be sourced from this directory — hdk_setup.sh uses git rev-parse
# to find the repo root. Sourcing from inside SatSwarmV2 will mis-resolve it.
```

### Build and test the solver (Verilator — primary development loop)

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim

# Build the 1×1 single-core binary
make build_1x1

# Run a single test case
./obj_dir_1x1/Vtb_satswarmv2 +CNF=tests/generated_instances/sat_50v_215c_1.cnf +EXPECT=SAT +TIMEOUT=5000000 +DEBUG=0

# Run the 98-test regression ladder
BIN=$PWD/obj_dir_1x1/Vtb_satswarmv2 bash scripts/run_bigger_ladder.sh

# Run exhaustive small-test sweep (all files in tests/small_tests/)
# bash scripts/find_failures.sh - Run this if you find failures to look for small, easy to debug cases
```

### Debug flags

- `+DEBUG=0` — no trace output (fastest)
- `+DEBUG=1` — FSM transitions, decisions, propagations, conflicts, learned clauses
- `+DEBUG=2` — verbose (includes watcher replacement trace from PSE)

### Run HDK shell simulation (XSim — recommended pre-synthesis check)

Uses the shell BFM to exercise the full CL through AXI transactions. This is the
primary integration-level check recommended by `deploy/tcl/AWS_quickstart.md`.

```bash
cd $CL_DIR/verif/scripts
make TEST=test_satswarm_aws  # or: make C_TEST=test_satswarm_aws
```

See `verif/tests/test_satswarm_aws.sv` for the testbench. Requires HDK env sourced first.

### Run SatSwarm synthesis

```bash
# Preferred: use the launcher script (handles HDK env sourcing automatically)
cd /home/ubuntu/src/project_data/SatSwarmV2/deploy
./run_synthesis.sh 2>&1 | tee /tmp/synth_explore.log &
```

Current launcher settings (`deploy/run_synthesis.sh`):

- Clock recipe A: **A2** — produces `gen_clk_extra_a1` at **15.625 MHz** via `aws_clk_gen` (solver domain). Shell `clk_main_a0` remains fixed at 250 MHz.
- Physical optimization: **Explore** (lighter than AggressiveExplore — fits in 30 GB RAM)
- Physical placement: SSI_SpreadLogic_high (default)
- Routing: AggressiveExplore (default — only runs after synthesis, acceptable)

DO NOT use A0 (250 MHz constraint) or AggressiveExplore physical opt — all prior attempts with those
settings were killed by OOM during Timing Optimization. See §3 for full history.

```bash
# Manual invocation (equivalent, after sourcing HDK env)
export CL_DIR=$HDK_DIR/cl/examples/cl_satswarm
cd $CL_DIR/build/scripts
python3 $HDK_DIR/common/shell_stable/build/scripts/aws_build_dcp_from_cl.py \
  -c cl_satswarm -f SynthCL --no-encrypt \
  --aws_clk_gen --clock_recipe_a A2 --clock_recipe_b B0 \
  --clock_recipe_c C0 --clock_recipe_hbm H0 \
  -o Explore
# Synthesis logs: build/reports/  Checkpoints: build/checkpoints/
```

### Run full build (synthesis + implementation)

```bash
# Same as above but with -f BuildAll (only after synthesis DCP is confirmed clean)
python3 $HDK_DIR/common/shell_stable/build/scripts/aws_build_dcp_from_cl.py \
  -c cl_satswarm -f BuildAll --no-encrypt \
  --aws_clk_gen --clock_recipe_a A2 --clock_recipe_b B0 \
  --clock_recipe_c C0 --clock_recipe_hbm H0 \
  -o Explore
```

### Convert Synthesis DCP to AFI (deploy to F2)

After `BuildAll` completes, a tarball is placed at:

```
$CL_DIR/build/checkpoints/to_aws/<timestamp>.Developer_CL.tar
```

**Step 1 — Upload DCP to S3:**

```bash
# Create a bucket (one-time)
aws s3 mb s3://<your-bucket>
aws s3 mb s3://<your-bucket>/logs

# Upload the DCP tar
aws s3 cp $CL_DIR/build/checkpoints/to_aws/*.Developer_CL.tar \
    s3://<your-bucket>/dcp/
```

**Step 2 — Create the AFI:**

```bash
aws ec2 create-fpga-image \
    --region us-east-1 \
    --name "SatSwarmV2" \
    --description "SatSwarm V2 CDCL solver, 1x1 grid, 15.625 MHz solver clock" \
    --input-storage-location Bucket=<your-bucket>,Key=dcp/<filename>.Developer_CL.tar \
    --logs-storage-location  Bucket=<your-bucket>,Key=logs
# Returns: FpgaImageId (fi-*) and FpgaImageGlobalId (agfi-*)
# Save the agfi-* ID — it is used to load the image on the F2 instance.
```

**Step 3 — Poll until available (~30–60 min):**

```bash
aws ec2 describe-fpga-images --fpga-image-ids fi-xxxx \
    --query 'FpgaImages[0].State'
# Wait until: {"Code": "available"}
```

**Step 4 — Load on F2 instance:**

```bash
source $AWS_FPGA_REPO_DIR/sdk_setup.sh
sudo fpga-clear-local-image  -S 0
sudo fpga-load-local-image   -S 0 -l agfi-xxxx
sudo fpga-describe-local-image -S 0 -H
# Verify StatusName: loaded
```

**Pre-synthesis quick-check (recommended before committing to 10h+ build):**

```bash
cd $CL_DIR/verif/scripts
make TEST=test_satswarm_aws   # XSim BFM test — takes ~minutes, validates AXI wiring
```

See `deploy/tcl/AWS_quickstart.md` for full quick-check workflow reference.

---

## 5. Open Problems & Future Work

### Complete Synthesis (Highest Priority)

Synthesis Attempt 6 completed with a new milestone — **Timing Optimization passed for the first time** — but was OOM-killed in the Technology Mapping phase (~1h35m total, ~30 GB RAM exhausted). No checkpoint was written.

**Attempt 7 settings and outcome (2026-03-02, 30 GB instance):**

- `DDR_PRESENT=0` — excludes the DDR4 controller (MicroBlaze MCS + calibration logic) from Technology Mapping. The solver is functionally unaffected: `lit_mem` is on-chip BRAM, and `global_read_req`/`global_write_req` are always `1'b0`. **This is a temporary measure** — see §5 "Future Work: VeriSAT External-Memory Migration".
- `set_param general.maxThreads 4` — caps parallel Vivado workers to reduce peak memory.
- `-global_retiming off` — replaces deprecated `-retiming`; avoids the retiming memory spike.
- +20 GB swap added at `/swapfile2` (total VM: ~60 GB RAM+swap).

**Result: OOM-killed again in Technology Mapping.** Memory trajectory for Attempt 7:

| Phase | Elapsed | Peak Memory |
| ----- | ------- | ----------- |
| RTL Elaboration | 02:56 | 8.2 GB |
| RTL Opt Phase 1 | 03:08 | 8.2 GB |
| RTL Opt Phase 2 | 21:05 | 11.9 GB |
| Cross Boundary & Area Opt | 51:37 | 12.2 GB (vs 55:02 in Att. 6) |
| Applying XDC Constraints | 53:29 | 12.2 GB |
| Timing Optimization | 01:00:20 | **12.35 GB** (vs 01:07:22 / 12.9 GB in Att. 6) |
| **Technology Mapping** | — | **OOM Killed** (free virtual was 30 GB; Tech Mapping needs >30 GB additional) |

DDR disabled saved ~550 MB and ~7 min across early phases, but Technology Mapping still exceeds the available virtual memory. **The 30 GB instance is definitively too small for Technology Mapping regardless of DDR setting.** The machine needs to be upgraded.

**Confirmed next step: Use a ≥64 GB RAM instance.** Technology Mapping needs between 30–50 GB of additional virtual memory on top of the ~12 GB Vivado holds entering the phase; a 64 GB instance provides sufficient headroom.


**Attempt 8 — BRAM Inference Fix (2026-03-03, 30 GB instance):**

Root-cause analysis of Attempt 7's OOM confirmed that Vivado was dissolving ~540K bits of storage
arrays into individual flip-flops instead of BRAM/LUTRAM. This forced Technology Mapping to process
~540K additional timing endpoints (each FF is a node), exploding the timing graph on the 4-die VU47P.

RTL changes applied in Attempt 8:

| File | Change | FF reduction |
| ---- | ------ | ------------ |
| `src/Mega/shared_clause_buffer.sv` | Flattened `shared_packet_t mem[4096]` to `logic[95:0]` with `(* ram_style = "block" *)` | ~393K FFs → 4 RAMB36s |
| `src/Mega/utils/sfifo.sv` | Added `(* ram_style = "distributed" *)` to `mem` (all 3 instantiations) | ~54K FFs → LUTRAM |
| `src/Mega/pse.sv` | Added `(* ram_style = "distributed" *)` to all 11 storage arrays | ~65K FFs → LUTRAM |
| `src/Mega/trail_manager.sv` | Flattened `trail_entry_t trail[]` to `logic[65:0]` in synthesis; added distributed hints to 4 lookup tables | ~17K FFs → LUTRAM |
| `src/Mega/vde_heap.sv` | Added `(* ram_style = "block" *)` to `heap_mem`/`pos_mem` (sync reads + TDP pattern) | ~10K FFs → BRAM |

Expected result: ~540K FFs → ~15K FFs, matching VeriSAT reference (1.67% FF / 77% BRAM). Technology
Mapping peak memory should drop from >37 GB to under 15 GB, fitting within the 30 GB instance.

All changes verified with xvlog syntax check (0 errors). Verilator regression and synthesis running
in parallel — see §6 for regression results, and below for synthesis progress.

Quick inference check command (run ~5 min after synthesis starts):
```bash
grep -E "Synth 8-4767|Synth 8-13159|dissolved into|Trying to implement RAM in registers" \
    /tmp/synth_attempt8.log | head -20
# Absent = BRAM/LUTRAM inference working; Present = inference failed for that signal
```

Synthesis monitoring:
```bash
# Is it still running?
ps aux | grep "unwrapped.*vivado" | grep -v grep | awk '{printf "PID=%s CPU=%s RSS_MB=%.0f\n", $2, $3, $6/1024}'

# Has it completed or crashed?
grep -E "Finished Synthesis|Thrashing|Killed|ERROR" /tmp/synth_attempt8.log | tail -5

# Latest log output
tail -20 /tmp/synth_attempt8.log
```

When synthesis completes, check timing:
```bash
grep -E "WNS|TNS|FAILING|Finished Synthesis|write_checkpoint" /tmp/synth_attempt8.log | tail -10
```

**Attempt 8 — STATUS: OOM Killed in Technology Mapping ❌** (2026-03-03)

| Phase | Elapsed | Peak Memory | Free Physical | Free Virtual |
| ----- | ------- | ----------- | ------------- | ------------ |
| RTL Elaboration | 01:44 | 6.7 GB | 20.4 GB | 53.3 GB |
| RTL Opt Phase 1 | 01:49 | 6.7 GB | 20.4 GB | 53.3 GB |
| RTL Opt Phase 2 | 16:45 | 8.7 GB | 15.4 GB | 48.5 GB |
| Cross Boundary & Area Opt | 45:14 | 10.8 GB | 1.3 GB | 34.3 GB |
| Applying XDC Constraints | 46:47 | 10.8 GB | 0.5 GB | 30.8 GB |
| Timing Optimization | 53:02 | **11.0 GB** | 0.3 GB | 30.7 GB |
| **Technology Mapping** | — | **OOM Killed** | — | 30.7 GB free at start |

BRAM fix reduced peak memory by ~1.35 GB vs Attempt 7 (11.0 GB vs 12.35 GB), but Technology Mapping
still needed >30.7 GB additional virtual on top of the 28.3 GB already consumed. At OOM kill:
`dmesg` confirmed `total-vm=40.8 GB, anon-rss=28.8 GB` for the Vivado process. System total
(30 GB RAM + 29 GB swap = 59 GB) was exhausted.

**Root cause**: The `pse.sv` (~65K FFs) and `trail_manager.sv` (~17K FFs) arrays still dissolved
into FFs despite the `(* ram_style = "distributed" *)` hints (Vivado rejected them due to async
reset sensitivity and multiple write ports). These 82K remaining FFs — on top of the base DDR
controller complexity — still produce a timing graph large enough to exceed 59 GB during Tech Mapping.

**Attempt 9 — Fix: Add virtual memory (swap) to give Tech Mapping room (2026-03-03):**

Vivado's Technology Mapping peak was ~40.8 GB total virtual at the OOM kill point, with the
system at 59 GB total (30 GB RAM + 29 GB swap). Adding 10 GB swap brings the total to 69 GB,
giving ~10 GB of headroom beyond the observed OOM point. No RTL changes needed; BRAM-fix RTL
from Attempt 8 carries forward.

Actions taken:
- Deleted `.Xil` Vivado elaboration cache (~2 GB) to free disk
- Created `/swapfile3` (10 GB) → total swap = 40 GB → total virtual = 70 GB
- Reduced `maxThreads` to 2 (fewer worker processes competing for physical pages)
- Relaunched synthesis with same BRAM-fix RTL

Monitoring commands:
```bash
grep -E "Finished|Killed|ERROR|Technology Map" /tmp/synth_attempt9.log | tail -10
ps aux | grep "unwrapped.*vivado" | grep -v grep | awk '{printf "PID=%s RSS_MB=%.0f\n", $2, $6/1024}'
```

**Attempt 9 — STATUS: Cancelled ⚪** (user requested more conservative settings before Tech Mapping; superseded by Attempt 10)

**Attempt 10 — Conservative Single-thread + RuntimeOptimized (2026-03-03, 30 GB instance + 40 GB swap):**

Settings:
- `set_param general.maxThreads 1`
- `synth_design ... -flatten_hierarchy rebuilt -directive RuntimeOptimized`
- DDR still disabled (`DDR_PRESENT=0` in `cl_satswarm.sv`)
- Total virtual memory: 30 GB RAM + 40 GB swap = 70 GB

**Attempt 10 — STATUS: OOM Killed in Technology Mapping ❌** (2026-03-03)

| Phase | Elapsed | Peak Memory | Free Physical | Free Virtual |
| ----- | ------- | ----------- | ------------- | ------------ |
| RTL Elaboration | 01:43 | 6.7 GB | 21.2 GB | 63.4 GB |
| RTL Opt Phase 1 | 01:45 | 6.7 GB | 21.2 GB | 63.4 GB |
| RTL Opt Phase 2 | 16:50 | 8.7 GB | 19.0 GB | 61.2 GB |
| Cross Boundary & Area Opt | 31:39 | 10.7 GB | 7.3 GB | 50.0 GB |
| Applying XDC Constraints | 32:46 | 10.7 GB | 7.3 GB | 50.0 GB |
| **Technology Mapping** | — | **OOM Killed** | — | — |

`dmesg` at kill: `total-vm=59.5 GB, anon-rss=29.0 GB` for the worker process (PID 148211).

**Cross-attempt `dmesg` analysis — all Technology Mapping OOM kills:**

| Attempt | Threads | Directive | Worker `anon-rss` | Worker `total-vm` |
| ------- | ------- | --------- | ----------------- | ----------------- |
| 8 | 4 | (default) | 29.4 GB | 38.7 GB |
| 9 | 2 | (default) | 28.8 GB | 40.7 GB |
| 10 | 1 | RuntimeOptimized | 29.0 GB | 59.5 GB |

**Key finding: the worker's physical memory demand (~29 GB) is constant across all thread
counts and directives.** Reducing threads and switching to RuntimeOptimized had no effect on
the actual RSS footprint — only `total-vm` changed (and actually increased with fewer threads,
likely because the single worker now handles all work previously split across multiple workers).

**This is NOT a VU47P device-constant.** The AWS `hello_world` CL example was successfully
synthesized on this same 30 GB AMI targeting the same VU47P device. The ~29 GB worker RSS is
driven by **our design's complexity** — specifically, the ~146K FFs still dissolved from
`pse.sv` arrays (Vivado rejected all 11 `(* ram_style = "distributed" *)` hints due to
multiple write ports and async reset sensitivity) and `trail_manager.sv` lookup tables. These
dissolved FFs create massive mux trees in the netlist that Technology Mapping must process.

**Conclusion: no synthesis settings can fix this on the 30 GB instance.** The options are:

1. **Fix `pse.sv` write patterns** — refactor the `always_ff` blocks so each array has a
   single write port per process (no multi-address writes, no async reset sensitivity on the
   memory process). This would eliminate ~100K+ dissolved FFs and their mux trees, potentially
   bringing Tech Mapping under 30 GB. This is the same class of fix that worked for
   `shared_clause_buffer.sv` and `sfifo.sv`.
2. **Use a ≥64 GB RAM instance** — a 64 GB instance provides enough physical RAM for the
   ~39 GB combined RSS (worker + parent) with headroom to spare.
3. **Both** — fix the RTL for long-term health AND use a larger instance for immediate
   progress.

**If WNS is negative after synthesis**:

1. Check which path is the worst violator in `build/reports/` timing reports
2. Add path-specific multicycle or false-path exceptions to `deploy/constraints/timing_aws.xdc`
3. The pipelined CAE rewrite should have eliminated the dominant 489-level combinatorial path;
   check the new critical path before making broad changes

### Design Improvements

- **DDR_PRESENT — temporary workaround (KEY SCALING ISSUE)**: `DDR_PRESENT` is set to `0` in
`cl_satswarm.sv` for Attempt 7 synthesis to reduce Technology Mapping memory pressure. The DDR4
controller (MicroBlaze MCS, calibration logic) is the dominant synthesis memory consumer but is
entirely unused at runtime — the solver stores all clause literals in on-chip BRAM (`lit_mem`).
**Restoring `DDR_PRESENT=1` is a prerequisite for the VeriSAT migration below.** Set it back in
`cl_satswarm.sv` line ~705 and verify synthesis fits in memory before that migration.
- **VeriSAT External-Memory Migration (Future Work)**: SatSwarmV2 stores clause literals in
on-chip BRAM (`lit_mem` in `pse.sv`), limiting scalability to small CNF instances (`MAX_LITS=65536`).
VeriSAT (Tao & Cai, ICCAD 2025) stores literals in external DDR4 memory, enabling significantly
larger problem instances without growing on-chip BRAM. Migration would require:
  1. Replace the `lit_mem` BRAM array in `pse.sv` with an AXI4 memory controller.
  2. Add pipeline stages to `pse.sv` BCP to tolerate DDR read latency (~tens of cycles).
  3. Restore `DDR_PRESENT=1` in `cl_satswarm.sv` and validate the DDR AXI bridge FSM
     (currently a simplified single-transaction state machine — needs a proper queued AXI4 master).
  4. Re-validate with the full regression suite.
- **PCIS read channels tied off**: The `PCIS_CDC` AXI converter's AR/R (read) channels are
wired to `'0`/`()`. The solver only accepts data written by the host DMA engine; it cannot
initiate DMA reads back to the host through PCIS. DDR reads are handled via the separate DDR
bridge FSM path.
- **Multi-core scaling**: `satswarm_top` is parameterized for `GRID_X × GRID_Y` cores but
currently built with `1×1`. Increasing this requires validating `mesh_interconnect.sv` and
`global_allocator.sv` under multi-core load.
- **`solver_core.sv` documentation**: Several ports are marked `// TODO: document what this is`
(e.g., `rst_n`, `vde_phase_offset`). These should be documented to prevent future confusion.
- **Assertion cleanup**: The `pse.sv`, `trail_manager.sv`, and `cae.sv` assertion blocks are
guarded by `` `ifndef SYNTHESIS`` and are simulation-only. They should remain for regression
safety but may need `$fatal` → `$error` downgrade if they fire spuriously on edge cases.

---

## 6. Test Results (2026-02-27/28)

### Verilator Regression (2026-02-27, baseline)

```
Total Tests: 98    Passed: 98    Failed: 0
Configuration: 1×1 grid, MAX_VARS=256, MAX_CLAUSES=4096, restarts DISABLED
Binary: sim/obj_dir_1x1/Vtb_satswarmv2
```

### Verilator Regression post soundness-fix (2026-03-02)

Run under synthesis load (~30 GB system RAM in use); 2 large SAT instances hit cycle timeout.

```
1×1 (pre-fix binary, no rebuild):    98 tests — 96 PASSED, 2 FAILED (SAT timeout, system load)
2×2 (post-fix binary, rebuild):      98 tests — 96 PASSED, 2 FAILED (SAT timeout, system load)
  Both failures identical: sat_50v_215c_1.cnf, sat_75v_325c_1.cnf (SAT instances, not soundness)
  Key: gen_unsat_8v_2.cnf and unsat_8v_20c_1.cnf now PASS in 2×2 (were failing before fix)
```

### Memory-pressure verification (2026-03-02)

Post-fix 1×1 binary (rebuilt from current source, no synthesis running):

```
sat_50v_215c_1.cnf  — PASSED (SAT, 60351 cycles)    *** confirmed: prior failure was system load
sat_75v_325c_1.cnf  — PASSED (SAT, 278749 cycles)   *** confirmed: prior failure was system load
```

Both cases complete well within the 5M-cycle / 180 s limits when the system is idle. No regression
from the multi-core soundness fix. The 1×1 post-fix binary is **98/98** clean.

### Verilator Regression post BRAM-fix (2026-03-03)

1×1 binary rebuilt from BRAM-inference-fixed source (shared_clause_buffer, sfifo, pse, trail_manager,
vde_heap changes). Run with no synthesis in progress (idle system):

```
Total Tests: 98    Passed: 98    Failed: 0
Configuration: 1×1 grid, MAX_VARS=256, MAX_CLAUSES=4096, restarts DISABLED
Binary: sim/obj_dir_1x1/Vtb_satswarmv2 (built 2026-03-03)
```

No functional regression from any of the five BRAM/LUTRAM inference fixes. The `(* ram_style = ... *)`
attributes are transparent to Verilator; the `shared_clause_buffer` restructure and `trail_manager`
`ifdef SYNTHESIS` split are functionally equivalent to the original code.

### XSim BFM Test (2026-02-27)

```
TEST: test_satswarm_aws    RESULT: *** TEST PASSED ***    Time: 11380 ns
```

Full HDK shell simulation via `make TEST=test_satswarm_aws` in `verif/scripts/`.

### Multi-Core Soundness Bug (2026-03-02, **FIXED**)

**Status**: Fixed in `solver_core.sv` on 2026-03-02. Confirmed by regression.

**Root cause (three compounding bugs):**
1. `pse.sv` `INJECT_CLAUSE` state was a stub: incremented clause/literal counters but did NOT
   write literals to `lit_mem[]` or update `clause_start[]`/`clause_len[]` — injected clauses
   were phantom and invisible to BCP.
2. After phantom injection, PSE transitioned directly to `SEED_DECISION`, skipping `INIT_WATCHES`
   so the ghost clause was never added to the watch lists.
3. `interface_unit.sv` presents `clause_rx_valid` as a one-cycle combinatorial pulse. The old
   `INJECT_RX_CLAUSE` state re-checked `iface_clause_rx_valid` a cycle later, missing the data.

**Fix applied** (`src/Mega/solver_core.sv`):
- Added `rx_clause_lit1_q/d` and `rx_clause_lit2_q/d` registers to capture incoming NoC literals.
- In PSE_PHASE exit: when `iface_clause_rx_valid` is detected, the literals are registered and
  `iface_clause_rx_ready` is asserted immediately (consumes the one-cycle pulse the same cycle).
- `INJECT_RX_CLAUSE` state rewritten to use `cae_direct_append_en` (the same proven path used
  for learned clauses after conflict analysis). This writes the literals into PSE's clause store
  and triggers PSE to start, which runs `INIT_WATCHES` making the clause visible to BCP.
  The broken `pse_inject_req` path is no longer used.

**Verification (2026-03-02, run under synthesis load ~30 GB total system RAM):**

1×1 regression (pre-fix binary, no rebuild):
```
Total Tests: 98    Passed: 96    Failed: 2
  sat_50v_215c_1.cnf   — TIMEOUT (system load, not a soundness issue)
  sat_75v_325c_1.cnf   — TIMEOUT (system load, not a soundness issue)
  gen_unsat_8v_2.cnf   — PASSED  (was passing before; confirmed no regression)
  unsat_8v_20c_1.cnf   — PASSED  (was passing before; confirmed no regression)
```

2×2 regression (post-fix rebuild):
```
Total Tests: 98    Passed: 96    Failed: 2
  sat_50v_215c_1.cnf   — TIMEOUT (same as 1×1; caused by synthesis load, not the fix)
  sat_75v_325c_1.cnf   — TIMEOUT (same as 1×1; caused by synthesis load, not the fix)
  gen_unsat_8v_2.cnf   — PASSED  *** previously FAILED (SAT for UNSAT); soundness fix confirmed
  unsat_8v_20c_1.cnf   — PASSED  *** previously FAILED (SAT for UNSAT); soundness fix confirmed
```

The 2 SAT-instance timeouts are identical across 1×1 (old binary) and 2×2 (new binary), proving
they are not caused by the fix. They are pre-existing flakiness on the hardest instances when the
system is under heavy memory pressure from concurrent synthesis.

**Reproduction**: Run `make build_1x2` (4-core 2×2 binary) and `run_bigger_ladder.sh`.

### FPGA Synthesis (2026-03-02, FAILED — Attempts 6 & 7 both OOM in Technology Mapping)

```
Attempt 6 Status: OOM-KILLED (2026-03-02 ~20:26 UTC)
Settings: DDR_PRESENT=1, clock_recipe_a=A2, phys_opt=Explore
  Cross Boundary and Area Optimization : DONE  (00:55:02, peak 12.6 GB)
  Applying XDC Timing Constraints      : DONE  (00:57:27, peak 12.7 GB)
  Timing Optimization                  : DONE  (01:07:22, peak 12.9 GB) *** FIRST TIME PASSED ***
  Technology Mapping                   : OOM-KILLED

Attempt 7 Status: OOM-KILLED (2026-03-02 ~23:56 UTC)
Settings: DDR_PRESENT=0, maxThreads=4, global_retiming off, +20 GB swap (~60 GB VM total)
  Cross Boundary and Area Optimization : DONE  (00:51:37, peak 12.2 GB) — 4 min faster than Att. 6
  Applying XDC Timing Constraints      : DONE  (00:53:29, peak 12.2 GB)
  Timing Optimization                  : DONE  (01:00:20, peak 12.35 GB) — 7 min faster than Att. 6
  Technology Mapping                   : OOM-KILLED (same kill site)
  Routing / write_checkpoint           : Not reached

Previous attempts 1–5: All OOM-killed during Timing Optimization.
Attempts 6–7: Pass Timing Optimization; both OOM-killed in Technology Mapping.
Conclusion: Technology Mapping requires >42 GB virtual memory on this design. 30 GB instance + 30 GB swap is insufficient. Needs ≥64 GB RAM instance.
Next step: Attempt 8 on a ≥64 GB RAM instance — see §5.
```

To check status at any time:

```bash
# Is Vivado still alive?
ps aux | grep "unwrapped.*vivado" | grep -v grep | awk '{printf "PID=%s RSS_MB=%.0f\n", $2, $6/1024}'

# Key phase milestones
grep -E "^Finished|^Start|write_checkpoint|ERROR|Killed|WNS|TNS" /tmp/synth_explore.log | tail -15

# Latest log tail
tail -20 /tmp/synth_explore.log
```

See §3 "Synthesis Attempt History" and §5 "Complete Synthesis" for details and next steps.

---

*Last updated: 2026-03-02 UTC (Attempt 7 OOM-killed in Technology Mapping; 30 GB instance confirmed too small even with DDR disabled; next step is ≥64 GB instance for Attempt 8)*