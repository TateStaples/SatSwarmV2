# DDR Literal Pool — Architecture & Write-Through Pipeline

## Purpose

SatSwarm uses DDR4 as a **mirrored replica** of each solver core's on-chip
literal array (`lit_mem` inside `pse.sv`).  Three reasons:

1. **Capacity** — the FPGA's on-chip SRAM is the limiting factor for literal pool
   size.  Mirroring to DDR allows future designs to spill the literal pool off-chip
   entirely, removing the BRAM constraint.
2. **Debug visibility** — hardware debugging can inspect the full literal pool
   without stopping the solver (DDR is readable via the host at any time).
3. **Future clause retrieval** — learned clause bodies will eventually be read back
   from DDR during watch-list processing; the mirror establishes the correct address
   layout before the read path is needed.

---

## Address Map

Byte addresses are **32-bit** on the solver's simplified global port
(`global_write_addr` / `global_read_addr`); the AWS CL bridge maps them straight
to AXI4 byte addresses on `SH_DDR`.

| Region | Base address | Size | Notes |
|--------|-------------|------|-------|
| **Per-core literal pool** | `CORE_ID * MAX_LITS * 4` | `MAX_LITS * 4` bytes per core | Contiguous, statically allocated. Literal index `i` maps to byte `pool_base + i*4`. |
| **Learned bump allocator** | `32'h4000_0000` (`global_allocator BASE_ADDR`) | Grows upward | Reserved for future fragmented learned-clause storage; `alloc_req`/`alloc_words` account for each clause. Literal bodies still live in the per-core pool above. |

### Concrete example — 1×1 build, MAX_LITS = 16384

```
0x00000000 .. 0x0000FFFC   Core 0 literal pool   (16384 literals × 4 bytes = 64 KB)
0x40000000 ..              Bump allocator region  (learned clause metadata, future)
```

### Concrete example — 2×2 build, MAX_LITS = 16384

```
0x00000000 .. 0x0000FFFC   Core 0 literal pool   (64 KB)
0x00010000 .. 0x0001FFFC   Core 1 literal pool   (64 KB)
0x00020000 .. 0x0002FFFC   Core 2 literal pool   (64 KB)
0x00030000 .. 0x0003FFFC   Core 3 literal pool   (64 KB)
0x40000000 ..              Bump allocator region
```

---

## Write-Through Pipeline

Every literal written into the PSE is simultaneously mirrored to DDR in the
same clock cycle (the strobe appears concurrent with the in-core write).

```
pse.sv
  lit_ddr_wr      — one-cycle strobe, HIGH on the cycle a literal is written
  lit_ddr_wr_idx  — index i in this core's pool (absolute, not clause-relative)
  lit_ddr_wr_data — the signed 32-bit literal value
        |
        v
solver_core.sv
  global_write_req  = ENABLE_LIT_DDR_MIRROR ? lit_ddr_wr : 0
  global_write_addr = LIT_POOL_BYTE_BASE + lit_ddr_wr_idx * 4
  global_write_data = lit_ddr_wr_data
        |
        v
global_mem_arbiter.sv
  Round-robin N:1 mux.  Guards with write_active_q:
    set on ddr_write_grant  (bridge accepted the write)
    cleared on ddr_write_done (BRESP received)
  ARB_IDLE refuses new writes while write_active_q is high.
        |
        v  (simulation)                      (synthesis)
tb_satswarmv2.sv                     hdk_cl_satswarm/design/cl_satswarm.sv
  Sparse associative-array mock.       Full AXI4 DDR FSM:
  ddr_write_grant = 1 same cycle.        DDR_IDLE → DDR_WR_ADDR → DDR_WR_DATA
  ddr_write_done  = 1 next cycle.        → DDR_WR_RESP → DDR_IDLE
                                       addr/data latched in ddr_wr_addr_q/data_q
                                       on DDR_IDLE→DDR_WR_ADDR transition.
                                       ddr_write_done pulsed on bvalid in RESP.
```

### Two trigger sources in pse.sv

| Trigger | When | Index | Data |
|---------|------|-------|------|
| CNF load | `load_fire` (= `load_valid && load_ready`) during loading states | `lit_count_q` — absolute position of this literal in the pool | `load_literal` |
| Learned clause append | Each cycle of `APPEND_CLAUSE` state (serialized: one literal/cycle) | `append_clause_base_q + append_idx_q` | `append_lits_q[append_idx_q]` |

---

## Signal Glossary

| Signal | Location | Description |
|--------|----------|-------------|
| `ENABLE_LIT_DDR_MIRROR` | `solver_core.sv`, `pse.sv` | Parameter (default 1). When 0, `global_write_req` is always 0 and no DDR writes occur from this core. |
| `LIT_POOL_BYTE_BASE` | `solver_core.sv` | `localparam = CORE_ID * MAX_LITS * 4`. Byte offset of this core's pool region. |
| `lit_ddr_wr` | `pse.sv` → `solver_core.sv` | One-cycle strobe. HIGH exactly on the clock a literal is written. |
| `lit_ddr_wr_idx` | `pse.sv` → `solver_core.sv` | Literal pool index (0-based, absolute). |
| `lit_ddr_wr_data` | `pse.sv` → `solver_core.sv` | Signed 32-bit literal value to write. |
| `pse_append_active` | `pse.sv` → `solver_core.sv` | HIGH throughout `APPEND_CLAUSE` state (multi-cycle for long clauses). Used by edge-detector to fire `alloc_req` exactly once per learned clause. |
| `write_active_q` | `global_mem_arbiter.sv` | Registered flag. Set on `ddr_write_grant`; cleared on `ddr_write_done`. Prevents issuing a new write before the prior BRESP arrives. |
| `ddr_write_done` | `cl_satswarm.sv` → `satswarm_core_bridge` → `satswarm_top` → `global_mem_arbiter` | One-cycle pulse from the AXI bridge when BRESP (`bvalid`) is received. Clears `write_active_q`. |
| `ddr_wr_addr_q` / `ddr_wr_data_q` | `cl_satswarm.sv` | Registered copies of `ddr_write_addr/data`. Latched on `DDR_IDLE→DDR_WR_ADDR` to hold AXI signals stable across the multi-cycle AXI write handshake. |

---

## Simulation vs. Synthesis Differences

| Aspect | Simulation (`tb_satswarmv2.sv`) | Synthesis (`cl_satswarm.sv`) |
|--------|--------------------------------|------------------------------|
| Backing store | `logic [31:0] tb_ddr_mem [logic [31:0]]` — sparse associative array | Real DDR4 via AWS `SH_DDR` IP |
| Write latency | 1 cycle (grant same cycle as req) | Several cycles (AXI4 handshake: AWVALID→AWREADY→WVALID→WREADY→BVALID) |
| `ddr_write_done` | 1 cycle after `ddr_write_grant` | 1 cycle after `m_ddr_axi_bvalid` in `DDR_WR_RESP` |
| Read latency | 1 cycle (grant+valid same cycle as req) | Multi-cycle DDR read latency |
| Addr/data stability | Arbiter outputs stable for full duration (no re-use before done) | `ddr_wr_addr_q`/`ddr_wr_data_q` latch provides stability |
| Unwritten reads | Return `32'hDEAD_BEEF` (sentinel) | Return whatever DDR contains (undefined at startup) |

---

## Verification

```bash
# Build with DDR_CHECK assertions enabled (1×1, -DDDR_CHECK=1)
cd sim && make test_ddr_mirror
```

`test_ddr_mirror` (defined in `sim/Makefile`) builds `tb_satswarmv2.sv` with
`-DDDR_CHECK=1` and runs a small SAT instance (`sat_5v_10c_1.cnf`).  The
`DDR_CHECK` block in the testbench asserts:

1. **Range check** — every `ddr_write_addr` must be in `[0, GRID_X*GRID_Y*MAX_LITS*4)`.
   A write above this limit means either a miscalculated `LIT_POOL_BYTE_BASE` or an
   out-of-bounds literal index in the PSE.
2. **Liveness check** — `ddr_write_count > 0` at the end of each test.  Catches the
   case where `ENABLE_LIT_DDR_MIRROR` was accidentally disabled.

Expected output: `[DDR_CHECK] PASS: 30 DDR writes (all within pool range).`
