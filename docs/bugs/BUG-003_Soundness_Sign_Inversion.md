# BUG-003: Soundness Error (Sign Inversion in CAE)

## Status
**RESOLVED**

## Description
The solver reported `SAT` for known `UNSAT` problems (e.g., `SAT 8v #1` which was actually an UNSAT instance in disguise, or valid UNSAT tests). Model verification failed, indicating the reported model did not satisfy the formula.

## Symptoms
- Solver reported `SAT`.
- `tb_regression_single` reported "MODEL INVALID" with failed clauses.
- Debug prints showed the CAE learning a literal with the WRONG sign (e.g., learning `2` when it should have learned `-2` as the UIP).

## Root Cause
Logic error in `cae.sv` (Conflict Analysis Engine).
The line constructing the learned clause inverted the sign of the UIP literal:
```systemverilog
learned_clause[0] = !uip_literal; // INCORRECT
```
This caused the solver to learn the *negation* of the correct implication, effectively asserting the wrong branch and validating an invalid path.

## Fix
Removed the incorrect negation in `cae.sv`:
```systemverilog
learned_clause[0] = uip_literal; // CORRECT
```

## Verification
- `SAT 8v #1` passed (correctly identifying satisfiability or unsatisfiability).
- All Level-0 conflict tests passed.
- Model verification now succeeds for all SAT results.
