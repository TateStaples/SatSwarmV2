import os

file_path = "src/Mega/cae.sv"
with open(file_path, "r") as f:
    content = f.read()

# 1. Declarations
content = content.replace(
    "    logic                   fin_found_uip_q, fin_found_uip_d;\n",
    "    logic                   fin_found_uip_q, fin_found_uip_d;\n    logic                   fin_found_sec_q, fin_found_sec_d;\n"
)

# 2. Comb defaults
content = content.replace(
    "        fin_found_uip_d  = fin_found_uip_q;\n",
    "        fin_found_uip_d  = fin_found_uip_q;\n        fin_found_sec_d  = fin_found_sec_q;\n"
)

# 3. INIT_CLAUSE zeroing
content = content.replace(
    "                        fin_found_uip_d = 1'b0;\n                        fin_out_idx_d   = 1;\n                        for (int k = 0; k < MAX_LITS; k++) output_clause_d[k] = 0;\n                        state_d = FINALIZE_SCAN;\n",
    "                        fin_found_uip_d = 1'b0;\n                        fin_found_sec_d = 1'b0;\n                        fin_out_idx_d   = 1;\n                        for (int k = 0; k < MAX_LITS; k++) output_clause_d[k] = 0;\n                        state_d = FINALIZE_SCAN;\n"
)

# 4. FINALIZE_SCAN logic
old_finalize = """                            if (!fin_found_uip_q && buf_levels[fin_scan_idx_q] == decision_level) begin
                                output_clause_d[0] = buf_lits[fin_scan_idx_q];
                                fin_found_uip_d = 1'b1;
                            end else begin
                                if (fin_out_idx_q < MAX_LITS) begin
                                    output_clause_d[fin_out_idx_q] = buf_lits[fin_scan_idx_q];
                                    fin_out_idx_d = fin_out_idx_q + 1;
                                end
                            end"""

new_finalize = """                            if (!fin_found_uip_q && buf_levels[fin_scan_idx_q] == decision_level) begin
                                output_clause_d[0] = buf_lits[fin_scan_idx_q];
                                fin_found_uip_d = 1'b1;
                            end else if (!fin_found_sec_q && buf_levels[fin_scan_idx_q] == sec_max_level_q) begin
                                if (fin_out_idx_q > 1) begin
                                    output_clause_d[fin_out_idx_q] = output_clause_d[1];
                                    output_clause_d[1] = buf_lits[fin_scan_idx_q];
                                    fin_out_idx_d = fin_out_idx_q + 1;
                                end else begin
                                    output_clause_d[1] = buf_lits[fin_scan_idx_q];
                                    fin_out_idx_d = fin_out_idx_q + 1;
                                end
                                fin_found_sec_d = 1'b1;
                            end else begin
                                if (fin_out_idx_q < MAX_LITS) begin
                                    output_clause_d[fin_out_idx_q] = buf_lits[fin_scan_idx_q];
                                    fin_out_idx_d = fin_out_idx_q + 1;
                                end
                            end"""

content = content.replace(old_finalize, new_finalize)

# 5. FF resets
content = content.replace(
    "            fin_found_uip_q <= 0;\n",
    "            fin_found_uip_q <= 0;\n            fin_found_sec_q <= 0;\n"
)

# 6. FF updates
content = content.replace(
    "            fin_found_uip_q <= fin_found_uip_d;\n",
    "            fin_found_uip_q <= fin_found_uip_d;\n            fin_found_sec_q <= fin_found_sec_d;\n"
)

with open(file_path, "w") as f:
    f.write(content)
