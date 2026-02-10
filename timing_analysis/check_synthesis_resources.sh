#!/bin/bash
# Run synthesis check with timeout
# Usage: ./check_synthesis_resources.sh

TIMEOUT_CMD="timeout"
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac doesn't have timeout by default, rely on gtimeout if available or perl fallback
    if command -v gtimeout &> /dev/null; then
        TIMEOUT_CMD="gtimeout"
    else
        # Fallback to python for timeout
        function python_timeout() {
            local time=$1
            shift
            perl -e 'alarm shift; exec @ARGV' "$time" "$@"
        }
        TIMEOUT_CMD="python_timeout"
    fi
fi

echo "Running Synthesis Check (Timeout: 15m)..."
START_TIME=$(date +%s)
$TIMEOUT_CMD 15m yosys -l opensta_resource_check.log synth_check.ys
EXIT_CODE=$?
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ $EXIT_CODE -eq 124 ] || [ $EXIT_CODE -eq 142 ]; then
    echo "Synthesis Timed Out after ${DURATION}s!"
else
    echo "Synthesis Completed in ${DURATION}s."
fi

# Grep for resource usage
echo "========================================"
echo "Resource Usage Summary:"
grep "Number of cells" opensta_resource_check.log
grep "RAMB" opensta_resource_check.log
grep "FDRE" opensta_resource_check.log | head -n 5
grep "FDSE" opensta_resource_check.log | head -n 5
echo "========================================"

# Grep for specific memory inference messages
grep "Mapping memory" opensta_resource_check.log | grep -v "Mapping memory .* to block ram"
