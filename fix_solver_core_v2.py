import os

file_path = "src/Mega/solver_core.sv"
with open(file_path, "r") as f:
    content = f.read()

old_exit = """                    } else if (pse_started_q && (conflict_seen_q || pse_conflict)) begin
                        // Conflict detected and variables remain unassigned
                        // $strobe("[CORE %0d] Conflict detected in ACCUMULATE. pse_started=%d seen=%d conflict=%d", CORE_ID, pse_started_q, conflict_seen_q, pse_conflict);
                        state_d = CONFLICT_ANALYSIS;
                        query_index_d = 4'd0;"""

new_exit = """                    } else if (pse_started_q && (conflict_seen_q || pse_conflict)) begin
                        // Conflict detected and variables remain unassigned
                        if (decision_level_q == 0) begin
                            state_d = FINISH_UNSAT;
                        end else begin
                            state_d = CONFLICT_ANALYSIS;
                            query_index_d = 4'd0;
                        end"""

if old_exit in content:
    content = content.replace(old_exit, new_exit)
    with open(file_path, "w") as f:
        f.write(content)
    print("Success")
else:
    print("Failed to find pattern")
