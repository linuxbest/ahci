// ctrl_ll.v --- 
// 
// Filename: ctrl_ll.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Thu Sep 16 10:28:43 2010 (+0800)
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
module ctrl_ll (/*AUTOARG*/
   // Outputs
   trn_cdst_rdy_n, trn_cdst_dsc_n, trn_cdst_lock_n, ctrl_data,
   ctrl_src_rdy_n,
   // Inputs
   phyclk, phyreset, sys_clk, sys_rst, trn_cd, trn_csof_n, trn_ceof_n,
   trn_csrc_rdy_n, trn_csrc_dsc_n, ctrl_dst_rdy1, ctrl_dst_rdy2,
   ctrl_dst_rdy3, ctrl_dst_lock
   );
   input phyclk;
   input phyreset;

   input sys_clk;
   input sys_rst;

   input [31:0] trn_cd;
   input 	trn_csof_n;
   input 	trn_ceof_n;
   input 	trn_csrc_rdy_n;   
   input 	trn_csrc_dsc_n;
   output 	trn_cdst_rdy_n;
   output 	trn_cdst_dsc_n;
   output 	trn_cdst_lock_n;
   
   output [31:0] ctrl_data;
   output 	 ctrl_src_rdy_n;
   input         ctrl_dst_rdy1;
   input         ctrl_dst_rdy2;
   input         ctrl_dst_rdy3;
   input 	 ctrl_dst_lock;
   
   wire 	 trn_cdst_rdy;   
   wire 	 trn_cdst_lock;
   
   assign trn_cdst_dsc_n = 1'b1;
   assign trn_cdst_rdy_n = ~trn_cdst_rdy;
   assign trn_cdst_lock_n= ~trn_cdst_lock;
   
   reg_sync
     dst_rdy (.sts(trn_cdst_rdy),
	      .set(ctrl_dst_rdy1 || ctrl_dst_rdy3),
	      .wclk(sys_clk),
	      .rclk(phyclk),
	      .rst(sys_rst));

   signal
     dst_lock (.clkA(sys_clk),
	       .signalIn(ctrl_dst_lock),
	       .clkB(phyclk),
	       .signalOut(trn_cdst_lock));
   
   reg 		 trn_csrc_rdy_n_d1;
   always @(posedge phyclk)
     begin
	trn_csrc_rdy_n_d1 <= #1 trn_csrc_rdy_n;
     end
   wire wen;
   assign wen = trn_csrc_rdy_n_d1 && trn_csrc_rdy_n == 1'b0;
   wire ren;
   assign ren = ctrl_dst_rdy1 || ctrl_dst_rdy3;
   FIFO18_36
     trn_fifo (
	       // Outputs
	       .ALMOSTEMPTY		(),
	       .ALMOSTFULL		(),
	       .DO			(ctrl_data),
	       .DOP			(),
	       .EMPTY			(ctrl_src_rdy_n),
	       .FULL			(),
	       .RDCOUNT			(),
	       .RDERR			(),
	       .WRCOUNT			(),
	       .WRERR			(),
	       // Inputs
	       .DI			(trn_cd),
	       .DIP			(4'h0),
	       .RDCLK			(sys_clk),
	       .RDEN			(ren),
	       .RST			(sys_rst),
	       .WRCLK			(phyclk),
	       .WREN			(wen));
   defparam trn_fifo.FIRST_WORD_FALL_THROUGH = "TRUE";
   /* XXXXXXX
    * merge the ctrl into rx fifo 
    * XXXXXXX 
    */
endmodule
// 
// ctrl_ll.v ends here
