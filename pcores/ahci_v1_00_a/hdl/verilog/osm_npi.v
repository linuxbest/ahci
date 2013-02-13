// osm_npi.v --- 
// 
// Filename: osm_npi.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Îå  6ÔÂ 26 16:32:36 2009 (+0800)
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

// Copyright (C) 2008 Beijing Soul tech.

// Code:

module osm_npi (/*AUTOARG*/
   // Outputs
   M_rdNum, M_rdReq, M_rdAddr, M_rdBE, M_rdPriority, M_rdType,
   M_rdCompress, M_rdGuarded, M_rdLockErr, M_rdAbort, npi_ack,
   npi_data, npi_rem, npi_valid, npi_last, osm_npi2dbg,
   // Inputs
   M_rdAccept, M_rdData, M_rdAck, M_rdComp, M_rdRearb, M_rdError,
   sys_clk, sys_rst, npi_addr, npi_len, npi_req, npi_rdy
   );
   parameter C_NUM_WIDTH = 5;
   parameter C_DEBUG_TX_FIFO = 0;
   
   input sys_clk;
   input sys_rst;

   /*AUTOINOUTMODULE("ipic_rd_common")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output [C_NUM_WIDTH-1:0] M_rdNum;
   output		M_rdReq;
   output [31:0]	M_rdAddr;
   output [7:0]		M_rdBE;
   output [1:0]		M_rdPriority;
   output [2:0]		M_rdType;
   output		M_rdCompress;
   output		M_rdGuarded;
   output		M_rdLockErr;
   output		M_rdAbort;
   input		M_rdAccept;
   input [63:0]		M_rdData;
   input		M_rdAck;
   input		M_rdComp;
   input		M_rdRearb;
   input		M_rdError;
   // End of automatics
   input [35:0] 	npi_addr;
   input [13:0] 	npi_len;
   input 		npi_req;
   output 		npi_ack;
   input                npi_rdy;

   output [63:0] 	npi_data;
   output     	        npi_rem;
   output 		npi_valid;
   output 		npi_last;

   /**********************************************************************/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			M_rdAbort;
   reg [31:0]		M_rdAddr;
   reg [7:0]		M_rdBE;
   reg			M_rdCompress;
   reg			M_rdGuarded;
   reg			M_rdLockErr;
   reg [C_NUM_WIDTH-1:0] M_rdNum;
   reg [1:0]		M_rdPriority;
   reg			M_rdReq;
   reg [2:0]		M_rdType;
   reg [63:0]		npi_data;
   reg			npi_last;
   reg			npi_rem;
   reg			npi_valid;
   // End of automatics

   /**********************************************************************/
   localparam [2:0]// synopsys enum state_info
     S_IDLE     = 3'h0,
     S_BUS_REQ  = 3'h1,
     S_ADDR_REQ = 3'h2,
     S_WAIT_DATA= 3'h3,
     S_DONE     = 3'h4,
     S_WAIT_RDY = 4'h5,
     S_ERROR    = 3'h6;
   reg [2:0] 	// synopsys enum state_info
		state, state_n;
   always @(posedge sys_clk or posedge sys_rst)
     begin
	if (sys_rst) begin
	   state <= #1 S_IDLE;
	end else begin
	   state <= #1 state_n;
	end
     end
   reg 	      npi_len_last;
   always @(*)
     begin
	state_n = state;
	case (state)
	  S_IDLE: if (npi_req && npi_rdy)
	    begin
	       state_n = S_BUS_REQ;
	    end
	  S_BUS_REQ:
	    begin
	       state_n = S_ADDR_REQ;
	    end
	  S_ADDR_REQ: if (M_rdAccept) 
	    begin
	       state_n = S_WAIT_DATA;
	    end
	  else if (M_rdError) 
	    begin
	       state_n = S_ERROR;
	    end
	  S_WAIT_DATA: if (M_rdComp && npi_len_last) 
	    begin
	       state_n = S_DONE;
	    end 
	  else if (M_rdComp)
	    begin
	       state_n = S_WAIT_RDY;
	    end
	  S_WAIT_RDY:
	    begin
	       if (npi_rdy)
		 begin
		    state_n = S_BUS_REQ;
		 end
	    end
	  S_DONE:
	    state_n = S_IDLE;
	  S_ERROR:
	    state_n = S_ERROR;
	endcase
     end // always @ (...
   /**********************************************************************/
   reg [15:0] req_cnt;
generate if (C_DEBUG_TX_FIFO)
  begin
   always @(posedge sys_clk)
     begin
	if (state == S_BUS_REQ)
	  begin
	     req_cnt <= #1 0;
	  end
	else if (state == S_ADDR_REQ && M_rdReq == 1'b0)
	  begin
	     req_cnt <= #1 req_cnt + 1'b1;
	  end
     end // always @ (posedge sys_clk)
  end // if (C_DEBUG_FIFO)
endgenerate
generate if (C_DEBUG_TX_FIFO == 0)
  begin
     always @(posedge sys_clk) req_cnt = 16'hffff;
  end
endgenerate
   always @(posedge sys_clk)
     begin
	if (state == S_ADDR_REQ & ~M_rdAccept && req_cnt[5]) begin
	   M_rdReq      <= #1 1'b1;
	   M_rdBE       <= #1 8'hff;
	   M_rdType     <= #1 3'b000;
	   M_rdPriority <= #1 2'b00;
	   M_rdCompress <= #1 1'b0;
	   M_rdGuarded  <= #1 1'b0;
	   M_rdLockErr  <= #1 1'b0;
	   M_rdAbort    <= #1 1'b0;
	end else begin
	   M_rdReq      <= #1 1'b0;
	end
     end // always @ (posedge sys_clk)
   reg [13:7] npi_len_reg;
   reg [35:7] npi_addr_reg;
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE && npi_req)
	  begin
	     npi_len_reg <= #1 npi_len[13:7];
	     npi_addr_reg<= #1 npi_addr[35:7];
	  end
	else if (state == S_BUS_REQ && ~npi_len_last)
	  begin
	     npi_len_reg <= #1 npi_len_reg  - 1'b1;
	     npi_addr_reg<= #1 npi_addr_reg + 1'b1;
	     M_rdAddr    <= #1 {npi_addr_reg, npi_addr[6:0]};
	  end
     end // always @ (posedge sys_clk)
   wire [2:0] npi_len_low = npi_len[2:0];
   wire [6:0] npi_len_mid = npi_len[6:0];
   always @(posedge sys_clk)
     begin
	if (state == S_BUS_REQ && npi_len_reg == 0)
	  begin
	     M_rdNum <= #1 npi_len[6:3] + (|npi_len_low);
	  end
	else if (state == S_BUS_REQ)
	  begin
	     M_rdNum <= #1 6'h10;
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE)
	  begin
	     npi_len_last <= #1 1'b0;
	  end
	else if (state == S_BUS_REQ && 
		 ((npi_len_reg == 1 && ~(|npi_len_mid)) ||
		  (npi_len_reg == 0)))
	  begin
	     npi_len_last <= #1 1'b1;
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	npi_data  <= #1 M_rdData;
	npi_valid <= #1 M_rdAck;
	npi_last  <= #1 M_rdComp && npi_len_last;
	npi_rem   <= #1 M_rdComp && npi_len_last &&
		((npi_len_low[2] == 1'b1 && npi_len_low[1:0] == 2'b00) ||
		 (npi_len_low[2] == 1'b0 && npi_len_low[1:0] != 2'b00));
     end
   assign npi_ack = state == S_DONE;

   output [31:0] osm_npi2dbg;
   assign osm_npi2dbg[7:0] = state;
   assign osm_npi2dbg[8]   = npi_rdy;
   assign osm_npi2dbg[30]  = npi_valid;
   assign osm_npi2dbg[31]  = state == S_WAIT_DATA;
   /**********************************************************************/
   /*AUTOASCIIENUM("state", "state_ascii", "S_")*/
   // Beginning of automatic ASCII enum decoding
   reg [71:0]		state_ascii;		// Decode of state
   always @(state) begin
      case ({state})
	S_IDLE:      state_ascii = "idle     ";
	S_BUS_REQ:   state_ascii = "bureq    ";
	S_ADDR_REQ:  state_ascii = "addr_req ";
	S_WAIT_DATA: state_ascii = "wait_data";
	S_DONE:      state_ascii = "done     ";
	S_WAIT_RDY:  state_ascii = "wait_rdy ";
	S_ERROR:     state_ascii = "error    ";
	default:     state_ascii = "%Error   ";
      endcase
   end
   // End of automatics
endmodule
// Local Variables:
// verilog-library-directories:("." "cache" "ipic")
// verilog-library-files:("")
// verilog-library-extensions:(".v" ".h")
// End:
//
// 
// osm_npi.v ends here
