# Parallel SAT Solver - Mini
> A DPLL SAT solver for FPGAs

## Features
- 3SAT with dense encoding (0 = True or Symbol, 1 = False)
- Static memory holds the entire CNF formula
- Iteratively loads the static memory to get a bitmask of the CNF formula
- Simple OR between state & bitmask to update dense encoding
- Whenever decisions are m
