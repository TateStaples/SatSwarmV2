# SatSwarm Benchmark Results

- **Grid config**: 2x2-none
- **Run timestamp**: 20260402_033615
- **Instances per dataset**: 15
- **FPGA slot**: 0
- **Host binary**: /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 34631 | 2.216 | 1.448 | ✓ |
| uf50-02 | SAT | SAT | 14128 | .904 | 1.402 | ✓ |
| uf50-03 | SAT | SAT | 7092 | .453 | 1.397 | ✓ |
| uf50-04 | SAT | SAT | 18487 | 1.183 | 1.393 | ✓ |
| uf50-05 | SAT | SAT | 7847 | .502 | 1.884 | ✓ |
| uf50-06 | SAT | SAT | 17968 | 1.149 | 1.389 | ✓ |
| uf50-07 | SAT | SAT | 25074 | 1.604 | 1.389 | ✓ |
| uf50-08 | SAT | SAT | 18115 | 1.159 | 1.398 | ✓ |
| uf50-09 | SAT | SAT | 15026 | .961 | 1.391 | ✓ |
| uf50-010 | SAT | SAT | 20053 | 1.283 | 1.391 | ✓ |
| uf50-011 | SAT | SAT | 23257 | 1.488 | 1.394 | ✓ |
| uf50-012 | SAT | SAT | 10684 | .683 | 1.387 | ✓ |
| uf50-013 | SAT | SAT | 6818 | .436 | 1.564 | ✓ |
| uf50-014 | SAT | SAT | 17336 | 1.109 | 1.394 | ✓ |
| uf50-015 | SAT | SAT | 8156 | .521 | 1.387 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 16311 &nbsp;|&nbsp; mean time: 1.043 ms &nbsp;|&nbsp; mean wall: 1.440s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 52492 | 3.359 | 1.373 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 43097 | 2.758 | 1.408 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 22936 | 1.467 | 1.400 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 46237 | 2.959 | 1.394 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 50569 | 3.236 | 2.220 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 59747 | 3.823 | 1.396 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 55842 | 3.573 | 1.390 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 48869 | 3.127 | 1.385 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 70674 | 4.523 | 1.406 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 30108 | 1.926 | 1.394 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 64591 | 4.133 | 1.403 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 61575 | 3.940 | 1.396 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 34105 | 2.182 | 1.496 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 53435 | 3.419 | 1.396 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 43158 | 2.762 | 1.391 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 49162 &nbsp;|&nbsp; mean time: 3.146 ms &nbsp;|&nbsp; mean wall: 1.456s

---

