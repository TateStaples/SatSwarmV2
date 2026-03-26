# SatSwarm Benchmark Results

- **Grid config**: 1x1-none-maxlits8192
- **Run timestamp**: 20260326_145031
- **Instances per dataset**: 15
- **FPGA slot**: 0
- **Host binary**: /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 38465 | 2.461 | 1.376 | ✓ |
| uf50-02 | SAT | SAT | 30071 | 1.924 | 1.393 | ✓ |
| uf50-03 | SAT | SAT | 72601 | 4.646 | 1.397 | ✓ |
| uf50-04 | SAT | SAT | 67019 | 4.289 | 1.390 | ✓ |
| uf50-05 | SAT | SAT | 9213 | .589 | 1.389 | ✓ |
| uf50-06 | SAT | SAT | 41696 | 2.668 | 1.393 | ✓ |
| uf50-07 | SAT | SAT | 26669 | 1.706 | 1.401 | ✓ |
| uf50-08 | SAT | SAT | 65029 | 4.161 | 1.392 | ✓ |
| uf50-09 | SAT | SAT | 53394 | 3.417 | 1.388 | ✓ |
| uf50-010 | SAT | SAT | 21521 | 1.377 | 1.395 | ✓ |
| uf50-011 | SAT | SAT | 65624 | 4.199 | 1.395 | ✓ |
| uf50-012 | SAT | SAT | 42851 | 2.742 | 1.397 | ✓ |
| uf50-013 | SAT | SAT | 8166 | .522 | 1.385 | ✓ |
| uf50-014 | SAT | SAT | 18866 | 1.207 | 1.395 | ✓ |
| uf50-015 | SAT | SAT | 21196 | 1.356 | 2.180 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 38825 &nbsp;|&nbsp; mean time: 2.484 ms &nbsp;|&nbsp; mean wall: 1.444s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 54006 | 3.456 | 1.374 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 51336 | 3.285 | 1.386 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 53199 | 3.404 | 1.401 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 66911 | 4.282 | 1.401 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 58609 | 3.750 | 1.390 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 84800 | 5.427 | 1.401 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 92699 | 5.932 | 1.400 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 50668 | 3.242 | 1.574 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 88477 | 5.662 | 1.390 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 52022 | 3.329 | 1.388 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 95026 | 6.081 | 1.398 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 74703 | 4.780 | 1.388 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 53767 | 3.441 | 1.394 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 60519 | 3.873 | 1.394 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 56347 | 3.606 | 2.317 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 66205 &nbsp;|&nbsp; mean time: 4.237 ms &nbsp;|&nbsp; mean wall: 1.466s

---

## uf75 — SAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf75-01 | SAT | SAT | 255141 | 16.329 | 1.383 | ✓ |
| uf75-02 | SAT | SAT | 19219 | 1.230 | 1.377 | ✓ |
| uf75-03 | SAT | SAT | 42012 | 2.688 | 1.396 | ✓ |
| uf75-04 | SAT | SAT | 221396 | 14.169 | 1.399 | ✓ |
| uf75-05 | SAT | SAT | 136138 | 8.712 | 1.389 | ✓ |
| uf75-06 | SAT | SAT | 604960 | 38.717 | 1.430 | ✓ |
| uf75-07 | SAT | SAT | 576862 | 36.919 | 1.594 | ✓ |
| uf75-08 | SAT | SAT | 411039 | 26.306 | 1.504 | ✓ |
| uf75-09 | SAT | SAT | 132352 | 8.470 | 1.381 | ✓ |
| uf75-010 | SAT | SAT | 207166 | 13.258 | 1.390 | ✓ |
| uf75-011 | SAT | UNSAT | 457967 | 29.309 | 1.411 | ✗ |
| uf75-012 | SAT | UNSAT | 238198 | 15.244 | 1.383 | ✗ |
| uf75-013 | SAT | SAT | 42609 | 2.726 | 1.378 | ✓ |
| uf75-014 | SAT | SAT | 20409 | 1.306 | 1.397 | ✓ |
| uf75-015 | SAT | SAT | 255336 | 16.341 | 2.339 | ✓ |

**Summary** — 13 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 241386 &nbsp;|&nbsp; mean time: 15.448 ms &nbsp;|&nbsp; mean wall: 1.476s

---

## uuf75 — UNSAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf75-01 | UNSAT | UNSAT | 264427 | 16.923 | 1.577 | ✓ |
| uuf75-02 | UNSAT | UNSAT | 145805 | 9.331 | 1.385 | ✓ |
| uuf75-03 | UNSAT | UNSAT | 851497 | 54.495 | 1.432 | ✓ |
| uuf75-04 | UNSAT | UNSAT | 199327 | 12.756 | 1.566 | ✓ |
| uuf75-05 | UNSAT | UNSAT | 629919 | 40.314 | 1.592 | ✓ |
| uuf75-06 | UNSAT | UNSAT | 356225 | 22.798 | 1.585 | ✓ |
| uuf75-07 | UNSAT | UNSAT | 239159 | 15.306 | 2.020 | ✓ |
| uuf75-08 | UNSAT | UNSAT | 353918 | 22.650 | 1.391 | ✓ |
| uuf75-09 | UNSAT | UNSAT | 166304 | 10.643 | 1.388 | ✓ |
| uuf75-010 | UNSAT | UNSAT | 301670 | 19.306 | 1.399 | ✓ |
| uuf75-011 | UNSAT | UNSAT | 536651 | 34.345 | 1.407 | ✓ |
| uuf75-012 | UNSAT | UNSAT | 423679 | 27.115 | 1.580 | ✓ |
| uuf75-013 | UNSAT | UNSAT | 316890 | 20.280 | 1.578 | ✓ |
| uuf75-014 | UNSAT | UNSAT | 315631 | 20.200 | 2.248 | ✓ |
| uuf75-015 | UNSAT | UNSAT | 286557 | 18.339 | 1.388 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 359177 &nbsp;|&nbsp; mean time: 22.987 ms &nbsp;|&nbsp; mean wall: 1.569s

---

## uf100 — SAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf100-01 | SAT | SAT | 1193476 | 76.382 | 1.623 | ✓ |
| uf100-02 | SAT | SAT | 447468 | 28.637 | 1.544 | ✓ |
| uf100-03 | SAT | SAT | 531440 | 34.012 | 1.401 | ✓ |
| uf100-04 | SAT | SAT | 980696 | 62.764 | 1.613 | ✓ |
| uf100-05 | SAT | SAT | 149447 | 9.564 | 1.539 | ✓ |
| uf100-06 | SAT | SAT | 18013 | 1.152 | 1.690 | ✓ |
| uf100-07 | SAT | SAT | 193423 | 12.379 | 1.403 | ✓ |
| uf100-08 | SAT | UNSAT | 2313068 | 148.036 | 1.523 | ✗ |
| uf100-09 | SAT | SAT | 364922 | 23.355 | 1.474 | ✓ |
| uf100-010 | SAT | SAT | 168642 | 10.793 | 1.383 | ✓ |
| uf100-011 | SAT | SAT | 544028 | 34.817 | 1.410 | ✓ |
| uf100-012 | SAT | SAT | 275696 | 17.644 | 1.572 | ✓ |
| uf100-013 | SAT | UNSAT | 2821026 | 180.545 | 2.482 | ✗ |
| uf100-014 | SAT | SAT | 589755 | 37.744 | 1.459 | ✓ |
| uf100-015 | SAT | UNSAT | 1316517 | 84.257 | 1.643 | ✗ |

**Summary** — 12 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 793841 &nbsp;|&nbsp; mean time: 50.805 ms &nbsp;|&nbsp; mean wall: 1.583s

---

## uuf100 — UNSAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf100-01 | UNSAT | UNSAT | 2725772 | 174.449 | 1.650 | ✓ |
| uuf100-02 | UNSAT | UNSAT | 2692512 | 172.320 | 1.590 | ✓ |
| uuf100-03 | UNSAT | UNSAT | 1407727 | 90.094 | 1.514 | ✓ |
| uuf100-04 | UNSAT | UNSAT | 2984997 | 191.039 | 1.681 | ✓ |
| uuf100-05 | UNSAT | UNSAT | 1971730 | 126.190 | 1.613 | ✓ |
| uuf100-06 | UNSAT | UNSAT | 1041525 | 66.657 | 1.538 | ✓ |
| uuf100-07 | UNSAT | UNSAT | 2187774 | 140.017 | 1.655 | ✓ |
| uuf100-08 | UNSAT | UNSAT | 2692340 | 172.309 | 1.628 | ✓ |
| uuf100-09 | UNSAT | UNSAT | 972251 | 62.224 | 1.484 | ✓ |
| uuf100-010 | UNSAT | UNSAT | 1405540 | 89.954 | 1.611 | ✓ |
| uuf100-011 | UNSAT | UNSAT | 2476634 | 158.504 | 1.661 | ✓ |
| uuf100-012 | UNSAT | UNSAT | 1474625 | 94.376 | 1.594 | ✓ |
| uuf100-013 | UNSAT | UNSAT | 701389 | 44.888 | 1.538 | ✓ |
| uuf100-014 | UNSAT | UNSAT | 1052339 | 67.349 | 1.619 | ✓ |
| uuf100-015 | UNSAT | UNSAT | 1229231 | 78.670 | 1.607 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1801092 &nbsp;|&nbsp; mean time: 115.269 ms &nbsp;|&nbsp; mean wall: 1.598s

---

