`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/02/16 09:40:17
// Design Name: 
// Module Name: div_top
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


module div_top(
  input  wire       rst_n,
  input  wire       clk_i,
  input  wire [7:0] cmd_addr_i,
  input  wire [7:0] cmd_data_i,
  input  wire       cmd_wr_i,
  input  wire       cmd_rd_i,
  output wire       cmd_rdata_o,
  
  input  wire       uart_rx_i,
  input  wire       i2c_scl_i,
  inout  wire       i2c_sda_io,
  input  wire       spi_csn_i,
  input  wire       spi_clk_i,
  input  wire       spi_mosi_i,
  output wire       spi_miso_o,
  output wire       uart_tx_o,
  output wire       div_en_o,
  output wire       div_clk_o
  );
	
  wire 		    rst_sync;
  wire [2:0]    uart_buad;
  wire [7:0]    uart_rdata;
  wire 		    uart_rdone;
  wire 		    tx_done;
  wire 		    rx_error;
  
  wire [7:0]    i2c_rdata;
  wire          i2c_done;
  
  wire [7:0]    spi_rdata;
  wire          spi_rdone;
  
  wire [7:0]    div_data;
//  wire          div_en;
  wire [1:0]    con_bit;
  
	
  rst_syc U_rst_syc(
    .rst_n          (rst_n      ),
    .clk_i          (clk_i      ),
    .rst_syc_o      (rst_sync   )
  );
  
  reg_ctrl(
    .rst_n          (rst_sync   ),
    .clk_i          (clk_i      ),
    .div_data_i     (div_data   ),
    .cmd_addr_i     (cmd_addr_i ),
    .cmd_data_i     (cmd_data_i ),
    .cmd_wr_i       (cmd_wr_i   ),
    .cmd_rd_i       (cmd_rd_i   ),
    .cmd_rdata_o    (cmd_rdata_o),
    .con_bit_o      (con_bit    ),
    .uart_buad_o    (uart_buad  )
  );
	
  uart_rx U_uart_rx(
    .rst_n          (rst_sync   ),
    .clk_i          (clk_i      ),
    .uart_rx_i      (uart_rx_i  ),
    .buad_set_i     (uart_buad  ),
    
    .rx_data_o      (uart_rdata ),
    .rx_done_o      (uart_rdone ),
    .rx_error_o     (rx_error   )
  );
	
  slave_i2c U_slave_i2c(
    .rst_n          (rst_sync   ),  
    .clk_i          (clk_i      ),
    .i2c_scl_i      (i2c_scl_i  ),
    .i2c_sda_io     (i2c_sda_io ),
    .rx_data_o      (i2c_rdata  ),
    .rx_done_o      (i2c_done   )
  );
  
  slave_spi U_slave_spi(
    .rst_n          (rst_sync   ),
    .clk_i          (clk_i      ),
    .spi_csn_i      (spi_csn_i  ),
    .spi_clk_i      (spi_clk_i  ),
    .spi_mosi_i     (spi_mosi_i ),
    .spi_miso_o     (spi_miso_o ),
    .spi_rdata_o    (spi_rdata  ),
    .spi_rdone_o    (spi_rdone  )
  );
  
  uart_tx U_uart_tx(
    .rst_n          (rst_sync   ),
    .clk_i          (clk_i      ),
    .tx_en_i        (uart_rdone ),
    .tx_data_i      (uart_rdata ),
    .uart_tx_o      (uart_tx_o  ),
    .tx_done_o      (tx_done    )
  );
  
  data_confirm U_data_confirm(
    .rst_n          (rst_sync   ),
    .clk_i          (clk_i      ),
    .con_bit_i      (con_bit    ),
    .uart_rdata_i   (uart_rdata ),
    .uart_rdone_i   (uart_rdone ),
    .i2c_rdata_i    (i2c_rdata  ),
    .i2c_rdone_i    (i2c_done   ),
    .spi_rdata_i    (spi_rdata  ),
    .spi_rdone_i    (spi_rdone  ),
    
    .div_data_o     (div_data   ),
    .div_en_o       (div_en_o   )
  );

  clk_div U_clk_div(
    .rst_n          (rst_sync   ),
    .clk_i          (clk_i      ),
    .div_data_i     (div_data   ),
    .div_en_i       (div_en_o   ),
    .div_clk_o      (div_clk_o  )
  );
	
endmodule
