// datamem.v --- 
// 
// Filename: datamem.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Thu Apr  1 23:13:01 2010 (+0800)
// Version: 
// Last-Updated: 
//           By: 
//     Update #: 0
// URL: 
// Keywords: 
// Compatibility: 
// 
// 

// Commentary: 
// 
// 
// 
// 

// Change log:
// 
// 
// 

// Copyright (C) 2008,2009 Beijing Soul tech.
// -------------------------------------
// Naming Conventions:
// 	active low signals                 : "*_n"
// 	clock signals                      : "clk", "clk_div#", "clk_#x"
// 	reset signals                      : "rst", "rst_n"
// 	generics                           : "C_*"
// 	user defined types                 : "*_TYPE"
// 	state machine next state           : "*_ns"
// 	state machine current state        : "*_cs"
// 	combinatorial signals              : "*_com"
// 	pipelined or register delay signals: "*_d#"
// 	counter signals                    : "*cnt*"
// 	clock enable signals               : "*_ce"
// 	internal version of output port    : "*_i"
// 	device pins                        : "*_pin"
// 	ports                              : - Names begin with Uppercase
// Code:

module datamem (/*AUTOARG*/
   // Outputs
   dout,
   // Inputs
   sys_clk, a, we, di
   );
   parameter depth = 6;
   
   input sys_clk;

   input [depth-1:0] a;
   input [7:0] 	     we;
   input [63:0]      di;
   output [63:0]     dout;
`define BRAM
`ifdef BRAM
   wire [15:0] addr_a;
   wire [15:0] addr_b;
   RAMB36
     ram (
	  // Outputs
	  .CASCADEOUTLATA		(),
	  .CASCADEOUTREGA		(),
	  .CASCADEOUTLATB		(),
	  .CASCADEOUTREGB		(),
	  .DOPA				(),
	  .DOPB				(),
	  .DOA				(dout[31:0]),
	  .DOB				(dout[63:32]),
	  // Inputs
	  .CLKA				(sys_clk),
	  .SSRA				(1'b0),
	  .CASCADEINLATA		(1'b0),
	  .CASCADEINREGA		(1'b0),
	  .REGCEA			(1'b1),
	  .ENB				(1'b1),
	  .CLKB				(sys_clk),
	  .SSRB				(1'b0),
	  .CASCADEINLATB		(1'b0),
	  .CASCADEINREGB		(1'b0),
	  .REGCEB			(1'b1),
	  .ENA				(1'b1),
	  .ADDRA			(addr_a),
	  .ADDRB			(addr_b),
	  .DIA				(di[31:0]),
	  .DIB				(di[63:32]),
	  .DIPA				(4'h0),
	  .DIPB				(4'h0),
	  .WEA				(we[3:0]),
	  .WEB				(we[7:4]));
  defparam ram.READ_WIDTH_A  = 36;
  defparam ram.READ_WIDTH_B  = 36;
  defparam ram.WRITE_WIDTH_A = 36;
  defparam ram.WRITE_WIDTH_B = 36;
  defparam ram.DOA_REG = 0;
  defparam ram.DOB_REG = 0;
  defparam ram.WRITE_MODE_A = "WRITE_FIRST";
  defparam ram.WRITE_MODE_B = "WRITE_FIRST";
  assign addr_a = {1'b1, a, 5'h0};
  assign addr_b = {1'b0, a, 5'h0};
`else
   genvar 	     i;
   generate
      for (i = 0; i < 8; i = i + 1)
	begin: ram_block
	   reg [7:0] ram[0:(1<<depth)-1];
	   wire [7:0] ram_di;
	   wire [7:0] ram_do;
	   reg [depth-1:0] a_r;
	   always @(posedge sys_clk)
	     a_r <= #1 a;
	   always @(posedge sys_clk)
	     if (we[i])
	       ram[a] <= #1 ram_di;
	   assign ram_di = di[(i*8)+7:(i*8)];
	   assign dout[(i*8)+7:(i*8)] = ram[a_r];
	end // block: ram_block
   endgenerate
`endif 
endmodule
// 
// datamem.v ends here
