# Shell-to-Core AWS Connection

This document explains how the SatSwarm SAT solver core connects to the AWS FPGA Shell on F2 instances, covering the full data path from the host application through the PCIe/Shell interfaces down to the solver hardware. For HDK-level reference material, see [HDK.md](HDK.md).

---

## Architecture Overview

The AWS F2 Shell is a fixed piece of logic provided by Amazon that occupies part of the FPGA. It handles PCIe, DMA engines, DDR4 controllers, and management functions. Our **Customer Logic (CL)** plugs into the Shell through a set of standardized AXI interfaces.

The hierarchy is:

```
Host CPU  (satswarm_host.c)
  │  AWS FPGA SDK  (libfpga_mgmt, fpga_pci, fpga_dma)
  ▼
PCIe / Shell  (provided by AWS)
  │  AXI-Lite (OCL BAR0), AXI4 (PCIS BAR4), AXI4 (DDR4)
  ▼
cl_satswarm.sv  (CL top-level — clock gen, CDC, tie-offs)
  │  Simplified AXI-Lite + PCIS + DDR signals
  ▼
satswarm_core_bridge.sv  (register file, CNF load, cycle counter)
  │  Native solver ports
  ▼
satswarm_top.sv  (solver grid + mesh interconnect)
```

> **AWS reference:** [AWS Shell Interface Specification](../src/aws-fpga/hdk/docs/AWS_Shell_Interface_Specification.md) — authoritative spec for every Shell-to-CL signal, timing requirements, and protocol rules.

---

## Shell Interfaces Used

SatSwarm uses three of the Shell's I/O channels. All others are tied off.

### 1. OCL AXI-Lite (AppPF BAR0)

**Purpose:** Low-bandwidth register reads and writes — start/stop the solver, read status, check version.

- **Shell signals:** `ocl_cl_*` / `cl_ocl_*` (32-bit AXI-Lite)
- **BAR mapping:** BAR0, 64 MiB address space
- **Clock domain:** `clk_main_a0` (250 MHz) on the Shell side

The host accesses these registers via `fpga_pci_peek()` / `fpga_pci_poke()` from the AWS FPGA SDK.

> **AWS reference:** [AWS_Fpga_Pcie_Memory_Map.md](../src/aws-fpga/hdk/docs/AWS_Fpga_Pcie_Memory_Map.md) — BAR0 layout and address decoding rules.

### 2. DMA PCIS AXI4 (AppPF BAR4)

**Purpose:** High-bandwidth CNF literal upload from host to FPGA. The host writes each literal as a 32-bit word to address `0x1000` (mid-clause) or `0x1004` (clause-end marker).

- **Shell signals:** `sh_cl_dma_pcis_*` / `cl_sh_dma_pcis_*` (512-bit AXI4)
- **BAR mapping:** BAR4, 128 GiB address space
- **Transfer modes:** XDMA burst writes (`fpga_dma_burst_write()`) or MMIO fallback (`fpga_pci_poke()` on BAR4)

> **AWS reference:** [AWS Shell Interface Specification](../src/aws-fpga/hdk/docs/AWS_Shell_Interface_Specification.md) — PCIS protocol, 4K boundary rule, 8 us timeout. See also [AWS_Shell_ERRATA.md](../src/aws-fpga/hdk/docs/AWS_Shell_ERRATA.md) for 64B AxSIZE requirements.

### 3. DDR4 AXI4 (via sh_ddr)

**Purpose:** External memory for clause literal overflow. The solver grid accesses DDR4 through `global_mem_arbiter.sv`, which arbitrates among cores.

- **Shell signals:** `cl_sh_ddr_*` / `sh_cl_ddr_*` (512-bit AXI4)
- **Instantiated via:** `sh_ddr` macro from the HDK

> **AWS reference:** [Supported_DDR_Modes.md](../src/aws-fpga/hdk/docs/Supported_DDR_Modes.md)

### Tied-Off Interfaces

The following Shell interfaces are unused and tied to safe defaults in `cl_satswarm.sv`:

- **SDA** (AXI-Lite BAR1) — not needed; all registers fit in OCL
- **PCIM** (CL-initiated PCIe reads) — solver does not DMA back to host memory
- **HBM** — not used; DDR4 is sufficient
- **PCIe EP/RP** — not a PCIe endpoint design
- **JTAG / Virtual JTAG** — debug via register reads instead
- **Interrupts** — host polls status register

---

## CL Top-Level: cl_satswarm.sv

**Source:** [`hdk_cl_satswarm/design/cl_satswarm.sv`](../hdk_cl_satswarm/design/cl_satswarm.sv)

This module is the entry point for all Shell interactions. Its responsibilities:

### Reset Synchronization

```systemverilog
lib_pipe #(.WIDTH(1), .STAGES(4)) RST_PIPE (
    .clk     (clk_main_a0),
    .rst_n   (1'b1),
    .in_bus  (rst_main_n),
    .out_bus (rst_main_n_sync)
);
```

The Shell's `rst_main_n` is synchronized through a 4-stage pipeline register to avoid metastability on `clk_main_a0`.

### Solver Clock Generation

The Shell provides `clk_main_a0` at 250 MHz. The solver needs a slower clock to meet timing on the CDCL datapath. A CL-owned MMCM generates it:

```
clk_main_a0 (250 MHz) → MMCME4_ADV → VCO 1250 MHz → /80 → 15.625 MHz → BUFG → clk_solver
```

- **MMCM parameters:** `CLKFBOUT_MULT_F=5.0`, `CLKOUT0_DIVIDE_F=80.0`, `DIVCLK_DIVIDE=1`
- **Solver reset** (`rst_solver_n`) is held low until `mmcm_solver_locked` asserts, ensuring the solver only starts after a stable clock.

The `aws_clk_gen` IP is instantiated with all clock groups disabled (`CLK_GRP_A_EN=0`, etc.) purely for HDK elaboration compatibility — it generates no clocks.

> **AWS reference:** [Clock_Recipes_User_Guide.md](../src/aws-fpga/hdk/docs/Clock_Recipes_User_Guide.md), [AWS_CLK_GEN_spec.md](../src/aws-fpga/hdk/docs/AWS_CLK_GEN_spec.md)

### Clock Domain Crossing (CDC)

Because Shell-facing logic runs at 250 MHz and solver logic runs at 15.625 MHz, every interface needs a CDC bridge:

| Instance | Type | From | To | Purpose |
|----------|------|------|----|---------|
| `OCL_CDC` | `cl_axi_clock_converter_light` | `clk_main_a0` | `clk_solver` | Register reads/writes |
| `PCIS_CDC` | `cl_axi_clock_converter` | `clk_main_a0` | `clk_solver` | DMA literal uploads |
| `DDR_CDC` | `cl_axi_clock_converter` | `clk_solver` | `clk_main_a0` | DDR4 memory access |

Status LED signals (`solver_done`, `solver_sat`, `solver_unsat`) use 2-FF synchronizers from `clk_solver` back to `clk_main_a0` for the virtual LED output (`cl_sh_status_vled`).

> **AWS reference:** [How_To_Detect_Shell_Timeout.md](../src/aws-fpga/hdk/docs/How_To_Detect_Shell_Timeout.md) — if a CDC stall causes the Shell's 8 us AXI timeout, the AFI must be reloaded.

### Shell Identity

```systemverilog
cl_sh_id0 = `CL_SH_ID0;   // Vendor/Device ID
cl_sh_id1 = `CL_SH_ID1;   // Subsystem ID
```

Defined in [`cl_id_defines.vh`](../hdk_cl_satswarm/design/cl_id_defines.vh). The Shell reads these to identify the loaded CL.

---

## Core Bridge: satswarm_core_bridge.sv

**Source:** [`hdk_cl_satswarm/design/satswarm_core_bridge.sv`](../hdk_cl_satswarm/design/satswarm_core_bridge.sv)

This module converts the AXI-based signals from `cl_satswarm` into the solver's native port interface. It runs entirely in the `clk_solver` domain.

### Register Map

| Address | Access | Bits | Description |
|---------|--------|------|-------------|
| `0x00` | Write | `[0]` | `host_start` — triggers solve (auto-clears after 1 cycle) |
| `0x00` | Read | `[0]` done, `[1]` sat, `[2]` unsat | Solver status |
| `0x04` | Read | `[31:0]` | Cycle counter (resets on `host_start`, increments until `host_done`) |
| `0x08` | Read | `[31:0]` | Version magic `0x53415431` ("SAT1") |
| `0x0C` | Write | `[0]` | Soft reset (auto-clears) |
| `0x10` | R/W | `[31:0]` | Debug verbosity level |

### CNF Literal Loading

PCIS writes are decoded by address to produce a literal stream:

```systemverilog
host_load_valid   <= 1'b1;
host_load_literal <= $signed(pcis_wr_data);  // DIMACS signed literal
host_load_clause_end <= (pcis_wr_addr[15:0] == 16'h1004);  // 0x1004 = end-of-clause
```

- Write to `0x1000`: literal within a clause (`clause_end = 0`)
- Write to `0x1004`: last literal of a clause (`clause_end = 1`)
- Backpressure: `pcis_wr_ready = host_load_ready` (from `satswarm_top`)

### Solver Instantiation

The bridge instantiates `satswarm_top` with all grid and memory parameters, connecting:
- Control signals: `host_start`, `host_done`, `host_sat`, `host_unsat`
- CNF load stream: `host_load_valid/literal/clause_end/ready`
- DDR4 memory: `ddr_read_*`, `ddr_write_*`
- Debug level

---

## Host Application: satswarm_host.c

**Source:** [`hdk_cl_satswarm/host/satswarm_host.c`](../hdk_cl_satswarm/host/satswarm_host.c)

The host-side C program runs on the EC2 F2 instance CPU and communicates with the FPGA through the AWS FPGA SDK libraries.

### SDK Libraries Used

| Library | Header | Purpose |
|---------|--------|---------|
| **FPGA Management** | `<fpga_mgmt.h>` | `fpga_mgmt_init()`, `fpga_mgmt_describe_local_image()` — initialize SDK, verify AFI is loaded |
| **FPGA PCI** | `<fpga_pci.h>` | `fpga_pci_attach()`, `fpga_pci_peek()`, `fpga_pci_poke()` — BAR0/BAR4 MMIO register access |
| **FPGA DMA** | `<fpga_dma.h>` | `fpga_dma_open_queue()`, `fpga_dma_burst_write()` — XDMA high-speed transfers |

> **AWS reference:** The SDK source and headers live in `$SDK_DIR` (typically `src/aws-fpga/sdk`). See also [XDMA_Install.md](../src/aws-fpga/hdk/docs/XDMA_Install.md) for DMA driver setup.

### Execution Flow

```
1. fpga_init()
   ├── fpga_mgmt_init()                    // Initialize management library
   ├── fpga_mgmt_describe_local_image()    // Verify AFI status == LOADED
   ├── fpga_pci_attach(BAR0)               // Attach OCL for register access
   ├── Poll REG_VERSION until 0x53415431   // Wait for MMCM lock + reset release
   └── fpga_dma_open_queue(XDMA)           // Open DMA channel (BAR4 MMIO fallback)

2. parse_cnf(filename)
   └── Read DIMACS file → lit_buffer[]     // Array of {literal, clause_end} pairs

3. upload_cnf()
   ├── fpga_pci_poke(REG_SOFT_RESET, 1)   // Reset solver
   └── For each literal:
       ├── addr = clause_end ? 0x1004 : 0x1000
       └── fpga_dma_burst_write() or fpga_pci_poke(BAR4, addr, data)

4. run_solve(timeout)
   ├── fpga_pci_poke(REG_STATUS, 1)        // Assert host_start
   ├── Poll REG_STATUS until STATUS_DONE   // 100us intervals
   └── fpga_pci_peek(REG_CYCLES)           // Read solve time

5. fpga_cleanup()
   ├── close(dma_write_fd)
   ├── fpga_pci_detach(ocl_bar_handle)
   └── fpga_mgmt_close()
```

### Usage

```bash
# Build
make -C hdk_cl_satswarm/host/

# Run (AFI must already be loaded)
./hdk_cl_satswarm/host/satswarm_host test.cnf --slot 0 --timeout 60 --debug 1
```

Wrapper scripts are provided for convenience:
- [`hdk_cl_satswarm/scripts/run_fpga_single.sh`](../hdk_cl_satswarm/scripts/run_fpga_single.sh) — single CNF file
- [`hdk_cl_satswarm/scripts/run_fpga_suite.sh`](../hdk_cl_satswarm/scripts/run_fpga_suite.sh) — batch execution over a directory

---

## Data Flow Diagram

```
                         Host CPU
                     ┌──────────────────┐
                     │  satswarm_host.c  │
                     │                   │
                     │  fpga_pci_poke()  │──── BAR0 (OCL AXI-Lite) ────┐
                     │  fpga_pci_peek()  │◄── BAR0 (OCL AXI-Lite) ────┤
                     │                   │                              │
                     │  fpga_dma_burst   │──── BAR4 (PCIS AXI4) ──────┤
                     │  _write()         │                              │
                     └──────────────────┘                              │
                                                                       │
                     ┌─────────────────────────────────────────────────┤
                     │              AWS Shell (250 MHz)                │
                     │                                                 │
                     │  OCL AXI-Lite ──► OCL_CDC ──┐                  │
                     │  PCIS AXI4   ──► PCIS_CDC ──┤  (clk_solver    │
                     │  DDR4 AXI4   ◄── DDR_CDC ◄──┤   15.625 MHz)   │
                     └──────────────────────────────┤──────────────────┘
                                                    │
                     ┌──────────────────────────────┤
                     │        cl_satswarm            │
                     │   (CL top, clock gen, CDC)    │
                     └──────────────┬───────────────┘
                                    │
                     ┌──────────────▼───────────────┐
                     │    satswarm_core_bridge       │
                     │  (register file, CNF decode,  │
                     │   cycle counter)              │
                     └──────────────┬───────────────┘
                                    │
                     ┌──────────────▼───────────────┐
                     │       satswarm_top            │
                     │  (GRID_X × GRID_Y solver     │
                     │   cores + mesh interconnect)  │
                     └──────────────────────────────┘
```

---

## Key Design Decisions

### Why a CL-owned MMCM instead of aws_clk_gen?

The `aws_clk_gen` IP provides configurable clocks via recipe tables, but the available recipes don't include 15.625 MHz. A CL-owned `MMCME4_ADV` gives exact control over the solver frequency. The `aws_clk_gen` is still instantiated (all groups disabled) because the HDK build scripts expect it.

### Why 15.625 MHz?

The CDCL solver's critical path — through the propagation engine's watched-literal lookup, conflict detection, and trail update — is long. 15.625 MHz provides sufficient timing margin on the VU47P at the target grid sizes (up to 3x3). Higher frequencies are possible with pipeline optimizations.

### Why poll instead of interrupts?

The host polls `REG_STATUS` at 100 us intervals rather than using Shell interrupts. This simplifies the CL (no interrupt logic needed) and is sufficient because solve times are typically milliseconds to seconds. The polling overhead is negligible.

### DMA vs MMIO for literal loading

The host prefers XDMA burst writes for CNF upload (higher throughput). If the DMA channel fails to open (e.g., XDMA driver not installed), it falls back to individual MMIO writes via BAR4 (`fpga_pci_poke`). Both paths produce identical literal streams to the solver.

---

## Environment Setup

Before running on hardware, source the environment script:

```bash
source deploy/env.sh
```

This sets:
- `AWS_FPGA_REPO_DIR` / `HDK_DIR` / `SDK_DIR` — paths to the AWS FPGA HDK/SDK
- `IS_AWS_FPGA` — auto-detected from instance metadata
- `VERISAT_ROOT` — project root

For AFI creation, also set `SATSWARM_S3_BUCKET` to your S3 bucket name.

See [AWS_instructions.md](AWS_instructions.md) for full FPGA Developer AMI setup and [FPGA.md](FPGA.md) for AFI loading and execution.

---

## AWS HDK Documentation Index

For deeper details on any Shell interface, see the bundled HDK docs listed in [HDK.md](HDK.md):

| Topic | Document |
|-------|----------|
| Shell-CL interface spec | [AWS_Shell_Interface_Specification.md](../src/aws-fpga/hdk/docs/AWS_Shell_Interface_Specification.md) |
| Shell errata (timeouts, boundaries) | [AWS_Shell_ERRATA.md](../src/aws-fpga/hdk/docs/AWS_Shell_ERRATA.md) |
| PCIe BAR memory map | [AWS_Fpga_Pcie_Memory_Map.md](../src/aws-fpga/hdk/docs/AWS_Fpga_Pcie_Memory_Map.md) |
| Clock recipes & aws_clk_gen | [Clock_Recipes_User_Guide.md](../src/aws-fpga/hdk/docs/Clock_Recipes_User_Guide.md) |
| Shell timeout detection | [How_To_Detect_Shell_Timeout.md](../src/aws-fpga/hdk/docs/How_To_Detect_Shell_Timeout.md) |
| AFI lifecycle | [Amazon_FPGA_Images_Afis_Guide.md](../src/aws-fpga/hdk/docs/Amazon_FPGA_Images_Afis_Guide.md) |
| RTL simulation | [RTL_Simulation_Guide_for_HDK_Design_Flow.md](../src/aws-fpga/hdk/docs/RTL_Simulation_Guide_for_HDK_Design_Flow.md) |
| XDMA driver install | [XDMA_Install.md](../src/aws-fpga/hdk/docs/XDMA_Install.md) |

---

## Related Documentation

- [Design.md](Design.md) — High-level solver architecture
- [HDK.md](HDK.md) — Full HDK doc index
- [Synth.md](Synth.md) — AWS synthesis workflow
- [FPGA.md](FPGA.md) — Loading AFI and running on hardware
- [spec/cl_satswarm.md](spec/cl_satswarm.md) — Detailed CL RTL spec
- [spec/satswarm_core_bridge.md](spec/satswarm_core_bridge.md) — Bridge RTL spec
