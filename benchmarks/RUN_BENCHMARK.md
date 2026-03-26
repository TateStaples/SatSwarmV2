# SatSwarm Benchmark Run Instructions

This document covers loading an AFI and running the benchmark suite against it.
Results are saved to `benchmarks/results/<timestamp>/` after each dataset batch.

---

## Prerequisites

1. You are on an F2 instance with the AWS SDK sourced
2. The host app is built (`hdk_cl_satswarm/host/satswarm_host` exists)
3. An AFI is available (state = `available`) — see `docs/FPGA.md` for the full list

If you need to build the host app:

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2
source src/aws-fpga/sdk_setup.sh
cd hdk_cl_satswarm/host && make
```

---

## Step 1 — Load the AFI

### 1×1 (preferred, PCIS-fixed, validated)

```bash
source src/aws-fpga/sdk_setup.sh
sudo fpga-clear-local-image -S 0
sudo fpga-load-local-image -S 0 -I agfi-0aa0b1b8ec26f6b5d
sudo fpga-describe-local-image -S 0 -H
```

### 2×2 (preferred 2×2)

```bash
source src/aws-fpga/sdk_setup.sh
sudo fpga-clear-local-image -S 0
sudo fpga-load-local-image -S 0 -I agfi-022074a3e1f323966
sudo fpga-describe-local-image -S 0 -H
```

### 2×2 sharing-mode variants (once available)

| Mode   | agfi                        |
|--------|-----------------------------|
| none   | agfi-06be2426aa615503a      |
| 2clz   | agfi-028e6419bce2d9003      |
| 3clz   | agfi-03c4ec38595841774      |

Confirm `StatusName: loaded` before continuing.

---

## Step 2 — Validate a single problem first

Always do a single-file sanity check before running the full suite:

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2
./hdk_cl_satswarm/host/satswarm_host \
  benchmarks/satlib_3sat/sat/uf50/uf50-01.cnf \
  --slot 0 --timeout 15 --debug 0
```

Expected output includes `Result: SAT` and a `Cycles:` count.
If this hangs or errors, do not proceed — reload the AFI and recheck.

---

## Step 3 — Run the smoke test first

Before running the full suite, use the smoke test to confirm the end-to-end pipeline works.
It runs only `uf50` and `uuf50` (15 instances each = 30 problems total, ~5 minutes).

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2

export GRID=1x1    # match the AFI you loaded
export SLOT=0
export N=15

bash benchmarks/run_smoke_test.sh
```

Check the output for:
- All 30 results showing `✓` (correct)
- No `ERROR` or `TIMEOUT` results
- Cycles and time values that look reasonable (uf50 should be in the tens-of-thousands of cycles)

Results are saved to `benchmarks/results/smoke_<timestamp>_<GRID>/`.
If anything looks wrong here, do not proceed to the full suite.

---

## Step 4 — Run the full benchmark suite

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2

# Set the grid label (used for output file naming and the results table)
export GRID=1x1    # or 2x2, 2x2-none, 2x2-2clz, 2x2-3clz

# Optional overrides (defaults shown)
export SLOT=0
export N=15        # instances per dataset
export HOST=$PWD/hdk_cl_satswarm/host/satswarm_host

bash benchmarks/run_benchmark.sh
```

Results are written to `benchmarks/results/<timestamp>_<GRID>/`:

| File          | Contents                                          |
|---------------|---------------------------------------------------|
| `results.md`  | Markdown table per dataset, appended after each batch |
| `results.csv` | One row per instance — all raw data               |
| `run.log`     | Full verbose output from every host invocation    |

---

## Step 5 — Compare 1×1 vs 2×2

Run the suite twice (once per AFI), keeping the output directories.
The CSV schema is identical between runs, so you can diff or join them
on `dataset,instance` to compute speedup.

---

## Timeouts used per dataset

These are baked into the script and scale with problem size:

| Dataset       | Timeout |
|---------------|---------|
| uf50 / uuf50  | 15s     |
| uf75 / uuf75  | 20s     |
| uf100 / uuf100| 30s     |
| uf125 / uuf125| 45s     |
| uf150 / uuf150| 60s     |
| uf175 / uuf175| 90s     |
| uf200 / uuf200| 120s    |
| uf225 / uuf225| 150s    |
| uf250 / uuf250| 180s    |
