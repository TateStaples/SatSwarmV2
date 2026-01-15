module watch_manager #(
    parameter int MAX_VARS = 256,
    parameter int MAX_CLAUSES = 256
)(
    input  logic               clk,
    input  logic               rst_n,

    // Control
    input  logic               clear_all,     // Clear all lists and watches
    input  logic [15:0]        clear_idx,     // Index for clearing in steps if needed (or just use clear_all)

    // Linking interface (for INIT_WATCHES or LOAD_CLAUSE)
    input  logic               link_en,
    input  logic [15:0]        link_clause_id,
    input  logic [15:0]        link_w1,       // literal index in mem
    input  logic [15:0]        link_w2,
    input  logic [15:0]        link_idx1,     // safe_lit_idx output
    input  logic [15:0]        link_idx2,

    // Move/Update interface (for SCAN_WATCH)
    input  logic               move_en,
    input  logic [15:0]        move_clause_id,
    input  logic               move_list_sel, // 0 -> move watch1, 1 -> move watch2
    input  logic [15:0]        move_new_w,    // new literal index in mem
    input  logic [15:0]        move_old_idx,  // old safe_lit_idx
    input  logic [15:0]        move_new_idx,  // new safe_lit_idx
    input  logic [15:0]        move_prev_id,  // previous clause in list (for unlinking)

    // Direct access for SCAN_WATCH traversal
    input  logic [15:0]        rd_clause_id,
    output logic [15:0]        rd_w1,
    output logic [15:0]        rd_w2,
    output logic [15:0]        rd_next1,
    output logic [15:0]        rd_next2,

    input  logic [15:0]        rd_head_idx,
    output logic [15:0]        rd_head1,
    output logic [15:0]        rd_head2
);

    // Watched-literal structures
    logic [15:0] watched_lit1 [0:MAX_CLAUSES-1];
    logic [15:0] watched_lit2 [0:MAX_CLAUSES-1];
    logic [15:0] watch_head1  [0:(2*MAX_VARS-1)];
    logic [15:0] watch_head2  [0:(2*MAX_VARS-1)];
    logic [15:0] watch_next1  [0:MAX_CLAUSES-1];
    logic [15:0] watch_next2  [0:MAX_CLAUSES-1];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Initialization handled by clear_all logic usually
        end else if (clear_all) begin
            if (clear_idx < MAX_CLAUSES) begin
                watch_next1[clear_idx] <= 16'hFFFF;
                watch_next2[clear_idx] <= 16'hFFFF;
            end
            if (clear_idx < 2*MAX_VARS) begin
                watch_head1[clear_idx] <= 16'hFFFF;
                watch_head2[clear_idx] <= 16'hFFFF;
            end
        end else if (link_en) begin
            watched_lit1[link_clause_id] <= link_w1;
            watched_lit2[link_clause_id] <= link_w2;
            
            watch_next1[link_clause_id] <= watch_head1[link_idx1];
            watch_head1[link_idx1]      <= link_clause_id;
            
            watch_next2[link_clause_id] <= watch_head2[link_idx2];
            watch_head2[link_idx2]      <= link_clause_id;
        end else if (move_en) begin
            if (move_list_sel == 1'b0) begin
                // Move watch1
                if (move_old_idx == move_new_idx) begin
                    watched_lit1[move_clause_id] <= move_new_w;
                    // next remains same, skip head update
                end else begin
                    // Unlink from old list
                    if (move_prev_id == 16'hFFFF)
                        watch_head1[move_old_idx] <= watch_next1[move_clause_id];
                    else
                        watch_next1[move_prev_id] <= watch_next1[move_clause_id];
                    
                    // Link to new list
                    watched_lit1[move_clause_id] <= move_new_w;
                    watch_next1[move_clause_id]  <= watch_head1[move_new_idx];
                    watch_head1[move_new_idx]    <= move_clause_id;
                end
            end else begin
                // Move watch2
                if (move_old_idx == move_new_idx) begin
                    watched_lit2[move_clause_id] <= move_new_w;
                end else begin
                    if (move_prev_id == 16'hFFFF)
                        watch_head2[move_old_idx] <= watch_next2[move_clause_id];
                    else
                        watch_next2[move_prev_id] <= watch_next2[move_clause_id];
                        
                    watched_lit2[move_clause_id] <= move_new_w;
                    watch_next2[move_clause_id]  <= watch_head2[move_new_idx];
                    watch_head2[move_new_idx]    <= move_clause_id;
                end
            end
        end
    end

    // Reads
    assign rd_w1 = (rd_clause_id < MAX_CLAUSES) ? watched_lit1[rd_clause_id] : 16'hFFFF;
    assign rd_w2 = (rd_clause_id < MAX_CLAUSES) ? watched_lit2[rd_clause_id] : 16'hFFFF;
    assign rd_next1 = (rd_clause_id < MAX_CLAUSES) ? watch_next1[rd_clause_id] : 16'hFFFF;
    assign rd_next2 = (rd_clause_id < MAX_CLAUSES) ? watch_next2[rd_clause_id] : 16'hFFFF;

    assign rd_head1 = (rd_head_idx < 2*MAX_VARS) ? watch_head1[rd_head_idx] : 16'hFFFF;
    assign rd_head2 = (rd_head_idx < 2*MAX_VARS) ? watch_head2[rd_head_idx] : 16'hFFFF;

endmodule
