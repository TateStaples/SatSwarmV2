# SatSwarm Benchmark Results

- **Grid config**: 1x1-maxlits16384
- **Run timestamp**: 20260326_124540
- **Instances per dataset**: 15
- **FPGA slot**: 0
- **Host binary**: /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host

---

## uf50 — SAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf50-01 | SAT | SAT | 37015 | 2.368 | 1.496 | ✓ |
| uf50-02 | SAT | SAT | 28539 | 1.826 | 1.391 | ✓ |
| uf50-03 | SAT | SAT | 71193 | 4.556 | 1.396 | ✓ |
| uf50-04 | SAT | SAT | 65308 | 4.179 | 1.389 | ✓ |
| uf50-05 | SAT | SAT | 7627 | .488 | 1.393 | ✓ |
| uf50-06 | SAT | SAT | 40094 | 2.566 | 1.390 | ✓ |
| uf50-07 | SAT | SAT | 25073 | 1.604 | 2.685 | ✓ |
| uf50-08 | SAT | SAT | 63561 | 4.067 | 1.415 | ✓ |
| uf50-09 | SAT | SAT | 51857 | 3.318 | 1.398 | ✓ |
| uf50-010 | SAT | SAT | 20162 | 1.290 | 1.389 | ✓ |
| uf50-011 | SAT | SAT | 64155 | 4.105 | 1.389 | ✓ |
| uf50-012 | SAT | SAT | 41124 | 2.631 | 1.398 | ✓ |
| uf50-013 | SAT | SAT | 6628 | .424 | 1.382 | ✓ |
| uf50-014 | SAT | SAT | 17397 | 1.113 | 1.397 | ✓ |
| uf50-015 | SAT | SAT | 19450 | 1.244 | 1.394 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 37278 &nbsp;|&nbsp; mean time: 2.385 ms &nbsp;|&nbsp; mean wall: 1.486s

---

## uuf50 — UNSAT, 50 vars, 218 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf50-01 | UNSAT | UNSAT | 52527 | 3.361 | 1.566 | ✓ |
| uuf50-02 | UNSAT | UNSAT | 49668 | 3.178 | 1.388 | ✓ |
| uuf50-03 | UNSAT | UNSAT | 51883 | 3.320 | 1.387 | ✓ |
| uuf50-04 | UNSAT | UNSAT | 65395 | 4.185 | 1.398 | ✓ |
| uuf50-05 | UNSAT | UNSAT | 57076 | 3.652 | 1.394 | ✓ |
| uuf50-06 | UNSAT | UNSAT | 83174 | 5.323 | 1.393 | ✓ |
| uuf50-07 | UNSAT | UNSAT | 91280 | 5.841 | 2.144 | ✓ |
| uuf50-08 | UNSAT | UNSAT | 49068 | 3.140 | 1.388 | ✓ |
| uuf50-09 | UNSAT | UNSAT | 87054 | 5.571 | 1.435 | ✓ |
| uuf50-010 | UNSAT | UNSAT | 50331 | 3.221 | 1.556 | ✓ |
| uuf50-011 | UNSAT | UNSAT | 93505 | 5.984 | 1.391 | ✓ |
| uuf50-012 | UNSAT | UNSAT | 73236 | 4.687 | 1.386 | ✓ |
| uuf50-013 | UNSAT | UNSAT | 52343 | 3.349 | 1.390 | ✓ |
| uuf50-014 | UNSAT | UNSAT | 58972 | 3.774 | 1.407 | ✓ |
| uuf50-015 | UNSAT | UNSAT | 54896 | 3.513 | 1.899 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 64693 &nbsp;|&nbsp; mean time: 4.140 ms &nbsp;|&nbsp; mean wall: 1.501s

---

## uf75 — SAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf75-01 | SAT | SAT | 227338 | 14.549 | 1.420 | ✓ |
| uf75-02 | SAT | SAT | 17624 | 1.127 | 1.538 | ✓ |
| uf75-03 | SAT | SAT | 40499 | 2.591 | 1.444 | ✓ |
| uf75-04 | SAT | SAT | 219590 | 14.053 | 1.568 | ✓ |
| uf75-05 | SAT | SAT | 134420 | 8.602 | 1.385 | ✓ |
| uf75-06 | SAT | SAT | 428480 | 27.422 | 1.405 | ✓ |
| uf75-07 | SAT | SAT | 384797 | 24.627 | 2.195 | ✓ |
| uf75-08 | SAT | SAT | 331808 | 21.235 | 1.540 | ✓ |
| uf75-09 | SAT | SAT | 130932 | 8.379 | 1.381 | ✓ |
| uf75-010 | SAT | SAT | 205597 | 13.158 | 1.392 | ✓ |
| uf75-011 | SAT | SAT | 303676 | 19.435 | 1.400 | ✓ |
| uf75-012 | SAT | UNSAT | 243474 | 15.582 | 1.388 | ✗ |
| uf75-013 | SAT | SAT | 40973 | 2.622 | 1.368 | ✓ |
| uf75-014 | SAT | SAT | 19057 | 1.219 | 1.402 | ✓ |
| uf75-015 | SAT | UNSAT | 298756 | 19.120 | 1.560 | ✗ |

**Summary** — 13 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 201801 &nbsp;|&nbsp; mean time: 12.915 ms &nbsp;|&nbsp; mean wall: 1.492s

---

## uuf75 — UNSAT, 75 vars, 325 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf75-01 | UNSAT | UNSAT | 259933 | 16.635 | 1.579 | ✓ |
| uuf75-02 | UNSAT | UNSAT | 144199 | 9.228 | 1.383 | ✓ |
| uuf75-03 | UNSAT | UNSAT | 418137 | 26.760 | 1.410 | ✓ |
| uuf75-04 | UNSAT | UNSAT | 198590 | 12.709 | 1.379 | ✓ |
| uuf75-05 | UNSAT | UNSAT | 557717 | 35.693 | 1.413 | ✓ |
| uuf75-06 | UNSAT | UNSAT | 289801 | 18.547 | 1.575 | ✓ |
| uuf75-07 | UNSAT | UNSAT | 226857 | 14.518 | 1.640 | ✓ |
| uuf75-08 | UNSAT | UNSAT | 268674 | 17.195 | 1.394 | ✓ |
| uuf75-09 | UNSAT | UNSAT | 164864 | 10.551 | 1.387 | ✓ |
| uuf75-010 | UNSAT | UNSAT | 252971 | 16.190 | 1.403 | ✓ |
| uuf75-011 | UNSAT | UNSAT | 718069 | 45.956 | 1.421 | ✓ |
| uuf75-012 | UNSAT | UNSAT | 339057 | 21.699 | 1.612 | ✓ |
| uuf75-013 | UNSAT | UNSAT | 309151 | 19.785 | 1.546 | ✓ |
| uuf75-014 | UNSAT | UNSAT | 410903 | 26.297 | 2.201 | ✓ |
| uuf75-015 | UNSAT | UNSAT | 274205 | 17.549 | 1.543 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 322208 &nbsp;|&nbsp; mean time: 20.621 ms &nbsp;|&nbsp; mean wall: 1.525s

---

## uf100 — SAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf100-01 | SAT | SAT | 303288 | 19.410 | 1.580 | ✓ |
| uf100-02 | SAT | SAT | 827105 | 52.934 | 1.618 | ✓ |
| uf100-03 | SAT | SAT | 544755 | 34.864 | 1.574 | ✓ |
| uf100-04 | SAT | UNSAT | 745563 | 47.716 | 1.599 | ✗ |
| uf100-05 | SAT | SAT | 119691 | 7.660 | 1.562 | ✓ |
| uf100-06 | SAT | SAT | 16449 | 1.052 | 1.375 | ✓ |
| uf100-07 | SAT | SAT | 218998 | 14.015 | 1.408 | ✓ |
| uf100-08 | SAT | UNSAT | 913094 | 58.438 | 1.462 | ✗ |
| uf100-09 | SAT | UNSAT | 1469095 | 94.022 | 1.642 | ✗ |
| uf100-010 | SAT | SAT | 248168 | 15.882 | 1.506 | ✓ |
| uf100-011 | SAT | SAT | 267287 | 17.106 | 1.391 | ✓ |
| uf100-012 | SAT | SAT | 214451 | 13.724 | 1.388 | ✓ |
| uf100-013 | SAT | UNSAT | 1112072 | 71.172 | 2.253 | ✗ |
| uf100-014 | SAT | UNSAT | 2099870 | 134.391 | 1.655 | ✗ |
| uf100-015 | SAT | UNSAT | 841418 | 53.850 | 1.511 | ✗ |

**Summary** — 9 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 662753 &nbsp;|&nbsp; mean time: 42.416 ms &nbsp;|&nbsp; mean wall: 1.568s

---

## uuf100 — UNSAT, 100 vars, 430 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf100-01 | UNSAT | UNSAT | 476018 | 30.465 | 1.535 | ✓ |
| uuf100-02 | UNSAT | UNSAT | 1865438 | 119.388 | 1.481 | ✓ |
| uuf100-03 | UNSAT | UNSAT | 1240227 | 79.374 | 1.569 | ✓ |
| uuf100-04 | UNSAT | UNSAT | 853040 | 54.594 | 1.571 | ✓ |
| uuf100-05 | UNSAT | UNSAT | 772384 | 49.432 | 1.518 | ✓ |
| uuf100-06 | UNSAT | UNSAT | 950938 | 60.860 | 1.601 | ✓ |
| uuf100-07 | UNSAT | UNSAT | 1382643 | 88.489 | 1.618 | ✓ |
| uuf100-08 | UNSAT | UNSAT | 844654 | 54.057 | 1.570 | ✓ |
| uuf100-09 | UNSAT | UNSAT | 960640 | 61.480 | 1.591 | ✓ |
| uuf100-010 | UNSAT | UNSAT | 875448 | 56.028 | 1.600 | ✓ |
| uuf100-011 | UNSAT | UNSAT | 1054091 | 67.461 | 1.596 | ✓ |
| uuf100-012 | UNSAT | UNSAT | 966984 | 61.886 | 1.494 | ✓ |
| uuf100-013 | UNSAT | UNSAT | 1170122 | 74.887 | 1.601 | ✓ |
| uuf100-014 | UNSAT | UNSAT | 863283 | 55.250 | 1.577 | ✓ |
| uuf100-015 | UNSAT | UNSAT | 995219 | 63.694 | 1.608 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1018075 &nbsp;|&nbsp; mean time: 65.156 ms &nbsp;|&nbsp; mean wall: 1.568s

---

## uf125 — SAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf125-01 | SAT | UNSAT | 5036000 | 322.304 | 1.827 | ✗ |
| uf125-02 | SAT | UNSAT | 15172678 | 971.051 | 2.444 | ✗ |
| uf125-03 | SAT | UNSAT | 2008381 | 128.536 | 1.834 | ✗ |
| uf125-04 | SAT | UNSAT | 3010503 | 192.672 | 1.663 | ✗ |
| uf125-05 | SAT | UNSAT | 8388 | .536 | 1.397 | ✗ |
| uf125-06 | SAT | UNSAT | 1019732 | 65.262 | 1.457 | ✗ |
| uf125-07 | SAT | UNSAT | 19225729 | 1230.446 | 2.754 | ✗ |
| uf125-08 | SAT | SAT | 16131177 | 1032.395 | 2.416 | ✓ |
| uf125-09 | SAT | UNSAT | 5058488 | 323.743 | 1.876 | ✗ |
| uf125-010 | SAT | UNSAT | 12157456 | 778.077 | 2.250 | ✗ |
| uf125-011 | SAT | UNSAT | 3010295 | 192.658 | 1.615 | ✗ |
| uf125-012 | SAT | UNSAT | 10150574 | 649.636 | 2.049 | ✗ |
| uf125-013 | SAT | UNSAT | 2008796 | 128.562 | 1.514 | ✗ |
| uf125-014 | SAT | SAT | 11072574 | 708.644 | 2.160 | ✓ |
| uf125-015 | SAT | UNSAT | 1045363 | 66.903 | 1.498 | ✗ |

**Summary** — 2 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 7074408 &nbsp;|&nbsp; mean time: 452.762 ms &nbsp;|&nbsp; mean wall: 1.916s

---

## uuf125 — UNSAT, 125 vars, 538 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf125-01 | UNSAT | UNSAT | 5036916 | 322.362 | 1.833 | ✓ |
| uuf125-02 | UNSAT | UNSAT | 27192790 | 1740.338 | 3.208 | ✓ |
| uuf125-03 | UNSAT | UNSAT | 5071080 | 324.549 | 1.797 | ✓ |
| uuf125-04 | UNSAT | UNSAT | 2064546 | 132.130 | 1.603 | ✓ |
| uuf125-05 | UNSAT | UNSAT | 3038497 | 194.463 | 2.316 | ✓ |
| uuf125-06 | UNSAT | UNSAT | 3030028 | 193.921 | 1.586 | ✓ |
| uuf125-07 | UNSAT | UNSAT | 14105 | .902 | 1.397 | ✓ |
| uuf125-08 | UNSAT | UNSAT | 5059313 | 323.796 | 1.714 | ✓ |
| uuf125-09 | UNSAT | UNSAT | 3059956 | 195.837 | 1.678 | ✓ |
| uuf125-010 | UNSAT | UNSAT | 4048238 | 259.087 | 1.648 | ✓ |
| uuf125-011 | UNSAT | UNSAT | 15157295 | 970.066 | 2.513 | ✓ |
| uuf125-012 | UNSAT | UNSAT | 6034725 | 386.222 | 1.915 | ✓ |
| uuf125-013 | UNSAT | UNSAT | 5042850 | 322.742 | 1.736 | ✓ |
| uuf125-014 | UNSAT | UNSAT | 3026803 | 193.715 | 1.665 | ✓ |
| uuf125-015 | UNSAT | UNSAT | 7087911 | 453.626 | 1.855 | ✓ |

**Summary** — 15 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 6264336 &nbsp;|&nbsp; mean time: 400.917 ms &nbsp;|&nbsp; mean wall: 1.897s

---

## uf150 — SAT, 150 vars, 645 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uf150-01 | SAT | SAT | 37481 | 2.398 | 1.538 | ✓ |
| uf150-02 | SAT | SAT | 49392 | 3.161 | 1.390 | ✓ |
| uf150-03 | SAT | SAT | 30071 | 1.924 | 1.400 | ✓ |
| uf150-04 | SAT | UNSAT | 1019058 | 65.219 | 1.455 | ✗ |
| uf150-05 | SAT | SAT | 1049660 | 67.178 | 1.598 | ✓ |
| uf150-06 | SAT | SAT | 41842 | 2.677 | 1.531 | ✓ |
| uf150-07 | SAT | SAT | 4026975 | 257.726 | 1.636 | ✓ |
| uf150-08 | SAT | UNSAT | 2016327 | 129.044 | 1.671 | ✗ |
| uf150-09 | SAT | SAT | 27939 | 1.788 | 1.469 | ✓ |
| uf150-010 | SAT | UNSAT | 2027860 | 129.783 | 1.687 | ✗ |
| uf150-011 | SAT | SAT | 1033311 | 66.131 | 1.521 | ✓ |
| uf150-012 | SAT | SAT | 1030510 | 65.952 | 1.595 | ✓ |
| uf150-013 | SAT | SAT | 3025558 | 193.635 | 1.720 | ✓ |
| uf150-014 | SAT | SAT | 31392 | 2.009 | 1.402 | ✓ |
| uf150-015 | SAT | SAT | 22829 | 1.461 | 1.389 | ✓ |

**Summary** — 12 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1031347 &nbsp;|&nbsp; mean time: 66.006 ms &nbsp;|&nbsp; mean wall: 1.533s

---

## uuf150 — UNSAT, 150 vars, 645 clauses

| Instance | Expected | Result | Cycles | Time (ms) | Wall (s) | ✓/✗ |
|----------|----------|--------|--------|-----------|----------|-----|
| uuf150-01 | UNSAT | SAT | 33505 | 2.144 | 1.367 | ✗ |
| uuf150-02 | UNSAT | SAT | 20085 | 1.285 | 2.702 | ✗ |
| uuf150-03 | UNSAT | SAT | 24206 | 1.549 | 1.386 | ✗ |
| uuf150-04 | UNSAT | SAT | 7038237 | 450.447 | 1.856 | ✗ |
| uuf150-05 | UNSAT | SAT | 2033757 | 130.160 | 1.676 | ✗ |
| uuf150-06 | UNSAT | UNSAT | 9534 | .610 | 1.466 | ✓ |
| uuf150-07 | UNSAT | SAT | 40666 | 2.602 | 1.393 | ✗ |
| uuf150-08 | UNSAT | SAT | 38034 | 2.434 | 1.386 | ✗ |
| uuf150-09 | UNSAT | SAT | 43584 | 2.789 | 1.793 | ✗ |
| uuf150-010 | UNSAT | SAT | 40890 | 2.616 | 1.392 | ✗ |
| uuf150-011 | UNSAT | SAT | 1047743 | 67.055 | 1.457 | ✗ |
| uuf150-012 | UNSAT | SAT | 7067468 | 452.317 | 1.978 | ✗ |
| uuf150-013 | UNSAT | UNSAT | 1050488 | 67.231 | 1.610 | ✓ |
| uuf150-014 | UNSAT | SAT | 40138 | 2.568 | 1.525 | ✗ |
| uuf150-015 | UNSAT | SAT | 21130 | 1.352 | 1.388 | ✗ |

**Summary** — 2 / 15 correct &nbsp;|&nbsp; 0 timeouts &nbsp;|&nbsp; mean cycles: 1236631 &nbsp;|&nbsp; mean time: 79.144 ms &nbsp;|&nbsp; mean wall: 1.625s

---

