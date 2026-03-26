# SatSwarm Smoke Test Results

- **Grid config**: 2x2-3clz
- **Run timestamp**: 20260326_035401
- **Instances per dataset**: 15
- **FPGA slot**: 0

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 34625 | 2.216 | 1.491 | ✓ |
| uf50-02 | SAT | SAT | 13944 | .892 | 1.386 | ✓ |
| uf50-03 | SAT | SAT | 7078 | .452 | 1.399 | ✓ |
| uf50-04 | SAT | SAT | 18335 | 1.173 | 1.393 | ✓ |
| uf50-05 | SAT | SAT | 7697 | .492 | 1.390 | ✓ |
| uf50-06 | SAT | SAT | 17826 | 1.140 | 1.393 | ✓ |
| uf50-07 | SAT | SAT | 25051 | 1.603 | 1.397 | ✓ |
| uf50-08 | SAT | SAT | 18121 | 1.159 | 1.402 | ✓ |
| uf50-09 | SAT | SAT | 15193 | .972 | 2.608 | ✓ |
| uf50-010 | SAT | SAT | 19998 | 1.279 | 1.395 | ✓ |
| uf50-011 | SAT | SAT | 23046 | 1.474 | 1.395 | ✓ |
| uf50-012 | SAT | SAT | 10531 | .673 | 1.393 | ✓ |
| uf50-013 | SAT | SAT | 6616 | .423 | 1.397 | ✓ |
| uf50-014 | SAT | SAT | 17430 | 1.115 | 1.390 | ✓ |
| uf50-015 | SAT | SAT | 8255 | .528 | 1.397 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 16249 &nbsp;|&nbsp; mean time: 1.039 ms &nbsp;|&nbsp; mean wall: 1.481s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 52421 | 3.354 | 1.380 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 42933 | 2.747 | 1.413 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 23151 | 1.481 | 1.395 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 46036 | 2.946 | 1.396 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 50414 | 3.226 | 1.392 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 58353 | 3.734 | 1.407 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 56039 | 3.586 | 1.390 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 49791 | 3.186 | 1.397 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 71425 | 4.571 | 1.394 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 30349 | 1.942 | 1.550 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 64523 | 4.129 | 1.404 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 61443 | 3.932 | 1.398 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 34019 | 2.177 | 1.394 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 53148 | 3.401 | 1.390 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 43332 | 2.773 | 1.393 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 49158 &nbsp;|&nbsp; mean time: 3.146 ms &nbsp;|&nbsp; mean wall: 1.406s

---

## Overall
- **Grid**: 2x2-3clz
- **Total correct**: 30 / 30
- **Finished**: Thu Mar 26 03:54:45 UTC 2026
