# SatSwarm Benchmark Results

- **Grid config**: unknown
- **Run timestamp**: 20260401_231236
- **Instances per dataset**: 15
- **FPGA slot**: 0
- **Host binary**: /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 38476 | 2.462 | 1.549 | ✓ |
| uf50-02 | SAT | SAT | 30137 | 1.928 | 1.396 | ✓ |
| uf50-03 | SAT | SAT | 72687 | 4.651 | 1.397 | ✓ |
| uf50-04 | SAT | SAT | 67011 | 4.288 | 1.392 | ✓ |
| uf50-05 | SAT | SAT | 9221 | .590 | 1.995 | ✓ |
| uf50-06 | SAT | SAT | 41470 | 2.654 | 1.398 | ✓ |
| uf50-07 | SAT | SAT | 26490 | 1.695 | 1.397 | ✓ |
| uf50-08 | SAT | SAT | 65206 | 4.173 | 1.395 | ✓ |
| uf50-09 | SAT | SAT | 53430 | 3.419 | 1.392 | ✓ |
| uf50-010 | SAT | SAT | 21665 | 1.386 | 1.389 | ✓ |
| uf50-011 | SAT | SAT | 65676 | 4.203 | 1.411 | ✓ |
| uf50-012 | SAT | SAT | 42760 | 2.736 | 1.400 | ✓ |
| uf50-013 | SAT | SAT | 8203 | .524 | 1.522 | ✓ |
| uf50-014 | SAT | SAT | 18903 | 1.209 | 1.391 | ✓ |
| uf50-015 | SAT | SAT | 21075 | 1.348 | 1.393 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 38827 &nbsp;|&nbsp; mean time: 2.484 ms &nbsp;|&nbsp; mean wall: 1.454s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 54148 | 3.465 | 1.569 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 51378 | 3.288 | 1.393 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 53416 | 3.418 | 1.392 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 67092 | 4.293 | 1.392 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 58597 | 3.750 | 2.085 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 84638 | 5.416 | 1.388 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 92735 | 5.935 | 1.389 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 50555 | 3.235 | 1.387 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 88473 | 5.662 | 1.398 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 51959 | 3.325 | 1.388 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 94987 | 6.079 | 1.395 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 74656 | 4.777 | 1.389 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 53726 | 3.438 | 1.547 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 60555 | 3.875 | 1.396 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 56478 | 3.614 | 1.397 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 66226 &nbsp;|&nbsp; mean time: 4.238 ms &nbsp;|&nbsp; mean wall: 1.460s

---

## uf75 — SAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf75-01 | SAT | SAT | 255278 | 16.337 | 1.383 | ✓ |
| uf75-02 | SAT | SAT | 19240 | 1.231 | 1.377 | ✓ |
| uf75-03 | SAT | SAT | 41969 | 2.686 | 1.399 | ✓ |
| uf75-04 | SAT | SAT | 221239 | 14.159 | 1.399 | ✓ |
| uf75-05 | SAT | SAT | 136041 | 8.706 | 2.733 | ✓ |
| uf75-06 | SAT | SAT | 604842 | 38.709 | 1.429 | ✓ |
| uf75-07 | SAT | SAT | 576915 | 36.922 | 1.595 | ✓ |
| uf75-08 | SAT | SAT | 411092 | 26.309 | 1.585 | ✓ |
| uf75-09 | SAT | SAT | 132492 | 8.479 | 1.376 | ✓ |
| uf75-010 | SAT | SAT | 207075 | 13.252 | 1.401 | ✓ |
| uf75-011 | SAT | UNSAT | 457942 | 29.308 | 1.403 | ✗ |
| uf75-012 | SAT | UNSAT | 238039 | 15.234 | 2.200 | ✗ |
| uf75-013 | SAT | SAT | 42460 | 2.717 | 1.377 | ✓ |
| uf75-014 | SAT | SAT | 20635 | 1.320 | 1.396 | ✓ |
| uf75-015 | SAT | SAT | 255445 | 16.348 | 1.404 | ✓ |

**Summary** — 13 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 241380 &nbsp;|&nbsp; mean time: 15.448 ms &nbsp;|&nbsp; mean wall: 1.563s

---

## uuf75 — UNSAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf75-01 | UNSAT | UNSAT | 264582 | 16.933 | 1.576 | ✓ |
| uuf75-02 | UNSAT | UNSAT | 145637 | 9.320 | 1.387 | ✓ |
| uuf75-03 | UNSAT | UNSAT | 851418 | 54.490 | 1.446 | ✓ |
| uuf75-04 | UNSAT | UNSAT | 199381 | 12.760 | 2.429 | ✓ |
| uuf75-05 | UNSAT | UNSAT | 630091 | 40.325 | 1.458 | ✓ |
| uuf75-06 | UNSAT | UNSAT | 356147 | 22.793 | 1.587 | ✓ |
| uuf75-07 | UNSAT | UNSAT | 238953 | 15.292 | 1.380 | ✓ |
| uuf75-08 | UNSAT | UNSAT | 353812 | 22.643 | 1.401 | ✓ |
| uuf75-09 | UNSAT | UNSAT | 166438 | 10.652 | 1.386 | ✓ |
| uuf75-010 | UNSAT | UNSAT | 301648 | 19.305 | 1.393 | ✓ |
| uuf75-011 | UNSAT | UNSAT | 536570 | 34.340 | 1.407 | ✓ |
| uuf75-012 | UNSAT | UNSAT | 423557 | 27.107 | 1.438 | ✓ |
| uuf75-013 | UNSAT | UNSAT | 316779 | 20.273 | 1.387 | ✓ |
| uuf75-014 | UNSAT | UNSAT | 315475 | 20.190 | 1.391 | ✓ |
| uuf75-015 | UNSAT | UNSAT | 286435 | 18.331 | 1.392 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 359128 &nbsp;|&nbsp; mean time: 22.984 ms &nbsp;|&nbsp; mean wall: 1.497s

---

## uf100 — SAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf100-01 | SAT | SAT | 1353924 | 86.651 | 1.641 | ✓ |
| uf100-02 | SAT | SAT | 447363 | 28.631 | 1.548 | ✓ |
| uf100-03 | SAT | SAT | 531450 | 34.012 | 1.598 | ✓ |
| uf100-04 | SAT | SAT | 980687 | 62.763 | 1.552 | ✓ |
| uf100-05 | SAT | SAT | 149327 | 9.556 | 1.539 | ✓ |
| uf100-06 | SAT | SAT | 17861 | 1.143 | 1.383 | ✓ |
| uf100-07 | SAT | SAT | 193228 | 12.366 | 1.406 | ✓ |
| uf100-08 | SAT | UNSAT | 3524693 | 225.580 | 1.613 | ✗ |
| uf100-09 | SAT | SAT | 364780 | 23.345 | 1.391 | ✓ |
| uf100-010 | SAT | SAT | 168532 | 10.786 | 1.381 | ✓ |
| uf100-011 | SAT | SAT | 543974 | 34.814 | 2.149 | ✓ |
| uf100-012 | SAT | SAT | 275769 | 17.649 | 1.578 | ✓ |
| uf100-013 | SAT | UNSAT | 2295722 | 146.926 | 1.530 | ✗ |
| uf100-014 | SAT | SAT | 589883 | 37.752 | 1.493 | ✓ |
| uf100-015 | SAT | UNSAT | 1394370 | 89.239 | 1.650 | ✗ |

**Summary** — 12 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 855437 &nbsp;|&nbsp; mean time: 54.747 ms &nbsp;|&nbsp; mean wall: 1.563s

---

## uuf100 — UNSAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf100-01 | UNSAT | UNSAT | 1379961 | 88.317 | 1.564 | ✓ |
| uuf100-02 | UNSAT | UNSAT | 2635954 | 168.701 | 1.675 | ✓ |
| uuf100-03 | UNSAT | UNSAT | 2955445 | 189.148 | 1.616 | ✓ |
| uuf100-04 | UNSAT | UNSAT | 2738598 | 175.270 | 1.577 | ✓ |
| uuf100-05 | UNSAT | UNSAT | 3389512 | 216.928 | 1.638 | ✓ |
| uuf100-06 | UNSAT | UNSAT | 1041486 | 66.655 | 1.446 | ✓ |
| uuf100-07 | UNSAT | UNSAT | 1275673 | 81.643 | 1.610 | ✓ |
| uuf100-08 | UNSAT | UNSAT | 2218846 | 142.006 | 1.663 | ✓ |
| uuf100-09 | UNSAT | UNSAT | 972204 | 62.221 | 1.520 | ✓ |
| uuf100-010 | UNSAT | UNSAT | 1285536 | 82.274 | 1.650 | ✓ |
| uuf100-011 | UNSAT | UNSAT | 3049917 | 195.194 | 1.704 | ✓ |
| uuf100-012 | UNSAT | UNSAT | 1709154 | 109.385 | 1.509 | ✓ |
| uuf100-013 | UNSAT | UNSAT | 701429 | 44.891 | 1.536 | ✓ |
| uuf100-014 | UNSAT | UNSAT | 1052364 | 67.351 | 1.628 | ✓ |
| uuf100-015 | UNSAT | UNSAT | 1438950 | 92.092 | 1.653 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1856335 &nbsp;|&nbsp; mean time: 118.805 ms &nbsp;|&nbsp; mean wall: 1.599s

---

## uf125 — SAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf125-01 | SAT | SAT | 371802 | 23.795 | 1.509 | ✓ |
| uf125-02 | SAT | UNSAT | 3040485 | 194.591 | 1.703 | ✗ |
| uf125-03 | SAT | SAT | 2639771 | 168.945 | 1.569 | ✓ |
| uf125-04 | SAT | UNSAT | 2646562 | 169.379 | 1.591 | ✗ |
| uf125-05 | SAT | SAT | 787284 | 50.386 | 1.472 | ✓ |
| uf125-06 | SAT | SAT | 120906 | 7.737 | 1.552 | ✓ |
| uf125-07 | SAT | SAT | 757053 | 48.451 | 1.437 | ✓ |
| uf125-08 | SAT | UNSAT | 2448669 | 156.714 | 1.703 | ✗ |
| uf125-09 | SAT | UNSAT | 2964705 | 189.741 | 1.658 | ✗ |
| uf125-010 | SAT | UNSAT | 1234137 | 78.984 | 1.482 | ✗ |
| uf125-011 | SAT | UNSAT | 2339406 | 149.721 | 1.669 | ✗ |
| uf125-012 | SAT | UNSAT | 1961090 | 125.509 | 1.568 | ✗ |
| uf125-013 | SAT | SAT | 652977 | 41.790 | 1.513 | ✓ |
| uf125-014 | SAT | UNSAT | 3217585 | 205.925 | 1.760 | ✗ |
| uf125-015 | SAT | UNSAT | 3284262 | 210.192 | 1.604 | ✗ |

**Summary** — 6 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1897779 &nbsp;|&nbsp; mean time: 121.457 ms &nbsp;|&nbsp; mean wall: 1.586s

---

## uuf125 — UNSAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf125-01 | UNSAT | UNSAT | 1592421 | 101.914 | 1.627 | ✓ |
| uuf125-02 | UNSAT | UNSAT | 2217475 | 141.918 | 1.630 | ✓ |
| uuf125-03 | UNSAT | UNSAT | 2111575 | 135.140 | 1.584 | ✓ |
| uuf125-04 | UNSAT | UNSAT | 3635027 | 232.641 | 1.695 | ✓ |
| uuf125-05 | UNSAT | UNSAT | 3114724 | 199.342 | 1.760 | ✓ |
| uuf125-06 | UNSAT | UNSAT | 2055116 | 131.527 | 1.526 | ✓ |
| uuf125-07 | UNSAT | UNSAT | 2449796 | 156.786 | 2.828 | ✓ |
| uuf125-08 | UNSAT | UNSAT | 3064133 | 196.104 | 1.629 | ✓ |
| uuf125-09 | UNSAT | UNSAT | 2272542 | 145.442 | 1.547 | ✓ |
| uuf125-010 | UNSAT | UNSAT | 1186062 | 75.907 | 1.520 | ✓ |
| uuf125-011 | UNSAT | UNSAT | 3616790 | 231.474 | 1.750 | ✓ |
| uuf125-012 | UNSAT | UNSAT | 2286819 | 146.356 | 1.716 | ✓ |
| uuf125-013 | UNSAT | UNSAT | 1253173 | 80.203 | 1.521 | ✓ |
| uuf125-014 | UNSAT | UNSAT | 1990433 | 127.387 | 1.499 | ✓ |
| uuf125-015 | UNSAT | UNSAT | 1988657 | 127.274 | 1.596 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 2322316 &nbsp;|&nbsp; mean time: 148.628 ms &nbsp;|&nbsp; mean wall: 1.695s

---

