# SatSwarm Benchmark Results

- **Grid config**: 2x2-2clz
- **Run timestamp**: 20260402_033940
- **Instances per dataset**: 15
- **FPGA slot**: 0
- **Host binary**: /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 36272 | 2.321 | 1.486 | ✓ |
| uf50-02 | SAT | SAT | 15625 | 1.000 | 1.393 | ✓ |
| uf50-03 | SAT | SAT | 8473 | .542 | 1.393 | ✓ |
| uf50-04 | SAT | SAT | 19892 | 1.273 | 1.391 | ✓ |
| uf50-05 | SAT | SAT | 9274 | .593 | 1.490 | ✓ |
| uf50-06 | SAT | SAT | 19468 | 1.245 | 1.387 | ✓ |
| uf50-07 | SAT | SAT | 26630 | 1.704 | 1.399 | ✓ |
| uf50-08 | SAT | SAT | 19745 | 1.263 | 1.391 | ✓ |
| uf50-09 | SAT | SAT | 16686 | 1.067 | 1.414 | ✓ |
| uf50-010 | SAT | SAT | 21752 | 1.392 | 1.415 | ✓ |
| uf50-011 | SAT | SAT | 24732 | 1.582 | 1.398 | ✓ |
| uf50-012 | SAT | SAT | 12221 | .782 | 1.926 | ✓ |
| uf50-013 | SAT | SAT | 8302 | .531 | 1.385 | ✓ |
| uf50-014 | SAT | SAT | 18989 | 1.215 | 1.395 | ✓ |
| uf50-015 | SAT | SAT | 9728 | .622 | 1.405 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 17852 &nbsp;|&nbsp; mean time: 1.142 ms &nbsp;|&nbsp; mean wall: 1.444s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 54201 | 3.468 | 1.566 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 44568 | 2.852 | 1.399 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 24440 | 1.564 | 1.387 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 47730 | 3.054 | 1.398 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 51885 | 3.320 | 1.474 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 59886 | 3.832 | 1.399 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 57541 | 3.682 | 1.385 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 50533 | 3.234 | 1.390 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 73454 | 4.701 | 1.395 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 31701 | 2.028 | 1.384 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 66410 | 4.250 | 1.394 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 63059 | 4.035 | 2.105 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 35694 | 2.284 | 1.387 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 54818 | 3.508 | 1.394 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 44740 | 2.863 | 1.391 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 50710 &nbsp;|&nbsp; mean time: 3.245 ms &nbsp;|&nbsp; mean wall: 1.456s

---

## uf75 — SAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf75-01 | SAT | SAT | 7433 | .475 | 1.563 | ✓ |
| uf75-02 | SAT | SAT | 19333 | 1.237 | 1.383 | ✓ |
| uf75-03 | SAT | SAT | 42063 | 2.692 | 1.393 | ✓ |
| uf75-04 | SAT | SAT | 221164 | 14.154 | 1.399 | ✓ |
| uf75-05 | SAT | SAT | 136049 | 8.707 | 1.510 | ✓ |
| uf75-06 | SAT | SAT | 88080 | 5.637 | 1.393 | ✓ |
| uf75-07 | SAT | SAT | 14358 | .918 | 1.378 | ✓ |
| uf75-08 | SAT | SAT | 50349 | 3.222 | 1.395 | ✓ |
| uf75-09 | SAT | SAT | 45206 | 2.893 | 1.390 | ✓ |
| uf75-010 | SAT | SAT | 30046 | 1.922 | 1.388 | ✓ |
| uf75-011 | SAT | SAT | 129177 | 8.267 | 1.395 | ✓ |
| uf75-012 | SAT | SAT | 32950 | 2.108 | 2.385 | ✓ |
| uf75-013 | SAT | SAT | 36118 | 2.311 | 1.388 | ✓ |
| uf75-014 | SAT | SAT | 13672 | .875 | 1.391 | ✓ |
| uf75-015 | SAT | SAT | 24761 | 1.584 | 1.393 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 59383 &nbsp;|&nbsp; mean time: 3.800 ms &nbsp;|&nbsp; mean wall: 1.476s

---

## uuf75 — UNSAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf75-01 | UNSAT | UNSAT | 131652 | 8.425 | 1.382 | ✓ |
| uuf75-02 | UNSAT | UNSAT | 145823 | 9.332 | 1.394 | ✓ |
| uuf75-03 | UNSAT | UNSAT | 208657 | 13.354 | 1.395 | ✓ |
| uuf75-04 | UNSAT | UNSAT | 199460 | 12.765 | 1.407 | ✓ |
| uuf75-05 | UNSAT | UNSAT | 238834 | 15.285 | 1.519 | ✓ |
| uuf75-06 | UNSAT | UNSAT | 351798 | 22.515 | 1.401 | ✓ |
| uuf75-07 | UNSAT | UNSAT | 114610 | 7.335 | 1.381 | ✓ |
| uuf75-08 | UNSAT | UNSAT | 315208 | 20.173 | 1.404 | ✓ |
| uuf75-09 | UNSAT | UNSAT | 166469 | 10.654 | 1.384 | ✓ |
| uuf75-010 | UNSAT | UNSAT | 229444 | 14.684 | 1.395 | ✓ |
| uuf75-011 | UNSAT | UNSAT | 266695 | 17.068 | 1.392 | ✓ |
| uuf75-012 | UNSAT | UNSAT | 288814 | 18.484 | 2.276 | ✓ |
| uuf75-013 | UNSAT | UNSAT | 253255 | 16.208 | 1.390 | ✓ |
| uuf75-014 | UNSAT | UNSAT | 315668 | 20.202 | 1.413 | ✓ |
| uuf75-015 | UNSAT | UNSAT | 263951 | 16.892 | 1.395 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 232689 &nbsp;|&nbsp; mean time: 14.892 ms &nbsp;|&nbsp; mean wall: 1.461s

---

## uf100 — SAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf100-01 | SAT | SAT | 80710 | 5.165 | 1.565 | ✓ |
| uf100-02 | SAT | SAT | 259984 | 16.638 | 1.408 | ✓ |
| uf100-03 | SAT | SAT | 133732 | 8.558 | 1.382 | ✓ |
| uf100-04 | SAT | SAT | 493479 | 31.582 | 1.415 | ✓ |
| uf100-05 | SAT | SAT | 149262 | 9.552 | 1.559 | ✓ |
| uf100-06 | SAT | SAT | 9781 | .625 | 1.382 | ✓ |
| uf100-07 | SAT | SAT | 42104 | 2.694 | 1.392 | ✓ |
| uf100-08 | SAT | SAT | 258890 | 16.568 | 1.405 | ✓ |
| uf100-09 | SAT | SAT | 364775 | 23.345 | 1.400 | ✓ |
| uf100-010 | SAT | SAT | 15522 | .993 | 1.367 | ✓ |
| uf100-011 | SAT | SAT | 234087 | 14.981 | 1.406 | ✓ |
| uf100-012 | SAT | SAT | 94981 | 6.078 | 1.904 | ✓ |
| uf100-013 | SAT | SAT | 113899 | 7.289 | 1.393 | ✓ |
| uf100-014 | SAT | SAT | 247753 | 15.856 | 1.400 | ✓ |
| uf100-015 | SAT | SAT | 860133 | 55.048 | 1.434 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 223939 &nbsp;|&nbsp; mean time: 14.332 ms &nbsp;|&nbsp; mean wall: 1.454s

---

## uuf100 — UNSAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf100-01 | UNSAT | UNSAT | 810756 | 51.888 | 1.560 | ✓ |
| uuf100-02 | UNSAT | UNSAT | 1493972 | 95.614 | 1.631 | ✓ |
| uuf100-03 | UNSAT | UNSAT | 816809 | 52.275 | 1.552 | ✓ |
| uuf100-04 | UNSAT | UNSAT | 1439738 | 92.143 | 2.107 | ✓ |
| uuf100-05 | UNSAT | UNSAT | 1318152 | 84.361 | 1.604 | ✓ |
| uuf100-06 | UNSAT | UNSAT | 882015 | 56.448 | 1.575 | ✓ |
| uuf100-07 | UNSAT | UNSAT | 777228 | 49.742 | 1.595 | ✓ |
| uuf100-08 | UNSAT | UNSAT | 821007 | 52.544 | 1.594 | ✓ |
| uuf100-09 | UNSAT | UNSAT | 972179 | 62.219 | 1.600 | ✓ |
| uuf100-010 | UNSAT | UNSAT | 749945 | 47.996 | 1.581 | ✓ |
| uuf100-011 | UNSAT | UNSAT | 1358993 | 86.975 | 1.561 | ✓ |
| uuf100-012 | UNSAT | UNSAT | 555119 | 35.527 | 1.548 | ✓ |
| uuf100-013 | UNSAT | UNSAT | 701223 | 44.878 | 1.608 | ✓ |
| uuf100-014 | UNSAT | UNSAT | 934222 | 59.790 | 1.607 | ✓ |
| uuf100-015 | UNSAT | UNSAT | 1079580 | 69.093 | 1.618 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 980729 &nbsp;|&nbsp; mean time: 62.766 ms &nbsp;|&nbsp; mean wall: 1.622s

---

## uf125 — SAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf125-01 | SAT | SAT | 245045 | 15.682 | 1.516 | ✓ |
| uf125-02 | SAT | UNSAT | 804151 | 51.465 | 1.428 | ✗ |
| uf125-03 | SAT | SAT | 74615 | 4.775 | 1.406 | ✓ |
| uf125-04 | SAT | SAT | 331325 | 21.204 | 1.416 | ✓ |
| uf125-05 | SAT | SAT | 593792 | 38.002 | 1.406 | ✓ |
| uf125-06 | SAT | SAT | 120711 | 7.725 | 1.562 | ✓ |
| uf125-07 | SAT | SAT | 627937 | 40.187 | 1.422 | ✓ |
| uf125-08 | SAT | UNSAT | 1141821 | 73.076 | 1.630 | ✗ |
| uf125-09 | SAT | UNSAT | 1391712 | 89.069 | 1.608 | ✗ |
| uf125-010 | SAT | UNSAT | 779554 | 49.891 | 1.998 | ✗ |
| uf125-011 | SAT | SAT | 1083436 | 69.339 | 1.613 | ✓ |
| uf125-012 | SAT | SAT | 458756 | 29.360 | 1.564 | ✓ |
| uf125-013 | SAT | SAT | 652734 | 41.774 | 1.633 | ✓ |
| uf125-014 | SAT | UNSAT | 1067220 | 68.302 | 1.599 | ✗ |
| uf125-015 | SAT | UNSAT | 1358079 | 86.917 | 1.615 | ✗ |

**Summary** — 9 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 715392 &nbsp;|&nbsp; mean time: 45.785 ms &nbsp;|&nbsp; mean wall: 1.561s

---

## uuf125 — UNSAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf125-01 | UNSAT | UNSAT | 1256585 | 80.421 | 1.567 | ✓ |
| uuf125-02 | UNSAT | UNSAT | 1339125 | 85.704 | 1.550 | ✓ |
| uuf125-03 | UNSAT | UNSAT | 1514527 | 96.929 | 1.602 | ✓ |
| uuf125-04 | UNSAT | UNSAT | 1234045 | 78.978 | 1.577 | ✓ |
| uuf125-05 | UNSAT | UNSAT | 1469009 | 94.016 | 1.611 | ✓ |
| uuf125-06 | UNSAT | UNSAT | 1274436 | 81.563 | 1.580 | ✓ |
| uuf125-07 | UNSAT | UNSAT | 1068703 | 68.396 | 1.578 | ✓ |
| uuf125-08 | UNSAT | UNSAT | 1698413 | 108.698 | 1.636 | ✓ |
| uuf125-09 | UNSAT | UNSAT | 1044079 | 66.821 | 1.492 | ✓ |
| uuf125-010 | UNSAT | UNSAT | 1098582 | 70.309 | 1.600 | ✓ |
| uuf125-011 | UNSAT | UNSAT | 1376080 | 88.069 | 1.610 | ✓ |
| uuf125-012 | UNSAT | UNSAT | 1312523 | 84.001 | 1.593 | ✓ |
| uuf125-013 | UNSAT | UNSAT | 1183217 | 75.725 | 1.591 | ✓ |
| uuf125-014 | UNSAT | UNSAT | 1481114 | 94.791 | 1.613 | ✓ |
| uuf125-015 | UNSAT | UNSAT | 1187390 | 75.992 | 1.578 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1302521 &nbsp;|&nbsp; mean time: 83.361 ms &nbsp;|&nbsp; mean wall: 1.585s

---

## Overall Summary

- **Grid**: 2x2-2clz
- **Total correct**: 114 / 120
- **Finished**: Thu Apr  2 03:42:44 UTC 2026
