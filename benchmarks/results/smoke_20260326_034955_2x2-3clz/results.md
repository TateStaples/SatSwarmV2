# SatSwarm Smoke Test Results

- **Grid config**: 2x2-3clz
- **Run timestamp**: 20260326_034955
- **Instances per dataset**: 15
- **FPGA slot**: 0

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | TIMEOUT | 34631 | 2.216 | 1.499 | T |
| uf50-02 | SAT | TIMEOUT | 13951 | .892 | 1.390 | T |
| uf50-03 | SAT | TIMEOUT | 6879 | .440 | 1.967 | T |
| uf50-04 | SAT | TIMEOUT | 18283 | 1.170 | 1.394 | T |
| uf50-05 | SAT | TIMEOUT | 7675 | .491 | 1.391 | T |
| uf50-06 | SAT | TIMEOUT | 18038 | 1.154 | 1.396 | T |
| uf50-07 | SAT | TIMEOUT | 25002 | 1.600 | 1.394 | T |
| uf50-08 | SAT | TIMEOUT | 18058 | 1.155 | 1.393 | T |
| uf50-09 | SAT | TIMEOUT | 14951 | .956 | 1.393 | T |
| uf50-010 | SAT | TIMEOUT | 20238 | 1.295 | 1.394 | T |
| uf50-011 | SAT | TIMEOUT | 23035 | 1.474 | 1.485 | T |
| uf50-012 | SAT | TIMEOUT | 10515 | .672 | 1.395 | T |
| uf50-013 | SAT | TIMEOUT | 6692 | .428 | 1.399 | T |
| uf50-014 | SAT | TIMEOUT | 17387 | 1.112 | 1.407 | T |
| uf50-015 | SAT | TIMEOUT | 8055 | .515 | 1.403 | T |

**Summary** — 0 / 15 correct &nbsp;|&nbsp; 15 timeouts &nbsp;|&nbsp; mean cycles: N/A &nbsp;|&nbsp; mean time: N/A ms &nbsp;|&nbsp; mean wall: 1.446s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | TIMEOUT | 52463 | 3.357 | 1.383 | T |
| uuf50-02 | UNSAT | TIMEOUT | 42938 | 2.748 | 1.396 | T |
| uuf50-03 | UNSAT | TIMEOUT | 22992 | 1.471 | 1.394 | T |
| uuf50-04 | UNSAT | TIMEOUT | 46066 | 2.948 | 1.517 | T |
| uuf50-05 | UNSAT | TIMEOUT | 50337 | 3.221 | 1.389 | T |
| uuf50-06 | UNSAT | TIMEOUT | 58423 | 3.739 | 1.394 | T |
| uuf50-07 | UNSAT | TIMEOUT | 55821 | 3.572 | 1.400 | T |
| uuf50-08 | UNSAT | TIMEOUT | 49790 | 3.186 | 1.387 | T |
| uuf50-09 | UNSAT | TIMEOUT | 71438 | 4.572 | 1.394 | T |
| uuf50-010 | UNSAT | TIMEOUT | 30128 | 1.928 | 1.394 | T |
| uuf50-011 | UNSAT | TIMEOUT | 64536 | 4.130 | 1.939 | T |
| uuf50-012 | UNSAT | TIMEOUT | 61416 | 3.930 | 1.400 | T |
| uuf50-013 | UNSAT | TIMEOUT | 34223 | 2.190 | 1.396 | T |
| uuf50-014 | UNSAT | TIMEOUT | 53081 | 3.397 | 1.392 | T |
| uuf50-015 | UNSAT | TIMEOUT | 43122 | 2.759 | 1.401 | T |

**Summary** — 0 / 15 correct &nbsp;|&nbsp; 15 timeouts &nbsp;|&nbsp; mean cycles: N/A &nbsp;|&nbsp; mean time: N/A ms &nbsp;|&nbsp; mean wall: 1.438s

---

## Overall
- **Grid**: 2x2-3clz
- **Total correct**: 0 / 30
- **Finished**: Thu Mar 26 03:50:39 UTC 2026
