# SatSwarm V2 — Project Handoff

Welcome. This document captures the **current state** of SatSwarmV2 development, passing context from the previous agent to you.

---

## 1. Documentation Navigation

The repository's documentation has been modularized:
- **[README.md](README.md)**: Start here. Architecture, core RTL overviews, and repository structure.
- **[Deploy.md](Deploy.md)**: Synthesis methodology. How to use AWS HDK, build DCPs, and create Amazon FPGA Images (AFI).
- **[Verification.md](Verification.md)**: Testing and debugging. Verilator commands, regression suites, and inference checks.
- **[Changes.md](Changes.md)**: Historical log. Read this before undoing past work (e.g. why `pse.sv` BRAM inference failed 21 times).
- **[FPGA.md](FPGA.md)**: Final bitstream details and Amazon FPGA Image (AFI) creation instructions.
- **HANDOFF.md (This File)**: Living state of the project.

---

## 2. Last Agent Session (2026-03-18, continued — bigger_ladder timing fix)

**Primary objectives completed this session:**
1. Identified root cause of all prior AFI failures: DRC REQP-123 (fixed).
2. Discovered and fixed timing failure at 150 MHz in `vde_heap.sv` (bigger_ladder).
3. Verified RTL fix via Verilator simulation: `run_bigger_ladder.sh` 98/98 PASSED.
4. Launched new 1×1 build at 150 MHz (A1 recipe) with the pipeline fix — **currently running**.

### REQP-123 DRC Root Cause & Fix

All prior AFI submissions failed with `UNKNOWN_BITSTREAM_GENERATE_ERROR`. AWS backend Vivado logs revealed the true cause: **DRC REQP-123** — `MMCME4_ADV.CLKIN1` was driven by `1'b0` (constant) instead of a real toggling clock. AWS `ingest.tcl` resets all DRC severities to ERROR before `write_bitstream`, making local Warning suppressions ineffective.

**Fix** (1 line, `cl_satswarm.sv:94`, commit `fd6a0a3`):
```diff
- .i_clk_hbm_ref (1'b0),
+ .i_clk_hbm_ref (clk_hbm_ref),
```

**Do NOT resubmit any tars built before this fix** — they will all fail AWS bitgen with REQP-123.

### Timing Failure at 150 MHz — bigger_ladder

A post-REQP-123-fix build (tag `2026_03_18-120815`, A1/150 MHz) completed but had **WNS = -18.135 ns**. Do not submit this tar.

**Root cause**: `vde_heap.sv` `BUMP_UPDATE_WRITE` state — BRAM read output fed directly into 32-bit adder → BRAM write data in one cycle (24.6 ns path, 176 logic levels, 145 CARRY8). Clock period is 6.667 ns.

**Fix** (`vde_heap.sv`, commit `bab99f4`): Added `BUMP_UPDATE_PIPE` state that registers `rdata_h1` into `bump_rdata_q` before the adder. `BUMP_UPDATE_WRITE` uses `bump_rdata_q` instead of the raw BRAM output.

**Verification**: `sim/scripts/run_bigger_ladder.sh` — **98/98 PASSED** after fix.

---

## 3. Current Project State

- **Design configuration**: 1×1 grid (1 solver core) — `GRID_X=1, GRID_Y=1`
- **Build process**: ⏳ **RUNNING** — PID 35679, log `/home/ubuntu/buildall_1x1_150mhz_pipelined_20260318_142140.log`
- **Clock**: A1 recipe (`clk_out1_clk_mmcm_a` = 150 MHz, 6.667 ns)

### Build Artifacts

| Build | Tag | Timing | Developer_CL.tar | S3 | AFI | Notes |
|---|---|---|---|---|---|---|
| 1×1 A2 | `2026_03_18-004125` | WNS=+0.711 ns ✅ | ✅ | ✅ | ❌ REQP-123 fail | Pre-fix, **do not resubmit** |
| 2×2 A2 | `2026_03_18-020509` | WNS=+0.711 ns ✅ | ✅ | ✅ | ⏳ `afi-0a3e524ae986734e5` | Pre-fix, **do not resubmit** |
| 1×1 A1 | `2026_03_18-120815` | WNS=-18.135 ns ❌ | ✅ | ❌ | — | Timing fail, **do not submit** |
| 1×1 A1 pipelined | in progress | — | — | — | — | **This build** |

All artifacts under: `src/aws-fpga/hdk/cl/examples/cl_satswarm/build/checkpoints/`

### AWS Infrastructure

- **S3 bucket**: `satswarm-v2-afi-624824941978`
- **S3 key pattern**: `dcp/<tag>.Developer_CL.tar`
- **Logs prefix**: `logs/`
- **AWS account**: `624824941978`
- **IAM role**: `TateFPGABuilder`
- `aws s3 ls` (ListAllMyBuckets) is denied — use explicit bucket paths.
- `aws ec2 create-fpga-image` permission confirmed.

### Key Active Parameters

| Parameter | Value | Files |
|---|---|---|
| `GRID_X` × `GRID_Y` | **1×1** | `cl_satswarm.sv`, `satswarm_core_bridge.sv`, `satswarm_top.sv`, `mesh_interconnect.sv` |
| `DDR_PRESENT` | 0 | `cl_satswarm.sv` |
| `RESTART_CONFLICT_THRESHOLD` | 65535 (Disabled) | `satswarmv2_pkg.sv` |
| Clock Recipe | **A1 (150 MHz)** | build command |
| `i_clk_hbm_ref` | `clk_hbm_ref` (fixed) | `cl_satswarm.sv:94` |

---

## 4. Immediate Next Steps (For Next Agent)

### Priority 1: Confirm Build Passes Timing

Check the running build log (PID 35679):
```bash
tail -20 /home/ubuntu/buildall_1x1_150mhz_pipelined_20260318_142140.log
```

Once it completes, verify timing:
```bash
grep "WNS\|Build completes\|ERROR" /home/ubuntu/buildall_1x1_150mhz_pipelined_20260318_142140.log | tail -10
```

Pass criteria: `WNS >= 0` and `Build completes` in log. If timing still fails, check `build/reports/cl_satswarm.<tag>.post_route_timing.rpt` for the new critical path.

### Priority 2: Upload and Submit AFI

Once timing is met:
```bash
# Upload
TAG=<new-tag>  # from build log
aws s3 cp \
  /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/hdk/cl/examples/cl_satswarm/build/checkpoints/${TAG}.Developer_CL.tar \
  s3://satswarm-v2-afi-624824941978/dcp/${TAG}.Developer_CL.tar

# Submit
aws ec2 create-fpga-image \
  --name "SatSwarmV2-1x1-150MHz" \
  --description "SatSwarm V2 CDCL solver, 1x1 grid, 150 MHz (A1), REQP-123+timing fixed" \
  --input-storage-location "Bucket=satswarm-v2-afi-624824941978,Key=dcp/${TAG}.Developer_CL.tar" \
  --logs-storage-location "Bucket=satswarm-v2-afi-624824941978,Key=logs/" \
  --region us-east-1
```

### Priority 3: Build 2×2 at 150 MHz

After 1×1 AFI is submitted, switch to 2×2 and rebuild:
- Change `GRID_X=1, GRID_Y=1` → `GRID_X=2, GRID_Y=2` in four files (see previous session)
- Rerun the same build command with the same clock recipe (A1)
- Verify timing, upload, submit

### Priority 4: Poll and Load

```bash
aws ec2 describe-fpga-images \
  --fpga-image-ids <afi-id> \
  --query 'FpgaImages[*].{Id:FpgaImageId,State:State}' \
  --region us-east-1
```

Once `available`:
```bash
source /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/sdk_setup.sh
sudo fpga-clear-local-image -S 0
sudo fpga-load-local-image -S 0 -l <agfi-id>
sudo fpga-describe-local-image -S 0 -H
```

---

## 5. Operational Notes

### HDK Environment Setup Workaround (IMPORTANT)

`hdk_setup.sh` **cannot be sourced** in this directory. The script calls `git rev-parse --show-toplevel` to determine `repo_root`. Since `SatSwarmV2` is not a git repository, `git rev-parse` returns empty and `set_common_env_vars.sh` resets `AWS_FPGA_REPO_DIR` to empty string, breaking all downstream paths.

**Working approach — set all vars manually:**
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
export VIVADO_TOOL_VERSION=2025.2
export XILINX_VIVADO=/opt/Xilinx/2025.2/Vivado
export PATH=/opt/Xilinx/2025.2/Vivado/bin:$PATH
```

Then run the build command inside the same `bash -c '...'` block so env vars are inherited by the child process.

### Tar File Location

The AWS BuildAll script places `Developer_CL.tar` in:
```
$CL_DIR/build/checkpoints/<tag>.Developer_CL.tar
```
(Not in a `to_aws/` subdirectory as older docs state.)

### Design Files: Two Separate Copies

There are two copies of the CL design files with **different inodes** — only one is used by the build:
- `src/aws-fpga/hdk/cl/examples/cl_satswarm/design/` ← **USED by build**
- `src/Mega/` ← **USED by build**
- `hdk_cl_satswarm/design/` ← NOT used by build (stale copy, may be out of date)

---

**Note to next agent**: Update this file after your session with final AFI IDs (1×1 retry and 2×2), their states, and any new issues encountered.
