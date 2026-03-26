# SatSwarm V2 — Project Handoff

Welcome. This document captures the **current state** of SatSwarmV2 development, passing context from the previous agent to you.

**Quick status (2026-03-19, VALIDATED):** PCIS byte-lane bug fix confirmed working for 1×1. AFI `afi-0d8e504d573195da8` (agfi-0aa0b1b8ec26f6b5d) loaded and tested on F2 — `sat_20v_80c_1.cnf` → SAT ✓ (5,366 cycles), `unsat_50v_215c_1.cnf` → **UNSAT ✓** (56,310 cycles). The 2×2 PCIS-fix BuildAll AFI (tag `2026_03_19-171700`) `afi-037e5d7f209df2123` (`agfi-022074a3e1f323966`) is **available**.

**Update (2026-03-26):** 1×1 MAX_LITS=16384 tar (`2026_03_26-042416.Developer_CL.tar`) has now been submitted for AFI creation: `afi-08804376adf00f2ab` (`agfi-0ecd81ca9a8dd581c`), state `pending`. Creation response: `deploy/logs/grid_sharing_20260326_042415/afi_create_1x1_none_2026_03_26-042416.json`.

**Process update (2026-03-26):** `deploy/run_grid_sharing_builds.sh` now auto-submits AFIs for every successful run by default (`AUTO_CREATE_AFI=1`) and records `afi_status`, `afi_id`, `agfi_id`, and `afi_json` in the run summary CSV.

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
- **[AWS_Intructions.md](AWS_instructions.md)**: Explinations and links to further resources to understand the aws-fpga ecosystem and rules
- **HANDOFF.md (This File)**: Living state of the project.

---

## 2d. This Session (2026-03-19 — PCIS byte-lane fix CONFIRMED, AFI afi-0d8e504d573195da8)

## 2f. This Session (2026-03-26 — 1x1 MAX_LITS=16384 AFI submitted + auto-submit enabled)

**What was done:**

1. Uploaded `src/aws-fpga/hdk/cl/examples/cl_satswarm/build/checkpoints/2026_03_26-042416.Developer_CL.tar` to `s3://satswarm-v2-afi-624824941978/dcp/2026_03_26-042416.Developer_CL.tar`.
2. Submitted AFI creation:
  - AFI: `afi-08804376adf00f2ab`
  - AGFI: `agfi-0ecd81ca9a8dd581c`
  - Name: `SatSwarmV2-1x1-maxlits16384-2026_03_26-042416`
  - Initial state: `pending`
3. Persisted create response JSON:
  - `deploy/logs/grid_sharing_20260326_042415/afi_create_1x1_none_2026_03_26-042416.json`
4. Updated `deploy/run_grid_sharing_builds.sh` so every successful run automatically:
  - uploads latest `Developer_CL.tar` to S3
  - calls `aws ec2 create-fpga-image`
  - records AFI metadata in summary CSV

**Default automation knobs (can override via env):**

- `AUTO_CREATE_AFI=1`
- `AWS_REGION=us-east-1`
- `AFI_S3_BUCKET=satswarm-v2-afi-624824941978`
- `AFI_S3_DCP_PREFIX=dcp`
- `AFI_S3_LOGS_PREFIX=logs`

**What was done:**

- Loaded new AFI `agfi-0aa0b1b8ec26f6b5d` (afi-0d8e504d573195da8, name: SatSwarmV2-1x1) on F2 slot 0: `loaded` / `ok`.
- Ran `sat_20v_80c_1.cnf` → **SAT ✓**, 5,366 cycles.
- Ran `unsat_50v_215c_1.cnf` → **UNSAT ✓**, 56,310 cycles.

**Conclusion: PCIS byte-lane bug is fixed.** Previous buggy AFIs returned SAT on the UNSAT instance; this one returns UNSAT correctly. This AFI is now the **preferred 1×1** for all testing.

**What still needs to be done:**

- 2×2 build with the PCIS fix (see Priority 1 below).
- Larger-scale correctness sweep (SATLIB uf50/uuf50) to validate beyond the two smoke-test instances.

---

## 2c. This Session (2026-03-19 — AFI afi-09a915f455297380f validation, fix NOT confirmed)

**What was done:**

- Loaded new AFI `agfi-0a1f52695eab415b2` on F2, status: loaded OK.
- Rebuilt `satswarm_host` with correct `AWS_FPGA_REPO_DIR` env var.
- Ran `sat_20v_80c_1.cnf` → SAT, 3,302 cycles (old buggy AFI: 3,267 cycles).
- Ran `unsat_50v_215c_1.cnf` → **SAT ✗**, 12,889 cycles (old buggy AFI: 12,877 cycles).

**Conclusion: AFI afi-09a915f455297380f still has the PCIS byte-lane bug.**
Cycle counts within 0.1% of old AFI — hardware is receiving the same corrupted formula. The RTL fix (commit `1c7c51b`, 07:21:50 UTC) is in `hdk_cl_satswarm/design/cl_satswarm.sv:604` but the build-used path `src/aws-fpga/hdk/cl/examples/cl_satswarm/` does not exist in this F2 repo clone. The build machine either: (a) used a pre-fix DCP/tar, or (b) built from a copy that did not have the fix. Note: AFI creation timestamp is 08:12:49 UTC — only 51 min after the fix commit, which is borderline for a full Vivado build.

**What still needs to be done:**

1. On a build machine: verify `src/aws-fpga/hdk/cl/examples/cl_satswarm/design/cl_satswarm.sv` line 601 reads `slv_pcis_wdata[{pcis_aw_addr_q[5:2], 5'h0} +: 32]` (not `[31:0]`).
2. Run a fresh full BuildAll from that verified source.
3. Submit new tar to S3/AFI.
4. Load on F2 and validate with `unsat_50v_215c_1.cnf` — must return UNSAT.

---

## 2. Last Agent Session (2026-03-19 — CL-owned MMCM solver clock + REQP-123 fix)

## 2e. This Session (2026-03-24 — 2x2 sharing builds completed, AFIs submitted)

**What was done:**

1. Monitored the full 2x2 sharing-mode run `sharing_2x2_20260324_161553` to completion (`none`, `2clz`, `3clz`, `4clz` all `ok` in `deploy/logs/sharing_2x2_20260324_161553/summary.csv`).
2. Uploaded completed `Developer_CL.tar` artifacts and created AFIs for each mode:
  - `none`: `afi-0070486be9cca64bb` (`agfi-06be2426aa615503a`)
  - `2clz`: `afi-0cce87e15db5a8c58` (`agfi-028e6419bce2d9003`)
  - `3clz`: `afi-0c9157a0d6d10ac9b` (`agfi-03c4ec38595841774`)
  - `4clz`: `afi-0db4c324dc633940e` (`agfi-0197eb8028efe5692`)
3. Verified AFI states via AWS:
  - `none`, `2clz`, `3clz` are `available`
  - `4clz` is `pending` (submitted 2026-03-24 21:51 UTC)
4. Updated documentation to track this run and AFI lifecycle:
  - `docs/Synth.md` (new 2026-03-24 sharing AFI table + 4clz entry)
  - `docs/FPGA.md` (deploy-facing AFI list with current states)
  - `docs/Deploy.md` (index pointers to latest AFI status sections)
  - `docs/HANDOFF.md` (AFI status corrections + new 4clz entry)

**Artifacts and logs:**

- Run log: `deploy/logs/run_2x2_sharing_builds_20260324_161553.out`
- Summary CSV: `deploy/logs/sharing_2x2_20260324_161553/summary.csv`
- AFI create responses:
  - `deploy/logs/sharing_2x2_20260324_161553/afi_create_none_2026_03_24-161553.json`
  - `deploy/logs/sharing_2x2_20260324_161553/afi_create_2clz_2026_03_24-173923.json`
  - `deploy/logs/sharing_2x2_20260324_161553/afi_create_3clz_2026_03_24-190133.json`
  - `deploy/logs/sharing_2x2_20260324_161553/afi_create_4clz_2026_03_24-215103.json`

**Remaining follow-up:**

- Poll `afi-0db4c324dc633940e` until `available`, then update docs to flip 4clz from pending to available.

---

**What was done:**

1. **REQP-123 root cause**: Previous AFI (`afi-064b74577e3b2f258`, tag `2026_03_19-031457`) failed with DRC REQP-123. Root cause: `CLK_GRP_A_EN(1)` in aws_clk_gen kept Group A MMCM instantiated, but `.i_clk_hbm_ref(1'b0)` fed it a dead clock. This was a regression of commit `fd6a0a3`.
2. **CL-owned MMCM**: Replaced fabric `solver_clk_div` with standalone MMCME4_ADV primitive (`u_mmcm_solver`): clk_main_a0 (250 MHz) → VCO 1250 MHz → CLKOUT0/80 = 15.625 MHz → BUFG → `clk_solver`. Solver reset gated on `mmcm_solver_locked`.
3. **aws_clk_gen disabled**: Set `CLK_GRP_A_EN(0)` — no MMCMs instantiated inside aws_clk_gen, eliminating the REQP-123 trigger.
4. **XDC updated**: Removed `create_clock` workaround. Vivado auto-propagates generated clock through the MMCM. `set_false_path` references `u_mmcm_solver/CLKOUT0` pin.
5. **Verification**: run_bigger_ladder **98/98 PASSED**; run_xsim_bridge_test **6/6 PASSED**.
6. **BuildAll**: Tag `2026_03_19-051231`, 1×1 grid, 37 min. **WNS=+0.711 ns**, 0 DRC errors.
7. **AFI**: Tar uploaded to S3, AFI created: **afi-0520f5f8b8900def7** (agfi-0b41689a08b4d4d5f), now **available**.

**Not done yet (for next agent):**

- Poll `aws ec2 describe-fpga-images --fpga-image-ids afi-0520f5f8b8900def7` until `State.Code == available`; then load on F2 and validate per [FPGA.md](FPGA.md).
- Run **2×2** build after 1×1 AFI is validated (change GRID_X/GRID_Y in the eight files; do not run in parallel with another build).

---

## 2b. This Session (2026-03-19 — PCIS byte-lane bug + host BAR4 fix)

**What was discovered:**

- Loaded AFI `agfi-0b41689a08b4d4d5f` on F2; host version register read correctly (`0x53415431`).
- Host binary failed to load literals: `fpga_pci_poke` for literals was targeting BAR0 (OCL) instead of BAR4 (PCIS). Fixed by attaching BAR4 separately; literals now reach the FPGA.
- After BAR4 fix, SAT instances returned correct results with non-zero cycle counts. UNSAT instances returned SAT — revealing a deeper RTL bug.

**Root cause (PCIS byte-lane mismatch):**

- `cl_satswarm.sv:601` always reads `slv_pcis_wdata[31:0]` from the 512-bit PCIS data bus.
- AXI4 byte-lane steering places a 32-bit write to address `0x1004` (clause-end) in `wdata[63:32]`, not `[31:0]`.
- Result: every last literal of every clause is silently replaced with `0`. Corrupted formula; UNSAT becomes SAT.
- XSim BFM packed data into `[31:0]` regardless of address, masking the bug in simulation.

**Evidence:**

| CNF                    | Expected | Hardware | XSim cycles | HW cycles |
| ---------------------- | -------- | -------- | ----------- | --------- |
| `sat_20v_80c_1.cnf`    | SAT      | SAT ✓    | 5,219       | 3,267     |
| `unsat_50v_215c_1.cnf` | UNSAT    | SAT ✗    | —           | 12,877    |

Hardware solved faster than XSim on the same SAT instance (corrupted formula is easier). UNSAT flipped to SAT (missing constraints make it satisfiable).

**Fixes committed (no rebuild yet):**

1. `hdk_cl_satswarm/design/cl_satswarm.sv:601` — byte-lane-aware extraction: `slv_pcis_wdata[{pcis_aw_addr_q[5:2], 5'h0} +: 32]`
2. `hdk_cl_satswarm/verif/tests/test_satswarm_aws.sv` — BFM data placement corrected to match hardware (`{448'h0, lit, 32'h0}` for `0x1004` writes)
3. `hdk_cl_satswarm/host/satswarm_host.c` — BAR4 attached separately for MMIO literal loading

**Full writeup**: `docs/bugs/pcis_byte_lane_bug.md`

**Status (updated):** RTL fix is in tree and the **2x2** AFI from build tag `2026_03_19-171700` is **available**: **afi-037e5d7f209df2123** (`agfi-022074a3e1f323966`).

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
- **Current preferred 1×1 AFI (PCIS-fixed, VALIDATED)**: `afi-0d8e504d573195da8` (agfi-0aa0b1b8ec26f6b5d) — **available**, validated on F2 2026-03-19. SAT ✓, UNSAT ✓. Load: `sudo fpga-load-local-image -S 0 -I agfi-0aa0b1b8ec26f6b5d`
- **Previous 1×1 MMCM build**: afi-0520f5f8b8900def7 (agfi-0b41689a08b4d4d5f) — PCIS bug NOT fixed (built before fix reached build machine). Do not use for correctness testing.
- **Previous 1×1 AFI** (fabric divider): afi-064b74577e3b2f258 — **FAILED** REQP-123 during AWS bitgen. Do not use.
- **Older 1×1 AFI** (pre–clock-divide): afi-08366141b8a92b36f (agfi-0f933cb959906a494) — **available** but uses `gen_clk_extra_a1`; PCIS bug present; on real F2 the aws_clk_gen MMCM may never lock.
- **Existing 2×2 AFI** (pre–clock-divide): afi-01ef63d452c8940a2 (agfi-0193eda3eade22ae4) — **available**; PCIS bug present; same MMCM caveat.
- **Clock**: A2 recipe; solver runs on **clk_solver** (15.625 MHz, 64 ns) from CL-owned MMCME4_ADV (clk_main_a0 × 5 / 80); shell-facing logic on **clk_main_a0** (250 MHz).

### Build Artifacts

| Build                                                   | Tag                     | Timing               | Developer_CL.tar | S3     | AFI                        | Notes                                                                                                |
| ------------------------------------------------------- | ----------------------- | -------------------- | ---------------- | ------ | -------------------------- | ---------------------------------------------------------------------------------------------------- |
| 1×1 A2                                                  | `2026_03_18-004125`     | WNS=+0.711 ns ✅     | ✅               | ✅     | ❌ REQP-123 fail           | Pre-fix, **do not resubmit**                                                                         |
| 2×2 A2                                                  | `2026_03_18-020509`     | WNS=+0.711 ns ✅     | ✅               | ✅     | ⏳ `afi-0a3e524ae986734e5` | Pre-fix, **do not resubmit**                                                                         |
| 1×1 A1                                                  | `2026_03_18-120815`     | WNS=-18.135 ns ❌    | ✅               | ❌     | —                          | Timing fail, **do not submit**                                                                       |
| 1×1 A1 pipelined                                        | `2026_03_18-142140`     | WNS=-18.820 ns ❌    | ✅               | ❌     | —                          | 2nd timing fail (pos_mem/bubble), killed                                                             |
| 1×1 A2 (REQP+pipe fixed)                                | `2026_03_18-151300`     | WNS=-1.627 ns ❌     | ✅               | ❌     | —                          | CDC fail: vled crossing user→shell clk, fixed in commit ef79614                                      |
| 1×1 A2 (CDC fixed)                                      | `2026_03_18-163435`     | WNS=+0.711 ns ✅     | ✅               | ✅     | ✅ **available**           | afi-08366141b8a92b36f, agfi-0f933cb959906a494                                                        |
| 2×2 A2 (CDC fixed)                                      | `2026_03_18-171846`     | WNS=+0.711 ns ✅     | ✅               | ✅     | ✅ **available**           | afi-01ef63d452c8940a2, agfi-0193eda3eade22ae4                                                        |
| 1×1 A2 (full BuildAll, clk_main_a0 direct)              | `2026_03_19-020552`     | WNS=-6.66 ns ❌      | ✅               | ❌     | —                          | **FAILED** timing; solver at 250 MHz. Do not use. Log: `build/scripts/2026_03_19-020552.vivado.log`. |
| 1×1 A2 (clock-divide, clk_solver XDC fix)               | `2026_03_19-031457`     | WNS=+0.711 ns ✅     | ✅               | ✅     | ❌ REQP-123 fail           | afi-064b74577e3b2f258 — FAILED. `.i_clk_hbm_ref(1'b0)` with `CLK_GRP_A_EN(1)`.                       |
| **1×1 A2 (CL-owned MMCM, CLK_GRP_A_EN=0)**              | **`2026_03_19-051231`** | **WNS=+0.711 ns ✅** | **✅**           | **✅** | **✅ available**           | **afi-0520f5f8b8900def7** (agfi-0b41689a08b4d4d5f). Preferred 1×1.                                   |
| **2×2 A2 (BuildAll, Default directives, PCIS-fix RTL)** | **`2026_03_19-171700`** | **WNS=+0.711 ns ✅** | **✅**           | **✅** | **✅ available**           | **afi-037e5d7f209df2123** (agfi-022074a3e1f323966); `create-fpga-image` submitted 2026-03-19.        |

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

| Parameter                    | Value                                                                        | Files                                                                                                |
| ---------------------------- | ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `GRID_X` × `GRID_Y`          | **1×1** (current). Set to 2×2 only for a 2×2 build, in the five files below. | `cl_satswarm.sv`, `satswarm_core_bridge.sv`, `satswarm_top.sv`, `mesh_interconnect.sv`, `solver_core.sv` (build-used paths: `src/aws-fpga/.../design/` and `src/Mega/`) |
| `DDR_PRESENT`                | 0                                                                            | `cl_satswarm.sv`                                                                                     |
| `RESTART_CONFLICT_THRESHOLD` | 64                                                                           | `solver_core.sv`                                                                                     |
| Clock Recipe                 | **A2 (15.625 MHz)**                                                          | build command                                                                                        |
| `i_clk_hbm_ref`              | `1'b0` (safe: all groups disabled)                                           | `cl_satswarm.sv`                                                                                     |
| `CLK_GRP_A_EN`               | `0` (MMCM disabled)                                                          | `cl_satswarm.sv`                                                                                     |
| Solver clock                 | CL-owned MMCME4_ADV (`u_mmcm_solver`)                                        | `cl_satswarm.sv`                                                                                     |

---

## 5. Immediate Next Steps (For Next Agent)

### ~~Priority 0: Rebuild AFI with PCIS Byte-Lane Fix~~ — DONE ✓

**RESOLVED 2026-03-19.** AFI `afi-0d8e504d573195da8` (agfi-0aa0b1b8ec26f6b5d) validated on F2:

- `sat_20v_80c_1.cnf` → SAT ✓ (5,366 cycles)
- `unsat_50v_215c_1.cnf` → UNSAT ✓ (56,310 cycles)

### Priority 0: Run 2×2 Build with PCIS Fix

Build + submission are now done for 2×2 PCIS-fix RTL:

1. Build tag: `2026_03_19-171700` (BuildAll, Default directives, WNS=+0.711 ns)
2. AFI: `afi-037e5d7f209df2123`
3. AGFI: `agfi-022074a3e1f323966`

Next step: poll until `available`, then validate with `unsat_50v_215c_1.cnf` on F2 (must return UNSAT).

### Priority 1: Broader Correctness Sweep

Now that 1×1 is validated, run the SATLIB uf50/uuf50 suite to confirm correctness across more instances before scaling experiments.

```bash
bash hdk_cl_satswarm/scripts/run_fpga_suite.sh \
  --suite-dir sim/tests/satlib/sat \
  --out logs/hw_satlib_uf50.csv --slot 0 --timeout 30
```

### Priority 2: (Optional) Run 2×2 Build After 1×1 Completes

Do **not** start 2×2 while 1×1 is still building (shared `CL_DIR/build/`). After 1×1 is done: set `GRID_X=2`, `GRID_Y=2` in `cl_satswarm.sv`, `satswarm_core_bridge.sv`, `satswarm_top.sv`, `mesh_interconnect.sv`, `solver_core.sv` (build-used paths under `src/aws-fpga/...` and `src/Mega/`). Then run the same build command with HDK env (and `--cl cl_satswarm`). When that tar is ready, upload and create a second AFI for 2×2 clk_main_a0.

### Priority 3: Load and Test AFI on F2

Once the new 1×1 AFI (from clock-divide build) is available, load it on an F2 instance to confirm correct operation:

```bash
source /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/sdk_setup.sh
sudo fpga-clear-local-image -S 0
sudo fpga-load-local-image -S 0 -I <new-agfi-id>
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

- **afi-0db4c324dc633940e** (agfi-0197eb8028efe5692) — 2×2, sharing `4clz`, tag `2026_03_24-202347` — **pending** (submitted 2026-03-24 21:51 UTC). Creation JSON: `deploy/logs/sharing_2x2_20260324_161553/afi_create_4clz_2026_03_24-215103.json`.
- **afi-0d8e504d573195da8** (agfi-0aa0b1b8ec26f6b5d) — 1×1, name `SatSwarmV2-1x1` — **available, VALIDATED 2026-03-19**. PCIS byte-lane fix confirmed. **Preferred 1×1.** Load: `sudo fpga-load-local-image -S 0 -I agfi-0aa0b1b8ec26f6b5d`
- **afi-037e5d7f209df2123** (`agfi-022074a3e1f323966`) — 2×2, tag `2026_03_19-171700` — **available**. Built with BuildAll `Default` directives and PCIS byte-lane fix. Load with: `sudo fpga-load-local-image -S 0 -I agfi-022074a3e1f323966`
- afi-0520f5f8b8900def7 (agfi-0b41689a08b4d4d5f) — 1×1, tag `2026_03_19-051231` — **available** but PCIS bug not confirmed fixed (build timing uncertain). Do not use for correctness testing.
- afi-064b74577e3b2f258 — 1×1, tag `2026_03_19-031457` — **FAILED** REQP-123. Do not use.
- **afi-08366141b8a92b36f** (agfi-0f933cb959906a494) — 1×1, tag `2026_03_18-163435` — **available**. PCIS bug present. Uses gen_clk_extra_a1; may stay in reset on real F2.
- **afi-01ef63d452c8940a2** (agfi-0193eda3eade22ae4) — 2×2, tag `2026_03_18-171846` — **available**. PCIS bug present. Same MMCM caveat.