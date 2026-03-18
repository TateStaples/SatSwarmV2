# Historical Record: Changes, Bugs, and Synthesis Attempts

This document serves as an archive of major architectural pivots, difficult bugs, and the long sequence of AWS synthesis attempts that shaped SatSwarmV2.

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
`hdk_setup.sh` cannot be sourced from this project directory. `set_common_env_vars.sh` calls `git rev-parse --show-toplevel` to set `repo_root`; since this is not a git repo, `repo_root` is empty and `AWS_FPGA_REPO_DIR` gets zeroed out, causing Vivado's `build_all.tcl` to fail with "HDK_SHELL_DIR not set". Fix: export all HDK env vars manually in the same shell/bash-c block as the build command. See `Deploy.md` and `HANDOFF.md` for the complete export block.

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
