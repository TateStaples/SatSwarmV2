#!/bin/bash
# =============================================================================
# resume_and_continue.sh
#
# Resumes the 2x2_none build from its saved post_phys_opt.dcp checkpoint,
# packages the resulting DCP, submits the AFI, appends to the existing
# summary CSV, then relaunches run_grid_sharing_builds.sh for the remaining
# builds (3x3_none … 3x3_3clz) reusing the same run directory.
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# Constants matching the interrupted 2x2_none build
# ---------------------------------------------------------------------------
ROOT_DIR="/home/ubuntu/src/project_data/SatSwarmV2"
RESUME_TAG="2026_03_26-140059"
RESUME_RUN_DIR="$ROOT_DIR/deploy/logs/grid_sharing_20260326_130056"
SUMMARY_CSV="$RESUME_RUN_DIR/summary.csv"

AWS_REGION="${AWS_REGION:-us-east-1}"
AFI_S3_BUCKET="${AFI_S3_BUCKET:-satswarm-v2-afi-624824941978}"
AFI_S3_DCP_PREFIX="${AFI_S3_DCP_PREFIX:-dcp}"
AFI_S3_LOGS_PREFIX="${AFI_S3_LOGS_PREFIX:-logs}"

# ---------------------------------------------------------------------------
# Environment (mirrors setup_env in run_grid_sharing_builds.sh)
# ---------------------------------------------------------------------------
export AWS_FPGA_REPO_DIR="$ROOT_DIR/src/aws-fpga"
export HDK_DIR="$AWS_FPGA_REPO_DIR/hdk"
export HDK_COMMON_DIR="$HDK_DIR/common"
export HDK_SHELL_DIR="$HDK_COMMON_DIR/shell_stable"
export HDK_SHELL_DESIGN_DIR="$HDK_SHELL_DIR/design"
export HDK_IP_SRC_DIR="$HDK_COMMON_DIR/ip/cl_ip/cl_ip.srcs/sources_1/ip"
export HDK_BD_SRC_DIR="$HDK_COMMON_DIR/ip/cl_ip/cl_ip.srcs/sources_1/bd"
export HDK_BD_GEN_DIR="$HDK_COMMON_DIR/ip/cl_ip/cl_ip.gen/sources_1/bd"
export CL_DIR="$AWS_FPGA_REPO_DIR/hdk/cl/examples/cl_satswarm"
export FAAS_CL_DIR="$CL_DIR"
export VIVADO_TOOL_VERSION=2025.2
export XILINX_VIVADO=/opt/Xilinx/2025.2/Vivado
export PATH=/opt/Xilinx/2025.2/Vivado/bin:$PATH

# For resume_from_phys_opt.tcl
export BUILD_TAG="$RESUME_TAG"

CHECKPOINTS_DIR="$CL_DIR/build/checkpoints"
BUILD_SCRIPTS_DIR="$CL_DIR/build/scripts"
TCL_SCRIPT="$ROOT_DIR/deploy/resume_from_phys_opt.tcl"
VIVADO_LOG="$RESUME_RUN_DIR/resume_2x2_none_${RESUME_TAG}.vivado.log"
ROUTE_LOG="$RESUME_RUN_DIR/resume_2x2_none_route.log"

echo "============================================================"
echo " RESUME: 2x2_none from post_phys_opt.dcp"
echo " TAG:    $RESUME_TAG"
echo " RUN_DIR: $RESUME_RUN_DIR"
echo "============================================================"

# ---------------------------------------------------------------------------
# Sanity checks
# ---------------------------------------------------------------------------
PHYS_OPT_DCP="$CHECKPOINTS_DIR/cl_satswarm.${RESUME_TAG}.post_phys_opt.dcp"
if [[ ! -f "$PHYS_OPT_DCP" ]]; then
    echo "ERROR: post_phys_opt checkpoint not found: $PHYS_OPT_DCP"
    exit 1
fi
echo "Found checkpoint: $PHYS_OPT_DCP"

# ---------------------------------------------------------------------------
# Step 1: Run Vivado route_design from post_phys_opt checkpoint
# ---------------------------------------------------------------------------
START_TS="$(date +%Y-%m-%dT%H:%M:%S%z)"
echo "[$START_TS] Launching Vivado route resume..."

(
  cd "$BUILD_SCRIPTS_DIR"
  vivado -mode batch \
         -source "$TCL_SCRIPT" \
         -log "$VIVADO_LOG" \
         -nojournal
) > "$ROUTE_LOG" 2>&1 &
VIVADO_PID=$!
echo "Vivado PID: $VIVADO_PID  log: $ROUTE_LOG"

# Monitor while running
while kill -0 "$VIVADO_PID" 2>/dev/null; do
    sleep 120
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] route resume still running..."
    grep -E "^Phase|WNS|WHS|route_design|write_checkpoint|post_route|ERROR:|FATAL" \
         "$ROUTE_LOG" 2>/dev/null | tail -n 8 || true
done

if ! wait "$VIVADO_PID"; then
    echo "ERROR: Vivado route resume FAILED — see $ROUTE_LOG"
    exit 1
fi

END_TS="$(date +%Y-%m-%dT%H:%M:%S%z)"
echo "[$END_TS] Vivado route completed."

# Check the expected output checkpoint exists
POST_ROUTE_DCP="$CHECKPOINTS_DIR/cl_satswarm.${RESUME_TAG}.post_route.dcp"
POST_ROUTE_VIOLATED="$CHECKPOINTS_DIR/cl_satswarm.${RESUME_TAG}.post_route.VIOLATED.dcp"
if [[ ! -f "$POST_ROUTE_DCP" && ! -f "$POST_ROUTE_VIOLATED" ]]; then
    echo "ERROR: Neither post_route.dcp nor post_route.VIOLATED.dcp found after route."
    exit 1
fi

# ---------------------------------------------------------------------------
# Step 2: Package DCP into Developer_CL.tar via Python helper
# ---------------------------------------------------------------------------
echo "Packaging DCP tarball..."
(
  cd "$BUILD_SCRIPTS_DIR"
  python3 - <<'PYEOF'
import sys, os
sys.path.insert(0, os.getcwd())
import aws_build_dcp_from_cl as b
b.generate_dcp_tarball(
    'cl_satswarm',
    os.environ['BUILD_TAG'],
    'A2', 'B0', 'C0', 'H2'
)
PYEOF
)

LATEST_TAR="$CHECKPOINTS_DIR/${RESUME_TAG}.Developer_CL.tar"
if [[ ! -f "$LATEST_TAR" ]]; then
    echo "ERROR: Developer_CL.tar not found after packaging: $LATEST_TAR"
    exit 1
fi
echo "DCP tarball: $LATEST_TAR"

# ---------------------------------------------------------------------------
# Step 3: Upload to S3 and create AFI
# ---------------------------------------------------------------------------
RUN_LABEL="2x2_none"
RUN_STAMP="$(echo "$RESUME_TAG" | tr '_' '' | tr '-' '')"  # e.g. 20260326140059
AFI_NAME="SatSwarmV2-${RUN_LABEL}-maxlits8192-resume-${RESUME_TAG}"
TAR_NAME="$(basename "$LATEST_TAR")"
S3_KEY="${AFI_S3_DCP_PREFIX}/${TAR_NAME}"
AFI_JSON="$RESUME_RUN_DIR/afi_create_2x2_none_resume_${RESUME_TAG}.json"

AFI_STATUS="not_requested"
AFI_ID=""
AGFI_ID=""

echo "Uploading to s3://${AFI_S3_BUCKET}/${S3_KEY} ..."
if aws s3 cp "$LATEST_TAR" "s3://${AFI_S3_BUCKET}/${S3_KEY}"; then
    echo "S3 upload OK. Creating AFI..."
    if aws ec2 create-fpga-image \
        --region "$AWS_REGION" \
        --name "$AFI_NAME" \
        --description "SatSwarmV2 2x2_none MAX_LITS=8192 MAX_CLAUSES=2048 (route resume)" \
        --input-storage-location "Bucket=${AFI_S3_BUCKET},Key=${S3_KEY}" \
        --logs-storage-location "Bucket=${AFI_S3_BUCKET},Key=${AFI_S3_LOGS_PREFIX}/" \
        > "$AFI_JSON"; then
        AFI_ID="$(sed -n 's/.*"FpgaImageId"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$AFI_JSON" | head -n 1)"
        AGFI_ID="$(sed -n 's/.*"FpgaImageGlobalId"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$AFI_JSON" | head -n 1)"
        [[ -n "$AFI_ID" ]] && AFI_STATUS="submitted" || AFI_STATUS="submit_failed"
    else
        echo "WARNING: create-fpga-image failed"
        AFI_STATUS="submit_failed"
    fi
else
    echo "WARNING: S3 upload failed"
    AFI_STATUS="upload_failed"
fi

echo "AFI status: $AFI_STATUS  ID: $AFI_ID  AGFI: $AGFI_ID"

# ---------------------------------------------------------------------------
# Step 4: Append result to existing summary CSV
# ---------------------------------------------------------------------------
echo "2x2,2,2,none,0,2,8192,${START_TS},${END_TS},ok,${ROUTE_LOG},${LATEST_TAR},${AFI_STATUS},${AFI_ID},${AGFI_ID},${AFI_JSON}" >> "$SUMMARY_CSV"
echo "Summary CSV updated: $SUMMARY_CSV"

# ---------------------------------------------------------------------------
# Step 5: Relaunch run_grid_sharing_builds.sh for remaining builds,
#         reusing the existing RUN_DIR and SUMMARY_CSV.
# ---------------------------------------------------------------------------
echo ""
echo "============================================================"
echo " Launching remaining builds (3x3_none … 3x3_3clz)"
echo " RUN_DIR: $RESUME_RUN_DIR"
echo "============================================================"

export RUN_DIR="$RESUME_RUN_DIR"
export SUMMARY_CSV="$SUMMARY_CSV"
export SKIP_BACKUP=1

cd "$ROOT_DIR/deploy"
bash run_grid_sharing_builds.sh >> "$RESUME_RUN_DIR/runner_continued.log" 2>&1
echo "All remaining builds complete."
