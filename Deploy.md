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

*Note: A2 (15.625 MHz) was used in earlier sessions and met timing but is very slow. A0 caused OOM during Timing Optimization at prior attempts. A1 (150 MHz) is the current target — timing closes after the `vde_heap` pipeline fix (see [Changes.md](Changes.md)).*

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
  --clock_recipe_a A1 --clock_recipe_b B0 --clock_recipe_c C0 \
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
  --cl cl_satswarm -f ImplCL -t "2026_03_18-120815" \
  --aws_clk_gen --clock_recipe_a A1 --clock_recipe_b B0 --clock_recipe_c C0 \
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
