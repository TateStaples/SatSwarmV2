# SatSwarm V2 — Project Handoff

Welcome. This document captures the **current state** of SatSwarmV2 development, passing context from the previous agent to you.

**Quick status (2026-03-19):** CL-owned MMCM solver clock build complete (tag `2026_03_19-051231`). Replaced fabric `solver_clk_div` with MMCME4_ADV; set `CLK_GRP_A_EN(0)` in aws_clk_gen to fix REQP-123. BuildAll passed (WNS=+0.711 ns, 0 DRC errors). AFI created: **afi-0520f5f8b8900def7** (agfi-0b41689a08b4d4d5f). Poll until `available`, then load on F2 per FPGA.md. See §2 and §5.

---

## 1. Documentation Navigation

The repository's documentation has been modularized:
- **[README.md](README.md)**: Start here. Architecture, core RTL overviews, and repository structure.
- **[Synth.md](Synth.md)**: Synthesis methodology. How to use AWS HDK, build DCPs, and create Amazon FPGA Images (AFI).
- **[Design.md](Design.md)**: High-level architecture, invariants, and design intent.
- **[Verification.md](Verification.md)**: Testing and debugging. Verilator commands, regression suites, and inference checks.
- **[Changes.md](Changes.md)**: Historical log. Read this before undoing past work (e.g. why `pse.sv` BRAM inference failed 21 times). Also update this file after validated changes or end of session.
- **[FPGA.md](FPGA.md)**: Loading an existing AFI on F2 and collecting hardware-side data.
- **[Model.md](Model.md)**: Practical modeling flow for turning measured CSVs into scaling projections.
- **HANDOFF.md (This File)**: Living state of the project.

---

## 2. Last Agent Session (2026-03-19 — CL-owned MMCM solver clock + REQP-123 fix)

**What was done:**
1. **REQP-123 root cause**: Previous AFI (`afi-064b74577e3b2f258`, tag `2026_03_19-031457`) failed with DRC REQP-123. Root cause: `CLK_GRP_A_EN(1)` in aws_clk_gen kept Group A MMCM instantiated, but `.i_clk_hbm_ref(1'b0)` fed it a dead clock. This was a regression of commit `fd6a0a3`.
2. **CL-owned MMCM**: Replaced fabric `solver_clk_div` with standalone MMCME4_ADV primitive (`u_mmcm_solver`): clk_main_a0 (250 MHz) → VCO 1250 MHz → CLKOUT0/80 = 15.625 MHz → BUFG → `clk_solver`. Solver reset gated on `mmcm_solver_locked`.
3. **aws_clk_gen disabled**: Set `CLK_GRP_A_EN(0)` — no MMCMs instantiated inside aws_clk_gen, eliminating the REQP-123 trigger.
4. **XDC updated**: Removed `create_clock` workaround. Vivado auto-propagates generated clock through the MMCM. `set_false_path` references `u_mmcm_solver/CLKOUT0` pin.
5. **Verification**: run_bigger_ladder **98/98 PASSED**; run_xsim_bridge_test **6/6 PASSED**.
6. **BuildAll**: Tag `2026_03_19-051231`, 1×1 grid, 37 min. **WNS=+0.711 ns**, 0 DRC errors.
7. **AFI**: Tar uploaded to S3, AFI created: **afi-0520f5f8b8900def7** (agfi-0b41689a08b4d4d5f). Pending availability.

**Not done yet (for next agent):**
- Poll `aws ec2 describe-fpga-images --fpga-image-ids afi-0520f5f8b8900def7` until `State.Code == available`; then load on F2 and validate per [FPGA.md](FPGA.md).
- Run **2×2** build after 1×1 AFI is validated (change GRID_X/GRID_Y in the eight files; do not run in parallel with another build).

---

## 3. Previous Session (2026-03-18 — strategy change to A2/15.625 MHz)

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

## 4. Current Project State

- **Design configuration**: **1×1** (`GRID_X=1, GRID_Y=1`) in all design files. Change to 2×2 in the eight files only when starting a 2×2 build.
- **1×1 MMCM build (2026-03-19)**: Full BuildAll tag `2026_03_19-051231` — WNS=+0.711 ns. AFI **afi-0520f5f8b8900def7** (agfi-0b41689a08b4d4d5f) created; **pending** availability. This is the preferred 1×1 AFI (CL-owned MMCM for clk_solver, CLK_GRP_A_EN=0).
- **Previous 1×1 AFI** (fabric divider): afi-064b74577e3b2f258 — **FAILED** REQP-123 during AWS bitgen. Do not use.
- **Older 1×1 AFI** (pre–clock-divide): afi-08366141b8a92b36f (agfi-0f933cb959906a494) — **available** but uses `gen_clk_extra_a1`; on real F2 the aws_clk_gen MMCM may never lock.
- **Existing 2×2 AFI** (pre–clock-divide): afi-01ef63d452c8940a2 (agfi-0193eda3eade22ae4) — **available**; same MMCM caveat.
- **Clock**: A2 recipe; solver runs on **clk_solver** (15.625 MHz, 64 ns) from CL-owned MMCME4_ADV (clk_main_a0 × 5 / 80); shell-facing logic on **clk_main_a0** (250 MHz).

### Build Artifacts

| Build | Tag | Timing | Developer_CL.tar | S3 | AFI | Notes |
|---|---|---|---|---|---|---|
| 1×1 A2 | `2026_03_18-004125` | WNS=+0.711 ns ✅ | ✅ | ✅ | ❌ REQP-123 fail | Pre-fix, **do not resubmit** |
| 2×2 A2 | `2026_03_18-020509` | WNS=+0.711 ns ✅ | ✅ | ✅ | ⏳ `afi-0a3e524ae986734e5` | Pre-fix, **do not resubmit** |
| 1×1 A1 | `2026_03_18-120815` | WNS=-18.135 ns ❌ | ✅ | ❌ | — | Timing fail, **do not submit** |
| 1×1 A1 pipelined | `2026_03_18-142140` | WNS=-18.820 ns ❌ | ✅ | ❌ | — | 2nd timing fail (pos_mem/bubble), killed |
| 1×1 A2 (REQP+pipe fixed) | `2026_03_18-151300` | WNS=-1.627 ns ❌ | ✅ | ❌ | — | CDC fail: vled crossing user→shell clk, fixed in commit ef79614 |
| 1×1 A2 (CDC fixed) | `2026_03_18-163435` | WNS=+0.711 ns ✅ | ✅ | ✅ | ✅ **available** | afi-08366141b8a92b36f, agfi-0f933cb959906a494 |
| 2×2 A2 (CDC fixed) | `2026_03_18-171846` | WNS=+0.711 ns ✅ | ✅ | ✅ | ✅ **available** | afi-01ef63d452c8940a2, agfi-0193eda3eade22ae4 |
| 1×1 A2 (full BuildAll, clk_main_a0 direct) | `2026_03_19-020552` | WNS=-6.66 ns ❌ | ✅ | ❌ | — | **FAILED** timing; solver at 250 MHz. Do not use. Log: `build/scripts/2026_03_19-020552.vivado.log`. |
| 1×1 A2 (clock-divide, clk_solver XDC fix) | `2026_03_19-031457` | WNS=+0.711 ns ✅ | ✅ | ✅ | ❌ REQP-123 fail | afi-064b74577e3b2f258 — FAILED. `.i_clk_hbm_ref(1'b0)` with `CLK_GRP_A_EN(1)`. |
| **1×1 A2 (CL-owned MMCM, CLK_GRP_A_EN=0)** | **`2026_03_19-051231`** | **WNS=+0.711 ns ✅** | **✅** | **✅** | **⏳ pending** | **afi-0520f5f8b8900def7** (agfi-0b41689a08b4d4d5f). Preferred 1×1. |

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
| `GRID_X` × `GRID_Y` | **1×1** (current). Set to 2×2 only for a 2×2 build, in the five files below. | `cl_satswarm.sv`, `satswarm_core_bridge.sv`, `satswarm_top.sv`, `mesh_interconnect.sv`, `solver_core.sv` (build-used paths: `src/aws-fpga/.../design/` and `src/Mega/`) |
| `DDR_PRESENT` | 0 | `cl_satswarm.sv` |
| `RESTART_CONFLICT_THRESHOLD` | 65535 (Disabled) | `satswarmv2_pkg.sv` |
| Clock Recipe | **A2 (15.625 MHz)** | build command |
| `i_clk_hbm_ref` | `1'b0` (safe: all groups disabled) | `cl_satswarm.sv` |
| `CLK_GRP_A_EN` | `0` (MMCM disabled) | `cl_satswarm.sv` |
| Solver clock | CL-owned MMCME4_ADV (`u_mmcm_solver`) | `cl_satswarm.sv` |

---

## 5. Immediate Next Steps (For Next Agent)

### Priority 1: Poll AFI and Validate on F2 (CL-owned MMCM build)

1. **Poll until AFI is available**:
   ```bash
   aws ec2 describe-fpga-images --fpga-image-ids afi-0520f5f8b8900def7 \
     --query 'FpgaImages[*].{Id:FpgaImageId,State:State.Code}' --region us-east-1
   ```
   When `State` is `available`, the 1×1 CL-owned MMCM AFI is ready.
2. **Load and test on F2** (see [FPGA.md](FPGA.md)):
   ```bash
   sudo fpga-load-local-image -S 0 -l agfi-0b41689a08b4d4d5f
   sudo fpga-describe-local-image -S 0 -H
   ```
   Run the host app and confirm the CL comes out of reset and returns correct results. Update this HANDOFF and FPGA.md with "validated on F2" once confirmed.

### Priority 2: (Optional) Run 2×2 Build After 1×1 Completes

Do **not** start 2×2 while 1×1 is still building (shared `CL_DIR/build/`). After 1×1 is done: set `GRID_X=2`, `GRID_Y=2` in `cl_satswarm.sv`, `satswarm_core_bridge.sv`, `satswarm_top.sv`, `mesh_interconnect.sv`, `solver_core.sv` (build-used paths under `src/aws-fpga/...` and `src/Mega/`). Then run the same build command with HDK env (and `--cl cl_satswarm`). When that tar is ready, upload and create a second AFI for 2×2 clk_main_a0.

### Priority 3: Load and Test AFI on F2

Once the new 1×1 AFI (from clock-divide build) is available, load it on an F2 instance to confirm correct operation:
```bash
source /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/sdk_setup.sh
sudo fpga-clear-local-image -S 0
sudo fpga-load-local-image -S 0 -l <new-agfi-id>
sudo fpga-describe-local-image -S 0 -H
```
Existing AFIs (agfi-0f933cb959906a494, agfi-0193eda3eade22ae4) may leave the CL in reset on real F2 due to the MMCM lock issue.

### Build Command Reference (run from env where CL_DIR and HDK vars are set)

```bash
cd $CL_DIR/build/scripts
python3 aws_build_dcp_from_cl.py --cl cl_satswarm --aws_clk_gen --clock_recipe_a A2
```
Use `source hdk_setup.sh` then `export CL_DIR=$AWS_FPGA_REPO_DIR/hdk/cl/examples/cl_satswarm` (or the manual export block in §6) in the same shell before this.

### Deferred: 150 MHz Timing Closure

The `BUMP_UPDATE_PIPE` fix alone is insufficient. Phys_opt with A1 shows WNS = -18.820 ns on a second ~25 ns path in `pos_mem`/bubble-up/down logic. The entire heap FSM has multiple long combinational chains (~25 ns each). This requires dedicated RTL pipelining work — do not attempt until the A2 working AFI is confirmed deployed.

---

## 6. Operational Notes

### HDK Environment Setup

From a shell, `cd` to `src/aws-fpga` and run `source hdk_setup.sh`; then `export CL_DIR=$AWS_FPGA_REPO_DIR/hdk/cl/examples/cl_satswarm`. If that fails (e.g. git not available or wrong root), use the manual block below in the same `bash -c '...'` as the build so the child inherits env vars.

**Manual fallback — set all vars explicitly:**
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

Design files: ensure both copies are synced before building:
- `src/aws-fpga/hdk/cl/examples/cl_satswarm/design/` ← **USED by build**
- `src/Mega/` ← **USED by build**
- `hdk_cl_satswarm/design/` ← Sync with above; both have CL-owned MMCM (`u_mmcm_solver`) in current RTL

---

**AFIs**:
- **afi-0520f5f8b8900def7** (agfi-0b41689a08b4d4d5f) — 1×1, tag `2026_03_19-051231` — **pending** (CL-owned MMCM, CLK_GRP_A_EN=0). **Preferred 1×1** once available. Load: `sudo fpga-load-local-image -S 0 -l agfi-0b41689a08b4d4d5f`
- afi-064b74577e3b2f258 — 1×1, tag `2026_03_19-031457` — **FAILED** REQP-123. Do not use.
- **afi-08366141b8a92b36f** (agfi-0f933cb959906a494) — 1×1, tag `2026_03_18-163435` — **available**. Uses gen_clk_extra_a1; may stay in reset on real F2 (MMCM lock). Load: `sudo fpga-load-local-image -S 0 -l agfi-0f933cb959906a494`
- **afi-01ef63d452c8940a2** (agfi-0193eda3eade22ae4) — 2×2, tag `2026_03_18-171846` — **available**. Same MMCM caveat. Load: `sudo fpga-load-local-image -S 0 -l agfi-0193eda3eade22ae4`
