# Archive Directory

This directory contains deprecated or unused code kept for reference purposes.

## Files

### `vde_scan.sv`
**Status:** Deprecated (archived 2026-01-14)

**Description:** Alternate implementation of the Variable Decision Engine (VDE) using a linear scan approach instead of the binary heap structure. This was created as a simpler reference implementation but was never integrated into the actual solver.

**Why Archived:**
- No active usage in the codebase (zero references)
- The production solver uses `vde.sv` → `vde_heap.sv` (binary max-heap implementation)
- Kept for reference/comparison purposes

**If Needed:**
This module could be brought back for debugging or educational purposes. It implements the same interface as `vde_heap.sv` but with O(N) scan time instead of O(log N) heap operations.
