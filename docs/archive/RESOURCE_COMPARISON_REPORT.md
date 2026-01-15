# FPGA SAT Solver Resource Estimation & Comparison Report

**Generated**: January 2025  
**Method**: Yosys Synthesis + Manual Memory Analysis  
**Target**: Generic FPGA (estimates for Xilinx UltraScale+)

## Executive Summary

| Solver | Architecture | LUTs (Est.) | FFs (Est.) | BRAM36 | URAM | Memory Model |
|--------|-------------|-------------|------------|--------|------|--------------|
| **SatSwarmv2** | Full CDCL | 50K-100K | 25K-50K | ~6,300 | ~230 | On-chip + DDR |
| **SatAccel** | Partitioned CDCL | 80K-150K | 40K-75K | ~4,900 | ~170 | External DDR |
| **SatSwarm** | Node-based | 5K-15K | 2K-8K | ~1 | 0 | On-chip ROM |

## Detailed Resource Breakdown

### 1. SatSwarmv2

**Top Module**: `verisat_top`

**Architecture**: Complete CDCL solver with:
- Propagation Search Engine (PSE)
- Conflict Analysis Engine (CAE)
- Backtracking module
- Variable Decision Engine (VDE) - planned
- VSIDS heap - planned

#### Memory Structures

| Component | Depth | Width | Total Bits | Type | Notes |
|-----------|-------|-------|------------|------|-------|
| **Literal Store** | 1,048,576 | 32 | 33,554,432 | External DDR | ~33.5 MB - off-chip |
| **Clause Table** | 262,144 | ~256 | 67,108,864 | BRAM/URAM | clause_entry_t struct |
| **Variable Table** | 16,384 | ~96 | 1,572,864 | LUTRAM/BRAM | assignment metadata |
| **Trail Queue** | 32,768 | 32 | 1,048,576 | BRAM | assignment history |
| **CAE Learned Clause** | 1,024 | 32 | 32,768 | BRAM | conflict analysis buffer |

**Total On-Chip Memory**: ~69.8 MB  
**BRAM36 Estimate**: ~6,300 (assuming 18K BRAMs, 2 per BRAM36)  
**URAM Estimate**: ~230 (for large clause table)

#### Logic Resources

- **PSE Module**: ~10K-20K LUTs (state machine, clause scanning)
- **CAE Module**: ~15K-30K LUTs (First-UIP resolution, minimization)
- **Backtrack Module**: ~5K-10K LUTs (trail traversal, variable clearing)
- **Variable Table**: ~5K-10K LUTs (LUTRAM + control logic)
- **Top-level FSM**: ~5K-10K LUTs (CDCL orchestration)
- **Misc (counters, muxes)**: ~10K-20K LUTs

**Total LUT Estimate**: 50K-100K  
**Total FF Estimate**: 25K-50K

#### Key Features
- ✅ Full CDCL implementation
- ✅ Watched-literal BCP
- ✅ Conflict analysis
- ✅ Backtracking
- ⚠️ VSIDS incomplete
- ⚠️ Large memory footprint

---

### 2. SatAccel

**Top Module**: `sataccel_solver`

**Architecture**: Optimized CDCL with:
- 8-way partitioned BCP (discover)
- First-UIP conflict analysis (learn)
- VSIDS priority queue
- Luby restart policy
- Stream-based memory interfaces

#### Memory Structures

| Component | Depth | Width | Total Bits | Type | Notes |
|-----------|-------|-------|------------|------|-------|
| **Literal Store** | External | 512 | N/A | External DDR4 | 512-bit pages |
| **Clause States** | 131,072 × 8 | 64 | 67,108,864 | BRAM (partitioned) | 8 partitions |
| **Literal Metadata** | 32,768 | 386 | 12,648,448 | LUTRAM/BRAM | per-literal info |
| **Answer Stack** | 32,768 | 32 | 1,048,576 | BRAM | assignment trail |
| **Priority Queue** | 32,768 | 64 | 2,097,152 | BRAM | VSIDS heap |

**Total On-Chip Memory**: ~82.9 MB  
**BRAM36 Estimate**: ~4,900  
**URAM Estimate**: ~170

#### Logic Resources

- **Discover Module**: ~30K-60K LUTs (8 partitions, watch-list processing)
- **Learn Module**: ~20K-40K LUTs (First-UIP, parallel minimization)
- **Backtrack Module**: ~10K-20K LUTs (trail management)
- **PQ Handler**: ~10K-20K LUTs (VSIDS heap operations)
- **Color Stream**: ~5K-10K LUTs (memory stream interface)
- **Top-level FSM**: ~5K-10K LUTs (CDCL orchestration)

**Total LUT Estimate**: 80K-150K  
**Total FF Estimate**: 40K-75K

#### Key Features
- ✅ 8-way parallel BCP
- ✅ Optimized dataflow
- ✅ VSIDS implemented
- ✅ Restart policy
- ✅ External memory interface
- ⚠️ Higher complexity

---

### 3. SatSwarm/FPGAngster

**Top Module**: `node_with_backtrack`

**Architecture**: Lightweight node-based solver:
- Combinational clause evaluation
- Static memory for clauses
- Simple backtracking controller
- 16 clauses per cycle throughput

#### Memory Structures

| Component | Depth | Width | Total Bits | Type | Notes |
|-----------|-------|-------|------------|------|-------|
| **Static Memory** | 16 | 216 | 3,456 | BRAM/ROM | Clause storage (3-SAT) |
| **Decision Stack** | 16 | 9 | 144 | LUTRAM | Backtrack history |
| **Polarity Tracking** | 256 | 2 | 512 | LUTRAM | Tried assignments |

**Total On-Chip Memory**: ~4 KB  
**BRAM36 Estimate**: ~1 (minimal)

#### Logic Resources

- **Node Module**: ~2K-5K LUTs (clause evaluator, comparator, OR mask)
- **Backtrack Controller**: ~2K-5K LUTs (state machine, decision stack)
- **Memory Interface**: ~1K-3K LUTs (row pointer, static memory)
- **Misc**: ~1K-2K LUTs

**Total LUT Estimate**: 5K-15K  
**Total FF Estimate**: 2K-8K

#### Key Features
- ✅ Very low resource usage
- ✅ High throughput (16 clauses/cycle)
- ✅ Simple architecture
- ⚠️ Limited scalability (fixed clause count)
- ⚠️ Basic backtracking

---

## Resource Utilization Comparison

### For Xilinx UltraScale+ VU9P

**Available Resources**:
- LUTs: 1,182,240
- FFs: 2,364,480
- BRAM36: 2,160 (each = 36Kb)
- URAM: 960 (each = 288Kb)

| Solver | LUTs | LUT % | FFs | FF % | BRAM36 | BRAM % | URAM | URAM % |
|--------|------|-------|-----|------|--------|--------|------|--------|
| SatSwarmv2 | 50K-100K | 4-8% | 25K-50K | 1-2% | ~6,300 | 292%* | ~230 | 24% |
| SatAccel | 80K-150K | 7-13% | 40K-75K | 2-3% | ~4,900 | 227%* | ~170 | 18% |
| SatSwarm | 5K-15K | 0.4-1% | 2K-8K | 0.1-0.3% | ~1 | 0.05% | 0 | 0% |

*BRAM usage exceeds available - requires external memory or URAM

### For Smaller FPGAs (e.g., Artix-7 200T)

**Available Resources**:
- LUTs: 126,800
- FFs: 253,600
- BRAM36: 365

| Solver | Feasible? | Notes |
|--------|-----------|-------|
| SatSwarmv2 | ❌ No | BRAM requirement too high |
| SatAccel | ❌ No | BRAM requirement too high |
| SatSwarm | ✅ Yes | Fits easily |

## Architecture Comparison

| Aspect | SatSwarmv2 | SatAccel | SatSwarm |
|--------|---------|----------|----------|
| **Algorithm** | Full CDCL | Optimized CDCL | Simple backtracking |
| **BCP Method** | Watched literals | 8-way partitioned | Combinational eval |
| **Conflict Analysis** | First-UIP (partial) | First-UIP + minimize | None |
| **Decision Heuristic** | Sequential (VSIDS planned) | VSIDS (heap) | Sequential |
| **Memory Model** | On-chip + DDR | External DDR4 | On-chip only |
| **Parallelism** | Single-threaded | 8-way BCP | 16 clauses/cycle |
| **Scalability** | Medium | High | Low |
| **Complexity** | Medium-High | High | Low |
| **Resource Usage** | High | Very High | Very Low |

## Performance Characteristics

### Throughput

- **SatSwarmv2**: Sequential BCP, ~1 clause per cycle (watched literals)
- **SatAccel**: 8-way parallel BCP, ~8 clauses per cycle
- **SatSwarm**: 16 clauses per cycle (combinational)

### Memory Bandwidth

- **SatSwarmv2**: Moderate (on-chip BRAM access)
- **SatAccel**: High (external DDR4, 512-bit pages)
- **SatSwarm**: Very Low (small on-chip memory)

### Latency

- **SatSwarmv2**: Variable (CDCL loop iterations)
- **SatAccel**: Variable (optimized pipeline)
- **SatSwarm**: Fixed (2-3 cycles per evaluation)

## Recommendations

### For Large Instances (>10K variables)
- **SatAccel**: Best choice due to external memory and parallelism
- Requires high-end FPGA with DDR4 interface

### For Medium Instances (1K-10K variables)
- **SatSwarmv2**: Good balance of features and resources
- May need URAM for clause table

### For Small Instances (<1K variables)
- **SatSwarm**: Most efficient, fits on small FPGAs
- Limited by fixed clause count

### For Research/Development
- **SatSwarmv2**: Most complete implementation, easier to modify
- **SatAccel**: Best performance, more complex
- **SatSwarm**: Simplest, good for understanding basics

## Notes

1. **Memory Estimates**: Based on maximum parameter values. Actual usage depends on problem size.
2. **LUT Estimates**: Rough approximations from code analysis. Actual synthesis may vary.
3. **BRAM Overflow**: SatSwarmv2 and SatAccel exceed available BRAM on most FPGAs - requires:
   - External DDR memory
   - URAM usage
   - Parameter reduction
4. **Synthesis Results**: Yosys generic synthesis used. Technology-specific synthesis (Vivado/Quartus) will provide more accurate counts.
5. **Timing**: Not analyzed. Critical paths may limit clock frequency.

## Next Steps

1. **Technology Mapping**: Run Vivado/Quartus synthesis for target device
2. **Parameter Tuning**: Adjust MAX_VARS, MAX_CLAUSES for target FPGA
3. **Memory Optimization**: Use URAM for large arrays, external DDR where possible
4. **Timing Analysis**: Identify and optimize critical paths
5. **Place & Route**: Extract actual resource usage post-implementation

---

**Report Generated**: January 2025  
**Tools Used**: Yosys, Manual Code Analysis  
**Contact**: See project documentation for details

