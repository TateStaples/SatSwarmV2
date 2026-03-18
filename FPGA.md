# FPGA Deployment Instructions

This document outlines the final steps to deploy SatSwarm V2 to an AWS F2 instance.

---

## 1. Bitstream Artifacts

All artifacts are under:
`/home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/hdk/cl/examples/cl_satswarm/build/checkpoints/`

### 1×1 Build (tag `2026_03_18-004125`)

- **Tarball**: `2026_03_18-004125.Developer_CL.tar`
- **Post-Route DCP**: `cl_satswarm.2026_03_18-004125.post_route.dcp`
- **S3**: `s3://satswarm-v2-afi-624824941978/dcp/2026_03_18-004125.Developer_CL.tar` ✅ uploaded
- **AFI status**: `afi-0edbf121d0cabe2b3` — **FAILED** (transient `UNKNOWN_BITSTREAM_GENERATE_ERROR`; resubmit using tar already on S3)

### 2×2 Build (tag `2026_03_18-020509`)

- **Tarball**: `2026_03_18-020509.Developer_CL.tar`
- **Post-Route DCP**: `cl_satswarm.2026_03_18-020509.post_route.dcp`
- **S3**: not yet uploaded
- **AFI status**: not yet submitted

### Timing Results

| Metric | 1×1 (`2026_03_18-004125`) | 2×2 (`2026_03_18-020509`) |
|---|---|---|
| WNS | +0.711 ns | +0.711 ns |
| TNS | 0.000 ns | 0.000 ns |
| WHS | +0.014 ns | +0.011 ns |
| Build time | ~31 min | ~62 min |
| Status | Timing MET | Timing MET |

---

## 2. Amazon FPGA Image (AFI) Creation Workflow

### Step 2a: Upload Tarball to S3

```bash
# For 2x2 (1x1 is already uploaded):
aws s3 cp \
  /home/ubuntu/src/project_data/SatSwarmV2/src/aws-fpga/hdk/cl/examples/cl_satswarm/build/checkpoints/2026_03_18-020509.Developer_CL.tar \
  s3://satswarm-v2-afi-624824941978/dcp/2026_03_18-020509.Developer_CL.tar
```

### Step 2b: Request AFI Creation

**1×1 (retry — tar already on S3):**
```bash
aws ec2 create-fpga-image \
    --region us-east-1 \
    --name "SatSwarmV2-1x1" \
    --description "SatSwarm V2 CDCL solver, 1x1 grid, 15.625 MHz clock" \
    --input-storage-location Bucket=satswarm-v2-afi-624824941978,Key=dcp/2026_03_18-004125.Developer_CL.tar \
    --logs-storage-location Bucket=satswarm-v2-afi-624824941978,Key=logs/
```

**2×2 (new submission):**
```bash
aws ec2 create-fpga-image \
    --region us-east-1 \
    --name "SatSwarmV2-2x2" \
    --description "SatSwarm V2 CDCL solver, 2x2 grid (4 cores), 15.625 MHz clock" \
    --input-storage-location Bucket=satswarm-v2-afi-624824941978,Key=dcp/2026_03_18-020509.Developer_CL.tar \
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

| AFI ID | Grid | Tag | Status | Notes |
|---|---|---|---|---|
| `afi-0edbf121d0cabe2b3` | 1×1 | `2026_03_18-004125` | FAILED | Transient `UNKNOWN_BITSTREAM_GENERATE_ERROR` |
| `afi-033c546a9698c9134` | 1×1 | `2026_03_18-004125` | pending | Retry; GlobalId: `agfi-0fc60c975e389b731` |
| `afi-0a3e524ae986734e5` | 2×2 | `2026_03_18-020509` | pending | New; GlobalId: `agfi-031f551cf7bed2bdd` |
