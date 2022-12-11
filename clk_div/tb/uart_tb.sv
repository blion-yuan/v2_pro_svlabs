`timescale 1ns/1ps

interface uart_intf(input clk, input rstn);
	logic        uart_txd;
	clocking drv_ck @(posedge clk);
		default input #1ns output #1ns;
	output uart_txd;
	endclocking
	
	clocking mon_ck @(posedge clk);
		default input #1ns output #1ns;
	output uart_txd;
	endclocking
	
endinterface

module uart_tb;
	logic         clk;
	logic         rstn;
	logic [7:0]  	rx_data;
	logic         rx_done;
	logic         rx_error;
	logic [ 2:0]  buad_set = 3'd5;
  
	uart_rx dut_uart_rx(
		.rst_n			(rstn				),
		.clk_i			(clk				),
		.uart_rx_i		(uart_if.uart_txd	),
		.buad_set_i		(buad_set			),

		.rx_data_o		(rx_data			),
		.rx_done_o		(rx_done			),
		.rx_error_o		(rx_error			)
	);
	
  // clock generation
	initial begin 
		clk <= 0;
		forever begin
			#5 clk <= !clk;
		end
	end
  
  // reset trigger
	initial begin 
		#10 rstn <= 0;
		repeat(10) @(posedge clk);
		rstn <= 1;
	end

	import uart_pkg::*;

	uart_intf uart_if(.*);

	uart_agent uart_agent_test;
//	uart_generator uart_generator_test;

	initial begin 
		uart_agent_test = new();
//		uart_generator_test = new();
		uart_agent_test.set_interface(uart_if);
		fork
			//uart_generator_test.start();
			uart_agent_test.run(); 
		join
		$display("*****************all of tests have been finished********************");
		$stop();
	end


endmodule

