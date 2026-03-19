# Historical Record: Changes, Bugs, and Synthesis Attempts

This document serves as an archive of major architectural pivots, difficult bugs, and the long sequence of AWS synthesis attempts that shaped SatSwarmV2.

---

## Session Log: 2026-03-19 — MMCM Lock Failure on Real F2 Hardware (clk_main_a0 Direct)

### What Went Wrong

On real F2 instances, the Custom Logic (CL) never came out of reset: `gen_rst_a1_n` stayed deasserted, so the entire CL remained held in reset. In XSim and Verilator, the design worked because the testbench BFMs drive clocks directly and never exercise the MMCM lock path.

**Root cause**: The MMCM inside `aws_clk_gen` (`clk_mmcm_a.xci`) is configured with **PLL_CLKIN_PERIOD = 10.000 ns** (100 MHz input). Across all A-recipes, the shell drives **clk_main_a0 at 250 MHz** (4 ns period) — this was confirmed by examining `aws_gen_clk_constraints.tcl`, which hardcodes `clk_main_a0_period = 4` for A0, A1, and A2 (the 64 ns variant is marked `#NOT SUPPORTED`). The MMCM therefore receives a 250 MHz input into a cell configured for 100 MHz, pushing the VCO to ~3750 MHz (far above the valid range). It **never locks**. The HDK ties `gen_rst_a1_n` to the MMCM lock status, so the CL reset never releases on real hardware. (The previous passing builds appeared correct because `gen_clk_extra_a1` — the MMCM output — had **no timing constraint** in Vivado; the solver logic was technically unconstrained and "met timing" trivially.)

### Changes Made

- **All CL logic** (OCL AXI-Lite, PCIS DMA, DDR FSM, and `satswarm_core_bridge` / solver) now runs on **clk_main_a0** directly instead of **gen_clk_extra_a1** (the MMCM output).
- The three AXI clock-converter IPs (OCL_CDC, PCIS_CDC, DDR_CDC) are kept for HDK compatibility but now see **the same clock on both sides** (clk_main_a0); they operate in pass-through mode.
- `aws_clk_gen` remains instantiated (required by HDK/sh_ddr elaboration); its extra-clock outputs are no longer used to drive any logic.
- **clk_main_a0 = 250 MHz** — Despite being recipe A2, `clk_main_a0` is always 250 MHz (4 ns); `aws_gen_clk_constraints.tcl` hardcodes `clk_main_a0_period = 4` for all A-recipes. Only the clock source wire changed from unconstrained `gen_clk_extra_a1` to constrained `clk_main_a0`, which exposed a pre-existing timing violation (see below).

Files touched: `hdk_cl_satswarm/design/cl_satswarm.sv` (commit 68ad813). The build-used copy is `src/aws-fpga/hdk/cl/examples/cl_satswarm/design/cl_satswarm.sv` (must be synced before Vivado build).

### Why This Fix Works

1. **clk_main_a0 is always valid** — It is driven by the shell’s clock infrastructure and does not depend on the user MMCM locking. The CL no longer waits on a lock that never occurs.
2. **clk_main_a0 is properly constrained** — `gen_clk_extra_a1` (MMCM CLKOUT0) had no timing constraint in Vivado (no `create_generated_clock` in MMCM IP XDC; constraint script only writes `clk_main_a0`). Solver FFs were unconstrained; 24 ns paths had infinite slack. Moving to `clk_main_a0` subjects the solver to real 250 MHz analysis and exposed the vde_heap modulo path (fixed in commit 295bb4f — see below).
3. **No new clock domains** — No divider, no CDC boundary. Only the source wire changed; MMCM bypassed for logic while remaining for elaboration.

---

## Session Log: 2026-03-19 (continued) — INIT_WRITE Timing Violation in vde_heap.sv (250 MHz)

### What Went Wrong

After the clk_main_a0 fix (68ad813), build `2026_03_19-003427` **failed timing** with WNS = **-20.723 ns** (required 4 ns, got 24.685 ns). Critical path:

- **Source**: `u_vde/u_heap/max_var_init_q_reg[0]` (FDCE, clk_main_a0)
- **Destination**: `u_vde/u_heap/pos_mem_reg_bram_0/ADDRARDADDR[7]` (RAMB18E2, clk_main_a0)
- **Data path**: 24.685 ns, **180 logic levels** (CARRY8=149 + LUTs=31)

Root cause: the `INIT_WRITE` state in `vde_heap.sv` uses a **runtime modulo** in combinational logic:

```systemverilog
k = (idx_q + (max_var_init_q >> 2) * phase_offset[3:2]) % max_var_init_q;
```

`max_var_init_q` is a runtime variable, so Vivado synthesizes `%` as a full hardware integer divider → 149 CARRY8 chains → 24.685 ns path. This path existed in all prior builds but had infinite slack because the solver was clocked on unconstrained `gen_clk_extra_a1`.

### Changes Made

**`src/Mega/vde_heap.sv`** (commit 295bb4f): Replace the combinational modulo with a registered counter `k_q`.

- `k_q` initialized at IDLE→INIT_WRITE using `k_init` (phase-offset start = multiples of `max_var/4`; computed as shifts+add, no `%`).
- During INIT_WRITE, `k_q` increments with modular wrap (`k_q <= (k_q+1 >= max_var_init_q) ? '0 : k_q+1`).
- INIT_WRITE comb block uses `k_q` directly — `%` is gone entirely.

Same pipeline-register strategy as commit `bab99f4` (BUMP_UPDATE_PIPE).

### Why This Fix Works

- `max_var_init_q` is constant for the whole INIT_WRITE loop. The wrapping counter produces the same `k` sequence as the modulo formula.
- New critical path for INIT_WRITE: `k_q + 1 ≥ max_var_init_q` (~0.5 ns, one 32-bit compare), well within 4 ns.
- No functional change.

---

## Session Log: 2026-03-18 (continued — bigger_ladder timing fix)

### REQP-123 DRC Fix
Root cause of all prior AFI failures: `cl_satswarm.sv:94` passed `1'b0` to `i_clk_hbm_ref`, which feeds `MMCME4_ADV.CLKIN1`. With `CLKINSEL=1'b1` hardcoded in the MMCM wizard, AWS ingest.tcl's DRC check fires REQP-123 (constant input to active-clock pin) and aborts bitgen. Fix: `.i_clk_hbm_ref(clk_hbm_ref)`.

### Timing Failure at 150 MHz — bigger_ladder

Post-fix build `2026_03_18-120815` (A1 recipe, `clk_out1_clk_mmcm_a` = 150 MHz / 6.667 ns period) failed timing with WNS = -18.135 ns.

**Critical path analysis** (`post_route_timing.rpt`):
- Source: `u_vde/u_heap/max_var_init_q_reg[1]` (FDCE)
- Destination: `u_heap/heap_mem_reg_bram_0/DINBDIN[8]` (RAMB36E2 port B write data)
- Data path delay: 24.575 ns (logic 10.462 ns, route 14.113 ns)
- Logic levels: 176 (CARRY8=145, LUT1=1, LUT2=1, LUT3=24, LUT4=2, LUT5=3)
- Vivado synthesis warning: "no optional output register could be merged into the ram block"

**Root cause**: In `BUMP_UPDATE_WRITE` state (`vde_heap.sv:578-582`), `rdata_h1` (BRAM A read output) flows directly into a 32-bit adder → mux → BRAM B write data port in a single combinational path. The synthesizer merges all state-machine mux cases into one logic cone, creating the 176-level chain.

**Fix**: Insert `BUMP_UPDATE_PIPE` state between `BUMP_UPDATE_READ` and `BUMP_UPDATE_WRITE`. The new state registers `rdata_h1` into `bump_rdata_q`. `BUMP_UPDATE_WRITE` then uses `bump_rdata_q` instead of the raw BRAM output, breaking the long combinational path to ≤1 register stage.

---

## Session Log: 2026-03-18

### 1×1 BuildAll — Completed
- Tag: `2026_03_18-004125`, build time ~31 min.
- Timing: WNS=+0.711 ns, TNS=0, WHS=+0.014 ns. All met.
- Tar uploaded to `s3://satswarm-v2-afi-624824941978/dcp/2026_03_18-004125.Developer_CL.tar`.
- AFI submitted: `afi-0edbf121d0cabe2b3` / `agfi-0610ea9ddef56b71d` — **FAILED** with `UNKNOWN_BITSTREAM_GENERATE_ERROR` (transient AWS backend error). Resubmit the same tar.

### 2×2 Grid Switch
Changed `GRID_X=1, GRID_Y=1` → `GRID_X=2, GRID_Y=2` in four files:
- `src/aws-fpga/hdk/cl/examples/cl_satswarm/design/cl_satswarm.sv` (lines 17–18)
- `src/aws-fpga/hdk/cl/examples/cl_satswarm/design/satswarm_core_bridge.sv` (lines 19–20)
- `src/Mega/satswarm_top.sv` (lines 3–4)
- `src/Mega/mesh_interconnect.sv` (lines 4–5)

Note: `satswarmv2_pkg.sv` was already `GRID_X=2, GRID_Y=2` by default.

### 2×2 BuildAll — Completed
- Tag: `2026_03_18-020509`, build time ~62 min.
- Timing: WNS=+0.711 ns, TNS=0, WHS=+0.011 ns. All met.
- Synthesis confirmed `GRID_X bound to: 2`, `GRID_Y bound to: 2`, `NUM_CORES bound to: 4`.
- Tar on disk, not yet uploaded to S3 or submitted as AFI.

### HDK Environment Workaround Discovered
`hdk_setup.sh` cannot be sourced from this project directory. `set_common_env_vars.sh` calls `git rev-parse --show-toplevel` to set `repo_root`; since this is not a git repo, `repo_root` is empty and `AWS_FPGA_REPO_DIR` gets zeroed out, causing Vivado's `build_all.tcl` to fail with "HDK_SHELL_DIR not set". Fix: export all HDK env vars manually in the same shell/bash-c block as the build command. See `Synth.md` and `HANDOFF.md` for the complete export block.

---

## Synthesis Attempt History

Synthesizing a complex CDCL solver for AWS F2 (Xilinx VU47P) required multiple iterations to fit within timing and memory (OOM) constraints.

### The OOM Problem
Early attempts (1–5) were killed by the OS due to Out-Of-Memory during Vivado's "Timing Optimization" or "Technology Mapping" phases. The 30 GB AWS instance was insufficient because Vivado dissolved massive storage arrays (`lit_mem` in `pse.sv`, `trail` in `trail_manager.sv`) into individual flip-flops. This created ~146K+ FFs, exploding the timing graph size.

### Attempts Summary

| # | Clock Recipe | Solver Clock | Phys. Opt | Outcome | Failed At |
|---|---|---|---|---|---|
| **1-3** | A0 | 250 MHz (no CDC) | AggressiveExplore | OOM Killed | Timing Opt (~4-5h) |
| **4** | A2 | 250 MHz (no CDC) | AggressiveExplore | OOM Killed | Timing Opt (~9.5h) |
| **5** | A2 | 250 MHz (no CDC) | Explore | OOM Killed | Timing Opt |
| **6** | **A2** | **15.625 MHz (CDC)** | **Explore** | **OOM Killed** | **Technology Mapping** (1h35m) |
| **7-10** | A2 | 15.625 MHz | Explore/RuntimeOpt | OOM Killed | Technology Mapping |
| **11-18** | A2 | 15.625 MHz | Explore | Failed | RTL Elaboration / OOM |
| **19-21** | A2 | 15.625 MHz | Explore | Failed | OOM / Inference |
| **22** | A2 | 15.625 MHz | Explore | **PASSED** | Completed successfully (~12m) |

### Key Fixes Leading to Attempt 22 Success

1. **Clock Domain Crossing (CDC)**: Hardwiring the solver to `clk_main_a0` (250 MHz) created impossible timing constraints. Added `aws_clk_gen` and AXI clock converters to decouple the solver into a 15.625 MHz domain (`gen_clk_extra_a1`), allowing Timing Optimization to pass (starting in Attempt 6).
2. **`sh_ddr` Encryption Error**: Vivado failed immediately with an encrypted envelope assertion. Fixed by including the same Xilinx IP (AXI interconnects, clock converters) loaded by AWS reference designs in `synth_cl_satswarm.tcl`.
3. **BRAM/LUTRAM Inference Refactoring**:
    - **Attempt 8**: Flattened `shared_clause_buffer`, separated logic in `vde_heap`, and added `(* ram_style = "distributed" *)` to FIFOs. Cut 400K+ FFs.
    - **Attempts 19-21**: Removed async resets and split `pse.sv`/`trail_manager.sv` memory assignments into pure synchronous `always_ff` blocks.
    - **Attempt 22 Block**: The final blocker was multi-port paralell writes in `pse.sv` (Learned Clause Ingestion) forcing Vivado to dissolve `lit_mem`. *Fix*: Serialized the writes to one literal per cycle. The peak memory plummeted and Technology Mapping succeeded.

---

## Notable Architectural Changes

### `cae.sv` — Pipelined Rewrite
The original Conflict Analysis Engine used bulk combinatorial loops (64-wide parallel scans over the trail buffer). This resulted in **489 logic levels** on the critical path, guaranteeing timing failure. It was rewritten into a pipelined, incremental sequential FSM processing one trail entry per cycle.

### RESYNC_PSE Elimination
An old FSM state designed to wipe the PSE assignment shadow caused complete test failures upon solver restarts (restarts broke the trail assumptions). The logic was deleted, and three entry paths were rewritten to perform iterative backward backtracking instead. (Restarts currently disabled via `RESTART_CONFLICT_THRESHOLD = 16'd65535`).

### Sizing Audit (2026-02-26)
16 hard-coded loop bounds were truncating variables. Fixed parameters in `solver_core.sv` to use `$clog2(MAX_CLAUSE_LEN+1)`.

### HDK CL Module Renaming
Wrapped out the older simplified interfaces into `satswarm_core_bridge.sv`, while preserving `cl_satswarm.sv` as the top-level matching the strict `cl_ports.vh` interface required by AWS HDK linkers.

---

## Archive: Resolved Bugs

| Bug | Severity | Issue | Status |
|-----|----------|-------|--------|
| BUG-011 | Critical | Invalid literal 0 in conflict analysis. | ✅ Fixed |
| BUG-010 | Critical | CAE reason staleness causing false UNSATs. | ✅ Fixed |
| BUG-007 | Critical | Infinite loop & soundness failure. | ✅ Fixed |
| BUG-006 | High | Completeness failure (truncated clauses). | ✅ Fixed |
| BUG-005 | Critical | Single-core soundness (PSE race condition). | ✅ Fixed |
| BUG-003 | Critical | Sign inversion in learned clauses. | ✅ Fixed |
| BUG-002 | High | Livelock in ACCUMULATE_PROPS. | ✅ Fixed |

### The Multi-Core Soundness Bug (BUG-005 deep-dive)
Fixed on 2026-03-02.
**Root Cause**: `pse.sv` INJECT_CLAUSE was incrementing clause counters but never writing to `lit_mem` or `clause_len`. Injected NoC clauses were effectively invisible "phantoms".
**Fix**: Rewrote `INJECT_RX_CLAUSE` in `solver_core.sv` to use the proven `cae_direct_append_en` path, forcing the PSE FSM through `INIT_WATCHES` to make the new clause visible to BCP. Tested successfully across a 2x2 grid.
