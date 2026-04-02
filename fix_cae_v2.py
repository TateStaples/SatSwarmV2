import os

file_path = "src/Mega/cae.sv"
with open(file_path, "r") as f:
    content = f.read()

# 1. Update FINALIZE_SCAN logic to check decision_level > 0
old_scan = """                            if (!fin_found_uip_q && buf_levels[fin_scan_idx_q] == decision_level) begin
                                output_clause_d[0] = buf_lits[fin_scan_idx_q];
                                fin_found_uip_d = 1'b1;
                            end else if (!fin_found_sec_q && buf_levels[fin_scan_idx_q] == sec_max_level_q) begin"""

new_scan = """                            if (!fin_found_uip_q && buf_levels[fin_scan_idx_q] == decision_level) begin
                                output_clause_d[0] = buf_lits[fin_scan_idx_q];
                                fin_found_uip_d = 1'b1;
                            end else if (decision_level > 0 && !fin_found_sec_q && buf_levels[fin_scan_idx_q] == sec_max_level_q) begin"""

content = content.replace(old_scan, new_scan)

# 2. Restore unsat_d logic
content = content.replace(
    "                unsat_d = (valid_count_q == 0);\n",
    "                unsat_d = (valid_count_q == 0) || (decision_level == 0);\n"
)

# 3. Guard validation logic
old_val = """                // === CAE LEARNED CLAUSE VALIDATION ===
                begin"""

new_val = """                // === CAE LEARNED CLAUSE VALIDATION ===
                if (decision_level > 0) begin"""

content = content.replace(old_val, new_val)

with open(file_path, "w") as f:
    f.write(content)
