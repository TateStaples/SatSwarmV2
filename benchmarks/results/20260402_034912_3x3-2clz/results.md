# SatSwarm Benchmark Results

- **Grid config**: 3x3-2clz
- **Run timestamp**: 20260402_034912
- **Instances per dataset**: 15
- **FPGA slot**: 0
- **Host binary**: /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 12154 | .777 | 1.419 | ✓ |
| uf50-02 | SAT | SAT | 15632 | 1.000 | 1.393 | ✓ |
| uf50-03 | SAT | SAT | 6856 | .438 | 1.392 | ✓ |
| uf50-04 | SAT | SAT | 19953 | 1.276 | 1.392 | ✓ |
| uf50-05 | SAT | SAT | 5051 | .323 | 1.514 | ✓ |
| uf50-06 | SAT | SAT | 19402 | 1.241 | 1.386 | ✓ |
| uf50-07 | SAT | SAT | 5403 | .345 | 1.390 | ✓ |
| uf50-08 | SAT | SAT | 4655 | .297 | 1.388 | ✓ |
| uf50-09 | SAT | SAT | 4481 | .286 | 1.402 | ✓ |
| uf50-010 | SAT | SAT | 7606 | .486 | 1.386 | ✓ |
| uf50-011 | SAT | SAT | 21855 | 1.398 | 1.410 | ✓ |
| uf50-012 | SAT | SAT | 9441 | .604 | 2.005 | ✓ |
| uf50-013 | SAT | SAT | 8309 | .531 | 1.396 | ✓ |
| uf50-014 | SAT | SAT | 19054 | 1.219 | 1.393 | ✓ |
| uf50-015 | SAT | SAT | 4552 | .291 | 1.389 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 10960 &nbsp;|&nbsp; mean time: .701 ms &nbsp;|&nbsp; mean wall: 1.443s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 49450 | 3.164 | 1.371 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 44614 | 2.855 | 1.397 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 24471 | 1.566 | 1.395 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 47806 | 3.059 | 1.424 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 37875 | 2.424 | 1.498 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 53896 | 3.449 | 1.385 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 48095 | 3.078 | 1.393 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 37835 | 2.421 | 1.395 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 46096 | 2.950 | 1.389 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 31767 | 2.033 | 1.394 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 38152 | 2.441 | 1.392 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 58171 | 3.722 | 1.395 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 35734 | 2.286 | 2.294 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 42746 | 2.735 | 1.391 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 44805 | 2.867 | 1.399 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 42767 &nbsp;|&nbsp; mean time: 2.737 ms &nbsp;|&nbsp; mean wall: 1.460s

---

## uf75 — SAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf75-01 | SAT | SAT | 7452 | .476 | 1.569 | ✓ |
| uf75-02 | SAT | SAT | 19308 | 1.235 | 1.396 | ✓ |
| uf75-03 | SAT | SAT | 31207 | 1.997 | 1.394 | ✓ |
| uf75-04 | SAT | SAT | 39642 | 2.537 | 1.388 | ✓ |
| uf75-05 | SAT | SAT | 29649 | 1.897 | 1.406 | ✓ |
| uf75-06 | SAT | SAT | 31894 | 2.041 | 1.466 | ✓ |
| uf75-07 | SAT | SAT | 14453 | .924 | 1.385 | ✓ |
| uf75-08 | SAT | SAT | 50326 | 3.220 | 1.382 | ✓ |
| uf75-09 | SAT | SAT | 15378 | .984 | 1.392 | ✓ |
| uf75-010 | SAT | SAT | 18836 | 1.205 | 1.390 | ✓ |
| uf75-011 | SAT | SAT | 57213 | 3.661 | 1.387 | ✓ |
| uf75-012 | SAT | SAT | 32916 | 2.106 | 1.391 | ✓ |
| uf75-013 | SAT | SAT | 12442 | .796 | 2.174 | ✓ |
| uf75-014 | SAT | SAT | 13810 | .883 | 1.386 | ✓ |
| uf75-015 | SAT | SAT | 24663 | 1.578 | 1.398 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 26612 &nbsp;|&nbsp; mean time: 1.703 ms &nbsp;|&nbsp; mean wall: 1.460s

---

## uuf75 — UNSAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf75-01 | UNSAT | UNSAT | 131618 | 8.423 | 1.574 | ✓ |
| uuf75-02 | UNSAT | UNSAT | 145669 | 9.322 | 1.385 | ✓ |
| uuf75-03 | UNSAT | UNSAT | 159086 | 10.181 | 1.391 | ✓ |
| uuf75-04 | UNSAT | UNSAT | 199424 | 12.763 | 1.392 | ✓ |
| uuf75-05 | UNSAT | UNSAT | 239073 | 15.300 | 1.393 | ✓ |
| uuf75-06 | UNSAT | UNSAT | 186371 | 11.927 | 1.437 | ✓ |
| uuf75-07 | UNSAT | UNSAT | 114435 | 7.323 | 1.389 | ✓ |
| uuf75-08 | UNSAT | UNSAT | 268465 | 17.181 | 1.398 | ✓ |
| uuf75-09 | UNSAT | UNSAT | 115094 | 7.366 | 1.384 | ✓ |
| uuf75-010 | UNSAT | UNSAT | 229490 | 14.687 | 1.394 | ✓ |
| uuf75-011 | UNSAT | UNSAT | 213178 | 13.643 | 1.392 | ✓ |
| uuf75-012 | UNSAT | UNSAT | 255516 | 16.353 | 1.397 | ✓ |
| uuf75-013 | UNSAT | UNSAT | 229421 | 14.682 | 2.250 | ✓ |
| uuf75-014 | UNSAT | UNSAT | 315546 | 20.194 | 1.417 | ✓ |
| uuf75-015 | UNSAT | UNSAT | 153930 | 9.851 | 1.383 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 197087 &nbsp;|&nbsp; mean time: 12.613 ms &nbsp;|&nbsp; mean wall: 1.465s

---

## uf100 — SAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf100-01 | SAT | SAT | 80600 | 5.158 | 1.569 | ✓ |
| uf100-02 | SAT | SAT | 61642 | 3.945 | 1.387 | ✓ |
| uf100-03 | SAT | SAT | 133765 | 8.560 | 1.396 | ✓ |
| uf100-04 | SAT | SAT | 131712 | 8.429 | 1.389 | ✓ |
| uf100-05 | SAT | SAT | 66950 | 4.284 | 1.383 | ✓ |
| uf100-06 | SAT | SAT | 9531 | .609 | 1.539 | ✓ |
| uf100-07 | SAT | SAT | 31150 | 1.993 | 1.400 | ✓ |
| uf100-08 | SAT | SAT | 258955 | 16.573 | 1.411 | ✓ |
| uf100-09 | SAT | SAT | 47031 | 3.009 | 1.376 | ✓ |
| uf100-010 | SAT | SAT | 15394 | .985 | 1.383 | ✓ |
| uf100-011 | SAT | SAT | 159633 | 10.216 | 1.395 | ✓ |
| uf100-012 | SAT | SAT | 46869 | 2.999 | 1.384 | ✓ |
| uf100-013 | SAT | SAT | 113913 | 7.290 | 2.029 | ✓ |
| uf100-014 | SAT | SAT | 163895 | 10.489 | 1.394 | ✓ |
| uf100-015 | SAT | SAT | 725226 | 46.414 | 1.429 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 136417 &nbsp;|&nbsp; mean time: 8.730 ms &nbsp;|&nbsp; mean wall: 1.457s

---

## uuf100 — UNSAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf100-01 | UNSAT | UNSAT | 575406 | 36.825 | 1.552 | ✓ |
| uuf100-02 | UNSAT | UNSAT | 1221885 | 78.200 | 1.630 | ✓ |
| uuf100-03 | UNSAT | UNSAT | 817000 | 52.288 | 1.583 | ✓ |
| uuf100-04 | UNSAT | UNSAT | 1310367 | 83.863 | 1.619 | ✓ |
| uuf100-05 | UNSAT | UNSAT | 746901 | 47.801 | 1.703 | ✓ |
| uuf100-06 | UNSAT | UNSAT | 882019 | 56.449 | 1.604 | ✓ |
| uuf100-07 | UNSAT | UNSAT | 777125 | 49.736 | 1.589 | ✓ |
| uuf100-08 | UNSAT | UNSAT | 639009 | 40.896 | 1.579 | ✓ |
| uuf100-09 | UNSAT | UNSAT | 972334 | 62.229 | 1.614 | ✓ |
| uuf100-010 | UNSAT | UNSAT | 749729 | 47.982 | 1.576 | ✓ |
| uuf100-011 | UNSAT | UNSAT | 1272930 | 81.467 | 1.630 | ✓ |
| uuf100-012 | UNSAT | UNSAT | 555066 | 35.524 | 1.456 | ✓ |
| uuf100-013 | UNSAT | UNSAT | 678819 | 43.444 | 1.601 | ✓ |
| uuf100-014 | UNSAT | UNSAT | 540025 | 34.561 | 1.582 | ✓ |
| uuf100-015 | UNSAT | UNSAT | 1079552 | 69.091 | 1.626 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 854544 &nbsp;|&nbsp; mean time: 54.690 ms &nbsp;|&nbsp; mean wall: 1.596s

---

## uf125 — SAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf125-01 | SAT | SAT | 245177 | 15.691 | 1.509 | ✓ |
| uf125-02 | SAT | SAT | 328321 | 21.012 | 1.396 | ✓ |
| uf125-03 | SAT | SAT | 74616 | 4.775 | 1.369 | ✓ |
| uf125-04 | SAT | SAT | 331507 | 21.216 | 1.774 | ✓ |
| uf125-05 | SAT | SAT | 419330 | 26.837 | 1.590 | ✓ |
| uf125-06 | SAT | SAT | 120754 | 7.728 | 1.578 | ✓ |
| uf125-07 | SAT | SAT | 344276 | 22.033 | 1.405 | ✓ |
| uf125-08 | SAT | SAT | 989267 | 63.313 | 1.444 | ✓ |
| uf125-09 | SAT | SAT | 413868 | 26.487 | 1.558 | ✓ |
| uf125-010 | SAT | SAT | 339436 | 21.723 | 1.586 | ✓ |
| uf125-011 | SAT | SAT | 393940 | 25.212 | 1.723 | ✓ |
| uf125-012 | SAT | SAT | 347607 | 22.246 | 1.392 | ✓ |
| uf125-013 | SAT | SAT | 652882 | 41.784 | 1.414 | ✓ |
| uf125-014 | SAT | UNSAT | 1066968 | 68.285 | 1.632 | ✗ |
| uf125-015 | SAT | SAT | 651470 | 41.694 | 1.557 | ✓ |

**Summary** — 14 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 447961 &nbsp;|&nbsp; mean time: 28.669 ms &nbsp;|&nbsp; mean wall: 1.528s

---

## uuf125 — UNSAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf125-01 | UNSAT | UNSAT | 1114812 | 71.347 | 1.622 | ✓ |
| uuf125-02 | UNSAT | UNSAT | 1339033 | 85.698 | 1.608 | ✓ |
| uuf125-03 | UNSAT | UNSAT | 1206384 | 77.208 | 1.826 | ✓ |
| uuf125-04 | UNSAT | UNSAT | 1233947 | 78.972 | 1.597 | ✓ |
| uuf125-05 | UNSAT | UNSAT | 1399040 | 89.538 | 1.603 | ✓ |
| uuf125-06 | UNSAT | UNSAT | 1274457 | 81.565 | 1.582 | ✓ |
| uuf125-07 | UNSAT | UNSAT | 1068790 | 68.402 | 1.572 | ✓ |
| uuf125-08 | UNSAT | UNSAT | 1297885 | 83.064 | 1.609 | ✓ |
| uuf125-09 | UNSAT | UNSAT | 1044124 | 66.823 | 1.579 | ✓ |
| uuf125-010 | UNSAT | UNSAT | 1026525 | 65.697 | 1.519 | ✓ |
| uuf125-011 | UNSAT | UNSAT | 1250319 | 80.020 | 1.613 | ✓ |
| uuf125-012 | UNSAT | UNSAT | 1312579 | 84.005 | 1.592 | ✓ |
| uuf125-013 | UNSAT | UNSAT | 1183092 | 75.717 | 1.572 | ✓ |
| uuf125-014 | UNSAT | UNSAT | 1261307 | 80.723 | 1.604 | ✓ |
| uuf125-015 | UNSAT | UNSAT | 1179141 | 75.465 | 1.588 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1212762 &nbsp;|&nbsp; mean time: 77.616 ms &nbsp;|&nbsp; mean wall: 1.605s

---

## Overall Summary

- **Grid**: 3x3-2clz
- **Total correct**: 119 / 120
- **Finished**: Thu Apr  2 03:52:16 UTC 2026
