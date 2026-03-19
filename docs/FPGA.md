# Using SatSwarm On An F2 Instance

This document assumes an AFI already exists and is `available`. It covers loading that AFI on an AWS F2 instance, building the host app, running a single DIMACS file on hardware, and collecting hardware-side CSVs. For synthesis and AFI creation, see `Synth.md`. For HDK reference material, see [HDK.md](HDK.md).

---

## Available AFIs


| AFI                     | agfi                     | Grid | Tag                 | Clock           | Notes                    |
| ----------------------- | ------------------------ | ---- | ------------------- | --------------- | ------------------------ |
| `afi-0520f5f8b8900def7` | `agfi-0b41689a08b4d4d5f` | 1×1  | `2026_03_19-051231` | A2 / 15.625 MHz | **Preferred** CL-owned MMCM, CLK_GRP_A_EN=0 |
| `afi-08366141b8a92b36f` | `agfi-0f933cb959906a494` | 1×1  | `2026_03_18-163435` | A2 / 15.625 MHz | CDC-fixed; gen_clk_extra_a1, may not lock on F2 |
| `afi-01ef63d452c8940a2` | `agfi-0193eda3eade22ae4` | 2×2  | `2026_03_18-171846` | A2 / 15.625 MHz | CDC-fixed; same MMCM caveat |

In these A2 builds, the shell runs at `clk_main_a0` (250 MHz) while the solver domain runs at `clk_solver` (15.625 MHz) from a CL-owned MMCME4_ADV. **Preferred 1×1**: use `agfi-0b41689a08b4d4d5f`; poll `aws ec2 describe-fpga-images --fpga-image-ids afi-0520f5f8b8900def7` until `State` is `available`. Older AFIs use `gen_clk_extra_a1` and may have MMCM lock issues on real F2.

> Historical note: `afi-064b74577e3b2f258` (fabric divider) failed REQP-123 during AWS bitgen. Do not use. AFIs created from tars before the REQP-123 fix should also not be used.

---

## Load The AFI On F2

On the F2 instance:

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga
source sdk_setup.sh

sudo fpga-clear-local-image -S 0

# 1×1 AFI (preferred: CL-owned MMCM build, once available)
sudo fpga-load-local-image -S 0 -l agfi-0b41689a08b4d4d5f

# Fallback: older 1×1 (gen_clk_extra_a1; may not lock on F2)
# sudo fpga-load-local-image -S 0 -l agfi-0f933cb959906a494

# Optional: 2×2 AFI
# sudo fpga-load-local-image -S 0 -l agfi-0193eda3eade22ae4

sudo fpga-describe-local-image -S 0 -H
```

Confirm `StatusName: loaded` before doing anything else.

---

## Build The Host App

The host executable is:

`hdk_cl_satswarm/host/satswarm_host`

It:

- checks the AFI status on the selected slot
- waits for the version register to come out of reset
- parses a DIMACS CNF
- uploads literals via DMA or MMIO
- starts the solver
- polls for done
- prints `Result:` and `Cycles:`

### Build

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga
source sdk_setup.sh

cd /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host
make
```

If the AWS SDK is visible, this builds `./satswarm_host`.

---

## Run A Single CNF On Hardware

Example:

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host

./satswarm_host \
  /home/ubuntu/src/project_data/SatSwarmV2/sim/tests/generated_instances/sat_20v_80c_1.cnf \
  --slot 0 \
  --timeout 10 \
  --debug 0
```

Expected output format includes:

- `Result:    SAT` or `UNSAT`
- `Cycles:    <count>`
- `Status:    0x...`

Use this first before trying any batch collection. It proves:

- the AFI is really loaded
- the core came out of reset
- host-to-FPGA literal loading works
- status and cycle reads work

---

## Collect A Small Hardware CSV

The repository does **not** yet contain a dedicated checked-in F2 batch-collector script. The host app is sufficient to collect real hardware CSVs today with shell loops.

### Example: generated instances -> CSV

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2

HOST=/home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host
OUT=/home/ubuntu/src/project_data/SatSwarmV2/logs/f2_generated_$(date +%Y%m%d_%H%M%S).csv

mkdir -p logs
echo "benchmark,expected,result,cycles,slot,timeout_sec" > "$OUT"

for cnf in sim/tests/generated_instances/*.cnf; do
  name=$(basename "$cnf")
  if [[ "$name" == *unsat* ]]; then
    expected=UNSAT
  else
    expected=SAT
  fi

  output=$("$HOST" "$PWD/$cnf" --slot 0 --timeout 15 2>&1 || true)
  result=$(printf "%s\n" "$output" | sed -n 's/^Result:[[:space:]]*//p' | head -1)
  cycles=$(printf "%s\n" "$output" | sed -n 's/^Cycles:[[:space:]]*//p' | head -1)

  [ -z "$result" ] && result=ERROR
  [ -z "$cycles" ] && cycles=0

  echo "$name,$expected,$result,$cycles,0,15" >> "$OUT"
done

echo "Wrote $OUT"
```

### Example: SATLIB subset -> CSV

```bash
cd /home/ubuntu/src/project_data/SatSwarmV2

HOST=/home/ubuntu/src/project_data/SatSwarmV2/hdk_cl_satswarm/host/satswarm_host
OUT=/home/ubuntu/src/project_data/SatSwarmV2/logs/f2_satlib_uf50_$(date +%Y%m%d_%H%M%S).csv

mkdir -p logs
echo "benchmark,expected,result,cycles,slot,timeout_sec" > "$OUT"

for cnf in sim/tests/satlib/sat/uf50*.cnf sim/tests/satlib/unsat/uuf50*.cnf; do
  [ -f "$cnf" ] || continue
  name=$(basename "$cnf")

  if [[ "$name" == uuf* ]]; then
    expected=UNSAT
  else
    expected=SAT
  fi

  output=$("$HOST" "$PWD/$cnf" --slot 0 --timeout 30 2>&1 || true)
  result=$(printf "%s\n" "$output" | sed -n 's/^Result:[[:space:]]*//p' | head -1)
  cycles=$(printf "%s\n" "$output" | sed -n 's/^Cycles:[[:space:]]*//p' | head -1)

  [ -z "$result" ] && result=ERROR
  [ -z "$cycles" ] && cycles=0

  echo "$name,$expected,$result,$cycles,0,30" >> "$OUT"
done

echo "Wrote $OUT"
```

These CSVs are enough for spot analysis and later ingestion into the modeling workflow in `Model.md`.

---

## Practical Collection Advice

### Start with the single-file run

Always validate one CNF by hand before launching a batch. This catches:

- wrong slot selection
- stale or unloaded AFI
- reset / version-register issues
- broken host build

### Prefer small suites first

For early hardware validation, start with:

- a handful of `generated_instances`
- a few `uf50` / `uuf50` files

Do not begin with a giant sweep until the host run is stable.

### Keep the CSV schema simple

At minimum, keep:

- `benchmark`
- `expected`
- `result`
- `cycles`
- `slot`
- `timeout_sec`

If you later want to feed those results into the same projection machinery used by the simulation pipeline, you will eventually want a converter into the `raw_runs.csv` schema described in `Model.md`.

---

## Troubleshooting

**Host hangs or no response:** The shell enforces an 8 µs timeout on OCL and DMA transactions. If the CL does not respond in time, the interface may stop working. Run `fpga-describe-local-image -S 0 --metrics` and check `ocl-slave-timeout`, `dma-pcis-timeout`, and the offending address. After a timeout, reload the AFI. See [How_To_Detect_Shell_Timeout.md](../src/aws-fpga/hdk/docs/How_To_Detect_Shell_Timeout.md).

---

## Checked-In FPGA Scripts

All four previously-missing wrappers are now in `hdk_cl_satswarm/scripts/`:

| Script | Purpose |
| ------ | ------- |
| `run_fpga_single.sh` | Wrapper around `satswarm_host` for a single CNF file |
| `run_fpga_suite.sh` | Runs a CNF directory and emits a CSV |
| `run_fpga_scaling_collection.sh` | Multi-AFI scaling collector (mirrors `sim/scripts/run_aws_scaling_collection.sh`) |

Two modeling helpers live in `sim/scripts/`:

| Script | Purpose |
| ------ | ------- |
| `convert_fpga_csv.py` | Converts host-side CSVs into the `raw_runs.csv` schema |
| `refit_project.py` | Fits distributions and projects scaling from an existing `raw_runs.csv` |

### Quick Start

```bash
# 1. Validate a single CNF first
bash hdk_cl_satswarm/scripts/run_fpga_single.sh \
  sim/tests/generated_instances/sat_20v_80c_1.cnf --slot 0 --timeout 15

# 2. Run a full suite and get a CSV
bash hdk_cl_satswarm/scripts/run_fpga_suite.sh \
  --suite-dir sim/tests/generated_instances \
  --out logs/hw_generated.csv \
  --slot 0 --timeout 30

# 3. Full scaling collection across two AFIs (requires sudo for fpga-load-local-image)
source src/aws-fpga/sdk_setup.sh
bash hdk_cl_satswarm/scripts/run_fpga_scaling_collection.sh \
  --afis "1x1:agfi-0f933cb959906a494,2x2:agfi-0193eda3eade22ae4" \
  --suite-dir sim/tests/generated_instances \
  --timeout-sec 30

# 4. Convert a manually-collected CSV into raw_runs.csv and then refit
python3 sim/scripts/convert_fpga_csv.py \
  --input 1x1:logs/hw_1x1.csv \
  --input 2x2:logs/hw_2x2.csv \
  --clock-mhz 15.625 \
  --output logs/raw_runs.csv

python3 sim/scripts/refit_project.py \
  --input logs/raw_runs.csv \
  --output-dir logs/refit_out
```

For the theory behind the fitting and projection outputs, see `Model.md`.