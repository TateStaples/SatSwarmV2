# SatSwarm Benchmark Results

- **Grid config**: 1x1
- **Run timestamp**: 20260402_193957
- **Instances per dataset**: 15
- **FPGA slot**: 0
- **Host binary**: /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 39849 | 2.550 | 1.456 | ✓ |
| uf50-02 | SAT | SAT | 29983 | 1.918 | 1.390 | ✓ |
| uf50-03 | SAT | SAT | 56222 | 3.598 | 1.394 | ✓ |
| uf50-04 | SAT | SAT | 59630 | 3.816 | 1.393 | ✓ |
| uf50-05 | SAT | SAT | 9536 | .610 | 1.391 | ✓ |
| uf50-06 | SAT | SAT | 41085 | 2.629 | 1.420 | ✓ |
| uf50-07 | SAT | SAT | 22661 | 1.450 | 1.395 | ✓ |
| uf50-08 | SAT | SAT | 48593 | 3.109 | 1.396 | ✓ |
| uf50-09 | SAT | SAT | 48727 | 3.118 | 1.391 | ✓ |
| uf50-010 | SAT | SAT | 21879 | 1.400 | 1.408 | ✓ |
| uf50-011 | SAT | SAT | 49794 | 3.186 | 1.397 | ✓ |
| uf50-012 | SAT | SAT | 39978 | 2.558 | 1.392 | ✓ |
| uf50-013 | SAT | SAT | 8338 | .533 | 2.087 | ✓ |
| uf50-014 | SAT | SAT | 18999 | 1.215 | 1.395 | ✓ |
| uf50-015 | SAT | SAT | 20569 | 1.316 | 1.390 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 34389 &nbsp;|&nbsp; mean time: 2.200 ms &nbsp;|&nbsp; mean wall: 1.446s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 57646 | 3.689 | 1.366 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 45537 | 2.914 | 1.409 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 58854 | 3.766 | 1.390 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 51070 | 3.268 | 1.397 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 56553 | 3.619 | 1.391 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 61259 | 3.920 | 1.539 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 100363 | 6.423 | 1.394 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 51201 | 3.276 | 1.394 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 81096 | 5.190 | 1.389 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 45993 | 2.943 | 1.394 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 65046 | 4.162 | 1.393 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 92013 | 5.888 | 1.396 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 42156 | 2.697 | 2.251 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 60792 | 3.890 | 1.389 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 44337 | 2.837 | 1.403 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 60927 &nbsp;|&nbsp; mean time: 3.899 ms &nbsp;|&nbsp; mean wall: 1.459s

---

## uf75 — SAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf75-01 | SAT | SAT | 185775 | 11.889 | 1.396 | ✓ |
| uf75-02 | SAT | SAT | 57845 | 3.702 | 1.383 | ✓ |
| uf75-03 | SAT | SAT | 47472 | 3.038 | 1.394 | ✓ |
| uf75-04 | SAT | SAT | 175198 | 11.212 | 1.400 | ✓ |
| uf75-05 | SAT | SAT | 183298 | 11.731 | 1.391 | ✓ |
| uf75-06 | SAT | SAT | 149010 | 9.536 | 1.490 | ✓ |
| uf75-07 | SAT | SAT | 326194 | 20.876 | 1.404 | ✓ |
| uf75-08 | SAT | SAT | 193660 | 12.394 | 1.402 | ✓ |
| uf75-09 | SAT | SAT | 168323 | 10.772 | 1.389 | ✓ |
| uf75-010 | SAT | SAT | 253451 | 16.220 | 1.395 | ✓ |
| uf75-011 | SAT | SAT | 83561 | 5.347 | 1.405 | ✓ |
| uf75-012 | SAT | SAT | 180485 | 11.551 | 1.402 | ✓ |
| uf75-013 | SAT | SAT | 31402 | 2.009 | 1.381 | ✓ |
| uf75-014 | SAT | SAT | 19992 | 1.279 | 1.378 | ✓ |
| uf75-015 | SAT | SAT | 167331 | 10.709 | 1.403 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 148199 &nbsp;|&nbsp; mean time: 9.484 ms &nbsp;|&nbsp; mean wall: 1.400s

---

## uuf75 — UNSAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf75-01 | UNSAT | UNSAT | 225210 | 14.413 | 1.577 | ✓ |
| uuf75-02 | UNSAT | UNSAT | 188058 | 12.035 | 1.387 | ✓ |
| uuf75-03 | UNSAT | UNSAT | 320480 | 20.510 | 1.402 | ✓ |
| uuf75-04 | UNSAT | UNSAT | 176707 | 11.309 | 1.392 | ✓ |
| uuf75-05 | UNSAT | UNSAT | 373551 | 23.907 | 1.395 | ✓ |
| uuf75-06 | UNSAT | UNSAT | 227488 | 14.559 | 2.034 | ✓ |
| uuf75-07 | UNSAT | UNSAT | 244644 | 15.657 | 1.392 | ✓ |
| uuf75-08 | UNSAT | UNSAT | 461507 | 29.536 | 1.400 | ✓ |
| uuf75-09 | UNSAT | UNSAT | 132665 | 8.490 | 1.569 | ✓ |
| uuf75-010 | UNSAT | UNSAT | 338984 | 21.694 | 1.404 | ✓ |
| uuf75-011 | UNSAT | UNSAT | 343038 | 21.954 | 1.391 | ✓ |
| uuf75-012 | UNSAT | UNSAT | 275910 | 17.658 | 1.379 | ✓ |
| uuf75-013 | UNSAT | UNSAT | 576985 | 36.927 | 1.413 | ✓ |
| uuf75-014 | UNSAT | UNSAT | 550702 | 35.244 | 1.511 | ✓ |
| uuf75-015 | UNSAT | UNSAT | 256044 | 16.386 | 1.570 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 312798 &nbsp;|&nbsp; mean time: 20.019 ms &nbsp;|&nbsp; mean wall: 1.481s

---

## uf100 — SAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf100-01 | SAT | SAT | 1021057 | 65.347 | 1.621 | ✓ |
| uf100-02 | SAT | SAT | 266049 | 17.027 | 1.541 | ✓ |
| uf100-03 | SAT | SAT | 617060 | 39.491 | 1.413 | ✓ |
| uf100-04 | SAT | UNSAT | 1324803 | 84.787 | 1.635 | ✗ |
| uf100-05 | SAT | SAT | 283854 | 18.166 | 1.527 | ✓ |
| uf100-06 | SAT | SAT | 17893 | 1.145 | 1.473 | ✓ |
| uf100-07 | SAT | SAT | 117270 | 7.505 | 1.403 | ✓ |
| uf100-08 | SAT | SAT | 834324 | 53.396 | 1.436 | ✓ |
| uf100-09 | SAT | SAT | 587529 | 37.601 | 1.579 | ✓ |
| uf100-010 | SAT | SAT | 476635 | 30.504 | 1.397 | ✓ |
| uf100-011 | SAT | SAT | 249261 | 15.952 | 1.570 | ✓ |
| uf100-012 | SAT | SAT | 124373 | 7.959 | 1.381 | ✓ |
| uf100-013 | SAT | SAT | 565621 | 36.199 | 1.765 | ✓ |
| uf100-014 | SAT | SAT | 528476 | 33.822 | 1.586 | ✓ |
| uf100-015 | SAT | SAT | 329954 | 21.117 | 1.581 | ✓ |

**Summary** — 14 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 489610 &nbsp;|&nbsp; mean time: 31.335 ms &nbsp;|&nbsp; mean wall: 1.527s

---

## uuf100 — UNSAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf100-01 | UNSAT | UNSAT | 968268 | 61.969 | 1.647 | ✓ |
| uuf100-02 | UNSAT | UNSAT | 689238 | 44.111 | 1.538 | ✓ |
| uuf100-03 | UNSAT | UNSAT | 929753 | 59.504 | 1.613 | ✓ |
| uuf100-04 | UNSAT | UNSAT | 1644609 | 105.254 | 1.636 | ✓ |
| uuf100-05 | UNSAT | UNSAT | 1259539 | 80.610 | 1.537 | ✓ |
| uuf100-06 | UNSAT | UNSAT | 1101541 | 70.498 | 1.581 | ✓ |
| uuf100-07 | UNSAT | UNSAT | 1171773 | 74.993 | 1.595 | ✓ |
| uuf100-08 | UNSAT | UNSAT | 1729846 | 110.710 | 1.627 | ✓ |
| uuf100-09 | UNSAT | UNSAT | 1506765 | 96.432 | 1.572 | ✓ |
| uuf100-010 | UNSAT | UNSAT | 1852429 | 118.555 | 1.659 | ✓ |
| uuf100-011 | UNSAT | UNSAT | 1244234 | 79.630 | 1.550 | ✓ |
| uuf100-012 | UNSAT | UNSAT | 1085656 | 69.481 | 1.478 | ✓ |
| uuf100-013 | UNSAT | UNSAT | 538190 | 34.444 | 1.531 | ✓ |
| uuf100-014 | UNSAT | UNSAT | 747616 | 47.847 | 1.643 | ✓ |
| uuf100-015 | UNSAT | UNSAT | 1252144 | 80.137 | 1.585 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1181440 &nbsp;|&nbsp; mean time: 75.612 ms &nbsp;|&nbsp; mean wall: 1.586s

---

## uf125 — SAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf125-01 | SAT | SAT | 211366 | 13.527 | 1.506 | ✓ |
| uf125-02 | SAT | SAT | 1185978 | 75.902 | 1.454 | ✓ |
| uf125-03 | SAT | SAT | 419379 | 26.840 | 1.543 | ✓ |
| uf125-04 | SAT | UNSAT | 1454803 | 93.107 | 1.627 | ✗ |
| uf125-05 | SAT | SAT | 586808 | 37.555 | 1.492 | ✓ |
| uf125-06 | SAT | SAT | 136243 | 8.719 | 1.567 | ✓ |
| uf125-07 | SAT | SAT | 675019 | 43.201 | 1.421 | ✓ |
| uf125-08 | SAT | SAT | 572147 | 36.617 | 1.587 | ✓ |
| uf125-09 | SAT | SAT | 459430 | 29.403 | 1.592 | ✓ |
| uf125-010 | SAT | UNSAT | 1540308 | 98.579 | 1.467 | ✗ |
| uf125-011 | SAT | UNSAT | 1504669 | 96.298 | 1.504 | ✗ |
| uf125-012 | SAT | UNSAT | 951038 | 60.866 | 1.562 | ✗ |
| uf125-013 | SAT | UNSAT | 1877404 | 120.153 | 1.645 | ✗ |
| uf125-014 | SAT | UNSAT | 1160484 | 74.270 | 1.552 | ✗ |
| uf125-015 | SAT | SAT | 1733489 | 110.943 | 1.632 | ✓ |

**Summary** — 9 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 964571 &nbsp;|&nbsp; mean time: 61.732 ms &nbsp;|&nbsp; mean wall: 1.543s

---

## uuf125 — UNSAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf125-01 | UNSAT | UNSAT | 1359130 | 86.984 | 1.586 | ✓ |
| uuf125-02 | UNSAT | UNSAT | 1256044 | 80.386 | 1.552 | ✓ |
| uuf125-03 | UNSAT | UNSAT | 1381165 | 88.394 | 1.934 | ✓ |
| uuf125-04 | UNSAT | UNSAT | 1163764 | 74.480 | 1.535 | ✓ |
| uuf125-05 | UNSAT | UNSAT | 1147215 | 73.421 | 1.597 | ✓ |
| uuf125-06 | UNSAT | UNSAT | 1234410 | 79.002 | 1.598 | ✓ |
| uuf125-07 | UNSAT | UNSAT | 2275009 | 145.600 | 1.658 | ✓ |
| uuf125-08 | UNSAT | UNSAT | 1535231 | 98.254 | 1.542 | ✓ |
| uuf125-09 | UNSAT | UNSAT | 1302722 | 83.374 | 1.578 | ✓ |
| uuf125-010 | UNSAT | UNSAT | 1334920 | 85.434 | 1.831 | ✓ |
| uuf125-011 | UNSAT | UNSAT | 1211322 | 77.524 | 1.587 | ✓ |
| uuf125-012 | UNSAT | UNSAT | 1753519 | 112.225 | 1.642 | ✓ |
| uuf125-013 | UNSAT | UNSAT | 1458732 | 93.358 | 1.565 | ✓ |
| uuf125-014 | UNSAT | UNSAT | 1226424 | 78.491 | 1.568 | ✓ |
| uuf125-015 | UNSAT | UNSAT | 1719113 | 110.023 | 1.624 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1423914 &nbsp;|&nbsp; mean time: 91.130 ms &nbsp;|&nbsp; mean wall: 1.626s

---

## Overall Summary

- **Grid**: 1x1
- **Total correct**: 113 / 120
- **Finished**: Thu Apr  2 19:43:01 UTC 2026
