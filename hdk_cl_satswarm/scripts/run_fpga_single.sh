#!/usr/bin/env bash
# Wrapper around satswarm_host for running a single DIMACS CNF on the FPGA.
#
# Usage:
#   run_fpga_single.sh <cnf_file> [--slot N] [--timeout N] [--debug N] [--host PATH]
#
# Defaults: slot=0  timeout=15  debug=0
# The host binary is resolved relative to this script (../host/satswarm_host).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_HOST="$SCRIPT_DIR/../host/satswarm_host"

SLOT=0
TIMEOUT=15
DEBUG=0
HOST="$DEFAULT_HOST"
CNF_FILE=""

usage() {
  cat <<EOF
Usage: $(basename "$0") <cnf_file> [options]

Options:
  --slot N       FPGA slot number (default: ${SLOT})
  --timeout N    Per-run timeout in seconds (default: ${TIMEOUT})
  --debug N      Debug verbosity passed to host (default: ${DEBUG})
  --host PATH    Path to satswarm_host binary (default: auto-detected)
  -h, --help     Show this help

The CNF file must be in DIMACS format (.cnf or .dimacs).

Example:
  $(basename "$0") sim/tests/generated_instances/sat_20v_80c_1.cnf --slot 0 --timeout 30
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slot)    SLOT="$2";    shift 2 ;;
    --timeout) TIMEOUT="$2"; shift 2 ;;
    --debug)   DEBUG="$2";   shift 2 ;;
    --host)    HOST="$2";    shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;
    *)
      if [[ -z "$CNF_FILE" ]]; then
        CNF_FILE="$1"
        shift
      else
        echo "Unexpected argument: $1" >&2
        usage
        exit 2
      fi
      ;;
  esac
done

if [[ -z "$CNF_FILE" ]]; then
  echo "Error: CNF file is required." >&2
  usage
  exit 2
fi

if [[ ! -f "$CNF_FILE" ]]; then
  echo "Error: CNF file not found: $CNF_FILE" >&2
  exit 2
fi

if [[ ! -x "$HOST" ]]; then
  echo "Error: satswarm_host binary not found or not executable: $HOST" >&2
  echo "Build it first:" >&2
  echo "  cd $(dirname "$HOST") && make" >&2
  exit 2
fi

echo "==========================================="
echo "FPGA Single-CNF Run"
echo "==========================================="
echo "CNF:     $CNF_FILE"
echo "Host:    $HOST"
echo "Slot:    $SLOT"
echo "Timeout: ${TIMEOUT}s"
echo "Debug:   $DEBUG"
echo "==========================================="

exec "$HOST" "$CNF_FILE" --slot "$SLOT" --timeout "$TIMEOUT" --debug "$DEBUG"
