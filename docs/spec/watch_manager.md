# watch_manager — Two-Watched-Literal Lists

**Source:** [src/Mega/watch_manager.sv](../../src/Mega/watch_manager.sv)

## Overview

The watch manager maintains the two-watched-literal scheme. Each clause has two watched literals; each literal (in both polarities) has a linked list of clauses watching it. Used for efficient BCP: only clauses that need scanning (watched literal falsified) are examined.

**Note:** PSE embeds its own watch lists (watched_lit1/2, watch_head1/2, watch_next1/2). The standalone `watch_manager` may be used in alternative configurations; the build uses PSE's internal arrays.

## Parameters


| Parameter     | Default | Description   |
| ------------- | ------- | ------------- |
| `MAX_VARS`    | 256     | Max variables |
| `MAX_CLAUSES` | 256     | Max clauses   |


## Interface

### Control


| Port        | Direction | Type           | Description                   |
| ----------- | --------- | -------------- | ----------------------------- |
| `clear_all` | input     | `logic`        | Clear all lists               |
| `clear_idx` | input     | `logic [15:0]` | Index for clearing (stepwise) |


### Link (for INIT_WATCHES or LOAD_CLAUSE)


| Port             | Direction | Type           | Description                  |
| ---------------- | --------- | -------------- | ---------------------------- |
| `link_en`        | input     | `logic`        | Link enable                  |
| `link_clause_id` | input     | `logic [15:0]` | Clause ID                    |
| `link_w1`        | input     | `logic [15:0]` | First watched literal index  |
| `link_w2`        | input     | `logic [15:0]` | Second watched literal index |
| `link_idx1`      | input     | `logic [15:0]` | safe_lit_idx for w1          |
| `link_idx2`      | input     | `logic [15:0]` | safe_lit_idx for w2          |


### Move (for SCAN_WATCH)


| Port             | Direction | Type           | Description                             |
| ---------------- | --------- | -------------- | --------------------------------------- |
| `move_en`        | input     | `logic`        | Move enable                             |
| `move_clause_id` | input     | `logic [15:0]` | Clause ID                               |
| `move_list_sel`  | input     | `logic`        | 0=move watch1, 1=move watch2            |
| `move_new_w`     | input     | `logic [15:0]` | New literal index                       |
| `move_old_idx`   | input     | `logic [15:0]` | Old safe_lit_idx                        |
| `move_new_idx`   | input     | `logic [15:0]` | New safe_lit_idx                        |
| `move_prev_id`   | input     | `logic [15:0]` | Previous clause in list (for unlinking) |


### Direct Read (for SCAN_WATCH traversal)


| Port           | Direction | Type           | Description                       |
| -------------- | --------- | -------------- | --------------------------------- |
| `rd_clause_id` | input     | `logic [15:0]` | Clause ID                         |
| `rd_w1`        | output    | `logic [15:0]` | Watched literal 1                 |
| `rd_w2`        | output    | `logic [15:0]` | Watched literal 2                 |
| `rd_next1`     | output    | `logic [15:0]` | Next clause in watch1 list        |
| `rd_next2`     | output    | `logic [15:0]` | Next clause in watch2 list        |
| `rd_head_idx`  | input     | `logic [15:0]` | Literal index (0 to 2*MAX_VARS-1) |
| `rd_head1`     | output    | `logic [15:0]` | Head of watch1 list               |
| `rd_head2`     | output    | `logic [15:0]` | Head of watch2 list               |


## Internal Structure

### Arrays

- `watched_lit1[0:MAX_CLAUSES-1]` — Per-clause watched literal 1
- `watched_lit2[0:MAX_CLAUSES-1]` — Per-clause watched literal 2
- `watch_head1[0:2*MAX_VARS-1]` — Head of list per literal (literal index 0..2*MAX_VARS-1)
- `watch_head2[0:2*MAX_VARS-1]` — Same for watch2
- `watch_next1[0:MAX_CLAUSES-1]` — Next clause in list
- `watch_next2[0:MAX_CLAUSES-1]` — Same for watch2

### safe_lit_idx

- Index into watch_head/watch_next: 2*v for positive literal v, 2*v-1 for negative

## Behavior (RTL Specification)

### clear_all (synchronous)

When clear_all on posedge clk: if clear_idx < MAX_CLAUSES: watch_next1[clear_idx] <= 16'hFFFF, watch_next2[clear_idx] <= 16'hFFFF. if clear_idx < 2*MAX_VARS: watch_head1[clear_idx] <= 16'hFFFF, watch_head2[clear_idx] <= 16'hFFFF. Caller must step clear_idx to clear all.

### link_en (synchronous)

When link_en (and !clear_all): watched_lit1[link_clause_id] <= link_w1, watched_lit2[link_clause_id] <= link_w2. watch_next1[link_clause_id] <= watch_head1[link_idx1], watch_head1[link_idx1] <= link_clause_id. watch_next2[link_clause_id] <= watch_head2[link_idx2], watch_head2[link_idx2] <= link_clause_id.

### move_en (synchronous)

When move_en (and !clear_all, !link_en): If move_list_sel == 0 (watch1): If move_old_idx == move_new_idx: watched_lit1[move_clause_id] <= move_new_w. Else: if move_prev_id == 16'hFFFF then watch_head1[move_old_idx] <= watch_next1[move_clause_id]; else watch_next1[move_prev_id] <= watch_next1[move_clause_id]. watched_lit1[move_clause_id] <= move_new_w, watch_next1[move_clause_id] <= watch_head1[move_new_idx], watch_head1[move_new_idx] <= move_clause_id. If move_list_sel == 1 (watch2): same logic for watch2 arrays.

### Read (combinational)

rd_w1 = (rd_clause_id < MAX_CLAUSES) ? watched_lit1[rd_clause_id] : 16'hFFFF. rd_w2, rd_next1, rd_next2 analogous. rd_head1 = (rd_head_idx < 2*MAX_VARS) ? watch_head1[rd_head_idx] : 16'hFFFF. rd_head2 analogous.

## References

- [pse](pse.md)
- Two-watched-literal scheme (MiniSat)

