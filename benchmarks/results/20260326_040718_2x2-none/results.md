# SatSwarm Benchmark Results

- **Grid config**: 2x2-none
- **Run timestamp**: 20260326_040718
- **Instances per dataset**: 15
- **FPGA slot**: 0
- **Host binary**: /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 34793 | 2.226 | 1.416 | ✓ |
| uf50-02 | SAT | SAT | 14112 | .903 | 1.400 | ✓ |
| uf50-03 | SAT | SAT | 7095 | .454 | 1.393 | ✓ |
| uf50-04 | SAT | SAT | 18303 | 1.171 | 1.396 | ✓ |
| uf50-05 | SAT | SAT | 7716 | .493 | 1.391 | ✓ |
| uf50-06 | SAT | SAT | 17978 | 1.150 | 1.397 | ✓ |
| uf50-07 | SAT | SAT | 24981 | 1.598 | 1.393 | ✓ |
| uf50-08 | SAT | SAT | 18098 | 1.158 | 1.407 | ✓ |
| uf50-09 | SAT | SAT | 15146 | .969 | 1.392 | ✓ |
| uf50-010 | SAT | SAT | 20227 | 1.294 | 1.405 | ✓ |
| uf50-011 | SAT | SAT | 23004 | 1.472 | 1.392 | ✓ |
| uf50-012 | SAT | SAT | 10575 | .676 | 1.399 | ✓ |
| uf50-013 | SAT | SAT | 6724 | .430 | 1.395 | ✓ |
| uf50-014 | SAT | SAT | 17297 | 1.107 | 1.392 | ✓ |
| uf50-015 | SAT | SAT | 8034 | .514 | 1.402 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 16272 &nbsp;|&nbsp; mean time: 1.041 ms &nbsp;|&nbsp; mean wall: 1.398s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 52456 | 3.357 | 1.459 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 43103 | 2.758 | 1.393 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 22909 | 1.466 | 1.402 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 46045 | 2.946 | 1.390 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 50579 | 3.237 | 1.396 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 58357 | 3.734 | 1.403 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 56032 | 3.586 | 1.388 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 49790 | 3.186 | 1.399 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 71336 | 4.565 | 1.437 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 30328 | 1.940 | 1.395 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 64555 | 4.131 | 1.397 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 61563 | 3.940 | 1.404 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 34104 | 2.182 | 1.390 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 53076 | 3.396 | 1.395 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 43111 | 2.759 | 1.399 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 49156 &nbsp;|&nbsp; mean time: 3.145 ms &nbsp;|&nbsp; mean wall: 1.403s

---

## uf75 — SAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf75-01 | SAT | SAT | 5911 | .378 | 1.371 | ✓ |
| uf75-02 | SAT | SAT | 22104 | 1.414 | 1.550 | ✓ |
| uf75-03 | SAT | UNSAT | 143378 | 9.176 | 1.402 | ✗ |
| uf75-04 | SAT | SAT | 53692 | 3.436 | 1.384 | ✓ |
| uf75-05 | SAT | UNSAT | 106293 | 6.802 | 1.404 | ✗ |
| uf75-06 | SAT | UNSAT | 164148 | 10.505 | 1.410 | ✗ |
| uf75-07 | SAT | SAT | 12734 | .814 | 1.385 | ✓ |
| uf75-08 | SAT | SAT | 97227 | 6.222 | 1.404 | ✓ |
| uf75-09 | SAT | SAT | 34916 | 2.234 | 2.360 | ✓ |
| uf75-010 | SAT | SAT | 35421 | 2.266 | 1.402 | ✓ |
| uf75-011 | SAT | SAT | 138135 | 8.840 | 1.401 | ✓ |
| uf75-012 | SAT | SAT | 36806 | 2.355 | 1.392 | ✓ |
| uf75-013 | SAT | SAT | 28667 | 1.834 | 1.392 | ✓ |
| uf75-014 | SAT | SAT | 12313 | .788 | 1.390 | ✓ |
| uf75-015 | SAT | SAT | 25460 | 1.629 | 1.397 | ✓ |

**Summary** — 12 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 61147 &nbsp;|&nbsp; mean time: 3.913 ms &nbsp;|&nbsp; mean wall: 1.469s

---

## uuf75 — UNSAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf75-01 | UNSAT | UNSAT | 167213 | 10.701 | 1.387 | ✓ |
| uuf75-02 | UNSAT | UNSAT | 149244 | 9.551 | 1.395 | ✓ |
| uuf75-03 | UNSAT | UNSAT | 202367 | 12.951 | 1.399 | ✓ |
| uuf75-04 | UNSAT | UNSAT | 209747 | 13.423 | 1.396 | ✓ |
| uuf75-05 | UNSAT | UNSAT | 212040 | 13.570 | 1.393 | ✓ |
| uuf75-06 | UNSAT | UNSAT | 121644 | 7.785 | 1.389 | ✓ |
| uuf75-07 | UNSAT | UNSAT | 113781 | 7.281 | 1.395 | ✓ |
| uuf75-08 | UNSAT | UNSAT | 91723 | 5.870 | 1.392 | ✓ |
| uuf75-09 | UNSAT | UNSAT | 90177 | 5.771 | 1.396 | ✓ |
| uuf75-010 | UNSAT | UNSAT | 104183 | 6.667 | 1.526 | ✓ |
| uuf75-011 | UNSAT | UNSAT | 209951 | 13.436 | 1.405 | ✓ |
| uuf75-012 | UNSAT | UNSAT | 210084 | 13.445 | 1.406 | ✓ |
| uuf75-013 | UNSAT | UNSAT | 175640 | 11.240 | 1.393 | ✓ |
| uuf75-014 | UNSAT | UNSAT | 131569 | 8.420 | 1.392 | ✓ |
| uuf75-015 | UNSAT | UNSAT | 147426 | 9.435 | 1.419 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 155785 &nbsp;|&nbsp; mean time: 9.970 ms &nbsp;|&nbsp; mean wall: 1.405s

---

## uf100 — SAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf100-01 | SAT | UNSAT | 190847 | 12.214 | 1.579 | ✗ |
| uf100-02 | SAT | SAT | 7763 | .496 | 1.707 | ✓ |
| uf100-03 | SAT | SAT | 18335 | 1.173 | 1.398 | ✓ |
| uf100-04 | SAT | SAT | 22525 | 1.441 | 1.389 | ✓ |
| uf100-05 | SAT | SAT | 8621 | .551 | 1.405 | ✓ |
| uf100-06 | SAT | SAT | 8629 | .552 | 1.397 | ✓ |
| uf100-07 | SAT | SAT | 31139 | 1.992 | 1.398 | ✓ |
| uf100-08 | SAT | SAT | 118509 | 7.584 | 1.396 | ✓ |
| uf100-09 | SAT | SAT | 187713 | 12.013 | 1.401 | ✓ |
| uf100-010 | SAT | SAT | 23669 | 1.514 | 1.448 | ✓ |
| uf100-011 | SAT | SAT | 16341 | 1.045 | 1.393 | ✓ |
| uf100-012 | SAT | SAT | 45981 | 2.942 | 1.397 | ✓ |
| uf100-013 | SAT | SAT | 20140 | 1.288 | 1.396 | ✓ |
| uf100-014 | SAT | SAT | 12724 | .814 | 1.394 | ✓ |
| uf100-015 | SAT | UNSAT | 542259 | 34.704 | 1.428 | ✗ |

**Summary** — 13 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 83679 &nbsp;|&nbsp; mean time: 5.355 ms &nbsp;|&nbsp; mean wall: 1.435s

---

## uuf100 — UNSAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf100-01 | UNSAT | SAT | 124186 | 7.947 | 1.558 | ✗ |
| uuf100-02 | UNSAT | SAT | 163068 | 10.436 | 2.227 | ✗ |
| uuf100-03 | UNSAT | SAT | 166119 | 10.631 | 1.402 | ✗ |
| uuf100-04 | UNSAT | SAT | 78580 | 5.029 | 1.393 | ✗ |
| uuf100-05 | UNSAT | SAT | 161839 | 10.357 | 1.406 | ✗ |
| uuf100-06 | UNSAT | UNSAT | 135390 | 8.664 | 1.416 | ✓ |
| uuf100-07 | UNSAT | SAT | 105722 | 6.766 | 1.390 | ✗ |
| uuf100-08 | UNSAT | SAT | 77682 | 4.971 | 1.401 | ✗ |
| uuf100-09 | UNSAT | UNSAT | 455437 | 29.147 | 1.421 | ✓ |
| uuf100-010 | UNSAT | SAT | 217582 | 13.925 | 1.379 | ✗ |
| uuf100-011 | UNSAT | SAT | 25097 | 1.606 | 1.387 | ✗ |
| uuf100-012 | UNSAT | SAT | 247148 | 15.817 | 1.405 | ✗ |
| uuf100-013 | UNSAT | SAT | 276150 | 17.673 | 1.394 | ✗ |
| uuf100-014 | UNSAT | SAT | 36399 | 2.329 | 1.380 | ✗ |
| uuf100-015 | UNSAT | SAT | 120074 | 7.684 | 1.399 | ✗ |

**Summary** — 2 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 159364 &nbsp;|&nbsp; mean time: 10.199 ms &nbsp;|&nbsp; mean wall: 1.463s

---

## uf125 — SAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf125-01 | SAT | SAT | 17741 | 1.135 | 1.379 | ✓ |
| uf125-02 | SAT | UNSAT | 1019188 | 65.228 | 1.460 | ✗ |
| uf125-03 | SAT | UNSAT | 1014578 | 64.932 | 1.478 | ✗ |
| uf125-04 | SAT | SAT | 1014927 | 64.955 | 1.600 | ✓ |
| uf125-05 | SAT | SAT | 21021 | 1.345 | 1.529 | ✓ |
| uf125-06 | SAT | SAT | 18626 | 1.192 | 1.398 | ✓ |
| uf125-07 | SAT | UNSAT | 1014258 | 64.912 | 1.464 | ✗ |
| uf125-08 | SAT | UNSAT | 4934 | .315 | 1.536 | ✗ |
| uf125-09 | SAT | SAT | 9101 | .582 | 1.393 | ✓ |
| uf125-010 | SAT | UNSAT | 4027843 | 257.781 | 1.792 | ✗ |
| uf125-011 | SAT | SAT | 10558 | .675 | 1.539 | ✓ |
| uf125-012 | SAT | SAT | 20569 | 1.316 | 1.401 | ✓ |
| uf125-013 | SAT | UNSAT | 1010350 | 64.662 | 1.460 | ✗ |
| uf125-014 | SAT | UNSAT | 12795 | .818 | 1.527 | ✗ |
| uf125-015 | SAT | UNSAT | 1006854 | 64.438 | 1.457 | ✗ |

**Summary** — 7 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 681556 &nbsp;|&nbsp; mean time: 43.619 ms &nbsp;|&nbsp; mean wall: 1.494s

---

## uuf125 — UNSAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf125-01 | UNSAT | SAT | 1047293 | 67.026 | 1.606 | ✗ |
| uuf125-02 | UNSAT | SAT | 33315 | 2.132 | 2.254 | ✗ |
| uuf125-03 | UNSAT | SAT | 8047 | .515 | 1.404 | ✗ |
| uuf125-04 | UNSAT | UNSAT | 3342 | .213 | 1.391 | ✓ |
| uuf125-05 | UNSAT | UNSAT | 25421 | 1.626 | 1.395 | ✓ |
| uuf125-06 | UNSAT | SAT | 18108 | 1.158 | 1.394 | ✗ |
| uuf125-07 | UNSAT | SAT | 2028529 | 129.825 | 1.539 | ✗ |
| uuf125-08 | UNSAT | UNSAT | 6080 | .389 | 1.460 | ✓ |
| uuf125-09 | UNSAT | UNSAT | 1014924 | 64.955 | 1.458 | ✓ |
| uuf125-010 | UNSAT | UNSAT | 5086596 | 325.542 | 1.875 | ✓ |
| uuf125-011 | UNSAT | UNSAT | 2052325 | 131.348 | 1.611 | ✓ |
| uuf125-012 | UNSAT | UNSAT | 2014444 | 128.924 | 1.593 | ✓ |
| uuf125-013 | UNSAT | UNSAT | 6477 | .414 | 1.468 | ✓ |
| uuf125-014 | UNSAT | UNSAT | 2034483 | 130.206 | 1.531 | ✓ |
| uuf125-015 | UNSAT | UNSAT | 1014801 | 64.947 | 1.532 | ✓ |

**Summary** — 10 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1092945 &nbsp;|&nbsp; mean time: 69.948 ms &nbsp;|&nbsp; mean wall: 1.567s

---

## uf150 — SAT, 150 vars, 645 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf150-01 | SAT | UNSAT | 23341 | 1.493 | 2.754 | ✗ |
| uf150-02 | SAT | UNSAT | 2036756 | 130.352 | 1.523 | ✗ |
| uf150-03 | SAT | SAT | 1023606 | 65.510 | 1.533 | ✓ |
| uf150-04 | SAT | UNSAT | 1022426 | 65.435 | 1.595 | ✗ |
| uf150-05 | SAT | UNSAT | 2207539 | 141.282 | 1.663 | ✗ |
| uf150-06 | SAT | UNSAT | 21152 | 1.353 | 1.468 | ✗ |
| uf150-07 | SAT | SAT | 57649 | 3.689 | 1.392 | ✓ |
| uf150-08 | SAT | SAT | 1019090 | 65.221 | 1.959 | ✓ |
| uf150-09 | SAT | SAT | 1020053 | 65.283 | 1.599 | ✓ |
| uf150-010 | SAT | SAT | 33702 | 2.156 | 1.553 | ✓ |
| uf150-011 | SAT | UNSAT | 10083 | .645 | 1.386 | ✗ |
| uf150-012 | SAT | SAT | 25251 | 1.616 | 1.397 | ✓ |
| uf150-013 | SAT | UNSAT | 3096 | .198 | 1.395 | ✗ |
| uf150-014 | SAT | UNSAT | 118928 | 7.611 | 1.399 | ✗ |
| uf150-015 | SAT | UNSAT | 17179 | 1.099 | 2.168 | ✗ |

**Summary** — 6 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 575990 &nbsp;|&nbsp; mean time: 36.863 ms &nbsp;|&nbsp; mean wall: 1.652s

---

## uuf150 — UNSAT, 150 vars, 645 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf150-01 | UNSAT | UNSAT | 7460 | .477 | 1.387 | ✓ |
| uuf150-02 | UNSAT | SAT | 41250 | 2.640 | 1.392 | ✗ |
| uuf150-03 | UNSAT | SAT | 1022899 | 65.465 | 1.461 | ✗ |
| uuf150-04 | UNSAT | UNSAT | 9443 | .604 | 1.536 | ✓ |
| uuf150-05 | UNSAT | SAT | 26699 | 1.708 | 1.386 | ✗ |
| uuf150-06 | UNSAT | SAT | 16940 | 1.084 | 1.400 | ✗ |
| uuf150-07 | UNSAT | SAT | 25374 | 1.623 | 1.398 | ✗ |
| uuf150-08 | UNSAT | UNSAT | 19956 | 1.277 | 1.520 | ✓ |
| uuf150-09 | UNSAT | SAT | 38853 | 2.486 | 1.400 | ✗ |
| uuf150-010 | UNSAT | SAT | 46280 | 2.961 | 1.400 | ✗ |
| uuf150-011 | UNSAT | SAT | 18825 | 1.204 | 1.397 | ✗ |
| uuf150-012 | UNSAT | UNSAT | 1013454 | 64.861 | 1.458 | ✓ |
| uuf150-013 | UNSAT | SAT | 41698 | 2.668 | 1.528 | ✗ |
| uuf150-014 | UNSAT | UNSAT | 25880 | 1.656 | 1.397 | ✓ |
| uuf150-015 | UNSAT | SAT | 22828 | 1.460 | 1.880 | ✗ |

**Summary** — 5 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 158522 &nbsp;|&nbsp; mean time: 10.145 ms &nbsp;|&nbsp; mean wall: 1.462s

---

## uf175 — SAT, 175 vars, 754 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf175-01 | SAT | SAT | 13410 | .858 | 1.381 | ✓ |
| uf175-02 | SAT | SAT | 28476 | 1.822 | 1.396 | ✓ |
| uf175-03 | SAT | SAT | 14155 | .905 | 1.402 | ✓ |
| uf175-04 | SAT | SAT | 15684 | 1.003 | 1.391 | ✓ |
| uf175-05 | SAT | SAT | 21948 | 1.404 | 1.398 | ✓ |
| uf175-06 | SAT | SAT | 17280 | 1.105 | 1.393 | ✓ |
| uf175-07 | SAT | SAT | 26316 | 1.684 | 1.396 | ✓ |
| uf175-08 | SAT | SAT | 38862 | 2.487 | 1.465 | ✓ |
| uf175-09 | SAT | SAT | 63869 | 4.087 | 1.403 | ✓ |
| uf175-010 | SAT | SAT | 18872 | 1.207 | 1.380 | ✓ |
| uf175-011 | SAT | SAT | 27566 | 1.764 | 1.402 | ✓ |
| uf175-012 | SAT | SAT | 30027 | 1.921 | 1.393 | ✓ |
| uf175-013 | SAT | SAT | 10515 | .672 | 1.391 | ✓ |
| uf175-014 | SAT | SAT | 17678 | 1.131 | 1.393 | ✓ |
| uf175-015 | SAT | UNSAT | 12607 | .806 | 1.401 | ✗ |

**Summary** — 14 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 23817 &nbsp;|&nbsp; mean time: 1.524 ms &nbsp;|&nbsp; mean wall: 1.399s

---

## uuf175 — UNSAT, 175 vars, 754 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf175-01 | UNSAT | SAT | 25775 | 1.649 | 1.605 | ✗ |
| uuf175-02 | UNSAT | SAT | 18217 | 1.165 | 1.558 | ✗ |
| uuf175-03 | UNSAT | UNSAT | 16778 | 1.073 | 1.385 | ✓ |
| uuf175-04 | UNSAT | SAT | 13584 | .869 | 1.420 | ✗ |
| uuf175-05 | UNSAT | SAT | 28500 | 1.824 | 1.376 | ✗ |
| uuf175-06 | UNSAT | SAT | 30784 | 1.970 | 1.420 | ✗ |
| uuf175-07 | UNSAT | SAT | 14186 | .907 | 1.369 | ✗ |
| uuf175-08 | UNSAT | SAT | 25415 | 1.626 | 1.804 | ✗ |
| uuf175-09 | UNSAT | SAT | 16926 | 1.083 | 1.388 | ✗ |
| uuf175-010 | UNSAT | SAT | 47517 | 3.041 | 1.401 | ✗ |
| uuf175-011 | UNSAT | SAT | 27988 | 1.791 | 1.397 | ✗ |
| uuf175-012 | UNSAT | SAT | 26684 | 1.707 | 1.401 | ✗ |
| uuf175-013 | UNSAT | SAT | 19318 | 1.236 | 1.396 | ✗ |
| uuf175-014 | UNSAT | UNSAT | 8898 | .569 | 1.396 | ✓ |
| uuf175-015 | UNSAT | SAT | 21664 | 1.386 | 1.404 | ✗ |

**Summary** — 2 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 22815 &nbsp;|&nbsp; mean time: 1.460 ms &nbsp;|&nbsp; mean wall: 1.448s

---

## uf200 — SAT, 200 vars, 860 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf200-01 | SAT | SAT | 11842 | .757 | 1.550 | ✓ |
| uf200-02 | SAT | SAT | 17986 | 1.151 | 1.395 | ✓ |
| uf200-03 | SAT | SAT | 19347 | 1.238 | 1.394 | ✓ |
| uf200-04 | SAT | SAT | 18441 | 1.180 | 1.398 | ✓ |
| uf200-05 | SAT | SAT | 11382 | .728 | 1.406 | ✓ |
| uf200-06 | SAT | UNSAT | 3507 | .224 | 1.387 | ✗ |
| uf200-07 | SAT | SAT | 12968 | .829 | 1.404 | ✓ |
| uf200-08 | SAT | SAT | 9096 | .582 | 2.255 | ✓ |
| uf200-09 | SAT | SAT | 10618 | .679 | 1.392 | ✓ |
| uf200-010 | SAT | SAT | 27913 | 1.786 | 1.397 | ✓ |
| uf200-011 | SAT | SAT | 16036 | 1.026 | 1.402 | ✓ |
| uf200-012 | SAT | SAT | 28335 | 1.813 | 1.398 | ✓ |
| uf200-013 | SAT | SAT | 23310 | 1.491 | 1.395 | ✓ |
| uf200-014 | SAT | SAT | 24752 | 1.584 | 1.394 | ✓ |
| uf200-015 | SAT | SAT | 19009 | 1.216 | 1.394 | ✓ |

**Summary** — 14 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 16969 &nbsp;|&nbsp; mean time: 1.086 ms &nbsp;|&nbsp; mean wall: 1.464s

---

## uuf200 — UNSAT, 200 vars, 860 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf200-01 | UNSAT | SAT | 42300 | 2.707 | 1.558 | ✗ |
| uuf200-02 | UNSAT | SAT | 14972 | .958 | 1.397 | ✗ |
| uuf200-03 | UNSAT | SAT | 24985 | 1.599 | 1.393 | ✗ |
| uuf200-04 | UNSAT | SAT | 25136 | 1.608 | 1.406 | ✗ |
| uuf200-05 | UNSAT | SAT | 10350 | .662 | 1.404 | ✗ |
| uuf200-06 | UNSAT | SAT | 14006 | .896 | 1.389 | ✗ |
| uuf200-07 | UNSAT | SAT | 27037 | 1.730 | 1.402 | ✗ |
| uuf200-08 | UNSAT | SAT | 8866 | .567 | 2.212 | ✗ |
| uuf200-09 | UNSAT | SAT | 12452 | .796 | 1.398 | ✗ |
| uuf200-010 | UNSAT | SAT | 19105 | 1.222 | 1.393 | ✗ |
| uuf200-011 | UNSAT | SAT | 22348 | 1.430 | 1.405 | ✗ |
| uuf200-012 | UNSAT | SAT | 21678 | 1.387 | 1.401 | ✗ |
| uuf200-013 | UNSAT | SAT | 17409 | 1.114 | 1.395 | ✗ |
| uuf200-014 | UNSAT | SAT | 34799 | 2.227 | 1.390 | ✗ |
| uuf200-015 | UNSAT | SAT | 29030 | 1.857 | 1.401 | ✗ |

**Summary** — 0 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 21631 &nbsp;|&nbsp; mean time: 1.384 ms &nbsp;|&nbsp; mean wall: 1.462s

---

## uf225 — SAT, 225 vars, 962 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf225-01 | SAT | SAT | 10908 | .698 | 1.407 | ✓ |
| uf225-02 | SAT | SAT | 9520 | .609 | 1.394 | ✓ |
| uf225-03 | SAT | SAT | 8062 | .515 | 1.397 | ✓ |
| uf225-04 | SAT | SAT | 6794 | .434 | 1.397 | ✓ |
| uf225-05 | SAT | SAT | 5024 | .321 | 1.392 | ✓ |
| uf225-06 | SAT | SAT | 5060 | .323 | 1.405 | ✓ |
| uf225-07 | SAT | SAT | 10251 | .656 | 1.397 | ✓ |
| uf225-08 | SAT | SAT | 16778 | 1.073 | 1.394 | ✓ |
| uf225-09 | SAT | SAT | 8468 | .541 | 1.377 | ✓ |
| uf225-010 | SAT | SAT | 10962 | .701 | 1.390 | ✓ |
| uf225-011 | SAT | SAT | 5029 | .321 | 1.393 | ✓ |
| uf225-012 | SAT | SAT | 5231 | .334 | 1.389 | ✓ |
| uf225-013 | SAT | SAT | 13930 | .891 | 1.397 | ✓ |
| uf225-014 | SAT | SAT | 5644 | .361 | 1.393 | ✓ |
| uf225-015 | SAT | SAT | 4995 | .319 | 1.400 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 8443 &nbsp;|&nbsp; mean time: .540 ms &nbsp;|&nbsp; mean wall: 1.394s

---

## uuf225 — UNSAT, 225 vars, 962 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf225-01 | UNSAT | SAT | 6973 | .446 | 2.133 | ✗ |
| uuf225-02 | UNSAT | SAT | 5212 | .333 | 1.391 | ✗ |
| uuf225-03 | UNSAT | SAT | 5086 | .325 | 1.410 | ✗ |
| uuf225-04 | UNSAT | SAT | 5471 | .350 | 1.394 | ✗ |
| uuf225-05 | UNSAT | SAT | 7546 | .482 | 1.389 | ✗ |
| uuf225-06 | UNSAT | SAT | 5248 | .335 | 1.399 | ✗ |
| uuf225-07 | UNSAT | SAT | 13846 | .886 | 1.400 | ✗ |
| uuf225-08 | UNSAT | SAT | 6980 | .446 | 1.388 | ✗ |
| uuf225-09 | UNSAT | SAT | 14104 | .902 | 1.458 | ✗ |
| uuf225-010 | UNSAT | SAT | 14322 | .916 | 1.396 | ✗ |
| uuf225-011 | UNSAT | SAT | 11052 | .707 | 1.391 | ✗ |
| uuf225-012 | UNSAT | SAT | 6135 | .392 | 1.399 | ✗ |
| uuf225-013 | UNSAT | SAT | 7140 | .456 | 1.393 | ✗ |
| uuf225-014 | UNSAT | SAT | 13585 | .869 | 1.401 | ✗ |
| uuf225-015 | UNSAT | SAT | 7668 | .490 | 1.401 | ✗ |

**Summary** — 0 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 8691 &nbsp;|&nbsp; mean time: .556 ms &nbsp;|&nbsp; mean wall: 1.449s

---

## uf250 — SAT, 250 vars, 1065 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf250-01 | SAT | SAT | 5542 | .354 | 1.392 | ✓ |
| uf250-02 | SAT | SAT | 5497 | .351 | 1.557 | ✓ |
| uf250-03 | SAT | SAT | 5381 | .344 | 1.396 | ✓ |
| uf250-04 | SAT | SAT | 5561 | .355 | 1.398 | ✓ |
| uf250-05 | SAT | SAT | 5514 | .352 | 1.392 | ✓ |
| uf250-06 | SAT | SAT | 5435 | .347 | 1.395 | ✓ |
| uf250-07 | SAT | SAT | 5592 | .357 | 1.399 | ✓ |
| uf250-08 | SAT | SAT | 5483 | .350 | 1.396 | ✓ |
| uf250-09 | SAT | SAT | 5355 | .342 | 1.911 | ✓ |
| uf250-010 | SAT | SAT | 5537 | .354 | 1.398 | ✓ |
| uf250-011 | SAT | SAT | 5365 | .343 | 1.389 | ✓ |
| uf250-012 | SAT | SAT | 5560 | .355 | 1.401 | ✓ |
| uf250-013 | SAT | SAT | 5413 | .346 | 1.390 | ✓ |
| uf250-014 | SAT | SAT | 5529 | .353 | 1.392 | ✓ |
| uf250-015 | SAT | SAT | 5442 | .348 | 1.392 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 5480 &nbsp;|&nbsp; mean time: .350 ms &nbsp;|&nbsp; mean wall: 1.439s

---

## uuf250 — UNSAT, 250 vars, 1065 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf250-01 | UNSAT | SAT | 5451 | .348 | 1.379 | ✗ |
| uuf250-02 | UNSAT | SAT | 5539 | .354 | 1.478 | ✗ |
| uuf250-03 | UNSAT | SAT | 5521 | .353 | 1.392 | ✗ |
| uuf250-04 | UNSAT | SAT | 5409 | .346 | 1.394 | ✗ |
| uuf250-05 | UNSAT | SAT | 5491 | .351 | 1.393 | ✗ |
| uuf250-06 | UNSAT | SAT | 5583 | .357 | 1.394 | ✗ |
| uuf250-07 | UNSAT | SAT | 5398 | .345 | 1.394 | ✗ |
| uuf250-08 | UNSAT | SAT | 5394 | .345 | 1.392 | ✗ |
| uuf250-09 | UNSAT | SAT | 5388 | .344 | 1.394 | ✗ |
| uuf250-010 | UNSAT | SAT | 5516 | .353 | 1.529 | ✗ |
| uuf250-011 | UNSAT | SAT | 5484 | .350 | 1.401 | ✗ |
| uuf250-012 | UNSAT | SAT | 5573 | .356 | 1.403 | ✗ |
| uuf250-013 | UNSAT | SAT | 5380 | .344 | 1.385 | ✗ |
| uuf250-014 | UNSAT | SAT | 5421 | .346 | 1.396 | ✗ |
| uuf250-015 | UNSAT | SAT | 5512 | .352 | 1.395 | ✗ |

**Summary** — 0 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 5470 &nbsp;|&nbsp; mean time: .350 ms &nbsp;|&nbsp; mean wall: 1.407s

---

## Overall Summary

- **Grid**: 2x2-none
- **Total correct**: 160 / 270
- **Finished**: Thu Mar 26 04:13:57 UTC 2026
