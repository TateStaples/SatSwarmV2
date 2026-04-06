import os

def fix_cae():
    file_path = "src/Mega/cae.sv"
    with open(file_path, "r") as f:
        content = f.read()
    
    # Early exit in IDLE for level 0
    old_idle = """                    if (trail_height > 0)
                        trail_scan_idx_d = trail_height - 1;
                    else
                        trail_scan_idx_d = 0;
                    state_d = INIT_CLAUSE;
                end
            end"""
    
    new_idle = """                    if (trail_height > 0)
                        trail_scan_idx_d = trail_height - 1;
                    else
                        trail_scan_idx_d = 0;
                    
                    if (decision_level == 0) begin
                        state_d = FINALIZE_EMIT;
                    end else begin
                        state_d = INIT_CLAUSE;
                    end
                end
            end"""
    
    content = content.replace(old_idle, new_idle)
    with open(file_path, "w") as f:
        f.write(content)

def fix_solver_core():
    file_path = "src/Mega/solver_core.sv"
    with open(file_path, "r") as f:
        content = f.read()
    
    # Handle level 0 conflict in PSE_PHASE exit
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
    
    content = content.replace(old_exit, new_exit)
    with open(file_path, "w") as f:
        f.write(content)

fix_cae()
fix_solver_core()
