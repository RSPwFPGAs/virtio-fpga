`timescale 1ns / 100ps

//`include "axi_vip_0_exdes_generic.sv"
`include "axi_vip_0_passthrough_mst_stimulus.sv"
`include "axi_vip_thread00_passthrough_mst_stimulus.sv"
`include "axi_vip_thread01_passthrough_mst_stimulus.sv"
`include "axi_vip_thread02_passthrough_mst_stimulus.sv"
`include "axi_vip_thread03_passthrough_mst_stimulus.sv"
`include "axi_vip_thread04_passthrough_mst_stimulus.sv"
`include "axi_vip_thread05_passthrough_mst_stimulus.sv"
`include "axi_vip_thread06_passthrough_mst_stimulus.sv"
//`include "axi_vip_0_slv_basic_stimulus.sv"

module test_top ();

reg  PCIE_CLK_N;
reg  PCIE_CLK_P;
wire [7:0] PCIE_RX_N;
wire [7:0] PCIE_RX_P;
wire [7:0] PCIE_TX_N;
wire [7:0] PCIE_TX_P;
reg  PERSTN;
reg  FPGA_SYSCLK_N;
reg  FPGA_SYSCLK_P;
reg  RESET;
wire  UART_RXD_OUT;
wire  UART_TXD_IN;
shell_region_wrapper DUT (
  .pci_express_rxn (PCIE_RX_N),
  .pci_express_rxp (PCIE_RX_P),
  .pci_express_txn (PCIE_TX_N),
  .pci_express_txp (PCIE_TX_P),
  .pcie_perstn (PERSTN),
  .pcie_refclk_clk_n (PCIE_CLK_N),
  .pcie_refclk_clk_p (PCIE_CLK_P)
);

// instantiate vip master
//  axi_vip_0_exdes_generic  generic_tb();
  axi_vip_0_passthrough_mst_stimulus mst_axilite_toCSR();  // for initialization of CSR
  axi_vip_thread00_passthrough_mst_stimulus mst_axifull_toDMA_th00();  // for transaction of DMA
  axi_vip_thread01_passthrough_mst_stimulus mst_axifull_toDMA_th01();  // for transaction of DMA
  axi_vip_thread02_passthrough_mst_stimulus mst_axifull_toDMA_th02();  // for transaction of DMA
  axi_vip_thread03_passthrough_mst_stimulus mst_axifull_toDMA_th03();  // for transaction of DMA
  axi_vip_thread04_passthrough_mst_stimulus mst_axifull_toDMA_th04();  // for transaction of DMA
  axi_vip_thread05_passthrough_mst_stimulus mst_axifull_toDMA_th05();  // for transaction of DMA
  axi_vip_thread06_passthrough_mst_stimulus mst_axifull_toDMA_th06();  // for transaction of DMA
//  axi_vip_0_slv_basic_stimulus slv();
    

//////////////////////////////////
// Inter-thread signals

`define CSR_PATH test_top.DUT.shell_region_i.FIM.FIU.feature_ram.virtio_csr_0.inst
`define TH00_PATH test_top.mst_axifull_toDMA_th00
`define TH01_PATH test_top.mst_axifull_toDMA_th01
`define TH02_PATH test_top.mst_axifull_toDMA_th02
`define TH03_PATH test_top.mst_axifull_toDMA_th03
`define TH04_PATH test_top.mst_axifull_toDMA_th04
`define TH05_PATH test_top.mst_axifull_toDMA_th05
`define TH06_PATH test_top.mst_axifull_toDMA_th06

reg [2:0] queue_notify_pending;
// make a record of pending notification
always @(posedge `CSR_PATH.clk) begin
  for (int i = 0; i < 3; i++) begin
    if (`CSR_PATH.csr_rst)
      queue_notify_pending[i] = 1'b0;
    else if (`TH00_PATH.queue_notify_set[i])
      queue_notify_pending[i] = 1'b1;
    else if (`TH01_PATH.queue_notify_clr[i])
      queue_notify_pending[i] = 1'b0;
  end
end

// Inter-thread signals
/////////////////////////////////////

always
begin
  PCIE_CLK_N = 1;
  #5.0;
  PCIE_CLK_N = 0;
  #5.0;
end
always
begin
  PCIE_CLK_P = 0;
  #5.0;
  PCIE_CLK_P = 1;
  #5.0;
end

always
begin
  FPGA_SYSCLK_N = 0;
  #2.5;
  FPGA_SYSCLK_N = 1;
  #2.5;
end
always
begin
  FPGA_SYSCLK_P = 1;
  #2.5;
  FPGA_SYSCLK_P = 0;
  #2.5;
end

initial
begin
  $display("[%t] : System Reset(test_top/RESET) Is Asserted...", $realtime);
  RESET = 1;
  #5000;
  $display("[%t] : System Reset(test_top/RESET) Is DeAsserted...", $realtime);
  RESET = 0;
end

initial
begin
  $display("[%t] : System Reset(test_top/PERSTN) Is Asserted...", $realtime);
  PERSTN = 0;
  #100;
  $display("[%t] : System Reset(test_top/PERSTN) Is DeAsserted...", $realtime);
  PERSTN = 1;
end

initial begin
  $display("V: testbench init.");
end

endmodule

