// Variable Decision Engine (VDE)
// Implements a lightweight VSIDS-like selector with activity scores and
// phase saving. Decisions are made on request and returned once the scan
// across all variables completes.
module vde #(
    parameter int MAX_VARS = 256,
    parameter int ACT_W    = 32
)(
    input  logic         clk,
    input  logic         reset,

    // Decision request
    input  logic         request,
    output logic         decision_valid,
    output logic [31:0]  decision_var,
    output logic         decision_phase,
    input  logic [3:0]   phase_offset,
    output logic         all_assigned,
    input  logic [31:0]  max_var,
    input  logic         clear_all,

    // Assignment bookkeeping
    input  logic         assign_valid,
    input  logic [31:0]  assign_var,
    input  logic         assign_value,
    input  logic         clear_valid,
    input  logic [31:0]  clear_var,

    // Activity updates
    input  logic         bump_valid,
    input  logic [31:0]  bump_var,
    
    // Multi-bump for learned clause (up to 8 vars)
    input  logic [3:0]   bump_count,          // How many vars to bump (0-8)
    input  logic [7:0][31:0] bump_vars,     // Variables to bump
    input  logic         decay
);

    typedef enum logic [1:0] {IDLE, SCAN, ISSUE} state_e;

    state_e state_q, state_d;

    logic [ACT_W-1:0] activity [0:MAX_VARS-1];
    logic             assigned [0:MAX_VARS-1];
    logic             phase_hint [0:MAX_VARS-1];

    logic [ACT_W-1:0] best_act_q, best_act_d;
    logic [15:0]      best_idx_q, best_idx_d;
    logic [15:0]      scan_idx_q, scan_idx_d;

    integer i;

    // Combinational state machine
    always_comb begin
        state_d         = state_q;
        best_act_d      = best_act_q;
        best_idx_d      = best_idx_q;
        scan_idx_d      = scan_idx_q;
        decision_valid  = 1'b0;
        decision_var    = '0;
        decision_phase  = 1'b0;
        all_assigned    = 1'b0;

        case (state_q)
            IDLE: begin
                best_act_d = '0;  // Zero for finding maximum activity
                best_idx_d = 16'hFFFF;
                scan_idx_d = '0;
                if (request)
                    state_d = SCAN;
            end

            SCAN: begin
                if (scan_idx_q < max_var) begin
                    // Activity-based selection: pick unassigned variable with HIGHEST activity (VSIDS)
                    // Confluent scan: always examine all candidates; tie-break on lowest index
                    if (!assigned[scan_idx_q]) begin
                        if (activity[scan_idx_q] > best_act_q ||
                            (activity[scan_idx_q] == best_act_q && scan_idx_q < best_idx_q) ||
                            best_idx_q == 16'hFFFF) begin
                            best_act_d = activity[scan_idx_q];
                            best_idx_d = scan_idx_q;
                        end
                    end
                    scan_idx_d = scan_idx_q + 1'b1;
                end else begin
                    state_d = ISSUE;
                end
            end

            ISSUE: begin
                if (best_idx_q != 16'hFFFF) begin
                    decision_valid = 1'b1;
                    decision_var   = best_idx_q + 1;
                    decision_phase = phase_hint[best_idx_q] ^ phase_offset[0];
                end else begin
                    all_assigned = 1'b1;
                end
                if (!request)
                    state_d = IDLE;
            end

            default: state_d = IDLE;
        endcase
    end

    // Sequential updates
    always_ff @(posedge clk or posedge reset) begin
        if (reset || clear_all) begin
            state_q    <= IDLE;
            best_act_q <= '0;
            best_idx_q <= 16'hFFFF;
            scan_idx_q <= '0;
            for (i = 0; i < MAX_VARS; i = i + 1) begin
                // Phase 5: Advanced Swarm Divergence
                // Initialize activity with pseudo-random noise seeded by phase_offset (Core ID)
                // This forces each core to pick a different starting variable.
                // Formula: LCG-style hash
                activity[i]   <= ((i + 1) * (phase_offset + 1) * 32'd1103515245 + 32'd12345) & 32'h0000_FFFF;
                assigned[i]   <= 1'b0;
                phase_hint[i] <= 1'b0; // default to negative phase (False) for initial decisions
            end
        end else begin
            state_q    <= state_d;
            best_act_q <= best_act_d;
            best_idx_q <= best_idx_d;
            scan_idx_q <= scan_idx_d;

            // Assignment updates
            if (assign_valid && assign_var != 0 && assign_var <= MAX_VARS) begin
                assigned[assign_var-1]   <= 1'b1;
                phase_hint[assign_var-1] <= assign_value;
            end
            if (clear_valid && clear_var != 0 && clear_var <= MAX_VARS) begin
                assigned[clear_var-1] <= 1'b0;
            end

            // Activity bump - large increment to ensure recent conflicts dominate selection
            // Bump must be >> decay rate (1/16 per decay) to drive exploration
            if (bump_valid && bump_var != 0 && bump_var <= MAX_VARS) begin
                activity[bump_var-1] <= activity[bump_var-1] + 32'd10000;
            end
            
            // Multi-bump: bump all variables in learned clause simultaneously
            if (bump_count > 0) begin
                for (int i = 0; i < 8; i++) begin
                    if (i < bump_count && bump_vars[i] != 0 && bump_vars[i] <= MAX_VARS) begin
                        activity[bump_vars[i]-1] <= activity[bump_vars[i]-1] + 32'd10000;
                    end
                end
            end

            // Decay all activities when requested
            if (decay) begin
                for (i = 0; i < MAX_VARS; i = i + 1)
                    activity[i] <= activity[i] - (activity[i] >> 4);
            end
        end
    end

endmodule
