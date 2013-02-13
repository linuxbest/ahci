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
module aport (/*AUTOARG*/
   // Outputs
   txdatak, txdata, sata_ledB, sata_ledA, port2ghc_ips_set,
   port2ghc_intr_req, port2ghc_PxISIE, StartComm, Sl_dcrDbus_port,
   M_wrType1, M_wrType0, M_wrReq1, M_wrReq0, M_wrPriority1,
   M_wrPriority0, M_wrOrdered1, M_wrOrdered0, M_wrNum1, M_wrNum0,
   M_wrLockErr1, M_wrLockErr0, M_wrGuarded1, M_wrGuarded0, M_wrData1,
   M_wrData0, M_wrCompress1, M_wrCompress0, M_wrBE1, M_wrBE0,
   M_wrAddr1, M_wrAddr0, M_wrAbort1, M_wrAbort0, M_rdType1, M_rdType0,
   M_rdReq1, M_rdReq0, M_rdPriority1, M_rdPriority0, M_rdNum1,
   M_rdNum0, M_rdLockErr1, M_rdLockErr0, M_rdGuarded1, M_rdGuarded0,
   M_rdCompress1, M_rdCompress0, M_rdBE1, M_rdBE0, M_rdAddr1,
   M_rdAddr0, M_rdAbort1, M_rdAbort0, phyreset, M_Lock, gtx_tune,
   // Inputs
   txdatak_pop, sys_rst, sys_clk, rxdatak, rxdata, plllock, oob2dbg,
   linkup, gtx_txdatak, gtx_txdata, gtx_rxdatak, gtx_rxdata,
   ghc2port_ie, ghc2port_cap, ghc2port_ae, Sl_dcrAck, M_wrReq2dbg,
   M_wrRearb1, M_wrRearb0, M_wrRdy1, M_wrRdy0, M_wrGnt2dbg,
   M_wrError1, M_wrError0, M_wrComp1, M_wrComp0, M_wrBus, M_wrAck1,
   M_wrAck0, M_wrAccept1, M_wrAccept0, M_rdReq2dbg, M_rdRearb1,
   M_rdRearb0, M_rdGnt2dbg, M_rdError1, M_rdError0, M_rdData1,
   M_rdData0, M_rdComp1, M_rdComp0, M_rdBus, M_rdAck1, M_rdAck0,
   M_rdAccept1, M_rdAccept0, DCR_Write, DCR_Sl_DBus, DCR_Rst,
   DCR_Read, DCR_ABus, CommInit, M_Error, M_Reset, M_Clk, DCR_Clk,
   phyclk
   );
   parameter C_NUM_WIDTH = 5;
   parameter C_PM = 16;
   parameter C_BIG_ENDIAN = 0;
   parameter C_DEBUG_TX_FIFO = 0;
   parameter C_DEBUG_RX_FIFO = 0;
   parameter C_PORT = 4'b0010;
   parameter C_VERSION = 32'hdead_dead;
   parameter C_CHIPSCOPE = 0;
   parameter C_LINKFSM_DEBUG = 0;
   
   output phyreset;
   output M_Lock;
   input  M_Error;
   input  M_Reset;

   (* PERIOD = "10000ps" *)
   input M_Clk;
   /* 100Mhz */
   (* PERIOD = "10000ps" *)
   input DCR_Clk;
   /* 100Mhz */
   (* PERIOD = "13333ps" *)
   input phyclk;
   /* 75Mhz  */

   output [31:0] gtx_tune;
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		CommInit;		// To port of port.v
   input [0:9]		DCR_ABus;		// To dcr of aport_dcr.v
   input		DCR_Read;		// To dcr of aport_dcr.v
   input		DCR_Rst;		// To dcr of aport_dcr.v
   input [0:31]		DCR_Sl_DBus;		// To dcr of aport_dcr.v
   input		DCR_Write;		// To dcr of aport_dcr.v
   input		M_rdAccept0;		// To osm_npi of osm_npi.v
   input		M_rdAccept1;		// To ctba of ctba.v
   input		M_rdAck0;		// To osm_npi of osm_npi.v
   input		M_rdAck1;		// To ctba of ctba.v
   input [127:0]	M_rdBus;		// To dcr of aport_dcr.v
   input		M_rdComp0;		// To osm_npi of osm_npi.v
   input		M_rdComp1;		// To ctba of ctba.v
   input [63:0]		M_rdData0;		// To osm_npi of osm_npi.v
   input [63:0]		M_rdData1;		// To ctba of ctba.v
   input		M_rdError0;		// To osm_npi of osm_npi.v
   input		M_rdError1;		// To ctba of ctba.v
   input [3:0]		M_rdGnt2dbg;		// To dcr of aport_dcr.v
   input		M_rdRearb0;		// To osm_npi of osm_npi.v
   input		M_rdRearb1;		// To ctba of ctba.v
   input [3:0]		M_rdReq2dbg;		// To dcr of aport_dcr.v
   input		M_wrAccept0;		// To rxdma of rxdma.v
   input		M_wrAccept1;		// To ctba of ctba.v
   input		M_wrAck0;		// To rxdma of rxdma.v
   input		M_wrAck1;		// To ctba of ctba.v
   input [127:0]	M_wrBus;		// To dcr of aport_dcr.v
   input		M_wrComp0;		// To rxdma of rxdma.v
   input		M_wrComp1;		// To ctba of ctba.v
   input		M_wrError0;		// To rxdma of rxdma.v
   input		M_wrError1;		// To ctba of ctba.v
   input [3:0]		M_wrGnt2dbg;		// To dcr of aport_dcr.v
   input		M_wrRdy0;		// To rxdma of rxdma.v
   input		M_wrRdy1;		// To ctba of ctba.v
   input		M_wrRearb0;		// To rxdma of rxdma.v
   input		M_wrRearb1;		// To ctba of ctba.v
   input [3:0]		M_wrReq2dbg;		// To dcr of aport_dcr.v
   input		Sl_dcrAck;		// To dcr of aport_dcr.v
   input		ghc2port_ae;		// To port of port.v
   input [31:0]		ghc2port_cap;		// To port of port.v
   input		ghc2port_ie;		// To port of port.v
   input [31:0]		gtx_rxdata;		// To sata_link of sata_link.v
   input [3:0]		gtx_rxdatak;		// To sata_link of sata_link.v
   input [31:0]		gtx_txdata;		// To sata_link of sata_link.v
   input [3:0]		gtx_txdatak;		// To sata_link of sata_link.v
   input		linkup;			// To port of port.v, ...
   input [127:0]	oob2dbg;		// To dcr of aport_dcr.v
   input		plllock;		// To sata_link of sata_link.v
   input [31:0]		rxdata;			// To sata_link of sata_link.v
   input		rxdatak;		// To sata_link of sata_link.v
   input		sys_clk;		// To port of port.v, ...
   input		sys_rst;		// To port of port.v, ...
   input		txdatak_pop;		// To sata_link of sata_link.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		M_rdAbort0;		// From osm_npi of osm_npi.v
   output		M_rdAbort1;		// From ctba of ctba.v
   output [31:0]	M_rdAddr0;		// From osm_npi of osm_npi.v
   output [31:0]	M_rdAddr1;		// From ctba of ctba.v
   output [7:0]		M_rdBE0;		// From osm_npi of osm_npi.v
   output [7:0]		M_rdBE1;		// From ctba of ctba.v
   output		M_rdCompress0;		// From osm_npi of osm_npi.v
   output		M_rdCompress1;		// From ctba of ctba.v
   output		M_rdGuarded0;		// From osm_npi of osm_npi.v
   output		M_rdGuarded1;		// From ctba of ctba.v
   output		M_rdLockErr0;		// From osm_npi of osm_npi.v
   output		M_rdLockErr1;		// From ctba of ctba.v
   output [C_NUM_WIDTH-1:0] M_rdNum0;		// From osm_npi of osm_npi.v
   output [C_NUM_WIDTH-1:0] M_rdNum1;		// From ctba of ctba.v
   output [1:0]		M_rdPriority0;		// From osm_npi of osm_npi.v
   output [1:0]		M_rdPriority1;		// From ctba of ctba.v
   output		M_rdReq0;		// From osm_npi of osm_npi.v
   output		M_rdReq1;		// From ctba of ctba.v
   output [2:0]		M_rdType0;		// From osm_npi of osm_npi.v
   output [2:0]		M_rdType1;		// From ctba of ctba.v
   output		M_wrAbort0;		// From rxdma of rxdma.v
   output		M_wrAbort1;		// From ctba of ctba.v
   output [31:0]	M_wrAddr0;		// From rxdma of rxdma.v
   output [31:0]	M_wrAddr1;		// From ctba of ctba.v
   output [7:0]		M_wrBE0;		// From rxdma of rxdma.v
   output [7:0]		M_wrBE1;		// From ctba of ctba.v
   output		M_wrCompress0;		// From rxdma of rxdma.v
   output		M_wrCompress1;		// From ctba of ctba.v
   output [63:0]	M_wrData0;		// From rxdma of rxdma.v
   output [63:0]	M_wrData1;		// From ctba of ctba.v
   output		M_wrGuarded0;		// From rxdma of rxdma.v
   output		M_wrGuarded1;		// From ctba of ctba.v
   output		M_wrLockErr0;		// From rxdma of rxdma.v
   output		M_wrLockErr1;		// From ctba of ctba.v
   output [C_NUM_WIDTH-1:0] M_wrNum0;		// From rxdma of rxdma.v
   output [C_NUM_WIDTH-1:0] M_wrNum1;		// From ctba of ctba.v
   output		M_wrOrdered0;		// From rxdma of rxdma.v
   output		M_wrOrdered1;		// From ctba of ctba.v
   output [1:0]		M_wrPriority0;		// From rxdma of rxdma.v
   output [1:0]		M_wrPriority1;		// From ctba of ctba.v
   output		M_wrReq0;		// From rxdma of rxdma.v
   output		M_wrReq1;		// From ctba of ctba.v
   output [2:0]		M_wrType0;		// From rxdma of rxdma.v
   output [2:0]		M_wrType1;		// From ctba of ctba.v
   output [31:0]	Sl_dcrDbus_port;	// From dcr of aport_dcr.v
   output		StartComm;		// From port of port.v
   output [31:0]	port2ghc_PxISIE;	// From dcr of aport_dcr.v
   output [15:0]	port2ghc_intr_req;	// From port of port.v
   output [15:0]	port2ghc_ips_set;	// From port of port.v
   output		sata_ledA;		// From port of port.v
   output		sata_ledB;		// From port of port.v
   output [31:0]	txdata;			// From sata_link of sata_link.v
   output		txdatak;		// From sata_link of sata_link.v
   // End of automatics
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [31:0]		PxCI;			// From dcr of aport_dcr.v
   wire [31:0]		PxCLB;			// From dcr of aport_dcr.v
   wire [31:0]		PxCLBU;			// From dcr of aport_dcr.v
   wire [31:0]		PxCMD;			// From dcr of aport_dcr.v
   wire [31:0]		PxFB;			// From dcr of aport_dcr.v
   wire [31:0]		PxFBS;			// From dcr of aport_dcr.v
   wire [31:0]		PxFBU;			// From dcr of aport_dcr.v
   wire [31:0]		PxIE;			// From dcr of aport_dcr.v
   wire [31:0]		PxIS;			// From dcr of aport_dcr.v
   wire [31:0]		PxSACT;			// From dcr of aport_dcr.v
   wire [31:0]		PxSCTL;			// From dcr of aport_dcr.v
   wire [31:0]		PxSERR;			// From dcr of aport_dcr.v
   wire [31:0]		PxSIG;			// From dcr of aport_dcr.v
   wire [31:0]		PxSNTF;			// From dcr of aport_dcr.v
   wire [31:0]		PxSSTS;			// From dcr of aport_dcr.v
   wire [31:0]		PxTFD;			// From dcr of aport_dcr.v
   wire [31:0]		PxVS;			// From dcr of aport_dcr.v
   wire			al2ctba_req;		// From dma_al of dma_al.v
   wire [127:0]		al2dbg;			// From dma_al of dma_al.v
   wire			al2dh_ack;		// From dma_al of dma_al.v
   wire [31:0]		al2dh_addr;		// From dma_al of dma_al.v
   wire			al2dh_err;		// From dma_al of dma_al.v
   wire			al2dh_last;		// From dma_al of dma_al.v
   wire [13:0]		al2dh_len;		// From dma_al of dma_al.v
   wire [31:0]		al2port_PRD_off;	// From dma_al of dma_al.v
   wire			cache2ctba_A;		// From ctba_ram of ctba_ram.v
   wire			cache2ctba_B;		// From ctba_ram of ctba_ram.v
   wire			cache2ctba_C;		// From ctba_ram of ctba_ram.v
   wire [4:0]		cache2ctba_CFL;		// From ctba_ram of ctba_ram.v
   wire [31:0]		cache2ctba_CTBA;	// From ctba_ram of ctba_ram.v
   wire			cache2ctba_P;		// From ctba_ram of ctba_ram.v
   wire [3:0]		cache2ctba_PMP;		// From ctba_ram of ctba_ram.v
   wire [31:0]		cache2ctba_PRDBC;	// From ctba_ram of ctba_ram.v
   wire [15:0]		cache2ctba_PRDTL;	// From ctba_ram of ctba_ram.v
   wire [15:0]		cache2ctba_PRD_cnt;	// From ctba_ram of ctba_ram.v
   wire [31:0]		cache2ctba_PRD_off;	// From ctba_ram of ctba_ram.v
   wire			cache2ctba_R;		// From ctba_ram of ctba_ram.v
   wire			cache2ctba_W;		// From ctba_ram of ctba_ram.v
   wire [3:0]		cache2ctba_strip;	// From ctba_ram of ctba_ram.v
   wire			cache2ctba_strip_enable;// From ctba_ram of ctba_ram.v
   wire [3:0]		cache2ctba_strip_index;	// From ctba_ram of ctba_ram.v
   wire [3:0]		cache2ctba_strip_total;	// From ctba_ram of ctba_ram.v
   wire			cache2port_ack;		// From ctba_ram of ctba_ram.v
   wire [8:0]		cs2dcr_cnt;		// From sata_link of sata_link.v
   wire [35:0]		cs2dcr_prim;		// From sata_link of sata_link.v
   wire			ctba2al_ack;		// From ctba of ctba.v
   wire [31:0]		ctba2al_addr;		// From ctba of ctba.v
   wire			ctba2al_end;		// From ctba of ctba.v
   wire			ctba2al_last;		// From ctba of ctba.v
   wire [21:0]		ctba2al_len;		// From ctba of ctba.v
   wire [3:0]		ctba2cache_strip;	// From dma_al of dma_al.v
   wire [31:0]		ctba2dbg;		// From ctba of ctba.v
   wire			ctba2port_FetchCFIS_ack;// From ctba of ctba.v
   wire			ctba2port_FetchCmd_ack;	// From ctba of ctba.v
   wire [15:0]		ctba2port_PRD_cnt;	// From ctba of ctba.v
   wire			ctba2port_UpdateBC_ack;	// From ctba of ctba.v
   wire			ctba2port_ack;		// From ctba of ctba.v
   wire [63:0]		ctba2port_do;		// From ctba of ctba.v
   wire [1:0]		ctba2port_idx;		// From ctba of ctba.v
   wire			ctba2txll_ack;		// From ctba of ctba.v
   wire [63:0]		ctba2txll_do;		// From ctba of ctba.v
   wire [31:0]		ctrl_data;		// From ctrl_ll of ctrl_ll.v
   wire			ctrl_dst_lock;		// From port of port.v
   wire			ctrl_dst_rdy1;		// From port of port.v
   wire			ctrl_dst_rdy2;		// From txdma of txdma.v
   wire			ctrl_dst_rdy3;		// From rxdma of rxdma.v
   wire			ctrl_src_rdy_n;		// From ctrl_ll of ctrl_ll.v
   wire			dcr2cs_clk;		// From dcr of aport_dcr.v
   wire			dcr2cs_pop;		// From dcr of aport_dcr.v
   wire			dcr2port_PxCI_ack;	// From dcr of aport_dcr.v
   wire			dcr2port_PxCMD_FRE;	// From dcr of aport_dcr.v
   wire			dcr2port_PxCMD_ICC_we;	// From dcr of aport_dcr.v
   wire			dcr2port_PxCMD_PMA;	// From dcr of aport_dcr.v
   wire			dcr2port_PxCMD_POD;	// From dcr of aport_dcr.v
   wire			dcr2port_PxCMD_ST;	// From dcr of aport_dcr.v
   wire			dcr2port_PxCMD_SUD;	// From dcr of aport_dcr.v
   wire			dcr2port_PxFBS_EN;	// From dcr of aport_dcr.v
   wire			dcr2port_PxIE_PCE;	// From dcr of aport_dcr.v
   wire			dcr2port_PxIS_ack;	// From dcr of aport_dcr.v
   wire			dcr2port_PxSACT_ack;	// From dcr of aport_dcr.v
   wire [3:0]		dcr2port_PxSCTL_DET;	// From dcr of aport_dcr.v
   wire			dcr2port_PxSERR_DIAG_X;	// From dcr of aport_dcr.v
   wire [3:0]		dcr2port_PxSSTS_DET;	// From dcr of aport_dcr.v
   wire [3:0]		dcr2port_PxSSTS_IPM;	// From dcr of aport_dcr.v
   wire			dcr2port_PxTFD_STS_BSY;	// From dcr of aport_dcr.v
   wire			dcr2port_PxTFD_SYS_DRQ;	// From dcr of aport_dcr.v
   wire			dcr2port_PxTFD_SYS_ERR;	// From dcr of aport_dcr.v
   wire			dh2al_ack;		// From dma_al of dma_al.v
   wire			dh2tx_ack;		// From dma_dh of dma_dh.v
   wire			dh2tx_err;		// From dma_dh of dma_dh.v
   wire [31:0]		err2dbg;		// From port of port.v
   wire			host_rst;		// From dcr of aport_dcr.v
   wire [31:0]		ififo2dcr_PxSIG;	// From rxll of rxll.v
   wire [31:0]		ififo2port_DS_Count;	// From rxll of rxll.v
   wire [5:0]		ififo2port_DS_TAG;	// From rxll of rxll.v
   wire [31:0]		ififo2port_DS_offset;	// From rxll of rxll.v
   wire [7:0]		ififo2port_Estatus;	// From rxll of rxll.v
   wire [31:0]		ififo2port_SDB_SActive;	// From rxll of rxll.v
   wire [15:0]		ififo2port_Transfer_Count;// From rxll of rxll.v
   wire			ififo2port_empty;	// From rxll of rxll.v
   wire [31:0]		ififo2port_fis_hdr;	// From rxll of rxll.v
   wire			ififo2port_fo_ack;	// From rxdma of rxdma.v
   wire [35:0]		ififo2rxdma_ndr_rd_do;	// From rxll of rxll.v
   wire [127:0]		link_fsm2dbg;		// From sata_link of sata_link.v
   wire			npi_ack;		// From osm_npi of osm_npi.v
   wire [35:0]		npi_addr;		// From dma_dh of dma_dh.v
   wire [63:0]		npi_data;		// From osm_npi of osm_npi.v
   wire			npi_last;		// From osm_npi of osm_npi.v
   wire [13:0]		npi_len;		// From dma_dh of dma_dh.v
   wire			npi_rdy;		// From dma_dh of dma_dh.v
   wire			npi_rem;		// From osm_npi of osm_npi.v
   wire			npi_req;		// From dma_dh of dma_dh.v
   wire			npi_valid;		// From osm_npi of osm_npi.v
   wire [31:0]		osm_npi2dbg;		// From osm_npi of osm_npi.v
   wire [31:0]		pBsyDrq;		// From port of port.v
   wire [31:0]		pDmaXferCnt_ex;		// From port of port.v
   wire [3:0]		pPMP;			// From port of port.v
   wire [3:0]		pPmpCur;		// From port of port.v
   wire			port2cache_PRDBC_incr;	// From port of port.v
   wire			port2cache_req;		// From port of port.v
   wire [4:0]		port2cache_slot;	// From port of port.v
   wire			port2cache_we;		// From port of port.v
   wire [31:0]		port2ctba_FetchCFIS_addr;// From port of port.v
   wire [4:0]		port2ctba_FetchCFIS_len;// From port of port.v
   wire			port2ctba_FetchCFIS_req;// From port of port.v
   wire [31:0]		port2ctba_FetchCmd_addr;// From port of port.v
   wire			port2ctba_FetchCmd_req;	// From port of port.v
   wire [4:0]		port2ctba_FetchCmd_slot;// From port of port.v
   wire [31:0]		port2ctba_FetchPRDBC;	// From port of port.v
   wire [15:0]		port2ctba_FetchPRDTL;	// From port of port.v
   wire [31:0]		port2ctba_FetchPRD_addr;// From port of port.v
   wire [15:0]		port2ctba_FetchPRD_cnt;	// From port of port.v
   wire [31:0]		port2ctba_FetchPRD_off;	// From port of port.v
   wire [31:0]		port2ctba_UpdateBC_addr;// From port of port.v
   wire			port2ctba_UpdateBC_req;	// From port of port.v
   wire [127:0]		port2dbg;		// From port of port.v
   wire [4:0]		port2dcr_PxCI;		// From port of port.v
   wire			port2dcr_PxCI_clear;	// From port of port.v
   wire [4:0]		port2dcr_PxCMD_CCS;	// From port of port.v
   wire			port2dcr_PxCMD_CCS_we;	// From port of port.v
   wire [3:0]		port2dcr_PxFBS_DWE;	// From port of port.v
   wire			port2dcr_PxFBS_DWE_clear;// From port of port.v
   wire			port2dcr_PxFBS_DWE_set;	// From port of port.v
   wire [31:0]		port2dcr_PxIS;		// From port of port.v
   wire			port2dcr_PxIS_set;	// From port of port.v
   wire			port2dcr_PxSACT_clear;	// From port of port.v
   wire [31:0]		port2dcr_PxSERR;	// From port of port.v
   wire			port2dcr_PxSERR_DIAG_set;// From port of port.v
   wire			port2dcr_PxSERR_ERR_set;// From port of port.v
   wire			port2dcr_PxSIG_we;	// From port of port.v
   wire [7:0]		port2dcr_PxTFD_ERR;	// From port of port.v
   wire			port2dcr_PxTFD_ERR_we;	// From port of port.v
   wire [7:0]		port2dcr_PxTFD_STS;	// From port of port.v
   wire			port2dcr_PxTFD_STS_we;	// From port of port.v
   wire			port2ififo_fo_req;	// From port of port.v
   wire			port2rxdma_req;		// From port of port.v
   wire [31:0]		port2txdma_len;		// From port of port.v
   wire			port2txdma_req;		// From port of port.v
   wire			port2txll_Push_req;	// From port of port.v
   wire [7:0]		port_state;		// From port of port.v
   wire [13:0]		rx2al_len;		// From rxdma of rxdma.v
   wire			rx2al_req;		// From rxdma of rxdma.v
   wire [127:0]		rx_cs2dbg;		// From sata_link of sata_link.v
   wire [31:0]		rxdma2dbg;		// From rxdma of rxdma.v
   wire			rxdma2ififo_ndr_rd_en;	// From rxdma of rxdma.v
   wire			rxdma2port_ack;		// From rxdma of rxdma.v
   wire			rxdma2port_idle;	// From rxdma of rxdma.v
   wire [31:0]		rxdma2port_sts;		// From rxdma of rxdma.v
   wire			rxdma2port_xfer;	// From rxdma of rxdma.v
   wire			rxdma2rxll_rd_en;	// From rxdma of rxdma.v
   wire [31:0]		rxll2dbg;		// From rxll of rxll.v
   wire [31:0]		rxll2port_fis_hdr;	// From rxll of rxll.v
   wire			rxll2port_req;		// From rxll of rxll.v
   wire [15:0]		rxll2port_rxcount;	// From rxll of rxll.v
   wire [35:0]		rxll2rxdma_rd_do;	// From rxll of rxll.v
   wire			rxll2rxdma_rd_empty;	// From rxll of rxll.v
   wire			rxll2rxdma_rd_eof_rdy;	// From rxll of rxll.v
   wire [31:0]		trn_cd;			// From sata_link of sata_link.v
   wire			trn_cdst_dsc_n;		// From ctrl_ll of ctrl_ll.v
   wire			trn_cdst_lock_n;	// From ctrl_ll of ctrl_ll.v
   wire			trn_cdst_rdy_n;		// From ctrl_ll of ctrl_ll.v
   wire			trn_ceof_n;		// From sata_link of sata_link.v
   wire			trn_csof_n;		// From sata_link of sata_link.v
   wire			trn_csrc_dsc_n;		// From sata_link of sata_link.v
   wire			trn_csrc_rdy_n;		// From sata_link of sata_link.v
   wire [31:0]		trn_rd;			// From sata_link of sata_link.v
   wire			trn_rdst_dsc_n;		// From rxll of rxll.v
   wire			trn_rdst_rdy_n;		// From rxll of rxll.v
   wire			trn_reof_n;		// From sata_link of sata_link.v
   wire			trn_rsof_n;		// From sata_link of sata_link.v
   wire			trn_rsrc_dsc_n;		// From sata_link of sata_link.v
   wire			trn_rsrc_rdy_n;		// From sata_link of sata_link.v
   wire [31:0]		trn_td;			// From txll of txll.v
   wire			trn_tdst_dsc_n;		// From sata_link of sata_link.v
   wire			trn_tdst_rdy_n;		// From sata_link of sata_link.v
   wire			trn_teof_n;		// From txll of txll.v
   wire			trn_tsof_n;		// From txll of txll.v
   wire			trn_tsrc_dsc_n;		// From txll of txll.v
   wire			trn_tsrc_rdy_n;		// From txll of txll.v
   wire [13:0]		tx2al_len;		// From dma_dh of dma_dh.v
   wire			tx2al_req;		// From dma_dh of dma_dh.v
   wire [13:0]		tx2dh_len;		// From txdma of txdma.v
   wire			tx2dh_req;		// From txdma of txdma.v
   wire [127:0]		tx_cs2dbg;		// From sata_link of sata_link.v
   wire [31:0]		txdma2dbg;		// From txdma of txdma.v
   wire			txdma2port_ack;		// From txdma of txdma.v
   wire			txdma2port_idle;	// From txdma of txdma.v
   wire [31:0]		txdma2port_sts;		// From txdma of txdma.v
   wire [71:0]		txdma2txll_do;		// From dma_dh of dma_dh.v
   wire			txdma2txll_push;	// From dma_dh of dma_dh.v
   wire [31:0]		txdmadh2dbg;		// From dma_dh of dma_dh.v
   wire [31:0]		txll2dbg;		// From txll of txll.v
   wire			txll2port_Push_ack;	// From txll of txll.v
   wire			txll2port_xfer;		// From txll of txll.v
   wire			txll2txdma_rdy;		// From txll of txll.v
   // End of automatics

   port #(/*AUTOINSTPARAM*/
	  // Parameters
	  .C_PM				(C_PM))
   port(/*AUTOINST*/
	// Outputs
	.ctrl_dst_rdy1			(ctrl_dst_rdy1),
	.ctrl_dst_lock			(ctrl_dst_lock),
	.port2ctba_FetchCmd_req		(port2ctba_FetchCmd_req),
	.port2ctba_FetchCmd_addr	(port2ctba_FetchCmd_addr[31:0]),
	.port2ctba_FetchCmd_slot	(port2ctba_FetchCmd_slot[4:0]),
	.port2ctba_FetchCFIS_req	(port2ctba_FetchCFIS_req),
	.port2ctba_FetchCFIS_addr	(port2ctba_FetchCFIS_addr[31:0]),
	.port2ctba_FetchCFIS_len	(port2ctba_FetchCFIS_len[4:0]),
	.port2ctba_UpdateBC_req		(port2ctba_UpdateBC_req),
	.port2ctba_UpdateBC_addr	(port2ctba_UpdateBC_addr[31:0]),
	.port2ctba_FetchPRD_addr	(port2ctba_FetchPRD_addr[31:0]),
	.port2ctba_FetchPRD_cnt		(port2ctba_FetchPRD_cnt[15:0]),
	.port2ctba_FetchPRD_off		(port2ctba_FetchPRD_off[31:0]),
	.port2ctba_FetchPRDTL		(port2ctba_FetchPRDTL[15:0]),
	.port2ctba_FetchPRDBC		(port2ctba_FetchPRDBC[31:0]),
	.port2rxdma_req			(port2rxdma_req),
	.pPMP				(pPMP[3:0]),
	.pPmpCur			(pPmpCur[3:0]),
	.port2txll_Push_req		(port2txll_Push_req),
	.port2txdma_req			(port2txdma_req),
	.port2txdma_len			(port2txdma_len[31:0]),
	.port2dcr_PxTFD_STS_we		(port2dcr_PxTFD_STS_we),
	.port2dcr_PxTFD_STS		(port2dcr_PxTFD_STS[7:0]),
	.port2dcr_PxTFD_ERR_we		(port2dcr_PxTFD_ERR_we),
	.port2dcr_PxTFD_ERR		(port2dcr_PxTFD_ERR[7:0]),
	.port2dcr_PxCMD_CCS		(port2dcr_PxCMD_CCS[4:0]),
	.port2dcr_PxCMD_CCS_we		(port2dcr_PxCMD_CCS_we),
	.port2dcr_PxCI_clear		(port2dcr_PxCI_clear),
	.port2dcr_PxCI			(port2dcr_PxCI[4:0]),
	.port2dcr_PxSACT_clear		(port2dcr_PxSACT_clear),
	.port2dcr_PxIS			(port2dcr_PxIS[31:0]),
	.port2dcr_PxIS_set		(port2dcr_PxIS_set),
	.port2dcr_PxFBS_DWE		(port2dcr_PxFBS_DWE[3:0]),
	.port2dcr_PxFBS_DWE_set		(port2dcr_PxFBS_DWE_set),
	.port2dcr_PxFBS_DWE_clear	(port2dcr_PxFBS_DWE_clear),
	.port2dcr_PxSERR		(port2dcr_PxSERR[31:0]),
	.port2dcr_PxSERR_DIAG_set	(port2dcr_PxSERR_DIAG_set),
	.port2dcr_PxSERR_ERR_set	(port2dcr_PxSERR_ERR_set),
	.port2cache_req			(port2cache_req),
	.port2cache_slot		(port2cache_slot[4:0]),
	.port2cache_we			(port2cache_we),
	.port2cache_PRDBC_incr		(port2cache_PRDBC_incr),
	.port2ififo_fo_req		(port2ififo_fo_req),
	.StartComm			(StartComm),
	.port_state			(port_state[7:0]),
	.sata_ledA			(sata_ledA),
	.sata_ledB			(sata_ledB),
	.port2dcr_PxSIG_we		(port2dcr_PxSIG_we),
	.port2ghc_intr_req		(port2ghc_intr_req[15:0]),
	.port2ghc_ips_set		(port2ghc_ips_set[15:0]),
	.port2dbg			(port2dbg[127:0]),
	.err2dbg			(err2dbg[31:0]),
	.pDmaXferCnt_ex			(pDmaXferCnt_ex[31:0]),
	.pBsyDrq			(pBsyDrq[31:0]),
	// Inputs
	.sys_clk			(sys_clk),
	.sys_rst			(sys_rst),
	.linkup				(linkup),
	.ghc2port_ae			(ghc2port_ae),
	.ghc2port_ie			(ghc2port_ie),
	.ghc2port_cap			(ghc2port_cap[31:0]),
	.dcr2port_PxSCTL_DET		(dcr2port_PxSCTL_DET[03:0]),
	.dcr2port_PxSSTS_DET		(dcr2port_PxSSTS_DET[03:0]),
	.dcr2port_PxCMD_POD		(dcr2port_PxCMD_POD),
	.dcr2port_PxCMD_SUD		(dcr2port_PxCMD_SUD),
	.dcr2port_PxCMD_FRE		(dcr2port_PxCMD_FRE),
	.dcr2port_PxCMD_PMA		(dcr2port_PxCMD_PMA),
	.dcr2port_PxCMD_ST		(dcr2port_PxCMD_ST),
	.dcr2port_PxCMD_ICC_we		(dcr2port_PxCMD_ICC_we),
	.dcr2port_PxFBS_EN		(dcr2port_PxFBS_EN),
	.dcr2port_PxTFD_STS_BSY		(dcr2port_PxTFD_STS_BSY),
	.dcr2port_PxTFD_SYS_DRQ		(dcr2port_PxTFD_SYS_DRQ),
	.dcr2port_PxTFD_SYS_ERR		(dcr2port_PxTFD_SYS_ERR),
	.dcr2port_PxSERR_DIAG_X		(dcr2port_PxSERR_DIAG_X),
	.dcr2port_PxSSTS_IPM		(dcr2port_PxSSTS_IPM[3:0]),
	.dcr2port_PxIE_PCE		(dcr2port_PxIE_PCE),
	.rxll2port_req			(rxll2port_req),
	.rxll2port_rxcount		(rxll2port_rxcount[15:0]),
	.rxll2port_fis_hdr		(rxll2port_fis_hdr[15:0]),
	.ctrl_data			(ctrl_data[31:0]),
	.ctrl_src_rdy_n			(ctrl_src_rdy_n),
	.ctba2port_FetchCmd_ack		(ctba2port_FetchCmd_ack),
	.ctba2port_do			(ctba2port_do[63:0]),
	.ctba2port_ack			(ctba2port_ack),
	.ctba2port_FetchCFIS_ack	(ctba2port_FetchCFIS_ack),
	.ctba2port_UpdateBC_ack		(ctba2port_UpdateBC_ack),
	.ctba2port_PRD_cnt		(ctba2port_PRD_cnt[15:0]),
	.rxdma2port_ack			(rxdma2port_ack),
	.rxdma2port_sts			(rxdma2port_sts[31:0]),
	.rxdma2port_xfer		(rxdma2port_xfer),
	.txll2port_xfer			(txll2port_xfer),
	.txll2port_Push_ack		(txll2port_Push_ack),
	.txdma2port_ack			(txdma2port_ack),
	.txdma2port_sts			(txdma2port_sts[31:0]),
	.rxdma2port_idle		(rxdma2port_idle),
	.txdma2port_idle		(txdma2port_idle),
	.dcr2port_PxCI_ack		(dcr2port_PxCI_ack),
	.dcr2port_PxSACT_ack		(dcr2port_PxSACT_ack),
	.dcr2port_PxIS_ack		(dcr2port_PxIS_ack),
	.cache2port_ack			(cache2port_ack),
	.ififo2port_empty		(ififo2port_empty),
	.ififo2port_fo_ack		(ififo2port_fo_ack),
	.ififo2port_fis_hdr		(ififo2port_fis_hdr[31:0]),
	.ififo2port_Estatus		(ififo2port_Estatus[7:0]),
	.ififo2port_Transfer_Count	(ififo2port_Transfer_Count[15:0]),
	.ififo2port_DS_TAG		(ififo2port_DS_TAG[5:0]),
	.ififo2port_DS_offset		(ififo2port_DS_offset[31:0]),
	.ififo2port_DS_Count		(ififo2port_DS_Count[31:0]),
	.ififo2port_SDB_SActive		(ififo2port_SDB_SActive[31:0]),
	.trn_tsrc_rdy_n			(trn_tsrc_rdy_n),
	.trn_tdst_dsc_n			(trn_tdst_dsc_n),
	.CommInit			(CommInit),
	.cache2ctba_CFL			(cache2ctba_CFL[4:0]),
	.cache2ctba_A			(cache2ctba_A),
	.cache2ctba_W			(cache2ctba_W),
	.cache2ctba_P			(cache2ctba_P),
	.cache2ctba_R			(cache2ctba_R),
	.cache2ctba_B			(cache2ctba_B),
	.cache2ctba_C			(cache2ctba_C),
	.cache2ctba_PMP			(cache2ctba_PMP[3:0]),
	.cache2ctba_PRDTL		(cache2ctba_PRDTL[15:0]),
	.cache2ctba_PRDBC		(cache2ctba_PRDBC[31:0]),
	.cache2ctba_CTBA		(cache2ctba_CTBA[31:0]),
	.cache2ctba_PRD_off		(cache2ctba_PRD_off[31:0]),
	.cache2ctba_PRD_cnt		(cache2ctba_PRD_cnt[15:0]),
	.PxCLB				(PxCLB[31:0]),
	.PxCLBU				(PxCLBU[31:0]),
	.PxFB				(PxFB[31:0]),
	.PxFBU				(PxFBU[31:0]),
	.PxIS				(PxIS[31:0]),
	.PxIE				(PxIE[31:0]),
	.PxCMD				(PxCMD[31:0]),
	.PxTFD				(PxTFD[31:0]),
	.PxSIG				(PxSIG[31:0]),
	.PxSSTS				(PxSSTS[31:0]),
	.PxSCTL				(PxSCTL[31:0]),
	.PxSERR				(PxSERR[31:0]),
	.PxSACT				(PxSACT[31:0]),
	.PxCI				(PxCI[31:0]),
	.PxSNTF				(PxSNTF[31:0]),
	.PxFBS				(PxFBS[31:0]),
	.PxVS				(PxVS[31:0]));
   aport_dcr  #(/*AUTOINSTPARAM*/
		// Parameters
		.C_CHIPSCOPE		(C_CHIPSCOPE),
		.C_BIG_ENDIAN		(C_BIG_ENDIAN),
		.C_PORT			(C_PORT),
		.C_VERSION		(C_VERSION),
		.C_LINKFSM_DEBUG	(C_LINKFSM_DEBUG))
   dcr (/*AUTOINST*/
	// Outputs
	.Sl_dcrDbus_port		(Sl_dcrDbus_port[31:0]),
	.phyreset			(phyreset),
	.host_rst			(host_rst),
	.port2ghc_PxISIE		(port2ghc_PxISIE[31:0]),
	.gtx_tune			(gtx_tune[31:0]),
	.dcr2port_PxSCTL_DET		(dcr2port_PxSCTL_DET[03:0]),
	.dcr2port_PxSSTS_DET		(dcr2port_PxSSTS_DET[03:0]),
	.dcr2port_PxCMD_POD		(dcr2port_PxCMD_POD),
	.dcr2port_PxCMD_SUD		(dcr2port_PxCMD_SUD),
	.dcr2port_PxCMD_FRE		(dcr2port_PxCMD_FRE),
	.dcr2port_PxCMD_PMA		(dcr2port_PxCMD_PMA),
	.dcr2port_PxCMD_ST		(dcr2port_PxCMD_ST),
	.dcr2port_PxCMD_ICC_we		(dcr2port_PxCMD_ICC_we),
	.dcr2port_PxFBS_EN		(dcr2port_PxFBS_EN),
	.dcr2port_PxTFD_STS_BSY		(dcr2port_PxTFD_STS_BSY),
	.dcr2port_PxTFD_SYS_DRQ		(dcr2port_PxTFD_SYS_DRQ),
	.dcr2port_PxTFD_SYS_ERR		(dcr2port_PxTFD_SYS_ERR),
	.dcr2port_PxSERR_DIAG_X		(dcr2port_PxSERR_DIAG_X),
	.dcr2port_PxSSTS_IPM		(dcr2port_PxSSTS_IPM[3:0]),
	.dcr2port_PxIE_PCE		(dcr2port_PxIE_PCE),
	.dcr2port_PxCI_ack		(dcr2port_PxCI_ack),
	.dcr2port_PxSACT_ack		(dcr2port_PxSACT_ack),
	.dcr2port_PxIS_ack		(dcr2port_PxIS_ack),
	.PxCLB				(PxCLB[31:0]),
	.PxCLBU				(PxCLBU[31:0]),
	.PxFB				(PxFB[31:0]),
	.PxFBU				(PxFBU[31:0]),
	.PxIS				(PxIS[31:0]),
	.PxIE				(PxIE[31:0]),
	.PxCMD				(PxCMD[31:0]),
	.PxTFD				(PxTFD[31:0]),
	.PxSIG				(PxSIG[31:0]),
	.PxSSTS				(PxSSTS[31:0]),
	.PxSCTL				(PxSCTL[31:0]),
	.PxSERR				(PxSERR[31:0]),
	.PxSACT				(PxSACT[31:0]),
	.PxCI				(PxCI[31:0]),
	.PxSNTF				(PxSNTF[31:0]),
	.PxFBS				(PxFBS[31:0]),
	.PxVS				(PxVS[31:0]),
	.dcr2cs_pop			(dcr2cs_pop),
	.dcr2cs_clk			(dcr2cs_clk),
	// Inputs
	.DCR_Clk			(DCR_Clk),
	.DCR_Rst			(DCR_Rst),
	.DCR_Read			(DCR_Read),
	.DCR_Write			(DCR_Write),
	.DCR_ABus			(DCR_ABus[0:9]),
	.DCR_Sl_DBus			(DCR_Sl_DBus[0:31]),
	.Sl_dcrAck			(Sl_dcrAck),
	.sys_clk			(sys_clk),
	.sys_rst			(sys_rst),
	.linkup				(linkup),
	.port2dcr_PxTFD_STS		(port2dcr_PxTFD_STS[7:0]),
	.port2dcr_PxTFD_STS_we		(port2dcr_PxTFD_STS_we),
	.port2dcr_PxTFD_ERR_we		(port2dcr_PxTFD_ERR_we),
	.port2dcr_PxTFD_ERR		(port2dcr_PxTFD_ERR[7:0]),
	.port2dcr_PxCMD_CCS		(port2dcr_PxCMD_CCS[4:0]),
	.port2dcr_PxCMD_CCS_we		(port2dcr_PxCMD_CCS_we),
	.port2dcr_PxCI_clear		(port2dcr_PxCI_clear),
	.port2dcr_PxCI			(port2dcr_PxCI[4:0]),
	.port2dcr_PxSACT_clear		(port2dcr_PxSACT_clear),
	.port2dcr_PxIS			(port2dcr_PxIS[31:0]),
	.port2dcr_PxIS_set		(port2dcr_PxIS_set),
	.port2dcr_PxFBS_DWE		(port2dcr_PxFBS_DWE[3:0]),
	.port2dcr_PxFBS_DWE_set		(port2dcr_PxFBS_DWE_set),
	.port2dcr_PxFBS_DWE_clear	(port2dcr_PxFBS_DWE_clear),
	.port2dcr_PxSERR		(port2dcr_PxSERR[31:0]),
	.port2dcr_PxSERR_DIAG_set	(port2dcr_PxSERR_DIAG_set),
	.port2dcr_PxSERR_ERR_set	(port2dcr_PxSERR_ERR_set),
	.port2dcr_PxSIG_we		(port2dcr_PxSIG_we),
	.ififo2dcr_PxSIG		(ififo2dcr_PxSIG[31:0]),
	.ififo2port_SDB_SActive		(ififo2port_SDB_SActive[31:0]),
	.phyclk				(phyclk),
	.link_fsm2dbg			(link_fsm2dbg[127:0]),
	.rx_cs2dbg			(rx_cs2dbg[127:0]),
	.tx_cs2dbg			(tx_cs2dbg[127:0]),
	.port2dbg			(port2dbg[127:0]),
	.err2dbg			(err2dbg[31:0]),
	.al2dbg				(al2dbg[127:0]),
	.ctba2dbg			(ctba2dbg[31:0]),
	.rxdma2dbg			(rxdma2dbg[31:0]),
	.txdma2dbg			(txdma2dbg[31:0]),
	.txdmadh2dbg			(txdmadh2dbg[31:0]),
	.osm_npi2dbg			(osm_npi2dbg[31:0]),
	.M_rdGnt2dbg			(M_rdGnt2dbg[3:0]),
	.M_rdReq2dbg			(M_rdReq2dbg[3:0]),
	.M_wrGnt2dbg			(M_wrGnt2dbg[3:0]),
	.M_wrReq2dbg			(M_wrReq2dbg[3:0]),
	.M_rdBus			(M_rdBus[127:0]),
	.M_wrBus			(M_wrBus[127:0]),
	.txll2dbg			(txll2dbg[31:0]),
	.rxll2dbg			(rxll2dbg[31:0]),
	.cache2ctba_PRDBC		(cache2ctba_PRDBC[31:0]),
	.oob2dbg			(oob2dbg[127:0]),
	.pDmaXferCnt_ex			(pDmaXferCnt_ex[31:0]),
	.pBsyDrq			(pBsyDrq[31:0]),
	.cs2dcr_prim			(cs2dcr_prim[35:0]),
	.cs2dcr_cnt			(cs2dcr_cnt[8:0]));
   rxll
     rxll(/*AUTOINST*/
	  // Outputs
	  .rxll2port_rxcount		(rxll2port_rxcount[15:0]),
	  .ififo2port_empty		(ififo2port_empty),
	  .ififo2port_fis_hdr		(ififo2port_fis_hdr[31:0]),
	  .rxll2port_req		(rxll2port_req),
	  .ififo2dcr_PxSIG		(ififo2dcr_PxSIG[31:0]),
	  .ififo2port_DS_Count		(ififo2port_DS_Count[31:0]),
	  .ififo2port_DS_TAG		(ififo2port_DS_TAG[5:0]),
	  .ififo2port_DS_offset		(ififo2port_DS_offset[31:0]),
	  .ififo2port_Estatus		(ififo2port_Estatus[7:0]),
	  .ififo2port_SDB_SActive	(ififo2port_SDB_SActive[31:0]),
	  .ififo2port_Transfer_Count	(ififo2port_Transfer_Count[15:0]),
	  .ififo2rxdma_ndr_rd_do	(ififo2rxdma_ndr_rd_do[35:0]),
	  .rxll2dbg			(rxll2dbg[31:0]),
	  .rxll2port_fis_hdr		(rxll2port_fis_hdr[31:0]),
	  .rxll2rxdma_rd_do		(rxll2rxdma_rd_do[35:0]),
	  .rxll2rxdma_rd_empty		(rxll2rxdma_rd_empty),
	  .rxll2rxdma_rd_eof_rdy	(rxll2rxdma_rd_eof_rdy),
	  .trn_rdst_dsc_n		(trn_rdst_dsc_n),
	  .trn_rdst_rdy_n		(trn_rdst_rdy_n),
	  // Inputs
	  .sys_clk			(sys_clk),
	  .sys_rst			(sys_rst),
	  .phyreset			(phyreset),
	  .phyclk			(phyclk),
	  .rxdma2ififo_ndr_rd_en	(rxdma2ififo_ndr_rd_en),
	  .rxdma2rxll_rd_en		(rxdma2rxll_rd_en),
	  .trn_rd			(trn_rd[31:0]),
	  .trn_reof_n			(trn_reof_n),
	  .trn_rsof_n			(trn_rsof_n),
	  .trn_rsrc_dsc_n		(trn_rsrc_dsc_n),
	  .trn_rsrc_rdy_n		(trn_rsrc_rdy_n));
   txll
     txll(/*AUTOINST*/
	  // Outputs
	  .trn_td			(trn_td[31:0]),
	  .trn_teof_n			(trn_teof_n),
	  .trn_tsof_n			(trn_tsof_n),
	  .trn_tsrc_dsc_n		(trn_tsrc_dsc_n),
	  .trn_tsrc_rdy_n		(trn_tsrc_rdy_n),
	  .txll2dbg			(txll2dbg[31:0]),
	  .txll2port_Push_ack		(txll2port_Push_ack),
	  .txll2port_xfer		(txll2port_xfer),
	  .txll2txdma_rdy		(txll2txdma_rdy),
	  // Inputs
	  .sys_clk			(sys_clk),
	  .sys_rst			(sys_rst),
	  .phyclk			(phyclk),
	  .phyreset			(phyreset),
	  .ctba2port_FetchCFIS_ack	(ctba2port_FetchCFIS_ack),
	  .ctba2txll_ack		(ctba2txll_ack),
	  .ctba2txll_do			(ctba2txll_do[63:0]),
	  .pPMP				(pPMP[3:0]),
	  .pPmpCur			(pPmpCur[3:0]),
	  .port2ctba_FetchCFIS_len	(port2ctba_FetchCFIS_len[4:0]),
	  .port2ctba_FetchCFIS_req	(port2ctba_FetchCFIS_req),
	  .port2txdma_req		(port2txdma_req),
	  .port2txll_Push_req		(port2txll_Push_req),
	  .trn_tdst_dsc_n		(trn_tdst_dsc_n),
	  .trn_tdst_rdy_n		(trn_tdst_rdy_n),
	  .txdma2txll_do		(txdma2txll_do[71:0]),
	  .txdma2txll_push		(txdma2txll_push));
   ctrl_ll 
     ctrl_ll(/*AUTOINST*/
	     // Outputs
	     .trn_cdst_rdy_n		(trn_cdst_rdy_n),
	     .trn_cdst_dsc_n		(trn_cdst_dsc_n),
	     .trn_cdst_lock_n		(trn_cdst_lock_n),
	     .ctrl_data			(ctrl_data[31:0]),
	     .ctrl_src_rdy_n		(ctrl_src_rdy_n),
	     // Inputs
	     .phyclk			(phyclk),
	     .phyreset			(phyreset),
	     .sys_clk			(sys_clk),
	     .sys_rst			(sys_rst),
	     .trn_cd			(trn_cd[31:0]),
	     .trn_csof_n		(trn_csof_n),
	     .trn_ceof_n		(trn_ceof_n),
	     .trn_csrc_rdy_n		(trn_csrc_rdy_n),
	     .trn_csrc_dsc_n		(trn_csrc_dsc_n),
	     .ctrl_dst_rdy1		(ctrl_dst_rdy1),
	     .ctrl_dst_rdy2		(ctrl_dst_rdy2),
	     .ctrl_dst_rdy3		(ctrl_dst_rdy3),
	     .ctrl_dst_lock		(ctrl_dst_lock));
   /* osm_npi AUTO_TEMPLATE (
    .M_rd\(.*\)  (M_rd\10[]),
    .M_wr\(.*\)  (M_wr\10[]),
    );*/
   osm_npi #(/*AUTOINSTPARAM*/
	     // Parameters
	     .C_NUM_WIDTH		(C_NUM_WIDTH),
	     .C_DEBUG_TX_FIFO		(C_DEBUG_TX_FIFO))
     osm_npi (/*AUTOINST*/
	      // Outputs
	      .M_rdNum			(M_rdNum0[C_NUM_WIDTH-1:0]), // Templated
	      .M_rdReq			(M_rdReq0),		 // Templated
	      .M_rdAddr			(M_rdAddr0[31:0]),	 // Templated
	      .M_rdBE			(M_rdBE0[7:0]),		 // Templated
	      .M_rdPriority		(M_rdPriority0[1:0]),	 // Templated
	      .M_rdType			(M_rdType0[2:0]),	 // Templated
	      .M_rdCompress		(M_rdCompress0),	 // Templated
	      .M_rdGuarded		(M_rdGuarded0),		 // Templated
	      .M_rdLockErr		(M_rdLockErr0),		 // Templated
	      .M_rdAbort		(M_rdAbort0),		 // Templated
	      .npi_ack			(npi_ack),
	      .npi_data			(npi_data[63:0]),
	      .npi_rem			(npi_rem),
	      .npi_valid		(npi_valid),
	      .npi_last			(npi_last),
	      .osm_npi2dbg		(osm_npi2dbg[31:0]),
	      // Inputs
	      .sys_clk			(sys_clk),
	      .sys_rst			(sys_rst),
	      .M_rdAccept		(M_rdAccept0),		 // Templated
	      .M_rdData			(M_rdData0[63:0]),	 // Templated
	      .M_rdAck			(M_rdAck0),		 // Templated
	      .M_rdComp			(M_rdComp0),		 // Templated
	      .M_rdRearb		(M_rdRearb0),		 // Templated
	      .M_rdError		(M_rdError0),		 // Templated
	      .npi_addr			(npi_addr[35:0]),
	      .npi_len			(npi_len[13:0]),
	      .npi_req			(npi_req),
	      .npi_rdy			(npi_rdy));
   dma_dh #(/*AUTOINSTPARAM*/
	    // Parameters
	    .C_BIG_ENDIAN		(C_BIG_ENDIAN))
     dma_dh (/*AUTOINST*/
	     // Outputs
	     .dh2tx_ack			(dh2tx_ack),
	     .dh2tx_err			(dh2tx_err),
	     .tx2al_req			(tx2al_req),
	     .tx2al_len			(tx2al_len[13:0]),
	     .txdma2txll_do		(txdma2txll_do[71:0]),
	     .txdma2txll_push		(txdma2txll_push),
	     .npi_addr			(npi_addr[35:0]),
	     .npi_len			(npi_len[13:0]),
	     .npi_req			(npi_req),
	     .npi_rdy			(npi_rdy),
	     .txdmadh2dbg		(txdmadh2dbg[31:0]),
	     // Inputs
	     .sys_clk			(sys_clk),
	     .sys_rst			(sys_rst),
	     .tx2dh_req			(tx2dh_req),
	     .tx2dh_len			(tx2dh_len[13:0]),
	     .dh2al_ack			(dh2al_ack),
	     .al2dh_ack			(al2dh_ack),
	     .al2dh_err			(al2dh_err),
	     .al2dh_last		(al2dh_last),
	     .al2dh_addr		(al2dh_addr[31:0]),
	     .al2dh_len			(al2dh_len[13:0]),
	     .txll2txdma_rdy		(txll2txdma_rdy),
	     .npi_ack			(npi_ack),
	     .npi_rem			(npi_rem),
	     .pPMP			(pPMP[3:0]),
	     .pPmpCur			(pPmpCur[3:0]),
	     .npi_data			(npi_data[63:0]),
	     .npi_valid			(npi_valid),
	     .npi_last			(npi_last));
   
   txdma #(/*AUTOINSTPARAM*/
	   // Parameters
	   .C_NUM_WIDTH			(C_NUM_WIDTH),
	   .C_BIG_ENDIAN		(C_BIG_ENDIAN))
     txdma (/*AUTOINST*/
	    // Outputs
	    .txdma2port_ack		(txdma2port_ack),
	    .txdma2port_sts		(txdma2port_sts[31:0]),
	    .txdma2port_idle		(txdma2port_idle),
	    .tx2dh_req			(tx2dh_req),
	    .tx2dh_len			(tx2dh_len[13:0]),
	    .ctrl_dst_rdy2		(ctrl_dst_rdy2),
	    .txdma2dbg			(txdma2dbg[31:0]),
	    // Inputs
	    .sys_clk			(sys_clk),
	    .sys_rst			(sys_rst),
	    .port2txdma_req		(port2txdma_req),
	    .port2txdma_len		(port2txdma_len[31:0]),
	    .dh2tx_ack			(dh2tx_ack),
	    .dh2tx_err			(dh2tx_err),
	    .ctrl_src_rdy_n		(ctrl_src_rdy_n),
	    .ctrl_data			(ctrl_data[31:0]),
	    .txdma2txll_push		(txdma2txll_push));
   dma_al 
     dma_al (/*AUTOINST*/
	     // Outputs
	     .al2dh_ack			(al2dh_ack),
	     .al2dh_err			(al2dh_err),
	     .al2dh_len			(al2dh_len[13:0]),
	     .al2dh_addr		(al2dh_addr[31:0]),
	     .al2dh_last		(al2dh_last),
	     .al2port_PRD_off		(al2port_PRD_off[31:0]),
	     .al2ctba_req		(al2ctba_req),
	     .dh2al_ack			(dh2al_ack),
	     .ctba2cache_strip		(ctba2cache_strip[3:0]),
	     .al2dbg			(al2dbg[127:0]),
	     // Inputs
	     .sys_clk			(sys_clk),
	     .sys_rst			(sys_rst),
	     .rx2al_req			(rx2al_req),
	     .rx2al_len			(rx2al_len[13:0]),
	     .tx2al_req			(tx2al_req),
	     .tx2al_len			(tx2al_len[13:0]),
	     .port2ififo_fo_req		(port2ififo_fo_req),
	     .ififo2port_fo_ack		(ififo2port_fo_ack),
	     .port2rxdma_req		(port2rxdma_req),
	     .rxll2port_fis_hdr		(rxll2port_fis_hdr[15:0]),
	     .port2ctba_FetchPRD_off	(port2ctba_FetchPRD_off[21:0]),
	     .ctba2port_PRD_cnt		(ctba2port_PRD_cnt[15:0]),
	     .cache2ctba_CTBA		(cache2ctba_CTBA[31:0]),
	     .ctba2al_ack		(ctba2al_ack),
	     .ctba2al_len		(ctba2al_len[21:0]),
	     .ctba2al_addr		(ctba2al_addr[31:0]),
	     .ctba2al_end		(ctba2al_end),
	     .ctba2al_last		(ctba2al_last),
	     .rxdma2port_ack		(rxdma2port_ack),
	     .port2txdma_req		(port2txdma_req),
	     .txdma2port_ack		(txdma2port_ack),
	     .dcr2port_PxFBS_EN		(dcr2port_PxFBS_EN),
	     .PxCLB			(PxCLB[31:0]),
	     .PxCLBU			(PxCLBU[31:0]),
	     .PxFB			(PxFB[31:0]),
	     .PxFBU			(PxFBU[31:0]),
	     .cache2ctba_strip_total	(cache2ctba_strip_total[3:0]),
	     .cache2ctba_strip_index	(cache2ctba_strip_index[3:0]),
	     .cache2ctba_strip_enable	(cache2ctba_strip_enable),
	     .cache2ctba_strip		(cache2ctba_strip[3:0]));
   /* rxdma AUTO_TEMPLATE (
    .M_rd\(.*\)  (M_rd\10[]),
    .M_wr\(.*\)  (M_wr\10[]),
    );*/
   rxdma #(/*AUTOINSTPARAM*/
	   // Parameters
	   .C_NUM_WIDTH			(C_NUM_WIDTH),
	   .C_BIG_ENDIAN		(C_BIG_ENDIAN),
	   .C_DEBUG_RX_FIFO		(C_DEBUG_RX_FIFO))
     rxdma (/*AUTOINST*/
	    // Outputs
	    .rxdma2port_idle		(rxdma2port_idle),
	    .rxdma2dbg			(rxdma2dbg[31:0]),
	    .M_wrNum			(M_wrNum0[C_NUM_WIDTH-1:0]), // Templated
	    .M_wrReq			(M_wrReq0),		 // Templated
	    .M_wrAddr			(M_wrAddr0[31:0]),	 // Templated
	    .M_wrBE			(M_wrBE0[7:0]),		 // Templated
	    .M_wrData			(M_wrData0[63:0]),	 // Templated
	    .M_wrPriority		(M_wrPriority0[1:0]),	 // Templated
	    .M_wrType			(M_wrType0[2:0]),	 // Templated
	    .M_wrCompress		(M_wrCompress0),	 // Templated
	    .M_wrGuarded		(M_wrGuarded0),		 // Templated
	    .M_wrOrdered		(M_wrOrdered0),		 // Templated
	    .M_wrLockErr		(M_wrLockErr0),		 // Templated
	    .M_wrAbort			(M_wrAbort0),		 // Templated
	    .rxdma2ififo_ndr_rd_en	(rxdma2ififo_ndr_rd_en),
	    .rxdma2rxll_rd_en		(rxdma2rxll_rd_en),
	    .ififo2port_fo_ack		(ififo2port_fo_ack),
	    .rxdma2port_ack		(rxdma2port_ack),
	    .rxdma2port_sts		(rxdma2port_sts[31:0]),
	    .rxdma2port_xfer		(rxdma2port_xfer),
	    .rx2al_req			(rx2al_req),
	    .rx2al_len			(rx2al_len[13:0]),
	    .ctrl_dst_rdy3		(ctrl_dst_rdy3),
	    // Inputs
	    .sys_clk			(sys_clk),
	    .sys_rst			(sys_rst),
	    .M_wrAccept			(M_wrAccept0),		 // Templated
	    .M_wrRdy			(M_wrRdy0),		 // Templated
	    .M_wrAck			(M_wrAck0),		 // Templated
	    .M_wrComp			(M_wrComp0),		 // Templated
	    .M_wrRearb			(M_wrRearb0),		 // Templated
	    .M_wrError			(M_wrError0),		 // Templated
	    .ififo2rxdma_ndr_rd_do	(ififo2rxdma_ndr_rd_do[35:0]),
	    .ififo2port_empty		(ififo2port_empty),
	    .rxll2rxdma_rd_do		(rxll2rxdma_rd_do[35:0]),
	    .rxll2rxdma_rd_empty	(rxll2rxdma_rd_empty),
	    .rxll2rxdma_rd_eof_rdy	(rxll2rxdma_rd_eof_rdy),
	    .port2ififo_fo_req		(port2ififo_fo_req),
	    .port2rxdma_req		(port2rxdma_req),
	    .port2ctba_FetchPRDBC	(port2ctba_FetchPRDBC[31:0]),
	    .al2dh_ack			(al2dh_ack),
	    .al2dh_err			(al2dh_err),
	    .al2dh_addr			(al2dh_addr[31:0]),
	    .al2dh_len			(al2dh_len[13:0]));
   ctba_ram
     ctba_ram (/*AUTOINST*/
	       // Outputs
	       .cache2port_ack		(cache2port_ack),
	       .cache2ctba_CFL		(cache2ctba_CFL[4:0]),
	       .cache2ctba_A		(cache2ctba_A),
	       .cache2ctba_W		(cache2ctba_W),
	       .cache2ctba_P		(cache2ctba_P),
	       .cache2ctba_R		(cache2ctba_R),
	       .cache2ctba_B		(cache2ctba_B),
	       .cache2ctba_C		(cache2ctba_C),
	       .cache2ctba_PMP		(cache2ctba_PMP[3:0]),
	       .cache2ctba_PRDTL	(cache2ctba_PRDTL[15:0]),
	       .cache2ctba_strip_total	(cache2ctba_strip_total[3:0]),
	       .cache2ctba_strip_index	(cache2ctba_strip_index[3:0]),
	       .cache2ctba_strip_enable	(cache2ctba_strip_enable),
	       .cache2ctba_strip	(cache2ctba_strip[3:0]),
	       .cache2ctba_PRDBC	(cache2ctba_PRDBC[31:0]),
	       .cache2ctba_CTBA		(cache2ctba_CTBA[31:0]),
	       .cache2ctba_PRD_off	(cache2ctba_PRD_off[31:0]),
	       .cache2ctba_PRD_cnt	(cache2ctba_PRD_cnt[15:0]),
	       // Inputs
	       .sys_clk			(sys_clk),
	       .sys_rst			(sys_rst),
	       .ctba2port_do		(ctba2port_do[63:0]),
	       .ctba2port_idx		(ctba2port_idx[1:0]),
	       .ctba2port_ack		(ctba2port_ack),
	       .port2ctba_FetchCmd_req	(port2ctba_FetchCmd_req),
	       .port2ctba_FetchCmd_slot	(port2ctba_FetchCmd_slot[4:0]),
	       .port2cache_req		(port2cache_req),
	       .port2cache_slot		(port2cache_slot[4:0]),
	       .port2cache_we		(port2cache_we),
	       .ctba2cache_strip	(ctba2cache_strip[3:0]),
	       .port2cache_PRDBC_incr	(port2cache_PRDBC_incr),
	       .al2port_PRD_off		(al2port_PRD_off[31:0]),
	       .ctba2port_PRD_cnt	(ctba2port_PRD_cnt[15:0]));
   /* ctba AUTO_TEMPLATE (
    .M_rd\(.*\)  (M_rd\11[]),
    .M_wr\(.*\)  (M_wr\11[]),
    );*/
   ctba #(/*AUTOINSTPARAM*/
	  // Parameters
	  .C_NUM_WIDTH			(C_NUM_WIDTH),
	  .C_BIG_ENDIAN			(C_BIG_ENDIAN))
     ctba(/*AUTOINST*/
	  // Outputs
	  .ctba2port_do			(ctba2port_do[63:0]),
	  .ctba2port_idx		(ctba2port_idx[1:0]),
	  .ctba2port_ack		(ctba2port_ack),
	  .ctba2port_PRD_cnt		(ctba2port_PRD_cnt[15:0]),
	  .ctba2port_FetchCmd_ack	(ctba2port_FetchCmd_ack),
	  .ctba2port_FetchCFIS_ack	(ctba2port_FetchCFIS_ack),
	  .ctba2port_UpdateBC_ack	(ctba2port_UpdateBC_ack),
	  .ctba2txll_ack		(ctba2txll_ack),
	  .ctba2txll_do			(ctba2txll_do[63:0]),
	  .ctba2al_ack			(ctba2al_ack),
	  .ctba2al_len			(ctba2al_len[21:0]),
	  .ctba2al_addr			(ctba2al_addr[31:0]),
	  .ctba2al_end			(ctba2al_end),
	  .ctba2al_last			(ctba2al_last),
	  .M_wrNum			(M_wrNum1[C_NUM_WIDTH-1:0]), // Templated
	  .M_wrReq			(M_wrReq1),		 // Templated
	  .M_wrAddr			(M_wrAddr1[31:0]),	 // Templated
	  .M_wrBE			(M_wrBE1[7:0]),		 // Templated
	  .M_wrData			(M_wrData1[63:0]),	 // Templated
	  .M_wrPriority			(M_wrPriority1[1:0]),	 // Templated
	  .M_wrType			(M_wrType1[2:0]),	 // Templated
	  .M_wrCompress			(M_wrCompress1),	 // Templated
	  .M_wrGuarded			(M_wrGuarded1),		 // Templated
	  .M_wrOrdered			(M_wrOrdered1),		 // Templated
	  .M_wrLockErr			(M_wrLockErr1),		 // Templated
	  .M_wrAbort			(M_wrAbort1),		 // Templated
	  .M_rdNum			(M_rdNum1[C_NUM_WIDTH-1:0]), // Templated
	  .M_rdReq			(M_rdReq1),		 // Templated
	  .M_rdAddr			(M_rdAddr1[31:0]),	 // Templated
	  .M_rdBE			(M_rdBE1[7:0]),		 // Templated
	  .M_rdPriority			(M_rdPriority1[1:0]),	 // Templated
	  .M_rdType			(M_rdType1[2:0]),	 // Templated
	  .M_rdCompress			(M_rdCompress1),	 // Templated
	  .M_rdGuarded			(M_rdGuarded1),		 // Templated
	  .M_rdLockErr			(M_rdLockErr1),		 // Templated
	  .M_rdAbort			(M_rdAbort1),		 // Templated
	  .ctba2dbg			(ctba2dbg[31:0]),
	  // Inputs
	  .sys_clk			(sys_clk),
	  .sys_rst			(sys_rst),
	  .trn_tsrc_rdy_n		(trn_tsrc_rdy_n),
	  .port2ctba_FetchCmd_req	(port2ctba_FetchCmd_req),
	  .port2ctba_FetchCmd_addr	(port2ctba_FetchCmd_addr[31:0]),
	  .port2ctba_FetchCmd_slot	(port2ctba_FetchCmd_slot[4:0]),
	  .port2ctba_FetchCFIS_req	(port2ctba_FetchCFIS_req),
	  .port2ctba_FetchCFIS_addr	(port2ctba_FetchCFIS_addr[31:0]),
	  .port2ctba_FetchCFIS_len	(port2ctba_FetchCFIS_len[4:0]),
	  .port2ctba_UpdateBC_req	(port2ctba_UpdateBC_req),
	  .port2ctba_UpdateBC_addr	(port2ctba_UpdateBC_addr[31:0]),
	  .port2ctba_FetchPRD_addr	(port2ctba_FetchPRD_addr[31:0]),
	  .port2ctba_FetchPRD_cnt	(port2ctba_FetchPRD_cnt[15:0]),
	  .port2ctba_FetchPRD_off	(port2ctba_FetchPRD_off[31:0]),
	  .port2ctba_FetchPRDTL		(port2ctba_FetchPRDTL[15:0]),
	  .port2ctba_FetchPRDBC		(port2ctba_FetchPRDBC[31:0]),
	  .al2ctba_req			(al2ctba_req),
	  .rxdma2port_ack		(rxdma2port_ack),
	  .txdma2port_ack		(txdma2port_ack),
	  .port2rxdma_req		(port2rxdma_req),
	  .port2txdma_req		(port2txdma_req),
	  .pPMP				(pPMP[3:0]),
	  .pPmpCur			(pPmpCur[3:0]),
	  .M_wrAccept			(M_wrAccept1),		 // Templated
	  .M_wrRdy			(M_wrRdy1),		 // Templated
	  .M_wrAck			(M_wrAck1),		 // Templated
	  .M_wrComp			(M_wrComp1),		 // Templated
	  .M_wrRearb			(M_wrRearb1),		 // Templated
	  .M_wrError			(M_wrError1),		 // Templated
	  .M_rdAccept			(M_rdAccept1),		 // Templated
	  .M_rdData			(M_rdData1[63:0]),	 // Templated
	  .M_rdAck			(M_rdAck1),		 // Templated
	  .M_rdComp			(M_rdComp1),		 // Templated
	  .M_rdRearb			(M_rdRearb1),		 // Templated
	  .M_rdError			(M_rdError1));		 // Templated
   sata_link #(/*AUTOINSTPARAM*/
	       // Parameters
	       .C_LINKFSM_DEBUG		(C_LINKFSM_DEBUG))
   sata_link (/*AUTOINST*/
	      // Outputs
	      .trn_rsof_n		(trn_rsof_n),
	      .trn_reof_n		(trn_reof_n),
	      .trn_rd			(trn_rd[31:0]),
	      .trn_rsrc_rdy_n		(trn_rsrc_rdy_n),
	      .trn_rsrc_dsc_n		(trn_rsrc_dsc_n),
	      .trn_tdst_rdy_n		(trn_tdst_rdy_n),
	      .trn_tdst_dsc_n		(trn_tdst_dsc_n),
	      .trn_csof_n		(trn_csof_n),
	      .trn_ceof_n		(trn_ceof_n),
	      .trn_cd			(trn_cd[31:0]),
	      .trn_csrc_rdy_n		(trn_csrc_rdy_n),
	      .trn_csrc_dsc_n		(trn_csrc_dsc_n),
	      .txdata			(txdata[31:0]),
	      .txdatak			(txdatak),
	      .rx_cs2dbg		(rx_cs2dbg[127:0]),
	      .tx_cs2dbg		(tx_cs2dbg[127:0]),
	      .link_fsm2dbg		(link_fsm2dbg[127:0]),
	      .cs2dcr_prim		(cs2dcr_prim[35:0]),
	      .cs2dcr_cnt		(cs2dcr_cnt[8:0]),
	      // Inputs
	      .phyclk			(phyclk),
	      .host_rst			(host_rst),
	      .trn_rdst_rdy_n		(trn_rdst_rdy_n),
	      .trn_rdst_dsc_n		(trn_rdst_dsc_n),
	      .trn_tsof_n		(trn_tsof_n),
	      .trn_teof_n		(trn_teof_n),
	      .trn_td			(trn_td[31:0]),
	      .trn_tsrc_rdy_n		(trn_tsrc_rdy_n),
	      .trn_tsrc_dsc_n		(trn_tsrc_dsc_n),
	      .trn_cdst_rdy_n		(trn_cdst_rdy_n),
	      .trn_cdst_dsc_n		(trn_cdst_dsc_n),
	      .trn_cdst_lock_n		(trn_cdst_lock_n),
	      .txdatak_pop		(txdatak_pop),
	      .rxdata			(rxdata[31:0]),
	      .rxdatak			(rxdatak),
	      .linkup			(linkup),
	      .plllock			(plllock),
	      .dcr2cs_pop		(dcr2cs_pop),
	      .dcr2cs_clk		(dcr2cs_clk),
	      .port_state		(port_state[7:0]),
	      .gtx_txdata		(gtx_txdata[31:0]),
	      .gtx_txdatak		(gtx_txdatak[3:0]),
	      .gtx_rxdata		(gtx_rxdata[31:0]),
	      .gtx_rxdatak		(gtx_rxdatak[3:0]),
	      .gtx_tune			(gtx_tune[31:0]));
endmodule // ahci
// Local Variables:
// verilog-library-directories:("." "ll")
// verilog-library-files:("")
// verilog-library-extensions:(".v" ".h")
// End:
// 
// ahci.v ends here
