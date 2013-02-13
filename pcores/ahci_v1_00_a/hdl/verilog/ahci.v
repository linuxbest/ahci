// ahci.v --- 
// 
// Filename: ahci.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Fri Sep 10 11:16:15 2010 (+0800)
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
module ahci (/*AUTOARG*/
   // Outputs
   txdatak1, txdatak0, txdata1, txdata0, sata_ledB1, sata_ledB0,
   sata_ledA1, sata_ledA0, phyreset1, phyreset0, interrupt, gtx_tune1,
   gtx_tune0, StartComm1, StartComm0, Sl_dcrDBus, M_wrType, M_wrReq,
   M_wrPriority, M_wrOrdered, M_wrNum, M_wrLockErr, M_wrGuarded,
   M_wrData, M_wrCompress, M_wrBE, M_wrAddr, M_wrAbort, M_rdType,
   M_rdReq, M_rdPriority, M_rdNum, M_rdLockErr, M_rdGuarded,
   M_rdCompress, M_rdBE, M_rdAddr, M_rdAbort, M_Lock, Sl_dcrAck,
   // Inputs
   txdatak_pop1, txdatak_pop0, rxdatak1, rxdatak0, rxdata1, rxdata0,
   plllock1, plllock0, phyclk1, phyclk0, oob2dbg1, oob2dbg0, linkup1,
   linkup0, gtx_txdatak1, gtx_txdatak0, gtx_txdata1, gtx_txdata0,
   gtx_rxdatak1, gtx_rxdatak0, gtx_rxdata1, gtx_rxdata0, M_wrRearb,
   M_wrRdy, M_wrError, M_wrComp, M_wrAck, M_wrAccept, M_rdRearb,
   M_rdError, M_rdData, M_rdComp, M_rdAck, M_rdAccept, DCR_Write,
   DCR_Sl_DBus, DCR_Rst, DCR_Read, DCR_ABus, CommInit1, CommInit0,
   M_Error, M_Reset, M_Clk, DCR_Clk
   );
   parameter C_NUM_WIDTH = 5;
   parameter C_FAMILY = "virtex5";
   parameter C_PM = 16;
   parameter C_CHIPSCOPE = 0;
   parameter C_BIG_ENDIAN = 0;
   parameter C_PORT = 4'b1111;
   parameter C_VERSION = 32'hdead_dead;
   parameter C_LINKFSM_DEBUG = 0;
   parameter C_HW_RAID = 0;

   localparam C_DEBUG_TX_FIFO = 0;
   localparam C_DEBUG_RX_FIFO = 0;
   localparam C_PORT0 = 4'b0010;
   localparam C_PORT1 = 4'b0011;
   localparam C_PORT2 = 4'b0100;
   localparam C_PORT3 = 4'b0101;
   
   output M_Lock;
   input  M_Error;
   input  M_Reset;

   output Sl_dcrAck;

   (* PERIOD = "10000ps" *)
   input M_Clk;
   /* 100Mhz */
   (* PERIOD = "10000ps" *)
   input DCR_Clk;
   /* 100Mhz */
  
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		CommInit0;		// To aport0 of aport.v
   input		CommInit1;		// To aport1 of aport.v
   input [0:9]		DCR_ABus;		// To aport0 of aport.v, ...
   input		DCR_Read;		// To aport0 of aport.v, ...
   input		DCR_Rst;		// To aport0 of aport.v, ...
   input [0:31]		DCR_Sl_DBus;		// To aport0 of aport.v, ...
   input		DCR_Write;		// To aport0 of aport.v, ...
   input		M_rdAccept;		// To ipic_rd of ipic_rd.v
   input		M_rdAck;		// To ipic_rd of ipic_rd.v
   input		M_rdComp;		// To ipic_rd of ipic_rd.v
   input [63:0]		M_rdData;		// To ipic_rd of ipic_rd.v
   input		M_rdError;		// To ipic_rd of ipic_rd.v
   input		M_rdRearb;		// To ipic_rd of ipic_rd.v
   input		M_wrAccept;		// To ipic_wr of ipic_wr.v
   input		M_wrAck;		// To ipic_wr of ipic_wr.v
   input		M_wrComp;		// To ipic_wr of ipic_wr.v
   input		M_wrError;		// To ipic_wr of ipic_wr.v
   input		M_wrRdy;		// To ipic_wr of ipic_wr.v
   input		M_wrRearb;		// To ipic_wr of ipic_wr.v
   input [31:0]		gtx_rxdata0;		// To aport0 of aport.v
   input [31:0]		gtx_rxdata1;		// To aport1 of aport.v
   input [3:0]		gtx_rxdatak0;		// To aport0 of aport.v
   input [3:0]		gtx_rxdatak1;		// To aport1 of aport.v
   input [31:0]		gtx_txdata0;		// To aport0 of aport.v
   input [31:0]		gtx_txdata1;		// To aport1 of aport.v
   input [3:0]		gtx_txdatak0;		// To aport0 of aport.v
   input [3:0]		gtx_txdatak1;		// To aport1 of aport.v
   input		linkup0;		// To aport0 of aport.v
   input		linkup1;		// To aport1 of aport.v
   input [127:0]	oob2dbg0;		// To aport0 of aport.v
   input [127:0]	oob2dbg1;		// To aport1 of aport.v
   input		phyclk0;		// To aport0 of aport.v
   input		phyclk1;		// To aport1 of aport.v
   input		plllock0;		// To aport0 of aport.v
   input		plllock1;		// To aport1 of aport.v
   input [31:0]		rxdata0;		// To aport0 of aport.v
   input [31:0]		rxdata1;		// To aport1 of aport.v
   input		rxdatak0;		// To aport0 of aport.v
   input		rxdatak1;		// To aport1 of aport.v
   input		txdatak_pop0;		// To aport0 of aport.v
   input		txdatak_pop1;		// To aport1 of aport.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		M_rdAbort;		// From ipic_rd of ipic_rd.v
   output [31:0]	M_rdAddr;		// From ipic_rd of ipic_rd.v
   output [7:0]		M_rdBE;			// From ipic_rd of ipic_rd.v
   output		M_rdCompress;		// From ipic_rd of ipic_rd.v
   output		M_rdGuarded;		// From ipic_rd of ipic_rd.v
   output		M_rdLockErr;		// From ipic_rd of ipic_rd.v
   output [C_NUM_WIDTH-1:0] M_rdNum;		// From ipic_rd of ipic_rd.v
   output [1:0]		M_rdPriority;		// From ipic_rd of ipic_rd.v
   output		M_rdReq;		// From ipic_rd of ipic_rd.v
   output [2:0]		M_rdType;		// From ipic_rd of ipic_rd.v
   output		M_wrAbort;		// From ipic_wr of ipic_wr.v
   output [31:0]	M_wrAddr;		// From ipic_wr of ipic_wr.v
   output [7:0]		M_wrBE;			// From ipic_wr of ipic_wr.v
   output		M_wrCompress;		// From ipic_wr of ipic_wr.v
   output [63:0]	M_wrData;		// From ipic_wr of ipic_wr.v
   output		M_wrGuarded;		// From ipic_wr of ipic_wr.v
   output		M_wrLockErr;		// From ipic_wr of ipic_wr.v
   output [C_NUM_WIDTH-1:0] M_wrNum;		// From ipic_wr of ipic_wr.v
   output		M_wrOrdered;		// From ipic_wr of ipic_wr.v
   output [1:0]		M_wrPriority;		// From ipic_wr of ipic_wr.v
   output		M_wrReq;		// From ipic_wr of ipic_wr.v
   output [2:0]		M_wrType;		// From ipic_wr of ipic_wr.v
   output [0:31]	Sl_dcrDBus;		// From dcr of dcr.v
   output		StartComm0;		// From aport0 of aport.v
   output		StartComm1;		// From aport1 of aport.v
   output [31:0]	gtx_tune0;		// From aport0 of aport.v
   output [31:0]	gtx_tune1;		// From aport1 of aport.v
   output		interrupt;		// From dcr of dcr.v
   output		phyreset0;		// From aport0 of aport.v
   output		phyreset1;		// From aport1 of aport.v
   output		sata_ledA0;		// From aport0 of aport.v
   output		sata_ledA1;		// From aport1 of aport.v
   output		sata_ledB0;		// From aport0 of aport.v
   output		sata_ledB1;		// From aport1 of aport.v
   output [31:0]	txdata0;		// From aport0 of aport.v
   output [31:0]	txdata1;		// From aport1 of aport.v
   output		txdatak0;		// From aport0 of aport.v
   output		txdatak1;		// From aport1 of aport.v
   // End of automatics
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			M_rdAbort0;		// From aport0 of aport.v
   wire			M_rdAbort1;		// From aport0 of aport.v
   wire			M_rdAbort2;		// From aport1 of aport.v
   wire			M_rdAbort3;		// From aport1 of aport.v
   wire			M_rdAccept0;		// From ipic_rd of ipic_rd.v
   wire			M_rdAccept1;		// From ipic_rd of ipic_rd.v
   wire			M_rdAccept2;		// From ipic_rd of ipic_rd.v
   wire			M_rdAccept3;		// From ipic_rd of ipic_rd.v
   wire			M_rdAck0;		// From ipic_rd of ipic_rd.v
   wire			M_rdAck1;		// From ipic_rd of ipic_rd.v
   wire			M_rdAck2;		// From ipic_rd of ipic_rd.v
   wire			M_rdAck3;		// From ipic_rd of ipic_rd.v
   wire [31:0]		M_rdAddr0;		// From aport0 of aport.v
   wire [31:0]		M_rdAddr1;		// From aport0 of aport.v
   wire [31:0]		M_rdAddr2;		// From aport1 of aport.v
   wire [31:0]		M_rdAddr3;		// From aport1 of aport.v
   wire [7:0]		M_rdBE0;		// From aport0 of aport.v
   wire [7:0]		M_rdBE1;		// From aport0 of aport.v
   wire [7:0]		M_rdBE2;		// From aport1 of aport.v
   wire [7:0]		M_rdBE3;		// From aport1 of aport.v
   wire [127:0]		M_rdBus;		// From ipic_rd of ipic_rd.v
   wire			M_rdComp0;		// From ipic_rd of ipic_rd.v
   wire			M_rdComp1;		// From ipic_rd of ipic_rd.v
   wire			M_rdComp2;		// From ipic_rd of ipic_rd.v
   wire			M_rdComp3;		// From ipic_rd of ipic_rd.v
   wire			M_rdCompress0;		// From aport0 of aport.v
   wire			M_rdCompress1;		// From aport0 of aport.v
   wire			M_rdCompress2;		// From aport1 of aport.v
   wire			M_rdCompress3;		// From aport1 of aport.v
   wire [63:0]		M_rdData0;		// From ipic_rd of ipic_rd.v
   wire [63:0]		M_rdData1;		// From ipic_rd of ipic_rd.v
   wire [63:0]		M_rdData2;		// From ipic_rd of ipic_rd.v
   wire [63:0]		M_rdData3;		// From ipic_rd of ipic_rd.v
   wire			M_rdError0;		// From ipic_rd of ipic_rd.v
   wire			M_rdError1;		// From ipic_rd of ipic_rd.v
   wire			M_rdError2;		// From ipic_rd of ipic_rd.v
   wire			M_rdError3;		// From ipic_rd of ipic_rd.v
   wire [3:0]		M_rdGnt2dbg;		// From ipic_rd of ipic_rd.v
   wire			M_rdGuarded0;		// From aport0 of aport.v
   wire			M_rdGuarded1;		// From aport0 of aport.v
   wire			M_rdGuarded2;		// From aport1 of aport.v
   wire			M_rdGuarded3;		// From aport1 of aport.v
   wire			M_rdLockErr0;		// From aport0 of aport.v
   wire			M_rdLockErr1;		// From aport0 of aport.v
   wire			M_rdLockErr2;		// From aport1 of aport.v
   wire			M_rdLockErr3;		// From aport1 of aport.v
   wire [C_NUM_WIDTH-1:0] M_rdNum0;		// From aport0 of aport.v
   wire [C_NUM_WIDTH-1:0] M_rdNum1;		// From aport0 of aport.v
   wire [C_NUM_WIDTH-1:0] M_rdNum2;		// From aport1 of aport.v
   wire [C_NUM_WIDTH-1:0] M_rdNum3;		// From aport1 of aport.v
   wire [1:0]		M_rdPriority0;		// From aport0 of aport.v
   wire [1:0]		M_rdPriority1;		// From aport0 of aport.v
   wire [1:0]		M_rdPriority2;		// From aport1 of aport.v
   wire [1:0]		M_rdPriority3;		// From aport1 of aport.v
   wire			M_rdRearb0;		// From ipic_rd of ipic_rd.v
   wire			M_rdRearb1;		// From ipic_rd of ipic_rd.v
   wire			M_rdRearb2;		// From ipic_rd of ipic_rd.v
   wire			M_rdRearb3;		// From ipic_rd of ipic_rd.v
   wire			M_rdReq0;		// From aport0 of aport.v
   wire			M_rdReq1;		// From aport0 of aport.v
   wire			M_rdReq2;		// From aport1 of aport.v
   wire [3:0]		M_rdReq2dbg;		// From ipic_rd of ipic_rd.v
   wire			M_rdReq3;		// From aport1 of aport.v
   wire [2:0]		M_rdType0;		// From aport0 of aport.v
   wire [2:0]		M_rdType1;		// From aport0 of aport.v
   wire [2:0]		M_rdType2;		// From aport1 of aport.v
   wire [2:0]		M_rdType3;		// From aport1 of aport.v
   wire			M_wrAbort0;		// From aport0 of aport.v
   wire			M_wrAbort1;		// From aport0 of aport.v
   wire			M_wrAbort2;		// From aport1 of aport.v
   wire			M_wrAbort3;		// From aport1 of aport.v
   wire			M_wrAccept0;		// From ipic_wr of ipic_wr.v
   wire			M_wrAccept1;		// From ipic_wr of ipic_wr.v
   wire			M_wrAccept2;		// From ipic_wr of ipic_wr.v
   wire			M_wrAccept3;		// From ipic_wr of ipic_wr.v
   wire			M_wrAck0;		// From ipic_wr of ipic_wr.v
   wire			M_wrAck1;		// From ipic_wr of ipic_wr.v
   wire			M_wrAck2;		// From ipic_wr of ipic_wr.v
   wire			M_wrAck3;		// From ipic_wr of ipic_wr.v
   wire [31:0]		M_wrAddr0;		// From aport0 of aport.v
   wire [31:0]		M_wrAddr1;		// From aport0 of aport.v
   wire [31:0]		M_wrAddr2;		// From aport1 of aport.v
   wire [31:0]		M_wrAddr3;		// From aport1 of aport.v
   wire [7:0]		M_wrBE0;		// From aport0 of aport.v
   wire [7:0]		M_wrBE1;		// From aport0 of aport.v
   wire [7:0]		M_wrBE2;		// From aport1 of aport.v
   wire [7:0]		M_wrBE3;		// From aport1 of aport.v
   wire [127:0]		M_wrBus;		// From ipic_wr of ipic_wr.v
   wire			M_wrComp0;		// From ipic_wr of ipic_wr.v
   wire			M_wrComp1;		// From ipic_wr of ipic_wr.v
   wire			M_wrComp2;		// From ipic_wr of ipic_wr.v
   wire			M_wrComp3;		// From ipic_wr of ipic_wr.v
   wire			M_wrCompress0;		// From aport0 of aport.v
   wire			M_wrCompress1;		// From aport0 of aport.v
   wire			M_wrCompress2;		// From aport1 of aport.v
   wire			M_wrCompress3;		// From aport1 of aport.v
   wire [63:0]		M_wrData0;		// From aport0 of aport.v
   wire [63:0]		M_wrData1;		// From aport0 of aport.v
   wire [63:0]		M_wrData2;		// From aport1 of aport.v
   wire [63:0]		M_wrData3;		// From aport1 of aport.v
   wire			M_wrError0;		// From ipic_wr of ipic_wr.v
   wire			M_wrError1;		// From ipic_wr of ipic_wr.v
   wire			M_wrError2;		// From ipic_wr of ipic_wr.v
   wire			M_wrError3;		// From ipic_wr of ipic_wr.v
   wire [3:0]		M_wrGnt2dbg;		// From ipic_wr of ipic_wr.v
   wire			M_wrGuarded0;		// From aport0 of aport.v
   wire			M_wrGuarded1;		// From aport0 of aport.v
   wire			M_wrGuarded2;		// From aport1 of aport.v
   wire			M_wrGuarded3;		// From aport1 of aport.v
   wire			M_wrLockErr0;		// From aport0 of aport.v
   wire			M_wrLockErr1;		// From aport0 of aport.v
   wire			M_wrLockErr2;		// From aport1 of aport.v
   wire			M_wrLockErr3;		// From aport1 of aport.v
   wire [C_NUM_WIDTH-1:0] M_wrNum0;		// From aport0 of aport.v
   wire [C_NUM_WIDTH-1:0] M_wrNum1;		// From aport0 of aport.v
   wire [C_NUM_WIDTH-1:0] M_wrNum2;		// From aport1 of aport.v
   wire [C_NUM_WIDTH-1:0] M_wrNum3;		// From aport1 of aport.v
   wire			M_wrOrdered0;		// From aport0 of aport.v
   wire			M_wrOrdered1;		// From aport0 of aport.v
   wire			M_wrOrdered2;		// From aport1 of aport.v
   wire			M_wrOrdered3;		// From aport1 of aport.v
   wire [1:0]		M_wrPriority0;		// From aport0 of aport.v
   wire [1:0]		M_wrPriority1;		// From aport0 of aport.v
   wire [1:0]		M_wrPriority2;		// From aport1 of aport.v
   wire [1:0]		M_wrPriority3;		// From aport1 of aport.v
   wire			M_wrRdy0;		// From ipic_wr of ipic_wr.v
   wire			M_wrRdy1;		// From ipic_wr of ipic_wr.v
   wire			M_wrRdy2;		// From ipic_wr of ipic_wr.v
   wire			M_wrRdy3;		// From ipic_wr of ipic_wr.v
   wire			M_wrRearb0;		// From ipic_wr of ipic_wr.v
   wire			M_wrRearb1;		// From ipic_wr of ipic_wr.v
   wire			M_wrRearb2;		// From ipic_wr of ipic_wr.v
   wire			M_wrRearb3;		// From ipic_wr of ipic_wr.v
   wire			M_wrReq0;		// From aport0 of aport.v
   wire			M_wrReq1;		// From aport0 of aport.v
   wire			M_wrReq2;		// From aport1 of aport.v
   wire [3:0]		M_wrReq2dbg;		// From ipic_wr of ipic_wr.v
   wire			M_wrReq3;		// From aport1 of aport.v
   wire [2:0]		M_wrType0;		// From aport0 of aport.v
   wire [2:0]		M_wrType1;		// From aport0 of aport.v
   wire [2:0]		M_wrType2;		// From aport1 of aport.v
   wire [2:0]		M_wrType3;		// From aport1 of aport.v
   wire [31:0]		Sl_dcrDbus_port0;	// From aport0 of aport.v
   wire [31:0]		Sl_dcrDbus_port1;	// From aport1 of aport.v
   wire			ghc2port_ae;		// From dcr of dcr.v
   wire [31:0]		ghc2port_cap;		// From dcr of dcr.v
   wire			ghc2port_ie;		// From dcr of dcr.v
   wire [31:0]		port2ghc_PxISIE0;	// From aport0 of aport.v
   wire [31:0]		port2ghc_PxISIE1;	// From aport1 of aport.v
   wire [15:0]		port2ghc_intr_req0;	// From aport0 of aport.v
   wire [15:0]		port2ghc_intr_req1;	// From aport1 of aport.v
   wire [15:0]		port2ghc_ips_set0;	// From aport0 of aport.v
   wire [15:0]		port2ghc_ips_set1;	// From aport1 of aport.v
   wire			sys_clk0;		// From dcr of dcr.v
   wire			sys_clk1;		// From dcr of dcr.v
   wire			sys_rst;		// From dcr of dcr.v
   // End of automatics

   /* aport AUTO_TEMPLATE "\([0-9]+\)" 
    (
    .C_\(.*\)(C_\1[]),
    .M_Lock(),
    .M_Error(),
    .M_Reset(M_Reset),
    .M_Clk(M_Clk),
    .M_Reset(M_Reset),
    .DCR_\(.*\)(DCR_\1[]),
    .ghc2port_\(.*\)(ghc2port_\1[]),    
    .sys_rst(sys_rst),
    .Sl_dcrAck(Sl_dcrAck),
    
    .M_\(.*\)0(M_\10[]),
    .M_\(.*\)1(M_\11[]),

    .M_\(.*\)dbg(M_\1dbg[]),
    .M_rdBus(M_rdBus),
    .M_wrBus(M_wrBus),
    
    .\(.*\)(\1@[]),
    );*/
generate if (C_PORT[0])
begin:aport0     
   aport #(
	   .C_PORT(C_PORT0),
	   /*AUTOINSTPARAM*/
	   // Parameters
	   .C_NUM_WIDTH			(C_NUM_WIDTH),		 // Templated
	   .C_PM			(C_PM),			 // Templated
	   .C_BIG_ENDIAN		(C_BIG_ENDIAN),		 // Templated
	   .C_DEBUG_TX_FIFO		(C_DEBUG_TX_FIFO),	 // Templated
	   .C_DEBUG_RX_FIFO		(C_DEBUG_RX_FIFO),	 // Templated
	   .C_VERSION			(C_VERSION),		 // Templated
	   .C_CHIPSCOPE			(C_CHIPSCOPE),		 // Templated
	   .C_LINKFSM_DEBUG		(C_LINKFSM_DEBUG))	 // Templated
   aport0 (/*AUTOINST*/
	   // Outputs
	   .phyreset			(phyreset0),		 // Templated
	   .M_Lock			(),			 // Templated
	   .gtx_tune			(gtx_tune0[31:0]),	 // Templated
	   .M_rdAbort0			(M_rdAbort0),		 // Templated
	   .M_rdAbort1			(M_rdAbort1),		 // Templated
	   .M_rdAddr0			(M_rdAddr0[31:0]),	 // Templated
	   .M_rdAddr1			(M_rdAddr1[31:0]),	 // Templated
	   .M_rdBE0			(M_rdBE0[7:0]),		 // Templated
	   .M_rdBE1			(M_rdBE1[7:0]),		 // Templated
	   .M_rdCompress0		(M_rdCompress0),	 // Templated
	   .M_rdCompress1		(M_rdCompress1),	 // Templated
	   .M_rdGuarded0		(M_rdGuarded0),		 // Templated
	   .M_rdGuarded1		(M_rdGuarded1),		 // Templated
	   .M_rdLockErr0		(M_rdLockErr0),		 // Templated
	   .M_rdLockErr1		(M_rdLockErr1),		 // Templated
	   .M_rdNum0			(M_rdNum0[C_NUM_WIDTH-1:0]), // Templated
	   .M_rdNum1			(M_rdNum1[C_NUM_WIDTH-1:0]), // Templated
	   .M_rdPriority0		(M_rdPriority0[1:0]),	 // Templated
	   .M_rdPriority1		(M_rdPriority1[1:0]),	 // Templated
	   .M_rdReq0			(M_rdReq0),		 // Templated
	   .M_rdReq1			(M_rdReq1),		 // Templated
	   .M_rdType0			(M_rdType0[2:0]),	 // Templated
	   .M_rdType1			(M_rdType1[2:0]),	 // Templated
	   .M_wrAbort0			(M_wrAbort0),		 // Templated
	   .M_wrAbort1			(M_wrAbort1),		 // Templated
	   .M_wrAddr0			(M_wrAddr0[31:0]),	 // Templated
	   .M_wrAddr1			(M_wrAddr1[31:0]),	 // Templated
	   .M_wrBE0			(M_wrBE0[7:0]),		 // Templated
	   .M_wrBE1			(M_wrBE1[7:0]),		 // Templated
	   .M_wrCompress0		(M_wrCompress0),	 // Templated
	   .M_wrCompress1		(M_wrCompress1),	 // Templated
	   .M_wrData0			(M_wrData0[63:0]),	 // Templated
	   .M_wrData1			(M_wrData1[63:0]),	 // Templated
	   .M_wrGuarded0		(M_wrGuarded0),		 // Templated
	   .M_wrGuarded1		(M_wrGuarded1),		 // Templated
	   .M_wrLockErr0		(M_wrLockErr0),		 // Templated
	   .M_wrLockErr1		(M_wrLockErr1),		 // Templated
	   .M_wrNum0			(M_wrNum0[C_NUM_WIDTH-1:0]), // Templated
	   .M_wrNum1			(M_wrNum1[C_NUM_WIDTH-1:0]), // Templated
	   .M_wrOrdered0		(M_wrOrdered0),		 // Templated
	   .M_wrOrdered1		(M_wrOrdered1),		 // Templated
	   .M_wrPriority0		(M_wrPriority0[1:0]),	 // Templated
	   .M_wrPriority1		(M_wrPriority1[1:0]),	 // Templated
	   .M_wrReq0			(M_wrReq0),		 // Templated
	   .M_wrReq1			(M_wrReq1),		 // Templated
	   .M_wrType0			(M_wrType0[2:0]),	 // Templated
	   .M_wrType1			(M_wrType1[2:0]),	 // Templated
	   .Sl_dcrDbus_port		(Sl_dcrDbus_port0[31:0]), // Templated
	   .StartComm			(StartComm0),		 // Templated
	   .port2ghc_PxISIE		(port2ghc_PxISIE0[31:0]), // Templated
	   .port2ghc_intr_req		(port2ghc_intr_req0[15:0]), // Templated
	   .port2ghc_ips_set		(port2ghc_ips_set0[15:0]), // Templated
	   .sata_ledA			(sata_ledA0),		 // Templated
	   .sata_ledB			(sata_ledB0),		 // Templated
	   .txdata			(txdata0[31:0]),	 // Templated
	   .txdatak			(txdatak0),		 // Templated
	   // Inputs
	   .M_Error			(),			 // Templated
	   .M_Reset			(M_Reset),		 // Templated
	   .M_Clk			(M_Clk),		 // Templated
	   .DCR_Clk			(DCR_Clk),		 // Templated
	   .phyclk			(phyclk0),		 // Templated
	   .CommInit			(CommInit0),		 // Templated
	   .DCR_ABus			(DCR_ABus[0:9]),	 // Templated
	   .DCR_Read			(DCR_Read),		 // Templated
	   .DCR_Rst			(DCR_Rst),		 // Templated
	   .DCR_Sl_DBus			(DCR_Sl_DBus[0:31]),	 // Templated
	   .DCR_Write			(DCR_Write),		 // Templated
	   .M_rdAccept0			(M_rdAccept0),		 // Templated
	   .M_rdAccept1			(M_rdAccept1),		 // Templated
	   .M_rdAck0			(M_rdAck0),		 // Templated
	   .M_rdAck1			(M_rdAck1),		 // Templated
	   .M_rdBus			(M_rdBus),		 // Templated
	   .M_rdComp0			(M_rdComp0),		 // Templated
	   .M_rdComp1			(M_rdComp1),		 // Templated
	   .M_rdData0			(M_rdData0[63:0]),	 // Templated
	   .M_rdData1			(M_rdData1[63:0]),	 // Templated
	   .M_rdError0			(M_rdError0),		 // Templated
	   .M_rdError1			(M_rdError1),		 // Templated
	   .M_rdGnt2dbg			(M_rdGnt2dbg[3:0]),	 // Templated
	   .M_rdRearb0			(M_rdRearb0),		 // Templated
	   .M_rdRearb1			(M_rdRearb1),		 // Templated
	   .M_rdReq2dbg			(M_rdReq2dbg[3:0]),	 // Templated
	   .M_wrAccept0			(M_wrAccept0),		 // Templated
	   .M_wrAccept1			(M_wrAccept1),		 // Templated
	   .M_wrAck0			(M_wrAck0),		 // Templated
	   .M_wrAck1			(M_wrAck1),		 // Templated
	   .M_wrBus			(M_wrBus),		 // Templated
	   .M_wrComp0			(M_wrComp0),		 // Templated
	   .M_wrComp1			(M_wrComp1),		 // Templated
	   .M_wrError0			(M_wrError0),		 // Templated
	   .M_wrError1			(M_wrError1),		 // Templated
	   .M_wrGnt2dbg			(M_wrGnt2dbg[3:0]),	 // Templated
	   .M_wrRdy0			(M_wrRdy0),		 // Templated
	   .M_wrRdy1			(M_wrRdy1),		 // Templated
	   .M_wrRearb0			(M_wrRearb0),		 // Templated
	   .M_wrRearb1			(M_wrRearb1),		 // Templated
	   .M_wrReq2dbg			(M_wrReq2dbg[3:0]),	 // Templated
	   .Sl_dcrAck			(Sl_dcrAck),		 // Templated
	   .ghc2port_ae			(ghc2port_ae),		 // Templated
	   .ghc2port_cap		(ghc2port_cap[31:0]),	 // Templated
	   .ghc2port_ie			(ghc2port_ie),		 // Templated
	   .gtx_rxdata			(gtx_rxdata0[31:0]),	 // Templated
	   .gtx_rxdatak			(gtx_rxdatak0[3:0]),	 // Templated
	   .gtx_txdata			(gtx_txdata0[31:0]),	 // Templated
	   .gtx_txdatak			(gtx_txdatak0[3:0]),	 // Templated
	   .linkup			(linkup0),		 // Templated
	   .oob2dbg			(oob2dbg0[127:0]),	 // Templated
	   .plllock			(plllock0),		 // Templated
	   .rxdata			(rxdata0[31:0]),	 // Templated
	   .rxdatak			(rxdatak0),		 // Templated
	   .sys_clk			(sys_clk0),		 // Templated
	   .sys_rst			(sys_rst),		 // Templated
	   .txdatak_pop			(txdatak_pop0));		 // Templated
end // if (C_PORT > 0)
endgenerate

      /* aport AUTO_TEMPLATE "\([0-9]+\)" 
    (
    .C_\(.*\)(C_\1[]),
    .M_Lock(),
    .M_Error(),
    .M_Reset(M_Reset),
    .M_Clk(M_Clk),
    .M_Reset(M_Reset),
    .DCR_\(.*\)(DCR_\1[]),
    .ghc2port_\(.*\)(ghc2port_\1[]),    
    .sys_rst(sys_rst),
    .Sl_dcrAck(Sl_dcrAck),
    
    .M_\(.*\)0(M_\12[]),
    .M_\(.*\)1(M_\13[]),

    .M_\(.*\)dbg(M_\1dbg[]),    
    .M_rdBus(M_rdBus),
    .M_wrBus(M_wrBus),
              
    .\(.*\)(\1@[]),
    );*/

generate if (C_PORT[1])
begin:aport1     
   aport #(
	   .C_PORT(C_PORT1),
	   /*AUTOINSTPARAM*/
	   // Parameters
	   .C_NUM_WIDTH			(C_NUM_WIDTH),		 // Templated
	   .C_PM			(C_PM),			 // Templated
	   .C_BIG_ENDIAN		(C_BIG_ENDIAN),		 // Templated
	   .C_DEBUG_TX_FIFO		(C_DEBUG_TX_FIFO),	 // Templated
	   .C_DEBUG_RX_FIFO		(C_DEBUG_RX_FIFO),	 // Templated
	   .C_VERSION			(C_VERSION),		 // Templated
	   .C_CHIPSCOPE			(C_CHIPSCOPE),		 // Templated
	   .C_LINKFSM_DEBUG		(C_LINKFSM_DEBUG))	 // Templated
   aport1 (/*AUTOINST*/
	   // Outputs
	   .phyreset			(phyreset1),		 // Templated
	   .M_Lock			(),			 // Templated
	   .gtx_tune			(gtx_tune1[31:0]),	 // Templated
	   .M_rdAbort0			(M_rdAbort2),		 // Templated
	   .M_rdAbort1			(M_rdAbort3),		 // Templated
	   .M_rdAddr0			(M_rdAddr2[31:0]),	 // Templated
	   .M_rdAddr1			(M_rdAddr3[31:0]),	 // Templated
	   .M_rdBE0			(M_rdBE2[7:0]),		 // Templated
	   .M_rdBE1			(M_rdBE3[7:0]),		 // Templated
	   .M_rdCompress0		(M_rdCompress2),	 // Templated
	   .M_rdCompress1		(M_rdCompress3),	 // Templated
	   .M_rdGuarded0		(M_rdGuarded2),		 // Templated
	   .M_rdGuarded1		(M_rdGuarded3),		 // Templated
	   .M_rdLockErr0		(M_rdLockErr2),		 // Templated
	   .M_rdLockErr1		(M_rdLockErr3),		 // Templated
	   .M_rdNum0			(M_rdNum2[C_NUM_WIDTH-1:0]), // Templated
	   .M_rdNum1			(M_rdNum3[C_NUM_WIDTH-1:0]), // Templated
	   .M_rdPriority0		(M_rdPriority2[1:0]),	 // Templated
	   .M_rdPriority1		(M_rdPriority3[1:0]),	 // Templated
	   .M_rdReq0			(M_rdReq2),		 // Templated
	   .M_rdReq1			(M_rdReq3),		 // Templated
	   .M_rdType0			(M_rdType2[2:0]),	 // Templated
	   .M_rdType1			(M_rdType3[2:0]),	 // Templated
	   .M_wrAbort0			(M_wrAbort2),		 // Templated
	   .M_wrAbort1			(M_wrAbort3),		 // Templated
	   .M_wrAddr0			(M_wrAddr2[31:0]),	 // Templated
	   .M_wrAddr1			(M_wrAddr3[31:0]),	 // Templated
	   .M_wrBE0			(M_wrBE2[7:0]),		 // Templated
	   .M_wrBE1			(M_wrBE3[7:0]),		 // Templated
	   .M_wrCompress0		(M_wrCompress2),	 // Templated
	   .M_wrCompress1		(M_wrCompress3),	 // Templated
	   .M_wrData0			(M_wrData2[63:0]),	 // Templated
	   .M_wrData1			(M_wrData3[63:0]),	 // Templated
	   .M_wrGuarded0		(M_wrGuarded2),		 // Templated
	   .M_wrGuarded1		(M_wrGuarded3),		 // Templated
	   .M_wrLockErr0		(M_wrLockErr2),		 // Templated
	   .M_wrLockErr1		(M_wrLockErr3),		 // Templated
	   .M_wrNum0			(M_wrNum2[C_NUM_WIDTH-1:0]), // Templated
	   .M_wrNum1			(M_wrNum3[C_NUM_WIDTH-1:0]), // Templated
	   .M_wrOrdered0		(M_wrOrdered2),		 // Templated
	   .M_wrOrdered1		(M_wrOrdered3),		 // Templated
	   .M_wrPriority0		(M_wrPriority2[1:0]),	 // Templated
	   .M_wrPriority1		(M_wrPriority3[1:0]),	 // Templated
	   .M_wrReq0			(M_wrReq2),		 // Templated
	   .M_wrReq1			(M_wrReq3),		 // Templated
	   .M_wrType0			(M_wrType2[2:0]),	 // Templated
	   .M_wrType1			(M_wrType3[2:0]),	 // Templated
	   .Sl_dcrDbus_port		(Sl_dcrDbus_port1[31:0]), // Templated
	   .StartComm			(StartComm1),		 // Templated
	   .port2ghc_PxISIE		(port2ghc_PxISIE1[31:0]), // Templated
	   .port2ghc_intr_req		(port2ghc_intr_req1[15:0]), // Templated
	   .port2ghc_ips_set		(port2ghc_ips_set1[15:0]), // Templated
	   .sata_ledA			(sata_ledA1),		 // Templated
	   .sata_ledB			(sata_ledB1),		 // Templated
	   .txdata			(txdata1[31:0]),	 // Templated
	   .txdatak			(txdatak1),		 // Templated
	   // Inputs
	   .M_Error			(),			 // Templated
	   .M_Reset			(M_Reset),		 // Templated
	   .M_Clk			(M_Clk),		 // Templated
	   .DCR_Clk			(DCR_Clk),		 // Templated
	   .phyclk			(phyclk1),		 // Templated
	   .CommInit			(CommInit1),		 // Templated
	   .DCR_ABus			(DCR_ABus[0:9]),	 // Templated
	   .DCR_Read			(DCR_Read),		 // Templated
	   .DCR_Rst			(DCR_Rst),		 // Templated
	   .DCR_Sl_DBus			(DCR_Sl_DBus[0:31]),	 // Templated
	   .DCR_Write			(DCR_Write),		 // Templated
	   .M_rdAccept0			(M_rdAccept2),		 // Templated
	   .M_rdAccept1			(M_rdAccept3),		 // Templated
	   .M_rdAck0			(M_rdAck2),		 // Templated
	   .M_rdAck1			(M_rdAck3),		 // Templated
	   .M_rdBus			(M_rdBus),		 // Templated
	   .M_rdComp0			(M_rdComp2),		 // Templated
	   .M_rdComp1			(M_rdComp3),		 // Templated
	   .M_rdData0			(M_rdData2[63:0]),	 // Templated
	   .M_rdData1			(M_rdData3[63:0]),	 // Templated
	   .M_rdError0			(M_rdError2),		 // Templated
	   .M_rdError1			(M_rdError3),		 // Templated
	   .M_rdGnt2dbg			(M_rdGnt2dbg[3:0]),	 // Templated
	   .M_rdRearb0			(M_rdRearb2),		 // Templated
	   .M_rdRearb1			(M_rdRearb3),		 // Templated
	   .M_rdReq2dbg			(M_rdReq2dbg[3:0]),	 // Templated
	   .M_wrAccept0			(M_wrAccept2),		 // Templated
	   .M_wrAccept1			(M_wrAccept3),		 // Templated
	   .M_wrAck0			(M_wrAck2),		 // Templated
	   .M_wrAck1			(M_wrAck3),		 // Templated
	   .M_wrBus			(M_wrBus),		 // Templated
	   .M_wrComp0			(M_wrComp2),		 // Templated
	   .M_wrComp1			(M_wrComp3),		 // Templated
	   .M_wrError0			(M_wrError2),		 // Templated
	   .M_wrError1			(M_wrError3),		 // Templated
	   .M_wrGnt2dbg			(M_wrGnt2dbg[3:0]),	 // Templated
	   .M_wrRdy0			(M_wrRdy2),		 // Templated
	   .M_wrRdy1			(M_wrRdy3),		 // Templated
	   .M_wrRearb0			(M_wrRearb2),		 // Templated
	   .M_wrRearb1			(M_wrRearb3),		 // Templated
	   .M_wrReq2dbg			(M_wrReq2dbg[3:0]),	 // Templated
	   .Sl_dcrAck			(Sl_dcrAck),		 // Templated
	   .ghc2port_ae			(ghc2port_ae),		 // Templated
	   .ghc2port_cap		(ghc2port_cap[31:0]),	 // Templated
	   .ghc2port_ie			(ghc2port_ie),		 // Templated
	   .gtx_rxdata			(gtx_rxdata1[31:0]),	 // Templated
	   .gtx_rxdatak			(gtx_rxdatak1[3:0]),	 // Templated
	   .gtx_txdata			(gtx_txdata1[31:0]),	 // Templated
	   .gtx_txdatak			(gtx_txdatak1[3:0]),	 // Templated
	   .linkup			(linkup1),		 // Templated
	   .oob2dbg			(oob2dbg1[127:0]),	 // Templated
	   .plllock			(plllock1),		 // Templated
	   .rxdata			(rxdata1[31:0]),	 // Templated
	   .rxdatak			(rxdatak1),		 // Templated
	   .sys_clk			(sys_clk1),		 // Templated
	   .sys_rst			(sys_rst),		 // Templated
	   .txdatak_pop			(txdatak_pop1));		 // Templated
end // if (C_PORT > 1)
endgenerate
   
   dcr  #(/*AUTOINSTPARAM*/
	  // Parameters
	  .C_CHIPSCOPE			(C_CHIPSCOPE),
	  .C_BIG_ENDIAN			(C_BIG_ENDIAN),
	  .C_PORT0			(C_PORT0),
	  .C_PORT1			(C_PORT1),
	  .C_PORT2			(C_PORT2),
	  .C_PORT3			(C_PORT3),
	  .C_PORT			(C_PORT))
   dcr (/*AUTOINST*/
	// Outputs
	.Sl_dcrDBus			(Sl_dcrDBus[0:31]),
	.Sl_dcrAck			(Sl_dcrAck),
	.sys_clk0			(sys_clk0),
	.sys_clk1			(sys_clk1),
	.sys_rst			(sys_rst),
	.interrupt			(interrupt),
	.ghc2port_ae			(ghc2port_ae),
	.ghc2port_ie			(ghc2port_ie),
	.ghc2port_cap			(ghc2port_cap[31:0]),
	// Inputs
	.DCR_Clk			(DCR_Clk),
	.DCR_Rst			(DCR_Rst),
	.DCR_Read			(DCR_Read),
	.DCR_Write			(DCR_Write),
	.DCR_ABus			(DCR_ABus[0:9]),
	.DCR_Sl_DBus			(DCR_Sl_DBus[0:31]),
	.port2ghc_intr_req0		(port2ghc_intr_req0[15:0]),
	.port2ghc_ips_set0		(port2ghc_ips_set0[15:0]),
	.Sl_dcrDbus_port0		(Sl_dcrDbus_port0[31:0]),
	.port2ghc_PxISIE0		(port2ghc_PxISIE0[31:0]),
	.port2ghc_intr_req1		(port2ghc_intr_req1[15:0]),
	.port2ghc_ips_set1		(port2ghc_ips_set1[15:0]),
	.Sl_dcrDbus_port1		(Sl_dcrDbus_port1[31:0]),
	.port2ghc_PxISIE1		(port2ghc_PxISIE1[31:0]),
	.M_rdGnt2dbg			(M_rdGnt2dbg[3:0]),
	.M_rdReq2dbg			(M_rdReq2dbg[3:0]),
	.M_wrGnt2dbg			(M_wrGnt2dbg[3:0]),
	.M_wrReq2dbg			(M_wrReq2dbg[3:0]));
   
   ipic_rd #(/*AUTOINSTPARAM*/
	     // Parameters
	     .C_NUM_WIDTH		(C_NUM_WIDTH))
   ipic_rd (/*AUTOINST*/
	    // Outputs
	    .M_rdNum			(M_rdNum[C_NUM_WIDTH-1:0]),
	    .M_rdReq			(M_rdReq),
	    .M_rdAddr			(M_rdAddr[31:0]),
	    .M_rdBE			(M_rdBE[7:0]),
	    .M_rdPriority		(M_rdPriority[1:0]),
	    .M_rdType			(M_rdType[2:0]),
	    .M_rdCompress		(M_rdCompress),
	    .M_rdGuarded		(M_rdGuarded),
	    .M_rdLockErr		(M_rdLockErr),
	    .M_rdAbort			(M_rdAbort),
	    .M_rdReq2dbg		(M_rdReq2dbg[3:0]),
	    .M_rdGnt2dbg		(M_rdGnt2dbg[3:0]),
	    .M_rdAccept0		(M_rdAccept0),
	    .M_rdAccept1		(M_rdAccept1),
	    .M_rdAccept2		(M_rdAccept2),
	    .M_rdAccept3		(M_rdAccept3),
	    .M_rdAck0			(M_rdAck0),
	    .M_rdAck1			(M_rdAck1),
	    .M_rdAck2			(M_rdAck2),
	    .M_rdAck3			(M_rdAck3),
	    .M_rdComp0			(M_rdComp0),
	    .M_rdComp1			(M_rdComp1),
	    .M_rdComp2			(M_rdComp2),
	    .M_rdComp3			(M_rdComp3),
	    .M_rdData0			(M_rdData0[63:0]),
	    .M_rdData1			(M_rdData1[63:0]),
	    .M_rdData2			(M_rdData2[63:0]),
	    .M_rdData3			(M_rdData3[63:0]),
	    .M_rdError0			(M_rdError0),
	    .M_rdError1			(M_rdError1),
	    .M_rdError2			(M_rdError2),
	    .M_rdError3			(M_rdError3),
	    .M_rdRearb0			(M_rdRearb0),
	    .M_rdRearb1			(M_rdRearb1),
	    .M_rdRearb2			(M_rdRearb2),
	    .M_rdRearb3			(M_rdRearb3),
	    .M_rdBus			(M_rdBus[127:0]),
	    // Inputs
	    .M_rdAccept			(M_rdAccept),
	    .M_rdData			(M_rdData[63:0]),
	    .M_rdAck			(M_rdAck),
	    .M_rdComp			(M_rdComp),
	    .M_rdRearb			(M_rdRearb),
	    .M_rdError			(M_rdError),
	    .M_Clk			(M_Clk),
	    .M_Reset			(M_Reset),
	    .M_rdAbort0			(M_rdAbort0),
	    .M_rdAbort1			(M_rdAbort1),
	    .M_rdAbort2			(M_rdAbort2),
	    .M_rdAbort3			(M_rdAbort3),
	    .M_rdAddr0			(M_rdAddr0[31:0]),
	    .M_rdAddr1			(M_rdAddr1[31:0]),
	    .M_rdAddr2			(M_rdAddr2[31:0]),
	    .M_rdAddr3			(M_rdAddr3[31:0]),
	    .M_rdBE0			(M_rdBE0[7:0]),
	    .M_rdBE1			(M_rdBE1[7:0]),
	    .M_rdBE2			(M_rdBE2[7:0]),
	    .M_rdBE3			(M_rdBE3[7:0]),
	    .M_rdCompress0		(M_rdCompress0),
	    .M_rdCompress1		(M_rdCompress1),
	    .M_rdCompress2		(M_rdCompress2),
	    .M_rdCompress3		(M_rdCompress3),
	    .M_rdGuarded0		(M_rdGuarded0),
	    .M_rdGuarded1		(M_rdGuarded1),
	    .M_rdGuarded2		(M_rdGuarded2),
	    .M_rdGuarded3		(M_rdGuarded3),
	    .M_rdLockErr0		(M_rdLockErr0),
	    .M_rdLockErr1		(M_rdLockErr1),
	    .M_rdLockErr2		(M_rdLockErr2),
	    .M_rdLockErr3		(M_rdLockErr3),
	    .M_rdNum0			(M_rdNum0[C_NUM_WIDTH-1:0]),
	    .M_rdNum1			(M_rdNum1[C_NUM_WIDTH-1:0]),
	    .M_rdNum2			(M_rdNum2[C_NUM_WIDTH-1:0]),
	    .M_rdNum3			(M_rdNum3[C_NUM_WIDTH-1:0]),
	    .M_rdPriority0		(M_rdPriority0[1:0]),
	    .M_rdPriority1		(M_rdPriority1[1:0]),
	    .M_rdPriority2		(M_rdPriority2[1:0]),
	    .M_rdPriority3		(M_rdPriority3[1:0]),
	    .M_rdReq0			(M_rdReq0),
	    .M_rdReq1			(M_rdReq1),
	    .M_rdReq2			(M_rdReq2),
	    .M_rdReq3			(M_rdReq3),
	    .M_rdType0			(M_rdType0[2:0]),
	    .M_rdType1			(M_rdType1[2:0]),
	    .M_rdType2			(M_rdType2[2:0]),
	    .M_rdType3			(M_rdType3[2:0]));
   ipic_wr #(/*AUTOINSTPARAM*/
	     // Parameters
	     .C_NUM_WIDTH		(C_NUM_WIDTH))
   ipic_wr (/*AUTOINST*/
	    // Outputs
	    .M_wrNum			(M_wrNum[C_NUM_WIDTH-1:0]),
	    .M_wrReq			(M_wrReq),
	    .M_wrAddr			(M_wrAddr[31:0]),
	    .M_wrBE			(M_wrBE[7:0]),
	    .M_wrData			(M_wrData[63:0]),
	    .M_wrPriority		(M_wrPriority[1:0]),
	    .M_wrType			(M_wrType[2:0]),
	    .M_wrCompress		(M_wrCompress),
	    .M_wrGuarded		(M_wrGuarded),
	    .M_wrOrdered		(M_wrOrdered),
	    .M_wrLockErr		(M_wrLockErr),
	    .M_wrAbort			(M_wrAbort),
	    .M_wrReq2dbg		(M_wrReq2dbg[3:0]),
	    .M_wrGnt2dbg		(M_wrGnt2dbg[3:0]),
	    .M_wrAccept0		(M_wrAccept0),
	    .M_wrAccept1		(M_wrAccept1),
	    .M_wrAccept2		(M_wrAccept2),
	    .M_wrAccept3		(M_wrAccept3),
	    .M_wrAck0			(M_wrAck0),
	    .M_wrAck1			(M_wrAck1),
	    .M_wrAck2			(M_wrAck2),
	    .M_wrAck3			(M_wrAck3),
	    .M_wrComp0			(M_wrComp0),
	    .M_wrComp1			(M_wrComp1),
	    .M_wrComp2			(M_wrComp2),
	    .M_wrComp3			(M_wrComp3),
	    .M_wrError0			(M_wrError0),
	    .M_wrError1			(M_wrError1),
	    .M_wrError2			(M_wrError2),
	    .M_wrError3			(M_wrError3),
	    .M_wrRdy0			(M_wrRdy0),
	    .M_wrRdy1			(M_wrRdy1),
	    .M_wrRdy2			(M_wrRdy2),
	    .M_wrRdy3			(M_wrRdy3),
	    .M_wrRearb0			(M_wrRearb0),
	    .M_wrRearb1			(M_wrRearb1),
	    .M_wrRearb2			(M_wrRearb2),
	    .M_wrRearb3			(M_wrRearb3),
	    .M_wrBus			(M_wrBus[127:0]),
	    // Inputs
	    .M_wrAccept			(M_wrAccept),
	    .M_wrRdy			(M_wrRdy),
	    .M_wrAck			(M_wrAck),
	    .M_wrComp			(M_wrComp),
	    .M_wrRearb			(M_wrRearb),
	    .M_wrError			(M_wrError),
	    .M_Clk			(M_Clk),
	    .M_Reset			(M_Reset),
	    .M_wrAbort0			(M_wrAbort0),
	    .M_wrAbort1			(M_wrAbort1),
	    .M_wrAbort2			(M_wrAbort2),
	    .M_wrAbort3			(M_wrAbort3),
	    .M_wrAddr0			(M_wrAddr0[31:0]),
	    .M_wrAddr1			(M_wrAddr1[31:0]),
	    .M_wrAddr2			(M_wrAddr2[31:0]),
	    .M_wrAddr3			(M_wrAddr3[31:0]),
	    .M_wrBE0			(M_wrBE0[7:0]),
	    .M_wrBE1			(M_wrBE1[7:0]),
	    .M_wrBE2			(M_wrBE2[7:0]),
	    .M_wrBE3			(M_wrBE3[7:0]),
	    .M_wrCompress0		(M_wrCompress0),
	    .M_wrCompress1		(M_wrCompress1),
	    .M_wrCompress2		(M_wrCompress2),
	    .M_wrCompress3		(M_wrCompress3),
	    .M_wrData0			(M_wrData0[63:0]),
	    .M_wrData1			(M_wrData1[63:0]),
	    .M_wrData2			(M_wrData2[63:0]),
	    .M_wrData3			(M_wrData3[63:0]),
	    .M_wrGuarded0		(M_wrGuarded0),
	    .M_wrGuarded1		(M_wrGuarded1),
	    .M_wrGuarded2		(M_wrGuarded2),
	    .M_wrGuarded3		(M_wrGuarded3),
	    .M_wrLockErr0		(M_wrLockErr0),
	    .M_wrLockErr1		(M_wrLockErr1),
	    .M_wrLockErr2		(M_wrLockErr2),
	    .M_wrLockErr3		(M_wrLockErr3),
	    .M_wrNum0			(M_wrNum0[C_NUM_WIDTH-1:0]),
	    .M_wrNum1			(M_wrNum1[C_NUM_WIDTH-1:0]),
	    .M_wrNum2			(M_wrNum2[C_NUM_WIDTH-1:0]),
	    .M_wrNum3			(M_wrNum3[C_NUM_WIDTH-1:0]),
	    .M_wrOrdered0		(M_wrOrdered0),
	    .M_wrOrdered1		(M_wrOrdered1),
	    .M_wrOrdered2		(M_wrOrdered2),
	    .M_wrOrdered3		(M_wrOrdered3),
	    .M_wrPriority0		(M_wrPriority0[1:0]),
	    .M_wrPriority1		(M_wrPriority1[1:0]),
	    .M_wrPriority2		(M_wrPriority2[1:0]),
	    .M_wrPriority3		(M_wrPriority3[1:0]),
	    .M_wrReq0			(M_wrReq0),
	    .M_wrReq1			(M_wrReq1),
	    .M_wrReq2			(M_wrReq2),
	    .M_wrReq3			(M_wrReq3),
	    .M_wrType0			(M_wrType0[2:0]),
	    .M_wrType1			(M_wrType1[2:0]),
	    .M_wrType2			(M_wrType2[2:0]),
	    .M_wrType3			(M_wrType3[2:0]));
   
endmodule // ahci
// Local Variables:
// verilog-library-directories:("." "ll" "ipic")
// verilog-library-files:("")
// verilog-library-extensions:(".v" ".h")
// End:
// 
// ahci.v ends here
