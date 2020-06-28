////////////////////////////////////////////////////////////////////////////////
// Author: Yang Wenxi, copyright (c) 2020
// E-mail: vencifreeman16@sjtu.edu.cn
// School: Shanghai Jiao Tong University
// File Name: core
// Details: 
// Release History:
// - Version 0.1 20/06/22: Create;
// - Version 0.2 20/06/23: Determine the file structure;
// - Version 0.2 20/05/24: Add read and write parts.
////////////////////////////////////////////////////////////////////////////////
`include "fifo.v"

module dma_core (

  input  wire			  clk,
  input  wire       rst_n,
  input  wire       dma_icb_rsp_err,        // 反馈的错误标志，为高表示错误
  input  wire       dma_icb_cmd_ready,      // 从设备反馈的读写接受信号，为高表示从设备接受
  input  wire       dma_icb_rsp_valid,
  input  wire[31:0] dma_icb_rsp_rdata,      // 读反馈的数据

	input  wire[31:0] src_addr_reg,
	input  wire[31:0]	dst_addr_reg,
	input  wire[31:0]	len_addr_reg,
	input  wire[ 7:0]	sta_addr_reg,
	input  wire	      start,

  output reg        dma_irq,                // 中断请求
  output reg        dma_icb_cmd_valid,      // 向从设备发送读写请求
  output reg        dma_icb_cmd_read,       // 读写操作指示
  output reg        dma_icb_rsp_ready,      // 向从设备返回的读写反馈接受信号，为高表示主设备接受
  output reg [31:0] dma_icb_cmd_addr,       // 读写地址
  output reg [31:0] dma_icb_cmd_wdata,      // 写操作的数据
  output reg [ 3:0] dma_icb_cmd_wmask       // 写操作的字节掩码

);

  parameter   IDLE  = 3'b001;   
  parameter   READ  = 3'b010;
  parameter   WRITE = 3'b100;

  wire        dma_ini_en;
  wire        fifo_read_en, fifo_write_en;  // for fifo
  wire        fifo_full, fifo_empty;        // for fifo
  wire        read_addr_en, write_addr_en;
  wire [31:0] fifo_read_data;               // for fifo

  wire [31:0] src_end_next;
  wire [31:0] dst_end_next;
  wire [31:0] length;

  reg  [31:0] read_addr;
  reg  [31:0] write_addr;
  reg  [31:0] fifo_write_data;              // for fifo
  reg  [31:0] read_addr_reg;                // for fifo
  reg         read_en, write_en;

  reg   [2:0] state_curr;                   // for FSM
  wire  [2:0] state_next;                   // for FSM

  reg   [1:0] size;
  reg  [31:0] src_end;
  reg  [31:0] dst_end;

// 作为master的总线时序定义
  assign dma_ini_en   = state_curr[0] & start;
  assign length       = (len_addr_reg - 1'b1) << len_addr_reg[1:0];
  assign src_end_next = src_addr_reg + length;
  assign dst_end_next = dst_addr_reg + length;

  assign read_addr_en  = dma_icb_cmd_ready & state_curr[1];
  assign write_addr_en = dma_icb_cmd_ready & state_curr[2];

  assign fifo_read_en  =   state_curr[0] ? ~fifo_empty : (write_en & dma_icb_cmd_ready);
  assign fifo_write_en =   dma_icb_cmd_ready & ~fifo_full & read_en;

  assign state_next = state_curr[0] & start ? READ : (state_curr[1] ? WRITE : (state_curr[2] & dma_irq ? IDLE : (state_curr[2] ? READ : state_curr))); 

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n)
    dma_irq <= 1'b0;
  else if (state_curr[2] == 1'b1)
    dma_irq <= 1'b1;
  else
    dma_req <= 1'b0;
end

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n)
    dma_icb_rsp_valid <= 1'b0;
  else if (state_curr[0] && dma_icb_cmd_ready || state_curr[1] && dma_icb_cmd_ready)
    dma_icb_rsp_valid <= 1'b1;
  else
    dma_icb_rsp_valid <= 1'b0;
end

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n)
    dma_icb_cmd_addr <= 32'h0;
  else if (state_curr[0])
    dma_icb_cmd_addr <= read_addr;
  else if (state_curr[1])
    dma_icb_cmd_addr <= write_addr;
  else
    dma_icb_cmd_addr <= 32'h0;
end

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n)
    dma_icb_cmd_read <= 1'b0;
  else if (state_curr[1])
    dma_icb_cmd_read <= 1'b1;
  else
    dma_icb_cmd_addr <= 1'b0;
end

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n)
    dma_icb_cmd_wdata <= 32'h0;
  else if (state_curr[2])
    dma_icb_cmd_wdata <= fifo_read_data;
  else
    dma_icb_cmd_wdata <= 32'h0;
end

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n)
    dma_icb_cmd_wmask <= 4'b0;
  else if (state_curr[2])
    dma_icb_cmd_wmask <= 4'b1111;
  else
    dma_icb_cmd_wmask <= 4'b0;
end

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n)
    dma_icb_rsp_ready <= 1'b0;
  else if (state_curr[1] && dma_icb_cmd_valid || state_curr[2] && dma_icb_cmd_valid)
    dma_icb_rsp_ready <= 1'b1;
  else
    dma_icb_rsp_ready <= 1'b0;
end

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n)
    dma_icb_rsp_err <= 1'b0;
  else
    dma_icb_rsp_err <= 1'b0;
end

// 有限状态机：空闲/读/写
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
      state_curr <= IDLE;
    else
      state_curr <= state_next;
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
      size <= 2'b0;
    else if (dma_ini_en)
      size <= len_addr_reg[1:0];
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
      src_end <= 32'b0;
    else if (dma_ini_en)
      src_end <= src_end_next;
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
      dst_end <= 32'b0; 
    else if (dma_ini_en)
      dst_end <= dst_end_next;
end 

// 读地址生成
always @ (posedge clk or negedge rst_n) begin
  if (!rst_n)
    read_addr <= 32'h0;
  else if (dma_ini_en)
    read_addr <= src_addr_reg;
  else if (state_curr[1])
    read_addr <= 32'h0;
  else if (read_addr_en)
    read_addr <= read_addr + 3'b100;
  else
    read_addr <= read_addr;
end

// 写地址生成
always @ (posedge clk or negedge rst_n) begin
  if (!rst_n)
    write_addr <= 32'h0;
  else if (dma_ini_en)
    write_addr <= dst_addr_reg;
  else if (state_curr[2])
    write_addr <= 32'h0;
  else if (write_addr_en)
    write_addr <= write_addr + 3'b100;
  else
    write_addr <= write_addr;
end

// FIFO的例化
fifo inst_fifo (.clk        (clk),
      				  .rst_n      (rst_n),
                .read_req   (fifo_read_en),
                .write_req  (fifo_write_en),
                .din        (fifo_write_data),
                .full       (fifo_full),
                .empty      (fifo_empty),
                .dout       (fifo_read_data));

// FIFO控制
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
      read_en <= 1'b0;
    else
      read_en <= state_curr[1];
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
      write_en <= 1'b0;
    else
      write_en <= state_curr[2];
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) 
      read_addr_reg <= 32'b0;
    else if (dma_icb_cmd_ready)
      read_addr_reg <= read_addr;
end

always @ (*) begin
    case (size)
      2'b00: begin
        case (read_addr_reg[1:0])
          2'b00 : fifo_write_data = { 4{dma_icb_rsp_rdata[ 7: 0]} };
          2'b01 : fifo_write_data = { 4{dma_icb_rsp_rdata[15: 8]} };
          2'b10 : fifo_write_data = { 4{dma_icb_rsp_rdata[23:16]} };
          2'b11 : fifo_write_data = { 4{dma_icb_rsp_rdata[31:24]} };
        endcase end
      2'b01: begin
        case (read_addr_reg[1])
          1'b0 : fifo_write_data = { 2{dma_icb_rsp_rdata[15: 0]} };
          1'b1 : fifo_write_data = { 2{dma_icb_rsp_rdata[31:16]} };
        endcase end
      2'b10: begin
          fifo_write_data = dma_icb_rsp_rdata;
        end
      default: begin
          fifo_write_data = 32'b0;
        end
    endcase
end

endmodule