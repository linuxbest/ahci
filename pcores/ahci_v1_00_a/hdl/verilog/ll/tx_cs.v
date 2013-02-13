// tx_cs.v --- 
// 
// Filename: tx_cs.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Thu Aug 12 22:00:58 2010 (+0800)
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
module tx_cs (/*AUTOARG*/
   // Outputs
   trn_tdst_rdy_n, txdata, txdatak, rd_sof, rd_eof, rd_empty,
   rd_almost_empty, tx_cs2dbg,
   // Inputs
   clk_75m, host_rst, link2cs_char, link2cs_chark, trn_tsof_n,
   trn_teof_n, trn_td, trn_tsrc_rdy_n, trn_tsrc_dsc_n, trn_tdst_dsc_n,
   trn_tfifo_rst, txdatak_pop, gtx_tune
   );
`include "sata.v"

   input clk_75m;
   input host_rst;

   // from link fsm
   input [31:0] link2cs_char;
   input 	link2cs_chark;
   
   input        trn_tsof_n;
   input        trn_teof_n;
   input [31:0] trn_td;
   input        trn_tsrc_rdy_n;
   output 	trn_tdst_rdy_n;
   input 	trn_tsrc_dsc_n;
   input 	trn_tdst_dsc_n;
   input        trn_tfifo_rst;

   // to phy
   output [31:0] txdata;
   output 	 txdatak;
   input 	 txdatak_pop;
   
   output 	 rd_sof;
   output 	 rd_eof;
   output 	 rd_empty;
   output 	 rd_almost_empty;

   input [31:0]  gtx_tune;
   // [33] SOF
   // [32] EOF
   wire [31:0] rd_do;
   wire        rd_sof;
   wire        rd_eof;
   wire        rd_en;
   wire        rd_empty;
   wire        rd_almost_empty;
   wire        wr_almost_full;
   wire        wr_full;
   
   reg [31:0]  wr_di;
   reg 	       wr_sof;
   reg 	       wr_eof;
   reg 	       wr_en;
   srl16e_fifo_protect
     cs_fifo (
	      // Outputs
	      .DOUT			({rd_eof, rd_sof, rd_do}),
	      .ALMOST_FULL		(wr_almost_full),
	      .FULL			(wr_full),
	      .ALMOST_EMPTY		(rd_almost_empty),
	      .EMPTY			(rd_empty),
	      // Inputs
	      .Clk			(clk_75m),
	      .Rst			(host_rst | trn_tfifo_rst),
	      .WR_EN			(wr_en),
	      .RD_EN			(rd_en),
	      .DIN			({wr_eof, wr_sof, wr_di}));
   defparam cs_fifo.c_width = 34;
   defparam cs_fifo.c_awidth= 4;
   defparam cs_fifo.c_depth = 16;
   
   assign trn_tdst_rdy_n = ~(~(wr_almost_full|wr_full) && trn_tsrc_rdy_n == 1'b0);
  
   wire [31:0] trn_scrambler;
   wire [31:0] trn_crc;
   wire        trn_rst;
   wire        trn_xfer;
   assign trn_rst  = trn_tsrc_rdy_n == 1'b1 && trn_tsof_n == 1'b0;
   assign trn_xfer = trn_tdst_rdy_n == 1'b0 && trn_tsrc_rdy_n == 1'b0;
   scrambler
     cs_scrambler (.scrambler (trn_scrambler),
		   .clk_75m   (clk_75m),
		   .crc_rst   (trn_rst),
		   .data_valid(trn_xfer));
   crc
     cs_crc       (.crc_out   (trn_crc),
		   .clk_75m   (clk_75m),
		   .crc_rst   (trn_rst),
		   .data_valid(trn_xfer),
		   .data_in   (trn_td));
   reg 	       eof_reg;
   always @(posedge clk_75m)
     begin
	eof_reg <= #1 trn_xfer && trn_teof_n == 1'b0;
     end
   // Write Side
   always @(posedge clk_75m)
     begin
	if (trn_xfer)
	  begin
	     wr_en  <= #1 1'b1;
	     wr_di  <= #1 trn_scrambler ^ trn_td;
	     wr_sof <= #1 ~trn_tsof_n;
	     wr_eof <= #1 ~trn_teof_n;
	  end
	else
	  begin
	     wr_di  <= #1 trn_scrambler ^ trn_crc;
	     wr_en  <= #1 eof_reg;
	  end
     end // always @ (posedge clk_75m)

   // Read Side   
   reg trn_eof_reg;
   always @(posedge clk_75m)
     begin
	if (rd_eof && rd_en)
	  begin
	     trn_eof_reg <= #1 1'b1;
	  end
	else if (rd_sof)
	  begin
	     trn_eof_reg <= #1 1'b0;
	  end
     end // always @ (posedge clk_75m)
   assign rd_en  =~link2cs_chark && txdatak_pop;
   assign txdatak= link2cs_chark;
   assign txdata = link2cs_chark ? link2cs_char :
		   trn_eof_reg   ? wr_di        : rd_do;
   
   output [127:0] tx_cs2dbg;
endmodule
// 
// tx_cs.v ends here
