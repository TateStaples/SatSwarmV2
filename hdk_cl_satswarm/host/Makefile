# Makefile for SatSwarm AWS F1 Host Application
#
# Requires AWS FPGA SDK:
#   export SDK_DIR=/path/to/aws-fpga/sdk
#   source $SDK_DIR/userspace/sdk_setup.sh
#
# Usage:
#   make              # Build satswarm_host
#   make clean        # Remove build artifacts
#   make test         # Build and show usage

CC      := gcc
CFLAGS  := -std=c11 -Wall -Wextra -O2 -g

# AWS FPGA SDK paths
SDK_DIR   ?= $(AWS_FPGA_REPO_DIR)/sdk
INCLUDES  := -I$(SDK_DIR)/userspace/include
LDFLAGS   := -L$(SDK_DIR)/userspace/lib
LIBS      := -lfpga_mgmt -lrt -lpthread

# If SDK not found, provide a stub build that compiles but won't link
ifeq ($(wildcard $(SDK_DIR)/userspace/include/fpga_pci.h),)
$(warning AWS FPGA SDK not found at $(SDK_DIR))
$(warning Building with stubs — binary will not work without SDK)
INCLUDES := -DAWS_SDK_STUB
LIBS     :=
endif

TARGET    := satswarm_host
SRC       := satswarm_host.c

.PHONY: all build clean test help

all: build

build: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $< $(LDFLAGS) $(LIBS)
	@echo "Built: $(TARGET)"

clean:
	rm -f $(TARGET)
	@echo "Cleaned."

test: build
	./$(TARGET) --help

help:
	@echo "SatSwarm Host Application Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make          Build satswarm_host"
	@echo "  make clean    Remove build artifacts"
	@echo "  make test     Build and show usage"
	@echo ""
	@echo "Environment:"
	@echo "  SDK_DIR       Path to AWS FPGA SDK (default: $$AWS_FPGA_REPO_DIR/sdk)"
	@echo ""
	@echo "Usage:"
	@echo "  ./satswarm_host <cnf_file> [--slot N] [--timeout N] [--debug N]"
