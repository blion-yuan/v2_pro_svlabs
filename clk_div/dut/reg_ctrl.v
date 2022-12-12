`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/12 09:40:17
// Design Name: 
// Module Name: reg_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "param_def.v"

module reg_ctrl(
  input  wire       rst_n,
  input  wire       clk_i,
  input  wire [7:0] div_data_i,
  input  wire [7:0] cmd_addr_i,
  input  wire [7:0] cmd_data_i,
  input  wire       cmd_wr_i,
  input  wire       cmd_rd_i,
  output wire [7:0] cmd_rdata_o,
  output wire [1:0] con_bit_o,
  output wire [2:0] uart_buad_o
  );
  
  
  reg [7:0] chnnel_sel;
  reg [7:0] uart_buad;
  reg [7:0] cmd_rdata;
  reg [1:0] con_bit;
  
  assign con_bit_o = con_bit;
  assign cmd_rdata_o = cmd_rdata;
  assign uart_buad_o = uart_buad[2:0];
      
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      chnnel_sel <= 8'h03;
    else if(cmd_wr_i != 1'b1)
      chnnel_sel <= chnnel_sel;
    else if(cmd_addr_i == `CHNEL_SEL)
      chnnel_sel <= cmd_data_i;
    else
      chnnel_sel <= chnnel_sel;
  end
    
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      cmd_rdata <= 8'h00;
    else if(cmd_rd_i != 1'b1)
      cmd_rdata <= cmd_rdata;
    else if(cmd_addr_i == `CHNEL_SEL)
      cmd_rdata <= {6'b00_0000,chnnel_sel[1:0]};
    else if(cmd_addr_i == `DVI_FAC)
      cmd_rdata <= div_data_i;
    else if(cmd_addr_i == `UART_BUAD)
      cmd_rdata <= uart_buad;
    else
      cmd_rdata <= 8'h00;
  end
  
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      uart_buad <= 8'h05;
    else if(cmd_wr_i != 1'b1)
      uart_buad <= uart_buad;
    else if(cmd_addr_i == `UART_BUAD)
      uart_buad <= {5'b0_0000,cmd_data_i[2:0]};
    else
      uart_buad <= uart_buad;
  end
    
  always@(posedge clk_i or negedge rst_n)begin
    if(!rst_n)
      con_bit <= 2'b11;
    else 
      con_bit <= chnnel_sel[1:0];
  end
    
endmodule
