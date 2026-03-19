# Modeling From Measured Data

This document explains how to take measured cycle-count CSVs and turn them into a scaling model. `Scaling.md` is the theory document; this file is the practical guide for applying that theory with the scripts that already exist in the repository.

---

## Inputs

There are two useful classes of input data:

1. **Simulation-generated scaling data**  
   Produced directly by:
   - `sim/scripts/run_aws_scaling_collection.sh`
   - `sim/scripts/collect_scaling_data.py`

2. **Custom measured CSVs**  
   Produced by:
   - simulation benchmark scripts such as `sim/scripts/stability_test_50v.sh` and `sim/scripts/speedup_benchmark_50v.sh`
   - FPGA-side host wrappers: `hdk_cl_satswarm/scripts/run_fpga_suite.sh` and `hdk_cl_satswarm/scripts/run_fpga_scaling_collection.sh`

For the first case, the full fitting and projection pipeline runs automatically. For the second case, use `sim/scripts/convert_fpga_csv.py` to normalize the host-side CSV and `sim/scripts/refit_project.py` to fit and project. See "Working From A Custom CSV" below.

---

## Recommended Workflow

### Path A: use the full built-in pipeline

If your goal is "collect data and immediately fit / project," use the existing scaling collector.

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/sim

bash scripts/run_aws_scaling_collection.sh \
  --configs 1x1,2x2 \
  --benchmark-profile verisat_full \
  --runs-per-test 3 \
  --min-baseline-samples 20
```

This produces:

- `raw_runs.csv`
- `aggregate_by_config.csv`
- `fit_summary.json`
- `scaling_projection.csv`
- `summary.txt`

under `sim/logs/benchmark_results/scaling_<timestamp>/`.

This is the easiest path because the script both **collects** the data and **fits** the model.

### Path B: use smaller benchmark scripts first

For quicker exploration, the repository also has lighter-weight benchmarking scripts:

- `sim/scripts/stability_test_50v.sh`
- `sim/scripts/speedup_benchmark_50v.sh`
- `sim/scripts/benchmark_suite.py`

These are useful when you want:

- quick SAT / UNSAT sanity on a family
- coarse speedup numbers across 1×1 / 2×2 / 3×3
- small CSVs before a full `collect_scaling_data.py` run

These scripts do **not** currently replace the full fitting pipeline; they are good for exploratory benchmarking and spot checks.

---

## What The Main Modeling Script Actually Does

`sim/scripts/collect_scaling_data.py` performs five main steps:

1. **Discover benchmark files**  
   It selects CNFs from:
   - `generated_instances`
   - `verisat_full`
   - `custom_dir`

2. **Run each config**  
   It runs each requested config (`1x1`, `2x2`, `3x3`) and records:
   - expected result
   - PASS / FAIL / timeout
   - cycle count
   - wall-clock runtime
   - the full command used

3. **Build the 1×1 baseline distribution**  
   It extracts successful `1x1` cycle counts and requires at least `--min-baseline-samples` samples.

4. **Fit candidate runtime distributions**  
   It fits:
   - exponential
   - shifted exponential
   - lognormal
   - Weibull

   then ranks them by AIC and selects the best fit.

5. **Project scaling**  
   It uses Monte Carlo order-statistics estimates plus a topology overhead model to predict larger-core speedup.

---

## How To Read The Outputs

### `raw_runs.csv`

This is the authoritative measurement log.

Important columns:

- `benchmark`
- `config`
- `cores`
- `result`
- `cycles`
- `wall_sec`
- `timed_out`

Use this when you want to audit:

- which instances actually passed
- where timeouts happened
- whether one config is noisier than another

### `aggregate_by_config.csv`

This summarizes each measured config:

- success rate
- mean cycles
- median cycles
- mean wall-clock time

Use this for quick comparisons between measured configs.

### `fit_summary.json`

This is the best artifact for understanding the model.

It contains:

- the ranked candidate fits
- the selected best fit
- `baseline_mean_cycles`
- measured speedups for observed multi-core points
- the estimated communication-overhead parameter `alpha`
- per-config success rates

### `scaling_projection.csv`

This is the practical projection output. For each projected core count it includes:

- `independent_speedup`
- `sharing_speedup`
- `overhead_fraction`
- `projected_actual_speedup`

Read it as:

- `independent_speedup` = what order statistics alone would predict
- `sharing_speedup` = order statistics after any clause-sharing uplift term
- `projected_actual_speedup` = what survives after the topology overhead penalty

### `summary.txt`

Short human-readable summary of the run.

---

## Mapping `Scaling.md` Into The Script

`Scaling.md` gives the theory; here is how it appears in the existing code.

### 1. Order statistics baseline

`Scaling.md` models parallel runtime as the minimum of `n` i.i.d. draws from the single-core runtime distribution.

In `collect_scaling_data.py`, that becomes:

- fit the `1x1` runtime distribution
- sample from the chosen fit
- estimate the expected minimum for `n` draws
- compute speedup relative to baseline mean cycles

### 2. Clause-sharing uplift

`Scaling.md` describes a three-layer model with a clause-sharing multiplier `beta(n)`.

In the current script:

- `beta` is present conceptually
- but it is effectively fixed to `1.0`

That means current projections are conservative with respect to any future clause-sharing benefit.

### 3. Communication overhead

`Scaling.md` describes topology-dependent overhead terms such as:

- all-to-all: `alpha * n^2`
- ring: `alpha * n`
- tree: `alpha * n log n`
- mesh: `alpha * sqrt(n)`

The current script implements these topology families and estimates `alpha` from measured multi-core points by comparing:

- observed speedup
- order-statistics-predicted speedup

The gap becomes the calibrated overhead term.

---

## Practical Modeling Advice

### Start with trustworthy baseline data

The model is only as good as the `1x1` baseline samples.

Before fitting:

- make sure correctness is solid in `Verification.md`
- keep only passing runs in the baseline
- collect enough `1x1` samples for the selected benchmark family

### Prefer families over one giant mixed pool

`Scaling.md` explicitly warns that runtime distributions differ a lot across benchmark families. Treating everything as one distribution can hide real behavior.

Good practice:

- fit `UF50` separately from `UUF50`
- fit generated instances separately from SATLIB families
- keep structured families separate when possible

### Use small scripts for exploration, big script for final numbers

Suggested cadence:

1. Use `stability_test_50v.sh` or `speedup_benchmark_50v.sh` to see if behavior is roughly sane.
2. Use `benchmark_suite.py` if you want quick variable-count summaries.
3. Use `run_aws_scaling_collection.sh` when you want results suitable for actual projection.

---

## Working From A Custom CSV

### Path C: FPGA hardware data

When your measurements come from F2 host runs via `satswarm_host`, use the two
helpers in `sim/scripts/`:

```bash
# Step 1 — convert one or more per-config host CSVs into raw_runs.csv
python3 sim/scripts/convert_fpga_csv.py \
  --input 1x1:logs/hw_1x1.csv \
  --input 2x2:logs/hw_2x2.csv \
  --clock-mhz 15.625 \
  --output logs/raw_runs.csv

# Step 2 — fit distributions and project scaling
python3 sim/scripts/refit_project.py \
  --input logs/raw_runs.csv \
  --output-dir logs/refit_out \
  --topology mesh \
  --min-baseline-samples 5
```

`refit_project.py` produces the same five output files as `collect_scaling_data.py`:
`aggregate_by_config.csv`, `fit_summary.json`, `scaling_projection.csv`, and `summary.txt`.

### Path D: refit from any existing raw_runs.csv

If you already have a `raw_runs.csv` (from either simulation or converted FPGA
data) and want to re-project with different parameters (topology, core counts,
seed), run `refit_project.py` directly without re-collecting:

```bash
python3 sim/scripts/refit_project.py \
  --input sim/logs/benchmark_results/scaling_20260318_163435/raw_runs.csv \
  --output-dir logs/refit_mesh512 \
  --projection-cores 1,2,4,8,16,32,64,128,256,512 \
  --topology mesh
```

### Manual normalization

If your CSV comes from a non-standard source, normalize it to the `raw_runs.csv`
schema by hand, then feed it to `refit_project.py`:

| Column | Type | Notes |
| ------ | ---- | ----- |
| `benchmark` | str | CNF file name |
| `run_idx` | int | Run index within config (use `1` if single-shot) |
| `config` | str | Grid config, e.g. `1x1`, `2x2` |
| `cores` | int | Total core count (N×M) |
| `expected` | str | `SAT` or `UNSAT` |
| `result` | str | Actual result; `TIMEOUT` for timed-out runs |
| `cycles` | int | Hardware cycle count |
| `wall_sec` | float | Wall-clock time in seconds |
| `timed_out` | int | `1` if the run timed out, else `0` |
| `command` | str | Command used (may be a description string) |

The `1x1` config rows serve as the baseline for distribution fitting; at least
`--min-baseline-samples` non-timed-out rows with `cycles > 0` are required.

---

## Confidence And Limits

The current modeling stack is strongest when:

- the measured configs are real and stable
- the `1x1` baseline has enough passing samples
- the benchmark family is reasonably homogeneous
- the topology assumption matches the actual sharing structure

It is weakest when:

- the CSV mixes unrelated benchmark families
- timeouts dominate the baseline
- only one or two multi-core points exist to estimate `alpha`
- hardware data is treated as identical to simulation without validation

For the deeper theoretical background, assumptions, and literature context, read `Scaling.md`.
