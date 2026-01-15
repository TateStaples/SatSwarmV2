module stats_manager (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        clear_stats,
    
    // Event Pulses
    input  logic        inc_cycle,
    input  logic        inc_conflict,
    input  logic        inc_decision,
    input  logic        inc_restart,
    input  logic        inc_learned,
    
    // Special Event: Level 0 Conflict
    input  logic        inc_level0_conflict,
    input  logic        clear_level0_conflicts,
    
    // Restart Control
    input  logic [15:0] restart_threshold,
    input  logic        clear_restart_counter,
    output logic        restart_pending,
    
    // Statistics Outputs
    output logic [31:0] total_cycles,
    output logic [31:0] total_conflicts,
    output logic [31:0] total_decisions,
    output logic [31:0] total_restarts,
    output logic [31:0] total_learned,
    output logic [15:0] conflict_counter,
    output logic [15:0] level0_conflict_count
);

    logic [31:0] total_cycles_q, total_cycles_d;
    logic [31:0] total_conflicts_q, total_conflicts_d;
    logic [31:0] total_decisions_q, total_decisions_d;
    logic [31:0] total_restarts_q, total_restarts_d;
    logic [31:0] total_learned_q, total_learned_d;
    logic [15:0] conflict_counter_q, conflict_counter_d;
    logic [15:0] level0_conflict_count_q, level0_conflict_count_d;

    assign total_cycles         = total_cycles_q;
    assign total_conflicts      = total_conflicts_q;
    assign total_decisions      = total_decisions_q;
    assign total_restarts       = total_restarts_q;
    assign total_learned        = total_learned_q;
    assign conflict_counter     = conflict_counter_q;
    assign level0_conflict_count = level0_conflict_count_q;
    
    assign restart_pending = (conflict_counter_q >= restart_threshold) && (restart_threshold != 0);

    always_comb begin
        total_cycles_d         = total_cycles_q;
        total_conflicts_d      = total_conflicts_q;
        total_decisions_d      = total_decisions_q;
        total_restarts_d       = total_restarts_q;
        total_learned_d        = total_learned_q;
        conflict_counter_d     = conflict_counter_q;
        level0_conflict_count_d = level0_conflict_count_q;

        if (clear_stats) begin
            total_cycles_d          = '0;
            total_conflicts_d       = '0;
            total_decisions_d       = '0;
            total_restarts_d        = '0;
            total_learned_d         = '0;
            conflict_counter_d      = '0;
            level0_conflict_count_d = '0;
        end else begin
            if (inc_cycle)    total_cycles_d    = total_cycles_q + 1'b1;
            if (inc_conflict) begin
                total_conflicts_d  = total_conflicts_q + 1'b1;
                conflict_counter_d = conflict_counter_q + 1'b1;
            end
            if (inc_decision) total_decisions_d = total_decisions_q + 1'b1;
            if (inc_restart)  total_restarts_d  = total_restarts_q + 1'b1;
            if (inc_learned)  total_learned_d   = total_learned_q + 1'b1;
            
            if (inc_level0_conflict)    level0_conflict_count_d = level0_conflict_count_q + 1'b1;
            if (clear_level0_conflicts) level0_conflict_count_d = '0;
            if (clear_restart_counter)  conflict_counter_d      = '0;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            total_cycles_q          <= '0;
            total_conflicts_q       <= '0;
            total_decisions_q       <= '0;
            total_restarts_q        <= '0;
            total_learned_q         <= '0;
            conflict_counter_q      <= '0;
            level0_conflict_count_q <= '0;
        end else begin
            total_cycles_q          <= total_cycles_d;
            total_conflicts_q       <= total_conflicts_d;
            total_decisions_q       <= total_decisions_d;
            total_restarts_q        <= total_restarts_d;
            total_learned_q         <= total_learned_d;
            conflict_counter_q      <= conflict_counter_d;
            level0_conflict_count_q <= level0_conflict_count_d;
        end
    end

endmodule
