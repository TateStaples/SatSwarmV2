// ============================================================================
// Amazon FPGA Hardware Development Kit
//
// Copyright 2024 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License"). You may not use
// this file except in compliance with the License. A copy of the License is
// located at
//
//    http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
// implied. See the License for the specific language governing permissions and
// limitations under the License.
// ============================================================================


module cl_sda_slv (
   input aclk,
   input aresetn,

   // Explicit AXI-Lite ports instead of axi_bus_t interface
   input  logic [31:0] sda_cl_bus_awaddr,
   input  logic        sda_cl_bus_awvalid,
   output logic        cl_sda_bus_awready,
   input  logic [31:0] sda_cl_bus_wdata,
   input  logic  [3:0] sda_cl_bus_wstrb,
   input  logic        sda_cl_bus_wvalid,
   output logic        cl_sda_bus_wready,
   output logic  [1:0] cl_sda_bus_bresp,
   output logic        cl_sda_bus_bvalid,
   input  logic        sda_cl_bus_bready,
   input  logic [31:0] sda_cl_bus_araddr,
   input  logic        sda_cl_bus_arvalid,
   output logic        cl_sda_bus_arready,
   output logic [31:0] cl_sda_bus_rdata,
   output logic  [1:0] cl_sda_bus_rresp,
   output logic        cl_sda_bus_rvalid,
   input  logic        sda_cl_bus_rready
);

logic [31:0] sda_cl_q_awaddr;
logic        sda_cl_q_awvalid;
logic        sda_cl_q_awready;
logic [31:0] sda_cl_q_wdata;
logic  [3:0] sda_cl_q_wstrb;
logic        sda_cl_q_wvalid;
logic        sda_cl_q_wready;
logic  [1:0] sda_cl_q_bresp;
logic        sda_cl_q_bvalid;
logic        sda_cl_q_bready;
logic [31:0] sda_cl_q_araddr;
logic        sda_cl_q_arvalid;
logic        sda_cl_q_arready;
logic [31:0] sda_cl_q_rdata;
logic  [1:0] sda_cl_q_rresp;
logic        sda_cl_q_rvalid;
logic        sda_cl_q_rready;

//---------------------------------
// flop the input SDA bus
//---------------------------------
   axi_register_slice_light AXIL_SDA_REG_SLC (
    .aclk          (aclk),
    .aresetn       (aresetn),
    .s_axi_awaddr  (sda_cl_bus_awaddr),
    .s_axi_awvalid (sda_cl_bus_awvalid),
    .s_axi_awready (cl_sda_bus_awready),
    .s_axi_wdata   (sda_cl_bus_wdata),
    .s_axi_wstrb   (sda_cl_bus_wstrb),
    .s_axi_wvalid  (sda_cl_bus_wvalid),
    .s_axi_wready  (cl_sda_bus_wready),
    .s_axi_bresp   (cl_sda_bus_bresp),
    .s_axi_bvalid  (cl_sda_bus_bvalid),
    .s_axi_bready  (sda_cl_bus_bready),
    .s_axi_araddr  (sda_cl_bus_araddr),
    .s_axi_arvalid (sda_cl_bus_arvalid),
    .s_axi_arready (cl_sda_bus_arready),
    .s_axi_rdata   (cl_sda_bus_rdata),
    .s_axi_rresp   (cl_sda_bus_rresp),
    .s_axi_rvalid  (cl_sda_bus_rvalid),
    .s_axi_rready  (sda_cl_bus_rready),

    .m_axi_awaddr  (sda_cl_q_awaddr),
    .m_axi_awvalid (sda_cl_q_awvalid),
    .m_axi_awready (sda_cl_q_awready),
    .m_axi_wdata   (sda_cl_q_wdata),
    .m_axi_wstrb   (sda_cl_q_wstrb),
    .m_axi_wvalid  (sda_cl_q_wvalid),
    .m_axi_wready  (sda_cl_q_wready),
    .m_axi_bresp   (sda_cl_q_bresp),
    .m_axi_bvalid  (sda_cl_q_bvalid),
    .m_axi_bready  (sda_cl_q_bready),
    .m_axi_araddr  (sda_cl_q_araddr),
    .m_axi_arvalid (sda_cl_q_arvalid),
    .m_axi_arready (sda_cl_q_arready),
    .m_axi_rdata   (sda_cl_q_rdata),
    .m_axi_rresp   (sda_cl_q_rresp),
    .m_axi_rvalid  (sda_cl_q_rvalid),
    .m_axi_rready  (sda_cl_q_rready)
   );

//---------------------------------
// Simple tie-off for SDA accesses
//   Accepts all transactions.
//   Read data returns 0.
//   Response always OKAY (00).
//---------------------------------

   // Write channels
   assign sda_cl_q_awready = 1'b1;
   assign sda_cl_q_wready  = 1'b1;

   always_ff @(posedge aclk or negedge aresetn) begin
      if (!aresetn) begin
         sda_cl_q_bvalid <= 1'b0;
      end else begin
         if (sda_cl_q_wvalid && sda_cl_q_wready) begin
            sda_cl_q_bvalid <= 1'b1;
         end else if (sda_cl_q_bvalid && sda_cl_q_bready) begin
            sda_cl_q_bvalid <= 1'b0;
         end
      end
   end
   assign sda_cl_q_bresp = 2'b00;

   // Read channels
   assign sda_cl_q_arready = 1'b1;
   assign sda_cl_q_rdata   = 32'h0;
   assign sda_cl_q_rresp   = 2'b00;

   always_ff @(posedge aclk or negedge aresetn) begin
      if (!aresetn) begin
         sda_cl_q_rvalid <= 1'b0;
      end else begin
         if (sda_cl_q_arvalid && sda_cl_q_arready && !sda_cl_q_rvalid) begin
            sda_cl_q_rvalid <= 1'b1;
         end else if (sda_cl_q_rvalid && sda_cl_q_rready) begin
            sda_cl_q_rvalid <= 1'b0;
         end
      end
   end

endmodule
