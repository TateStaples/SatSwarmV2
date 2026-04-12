# SatSwarm Benchmark Results

- **Grid config**: 3x3-2clz
- **Run timestamp**: 20260412_184806
- **Instances per dataset**: 25
- **FPGA slot**: 0
- **Host binary**: /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 12163 | .778 | 1.533 | ✓ |
| uf50-02 | SAT | SAT | 15550 | .995 | 1.396 | ✓ |
| uf50-03 | SAT | SAT | 6821 | .436 | 1.397 | ✓ |
| uf50-04 | SAT | SAT | 20044 | 1.282 | 1.398 | ✓ |
| uf50-05 | SAT | SAT | 5054 | .323 | 1.397 | ✓ |
| uf50-06 | SAT | SAT | 19449 | 1.244 | 1.392 | ✓ |
| uf50-07 | SAT | SAT | 5325 | .340 | 1.394 | ✓ |
| uf50-08 | SAT | SAT | 4588 | .293 | 1.387 | ✓ |
| uf50-09 | SAT | SAT | 4655 | .297 | 1.566 | ✓ |
| uf50-010 | SAT | SAT | 7504 | .480 | 1.386 | ✓ |
| uf50-011 | SAT | SAT | 21827 | 1.396 | 1.391 | ✓ |
| uf50-012 | SAT | SAT | 9658 | .618 | 1.393 | ✓ |
| uf50-013 | SAT | SAT | 8300 | .531 | 1.391 | ✓ |
| uf50-014 | SAT | SAT | 19020 | 1.217 | 1.390 | ✓ |
| uf50-015 | SAT | SAT | 4341 | .277 | 1.391 | ✓ |
| uf50-016 | SAT | SAT | 4553 | .291 | 1.928 | ✓ |
| uf50-017 | SAT | SAT | 8126 | .520 | 1.392 | ✓ |
| uf50-018 | SAT | SAT | 11715 | .749 | 1.389 | ✓ |
| uf50-019 | SAT | SAT | 9066 | .580 | 1.391 | ✓ |
| uf50-020 | SAT | SAT | 7959 | .509 | 1.398 | ✓ |
| uf50-021 | SAT | SAT | 9378 | .600 | 1.387 | ✓ |
| uf50-022 | SAT | SAT | 13337 | .853 | 1.396 | ✓ |
| uf50-023 | SAT | SAT | 7169 | .458 | 1.383 | ✓ |
| uf50-024 | SAT | SAT | 7718 | .493 | 1.420 | ✓ |
| uf50-025 | SAT | SAT | 5705 | .365 | 1.386 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 9961 &nbsp;|&nbsp; mean time: .637 ms &nbsp;|&nbsp; mean wall: 1.426s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 49303 | 3.155 | 1.570 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 44601 | 2.854 | 1.395 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 24541 | 1.570 | 1.383 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 47716 | 3.053 | 1.389 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 37872 | 2.423 | 1.384 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 54078 | 3.460 | 1.401 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 48155 | 3.081 | 1.574 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 37777 | 2.417 | 1.398 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 46215 | 2.957 | 1.383 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 31696 | 2.028 | 1.394 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 38164 | 2.442 | 1.386 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 58367 | 3.735 | 1.395 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 35723 | 2.286 | 1.384 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 42577 | 2.724 | 1.387 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 44848 | 2.870 | 1.503 | ✓ |
| uuf50-016 | UNSAT | UNSAT | 33663 | 2.154 | 1.391 | ✓ |
| uuf50-017 | UNSAT | UNSAT | 41416 | 2.650 | 1.381 | ✓ |
| uuf50-018 | UNSAT | UNSAT | 28973 | 1.854 | 1.393 | ✓ |
| uuf50-019 | UNSAT | UNSAT | 62440 | 3.996 | 1.410 | ✓ |
| uuf50-020 | UNSAT | UNSAT | 76290 | 4.882 | 1.405 | ✓ |
| uuf50-021 | UNSAT | UNSAT | 56136 | 3.592 | 1.382 | ✓ |
| uuf50-022 | UNSAT | UNSAT | 61521 | 3.937 | 1.395 | ✓ |
| uuf50-023 | UNSAT | UNSAT | 60435 | 3.867 | 1.369 | ✓ |
| uuf50-024 | UNSAT | UNSAT | 38609 | 2.470 | 1.401 | ✓ |
| uuf50-025 | UNSAT | UNSAT | 49469 | 3.166 | 1.387 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 46023 &nbsp;|&nbsp; mean time: 2.945 ms &nbsp;|&nbsp; mean wall: 1.409s

---

## uf75 — SAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf75-01 | SAT | SAT | 7449 | .476 | 1.362 | ✓ |
| uf75-02 | SAT | SAT | 19154 | 1.225 | 1.393 | ✓ |
| uf75-03 | SAT | SAT | 31305 | 2.003 | 1.392 | ✓ |
| uf75-04 | SAT | SAT | 39543 | 2.530 | 1.389 | ✓ |
| uf75-05 | SAT | SAT | 29579 | 1.893 | 2.235 | ✓ |
| uf75-06 | SAT | SAT | 31766 | 2.033 | 1.387 | ✓ |
| uf75-07 | SAT | SAT | 14297 | .915 | 1.387 | ✓ |
| uf75-08 | SAT | SAT | 50302 | 3.219 | 1.387 | ✓ |
| uf75-09 | SAT | SAT | 15163 | .970 | 1.385 | ✓ |
| uf75-010 | SAT | SAT | 18629 | 1.192 | 1.391 | ✓ |
| uf75-011 | SAT | SAT | 57019 | 3.649 | 1.390 | ✓ |
| uf75-012 | SAT | SAT | 32926 | 2.107 | 1.387 | ✓ |
| uf75-013 | SAT | SAT | 12429 | .795 | 1.408 | ✓ |
| uf75-014 | SAT | SAT | 13725 | .878 | 1.390 | ✓ |
| uf75-015 | SAT | SAT | 24627 | 1.576 | 1.386 | ✓ |
| uf75-016 | SAT | SAT | 51911 | 3.322 | 1.401 | ✓ |
| uf75-017 | SAT | SAT | 25736 | 1.647 | 1.387 | ✓ |
| uf75-018 | SAT | SAT | 7162 | .458 | 1.389 | ✓ |
| uf75-019 | SAT | SAT | 65013 | 4.160 | 1.395 | ✓ |
| uf75-020 | SAT | SAT | 93869 | 6.007 | 1.394 | ✓ |
| uf75-021 | SAT | SAT | 10609 | .678 | 1.524 | ✓ |
| uf75-022 | SAT | SAT | 18785 | 1.202 | 1.390 | ✓ |
| uf75-023 | SAT | SAT | 23106 | 1.478 | 1.434 | ✓ |
| uf75-024 | SAT | SAT | 6322 | .404 | 1.402 | ✓ |
| uf75-025 | SAT | SAT | 6773 | .433 | 1.394 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 28287 &nbsp;|&nbsp; mean time: 1.810 ms &nbsp;|&nbsp; mean wall: 1.431s

---

## uuf75 — UNSAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf75-01 | UNSAT | UNSAT | 131562 | 8.419 | 1.374 | ✓ |
| uuf75-02 | UNSAT | UNSAT | 145692 | 9.324 | 1.391 | ✓ |
| uuf75-03 | UNSAT | UNSAT | 158996 | 10.175 | 2.099 | ✓ |
| uuf75-04 | UNSAT | UNSAT | 199407 | 12.762 | 1.384 | ✓ |
| uuf75-05 | UNSAT | UNSAT | 238954 | 15.293 | 1.398 | ✓ |
| uuf75-06 | UNSAT | UNSAT | 186241 | 11.919 | 1.390 | ✓ |
| uuf75-07 | UNSAT | UNSAT | 114528 | 7.329 | 1.386 | ✓ |
| uuf75-08 | UNSAT | UNSAT | 268410 | 17.178 | 1.391 | ✓ |
| uuf75-09 | UNSAT | UNSAT | 115194 | 7.372 | 1.377 | ✓ |
| uuf75-010 | UNSAT | UNSAT | 229422 | 14.683 | 1.400 | ✓ |
| uuf75-011 | UNSAT | UNSAT | 213328 | 13.652 | 1.504 | ✓ |
| uuf75-012 | UNSAT | UNSAT | 255465 | 16.349 | 1.404 | ✓ |
| uuf75-013 | UNSAT | UNSAT | 229343 | 14.677 | 1.398 | ✓ |
| uuf75-014 | UNSAT | UNSAT | 315702 | 20.204 | 1.389 | ✓ |
| uuf75-015 | UNSAT | UNSAT | 153960 | 9.853 | 1.381 | ✓ |
| uuf75-016 | UNSAT | UNSAT | 167953 | 10.748 | 1.393 | ✓ |
| uuf75-017 | UNSAT | UNSAT | 204282 | 13.074 | 1.386 | ✓ |
| uuf75-018 | UNSAT | UNSAT | 159768 | 10.225 | 1.390 | ✓ |
| uuf75-019 | UNSAT | UNSAT | 167307 | 10.707 | 1.524 | ✓ |
| uuf75-020 | UNSAT | UNSAT | 381327 | 24.404 | 1.403 | ✓ |
| uuf75-021 | UNSAT | UNSAT | 186135 | 11.912 | 1.376 | ✓ |
| uuf75-022 | UNSAT | UNSAT | 177111 | 11.335 | 1.385 | ✓ |
| uuf75-023 | UNSAT | UNSAT | 256424 | 16.411 | 1.404 | ✓ |
| uuf75-024 | UNSAT | UNSAT | 169648 | 10.857 | 1.381 | ✓ |
| uuf75-025 | UNSAT | UNSAT | 163058 | 10.435 | 1.403 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 199568 &nbsp;|&nbsp; mean time: 12.772 ms &nbsp;|&nbsp; mean wall: 1.428s

---

## uf100 — SAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf100-01 | SAT | SAT | 80660 | 5.162 | 2.013 | ✓ |
| uf100-02 | SAT | SAT | 61510 | 3.936 | 1.396 | ✓ |
| uf100-03 | SAT | SAT | 133641 | 8.553 | 1.392 | ✓ |
| uf100-04 | SAT | SAT | 131743 | 8.431 | 1.393 | ✓ |
| uf100-05 | SAT | SAT | 66984 | 4.286 | 1.379 | ✓ |
| uf100-06 | SAT | SAT | 9420 | .602 | 1.393 | ✓ |
| uf100-07 | SAT | SAT | 31173 | 1.995 | 1.381 | ✓ |
| uf100-08 | SAT | SAT | 258970 | 16.574 | 1.405 | ✓ |
| uf100-09 | SAT | SAT | 47033 | 3.010 | 1.461 | ✓ |
| uf100-010 | SAT | SAT | 15502 | .992 | 1.388 | ✓ |
| uf100-011 | SAT | SAT | 159732 | 10.222 | 1.402 | ✓ |
| uf100-012 | SAT | SAT | 46880 | 3.000 | 1.380 | ✓ |
| uf100-013 | SAT | SAT | 114106 | 7.302 | 1.395 | ✓ |
| uf100-014 | SAT | SAT | 163917 | 10.490 | 1.413 | ✓ |
| uf100-015 | SAT | SAT | 725301 | 46.419 | 1.428 | ✓ |
| uf100-016 | SAT | SAT | 360984 | 23.102 | 1.568 | ✓ |
| uf100-017 | SAT | SAT | 261328 | 16.724 | 1.524 | ✓ |
| uf100-018 | SAT | SAT | 43081 | 2.757 | 1.374 | ✓ |
| uf100-019 | SAT | SAT | 10343 | .661 | 1.380 | ✓ |
| uf100-020 | SAT | SAT | 88249 | 5.647 | 1.397 | ✓ |
| uf100-021 | SAT | SAT | 199646 | 12.777 | 1.396 | ✓ |
| uf100-022 | SAT | SAT | 502855 | 32.182 | 1.411 | ✓ |
| uf100-023 | SAT | SAT | 229258 | 14.672 | 1.573 | ✓ |
| uf100-024 | SAT | SAT | 12140 | .776 | 1.732 | ✓ |
| uf100-025 | SAT | SAT | 28390 | 1.816 | 1.390 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 151313 &nbsp;|&nbsp; mean time: 9.684 ms &nbsp;|&nbsp; mean wall: 1.454s

---

## uuf100 — UNSAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf100-01 | UNSAT | UNSAT | 575445 | 36.828 | 1.403 | ✓ |
| uuf100-02 | UNSAT | UNSAT | 1221943 | 78.204 | 1.450 | ✓ |
| uuf100-03 | UNSAT | UNSAT | 816901 | 52.281 | 1.575 | ✓ |
| uuf100-04 | UNSAT | UNSAT | 1310276 | 83.857 | 1.624 | ✓ |
| uuf100-05 | UNSAT | UNSAT | 746921 | 47.802 | 1.562 | ✓ |
| uuf100-06 | UNSAT | UNSAT | 881891 | 56.441 | 2.038 | ✓ |
| uuf100-07 | UNSAT | UNSAT | 777135 | 49.736 | 1.585 | ✓ |
| uuf100-08 | UNSAT | UNSAT | 639066 | 40.900 | 1.585 | ✓ |
| uuf100-09 | UNSAT | UNSAT | 972324 | 62.228 | 1.663 | ✓ |
| uuf100-010 | UNSAT | UNSAT | 749806 | 47.987 | 1.526 | ✓ |
| uuf100-011 | UNSAT | UNSAT | 1273142 | 81.481 | 1.684 | ✓ |
| uuf100-012 | UNSAT | UNSAT | 554904 | 35.513 | 1.549 | ✓ |
| uuf100-013 | UNSAT | UNSAT | 678590 | 43.429 | 1.490 | ✓ |
| uuf100-014 | UNSAT | UNSAT | 540118 | 34.567 | 1.582 | ✓ |
| uuf100-015 | UNSAT | UNSAT | 1079615 | 69.095 | 1.624 | ✓ |
| uuf100-016 | UNSAT | UNSAT | 993776 | 63.601 | 1.581 | ✓ |
| uuf100-017 | UNSAT | UNSAT | 860103 | 55.046 | 1.583 | ✓ |
| uuf100-018 | UNSAT | UNSAT | 797609 | 51.046 | 1.591 | ✓ |
| uuf100-019 | UNSAT | UNSAT | 639386 | 40.920 | 1.583 | ✓ |
| uuf100-020 | UNSAT | UNSAT | 701723 | 44.910 | 1.531 | ✓ |
| uuf100-021 | UNSAT | UNSAT | 678221 | 43.406 | 1.592 | ✓ |
| uuf100-022 | UNSAT | UNSAT | 931606 | 59.622 | 1.612 | ✓ |
| uuf100-023 | UNSAT | UNSAT | 675783 | 43.250 | 1.569 | ✓ |
| uuf100-024 | UNSAT | UNSAT | 550161 | 35.210 | 1.809 | ✓ |
| uuf100-025 | UNSAT | UNSAT | 524134 | 33.544 | 1.573 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 806823 &nbsp;|&nbsp; mean time: 51.636 ms &nbsp;|&nbsp; mean wall: 1.598s

---

## uf125 — SAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf125-01 | SAT | SAT | 245029 | 15.681 | 1.550 | ✓ |
| uf125-02 | SAT | SAT | 328501 | 21.024 | 1.440 | ✓ |
| uf125-03 | SAT | SAT | 74557 | 4.771 | 1.373 | ✓ |
| uf125-04 | SAT | SAT | 331457 | 21.213 | 1.406 | ✓ |
| uf125-05 | SAT | SAT | 419146 | 26.825 | 1.395 | ✓ |
| uf125-06 | SAT | SAT | 120956 | 7.741 | 1.572 | ✓ |
| uf125-07 | SAT | SAT | 344066 | 22.020 | 1.407 | ✓ |
| uf125-08 | SAT | SAT | 989142 | 63.305 | 1.431 | ✓ |
| uf125-09 | SAT | SAT | 413692 | 26.476 | 2.061 | ✓ |
| uf125-010 | SAT | SAT | 339576 | 21.732 | 1.388 | ✓ |
| uf125-011 | SAT | SAT | 394024 | 25.217 | 1.392 | ✓ |
| uf125-012 | SAT | SAT | 347769 | 22.257 | 1.390 | ✓ |
| uf125-013 | SAT | SAT | 652953 | 41.788 | 1.411 | ✓ |
| uf125-014 | SAT | UNSAT | 1067203 | 68.300 | 1.613 | ✗ |
| uf125-015 | SAT | SAT | 651560 | 41.699 | 1.575 | ✓ |
| uf125-016 | SAT | SAT | 95436 | 6.107 | 2.226 | ✓ |
| uf125-017 | SAT | UNSAT | 996905 | 63.801 | 1.450 | ✗ |
| uf125-018 | SAT | SAT | 252613 | 16.167 | 1.604 | ✓ |
| uf125-019 | SAT | SAT | 34743 | 2.223 | 1.525 | ✓ |
| uf125-020 | SAT | SAT | 134005 | 8.576 | 1.397 | ✓ |
| uf125-021 | SAT | SAT | 401400 | 25.689 | 1.406 | ✓ |
| uf125-022 | SAT | SAT | 533098 | 34.118 | 1.401 | ✓ |
| uf125-023 | SAT | SAT | 44646 | 2.857 | 2.114 | ✓ |
| uf125-024 | SAT | SAT | 442301 | 28.307 | 1.419 | ✓ |
| uf125-025 | SAT | SAT | 442423 | 28.315 | 1.592 | ✓ |

**Summary** — 23 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 403888 &nbsp;|&nbsp; mean time: 25.848 ms &nbsp;|&nbsp; mean wall: 1.541s

---

## uuf125 — UNSAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf125-01 | UNSAT | UNSAT | 1114950 | 71.356 | 1.609 | ✓ |
| uuf125-02 | UNSAT | UNSAT | 1338988 | 85.695 | 1.667 | ✓ |
| uuf125-03 | UNSAT | UNSAT | 1206379 | 77.208 | 1.525 | ✓ |
| uuf125-04 | UNSAT | UNSAT | 1233803 | 78.963 | 1.590 | ✓ |
| uuf125-05 | UNSAT | UNSAT | 1399110 | 89.543 | 1.738 | ✓ |
| uuf125-06 | UNSAT | UNSAT | 1274574 | 81.572 | 1.593 | ✓ |
| uuf125-07 | UNSAT | UNSAT | 1068844 | 68.406 | 1.562 | ✓ |
| uuf125-08 | UNSAT | UNSAT | 1297980 | 83.070 | 1.615 | ✓ |
| uuf125-09 | UNSAT | UNSAT | 1044096 | 66.822 | 1.579 | ✓ |
| uuf125-010 | UNSAT | UNSAT | 1026459 | 65.693 | 1.649 | ✓ |
| uuf125-011 | UNSAT | UNSAT | 1250166 | 80.010 | 1.547 | ✓ |
| uuf125-012 | UNSAT | UNSAT | 1312491 | 83.999 | 1.647 | ✓ |
| uuf125-013 | UNSAT | UNSAT | 1183078 | 75.716 | 1.639 | ✓ |
| uuf125-014 | UNSAT | UNSAT | 1261432 | 80.731 | 1.545 | ✓ |
| uuf125-015 | UNSAT | UNSAT | 1179188 | 75.468 | 1.618 | ✓ |
| uuf125-016 | UNSAT | UNSAT | 1119303 | 71.635 | 1.589 | ✓ |
| uuf125-017 | UNSAT | UNSAT | 1050514 | 67.232 | 1.583 | ✓ |
| uuf125-018 | UNSAT | UNSAT | 1083713 | 69.357 | 1.597 | ✓ |
| uuf125-019 | UNSAT | UNSAT | 1156261 | 74.000 | 1.503 | ✓ |
| uuf125-020 | UNSAT | UNSAT | 1048619 | 67.111 | 1.592 | ✓ |
| uuf125-021 | UNSAT | UNSAT | 1116979 | 71.486 | 1.589 | ✓ |
| uuf125-022 | UNSAT | UNSAT | 1180626 | 75.560 | 1.597 | ✓ |
| uuf125-023 | UNSAT | UNSAT | 941746 | 60.271 | 1.576 | ✓ |
| uuf125-024 | UNSAT | UNSAT | 1008910 | 64.570 | 1.596 | ✓ |
| uuf125-025 | UNSAT | UNSAT | 1033534 | 66.146 | 1.593 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1157269 &nbsp;|&nbsp; mean time: 74.065 ms &nbsp;|&nbsp; mean wall: 1.597s

---

## uf150 — SAT, 150 vars, 645 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf150-01 | SAT | SAT | 595210 | 38.093 | 1.500 | ✓ |
| uf150-02 | SAT | SAT | 378882 | 24.248 | 1.593 | ✓ |
| uf150-03 | SAT | UNSAT | 1399690 | 89.580 | 1.461 | ✗ |
| uf150-04 | SAT | SAT | 679797 | 43.507 | 1.543 | ✓ |
| uf150-05 | SAT | SAT | 654861 | 41.911 | 1.598 | ✓ |
| uf150-06 | SAT | UNSAT | 1531639 | 98.024 | 1.642 | ✗ |
| uf150-07 | SAT | SAT | 146920 | 9.402 | 1.510 | ✓ |
| uf150-08 | SAT | SAT | 144021 | 9.217 | 1.427 | ✓ |
| uf150-09 | SAT | SAT | 373125 | 23.880 | 1.405 | ✓ |
| uf150-010 | SAT | SAT | 257812 | 16.499 | 1.581 | ✓ |
| uf150-011 | SAT | SAT | 259211 | 16.589 | 1.394 | ✓ |
| uf150-012 | SAT | UNSAT | 1439236 | 92.111 | 1.464 | ✗ |
| uf150-013 | SAT | SAT | 834885 | 53.432 | 1.575 | ✓ |
| uf150-014 | SAT | UNSAT | 1072091 | 68.613 | 1.600 | ✗ |
| uf150-015 | SAT | SAT | 355644 | 22.761 | 1.497 | ✓ |
| uf150-016 | SAT | SAT | 327540 | 20.962 | 1.545 | ✓ |
| uf150-017 | SAT | SAT | 755888 | 48.376 | 1.616 | ✓ |
| uf150-018 | SAT | SAT | 368693 | 23.596 | 1.577 | ✓ |
| uf150-019 | SAT | UNSAT | 1650630 | 105.640 | 1.671 | ✗ |
| uf150-020 | SAT | SAT | 985151 | 63.049 | 1.550 | ✓ |
| uf150-021 | SAT | UNSAT | 1211041 | 77.506 | 1.603 | ✗ |
| uf150-022 | SAT | SAT | 1057750 | 67.696 | 1.461 | ✓ |
| uf150-023 | SAT | UNSAT | 1253152 | 80.201 | 1.602 | ✗ |
| uf150-024 | SAT | SAT | 770898 | 49.337 | 1.561 | ✓ |
| uf150-025 | SAT | UNSAT | 1398315 | 89.492 | 1.633 | ✗ |

**Summary** — 17 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 796083 &nbsp;|&nbsp; mean time: 50.949 ms &nbsp;|&nbsp; mean wall: 1.544s

---

## uuf150 — UNSAT, 150 vars, 645 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf150-01 | UNSAT | UNSAT | 1248602 | 79.910 | 1.559 | ✓ |
| uuf150-02 | UNSAT | UNSAT | 1244865 | 79.671 | 1.597 | ✓ |
| uuf150-03 | UNSAT | UNSAT | 1711630 | 109.544 | 1.644 | ✓ |
| uuf150-04 | UNSAT | UNSAT | 1485618 | 95.079 | 1.638 | ✓ |
| uuf150-05 | UNSAT | UNSAT | 1492624 | 95.527 | 1.593 | ✓ |
| uuf150-06 | UNSAT | UNSAT | 1083635 | 69.352 | 1.558 | ✓ |
| uuf150-07 | UNSAT | UNSAT | 1039022 | 66.497 | 1.592 | ✓ |
| uuf150-08 | UNSAT | UNSAT | 1215023 | 77.761 | 1.606 | ✓ |
| uuf150-09 | UNSAT | UNSAT | 1319350 | 84.438 | 1.646 | ✓ |
| uuf150-010 | UNSAT | UNSAT | 1408621 | 90.151 | 1.563 | ✓ |
| uuf150-011 | UNSAT | UNSAT | 1393451 | 89.180 | 1.518 | ✓ |
| uuf150-012 | UNSAT | UNSAT | 1684355 | 107.798 | 1.612 | ✓ |
| uuf150-013 | UNSAT | UNSAT | 1310669 | 83.882 | 1.570 | ✓ |
| uuf150-014 | UNSAT | UNSAT | 1504137 | 96.264 | 1.610 | ✓ |
| uuf150-015 | UNSAT | UNSAT | 1267379 | 81.112 | 1.600 | ✓ |
| uuf150-016 | UNSAT | UNSAT | 1024162 | 65.546 | 1.580 | ✓ |
| uuf150-017 | UNSAT | UNSAT | 1507618 | 96.487 | 2.548 | ✓ |
| uuf150-018 | UNSAT | UNSAT | 1284541 | 82.210 | 1.578 | ✓ |
| uuf150-019 | UNSAT | UNSAT | 1099539 | 70.370 | 1.581 | ✓ |
| uuf150-020 | UNSAT | UNSAT | 1306961 | 83.645 | 1.605 | ✓ |
| uuf150-021 | UNSAT | UNSAT | 1118573 | 71.588 | 1.580 | ✓ |
| uuf150-022 | UNSAT | UNSAT | 1403562 | 89.827 | 1.609 | ✓ |
| uuf150-023 | UNSAT | UNSAT | 1423162 | 91.082 | 1.636 | ✓ |
| uuf150-024 | UNSAT | UNSAT | 1038798 | 66.483 | 1.500 | ✓ |
| uuf150-025 | UNSAT | UNSAT | 1229082 | 78.661 | 1.600 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1313799 &nbsp;|&nbsp; mean time: 84.083 ms &nbsp;|&nbsp; mean wall: 1.628s

---

## uf175 — SAT, 175 vars, 753 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf175-01 | SAT | UNSAT | 1987069 | 127.172 | 1.624 | ✗ |
| uf175-02 | SAT | UNSAT | 1517759 | 97.136 | 1.557 | ✗ |
| uf175-03 | SAT | UNSAT | 1461783 | 93.554 | 1.593 | ✗ |
| uf175-04 | SAT | SAT | 275269 | 17.617 | 1.520 | ✓ |
| uf175-05 | SAT | UNSAT | 1609039 | 102.978 | 1.491 | ✗ |
| uf175-06 | SAT | UNSAT | 1770049 | 113.283 | 1.653 | ✗ |
| uf175-07 | SAT | UNSAT | 1629612 | 104.295 | 1.583 | ✗ |
| uf175-08 | SAT | UNSAT | 1423714 | 91.117 | 1.578 | ✗ |
| uf175-09 | SAT | UNSAT | 1694156 | 108.425 | 1.648 | ✗ |
| uf175-010 | SAT | SAT | 1784495 | 114.207 | 1.555 | ✓ |
| uf175-011 | SAT | SAT | 278144 | 17.801 | 1.490 | ✓ |
| uf175-012 | SAT | UNSAT | 1837429 | 117.595 | 1.493 | ✗ |
| uf175-013 | SAT | UNSAT | 2222099 | 142.214 | 1.686 | ✗ |
| uf175-014 | SAT | UNSAT | 1600315 | 102.420 | 1.561 | ✗ |
| uf175-015 | SAT | SAT | 252404 | 16.153 | 1.520 | ✓ |
| uf175-016 | SAT | UNSAT | 1872474 | 119.838 | 1.508 | ✗ |
| uf175-017 | SAT | UNSAT | 1284779 | 82.225 | 1.560 | ✗ |
| uf175-018 | SAT | SAT | 430065 | 27.524 | 1.534 | ✓ |
| uf175-019 | SAT | UNSAT | 1997956 | 127.869 | 1.494 | ✗ |
| uf175-020 | SAT | UNSAT | 1662686 | 106.411 | 1.695 | ✗ |
| uf175-021 | SAT | UNSAT | 1979908 | 126.714 | 1.610 | ✗ |
| uf175-022 | SAT | UNSAT | 1843904 | 118.009 | 1.583 | ✗ |
| uf175-023 | SAT | UNSAT | 1713165 | 109.642 | 1.579 | ✗ |
| uf175-024 | SAT | UNSAT | 1961630 | 125.544 | 1.610 | ✗ |
| uf175-025 | SAT | UNSAT | 1968127 | 125.960 | 1.633 | ✗ |

**Summary** — 5 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1522321 &nbsp;|&nbsp; mean time: 97.428 ms &nbsp;|&nbsp; mean wall: 1.574s

---

## uuf175 — UNSAT, 175 vars, 753 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf175-01 | UNSAT | UNSAT | 1953629 | 125.032 | 1.535 | ✓ |
| uuf175-02 | UNSAT | UNSAT | 1731866 | 110.839 | 1.554 | ✓ |
| uuf175-03 | UNSAT | UNSAT | 1610035 | 103.042 | 1.541 | ✓ |
| uuf175-04 | UNSAT | UNSAT | 1728984 | 110.654 | 1.611 | ✓ |
| uuf175-05 | UNSAT | UNSAT | 1954439 | 125.084 | 1.600 | ✓ |
| uuf175-06 | UNSAT | UNSAT | 1296956 | 83.005 | 1.548 | ✓ |
| uuf175-07 | UNSAT | UNSAT | 1834184 | 117.387 | 1.623 | ✓ |
| uuf175-08 | UNSAT | UNSAT | 1802629 | 115.368 | 1.623 | ✓ |
| uuf175-09 | UNSAT | UNSAT | 1180135 | 75.528 | 1.567 | ✓ |
| uuf175-010 | UNSAT | UNSAT | 1449969 | 92.798 | 1.607 | ✓ |
| uuf175-011 | UNSAT | UNSAT | 1492226 | 95.502 | 1.592 | ✓ |
| uuf175-012 | UNSAT | UNSAT | 1456978 | 93.246 | 1.600 | ✓ |
| uuf175-013 | UNSAT | UNSAT | 1334739 | 85.423 | 1.588 | ✓ |
| uuf175-014 | UNSAT | UNSAT | 2115083 | 135.365 | 1.640 | ✓ |
| uuf175-015 | UNSAT | UNSAT | 1412645 | 90.409 | 1.544 | ✓ |
| uuf175-016 | UNSAT | UNSAT | 1457652 | 93.289 | 1.502 | ✓ |
| uuf175-017 | UNSAT | UNSAT | 1887323 | 120.788 | 1.627 | ✓ |
| uuf175-018 | UNSAT | UNSAT | 1651040 | 105.666 | 1.587 | ✓ |
| uuf175-019 | UNSAT | UNSAT | 1741819 | 111.476 | 1.632 | ✓ |
| uuf175-020 | UNSAT | UNSAT | 1656002 | 105.984 | 1.561 | ✓ |
| uuf175-021 | UNSAT | UNSAT | 1392254 | 89.104 | 1.570 | ✓ |
| uuf175-022 | UNSAT | UNSAT | 1337733 | 85.614 | 1.595 | ✓ |
| uuf175-023 | UNSAT | UNSAT | 1460190 | 93.452 | 1.568 | ✓ |
| uuf175-024 | UNSAT | UNSAT | 1583066 | 101.316 | 1.648 | ✓ |
| uuf175-025 | UNSAT | UNSAT | 1817079 | 116.293 | 1.563 | ✓ |

**Summary** — 25 / 25 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1613546 &nbsp;|&nbsp; mean time: 103.266 ms &nbsp;|&nbsp; mean wall: 1.585s

---

## Overall Summary

- **Grid**: 3x3-2clz
- **Total correct**: 270 / 300
- **Finished**: Sun Apr 12 18:55:50 UTC 2026
