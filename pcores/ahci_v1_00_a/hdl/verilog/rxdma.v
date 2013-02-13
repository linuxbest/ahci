// rxdma.v --- 
// 
// Filename: rxdma.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Fri Sep 10 12:27:11 2010 (+0800)
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
module rxdma (/*AUTOARG*/
   // Outputs
   M_wrNum, M_wrReq, M_wrAddr, M_wrBE, M_wrData, M_wrPriority,
   M_wrType, M_wrCompress, M_wrGuarded, M_wrOrdered, M_wrLockErr,
   M_wrAbort, rxdma2port_idle, rxdma2dbg, rxdma2ififo_ndr_rd_en,
   rxdma2rxll_rd_en, ififo2port_fo_ack, rxdma2port_ack,
   rxdma2port_sts, rxdma2port_xfer, rx2al_req, rx2al_len,
   ctrl_dst_rdy3,
   // Inputs
   M_wrAccept, M_wrRdy, M_wrAck, M_wrComp, M_wrRearb, M_wrError,
   sys_clk, sys_rst, ififo2rxdma_ndr_rd_do, ififo2port_empty,
   rxll2rxdma_rd_do, rxll2rxdma_rd_empty, rxll2rxdma_rd_eof_rdy,
   port2ififo_fo_req, port2rxdma_req, port2ctba_FetchPRDBC, al2dh_ack,
   al2dh_err, al2dh_addr, al2dh_len
   );
   parameter C_NUM_WIDTH = 5;
   parameter C_BIG_ENDIAN = 1;
   parameter C_DEBUG_RX_FIFO = 0;
`include "ll/sata.v"   
   input sys_clk;
   input sys_rst;

   output rxdma2port_idle;
   output [31:0] rxdma2dbg;

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

   input [35:0] 	ififo2rxdma_ndr_rd_do;
   output 		rxdma2ififo_ndr_rd_en;
   input 		ififo2port_empty;

   input [35:0] 	rxll2rxdma_rd_do;
   input 		rxll2rxdma_rd_empty;
   output 		rxdma2rxll_rd_en;
   input                rxll2rxdma_rd_eof_rdy;

   input 		port2ififo_fo_req;
   output 		ififo2port_fo_ack;

   input 		port2rxdma_req;
   output 		rxdma2port_ack;
   output [31:0] 	rxdma2port_sts;

   input [31:0] 	port2ctba_FetchPRDBC;
   output               rxdma2port_xfer;

   input 		al2dh_ack;
   input 		al2dh_err;
   input [31:0] 	al2dh_addr;
   input [13:0] 	al2dh_len;
   output 		rx2al_req;
   output [13:0]        rx2al_len;

   output 		ctrl_dst_rdy3;
   /**********************************************************************/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
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
   reg			ctrl_dst_rdy3;
   reg [13:0]		rx2al_len;
   reg			rx2al_req;
   reg [31:0]		rxdma2dbg;
   reg			rxdma2port_idle;
   reg			rxdma2port_xfer;
   // End of automatics

   /**********************************************************************/
   localparam [2:0] // synopsys enum state_info
     S_IDLE      = 3'h0,
     S_AL_REQ    = 3'h1,
     S_BUS_REQ   = 3'h2,
     S_WRT_REQ   = 3'h3,
     S_WRT       = 3'h4,
     S_WRT_ACK   = 3'h5,
     S_BC_UPDATE = 3'h6,
     S_ERROR     = 3'h7;
   reg [2:0] // synopsys enum state_info
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
   wire rdy;
   reg frm_done;
   reg seg_done;
   wire full_ts;
   always @(*)
     begin
	state_ns = state;
	case(state)
	  S_IDLE: if (port2ififo_fo_req)
	    begin
	       state_ns = S_AL_REQ;
	    end
	  else if (port2rxdma_req && rdy)
	    begin
	       state_ns = S_AL_REQ;
	    end
	  S_AL_REQ: if (al2dh_ack && ~al2dh_err)
	    begin
	       state_ns = S_BUS_REQ;
	    end
	  else if (al2dh_err | rx2al_len == 0)
	    begin
	       state_ns = S_ERROR;
	    end
	  S_BUS_REQ:
	    begin
	       state_ns = S_WRT_REQ;
	    end
	  S_WRT_REQ: if (M_wrAccept)
	    begin
	       state_ns = S_WRT;
	    end
	  S_WRT: if (M_wrAck && M_wrComp && ~M_wrError)
	    begin
	       state_ns = S_WRT_ACK;
	    end
	  else if (M_wrError)
	    begin
	       state_ns = S_ERROR;	       
	    end
	  S_WRT_ACK: if (seg_done || frm_done)
	    begin
	       state_ns = S_BC_UPDATE;
	    end
	  else if (rdy)
	    begin
	       state_ns = S_BUS_REQ;
	    end
	  S_BC_UPDATE: if (frm_done && ~(port2ififo_fo_req | port2rxdma_req))
	    begin
	       state_ns = S_IDLE;
	    end
	  else if (~frm_done)
	    begin
	       state_ns = S_AL_REQ;
	    end
	  S_ERROR:
	    begin
	       if (~port2rxdma_req)
		 begin
		    /*state_ns = S_IDLE;*/
		 end
	    end
	endcase
     end // always @ (*)
   assign ififo2port_fo_ack  = state == S_BC_UPDATE && frm_done && port2ififo_fo_req;
   assign rxdma2port_ack     = port2rxdma_req && 
			       ((state == S_BC_UPDATE && frm_done) ||
				(state == S_ERROR));
   assign rxdma2port_sts     = state == S_ERROR ? C_R_ERR : C_R_OK;
   always @(posedge sys_clk)
     begin
	if (state == S_BC_UPDATE && frm_done && port2ififo_fo_req)
	  begin
	     ctrl_dst_rdy3 <= #1 1'b1;
	  end
	else
	  begin
	     ctrl_dst_rdy3 <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE)
	  begin
	     rx2al_len <= #1 14'h2000;
	  end
	else if (state == S_AL_REQ && al2dh_ack)
	  begin
	     rx2al_len <= #1 rx2al_len - al2dh_len;
	  end
     end // always @ (posedge sys_clk)
   
   always @(posedge sys_clk)
     begin
	if (state == S_AL_REQ && ~al2dh_ack)
	  begin
	     rx2al_req <= #1 1'b1;
	  end
	else
	  begin
	     rx2al_req <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   reg [15:0] req_cnt;
   
generate if (C_DEBUG_RX_FIFO)
begin   
   always @(posedge sys_clk)
     begin
	if (state == S_BUS_REQ)
	  begin
	     req_cnt <= #1 0;
	  end
	else if (state == S_WRT_REQ && M_wrReq == 1'b0)
	  begin
	     req_cnt <= #1 req_cnt + 1'b1;
	  end
     end // always @ (posedge sys_clk)
end
endgenerate
generate if (C_DEBUG_RX_FIFO == 0)
begin
     always @(posedge sys_clk) req_cnt = 16'hffff;
end
endgenerate
   
   always @(posedge sys_clk)
     begin
	if (state == S_WRT_REQ && ~M_wrAccept && req_cnt[8])
	  begin
	     M_wrReq     <= #1 1'b1;
	     M_wrType    <= #1 3'b000;
	     M_wrPriority<= #1 2'b00;
	     M_wrCompress<= #1 1'b0;
	     M_wrGuarded <= #1 1'b0;
	     M_wrLockErr <= #1 1'b0;
	     M_wrAbort   <= #1 1'b0;
	     M_wrOrdered <= #1 1'b0;
	  end // if (state == S_WRT_REQ && ~M_wrAccept)
	else
	  begin
	     M_wrReq     <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   
   reg [13:7] m_len;
   always @(posedge sys_clk)
     begin
	if (state == S_BUS_REQ && m_len == 0)
	  begin
	     M_wrNum <= #1 al2dh_len[6:3] + (|al2dh_len[2:0]);
	     M_wrBE  <= #1 8'hff;
	  end
	else if (state == S_BUS_REQ)
	  begin
	     M_wrNum <= #1 6'h10; // 128byte
	     M_wrBE  <= #1 8'hff;
	  end
     end // always @ (posedge sys_clk)
   
   reg [35:7] m_addr;
   always @(posedge sys_clk)
     begin
	if (al2dh_ack)
	  begin
	     m_addr <= #1 al2dh_addr[31:7];
	  end
	else if (state == S_BUS_REQ)
	  begin
	     m_addr <= #1 m_addr + 1'b1;
	     M_wrAddr<= #1 {m_addr, al2dh_addr[6:0]};
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (al2dh_ack)
	  begin
	     m_len    <= #1 al2dh_len[13:7];
	     seg_done <= #1 1'b0;
	  end
	else if (state == S_BUS_REQ)
	  begin
	     m_len    <= #1 m_len == 0 ? 0 : m_len - 1'b1;
	     seg_done <= #1 (m_len == 0 || (m_len == 1 && ~(|al2dh_len[6:0])));
	  end
     end // always @ (posedge sys_clk)

   wire [71:0] wrfifo_rd_do;
   wire [63:0] wrfifo_rd_do_le;
   wire        wrfifo_rd_en;
   wire        wrfifo_rd_empty;
   wire [63:0] MstWr0_d_swap;
   genvar      i;
   generate
      for (i = 0; i < 64; i = i + 8) begin: wrfifo_swap
	 assign MstWr0_d_swap[63-i:56-i] = wrfifo_rd_do_le[i+7:i];
      end
   endgenerate

   assign wrfifo_rd_do_le = wrfifo_rd_do;
   assign M_wrData = MstWr0_d_swap;

   wire [35:0] rd_data;
   wire        rd_empty;
   wire        rd_en;
   wire        rd_eof;
   wire        rd_sof;
   always @(posedge sys_clk)
     begin
	if (state == S_IDLE)
	  begin
	     frm_done <= #1 1'b0;
	  end
	else if (rd_eof && wrfifo_rd_en)
	  begin
	     frm_done <= #1 1'b1;
	  end
     end // always @ (posedge sys_clk)
   assign rd_sof         = wrfifo_rd_do[71];
   assign rd_eof         = wrfifo_rd_do[70];
   assign wrfifo_rd_en   = M_wrRdy;
   
   /************************************************************************/
   assign rxdma2ififo_ndr_rd_en = port2ififo_fo_req ? rd_en : 1'b0;
   assign rd_data  = port2ififo_fo_req ? ififo2rxdma_ndr_rd_do : rxll2rxdma_rd_do;
   assign rd_empty = port2ififo_fo_req ? ififo2port_empty      : rxll2rxdma_rd_empty;
   assign rxdma2rxll_rd_en = port2ififo_fo_req ? 1'b0 : rd_en;
   reg [71:0] wrfifo_wr_di;
   reg	      wrfifo_wr_en;
   wire       wrfifo_wr_almost_full;
   wire       wrfifo_rd_err;
   wire       wrfifo_wr_err;
   FIFO36_72
     wrfifo (
	     // Outputs
	     .ALMOSTEMPTY		(),
	     .ALMOSTFULL		(wrfifo_wr_almost_full),
	     .DBITERR			(),
	     .DO			(wrfifo_rd_do[63:0]),
	     .DOP			(wrfifo_rd_do[71:64]),
	     .ECCPARITY			(),
	     .EMPTY			(wrfifo_rd_empty),
	     .FULL			(),
	     .RDCOUNT			(),
	     .RDERR			(wrfifo_rd_err),
	     .SBITERR			(),
	     .WRCOUNT			(),
	     .WRERR			(wrfifo_wr_err),
	     // Inputs
	     .DI			(wrfifo_wr_di[63:0]),
	     .DIP			(wrfifo_wr_di[71:64]),
	     .RDCLK			(sys_clk),
	     .RDEN			(wrfifo_rd_en),
	     .RST			(sys_rst),
	     .WRCLK			(sys_clk),
	     .WREN			(wrfifo_wr_en));
   defparam wrfifo.FIRST_WORD_FALL_THROUGH = "TRUE";
   reg 	      to64bit;
   reg 	      eof_rdy;
   always @(posedge sys_clk)
     begin
	if (rd_data[35] && ~rd_data[34] && rd_en)     // SOF
	  begin
	     wrfifo_wr_di[31:0] <= #1 rd_data;
	     to64bit            <= #1 rd_data[33] ? 1'b0 : 1'b1; /* Data fis */
	     wrfifo_wr_di[71]   <= #1 1'b1; /* SOF */
	     wrfifo_wr_di[70]   <= #1 1'b0; /* EOF */
	     wrfifo_wr_di[69:64]<= #1 8'h0;
	     wrfifo_wr_en       <= #1 1'b0;
	     eof_rdy            <= #1 1'b0;
	  end
	else if (~rd_data[35] && rd_data[34] && rd_en) // EOF
	  begin
	     wrfifo_wr_di[31:0] <= #1 ~to64bit ? rd_data : wrfifo_wr_di[31:0];
	     wrfifo_wr_di[63:32]<= #1  to64bit ? rd_data : wrfifo_wr_di[63:32];
	     wrfifo_wr_di[71]   <= #1 1'b0; /* SOF */
	     wrfifo_wr_di[70]   <= #1 1'b1; /* EOF */
	     to64bit            <= #1 1'b1;	     
	     wrfifo_wr_en       <= #1 1'b1;
	     eof_rdy            <= #1 1'b1;
	  end
	else if (rd_data[35] && rd_data[34] && rd_en) // 1 word
	  begin
	     wrfifo_wr_di[31:0] <= #1 rd_data[31:0];
	     wrfifo_wr_di[63:32]<= #1 rd_data[31:0];
	     wrfifo_wr_di[71]   <= #1 1'b1; /* SOF */
	     wrfifo_wr_di[70]   <= #1 1'b1; /* EOF */
	     to64bit            <= #1 1'b1;	     	     
	     wrfifo_wr_en       <= #1 1'b1;
	     eof_rdy            <= #1 1'b1;
	  end
	else if (~rd_data[35] && ~rd_data[34] && rd_en)
	  begin
	     wrfifo_wr_di[31:0] <= #1 ~to64bit ? rd_data : wrfifo_wr_di[31:0];
	     wrfifo_wr_di[63:32]<= #1  to64bit ? rd_data : wrfifo_wr_di[63:32];
	     wrfifo_wr_di[71]   <= #1 1'b0; /* SOF */
	     wrfifo_wr_di[70]   <= #1 1'b0; /* EOF */
	     to64bit            <= #1 ~to64bit;	     
	     wrfifo_wr_en       <= #1  to64bit;
	  end
	else if (ififo2port_fo_ack | rxdma2port_ack)
	  begin
	     eof_rdy            <= #1 1'b0;
	  end
	else 
	  begin
	     wrfifo_wr_en       <= #1  1'b0;
	  end
     end // always @ (posedge sys_clk)
   assign rdy   = wrfifo_wr_almost_full | eof_rdy;
   
   wire rd_sof_case;
   wire rd_rdy_case;
   wire rd_data_case;
   assign rd_rdy_case  = ~rd_empty && ~wrfifo_wr_almost_full;
   assign rd_sof_case  = rd_data[35] && state == S_IDLE && (port2ififo_fo_req | port2rxdma_req);
   assign rd_data_case = ~rd_data[35];
   assign rd_en        = (rd_sof_case || rd_data_case) && rd_rdy_case;

   always @(posedge sys_clk)
     begin
	if (~rd_data[35] && rd_en && rd_data[33]) /* Data fis */
	  begin
	     rxdma2port_xfer <= #1 1'b1;
	  end
	else 
	  begin
	     rxdma2port_xfer <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
     always @(posedge sys_clk)
     begin
	rxdma2dbg[7:0] <= #1 state;
	rxdma2dbg[11]  <= #1 frm_done;
	rxdma2dbg[12]  <= #1 seg_done;
	rxdma2dbg[13]  <= #1 wrfifo_rd_empty;
	rxdma2dbg[14]  <= #1 eof_rdy;
	rxdma2dbg[15]  <= #1 1'b0;
     end
     always @(posedge sys_clk)
     begin
	if (state == S_AL_REQ && rx2al_len != 0)
	  begin
	     rxdma2dbg[31:16] <= #1 al2dh_len;
	     rxdma2dbg[8]     <= #1 al2dh_err;
	     rxdma2dbg[9]     <= #1 1'b1;
	     rxdma2dbg[10]    <= #1 1'b0;
	  end
	else if (state == S_AL_REQ && rx2al_len == 0)
	  begin
	     rxdma2dbg[31:16] <= #1 al2dh_len;
	     rxdma2dbg[8]     <= #1 al2dh_err;
	     rxdma2dbg[9]     <= #1 1'b1;
	     rxdma2dbg[10]    <= #1 1'b1;	     
	  end
	else if (state == S_WRT)
	  begin
	     rxdma2dbg[31:16] <= #1 al2dh_len;
	     rxdma2dbg[8]     <= #1 al2dh_err;
	     rxdma2dbg[9]     <= #1 1'b0;
	     rxdma2dbg[10]    <= #1 M_wrError;
	  end
     end // always @ (posedge sys_clk)
   /************************************************************************/
   /*AUTOASCIIENUM("state", "state_ascii", "S_")*/
   // Beginning of automatic ASCII enum decoding
   reg [71:0]		state_ascii;		// Decode of state
   always @(state) begin
      case ({state})
	S_IDLE:      state_ascii = "idle     ";
	S_AL_REQ:    state_ascii = "al_req   ";
	S_BUS_REQ:   state_ascii = "bureq    ";
	S_WRT_REQ:   state_ascii = "wrt_req  ";
	S_WRT:       state_ascii = "wrt      ";
	S_WRT_ACK:   state_ascii = "wrt_ack  ";
	S_BC_UPDATE: state_ascii = "bc_update";
	S_ERROR:     state_ascii = "error    ";
	default:     state_ascii = "%Error   ";
      endcase
   end
   // End of automatics
endmodule
// 
// rxdma.v ends here
