import re

file_path = "src/Mega/solver_core.sv"
with open(file_path, "r") as f:
    content = f.read()

# Match the logic block regardless of whitespace details
pattern = r'\} else if \(pse_started_q && \(conflict_seen_q \|\| pse_conflict\)\) begin\s+// Conflict detected and variables remain unassigned\s+// \$strobe\("\[CORE %0d\] Conflict detected in ACCUMULATE\. pse_started=%d seen=%d conflict=%d", CORE_ID, pse_started_q, conflict_seen_q, pse_conflict\);\s+state_d = CONFLICT_ANALYSIS;\s+query_index_d = 4\'d0;'

replacement = """} else if (pse_started_q && (conflict_seen_q || pse_conflict)) begin
                        // Conflict detected and variables remain unassigned
                        if (decision_level_q == 0) begin
                            state_d = FINISH_UNSAT;
                        end else begin
                            state_d = CONFLICT_ANALYSIS;
                            query_index_d = 4'd0;
                        end"""

new_content = re.sub(pattern, replacement, content)

if new_content != content:
    with open(file_path, "w") as f:
        f.write(new_content)
    print("Success")
else:
    print("Failed to find pattern")
