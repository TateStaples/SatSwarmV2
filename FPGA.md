# FPGA Deployment Instructions 🚀

This document outlines the final steps to deploy the SatSwarm V2 generated bitstream to an AWS F2 instance.

## 1. Bitstream Artifacts

The final, fully routed design checkpoint (DCP) and the packaged AWS tarball are located here:

- **Tarball (for AWS ingestion):** `/home/ubuntu/src/project_data/aws-fpga/hdk/cl/examples/cl_satswarm/build/checkpoints/2026_03_05-145659.Developer_CL.tar`
- **Post-Route DCP:** `/home/ubuntu/src/project_data/aws-fpga/hdk/cl/examples/cl_satswarm/build/checkpoints/cl_satswarm.2026_03_05-145659.post_route.dcp`

### Implementation Metrics
The 2026_03_05 BuildAll (Attempt 3: ImplCL only) completed successfully with the following critical metrics:
- **Completion Time**: ~3 hours 10 mins (18:44 UTC)
- **Worst Negative Slack (WNS)**: `+0.711 ns` (Timing MET for 15.625 MHz clock)
- **Total Negative Slack (TNS)**: `0.000 ns`
- **Worst Hold Slack (WHS)**: `+0.011 ns`

---

## 2. Amazon FPGA Image (AFI) Creation Workflow

To load this design onto an F2 instance, you must ask AWS to ingest the `.Developer_CL.tar` file and generate an Amazon FPGA Image (AFI).

### Step 2a: Upload the Tarball to S3
AWS requires the bitstream to be in an S3 bucket you own inside the same region (e.g., `us-east-1`).

```bash
# Set your bucket name (must be globally unique)
export MY_S3_BUCKET="your-satswarm-bucket-name"

# Create the bucket and a logs folder if you haven't already
aws s3 mb s3://$MY_S3_BUCKET
aws s3 mb s3://$MY_S3_BUCKET/logs

# Copy the tarball to S3
aws s3 cp /home/ubuntu/src/project_data/aws-fpga/hdk/cl/examples/cl_satswarm/build/checkpoints/2026_03_05-145659.Developer_CL.tar s3://$MY_S3_BUCKET/dcp/
```

### Step 2b: Request the AFI Creation
Tell the AWS EC2 systems to ingest the tarball and generate the AFI:

```bash
aws ec2 create-fpga-image \
    --region us-east-1 \
    --name "SatSwarmV2" \
    --description "SatSwarm V2 CDCL solver, 1x1 grid, 15.625 MHz clock" \
    --input-storage-location Bucket=$MY_S3_BUCKET,Key=dcp/2026_03_05-145659.Developer_CL.tar \
    --logs-storage-location Bucket=$MY_S3_BUCKET,Key=logs
```
*This command will output a JSON payload containing an `FpgaImageGlobalId` (`agfi-xxxx...`). **Save this ID, as this is what you will use to load the FPGA.*** Note: The output also includes an `FpgaImageId` (`fi-xxxx...`) which is used for checking status.

### Step 2c: Wait for AWS Ingestion (30-60 mins)
AWS runs background DRC checks on the bitstream. You can poll its status using the `fi-xxxx...` ID:

```bash
aws ec2 describe-fpga-images --fpga-image-ids fi-your-id-here --query 'FpgaImages[0].State'
```
Wait until the command outputs `{"Code": "available"}`.

---

## 3. Load onto the F2 Instance

Once the AFI is `available`, connect to your F2 instance and flash the FPGA slot:

```bash
# Source the AWS SDK (not HDK)
cd /home/ubuntu/src/project_data/aws-fpga
source sdk_setup.sh

# Clear the current slot 0 image
sudo fpga-clear-local-image -S 0

# Load the new AFI (use the agfi-xxxx ID)
sudo fpga-load-local-image -S 0 -l agfi-your-id-here

# Verify it was loaded successfully
sudo fpga-describe-local-image -S 0 -H
```

You are now ready to run your host-application software against the solver!
