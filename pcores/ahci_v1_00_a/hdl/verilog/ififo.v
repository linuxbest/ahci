// ififo.v --- 
// 
// Filename: ififo.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Thu Sep 16 11:58:58 2010 (+0800)
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
module ififo (/*AUTOARG*/
   // Outputs
   ififo2port_empty, ififo2port_fis_hdr, ififo2rxdma_ndr_rd_do,
   ififo2dcr_PxSIG, ififo2port_Estatus, ififo2port_Transfer_Count,
   ififo2port_DS_TAG, ififo2port_DS_offset, ififo2port_DS_Count,
   ififo2port_SDB_SActive,
   // Inputs
   sys_clk, sys_rst, rxdma2ififo_ndr_rd_en, wr_di, wr_ififo_en,
   wr_clk
   );
   input sys_clk;
   input sys_rst;

   output		ififo2port_empty;
   output [31:0]	ififo2port_fis_hdr;

   output [35:0]        ififo2rxdma_ndr_rd_do;
   input                rxdma2ififo_ndr_rd_en;

   input [35:0]         wr_di;
   input                wr_ififo_en;
   input                wr_clk;
   
   output [31:0] 	ififo2dcr_PxSIG;
   output [7:0] 	ififo2port_Estatus;
   output [15:0] 	ififo2port_Transfer_Count;
   output [5:0] 	ififo2port_DS_TAG;
   output [31:0] 	ififo2port_DS_offset;
   output [31:0] 	ififo2port_DS_Count;
   output [31:0] 	ififo2port_SDB_SActive;
   /**********************************************************************/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [31:0]		ififo2dcr_PxSIG;
   reg [31:0]		ififo2port_DS_Count;
   reg [5:0]		ififo2port_DS_TAG;
   reg [31:0]		ififo2port_DS_offset;
   reg [7:0]		ififo2port_Estatus;
   reg [31:0]		ififo2port_SDB_SActive;
   reg [15:0]		ififo2port_Transfer_Count;
   reg [31:0]		ififo2port_fis_hdr;
   // End of automatics

   wire ififo2port_empty;
   wire [35:0] ififo2rxdma_ndr_rd_do;
   /**********************************************************************/
   FIFO18_36
     rx_fifo (
	      // Outputs
	      .ALMOSTEMPTY		(),
	      .ALMOSTFULL		(),
	      .DO			(ififo2rxdma_ndr_rd_do[31:0]),
	      .DOP			(ififo2rxdma_ndr_rd_do[35:32]),
	      .EMPTY			(),
	      .FULL			(),
	      .RDCOUNT			(),
	      .RDERR			(),
	      .WRCOUNT			(),
	      .WRERR			(),
	      // Inputs
	      .DI			(wr_di[31:0]),
	      .DIP			(wr_di[35:32]),
	      .RDCLK			(sys_clk),
	      .RDEN			(rxdma2ififo_ndr_rd_en),
	      .RST			(sys_rst),
	      .WRCLK			(wr_clk),
	      .WREN			(wr_ififo_en));
   defparam rx_fifo.FIRST_WORD_FALL_THROUGH = "TRUE";
   /**********************************************************************/
   reg [2:0] 		cnt;
   always @(posedge sys_clk)
     begin
	if (ififo2rxdma_ndr_rd_do[35] == 1'b1 && ~rxdma2ififo_ndr_rd_en)
	  begin
	     cnt <= #1 3'h0;
	  end
	else if (rxdma2ififo_ndr_rd_en)
	  begin
	     cnt <= #1 cnt + 1'b1;
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (ififo2rxdma_ndr_rd_do[35])
	  begin
	     ififo2port_fis_hdr     <= #1 ififo2rxdma_ndr_rd_do[31:00];
	  end
	else if (cnt == 3'h1 && rxdma2ififo_ndr_rd_en)
	  begin
	     ififo2dcr_PxSIG[31:24] <= #1 ififo2rxdma_ndr_rd_do[23:16]; /* LBA High */
	     ififo2dcr_PxSIG[23:16] <= #1 ififo2rxdma_ndr_rd_do[15:08]; /* LBA Mid  */
	     ififo2dcr_PxSIG[15:08] <= #1 ififo2rxdma_ndr_rd_do[07:00]; /* LBA Low  */
	     ififo2port_DS_TAG      <= #1 ififo2rxdma_ndr_rd_do[05:00];
	     ififo2port_SDB_SActive <= #1 ififo2rxdma_ndr_rd_do[31:00];
	  end
	else if (cnt == 3'h3 && rxdma2ififo_ndr_rd_en)
	  begin
	     ififo2dcr_PxSIG[7:0]   <= #1 ififo2rxdma_ndr_rd_do[07:00]; /* Sector count */
	     ififo2port_Estatus     <= #1 ififo2rxdma_ndr_rd_do[31:24];
	  end
	else if (cnt == 3'h4 && rxdma2ififo_ndr_rd_en)
	  begin
	     ififo2port_Transfer_Count <= #1 ififo2rxdma_ndr_rd_do[15:00];
	     ififo2port_DS_offset      <= #1 ififo2rxdma_ndr_rd_do[31:00];
	  end
	else if (cnt == 3'h5 && rxdma2ififo_ndr_rd_en)
	  begin
	     ififo2port_DS_Count       <= #1 ififo2rxdma_ndr_rd_do[31:00];
	  end
     end // always @ (posedge sys_clk)

   wire 	 wr_eof;
   reg_sync
     eof (.wclk(wr_clk),
	  .rclk(sys_clk),
	  .rst(sys_rst),
	  .set(wr_ififo_en && wr_di[34]),
	  .sts(wr_eof));
   reg 		 rd_eof_rdy;
   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     rd_eof_rdy <= #1 1'b0;
	  end
	else if (wr_eof)
	  begin
	     rd_eof_rdy <= #1 1'b1;
	  end
	else if (rxdma2ififo_ndr_rd_en && ififo2rxdma_ndr_rd_do[34])
	  begin
	     rd_eof_rdy <= #1 1'b0;
	  end
     end // always @ (posedge rd_clk)
   assign ififo2port_empty = ~rd_eof_rdy;
endmodule
// 
// ififo.v ends here
