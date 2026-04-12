# SatSwarm Benchmark Results

- **Grid config**: 1x1
- **Run timestamp**: 20260412_183019
- **Instances per dataset**: 25
- **FPGA slot**: 0
- **Host binary**: /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 39850 | 2.550 | 1.464 | ✓ |
| uf50-02 | SAT | SAT | 29842 | 1.909 | 1.392 | ✓ |
| uf50-03 | SAT | SAT | 56149 | 3.593 | 1.395 | ✓ |
| uf50-04 | SAT | SAT | 59683 | 3.819 | 1.383 | ✓ |
| uf50-05 | SAT | SAT | 9703 | .620 | 1.634 | ✓ |
| uf50-06 | SAT | SAT | 41086 | 2.629 | 1.393 | ✓ |
| uf50-07 | SAT | SAT | 22672 | 1.451 | 1.394 | ✓ |
| uf50-08 | SAT | SAT | 48524 | 3.105 | 1.398 | ✓ |
| uf50-09 | SAT | SAT | 48578 | 3.108 | 1.385 | ✓ |
| uf50-010 | SAT | SAT | 21914 | 1.402 | 1.400 | ✓ |
| uf50-011 | SAT | SAT | 49909 | 3.194 | 1.389 | ✓ |
| uf50-012 | SAT | SAT | 39967 | 2.557 | 1.386 | ✓ |
| uf50-013 | SAT | SAT | 8203 | .524 | 1.398 | ✓ |
| uf50-014 | SAT | SAT | 18999 | 1.215 | 1.404 | ✓ |
| uf50-015 | SAT | SAT | 20641 | 1.321 | 1.385 | ✓ |
| uf50-016 | SAT | SAT | 24324 | 1.556 | 1.383 | ✓ |
| uf50-017 | SAT | SAT | 17454 | 1.117 | 1.390 | ✓ |
| uf50-018 | SAT | SAT | 12745 | .815 | 1.390 | ✓ |
| uf50-019 | SAT | SAT | 70546 | 4.514 | 1.381 | ✓ |
| uf50-020 | SAT | SAT | 13090 | .837 | 1.394 | ✓ |
| uf50-021 | SAT | SAT | 32267 | 2.065 | 1.434 | ✓ |
| uf50-022 | SAT | SAT | 61792 | 3.954 | 1.390 | ✓ |
| uf50-023 | SAT | SAT | 7065 | .452 | 1.389 | ✓ |
| uf50-024 | SAT | SAT | 64582 | 4.133 | 1.413 | ✓ |
| uf50-025 | SAT | SAT | 6358 | .406 | 1.381 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 33037 &nbsp;|&nbsp; mean time: 2.114 ms &nbsp;|&nbsp; mean wall: 1.405s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 57651 | 3.689 | 1.568 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 45549 | 2.915 | 1.386 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 58847 | 3.766 | 2.087 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 51205 | 3.277 | 1.395 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 56460 | 3.613 | 1.388 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 61212 | 3.917 | 1.390 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 100342 | 6.421 | 1.392 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 51089 | 3.269 | 1.384 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 81061 | 5.187 | 1.389 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 46099 | 2.950 | 1.385 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 64942 | 4.156 | 1.461 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 92087 | 5.893 | 1.392 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 42255 | 2.704 | 1.384 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 60721 | 3.886 | 1.397 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 44226 | 2.830 | 1.386 | ✓ |
| uuf50-016 | UNSAT | UNSAT | 36009 | 2.304 | 1.383 | ✓ |
| uuf50-017 | UNSAT | UNSAT | 69628 | 4.456 | 1.402 | ✓ |
| uuf50-018 | UNSAT | UNSAT | 47108 | 3.014 | 1.382 | ✓ |
| uuf50-019 | UNSAT | UNSAT | 61174 | 3.915 | 1.464 | ✓ |
| uuf50-020 | UNSAT | UNSAT | 65118 | 4.167 | 1.389 | ✓ |
| uuf50-021 | UNSAT | UNSAT | 136965 | 8.765 | 1.394 | ✓ |
| uuf50-022 | UNSAT | UNSAT | 66233 | 4.238 | 1.398 | ✓ |
| uuf50-023 | UNSAT | UNSAT | 58738 | 3.759 | 1.385 | ✓ |
| uuf50-024 | UNSAT | UNSAT | 39845 | 2.550 | 1.388 | ✓ |
| uuf50-025 | UNSAT | UNSAT | 58526 | 3.745 | 1.389 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 62123 &nbsp;|&nbsp; mean time: 3.975 ms &nbsp;|&nbsp; mean wall: 1.430s

---

## uf75 — SAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf75-01 | SAT | SAT | 185857 | 11.894 | 2.102 | ✓ |
| uf75-02 | SAT | SAT | 57829 | 3.701 | 1.374 | ✓ |
| uf75-03 | SAT | SAT | 47302 | 3.027 | 1.406 | ✓ |
| uf75-04 | SAT | SAT | 175101 | 11.206 | 1.396 | ✓ |
| uf75-05 | SAT | SAT | 183349 | 11.734 | 1.385 | ✓ |
| uf75-06 | SAT | SAT | 148993 | 9.535 | 1.381 | ✓ |
| uf75-07 | SAT | SAT | 326191 | 20.876 | 1.404 | ✓ |
| uf75-08 | SAT | SAT | 193819 | 12.404 | 1.381 | ✓ |
| uf75-09 | SAT | SAT | 168353 | 10.774 | 1.501 | ✓ |
| uf75-010 | SAT | SAT | 253353 | 16.214 | 1.386 | ✓ |
| uf75-011 | SAT | SAT | 83610 | 5.351 | 1.389 | ✓ |
| uf75-012 | SAT | SAT | 180486 | 11.551 | 1.391 | ✓ |
| uf75-013 | SAT | SAT | 31342 | 2.005 | 1.372 | ✓ |
| uf75-014 | SAT | SAT | 19902 | 1.273 | 1.390 | ✓ |
| uf75-015 | SAT | SAT | 167429 | 10.715 | 1.404 | ✓ |
| uf75-016 | SAT | SAT | 185017 | 11.841 | 2.232 | ✓ |
| uf75-017 | SAT | SAT | 73687 | 4.715 | 1.386 | ✓ |
| uf75-018 | SAT | SAT | 252659 | 16.170 | 1.402 | ✓ |
| uf75-019 | SAT | SAT | 284388 | 18.200 | 1.389 | ✓ |
| uf75-020 | SAT | SAT | 217757 | 13.936 | 1.387 | ✓ |
| uf75-021 | SAT | SAT | 175073 | 11.204 | 1.387 | ✓ |
| uf75-022 | SAT | SAT | 153744 | 9.839 | 1.390 | ✓ |
| uf75-023 | SAT | SAT | 203717 | 13.037 | 1.396 | ✓ |
| uf75-024 | SAT | SAT | 332997 | 21.311 | 1.543 | ✓ |
| uf75-025 | SAT | SAT | 6659 | .426 | 1.366 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 164344 &nbsp;|&nbsp; mean time: 10.518 ms &nbsp;|&nbsp; mean wall: 1.461s

---

## uuf75 — UNSAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf75-01 | UNSAT | UNSAT | 225125 | 14.408 | 1.391 | ✓ |
| uuf75-02 | UNSAT | UNSAT | 188139 | 12.040 | 1.391 | ✓ |
| uuf75-03 | UNSAT | UNSAT | 320524 | 20.513 | 1.396 | ✓ |
| uuf75-04 | UNSAT | UNSAT | 176598 | 11.302 | 1.388 | ✓ |
| uuf75-05 | UNSAT | UNSAT | 373546 | 23.906 | 1.399 | ✓ |
| uuf75-06 | UNSAT | UNSAT | 227305 | 14.547 | 2.181 | ✓ |
| uuf75-07 | UNSAT | UNSAT | 244730 | 15.662 | 1.392 | ✓ |
| uuf75-08 | UNSAT | UNSAT | 461574 | 29.540 | 1.432 | ✓ |
| uuf75-09 | UNSAT | UNSAT | 132642 | 8.489 | 1.543 | ✓ |
| uuf75-010 | UNSAT | UNSAT | 338888 | 21.688 | 1.406 | ✓ |
| uuf75-011 | UNSAT | UNSAT | 343206 | 21.965 | 1.586 | ✓ |
| uuf75-012 | UNSAT | UNSAT | 275855 | 17.654 | 1.393 | ✓ |
| uuf75-013 | UNSAT | UNSAT | 576919 | 36.922 | 2.259 | ✓ |
| uuf75-014 | UNSAT | UNSAT | 550654 | 35.241 | 1.591 | ✓ |
| uuf75-015 | UNSAT | UNSAT | 256136 | 16.392 | 1.579 | ✓ |
| uuf75-016 | UNSAT | UNSAT | 452027 | 28.929 | 1.397 | ✓ |
| uuf75-017 | UNSAT | UNSAT | 371239 | 23.759 | 1.591 | ✓ |
| uuf75-018 | UNSAT | UNSAT | 301043 | 19.266 | 1.399 | ✓ |
| uuf75-019 | UNSAT | UNSAT | 271312 | 17.363 | 1.397 | ✓ |
| uuf75-020 | UNSAT | UNSAT | 464735 | 29.743 | 1.991 | ✓ |
| uuf75-021 | UNSAT | UNSAT | 271388 | 17.368 | 1.577 | ✓ |
| uuf75-022 | UNSAT | UNSAT | 788921 | 50.490 | 1.422 | ✓ |
| uuf75-023 | UNSAT | UNSAT | 348685 | 22.315 | 1.596 | ✓ |
| uuf75-024 | UNSAT | UNSAT | 262885 | 16.824 | 1.585 | ✓ |
| uuf75-025 | UNSAT | UNSAT | 762319 | 48.788 | 1.593 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 359455 &nbsp;|&nbsp; mean time: 23.005 ms &nbsp;|&nbsp; mean wall: 1.555s

---

## uf100 — SAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf100-01 | SAT | SAT | 1020987 | 65.343 | 1.589 | ✓ |
| uf100-02 | SAT | SAT | 265934 | 17.019 | 1.437 | ✓ |
| uf100-03 | SAT | SAT | 617087 | 39.493 | 1.421 | ✓ |
| uf100-04 | SAT | UNSAT | 1324880 | 84.792 | 1.452 | ✗ |
| uf100-05 | SAT | SAT | 283695 | 18.156 | 1.521 | ✓ |
| uf100-06 | SAT | SAT | 17770 | 1.137 | 1.367 | ✓ |
| uf100-07 | SAT | SAT | 117174 | 7.499 | 1.397 | ✓ |
| uf100-08 | SAT | SAT | 834360 | 53.399 | 1.469 | ✓ |
| uf100-09 | SAT | SAT | 587630 | 37.608 | 2.390 | ✓ |
| uf100-010 | SAT | SAT | 476576 | 30.500 | 1.591 | ✓ |
| uf100-011 | SAT | SAT | 249142 | 15.945 | 1.579 | ✓ |
| uf100-012 | SAT | SAT | 124191 | 7.948 | 1.378 | ✓ |
| uf100-013 | SAT | SAT | 565665 | 36.202 | 1.448 | ✓ |
| uf100-014 | SAT | SAT | 528297 | 33.811 | 1.558 | ✓ |
| uf100-015 | SAT | SAT | 329857 | 21.110 | 1.594 | ✓ |
| uf100-016 | SAT | SAT | 146381 | 9.368 | 2.480 | ✓ |
| uf100-017 | SAT | SAT | 930881 | 59.576 | 1.469 | ✓ |
| uf100-018 | SAT | SAT | 326924 | 20.923 | 1.523 | ✓ |
| uf100-019 | SAT | SAT | 175627 | 11.240 | 1.575 | ✓ |
| uf100-020 | SAT | SAT | 360977 | 23.102 | 1.412 | ✓ |
| uf100-021 | SAT | UNSAT | 900504 | 57.632 | 1.626 | ✗ |
| uf100-022 | SAT | SAT | 787788 | 50.418 | 1.606 | ✓ |
| uf100-023 | SAT | UNSAT | 1205405 | 77.145 | 1.694 | ✗ |
| uf100-024 | SAT | SAT | 674508 | 43.168 | 1.557 | ✓ |
| uf100-025 | SAT | UNSAT | 1121388 | 71.768 | 1.618 | ✗ |

**Summary** — 21 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 558945 &nbsp;|&nbsp; mean time: 35.772 ms &nbsp;|&nbsp; mean wall: 1.590s

---

## uuf100 — UNSAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf100-01 | UNSAT | UNSAT | 968330 | 61.973 | 1.551 | ✓ |
| uuf100-02 | UNSAT | UNSAT | 689304 | 44.115 | 1.575 | ✓ |
| uuf100-03 | UNSAT | UNSAT | 929619 | 59.495 | 1.606 | ✓ |
| uuf100-04 | UNSAT | UNSAT | 1644456 | 105.245 | 1.633 | ✓ |
| uuf100-05 | UNSAT | UNSAT | 1259544 | 80.610 | 1.608 | ✓ |
| uuf100-06 | UNSAT | UNSAT | 1101456 | 70.493 | 1.587 | ✓ |
| uuf100-07 | UNSAT | UNSAT | 1171805 | 74.995 | 1.591 | ✓ |
| uuf100-08 | UNSAT | UNSAT | 1729842 | 110.709 | 1.628 | ✓ |
| uuf100-09 | UNSAT | UNSAT | 1506768 | 96.433 | 1.582 | ✓ |
| uuf100-010 | UNSAT | UNSAT | 1852443 | 118.556 | 1.634 | ✓ |
| uuf100-011 | UNSAT | UNSAT | 1244158 | 79.626 | 1.527 | ✓ |
| uuf100-012 | UNSAT | UNSAT | 1085613 | 69.479 | 1.480 | ✓ |
| uuf100-013 | UNSAT | UNSAT | 538276 | 34.449 | 1.562 | ✓ |
| uuf100-014 | UNSAT | UNSAT | 747527 | 47.841 | 1.605 | ✓ |
| uuf100-015 | UNSAT | UNSAT | 1251997 | 80.127 | 1.478 | ✓ |
| uuf100-016 | UNSAT | UNSAT | 1161004 | 74.304 | 1.604 | ✓ |
| uuf100-017 | UNSAT | UNSAT | 492942 | 31.548 | 1.527 | ✓ |
| uuf100-018 | UNSAT | UNSAT | 1172810 | 75.059 | 1.629 | ✓ |
| uuf100-019 | UNSAT | UNSAT | 1382073 | 88.452 | 1.568 | ✓ |
| uuf100-020 | UNSAT | UNSAT | 913314 | 58.452 | 1.560 | ✓ |
| uuf100-021 | UNSAT | UNSAT | 1402074 | 89.732 | 1.621 | ✓ |
| uuf100-022 | UNSAT | UNSAT | 1260649 | 80.681 | 1.586 | ✓ |
| uuf100-023 | UNSAT | UNSAT | 1234986 | 79.039 | 1.591 | ✓ |
| uuf100-024 | UNSAT | UNSAT | 1306048 | 83.587 | 1.595 | ✓ |
| uuf100-025 | UNSAT | UNSAT | 1007584 | 64.485 | 1.578 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1162184 &nbsp;|&nbsp; mean time: 74.379 ms &nbsp;|&nbsp; mean wall: 1.580s

---

## uf125 — SAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf125-01 | SAT | SAT | 211392 | 13.529 | 1.426 | ✓ |
| uf125-02 | SAT | SAT | 1185982 | 75.902 | 1.456 | ✓ |
| uf125-03 | SAT | SAT | 419423 | 26.843 | 1.548 | ✓ |
| uf125-04 | SAT | UNSAT | 1454906 | 93.113 | 1.651 | ✗ |
| uf125-05 | SAT | SAT | 586853 | 37.558 | 1.534 | ✓ |
| uf125-06 | SAT | SAT | 136295 | 8.722 | 1.562 | ✓ |
| uf125-07 | SAT | SAT | 674901 | 43.193 | 1.430 | ✓ |
| uf125-08 | SAT | SAT | 572054 | 36.611 | 1.527 | ✓ |
| uf125-09 | SAT | SAT | 459405 | 29.401 | 1.579 | ✓ |
| uf125-010 | SAT | UNSAT | 1540180 | 98.571 | 1.662 | ✗ |
| uf125-011 | SAT | UNSAT | 1504660 | 96.298 | 1.591 | ✗ |
| uf125-012 | SAT | UNSAT | 951233 | 60.878 | 1.559 | ✗ |
| uf125-013 | SAT | UNSAT | 1877468 | 120.157 | 1.655 | ✗ |
| uf125-014 | SAT | UNSAT | 1160422 | 74.267 | 1.539 | ✗ |
| uf125-015 | SAT | SAT | 1733505 | 110.944 | 1.547 | ✓ |
| uf125-016 | SAT | SAT | 106728 | 6.830 | 1.481 | ✓ |
| uf125-017 | SAT | UNSAT | 1733559 | 110.947 | 1.492 | ✗ |
| uf125-018 | SAT | UNSAT | 1510561 | 96.675 | 1.578 | ✗ |
| uf125-019 | SAT | UNSAT | 2294785 | 146.866 | 1.649 | ✗ |
| uf125-020 | SAT | UNSAT | 1803838 | 115.445 | 1.555 | ✗ |
| uf125-021 | SAT | UNSAT | 1696195 | 108.556 | 1.584 | ✗ |
| uf125-022 | SAT | UNSAT | 1497480 | 95.838 | 1.490 | ✗ |
| uf125-023 | SAT | UNSAT | 1152937 | 73.787 | 1.559 | ✗ |
| uf125-024 | SAT | UNSAT | 1544929 | 98.875 | 1.614 | ✗ |
| uf125-025 | SAT | UNSAT | 1891352 | 121.046 | 1.611 | ✗ |

**Summary** — 10 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1188041 &nbsp;|&nbsp; mean time: 76.034 ms &nbsp;|&nbsp; mean wall: 1.555s

---

## uuf125 — UNSAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf125-01 | UNSAT | UNSAT | 1359100 | 86.982 | 1.531 | ✓ |
| uuf125-02 | UNSAT | UNSAT | 1256126 | 80.392 | 1.583 | ✓ |
| uuf125-03 | UNSAT | UNSAT | 1381125 | 88.392 | 1.620 | ✓ |
| uuf125-04 | UNSAT | UNSAT | 1163832 | 74.485 | 2.292 | ✓ |
| uuf125-05 | UNSAT | UNSAT | 1147212 | 73.421 | 1.582 | ✓ |
| uuf125-06 | UNSAT | UNSAT | 1234421 | 79.002 | 1.599 | ✓ |
| uuf125-07 | UNSAT | UNSAT | 2275180 | 145.611 | 1.660 | ✓ |
| uuf125-08 | UNSAT | UNSAT | 1535046 | 98.242 | 1.554 | ✓ |
| uuf125-09 | UNSAT | UNSAT | 1302728 | 83.374 | 1.578 | ✓ |
| uuf125-010 | UNSAT | UNSAT | 1334879 | 85.432 | 1.595 | ✓ |
| uuf125-011 | UNSAT | UNSAT | 1211328 | 77.524 | 1.612 | ✓ |
| uuf125-012 | UNSAT | UNSAT | 1753547 | 112.227 | 1.631 | ✓ |
| uuf125-013 | UNSAT | UNSAT | 1458837 | 93.365 | 1.601 | ✓ |
| uuf125-014 | UNSAT | UNSAT | 1226257 | 78.480 | 1.553 | ✓ |
| uuf125-015 | UNSAT | UNSAT | 1719056 | 110.019 | 1.622 | ✓ |
| uuf125-016 | UNSAT | UNSAT | 1305391 | 83.545 | 1.585 | ✓ |
| uuf125-017 | UNSAT | UNSAT | 1385273 | 88.657 | 1.597 | ✓ |
| uuf125-018 | UNSAT | UNSAT | 1172136 | 75.016 | 1.599 | ✓ |
| uuf125-019 | UNSAT | UNSAT | 1519371 | 97.239 | 1.611 | ✓ |
| uuf125-020 | UNSAT | UNSAT | 1404506 | 89.888 | 1.584 | ✓ |
| uuf125-021 | UNSAT | UNSAT | 1177878 | 75.384 | 1.571 | ✓ |
| uuf125-022 | UNSAT | UNSAT | 1899465 | 121.565 | 1.636 | ✓ |
| uuf125-023 | UNSAT | UNSAT | 1243991 | 79.615 | 1.548 | ✓ |
| uuf125-024 | UNSAT | UNSAT | 1589431 | 101.723 | 1.612 | ✓ |
| uuf125-025 | UNSAT | UNSAT | 1342034 | 85.890 | 1.532 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1415926 &nbsp;|&nbsp; mean time: 90.619 ms &nbsp;|&nbsp; mean wall: 1.619s

---

## uf150 — SAT, 150 vars, 645 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf150-01 | SAT | UNSAT | 1642723 | 105.134 | 1.594 | ✗ |
| uf150-02 | SAT | UNSAT | 1875133 | 120.008 | 1.600 | ✗ |
| uf150-03 | SAT | UNSAT | 2385441 | 152.668 | 1.630 | ✗ |
| uf150-04 | SAT | UNSAT | 1460843 | 93.493 | 1.537 | ✗ |
| uf150-05 | SAT | UNSAT | 1408519 | 90.145 | 1.591 | ✗ |
| uf150-06 | SAT | UNSAT | 2280938 | 145.980 | 2.819 | ✗ |
| uf150-07 | SAT | UNSAT | 1874381 | 119.960 | 1.566 | ✗ |
| uf150-08 | SAT | UNSAT | 1337433 | 85.595 | 1.553 | ✗ |
| uf150-09 | SAT | UNSAT | 1544377 | 98.840 | 1.610 | ✗ |
| uf150-010 | SAT | UNSAT | 1688035 | 108.034 | 1.604 | ✗ |
| uf150-011 | SAT | SAT | 1645018 | 105.281 | 1.582 | ✓ |
| uf150-012 | SAT | UNSAT | 1793593 | 114.789 | 1.601 | ✗ |
| uf150-013 | SAT | UNSAT | 1482774 | 94.897 | 1.502 | ✗ |
| uf150-014 | SAT | UNSAT | 1827170 | 116.938 | 1.617 | ✗ |
| uf150-015 | SAT | UNSAT | 2171743 | 138.991 | 1.613 | ✗ |
| uf150-016 | SAT | UNSAT | 2772006 | 177.408 | 1.634 | ✗ |
| uf150-017 | SAT | UNSAT | 2153369 | 137.815 | 1.557 | ✗ |
| uf150-018 | SAT | UNSAT | 1568084 | 100.357 | 1.554 | ✗ |
| uf150-019 | SAT | UNSAT | 2184660 | 139.818 | 1.627 | ✗ |
| uf150-020 | SAT | UNSAT | 1708566 | 109.348 | 1.614 | ✗ |
| uf150-021 | SAT | UNSAT | 1689173 | 108.107 | 1.585 | ✗ |
| uf150-022 | SAT | UNSAT | 1546619 | 98.983 | 1.568 | ✗ |
| uf150-023 | SAT | UNSAT | 2211078 | 141.508 | 1.640 | ✗ |
| uf150-024 | SAT | UNSAT | 1601599 | 102.502 | 1.554 | ✗ |
| uf150-025 | SAT | UNSAT | 1936861 | 123.959 | 1.625 | ✗ |

**Summary** — 1 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1831605 &nbsp;|&nbsp; mean time: 117.222 ms &nbsp;|&nbsp; mean wall: 1.639s

---

## uuf150 — UNSAT, 150 vars, 645 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf150-01 | UNSAT | UNSAT | 2405207 | 153.933 | 1.629 | ✓ |
| uuf150-02 | UNSAT | UNSAT | 1737376 | 111.192 | 1.485 | ✓ |
| uuf150-03 | UNSAT | UNSAT | 1851276 | 118.481 | 1.595 | ✓ |
| uuf150-04 | UNSAT | UNSAT | 2487158 | 159.178 | 1.635 | ✓ |
| uuf150-05 | UNSAT | UNSAT | 1241336 | 79.445 | 1.513 | ✓ |
| uuf150-06 | UNSAT | UNSAT | 1696056 | 108.547 | 1.622 | ✓ |
| uuf150-07 | UNSAT | UNSAT | 1595393 | 102.105 | 1.584 | ✓ |
| uuf150-08 | UNSAT | UNSAT | 2322770 | 148.657 | 1.634 | ✓ |
| uuf150-09 | UNSAT | UNSAT | 1914774 | 122.545 | 1.564 | ✓ |
| uuf150-010 | UNSAT | UNSAT | 1215639 | 77.800 | 1.542 | ✓ |
| uuf150-011 | UNSAT | UNSAT | 1333240 | 85.327 | 1.606 | ✓ |
| uuf150-012 | UNSAT | UNSAT | 2301016 | 147.265 | 1.646 | ✓ |
| uuf150-013 | UNSAT | UNSAT | 1954683 | 125.099 | 1.576 | ✓ |
| uuf150-014 | UNSAT | UNSAT | 1578123 | 100.999 | 1.560 | ✓ |
| uuf150-015 | UNSAT | UNSAT | 1580510 | 101.152 | 1.595 | ✓ |
| uuf150-016 | UNSAT | UNSAT | 1389673 | 88.939 | 1.604 | ✓ |
| uuf150-017 | UNSAT | UNSAT | 2580519 | 165.153 | 1.664 | ✓ |
| uuf150-018 | UNSAT | UNSAT | 2521370 | 161.367 | 1.586 | ✓ |
| uuf150-019 | UNSAT | UNSAT | 1378968 | 88.253 | 1.519 | ✓ |
| uuf150-020 | UNSAT | UNSAT | 1552906 | 99.385 | 1.604 | ✓ |
| uuf150-021 | UNSAT | UNSAT | 2158735 | 138.159 | 1.633 | ✓ |
| uuf150-022 | UNSAT | UNSAT | 1423042 | 91.074 | 2.620 | ✓ |
| uuf150-023 | UNSAT | UNSAT | 1432747 | 91.695 | 1.597 | ✓ |
| uuf150-024 | UNSAT | UNSAT | 1454079 | 93.061 | 1.588 | ✓ |
| uuf150-025 | UNSAT | UNSAT | 2338518 | 149.665 | 1.648 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1817804 &nbsp;|&nbsp; mean time: 116.339 ms &nbsp;|&nbsp; mean wall: 1.633s

---

## uf175 — SAT, 175 vars, 753 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf175-01 | SAT | UNSAT | 2127320 | 136.148 | 1.561 | ✗ |
| uf175-02 | SAT | UNSAT | 1853688 | 118.636 | 1.580 | ✗ |
| uf175-03 | SAT | UNSAT | 2810824 | 179.892 | 1.656 | ✗ |
| uf175-04 | SAT | UNSAT | 2962934 | 189.627 | 1.688 | ✗ |
| uf175-05 | SAT | UNSAT | 2039327 | 130.516 | 1.534 | ✗ |
| uf175-06 | SAT | UNSAT | 1654304 | 105.875 | 1.563 | ✗ |
| uf175-07 | SAT | UNSAT | 2675632 | 171.240 | 1.659 | ✗ |
| uf175-08 | SAT | SAT | 1754922 | 112.315 | 1.527 | ✓ |
| uf175-09 | SAT | UNSAT | 2399467 | 153.565 | 1.633 | ✗ |
| uf175-010 | SAT | SAT | 1863136 | 119.240 | 1.556 | ✓ |
| uf175-011 | SAT | SAT | 1951696 | 124.908 | 1.669 | ✓ |
| uf175-012 | SAT | UNSAT | 2015598 | 128.998 | 1.585 | ✗ |
| uf175-013 | SAT | UNSAT | 4914192 | 314.508 | 1.783 | ✗ |
| uf175-014 | SAT | UNSAT | 2829306 | 181.075 | 1.656 | ✗ |
| uf175-015 | SAT | SAT | 1072471 | 68.638 | 1.479 | ✓ |
| uf175-016 | SAT | UNSAT | 2848502 | 182.304 | 1.704 | ✗ |
| uf175-017 | SAT | UNSAT | 2100819 | 134.452 | 2.085 | ✗ |
| uf175-018 | SAT | UNSAT | 2239840 | 143.349 | 1.605 | ✗ |
| uf175-019 | SAT | UNSAT | 2420738 | 154.927 | 1.595 | ✗ |
| uf175-020 | SAT | UNSAT | 1351649 | 86.505 | 1.519 | ✗ |
| uf175-021 | SAT | UNSAT | 2246505 | 143.776 | 1.657 | ✗ |
| uf175-022 | SAT | SAT | 1029526 | 65.889 | 1.516 | ✓ |
| uf175-023 | SAT | UNSAT | 2438317 | 156.052 | 1.676 | ✗ |
| uf175-024 | SAT | UNSAT | 3891780 | 249.073 | 1.799 | ✗ |
| uf175-025 | SAT | UNSAT | 3095739 | 198.127 | 1.743 | ✗ |

**Summary** — 5 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 2343529 &nbsp;|&nbsp; mean time: 149.985 ms &nbsp;|&nbsp; mean wall: 1.641s

---

## uuf175 — UNSAT, 175 vars, 753 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf175-01 | UNSAT | UNSAT | 1938863 | 124.087 | 1.693 | ✓ |
| uuf175-02 | UNSAT | UNSAT | 2061326 | 131.924 | 1.597 | ✓ |
| uuf175-03 | UNSAT | UNSAT | 3122737 | 199.855 | 1.659 | ✓ |
| uuf175-04 | UNSAT | UNSAT | 2297518 | 147.041 | 1.538 | ✓ |
| uuf175-05 | UNSAT | UNSAT | 1820728 | 116.526 | 2.457 | ✓ |
| uuf175-06 | UNSAT | UNSAT | 2865790 | 183.410 | 1.664 | ✓ |
| uuf175-07 | UNSAT | UNSAT | 2793375 | 178.776 | 1.591 | ✓ |
| uuf175-08 | UNSAT | UNSAT | 3037857 | 194.422 | 1.599 | ✓ |
| uuf175-09 | UNSAT | UNSAT | 3031997 | 194.047 | 1.620 | ✓ |
| uuf175-010 | UNSAT | UNSAT | 3041641 | 194.665 | 1.569 | ✓ |
| uuf175-011 | UNSAT | UNSAT | 2355347 | 150.742 | 1.570 | ✓ |
| uuf175-012 | UNSAT | UNSAT | 3661462 | 234.333 | 1.771 | ✓ |
| uuf175-013 | UNSAT | UNSAT | 2213257 | 141.648 | 1.708 | ✓ |
| uuf175-014 | UNSAT | UNSAT | 5143101 | 329.158 | 1.787 | ✓ |
| uuf175-015 | UNSAT | UNSAT | 2546593 | 162.981 | 1.622 | ✓ |
| uuf175-016 | UNSAT | UNSAT | 4918508 | 314.784 | 1.740 | ✓ |
| uuf175-017 | UNSAT | UNSAT | 2589399 | 165.721 | 1.642 | ✓ |
| uuf175-018 | UNSAT | UNSAT | 2397014 | 153.408 | 2.061 | ✓ |
| uuf175-019 | UNSAT | UNSAT | 4111573 | 263.140 | 1.696 | ✓ |
| uuf175-020 | UNSAT | UNSAT | 2762110 | 176.775 | 1.715 | ✓ |
| uuf175-021 | UNSAT | UNSAT | 1989592 | 127.333 | 1.539 | ✓ |
| uuf175-022 | UNSAT | UNSAT | 1828957 | 117.053 | 1.598 | ✓ |
| uuf175-023 | UNSAT | UNSAT | 2437479 | 155.998 | 1.637 | ✓ |
| uuf175-024 | UNSAT | UNSAT | 1841158 | 117.834 | 1.559 | ✓ |
| uuf175-025 | UNSAT | UNSAT | 1551103 | 99.270 | 1.572 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 2734339 &nbsp;|&nbsp; mean time: 174.997 ms &nbsp;|&nbsp; mean wall: 1.688s

---

## Overall Summary

- **Grid**: 1x1
- **Total correct**: 237 / 300
- **Finished**: Sun Apr 12 18:38:17 UTC 2026
