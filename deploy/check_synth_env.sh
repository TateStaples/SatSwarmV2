#!/usr/bin/env bash
# Quick check that Vivado (or required tools) are available before a long SatSwarm synthesis run.
set -euo pipefail
if ! command -v vivado >/dev/null 2>&1; then
  echo "ERROR: vivado not found in PATH. Source Xilinx/Vivado settings or run on F2 Developer AMI."
  exit 1
fi
echo "OK: $(command -v vivado)"
vivado -version | head -n 2
exit 0
