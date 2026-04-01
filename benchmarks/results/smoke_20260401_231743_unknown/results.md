# SatSwarm Smoke Test Results

- **Grid config**: unknown
- **Run timestamp**: 20260401_231743
- **Instances per dataset**: 15
- **FPGA slot**: 0

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 36305 | 2.323 | 1.550 | ✓ |
| uf50-02 | SAT | SAT | 15681 | 1.003 | 1.395 | ✓ |
| uf50-03 | SAT | SAT | 8489 | .543 | 1.388 | ✓ |
| uf50-04 | SAT | SAT | 19957 | 1.277 | 1.394 | ✓ |
| uf50-05 | SAT | SAT | 9223 | .590 | 1.390 | ✓ |
| uf50-06 | SAT | SAT | 19406 | 1.241 | 1.416 | ✓ |
| uf50-07 | SAT | SAT | 26587 | 1.701 | 1.392 | ✓ |
| uf50-08 | SAT | SAT | 19807 | 1.267 | 1.398 | ✓ |
| uf50-09 | SAT | SAT | 16619 | 1.063 | 1.389 | ✓ |
| uf50-010 | SAT | SAT | 21545 | 1.378 | 1.393 | ✓ |
| uf50-011 | SAT | SAT | 24581 | 1.573 | 1.395 | ✓ |
| uf50-012 | SAT | SAT | 12094 | .774 | 1.388 | ✓ |
| uf50-013 | SAT | SAT | 8168 | .522 | 2.165 | ✓ |
| uf50-014 | SAT | SAT | 18927 | 1.211 | 1.389 | ✓ |
| uf50-015 | SAT | SAT | 9572 | .612 | 1.391 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 17797 &nbsp;|&nbsp; mean time: 1.139 ms &nbsp;|&nbsp; mean wall: 1.455s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 54091 | 3.461 | 1.373 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 44453 | 2.844 | 1.393 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 24472 | 1.566 | 1.389 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 47789 | 3.058 | 1.391 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 52106 | 3.334 | 1.392 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 59927 | 3.835 | 1.471 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 57472 | 3.678 | 1.392 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 50591 | 3.237 | 1.397 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 73362 | 4.695 | 1.392 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 31842 | 2.037 | 1.397 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 66275 | 4.241 | 1.392 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 63066 | 4.036 | 1.392 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 35526 | 2.273 | 1.391 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 54976 | 3.518 | 1.527 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 44801 | 2.867 | 1.389 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 50716 &nbsp;|&nbsp; mean time: 3.245 ms &nbsp;|&nbsp; mean wall: 1.405s

---

## Overall
- **Grid**: unknown
- **Total correct**: 30 / 30
- **Finished**: Wed Apr  1 23:18:26 UTC 2026
