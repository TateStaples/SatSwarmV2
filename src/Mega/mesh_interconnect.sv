// Simple 2D Mesh Interconnect: Dimension-order (X-Y) routing
// For a 2x2 or larger grid, routes packets between neighboring cores.
module mesh_interconnect #(
    parameter int GRID_X = 2,
    parameter int GRID_Y = 2
)(
    input  logic clk,
    input  logic rst_n,

    // Ports indexed as [Y][X][port] where port: [3]=N, [2]=S, [1]=E, [0]=W
    input  satswarmv2_pkg::noc_packet_t core_tx [0:GRID_Y-1][0:GRID_X-1][3:0],
    input  logic core_tx_valid [0:GRID_Y-1][0:GRID_X-1][3:0],
    output logic core_tx_ready [0:GRID_Y-1][0:GRID_X-1][3:0],

    output satswarmv2_pkg::noc_packet_t core_rx [0:GRID_Y-1][0:GRID_X-1][3:0],
    output logic core_rx_valid [0:GRID_Y-1][0:GRID_X-1][3:0],
    input  logic core_rx_ready [0:GRID_Y-1][0:GRID_X-1][3:0]
);

    // Simplified pass-through: no pipelining, direct peer-to-peer
    // In real hardware, this would be a full mesh router.
    
    genvar y, x, i;
    generate
        for (y = 0; y < GRID_Y; y = y + 1) begin
            for (x = 0; x < GRID_X; x = x + 1) begin
                always_comb begin
                    integer ii;
                    // Default: no rx
                    for (ii = 0; ii < 4; ii = ii + 1) begin
                        core_rx_valid[y][x][ii] = 1'b0;
                        core_tx_ready[y][x][ii] = 1'b0;
                        core_rx[y][x][ii].msg_type = satswarmv2_pkg::MSG_STATUS;
                        core_rx[y][x][ii].payload = '0;
                        core_rx[y][x][ii].quality_metric = '0;
                        core_rx[y][x][ii].src_id = '0;
                        core_rx[y][x][ii].virtual_channel = '0;
                    end

                    // Route North neighbor's North output to this core's South input
                    if (y > 0 && core_tx_valid[y-1][x][3]) begin
                        core_rx_valid[y][x][2] = 1'b1;  // South port receives
                        core_rx[y][x][2] = core_tx[y-1][x][3];
                        core_tx_ready[y-1][x][3] = core_rx_ready[y][x][2];
                    end
                    
                    // Route South neighbor's South output to this core's North input
                    if (y < GRID_Y-1 && core_tx_valid[y+1][x][2]) begin
                        core_rx_valid[y][x][3] = 1'b1;  // North port receives
                        core_rx[y][x][3] = core_tx[y+1][x][2];
                        core_tx_ready[y+1][x][2] = core_rx_ready[y][x][3];
                    end
                    
                    // Route East neighbor's East output to this core's West input
                    if (x < GRID_X-1 && core_tx_valid[y][x+1][1]) begin
                        core_rx_valid[y][x][0] = 1'b1;  // West port receives
                        core_rx[y][x][0] = core_tx[y][x+1][1];
                        core_tx_ready[y][x+1][1] = core_rx_ready[y][x][0];
                    end
                    
                    // Route West neighbor's West output to this core's East input
                    if (x > 0 && core_tx_valid[y][x-1][0]) begin
                        core_rx_valid[y][x][1] = 1'b1;  // East port receives
                        core_rx[y][x][1] = core_tx[y][x-1][0];
                        core_tx_ready[y][x-1][0] = core_rx_ready[y][x][1];
                    end
                end
            end
        end
    endgenerate

endmodule
