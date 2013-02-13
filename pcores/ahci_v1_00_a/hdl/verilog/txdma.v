// txdma.v --- 
// 
// Filename: txdma.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Fri Sep 10 12:28:20 2010 (+0800)
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
module txdma(/*AUTOARG*/
   // Outputs
   txdma2port_ack, txdma2port_sts, txdma2port_idle, tx2dh_req,
   tx2dh_len, ctrl_dst_rdy2, txdma2dbg,
   // Inputs
   port2txdma_req, port2txdma_len, sys_clk, sys_rst, dh2tx_ack,
   dh2tx_err, ctrl_src_rdy_n, ctrl_data, txdma2txll_push
   );
`include "ll/sata.v"
   parameter C_NUM_WIDTH = 5;
   parameter C_BIG_ENDIAN = 1;
   input sys_clk;
   input sys_rst;

   /*AUTOINOUTCOMP("port", "txdma2port")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output		txdma2port_ack;
   output [31:0]	txdma2port_sts;
   output		txdma2port_idle;
   // End of automatics
   /*AUTOINOUTCOMP("port", "port2txdma")*/
   // Beginning of automatic in/out/inouts (from specific module)
   input		port2txdma_req;
   input [31:0]		port2txdma_len;
   // End of automatics

   output 		tx2dh_req;
   output [13:0] 	tx2dh_len;
   input 		dh2tx_ack;
   input 		dh2tx_err;

   input                ctrl_src_rdy_n;
   output 		ctrl_dst_rdy2;   
   input [31:0] 	ctrl_data;

   input 		txdma2txll_push;
   /**********************************************************************/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			ctrl_dst_rdy2;
   reg [13:0]		tx2dh_len;
   reg			tx2dh_req;
   reg			txdma2port_idle;
   reg [31:0]		txdma2port_sts;
   // End of automatics

   output [31:0] txdma2dbg;
   /************************************************************************/
   /*AUTOREG*/

   reg                  txdma_empty;
   reg 			tx2dh_last_frm;
   /************************************************************************/
   localparam [2:0] // synopsys enum state_info
     S_IDLE  = 3'h0,
     S_REQ   = 3'h1,
     S_DATA  = 3'h2,
     S_NEXT  = 3'h3,
     S_DONE  = 3'h4, 
     S_ERROR = 3'h5;
   reg [2:0]	// synopsys enum state_info
		state, state_ns;
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
   always @(*)
     begin
	state_ns = state;
	case (state)
	  S_IDLE: if (port2txdma_req)
	    begin
	       state_ns = S_REQ;
	    end
	  S_REQ: 
	    begin
	       state_ns = S_DATA;
	    end
	  S_DATA: if (dh2tx_ack && ~dh2tx_err)
	    begin
	       state_ns = S_NEXT;
	    end
	  else if (dh2tx_err && txdma_empty)
	    begin
	       state_ns = S_DONE;
	    end
	  else if (dh2tx_err && ~txdma_empty)
	    begin
	       state_ns = S_NEXT;
	    end
	  S_NEXT: if (ctrl_src_rdy_n == 1'b0 &&
		      ctrl_data == C_R_OK && 
		      (tx2dh_last_frm | dh2tx_err))
	    begin
	       state_ns = S_DONE;
	    end
	  else if (ctrl_src_rdy_n == 1'b0 &&
		   ctrl_data == C_R_OK)
	    begin
	       state_ns = S_DATA;
	    end
	  else if (ctrl_src_rdy_n == 1'b0 &&
		   ctrl_data != C_R_OK)
	    begin
	       state_ns = S_DONE;
	    end
	  S_DONE: if (~port2txdma_req)
	    begin
	       state_ns = S_IDLE;
	    end
	endcase
     end // always @ (*)
   assign txdma2port_ack = state == S_DONE;
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE)
	  begin
	     txdma_empty <= #1 1'b1;
	  end
	else if (txdma2txll_push)
	  begin
	     txdma_empty <= #1 1'b0;	     
	  end
	else if (state == S_NEXT)
	  begin
	     txdma_empty <= #1 1'b1;
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (state == S_NEXT &&
	    ctrl_src_rdy_n == 1'b0)
	  begin
	     txdma2port_sts <= #1 ctrl_data;
	     ctrl_dst_rdy2 <= #1 1'b1;
	  end
	else
	  begin
	     ctrl_dst_rdy2 <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (state == S_DATA && ~dh2tx_ack)
	  begin
	     tx2dh_req <= #1 1'b1;
	  end
	else
	  begin
	     tx2dh_req <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)

   reg [31:0] total_length;
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE)
	  begin
	     total_length <= #1 port2txdma_len == 32'h0 ? 32'h2000 : port2txdma_len;
	  end
	else if (state == S_DATA && dh2tx_ack && ~dh2tx_err)
	  begin
	     total_length <= #1 total_length - tx2dh_len;
	  end
     end // always @ (posedge sys_clk)
   localparam [13:0] C_FRM_SIZE = 14'h2000;
   always @(posedge sys_clk)
     begin
	if (state == S_REQ && total_length > C_FRM_SIZE)
	  begin
	     tx2dh_len      <= #1 C_FRM_SIZE;
	     tx2dh_last_frm <= #1 1'b0;
	  end
	else if (state == S_REQ)
	  begin
	     tx2dh_len      <= #1 total_length;
	     tx2dh_last_frm <= #1 1'b1;
	  end
     end // always @ (posedge sys_clk)
   assign txdma2dbg[3:0] = state;
   assign txdma2dbg[7:4] = txdma2port_sts;
   assign txdma2dbg[8]   = tx2dh_last_frm;
   assign txdma2dbg[9]   = ctrl_src_rdy_n;
   assign txdma2dbg[10]  = dh2tx_err;
   assign txdma2dbg[31:16]=tx2dh_len;
   /************************************************************************/
   /*AUTOASCIIENUM("state", "state_ascii", "S_")*/
   // Beginning of automatic ASCII enum decoding
   reg [39:0]		state_ascii;		// Decode of state
   always @(state) begin
      case ({state})
	S_IDLE:   state_ascii = "idle ";
	S_REQ:    state_ascii = "req  ";
	S_DATA:   state_ascii = "data ";
	S_NEXT:   state_ascii = "next ";
	S_DONE:   state_ascii = "done ";
	S_ERROR:  state_ascii = "error";
	default:  state_ascii = "%Erro";
      endcase
   end
   // End of automatics
endmodule
// 
// txdma.v ends here
