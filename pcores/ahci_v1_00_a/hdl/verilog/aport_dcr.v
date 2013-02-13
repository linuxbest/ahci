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
module aport_dcr (/*AUTOARG*/
   // Outputs
   dcr2port_PxSCTL_DET, dcr2port_PxSSTS_DET, dcr2port_PxCMD_POD,
   dcr2port_PxCMD_SUD, dcr2port_PxCMD_FRE, dcr2port_PxCMD_PMA,
   dcr2port_PxCMD_ST, dcr2port_PxCMD_ICC_we, dcr2port_PxFBS_EN,
   dcr2port_PxTFD_STS_BSY, dcr2port_PxTFD_SYS_DRQ,
   dcr2port_PxTFD_SYS_ERR, dcr2port_PxSERR_DIAG_X,
   dcr2port_PxSSTS_IPM, dcr2port_PxIE_PCE, dcr2port_PxCI_ack,
   dcr2port_PxSACT_ack, dcr2port_PxIS_ack, Sl_dcrDbus_port, phyreset,
   host_rst, port2ghc_PxISIE, gtx_tune, PxCLB, PxCLBU, PxFB, PxFBU,
   PxIS, PxIE, PxCMD, PxTFD, PxSIG, PxSSTS, PxSCTL, PxSERR, PxSACT,
   PxCI, PxSNTF, PxFBS, PxVS, dcr2cs_pop, dcr2cs_clk,
   // Inputs
   port2dcr_PxTFD_ERR_we, port2dcr_PxTFD_ERR, port2dcr_PxCMD_CCS,
   port2dcr_PxCMD_CCS_we, port2dcr_PxCI_clear, port2dcr_PxCI,
   port2dcr_PxSACT_clear, port2dcr_PxIS, port2dcr_PxIS_set,
   port2dcr_PxFBS_DWE, port2dcr_PxFBS_DWE_set,
   port2dcr_PxFBS_DWE_clear, port2dcr_PxSERR,
   port2dcr_PxSERR_DIAG_set, port2dcr_PxSERR_ERR_set,
   port2dcr_PxSIG_we, DCR_Clk, DCR_Rst, DCR_Read, DCR_Write, DCR_ABus,
   DCR_Sl_DBus, Sl_dcrAck, sys_clk, sys_rst, linkup,
   port2dcr_PxTFD_STS, port2dcr_PxTFD_STS_we, ififo2dcr_PxSIG,
   ififo2port_SDB_SActive, phyclk, link_fsm2dbg, rx_cs2dbg, tx_cs2dbg,
   port2dbg, err2dbg, al2dbg, ctba2dbg, rxdma2dbg, txdma2dbg,
   txdmadh2dbg, osm_npi2dbg, M_rdGnt2dbg, M_rdReq2dbg, M_wrGnt2dbg,
   M_wrReq2dbg, M_rdBus, M_wrBus, txll2dbg, rxll2dbg,
   cache2ctba_PRDBC, oob2dbg, pDmaXferCnt_ex, pBsyDrq, cs2dcr_prim,
   cs2dcr_cnt
   );
   parameter C_CHIPSCOPE = 0;
   parameter C_BIG_ENDIAN = 1;
   parameter C_PORT = 4'b0010;
   parameter C_VERSION = 32'hdead_deed;
   parameter C_LINKFSM_DEBUG = 0;

   input DCR_Clk;
   input DCR_Rst;
   input DCR_Read;
   input DCR_Write;
   input [0:9] DCR_ABus;
   input [0:31] DCR_Sl_DBus;
   input Sl_dcrAck;
   
   output [31:0] Sl_dcrDbus_port;
   
   output 	 phyreset;
   output 	 host_rst;
   input 	 sys_clk;
   input 	 sys_rst;
   
   input 	 linkup;

   input [7:0] 	 port2dcr_PxTFD_STS;
   input 	 port2dcr_PxTFD_STS_we;

   output [31:0] port2ghc_PxISIE;
   output [31:0] gtx_tune;
   /*AUTOINOUTCOMP("port", "dcr2port")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output [03:0]	dcr2port_PxSCTL_DET;
   output [03:0]	dcr2port_PxSSTS_DET;
   output		dcr2port_PxCMD_POD;
   output		dcr2port_PxCMD_SUD;
   output		dcr2port_PxCMD_FRE;
   output		dcr2port_PxCMD_PMA;
   output		dcr2port_PxCMD_ST;
   output		dcr2port_PxCMD_ICC_we;
   output		dcr2port_PxFBS_EN;
   output		dcr2port_PxTFD_STS_BSY;
   output		dcr2port_PxTFD_SYS_DRQ;
   output		dcr2port_PxTFD_SYS_ERR;
   output		dcr2port_PxSERR_DIAG_X;
   output [3:0]		dcr2port_PxSSTS_IPM;
   output		dcr2port_PxIE_PCE;
   output		dcr2port_PxCI_ack;
   output		dcr2port_PxSACT_ack;
   output		dcr2port_PxIS_ack;
   // End of automatics
   /*AUTOINOUTCOMP("port", "port2dcr")*/
   // Beginning of automatic in/out/inouts (from specific module)
   input		port2dcr_PxTFD_ERR_we;
   input [7:0]		port2dcr_PxTFD_ERR;
   input [4:0]		port2dcr_PxCMD_CCS;
   input		port2dcr_PxCMD_CCS_we;
   input		port2dcr_PxCI_clear;
   input [4:0]		port2dcr_PxCI;
   input		port2dcr_PxSACT_clear;
   input [31:0]		port2dcr_PxIS;
   input		port2dcr_PxIS_set;
   input [3:0]		port2dcr_PxFBS_DWE;
   input		port2dcr_PxFBS_DWE_set;
   input		port2dcr_PxFBS_DWE_clear;
   input [31:0]		port2dcr_PxSERR;
   input		port2dcr_PxSERR_DIAG_set;
   input		port2dcr_PxSERR_ERR_set;
   input		port2dcr_PxSIG_we;
   // End of automatics
   input [31:0] 	ififo2dcr_PxSIG;
   input [31:0] 	ififo2port_SDB_SActive;
   
   output [31:0] 	PxCLB;
   output [31:0] 	PxCLBU;
   output [31:0] 	PxFB;
   output [31:0] 	PxFBU;
   output [31:0] 	PxIS;
   output [31:0] 	PxIE;
   output [31:0] 	PxCMD;
   output [31:0] 	PxTFD;
   output [31:0] 	PxSIG;
   output [31:0] 	PxSSTS;
   output [31:0] 	PxSCTL;
   output [31:0] 	PxSERR;
   output [31:0] 	PxSACT;
   output [31:0] 	PxCI;
   output [31:0] 	PxSNTF;   
   output [31:0] 	PxFBS;
   output [31:0] 	PxVS;
   
   /**********************************************************************/
   input                phyclk;
   input [127:0] 	link_fsm2dbg;
   input [127:0] 	rx_cs2dbg;
   input [127:0] 	tx_cs2dbg;
   input [127:0]        port2dbg;
   input [31:0] 	err2dbg;
   input [127:0]        al2dbg;
   input [31:0]         ctba2dbg;
   input [31:0]         rxdma2dbg;
   input [31:0]         txdma2dbg;
   input [31:0]         txdmadh2dbg;
   input [31:0]         osm_npi2dbg;
   input [3:0]          M_rdGnt2dbg;
   input [3:0]          M_rdReq2dbg;
   input [3:0]          M_wrGnt2dbg;
   input [3:0]          M_wrReq2dbg;
   input [127:0]        M_rdBus;
   input [127:0]        M_wrBus;
   input [31:0]         txll2dbg;
   input [31:0]         rxll2dbg;
   input [31:0]         cache2ctba_PRDBC;
   input [127:0]        oob2dbg;
   input [31:0]         pDmaXferCnt_ex;
   input [31:0]         pBsyDrq;

   input [35:0] 	cs2dcr_prim;
   input [8:0] 		cs2dcr_cnt;
   output 		dcr2cs_pop;
   output 		dcr2cs_clk;
   /**********************************************************************/
   localparam [4:0]
     C_PxCLB  = 5'h0,		// 0x00
     C_PxCLBU = 5'h1,		// 0x04
     C_PxFB   = 5'h2,		// 0x08
     C_PxFBU  = 5'h3,		// 0x0C
     C_PxIS   = 5'h4,		// 0x10
     C_PxIE   = 5'h5,		// 0x14
     C_PxCMD  = 5'h6,		// 0x18
     C_PxTFD  = 5'h8,		// 0x20
     C_PxSIG  = 5'h9,		// 0x24
     C_PxSSTS = 5'ha,		// 0x28
     C_PxSCTL = 5'hb,		// 0x2C
     C_PxSERR = 5'hc,		// 0x30
     C_PxSACT = 5'hd,		// 0x34
     C_PxCI   = 5'he,		// 0x38
     C_PxSNTF = 5'hf,		// 0x3C
     C_PxFBS  = 5'h10,		// 0x40
     C_PxVS   = 5'h1c;		// 0x70
   /**********************************************************************/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [31:0]		PxCI;
   reg [31:0]		PxCLB;
   reg [31:0]		PxCLBU;
   reg [31:0]		PxCMD;
   reg [31:0]		PxFB;
   reg [31:0]		PxFBS;
   reg [31:0]		PxFBU;
   reg [31:0]		PxIE;
   reg [31:0]		PxIS;
   reg [31:0]		PxSACT;
   reg [31:0]		PxSCTL;
   reg [31:0]		PxSERR;
   reg [31:0]		PxSIG;
   reg [31:0]		PxSNTF;
   reg [31:0]		PxSSTS;
   reg [31:0]		PxTFD;
   reg [31:0]		PxVS;
   reg [31:0]		Sl_dcrDbus_port;
   reg			dcr2port_PxCI_ack;
   reg			dcr2port_PxIE_PCE;
   reg			dcr2port_PxIS_ack;
   reg			dcr2port_PxSACT_ack;
   reg [3:0]		dcr2port_PxSSTS_IPM;
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

   wire [4:0] paddr;
   assign paddr = prt == C_PORT ? addr[4:0] : 5'h1f;

   wire linkfsm_debug;
   assign linkfsm_debug = C_LINKFSM_DEBUG;
   always @(*)
     begin
	Sl_dcrDbus_port = 32'h0;
	case (addr[4:0])
	  C_PxCLB  : Sl_dcrDbus_port = PxCLB;
	  C_PxCLBU : Sl_dcrDbus_port = cs2dcr_prim;
	  C_PxFB   : Sl_dcrDbus_port = PxFB;
	  C_PxFBU  : Sl_dcrDbus_port = {linkfsm_debug, cs2dcr_prim[35:32], cs2dcr_cnt};
	  C_PxIS   : Sl_dcrDbus_port = PxIS;
	  C_PxIE   : Sl_dcrDbus_port = PxIE;
	  C_PxCMD  : Sl_dcrDbus_port = PxCMD;
	  5'h7     : Sl_dcrDbus_port = cache2ctba_PRDBC;
	  C_PxTFD  : Sl_dcrDbus_port = PxTFD;
	  C_PxSIG  : Sl_dcrDbus_port = PxSIG;
	  C_PxSSTS : Sl_dcrDbus_port = PxSSTS;
	  C_PxSCTL : Sl_dcrDbus_port = PxSCTL;
	  C_PxSERR : Sl_dcrDbus_port = PxSERR;
	  C_PxSACT : Sl_dcrDbus_port = PxSACT;
	  C_PxCI   : Sl_dcrDbus_port = PxCI;
	  C_PxSNTF : Sl_dcrDbus_port = PxSNTF;
	  C_PxFBS  : Sl_dcrDbus_port = PxFBS;
	  5'h11    : Sl_dcrDbus_port = port2dbg;
	  5'h12    : Sl_dcrDbus_port = al2dbg;
	  5'h13    : Sl_dcrDbus_port = ctba2dbg;
	  5'h14    : Sl_dcrDbus_port = rxdma2dbg;
	  5'h15    : Sl_dcrDbus_port = txdma2dbg;
	  5'h16    : Sl_dcrDbus_port = txdmadh2dbg;
	  5'h17    : Sl_dcrDbus_port = osm_npi2dbg;
	  5'h18    : Sl_dcrDbus_port = txll2dbg;
	  5'h19    : Sl_dcrDbus_port = rxll2dbg;
	  5'h1a    : Sl_dcrDbus_port = link_fsm2dbg;
	  5'h1b    : Sl_dcrDbus_port = err2dbg;
	  C_PxVS   : Sl_dcrDbus_port = PxVS;
	  5'h1d    : Sl_dcrDbus_port = pBsyDrq;
	  5'h1e    : Sl_dcrDbus_port = pDmaXferCnt_ex;
	  5'h1f    : Sl_dcrDbus_port = C_VERSION;
	endcase
     end // always @ (*)

   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     PxCLB <= #1 32'h0;
	  end
	else if (paddr == C_PxCLB && DCR_Write)
	  begin
	     PxCLB <= #1 dbus;	     
	  end
     end // always @ (posedge sys_clk)

   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     PxCLBU <= #1 32'h0;
	  end
	/*else if (addr == C_PxCLBU && DCR_Write)
	  begin
	     PxCLBU <= #1 dbus;	     
	  end*/
     end // always @ (posedge sys_clk)

   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     PxFB  <= #1 32'h0;
	  end
	else if (paddr == C_PxFB && DCR_Write)
	  begin
	     PxFB <= #1 dbus;	     
	  end
     end // always @ (posedge sys_clk)

   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     PxFBU <= #1 32'h0;
	  end
	/*else if (addr == C_PxFBU && DCR_Write)
	  begin
	     PxFBU <= #1 dbus;	     
	  end*/
     end // always @ (posedge sys_clk)
  
   /* TODO
    * [31] CDPS
    * [30] TFES
    * [29] FBFS
    * [28] HBDS
    * [27] IFS
    * [26] INFS
    * [25] 0
    * [24] OFS
    * [23] IPMS
    * [22] PRCS
    * [21:8] 0
    * [7]  DMPS
    * [6]  PCS
    * [5]  DPS
    * [4]  UFS
    * [3]  SDBS
    * [2]  DSS
    * [1]  PSS
    * [0]  DHRS
    */
   always @(posedge sys_clk)
     begin
	if (paddr == C_PxIS && DCR_Write && Sl_dcrAck)
	  begin
	     dcr2port_PxIS_ack <= #1 1'b0;
	  end
	else if (port2dcr_PxIS_set)
	  begin
	     dcr2port_PxIS_ack <= #1 1'b1;	     
	  end
	else
	  begin
	     dcr2port_PxIS_ack <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)
   generate
      for (i = 0; i < 32; i = i + 1)
	begin: PxIS_reg
	   always @(posedge sys_clk)
	     begin
		if (sys_rst)
		  begin
		     PxIS[i] <= #1 1'b0;
		  end
		else if (paddr == C_PxIS && DCR_Write && Sl_dcrAck && dbus[i])
		  begin
		     PxIS[i] <= #1 1'b0;
		  end
		else if (i == 22)
		  begin
		     PxIS[i] <= #1 PxSERR[16]; /* N */
		  end
		else if (i == 6)
		  begin
		     PxIS[i] <= #1 PxSERR[26]; /* X */
		  end		
		else if (port2dcr_PxIS_set && port2dcr_PxIS[i])
		  begin
		     PxIS[i] <= #1 1'b1;
		  end
	     end // always @ (posedge sys_clk)
	end
   endgenerate
   
   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     PxIE <= #1 32'h0;
	  end
	else if (paddr == C_PxIE && DCR_Write && Sl_dcrAck)
	  begin
	     PxIE <= #1 dbus;	     
	  end
     end // always @ (posedge sys_clk)

   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     PxCMD[31:23] <= #1 32'h0;
	     PxCMD[22]    <= #1 1'b0; /* FBSCP */
	     PxCMD[21]    <= #1 1'b0; /* ESP   */
	     PxCMD[20]    <= #1 1'b0; /* CPD   */
	     PxCMD[19]    <= #1 1'b0; /* MPSP  */
	     PxCMD[18]    <= #1 1'b1; /* HPCP  */
	     PxCMD[17]    <= #1 1'b0; /* PMA   */
	     PxCMD[16]    <= #1 1'b1; /* CPS   */
	     PxCMD[15]    <= #1 1'b0; /* CR TODO wire the txdma&rxdma */
	     PxCMD[14]    <= #1 1'b0; /* FR TODO */
	     PxCMD[13]    <= #1 1'b0; /* MPSS */
	     PxCMD[12:8]  <= #1 4'h0; /* CCS TODO */
	     PxCMD[7:5]   <= #1 3'h0;
	     PxCMD[4]     <= #1 1'b0; /* FRE   */
	     PxCMD[3]     <= #1 1'b0; /* CLO  TODO */
	     PxCMD[2]     <= #1 4'h0; /* POD */
	     PxCMD[1]     <= #1 4'h0; /* SUD */
	     PxCMD[0]     <= #1 4'h0; /* ST */
	  end
	else if (paddr == C_PxCMD && DCR_Write && Sl_dcrAck)
	  begin
	     PxCMD[31:23] <= #1 dbus[31:23];
	     PxCMD[17]    <= #1 dbus[17];  /* PMA */
	     PxCMD[4]     <= #1 dbus[4];   /* FRE */
	     PxCMD[3:0]   <= #1 dbus[3:0];
	  end
	else if (port2dcr_PxCMD_CCS_we)
	  begin
	     PxCMD[12:8] <= port2dcr_PxCMD_CCS;
	  end
	else if (PxCMD[3] &&	     // CLO
		 PxTFD[3] == 1'b0 && // DRQ
		 PxTFD[7] == 1'b0)   // BSY
	  begin
	     PxCMD[3]    <= 1'b0;
	  end
     end // always @ (posedge sys_clk)
   
   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     PxTFD[7:0] <= #1 32'h0;
	     PxTFD[31:16]<=#1 16'h0;
	  end
	else if (port2dcr_PxTFD_STS_we)
	  begin
	     PxTFD[7:0] <= #1 port2dcr_PxTFD_STS;
	  end
	else if (PxCMD[3])
	  begin
	     PxTFD[3]   <= #1 1'b0; // DRQ
	     PxTFD[7]   <= #1 1'b0; // BSY
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     PxTFD[15:8] <= #1 32'h0;
	  end
	else if (port2dcr_PxTFD_ERR_we)
	  begin
	     PxTFD[15:8] <= #1 port2dcr_PxTFD_ERR;
	  end	
     end
   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     PxSIG <= #1 32'hFFFF_FFFF;
	  end
	else if (port2dcr_PxSIG_we)
	  begin
	     PxSIG <= #1 ififo2dcr_PxSIG;
	  end
     end // always @ (posedge sys_clk)

   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     PxSSTS <= #1 32'h0;
	  end
	else if (linkup)
	  begin
	     PxSSTS[11:8] <= #1 4'h1; /* IPM TODO    */
	     PxSSTS[7:4]  <= #1 4'h2; /* SPD G2 only */
	     PxSSTS[3:0]  <= #1 4'h3; /* DET TODO    */
	  end
	else if (~linkup)
	  begin
	     PxSSTS[11:8] <= #1 4'h0;
	     PxSSTS[7:4]  <= #1 4'h0;
	     PxSSTS[3:0]  <= #1 4'h0;
	  end
     end // always @ (posedge sys_clk)

   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     PxSCTL <= #1 32'h0;
	  end
	else if (paddr == C_PxSCTL && DCR_Write && Sl_dcrAck)
	  begin
	     PxSCTL <= #1 dbus;
	  end
     end // always @ (posedge sys_clk)

   /* TODO
    * [26] X
    * [25] F
    * [24] T
    * [23] S
    * [22] H
    * [21] C
    * [20] D
    * [19] B
    * [18] W
    * [17] I
    * [16] N
    * [15:12] 
    * [11] E
    * [10] P
    * [9]  C
    * [8]  T
    * [7:2] 
    * [1]  M
    * [0]  I
    */
   generate
      for (i = 0; i < 32; i = i + 1)
	begin: SERR_reg
	   always @(posedge sys_clk)
	     begin
		if (sys_rst)
		  begin
		     PxSERR[i] <= #1 1'b0;
		  end
		else if (paddr == C_PxSERR && DCR_Write && Sl_dcrAck && dbus[i])
		  begin
		     PxSERR[i] <= #1 1'b0;
		  end
		else if (port2dcr_PxSERR_ERR_set && port2dcr_PxSERR[i])
		  begin
		     PxSERR[i] <= #1 1'b1;		     
		  end
		else if (port2dcr_PxSERR_DIAG_set && port2dcr_PxSERR[i])
		  begin
		     PxSERR[i] <= #1 1'b1;		     
		  end
	     end // always @ (posedge sys_clk)
	end // block: SERR_reg
   endgenerate

   reg PxCMD_ST;
   always @(posedge sys_clk)
     begin
	PxCMD_ST <= #1 dcr2port_PxCMD_ST;
     end

   always @(posedge sys_clk)
     begin
	if (paddr == C_PxCI && DCR_Write && Sl_dcrAck)
	  begin
	     dcr2port_PxCI_ack <= #1 1'b0;
	  end
	else if (port2dcr_PxCI_clear)
	  begin
	     dcr2port_PxCI_ack <= #1 1'b1;
	  end
	else
	  begin
	     dcr2port_PxCI_ack <= #1 1'b0;
	  end	
     end
   always @(posedge sys_clk)
     begin
	if (paddr == C_PxSACT && DCR_Write && Sl_dcrAck)
	  begin
	     dcr2port_PxSACT_ack <= #1 1'b0;	     
	  end
	else if (port2dcr_PxSACT_clear)
	  begin
	     dcr2port_PxSACT_ack <= #1 1'b1;
	  end
	else
	  begin
	     dcr2port_PxSACT_ack <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)
   
   generate
      for (i = 0; i < 32; i = i + 1) 
	begin: PxCI_reg
	   always @(posedge sys_clk)
	     begin
		if (sys_rst || 
		    (PxCMD_ST == 1'b1 &&
		     dcr2port_PxCMD_ST == 1'b0))
		  begin
		     PxSACT[i] <= #1 1'b0;
		  end
		else if (paddr == C_PxSACT && DCR_Write && Sl_dcrAck && dbus[i])
		  begin
		     PxSACT[i] <= #1 1'b1;
		  end
		else if (port2dcr_PxSACT_clear && ififo2port_SDB_SActive[i])
		  begin
		     PxSACT[i] <= #1 1'b0;
		  end
	     end // always @ (posedge sys_clk)
	   always @(posedge sys_clk)
	     begin
		if (sys_rst ||
		    (PxCMD_ST == 1'b1 &&
		     dcr2port_PxCMD_ST == 1'b0))
		  begin
		     PxCI[i] <= #1 1'b0;
		  end
		else if (paddr == C_PxCI && DCR_Write && Sl_dcrAck && dbus[i])
		  begin
		     PxCI[i] <= #1 1'b1;
		  end
		else if (port2dcr_PxCI_clear && port2dcr_PxCI == i)
		  begin
		     PxCI[i] <= #1 1'b0;
		  end
	     end // always @ (posedge sys_clk)
	end // block: PxCI_reg
   endgenerate

   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     PxSNTF <= #1 32'h0;
	  end
	/*else if (paddr == C_PxSNTF && DCR_Write && Sl_dcrAck)
	  begin
	     PxSNTF <= #1 dbus;	     
	  end*/
     end // always @ (posedge sys_clk)

   /* TODO
    * [19:16] DWE
    * [15:12] ADO
    * [11:8]  DEV
    * [7:3]
    * [2]     SDE
    * [1]     DEC
    * [0]     EN
    */
   always @(posedge sys_clk)
     begin
	PxFBS[31:16] <= #1 port2dcr_PxFBS_DWE;
	PxFBS[15:12] <= #1 4'h2;
     end
   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     PxFBS[11:8] <= #1 4'h0;
	  end
	else if (paddr == C_PxFBS && DCR_Write)
	  begin
	     PxFBS[11:8] <= #1 dbus[11:8];
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     PxFBS[2] <= #1 1'b0;
	  end
	else if (port2dcr_PxFBS_DWE_set)
	  begin
	     PxFBS[2] <= #1 1'b1;
	  end
	else if (port2dcr_PxFBS_DWE_clear)
	  begin
	     PxFBS[2] <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     PxFBS[1] <= #1 1'b0;
	     PxFBS[0] <= #1 1'b0;
	  end
	else if (paddr == C_PxFBS && DCR_Write && Sl_dcrAck)
	  begin
	     PxFBS[1] <= #1 dbus[1];
	     PxFBS[0] <= #1 dbus[0];
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     PxVS <= #1 32'h0;
	  end
	else if (paddr == C_PxVS && DCR_Write && Sl_dcrAck)
	  begin
	     PxVS <= #1 dbus;	     
	  end
     end // always @ (posedge sys_clk)

   assign dcr2port_PxCMD_ICC_we = 1'b0;
   assign dcr2port_PxCMD_PMA    = PxCMD[17];
   assign dcr2port_PxCMD_FRE    = PxCMD[4];   
   assign dcr2port_PxCMD_POD    = PxCMD[2];
   assign dcr2port_PxCMD_SUD    = PxCMD[1];
   assign dcr2port_PxCMD_ST     = PxCMD[0];
   
   assign dcr2port_PxSCTL_DET   = PxSCTL[3:0];
   
   assign dcr2port_PxSSTS_DET   = PxSSTS[3:0];

   assign dcr2port_PxTFD_SYS_ERR= PxTFD[0];
   assign dcr2port_PxTFD_SYS_DRQ= PxTFD[3];
   assign dcr2port_PxTFD_STS_BSY= PxTFD[7];
   
   assign dcr2port_PxSERR_DIAG_X= PxSERR[26];
   
   assign dcr2port_PxFBS_EN     = PxFBS[0];
   assign port2ghc_PxISIE       = PxIS & PxIE;

   assign dcr2cs_pop = paddr == C_PxFBU && DCR_Write && Sl_dcrAck;
   assign dcr2cs_clk = sys_clk;
   assign gtx_tune   = PxVS;
   /**********************************************************************/
   assign phyreset = sys_rst;
   assign host_rst = sys_rst;
   /**********************************************************************/
   wire [35:0] CONTROL0;
   wire [35:0] CONTROL1;
   wire [35:0] CONTROL2;
   wire        trig0;
   wire        trig1;
   wire        trig2;
   wire        trig3;
   wire [127:0] dbg0;
   wire [127:0] dbg1;
   wire [127:0] dbg2;
   generate if (C_CHIPSCOPE == 1 && C_PORT == 4'b0010)
     begin
	chipscope_icon3 
	  icon (.CONTROL0   (CONTROL0[35:0]),
		.CONTROL1   (CONTROL1[35:0]),
		.CONTROL2   (CONTROL2[35:0]));
        chipscope_ila_128x1
	  dbX0 (.TRIG_OUT (trig0),
		.CONTROL  (CONTROL0[35:0]),
		.CLK      (phyclk),
		.TRIG0    ({trig2,oob2dbg[126:0]}));
        chipscope_ila_128x1
	  dbX1 (.TRIG_OUT (trig1),
		.CONTROL  (CONTROL1[35:0]),
		.CLK      (phyclk),
		.TRIG0    (dbg1));
	assign dbg1[127]    =trig2;
	assign dbg1[126:123]=0;
	assign dbg1[122:115]=port2dbg[7:0];
	assign dbg1[114:0]=link_fsm2dbg[114:0];
        chipscope_ila_128x1
	  dbX2 (.TRIG_OUT (trig2),
		.CONTROL  (CONTROL2[35:0]),
		.CLK      (sys_clk),
		.TRIG0    (dbg2));
	assign dbg2[63:0]  = port2dbg;
	assign dbg2[95:64] = rxdma2dbg;
	assign dbg2[127:96]= rxll2dbg;
     end
   endgenerate
endmodule // aport_dcr
//
// aport_dcr.v ends here
module chipscope_icon3 (
CONTROL0, CONTROL1, CONTROL2
)/* synthesis syn_black_box syn_noprune=1 */;
  inout [35 : 0] CONTROL0;
  inout [35 : 0] CONTROL1;
  inout [35 : 0] CONTROL2;
 
endmodule

module chipscope_ila_128x1 (
  CLK, TRIG_OUT, CONTROL, TRIG0
)/* synthesis syn_black_box syn_noprune=1 */;
  input CLK;
  output TRIG_OUT;
  inout [35 : 0] CONTROL;
  input [127 : 0] TRIG0;
 
endmodule
