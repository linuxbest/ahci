// rxll.v --- 
// 
// Filename: rxll.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Fri Sep 10 12:32:43 2010 (+0800)
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
module rxll (/*AUTOARG*/
   // Outputs
   trn_rdst_rdy_n, trn_rdst_dsc_n, rxll2rxdma_rd_eof_rdy,
   rxll2rxdma_rd_empty, rxll2rxdma_rd_do, rxll2port_fis_hdr, rxll2dbg,
   ififo2rxdma_ndr_rd_do, ififo2port_Transfer_Count,
   ififo2port_SDB_SActive, ififo2port_Estatus, ififo2port_DS_offset,
   ififo2port_DS_TAG, ififo2port_DS_Count, ififo2dcr_PxSIG,
   rxll2port_rxcount, ififo2port_empty, ififo2port_fis_hdr,
   rxll2port_req,
   // Inputs
   trn_rsrc_rdy_n, trn_rsrc_dsc_n, trn_rsof_n, trn_reof_n, trn_rd,
   rxdma2rxll_rd_en, rxdma2ififo_ndr_rd_en, sys_clk, sys_rst,
   phyreset, phyclk
   );
   input sys_clk;
   input sys_rst;

   output [15:0]       rxll2port_rxcount;
   output              ififo2port_empty;
   output [31:0]       ififo2port_fis_hdr;
   output              rxll2port_req;

   input  phyreset;
   input  phyclk;
	
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		rxdma2ififo_ndr_rd_en;	// To ififo of ififo.v
   input		rxdma2rxll_rd_en;	// To rxll_fsm of rxll_fsm.v
   input [31:0]		trn_rd;			// To rxll_ll of rxll_ll.v
   input		trn_reof_n;		// To rxll_ll of rxll_ll.v
   input		trn_rsof_n;		// To rxll_ll of rxll_ll.v
   input		trn_rsrc_dsc_n;		// To rxll_ll of rxll_ll.v
   input		trn_rsrc_rdy_n;		// To rxll_ll of rxll_ll.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [31:0]	ififo2dcr_PxSIG;	// From ififo of ififo.v
   output [31:0]	ififo2port_DS_Count;	// From ififo of ififo.v
   output [5:0]		ififo2port_DS_TAG;	// From ififo of ififo.v
   output [31:0]	ififo2port_DS_offset;	// From ififo of ififo.v
   output [7:0]		ififo2port_Estatus;	// From ififo of ififo.v
   output [31:0]	ififo2port_SDB_SActive;	// From ififo of ififo.v
   output [15:0]	ififo2port_Transfer_Count;// From ififo of ififo.v
   output [35:0]	ififo2rxdma_ndr_rd_do;	// From ififo of ififo.v
   output [31:0]	rxll2dbg;		// From rxll_fsm of rxll_fsm.v
   output [31:0]	rxll2port_fis_hdr;	// From rxll_ll of rxll_ll.v
   output [35:0]	rxll2rxdma_rd_do;	// From rxll_fsm of rxll_fsm.v
   output		rxll2rxdma_rd_empty;	// From rxll_fsm of rxll_fsm.v
   output		rxll2rxdma_rd_eof_rdy;	// From rxll_fsm of rxll_fsm.v
   output		trn_rdst_dsc_n;		// From rxll_ll of rxll_ll.v
   output		trn_rdst_rdy_n;		// From rxll_ll of rxll_ll.v
   // End of automatics
    
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			rd_almost_empty;	// From rxll_fifo of rxll_fifo.v
   wire			rd_clk;			// From rxll_fsm of rxll_fsm.v
   wire [9:0]		rd_count;		// From rxll_fifo of rxll_fifo.v
   wire [35:0]		rd_do;			// From rxll_fifo of rxll_fifo.v
   wire			rd_empty;		// From rxll_fifo of rxll_fifo.v
   wire			rd_en;			// From rxll_fsm of rxll_fsm.v
   wire			rd_eof_rdy;		// From rxll_fifo of rxll_fifo.v
   wire			wr_almost_full;		// From rxll_fifo of rxll_fifo.v
   wire			wr_clk;			// From rxll_ll of rxll_ll.v
   wire [9:0]		wr_count;		// From rxll_fifo of rxll_fifo.v
   wire [35:0]		wr_di;			// From rxll_ll of rxll_ll.v
   wire			wr_en;			// From rxll_ll of rxll_ll.v
   wire			wr_full;		// From rxll_fifo of rxll_fifo.v
   wire			wr_ififo_en;		// From rxll_ll of rxll_ll.v
   // End of automatics
   rxll_fifo
     rxll_fifo(.rst(sys_rst),
	       /*AUTOINST*/
	       // Outputs
	       .wr_count		(wr_count[9:0]),
	       .wr_full			(wr_full),
	       .wr_almost_full		(wr_almost_full),
	       .rd_count		(rd_count[9:0]),
	       .rd_empty		(rd_empty),
	       .rd_almost_empty		(rd_almost_empty),
	       .rd_do			(rd_do[35:0]),
	       .rd_eof_rdy		(rd_eof_rdy),
	       // Inputs
	       .wr_di			(wr_di[35:0]),
	       .wr_en			(wr_en),
	       .wr_clk			(wr_clk),
	       .rd_clk			(rd_clk),
	       .rd_en			(rd_en));

   ififo
     ififo (/*AUTOINST*/
	    // Outputs
	    .ififo2port_empty		(ififo2port_empty),
	    .ififo2port_fis_hdr		(ififo2port_fis_hdr[31:0]),
	    .ififo2rxdma_ndr_rd_do	(ififo2rxdma_ndr_rd_do[35:0]),
	    .ififo2dcr_PxSIG		(ififo2dcr_PxSIG[31:0]),
	    .ififo2port_Estatus		(ififo2port_Estatus[7:0]),
	    .ififo2port_Transfer_Count	(ififo2port_Transfer_Count[15:0]),
	    .ififo2port_DS_TAG		(ififo2port_DS_TAG[5:0]),
	    .ififo2port_DS_offset	(ififo2port_DS_offset[31:0]),
	    .ififo2port_DS_Count	(ififo2port_DS_Count[31:0]),
	    .ififo2port_SDB_SActive	(ififo2port_SDB_SActive[31:0]),
	    // Inputs
	    .sys_clk			(sys_clk),
	    .sys_rst			(sys_rst),
	    .rxdma2ififo_ndr_rd_en	(rxdma2ififo_ndr_rd_en),
	    .wr_di			(wr_di[35:0]),
	    .wr_ififo_en		(wr_ififo_en),
	    .wr_clk			(wr_clk));
   
   rxll_fsm
     rxll_fsm (/*AUTOINST*/
	       // Outputs
	       .rd_clk			(rd_clk),
	       .rd_en			(rd_en),
	       .rxll2port_req		(rxll2port_req),
	       .rxll2rxdma_rd_eof_rdy	(rxll2rxdma_rd_eof_rdy),
	       .rxll2rxdma_rd_do	(rxll2rxdma_rd_do[35:0]),
	       .rxll2rxdma_rd_empty	(rxll2rxdma_rd_empty),
	       .rxll2dbg		(rxll2dbg[31:0]),
	       // Inputs
	       .sys_clk			(sys_clk),
	       .sys_rst			(sys_rst),
	       .rd_count		(rd_count[9:0]),
	       .rd_empty		(rd_empty),
	       .rd_almost_empty		(rd_almost_empty),
	       .rd_do			(rd_do[35:0]),
	       .rd_eof_rdy		(rd_eof_rdy),
	       .rxdma2rxll_rd_en	(rxdma2rxll_rd_en),
	       .rxll2port_rxcount	(rxll2port_rxcount[15:0]),
	       .wr_almost_full		(wr_almost_full),
	       .wr_full			(wr_full),
	       .ififo2port_empty	(ififo2port_empty),
	       .ififo2port_fis_hdr	(ififo2port_fis_hdr[31:0]));
   
   rxll_ll
     rxll_ll (/*AUTOINST*/
	      // Outputs
	      .wr_di			(wr_di[35:0]),
	      .wr_en			(wr_en),
	      .wr_clk			(wr_clk),
	      .wr_ififo_en		(wr_ififo_en),
	      .rxll2port_fis_hdr	(rxll2port_fis_hdr[31:0]),
	      .rxll2port_rxcount	(rxll2port_rxcount[15:0]),
	      .trn_rdst_rdy_n		(trn_rdst_rdy_n),
	      .trn_rdst_dsc_n		(trn_rdst_dsc_n),
	      // Inputs
	      .phyclk			(phyclk),
	      .phyreset			(phyreset),
	      .wr_count			(wr_count[9:0]),
	      .wr_full			(wr_full),
	      .wr_almost_full		(wr_almost_full),
	      .rd_empty			(rd_empty),
	      .trn_rsof_n		(trn_rsof_n),
	      .trn_reof_n		(trn_reof_n),
	      .trn_rd			(trn_rd[31:0]),
	      .trn_rsrc_rdy_n		(trn_rsrc_rdy_n),
	      .trn_rsrc_dsc_n		(trn_rsrc_dsc_n));
endmodule
// 
// rxll.v ends here
