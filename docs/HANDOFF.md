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

## 2. Last Agent Session (2026-03-18, continued — strategy change to A2/15.625 MHz)

**Primary objectives completed this session:**
1. Identified root cause of all prior AFI failures: DRC REQP-123 (fixed).
2. Discovered and fixed timing failure at 150 MHz in `vde_heap.sv` (bigger_ladder).
3. Verified RTL fix via Verilator simulation: `run_bigger_ladder.sh` 98/98 PASSED.
4. Killed failing A1 (150 MHz) build — phys_opt showed WNS = -18.820 ns on a *second* ~25 ns path in `pos_mem`/bubble logic beyond the one already fixed. 150 MHz requires more RTL pipelining work.
5. **Strategy change**: switched to A2 (15.625 MHz) which met timing cleanly (WNS = +0.711 ns) — get a working AFI deployed first, tackle 150 MHz timing closure separately.
6. A2 build completed but failed with **WNS = -1.627 ns** due to CDC violation: `solver_done/sat/unsat` (user clock domain) → `cl_sh_status_vled` (shell `clk_main_a0` domain) with no synchronizer.
7. **CDC fix** (commit `ef79614`): added `xpm_cdc_single` synchronizers for 3 status bits in `cl_satswarm.sv:840-848`.
8. Machine crashed (OOM — Claude process grew to ~30 GB RSS while Vivado used ~7 GB, exhausting 30 GB RAM).
9. After reboot: launched new A2 build with CDC fix — **completed** (WNS=+0.711 ns).
10. Uploaded tar to S3, submitted AFI — **afi-08366141b8a92b36f** now **available**.
11. Kicked off 2×2 A2 build (GRID_X=2, GRID_Y=2) — **completed** (WNS=+0.711 ns). Uploaded tar, created **afi-01ef63d452c8940a2** (agfi-0193eda3eade22ae4).

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

- **Design configuration**: Design files currently set to 2×2 (`GRID_X=2, GRID_Y=2`). Revert to 1×1 for 1×1 builds.
- **1×1 build**: ✅ **COMPLETE** — log `/home/ubuntu/buildall_1x1_a2_cdc_20260318_163435.log`
- **1×1 AFI**: ✅ **available** — afi-08366141b8a92b36f (agfi-0f933cb959906a494)
- **2×2 build**: ✅ **COMPLETE** — log `/home/ubuntu/buildall_2x2_a2_20260318_171846.log`, tag `2026_03_18-171846`, WNS=+0.711 ns
- **2×2 AFI**: ✅ **submitted** — afi-01ef63d452c8940a2 (agfi-0193eda3eade22ae4); poll for `available` then load with `sudo fpga-load-local-image -S 0 -l agfi-0193eda3eade22ae4`
- **Clock**: A2 recipe (`clk_main_a0` = 15.625 MHz, 64 ns) — switched from A1 due to unresolved 150 MHz timing

### Build Artifacts

| Build | Tag | Timing | Developer_CL.tar | S3 | AFI | Notes |
|---|---|---|---|---|---|---|
| 1×1 A2 | `2026_03_18-004125` | WNS=+0.711 ns ✅ | ✅ | ✅ | ❌ REQP-123 fail | Pre-fix, **do not resubmit** |
| 2×2 A2 | `2026_03_18-020509` | WNS=+0.711 ns ✅ | ✅ | ✅ | ⏳ `afi-0a3e524ae986734e5` | Pre-fix, **do not resubmit** |
| 1×1 A1 | `2026_03_18-120815` | WNS=-18.135 ns ❌ | ✅ | ❌ | — | Timing fail, **do not submit** |
| 1×1 A1 pipelined | `2026_03_18-142140` | WNS=-18.820 ns ❌ | ✅ | ❌ | — | 2nd timing fail (pos_mem/bubble), killed |
| 1×1 A2 (REQP+pipe fixed) | `2026_03_18-151300` | WNS=-1.627 ns ❌ | ✅ | ❌ | — | CDC fail: vled crossing user→shell clk, fixed in commit ef79614 |
| 1×1 A2 (CDC fixed) | `2026_03_18-163435` | WNS=+0.711 ns ✅ | ✅ | ✅ | ✅ **available** | afi-08366141b8a92b36f, agfi-0f933cb959906a494 |
| 2×2 A2 (CDC fixed) | `2026_03_18-171846` | WNS=+0.711 ns ✅ | ✅ | ✅ | ✅ **submitted** | afi-01ef63d452c8940a2, agfi-0193eda3eade22ae4 |

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
| `GRID_X` × `GRID_Y` | **2×2** (for 2×2 build; revert to 1×1 for 1×1) | `cl_satswarm.sv`, `satswarm_core_bridge.sv`, `satswarm_top.sv`, `mesh_interconnect.sv`, `solver_core.sv` |
| `DDR_PRESENT` | 0 | `cl_satswarm.sv` |
| `RESTART_CONFLICT_THRESHOLD` | 65535 (Disabled) | `satswarmv2_pkg.sv` |
| Clock Recipe | **A2 (15.625 MHz)** | build command |
| `i_clk_hbm_ref` | `clk_hbm_ref` (fixed) | `cl_satswarm.sv:94` |

---

## 4. Immediate Next Steps (For Next Agent)

### Priority 1: Load 1×1 AFI and Test (Ready Now)

The 1×1 AFI is **available**. Load and verify on an F2 instance:
```bash
source /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/sdk_setup.sh
sudo fpga-clear-local-image -S 0
sudo fpga-load-local-image -S 0 -l agfi-0f933cb959906a494
sudo fpga-describe-local-image -S 0 -H
```

### Priority 2: Poll 2×2 AFI and Load When Available

2×2 tar uploaded and AFI created (afi-01ef63d452c8940a2). Poll until available (10–30 min):
```bash
aws ec2 describe-fpga-images --fpga-image-ids afi-01ef63d452c8940a2 \
  --query 'FpgaImages[*].{Id:FpgaImageId,State:State}' --region us-east-1
```
Then load on F2: `sudo fpga-load-local-image -S 0 -l agfi-0193eda3eade22ae4`

### Priority 3: Revert to 1×1 for Future 1×1 Builds

Design files were changed to GRID_X=2, GRID_Y=2 for the 2×2 build. To build 1×1 again, revert those parameters in: `cl_satswarm.sv`, `satswarm_core_bridge.sv`, `satswarm_top.sv`, `mesh_interconnect.sv`, `solver_core.sv`.

### Deferred: 150 MHz Timing Closure

The `BUMP_UPDATE_PIPE` fix alone is insufficient. Phys_opt with A1 shows WNS = -18.820 ns on a second ~25 ns path in `pos_mem`/bubble-up/down logic. The entire heap FSM has multiple long combinational chains (~25 ns each). This requires dedicated RTL pipelining work — do not attempt until the A2 working AFI is confirmed deployed.

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

**AFI (2026-03-18)**:
- **afi-08366141b8a92b36f** (agfi-0f933cb959906a494) — SatSwarmV2-1x1-15MHz, tag `2026_03_18-163435` — **available**. Load: `sudo fpga-load-local-image -S 0 -l agfi-0f933cb959906a494`
- **afi-01ef63d452c8940a2** (agfi-0193eda3eade22ae4) — SatSwarmV2-2x2-15MHz, tag `2026_03_18-171846` — **submitted**; poll for `available`, then load: `sudo fpga-load-local-image -S 0 -l agfi-0193eda3eade22ae4`

**Note to next agent**: 2×2 build completed and AFI submitted; update HANDOFF when 2×2 AFI state becomes `available` if you poll it.
