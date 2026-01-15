# SatSwarmv2 Testing Directory

This directory contains test instances and helper scripts for benchmarking and validating the SatSwarmv2 solver.

## Directory Structure

- **`satlib/`**: Contains the standard SATLIB benchmark suite. This directory is expected to have `sat/` and `unsat/` subdirectories for validation purposes.
- **`eval_set/`**: A smaller collection of instances (e.g., `uf20` from SATLIB) used for quick evaluation and regression testing.
- **`generated_instances/`**: CNF files generated programmatically (e.g., using `toughsat.py`) for specific difficulty scaling or testing properties.
- **`unit_tests/`**: Small, simple CNF files used for sanity checking, basic functionality tests, and regression testing of corner cases.
- **`misc_benchmarks/`**: A collection of isolated benchmark files that do not fit into the other specific categories.
- **`aim/`, `random/`**: Varied collections of SAT/UNSAT instances from specific sources or challenges.
- **Root**: Contains helper scripts `toughsat.py` and `validate_satlib.py`.

## Scripts

### `toughsat.py`

A script to generate random k-SAT instances. It uses the `glucose3` solver (via `pysat`) to determine if a generated instance is SAT or UNSAT, allowing for the creation of specific test sets.

**Usage:**
```bash
python3 toughsat.py <k> <n> <m> <num_sat> <num_unsat>
```

- `k`: Number of literals per clause (e.g., 3 for 3-SAT).
- `n`: Number of variables.
- `m`: Number of clauses.
- `num_sat`: Number of satisfiable instances to generate.
- `num_unsat`: Number of unsatisfiable instances to generate.

### `validate_satlib.py`

A utility to validate the correctness of SAT solvers against known results. It expects a directory structure (defaulting to `satlib/`) containing `sat/` and `unsat/` subdirectories.

**Usage:**
```bash
python3 validate_satlib.py [--root DIR] [--solver NAME] [--limit N]
```

- `--root`: Path to the directory containing `sat/` and `unsat` folders.
- `--solver`: PySAT solver name to use for verification (default: `g3` i.e., Glucose3).
- `--limit`: Limit the number of files to check.
