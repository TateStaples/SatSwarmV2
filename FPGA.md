# FPGA Deployment Instructions

This document outlines the final steps to deploy SatSwarm V2 to an AWS F2 instance.

---

## 1. Bitstream Artifacts

All artifacts are under:
`/home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/hdk/cl/examples/cl_satswarm/build/checkpoints/`

> **Important**: All builds prior to commit `fd6a0a3` (REQP-123 fix) will fail AWS bitgen with `UNKNOWN_BITSTREAM_GENERATE_ERROR`. Do not submit those tars.

### Build History

| Tag | Grid | Clock | WNS | Tar on disk | S3 | Submit? |
|---|---|---|---|---|---|---|
| `2026_03_18-004125` | 1×1 | A2 / 15.625 MHz | +0.711 ns | ✅ | ✅ | ❌ Pre-REQP-123-fix |
| `2026_03_18-020509` | 2×2 | A2 / 15.625 MHz | +0.711 ns | ✅ | ✅ | ❌ Pre-REQP-123-fix |
| `2026_03_18-120815` | 1×1 | A1 / 150 MHz | -18.135 ns | ✅ | ❌ | ❌ Timing failure |
| _(in progress)_ | 1×1 | A1 / 150 MHz | — | — | — | ⏳ Awaiting result |

The in-progress build applies both fixes (REQP-123 + `vde_heap` pipeline). Once complete, check WNS ≥ 0 before uploading and submitting.

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
    --name "SatSwarmV2-1x1-150MHz" \
    --description "SatSwarm V2 CDCL solver, 1x1 grid, 150 MHz (A1), REQP-123+timing fixed" \
    --input-storage-location Bucket=satswarm-v2-afi-624824941978,Key=dcp/${TAG}.Developer_CL.tar \
    --logs-storage-location Bucket=satswarm-v2-afi-624824941978,Key=logs/
```

Each command returns `FpgaImageId` (`afi-*`, for polling) and `FpgaImageGlobalId` (`agfi-*`, for loading). **Save both.**

### Step 2c: Poll for Availability (30–60 min)

```bash
aws ec2 describe-fpga-images \
  --fpga-image-ids <afi-1x1> <afi-2x2> \
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

# Load the AFI (use the agfi-* GlobalId)
sudo fpga-load-local-image -S 0 -l agfi-xxxxxxxxxxxxxxxxxxxx

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

> All AFIs above were built from tars that predate the REQP-123 fix and will fail bitgen. The next valid AFI will be from the current in-progress build.
