# Deployment, Synthesis & AFI Methodology

This document consolidates the end-to-end synthesis instructions, AWS FPGA Developer tools, and quick-check workflows for bringing SatSwarmV2 to AWS F2 (Xilinx VU47P).

---

## Initialize HDK Environment (Prerequisite)

Before any AWS build step, the HDK environment variables must be populated.

> **Warning**: `hdk_setup.sh` **cannot be sourced** from this project. It calls `git rev-parse --show-toplevel` to locate the repo root; since `SatSwarmV2` is not a git repository, this returns empty and zeros out `AWS_FPGA_REPO_DIR`, breaking all downstream paths.

**Set all required vars manually:**

```bash
export AWS_FPGA_REPO_DIR=/home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga
export HDK_DIR=$AWS_FPGA_REPO_DIR/hdk
export HDK_COMMON_DIR=$HDK_DIR/common
export HDK_SHELL_DIR=$HDK_COMMON_DIR/shell_stable
export HDK_SHELL_DESIGN_DIR=$HDK_SHELL_DIR/design
export HDK_IP_SRC_DIR=$HDK_COMMON_DIR/ip/cl_ip/cl_ip.srcs/sources_1/ip
export HDK_BD_SRC_DIR=$HDK_COMMON_DIR/ip/cl_ip/cl_ip.srcs/sources_1/bd
export HDK_BD_GEN_DIR=$HDK_COMMON_DIR/ip/cl_ip/cl_ip.gen/sources_1/bd
export CL_DIR=$AWS_FPGA_REPO_DIR/hdk/cl/examples/cl_satswarm
export FAAS_CL_DIR=$CL_DIR
export VIVADO_TOOL_VERSION=2025.2
export XILINX_VIVADO=/opt/Xilinx/2025.2/Vivado
export PATH=/opt/Xilinx/2025.2/Vivado/bin:$PATH
```

These exports must live in the **same shell** (or `bash -c '...'` block) as the build command that follows, so the child process inherits them.

---

## AWS Quick-Check Workflow

Before embarking on a full Vivado build (which can take 10+ hours and consume huge RAM), utilize quick-check tools on the AWS AMI to catch syntax, connectivity, and simple RTL errors.

### Tools Available
- **Vivado CLI**: Fast syntax-only checks (`check_syntax`).
- **File Linting**: Compile individual files via `xvhdl -check_syntax` or `xvlog -lint +all`.
- **Out-of-context Synthesis**: `synth_design -top <module> -mode out_of_context` to catch elaboration errors early.
- **XSim**: Basic simulation functionality (see [Verification.md](Verification.md)).

### Quick-Check Steps

1. **Syntax & Lint:** Compile all RTL files pointing to `$CL_DIR/design/*.sv`. Fix any missing semicolons or undeclared signals.
2. **Out-of-Context Synthesis:** Use `synth_design -mode out_of_context` on the top module to confirm it elaborates.
3. **DRC Checks:** Run `report_drc` on the synthesized design for major rule violations.
4. **Constraint Sanity:** Ensure your `.xdc` has basic clocks and pins for the CL.

> **Why?** A quick syntax/lint/synth check taking minutes can save hours of AWS EC2 billing. Only proceed to full implementation when quick checks are clean.

---

## Testing & Simulation (Pre-Synthesis Gate)

Run these checks in order before every Vivado build. Verilator catches logic bugs in seconds; Vivado synthesis takes hours and consumes significant RAM.

### Prerequisites

```bash
# Verilator (one-time install; v5.020 confirmed working)
sudo apt-get install -y verilator

# All sim commands below run from the sim directory
cd /home/ubuntu/src/project_data/SatSwarmV2/sim
```

---

### 1. Build the Verilator Binary

The Makefile produces grid-specific binaries in separate `obj_dir_*` folders.

| Target | Grid | Binary | Use |
|---|---|---|---|
| `make build_1x1` | 1×1 | `obj_dir_1x1/Vtb_satswarmv2` | Default regression and CI |
| `make build_2x2` | 2×2 | `obj_dir_2x2/Vtb_satswarmv2` | Multi-core soundness (4 cores) |
| `make build_3x3` | 3×3 | `obj_dir_3x3/Vtb_satswarmv2` | 9-core scalability tests |
| `make mini` | 1×1 Mini DPLL | `obj_dir_mini/Vtb_mini` | DPLL-only baseline (no CDCL) |
| `make test_vde_heap` | — | `obj_dir/Vtb_vde_heap` | Variable-decision heap unit test |

```bash
# Most common: 1x1 build
make build_1x1

# After building 1x1, create the canonical obj_dir symlink that run_bigger_ladder.sh uses:
ln -sfn obj_dir_1x1 obj_dir
```

> **Note**: `build` (no suffix) is an alias for `build_1x1` and also copies the binary to `obj_dir/`. The symlink is more reliable for scripts that look for `obj_dir/Vtb_satswarmv2`.

---

### 2. Run a Single CNF File

Use `scripts/run_cnf.sh` to drive the 1×1 binary against any DIMACS `.cnf` file:

```bash
# Basic usage
bash scripts/run_cnf.sh tests/unit_tests/simple_sat1.cnf SAT

# With explicit cycle limit and debug output
bash scripts/run_cnf.sh tests/unit_tests/simple_unsat1.cnf UNSAT 2000000 +DEBUG=1
```

Or invoke the binary directly with Verilator plus-args:

```bash
./obj_dir/Vtb_satswarmv2 \
  +CNF=tests/generated_instances/sat_50v_215c_1.cnf \
  +EXPECT=SAT \
  +TIMEOUT=5000000 \
  +DEBUG=0
```

**Debug levels** (pass as `+DEBUG=<level>`):

| Level | Output |
|---|---|
| `0` | Silent — fastest; for regression |
| `1` | FSM state changes, conflict variables, decisions, learned clauses |
| `2` | Full verbosity including watch-list replacements |

> **Critical**: The argument is `+EXPECT=`, **not** `+EXPECTED=`. A typo silently ignores the check.

**Mini DPLL baseline** (no CDCL — useful for isolating BCP vs. conflict-analysis bugs):

```bash
bash scripts/run_mini_cnf.sh tests/unit_tests/simple_sat1.cnf SAT
```

---

### 3. Run the Full Regression (Bigger Ladder)

`run_bigger_ladder.sh` runs every `.cnf` file in `tests/generated_instances/` (98 files, 4v–75v). File names encode expected results: files containing `sat` → expect SAT, `unsat` → expect UNSAT.

```bash
# Requires the obj_dir symlink (set up in step 1):
ln -sfn obj_dir_1x1 obj_dir

bash scripts/run_bigger_ladder.sh
```

Expected output ends with:
```
Total Tests: 98
Passed:      98
Failed:      0
ALL TESTS PASSED
```

To run only the unit-test subset (minimal and pure-literal cases in `tests/unit_tests/`):

```bash
bash scripts/run_unit_tests.sh
```

This script compiles and runs dedicated per-module testbenches for `tb_vde`, `tb_trail_manager`, and `tb_cae`.

---

### 4. VDE Heap Unit Test

The variable-decision heap (`vde_heap.sv`) has a dedicated testbench that tests the BUMP_UPDATE pipeline fix (commit `bab99f4`). Always run this after any change to `vde_heap.sv`:

```bash
make test_vde_heap
```

---

### 5. Multi-Core Soundness (2×2 Build)

```bash
make build_2x2

# Run a single file against the 4-core build
./obj_dir_2x2/Vtb_satswarmv2 \
  +CNF=tests/generated_instances/sat_50v_215c_1.cnf \
  +EXPECT=SAT +TIMEOUT=5000000 +DEBUG=0
```

> **Note**: `tb_satswarmv2.sv` references `dut.cols[0].rows[1]`, `dut.cols[1].rows[0]`, and `dut.cols[1].rows[1]` under `ifdef MULTICORE`. Verilator resolves these hierarchical paths at elaboration time, so only `GRID_X≥2, GRID_Y≥2` is supported. A true 1×2 config requires generate-based signal aliasing in the testbench.

---

### 6. AWS HDK XSim Integration Test

Run this before submitting to Vivado to verify the AXI shell interconnect is wired correctly:

```bash
# HDK env must be set (see "Initialize HDK Environment" above)
cd /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/hdk/cl/examples/cl_satswarm/verif/scripts

# Single AWS BFM smoke test
make TEST=test_satswarm_aws
```

Expected: `TEST: test_satswarm_aws    RESULT: *** TEST PASSED ***    Time: 11380 ns`

**Full AWS regression over all generated instances** (XSim is ~10× slower than Verilator; each file has a 180 s timeout):

```bash
# From the SatSwarmV2 root
bash sim/scripts/run_aws_regression.sh
```

> **Warning**: `run_aws_regression.sh` requires `$HDK_DIR` to be set. Use the manual env-var block from "Initialize HDK Environment" first.

---

### Testing Workflow Summary

```
make build_1x1 && ln -sfn obj_dir_1x1 obj_dir   # build once
make test_vde_heap                                 # heap unit test
bash sim/scripts/run_bigger_ladder.sh              # 98-file regression
# If all pass → proceed to BRAM inference check, then Vivado build
```

---

## Verifying BRAM Inference

A key scaling blocker for SAT solvers is preventing Vivado from dissolving massive memory arrays into individual flip-flops. Always test array inference on `pse.sv` and `trail_manager.sv` before a full build.

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2

# Background monitor (recommended for fast iteration)
bash deploy/check_inference.sh -b pse

# Watch for the results live:
tail -f deploy/logs/synth_pse.log | grep --line-buffered -E "Synth 8-3390|Synth 8-3391|Synth 8-4767|dissolved|multiple write|Finished|ERROR|Killed"
```

Authoritative reading of `check_inference.sh` output requires opening `deploy/logs/synth_pse.log` and finding the `Distributed RAM: Final Mapping Report`. If your target array isn't listed, it dissolved into flip-flops (and will eventually crash Technology Mapping via OOM). See `Changes.md` for historical details.

---

## Running SatSwarm Synthesis

Once inference is verified, kick off full synthesis.

```bash
# Preferred launcher (handles HDK env sourcing/paths)
cd /home/ubuntu/src/project_data/SatSwarmV2/deploy
./run_synthesis.sh 2>&1 | tee logs/synth_explore.log &
```

### Current Launcher Settings

- **Clock Recipe A (`--clock_recipe_a A1`)**: Configures `clk_out1_clk_mmcm_a` = 150 MHz (6.667 ns period). This is the clock domain used by the SatSwarm core (`satswarm_core_bridge`, `vde_heap`, etc.).
- **`--aws_clk_gen`**: Required when specifying custom clock recipes. Without this flag the build script rejects `--clock_recipe_*` arguments.

*Note: **A2 (15.625 MHz) is the current working clock** — WNS = +0.711 ns on both 1×1 and 2×2 builds. A1 (150 MHz) requires additional RTL pipelining in `pos_mem`/bubble logic (WNS = −18.820 ns after `vde_heap` fix alone). Do not attempt A1 until A2 deployment is confirmed. See [Changes.md](Changes.md) for history.*

### Clock Domain Crossing Setup

Clock boundaries transition across AXI paths: OCL, PCIS, and DDR.
- The `cl_satswarm.sv` instantiation uses `cl_axi_clock_converter` and `cl_axi_clock_converter_light`.
- All `satswarm_core_bridge` logic runs in the `clk_out1_clk_mmcm_a` domain (150 MHz with A1 recipe).

---

## Running Full Build (BuildAll)

Once synthesis writes a clean checkpoint (`*.synthesis.dcp`), kick off implementation mapping:

```bash
# All vars must be in the same shell as the build command:
export AWS_FPGA_REPO_DIR=/home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga
export HDK_DIR=$AWS_FPGA_REPO_DIR/hdk
export HDK_COMMON_DIR=$HDK_DIR/common
export HDK_SHELL_DIR=$HDK_COMMON_DIR/shell_stable
export HDK_SHELL_DESIGN_DIR=$HDK_SHELL_DIR/design
export HDK_IP_SRC_DIR=$HDK_COMMON_DIR/ip/cl_ip/cl_ip.srcs/sources_1/ip
export HDK_BD_SRC_DIR=$HDK_COMMON_DIR/ip/cl_ip/cl_ip.srcs/sources_1/bd
export HDK_BD_GEN_DIR=$HDK_COMMON_DIR/ip/cl_ip/cl_ip.gen/sources_1/bd
export CL_DIR=$AWS_FPGA_REPO_DIR/hdk/cl/examples/cl_satswarm
export FAAS_CL_DIR=$CL_DIR
export VIVADO_TOOL_VERSION=2025.2
export XILINX_VIVADO=/opt/Xilinx/2025.2/Vivado
export PATH=/opt/Xilinx/2025.2/Vivado/bin:$PATH
LOG=/home/ubuntu/buildall_$(date +%Y%m%d_%H%M%S).log
cd $CL_DIR/build/scripts
nohup python3 aws_build_dcp_from_cl.py \
  --cl cl_satswarm --aws_clk_gen \
  --clock_recipe_a A2 --clock_recipe_b B0 --clock_recipe_c C0 \
  > "$LOG" 2>&1 &
echo "PID=$! LOG=$LOG"
```

> **Note**: The script must be run from `$CL_DIR/build/scripts/` — invoking it from another directory with a full path causes incorrect relative-path resolution for TCL includes.

The output tar lands at:
`$CL_DIR/build/checkpoints/<tag>.Developer_CL.tar`

> **Note**: Older docs refer to a `to_aws/` subdirectory — this is incorrect. The tar is placed directly under `checkpoints/`.

### Skipping Synthesis (`ImplCL`)

If your `post_synth.dcp` checkpoint is clean, skip the synthesis phase using the existing tag:

```bash
cd $CL_DIR/build/scripts
python3 aws_build_dcp_from_cl.py \
  --cl cl_satswarm -f ImplCL -t "2026_03_18-163435" \
  --aws_clk_gen --clock_recipe_a A2 --clock_recipe_b B0 --clock_recipe_c C0 \
  > /home/ubuntu/build_impl.log 2>&1 &
```
*Note: `ImplCL` skips tarball creation. You will need to manually generate `Developer_CL.tar` if using this flow.*

---

## Convert Synthesis DCP to AFI

After `BuildAll` is completed, the resulting tarball must be uploaded and transformed to an Amazon FPGA Image (AFI).

Tarball location:
`$CL_DIR/build/checkpoints/<timestamp>.Developer_CL.tar`

### 1. Upload to S3 Bucket

S3 bucket: `satswarm-v2-afi-624824941978` (already exists; `aws s3 ls` is denied by IAM but direct-path operations work).

```bash
# Upload tar (replace <tag> with actual timestamp tag)
aws s3 cp \
  $CL_DIR/build/checkpoints/<tag>.Developer_CL.tar \
  s3://satswarm-v2-afi-624824941978/dcp/<tag>.Developer_CL.tar
```

### 2. Create the AFI

```bash
aws ec2 create-fpga-image \
    --region us-east-1 \
    --name "SatSwarmV2-<grid>" \
    --description "SatSwarm V2 CDCL solver, <NxN> grid, 150 MHz (A1 recipe)" \
    --input-storage-location Bucket=satswarm-v2-afi-624824941978,Key=dcp/<tag>.Developer_CL.tar \
    --logs-storage-location Bucket=satswarm-v2-afi-624824941978,Key=logs/
```

*Save the returned FpgaImageGlobalId (`agfi-*`).*

### 3. Verify Availability and Load (AWS F2 Instance)

Poll the AWS CLI (this can take 30-60 minutes):

```bash
aws ec2 describe-fpga-images --fpga-image-ids fi-xxxx --query 'FpgaImages[0].State'
```

Once `{"Code": "available"}` appears, load it natively into the F2 shell:

```bash
source $AWS_FPGA_REPO_DIR/sdk_setup.sh
sudo fpga-clear-local-image  -S 0
sudo fpga-load-local-image   -S 0 -l agfi-xxxx
sudo fpga-describe-local-image -S 0 -H
```

Verify `StatusName: loaded`.

---

## Known Synthesis Warnings

You can safely ignore these known `CRITICAL WARNINGS` that emit during building:

| Code | Cause | Impact |
|---|---|---|
| `Designutils 20-1280` | Clock IPs registered as RTL sources instead of IP blocks, preventing corresponding XDCs from applying. | None — XDCs apply to shell-managed clocking, not CL logic. |
| `Synth 8-6858/6859` | Multi-driven payload outputs on unused NoC edges (e.g. `tx_pkt_n`). | None — Unconnected mesh outputs are safely tied to GND. |

---

## Future Deployment Improvements

### External DDR Migration (VeriSAT Scaling)

SatSwarmV2 currently sets `DDR_PRESENT=0` and stores all literals in partitioned BRAM (`lit_mem`).
To support massive SAT clauses (e.g. >65,536 max literals), the project should look toward VeriSAT architecture:
- Re-activate `DDR_PRESENT=1` inside `cl_satswarm.sv`.
- Switch `lit_mem` over to AXI4 multi-port memory queues on the F2 DDR.
- Pipelined latency changes inside the `pse.sv` BCP loop.
