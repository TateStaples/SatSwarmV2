# SatSwarmV2 Benchmark Results & VeriSAT Comparison
**Date:** 2026-02-05

- VeriSAT: SoTA, clocked at 150 MHz, ran on full 1000 examples
- SatSwarm: our design, clocked at 50 MHz, ran on 100 examples
---

## SAT Results (UF50)

| Design | Raw Cycles | Time (ms) |
| :--- | :--- | :--- |
| **VeriSAT** (150 MHz) | **39,240.15** | **0.26** |
| **SatSwarm 1x1** (50 MHz) | **24,772.53** | **0.495** |
| **SatSwarm 2x2** (50 MHz) | **12,158.19** | **0.243** |
| **SatSwarm 3x3** (50 MHz) | **8,300.11** | **0.166** |


---

## UNSAT Results (UUF50)


| Design | Raw Cycles | Time (ms) |
| :--- | :--- | :--- |
| **VeriSAT** (150 MHz) | **91,667.29** | **0.61** |
| **SatSwarm 1x1** (50 MHz) | **55,740.63** | **1.115** |
| **SatSwarm 2x2** (50 MHz) | **45,774.66** | **0.915** |
| **SatSwarm 3x3** (50 MHz) | **38,011.36** | **0.760** |
