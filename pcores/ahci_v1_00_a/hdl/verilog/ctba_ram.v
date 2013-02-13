// ctba_ram.v --- 
// 
// Filename: ctba_ram.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Wed Sep 15 10:05:56 2010 (+0800)
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
module ctba_ram (/*AUTOARG*/
   // Outputs
   cache2port_ack, cache2ctba_CFL, cache2ctba_A, cache2ctba_W,
   cache2ctba_P, cache2ctba_R, cache2ctba_B, cache2ctba_C,
   cache2ctba_PMP, cache2ctba_PRDTL, cache2ctba_strip_total,
   cache2ctba_strip_index, cache2ctba_strip_enable, cache2ctba_strip,
   cache2ctba_PRDBC, cache2ctba_CTBA, cache2ctba_PRD_off,
   cache2ctba_PRD_cnt,
   // Inputs
   sys_clk, sys_rst, ctba2port_do, ctba2port_idx, ctba2port_ack,
   port2ctba_FetchCmd_req, port2ctba_FetchCmd_slot, port2cache_req,
   port2cache_slot, port2cache_we, ctba2cache_strip,
   port2cache_PRDBC_incr, al2port_PRD_off, ctba2port_PRD_cnt
   );
   input sys_clk;
   input sys_rst;

   input [63:0] ctba2port_do;
   input [1:0] 	ctba2port_idx;
   input 	ctba2port_ack;
   input 	port2ctba_FetchCmd_req;
   input [4:0]  port2ctba_FetchCmd_slot;

   output 	cache2port_ack;
   input 	port2cache_req;
   input [4:0]  port2cache_slot;
   input 	port2cache_we;
   
   output [4:0] cache2ctba_CFL;
   output 	cache2ctba_A;
   output 	cache2ctba_W;
   output 	cache2ctba_P;
   output 	cache2ctba_R;
   output 	cache2ctba_B;
   output 	cache2ctba_C;
   output [3:0] cache2ctba_PMP;
   output [15:0] cache2ctba_PRDTL;

   output [3:0]  cache2ctba_strip_total;
   output [3:0]  cache2ctba_strip_index;
   output 	 cache2ctba_strip_enable;
   output [3:0]  cache2ctba_strip;   
   input  [3:0]  ctba2cache_strip;
   
   output [31:0] cache2ctba_PRDBC;
   output [31:0] cache2ctba_CTBA;
   
   output [31:0] cache2ctba_PRD_off;
   output [15:0] cache2ctba_PRD_cnt;

   input 	 port2cache_PRDBC_incr;
   input [31:0]  al2port_PRD_off;
   input [15:0]  ctba2port_PRD_cnt;
   /**********************************************************************/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			cache2ctba_A;
   reg			cache2ctba_B;
   reg			cache2ctba_C;
   reg [4:0]		cache2ctba_CFL;
   reg [31:0]		cache2ctba_CTBA;
   reg			cache2ctba_P;
   reg [3:0]		cache2ctba_PMP;
   reg [31:0]		cache2ctba_PRDBC;
   reg [15:0]		cache2ctba_PRDTL;
   reg [15:0]		cache2ctba_PRD_cnt;
   reg [31:0]		cache2ctba_PRD_off;
   reg			cache2ctba_R;
   reg			cache2ctba_W;
   reg [3:0]		cache2ctba_strip;
   reg			cache2ctba_strip_enable;
   reg [3:0]		cache2ctba_strip_index;
   reg [3:0]		cache2ctba_strip_total;
   // End of automatics
   
   reg 			cache_ack;
   wire [63:0] 		cache_do;
   reg [63:0] 		cache_di;
   reg [7:0] 		cache_we;
   reg [1:0] 		cache_idx;
   wire [8:0]           cache_addr;
   datamem #(.depth(9))
     datamem(.dout(cache_do),
	     .di(cache_di),
	     .we(cache_we),
	     .a(cache_addr),
	     .sys_clk(sys_clk));
   /**********************************************************************/
   localparam [1:0] // synopsys enum state_info
     S_IDLE = 2'h0,
     S_DATA = 2'h1,
     S_WRT  = 2'h2,
     S_DONE = 2'h3;
   reg [1:0] // synopsys enum state_info
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
	  S_IDLE: if (port2cache_req && ~port2cache_we)
	    begin
	       state_ns = S_DATA;
	    end
	  else if (port2cache_req && port2cache_we)
	    begin
	       state_ns = S_WRT;
	    end
	  S_DATA: if (&cache_idx)
	    begin
	       state_ns = S_DONE;
	    end
	  S_WRT: if (cache_we == 8'hff)
	    begin
	       state_ns = S_DONE;
	    end
	  S_DONE: if (~port2cache_req)
	    begin
	       state_ns = S_IDLE;
	    end
	endcase
     end // always @ (*)
   assign cache_addr = port2ctba_FetchCmd_req ? {port2ctba_FetchCmd_slot, cache_idx} : 
	                                        {port2cache_slot, cache_idx};
   reg [1:0] 	 cache_idx_d1;
   always @(posedge sys_clk)
     begin
	if ((state == S_IDLE || state == S_DATA) && port2cache_req && ~port2cache_we)
	  begin
	     cache_idx   <= #1 cache_idx + 1'b1;
	     cache_ack   <= #1 1'b1;
	  end
	else if (port2ctba_FetchCmd_req)
	  begin
	     cache_idx  <= #1 ctba2port_idx;
	     cache_we   <= #1 ctba2port_ack ? 8'hff : 8'h00;
	     cache_di   <= #1 ctba2port_do;
	  end
	else if (state == S_WRT && cache_we == 8'h00)
	  begin
	     cache_idx  <= #1 2'h0;
	     cache_we   <= #1 8'hf0;
	     cache_di   <= #1 {cache2ctba_PRDBC, 32'h0};
	  end
	else if (state == S_WRT && cache_we == 8'hf0)
	  begin
	     cache_idx  <= #1 2'h3;
	     cache_we   <= #1 8'hff;
	     cache_di   <= #1 {ctba2cache_strip, ctba2port_PRD_cnt, al2port_PRD_off};
	  end
	else
	  begin
	     cache_we   <= #1 8'h00;
	     cache_idx  <= #1 2'h0;
	     cache_ack  <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	cache_idx_d1 <= #1 cache_idx;
     end
   always @(posedge sys_clk)
     begin
	if (cache_idx_d1 == 2'h0 && cache_ack)
	  begin
	     cache2ctba_CFL  <= #1 cache_do[4:0];
	     cache2ctba_A    <= #1 cache_do[5];
	     cache2ctba_W    <= #1 cache_do[6];
	     cache2ctba_P    <= #1 cache_do[7];
	     cache2ctba_R    <= #1 cache_do[8];
	     cache2ctba_B    <= #1 cache_do[9];
	     cache2ctba_C    <= #1 cache_do[10];
	     cache2ctba_PMP  <= #1 cache_do[15:12];
	     cache2ctba_PRDTL<= #1 cache_do[31:16];
	     cache2ctba_PRDBC<= #1 cache_do[63:32];
	  end // if (state == S_IDLE)
	else if (cache_idx_d1 == 2'h1 && cache_ack)
	  begin
	     cache2ctba_CTBA <= #1 cache_do[31:0];
	  end
	else if (cache_idx_d1 == 2'h3 && cache_ack)
	  begin
	     cache2ctba_PRD_off  <= #1 cache_do[31:0];
	     cache2ctba_PRD_cnt  <= #1 cache_do[47:32];
	     cache2ctba_strip    <= #1 cache_do[51:48];
	  end
	else if (cache_idx_d1 == 2'h2 && cache_ack)
	  begin
	     cache2ctba_strip_index <= #1 cache_do[3:0];
	     cache2ctba_strip_total <= #1 cache_do[11:8];
	     cache2ctba_strip_enable<= #1 cache_do[15];
	  end
	else if (port2cache_PRDBC_incr)
	  begin
	     cache2ctba_PRDBC  <= #1 cache2ctba_PRDBC + 8'h4;
	  end
     end // always @ (posedge sys_clk)
   assign cache2port_ack = state == S_DONE;
   /**********************************************************************/
   /*AUTOASCIIENUM("state", "state_ascii", "S_")*/
   // Beginning of automatic ASCII enum decoding
   reg [31:0]		state_ascii;		// Decode of state
   always @(state) begin
      case ({state})
	S_IDLE:   state_ascii = "idle";
	S_DATA:   state_ascii = "data";
	S_WRT:    state_ascii = "wrt ";
	S_DONE:   state_ascii = "done";
	default:  state_ascii = "%Err";
      endcase
   end
   // End of automatics
endmodule
// 
// ctba_ram.v ends here
