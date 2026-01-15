# BUG-010: CAE Reason Staleness for Learned Clauses

## Metadata
- **Status**: Resolved
- **Fixed Date**: 2026-01-15
- **Severity**: Critical (Completeness/Soundness)
- **Component**: Conflict Analysis Engine (CAE) / Propagation Search Engine (PSE)
- **Affected Tests**: `sat_3v_12c_45.cnf` (and potentially any SAT instance requiring learned clause resolution)

## Description
The solver correctly identified conflict clauses but failed to derive the correct First-UIP (Unique Implication Point) clause.
Specifically, conflicting variables that were assigned via *learned clauses* were treated as having "No Reason" (`0xFFFF`) during resolution.
This caused the resolution process to abort prematurely or produce incorrect backtracking levels (e.g., backtracking to Level 0 instead of the assertion level), leading to invalid `UNSAT` results or livelocks.

## Root Cause
**Source of Truth Mismatch**:
1.  **Learned Clause Push**: When `solver_core` learns a clause, it pushes the asserting literal to the Trail with the correct "Reason ID" (the learned clause index).
2.  **PSE Broadcast**: This assignment is broadcast to PSE. However, PSE's internal logic treats any assignment pushed from "outside" (i.e., not its own propagation) as a decision-like assignment, often clearing or ignoring the reason ID unless specifically updated via a dedicated write path.
3.  **Stale Query**: The Conflict Analysis Engine (`cae.sv`) was querying **PSE** (`reason_query_clause`) to find out why a variable was assigned.
4.  **Failure**: Since PSE didn't persistently track the reason for these "external" learned pushes (or tracked them as `Decision`), it returned `0xFFFF`. CAE interpreted this as "Decision Variable" (which shouldn't happen at the conflict level) or "Invalid", causing resolution failure.

## Fix
Redirected the **Reason Query** path in `cae.sv` to use the **Trail Manager** (`trail_read_reason`) instead of PSE.
- The Trail Manager is the architectural Source of Truth for the assignment trace. It correctly stores the Reason ID for every assignment, including Decision (`0xFFFF`), Propagation (Clause ID), and Learned (Clause ID).
- By querying the Trail, CAE now reliably retrieves the correct reason, allowing the 1-UIP resolution to traverse the graph correctly back to the single literal at the current decision level.

## Verification
- **Test Case**: `sat_3v_12c_45.cnf`
- **Before Fix**: Hardware trace showed `Backtrack to: 1` then `Backtrack to: 0` with `Trail Height: 3` (incorrectly fixing variables at Level 0). Result: `UNSAT` (Incorrect).
- **After Fix**: Hardware trace showed `Learned Clause: [1]`. Behavior matched the Python golden model. Result: `SAT` (Correct).
