# OpenSTA Timing Analysis for SatSwarmV2

This directory contains files for performing static timing analysis on the VeriSAT hardware using OpenSTA.

## Prerequisites

- OpenSTA built at `../tools/OpenSTA/build/sta`
- Yosys for synthesis: `brew install yosys`
- A generic Liberty library (Nangate45 provided for demonstration)

## Files

- `constraints.sdc` - SDC timing constraints (derived from Vivado XDC)
- `run_sta.tcl` - TCL script to run OpenSTA timing analysis
- `synth_for_sta.ys` - Yosys script to generate gate-level netlist
- `nangate45.lib` - Generic Liberty library for timing (placeholder)

## Usage

### 1. Generate Gate-Level Netlist
```bash
cd /path/to/SatSwarmV2
yosys -s timing_analysis/synth_for_sta.ys
```

### 2. Run Timing Analysis
```bash
../tools/OpenSTA/build/sta timing_analysis/run_sta.tcl
```

## Notes

- OpenSTA is primarily an ASIC tool. Without real FPGA cell timing data (Liberty libraries), the timing numbers are estimates only.
- For accurate Xilinx timing analysis, use Vivado's built-in STA (`report_timing`).
- This flow is useful for relative path analysis and design exploration.
