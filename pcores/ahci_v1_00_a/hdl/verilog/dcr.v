// dcr.v --- 
// 
// Filename: dcr.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Fri Sep 10 11:21:03 2010 (+0800)
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
module dcr (/*AUTOARG*/
   // Outputs
   Sl_dcrDBus, Sl_dcrAck, sys_clk0, sys_clk1, sys_rst, interrupt,
   ghc2port_ae, ghc2port_ie, ghc2port_cap,
   // Inputs
   DCR_Clk, DCR_Rst, DCR_Read, DCR_Write, DCR_ABus, DCR_Sl_DBus,
   port2ghc_intr_req0, port2ghc_ips_set0, Sl_dcrDbus_port0,
   port2ghc_PxISIE0, port2ghc_intr_req1, port2ghc_ips_set1,
   Sl_dcrDbus_port1, port2ghc_PxISIE1, M_rdGnt2dbg, M_rdReq2dbg,
   M_wrGnt2dbg, M_wrReq2dbg
   );
   parameter C_CHIPSCOPE = 0;
   parameter C_BIG_ENDIAN = 1;
   parameter C_PORT0 = 4'b0010;
   parameter C_PORT1 = 4'b0011;
   parameter C_PORT2 = 4'b0100;
   parameter C_PORT3 = 4'b0101;
   parameter C_PORT  = 4'b1111;

   input DCR_Clk;
   input DCR_Rst;
   input DCR_Read;
   input DCR_Write;
   input [0:9] DCR_ABus;
   input [0:31] DCR_Sl_DBus;
   output [0:31] Sl_dcrDBus;
   output 	 Sl_dcrAck;

   output 	 sys_clk0;
   output 	 sys_clk1;
   output 	 sys_rst;
   output        interrupt;
   
   wire 	 sys_clk0;
   wire 	 sys_clk1;

   /**********************************************************************/
   output 		ghc2port_ae;
   output 		ghc2port_ie;
   output [31:0] 	ghc2port_cap;
   
   input [15:0] 	port2ghc_intr_req0;
   input [15:0] 	port2ghc_ips_set0;
   input [31:0] 	Sl_dcrDbus_port0;
   input [31:0] 	port2ghc_PxISIE0;
   
   input [15:0] 	port2ghc_intr_req1;
   input [15:0] 	port2ghc_ips_set1;
   input [31:0] 	Sl_dcrDbus_port1;
   input [31:0] 	port2ghc_PxISIE1;
   
   /**********************************************************************/
   input [3:0] 		M_rdGnt2dbg;
   input [3:0] 		M_rdReq2dbg;
   input [3:0] 		M_wrGnt2dbg;
   input [3:0] 		M_wrReq2dbg;
   
   wire [31:0] 		ghc2port_pi;
   wire [31:0] 		ghc2port_vs;
   
   localparam [8:0] 	
     C_CAP    = 9'h0,
     C_GHC    = 9'h1,
     C_IS     = 9'h2,
     C_PI     = 9'h3,
     C_VS     = 9'h4;
   /**********************************************************************/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			Sl_dcrAck;
   reg [0:31]		Sl_dcrDBus;
   reg			ghc2port_ie;
   reg			interrupt;
   // End of automatics

   wire [31:0] 		dbus;
   wire [31:0]          dbus_be;
   assign dbus_be  = DCR_Sl_DBus;

   generate if (C_BIG_ENDIAN == 1)
       assign dbus = dbus_be;
   endgenerate
   genvar i;
   generate if (C_BIG_ENDIAN == 0)
       for (i = 0; i < 32; i = i + 8) begin: dbus_swap
           assign dbus[i+7:i] = dbus_be[31-i:24-i];
       end
   endgenerate

   always @(posedge DCR_Clk)
     begin
	if (DCR_Rst)
	  begin
	     Sl_dcrAck <= #1 1'b0;
	  end
	else if (DCR_Read || DCR_Write)
	  begin
	     Sl_dcrAck <= #1 1'b1;
	  end
	else
	  begin
	     Sl_dcrAck <= #1 1'b0;
	  end
     end // always @ (posedge DCR_Clk)
   wire [8:0] addr;
   assign addr = DCR_ABus[1:9];
   wire [3:0] prt;
   assign prt  = addr[8:5];

   wire [31:0] Sl_dcrDbus_be;
   wire [31:0] Sl_dcrDbus_next;
   generate if (C_BIG_ENDIAN == 1)
       assign Sl_dcrDbus_next = Sl_dcrDbus_be;
   endgenerate
   generate if (C_BIG_ENDIAN == 0)
       for (i = 0; i < 32; i = i + 8) begin: Sl_dcrDbus_next_swap
           assign Sl_dcrDbus_next[i+7:i] = Sl_dcrDbus_be[31-i:24-i];
       end
   endgenerate

   reg [31:0] Sl_dcrDbus_ghc;
   assign Sl_dcrDbus_be = prt == C_PORT0 ? Sl_dcrDbus_port0 : 
			  prt == C_PORT1 ? Sl_dcrDbus_port1 : Sl_dcrDbus_ghc;
   always @(posedge DCR_Clk)
     begin
	  Sl_dcrDBus <= #1 Sl_dcrDbus_next;
     end

   /**********************************************************************/
   reg [15:0] sys_rst_sync;
   always @(posedge DCR_Clk)
     begin
	if (DCR_Rst)
	  begin
	     sys_rst_sync <= #1 32'hffff_ffff;
	  end
	else if (addr == C_GHC && dbus[0] && DCR_Write && Sl_dcrAck)
	  begin
	     sys_rst_sync <= #1 32'hffff_ffff;
	  end
	else 
	  begin
	     sys_rst_sync <= #1 sys_rst_sync << 1;
	  end
     end // always @ (posedge DCR_Clk)
   assign sys_rst = sys_rst_sync[15];
   always @(posedge DCR_Clk)
     begin
	if (sys_rst)
	  begin
	     ghc2port_ie <= #1 1'b0;
	  end
	else if (addr == C_GHC && DCR_Write && Sl_dcrAck)
	  begin
	     ghc2port_ie <= #1 dbus[1];
	  end
     end // always @ (posedge DCR_Clk)
   
   reg [3:0] 		ghc2port_is;
   always @(posedge DCR_Clk)
     begin
	interrupt <= ghc2port_ie & (|ghc2port_is);
     end

generate 
      for (i = 0; i < 4; i = i + 1)
	begin: is_reg
	   always @(posedge DCR_Clk)
	     begin
		if (sys_rst)
		  begin
		     ghc2port_is[i] <= #1 1'b0;
		  end
		else if (|port2ghc_PxISIE0 && i == 0)
		  begin
		     ghc2port_is[i] <= #1 1'b1;
		  end
		else if (|port2ghc_PxISIE1 && i == 1)
		  begin
		     ghc2port_is[i] <= #1 1'b1;
		  end
		else if (addr == C_IS && DCR_Write && Sl_dcrAck && dbus[i])
		  begin
		     ghc2port_is[i] <= #1 1'b0;
		  end
	     end // always @ (posedge DCR_Clk)
	end // block: is_reg
endgenerate
   
   always @(*)
     begin
	Sl_dcrDbus_ghc = 32'h0;
	case (addr)
	  C_CAP : Sl_dcrDbus_ghc = ghc2port_cap;
	  C_GHC :
	    begin
	       Sl_dcrDbus_ghc[31] = 1'b1;
	       Sl_dcrDbus_ghc[01] = ghc2port_ie;
	       Sl_dcrDbus_ghc[00] = sys_rst;
	    end
	  C_IS  : Sl_dcrDbus_ghc  = ghc2port_is;
	  C_PI  : Sl_dcrDbus_ghc  = ghc2port_pi;
	  C_VS  : Sl_dcrDbus_ghc  = ghc2port_vs;
	endcase
     end
   assign ghc2port_ae = 1'b1;
   assign ghc2port_pi = C_PORT;

   assign ghc2port_vs = 32'h0001_0300;
   
   assign ghc2port_cap[31] = 1'b0;
   assign ghc2port_cap[30] = 1'b1;
   assign ghc2port_cap[29] = 1'b0; // TODO
   assign ghc2port_cap[28] = 1'b0;
   assign ghc2port_cap[27] = 1'b1; // SSS
   assign ghc2port_cap[26] = 1'b0;
   assign ghc2port_cap[25] = 1'b0;
   assign ghc2port_cap[24] = 1'b1; // SCLO
   assign ghc2port_cap[23:20]= 4'b0010;
   assign ghc2port_cap[19] = 1'b0;
   assign ghc2port_cap[18] = 1'b1;
   assign ghc2port_cap[17] = 1'b1;
   assign ghc2port_cap[16] = 1'b1;
   assign ghc2port_cap[15] = 1'b1;
   assign ghc2port_cap[14] = 1'b0;
   assign ghc2port_cap[13] = 1'b0;
   assign ghc2port_cap[12:8]= 5'h1f; /* NCS */
   assign ghc2port_cap[7]  = 1'b0;
   assign ghc2port_cap[6]  = 1'b0;
   assign ghc2port_cap[5]  = 1'b0;
   assign ghc2port_cap[4:0]= 3;
   /**********************************************************************/
   assign sys_clk0 = DCR_Clk;
   assign sys_clk1 = sys_clk0;
   /**********************************************************************/
endmodule
