import re

with open('/home/ubuntu/src/project_data/SatSwarmV2/src/Mega/solver_core.sv', 'r') as f:
    text = f.read()

# 1. Add BACKTRACK_UNDO to enum
old_enum = """        BUMP_LEARNED_VARS,      // NEW: Bump activity for all variables in learned clause
        // INVARIANT: Learned clauses are appended to the clause database and immediately used for Resync.
        APPEND_LEARNED,
        APPEND_PUSH,            // NEW: Stable push state to decouple calculation from trail updates
        BACKTRACK_PHASE,
        RESYNC_PSE,"""
new_enum = """        BUMP_LEARNED_VARS,      // NEW: Bump activity for all variables in learned clause
        // INVARIANT: Learned clauses are appended to the clause database and immediately used for Resync.
        APPEND_LEARNED,
        APPEND_PUSH,            // NEW: Stable push state to decouple calculation from trail updates
        BACKTRACK_PHASE,
        BACKTRACK_UNDO,         // NEW: Wait for incremental unassign
        RESYNC_PSE,"""
text = text.replace(old_enum, new_enum)

# 2. Update defaults for vde_clear_valid and pse_clear_valid
old_defaults = """        vde_bump_valid    = 1'b0;
        vde_bump_var      = '0;
        vde_bump_count    = '0;
        for (int k = 0; k < 16; k++) begin
            vde_bump_vars[k] = '0;
        end
        vde_decay         = 1'b0;
        vde_unassign_all  = 1'b0; // Default low
        pse_clear_assignments = 1'b0;"""

new_defaults = """        vde_bump_valid    = 1'b0;
        vde_bump_var      = '0;
        vde_bump_count    = '0;
        for (int k = 0; k < 16; k++) begin
            vde_bump_vars[k] = '0;
        end
        vde_decay         = 1'b0;
        vde_clear_valid   = trail_backtrack_valid;
        vde_clear_var     = trail_backtrack_valid ? trail_backtrack_var : 32'd0;
        vde_unassign_all  = 1'b0; // Default low
        pse_clear_valid   = trail_backtrack_valid;
        pse_clear_var     = trail_backtrack_valid ? trail_backtrack_var : 32'd0;
        pse_clear_assignments = resync_clear_shadows;"""
text = text.replace(old_defaults, new_defaults)

# 3. Update BACKTRACK_PHASE logic
old_backtrack = """                        // INSTANT BACKTRACK
                        decision_level_d = cae_backtrack_level;
                        trail_truncate_en = 1'b1;
                        trail_truncate_level = cae_backtrack_level;
                        vde_unassign_all = 1'b1;
                        pse_clear_assignments = 1'b1;

                        // Replay
                        resync_started_d = 1'b0;
                        resync_idx_d     = 32'd0;
                        learn_idx_d      = 4'd0; // CRITICAL FIX: Reset learned clause index
                        rescan_required_d = 1'b0;
                        resync_append_learned_d = 1'b1;
                        state_d          = RESYNC_PSE;
                    end
                end
            end"""

new_backtrack = """                        // START ITERATIVE BACKTRACK
                        decision_level_d = cae_backtrack_level;
                        trail_backtrack_en = 1'b1;
                        trail_truncate_level = cae_backtrack_level;
                        
                        // We rely on trail_backtrack_valid combinational output
                        // to drive pse_clear_valid and vde_clear_valid incrementally.
                        state_d          = BACKTRACK_UNDO;
                    end
                end
            end

            BACKTRACK_UNDO: begin
                // Keep backtrack_en high so trail manager iterates
                trail_backtrack_en = 1'b1;
                
                if (trail_backtrack_done) begin
                    learn_idx_d      = 4'd0;
                    state_d          = APPEND_LEARNED;
                end else begin
                    state_d          = BACKTRACK_UNDO;
                end
            end"""
text = text.replace(old_backtrack, new_backtrack)

with open('/home/ubuntu/src/project_data/SatSwarmV2/src/Mega/solver_core.sv', 'w') as f:
    f.write(text)

print("Replacement script complete")
