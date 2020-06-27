////////////////////////////////////////////////////////////////////////////////
// Author: Venci Freeman, copyright (c) 2020
// E-mail: vencifreeman16@sjtu.edu.cn
// School: Shanghai Jiao Tong University
// File Name: FIFO
// Details: 
// Release History:
// - Version 0.1 20/06/23: Create.
////////////////////////////////////////////////////////////////////////////////

module fifo (
  
  input               clk,
  input               rst_n,
  input               read_req,
  input               write_req,
  input       [31:0]  din,

  output  reg         full,
  output  reg         empty,
  output  wire[31:0]  dout

);

reg         write_flag, read_flag;
reg  [3:0]  write_ptr, read_ptr;
reg [31:0]  fifo_mem[0:511];

assign dout = fifo_mem[read_ptr];

initial begin
  read_ptr   = 1'b0;
  write_ptr  = 1'b0;
  read_flag  = 1'b0;
  write_flag = 1'b0;
end

// This always part controls fifo_mem.
always @ (posedge clk) begin
  if (write_req && !full)
    fifo_mem[write_ptr] <= din;
end

// This always part controls write_ptr.
always @ (posedge clk) begin
  if (!rst_n)
    write_ptr <= 1'b0;
  else if (!full && write_req)
    write_ptr <= (write_ptr == 16 - 1) ? 0 : write_ptr + 1;
end

// This always part controls read_ptr.
always @ (posedge clk) begin
  if (!rst_n)
    read_ptr <= 1'b0;
  else if (!empty && read_req)
    read_ptr <= (read_ptr == 16 - 1) ? 0 : read_ptr + 1;
end

// This always part controls write_flag.
always @ (posedge clk) begin
  if (!rst_n)
    write_flag <= 1'b0;
  else if (!full && write_req)
    write_flag <= (write_ptr == 16 - 1) ? ~write_flag : write_flag;
end

// This always part controls read_flag.
always @ (posedge clk) begin
  if (!rst_n)
    read_flag <= 1'b0;
  else if (!empty && read_req)
    read_flag <= (read_ptr == 16 - 1) ? ~read_flag : read_flag;
end

// This always part controls full.
always @ (*) begin
    if(write_ptr == read_ptr && read_flag != write_flag)
      full <= 1'b1;
    else
      full <= 1'b0;
end

// This always part controls empty.
always @ (*) begin
    if(write_ptr == read_ptr && read_flag == write_flag)
      empty <= 1'b1;
    else
      empty <= 1'b0;
end

endmodule