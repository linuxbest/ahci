// dma_al.v --- 
// 
// Filename: dma_al.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Tue Sep  7 08:52:54 2010 (+0800)
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
module dma_al (/*AUTOARG*/
   // Outputs
   al2dh_ack, al2dh_err, al2dh_len, al2dh_addr, al2dh_last,
   al2port_PRD_off, al2ctba_req, dh2al_ack, ctba2cache_strip, al2dbg,
   // Inputs
   sys_clk, sys_rst, rx2al_req, rx2al_len, tx2al_req, tx2al_len,
   port2ififo_fo_req, ififo2port_fo_ack, port2rxdma_req,
   rxll2port_fis_hdr, port2ctba_FetchPRD_off, ctba2port_PRD_cnt,
   cache2ctba_CTBA, ctba2al_ack, ctba2al_len, ctba2al_addr,
   ctba2al_end, ctba2al_last, rxdma2port_ack, port2txdma_req,
   txdma2port_ack, dcr2port_PxFBS_EN, PxCLB, PxCLBU, PxFB, PxFBU,
   cache2ctba_strip_total, cache2ctba_strip_index,
   cache2ctba_strip_enable, cache2ctba_strip
   );
   input sys_clk;
   input sys_rst;

   input 	rx2al_req;
   input [13:0] rx2al_len;
   input 	tx2al_req;
   input [13:0] tx2al_len;
   
   output 	al2dh_ack;
   output       al2dh_err;
   output [13:0] al2dh_len;
   output [31:0] al2dh_addr;
   output        al2dh_last;

   input 	 port2ififo_fo_req;
   input         ififo2port_fo_ack;

   input 	 port2rxdma_req;
   input [15:0]  rxll2port_fis_hdr;

   input [21:0]  port2ctba_FetchPRD_off;
   output [31:0] al2port_PRD_off;
   input [15:0]  ctba2port_PRD_cnt;
   input [31:0]  cache2ctba_CTBA;
   
   input 	 ctba2al_ack;
   input [21:0]  ctba2al_len;
   input [31:0]  ctba2al_addr;
   input 	 ctba2al_end;
   input         ctba2al_last;
   output 	 al2ctba_req;
   output        dh2al_ack;

   input         rxdma2port_ack;

   input 	 port2txdma_req;
   input 	 txdma2port_ack;
   input         dcr2port_PxFBS_EN;

   input [31:0]  PxCLB;
   input [31:0]  PxCLBU;
   input [31:0]  PxFB;
   input [31:0]  PxFBU;

   input [3:0] 	 cache2ctba_strip_total;
   input [3:0] 	 cache2ctba_strip_index;
   input  	 cache2ctba_strip_enable;
   input [3:0] 	 cache2ctba_strip;
   output [3:0]  ctba2cache_strip;
   
   output [127:0] al2dbg;
   /**********************************************************************/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			al2ctba_req;
   reg			al2dh_ack;
   reg [31:0]		al2dh_addr;
   reg			al2dh_err;
   reg [13:0]		al2dh_len;
   reg [3:0]		ctba2cache_strip;
   // End of automatics

   /**********************************************************************/
   localparam [7:0]
     C_RFIS       = 8'h34,
     C_SDB        = 8'hA1,
     C_DmaAct     = 8'h39,
     C_DmaSetup   = 8'h41,
     C_BIST       = 8'h58,
     C_PioSetup   = 8'h5f,
     C_DFIS       = 8'h46;
   localparam [3:0] // synopsys enum state_info
     S_IDLE       = 4'h0,
     S_NDR_REQ    = 4'h1,
     
     S_PRD_REQ    = 4'h2,
     S_WAIT       = 4'h3,
     S_SG_REQ     = 4'h4,
     S_SG_ACK     = 4'h5,
     S_DMA_REQ    = 4'h6,
     S_DMA_ACK    = 4'h7,
     S_DMA_POST   = 4'h8,
     
     S_DONE       = 4'h9;
   reg [3:0] // synopsys enum state_info
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
   wire dh2al_req;
   assign dh2al_req = rx2al_req || tx2al_req;
   assign dh2al_ack = ififo2port_fo_ack | rxdma2port_ack | txdma2port_ack;
   wire [13:0] dh2al_len_req;
   wire [13:0] dh2al_len;
   assign dh2al_len_req = port2rxdma_req ? rx2al_len : tx2al_len;
   assign dh2al_len = dh2al_len_req > 14'h200 ? 14'h200 : dh2al_len_req;

   reg 	seg_complete;
   reg 	tsb_end;
   always @(*)
     begin
	state_ns = state;
	case (state)
	  S_IDLE:
	    begin
	       if (rx2al_req && port2ififo_fo_req)
		 begin
		    state_ns = S_NDR_REQ;
		 end
	       else if (rx2al_req && port2rxdma_req)
		 begin
		    state_ns = S_PRD_REQ;
		 end
	       else if (tx2al_req && port2txdma_req)
		 begin
		    state_ns = S_PRD_REQ;		    
		 end
	    end
	  S_NDR_REQ:
	    begin
	       state_ns = S_DONE;
	    end
	  S_PRD_REQ:
	    begin
	       state_ns = S_WAIT;
	    end
	  S_WAIT:
	    begin
	       if (dh2al_req && tsb_end)
		 begin
		    state_ns = S_DONE;
		 end
	       else if (dh2al_req && seg_complete)
		 begin
		    state_ns = S_SG_REQ;
		 end
	       else if (dh2al_req)
		 begin
		    state_ns = S_DMA_REQ;
		 end
	    end // case: S_WAIT
	  S_SG_REQ: 
	    begin 
	       if (ctba2al_ack)
		 begin
		    state_ns = S_SG_ACK;
		 end
	    end
	  S_SG_ACK:
	    begin
	       state_ns = S_WAIT;
	    end
	  S_DMA_REQ:
	    begin
	       state_ns = S_DMA_ACK;
	    end
	  S_DMA_ACK:
	    begin
	       state_ns = S_DMA_POST;
	    end
	  S_DMA_POST:
	    begin
	       state_ns = S_WAIT;
	    end
	  S_DONE: if (dh2al_ack)
	    begin
	       state_ns = S_IDLE;
	    end
	endcase
     end // always @ (*)
   /**********************************************************************/
   reg [21:0] tsb_len;
   wire [21:0] tsblen;
   reg [21:0] buf_offset_reg;
   reg [21:0] buf_offset;
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE)
	  begin
	     buf_offset_reg <= #1 port2ctba_FetchPRD_off;	     
	  end
	else if ((state == S_DMA_POST && tsb_len == al2dh_len) ||
		 (state == S_SG_ACK && buf_offset_reg == tsblen))
	  begin
	     buf_offset_reg <= #1 22'h0;
	  end
	else if (state == S_DMA_ACK)
	  begin
	     buf_offset_reg <= #1 buf_offset_reg + al2dh_len;	     
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (state == S_DMA_POST)
	  begin
	     buf_offset <= #1 buf_offset_reg;
	  end
     end
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE)
	  begin
	     seg_complete <= #1 1'b1;
	  end
	else if (state == S_DMA_POST)
	  begin
	     seg_complete <= #1 tsb_len == al2dh_len;
	  end
	else if (state == S_SG_REQ && ctba2al_ack)
	  begin
	     seg_complete <= #1 1'b0;
	  end
	else if (state == S_SG_ACK && tsblen == buf_offset_reg)
	  begin
	     seg_complete <= #1 1'b1;	     
	  end
     end // always @ (posedge sys_clk)
   reg [31:0] tsb_addr;
   wire [7:0] ndr_offset;
   reg 	      tsb_less_dh2al;
   wire [11:8] rx_fis_offset;
   assign  rx_fis_offset = dcr2port_PxFBS_EN ? rxll2port_fis_hdr[11:8] : 0;
   wire al2dh_ack0;
   wire al2dh_ack1;
   assign al2dh_ack0 = ~cache2ctba_strip_enable;
   assign al2dh_ack1 =  cache2ctba_strip_enable && ctba2cache_strip == cache2ctba_strip_index;
   always @(posedge sys_clk)
     begin
	if (state == S_NDR_REQ)
	  begin
	     al2dh_ack <= #1 1'b1;
	     al2dh_len <= #1 14'h20;
	     al2dh_addr<= #1 {PxFB[31:8]+rx_fis_offset, ndr_offset};
	  end
	else if (state == S_DMA_REQ && tsb_less_dh2al)
	  begin 
	     al2dh_len   <= #1 tsb_len;
	     al2dh_addr  <= #1 tsb_addr;
	     al2dh_ack   <= #1 al2dh_ack0|al2dh_ack1;
	  end
	else if (state == S_DMA_REQ)
	  begin
	     al2dh_len   <= #1 dh2al_len;
	     al2dh_addr  <= #1 tsb_addr;
	     al2dh_ack   <= #1 al2dh_ack0|al2dh_ack1;
	  end
	else
	  begin
	     al2dh_ack   <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   assign al2port_PRD_off = buf_offset;
   always @(posedge sys_clk)
     begin
	if (state == S_WAIT && dh2al_req)
	  begin
	     tsb_less_dh2al <= #1 dh2al_len > tsb_len;
	  end
     end
   always @(posedge sys_clk)
     begin
	if (state == S_DONE && dh2al_req && tsb_end)
	  begin
	     al2dh_err   <= #1 1'b1;
	  end
	else
	  begin
	     al2dh_err   <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (state == S_SG_REQ && ~ctba2al_ack)
	  begin
	     al2ctba_req <= #1 1'b1;
	  end
	else
	  begin
	     al2ctba_req <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   assign tsblen = ctba2al_len;
   reg tsb_len_z;
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE)
	  begin
	     tsb_end <= #1 1'b0;
	  end
	else if (state == S_SG_REQ && ctba2al_ack)
	  begin
	     tsb_addr <= #1 ctba2al_addr + buf_offset_reg;
	     tsb_len  <= #1 tsblen - buf_offset_reg;
	     tsb_end  <= #1 ctba2al_end;
	     tsb_len_z<= #1 tsblen == 22'h0;
	  end
	else if (state == S_SG_ACK)
	  begin
	     tsb_end  <= #1 tsb_end | (tsb_len_z);
	  end
	else if (state == S_DMA_POST)
	  begin
	     tsb_len  <= #1 tsb_len  - al2dh_len;
	     tsb_addr <= #1 tsb_addr + al2dh_len;
	  end
     end
   assign al2dh_last = ctba2al_last && seg_complete;

   always @(posedge sys_clk)
     begin
	if (state == S_PRD_REQ)
	  begin
	     ctba2cache_strip <= #1 cache2ctba_strip;
	  end
	else if (state == S_DMA_REQ && 
		 ctba2cache_strip != cache2ctba_strip_total)
	  begin
	     ctba2cache_strip <= #1 ctba2cache_strip + 1'b1;
	  end
	else if (state == S_DMA_REQ)
	  begin
	     ctba2cache_strip <= #1 0;	     
	  end
     end // always @ (posedge sys_clk)
   /**********************************************************************/
   assign ndr_offset = rxll2port_fis_hdr[7:0] == C_DmaSetup ? 8'h00 :
		       rxll2port_fis_hdr[7:0] == C_PioSetup ? 8'h20 :
		       rxll2port_fis_hdr[7:0] == C_RFIS     ? 8'h40 :
		       rxll2port_fis_hdr[7:0] == C_SDB      ? 8'h60 : 8'h80;
   assign al2dbg[7:0]   = state;
   assign al2dbg[8]     = al2dh_ack;
   assign al2dbg[9]     = al2dh_err;
   assign al2dbg[10]    = dh2al_req;
   assign al2dbg[11]    = al2ctba_req;
   assign al2dbg[12]    = ctba2al_ack;
   assign al2dbg[13]    = ctba2al_end;
   assign al2dbg[14]    = ctba2al_last;
   assign al2dbg[31:16] = al2dh_len;
   assign al2dbg[63:32] = ctba2al_addr;
   assign al2dbg[95:64] = al2dh_addr;
   assign al2dbg[127:96]= cache2ctba_CTBA;
   /**********************************************************************/
   /*AUTOASCIIENUM("state", "state_ascii", "S_")*/
   // Beginning of automatic ASCII enum decoding
   reg [63:0]		state_ascii;		// Decode of state
   always @(state) begin
      case ({state})
	S_IDLE:     state_ascii = "idle    ";
	S_NDR_REQ:  state_ascii = "ndr_req ";
	S_PRD_REQ:  state_ascii = "prd_req ";
	S_WAIT:     state_ascii = "wait    ";
	S_SG_REQ:   state_ascii = "sg_req  ";
	S_SG_ACK:   state_ascii = "sg_ack  ";
	S_DMA_REQ:  state_ascii = "dma_req ";
	S_DMA_ACK:  state_ascii = "dma_ack ";
	S_DMA_POST: state_ascii = "dma_post";
	S_DONE:     state_ascii = "done    ";
	default:    state_ascii = "%Error  ";
      endcase
   end
   // End of automatics
endmodule
// 
// dma_al.v ends here
