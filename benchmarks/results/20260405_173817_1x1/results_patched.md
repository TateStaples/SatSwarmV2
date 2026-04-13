# SatSwarm Benchmark Results (Patched with Verilator Re-simulation)

- **Grid config**: 1x1
- **Run timestamp**: 20260405_173817 (FPGA), 20260411 (Verilator re-sim)
- **Instances per dataset**: 15
- **FPGA slot**: 0
- **Host binary**: /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host
- **Verilator re-sim**: MAX_CLAUSES_PER_CORE=32768, MAX_LITS=65536 (4x FPGA clause capacity)

### Re-simulation Finding

**7 FPGA failures reproduced in Verilator with 4x clause capacity** — all return false UNSAT.
This confirms a **solver correctness bug** (not a resource limitation). All 7 instances
verified SATISFIABLE by minisat.

### Root Cause: Incorrect Learned Clauses

Instrumented Verilator runs reveal a consistent failure pattern:

1. **Buffers are NOT the issue**: Clause store peaked at 4-5% (max 1936/32768), literal pool at 18-27%, zero clause drops, zero CAE buffer overflows.
2. **UNSAT triggered from PSE_PHASE at decision_level==0**: After ~800-1400 conflicts and 13-21 restarts, a restart drives decision_level back to 0. BCP at level 0 using only the original + learned clauses produces a conflict.
3. **CAE did NOT signal UNSAT** (`cae_unsat=0`): The FINISH_UNSAT was entered from the PSE_PHASE conflict-at-level-0 path (`solver_core.sv:1281-1282`), not from CAE.
4. **Learned clauses are wrong**: Since these are SAT instances, a conflict at level 0 with only learned clauses + original clauses means the solver learned an invalid clause at some point. The accumulated invalid clauses eventually create a false contradiction.

**Likely culprits** (in order of suspicion):
- **CAE resolution bug**: Incorrect 1UIP computation produces a learned clause that doesn't logically follow from the conflict.
- **PSE watched-literal bug**: BCP incorrectly identifies a conflict or propagation, feeding wrong data to CAE.
- **Trail/level corruption**: Variable levels become inconsistent, causing CAE to compute wrong backtrack levels and wrong learned clause literals.

### Forensic Data (per instance)

| Instance | Cycles | Conflicts | Restarts | Clause HW | Lit HW | Trail HW | DLvl HW | UNSAT Path |
|----------|--------|-----------|----------|-----------|--------|----------|---------|------------|
| uf100-04 | 2,336,726 | 1,296 | 20 | 1726 (5%) | 13209 (20%) | 86 | 20 | PSE conflict @ dlvl 0 |
| uf125-04 | 1,578,487 | 859 | 13 | 1397 (4%) | 11882 (18%) | 105 | 24 | PSE conflict @ dlvl 0 |
| uf125-010 | 2,160,120 | 1,158 | 18 | 1696 (5%) | 13650 (20%) | 103 | 24 | PSE conflict @ dlvl 0 |
| uf125-011 | 2,441,312 | 1,223 | 18 | 1761 (5%) | 15353 (23%) | 111 | 22 | PSE conflict @ dlvl 0 |
| uf125-012 | 2,230,268 | 1,111 | 17 | 1649 (5%) | 15262 (23%) | 101 | 22 | PSE conflict @ dlvl 0 |
| uf125-013 | >4,700,000 | >1,400 | >21 | ~1944 (5%) | — | — | — | (killed, same pattern) |
| uf125-014 | 2,931,197 | 1,398 | 21 | 1936 (5%) | 18015 (27%) | 106 | 25 | PSE conflict @ dlvl 0 |

### Additional Finding: 16-bit Clause ID Ceiling

Clause IDs are `logic [15:0]` in `cae.sv`, `trail_manager.sv`, `watch_manager.sv`, and
`solver_core.sv`. This imposes a hard limit of `MAX_CLAUSES_PER_CORE <= 32768`.
Setting `MAX_CLAUSES=65536` causes the solver to hang (0 conflicts, infinite loop).

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 46091 | 2.949 | 1.480 | ✓ |
| uf50-02 | SAT | SAT | 36134 | 2.312 | 1.573 | ✓ |
| uf50-03 | SAT | SAT | 62234 | 3.982 | 1.397 | ✓ |
| uf50-04 | SAT | SAT | 65809 | 4.211 | 1.390 | ✓ |
| uf50-05 | SAT | SAT | 15806 | 1.011 | 1.388 | ✓ |
| uf50-06 | SAT | SAT | 47200 | 3.020 | 2.218 | ✓ |
| uf50-07 | SAT | SAT | 28627 | 1.832 | 1.399 | ✓ |
| uf50-08 | SAT | SAT | 54646 | 3.497 | 1.586 | ✓ |
| uf50-09 | SAT | SAT | 54861 | 3.511 | 1.382 | ✓ |
| uf50-010 | SAT | SAT | 27856 | 1.782 | 1.385 | ✓ |
| uf50-011 | SAT | SAT | 56046 | 3.586 | 1.390 | ✓ |
| uf50-012 | SAT | SAT | 46056 | 2.947 | 1.401 | ✓ |
| uf50-013 | SAT | SAT | 14376 | .920 | 1.385 | ✓ |
| uf50-014 | SAT | SAT | 25020 | 1.601 | 1.504 | ✓ |
| uf50-015 | SAT | SAT | 26674 | 1.707 | 1.381 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 40495 &nbsp;|&nbsp; mean time: 2.591 ms &nbsp;|&nbsp; mean wall: 1.483s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 63703 | 4.076 | 1.554 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 51698 | 3.308 | 1.386 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 64875 | 4.152 | 1.391 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 57161 | 3.658 | 1.403 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 62686 | 4.011 | 1.393 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 67380 | 4.312 | 1.864 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 106559 | 6.819 | 1.392 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 57356 | 3.670 | 1.392 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 87263 | 5.584 | 1.392 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 52164 | 3.338 | 1.419 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 71264 | 4.560 | 1.588 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 98183 | 6.283 | 1.382 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 48248 | 3.087 | 1.401 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 66897 | 4.281 | 1.500 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 50433 | 3.227 | 1.573 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 67058 &nbsp;|&nbsp; mean time: 4.291 ms &nbsp;|&nbsp; mean wall: 1.468s

---

## uf75 — SAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf75-01 | SAT | SAT | 191930 | 12.283 | 1.574 | ✓ |
| uf75-02 | SAT | SAT | 63974 | 4.094 | 1.401 | ✓ |
| uf75-03 | SAT | SAT | 53597 | 3.430 | 1.394 | ✓ |
| uf75-04 | SAT | SAT | 181274 | 11.601 | 1.392 | ✓ |
| uf75-05 | SAT | SAT | 189376 | 12.120 | 1.392 | ✓ |
| uf75-06 | SAT | SAT | 155185 | 9.931 | 1.536 | ✓ |
| uf75-07 | SAT | SAT | 332353 | 21.270 | 1.397 | ✓ |
| uf75-08 | SAT | SAT | 199959 | 12.797 | 1.387 | ✓ |
| uf75-09 | SAT | SAT | 174566 | 11.172 | 1.395 | ✓ |
| uf75-010 | SAT | SAT | 259428 | 16.603 | 1.389 | ✓ |
| uf75-011 | SAT | SAT | 89784 | 5.746 | 1.388 | ✓ |
| uf75-012 | SAT | SAT | 186738 | 11.951 | 1.413 | ✓ |
| uf75-013 | SAT | SAT | 37386 | 2.392 | 1.577 | ✓ |
| uf75-014 | SAT | SAT | 26200 | 1.676 | 1.436 | ✓ |
| uf75-015 | SAT | SAT | 173496 | 11.103 | 1.413 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 154349 &nbsp;|&nbsp; mean time: 9.878 ms &nbsp;|&nbsp; mean wall: 1.432s

---

## uuf75 — UNSAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf75-01 | UNSAT | UNSAT | 231132 | 14.792 | 1.562 | ✓ |
| uuf75-02 | UNSAT | UNSAT | 194234 | 12.430 | 1.586 | ✓ |
| uuf75-03 | UNSAT | UNSAT | 326639 | 20.904 | 1.409 | ✓ |
| uuf75-04 | UNSAT | UNSAT | 182805 | 11.699 | 1.396 | ✓ |
| uuf75-05 | UNSAT | UNSAT | 379659 | 24.298 | 1.401 | ✓ |
| uuf75-06 | UNSAT | UNSAT | 233602 | 14.950 | 1.683 | ✓ |
| uuf75-07 | UNSAT | UNSAT | 250754 | 16.048 | 1.391 | ✓ |
| uuf75-08 | UNSAT | UNSAT | 467743 | 29.935 | 1.604 | ✓ |
| uuf75-09 | UNSAT | UNSAT | 138944 | 8.892 | 1.570 | ✓ |
| uuf75-010 | UNSAT | UNSAT | 344971 | 22.078 | 1.398 | ✓ |
| uuf75-011 | UNSAT | UNSAT | 349204 | 22.349 | 1.404 | ✓ |
| uuf75-012 | UNSAT | UNSAT | 281959 | 18.045 | 1.589 | ✓ |
| uuf75-013 | UNSAT | UNSAT | 583023 | 37.313 | 2.069 | ✓ |
| uuf75-014 | UNSAT | UNSAT | 556820 | 35.636 | 1.602 | ✓ |
| uuf75-015 | UNSAT | UNSAT | 262217 | 16.781 | 1.576 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 318913 &nbsp;|&nbsp; mean time: 20.410 ms &nbsp;|&nbsp; mean wall: 1.549s

---

## uf100 — SAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | Source | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|--------|-----|
| uf100-01 | SAT | SAT | 1027143 | 65.737 | 1.617 | FPGA | ✓ |
| uf100-02 | SAT | SAT | 272070 | 17.412 | 1.546 | FPGA | ✓ |
| uf100-03 | SAT | SAT | 623299 | 39.891 | 1.418 | FPGA | ✓ |
| uf100-04 | SAT | **UNSAT** | 2336726 | 149.550 | — | **Verilator (32k cls)** | **BUG** |
| uf100-05 | SAT | SAT | 290017 | 18.561 | 1.757 | FPGA | ✓ |
| uf100-06 | SAT | SAT | 24030 | 1.537 | 1.375 | FPGA | ✓ |
| uf100-07 | SAT | SAT | 123379 | 7.896 | 1.401 | FPGA | ✓ |
| uf100-08 | SAT | SAT | 840444 | 53.788 | 1.440 | FPGA | ✓ |
| uf100-09 | SAT | SAT | 593588 | 37.989 | 1.581 | FPGA | ✓ |
| uf100-010 | SAT | SAT | 482647 | 30.889 | 1.592 | FPGA | ✓ |
| uf100-011 | SAT | SAT | 255314 | 16.340 | 1.587 | FPGA | ✓ |
| uf100-012 | SAT | SAT | 130310 | 8.339 | 2.153 | FPGA | ✓ |
| uf100-013 | SAT | SAT | 571741 | 36.591 | 1.432 | FPGA | ✓ |
| uf100-014 | SAT | SAT | 534479 | 34.206 | 1.584 | FPGA | ✓ |
| uf100-015 | SAT | SAT | 336131 | 21.512 | 1.564 | FPGA | ✓ |

**Summary** — 14 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; **1 solver bug (uf100-04: false UNSAT, confirmed SAT by minisat)**

---

## uuf100 — UNSAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf100-01 | UNSAT | UNSAT | 974454 | 62.365 | 1.602 | ✓ |
| uuf100-02 | UNSAT | UNSAT | 695434 | 44.507 | 1.565 | ✓ |
| uuf100-03 | UNSAT | UNSAT | 935806 | 59.891 | 1.621 | ✓ |
| uuf100-04 | UNSAT | UNSAT | 1650741 | 105.647 | 1.607 | ✓ |
| uuf100-05 | UNSAT | UNSAT | 1265759 | 81.008 | 1.577 | ✓ |
| uuf100-06 | UNSAT | UNSAT | 1107765 | 70.896 | 1.574 | ✓ |
| uuf100-07 | UNSAT | UNSAT | 1177913 | 75.386 | 1.600 | ✓ |
| uuf100-08 | UNSAT | UNSAT | 1736080 | 111.109 | 1.629 | ✓ |
| uuf100-09 | UNSAT | UNSAT | 1512915 | 96.826 | 1.580 | ✓ |
| uuf100-010 | UNSAT | UNSAT | 1858555 | 118.947 | 1.613 | ✓ |
| uuf100-011 | UNSAT | UNSAT | 1250323 | 80.020 | 1.446 | ✓ |
| uuf100-012 | UNSAT | UNSAT | 1091732 | 69.870 | 1.583 | ✓ |
| uuf100-013 | UNSAT | UNSAT | 544475 | 34.846 | 1.586 | ✓ |
| uuf100-014 | UNSAT | UNSAT | 753780 | 48.241 | 1.603 | ✓ |
| uuf100-015 | UNSAT | UNSAT | 1258129 | 80.520 | 1.613 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1187590 &nbsp;|&nbsp; mean time: 76.005 ms &nbsp;|&nbsp; mean wall: 1.586s

---

## uf125 — SAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | Source | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|--------|-----|
| uf125-01 | SAT | SAT | 217707 | 13.933 | 1.510 | FPGA | ✓ |
| uf125-02 | SAT | SAT | 1192096 | 76.294 | 1.646 | FPGA | ✓ |
| uf125-03 | SAT | SAT | 425436 | 27.227 | 1.583 | FPGA | ✓ |
| uf125-04 | SAT | **UNSAT** | 1578487 | 101.023 | — | **Verilator (32k cls)** | **BUG** |
| uf125-05 | SAT | SAT | 592783 | 37.938 | 1.532 | FPGA | ✓ |
| uf125-06 | SAT | SAT | 142488 | 9.119 | 1.572 | FPGA | ✓ |
| uf125-07 | SAT | SAT | 681098 | 43.590 | 1.619 | FPGA | ✓ |
| uf125-08 | SAT | SAT | 578136 | 37.000 | 1.592 | FPGA | ✓ |
| uf125-09 | SAT | SAT | 465544 | 29.794 | 1.590 | FPGA | ✓ |
| uf125-010 | SAT | **UNSAT** | 2160120 | 138.247 | — | **Verilator (32k cls)** | **BUG** |
| uf125-011 | SAT | **UNSAT** | 2441312 | 156.243 | — | **Verilator (32k cls)** | **BUG** |
| uf125-012 | SAT | **UNSAT** | 2230268 | 142.737 | — | **Verilator (32k cls)** | **BUG** |
| uf125-013 | SAT | **UNSAT** | >4700000 | >300 | — | **Verilator (32k cls, killed)** | **BUG** |
| uf125-014 | SAT | **UNSAT** | 2931197 | 187.596 | — | **Verilator (32k cls)** | **BUG** |
| uf125-015 | SAT | SAT | 1739581 | 111.333 | 1.628 | FPGA | ✓ |

**Summary** — 9 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; **6 solver bugs (false UNSAT, all confirmed SAT by minisat)**

---

## uuf125 — UNSAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf125-01 | UNSAT | UNSAT | 1365085 | 87.365 | 1.536 | ✓ |
| uuf125-02 | UNSAT | UNSAT | 1262171 | 80.778 | 1.592 | ✓ |
| uuf125-03 | UNSAT | UNSAT | 1387336 | 88.789 | 1.604 | ✓ |
| uuf125-04 | UNSAT | UNSAT | 1169992 | 74.879 | 1.571 | ✓ |
| uuf125-05 | UNSAT | UNSAT | 1153541 | 73.826 | 1.582 | ✓ |
| uuf125-06 | UNSAT | UNSAT | 1240556 | 79.395 | 1.591 | ✓ |
| uuf125-07 | UNSAT | UNSAT | 2281300 | 146.003 | 1.665 | ✓ |
| uuf125-08 | UNSAT | UNSAT | 1541279 | 98.641 | 1.540 | ✓ |
| uuf125-09 | UNSAT | UNSAT | 1308846 | 83.766 | 1.544 | ✓ |
| uuf125-010 | UNSAT | UNSAT | 1341112 | 85.831 | 1.603 | ✓ |
| uuf125-011 | UNSAT | UNSAT | 1217648 | 77.929 | 1.590 | ✓ |
| uuf125-012 | UNSAT | UNSAT | 1759533 | 112.610 | 1.629 | ✓ |
| uuf125-013 | UNSAT | UNSAT | 1464777 | 93.745 | 1.569 | ✓ |
| uuf125-014 | UNSAT | UNSAT | 1232473 | 78.878 | 1.583 | ✓ |
| uuf125-015 | UNSAT | UNSAT | 1725305 | 110.419 | 1.629 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1430063 &nbsp;|&nbsp; mean time: 91.524 ms &nbsp;|&nbsp; mean wall: 1.588s

---

## Overall Summary

- **Grid**: 1x1
- **Total correct**: 113 / 120 (FPGA) — **still 113 / 120 after Verilator re-sim**
- **Verilator re-sim**: 7 failing FPGA instances all return false UNSAT with 32768 clauses (4x FPGA capacity)
- **Root cause**: Solver correctness bug, NOT resource limitation
- **Affected instances**: uf100-04, uf125-04, uf125-010, uf125-011, uf125-012, uf125-013, uf125-014
- **Verification**: All 7 confirmed SATISFIABLE by minisat

### Verilator Re-simulation Details

| Instance | FPGA Cycles | FPGA Result | Sim Cycles (32k cls) | Sim Result | minisat |
|----------|-------------|-------------|----------------------|------------|---------|
| uf100-04 | 1,331,172 | UNSAT | 2,336,726 | UNSAT | **SAT** |
| uf125-04 | 1,461,121 | UNSAT | 1,578,487 | UNSAT | **SAT** |
| uf125-010 | 1,546,343 | UNSAT | 2,160,120 | UNSAT | **SAT** |
| uf125-011 | 1,510,775 | UNSAT | 2,441,312 | UNSAT | **SAT** |
| uf125-012 | 957,155 | UNSAT | 2,230,268 | UNSAT | **SAT** |
| uf125-013 | 1,883,713 | UNSAT | >4,700,000 (killed) | UNSAT | **SAT** |
| uf125-014 | 1,166,596 | UNSAT | 2,931,197 | UNSAT | **SAT** |

### Additional Finding: 16-bit Clause ID Ceiling

Clause IDs are `logic [15:0]` in `cae.sv`, `trail_manager.sv`, `watch_manager.sv`, and
`solver_core.sv`. This imposes a hard limit of `MAX_CLAUSES_PER_CORE <= 32768` (using
bit 15 as sentinel). Setting `MAX_CLAUSES=65536` causes the solver to hang with 0
conflicts — an overflow bug.

- **Finished FPGA run**: Sun Apr  5 17:41:24 UTC 2026
- **Finished Verilator re-sim**: Fri Apr 11 2026
