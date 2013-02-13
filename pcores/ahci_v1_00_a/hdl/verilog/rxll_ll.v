// rxll_ll.v --- 
// 
// Filename: rxll_ll.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Fri Sep 10 12:52:26 2010 (+0800)
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
module rxll_ll (/*AUTOARG*/
   // Outputs
   wr_di, wr_en, wr_clk, wr_ififo_en, rxll2port_fis_hdr,
   rxll2port_rxcount, trn_rdst_rdy_n, trn_rdst_dsc_n,
   // Inputs
   phyclk, phyreset, wr_count, wr_full, wr_almost_full, rd_empty,
   trn_rsof_n, trn_reof_n, trn_rd, trn_rsrc_rdy_n, trn_rsrc_dsc_n
   );
   input phyclk;
   input phyreset;
   
   output [35:0] wr_di;
   output 	 wr_en;
   output 	 wr_clk;
   output        wr_ififo_en;
   input [9:0] 	 wr_count;
   input 	 wr_full;
   input 	 wr_almost_full;
   input         rd_empty;

   output [31:0] rxll2port_fis_hdr;
   output [15:0] rxll2port_rxcount;

   input         trn_rsof_n;
   input         trn_reof_n;
   input [31:0]  trn_rd;
   input         trn_rsrc_rdy_n;
   output        trn_rdst_rdy_n;
   input         trn_rsrc_dsc_n;
   output        trn_rdst_dsc_n;
   /**********************************************************************/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [31:0]		rxll2port_fis_hdr;
   reg [15:0]		rxll2port_rxcount;
   reg [35:0]		wr_di;
   reg			wr_en;
   reg			wr_ififo_en;
   // End of automatics

   /**********************************************************************/
   wire [7:0]           fis_type;
   assign fis_type    = trn_rd[7:0];
   reg 			recv_fis;
   reg                  data_fis;
   always @(posedge wr_clk)
     begin
	if (phyreset)
	  begin
	     recv_fis <= #1 1'b0;
	  end
	else if (trn_rsrc_rdy_n == 1'b0 &&
		 trn_rdst_rdy_n == 1'b0 &&
		 trn_rsof_n == 1'b0 &&
		 trn_reof_n == 1'b1)/* SOF */
	  begin
	     wr_ififo_en       <= #1 fis_type != 8'h46;
	     wr_en             <= #1 fis_type == 8'h46;
	     wr_di[35]         <= #1 1'b1;
	     wr_di[34]         <= #1 1'b0;
	     wr_di[33]         <= #1 fis_type == 8'h46;
	     wr_di[32]         <= #1 1'b0;
	     wr_di[31:0]       <= #1 trn_rd;
	     data_fis          <= #1 fis_type == 8'h46;
	     rxll2port_fis_hdr <= #1 trn_rd;
	     rxll2port_rxcount <= #1 16'h1;
	  end
	else if (trn_rsrc_rdy_n == 1'b0 &&
		 /*trn_rdst_rdy_n == 1'b0 &&*/
		 trn_rsof_n == 1'b1 &&
	         trn_reof_n == 1'b1) /* Data */
	  begin
	     wr_ififo_en       <= #1 ~data_fis;
	     wr_en             <= #1 data_fis;
	     wr_di[35]         <= #1 1'b0;
	     wr_di[31:0]       <= #1 trn_rd;
	     rxll2port_rxcount <= #1 rxll2port_rxcount + 1'b1;
	  end
	else if (trn_rsrc_rdy_n == 1'b0 &&
		 /*trn_rdst_rdy_n == 1'b0 &&*/
		 trn_rsof_n == 1'b1 &&
		 trn_reof_n == 1'b0) /* EOF */
	  begin
	     wr_ififo_en       <= #1 ~data_fis;
	     wr_en             <= #1 data_fis;
	     wr_di[35]         <= #1 1'b0;
	     wr_di[34]         <= #1 1'b1;
	     wr_di[31:0]       <= #1 trn_rd;
	     rxll2port_rxcount <= #1 rxll2port_rxcount + 1'b1;
	  end
	else if (trn_rsrc_rdy_n == 1'b0 &&
		 trn_rdst_rdy_n == 1'b0 &&
		 trn_rsof_n == 1'b0 &&
		 trn_reof_n == 1'b0) /* SOF & EOF */
	  begin
	     wr_ififo_en       <= #1 1'b1;
	     wr_en             <= #1 1'b0;
	     wr_di[35]         <= #1 1'b1;
	     wr_di[34]         <= #1 1'b1;
	     wr_di[31:0]       <= #1 trn_rd;
	     rxll2port_rxcount <= #1 16'h1;
	     rxll2port_fis_hdr <= #1 trn_rd;
	  end
	else
	  begin
	     wr_ififo_en       <= #1 1'b0;
	     wr_en             <= #1 1'b0;
	  end // else: !if(link2dma_rx_push && link2dma_rx_sof && link2dma_rx_eof)
     end // always @ (posedge wr_clk)
   assign trn_rdst_dsc_n = 1'b1;
   localparam C_DEBUG_RX_HOLD = 0;
   reg [7:0] cnt;
   always @(posedge wr_clk)
     begin
	if (phyreset)
	  begin
	     cnt <= #1 16'h0;
	  end
	else 
	  begin
	     cnt <= #1 cnt + 1'b1;
	  end
     end
generate if (C_DEBUG_RX_HOLD == 1)
begin
   assign trn_rdst_rdy_n = cnt[7:6] != 2'b11;
end
endgenerate
generate if (C_DEBUG_RX_HOLD == 0)
begin
   assign trn_rdst_rdy_n = wr_almost_full;
end
endgenerate
   assign wr_clk = phyclk;
endmodule
// 
// rxll_ll.v ends here
