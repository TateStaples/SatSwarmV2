VERILATOR ?= verilator
TOP      := tb_satswarmv2
RTL_SRCS := $(abspath ../src/Mega/satswarmv2_pkg.sv \
            ../src/Mega/interface_unit.sv \
            ../src/Mega/mesh_interconnect.sv \
            ../src/Mega/global_mem_arbiter.sv \
            ../src/Mega/solver_core.sv \
            ../src/Mega/satswarm_top.sv \
            ../src/Mega/pse.sv \
            ../src/Mega/cae.sv \
            ../src/Mega/vde.sv \
            ../src/Mega/vde.sv \
            ../src/Mega/vde_heap.sv \
            ../src/Mega/trail_manager.sv \
            ../src/Mega/shared_clause_buffer.sv \
            ../src/Mega/utils/sfifo.sv \
            ../src/Mega/utils/stack.sv)

# Mini DPLL sources (no CAE, no VDE heap)
MINI_SRCS := $(abspath ../src/Mini/mini_pkg.sv \
             ../src/Mini/mini_pse.sv \
             ../src/Mini/mini_solver_core.sv \
             ../src/Mini/mini_top.sv)

VERILATOR_FLAGS := -Wall --timing --sv --cc --exe \
  --Wno-fatal --Wno-UNUSED --Wno-PINCONNECTEMPTY --Wno-UNOPTFLAT \
  --Wno-INITIALDLY --Wno-WIDTHTRUNC --Wno-WIDTHEXPAND --Wno-MODDUP \
  --Wno-BLKANDNBLK --Wno-WIDTH

.PHONY: all build test benchmark clean help debug_single regression_single regression_multi mini

all: build


build: build_1x1
	@mkdir -p obj_dir
	@cp obj_dir_1x1/Vtb_satswarmv2 obj_dir/Vtb_satswarmv2

# Build 1x1 grid (single core) for benchmark comparison
build_1x1:
	@echo "Building SatSwarmv2 1x1 (Single Core) for Benchmark..."
	$(VERILATOR) $(VERILATOR_FLAGS) sv/tb_satswarmv2.sv cpp/sim_main.cpp $(RTL_SRCS) \
		--top-module $(TOP) \
		-GGRID_X=1 -GGRID_Y=1 \
		-CFLAGS "-std=c++17" \
		-I../src/Mega \
		-Mdir obj_dir_1x1 \
		--build -j 8

# Build 2x2 grid (4 cores) for benchmark comparison  
build_2x2:
	@echo "Building SatSwarmv2 2x2 (4 Cores) for Benchmark..."
	$(VERILATOR) $(VERILATOR_FLAGS) sv/tb_satswarmv2.sv cpp/sim_main.cpp $(RTL_SRCS) \
		--top-module $(TOP) \
		-GGRID_X=2 -GGRID_Y=2 \
		-CFLAGS "-std=c++17" \
		-DMULTICORE \
		-I../src/Mega \
		-Mdir obj_dir_2x2 \
		--build -j 8

# Build 3x3 grid (9 cores) for benchmark comparison  
build_3x3:
	@echo "Building SatSwarmv2 3x3 (9 Cores) for Benchmark..."
	$(VERILATOR) $(VERILATOR_FLAGS) sv/tb_satswarmv2.sv cpp/sim_main.cpp $(RTL_SRCS) \
		--top-module $(TOP) \
		-GGRID_X=3 -GGRID_Y=3 \
		-CFLAGS "-std=c++17" \
		-DMULTICORE \
		-I../src/Mega \
		-Mdir obj_dir_3x3 \
		--build -j 8

test: build
	@echo ""
	@echo "========================================="
	@echo "Running SatSwarmv2 Test Suite"
	@echo "========================================="
	@./obj_dir/V$(TOP)

benchmark: build
	@echo ""
	@echo "========================================="
	@echo "SatSwarmv2 Benchmark Results"
	@echo "========================================="
	@./obj_dir/V$(TOP) | tee benchmark_results.txt
	@echo ""
	@echo "Results saved to benchmark_results.txt"

wave: build
	@echo "Running with waveform generation..."
	$(VERILATOR) $(VERILATOR_FLAGS) --trace --trace-structs \
		sv/tb_satswarmv2.sv cpp/sim_main.cpp $(RTL_SRCS) \
		--top-module $(TOP) \
		-CFLAGS "-std=c++17" \
		-I../src/rtl \
		--build -j 8
	@./obj_dir/V$(TOP)
	@echo "Waveform saved to dump.vcd"
	@if command -v gtkwave >/dev/null 2>&1; then \
		gtkwave dump.vcd & \
	else \
		echo "gtkwave not found, open dump.vcd manually"; \
	fi

debug_single:
	@echo "Building single-core debug testbench..."
	$(VERILATOR) $(VERILATOR_FLAGS) sv/tb_single_core_debug.sv cpp/sim_single_core.cpp $(RTL_SRCS) \
		--top-module tb_single_core_debug \
		-CFLAGS "-std=c++17" \
		-I../src/Mega \
		--build -j 8
	@echo "Running single-core debug test..."
	@./obj_dir/Vtb_single_core_debug

debug_8v:
	@echo "Building 8-var UNSAT debug testbench..."
	$(VERILATOR) $(VERILATOR_FLAGS) sv/tb_8v_debug.sv cpp/sim_8v_debug.cpp $(RTL_SRCS) \
		--top-module tb_8v_debug \
		-CFLAGS "-std=c++17" \
		-I../src/Mega \
		--build -j 8
	@echo "Running 8-var debug test..."
	@./obj_dir/Vtb_8v_debug 2>&1 | tee hw_trace_8v.log
	@echo "Hardware trace saved to hw_trace_8v.log"





test_vde_heap:
	@echo "Building VDE Heap testbench..."
	$(VERILATOR) $(VERILATOR_FLAGS) sv/tb_vde_heap.sv cpp/sim_tb_vde_heap.cpp \
		../src/Mega/satswarmv2_pkg.sv ../src/Mega/vde_heap.sv \
		--top-module tb_vde_heap \
		-CFLAGS "-std=c++17" \
		-I../src/Mega \
		--build -j 8
	@echo "Running VDE Heap test..."
	@./obj_dir/Vtb_vde_heap

# Default parameters for regression (can be overridden)
MAX_VARS ?= 256
MAX_CLAUSES ?= 2048
MAX_LITS ?= 16384

# Output executable targets
OBJ_SINGLE := obj_dir/Vtb_regression_single
STAMP_SINGLE := obj_dir/.build_single_stamp

$(STAMP_SINGLE): sv/tb_regression_single.sv cpp/sim_regression_single.cpp $(RTL_SRCS) Makefile
	@echo "Building single-core regression testbench with MAX_VARS=$(MAX_VARS)..."
	$(VERILATOR) $(VERILATOR_FLAGS) sv/tb_regression_single.sv cpp/sim_regression_single.cpp $(RTL_SRCS) \
		--top-module tb_regression_single \
		-GMAX_VARS_PER_CORE=$(MAX_VARS) \
		-GMAX_CLAUSES_PER_CORE=$(MAX_CLAUSES) \
		-GMAX_LITS=$(MAX_LITS) \
		-CFLAGS "-std=c++17 -Wno-unknown-warning-option" \
		-I../src/Mega \
		--build -j 8
	@touch $(STAMP_SINGLE)

regression_single: $(STAMP_SINGLE)

regression_multi: $(STAMP_SINGLE)
	@echo "Multi-core regression testbench build handled by $(STAMP_SINGLE) target"

# Mini DPLL target (pure DPLL without CAE)
OBJ_MINI := obj_dir_mini/Vtb_mini
STAMP_MINI := obj_dir_mini/.build_mini_stamp

$(STAMP_MINI): sv/tb_mini.sv $(MINI_SRCS) Makefile
	@echo "Building Mini DPLL testbench..."
	@mkdir -p obj_dir_mini
	$(VERILATOR) $(VERILATOR_FLAGS) sv/tb_mini.sv cpp/sim_mini.cpp $(MINI_SRCS) \
		--top-module tb_mini \
		-CFLAGS "-std=c++17 -Wno-unknown-warning-option" \
		-I../src/Mini \
		-Mdir obj_dir_mini \
		--build -j 8
	@touch $(STAMP_MINI)

mini: $(STAMP_MINI)

clean:
	rm -rf obj_dir obj_dir_mini logs *.vcd benchmark_results.txt .build_*_stamp

help:
	@echo "SatSwarmv2 Makefile Targets:"
	@echo "  make build     - Compile with Verilator"
	@echo "  make test      - Build and run test suite"
	@echo "  make benchmark - Run benchmarks and save results"
	@echo "  make wave      - Build with waveform tracing and view"
	@echo "  make mini      - Build Mini DPLL solver (no CAE)"
	@echo "  make clean     - Remove build artifacts"
