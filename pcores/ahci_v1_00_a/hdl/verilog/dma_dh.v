// dma_dh.v --- 
// 
// Filename: dma_dh.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Tue Sep  7 16:50:26 2010 (+0800)
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
module dma_dh (/*AUTOARG*/
   // Outputs
   dh2tx_ack, dh2tx_err, tx2al_req, tx2al_len, txdma2txll_do,
   txdma2txll_push, npi_addr, npi_len, npi_req, npi_rdy, txdmadh2dbg,
   // Inputs
   sys_clk, sys_rst, tx2dh_req, tx2dh_len, dh2al_ack, al2dh_ack,
   al2dh_err, al2dh_last, al2dh_addr, al2dh_len, txll2txdma_rdy,
   npi_ack, npi_rem, pPMP, pPmpCur, npi_data, npi_valid, npi_last
   );
   parameter C_BIG_ENDIAN = 1;
   input sys_clk;
   input sys_rst;

   input tx2dh_req;
   input [13:0] tx2dh_len;
   output 	dh2tx_ack;
   output 	dh2tx_err;
   input        dh2al_ack;

   output 	 tx2al_req;
   output [13:0] tx2al_len;
   input 	 al2dh_ack;
   input 	 al2dh_err;
   input 	 al2dh_last;
   input [31:0]  al2dh_addr;
   input [13:0]  al2dh_len;
   
   output [71:0] txdma2txll_do;
   output 	 txdma2txll_push;
   input 	 txll2txdma_rdy;
   
   output [35:0] npi_addr;
   output [13:0] npi_len;
   output 	 npi_req;
   output 	 npi_rdy;
   input 	 npi_ack;
   input 	 npi_rem;

   input [3:0]   pPMP;
   input [3:0]   pPmpCur;
   
   input [63:0]  npi_data;
   input 	 npi_valid;
   input 	 npi_last;

   output [31:0] txdmadh2dbg;
   /************************************************************************/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			npi_req;
   reg [13:0]		tx2al_len;
   reg			tx2al_req;
   reg			txdma2txll_push;
   // End of automatics

   reg frm_end;
   /************************************************************************/
   localparam [2:0] 	// synopsys enum state_info
     S_IDLE = 3'h0,
     S_REQ  = 3'h1,
     S_DATA = 3'h2,
     S_POST = 3'h3,
     S_NEXT = 3'h4,
     S_ERROR= 3'h5,
     S_DONE = 3'h6;
   reg [2:0]// synopsys enum state_info
	    state, state_ns;
   always @(posedge sys_clk)
     begin
	if (sys_rst || dh2al_ack)
	  begin
	     state <= #1 S_IDLE;
	  end
	else
	  begin
	     state <= #1 state_ns;
	  end
     end // always @ (posedge sys_clk)
   always @(*)
     begin
	state_ns = state;
	case (state)
	  S_IDLE: if (tx2dh_req && npi_rdy)
	    begin
	       state_ns = S_REQ;
	    end
	  S_REQ: if (al2dh_ack && ~al2dh_err)
	    begin
	       state_ns = S_DATA;
	    end
	  else if (al2dh_err)
	    begin
	       state_ns = S_ERROR;
	    end
	  S_DATA: if (npi_ack)
	    begin
	       state_ns = S_POST;
	    end
	  S_POST:
	    begin
	       state_ns = S_NEXT;
	    end
	  S_NEXT: if (frm_end)
	    begin
	       state_ns = S_DONE;
	    end
	  else if (npi_rdy)
	    begin
	       state_ns = S_REQ;
	    end
	  S_ERROR:
	    begin
	    end
	  S_DONE:
	    begin
	       state_ns = S_IDLE;
	    end
	endcase
     end // always @ (*)
   assign dh2tx_ack = state == S_DONE;
   assign dh2tx_err = state == S_ERROR;
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE && tx2dh_req)
	  begin
	     tx2al_len <= #1 tx2dh_len;
	  end
	else if (state == S_POST)
	  begin
	     tx2al_len <= #1 tx2al_len - al2dh_len;
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (state == S_REQ && ~al2dh_ack)
	  begin
	     tx2al_req <= #1 1'b1;
	  end
	else
	  begin
	     tx2al_req <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE && tx2dh_req)
	  begin
	     frm_end <= #1 1'b0;
	  end
	else if (state == S_POST && tx2al_len == al2dh_len)
	  begin
	     frm_end <= #1 1'b1;	     
	  end
     end // always @ (posedge sys_clk)
   
   always @(posedge sys_clk)
     begin
	if (state == S_DATA && ~npi_ack)
	  begin
	     npi_req <= #1 1'b1;
	  end
	else
	  begin
	     npi_req <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   assign npi_addr = al2dh_addr;
   assign npi_len  = al2dh_len;
   assign npi_rdy  = txll2txdma_rdy;
  
   wire [63:0] npi_data_le;
   genvar      i;
   generate
      for (i = 0; i < 64; i = i + 8) begin: rdfifo_swap
	 assign npi_data_le[i+7:i] = npi_data[63-i:56-i];
      end
   endgenerate

   reg [3:0] d3p;
   reg [3:0] d7p;
   reg [31:0] data0;
   reg [31:0] data1;
   reg frm_sof;
   reg frm_eof;
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE)
	  begin
	     frm_sof <= #1 1'b1;
	     frm_eof <= #1 1'b0;
	  end
	else if (npi_valid)
	  begin
	     frm_sof <= #1 1'b0;
	     frm_eof <= #1 (tx2al_len == al2dh_len) || al2dh_last;
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (npi_valid && frm_sof)
	  begin
	     d3p            <= #1 4'b1010;	// SOF & Data 
	     d7p            <= #1 4'b0000;
	     txdma2txll_push<= #1 1'b1;
	     data0          <= #1 npi_data_le[63:32];
	     data1          <= #1 npi_data_le[31:00];
	  end
	else if (npi_valid && frm_eof && npi_last)
	  begin
	     d3p            <= #1 4'b0000;
	     d7p            <= #1 4'b0100;	// EOF
	     txdma2txll_push<= #1 1'b1;
	     data0          <= #1 npi_data_le[63:32];
	     data1          <= #1 npi_data_le[31:00];
	  end
	else if (npi_valid)
	  begin
	     d3p            <= #1 4'b0000;
	     d7p            <= #1 4'b0000;
	     txdma2txll_push<= #1 1'b1;
	     data0          <= #1 npi_data_le[63:32];
	     data1          <= #1 npi_data_le[31:00];
	  end
	else
	  begin
	     txdma2txll_push<= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   assign txdma2txll_do = {d3p, d7p, data0, data1};
   assign txdmadh2dbg[7:0] = state;
   /************************************************************************/
   /*AUTOASCIIENUM("state", "state_ascii", "S_")*/
   // Beginning of automatic ASCII enum decoding
   reg [39:0]		state_ascii;		// Decode of state
   always @(state) begin
      case ({state})
	S_IDLE:   state_ascii = "idle ";
	S_REQ:    state_ascii = "req  ";
	S_DATA:   state_ascii = "data ";
	S_POST:   state_ascii = "post ";
	S_NEXT:   state_ascii = "next ";
	S_ERROR:  state_ascii = "error";
	S_DONE:   state_ascii = "done ";
	default:  state_ascii = "%Erro";
      endcase
   end
   // End of automatics
endmodule
// 
// dma_dh.v ends here
