// txll.v --- 
// 
// Filename: txll.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Fri Sep 10 12:33:06 2010 (+0800)
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
module txll (/*AUTOARG*/
   // Outputs
   txll2txdma_rdy, txll2port_xfer, txll2port_Push_ack, txll2dbg,
   trn_tsrc_rdy_n, trn_tsrc_dsc_n, trn_tsof_n, trn_teof_n, trn_td,
   // Inputs
   txdma2txll_push, txdma2txll_do, trn_tdst_rdy_n, trn_tdst_dsc_n,
   port2txll_Push_req, port2txdma_req, port2ctba_FetchCFIS_req,
   port2ctba_FetchCFIS_len, pPmpCur, pPMP, ctba2txll_do,
   ctba2txll_ack, ctba2port_FetchCFIS_ack, sys_clk, sys_rst, phyclk,
   phyreset
   );
   input sys_clk;
   input sys_rst;
   
   input phyclk;
   input phyreset;

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		ctba2port_FetchCFIS_ack;// To txll_fsm of txll_fsm.v
   input		ctba2txll_ack;		// To txll_fsm of txll_fsm.v
   input [63:0]		ctba2txll_do;		// To txll_fsm of txll_fsm.v
   input [3:0]		pPMP;			// To txll_fsm of txll_fsm.v
   input [3:0]		pPmpCur;		// To txll_fsm of txll_fsm.v
   input [4:0]		port2ctba_FetchCFIS_len;// To txll_fsm of txll_fsm.v
   input		port2ctba_FetchCFIS_req;// To txll_fsm of txll_fsm.v
   input		port2txdma_req;		// To txll_fsm of txll_fsm.v
   input		port2txll_Push_req;	// To txll_fsm of txll_fsm.v
   input		trn_tdst_dsc_n;		// To txll_ll of txll_ll.v
   input		trn_tdst_rdy_n;		// To txll_ll of txll_ll.v
   input [71:0]		txdma2txll_do;		// To txll_fsm of txll_fsm.v
   input		txdma2txll_push;	// To txll_fsm of txll_fsm.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [31:0]	trn_td;			// From txll_ll of txll_ll.v
   output		trn_teof_n;		// From txll_ll of txll_ll.v
   output		trn_tsof_n;		// From txll_ll of txll_ll.v
   output		trn_tsrc_dsc_n;		// From txll_ll of txll_ll.v
   output		trn_tsrc_rdy_n;		// From txll_ll of txll_ll.v
   output [31:0]	txll2dbg;		// From txll_fsm of txll_fsm.v
   output		txll2port_Push_ack;	// From txll_fsm of txll_fsm.v
   output		txll2port_xfer;		// From txll_fsm of txll_fsm.v
   output		txll2txdma_rdy;		// From txll_fsm of txll_fsm.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			rd_almost_empty;	// From txll_fifo of txll_fifo.v
   wire			rd_clk;			// From txll_ll of txll_ll.v
   wire [9:0]		rd_count;		// From txll_fifo of txll_fifo.v
   wire [35:0]		rd_do;			// From txll_fifo of txll_fifo.v
   wire			rd_empty;		// From txll_fifo of txll_fifo.v
   wire			rd_en;			// From txll_ll of txll_ll.v
   wire			rd_eof_rdy;		// From txll_fifo of txll_fifo.v
   wire			wr_almost_full;		// From txll_fifo of txll_fifo.v
   wire			wr_clk;			// From txll_fsm of txll_fsm.v
   wire [9:0]		wr_count;		// From txll_fifo of txll_fifo.v
   wire [35:0]		wr_di;			// From txll_fsm of txll_fsm.v
   wire			wr_en;			// From txll_fsm of txll_fsm.v
   wire			wr_eof_poped;		// From txll_fifo of txll_fifo.v
   wire			wr_full;		// From txll_fifo of txll_fifo.v
   // End of automatics

   txll_fifo
     txll_fifo (.rst(sys_rst),
	        /*AUTOINST*/
		// Outputs
		.wr_count		(wr_count[9:0]),
		.wr_full		(wr_full),
		.wr_almost_full		(wr_almost_full),
		.wr_eof_poped		(wr_eof_poped),
		.rd_count		(rd_count[9:0]),
		.rd_empty		(rd_empty),
		.rd_almost_empty	(rd_almost_empty),
		.rd_do			(rd_do[35:0]),
		.rd_eof_rdy		(rd_eof_rdy),
		// Inputs
		.wr_di			(wr_di[35:0]),
		.wr_en			(wr_en),
		.wr_clk			(wr_clk),
		.rd_clk			(rd_clk),
		.rd_en			(rd_en));
   txll_fsm
     txll_fsm (/*AUTOINST*/
	       // Outputs
	       .wr_di			(wr_di[35:0]),
	       .wr_en			(wr_en),
	       .wr_clk			(wr_clk),
	       .txll2txdma_rdy		(txll2txdma_rdy),
	       .txll2port_xfer		(txll2port_xfer),
	       .txll2port_Push_ack	(txll2port_Push_ack),
	       .txll2dbg		(txll2dbg[31:0]),
	       // Inputs
	       .sys_clk			(sys_clk),
	       .sys_rst			(sys_rst),
	       .wr_count		(wr_count[9:0]),
	       .wr_full			(wr_full),
	       .wr_almost_full		(wr_almost_full),
	       .wr_eof_poped		(wr_eof_poped),
	       .rd_almost_empty		(rd_almost_empty),
	       .rd_eof_rdy		(rd_eof_rdy),
	       .ctba2txll_do		(ctba2txll_do[63:0]),
	       .ctba2txll_ack		(ctba2txll_ack),
	       .txdma2txll_do		(txdma2txll_do[71:0]),
	       .txdma2txll_push		(txdma2txll_push),
	       .port2txdma_req		(port2txdma_req),
	       .pPMP			(pPMP[3:0]),
	       .pPmpCur			(pPmpCur[3:0]),
	       .port2ctba_FetchCFIS_len	(port2ctba_FetchCFIS_len[4:0]),
	       .port2ctba_FetchCFIS_req	(port2ctba_FetchCFIS_req),
	       .ctba2port_FetchCFIS_ack	(ctba2port_FetchCFIS_ack),
	       .port2txll_Push_req	(port2txll_Push_req));

   txll_ll
     txll_ll (/*AUTOINST*/
	      // Outputs
	      .trn_td			(trn_td[31:0]),
	      .trn_tsof_n		(trn_tsof_n),
	      .trn_teof_n		(trn_teof_n),
	      .trn_tsrc_rdy_n		(trn_tsrc_rdy_n),
	      .trn_tsrc_dsc_n		(trn_tsrc_dsc_n),
	      .rd_clk			(rd_clk),
	      .rd_en			(rd_en),
	      // Inputs
	      .phyclk			(phyclk),
	      .phyreset			(phyreset),
	      .trn_tdst_rdy_n		(trn_tdst_rdy_n),
	      .trn_tdst_dsc_n		(trn_tdst_dsc_n),
	      .rd_count			(rd_count[9:0]),
	      .rd_empty			(rd_empty),
	      .rd_almost_empty		(rd_almost_empty),
	      .rd_do			(rd_do[35:0]),
	      .rd_eof_rdy		(rd_eof_rdy));
   
endmodule
// 
// txll.v ends here
