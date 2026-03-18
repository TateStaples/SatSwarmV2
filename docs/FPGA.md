# FPGA Deployment Instructions

This document outlines the final steps to deploy SatSwarm V2 to an AWS F2 instance.

---

## Quick Start (AFIs Ready)

1×1 and 2×2 CDC-fixed AFIs are **available**. To load on an F2 instance:

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga
source sdk_setup.sh
sudo fpga-clear-local-image -S 0
# 1×1: 4 solver cores
sudo fpga-load-local-image -S 0 -l agfi-0f933cb959906a494
# 2×2: 16 solver cores
# sudo fpga-load-local-image -S 0 -l agfi-0193eda3eade22ae4
sudo fpga-describe-local-image -S 0 -H
```

| AFI | agfi | Grid | Tag | Clock |
|-----|------|------|-----|-------|
| afi-08366141b8a92b36f | agfi-0f933cb959906a494 | 1×1 | 2026_03_18-163435 | A2 / 15.625 MHz |
| afi-01ef63d452c8940a2 | agfi-0193eda3eade22ae4 | 2×2 | 2026_03_18-171846 | A2 / 15.625 MHz |

---

## 1. Bitstream Artifacts

All artifacts are under:
`/home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/hdk/cl/examples/cl_satswarm/build/checkpoints/`

> **Important**: All builds prior to commit `fd6a0a3` (REQP-123 fix) will fail AWS bitgen with `UNKNOWN_BITSTREAM_GENERATE_ERROR`. Do not submit those tars.

### Build History

| Tag | Grid | Clock | WNS | Tar on disk | S3 | AFI | Notes |
|---|---|---|---|---|---|---|---|
| `2026_03_18-004125` | 1×1 | A2 / 15.625 MHz | +0.711 ns | ✅ | ✅ | ❌ | Pre-REQP-123-fix |
| `2026_03_18-020509` | 2×2 | A2 / 15.625 MHz | +0.711 ns | ✅ | ✅ | ❌ | Pre-REQP-123-fix |
| `2026_03_18-120815` | 1×1 | A1 / 150 MHz | -18.135 ns | ✅ | ❌ | — | Timing failure |
| `2026_03_18-142140` | 1×1 | A1 / 150 MHz | -18.820 ns | ✅ | ❌ | — | 2nd timing fail (pos_mem/bubble), killed |
| `2026_03_18-151300` | 1×1 | A2 / 15.625 MHz | -1.627 ns | ✅ | ❌ | — | CDC fail (pre-ef79614) |
| **`2026_03_18-163435`** | **1×1** | **A2 / 15.625 MHz** | **+0.711 ns** | **✅** | **✅** | **✅ available** | **CDC fixed, use this** |
| **`2026_03_18-171846`** | **2×2** | **A2 / 15.625 MHz** | **+0.711 ns** | **✅** | **✅** | **✅ available** | **CDC fixed, 2×2 grid** |

---

## 2. Amazon FPGA Image (AFI) Creation Workflow

### Step 2a: Upload Tarball to S3

```bash
# Replace <tag> with the actual build tag (e.g. 2026_03_18-142140)
TAG=<tag>
aws s3 cp \
  /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/hdk/cl/examples/cl_satswarm/build/checkpoints/${TAG}.Developer_CL.tar \
  s3://satswarm-v2-afi-624824941978/dcp/${TAG}.Developer_CL.tar
```

### Step 2b: Request AFI Creation

```bash
TAG=<tag>
aws ec2 create-fpga-image \
    --region us-east-1 \
    --name "SatSwarmV2-1x1-15MHz" \
    --description "SatSwarm V2 CDCL solver, 1x1 grid, A2/15.625 MHz, REQP-123+CDC fixed" \
    --input-storage-location Bucket=satswarm-v2-afi-624824941978,Key=dcp/${TAG}.Developer_CL.tar \
    --logs-storage-location Bucket=satswarm-v2-afi-624824941978,Key=logs/
```

Each command returns `FpgaImageId` (`afi-*`, for polling) and `FpgaImageGlobalId` (`agfi-*`, for loading). **Save both.**

### Step 2c: Poll for Availability (10–30 min)

```bash
aws ec2 describe-fpga-images \
  --fpga-image-ids afi-08366141b8a92b36f \
  --query 'FpgaImages[*].{Id:FpgaImageId,State:State}' \
  --region us-east-1
```

Wait until `{"Code": "available"}` for the AFI you want to load.

---

## 3. Load onto the F2 Instance

Once an AFI is `available`, connect to your F2 instance:

```bash
# Source the AWS SDK (not HDK)
cd /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga
source sdk_setup.sh

# Clear the current slot 0 image
sudo fpga-clear-local-image -S 0

# Load the AFI (use the agfi-* GlobalId; 1×1 or 2×2)
sudo fpga-load-local-image -S 0 -l agfi-0f933cb959906a494   # 1×1
# sudo fpga-load-local-image -S 0 -l agfi-0193eda3eade22ae4  # 2×2

# Verify loaded successfully
sudo fpga-describe-local-image -S 0 -H
```

Verify `StatusName: loaded` in the output. The solver is now running on the FPGA.

---

## 4. AFI History

| AFI ID | Grid | Tag | Clock | Status | Notes |
|---|---|---|---|---|---|
| `afi-0edbf121d0cabe2b3` | 1×1 | `2026_03_18-004125` | A2 / 15.625 MHz | FAILED | `UNKNOWN_BITSTREAM_GENERATE_ERROR` — root cause: REQP-123 (pre-fix tar) |
| `afi-033c546a9698c9134` | 1×1 | `2026_03_18-004125` | A2 / 15.625 MHz | cancelled/ignore | Same broken tar — do not use |
| `afi-0a3e524ae986734e5` | 2×2 | `2026_03_18-020509` | A2 / 15.625 MHz | cancelled/ignore | Pre-fix tar — do not use |
| **`afi-08366141b8a92b36f`** | **1×1** | **`2026_03_18-163435`** | **A2 / 15.625 MHz** | **available** | **agfi-0f933cb959906a494** |
| **`afi-01ef63d452c8940a2`** | **2×2** | **`2026_03_18-171846`** | **A2 / 15.625 MHz** | **available** | **agfi-0193eda3eade22ae4** |

> AFIs from tars predating the REQP-123 fix (fd6a0a3) will fail bitgen. Use the CDC-fixed builds above (1×1 or 2×2).

---

## 5. Hardware Testbenches & Data Collection

These testbenches generate the cycle-count and speedup data used to characterize and project SatSwarm performance. Run them from the `sim/` directory on any machine where the Verilator binaries have been built.

---

### 5a. Scaling Data Collection (Primary Benchmark)

`run_aws_scaling_collection.sh` orchestrates the full data pipeline: it builds any missing Verilator configs, runs all selected CNFs across each config, fits a runtime distribution to the 1×1 baseline, and projects speedup to arbitrary core counts via Monte Carlo.

**Minimum run (1×1 and 2×2, generated test suite):**

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim

bash scripts/run_aws_scaling_collection.sh \
  --configs 1x1,2x2 \
  --benchmark-profile generated_instances \
  --runs-per-test 1
```

**Broader benchmark covering SATLIB families (UF/UUF 20–150, QG, BMC, HOLE, etc.):**

```bash
bash scripts/run_aws_scaling_collection.sh \
  --configs 1x1,2x2 \
  --benchmark-profile verisat_full \
  --runs-per-test 3 \
  --min-baseline-samples 20
```

**All options:**

| Flag | Default | Description |
|---|---|---|
| `--configs CSV` | `1x1,2x2` | Comma-separated grid configs; each must have a built binary (`obj_dir_<cfg>/Vtb_satswarmv2`) |
| `--benchmark-profile` | `verisat_full` | `verisat_full` — SATLIB families; `generated_instances` — `tests/generated_instances/`; `custom_dir` — `--suite-dir` path |
| `--runs-per-test N` | `10` | Repeated runs per CNF per config (for variance estimates) |
| `--max-tests N` | `0` (all) | Limit number of CNF files sampled (useful for quick checks) |
| `--timeout-sec N` | `180` | Wall-clock timeout per run |
| `--max-cycles N` | `5000000` | `+MAXCYCLES` plusarg passed to the binary |
| `--topology NAME` | `mesh` | Communication overhead model: `all_to_all`, `ring`, `tree`, `mesh` |
| `--projection-cores CSV` | `1,2,4,…,512` | Core counts to project speedup to |
| `--min-baseline-samples N` | `20` | Minimum 1×1 PASS samples required before fitting |
| `--seed N` | `12345` | RNG seed for sampling and Monte Carlo |
| `--skip-build` | off | Skip `make build_<cfg>` (if binaries already exist) |
| `--suite-dir PATH` | `tests/generated_instances` | CNF directory (relative to `sim/`) for `custom_dir` profile |

**Output files** (written to `sim/logs/benchmark_results/scaling_<timestamp>/`):

| File | Content |
|---|---|
| `raw_runs.csv` | One row per CNF × config × run: benchmark, config, cores, expected, result, cycles, wall_sec, timed_out, command |
| `aggregate_by_config.csv` | Per-config summary: mean/median cycles, mean wall time, success rate |
| `fit_summary.json` | Distribution fit results (exponential, shifted-exponential, lognormal, Weibull ranked by AIC); best fit params; estimated mesh overhead `alpha`; measured speedups |
| `scaling_projection.csv` | Projected speedup at each `--projection-cores` value: independent, sharing-adjusted, and overhead-corrected |
| `summary.txt` | Human-readable summary of fit, alpha, measured speedups, and projection file paths |

**Quick sanity check (10 CNFs only, skip build):**

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim
ln -sfn obj_dir_1x1 obj_dir   # ensure symlink exists
bash scripts/run_aws_scaling_collection.sh \
  --configs 1x1,2x2 \
  --max-tests 10 \
  --runs-per-test 1 \
  --benchmark-profile generated_instances \
  --skip-build
```

---

### 5b. Full Regression (Correctness Gate)

Run the 98-file ladder before any data collection run to confirm correctness:

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim
ln -sfn obj_dir_1x1 obj_dir

bash scripts/run_bigger_ladder.sh
```

Expected: `98/98 ALL TESTS PASSED`. Each failing file prints the command to reproduce it in isolation.

---

### 5c. AWS HDK XSim Regression (Shell Integration)

Verifies the AXI shell interface wiring using the AWS XSim BFM. Slower than Verilator (~10× per file; 180 s timeout per CNF).

```bash
# Requires HDK env vars (see Deploy.md "Initialize HDK Environment"):
cd /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/hdk/cl/examples/cl_satswarm/verif/scripts

# Single smoke test:
make TEST=test_satswarm_aws
# Expected: "RESULT: *** TEST PASSED ***"

# Full regression over all generated instances:
cd /home/ubuntu/src/project_data/SatSwarmV2
bash sim/scripts/run_aws_regression.sh
```

> **Note**: `run_aws_regression.sh` checks for `$HDK_DIR` on entry and exits if unset. Set the manual env block from Deploy.md first.

---

### 5d. SATLIB Corpus Validation

Before running benchmarks against SATLIB instances, verify their SAT/UNSAT ground-truth labels using PySAT:

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim

# Validate all instances under tests/satlib/ (sat/ and unsat/ subdirs):
python3 tests/validate_satlib.py --root tests/satlib

# Validate a specific family:
python3 tests/validate_satlib.py --root tests/satlib --pattern uf50 --log-every 1

# Options:
#   --solver g3|g4|m22|cadical124   PySAT solver (default: g3 / Glucose3)
#   --limit N                        Stop after N files
#   --quiet                          Suppress per-instance output except errors
```

Exit code 0 = all labels confirmed correct. Exit code 2 = mismatch or error found — do not run benchmarks until resolved.

---

### Data Collection Workflow Summary

```
# 1. Build Verilator configs (once, or after RTL changes)
cd sim
make build_1x1 && make build_2x2
ln -sfn obj_dir_1x1 obj_dir

# 2. Correctness gate
bash scripts/run_bigger_ladder.sh              # must be 98/98

# 3. Optional: validate SATLIB labels
python3 tests/validate_satlib.py --root tests/satlib --quiet

# 4. Collect scaling data
bash scripts/run_aws_scaling_collection.sh \
  --configs 1x1,2x2 \
  --benchmark-profile verisat_full \
  --runs-per-test 3

# 5. Inspect outputs
ls logs/benchmark_results/scaling_*/
cat logs/benchmark_results/scaling_*/summary.txt
```
