# Bug: PCIS AXI4 Byte-Lane Mismatch Corrupts Clause-End Literals on Real F2 Hardware

**Date discovered**: 2026-03-19
**Severity**: Critical — all UNSAT instances return SAT; all SAT cycle counts are wrong
**Status**: RTL fix committed; **AFI rebuild required** before hardware results are valid
**Affected AFIs**: All AFIs to date (afi-08366141b8a92b36f, afi-01ef63d452c8940a2, afi-0520f5f8b8900def7)

---

## Summary

When clause-end literals are uploaded to the FPGA via PCIS MMIO (BAR4), the AXI4
protocol places the 32-bit payload in `wdata[63:32]` (byte lane offset 4), but the RTL
in `cl_satswarm.sv` always extracts `slv_pcis_wdata[31:0]`. The result is that every
last literal of every clause is silently replaced with zero. The XSim BFM always packed
data into `[31:0]` regardless of address, so this bug did not appear in simulation.

On real F2 hardware:
- Every clause is loaded with literal `0` as its final element instead of the true literal.
- UNSAT instances return SAT (corrupted formula becomes satisfiable).
- SAT instances may return SAT with incorrect cycle counts (formula is easier than intended).

---

## Background: AXI4 Byte-Lane Steering

The PCIS (DMA slave) interface between the AWS shell and the CL uses a **512-bit
(64-byte) data bus** (`sh_cl_dma_pcis_wdata[511:0]`). The AXI4 specification requires
that a narrow write of width W bytes to byte address A places its data in byte lanes
`[A[5:0] +: W]` of the wide data bus. The write strobe (`wstrb`) marks the valid lanes.

For a 32-bit MMIO write (4 bytes, `AWSIZE = 2`) to:

| Address  | Byte offset within beat | Valid data bus bits | `wstrb` bits set |
|----------|------------------------|---------------------|-------------------|
| `0x1000` | 0                      | `wdata[31:0]`       | `[3:0]`           |
| `0x1004` | 4                      | `wdata[63:32]`      | `[7:4]`           |
| `0x1008` | 8                      | `wdata[95:64]`      | `[11:8]`          |
| …        | …                      | …                   | …                 |

The SatSwarm CL uses two addresses:
- `0x1000` — normal literal (clause_end = 0)
- `0x1004` — clause-terminating literal (clause_end = 1)

---

## The Bug: `cl_satswarm.sv:601`

```systemverilog
// BEFORE (buggy):
pcis_wr_data  <= slv_pcis_wdata[31:0];
```

This unconditionally takes the lowest 32 bits of the 512-bit data bus regardless of
which byte lane the AXI master used. For a write to `0x1004`, the data occupies bits
`[63:32]`, leaving `[31:0]` as zero (the wstrb indicates those lanes are invalid; the
interconnect drives them to 0 or leaves them as the previous beat's data).

The extracted value passed to `satswarm_core_bridge` as `pcis_wr_data` is therefore `0`
for every clause-end write.

---

## Propagation Through the Stack

```
Host:  fpga_pci_poke(pcis_bar_handle, 0x1004, literal_value)
         ↓  PCIe TLP: MemWrite, addr=0x1004, BE=0xF, data=literal_value
Shell: sh_cl_dma_pcis_wdata[511:0]
         [63:32] = literal_value   ← actual data per AXI4 spec
         [31:0]  = 0               ← invalid lane
         ↓  PCIS_CDC (cl_axi_clock_converter)
cl_satswarm.sv slv_pcis_wdata[511:0]
         [63:32] = literal_value
         [31:0]  = 0
         ↓  line 601 (BUG):
pcis_wr_data = slv_pcis_wdata[31:0] = 0   ← literal_value LOST
         ↓
satswarm_core_bridge.sv:
  host_load_literal    = $signed(0) = 0
  host_load_clause_end = (0x1004 == 0x1004) = 1   ← address check correct
         ↓
pse.sv line 980:
  lit_mem[lit_count_q] <= 0           ← literal 0 stored (wrong)
  clause_len += 1                     ← clause ends here
```

Every clause ends with literal `0` instead of its true final literal. Literal `0` is not
a valid DIMACS variable (variables are 1-indexed). The solver receives a corrupted formula.

---

## Why XSim Simulation Did Not Catch This

The XSim testbench in `test_satswarm_aws.sv` used `tb.poke_pcis` with data always packed
into `[31:0]`, regardless of address:

```systemverilog
// BEFORE (buggy testbench — does not match hardware byte-lane behaviour):
tb.poke_pcis(.addr(64'h1004), .data({480'h0, 32'd2}), ...);
//                                    ^^^^^^^^^^^^^^^^
//                                    literal in [31:0] — correct by accident in sim
```

The BFM packed all data into the low 32 bits, which happened to match what the RTL read,
making simulation pass while hardware failed.

The other XSim tests (`test_satswarm_regression.sv`, `test_satswarm_dma.sv`) bypass the
PCIS AXI path entirely by directly driving the internal `pcis_wr_data` / `pcis_wr_addr`
signals. Those tests are unaffected by both the bug and the fix.

---

## Evidence from Hardware Runs (2026-03-19)

All tests run with: AFI `afi-0520f5f8b8900def7` (agfi-0b41689a08b4d4d5f),
host binary with BAR4 MMIO fix (PR-date build).

| CNF file | Variables | Clauses | Expected | Hardware result | Cycles |
|----------|-----------|---------|----------|-----------------|--------|
| `sat_20v_80c_1.cnf` | 20 | 80 | SAT | **SAT** ✓ | 3,267 |
| `sat_50v_215c_1.cnf` | 50 | 215 | SAT | **SAT** ✓ | 12,972 |
| `unsat_50v_215c_1.cnf` | 50 | 215 | UNSAT | **SAT** ✗ | 12,877 |

XSim reference (same RTL, via `run_aws_regression.sh`): `sat_20v_80c_1.cnf` → SAT, **5,219 cycles**.

**Cycle count discrepancy**: hardware (3,267) vs XSim (5,219) for the same SAT instance.
Both return the correct answer (SAT), but the different cycle counts indicate the solver
is executing a different search because it was given a different (corrupted) formula.
The corrupted formula is easier than the original (missing a literal per clause), so the
hardware solver finishes faster.

**UNSAT→SAT flip**: With the last literal of every clause replaced by `0` (a non-existent
variable), many clauses become shorter and the formula loses constraints. A formula that
was UNSAT under the full constraint set becomes SAT under the reduced set.

---

## The Fix

### `cl_satswarm.sv` — one line changed

```systemverilog
// AFTER (correct):
// AXI4 byte-lane steering: a 32-bit write to byte address A places data in
// wdata[32*(A[5:2]) +: 32].  Always reading [31:0] silently zeroed the
// last literal of every clause (0x1004 writes landed in [63:32]).
pcis_wr_data  <= slv_pcis_wdata[{pcis_aw_addr_q[5:2], 5'h0} +: 32];
```

`pcis_aw_addr_q[5:2]` is the 4-bit word index within the 64-byte beat:

| Address  | `addr[5:2]` | Extracted bits     |
|----------|-------------|---------------------|
| `0x1000` | `4'h0`      | `wdata[31:0]`  ✓   |
| `0x1004` | `4'h1`      | `wdata[63:32]` ✓   |
| `0x1008` | `4'h2`      | `wdata[95:64]` ✓   |

This correctly handles any 32-bit-aligned PCIS write regardless of sub-64-byte offset.

### `test_satswarm_aws.sv` — testbench updated to match hardware

```systemverilog
// AFTER (correct — byte-steered to match hardware):
tb.poke_pcis(.addr(64'h1004), .data({448'h0, 32'd2, 32'h0}), ...);
//                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//                                   literal in [63:32], zero in [31:0]
```

This ensures future XSim runs exercise the same byte-lane extraction path as real hardware.
The `test_satswarm_regression.sv` and `test_satswarm_dma.sv` tests drive `pcis_wr_data`
directly (bypassing `cl_satswarm.sv`) and require no change.

---

## What Still Needs to Be Done

1. **Rebuild the AFI** — The RTL fix is in `hdk_cl_satswarm/design/cl_satswarm.sv`.
   A new Vivado build is required. The existing AFIs all have the bug; do not use
   hardware results from them for correctness testing.

2. **Re-run `test_satswarm_aws.sv` in XSim** — The updated BFM should now pass with
   the fixed RTL. If it fails, the RTL fix has a problem.

3. **Re-run hardware validation** — After a new AFI is built and loaded, repeat the
   UNSAT test suite. Expected: UNSAT instances now return UNSAT; SAT cycle counts
   should align more closely with XSim cycle counts.

---

## Why There Is No Host-Only Workaround

Every possible host-side approach was considered and rejected:

| Approach | Reason it fails |
|----------|-----------------|
| Write clause-end literal to `0x1000`, then dummy to `0x1004` | `pse.sv:980` stores `load_literal` on the clause_end beat — literal `0` becomes the clause's last stored value |
| Encode clause_end in data MSB, always write to `0x1000` | RTL decodes clause_end from address, not data; needs RTL change |
| Use 64-bit MMIO write spanning both lanes | Any write to a 64-byte-aligned base still puts byte-offset-4 data in `[63:32]` |
| Build xdma kernel module | Source not present in this SDK; no pre-built `.ko` available |

The fix must be in the RTL.

---

## Files Changed

| File | Change |
|------|--------|
| `hdk_cl_satswarm/design/cl_satswarm.sv:601` | Byte-lane-aware extraction of `pcis_wr_data` |
| `hdk_cl_satswarm/verif/tests/test_satswarm_aws.sv:38,42` | BFM data placement corrected to match hardware |
| `hdk_cl_satswarm/host/satswarm_host.c` | BAR4 attached separately for MMIO literal loading (prerequisite fix, same session) |
