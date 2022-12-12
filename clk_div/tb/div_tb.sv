`timescale 1ns/1ps

`include "param_def.v"

interface uart_intf(input clk, input rstn);
  logic			uart_txd;
  clocking drv_ck @(posedge clk);
    default input #1ns output #1ns;
    output uart_txd;
  endclocking
  
  clocking mon_ck @(posedge clk);
    default input #1ns output #1ns;
    input uart_txd;
  endclocking
  
endinterface

interface spi_intf(input clk, input rstn);
  logic			spi_csn;
  logic			spi_clk;
  logic			spi_mosi;
  logic			spi_miso;
  clocking drv_ck @(posedge clk);
    default input #1ns output #1ns;
    output spi_csn,spi_clk,spi_mosi;
	input spi_miso;
  endclocking
  
  clocking mon_ck @(posedge clk);
    default input #1ns output #1ns;
    input spi_csn,spi_clk,spi_mosi,spi_miso;
  endclocking
  
endinterface


interface reg_intf(input clk, input rstn);
  logic [1:0]				cmd;
  logic [`ADDR_WIDTH-1:0]	cmd_addr;
  logic [`DATA_WIDTH-1:0]	cmd_wdata;
  logic [`DATA_WIDTH-1:0]	cmd_rdata;
  clocking drv_ck @(posedge clk);
    default input #1ns output #1ns;
    output cmd, cmd_addr, cmd_wdata;
    input cmd_rdata;
  endclocking
  
  clocking mon_ck @(posedge clk);
    default input #1ns output #1ns;
    input cmd, cmd_addr, cmd_wdata, cmd_rdata;
  endclocking
endinterface

interface div_intf(input clk, input rstn);
  logic        div_en;
  logic        div_clk;
  
  clocking drv_ck @(posedge clk);
    default input #1ns output #1ns;
    input div_en, div_clk;
  endclocking
  
  clocking mon_ck @(posedge clk);
    default input #1ns output #1ns;
    input div_en, div_clk;
  endclocking
  
endinterface

module tb;
  logic         clk;
  logic         rstn;

  div_top u_div_top(
	.rst_n			(rstn				),
	.clk_i			(clk				),
	.cmd_addr_i		(reg_if.cmd_addr	),
	.cmd_data_i		(reg_if.cmd_wdata	),
	.cmd_opt_i		(reg_if.cmd			),
	.cmd_rdata_o	(reg_if.cmd_rdata	),
	
	.uart_rx_i		(uart_if.uart_txd	),
	.i2c_scl_i		(),
	.i2c_sda_io		(),
	.spi_csn_i		(spi_if.spi_csn		),
	.spi_clk_i		(spi_if.spi_clk		),
	.spi_mosi_i		(spi_if.spi_mosi	),
	.spi_miso_o		(spi_if.spi_miso	),
//	.uart_tx_o		(),
	.div_en_o		(div_if.div_en		),
	.div_clk_o		(div_if.div_clk		)
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
  import spi_pkg::*;
  import reg_pkg::*;
  import div_pkg::*;
  import plat_pkg::*;

  reg_intf	reg_if(.*);
  uart_intf	uart_if(.*);
  spi_intf	spi_if(.*);
  div_intf	div_if(.*);

  // mcdf interface monitoring MCDF ports and signals
//  assign mcdf_if.chnl_en[0] = tb.dut.ctrl_regs_inst.slv0_en_o;
//  assign mcdf_if.chnl_en[1] = tb.dut.ctrl_regs_inst.slv1_en_o;
//  assign mcdf_if.chnl_en[2] = tb.dut.ctrl_regs_inst.slv2_en_o;

  // arbiter interface monitoring arbiter ports
//  assign arb_if.slv_prios[0] = tb.dut.arbiter_inst.slv0_prio_i;
//  assign arb_if.slv_prios[1] = tb.dut.arbiter_inst.slv1_prio_i;
//  assign arb_if.slv_prios[2] = tb.dut.arbiter_inst.slv2_prio_i;
//  assign arb_if.slv_reqs[0] = tb.dut.arbiter_inst.slv0_req_i;
//  assign arb_if.slv_reqs[1] = tb.dut.arbiter_inst.slv1_req_i;
//  assign arb_if.slv_reqs[2] = tb.dut.arbiter_inst.slv2_req_i;
//  assign arb_if.a2s_acks[0] = tb.dut.arbiter_inst.a2s0_ack_o;
//  assign arb_if.a2s_acks[1] = tb.dut.arbiter_inst.a2s1_ack_o;
//  assign arb_if.a2s_acks[2] = tb.dut.arbiter_inst.a2s2_ack_o;
//  assign arb_if.f2a_id_req = tb.dut.arbiter_inst.f2a_id_req_i;

//  mcdf_data_consistence_basic_test t1;
//  mcdf_full_random_test t2;
//  mcdf_base_test tests[string];
//  string name;

  initial begin 
//    t1 = new();
//    t2 = new();
//    tests["mcdf_data_consistence_basic_test"] = t1;
//    tests["mcdf_full_random_test"] = t2;
//    if($value$plusargs("TESTNAME=%s", name)) begin
//      if(tests.exists(name)) begin
//        tests[name].set_interface(chnl0_if, chnl1_if, chnl2_if, reg_if, arb_if, fmt_if, mcdf_if);
//        tests[name].run();
//      end
//      else begin
//        $fatal($sformatf("[ERRTEST], test name %s is invalid, please specify a valid name!", name));
//      end
//    end
//    else begin
//      $display("NO runtime optiont +TESTNAME=xxx is configured, and run default test mcdf_data_consistence_basic_test");
//      tests["mcdf_data_consistence_basic_test"].set_interface(chnl0_if, chnl1_if, chnl2_if, reg_if, arb_if, fmt_if, mcdf_if);
//      tests["mcdf_data_consistence_basic_test"].run();
//    end
//  end
endmodule

