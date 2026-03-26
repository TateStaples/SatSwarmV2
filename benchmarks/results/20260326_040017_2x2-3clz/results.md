# SatSwarm Benchmark Results

- **Grid config**: 2x2-3clz
- **Run timestamp**: 20260326_040017
- **Instances per dataset**: 15
- **FPGA slot**: 0
- **Host binary**: /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 34761 | 2.224 | 2.590 | ✓ |
| uf50-02 | SAT | SAT | 14024 | .897 | 1.392 | ✓ |
| uf50-03 | SAT | SAT | 6896 | .441 | 1.402 | ✓ |
| uf50-04 | SAT | SAT | 18374 | 1.175 | 1.396 | ✓ |
| uf50-05 | SAT | SAT | 7646 | .489 | 1.397 | ✓ |
| uf50-06 | SAT | SAT | 17825 | 1.140 | 1.394 | ✓ |
| uf50-07 | SAT | SAT | 24927 | 1.595 | 1.397 | ✓ |
| uf50-08 | SAT | SAT | 18100 | 1.158 | 1.397 | ✓ |
| uf50-09 | SAT | SAT | 14966 | .957 | 1.499 | ✓ |
| uf50-010 | SAT | SAT | 20020 | 1.281 | 1.400 | ✓ |
| uf50-011 | SAT | SAT | 23098 | 1.478 | 1.393 | ✓ |
| uf50-012 | SAT | SAT | 10606 | .678 | 1.394 | ✓ |
| uf50-013 | SAT | SAT | 6665 | .426 | 1.399 | ✓ |
| uf50-014 | SAT | SAT | 17349 | 1.110 | 1.400 | ✓ |
| uf50-015 | SAT | SAT | 8031 | .513 | 1.388 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 16219 &nbsp;|&nbsp; mean time: 1.038 ms &nbsp;|&nbsp; mean wall: 1.482s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 52493 | 3.359 | 2.397 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 43098 | 2.758 | 1.400 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 22909 | 1.466 | 1.388 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 46045 | 2.946 | 1.396 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 50421 | 3.226 | 1.396 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 58434 | 3.739 | 1.395 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 56015 | 3.584 | 1.393 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 49800 | 3.187 | 1.424 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 71346 | 4.566 | 1.507 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 30106 | 1.926 | 1.392 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 64764 | 4.144 | 1.409 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 61380 | 3.928 | 1.394 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 34013 | 2.176 | 1.402 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 53296 | 3.410 | 1.389 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 43108 | 2.758 | 1.396 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 49148 &nbsp;|&nbsp; mean time: 3.145 ms &nbsp;|&nbsp; mean wall: 1.471s

---

## uf75 — SAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf75-01 | SAT | SAT | 5718 | .365 | 2.290 | ✓ |
| uf75-02 | SAT | SAT | 22117 | 1.415 | 1.390 | ✓ |
| uf75-03 | SAT | UNSAT | 143366 | 9.175 | 1.410 | ✗ |
| uf75-04 | SAT | SAT | 53641 | 3.433 | 1.392 | ✓ |
| uf75-05 | SAT | UNSAT | 106280 | 6.801 | 1.396 | ✗ |
| uf75-06 | SAT | UNSAT | 164013 | 10.496 | 1.406 | ✗ |
| uf75-07 | SAT | SAT | 12975 | .830 | 1.389 | ✓ |
| uf75-08 | SAT | SAT | 97406 | 6.233 | 1.419 | ✓ |
| uf75-09 | SAT | SAT | 34708 | 2.221 | 1.513 | ✓ |
| uf75-010 | SAT | SAT | 35408 | 2.266 | 1.398 | ✓ |
| uf75-011 | SAT | SAT | 138094 | 8.838 | 1.394 | ✓ |
| uf75-012 | SAT | SAT | 37037 | 2.370 | 1.390 | ✓ |
| uf75-013 | SAT | SAT | 28903 | 1.849 | 1.397 | ✓ |
| uf75-014 | SAT | SAT | 12258 | .784 | 1.393 | ✓ |
| uf75-015 | SAT | SAT | 25487 | 1.631 | 1.402 | ✓ |

**Summary** — 12 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 61160 &nbsp;|&nbsp; mean time: 3.914 ms &nbsp;|&nbsp; mean wall: 1.465s

---

## uuf75 — UNSAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf75-01 | UNSAT | UNSAT | 167407 | 10.714 | 1.384 | ✓ |
| uuf75-02 | UNSAT | UNSAT | 149247 | 9.551 | 1.518 | ✓ |
| uuf75-03 | UNSAT | UNSAT | 202346 | 12.950 | 1.398 | ✓ |
| uuf75-04 | UNSAT | UNSAT | 209498 | 13.407 | 1.401 | ✓ |
| uuf75-05 | UNSAT | UNSAT | 212188 | 13.580 | 1.399 | ✓ |
| uuf75-06 | UNSAT | UNSAT | 121682 | 7.787 | 1.389 | ✓ |
| uuf75-07 | UNSAT | UNSAT | 113715 | 7.277 | 1.406 | ✓ |
| uuf75-08 | UNSAT | UNSAT | 91787 | 5.874 | 1.392 | ✓ |
| uuf75-09 | UNSAT | UNSAT | 90270 | 5.777 | 2.129 | ✓ |
| uuf75-010 | UNSAT | UNSAT | 104187 | 6.667 | 1.396 | ✓ |
| uuf75-011 | UNSAT | UNSAT | 209812 | 13.427 | 1.400 | ✓ |
| uuf75-012 | UNSAT | UNSAT | 210066 | 13.444 | 1.393 | ✓ |
| uuf75-013 | UNSAT | UNSAT | 175746 | 11.247 | 1.403 | ✓ |
| uuf75-014 | UNSAT | UNSAT | 131539 | 8.418 | 1.387 | ✓ |
| uuf75-015 | UNSAT | UNSAT | 147639 | 9.448 | 1.398 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 155808 &nbsp;|&nbsp; mean time: 9.971 ms &nbsp;|&nbsp; mean wall: 1.452s

---

## uf100 — SAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf100-01 | SAT | UNSAT | 190648 | 12.201 | 1.374 | ✗ |
| uf100-02 | SAT | SAT | 7570 | .484 | 1.536 | ✓ |
| uf100-03 | SAT | SAT | 18339 | 1.173 | 1.394 | ✓ |
| uf100-04 | SAT | SAT | 22743 | 1.455 | 1.405 | ✓ |
| uf100-05 | SAT | SAT | 8656 | .553 | 1.391 | ✓ |
| uf100-06 | SAT | SAT | 8842 | .565 | 1.391 | ✓ |
| uf100-07 | SAT | SAT | 31006 | 1.984 | 1.405 | ✓ |
| uf100-08 | SAT | SAT | 118528 | 7.585 | 1.397 | ✓ |
| uf100-09 | SAT | SAT | 187688 | 12.012 | 2.199 | ✓ |
| uf100-010 | SAT | SAT | 23480 | 1.502 | 1.380 | ✓ |
| uf100-011 | SAT | SAT | 16150 | 1.033 | 1.400 | ✓ |
| uf100-012 | SAT | SAT | 45821 | 2.932 | 1.390 | ✓ |
| uf100-013 | SAT | SAT | 20172 | 1.291 | 1.395 | ✓ |
| uf100-014 | SAT | SAT | 12667 | .810 | 1.399 | ✓ |
| uf100-015 | SAT | UNSAT | 542235 | 34.703 | 1.425 | ✗ |

**Summary** — 13 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 83636 &nbsp;|&nbsp; mean time: 5.352 ms &nbsp;|&nbsp; mean wall: 1.458s

---

## uuf100 — UNSAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf100-01 | UNSAT | SAT | 124168 | 7.946 | 1.552 | ✗ |
| uuf100-02 | UNSAT | SAT | 163071 | 10.436 | 1.445 | ✗ |
| uuf100-03 | UNSAT | SAT | 166110 | 10.631 | 1.400 | ✗ |
| uuf100-04 | UNSAT | SAT | 78804 | 5.043 | 1.388 | ✗ |
| uuf100-05 | UNSAT | SAT | 162038 | 10.370 | 1.409 | ✗ |
| uuf100-06 | UNSAT | UNSAT | 135341 | 8.661 | 1.392 | ✓ |
| uuf100-07 | UNSAT | SAT | 105724 | 6.766 | 1.394 | ✗ |
| uuf100-08 | UNSAT | SAT | 77662 | 4.970 | 1.398 | ✗ |
| uuf100-09 | UNSAT | UNSAT | 455419 | 29.146 | 2.169 | ✓ |
| uuf100-010 | UNSAT | SAT | 217661 | 13.930 | 1.384 | ✗ |
| uuf100-011 | UNSAT | SAT | 25173 | 1.611 | 1.385 | ✗ |
| uuf100-012 | UNSAT | SAT | 247058 | 15.811 | 1.404 | ✗ |
| uuf100-013 | UNSAT | SAT | 276293 | 17.682 | 1.392 | ✗ |
| uuf100-014 | UNSAT | SAT | 36236 | 2.319 | 1.385 | ✗ |
| uuf100-015 | UNSAT | SAT | 119938 | 7.676 | 1.400 | ✗ |

**Summary** — 2 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 159379 &nbsp;|&nbsp; mean time: 10.200 ms &nbsp;|&nbsp; mean wall: 1.459s

---

## uf125 — SAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf125-01 | SAT | SAT | 17767 | 1.137 | 1.373 | ✓ |
| uf125-02 | SAT | UNSAT | 1019082 | 65.221 | 1.572 | ✗ |
| uf125-03 | SAT | UNSAT | 1014798 | 64.947 | 1.597 | ✗ |
| uf125-04 | SAT | SAT | 1014901 | 64.953 | 1.596 | ✓ |
| uf125-05 | SAT | SAT | 21009 | 1.344 | 1.537 | ✓ |
| uf125-06 | SAT | SAT | 18517 | 1.185 | 1.397 | ✓ |
| uf125-07 | SAT | UNSAT | 1014290 | 64.914 | 1.458 | ✗ |
| uf125-08 | SAT | UNSAT | 4798 | .307 | 1.536 | ✗ |
| uf125-09 | SAT | SAT | 8995 | .575 | 1.722 | ✓ |
| uf125-010 | SAT | UNSAT | 4027959 | 257.789 | 1.657 | ✗ |
| uf125-011 | SAT | SAT | 10547 | .675 | 1.540 | ✓ |
| uf125-012 | SAT | SAT | 20560 | 1.315 | 1.398 | ✓ |
| uf125-013 | SAT | UNSAT | 1010257 | 64.656 | 1.465 | ✗ |
| uf125-014 | SAT | UNSAT | 12896 | .825 | 1.543 | ✗ |
| uf125-015 | SAT | UNSAT | 1006788 | 64.434 | 1.459 | ✗ |

**Summary** — 7 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 681544 &nbsp;|&nbsp; mean time: 43.618 ms &nbsp;|&nbsp; mean wall: 1.523s

---

