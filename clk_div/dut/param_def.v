
`define  ADDR_WIDTH 8
`define  DATA_WIDTH 8

`define  WRITE 2'b10          //Register operation command
`define  READ  2'b01
`define  IDLE  2'b00

`define  CHNEL_SEL   8'h00
`define  UART_BUAD   8'h04

`define  DVI_FAC    8'h10

`define	 UART_INPUT	2'b11
`define	 I2C_INPUT	2'b10
`define	 SPI_INPUT	2'b00

`define  BUAD_9600	     9'd321
`define  BUAD_19200	     9'd161
`define  BUAD_38400	     9'd80 
`define  BUAD_57600	     9'd53 
`define  BUAD_115200	 9'd27 

//`define SLV0_RW_ADDR 8'h00    //Register address 
//`define SLV1_RW_ADDR 8'h04
//`define SLV2_RW_ADDR 8'h08
//`define SLV0_R_ADDR  8'h10
//`define SLV1_R_ADDR  8'h14
//`define SLV2_R_ADDR  8'h18
//
//
//`define SLV0_RW_REG 0
//`define SLV1_RW_REG 1
//`define SLV2_RW_REG 2
//`define SLV0_R_REG  3
//`define SLV1_R_REG  4
//`define SLV2_R_REG  5
//
//`define FIFO_MARGIN_WIDTH 8
//
//`define PRIO_WIDTH 2
//`define PRIO_HIGH 2
//`define PRIO_LOW  1
//
//`define PAC_LEN_WIDTH 3
//`define PAC_LEN_HIGH 5
//`define PAC_LEN_LOW  3    
