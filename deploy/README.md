# FPGA Deployment Guide

Deploy VeriSAT to a Xilinx Zynq UltraScale+ ZU9EG FPGA.

---

## Directory Structure

```
deploy/
├── deploy.sh              # Master deployment script
├── env.sh                 # Environment setup
├── constraints/
│   ├── timing.xdc         # Clock & timing constraints (150MHz)
│   └── pins_zu9eg.xdc     # Pin assignments (CUSTOMIZE THIS)
├── tcl/
│   ├── synth.tcl          # Synthesis script
│   ├── impl.tcl           # Implementation script
│   └── program.tcl        # FPGA programming script
└── output/
    ├── synth/             # Synthesis checkpoints & reports
    └── impl/              # Bitstreams & implementation reports
```

---

## Quick Start

```bash
# 1. Configure environment
cd VeriSAT/deploy
source env.sh

# 2. Run synthesis (Synthesizes src/Mega/solver_core.sv)
./deploy.sh synth

# 3. Run implementation (Place & Route, Bitstream)
./deploy.sh impl

# 4. Program FPGA
./deploy.sh program
```

---

## Configuration & Customization

### 1. Hard Limits (Compile-Time Parameters)
The hardware capabilities are defined by SystemVerilog parameters. To change the maximum problem size, you must edit `src/Mega/verisat_pkg.sv` and re-synthesize.

| Parameter | Default | File | Description |
|-----------|---------|------|-------------|
| `VAR_MAX` | 16,384 | `verisat_pkg.sv` | Maximum variables supported per core. |
| `CLAUSE_MAX`| 262,144 | `verisat_pkg.sv` | Maximum clauses (memory entries) allocated. |
| `LIT_MAX` | 1,048,576 | `verisat_pkg.sv` | Maximum total literals in clause database. |
| `GRID_X` / `GRID_Y` | 2x2 | `verisat_pkg.sv` | Dimensions of the solver swarm (if using `satswarm_top`). |

**To change these:**
1. Open `src/Mega/verisat_pkg.sv`.
2. Modify the values (e.g., set `VAR_MAX = 32768` for larger problems).
3. Run `./deploy.sh clean` then `./deploy.sh synth`.

### 2. Clock Frequency
The design targets **150 MHz** by default. To adjust this:
1. Open `deploy/constraints/timing.xdc`.
2. Update the period constraint:
   ```tcl
   create_clock -period 6.667 -name sys_clk [get_ports clk] # 150 MHz
   # create_clock -period 10.000 -name sys_clk [get_ports clk] # 100 MHz
   ```

---

## System Integration: Interfacing with the Solver

The VeriSAT core (`solver_core.sv` or `satswarm_top.sv`) is a **pure hardware compute kernel**. It exposes a streaming interface for loading problems and status signals for results.

**To deploy effectively on Zynq, you must integrate this core with the PS (Processing System) via AXI.**

### 1. Uploading SAT Problems (Input Interface)
The solver accepts problems in a streaming format (similar to simplified DIMACS). You need to drive these signals (e.g., via an AXI-Stream FIFO or DMA).

**Protocol:**
*   **Idle State**: Assert `rst_n` (low) to reset. Release to start.
*   **Loading**:
    *   Assert `load_valid = 1`.
    *   Drive `load_literal` with a signed 32-bit integer (e.g., `1`, `-2`).
    *   To mark the end of a clause (0 in DIMACS), assert `load_clause_end = 1` for one cycle along with the *last literal* of that clause.
    *   Wait for `load_ready` to be high before advancing to the next literal.
*   **Starting**:
    *   Once all clauses are loaded, deassert `load_valid`.
    *   Pulse `start_solve` high for one cycle.

### 2. Reading Results (Output Interface)
The solver provides status flags that can be mapped to LEDs or read by a status register.

| Signal | Direction | Description |
|--------|-----------|-------------|
| `solve_done` | Output | Goes high when the solver finishes. |
| `is_sat` | Output | High if the problem is Satisfiable. |
| `is_unsat` | Output | High if the problem is Unsatisfiable. |

**Interpretation:**
*   **SAT**: `solve_done=1`, `is_sat=1`. The solution (variable assignments) is currently stored in the core's internal BRAMs. *Note: Reading out the full assignment vector requires implementing a result readout mechanism, which is currently a future work item.*
*   **UNSAT**: `solve_done=1`, `is_unsat=1`.
*   **Timeout/Running**: `solve_done=0`.

---

## Customizing Constraints

The provided constraints (`deploy/constraints/pins_zu9eg.xdc`) are **placeholders**.

### Pin Mapping Guide
If you are connecting the PL (Programmable Logic) pins directly to board features (like buttons/LEDs), map them as follows:

1. **System Clock (`clk`)**: Connect to a PL-side oscillator pin (e.g., 300MHz differential) or a PS-derived clock.
2. **Reset (`reset`/`rst_n`)**: connect to a push-button (de-bounced) or a virtual debug reset.
3. **Status (`status`/`host_sat`)**: Connect to on-board LEDs for visual feedback.
   ```xdc
   # Example for ZCU102 LEDs
   set_property PACKAGE_PIN AG14 [get_ports {host_sat}]
   set_property IOSTANDARD LVCMOS33 [get_ports {host_sat}]
   ```

### Using Vivado Block Design (Recommended)
For full Zynq deployment:
1. Create a Block Design in Vivado.
2. Instantiate the Zynq UltraScale+ PS (Process System).
3. Import `solver_core.sv` as an RTL Module.
4. Connect PS `FCLK_CLK0` to `clk`.
5. Connect PS AXI GPIOs to drive `load_literal` and read `is_sat`.

---

## Troubleshooting

### Synthesis Fails: "Module not found"
Ensure all source files are in `src/Mega/`. The usage of `verisat_pkg` generally requires it to be compiled before other files. `deploy.sh` handles this, but if doing manual TCL, source the package first.

### Timing Violations (WNS < 0)
*   **Cause**: Logic too deep between registers, or clock too fast (150MHz).
*   **Fix**:
    1. Lower clock frequency in `timing.xdc` (e.g., to 100MHz).
    2. Reduce `VAR_MAX` or `CLAUSE_MAX` in `verisat_pkg.sv` to reduce BRAM utilization and routing congestion.

### "No hardware targets found" during Program
1. Ensure USB JTAG cable is connected.
2. Ensure `hw_server` is running.
3. Check status of dip switches on board (JTAG mode).

---

## Resource Estimates (ZCU102 / ZU9EG)

| Resource | Usage (Approx) | % of device |
|----------|----------------|-------------|
| LUTs     | ~15,000        | ~5%         |
| BRAM     | ~40 tiles      | ~4%         |
| URAM     | ~10 tiles      | ~12%        |

*Note: Usage scales roughly linearly with `GRID_X * GRID_Y`.*
