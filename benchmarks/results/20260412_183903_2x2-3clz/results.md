# SatSwarm Benchmark Results

- **Grid config**: 2x2-3clz
- **Run timestamp**: 20260412_183903
- **Instances per dataset**: 25
- **FPGA slot**: 0
- **Host binary**: /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 36312 | 2.323 | 1.511 | ✓ |
| uf50-02 | SAT | SAT | 15691 | 1.004 | 1.377 | ✓ |
| uf50-03 | SAT | SAT | 8629 | .552 | 1.394 | ✓ |
| uf50-04 | SAT | SAT | 19978 | 1.278 | 1.394 | ✓ |
| uf50-05 | SAT | SAT | 9187 | .587 | 1.777 | ✓ |
| uf50-06 | SAT | SAT | 19332 | 1.237 | 1.395 | ✓ |
| uf50-07 | SAT | SAT | 26713 | 1.709 | 1.393 | ✓ |
| uf50-08 | SAT | SAT | 19620 | 1.255 | 1.383 | ✓ |
| uf50-09 | SAT | SAT | 16487 | 1.055 | 1.389 | ✓ |
| uf50-010 | SAT | SAT | 21736 | 1.391 | 1.391 | ✓ |
| uf50-011 | SAT | SAT | 24540 | 1.570 | 1.398 | ✓ |
| uf50-012 | SAT | SAT | 12260 | .784 | 1.391 | ✓ |
| uf50-013 | SAT | SAT | 8218 | .525 | 1.495 | ✓ |
| uf50-014 | SAT | SAT | 19027 | 1.217 | 1.388 | ✓ |
| uf50-015 | SAT | SAT | 9718 | .621 | 1.388 | ✓ |
| uf50-016 | SAT | SAT | 22856 | 1.462 | 1.391 | ✓ |
| uf50-017 | SAT | SAT | 15320 | .980 | 1.382 | ✓ |
| uf50-018 | SAT | SAT | 12451 | .796 | 1.387 | ✓ |
| uf50-019 | SAT | SAT | 42706 | 2.733 | 1.391 | ✓ |
| uf50-020 | SAT | SAT | 13138 | .840 | 2.158 | ✓ |
| uf50-021 | SAT | SAT | 9486 | .607 | 1.389 | ✓ |
| uf50-022 | SAT | SAT | 13392 | .857 | 1.391 | ✓ |
| uf50-023 | SAT | SAT | 7130 | .456 | 1.430 | ✓ |
| uf50-024 | SAT | SAT | 17810 | 1.139 | 1.549 | ✓ |
| uf50-025 | SAT | SAT | 5615 | .359 | 1.390 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 17094 &nbsp;|&nbsp; mean time: 1.094 ms &nbsp;|&nbsp; mean wall: 1.452s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 53998 | 3.455 | 1.562 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 44444 | 2.844 | 2.258 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 24595 | 1.574 | 1.560 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 47774 | 3.057 | 1.390 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 51995 | 3.327 | 1.392 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 59973 | 3.838 | 1.392 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 57573 | 3.684 | 1.385 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 50633 | 3.240 | 1.389 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 73399 | 4.697 | 1.404 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 31680 | 2.027 | 1.392 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 66303 | 4.243 | 1.394 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 62874 | 4.023 | 1.428 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 35535 | 2.274 | 1.587 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 54910 | 3.514 | 1.555 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 44833 | 2.869 | 1.383 | ✓ |
| uuf50-016 | UNSAT | UNSAT | 33757 | 2.160 | 1.392 | ✓ |
| uuf50-017 | UNSAT | UNSAT | 47409 | 3.034 | 1.970 | ✓ |
| uuf50-018 | UNSAT | UNSAT | 46715 | 2.989 | 1.385 | ✓ |
| uuf50-019 | UNSAT | UNSAT | 62571 | 4.004 | 1.389 | ✓ |
| uuf50-020 | UNSAT | UNSAT | 81350 | 5.206 | 1.400 | ✓ |
| uuf50-021 | UNSAT | UNSAT | 96856 | 6.198 | 1.412 | ✓ |
| uuf50-022 | UNSAT | UNSAT | 67946 | 4.348 | 1.403 | ✓ |
| uuf50-023 | UNSAT | UNSAT | 60409 | 3.866 | 1.423 | ✓ |
| uuf50-024 | UNSAT | UNSAT | 40658 | 2.602 | 1.555 | ✓ |
| uuf50-025 | UNSAT | UNSAT | 51451 | 3.292 | 1.497 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 53985 &nbsp;|&nbsp; mean time: 3.455 ms &nbsp;|&nbsp; mean wall: 1.491s

---

## uf75 — SAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf75-01 | SAT | SAT | 7308 | .467 | 1.601 | ✓ |
| uf75-02 | SAT | SAT | 19223 | 1.230 | 1.568 | ✓ |
| uf75-03 | SAT | SAT | 41970 | 2.686 | 1.389 | ✓ |
| uf75-04 | SAT | SAT | 221277 | 14.161 | 1.404 | ✓ |
| uf75-05 | SAT | SAT | 136077 | 8.708 | 1.382 | ✓ |
| uf75-06 | SAT | SAT | 88079 | 5.637 | 1.392 | ✓ |
| uf75-07 | SAT | SAT | 14309 | .915 | 1.815 | ✓ |
| uf75-08 | SAT | SAT | 50394 | 3.225 | 1.399 | ✓ |
| uf75-09 | SAT | SAT | 45252 | 2.896 | 1.387 | ✓ |
| uf75-010 | SAT | SAT | 30087 | 1.925 | 1.428 | ✓ |
| uf75-011 | SAT | SAT | 129038 | 8.258 | 1.563 | ✓ |
| uf75-012 | SAT | SAT | 32795 | 2.098 | 1.382 | ✓ |
| uf75-013 | SAT | SAT | 36181 | 2.315 | 1.404 | ✓ |
| uf75-014 | SAT | SAT | 13646 | .873 | 1.378 | ✓ |
| uf75-015 | SAT | SAT | 24650 | 1.577 | 1.533 | ✓ |
| uf75-016 | SAT | SAT | 117445 | 7.516 | 1.391 | ✓ |
| uf75-017 | SAT | SAT | 33974 | 2.174 | 1.389 | ✓ |
| uf75-018 | SAT | SAT | 9258 | .592 | 1.424 | ✓ |
| uf75-019 | SAT | SAT | 127780 | 8.177 | 1.566 | ✓ |
| uf75-020 | SAT | SAT | 150844 | 9.654 | 1.389 | ✓ |
| uf75-021 | SAT | SAT | 92583 | 5.925 | 1.387 | ✓ |
| uf75-022 | SAT | SAT | 18763 | 1.200 | 1.795 | ✓ |
| uf75-023 | SAT | SAT | 282603 | 18.086 | 1.423 | ✓ |
| uf75-024 | SAT | SAT | 192835 | 12.341 | 1.391 | ✓ |
| uf75-025 | SAT | SAT | 6627 | .424 | 1.378 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 76919 &nbsp;|&nbsp; mean time: 4.922 ms &nbsp;|&nbsp; mean wall: 1.462s

---

## uuf75 — UNSAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf75-01 | UNSAT | UNSAT | 131698 | 8.428 | 1.388 | ✓ |
| uuf75-02 | UNSAT | UNSAT | 145660 | 9.322 | 1.388 | ✓ |
| uuf75-03 | UNSAT | UNSAT | 208696 | 13.356 | 1.390 | ✓ |
| uuf75-04 | UNSAT | UNSAT | 199498 | 12.767 | 1.386 | ✓ |
| uuf75-05 | UNSAT | UNSAT | 239060 | 15.299 | 1.428 | ✓ |
| uuf75-06 | UNSAT | UNSAT | 351765 | 22.512 | 1.397 | ✓ |
| uuf75-07 | UNSAT | UNSAT | 114578 | 7.332 | 1.571 | ✓ |
| uuf75-08 | UNSAT | UNSAT | 315436 | 20.187 | 1.399 | ✓ |
| uuf75-09 | UNSAT | UNSAT | 166416 | 10.650 | 1.382 | ✓ |
| uuf75-010 | UNSAT | UNSAT | 229355 | 14.678 | 1.596 | ✓ |
| uuf75-011 | UNSAT | UNSAT | 266627 | 17.064 | 1.412 | ✓ |
| uuf75-012 | UNSAT | UNSAT | 288875 | 18.488 | 2.187 | ✓ |
| uuf75-013 | UNSAT | UNSAT | 253111 | 16.199 | 1.386 | ✓ |
| uuf75-014 | UNSAT | UNSAT | 315504 | 20.192 | 1.394 | ✓ |
| uuf75-015 | UNSAT | UNSAT | 264092 | 16.901 | 1.382 | ✓ |
| uuf75-016 | UNSAT | UNSAT | 281716 | 18.029 | 1.393 | ✓ |
| uuf75-017 | UNSAT | UNSAT | 303757 | 19.440 | 1.390 | ✓ |
| uuf75-018 | UNSAT | UNSAT | 221074 | 14.148 | 1.379 | ✓ |
| uuf75-019 | UNSAT | UNSAT | 207860 | 13.303 | 1.399 | ✓ |
| uuf75-020 | UNSAT | UNSAT | 399826 | 25.588 | 1.544 | ✓ |
| uuf75-021 | UNSAT | UNSAT | 186180 | 11.915 | 1.577 | ✓ |
| uuf75-022 | UNSAT | UNSAT | 311125 | 19.912 | 1.393 | ✓ |
| uuf75-023 | UNSAT | UNSAT | 355317 | 22.740 | 1.400 | ✓ |
| uuf75-024 | UNSAT | UNSAT | 198924 | 12.731 | 1.579 | ✓ |
| uuf75-025 | UNSAT | UNSAT | 207620 | 13.287 | 1.387 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 246550 &nbsp;|&nbsp; mean time: 15.779 ms &nbsp;|&nbsp; mean wall: 1.461s

---

## uf100 — SAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf100-01 | SAT | SAT | 80630 | 5.160 | 1.554 | ✓ |
| uf100-02 | SAT | SAT | 259939 | 16.636 | 1.537 | ✓ |
| uf100-03 | SAT | SAT | 133645 | 8.553 | 1.578 | ✓ |
| uf100-04 | SAT | SAT | 493502 | 31.584 | 1.404 | ✓ |
| uf100-05 | SAT | SAT | 149401 | 9.561 | 1.571 | ✓ |
| uf100-06 | SAT | SAT | 9670 | .618 | 1.377 | ✓ |
| uf100-07 | SAT | SAT | 42035 | 2.690 | 1.391 | ✓ |
| uf100-08 | SAT | SAT | 258888 | 16.568 | 1.401 | ✓ |
| uf100-09 | SAT | SAT | 364814 | 23.348 | 2.212 | ✓ |
| uf100-010 | SAT | SAT | 15316 | .980 | 1.407 | ✓ |
| uf100-011 | SAT | SAT | 234245 | 14.991 | 1.568 | ✓ |
| uf100-012 | SAT | SAT | 95148 | 6.089 | 1.386 | ✓ |
| uf100-013 | SAT | SAT | 113947 | 7.292 | 1.400 | ✓ |
| uf100-014 | SAT | SAT | 247944 | 15.868 | 1.398 | ✓ |
| uf100-015 | SAT | SAT | 860085 | 55.045 | 1.468 | ✓ |
| uf100-016 | SAT | UNSAT | 1056356 | 67.606 | 2.331 | ✗ |
| uf100-017 | SAT | SAT | 738917 | 47.290 | 1.563 | ✓ |
| uf100-018 | SAT | SAT | 268793 | 17.202 | 1.564 | ✓ |
| uf100-019 | SAT | SAT | 10234 | .654 | 1.373 | ✓ |
| uf100-020 | SAT | SAT | 88178 | 5.643 | 1.397 | ✓ |
| uf100-021 | SAT | SAT | 199707 | 12.781 | 1.431 | ✓ |
| uf100-022 | SAT | SAT | 1057374 | 67.671 | 1.621 | ✓ |
| uf100-023 | SAT | SAT | 229368 | 14.679 | 1.858 | ✓ |
| uf100-024 | SAT | SAT | 12103 | .774 | 1.377 | ✓ |
| uf100-025 | SAT | SAT | 438143 | 28.041 | 1.428 | ✓ |

**Summary** — 24 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 298335 &nbsp;|&nbsp; mean time: 19.093 ms &nbsp;|&nbsp; mean wall: 1.543s

---

## uuf100 — UNSAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf100-01 | UNSAT | UNSAT | 810611 | 51.879 | 1.585 | ✓ |
| uuf100-02 | UNSAT | UNSAT | 1494033 | 95.618 | 1.631 | ✓ |
| uuf100-03 | UNSAT | UNSAT | 816930 | 52.283 | 1.548 | ✓ |
| uuf100-04 | UNSAT | UNSAT | 1439746 | 92.143 | 1.632 | ✓ |
| uuf100-05 | UNSAT | UNSAT | 1318157 | 84.362 | 1.985 | ✓ |
| uuf100-06 | UNSAT | UNSAT | 881960 | 56.445 | 1.561 | ✓ |
| uuf100-07 | UNSAT | UNSAT | 777153 | 49.737 | 1.597 | ✓ |
| uuf100-08 | UNSAT | UNSAT | 820905 | 52.537 | 1.598 | ✓ |
| uuf100-09 | UNSAT | UNSAT | 972194 | 62.220 | 1.613 | ✓ |
| uuf100-010 | UNSAT | UNSAT | 749762 | 47.984 | 1.582 | ✓ |
| uuf100-011 | UNSAT | UNSAT | 1359066 | 86.980 | 1.631 | ✓ |
| uuf100-012 | UNSAT | UNSAT | 555061 | 35.523 | 1.471 | ✓ |
| uuf100-013 | UNSAT | UNSAT | 701401 | 44.889 | 1.411 | ✓ |
| uuf100-014 | UNSAT | UNSAT | 934154 | 59.785 | 1.605 | ✓ |
| uuf100-015 | UNSAT | UNSAT | 1079473 | 69.086 | 1.614 | ✓ |
| uuf100-016 | UNSAT | UNSAT | 1279064 | 81.860 | 1.605 | ✓ |
| uuf100-017 | UNSAT | UNSAT | 1283909 | 82.170 | 1.597 | ✓ |
| uuf100-018 | UNSAT | UNSAT | 1132414 | 72.474 | 1.582 | ✓ |
| uuf100-019 | UNSAT | UNSAT | 1189252 | 76.112 | 1.453 | ✓ |
| uuf100-020 | UNSAT | UNSAT | 701729 | 44.910 | 1.567 | ✓ |
| uuf100-021 | UNSAT | UNSAT | 678224 | 43.406 | 1.596 | ✓ |
| uuf100-022 | UNSAT | UNSAT | 1054091 | 67.461 | 1.615 | ✓ |
| uuf100-023 | UNSAT | UNSAT | 675828 | 43.252 | 1.574 | ✓ |
| uuf100-024 | UNSAT | UNSAT | 1247507 | 79.840 | 1.625 | ✓ |
| uuf100-025 | UNSAT | UNSAT | 649973 | 41.598 | 1.585 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 984103 &nbsp;|&nbsp; mean time: 62.982 ms &nbsp;|&nbsp; mean wall: 1.594s

---

## uf125 — SAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf125-01 | SAT | SAT | 245148 | 15.689 | 1.399 | ✓ |
| uf125-02 | SAT | UNSAT | 804124 | 51.463 | 1.429 | ✗ |
| uf125-03 | SAT | SAT | 74718 | 4.781 | 1.550 | ✓ |
| uf125-04 | SAT | SAT | 331483 | 21.214 | 1.413 | ✓ |
| uf125-05 | SAT | SAT | 593767 | 38.001 | 1.403 | ✓ |
| uf125-06 | SAT | SAT | 120833 | 7.733 | 1.572 | ✓ |
| uf125-07 | SAT | SAT | 627981 | 40.190 | 1.418 | ✓ |
| uf125-08 | SAT | UNSAT | 1141712 | 73.069 | 2.207 | ✗ |
| uf125-09 | SAT | UNSAT | 1391757 | 89.072 | 1.609 | ✗ |
| uf125-010 | SAT | UNSAT | 779607 | 49.894 | 1.560 | ✗ |
| uf125-011 | SAT | SAT | 1083519 | 69.345 | 1.610 | ✓ |
| uf125-012 | SAT | SAT | 458702 | 29.356 | 1.565 | ✓ |
| uf125-013 | SAT | SAT | 652925 | 41.787 | 1.418 | ✓ |
| uf125-014 | SAT | UNSAT | 1067122 | 68.295 | 1.615 | ✗ |
| uf125-015 | SAT | UNSAT | 1358192 | 86.924 | 1.548 | ✗ |
| uf125-016 | SAT | SAT | 95443 | 6.108 | 1.515 | ✓ |
| uf125-017 | SAT | UNSAT | 996886 | 63.800 | 1.452 | ✗ |
| uf125-018 | SAT | UNSAT | 1112628 | 71.208 | 1.611 | ✗ |
| uf125-019 | SAT | SAT | 34796 | 2.226 | 1.525 | ✓ |
| uf125-020 | SAT | SAT | 134158 | 8.586 | 1.400 | ✓ |
| uf125-021 | SAT | SAT | 1241284 | 79.442 | 1.462 | ✓ |
| uf125-022 | SAT | SAT | 533219 | 34.126 | 2.166 | ✓ |
| uf125-023 | SAT | SAT | 44829 | 2.869 | 1.566 | ✓ |
| uf125-024 | SAT | SAT | 442311 | 28.307 | 1.418 | ✓ |
| uf125-025 | SAT | UNSAT | 1570202 | 100.492 | 1.659 | ✗ |

**Summary** — 16 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 677493 &nbsp;|&nbsp; mean time: 43.359 ms &nbsp;|&nbsp; mean wall: 1.563s

---

## uuf125 — UNSAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf125-01 | UNSAT | UNSAT | 1256746 | 80.431 | 1.553 | ✓ |
| uuf125-02 | UNSAT | UNSAT | 1339032 | 85.698 | 1.597 | ✓ |
| uuf125-03 | UNSAT | UNSAT | 1514458 | 96.925 | 1.617 | ✓ |
| uuf125-04 | UNSAT | UNSAT | 1233804 | 78.963 | 1.551 | ✓ |
| uuf125-05 | UNSAT | UNSAT | 1469016 | 94.017 | 1.609 | ✓ |
| uuf125-06 | UNSAT | UNSAT | 1274372 | 81.559 | 1.581 | ✓ |
| uuf125-07 | UNSAT | UNSAT | 1068842 | 68.405 | 1.574 | ✓ |
| uuf125-08 | UNSAT | UNSAT | 1698630 | 108.712 | 1.636 | ✓ |
| uuf125-09 | UNSAT | UNSAT | 1043898 | 66.809 | 1.553 | ✓ |
| uuf125-010 | UNSAT | UNSAT | 1098611 | 70.311 | 1.591 | ✓ |
| uuf125-011 | UNSAT | UNSAT | 1375899 | 88.057 | 1.647 | ✓ |
| uuf125-012 | UNSAT | UNSAT | 1312610 | 84.007 | 1.593 | ✓ |
| uuf125-013 | UNSAT | UNSAT | 1183027 | 75.713 | 1.603 | ✓ |
| uuf125-014 | UNSAT | UNSAT | 1480885 | 94.776 | 1.618 | ✓ |
| uuf125-015 | UNSAT | UNSAT | 1187458 | 75.997 | 1.576 | ✓ |
| uuf125-016 | UNSAT | UNSAT | 1684860 | 107.831 | 1.625 | ✓ |
| uuf125-017 | UNSAT | UNSAT | 1050690 | 67.244 | 1.553 | ✓ |
| uuf125-018 | UNSAT | UNSAT | 1456294 | 93.202 | 1.542 | ✓ |
| uuf125-019 | UNSAT | UNSAT | 1198257 | 76.688 | 1.590 | ✓ |
| uuf125-020 | UNSAT | UNSAT | 1204093 | 77.061 | 1.592 | ✓ |
| uuf125-021 | UNSAT | UNSAT | 1117045 | 71.490 | 1.588 | ✓ |
| uuf125-022 | UNSAT | UNSAT | 1411925 | 90.363 | 1.608 | ✓ |
| uuf125-023 | UNSAT | UNSAT | 1319500 | 84.448 | 1.591 | ✓ |
| uuf125-024 | UNSAT | UNSAT | 1187057 | 75.971 | 1.578 | ✓ |
| uuf125-025 | UNSAT | UNSAT | 1096608 | 70.182 | 1.597 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1290544 &nbsp;|&nbsp; mean time: 82.594 ms &nbsp;|&nbsp; mean wall: 1.590s

---

## uf150 — SAT, 150 vars, 645 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf150-01 | SAT | UNSAT | 1364309 | 87.315 | 1.607 | ✗ |
| uf150-02 | SAT | UNSAT | 1334432 | 85.403 | 1.587 | ✗ |
| uf150-03 | SAT | UNSAT | 1399679 | 89.579 | 1.598 | ✗ |
| uf150-04 | SAT | UNSAT | 1762351 | 112.790 | 1.620 | ✗ |
| uf150-05 | SAT | UNSAT | 896025 | 57.345 | 1.539 | ✗ |
| uf150-06 | SAT | SAT | 1580120 | 101.127 | 1.641 | ✓ |
| uf150-07 | SAT | UNSAT | 1371867 | 87.799 | 1.641 | ✗ |
| uf150-08 | SAT | SAT | 194343 | 12.437 | 1.518 | ✓ |
| uf150-09 | SAT | SAT | 373071 | 23.876 | 1.403 | ✓ |
| uf150-010 | SAT | SAT | 257866 | 16.503 | 1.389 | ✓ |
| uf150-011 | SAT | SAT | 613179 | 39.243 | 1.418 | ✓ |
| uf150-012 | SAT | UNSAT | 1452726 | 92.974 | 1.647 | ✗ |
| uf150-013 | SAT | SAT | 834800 | 53.427 | 1.555 | ✓ |
| uf150-014 | SAT | UNSAT | 1071990 | 68.607 | 1.537 | ✗ |
| uf150-015 | SAT | UNSAT | 1219830 | 78.069 | 1.602 | ✗ |
| uf150-016 | SAT | SAT | 408707 | 26.157 | 1.547 | ✓ |
| uf150-017 | SAT | UNSAT | 1761654 | 112.745 | 1.679 | ✗ |
| uf150-018 | SAT | SAT | 714093 | 45.701 | 1.523 | ✓ |
| uf150-019 | SAT | UNSAT | 1650592 | 105.637 | 1.661 | ✗ |
| uf150-020 | SAT | SAT | 984989 | 63.039 | 1.550 | ✓ |
| uf150-021 | SAT | SAT | 1362235 | 87.183 | 1.531 | ✓ |
| uf150-022 | SAT | SAT | 1057815 | 67.700 | 1.584 | ✓ |
| uf150-023 | SAT | UNSAT | 1509249 | 96.591 | 1.625 | ✗ |
| uf150-024 | SAT | SAT | 843196 | 53.964 | 1.558 | ✓ |
| uf150-025 | SAT | UNSAT | 1398170 | 89.482 | 1.629 | ✗ |

**Summary** — 12 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1096691 &nbsp;|&nbsp; mean time: 70.188 ms &nbsp;|&nbsp; mean wall: 1.567s

---

## uuf150 — UNSAT, 150 vars, 645 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf150-01 | UNSAT | UNSAT | 1248491 | 79.903 | 1.597 | ✓ |
| uuf150-02 | UNSAT | UNSAT | 1244880 | 79.672 | 1.606 | ✓ |
| uuf150-03 | UNSAT | UNSAT | 1762299 | 112.787 | 1.638 | ✓ |
| uuf150-04 | UNSAT | UNSAT | 1485504 | 95.072 | 1.577 | ✓ |
| uuf150-05 | UNSAT | UNSAT | 1492495 | 95.519 | 1.595 | ✓ |
| uuf150-06 | UNSAT | UNSAT | 1083603 | 69.350 | 1.571 | ✓ |
| uuf150-07 | UNSAT | UNSAT | 1257469 | 80.478 | 1.611 | ✓ |
| uuf150-08 | UNSAT | UNSAT | 1418950 | 90.812 | 1.609 | ✓ |
| uuf150-09 | UNSAT | UNSAT | 1319339 | 84.437 | 1.591 | ✓ |
| uuf150-010 | UNSAT | UNSAT | 1408910 | 90.170 | 1.554 | ✓ |
| uuf150-011 | UNSAT | UNSAT | 1620910 | 103.738 | 1.614 | ✓ |
| uuf150-012 | UNSAT | UNSAT | 1684328 | 107.796 | 1.590 | ✓ |
| uuf150-013 | UNSAT | UNSAT | 1628721 | 104.238 | 1.586 | ✓ |
| uuf150-014 | UNSAT | UNSAT | 1504129 | 96.264 | 1.613 | ✓ |
| uuf150-015 | UNSAT | UNSAT | 1522180 | 97.419 | 1.595 | ✓ |
| uuf150-016 | UNSAT | UNSAT | 1278152 | 81.801 | 2.284 | ✓ |
| uuf150-017 | UNSAT | UNSAT | 2079297 | 133.075 | 1.639 | ✓ |
| uuf150-018 | UNSAT | UNSAT | 1284636 | 82.216 | 1.542 | ✓ |
| uuf150-019 | UNSAT | UNSAT | 1608639 | 102.952 | 1.612 | ✓ |
| uuf150-020 | UNSAT | UNSAT | 1407949 | 90.108 | 1.582 | ✓ |
| uuf150-021 | UNSAT | UNSAT | 1819922 | 116.475 | 1.628 | ✓ |
| uuf150-022 | UNSAT | UNSAT | 1861519 | 119.137 | 1.590 | ✓ |
| uuf150-023 | UNSAT | UNSAT | 1472320 | 94.228 | 1.601 | ✓ |
| uuf150-024 | UNSAT | UNSAT | 1530336 | 97.941 | 1.605 | ✓ |
| uuf150-025 | UNSAT | UNSAT | 1863463 | 119.261 | 1.599 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1515537 &nbsp;|&nbsp; mean time: 96.994 ms &nbsp;|&nbsp; mean wall: 1.625s

---

## uf175 — SAT, 175 vars, 753 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf175-01 | SAT | UNSAT | 2415596 | 154.598 | 1.599 | ✗ |
| uf175-02 | SAT | UNSAT | 1877990 | 120.191 | 1.556 | ✗ |
| uf175-03 | SAT | UNSAT | 2043181 | 130.763 | 1.609 | ✗ |
| uf175-04 | SAT | SAT | 275269 | 17.617 | 1.477 | ✓ |
| uf175-05 | SAT | UNSAT | 1609207 | 102.989 | 1.648 | ✗ |
| uf175-06 | SAT | UNSAT | 1801638 | 115.304 | 1.609 | ✗ |
| uf175-07 | SAT | UNSAT | 1629482 | 104.286 | 1.587 | ✗ |
| uf175-08 | SAT | UNSAT | 1609294 | 102.994 | 1.591 | ✗ |
| uf175-09 | SAT | UNSAT | 2336107 | 149.510 | 1.634 | ✗ |
| uf175-010 | SAT | UNSAT | 1792849 | 114.742 | 1.557 | ✗ |
| uf175-011 | SAT | UNSAT | 1665038 | 106.562 | 1.579 | ✗ |
| uf175-012 | SAT | UNSAT | 2691644 | 172.265 | 1.687 | ✗ |
| uf175-013 | SAT | UNSAT | 2495927 | 159.739 | 1.603 | ✗ |
| uf175-014 | SAT | UNSAT | 2358585 | 150.949 | 1.578 | ✗ |
| uf175-015 | SAT | SAT | 252310 | 16.147 | 1.459 | ✓ |
| uf175-016 | SAT | SAT | 2536710 | 162.349 | 1.528 | ✓ |
| uf175-017 | SAT | UNSAT | 2260328 | 144.660 | 1.576 | ✗ |
| uf175-018 | SAT | SAT | 806076 | 51.588 | 1.494 | ✓ |
| uf175-019 | SAT | UNSAT | 2123127 | 135.880 | 1.553 | ✗ |
| uf175-020 | SAT | UNSAT | 2202831 | 140.981 | 1.588 | ✗ |
| uf175-021 | SAT | UNSAT | 1979916 | 126.714 | 1.578 | ✗ |
| uf175-022 | SAT | UNSAT | 1843833 | 118.005 | 1.583 | ✗ |
| uf175-023 | SAT | UNSAT | 1924148 | 123.145 | 1.593 | ✗ |
| uf175-024 | SAT | UNSAT | 1961879 | 125.560 | 1.605 | ✗ |
| uf175-025 | SAT | UNSAT | 3043665 | 194.794 | 1.677 | ✗ |

**Summary** — 4 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1901465 &nbsp;|&nbsp; mean time: 121.693 ms &nbsp;|&nbsp; mean wall: 1.581s

---

## uuf175 — UNSAT, 175 vars, 753 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf175-01 | UNSAT | UNSAT | 2188255 | 140.048 | 1.645 | ✓ |
| uuf175-02 | UNSAT | UNSAT | 2028415 | 129.818 | 1.577 | ✓ |
| uuf175-03 | UNSAT | UNSAT | 1609851 | 103.030 | 1.577 | ✓ |
| uuf175-04 | UNSAT | UNSAT | 2347531 | 150.241 | 1.642 | ✓ |
| uuf175-05 | UNSAT | UNSAT | 2501882 | 160.120 | 1.597 | ✓ |
| uuf175-06 | UNSAT | UNSAT | 1296821 | 82.996 | 1.517 | ✓ |
| uuf175-07 | UNSAT | UNSAT | 2338610 | 149.671 | 1.651 | ✓ |
| uuf175-08 | UNSAT | UNSAT | 2057690 | 131.692 | 1.652 | ✓ |
| uuf175-09 | UNSAT | UNSAT | 2394899 | 153.273 | 1.618 | ✓ |
| uuf175-010 | UNSAT | UNSAT | 2227608 | 142.566 | 1.583 | ✓ |
| uuf175-011 | UNSAT | UNSAT | 1881401 | 120.409 | 1.563 | ✓ |
| uuf175-012 | UNSAT | UNSAT | 1672652 | 107.049 | 1.581 | ✓ |
| uuf175-013 | UNSAT | UNSAT | 1607546 | 102.882 | 1.593 | ✓ |
| uuf175-014 | UNSAT | UNSAT | 2115283 | 135.378 | 1.623 | ✓ |
| uuf175-015 | UNSAT | UNSAT | 1753938 | 112.252 | 1.620 | ✓ |
| uuf175-016 | UNSAT | UNSAT | 1457613 | 93.287 | 1.577 | ✓ |
| uuf175-017 | UNSAT | UNSAT | 2134067 | 136.580 | 1.635 | ✓ |
| uuf175-018 | UNSAT | UNSAT | 1650996 | 105.663 | 1.561 | ✓ |
| uuf175-019 | UNSAT | UNSAT | 1741805 | 111.475 | 1.591 | ✓ |
| uuf175-020 | UNSAT | UNSAT | 1656135 | 105.992 | 1.584 | ✓ |
| uuf175-021 | UNSAT | UNSAT | 1817488 | 116.319 | 2.392 | ✓ |
| uuf175-022 | UNSAT | UNSAT | 1337750 | 85.616 | 1.555 | ✓ |
| uuf175-023 | UNSAT | UNSAT | 1460146 | 93.449 | 1.613 | ✓ |
| uuf175-024 | UNSAT | UNSAT | 2010233 | 128.654 | 1.645 | ✓ |
| uuf175-025 | UNSAT | UNSAT | 1817085 | 116.293 | 1.582 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1884228 &nbsp;|&nbsp; mean time: 120.590 ms &nbsp;|&nbsp; mean wall: 1.630s

---

## Overall Summary

- **Grid**: 2x2-3clz
- **Total correct**: 256 / 300
- **Finished**: Sun Apr 12 18:46:55 UTC 2026
