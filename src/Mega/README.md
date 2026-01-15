# SatSwarm Implementation

**Context**
This directory contains the implementation of **SatSwarm**, a distributed FPGA-based SAT solver. Unlike traditional single-core solvers, SatSwarm uses a grid of cooperative cores (`solver_core`) connected via a Network-on-Chip (NoC) to partition the SAT search space using "Divergence Propagation".

**Architecture Overview**
*   **Grid Topology**: 4x4 (scalable) mesh of solver cores.
*   **Divergence**: Active nodes force idle neighbors to explore specific sub-problems ($\neg X$).
*   **Hybrid Memory**:
    *   *Local*: Fast BRAM/LUTRAM for Trail, Variable Table, and Clause Headers.
    *   *Global*: Shared DDR4 for Clause Literals and original Problem CNF.
*   **Communication**: `noc_packet_t` protocol for Divergence and Clause Sharing.

**Files**
*   `spec.md`: The authoritative architecture specification.
*   `solver_core.sv`: The main CDCL processing unit (modified for Swarm).
*   `pse.sv`: Propagation Search Engine (Swarm-aware).
*   `cae.sv`: Conflict Analysis Engine (Global-aware).
*   `vde.sv`: Variable Decision Engine (Divergence-aware).
*   `interface_unit.sv`: NoC packet wrapper.

**Action Plan**
1.  Read `spec.md` thoroughly.
2.  Implement `solver_core.sv` as the top-level wrapper for a single node.
3.  Implement the Swarm-specific sub-blocks (`interface_unit`, `global_mem_arbiter`).
4.  Modify `pse/cae/vde` to handle the new External Force and Global Memory ports.

**Target Platform**
Xilinx ZU9EG (UltraScale+). Goal: 150 MHz Core / 300 MHz NoC.
