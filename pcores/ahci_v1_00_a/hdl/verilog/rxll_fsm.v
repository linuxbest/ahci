// rxll_fsm.v --- 
// 
// Filename: rxll_fsm.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Fri Sep 10 12:54:49 2010 (+0800)
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
module rxll_fsm (/*AUTOARG*/
   // Outputs
   rd_clk, rd_en, rxll2port_req, rxll2rxdma_rd_eof_rdy,
   rxll2rxdma_rd_do, rxll2rxdma_rd_empty, rxll2dbg,
   // Inputs
   sys_clk, sys_rst, rd_count, rd_empty, rd_almost_empty, rd_do,
   rd_eof_rdy, rxdma2rxll_rd_en, rxll2port_rxcount, wr_almost_full,
   wr_full, ififo2port_empty, ififo2port_fis_hdr
   );
   input sys_clk;
   input sys_rst;
   
   input [9:0] rd_count;
   input       rd_empty;
   input       rd_almost_empty;
   input [35:0]rd_do;
   input       rd_eof_rdy;
   output      rd_clk;
   output      rd_en;
   
   output      rxll2port_req;

   output        rxll2rxdma_rd_eof_rdy;
   output [35:0] rxll2rxdma_rd_do;
   output        rxll2rxdma_rd_empty;
   input         rxdma2rxll_rd_en;
   output [31:0] rxll2dbg;

   input [15:0]  rxll2port_rxcount;
   input         wr_almost_full;
   input         wr_full;
   input         ififo2port_empty;
   input [31:0]  ififo2port_fis_hdr;
   /**********************************************************************/
   /*AUTOREG*/
   
   /**********************************************************************/
   assign rd_clk              = sys_clk;
   assign rd_en               = rxdma2rxll_rd_en;
   assign rxll2rxdma_rd_do    = rd_do;
   assign rxll2rxdma_rd_empty = rd_empty;

   assign rxll2port_req       = ~rd_empty;

   assign rxll2rxdma_rd_eof_rdy= rd_eof_rdy;
   /**********************************************************************/
   assign rxll2dbg[31]        = rd_almost_empty;
   assign rxll2dbg[30]        = rd_empty;
   assign rxll2dbg[29]        = wr_almost_full;
   assign rxll2dbg[28]        = wr_full;
   assign rxll2dbg[27]        = ififo2port_empty;
   assign rxll2dbg[23:16]     = ififo2port_fis_hdr;
   assign rxll2dbg[15:0]      = rxll2port_rxcount;
endmodule
// 
// rxll_fsm.v ends here
