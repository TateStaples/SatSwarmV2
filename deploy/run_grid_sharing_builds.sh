#!/bin/bash
# =============================================================================
# Sequential BuildAll runner for SatSwarm grid/sharing sweep.
#
# Requested default matrix:
#   1x1: none (skip for next run; already completed)
#   2x2: none, 2clz, 3clz
#   3x3: none, 2clz, 3clz (with MAX_LITS=8192)
#
# All runs use speed-focused directives: -p Default -o Default -r Default
# Includes manual monitoring loop (sleep + grep) while each build is running.
# =============================================================================
set -euo pipefail

ROOT_DIR="/home/ubuntu/src/project_data/SatSwarmV2"
RUN_TS="$(date +%Y%m%d_%H%M%S)"
RUN_DIR="$ROOT_DIR/deploy/logs/grid_sharing_$RUN_TS"
BACKUP_DIR="$RUN_DIR/backups"
SUMMARY_CSV="$RUN_DIR/summary.csv"

TOP_FILE="$ROOT_DIR/src/Mega/satswarm_top.sv"
CL_TOP_FILE="$ROOT_DIR/src/aws-fpga/hdk/cl/examples/cl_satswarm/design/cl_satswarm.sv"
BRIDGE_FILE="$ROOT_DIR/src/aws-fpga/hdk/cl/examples/cl_satswarm/design/satswarm_core_bridge.sv"
PKG_FILE="$ROOT_DIR/src/Mega/satswarmv2_pkg.sv"
MESH_FILE="$ROOT_DIR/src/Mega/mesh_interconnect.sv"

TARGET_MAX_LITS="${TARGET_MAX_LITS:-16384}"
POLL_INTERVAL_SEC="${POLL_INTERVAL_SEC:-120}"
AUTO_CREATE_AFI="${AUTO_CREATE_AFI:-1}"
AWS_REGION="${AWS_REGION:-us-east-1}"
AFI_S3_BUCKET="${AFI_S3_BUCKET:-satswarm-v2-afi-624824941978}"
AFI_S3_DCP_PREFIX="${AFI_S3_DCP_PREFIX:-dcp}"
AFI_S3_LOGS_PREFIX="${AFI_S3_LOGS_PREFIX:-logs}"

mkdir -p "$RUN_DIR" "$BACKUP_DIR"

for f in "$TOP_FILE" "$CL_TOP_FILE" "$BRIDGE_FILE" "$PKG_FILE" "$MESH_FILE"; do
  if [[ ! -f "$f" ]]; then
    echo "ERROR: missing required file: $f"
    exit 1
  fi
  cp "$f" "$BACKUP_DIR/$(basename "$f")"
done

restore_originals() {
  cp "$BACKUP_DIR/$(basename "$TOP_FILE")" "$TOP_FILE"
  cp "$BACKUP_DIR/$(basename "$CL_TOP_FILE")" "$CL_TOP_FILE"
  cp "$BACKUP_DIR/$(basename "$BRIDGE_FILE")" "$BRIDGE_FILE"
  cp "$BACKUP_DIR/$(basename "$PKG_FILE")" "$PKG_FILE"
  cp "$BACKUP_DIR/$(basename "$MESH_FILE")" "$MESH_FILE"
}
trap restore_originals EXIT

setup_env() {
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
}

set_grid_params() {
  local gx="$1"
  local gy="$2"

  sed -i -E "s/(parameter int GRID_X[[:space:]]*=[[:space:]]*)[0-9]+/\\1${gx}/" "$CL_TOP_FILE"
  sed -i -E "s/(parameter int GRID_Y[[:space:]]*=[[:space:]]*)[0-9]+/\\1${gy}/" "$CL_TOP_FILE"

  sed -i -E "s/(parameter int GRID_X[[:space:]]*=[[:space:]]*)[0-9]+/\\1${gx}/" "$BRIDGE_FILE"
  sed -i -E "s/(parameter int GRID_Y[[:space:]]*=[[:space:]]*)[0-9]+/\\1${gy}/" "$BRIDGE_FILE"

  sed -i -E "s/(parameter int GRID_X[[:space:]]*=[[:space:]]*)[0-9]+/\\1${gx}/" "$TOP_FILE"
  sed -i -E "s/(parameter int GRID_Y[[:space:]]*=[[:space:]]*)[0-9]+/\\1${gy}/" "$TOP_FILE"

  sed -i -E "s/(parameter int GRID_X[[:space:]]*=[[:space:]]*)[0-9]+/\\1${gx}/" "$PKG_FILE"
  sed -i -E "s/(parameter int GRID_Y[[:space:]]*=[[:space:]]*)[0-9]+/\\1${gy}/" "$PKG_FILE"

  sed -i -E "s/(parameter int GRID_X[[:space:]]*=[[:space:]]*)[0-9]+/\\1${gx}/" "$MESH_FILE"
  sed -i -E "s/(parameter int GRID_Y[[:space:]]*=[[:space:]]*)[0-9]+/\\1${gy}/" "$MESH_FILE"
}

set_max_lits() {
  local max_lits="$1"

  sed -i -E "s/(parameter int MAX_LITS[[:space:]]*=[[:space:]]*)[0-9]+/\\1${max_lits}/" "$CL_TOP_FILE"
  sed -i -E "s/(parameter int MAX_LITS[[:space:]]*=[[:space:]]*)[0-9]+/\\1${max_lits}/" "$BRIDGE_FILE"
  sed -i -E "s/(parameter int MAX_LITS[[:space:]]*=[[:space:]]*)[0-9]+/\\1${max_lits}/" "$TOP_FILE"
}

set_max_clauses_per_core() {
  local max_clauses="$1"

  sed -i -E "s/(parameter int MAX_CLAUSES_PER_CORE[[:space:]]*=[[:space:]]*)[0-9]+/\\1${max_clauses}/" "$CL_TOP_FILE"
  sed -i -E "s/(parameter int MAX_CLAUSES_PER_CORE[[:space:]]*=[[:space:]]*)[0-9]+/\\1${max_clauses}/" "$BRIDGE_FILE"
  sed -i -E "s/(parameter int MAX_CLAUSES_PER_CORE[[:space:]]*=[[:space:]]*)[0-9]+/\\1${max_clauses}/" "$TOP_FILE"
}

set_sharing_params() {
  local mode="$1"
  local max_len="$2"

  sed -i -E "s/(parameter int CLAUSE_SHARING_MODE[[:space:]]*=[[:space:]]*)[-0-9]+/\\1${mode}/" "$TOP_FILE"
  sed -i -E "s/(parameter int SHARE_MAX_LEN[[:space:]]*=[[:space:]]*)[-0-9]+/\\1${max_len}/" "$TOP_FILE"
}

print_current_knobs() {
  echo "--- Current parameter snapshot ---"
  grep -nE "parameter int GRID_X|parameter int GRID_Y|parameter int MAX_LITS|parameter int MAX_CLAUSES_PER_CORE" "$CL_TOP_FILE" | sed 's/^/cl_satswarm: /'
  grep -nE "parameter int GRID_X|parameter int GRID_Y|parameter int MAX_LITS|parameter int MAX_CLAUSES_PER_CORE" "$BRIDGE_FILE" | sed 's/^/bridge: /'
  grep -nE "parameter int GRID_X|parameter int GRID_Y|parameter int MAX_LITS|parameter int MAX_CLAUSES_PER_CORE|CLAUSE_SHARING_MODE|SHARE_MAX_LEN" "$TOP_FILE" | sed 's/^/satswarm_top: /'
  grep -nE "parameter int GRID_X|parameter int GRID_Y" "$PKG_FILE" | sed 's/^/pkg: /'
  grep -nE "parameter int GRID_X|parameter int GRID_Y" "$MESH_FILE" | sed 's/^/mesh: /'
}

monitor_build_log() {
  local pid="$1"
  local log_file="$2"
  local label="$3"

  while kill -0 "$pid" 2>/dev/null; do
    sleep "$POLL_INTERVAL_SEC"
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] [$label] still running..."
    grep -E "Running CL builds|Build starts|synth_design|place_design|route_design|Timing|WNS|ERROR:|CRITICAL WARNING|write_bitstream|checkpoint" "$log_file" | tail -n 12 || true
  done
}

submit_afi_for_tar() {
  local tar_path="$1"
  local run_label="$2"
  local run_stamp="$3"
  local run_max_lits="$4"
  local afi_json_out="$5"

  local tar_name
  local s3_key
  local afi_name

  tar_name="$(basename "$tar_path")"
  s3_key="${AFI_S3_DCP_PREFIX}/${tar_name}"
  afi_name="SatSwarmV2-${run_label}-maxlits${run_max_lits}-${run_stamp}"

  if ! aws s3 cp "$tar_path" "s3://${AFI_S3_BUCKET}/${s3_key}"; then
    echo "ERROR: failed S3 upload for $run_label"
    return 1
  fi

  if ! aws ec2 create-fpga-image \
      --region "$AWS_REGION" \
      --name "$afi_name" \
      --description "SatSwarmV2 ${run_label} MAX_LITS=${run_max_lits}" \
      --input-storage-location "Bucket=${AFI_S3_BUCKET},Key=${s3_key}" \
      --logs-storage-location "Bucket=${AFI_S3_BUCKET},Key=${AFI_S3_LOGS_PREFIX}/" \
      > "$afi_json_out"; then
    echo "ERROR: failed AFI create-fpga-image for $run_label"
    return 1
  fi

  return 0
}

run_entry() {
  local grid_label="$1"
  local gx="$2"
  local gy="$3"
  local mode_name="$4"
  local mode_value="$5"
  local len_value="$6"
  local run_max_lits="$7"

  local run_label="${grid_label}_${mode_name}"
  local start_ts="$(date +%Y-%m-%dT%H:%M:%S%z)"
  local run_stamp="$(date +%Y%m%d_%H%M%S)"
  local log_file="$RUN_DIR/build_${run_label}_${run_stamp}.log"
  local latest_tar=""
  local afi_id=""
  local agfi_id=""
  local afi_status="not_requested"
  local afi_json="$RUN_DIR/afi_create_${run_label}_${run_stamp}.json"
  local status="ok"

  echo ""
  echo "=== [$run_label] apply params ==="
  set_grid_params "$gx" "$gy"
  set_max_lits "$run_max_lits"
  set_sharing_params "$mode_value" "$len_value"
  print_current_knobs

  echo "=== [$run_label] launch BuildAll (speed-focused directives) ==="
  (
    cd "$BUILD_DIR"
    python3 aws_build_dcp_from_cl.py \
      --cl cl_satswarm \
      --aws_clk_gen \
      --clock_recipe_a A2 \
      --clock_recipe_b B0 \
      --clock_recipe_c C0 \
      -p Default \
      -o Default \
      -r Default
  ) > "$log_file" 2>&1 &

  local build_pid=$!
  echo "[$run_label] pid=$build_pid log=$log_file"
  monitor_build_log "$build_pid" "$log_file" "$run_label"

  if ! wait "$build_pid"; then
    status="failed"
  fi

  local end_ts="$(date +%Y-%m-%dT%H:%M:%S%z)"
  latest_tar="$(ls -1t "$CL_DIR"/build/checkpoints/*.Developer_CL.tar 2>/dev/null | head -n 1 || true)"

  if [[ "$status" == "ok" && "$AUTO_CREATE_AFI" == "1" && -n "$latest_tar" ]]; then
    afi_status="submit_failed"
    if submit_afi_for_tar "$latest_tar" "$run_label" "$run_stamp" "$run_max_lits" "$afi_json"; then
      afi_id="$(sed -n 's/.*"FpgaImageId"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$afi_json" | head -n 1)"
      agfi_id="$(sed -n 's/.*"FpgaImageGlobalId"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$afi_json" | head -n 1)"
      if [[ -n "$afi_id" ]]; then
        afi_status="submitted"
      fi
    fi
  fi

  echo "${grid_label},${gx},${gy},${mode_name},${mode_value},${len_value},${run_max_lits},${start_ts},${end_ts},${status},${log_file},${latest_tar},${afi_status},${afi_id},${agfi_id},${afi_json}" >> "$SUMMARY_CSV"

  echo "=== [$run_label] ${status} ==="
  echo "log: $log_file"
  if [[ -n "$latest_tar" ]]; then
    echo "latest tar: $latest_tar"
  fi
  if [[ "$afi_status" == "submitted" ]]; then
    echo "afi submitted: $afi_id ($agfi_id)"
    echo "afi json: $afi_json"
  fi

  if [[ "$status" != "ok" ]]; then
    echo "[$run_label] last error lines:"
    grep -E "ERROR:|CRITICAL WARNING|failed|FATAL" "$log_file" | tail -n 20 || true
    return 1
  fi

  return 0
}

setup_env
BUILD_DIR="$CL_DIR/build/scripts"
if [[ ! -d "$BUILD_DIR" ]]; then
  echo "ERROR: missing build directory: $BUILD_DIR"
  exit 1
fi
if [[ ! -f "$BUILD_DIR/aws_build_dcp_from_cl.py" ]]; then
  echo "ERROR: missing aws_build_dcp_from_cl.py in $BUILD_DIR"
  exit 1
fi

echo "grid_label,grid_x,grid_y,mode_name,clause_sharing_mode,share_max_len,max_lits,start_time,end_time,status,log_file,latest_tar,afi_status,afi_id,agfi_id,afi_json" > "$SUMMARY_CSV"

set_max_clauses_per_core 2048

overall_status=0

# All runs use MAX_LITS=8192.
run_entry "1x1" 1 1 "none" 0 2 8192 || overall_status=1

run_entry "2x2" 2 2 "none" 0 2 8192 || overall_status=1
run_entry "3x3" 3 3 "none" 0 2 8192 || overall_status=1

run_entry "2x2" 2 2 "2clz" 1 2 8192 || overall_status=1
run_entry "3x3" 3 3 "2clz" 1 2 8192 || overall_status=1

run_entry "2x2" 2 2 "3clz" 2 3 8192 || overall_status=1
run_entry "3x3" 3 3 "3clz" 2 3 8192 || overall_status=1

echo ""
if [[ "$overall_status" -eq 0 ]]; then
  echo "All requested runs completed successfully."
else
  echo "One or more runs failed."
fi

echo "Summary CSV: $SUMMARY_CSV"
exit "$overall_status"
