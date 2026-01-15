/**
 * resync_controller.sv
 *
 * The Resync Controller is responsible for re-synchronizing the internal state of the 
 * Propagate-Search Engine (PSE) and other shadow structures with the Trail Manager.
 *
 * This is typically triggered after a conflict and backtrack, where the PSE's internal
 * assignment state might have diverged or needs a fresh start.
 *
 * Operation:
 * 1. CLEAR: Flushes the propagation FIFO and clears shadow structures.
 * 2. REPLAY: Iterates through the Trail from index 0 to trail_height, 
 *    re-applying each assignment to the PSE and VDE.
 * 3. DONE: Signals completion to the solver core.
 */

module resync_controller (
    input  logic        clk,
    input  logic        rst_n,
    
    // Control Interface
    input  logic        start,          // Start the resync operation
    input  logic [15:0] trail_height,   // Current height of the trail to replay
    output logic        done,           // Asserted when replays is complete
    
    // Trail Manager Interface
    output logic [15:0] trail_rd_idx,   // Index of the trail entry to read
    input  logic [31:0] trail_rd_var,    // Variable index from trail
    input  logic        trail_rd_value,  // Assignment value (0/1) from trail
    
    // Action Outputs (to PSE, VDE, etc.)
    output logic        clear_shadows,  // Pulse to clear shadow data structures
    output logic        fifo_flush,     // Pulse to flush the propagation FIFO
    output logic        resync_valid,   // Pulse indicating a valid resync assignment
    output logic [31:0] resync_var,     // Resync variable index
    output logic        resync_value    // Resync assignment value
);

    // FSM States
    typedef enum logic [1:0] {
        IDLE,   // Wait for start signal
        CLEAR,  // Trigger flushes and reset index
        REPLAY, // Iterate through the trail
        DONE    // Finish and return to IDLE
    } state_e;

    state_e state_q, state_d;
    logic [15:0] idx_q, idx_d;

    // Combinatorial Trail Read
    assign trail_rd_idx = idx_q;
    assign resync_var   = trail_rd_var;
    assign resync_value = trail_rd_value;

    always_comb begin
        // Default assignments
        state_d = state_q;
        idx_d   = idx_q;
        done    = 1'b0;
        clear_shadows = 1'b0;
        fifo_flush    = 1'b0;
        resync_valid  = 1'b0;

        case (state_q)
            IDLE: begin
                if (start) begin
                    state_d = CLEAR;
                end
            end

            CLEAR: begin
                // Trigger global clear and flush signals
                clear_shadows = 1'b1;
                fifo_flush    = 1'b1;
                idx_d         = '0;
                state_d       = REPLAY;
            end

            REPLAY: begin
                // Replay the trail until height is reached
                if (idx_q < trail_height) begin
                    resync_valid = 1'b1; // Pulse for one cycle per assignment
                    idx_d        = idx_q + 1'b1;
                end else begin
                    state_d = DONE;
                end
            end

            DONE: begin
                // Signal completion to the Core FSM
                done    = 1'b1;
                state_d = IDLE;
            end
            
            default: state_d = IDLE;
        endcase
    end

    // State and Index Registers
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q <= IDLE;
            idx_q   <= '0;
        end else begin
            state_q <= state_d;
            idx_q   <= idx_d;
        end
    end

endmodule
