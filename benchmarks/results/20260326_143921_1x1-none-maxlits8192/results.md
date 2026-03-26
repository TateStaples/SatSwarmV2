# SatSwarm Benchmark Results

- **Grid config**: 1x1-none-maxlits8192
- **Run timestamp**: 20260326_143921
- **Instances per dataset**: 15
- **FPGA slot**: 0
- **Host binary**: /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 38484 | 2.462 | 1.474 | ✓ |
| uf50-02 | SAT | SAT | 30069 | 1.924 | 1.397 | ✓ |
| uf50-03 | SAT | SAT | 72715 | 4.653 | 1.406 | ✓ |
| uf50-04 | SAT | SAT | 67025 | 4.289 | 1.406 | ✓ |
| uf50-05 | SAT | SAT | 9342 | .597 | 1.530 | ✓ |
| uf50-06 | SAT | SAT | 41576 | 2.660 | 1.398 | ✓ |
| uf50-07 | SAT | SAT | 26582 | 1.701 | 1.390 | ✓ |
| uf50-08 | SAT | SAT | 65147 | 4.169 | 1.394 | ✓ |
| uf50-09 | SAT | SAT | 53427 | 3.419 | 1.391 | ✓ |
| uf50-010 | SAT | SAT | 21718 | 1.389 | 1.387 | ✓ |
| uf50-011 | SAT | SAT | 65628 | 4.200 | 1.403 | ✓ |
| uf50-012 | SAT | SAT | 42858 | 2.742 | 2.094 | ✓ |
| uf50-013 | SAT | SAT | 8285 | .530 | 1.405 | ✓ |
| uf50-014 | SAT | SAT | 18984 | 1.214 | 1.401 | ✓ |
| uf50-015 | SAT | SAT | 21062 | 1.347 | 1.394 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 38860 &nbsp;|&nbsp; mean time: 2.487 ms &nbsp;|&nbsp; mean wall: 1.458s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 54061 | 3.459 | 1.565 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 51408 | 3.290 | 1.395 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 53250 | 3.408 | 1.384 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 67062 | 4.291 | 1.396 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 58698 | 3.756 | 1.497 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 84653 | 5.417 | 1.392 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 92825 | 5.940 | 1.412 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 50575 | 3.236 | 1.417 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 88514 | 5.664 | 1.383 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 52008 | 3.328 | 1.390 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 95043 | 6.082 | 1.396 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 74774 | 4.785 | 1.395 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 53724 | 3.438 | 1.542 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 60501 | 3.872 | 1.385 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 56501 | 3.616 | 1.395 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 66239 &nbsp;|&nbsp; mean time: 4.239 ms &nbsp;|&nbsp; mean wall: 1.422s

---

## uf75 — SAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf75-01 | SAT | SAT | 255086 | 16.325 | 1.386 | ✓ |
| uf75-02 | SAT | SAT | 19256 | 1.232 | 1.380 | ✓ |
| uf75-03 | SAT | SAT | 41856 | 2.678 | 1.391 | ✓ |
| uf75-04 | SAT | SAT | 221241 | 14.159 | 1.411 | ✓ |
| uf75-05 | SAT | SAT | 136073 | 8.708 | 2.128 | ✓ |
| uf75-06 | SAT | SAT | 604845 | 38.710 | 1.421 | ✓ |
| uf75-07 | SAT | SAT | 576964 | 36.925 | 1.595 | ✓ |
| uf75-08 | SAT | SAT | 410989 | 26.303 | 1.591 | ✓ |
| uf75-09 | SAT | SAT | 132393 | 8.473 | 1.374 | ✓ |
| uf75-010 | SAT | SAT | 207125 | 13.256 | 1.395 | ✓ |
| uf75-011 | SAT | UNSAT | 457958 | 29.309 | 1.419 | ✗ |
| uf75-012 | SAT | UNSAT | 238138 | 15.240 | 2.195 | ✗ |
| uf75-013 | SAT | SAT | 42481 | 2.718 | 1.378 | ✓ |
| uf75-014 | SAT | SAT | 20466 | 1.309 | 1.420 | ✓ |
| uf75-015 | SAT | SAT | 255473 | 16.350 | 1.410 | ✓ |

**Summary** — 13 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 241356 &nbsp;|&nbsp; mean time: 15.446 ms &nbsp;|&nbsp; mean wall: 1.526s

---

## uuf75 — UNSAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf75-01 | UNSAT | UNSAT | 264437 | 16.923 | 1.574 | ✓ |
| uuf75-02 | UNSAT | UNSAT | 145697 | 9.324 | 1.384 | ✓ |
| uuf75-03 | UNSAT | UNSAT | 851396 | 54.489 | 1.444 | ✓ |
| uuf75-04 | UNSAT | UNSAT | 199307 | 12.755 | 2.285 | ✓ |
| uuf75-05 | UNSAT | UNSAT | 630150 | 40.329 | 1.417 | ✓ |
| uuf75-06 | UNSAT | UNSAT | 356090 | 22.789 | 1.573 | ✓ |
| uuf75-07 | UNSAT | UNSAT | 239113 | 15.303 | 1.381 | ✓ |
| uuf75-08 | UNSAT | UNSAT | 353827 | 22.644 | 1.402 | ✓ |
| uuf75-09 | UNSAT | UNSAT | 166464 | 10.653 | 1.383 | ✓ |
| uuf75-010 | UNSAT | UNSAT | 301695 | 19.308 | 1.402 | ✓ |
| uuf75-011 | UNSAT | UNSAT | 536582 | 34.341 | 1.403 | ✓ |
| uuf75-012 | UNSAT | UNSAT | 423649 | 27.113 | 1.566 | ✓ |
| uuf75-013 | UNSAT | UNSAT | 316827 | 20.276 | 1.387 | ✓ |
| uuf75-014 | UNSAT | UNSAT | 315631 | 20.200 | 1.397 | ✓ |
| uuf75-015 | UNSAT | UNSAT | 286594 | 18.342 | 1.393 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 359163 &nbsp;|&nbsp; mean time: 22.986 ms &nbsp;|&nbsp; mean wall: 1.492s

---

## uf100 — SAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf100-01 | SAT | SAT | 1193709 | 76.397 | 1.457 | ✓ |
| uf100-02 | SAT | SAT | 447268 | 28.625 | 1.557 | ✓ |
| uf100-03 | SAT | SAT | 531381 | 34.008 | 1.397 | ✓ |
| uf100-04 | SAT | SAT | 980666 | 62.762 | 1.893 | ✓ |
| uf100-05 | SAT | SAT | 149228 | 9.550 | 1.540 | ✓ |
| uf100-06 | SAT | SAT | 17975 | 1.150 | 1.382 | ✓ |
| uf100-07 | SAT | SAT | 193307 | 12.371 | 1.407 | ✓ |
| uf100-08 | SAT | UNSAT | 2313138 | 148.040 | 1.527 | ✗ |
| uf100-09 | SAT | SAT | 364910 | 23.354 | 1.464 | ✓ |
| uf100-010 | SAT | SAT | 168672 | 10.795 | 1.385 | ✓ |
| uf100-011 | SAT | SAT | 543959 | 34.813 | 2.163 | ✓ |
| uf100-012 | SAT | SAT | 275889 | 17.656 | 1.574 | ✓ |
| uf100-013 | SAT | UNSAT | 2820954 | 180.541 | 1.551 | ✗ |
| uf100-014 | SAT | SAT | 589726 | 37.742 | 1.462 | ✓ |
| uf100-015 | SAT | UNSAT | 1316476 | 84.254 | 1.636 | ✗ |

**Summary** — 12 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 793817 &nbsp;|&nbsp; mean time: 50.804 ms &nbsp;|&nbsp; mean wall: 1.559s

---

## uuf100 — UNSAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf100-01 | UNSAT | UNSAT | 2725753 | 174.448 | 1.663 | ✓ |
| uuf100-02 | UNSAT | UNSAT | 2692576 | 172.324 | 1.591 | ✓ |
| uuf100-03 | UNSAT | UNSAT | 1407807 | 90.099 | 1.562 | ✓ |
| uuf100-04 | UNSAT | UNSAT | 2985098 | 191.046 | 1.697 | ✓ |
| uuf100-05 | UNSAT | UNSAT | 1971903 | 126.201 | 1.528 | ✓ |
| uuf100-06 | UNSAT | UNSAT | 1041341 | 66.645 | 1.547 | ✓ |
| uuf100-07 | UNSAT | UNSAT | 2187921 | 140.026 | 1.673 | ✓ |
| uuf100-08 | UNSAT | UNSAT | 2692325 | 172.308 | 1.623 | ✓ |
| uuf100-09 | UNSAT | UNSAT | 972323 | 62.228 | 1.490 | ✓ |
| uuf100-010 | UNSAT | UNSAT | 1405516 | 89.953 | 1.610 | ✓ |
| uuf100-011 | UNSAT | UNSAT | 2476686 | 158.507 | 1.666 | ✓ |
| uuf100-012 | UNSAT | UNSAT | 1474434 | 94.363 | 1.522 | ✓ |
| uuf100-013 | UNSAT | UNSAT | 701287 | 44.882 | 1.545 | ✓ |
| uuf100-014 | UNSAT | UNSAT | 1052499 | 67.359 | 1.615 | ✓ |
| uuf100-015 | UNSAT | UNSAT | 1229415 | 78.682 | 1.610 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1801125 &nbsp;|&nbsp; mean time: 115.272 ms &nbsp;|&nbsp; mean wall: 1.596s

---

## uf125 — SAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf125-01 | SAT | SAT | 371843 | 23.797 | 1.516 | ✓ |
| uf125-02 | SAT | UNSAT | 1952652 | 124.969 | 1.647 | ✗ |
| uf125-03 | SAT | UNSAT | 2566168 | 164.234 | 1.635 | ✗ |
| uf125-04 | SAT | UNSAT | 1898506 | 121.504 | 1.549 | ✗ |
| uf125-05 | SAT | SAT | 787221 | 50.382 | 1.528 | ✓ |
| uf125-06 | SAT | SAT | 120761 | 7.728 | 1.549 | ✓ |
| uf125-07 | SAT | SAT | 757187 | 48.459 | 1.433 | ✓ |
| uf125-08 | SAT | UNSAT | 1303120 | 83.399 | 1.627 | ✗ |
| uf125-09 | SAT | SAT | 1446378 | 92.568 | 1.988 | ✓ |
| uf125-010 | SAT | UNSAT | 1088317 | 69.652 | 1.572 | ✗ |
| uf125-011 | SAT | UNSAT | 1772711 | 113.453 | 1.640 | ✗ |
| uf125-012 | SAT | UNSAT | 2425993 | 155.263 | 1.632 | ✗ |
| uf125-013 | SAT | SAT | 652831 | 41.781 | 1.475 | ✓ |
| uf125-014 | SAT | UNSAT | 3647328 | 233.428 | 1.794 | ✗ |
| uf125-015 | SAT | UNSAT | 3802691 | 243.372 | 1.805 | ✗ |

**Summary** — 6 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1639580 &nbsp;|&nbsp; mean time: 104.933 ms &nbsp;|&nbsp; mean wall: 1.626s

---

## uuf125 — UNSAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf125-01 | UNSAT | UNSAT | 1349078 | 86.340 | 1.478 | ✓ |
| uuf125-02 | UNSAT | UNSAT | 2235671 | 143.082 | 1.649 | ✓ |
| uuf125-03 | UNSAT | UNSAT | 3285621 | 210.279 | 1.664 | ✓ |
| uuf125-04 | UNSAT | UNSAT | 2640526 | 168.993 | 1.556 | ✓ |
| uuf125-05 | UNSAT | UNSAT | 3259422 | 208.603 | 1.627 | ✓ |
| uuf125-06 | UNSAT | UNSAT | 2735784 | 175.090 | 1.558 | ✓ |
| uuf125-07 | UNSAT | UNSAT | 1899993 | 121.599 | 1.542 | ✓ |
| uuf125-08 | UNSAT | UNSAT | 2179259 | 139.472 | 1.578 | ✓ |
| uuf125-09 | UNSAT | UNSAT | 5217118 | 333.895 | 1.791 | ✓ |
| uuf125-010 | UNSAT | UNSAT | 1189109 | 76.102 | 1.539 | ✓ |
| uuf125-011 | UNSAT | UNSAT | 2199317 | 140.756 | 1.657 | ✓ |
| uuf125-012 | UNSAT | UNSAT | 2762598 | 176.806 | 1.636 | ✓ |
| uuf125-013 | UNSAT | UNSAT | 1385737 | 88.687 | 1.513 | ✓ |
| uuf125-014 | UNSAT | UNSAT | 2524196 | 161.548 | 2.333 | ✓ |
| uuf125-015 | UNSAT | UNSAT | 2018907 | 129.210 | 1.563 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 2458822 &nbsp;|&nbsp; mean time: 157.364 ms &nbsp;|&nbsp; mean wall: 1.645s

---

## uf150 — SAT, 150 vars, 645 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf150-01 | SAT | SAT | 1982940 | 126.908 | 1.564 | ✓ |
| uf150-02 | SAT | SAT | 2275378 | 145.624 | 1.627 | ✓ |
| uf150-03 | SAT | UNSAT | 3220148 | 206.089 | 1.655 | ✗ |
| uf150-04 | SAT | UNSAT | 4788017 | 306.433 | 1.704 | ✗ |
| uf150-05 | SAT | UNSAT | 997222 | 63.822 | 1.554 | ✗ |
| uf150-06 | SAT | UNSAT | 6012030 | 384.769 | 1.916 | ✗ |
| uf150-07 | SAT | UNSAT | 2943440 | 188.380 | 1.614 | ✗ |
| uf150-08 | SAT | SAT | 542726 | 34.734 | 1.435 | ✓ |
| uf150-09 | SAT | SAT | 2288463 | 146.461 | 1.707 | ✓ |
| uf150-010 | SAT | UNSAT | 4466409 | 285.850 | 1.734 | ✗ |
| uf150-011 | SAT | SAT | 613051 | 39.235 | 1.548 | ✓ |
| uf150-012 | SAT | UNSAT | 2760934 | 176.699 | 2.461 | ✗ |
| uf150-013 | SAT | SAT | 834877 | 53.432 | 1.467 | ✓ |
| uf150-014 | SAT | UNSAT | 3310750 | 211.888 | 1.773 | ✗ |
| uf150-015 | SAT | UNSAT | 2492470 | 159.518 | 1.547 | ✗ |

**Summary** — 6 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 2635257 &nbsp;|&nbsp; mean time: 168.656 ms &nbsp;|&nbsp; mean wall: 1.687s

---

## uuf150 — UNSAT, 150 vars, 645 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf150-01 | UNSAT | UNSAT | 3844664 | 246.058 | 1.655 | ✓ |
| uuf150-02 | UNSAT | UNSAT | 3634595 | 232.614 | 1.779 | ✓ |
| uuf150-03 | UNSAT | UNSAT | 2628666 | 168.234 | 1.532 | ✓ |
| uuf150-04 | UNSAT | UNSAT | 2131751 | 136.432 | 1.589 | ✓ |
| uuf150-05 | UNSAT | UNSAT | 3073401 | 196.697 | 1.655 | ✓ |
| uuf150-06 | UNSAT | UNSAT | 2499236 | 159.951 | 1.556 | ✓ |
| uuf150-07 | UNSAT | UNSAT | 2098966 | 134.333 | 1.572 | ✓ |
| uuf150-08 | UNSAT | UNSAT | 4013785 | 256.882 | 1.720 | ✓ |
| uuf150-09 | UNSAT | UNSAT | 2641112 | 169.031 | 1.707 | ✓ |
| uuf150-010 | UNSAT | UNSAT | 2215603 | 141.798 | 2.309 | ✓ |
| uuf150-011 | UNSAT | UNSAT | 4307751 | 275.696 | 1.727 | ✓ |
| uuf150-012 | UNSAT | UNSAT | 3393748 | 217.199 | 1.739 | ✓ |
| uuf150-013 | UNSAT | UNSAT | 3430928 | 219.579 | 1.604 | ✓ |
| uuf150-014 | UNSAT | UNSAT | 4404648 | 281.897 | 1.653 | ✓ |
| uuf150-015 | UNSAT | UNSAT | 2287669 | 146.410 | 1.661 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 3107101 &nbsp;|&nbsp; mean time: 198.854 ms &nbsp;|&nbsp; mean wall: 1.697s

---

## uf175 — SAT, 175 vars, 754 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf175-01 | SAT | UNSAT | 6493941 | 415.612 | 1.842 | ✗ |
| uf175-02 | SAT | UNSAT | 4063041 | 260.034 | 1.783 | ✗ |
| uf175-03 | SAT | UNSAT | 6393483 | 409.182 | 1.949 | ✗ |
| uf175-04 | SAT | SAT | 275178 | 17.611 | 1.407 | ✓ |
| uf175-05 | SAT | UNSAT | 6320439 | 404.508 | 1.775 | ✗ |
| uf175-06 | SAT | UNSAT | 3068720 | 196.398 | 1.583 | ✗ |
| uf175-07 | SAT | SAT | 4666623 | 298.663 | 1.698 | ✓ |
| uf175-08 | SAT | UNSAT | 1902313 | 121.748 | 1.631 | ✗ |
| uf175-09 | SAT | UNSAT | 5925491 | 379.231 | 1.856 | ✗ |
| uf175-010 | SAT | SAT | 1853074 | 118.596 | 1.536 | ✓ |
| uf175-011 | SAT | SAT | 1586583 | 101.541 | 1.578 | ✓ |
| uf175-012 | SAT | UNSAT | 5108264 | 326.928 | 1.821 | ✗ |
| uf175-013 | SAT | UNSAT | 5977953 | 382.588 | 1.846 | ✗ |
| uf175-014 | SAT | UNSAT | 5042760 | 322.736 | 2.297 | ✗ |
| uf175-015 | SAT | SAT | 2322912 | 148.666 | 1.622 | ✓ |

**Summary** — 5 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 4066718 &nbsp;|&nbsp; mean time: 260.269 ms &nbsp;|&nbsp; mean wall: 1.748s

---

## uuf175 — UNSAT, 175 vars, 754 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf175-01 | UNSAT | UNSAT | 7581781 | 485.233 | 1.909 | ✓ |
| uuf175-02 | UNSAT | UNSAT | 3405301 | 217.939 | 1.739 | ✓ |
| uuf175-03 | UNSAT | UNSAT | 8215152 | 525.769 | 1.910 | ✓ |
| uuf175-04 | UNSAT | UNSAT | 5182737 | 331.695 | 1.833 | ✓ |
| uuf175-05 | UNSAT | UNSAT | 5448278 | 348.689 | 2.070 | ✓ |
| uuf175-06 | UNSAT | UNSAT | 6710527 | 429.473 | 1.879 | ✓ |
| uuf175-07 | UNSAT | UNSAT | 7796186 | 498.955 | 1.868 | ✓ |
| uuf175-08 | UNSAT | UNSAT | 5923927 | 379.131 | 1.878 | ✓ |
| uuf175-09 | UNSAT | UNSAT | 6059073 | 387.780 | 1.812 | ✓ |
| uuf175-010 | UNSAT | UNSAT | 3582402 | 229.273 | 1.634 | ✓ |
| uuf175-011 | UNSAT | UNSAT | 6388157 | 408.842 | 1.944 | ✓ |
| uuf175-012 | UNSAT | UNSAT | 3469818 | 222.068 | 1.601 | ✓ |
| uuf175-013 | UNSAT | UNSAT | 7015217 | 448.973 | 1.830 | ✓ |
| uuf175-014 | UNSAT | UNSAT | 5030772 | 321.969 | 1.871 | ✓ |
| uuf175-015 | UNSAT | UNSAT | 4214707 | 269.741 | 1.743 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 5734935 &nbsp;|&nbsp; mean time: 367.035 ms &nbsp;|&nbsp; mean wall: 1.834s

---

## uf200 — SAT, 200 vars, 860 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf200-01 | SAT | UNSAT | 12464347 | 797.718 | 2.302 | ✗ |
| uf200-02 | SAT | UNSAT | 2986741 | 191.151 | 1.753 | ✗ |
| uf200-03 | SAT | UNSAT | 9461884 | 605.560 | 2.002 | ✗ |
| uf200-04 | SAT | UNSAT | 7795237 | 498.895 | 1.896 | ✗ |
| uf200-05 | SAT | UNSAT | 6428962 | 411.453 | 1.913 | ✗ |
| uf200-06 | SAT | UNSAT | 8587614 | 549.607 | 1.959 | ✗ |
| uf200-07 | SAT | UNSAT | 8566119 | 548.231 | 2.011 | ✗ |
| uf200-08 | SAT | UNSAT | 6288258 | 402.448 | 1.888 | ✗ |
| uf200-09 | SAT | UNSAT | 7525504 | 481.632 | 1.875 | ✗ |
| uf200-010 | SAT | UNSAT | 7020929 | 449.339 | 1.966 | ✗ |
| uf200-011 | SAT | UNSAT | 7584573 | 485.412 | 2.034 | ✗ |
| uf200-012 | SAT | UNSAT | 6317530 | 404.321 | 1.916 | ✗ |
| uf200-013 | SAT | UNSAT | 6876478 | 440.094 | 2.633 | ✗ |
| uf200-014 | SAT | UNSAT | 11874404 | 759.961 | 2.310 | ✗ |
| uf200-015 | SAT | UNSAT | 6293374 | 402.775 | 1.845 | ✗ |

**Summary** — 0 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 7738130 &nbsp;|&nbsp; mean time: 495.240 ms &nbsp;|&nbsp; mean wall: 2.020s

---

## uuf200 — UNSAT, 200 vars, 860 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf200-01 | UNSAT | UNSAT | 9169649 | 586.857 | 1.960 | ✓ |
| uuf200-02 | UNSAT | UNSAT | 11657690 | 746.092 | 2.149 | ✓ |
| uuf200-03 | UNSAT | UNSAT | 7157301 | 458.067 | 2.610 | ✓ |
| uuf200-04 | UNSAT | UNSAT | 9906400 | 634.009 | 2.195 | ✓ |
| uuf200-05 | UNSAT | UNSAT | 7339732 | 469.742 | 1.838 | ✓ |
| uuf200-06 | UNSAT | UNSAT | 10171386 | 650.968 | 2.183 | ✓ |
| uuf200-07 | UNSAT | UNSAT | 5125940 | 328.060 | 1.876 | ✓ |
| uuf200-08 | UNSAT | UNSAT | 8914085 | 570.501 | 2.034 | ✓ |
| uuf200-09 | UNSAT | UNSAT | 4316354 | 276.246 | 1.763 | ✓ |
| uuf200-010 | UNSAT | UNSAT | 7161482 | 458.334 | 1.980 | ✓ |
| uuf200-011 | UNSAT | UNSAT | 8765727 | 561.006 | 2.096 | ✓ |
| uuf200-012 | UNSAT | UNSAT | 8389930 | 536.955 | 1.978 | ✓ |
| uuf200-013 | UNSAT | UNSAT | 9206369 | 589.207 | 2.051 | ✓ |
| uuf200-014 | UNSAT | UNSAT | 10392122 | 665.095 | 2.180 | ✓ |
| uuf200-015 | UNSAT | UNSAT | 8250495 | 528.031 | 2.068 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 8394977 &nbsp;|&nbsp; mean time: 537.278 ms &nbsp;|&nbsp; mean wall: 2.064s

---

