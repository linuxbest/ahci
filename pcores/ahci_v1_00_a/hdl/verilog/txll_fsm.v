// txll_fsm.v --- 
// 
// Filename: txll_fsm.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Fri Sep 10 12:57:08 2010 (+0800)
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
module txll_fsm (/*AUTOARG*/
   // Outputs
   wr_di, wr_en, wr_clk, txll2txdma_rdy, txll2port_xfer,
   txll2port_Push_ack, txll2dbg,
   // Inputs
   sys_clk, sys_rst, wr_count, wr_full, wr_almost_full, wr_eof_poped,
   rd_almost_empty, rd_eof_rdy, ctba2txll_do, ctba2txll_ack,
   txdma2txll_do, txdma2txll_push, port2txdma_req, pPMP, pPmpCur,
   port2ctba_FetchCFIS_len, port2ctba_FetchCFIS_req,
   ctba2port_FetchCFIS_ack, port2txll_Push_req
   );
   input sys_clk;
   input sys_rst;

   output [35:0] wr_di;
   output 	 wr_en;
   output 	 wr_clk;
   input [9:0] 	 wr_count;
   input 	 wr_full;
   input 	 wr_almost_full;
   input 	 wr_eof_poped;
   input         rd_almost_empty;
   input         rd_eof_rdy;

   input [63:0]  ctba2txll_do;
   input         ctba2txll_ack;

   input [71:0]  txdma2txll_do;
   input         txdma2txll_push;
   output        txll2txdma_rdy;

   input 	 port2txdma_req;
   output        txll2port_xfer;
   input [3:0]   pPMP;
   input [3:0]   pPmpCur;

   input [4:0]   port2ctba_FetchCFIS_len;
   input 	 port2ctba_FetchCFIS_req;
   input 	 ctba2port_FetchCFIS_ack;

   input 	 port2txll_Push_req;
   output 	 txll2port_Push_ack;

   output [31:0] txll2dbg;
   /**********************************************************************/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [35:0]		wr_di;
   reg			wr_en;
   // End of automatics
   
   /**********************************************************************/
   localparam [2:0] // synopsys enum state_info
     S_IDLE = 3'h0,
     S_WAIT = 3'h1,
     S_SOF  = 3'h2,
     S_DATA = 3'h3,
     S_DONE = 3'h4,
     S_NEXT = 3'h5;
   reg [2:0] // synopsys enum state_info
	     state, state_ns;
   wire [63:0] wrfifo_rd_do;
   wire [3:0]  wrfifo_rd_dop0;
   wire [3:0]  wrfifo_rd_dop1;
   wire        wrfifo_rd_empty;
   wire [71:0] wrfifo_wr_di;
   wire        wrfifo_wr_en;
   wire        wrfifo_rd_en;
   reg [4:0]  len;
   reg [4:0]  eof_len;
   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     state <= #1 S_IDLE;
	  end
	else
	  begin
	     state <= #1 state_ns;
	  end
     end // always @ (posedge sys_clk)
   wire   frm_sof;
   wire   frm_eof;
   reg 	  arb;
   reg [7:0] rst_sync;
   always @(*)
     begin
	state_ns = state;
	case (state)
	  S_IDLE:
	    begin
	       if (port2txll_Push_req | port2txdma_req)
		 begin
		    state_ns = S_WAIT;
		 end
	    end // case: S_IDLE
	  S_WAIT:
	    begin
	       if (~wrfifo_rd_empty && ~wr_almost_full)
		 begin
		    state_ns = S_SOF;
		 end
	    end // case: S_WAIT
	  S_SOF:
	    begin
	       state_ns = S_DATA;
	    end
	  S_DATA:
	    begin
	       if (len == eof_len && arb)
		 begin
		    state_ns = S_DONE;
		 end
	       else if (port2txdma_req & frm_eof)
		 begin
		    state_ns = S_DONE;
		 end
	    end
	  S_DONE:
	    begin
	       if (wrfifo_rd_empty && wr_eof_poped)
		 begin
		    state_ns = S_NEXT;
		 end
	    end // case: S_DONE
	  S_NEXT:
	    begin
	       if (port2txll_Push_req == 1'b0 &&
		   port2txdma_req == 1'b0)
		 begin
		    state_ns = S_IDLE;
		 end
	    end
	endcase // case (state)
     end // always @ (*)
   assign txll2port_Push_ack = state == S_DONE && wrfifo_rd_empty && wr_eof_poped;
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE && port2txll_Push_req)
	  begin
	     eof_len <= #1 port2ctba_FetchCFIS_len - 1'b1;
	  end
     end
   wire [35:0] wr_en_comp;
   wire [35:0] wr_di_comp;
   wire wrfifo_almost_full;
   wire wrfifo_rderr;
   wire wrfifo_wrerr;
   assign txll2txdma_rdy = ~(wr_almost_full || wrfifo_almost_full);
   /**********************************************************************/
   assign wrfifo_wr_di = arb ? ctba2txll_do : txdma2txll_do;
   assign wrfifo_wr_en = arb ? ctba2txll_ack: txdma2txll_push;
   FIFO36_72
     wrfifo (
	     // Outputs
	     .ALMOSTEMPTY		(),
	     .ALMOSTFULL		(wrfifo_almost_full),
	     .DBITERR			(),
	     .DO			(wrfifo_rd_do[63:0]),
	     .DOP			({wrfifo_rd_dop1, wrfifo_rd_dop0}),
	     .ECCPARITY			(),
	     .EMPTY			(wrfifo_rd_empty),
	     .FULL			(),
	     .RDCOUNT			(),
	     .RDERR			(wrfifo_rderr),
	     .SBITERR			(),
	     .WRCOUNT			(),
	     .WRERR			(wrfifo_wrerr),
	     // Inputs
	     .DI			(wrfifo_wr_di[63:0]),
	     .DIP			(wrfifo_wr_di[71:64]),
	     .RDCLK			(sys_clk),
	     .RDEN			(wrfifo_rd_en),
	     .RST			(sys_rst),
	     .WRCLK			(sys_clk),
	     .WREN			(wrfifo_wr_en));
   defparam wrfifo.FIRST_WORD_FALL_THROUGH = "TRUE";

   reg pop;
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE)
	  begin
	     pop <= #1 1'b0;
	     len <= #1 5'h0;
	     arb <= #1 port2txll_Push_req;
	  end
	else if (wr_en_comp)
	  begin
	     pop <= #1 ~pop;
	     len <= #1 len + 1'b1;
	  end
     end // always @ (posedge sys_clk)
   wire   wrfifo_rd_eof;
   assign wrfifo_rd_en     = (pop && wr_en_comp) | (state == S_DONE);
   assign wr_en_comp       = ~wrfifo_rd_empty && ~wr_almost_full && (state == S_SOF || state == S_DATA);
   assign wr_di_comp[31:0] = pop ? wrfifo_rd_do[63:32] : wrfifo_rd_do[31:0];
   assign wr_di_comp[35]   = arb ? state == S_SOF : wrfifo_rd_dop0[3] && 1'b0;
   assign wr_di_comp[34]   = arb ? state == S_DATA && eof_len == len : wrfifo_rd_eof;
   assign wr_di_comp[33:32]= 3'h0;
   assign wr_clk      = sys_clk;
   assign frm_sof     = wr_di[35] && wr_en;
   assign frm_eof     = wr_di[34] && wr_en;
   assign wrfifo_rd_eof=(wrfifo_rd_dop0[2] && pop) | (wrfifo_rd_dop1[2] && ~pop);
   assign txll2port_xfer = wr_en_comp;

   reg [35:0] wr_di_p1;
   reg 	      wr_en_p1;
   always @(posedge sys_clk)
     begin
	if (state == S_SOF && port2txdma_req)
	  begin
	     wr_en       <= #1 1'b1;
	     wr_di[34:0] <= #1 {pPMP, 8'h46};
	     wr_di[35]   <= #1 1'b1;
	     wr_en_p1    <= #1 1'b1;
	  end
	else 
	  begin
	     wr_en_p1    <= #1 wr_en_comp;
	     wr_di_p1    <= #1 wr_di_comp;
	     wr_en       <= #1 wr_en_p1;
	     wr_di       <= #1 wr_di_p1;
	  end
     end // always @ (posedge sys_clk)
   assign txll2dbg[7:0] = state;
   assign txll2dbg[8]   = wrfifo_rd_empty;
   assign txll2dbg[9]   = wr_almost_full;
   assign txll2dbg[10]  = wrfifo_almost_full;
   assign txll2dbg[11]  = rd_almost_empty;
   assign txll2dbg[12]  = wr_eof_poped;
   assign txll2dbg[13]  = rd_eof_rdy;
   assign txll2dbg[14]  = arb;
   assign txll2dbg[31:24]=len;
   assign txll2dbg[23:16]=eof_len;
   /**********************************************************************/
   /*AUTOASCIIENUM("state", "state_ascii", "S_")*/
   // Beginning of automatic ASCII enum decoding
   reg [31:0]		state_ascii;		// Decode of state
   always @(state) begin
      case ({state})
	S_IDLE:   state_ascii = "idle";
	S_WAIT:   state_ascii = "wait";
	S_SOF:    state_ascii = "sof ";
	S_DATA:   state_ascii = "data";
	S_DONE:   state_ascii = "done";
	S_NEXT:   state_ascii = "next";
	default:  state_ascii = "%Err";
      endcase
   end
   // End of automatics
endmodule
// 
// txll_fsm.v ends here
