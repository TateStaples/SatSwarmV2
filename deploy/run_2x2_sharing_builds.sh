#!/bin/bash
# =============================================================================
# Run four 2x2 BuildAll runs across clause-sharing levels:
#   none  -> mode=0, len=2
#   2clz  -> mode=1, len=2
#   3clz  -> mode=2, len=3
#   4clz  -> mode=2, len=4
#
# This script intentionally sets HDK/Vivado env vars explicitly instead of
# sourcing hdk_setup.sh, matching docs/Synth.md guidance for this workspace.
# =============================================================================
set -euo pipefail

ROOT_DIR="/home/ubuntu/src/project_data/SatSwarmV2"
TOP_FILE="$ROOT_DIR/src/Mega/satswarm_top.sv"
BACKUP_FILE="$ROOT_DIR/deploy/logs/satswarm_top.sv.backup_sharing_builds"
RUN_TS="$(date +%Y%m%d_%H%M%S)"
RUN_DIR="$ROOT_DIR/deploy/logs/sharing_2x2_$RUN_TS"
SUMMARY_CSV="$RUN_DIR/summary.csv"

mkdir -p "$RUN_DIR"
mkdir -p "$(dirname "$BACKUP_FILE")"

if [[ ! -f "$TOP_FILE" ]]; then
  echo "ERROR: missing file: $TOP_FILE"
  exit 1
fi

cp "$TOP_FILE" "$BACKUP_FILE"
restore_original() {
  if [[ -f "$BACKUP_FILE" ]]; then
    cp "$BACKUP_FILE" "$TOP_FILE"
  fi
}
trap restore_original EXIT

# Manual HDK/Vivado environment setup (docs/Synth.md)
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

BUILD_DIR="$CL_DIR/build/scripts"
if [[ ! -d "$BUILD_DIR" ]]; then
  echo "ERROR: missing build directory: $BUILD_DIR"
  exit 1
fi

if [[ ! -f "$BUILD_DIR/aws_build_dcp_from_cl.py" ]]; then
  echo "ERROR: missing aws_build_dcp_from_cl.py in $BUILD_DIR"
  exit 1
fi

echo "mode_name,clause_sharing_mode,share_max_len,start_time,end_time,status,log_file,latest_tar" > "$SUMMARY_CSV"

OVERALL_STATUS=0

run_mode() {
  local mode_name="$1"
  local mode_value="$2"
  local len_value="$3"

  local start_ts
  local end_ts
  local run_stamp
  local mode_log
  local latest_tar
  local status

  start_ts="$(date +%Y-%m-%dT%H:%M:%S%z)"
  run_stamp="$(date +%Y%m%d_%H%M%S)"
  mode_log="$RUN_DIR/build_${mode_name}_${run_stamp}.log"

  echo "=== [$mode_name] setting CLAUSE_SHARING_MODE=$mode_value SHARE_MAX_LEN=$len_value ==="

  sed -i -E "s/(parameter int CLAUSE_SHARING_MODE = )[-0-9]+/\\1${mode_value}/" "$TOP_FILE"
  sed -i -E "s/(parameter int SHARE_MAX_LEN = )[-0-9]+/\\1${len_value}/" "$TOP_FILE"

  grep -nE "CLAUSE_SHARING_MODE|SHARE_MAX_LEN" "$TOP_FILE"

  echo "=== [$mode_name] build start ==="
  status="ok"
  latest_tar=""

  if ! (
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
  ) > "$mode_log" 2>&1; then
    status="failed"
  fi

  end_ts="$(date +%Y-%m-%dT%H:%M:%S%z)"

  latest_tar="$(ls -1t "$CL_DIR"/build/checkpoints/*.Developer_CL.tar 2>/dev/null | head -n 1 || true)"

  echo "${mode_name},${mode_value},${len_value},${start_ts},${end_ts},${status},${mode_log},${latest_tar}" >> "$SUMMARY_CSV"

  echo "=== [$mode_name] build ${status} ==="
  echo "log: $mode_log"
  if [[ -n "$latest_tar" ]]; then
    echo "latest tar: $latest_tar"
  fi

  if [[ "$status" != "ok" ]]; then
    OVERALL_STATUS=1
  fi
}

run_mode "none" 0 2
run_mode "2clz" 1 2
run_mode "3clz" 2 3
run_mode "4clz" 2 4

if [[ "$OVERALL_STATUS" -eq 0 ]]; then
  echo "All requested modes completed successfully."
else
  echo "All requested modes completed with one or more failures."
fi
echo "Summary CSV: $SUMMARY_CSV"

exit "$OVERALL_STATUS"
