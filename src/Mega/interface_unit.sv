// Interface Unit: NoC Packet Handler
// Manages incoming/outgoing packets, handles divergence force handshake.
module interface_unit #(
    parameter int CORE_ID = 0,
    parameter int CORE_ID_W = satswarmv2_pkg::CORE_ID_W
)(
    input  logic clk,
    input  logic rst_n,

    // Incoming packets from neighbors (4 directions: N, S, E, W)
    input  satswarmv2_pkg::noc_packet_t rx_pkt_n,
    input  satswarmv2_pkg::noc_packet_t rx_pkt_s,
    input  satswarmv2_pkg::noc_packet_t rx_pkt_e,
    input  satswarmv2_pkg::noc_packet_t rx_pkt_w,
    input  logic rx_valid_n, rx_valid_s, rx_valid_e, rx_valid_w,
    output logic rx_ready_n, rx_ready_s, rx_ready_e, rx_ready_w,

    // Outgoing packets to neighbors
    output satswarmv2_pkg::noc_packet_t tx_pkt_n,
    output satswarmv2_pkg::noc_packet_t tx_pkt_s,
    output satswarmv2_pkg::noc_packet_t tx_pkt_e,
    output satswarmv2_pkg::noc_packet_t tx_pkt_w,
    output logic tx_valid_n, tx_valid_s, tx_valid_e, tx_valid_w,
    input  logic tx_ready_n, tx_ready_s, tx_ready_e, tx_ready_w,

    // Core interface: Divergence requests
    input  logic        diverge_req,      // Core wants to force neighbor
    input  logic [3:0]  diverge_target,   // Bitmask: [3]=N, [2]=S, [1]=E, [0]=W
    input  logic signed [31:0] diverge_lit, // Literal to force
    output logic        diverge_ack,      // Acknowledged by neighbor

    // Core interface: Incoming divergence force
    output logic        force_valid,
    output logic signed [31:0] force_lit,
    input  logic        force_ready,

    // Core interface: Clause broadcasts
    input  logic        clause_bcast_req,
    input  logic [7:0]  clause_lbd,
    input  logic [63:0] clause_ptr,
    output logic        clause_bcast_ack,

    // Core interface: Incoming clause
    output logic        clause_rx_valid,
    output logic [7:0]  clause_rx_lbd,
    output logic [63:0] clause_rx_ptr,
    input  logic        clause_rx_ready
);

    // Internal FIFOs for each message type
    // Simplified: queue one message per direction per cycle
    
    logic [3:0] neighbor_status; // [3]=N, [2]=S, [1]=E, [0]=W present
    always_comb begin
        neighbor_status[3] = rx_valid_n;
        neighbor_status[2] = rx_valid_s;
        neighbor_status[1] = rx_valid_e;
        neighbor_status[0] = rx_valid_w;
    end

    // Route incoming packets to appropriate handlers
    logic diverge_rx_valid;
    logic signed [31:0] diverge_rx_lit;
    logic clause_rx_fifo_valid;
    logic [7:0] clause_rx_fifo_lbd;
    logic [63:0] clause_rx_fifo_ptr;

    // Packet muxing and routing
    always_comb begin
        // Default: no ready
        rx_ready_n = 1'b0; rx_ready_s = 1'b0; rx_ready_e = 1'b0; rx_ready_w = 1'b0;
        diverge_rx_valid = 1'b0; diverge_rx_lit = '0;
        clause_rx_fifo_valid = 1'b0; clause_rx_fifo_lbd = '0; clause_rx_fifo_ptr = '0;

        // Priority 1: Divergence
        if (rx_valid_n && rx_pkt_n.msg_type == satswarmv2_pkg::MSG_DIVERGE) begin
            diverge_rx_valid = 1'b1; diverge_rx_lit = rx_pkt_n.payload[31:0]; rx_ready_n = 1'b1;
        end else if (rx_valid_s && rx_pkt_s.msg_type == satswarmv2_pkg::MSG_DIVERGE) begin
            diverge_rx_valid = 1'b1; diverge_rx_lit = rx_pkt_s.payload[31:0]; rx_ready_s = 1'b1;
        end else if (rx_valid_e && rx_pkt_e.msg_type == satswarmv2_pkg::MSG_DIVERGE) begin
            diverge_rx_valid = 1'b1; diverge_rx_lit = rx_pkt_e.payload[31:0]; rx_ready_e = 1'b1;
        end else if (rx_valid_w && rx_pkt_w.msg_type == satswarmv2_pkg::MSG_DIVERGE) begin
            diverge_rx_valid = 1'b1; diverge_rx_lit = rx_pkt_w.payload[31:0]; rx_ready_w = 1'b1;
        // Priority 2: Clauses
        end else if (rx_valid_n && rx_pkt_n.msg_type == satswarmv2_pkg::MSG_CLAUSE) begin
            clause_rx_fifo_valid = 1'b1; clause_rx_fifo_lbd = rx_pkt_n.quality_metric; clause_rx_fifo_ptr = rx_pkt_n.payload; rx_ready_n = 1'b1;
        end else if (rx_valid_s && rx_pkt_s.msg_type == satswarmv2_pkg::MSG_CLAUSE) begin
            clause_rx_fifo_valid = 1'b1; clause_rx_fifo_lbd = rx_pkt_s.quality_metric; clause_rx_fifo_ptr = rx_pkt_s.payload; rx_ready_s = 1'b1;
        end else if (rx_valid_e && rx_pkt_e.msg_type == satswarmv2_pkg::MSG_CLAUSE) begin
            clause_rx_fifo_valid = 1'b1; clause_rx_fifo_lbd = rx_pkt_e.quality_metric; clause_rx_fifo_ptr = rx_pkt_e.payload; rx_ready_e = 1'b1;
        end else if (rx_valid_w && rx_pkt_w.msg_type == satswarmv2_pkg::MSG_CLAUSE) begin
            clause_rx_fifo_valid = 1'b1; clause_rx_fifo_lbd = rx_pkt_w.quality_metric; clause_rx_fifo_ptr = rx_pkt_w.payload; rx_ready_w = 1'b1;
        end
    end

    assign force_valid = diverge_rx_valid;
    assign force_lit = diverge_rx_lit;
    assign clause_rx_valid = clause_rx_fifo_valid;
    assign clause_rx_lbd = clause_rx_fifo_lbd;
    assign clause_rx_ptr = clause_rx_fifo_ptr;

    // Outgoing packet construction
    always_comb begin
        tx_valid_n = 1'b0; tx_valid_s = 1'b0; tx_valid_e = 1'b0; tx_valid_w = 1'b0;
        tx_pkt_n = '0; tx_pkt_s = '0; tx_pkt_e = '0; tx_pkt_w = '0;

        if (diverge_req) begin
            if (diverge_target[3]) begin tx_valid_n = 1'b1; tx_pkt_n.msg_type = satswarmv2_pkg::MSG_DIVERGE; tx_pkt_n.payload = {32'd0, diverge_lit}; tx_pkt_n.src_id = CORE_ID[CORE_ID_W-1:0]; end
            if (diverge_target[2]) begin tx_valid_s = 1'b1; tx_pkt_s.msg_type = satswarmv2_pkg::MSG_DIVERGE; tx_pkt_s.payload = {32'd0, diverge_lit}; tx_pkt_s.src_id = CORE_ID[CORE_ID_W-1:0]; end
            if (diverge_target[1]) begin tx_valid_e = 1'b1; tx_pkt_e.msg_type = satswarmv2_pkg::MSG_DIVERGE; tx_pkt_e.payload = {32'd0, diverge_lit}; tx_pkt_e.src_id = CORE_ID[CORE_ID_W-1:0]; end
            if (diverge_target[0]) begin tx_valid_w = 1'b1; tx_pkt_w.msg_type = satswarmv2_pkg::MSG_DIVERGE; tx_pkt_w.payload = {32'd0, diverge_lit}; tx_pkt_w.src_id = CORE_ID[CORE_ID_W-1:0]; end
        end else if (clause_bcast_req) begin
            tx_valid_n = 1'b1; tx_pkt_n.msg_type = satswarmv2_pkg::MSG_CLAUSE; tx_pkt_n.payload = clause_ptr; tx_pkt_n.quality_metric = clause_lbd; tx_pkt_n.src_id = CORE_ID[CORE_ID_W-1:0];
            tx_valid_s = 1'b1; tx_pkt_s.msg_type = satswarmv2_pkg::MSG_CLAUSE; tx_pkt_s.payload = clause_ptr; tx_pkt_s.quality_metric = clause_lbd; tx_pkt_s.src_id = CORE_ID[CORE_ID_W-1:0];
            tx_valid_e = 1'b1; tx_pkt_e.msg_type = satswarmv2_pkg::MSG_CLAUSE; tx_pkt_e.payload = clause_ptr; tx_pkt_e.quality_metric = clause_lbd; tx_pkt_e.src_id = CORE_ID[CORE_ID_W-1:0];
            tx_valid_w = 1'b1; tx_pkt_w.msg_type = satswarmv2_pkg::MSG_CLAUSE; tx_pkt_w.payload = clause_ptr; tx_pkt_w.quality_metric = clause_lbd; tx_pkt_w.src_id = CORE_ID[CORE_ID_W-1:0];
        end
    end

    // Acknowledgment logic (simplified: ack when all targets ready)
    assign diverge_ack = diverge_req && 
                         (!diverge_target[3] || tx_ready_n) &&
                         (!diverge_target[2] || tx_ready_s) &&
                         (!diverge_target[1] || tx_ready_e) &&
                         (!diverge_target[0] || tx_ready_w);

    assign clause_bcast_ack = clause_bcast_req && 
                              tx_ready_n && tx_ready_s && tx_ready_e && tx_ready_w;

endmodule
