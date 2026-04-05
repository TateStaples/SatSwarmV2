# SatSwarm Benchmark Results

- **Grid config**: 1x1
- **Run timestamp**: 20260405_173817
- **Instances per dataset**: 15
- **FPGA slot**: 0
- **Host binary**: /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 46091 | 2.949 | 1.480 | ✓ |
| uf50-02 | SAT | SAT | 36134 | 2.312 | 1.573 | ✓ |
| uf50-03 | SAT | SAT | 62234 | 3.982 | 1.397 | ✓ |
| uf50-04 | SAT | SAT | 65809 | 4.211 | 1.390 | ✓ |
| uf50-05 | SAT | SAT | 15806 | 1.011 | 1.388 | ✓ |
| uf50-06 | SAT | SAT | 47200 | 3.020 | 2.218 | ✓ |
| uf50-07 | SAT | SAT | 28627 | 1.832 | 1.399 | ✓ |
| uf50-08 | SAT | SAT | 54646 | 3.497 | 1.586 | ✓ |
| uf50-09 | SAT | SAT | 54861 | 3.511 | 1.382 | ✓ |
| uf50-010 | SAT | SAT | 27856 | 1.782 | 1.385 | ✓ |
| uf50-011 | SAT | SAT | 56046 | 3.586 | 1.390 | ✓ |
| uf50-012 | SAT | SAT | 46056 | 2.947 | 1.401 | ✓ |
| uf50-013 | SAT | SAT | 14376 | .920 | 1.385 | ✓ |
| uf50-014 | SAT | SAT | 25020 | 1.601 | 1.504 | ✓ |
| uf50-015 | SAT | SAT | 26674 | 1.707 | 1.381 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 40495 &nbsp;|&nbsp; mean time: 2.591 ms &nbsp;|&nbsp; mean wall: 1.483s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 63703 | 4.076 | 1.554 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 51698 | 3.308 | 1.386 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 64875 | 4.152 | 1.391 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 57161 | 3.658 | 1.403 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 62686 | 4.011 | 1.393 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 67380 | 4.312 | 1.864 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 106559 | 6.819 | 1.392 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 57356 | 3.670 | 1.392 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 87263 | 5.584 | 1.392 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 52164 | 3.338 | 1.419 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 71264 | 4.560 | 1.588 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 98183 | 6.283 | 1.382 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 48248 | 3.087 | 1.401 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 66897 | 4.281 | 1.500 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 50433 | 3.227 | 1.573 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 67058 &nbsp;|&nbsp; mean time: 4.291 ms &nbsp;|&nbsp; mean wall: 1.468s

---

## uf75 — SAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf75-01 | SAT | SAT | 191930 | 12.283 | 1.574 | ✓ |
| uf75-02 | SAT | SAT | 63974 | 4.094 | 1.401 | ✓ |
| uf75-03 | SAT | SAT | 53597 | 3.430 | 1.394 | ✓ |
| uf75-04 | SAT | SAT | 181274 | 11.601 | 1.392 | ✓ |
| uf75-05 | SAT | SAT | 189376 | 12.120 | 1.392 | ✓ |
| uf75-06 | SAT | SAT | 155185 | 9.931 | 1.536 | ✓ |
| uf75-07 | SAT | SAT | 332353 | 21.270 | 1.397 | ✓ |
| uf75-08 | SAT | SAT | 199959 | 12.797 | 1.387 | ✓ |
| uf75-09 | SAT | SAT | 174566 | 11.172 | 1.395 | ✓ |
| uf75-010 | SAT | SAT | 259428 | 16.603 | 1.389 | ✓ |
| uf75-011 | SAT | SAT | 89784 | 5.746 | 1.388 | ✓ |
| uf75-012 | SAT | SAT | 186738 | 11.951 | 1.413 | ✓ |
| uf75-013 | SAT | SAT | 37386 | 2.392 | 1.577 | ✓ |
| uf75-014 | SAT | SAT | 26200 | 1.676 | 1.436 | ✓ |
| uf75-015 | SAT | SAT | 173496 | 11.103 | 1.413 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 154349 &nbsp;|&nbsp; mean time: 9.878 ms &nbsp;|&nbsp; mean wall: 1.432s

---

## uuf75 — UNSAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf75-01 | UNSAT | UNSAT | 231132 | 14.792 | 1.562 | ✓ |
| uuf75-02 | UNSAT | UNSAT | 194234 | 12.430 | 1.586 | ✓ |
| uuf75-03 | UNSAT | UNSAT | 326639 | 20.904 | 1.409 | ✓ |
| uuf75-04 | UNSAT | UNSAT | 182805 | 11.699 | 1.396 | ✓ |
| uuf75-05 | UNSAT | UNSAT | 379659 | 24.298 | 1.401 | ✓ |
| uuf75-06 | UNSAT | UNSAT | 233602 | 14.950 | 1.683 | ✓ |
| uuf75-07 | UNSAT | UNSAT | 250754 | 16.048 | 1.391 | ✓ |
| uuf75-08 | UNSAT | UNSAT | 467743 | 29.935 | 1.604 | ✓ |
| uuf75-09 | UNSAT | UNSAT | 138944 | 8.892 | 1.570 | ✓ |
| uuf75-010 | UNSAT | UNSAT | 344971 | 22.078 | 1.398 | ✓ |
| uuf75-011 | UNSAT | UNSAT | 349204 | 22.349 | 1.404 | ✓ |
| uuf75-012 | UNSAT | UNSAT | 281959 | 18.045 | 1.589 | ✓ |
| uuf75-013 | UNSAT | UNSAT | 583023 | 37.313 | 2.069 | ✓ |
| uuf75-014 | UNSAT | UNSAT | 556820 | 35.636 | 1.602 | ✓ |
| uuf75-015 | UNSAT | UNSAT | 262217 | 16.781 | 1.576 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 318913 &nbsp;|&nbsp; mean time: 20.410 ms &nbsp;|&nbsp; mean wall: 1.549s

---

## uf100 — SAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf100-01 | SAT | SAT | 1027143 | 65.737 | 1.617 | ✓ |
| uf100-02 | SAT | SAT | 272070 | 17.412 | 1.546 | ✓ |
| uf100-03 | SAT | SAT | 623299 | 39.891 | 1.418 | ✓ |
| uf100-04 | SAT | UNSAT | 1331172 | 85.195 | 1.466 | ✗ |
| uf100-05 | SAT | SAT | 290017 | 18.561 | 1.757 | ✓ |
| uf100-06 | SAT | SAT | 24030 | 1.537 | 1.375 | ✓ |
| uf100-07 | SAT | SAT | 123379 | 7.896 | 1.401 | ✓ |
| uf100-08 | SAT | SAT | 840444 | 53.788 | 1.440 | ✓ |
| uf100-09 | SAT | SAT | 593588 | 37.989 | 1.581 | ✓ |
| uf100-010 | SAT | SAT | 482647 | 30.889 | 1.592 | ✓ |
| uf100-011 | SAT | SAT | 255314 | 16.340 | 1.587 | ✓ |
| uf100-012 | SAT | SAT | 130310 | 8.339 | 2.153 | ✓ |
| uf100-013 | SAT | SAT | 571741 | 36.591 | 1.432 | ✓ |
| uf100-014 | SAT | SAT | 534479 | 34.206 | 1.584 | ✓ |
| uf100-015 | SAT | SAT | 336131 | 21.512 | 1.564 | ✓ |

**Summary** — 14 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 495717 &nbsp;|&nbsp; mean time: 31.725 ms &nbsp;|&nbsp; mean wall: 1.567s

---

## uuf100 — UNSAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf100-01 | UNSAT | UNSAT | 974454 | 62.365 | 1.602 | ✓ |
| uuf100-02 | UNSAT | UNSAT | 695434 | 44.507 | 1.565 | ✓ |
| uuf100-03 | UNSAT | UNSAT | 935806 | 59.891 | 1.621 | ✓ |
| uuf100-04 | UNSAT | UNSAT | 1650741 | 105.647 | 1.607 | ✓ |
| uuf100-05 | UNSAT | UNSAT | 1265759 | 81.008 | 1.577 | ✓ |
| uuf100-06 | UNSAT | UNSAT | 1107765 | 70.896 | 1.574 | ✓ |
| uuf100-07 | UNSAT | UNSAT | 1177913 | 75.386 | 1.600 | ✓ |
| uuf100-08 | UNSAT | UNSAT | 1736080 | 111.109 | 1.629 | ✓ |
| uuf100-09 | UNSAT | UNSAT | 1512915 | 96.826 | 1.580 | ✓ |
| uuf100-010 | UNSAT | UNSAT | 1858555 | 118.947 | 1.613 | ✓ |
| uuf100-011 | UNSAT | UNSAT | 1250323 | 80.020 | 1.446 | ✓ |
| uuf100-012 | UNSAT | UNSAT | 1091732 | 69.870 | 1.583 | ✓ |
| uuf100-013 | UNSAT | UNSAT | 544475 | 34.846 | 1.586 | ✓ |
| uuf100-014 | UNSAT | UNSAT | 753780 | 48.241 | 1.603 | ✓ |
| uuf100-015 | UNSAT | UNSAT | 1258129 | 80.520 | 1.613 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1187590 &nbsp;|&nbsp; mean time: 76.005 ms &nbsp;|&nbsp; mean wall: 1.586s

---

## uf125 — SAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf125-01 | SAT | SAT | 217707 | 13.933 | 1.510 | ✓ |
| uf125-02 | SAT | SAT | 1192096 | 76.294 | 1.646 | ✓ |
| uf125-03 | SAT | SAT | 425436 | 27.227 | 1.583 | ✓ |
| uf125-04 | SAT | UNSAT | 1461121 | 93.511 | 1.665 | ✗ |
| uf125-05 | SAT | SAT | 592783 | 37.938 | 1.532 | ✓ |
| uf125-06 | SAT | SAT | 142488 | 9.119 | 1.572 | ✓ |
| uf125-07 | SAT | SAT | 681098 | 43.590 | 1.619 | ✓ |
| uf125-08 | SAT | SAT | 578136 | 37.000 | 1.592 | ✓ |
| uf125-09 | SAT | SAT | 465544 | 29.794 | 1.590 | ✓ |
| uf125-010 | SAT | UNSAT | 1546343 | 98.965 | 1.576 | ✗ |
| uf125-011 | SAT | UNSAT | 1510775 | 96.689 | 1.597 | ✗ |
| uf125-012 | SAT | UNSAT | 957155 | 61.257 | 1.558 | ✗ |
| uf125-013 | SAT | UNSAT | 1883713 | 120.557 | 1.650 | ✗ |
| uf125-014 | SAT | UNSAT | 1166596 | 74.662 | 1.556 | ✗ |
| uf125-015 | SAT | SAT | 1739581 | 111.333 | 1.628 | ✓ |

**Summary** — 9 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 970704 &nbsp;|&nbsp; mean time: 62.125 ms &nbsp;|&nbsp; mean wall: 1.591s

---

## uuf125 — UNSAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf125-01 | UNSAT | UNSAT | 1365085 | 87.365 | 1.536 | ✓ |
| uuf125-02 | UNSAT | UNSAT | 1262171 | 80.778 | 1.592 | ✓ |
| uuf125-03 | UNSAT | UNSAT | 1387336 | 88.789 | 1.604 | ✓ |
| uuf125-04 | UNSAT | UNSAT | 1169992 | 74.879 | 1.571 | ✓ |
| uuf125-05 | UNSAT | UNSAT | 1153541 | 73.826 | 1.582 | ✓ |
| uuf125-06 | UNSAT | UNSAT | 1240556 | 79.395 | 1.591 | ✓ |
| uuf125-07 | UNSAT | UNSAT | 2281300 | 146.003 | 1.665 | ✓ |
| uuf125-08 | UNSAT | UNSAT | 1541279 | 98.641 | 1.540 | ✓ |
| uuf125-09 | UNSAT | UNSAT | 1308846 | 83.766 | 1.544 | ✓ |
| uuf125-010 | UNSAT | UNSAT | 1341112 | 85.831 | 1.603 | ✓ |
| uuf125-011 | UNSAT | UNSAT | 1217648 | 77.929 | 1.590 | ✓ |
| uuf125-012 | UNSAT | UNSAT | 1759533 | 112.610 | 1.629 | ✓ |
| uuf125-013 | UNSAT | UNSAT | 1464777 | 93.745 | 1.569 | ✓ |
| uuf125-014 | UNSAT | UNSAT | 1232473 | 78.878 | 1.583 | ✓ |
| uuf125-015 | UNSAT | UNSAT | 1725305 | 110.419 | 1.629 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1430063 &nbsp;|&nbsp; mean time: 91.524 ms &nbsp;|&nbsp; mean wall: 1.588s

---

## Overall Summary

- **Grid**: 1x1
- **Total correct**: 113 / 120
- **Finished**: Sun Apr  5 17:41:24 UTC 2026
