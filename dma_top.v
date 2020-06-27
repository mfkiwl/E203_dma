////////////////////////////////////////////////////////////////////////////////
// Author: Venci Freeman, copyright (c) 2020
// E-mail: vencifreeman16@sjtu.edu.cn
// School: Shanghai Jiao Tong University
// File Name: top
// Details: Bus timing and registers maintenance.
// Release History:
// - Version 0.1 20/06/21: Create;
// - Version 0.2 20/06/23: Determine the file structure.
////////////////////////////////////////////////////////////////////////////////
`include "dma_core.v"

module e203_dma (

  input  wire			  clk,
  input  wire       rst_n,
  input  wire       dma_icb_rsp_err,        // 反馈的错误标志，为高表示错误
  input  wire       dma_icb_cmd_ready,      // 从设备反馈的读写接受信号，为高表示从设备接受
  input  wire       dma_icb_rsp_valid,
  input  wire[31:0] dma_icb_rsp_rdata,      // 读反馈的数据
  input  wire       dma_cfg_icb_cmd_read,
  input  wire       dma_cfg_icb_cmd_valid,
  input  wire       dma_cfg_icb_rsp_ready,
  input  wire[31:0] dma_cfg_icb_cmd_wdata,
  input  wire [3:0] dma_cfg_icb_cmd_wmask,
  input  wire[31:0] dma_cfg_icb_cmd_addr,

  output wire       dma_cfg_icb_rsp_err,
  output wire       dma_cfg_icb_cmd_ready,  
  output wire       dma_cfg_icb_rsp_valid,
  output wire[31:0] dma_cfg_icb_rsp_rdata,

  output wire       dma_irq,                // 中断请求
  output wire       dma_icb_cmd_valid,      // 向从设备发送读写请求
  output wire       dma_icb_cmd_read,       // 读写操作指示
  output wire       dma_icb_rsp_ready,      // 向从设备返回的读写反馈接受信号，为高表示主设备接受
  output wire[31:0] dma_icb_cmd_addr,       // 读写地址
  output wire[31:0] dma_icb_cmd_wdata,      // 写操作的数据
  output wire [3:0] dma_icb_cmd_wmask       // 写操作的字节掩码
  
);

  parameter IDLE_8  =  8'h0;
  parameter IDLE_32 = 32'h0;
  parameter SRCADDR = 32'h10000000;
  parameter DSTADDR = 32'h10000004;
  parameter LENADDR = 32'h10000008;
  parameter STAADDR = 32'h1000000c;

// 初始化与配置
  wire start = 1'b1;
  wire dma_icb_cmd_hsk = dma_icb_cmd_valid & dma_icb_cmd_ready;	 // 命令通道握手信号
  wire dma_icb_rsp_hsk = dma_icb_rsp_valid & dma_icb_rsp_ready;  // 响应通道握手信号

  reg [31:0] src_addr_reg;  // 源地址寄存器，指示搬运的起始地址
  reg [31:0] dst_addr_reg;  // 目的地址寄存器，指示搬运的目的地址
  reg [31:0] len_addr_reg;  // 数据长度寄存器，指示搬运的数据长度
  reg  [7:0] sta_addr_reg;  // 状态寄存器，指示配置和搬运完成

// 从设备总线时序定义
  assign start = sta_addr_reg[1];
  assign dma_cfg_icb_cmd_ready = dma_cfg_icb_cmd_ready;
  assign dma_cfg_icb_rsp_valid = dma_cfg_icb_cmd_valid;
  assign dma_cfg_icb_rsp_err   = dma_icb_rsp_err;
  assign dma_cfg_icb_rsp_rdata = dma_icb_rsp_rdata;
  assign rdata = dma_cfg_icb_cmd_read ? dma_cfg_icb_cmd_addr : IDLE_32;
  assign dma_icb_cmd_valid = dma_icb_rsp_hsk ? 1'b1 : 1'b0;
  assign dma_icb_cmd_ready = dma_icb_cmd_hsk ? 1'b1 : 1'b0;

// 寄存器维护
// This always part controls src_addr_reg.
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		src_addr_reg <= IDLE_32;
	else if (dma_cfg_icb_cmd_wmask != IDLE_32 && dma_cfg_icb_cmd_addr == SRCADDR)
		src_addr_reg <= dma_cfg_icb_cmd_wdata;
	else
		src_addr_reg <= SRCADDR;
end

// This always part controls dst_addr_reg.
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		dst_addr_reg <= IDLE_32;
	else if (dma_cfg_icb_cmd_wmask != IDLE_32 && dma_cfg_icb_cmd_addr == DSTADDR)
		dst_addr_reg <= dma_cfg_icb_cmd_wdata;
	else
		dst_addr_reg <= DSTADDR;
end

// This always part controls len_addr_reg.
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		len_addr_reg <= IDLE_32;
	else if (dma_cfg_icb_cmd_wmask != IDLE_32 && dma_cfg_icb_cmd_addr == LENADDR)
		len_addr_reg <= dma_cfg_icb_cmd_wdata;
	else
		len_addr_reg <= LENADDR;
end

// This always part controls sta_addr_reg.
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		sta_addr_reg <= IDLE_8;
	else if (dma_cfg_icb_cmd_wmask != IDLE_32) begin
    sta_addr_reg[0] <= 1'b0;
    sta_addr_reg[1] <= 1'b1;
  end else
		sta_addr_reg <= STAADDR[7:0];
end

// 控制/状态信号与core相连
dma_core inst_dma_core (.clk                (clk),
                        .rst_n              (rst_n),
                        .dma_icb_rsp_err    (dma_icb_rsp_err),
                        .dma_icb_cmd_ready  (dma_icb_cmd_ready),
                        .dma_icb_cmd_valid  (dma_icb_cmd_valid),
                        .dma_icb_rsp_rdata  (dma_icb_rsp_rdata),
                        .src_addr_reg       (src_addr_reg),
                        .dst_addr_reg       (dst_addr_reg),
                        .len_addr_reg       (len_addr_reg),
                        .sta_addr_reg       (sta_addr_reg),
                        .start              (start),
                        .dma_irq            (dma_irq),
                        .dma_icb_rsp_valid  (dma_icb_rsp_valid),
                        .dma_icb_cmd_read   (dma_icb_cmd_read),
                        .dma_icb_rsp_ready  (dma_icb_rsp_ready),
                        .dma_icb_cmd_addr   (dma_icb_cmd_addr),
                        .dma_icb_cmd_wdata  (dma_icb_cmd_wdata),
                        .dma_icb_cmd_wmask  (dma_icb_cmd_wmask));

endmodule

