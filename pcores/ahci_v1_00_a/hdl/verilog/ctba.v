// ctba.v --- 
// 
// Filename: ctba.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Fri Sep 10 11:22:56 2010 (+0800)
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
module ctba (/*AUTOARG*/
   // Outputs
   ctba2al_ack, ctba2al_len, ctba2al_addr, ctba2al_end, ctba2al_last,
   ctba2txll_ack, ctba2txll_do, ctba2port_FetchCmd_ack,
   ctba2port_FetchCFIS_ack, ctba2port_UpdateBC_ack, ctba2port_do,
   ctba2port_idx, ctba2port_ack, ctba2port_PRD_cnt, M_rdNum, M_rdReq,
   M_rdAddr, M_rdBE, M_rdPriority, M_rdType, M_rdCompress,
   M_rdGuarded, M_rdLockErr, M_rdAbort, M_wrNum, M_wrReq, M_wrAddr,
   M_wrBE, M_wrData, M_wrPriority, M_wrType, M_wrCompress,
   M_wrGuarded, M_wrOrdered, M_wrLockErr, M_wrAbort, ctba2dbg,
   // Inputs
   al2ctba_req, port2ctba_FetchCmd_req, port2ctba_FetchCmd_addr,
   port2ctba_FetchCmd_slot, port2ctba_FetchCFIS_req,
   port2ctba_FetchCFIS_addr, port2ctba_FetchCFIS_len,
   port2ctba_UpdateBC_req, port2ctba_UpdateBC_addr,
   port2ctba_FetchPRD_addr, port2ctba_FetchPRD_cnt,
   port2ctba_FetchPRD_off, port2ctba_FetchPRDTL, port2ctba_FetchPRDBC,
   M_rdAccept, M_rdData, M_rdAck, M_rdComp, M_rdRearb, M_rdError,
   M_wrAccept, M_wrRdy, M_wrAck, M_wrComp, M_wrRearb, M_wrError,
   sys_clk, sys_rst, trn_tsrc_rdy_n, rxdma2port_ack, txdma2port_ack,
   port2rxdma_req, port2txdma_req, pPMP, pPmpCur
   );
   parameter C_NUM_WIDTH = 5;
   parameter C_BIG_ENDIAN = 1;
   input sys_clk;
   input sys_rst;

   input                trn_tsrc_rdy_n;
   /*AUTOINOUTCOMP("ctba_ram", "ctba2port")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output [63:0]	ctba2port_do;
   output [1:0]		ctba2port_idx;
   output		ctba2port_ack;
   output [15:0]	ctba2port_PRD_cnt;
   // End of automatics
   /*AUTOINOUTCOMP("port", "ctba2port")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output		ctba2port_FetchCmd_ack;
   output		ctba2port_FetchCFIS_ack;
   output		ctba2port_UpdateBC_ack;
   // End of automatics
   /*AUTOINOUTCOMP("port", "port2ctba")*/
   // Beginning of automatic in/out/inouts (from specific module)
   input		port2ctba_FetchCmd_req;
   input [31:0]		port2ctba_FetchCmd_addr;
   input [4:0]		port2ctba_FetchCmd_slot;
   input		port2ctba_FetchCFIS_req;
   input [31:0]		port2ctba_FetchCFIS_addr;
   input [4:0]		port2ctba_FetchCFIS_len;
   input		port2ctba_UpdateBC_req;
   input [31:0]		port2ctba_UpdateBC_addr;
   input [31:0]		port2ctba_FetchPRD_addr;
   input [15:0]		port2ctba_FetchPRD_cnt;
   input [31:0]		port2ctba_FetchPRD_off;
   input [15:0]		port2ctba_FetchPRDTL;
   input [31:0]		port2ctba_FetchPRDBC;
   // End of automatics
   /*AUTOINOUTCOMP("txll", "ctba2txll")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output		ctba2txll_ack;
   output [63:0]	ctba2txll_do;
   // End of automatics
   /*AUTOINOUTCOMP("txll", "txll2ctba")*/

   /*AUTOINOUTCOMP("dma_al", "ctba2al")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output		ctba2al_ack;
   output [21:0]	ctba2al_len;
   output [31:0]	ctba2al_addr;
   output		ctba2al_end;
   output		ctba2al_last;
   // End of automatics
   /*AUTOINOUTCOMP("dma_al", "al2ctba")*/
   // Beginning of automatic in/out/inouts (from specific module)
   input		al2ctba_req;
   // End of automatics
   input                rxdma2port_ack;
   input                txdma2port_ack;
   input                port2rxdma_req;
   input                port2txdma_req;
   input [3:0]          pPMP;
   input [3:0]          pPmpCur;
   /*AUTOINOUTMODULE("ipic_wr_common")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output [C_NUM_WIDTH-1:0] M_wrNum;
   output		M_wrReq;
   output [31:0]	M_wrAddr;
   output [7:0]		M_wrBE;
   output [63:0]	M_wrData;
   output [1:0]		M_wrPriority;
   output [2:0]		M_wrType;
   output		M_wrCompress;
   output		M_wrGuarded;
   output		M_wrOrdered;
   output		M_wrLockErr;
   output		M_wrAbort;
   input		M_wrAccept;
   input		M_wrRdy;
   input		M_wrAck;
   input		M_wrComp;
   input		M_wrRearb;
   input		M_wrError;
   // End of automatics
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
   output [31:0]        ctba2dbg;
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
   reg			M_wrAbort;
   reg [31:0]		M_wrAddr;
   reg [7:0]		M_wrBE;
   reg			M_wrCompress;
   reg			M_wrGuarded;
   reg			M_wrLockErr;
   reg [C_NUM_WIDTH-1:0] M_wrNum;
   reg			M_wrOrdered;
   reg [1:0]		M_wrPriority;
   reg			M_wrReq;
   reg [2:0]		M_wrType;
   reg			ctba2al_ack;
   reg [31:0]		ctba2al_addr;
   reg			ctba2al_end;
   reg [21:0]		ctba2al_len;
   reg [15:0]		ctba2port_PRD_cnt;
   reg			ctba2port_ack;
   reg [1:0]		ctba2port_idx;
   // End of automatics

   /**********************************************************************/
   localparam [3:0] // synopsys enum state_info
     S_IDLE = 4'h0,
     S_REQ  = 4'h1,
     S_DATA = 4'h2,
     S_DONE = 4'h3,
     S_ERROR= 4'h4,
     S_WAIT = 4'h5,
     S_WARB = 4'h6,
     S_WDAT = 4'h7,
     S_WACK = 4'h8;
   reg [3:0] // synopsys enum state_info
	     state, state_ns;
   reg 	     cmd_req;
   reg 	     al_req;
   reg 	     cfis_req;
   reg 	     bc_req;
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
	  S_IDLE: if (port2ctba_FetchCmd_req ||
		      port2ctba_FetchCFIS_req)
	    begin
	       state_ns = S_REQ;
	    end
	  else if (al2ctba_req)
	    begin
	       state_ns = S_REQ;
	    end
	  else if (port2ctba_UpdateBC_req)
	    begin
	       state_ns = S_WARB;
	    end
	  S_REQ: if (M_rdAccept && ~M_rdError)
	    begin
	       state_ns = S_DATA;
	    end
	  else if (M_rdError)
	    begin
	       state_ns = S_ERROR;
	    end
	  S_DATA: if (M_rdComp && M_rdAck)
	    begin
	       state_ns = S_DONE;	       
	    end
	  S_DONE: if (al_req && ~al2ctba_req)
	    begin
	       state_ns = S_WAIT;
	    end
	  else if (cmd_req || bc_req)
	    begin
	       state_ns = S_IDLE;
	    end
	  else if (cfis_req)
	    begin
	       state_ns = S_IDLE;
	    end
	  S_WAIT: if (al2ctba_req)
	    begin
	       state_ns = S_REQ;
	    end
	  else if (rxdma2port_ack || txdma2port_ack)
	    begin
	       state_ns = S_IDLE;
	    end
	  S_WARB: if (M_wrAccept)
	    begin
	       state_ns = S_WACK;
	    end
	  S_WACK: if (M_wrAck && M_wrComp)
	    begin
	       state_ns = S_DONE;
	    end
	  else if (M_wrError)
	    begin
	       state_ns = S_ERROR;
	    end
	endcase
     end // always @ (*)
   assign ctba2port_FetchCmd_ack = state == S_DONE && cmd_req;
   assign ctba2port_FetchCFIS_ack= state == S_DONE && cfis_req;
   assign ctba2port_UpdateBC_ack = state == S_DONE && bc_req;
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE)
	  begin
	     cmd_req <= #1 port2ctba_FetchCmd_req;
	     al_req  <= #1 port2rxdma_req|port2txdma_req;
	     cfis_req<= #1 port2ctba_FetchCFIS_req;
	     bc_req  <= #1 port2ctba_UpdateBC_req;
	  end
     end
   wire [31:0] addr;
   wire [31:0] len;
   reg [31:0]  prdt_al_addr;
   assign addr = port2ctba_FetchCmd_req ? port2ctba_FetchCmd_addr :
		 port2ctba_FetchCFIS_req? port2ctba_FetchCFIS_addr:
		 al2ctba_req            ? prdt_al_addr : 32'h0;
   assign len = al2ctba_req             ? 6'h2 : 6'h4;
   always @(posedge sys_clk)
     begin
	if (state == S_REQ && ~M_rdAccept)
	  begin
             M_rdReq     <= #1 1'b1;
             M_rdNum     <= #1 len;
	     M_rdAddr    <= #1 addr;
             M_rdBE      <= #1 8'hff;
             M_rdType    <= #1 3'b000;
             M_rdPriority<= #1 2'b00;
             M_rdCompress<= #1 1'b0;
             M_rdGuarded <= #1 1'b0;
             M_rdLockErr <= #1 1'b0;
             M_rdAbort   <= #1 1'b0;
	  end // if (state == S_REQ && ~M_rdAccept)
	else
	  begin
	     M_rdReq     <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   
   reg [63:0] MstRd_d1;
   wire [63:0] MstRd_d_le = MstRd_d1;
   wire [63:0] MstRd_d_swap_le;
   wire [63:0] MstRd_d_swap_be;
   genvar      i;
   generate
      for (i = 0; i < 64; i = i + 8) begin: rdfifo_swap
	 assign MstRd_d_swap_le[i+7:i] = MstRd_d_le[63-i:56-i];
      end
   endgenerate
   assign MstRd_d_swap_be[63:32] = MstRd_d_le[31:00];
   assign MstRd_d_swap_be[31:00] = MstRd_d_le[63:32];

   always @(posedge sys_clk)
     begin
	MstRd_d1      <= #1 M_rdData;
	ctba2port_ack <= #1 M_rdAck;
     end
   assign ctba2port_do = MstRd_d_swap_le;
   assign ctba2txll_do = MstRd_d_swap_le;
   assign ctba2txll_ack= ctba2port_ack && port2ctba_FetchCFIS_req;

   always @(posedge sys_clk)
     begin
	if (state == S_IDLE)
	  begin
	     ctba2port_idx <= #1 2'h0;
	  end
	else if (ctba2port_ack)
	  begin
	     ctba2port_idx <= #1 ctba2port_idx + 1'b1;
	  end
     end // always @ (posedge sys_clk)
   reg [15:0] PRD_cnt;
   wire [31:0] prdt_addr;
   assign prdt_addr = port2ctba_FetchCFIS_addr + 8'h80;
   always @(posedge sys_clk)
     begin
	prdt_al_addr <= #1 {prdt_addr[31:4] + PRD_cnt, 4'b0000};
     end
   reg cnt;
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE || state == S_WAIT)
	  begin
	     cnt <= #1 1'b0;	     
	  end
	else if (al2ctba_req && ctba2port_ack)
	  begin
	     cnt <= #1 1'b1;
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (al2ctba_req && ctba2port_ack && cnt == 1'b0)
	  begin
	     ctba2al_addr<= #1 ctba2port_do[31:0];
	     ctba2al_end <= #1 PRD_cnt == port2ctba_FetchPRDTL;
	  end
	else if (al2ctba_req && ctba2port_ack)
	  begin
	     ctba2al_ack <= #1 1'b1;
	     ctba2al_len <= #1 ctba2port_do[53:32] + 1'b1;
	  end
	else
	  begin
	     ctba2al_ack <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE && al2ctba_req)
	  begin
	     PRD_cnt           <= #1 port2ctba_FetchPRD_cnt;
	     ctba2port_PRD_cnt <= #1 port2ctba_FetchPRD_cnt;	     
	  end
	else if (al2ctba_req && ctba2port_ack && cnt == 1'b0)
	  begin
	     PRD_cnt           <= #1 PRD_cnt + 1'b1;
	     ctba2port_PRD_cnt <= #1 PRD_cnt;
	  end
     end // always @ (posedge sys_clk)
   assign ctba2al_last = PRD_cnt == port2ctba_FetchPRDTL;
   /**********************************************************************/
   always @(posedge sys_clk)
     begin
	if (state == S_WARB && ~M_wrAccept)
	  begin
	     M_wrAddr    <= #1 port2ctba_UpdateBC_addr;
	     M_wrNum     <= #1 8'h1;
	     M_wrBE      <= #1 8'hff;
	     M_wrReq     <= #1 1'b1;
	     M_wrType    <= #1 3'b000;
	     M_wrPriority<= #1 2'b00;
	     M_wrCompress<= #1 1'b0;
	     M_wrGuarded <= #1 1'b0;
	     M_wrLockErr <= #1 1'b0;
	     M_wrAbort   <= #1 1'b0;
	     M_wrOrdered <= #1 1'b0;	     
	  end // if (state == S_WARB && ~M_wrAccept)
	else
	  begin
	     M_wrReq     <= #1 1'b0;	     
	  end // else: !if(state == S_WARB && ~M_wrAccept)
     end // always @ (posedge sys_clk)
   wire [63:0] wrfifo_do;
   assign wrfifo_do = {port2ctba_FetchPRDBC, 32'hAA55_1234};
   wire [63:0] MstWr_d_swap;
   generate 
      for (i = 0; i < 64; i = i + 8) begin: wrfifo_swap
	 assign MstWr_d_swap[63-i:56-i] = wrfifo_do[i+7:i];
      end
   endgenerate
   assign M_wrData  = MstWr_d_swap;
   assign ctba2dbg[7:0] = state;
   /**********************************************************************/
   /*AUTOASCIIENUM("state", "state_ascii", "S_")*/
   // Beginning of automatic ASCII enum decoding
   reg [39:0]		state_ascii;		// Decode of state
   always @(state) begin
      case ({state})
	S_IDLE:   state_ascii = "idle ";
	S_REQ:    state_ascii = "req  ";
	S_DATA:   state_ascii = "data ";
	S_DONE:   state_ascii = "done ";
	S_ERROR:  state_ascii = "error";
	S_WAIT:   state_ascii = "wait ";
	S_WARB:   state_ascii = "warb ";
	S_WDAT:   state_ascii = "wdat ";
	S_WACK:   state_ascii = "wack ";
	default:  state_ascii = "%Erro";
      endcase
   end
   // End of automatics
endmodule
// 
// ctba.v ends here
