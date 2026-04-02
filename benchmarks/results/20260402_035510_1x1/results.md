# SatSwarm Benchmark Results

- **Grid config**: 1x1
- **Run timestamp**: 20260402_035510
- **Instances per dataset**: 15
- **FPGA slot**: 0
- **Host binary**: /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 38447 | 2.460 | 1.548 | ✓ |
| uf50-02 | SAT | SAT | 30050 | 1.923 | 1.390 | ✓ |
| uf50-03 | SAT | SAT | 72500 | 4.640 | 1.387 | ✓ |
| uf50-04 | SAT | SAT | 66868 | 4.279 | 1.402 | ✓ |
| uf50-05 | SAT | SAT | 9233 | .590 | 1.394 | ✓ |
| uf50-06 | SAT | SAT | 41627 | 2.664 | 1.397 | ✓ |
| uf50-07 | SAT | SAT | 26685 | 1.707 | 1.392 | ✓ |
| uf50-08 | SAT | SAT | 65138 | 4.168 | 1.399 | ✓ |
| uf50-09 | SAT | SAT | 53380 | 3.416 | 1.401 | ✓ |
| uf50-010 | SAT | SAT | 21689 | 1.388 | 1.387 | ✓ |
| uf50-011 | SAT | SAT | 65609 | 4.198 | 1.396 | ✓ |
| uf50-012 | SAT | SAT | 42667 | 2.730 | 1.393 | ✓ |
| uf50-013 | SAT | SAT | 8326 | .532 | 1.396 | ✓ |
| uf50-014 | SAT | SAT | 19041 | 1.218 | 1.389 | ✓ |
| uf50-015 | SAT | SAT | 21104 | 1.350 | 1.395 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 38824 &nbsp;|&nbsp; mean time: 2.484 ms &nbsp;|&nbsp; mean wall: 1.404s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 54056 | 3.459 | 1.465 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 51377 | 3.288 | 1.391 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 53371 | 3.415 | 1.392 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 67028 | 4.289 | 1.388 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 58665 | 3.754 | 1.388 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 84719 | 5.422 | 1.406 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 92804 | 5.939 | 1.409 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 50625 | 3.240 | 2.257 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 88499 | 5.663 | 1.400 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 51916 | 3.322 | 1.380 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 94952 | 6.076 | 1.398 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 74868 | 4.791 | 1.390 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 53800 | 3.443 | 1.382 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 60562 | 3.875 | 1.403 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 56359 | 3.606 | 1.409 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 66240 &nbsp;|&nbsp; mean time: 4.239 ms &nbsp;|&nbsp; mean wall: 1.457s

---

## uf75 — SAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf75-01 | SAT | SAT | 255127 | 16.328 | 1.504 | ✓ |
| uf75-02 | SAT | SAT | 19176 | 1.227 | 1.379 | ✓ |
| uf75-03 | SAT | SAT | 42050 | 2.691 | 1.388 | ✓ |
| uf75-04 | SAT | SAT | 221238 | 14.159 | 1.396 | ✓ |
| uf75-05 | SAT | SAT | 136124 | 8.711 | 1.384 | ✓ |
| uf75-06 | SAT | SAT | 605014 | 38.720 | 1.428 | ✓ |
| uf75-07 | SAT | SAT | 577070 | 36.932 | 1.583 | ✓ |
| uf75-08 | SAT | SAT | 410916 | 26.298 | 2.093 | ✓ |
| uf75-09 | SAT | SAT | 132499 | 8.479 | 1.542 | ✓ |
| uf75-010 | SAT | SAT | 206973 | 13.246 | 1.405 | ✓ |
| uf75-011 | SAT | UNSAT | 457898 | 29.305 | 1.600 | ✗ |
| uf75-012 | SAT | UNSAT | 238177 | 15.243 | 1.575 | ✗ |
| uf75-013 | SAT | SAT | 42538 | 2.722 | 1.394 | ✓ |
| uf75-014 | SAT | SAT | 20406 | 1.305 | 1.566 | ✓ |
| uf75-015 | SAT | SAT | 255504 | 16.352 | 1.730 | ✓ |

**Summary** — 13 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 241380 &nbsp;|&nbsp; mean time: 15.448 ms &nbsp;|&nbsp; mean wall: 1.531s

---

## uuf75 — UNSAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf75-01 | UNSAT | UNSAT | 264506 | 16.928 | 1.570 | ✓ |
| uuf75-02 | UNSAT | UNSAT | 145629 | 9.320 | 1.379 | ✓ |
| uuf75-03 | UNSAT | UNSAT | 851402 | 54.489 | 1.434 | ✓ |
| uuf75-04 | UNSAT | UNSAT | 199306 | 12.755 | 1.547 | ✓ |
| uuf75-05 | UNSAT | UNSAT | 629953 | 40.316 | 1.412 | ✓ |
| uuf75-06 | UNSAT | UNSAT | 356148 | 22.793 | 1.572 | ✓ |
| uuf75-07 | UNSAT | UNSAT | 239119 | 15.303 | 1.950 | ✓ |
| uuf75-08 | UNSAT | UNSAT | 353837 | 22.645 | 1.393 | ✓ |
| uuf75-09 | UNSAT | UNSAT | 166432 | 10.651 | 1.378 | ✓ |
| uuf75-010 | UNSAT | UNSAT | 301746 | 19.311 | 1.403 | ✓ |
| uuf75-011 | UNSAT | UNSAT | 536634 | 34.344 | 1.402 | ✓ |
| uuf75-012 | UNSAT | UNSAT | 423524 | 27.105 | 1.588 | ✓ |
| uuf75-013 | UNSAT | UNSAT | 316807 | 20.275 | 1.585 | ✓ |
| uuf75-014 | UNSAT | UNSAT | 315679 | 20.203 | 2.373 | ✓ |
| uuf75-015 | UNSAT | UNSAT | 286466 | 18.333 | 1.409 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 359145 &nbsp;|&nbsp; mean time: 22.985 ms &nbsp;|&nbsp; mean wall: 1.559s

---

## uf100 — SAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf100-01 | SAT | SAT | 1354075 | 86.660 | 1.618 | ✓ |
| uf100-02 | SAT | SAT | 447313 | 28.628 | 1.534 | ✓ |
| uf100-03 | SAT | SAT | 531388 | 34.008 | 1.597 | ✓ |
| uf100-04 | SAT | SAT | 980676 | 62.763 | 1.623 | ✓ |
| uf100-05 | SAT | SAT | 149380 | 9.560 | 1.535 | ✓ |
| uf100-06 | SAT | SAT | 17912 | 1.146 | 1.527 | ✓ |
| uf100-07 | SAT | SAT | 193240 | 12.367 | 1.398 | ✓ |
| uf100-08 | SAT | UNSAT | 3524662 | 225.578 | 1.615 | ✗ |
| uf100-09 | SAT | SAT | 364822 | 23.348 | 1.402 | ✓ |
| uf100-010 | SAT | SAT | 168741 | 10.799 | 1.576 | ✓ |
| uf100-011 | SAT | SAT | 543850 | 34.806 | 1.418 | ✓ |
| uf100-012 | SAT | SAT | 275769 | 17.649 | 1.576 | ✓ |
| uf100-013 | SAT | UNSAT | 2295599 | 146.918 | 2.023 | ✗ |
| uf100-014 | SAT | SAT | 589743 | 37.743 | 1.487 | ✓ |
| uf100-015 | SAT | UNSAT | 1394358 | 89.238 | 1.641 | ✗ |

**Summary** — 12 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 855435 &nbsp;|&nbsp; mean time: 54.747 ms &nbsp;|&nbsp; mean wall: 1.571s

---

## uuf100 — UNSAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf100-01 | UNSAT | UNSAT | 1379909 | 88.314 | 1.562 | ✓ |
| uuf100-02 | UNSAT | UNSAT | 2636028 | 168.705 | 1.674 | ✓ |
| uuf100-03 | UNSAT | UNSAT | 2955233 | 189.134 | 1.627 | ✓ |
| uuf100-04 | UNSAT | UNSAT | 2738607 | 175.270 | 1.575 | ✓ |
| uuf100-05 | UNSAT | UNSAT | 3389347 | 216.918 | 1.659 | ✓ |
| uuf100-06 | UNSAT | UNSAT | 1041313 | 66.644 | 1.440 | ✓ |
| uuf100-07 | UNSAT | UNSAT | 1275655 | 81.641 | 1.608 | ✓ |
| uuf100-08 | UNSAT | UNSAT | 2219006 | 142.016 | 1.646 | ✓ |
| uuf100-09 | UNSAT | UNSAT | 972305 | 62.227 | 1.511 | ✓ |
| uuf100-010 | UNSAT | UNSAT | 1285392 | 82.265 | 1.609 | ✓ |
| uuf100-011 | UNSAT | UNSAT | 3049918 | 195.194 | 1.702 | ✓ |
| uuf100-012 | UNSAT | UNSAT | 1709048 | 109.379 | 1.621 | ✓ |
| uuf100-013 | UNSAT | UNSAT | 701355 | 44.886 | 1.521 | ✓ |
| uuf100-014 | UNSAT | UNSAT | 1052519 | 67.361 | 1.610 | ✓ |
| uuf100-015 | UNSAT | UNSAT | 1438960 | 92.093 | 1.615 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1856306 &nbsp;|&nbsp; mean time: 118.803 ms &nbsp;|&nbsp; mean wall: 1.598s

---

## uf125 — SAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf125-01 | SAT | SAT | 371951 | 23.804 | 1.507 | ✓ |
| uf125-02 | SAT | UNSAT | 3040363 | 194.583 | 1.761 | ✗ |
| uf125-03 | SAT | SAT | 2639756 | 168.944 | 2.323 | ✓ |
| uf125-04 | SAT | UNSAT | 2646564 | 169.380 | 1.590 | ✗ |
| uf125-05 | SAT | SAT | 787282 | 50.386 | 1.476 | ✓ |
| uf125-06 | SAT | SAT | 120747 | 7.727 | 1.557 | ✓ |
| uf125-07 | SAT | SAT | 757113 | 48.455 | 1.443 | ✓ |
| uf125-08 | SAT | UNSAT | 2448613 | 156.711 | 1.693 | ✗ |
| uf125-09 | SAT | UNSAT | 2964687 | 189.739 | 1.643 | ✗ |
| uf125-010 | SAT | UNSAT | 1234331 | 78.997 | 1.712 | ✗ |
| uf125-011 | SAT | UNSAT | 2339377 | 149.720 | 1.653 | ✗ |
| uf125-012 | SAT | UNSAT | 1961219 | 125.518 | 1.566 | ✗ |
| uf125-013 | SAT | SAT | 652739 | 41.775 | 1.502 | ✓ |
| uf125-014 | SAT | UNSAT | 3217643 | 205.929 | 1.579 | ✗ |
| uf125-015 | SAT | UNSAT | 3284229 | 210.190 | 1.594 | ✗ |

**Summary** — 6 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1897774 &nbsp;|&nbsp; mean time: 121.457 ms &nbsp;|&nbsp; mean wall: 1.639s

---

## uuf125 — UNSAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf125-01 | UNSAT | UNSAT | 1592244 | 101.903 | 1.661 | ✓ |
| uuf125-02 | UNSAT | UNSAT | 2217321 | 141.908 | 1.506 | ✓ |
| uuf125-03 | UNSAT | UNSAT | 2111651 | 135.145 | 1.592 | ✓ |
| uuf125-04 | UNSAT | UNSAT | 3635187 | 232.651 | 1.685 | ✓ |
| uuf125-05 | UNSAT | UNSAT | 3114900 | 199.353 | 1.571 | ✓ |
| uuf125-06 | UNSAT | UNSAT | 2054979 | 131.518 | 1.514 | ✓ |
| uuf125-07 | UNSAT | UNSAT | 2449896 | 156.793 | 1.617 | ✓ |
| uuf125-08 | UNSAT | UNSAT | 3064147 | 196.105 | 1.625 | ✓ |
| uuf125-09 | UNSAT | UNSAT | 2272714 | 145.453 | 1.574 | ✓ |
| uuf125-010 | UNSAT | UNSAT | 1186205 | 75.917 | 1.522 | ✓ |
| uuf125-011 | UNSAT | UNSAT | 3616883 | 231.480 | 1.746 | ✓ |
| uuf125-012 | UNSAT | UNSAT | 2286913 | 146.362 | 1.707 | ✓ |
| uuf125-013 | UNSAT | UNSAT | 1253226 | 80.206 | 1.525 | ✓ |
| uuf125-014 | UNSAT | UNSAT | 1990515 | 127.392 | 1.647 | ✓ |
| uuf125-015 | UNSAT | UNSAT | 1988554 | 127.267 | 1.594 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 2322355 &nbsp;|&nbsp; mean time: 148.630 ms &nbsp;|&nbsp; mean wall: 1.605s

---

## Overall Summary

- **Grid**: 1x1
- **Total correct**: 106 / 120
- **Finished**: Thu Apr  2 03:58:18 UTC 2026
