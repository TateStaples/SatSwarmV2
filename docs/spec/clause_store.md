# clause_store — Clause Metadata and Literal Storage

**Source:** [src/Mega/clause_store.sv](../../src/Mega/clause_store.sv)

## Overview

The clause store holds clause metadata (length, start index) and the literal memory. It provides write (for loading) and read (for scanning) interfaces. Used by PSE for local clause storage.

**Note:** The solver_core uses PSE's internal clause store (PSE embeds clause_len, clause_start, lit_mem). The standalone `clause_store` module exists for potential reuse; the build uses PSE's internal arrays.

## Parameters

| Parameter | Default | Description |
|-----------|---------|--------------|
| `MAX_CLAUSES` | 256 | Max clauses |
| `MAX_LITS` | 4096 | Max literals |

## Interface

### Write (for loading)

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `wr_en` | input | `logic` | Write enable |
| `wr_clause_id` | input | `logic [15:0]` | Clause ID |
| `wr_lit_count` | input | `logic [15:0]` | Literal count |
| `wr_clause_start` | input | `logic [15:0]` | Clause start index |
| `wr_clause_len` | input | `logic [15:0]` | Clause length |
| `wr_lit_addr` | input | `logic [15:0]` | Literal address |
| `wr_literal` | input | `logic signed [31:0]` | Literal value |

### Read

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `rd_clause_id` | input | `logic [15:0]` | Clause ID |
| `rd_lit_idx` | input | `logic [3:0]` | Literal index within clause |
| `rd_literal` | output | `logic signed [31:0]` | Literal value |
| `rd_clause_len` | output | `logic [15:0]` | Clause length |
| `rd_clause_start` | output | `logic [15:0]` | Clause start index |

### Direct Memory Access

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `mem_addr` | input | `logic [15:0]` | Direct address |
| `mem_literal` | output | `logic signed [31:0]` | Literal at address |

## Internal Structure

### Arrays

- `clause_len[0:MAX_CLAUSES-1]` — Per-clause length
- `clause_start[0:MAX_CLAUSES-1]` — Per-clause start index in lit_mem
- `lit_mem[0:MAX_LITS-1]` — Literal storage

### Read Logic

- `rd_literal` = lit_mem[rd_clause_start + rd_lit_idx] when in bounds
- `mem_literal` = lit_mem[mem_addr]

## Behavior (RTL Specification)

### Write (synchronous)
When wr_en on posedge clk: if wr_clause_id < MAX_CLAUSES: clause_len[wr_clause_id] <= wr_clause_len, clause_start[wr_clause_id] <= wr_clause_start. if wr_lit_addr < MAX_LITS: lit_mem[wr_lit_addr] <= wr_literal.

### Read (combinational)
rd_clause_len = (rd_clause_id < MAX_CLAUSES) ? clause_len[rd_clause_id] : 0. rd_clause_start = (rd_clause_id < MAX_CLAUSES) ? clause_start[rd_clause_id] : 0. abs_lit_addr = rd_clause_start + rd_lit_idx. rd_literal = (rd_clause_id < MAX_CLAUSES && rd_lit_idx < rd_clause_len && abs_lit_addr < MAX_LITS) ? lit_mem[abs_lit_addr] : 0.

### Direct memory
mem_literal = (mem_addr < MAX_LITS) ? lit_mem[mem_addr] : 0.

## References

- [pse](pse.md) — PSE embeds similar clause storage internally
