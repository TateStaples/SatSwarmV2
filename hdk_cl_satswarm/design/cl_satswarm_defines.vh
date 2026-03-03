`ifndef CL_SATSWARM_DEFINES
`define CL_SATSWARM_DEFINES

  //Put module name of the CL design here.
  `define CL_NAME cl_satswarm

  //Less async reset for lib FIFO blocks.
  `define FPGA_LESS_RST

  //Enable SDA interface
  `define SH_SDA

  //Make SH and CL operate on separate (async) clock domains
  `define SH_CL_ASYNC

  // DDR controller presence macros
  `ifndef DDR_A_ABSENT
    `define DDR_A_PRESENT 1
  `else
    `define DDR_A_PRESENT 0
  `endif

  `ifndef DDR_B_ABSENT
    `define DDR_B_PRESENT 1
  `else
    `define DDR_B_PRESENT 0
  `endif

  `ifndef DDR_D_ABSENT
    `define DDR_D_PRESENT 1
  `else
    `define DDR_D_PRESENT 0
  `endif

  // Default AXI values
  `define DEF_AXSIZE    3'd6
  `define DEF_AXBURST   2'd1
  `define DEF_AXCACHE   4'd3
  `define DEF_AXLOCK    1'd0
  `define DEF_AXPROT    3'd2
  `define DEF_AXQOS     4'd0
  `define DEF_AXREGION  4'd0

`endif
