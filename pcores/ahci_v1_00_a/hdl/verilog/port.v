// port.v --- 
// 
// Filename: port.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Fri Sep 10 09:30:21 2010 (+0800)
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
module port (/*AUTOARG*/
   // Outputs
   ctrl_dst_rdy1, ctrl_dst_lock, port2ctba_FetchCmd_req,
   port2ctba_FetchCmd_addr, port2ctba_FetchCmd_slot,
   port2ctba_FetchCFIS_req, port2ctba_FetchCFIS_addr,
   port2ctba_FetchCFIS_len, port2ctba_UpdateBC_req,
   port2ctba_UpdateBC_addr, port2ctba_FetchPRD_addr,
   port2ctba_FetchPRD_cnt, port2ctba_FetchPRD_off,
   port2ctba_FetchPRDTL, port2ctba_FetchPRDBC, port2rxdma_req, pPMP,
   pPmpCur, port2txll_Push_req, port2txdma_req, port2txdma_len,
   port2dcr_PxTFD_STS_we, port2dcr_PxTFD_STS, port2dcr_PxTFD_ERR_we,
   port2dcr_PxTFD_ERR, port2dcr_PxCMD_CCS, port2dcr_PxCMD_CCS_we,
   port2dcr_PxCI_clear, port2dcr_PxCI, port2dcr_PxSACT_clear,
   port2dcr_PxIS, port2dcr_PxIS_set, port2dcr_PxFBS_DWE,
   port2dcr_PxFBS_DWE_set, port2dcr_PxFBS_DWE_clear, port2dcr_PxSERR,
   port2dcr_PxSERR_DIAG_set, port2dcr_PxSERR_ERR_set, port2cache_req,
   port2cache_slot, port2cache_we, port2cache_PRDBC_incr,
   port2ififo_fo_req, StartComm, port_state, sata_ledA, sata_ledB,
   port2dcr_PxSIG_we, port2ghc_intr_req, port2ghc_ips_set, port2dbg,
   err2dbg, pDmaXferCnt_ex, pBsyDrq,
   // Inputs
   PxCLB, PxCLBU, PxFB, PxFBU, PxIS, PxIE, PxCMD, PxTFD, PxSIG,
   PxSSTS, PxSCTL, PxSERR, PxSACT, PxCI, PxSNTF, PxFBS, PxVS,
   cache2ctba_CFL, cache2ctba_A, cache2ctba_W, cache2ctba_P,
   cache2ctba_R, cache2ctba_B, cache2ctba_C, cache2ctba_PMP,
   cache2ctba_PRDTL, cache2ctba_PRDBC, cache2ctba_CTBA,
   cache2ctba_PRD_off, cache2ctba_PRD_cnt, sys_clk, sys_rst, linkup,
   ghc2port_ae, ghc2port_ie, ghc2port_cap, dcr2port_PxSCTL_DET,
   dcr2port_PxSSTS_DET, dcr2port_PxCMD_POD, dcr2port_PxCMD_SUD,
   dcr2port_PxCMD_FRE, dcr2port_PxCMD_PMA, dcr2port_PxCMD_ST,
   dcr2port_PxCMD_ICC_we, dcr2port_PxFBS_EN, dcr2port_PxTFD_STS_BSY,
   dcr2port_PxTFD_SYS_DRQ, dcr2port_PxTFD_SYS_ERR,
   dcr2port_PxSERR_DIAG_X, dcr2port_PxSSTS_IPM, dcr2port_PxIE_PCE,
   rxll2port_req, rxll2port_rxcount, rxll2port_fis_hdr, ctrl_data,
   ctrl_src_rdy_n, ctba2port_FetchCmd_ack, ctba2port_do,
   ctba2port_ack, ctba2port_FetchCFIS_ack, ctba2port_UpdateBC_ack,
   ctba2port_PRD_cnt, rxdma2port_ack, rxdma2port_sts, rxdma2port_xfer,
   txll2port_xfer, txll2port_Push_ack, txdma2port_ack, txdma2port_sts,
   rxdma2port_idle, txdma2port_idle, dcr2port_PxCI_ack,
   dcr2port_PxSACT_ack, dcr2port_PxIS_ack, cache2port_ack,
   ififo2port_empty, ififo2port_fo_ack, ififo2port_fis_hdr,
   ififo2port_Estatus, ififo2port_Transfer_Count, ififo2port_DS_TAG,
   ififo2port_DS_offset, ififo2port_DS_Count, ififo2port_SDB_SActive,
   trn_tsrc_rdy_n, trn_tdst_dsc_n, CommInit
   );
   parameter C_PM = 2;
`include "ll/sata.v"
   
   input sys_clk;
   input sys_rst;

   input linkup;
   input ghc2port_ae;
   input ghc2port_ie;
   input [31:0] ghc2port_cap;
   
   input [03:0] dcr2port_PxSCTL_DET;
   input [03:0] dcr2port_PxSSTS_DET;   
   input 	dcr2port_PxCMD_POD;
   input 	dcr2port_PxCMD_SUD;
   input 	dcr2port_PxCMD_FRE;
   input 	dcr2port_PxCMD_PMA;
   input 	dcr2port_PxCMD_ST;
   input 	dcr2port_PxCMD_ICC_we;
   input 	dcr2port_PxFBS_EN;
   input 	dcr2port_PxTFD_STS_BSY;
   input 	dcr2port_PxTFD_SYS_DRQ;
   input 	dcr2port_PxTFD_SYS_ERR;
   input 	dcr2port_PxSERR_DIAG_X;
   input [3:0]  dcr2port_PxSSTS_IPM;
   input        dcr2port_PxIE_PCE;

   input        rxll2port_req;
   input [15:0] rxll2port_rxcount;
   input [15:0] rxll2port_fis_hdr;

   input [31:0] ctrl_data;
   input        ctrl_src_rdy_n;
   output       ctrl_dst_rdy1;
   output 	ctrl_dst_lock;
   
   output 	 port2ctba_FetchCmd_req;
   output [31:0] port2ctba_FetchCmd_addr;      
   output [4:0]  port2ctba_FetchCmd_slot;      
   input 	 ctba2port_FetchCmd_ack;
   input [63:0]  ctba2port_do;
   input 	 ctba2port_ack;

   output 	 port2ctba_FetchCFIS_req;
   output [31:0] port2ctba_FetchCFIS_addr;
   output [4:0]  port2ctba_FetchCFIS_len;
   input 	 ctba2port_FetchCFIS_ack;
   
   output 	 port2ctba_UpdateBC_req;
   output [31:0] port2ctba_UpdateBC_addr;
   input 	 ctba2port_UpdateBC_ack;
   
   output [31:0] port2ctba_FetchPRD_addr;
   output [15:0] port2ctba_FetchPRD_cnt;
   output [31:0] port2ctba_FetchPRD_off;
   output [15:0] port2ctba_FetchPRDTL;
   output [31:0] port2ctba_FetchPRDBC;
   input [15:0]  ctba2port_PRD_cnt;
   output 	 port2rxdma_req;
   input 	 rxdma2port_ack;
   input [31:0]	 rxdma2port_sts;
   input         rxdma2port_xfer;
   input         txll2port_xfer;
   output [3:0]  pPMP;
   output [3:0]  pPmpCur;

   input         txll2port_Push_ack;
   output        port2txll_Push_req;

   output 	 port2txdma_req;
   output [31:0] port2txdma_len;
   input 	 txdma2port_ack;
   input [31:0]  txdma2port_sts;
   
   input 	 rxdma2port_idle;
   input 	 txdma2port_idle;

   output 	port2dcr_PxTFD_STS_we;
   output [7:0] port2dcr_PxTFD_STS;
   output 	port2dcr_PxTFD_ERR_we;
   output [7:0] port2dcr_PxTFD_ERR;
   output [4:0] port2dcr_PxCMD_CCS;
   output 	port2dcr_PxCMD_CCS_we;

   output 	port2dcr_PxCI_clear;
   output [4:0] port2dcr_PxCI;
   input 	dcr2port_PxCI_ack;
   
   output 	port2dcr_PxSACT_clear;
   input 	dcr2port_PxSACT_ack;
   
   output [31:0] port2dcr_PxIS;
   output 	 port2dcr_PxIS_set;
   input 	 dcr2port_PxIS_ack;
   
   output [3:0] port2dcr_PxFBS_DWE;
   output 	port2dcr_PxFBS_DWE_set;
   output 	port2dcr_PxFBS_DWE_clear;
   
   output [31:0] port2dcr_PxSERR;
   output 	 port2dcr_PxSERR_DIAG_set;
   output 	 port2dcr_PxSERR_ERR_set;
   
   output 	port2cache_req;
   output [4:0] port2cache_slot;
   output       port2cache_we;
   input        cache2port_ack;
   output       port2cache_PRDBC_incr;

   input        ififo2port_empty;
   output       port2ififo_fo_req;
   input        ififo2port_fo_ack;

   input [31:0]	ififo2port_fis_hdr;
   input [7:0]	ififo2port_Estatus;
   input [15:0]	ififo2port_Transfer_Count;
   input [5:0]	ififo2port_DS_TAG;
   input [31:0]	ififo2port_DS_offset;
   input [31:0]	ififo2port_DS_Count;
   input [31:0]	ififo2port_SDB_SActive;

   input        trn_tsrc_rdy_n;
   input        trn_tdst_dsc_n;
   wire         trn_tdst_dsc_n_sysclk;

   input 	CommInit;  /* async input from phy clock domain */
   output 	StartComm; /* async output to phy clock domain */
   output [7:0] port_state;
   output  sata_ledA;
   output  sata_ledB;

   /*AUTOINOUTCOMP("ctba_ram", "^cache2ctba")*/
   // Beginning of automatic in/out/inouts (from specific module)
   input [4:0]		cache2ctba_CFL;
   input		cache2ctba_A;
   input		cache2ctba_W;
   input		cache2ctba_P;
   input		cache2ctba_R;
   input		cache2ctba_B;
   input		cache2ctba_C;
   input [3:0]		cache2ctba_PMP;
   input [15:0]		cache2ctba_PRDTL;
   input [31:0]		cache2ctba_PRDBC;
   input [31:0]		cache2ctba_CTBA;
   input [31:0]		cache2ctba_PRD_off;
   input [15:0]		cache2ctba_PRD_cnt;
   // End of automatics
   
  
   output 	port2dcr_PxSIG_we;
   /*AUTOINOUTCOMP("aport_dcr", "^Px")*/
   // Beginning of automatic in/out/inouts (from specific module)
   input [31:0]		PxCLB;
   input [31:0]		PxCLBU;
   input [31:0]		PxFB;
   input [31:0]		PxFBU;
   input [31:0]		PxIS;
   input [31:0]		PxIE;
   input [31:0]		PxCMD;
   input [31:0]		PxTFD;
   input [31:0]		PxSIG;
   input [31:0]		PxSSTS;
   input [31:0]		PxSCTL;
   input [31:0]		PxSERR;
   input [31:0]		PxSACT;
   input [31:0]		PxCI;
   input [31:0]		PxSNTF;
   input [31:0]		PxFBS;
   input [31:0]		PxVS;
   // End of automatics
   
   wire 	ll2port_LowPower_req;
   
   output [15:0] port2ghc_intr_req;
   output [15:0] port2ghc_ips_set;

   output [127:0] port2dbg;
   output [31:0] err2dbg;
   output [31:0] pDmaXferCnt_ex;
   output [31:0] pBsyDrq;

   /* not support LowerPower */
   assign       ll2port_LowPower_req = 1'b0;
   /**********************************************************************/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			StartComm;
   reg			ctrl_dst_lock;
   reg			ctrl_dst_rdy1;
   reg [31:0]		err2dbg;
   reg			port2cache_req;
   reg [4:0]		port2cache_slot;
   reg			port2cache_we;
   reg			port2ctba_FetchCFIS_req;
   reg			port2ctba_FetchCmd_req;
   reg			port2ctba_UpdateBC_req;
   reg [4:0]		port2dcr_PxCI;
   reg			port2dcr_PxCI_clear;
   reg [4:0]		port2dcr_PxCMD_CCS;
   reg			port2dcr_PxCMD_CCS_we;
   reg [3:0]		port2dcr_PxFBS_DWE;
   reg			port2dcr_PxFBS_DWE_clear;
   reg			port2dcr_PxFBS_DWE_set;
   reg [31:0]		port2dcr_PxIS;
   reg			port2dcr_PxIS_set;
   reg			port2dcr_PxSACT_clear;
   reg [31:0]		port2dcr_PxSERR;
   reg			port2dcr_PxSERR_DIAG_set;
   reg			port2dcr_PxSERR_ERR_set;
   reg			port2dcr_PxSIG_we;
   reg [7:0]		port2dcr_PxTFD_ERR;
   reg			port2dcr_PxTFD_ERR_we;
   reg [7:0]		port2dcr_PxTFD_STS;
   reg			port2dcr_PxTFD_STS_we;
   reg			port2ififo_fo_req;
   reg			port2rxdma_req;
   reg			port2txdma_req;
   reg			port2txll_Push_req;
   // End of automatics
   
   reg [03:0] pDevIssue;
   reg 	      pUpdateSig;
   reg [15:0] pBsy;
   reg [15:0] pDrq;
   reg [3:0]  pPmpCur;
   reg [5:0]  pIssueSlot[15:0];
   reg [5:0]  pIssueSlot_pDevIssue;  
   reg [5:0]  pIssueSlot_pPmpCur;
   reg [5:0]  pIssueSlot_0;
   reg [5:0]  pDataSlot[15:0];
   reg [5:0]  pDataSlot_pDevIssue;
   reg [5:0]  pDataSlot_pPmpCur;
   reg [3:0]  pPMP;
   reg 	      pXferAtapi;
   reg [15:0] pPioXfer;
   reg [7:0]  pPioEsts;
   reg [7:0]  pPioErr;
   reg 	      pPiolbit;
   reg [27:2] pDmaXferCnt [15:0];
   reg [27:2] pDmaXferCnt_0;
   reg [27:2] pDmaXferCnt_pDevIssue;
   reg [5:0]  pCmdToIssue;
   reg [15:0] pPrdIntr;
   reg [31:0] pSActive;
   reg [4:0]  pSlotLoc;

   reg 	      PxCMD_POD;
   reg [3:0]  PxSCTL_DET;
   reg 	      PxCMD_SUD;
   reg 	      PxCMD_FRE;
   reg [15:0] pBsy_pDrq;
   reg 	      rx_wip;
   reg 	      PxCMD_ST;
   localparam [7:0]
     C_RFIS       = 8'h34,
     C_SDB        = 8'hA1,
     C_DmaAct     = 8'h39,
     C_DmaSetup   = 8'h41,
     C_BIST       = 8'h58,
     C_PioSetup   = 8'h5f,
     C_DFIS       = 8'h46;
   /**********************************************************************/
   localparam [7:0] // synopsys enum state_info
     P_Reset                 = 8'h0_0,
     P_Init                  = 8'h0_1,
     P_NotRunning            = 8'h0_2,
     P_ComInit               = 8'h0_3,
     P_ComInitSetIs          = 8'h0_4,
     P_ComInitGenIntr        = 8'h0_5,
     P_RegFisUpdate          = 8'h0_6,
     P_RegFisPostToMem       = 8'h0_7,
     P_Offline               = 8'h0_8,
     P_StartBitCleared       = 8'h0_9,
     P_Idle                  = 8'h0_a,
     P_SelectCmd             = 8'h0_b,
     P_FetchCmd              = 8'h0_c,
     P_FetchCmd1             = 8'h0_d, 
     P_StartComm             = 8'hf_a,
     P_PowerOn               = 8'hf_b,
     P_PowerOff              = 8'hf_c,
     P_PhyListening          = 8'hf_d,

     FB_Idle                 = 8'h1_0,
     FB_SelectDevice         = 8'h1_1,
     FB_SelectCmd            = 8'h1_2,
     FB_FetchCmd             = 8'h1_3,
     FB_FetchCmd1            = 8'h1_4,
     FB_SingleDeviceErr      = 8'h1_5,
     FB_SDE_Cleanup          = 8'h1_6,

     PM_Aggr                 = 8'h2_0,
     PM_ICC                  = 8'h2_1,
     PM_Partial              = 8'h2_2,
     PM_Slumber              = 8'h2_3,
     PM_LowPower             = 8'h2_4,
     PM_WakeLink             = 8'h2_5,

     NDR_Entry               = 8'h3_0,
     NDR_Entry1              = 8'h3_1,
     NDR_ERR_NotFatal        = 8'h3_2,
     NDR_ERR_NotFatal1       = 8'h3_3,     
     NDR_ERR_Fatal           = 8'h3_4,
     NDR_ERR_Fatal1          = 8'h3_5,     
     NDR_ERR_IPMS            = 8'h3_6,
     NDR_ERR_IPMS1           = 8'h3_7,     
     NDR_PmCheck             = 8'h3_8,
     NDR_Accept              = 8'h3_9,
     NDR_Accept_Idle         = 8'h3_a,
     NDR_Accept_Idle1        = 8'h3_b,
     
     CFIS_SyncEscape         = 8'h4_0,
     CFIS_Xmit               = 8'h4_1,
     CFIS_Xmit_Fetch         = 8'h4_2,
     CFIS_Xmit_Push          = 8'h4_3,
     CFIS_Xmit_Wait          = 8'h4_4,
     CFIS_Xmit_Abort         = 8'h4_5,
     CFIS_Xmit_Clear         = 8'h4_6,     
     CFIS_Success            = 8'h4_7,
     CFIS_ClearCI            = 8'h4_8,
     CFIS_PreFetchACMD       = 8'h4_9,
     CFIS_PreFetchPRD        = 8'h4_a,
     CFIS_PreFetchData       = 8'h4_b,

     ATAPI_Entry             = 8'h5_0,

     RegFis_Entry            = 8'h6_0,
     RegFis_ClearCI          = 8'h6_1,
     RegFis_Ccc              = 8'h6_2,
     RegFis_SetIntr          = 8'h6_3,
     RegFis_SetIs            = 8'h6_4,
     RegFis_GenIntr          = 8'h6_5,
     RegFis_UpdateSig        = 8'h6_6,
     RegFis_SetSig           = 8'h6_7,

     PIO_Entry               = 8'h7_0,
     PIO_Update              = 8'h7_1,
     PIO_Update1             = 8'h7_2,
     PIO_ClearCI             = 8'h7_3,
     PIO_Ccc                 = 8'h7_4,
     PIO_SetIntr             = 8'h7_5,
     PIO_SetIs               = 8'h7_6,
     PIO_GenIntr             = 8'h7_7,

     DX_Entry                = 8'h8_0,
     DX_Entry1               = 8'h8_1,     
     DX_Transmit2            = 8'h8_2,
     DX_Transmit3            = 8'h8_3,     
     DX_Transmit             = 8'h8_4,
     DX_UpdateByteCount      = 8'h8_5,
     DX_UpdateByteCount1     = 8'h8_6,
     DX_PrdSetIntr           = 8'h8_7,
     DX_PrdSetIs             = 8'h8_8,
     DX_PrdGentIntr          = 8'h8_9,

     DR_Entry                = 8'h9_0,
     DR_Receive0             = 8'h9_1,
     DR_Receive1             = 8'h9_2,
     DR_Receive2             = 8'h9_3,
     DR_Receive3             = 8'h9_4,
     DR_Receive4             = 8'h9_5,     
     DR_Receive              = 8'h9_6,
     DR_UpdateByteCount      = 8'h9_7,
     DR_UpdateByteCount1     = 8'h9_8,
     DR_UpdateByteCount2     = 8'h9_9,
     DR_UpdateByteCount3     = 8'h9_a,

     DmaSet_Entry            = 8'ha_0,
     DmaSet_Entry1           = 8'ha_1,
     DmaSet_SetIntr          = 8'ha_2,
     DmaSet_SetIs            = 8'ha_3,
     DmaSet_GenIntr          = 8'ha_4,
     DmaSet_AutoActivate     = 8'ha_5,
     DmaSet_AutoActivate1    = 8'ha_6,
     DmaSet_AutoActivate2    = 8'ha_7,

     SDB_Entry               = 8'hb_0,
     SDB_Entry1              = 8'hb_1,     
     SDB_Notification        = 8'hb_2,
     SDB_SetIntr             = 8'hb_3,
     SDB_Ccc                 = 8'hb_4,
     SDB_SetIs               = 8'hb_5,
     SDB_GenIntr             = 8'hb_6,

     UFIS_Entry              = 8'hc_0,
     UFIS_SetIs              = 8'hc_1,
     UFIS_GenIntr            = 8'hc_2,

     BIST_FarEndLoop         = 8'hd_0,
     BIST_TestOngoing        = 8'hd_1,

     ERR_IPMS                = 8'he_0,
     ERR_SyncEscapeRecv      = 8'he_1,
     ERR_SyncEscapeRecvFbNd  = 8'he_2,
     ERR_Fatal               = 8'he_3,
     ERR_NotFatal            = 8'he_4,
     ERR_FatalTaskFile       = 8'he_5,
     ERR_WaitForCLear        = 8'he_6,

     DmaAct_Entry            = 8'hf_0;
   (* fsm_extract = "no" *)
   reg [7:0] // synopsys enum state_info
	     state, state_ns;
   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     state <= #1 P_Reset;
	  end
	else
	  begin
	     state <= #1 state_ns;
	  end
     end // always @ (posedge sys_clk)
   always @(*)
     begin
	state_ns = state;
	case(state)
	  P_Reset:
	    begin
	       state_ns = P_Init;
	    end
	  P_Init:
	    begin
	       state_ns = P_NotRunning;
	    end
	  P_NotRunning: 
	    begin
	       if (ghc2port_ae == 1'b0)
		 begin
		    state_ns = P_NotRunning;
		 end
	       else if (dcr2port_PxCMD_POD == 1'b1 &&
			PxCMD_POD == 1'b0)
		 begin
		    state_ns = P_PowerOn;
		 end
	       else if (dcr2port_PxCMD_POD == 1'b0 &&
			PxCMD_POD == 1'b1)
		 begin
		    state_ns = P_PowerOff;
		 end
	       else if (dcr2port_PxSCTL_DET == 4'h4 &&
			PxSCTL_DET != 4'h4)
		 begin
		    state_ns = P_Offline;
		 end
	       else if (dcr2port_PxSCTL_DET == 4'h1 &&
			PxSCTL_DET != 4'h1 &&
			dcr2port_PxCMD_SUD == 1'b1)
		 begin
		    state_ns = P_StartComm;
		 end
	       else if (dcr2port_PxCMD_SUD == 1'b1 &&
			PxCMD_SUD == 1'b0 &&
			dcr2port_PxSCTL_DET == 4'h0)
		 begin
		    state_ns = P_StartComm;
		 end
	       else if (dcr2port_PxCMD_SUD == 1'b0 &&
			PxCMD_SUD == 1'b1 &&
			dcr2port_PxSCTL_DET == 4'h0)
		 begin
		    state_ns = P_PhyListening;
		 end
	       else if (dcr2port_PxCMD_FRE == 1'b1 &&
			PxCMD_FRE == 1'b0 &&
			dcr2port_PxSERR_DIAG_X == 1'b0 &&
			~ififo2port_empty)
		 begin
		    state_ns = P_RegFisPostToMem;
		 end
	       else if (dcr2port_PxCMD_ST == 1'b1 &&
			(dcr2port_PxSSTS_IPM == 4'h2 |
			 dcr2port_PxSSTS_IPM == 4'h6))
		 begin
		    state_ns = PM_LowPower;
		 end
	       else if (dcr2port_PxCMD_ST == 1'b1 &&
			dcr2port_PxFBS_EN == 1'b1 &&
			dcr2port_PxTFD_STS_BSY == 1'b0 &&
			dcr2port_PxTFD_SYS_DRQ == 1'b0)
		 begin
		    state_ns = FB_Idle;
		 end
	       else if (dcr2port_PxCMD_ST == 1'b1 &&
			dcr2port_PxTFD_STS_BSY == 1'b0 &&
			dcr2port_PxTFD_SYS_DRQ == 1'b0)
		 begin
		    state_ns = P_Idle;
		 end
	       else if (ififo2port_empty == 1'b0 &&
			ififo2port_fis_hdr[7:0] == C_RFIS)
		 begin
		    state_ns = NDR_Entry;
		 end
	    end // case: P_NotRunning
	  P_ComInit:
	    begin
	       if (dcr2port_PxIE_PCE == 1'b1)
		 begin
		    state_ns = P_ComInitSetIs;
		 end
	       else
		 begin
		    state_ns = P_NotRunning;
		 end
	    end // case: P_ComInit
	  P_ComInitSetIs:
	    begin
	       if (ghc2port_ie == 1'b1)
		 begin
		    state_ns = P_ComInitGenIntr;
		 end
	       else
		 begin
		    state_ns = P_NotRunning;
		 end
	    end // case: P_ComInitSetIs
	  P_ComInitGenIntr:
	    begin
	       state_ns = P_NotRunning;
	    end
	  P_RegFisUpdate:
	    begin
	       if (dcr2port_PxCMD_FRE == 1'b1)
		 begin
		    state_ns = P_RegFisPostToMem;
		 end
	       else
		 begin
		    state_ns = P_NotRunning;
		 end
	    end
	  P_RegFisPostToMem:
	    begin
	       if (ififo2port_fo_ack)
		 begin
		    state_ns = P_NotRunning;
		 end
	    end
	  P_Offline:
	    begin
	       state_ns = P_NotRunning;
	    end
	  P_StartBitCleared:
	    begin
	       /*if (rxdma2port_idle != 1'b0 ||
	           txdma2port_idle != 1'b0)
		 begin
		    state_ns = P_StartBitCleared;
		 end
	       else*/
		 begin
		    state_ns = P_NotRunning;
		 end
	    end // case: P_StartBitCleared
	  P_Idle:
	    begin
	       if (PxCMD_ST == 1'b1 &&
		   dcr2port_PxCMD_ST == 1'b0)
		 begin
		    state_ns = P_StartBitCleared;
		 end
	       else if (dcr2port_PxSSTS_DET != 4'h3)
		 begin
		    state_ns = P_NotRunning;
		 end
	       else if (PxCI != 32'h0 &&
			pIssueSlot_0 == 6'd32)
		 begin
		    state_ns = P_SelectCmd;
		 end
	       else if (pCmdToIssue == 6'h1 &&
			cache2ctba_R == 1'b1 &&
			pDmaXferCnt_0 == 32'h0)
		 begin
		    state_ns = CFIS_SyncEscape;
		 end
	       else if (rxll2port_req && ififo2port_empty)
		 begin
		    state_ns = DR_Entry;
		 end
	       else if (ififo2port_empty == 1'b0)
		 begin
		    state_ns = NDR_Entry;
		 end
	       else if (pCmdToIssue == 6'h1 &&
			pDmaXferCnt_0 == 32'h0 &&
			rx_wip == 1'b0)
		 begin
		    state_ns = CFIS_Xmit;
		 end
	       else if (ll2port_LowPower_req)
		 begin
		    state_ns = PM_LowPower;
		 end
	       else if (dcr2port_PxCMD_ICC_we)
		 begin
		    state_ns = PM_ICC;
		 end
	    end // case: P_Idle
	  P_SelectCmd:
	    begin
	       if (PxCI[pSlotLoc] == 1'b1)
		 begin
		    state_ns = P_FetchCmd;
		 end
	    end // case: P_SelectCmd
	  P_FetchCmd:
	    begin
	       if (ctba2port_FetchCmd_ack)
		 begin
		    state_ns = P_FetchCmd1;
		 end
	    end // case: P_FetchCmd
	  P_FetchCmd1:
	    begin
	       if (cache2port_ack)
		 begin
		    state_ns = P_Idle;
		 end
	    end
	  P_StartComm:
	    begin
	       if (dcr2port_PxSCTL_DET == 4'h1)
		 begin
		    state_ns = P_StartComm;
		 end
	       else
		 begin
		    state_ns = P_NotRunning;
		 end
	    end // case: P_StartComm
	  P_PowerOn:
	    begin
	       state_ns = P_NotRunning;	       
	    end
	  P_PowerOff:
	    begin
	       state_ns = P_NotRunning;	       
	    end
	  P_PhyListening:
	    begin
	       state_ns = P_NotRunning;	       
	    end
	  FB_Idle:
	    begin
	       if (dcr2port_PxSSTS_DET != 4'h3)
		 begin
		    state_ns = P_NotRunning;		    
		 end
	       else if (pCmdToIssue == 1'b0 &&
			pDmaXferCnt_pDevIssue == 32'h0 &&
			pBsy_pDrq[15:0] != 16'hffff &&
		        PxCI != 32'h0)
		 begin
		    state_ns = FB_SelectDevice;
		 end
	       else if (rxll2port_req && ififo2port_empty)
		 begin
		    state_ns = DR_Entry;
		 end
	       else if (ififo2port_empty == 1'b0)
		 begin
		    state_ns = NDR_Entry;
		 end
	       else if (pCmdToIssue == 6'h1 &&
			pDmaXferCnt_pDevIssue == 32'h0 &&
		        rx_wip == 1'b0)
		 begin
		    state_ns = CFIS_Xmit;
		 end
	       else if (ll2port_LowPower_req)
		 begin
		    state_ns = PM_LowPower;		    
		 end
	       else if (dcr2port_PxCMD_ICC_we)
		 begin
		    state_ns = PM_ICC;
		 end
	    end // case: FB_Idle
	  FB_SelectDevice:
	    begin
	       if (pBsy[pDevIssue] == 1'b0 &&
		   pDrq[pDevIssue] == 1'b0)
		 begin
		    state_ns = FB_SelectCmd;
		 end
	    end
	  FB_SelectCmd:
	    begin
	       if (PxCI[pSlotLoc] == 1'b1)
		 begin
		    state_ns = FB_FetchCmd;
		 end
	    end
	  FB_FetchCmd:
	    begin
	       if (ctba2port_FetchCmd_ack)
		 begin
		    state_ns = FB_FetchCmd1;
		 end
	    end
	  FB_FetchCmd1:
	    begin
	       if (cache2port_ack)
		 begin
		    state_ns = FB_Idle;
		 end
	    end
	  FB_SingleDeviceErr:
	    begin
	       if (PxFBS[1])
		 begin
		    state_ns = FB_SDE_Cleanup;
		 end
	    end
	  FB_SDE_Cleanup:
	    begin
	       
	    end
	  NDR_Entry:
	    begin
	       if (ctrl_src_rdy_n == 1'b0 &&
		   ctrl_data != C_GOOD)
		 begin
		    state_ns = NDR_ERR_NotFatal;
		 end
	       else if (rxll2port_rxcount[15:7] != 9'h0 && // >64byte
	                ctrl_src_rdy_n == 1'b0)
		 begin
		    state_ns = NDR_ERR_Fatal;
		 end
	       else if (dcr2port_PxCMD_PMA == 1'b1 &&
			ctrl_src_rdy_n == 1'b0)
		 begin
		    state_ns = NDR_PmCheck;
		 end
	       else if (ctrl_src_rdy_n == 1'b0)
		 begin
		    state_ns = NDR_Accept;
		 end
	    end // case: NDR_Entry
	  NDR_PmCheck:
	    begin
	       if (ififo2port_fis_hdr[7:0] == C_SDB &&
		   ififo2port_fis_hdr[15]  == 1'b1) // N bit
		 begin
		    state_ns = NDR_Accept;
		 end
	       else if (0 /* TODO page51 */)
		 begin
		    state_ns = NDR_ERR_IPMS;
		 end
	       else
		 begin
		    state_ns = NDR_Accept;
		 end
	    end // case: NDR_PmCheck
	  NDR_Accept:
	    begin
	       if ((ififo2port_fis_hdr[7:0] == C_RFIS ||
		    ififo2port_fis_hdr[7:0] == C_PioSetup) &&
		   pBsy[pPmpCur] == 1'b0 &&
		   pDrq[pPmpCur] == 1'b0)
		 begin
		    state_ns = NDR_Accept_Idle;
		 end
	       else if (ififo2port_fis_hdr[7:0] == C_RFIS &&
			dcr2port_PxCMD_ST == 1'b0)
		 begin
		    state_ns = P_RegFisUpdate;
		 end
	       else if (ififo2port_fis_hdr[7:0] == C_RFIS)
		 begin
		    state_ns = RegFis_Entry;
		 end
	       else if (ififo2port_fis_hdr[7:0] == C_SDB &&
			ififo2port_fis_hdr[15]  == 1'b1  && // N bit
			dcr2port_PxFBS_EN == 1'b0 &&
			0/*TODO page 52 */)
		 begin
		    state_ns = SDB_Notification;
		 end
	       else if (ififo2port_fis_hdr[7:0] == C_SDB)
		 begin
		    state_ns = SDB_Entry;
		 end
	       else if (ififo2port_fis_hdr[7:0] == C_DmaAct)
		 begin
		    state_ns = DmaAct_Entry;
		 end
	       else if (ififo2port_fis_hdr[7:0] == C_DmaSetup)
		 begin
		    state_ns = DmaSet_Entry;
		 end
	       else if (ififo2port_fis_hdr[7:0] == C_PioSetup)
		 begin
		    state_ns = PIO_Entry;
		 end
	       else
		 begin
		    state_ns = UFIS_Entry;
		 end
	    end // case: NDR_Accept
	  NDR_Accept_Idle:
	    begin
	       if (ififo2port_fo_ack && 
		   dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else if (ififo2port_fo_ack)
		 begin
		    state_ns = P_Idle;
		 end
	    end // case: NDR_Accept_Idle
	  NDR_ERR_NotFatal:
	    begin
	       if (ififo2port_fo_ack)
		 begin
		    state_ns = ERR_NotFatal;
		 end
	    end
	  NDR_ERR_Fatal:
	    begin
	       if (ififo2port_fo_ack)
		 begin
		    state_ns = ERR_Fatal;
		 end	       
	    end
	  NDR_ERR_IPMS:
	    begin
	       if (ififo2port_fo_ack)
		 begin
		    state_ns = ERR_IPMS;
		 end
	    end
	  DmaAct_Entry:
	    begin
	       if (ififo2port_fo_ack)
		 begin
		    state_ns = DX_Entry;
		 end
	    end
	  UFIS_Entry:
	    begin
	       if (ififo2port_fo_ack && 
		   PxIE[4] == 1'b1)
		 begin
		    state_ns = UFIS_SetIs;
		 end
	       else if (ififo2port_fo_ack &&
			dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else if (ififo2port_fo_ack)
		 begin
		    state_ns = P_Idle;
		 end
	    end
	  UFIS_SetIs:
	    begin
	       if (ghc2port_ie)
		 begin
		    state_ns = UFIS_GenIntr;
		 end
	       else if (dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else
		 begin
		    state_ns = P_Idle;
		 end
	    end
	  UFIS_GenIntr:
	    begin
	       if (dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;		    
		 end
	       else
		 begin
		    state_ns = P_Idle;
		 end
	    end
	  CFIS_SyncEscape: 
	    begin 
	       state_ns = CFIS_Xmit;
	    end
	  CFIS_Xmit:
	    begin
	       if (cache2port_ack)
		 begin
		    state_ns = CFIS_Xmit_Fetch;
		 end
	    end
	  CFIS_Xmit_Fetch:
	    begin
	       if (ctba2port_FetchCFIS_ack)
		 begin
		    state_ns = CFIS_Xmit_Push;
		 end
	    end
	  CFIS_Xmit_Push:
	    begin
	       if (txll2port_Push_ack)
		 begin
		    state_ns = CFIS_Xmit_Wait;
		 end
	    end
	  CFIS_Xmit_Wait:
	    begin
	       if ((ctrl_src_rdy_n == 1'b0 &&
		    (ctrl_data == C_SRCV || /* receive side information */
	             ctrl_data == C_GOOD ||
	             ctrl_data == C_BAD)) ||
		   trn_tdst_dsc_n_sysclk == 1'b0)
		 begin
		    state_ns = CFIS_Xmit_Abort;
		 end
	       else if (ctrl_src_rdy_n == 1'b0 &&
			ctrl_data == C_SYNC &&
			dcr2port_PxFBS_EN == 1'b1)
		 begin
		    state_ns = ERR_SyncEscapeRecvFbNd;
		 end
	       else if (ctrl_src_rdy_n == 1'b0 &&
			ctrl_data == C_SYNC)
		 begin
		    state_ns = ERR_SyncEscapeRecv;
		 end
	       else if (ctrl_src_rdy_n == 1'b0 &&
			ctrl_data == C_R_OK)
		 begin
		    state_ns = CFIS_Success;
		 end
	       else if (ctrl_src_rdy_n == 1'b0 &&
			ctrl_data != C_R_OK)
		 begin
		    state_ns = ERR_NotFatal;
		 end
	    end // case: CFIS_Xmit_Wait
	  CFIS_Xmit_Abort:
	    begin
	       if (ctrl_data == C_SRCV || 
	           trn_tdst_dsc_n_sysclk == 1'b0)
		 begin
		    state_ns = CFIS_Xmit_Clear;
		 end
	       else if (dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else
		 begin
		    state_ns = P_Idle;		    
		 end
	    end // case: CFIS_Xmit3
	  CFIS_Xmit_Clear:
	    begin
	       if ((ctrl_src_rdy_n == 1'b1 || 
		    trn_tdst_dsc_n_sysclk == 1'b0) &&
		   dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else if (ctrl_src_rdy_n == 1'b1 ||
	                trn_tdst_dsc_n_sysclk == 1'b0)
		 begin
	            state_ns = P_Idle;
		 end
	    end
	  CFIS_Success: if (cache2ctba_B && 
		            ctrl_src_rdy_n == 1'b1)
	    begin
	       state_ns = BIST_TestOngoing;
	    end
	  else if (cache2ctba_C && 
		   ctrl_src_rdy_n == 1'b1)
	    begin
	       state_ns = CFIS_ClearCI;
	    end
	  else if (dcr2port_PxFBS_EN && 
		   ctrl_src_rdy_n == 1'b1)
	    begin
	       state_ns = FB_Idle;
	    end
	  else if (ctrl_src_rdy_n == 1'b1)
	    begin
	       state_ns = P_Idle;
	    end
	  CFIS_ClearCI:
	    begin
	       if (dcr2port_PxCI_ack)
		 begin
		    state_ns = PM_Aggr;
		 end
	    end
	  PM_Aggr:
	    begin
	       if (dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else
		 begin
		    state_ns = P_Idle;
		 end
	    end // case: PM_Aggr
	  PIO_Entry:
	    begin
	       if (ififo2port_fo_ack &&
		   ififo2port_fis_hdr[23] == 1'b1)
		 begin
		    state_ns = ERR_FatalTaskFile;
		 end
	       else if (ififo2port_fo_ack &&
			ififo2port_fis_hdr[13] == 1'b0 && // Dbit
			pXferAtapi == 1'b0)
		 begin
		    state_ns = DX_Entry;
		 end
	       else if (ififo2port_fo_ack &&
			ififo2port_fis_hdr[13] == 1'b0 && // Dbit
			pXferAtapi == 1'b1)
		 begin
		    state_ns = ATAPI_Entry;
		 end
	       else if (ififo2port_fo_ack &&
			dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else if (ififo2port_fo_ack)
		 begin
		    state_ns = P_Idle;
		 end
	    end // case: PIO_Entry
	  PIO_Update:
	    begin
	       state_ns = PIO_Update1;
	    end // case: PIO_Update
	  PIO_Update1:
	    begin
	       if (pPioEsts[0] == 1'b1)
		 begin
		    state_ns = ERR_FatalTaskFile;
		 end
	       else if (pPioEsts[7] == 1'b0 &&
			pPioEsts[3] == 1'b0)
		 begin
		    state_ns = PIO_ClearCI;
		 end
	       else if (pPiolbit == 1'b1)
		 begin
		    state_ns = PIO_SetIntr;
		 end
	       else if (dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else
		 begin
		    state_ns = P_Idle;
		 end
	    end // case: PIO_Update
	  PIO_ClearCI:
	    begin
	       if (pPiolbit == 1'b1 && 
		   dcr2port_PxCI_ack)
		 begin
		    state_ns = PIO_SetIntr;
		 end
	       else if (dcr2port_PxCI_ack)
		 begin
		    state_ns = PM_Aggr;
		 end
	    end // case: PIO_ClearCI
	  PIO_SetIntr:
	    begin
	       if (PxIE[1] == 1'b1)
		 begin
		    state_ns = PIO_SetIs;
		 end
	       else
		 begin
		    state_ns = PM_Aggr;		    
		 end
	    end // case: PIO_SetIntr
	  PIO_SetIs:
	    begin
	       if (ghc2port_ie)
		 begin
		    state_ns = PIO_GenIntr;
		 end
	       else
		 begin
		    state_ns = PM_Aggr;		    		    
		 end
	    end // case: PIO_SetIs
	  PIO_GenIntr:
	    begin
	       state_ns = PM_Aggr;		    		    	       
	    end
	  DR_Entry:
	    begin/*TODO Page 58*/
	       state_ns = DR_Receive;
	    end
	  DR_Receive:
	    begin
	       state_ns = DR_Receive1;
	    end
	  DR_Receive1:
	    begin
	       if (cache2port_ack)
		 begin
		    state_ns = DR_Receive2;
		 end
	    end
	  DR_Receive2:
	    begin
	       state_ns = DR_Receive3;
	    end
	  DR_Receive3:
	    begin
	       if (rxdma2port_ack && rxdma2port_sts == C_R_OK)
		 begin
		    state_ns = DR_Receive4;
		 end
	       else if (rxdma2port_ack && rxdma2port_sts != C_R_OK)
		 begin
		    state_ns = DR_Receive4; /* TODO */
		 end
	    end // case: DR_Receive3
	  DR_Receive4:
	    begin
	       if (ctrl_src_rdy_n == 1'b0 &&
		   ctrl_data == C_GOOD)
		 begin
		    state_ns = DR_UpdateByteCount;
		 end
	       else if (ctrl_src_rdy_n == 1'b0 &&
			ctrl_data != C_GOOD)
		 begin
		    state_ns = ERR_Fatal;
		 end
	    end
	  DR_UpdateByteCount:
	    begin
	       if (cache2port_ack)
		 begin
		    state_ns = DR_UpdateByteCount1;
		 end
	    end
	  DR_UpdateByteCount1:
	    begin
	       if (ctba2port_UpdateBC_ack &&
		   pPrdIntr[pPmpCur])
		 begin
		    state_ns = DX_PrdSetIntr;
		 end
	       else if (ctba2port_UpdateBC_ack &&
			pPioXfer[pPmpCur])
		 begin
		    state_ns = PIO_Update;
		 end
	       else if (dcr2port_PxFBS_EN && 
			ctba2port_UpdateBC_ack)
		 begin
		    state_ns = FB_Idle;
		 end
	       else if (ctba2port_UpdateBC_ack)
		 begin
		    state_ns = P_Idle;
		 end
	    end // case: DR_UpdateByteCount1
	  RegFis_Entry:
	    begin
	       if (ififo2port_fo_ack &&
		   dcr2port_PxTFD_SYS_ERR == 1'b1)
		 begin
		    state_ns = ERR_FatalTaskFile;
		 end
	       else if (dcr2port_PxTFD_SYS_DRQ == 1'b0 &&
			dcr2port_PxTFD_STS_BSY == 1'b0 && 
		        ififo2port_fo_ack)
		 begin
		    state_ns = RegFis_ClearCI;
		 end
	       else if (ififo2port_fo_ack)
		 begin
		    state_ns = RegFis_UpdateSig;
		 end
	    end // case: RegFis_Entry
	  RegFis_ClearCI:
	    begin
	       if (ififo2port_fis_hdr[14] && 
		   dcr2port_PxCI_ack) // Ibit
		 begin
		    state_ns = RegFis_SetIntr;
		 end
	       else if (dcr2port_PxCI_ack)
		 begin
		    state_ns = RegFis_UpdateSig;		    
		 end
	    end // case: RegFis_ClearCI
	  RegFis_SetIntr:
	    begin
	       if (PxIE[0])
		 begin
		    state_ns = RegFis_SetIs;
		 end
	       else
		 begin
		    state_ns = RegFis_UpdateSig;		    		    
		 end
	    end // case: RegFis_SetIntr
	  RegFis_SetIs:
	    begin
	       if (ghc2port_ie)
		 begin
		    state_ns = RegFis_GenIntr;
		 end
	       else
		 begin
		    state_ns = RegFis_UpdateSig;		    		    		    
		 end
	    end // case: RegFis_SetIs
	  RegFis_GenIntr:
	    begin
	       state_ns = RegFis_UpdateSig;
	    end
	  RegFis_UpdateSig:
	    begin
	       if (pUpdateSig == 1'b1)
		 begin
		    state_ns = RegFis_SetSig;
		 end
	       else
		 begin
		    state_ns = PM_Aggr;
		 end
	    end // case: RegFis_UpdateSig
	  RegFis_SetSig:
	    begin
	       state_ns = PM_Aggr;
	    end
	  DX_Entry:
	    begin
	       if (cache2port_ack)
		 begin
		    state_ns = DX_Entry1;
		 end
	    end
	  DX_Entry1:
	    begin
	       if (cache2ctba_PRDTL == 16'h0 &&
		   pPioXfer[pPmpCur] == 1'b1)
		 begin
		    state_ns = PIO_Update;
		 end
	       else if (cache2ctba_PRDTL == 16'h0 &&
			pPioXfer[pPmpCur] == 1'b0 &&
			dcr2port_PxFBS_EN == 1'b1)
		 begin
		    state_ns = FB_Idle;
		 end
	       else if (cache2ctba_PRDTL == 16'h0 &&
			pPioXfer[pPmpCur] == 1'b0)
		 begin
		    state_ns = P_Idle;
		 end
	       else
		 begin
		    state_ns = DX_Transmit;
		 end
	    end // case: DX_Entry
	  DX_Transmit:
	    begin
	       state_ns = DX_Transmit2;
	    end
	  DX_Transmit2:
	    begin
	       if (txdma2port_ack)
		 begin
		    state_ns = DX_Transmit3;
		 end
	    end
	  DX_Transmit3:
	    begin
	       if (txdma2port_sts == C_SYNC &&
		   ctrl_src_rdy_n == 1'b1)
		 begin
		    state_ns = ERR_SyncEscapeRecv;
		 end
	       else if (txdma2port_sts == C_R_ERR &&
			dcr2port_PxFBS_EN == 1'b1 &&
			ctrl_src_rdy_n == 1'b1)
		 begin
		    state_ns = ERR_NotFatal;
		 end
	       else if (txdma2port_sts != C_R_OK &&
			ctrl_src_rdy_n == 1'b1)
		 begin
		    state_ns = ERR_Fatal;
		 end
	       else if (txdma2port_sts == C_R_OK &&
			ctrl_src_rdy_n == 1'b1)
		 begin
		    state_ns = DX_UpdateByteCount;		    
		 end
	    end // case: DX_Transmit
	  DX_UpdateByteCount:
	    begin
	       if (cache2port_ack) begin
		  state_ns = DX_UpdateByteCount1;
	       end
	    end
	  DX_UpdateByteCount1:
	    begin
	       if (ctba2port_UpdateBC_ack &&
		   pPrdIntr[pPmpCur])
		 begin
		    state_ns = DX_PrdSetIntr;
		 end
	       else if (ctba2port_UpdateBC_ack &&
			 pPioXfer[pPmpCur])
		 begin
		    state_ns = PIO_Update;
		 end
	       else if (dcr2port_PxFBS_EN && ctba2port_UpdateBC_ack)
		 begin
		    state_ns = FB_Idle;		    
		 end
	       else if (ctba2port_UpdateBC_ack)
		 begin
		    state_ns = P_Idle;
		 end
	    end // case: DX_UpdateByteCount1
	  DX_PrdSetIntr:
	    begin
	       if (PxIE[5])
		 begin
		    state_ns = DX_PrdSetIs;
		 end
	       else if (pPioXfer[pPmpCur])
		 begin
		    state_ns = PIO_Update;
		 end
	       else if (dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else
		 begin
		    state_ns = P_Idle;		    
		 end
	    end // case: DX_PrdSetIntr
	  DX_PrdSetIs:
	    begin
	       if (ghc2port_ie)
		 begin
		    state_ns = DX_PrdGentIntr;
		 end
	       else if (pPioXfer[pPmpCur])
		 begin
		    state_ns = PIO_Update;
		 end
	       else if (dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else
		 begin
		    state_ns = P_Idle;
		 end
	    end // case: DX_PrdSetIs
	  DX_PrdGentIntr:
	    begin
	       if (pPioXfer[pPmpCur])
		 begin
		    state_ns = PIO_Update;
		 end
	       else if (dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else
		 begin
		    state_ns = P_Idle;
		 end
	    end // case: DX_PrdGentIntr
	  DmaSet_Entry:
	    begin
	       if (ififo2port_fo_ack &&
		   ififo2port_fis_hdr[14]) // Ibit
		 begin
		    state_ns = DmaSet_SetIntr;
		 end
	       else if (ififo2port_fo_ack)
		 begin
		    state_ns = DmaSet_AutoActivate;
		 end
	    end // case: DmaSet_Entry
	  DmaSet_SetIntr:
	    begin
	       if (PxIE[2])	// DSE
		 begin
		    state_ns = DmaSet_SetIs;
		 end
	       else
		 begin
		    state_ns = DmaSet_AutoActivate;
		 end
	    end // case: DmaSet_SetIntr
	  DmaSet_SetIs:
	    begin
	       if (ghc2port_ie)
		 begin
		    state_ns = DmaSet_GenIntr;
		 end
	       else
		 begin
		    state_ns = DmaSet_AutoActivate;
		 end
	    end // case: DmaSet_SetIs
	  DmaSet_GenIntr:
	    begin
	       state_ns = DmaSet_AutoActivate;	       
	    end
	  DmaSet_AutoActivate:
	    begin
	       if (ififo2port_fis_hdr[15]) // Abit
		 begin
		    state_ns = DmaSet_AutoActivate1;
		 end
	       else if (dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else
		 begin
		    state_ns = P_Idle;		    
		 end
	    end // case: DmaSet_AutoActivate
	  DmaSet_AutoActivate1:
	    begin
	       if (cache2port_ack)
		 begin
		    state_ns = DmaSet_AutoActivate2;
		 end
	    end
	  DmaSet_AutoActivate2:
	    begin
	       if (cache2ctba_W)
		 begin
		    state_ns = DX_Entry;
		 end
	       else if (dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else
		 begin
		    state_ns = P_Idle;		    
		 end
	    end // case: DmaSet_AutoActivate1
	  SDB_Entry:
	    begin
	       if (ififo2port_fo_ack)
		 begin
		    state_ns = SDB_Entry1;
		 end
	    end
	  SDB_Entry1:
	    begin
	       if (dcr2port_PxSACT_ack &&
		   dcr2port_PxTFD_SYS_ERR)
		 begin
		    state_ns = ERR_FatalTaskFile;
		 end
	       else if (dcr2port_PxSACT_ack &&
			ghc2port_cap[29] &&
			ififo2port_fis_hdr[15]) // Nbit
		 begin
		    state_ns = SDB_Notification;
		 end
	       else if (dcr2port_PxSACT_ack &&
			ififo2port_fis_hdr[14]) // Ibit
		 begin
		    state_ns = SDB_SetIntr;
		 end
	       else if (dcr2port_PxSACT_ack)
		 begin
		    state_ns = PM_Aggr;
		 end
	    end // case: SDB_Entry
	  SDB_Notification:
	    begin		// TODO
	       state_ns = SDB_SetIntr;
	    end
	  SDB_SetIntr:
	    begin
	       if (PxIE[3])
		 begin
		    state_ns = SDB_SetIs;
		 end
	       else if (pSActive == 32'h0 &&
			dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else if (pSActive == 32'h0)
		 begin
		    state_ns = P_Idle;
		 end
	       else
		 begin
		    state_ns = PM_Aggr;
		 end
	    end // case: SDB_SetIntr
	  SDB_SetIs:
	    begin
	       if (ghc2port_ie)
		 begin
		    state_ns = SDB_GenIntr;
		 end
	       else if (pSActive == 32'h0 &&
			dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else if (pSActive == 32'h0)
		 begin
		    state_ns = P_Idle;		    
		 end
	       else
		 begin
		    state_ns = PM_Aggr;
		 end
	    end // case: SDB_SetIs
	  SDB_GenIntr:
	    begin
	       if (pSActive == 32'h0 &&
		   dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else if (pSActive == 32'h0)
		 begin
		    state_ns = P_Idle;		    
		 end
	       else
		 begin
		    state_ns = PM_Aggr;
		 end	       
	    end // case: SDB_GenIntr
	  ERR_IPMS:
	    begin
	       state_ns = ERR_NotFatal;
	    end
	  ERR_SyncEscapeRecv:
	    begin
	       state_ns = ERR_Fatal;
	    end
	  ERR_SyncEscapeRecvFbNd:
	    begin
	       state_ns = FB_SingleDeviceErr;
	    end
	  ERR_Fatal:
	    begin
	       if (dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_SingleDeviceErr;
		 end
	       else
		 begin
		    state_ns = ERR_WaitForCLear;
		 end
	    end // case: ERR_Fatal
	  ERR_NotFatal:
	    begin
	       if (dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_Idle;
		 end
	       else
		 begin
		    state_ns = P_Idle;
		 end
	    end
	  ERR_FatalTaskFile:
	    begin
	       if (dcr2port_PxFBS_EN)
		 begin
		    state_ns = FB_SingleDeviceErr;
		 end
	       else
		 begin
		    state_ns = ERR_WaitForCLear;
		 end
	    end
	  ERR_WaitForCLear:
	    begin
	       if (dcr2port_PxCMD_ST == 1'b0)
		 begin
		    state_ns = P_Idle;
		 end
	    end
	endcase // case (state)
     end // always @ (*)
   assign port2ghc_intr_req[0] = state == P_ComInitGenIntr;
   assign port2ghc_intr_req[1] = state == PIO_GenIntr;
   assign port2ghc_intr_req[2] = state == RegFis_GenIntr;
   assign port2ghc_intr_req[3] = state == DX_PrdGentIntr;
   assign port2ghc_intr_req[4] = state == DmaSet_GenIntr;
   assign port2ghc_intr_req[5] = state == SDB_GenIntr;
   assign port2ghc_intr_req[6] = state == UFIS_GenIntr;
   assign port2ghc_intr_req[15:7] = 0;

   assign port2ghc_ips_set[0]  = state == P_ComInitSetIs;
   assign port2ghc_ips_set[1]  = state == PIO_SetIs;
   assign port2ghc_ips_set[2]  = state == RegFis_SetIs;
   assign port2ghc_ips_set[3]  = state == DX_PrdSetIs;
   assign port2ghc_ips_set[4]  = state == DmaSet_SetIs;
   assign port2ghc_ips_set[5]  = state == SDB_SetIs;
   assign port2ghc_ips_set[6]  = state == UFIS_SetIs;
   assign port2ghc_ips_set[7]  = PxIE[6]  && port2dcr_PxIS[6];
   assign port2ghc_ips_set[8]  = PxIE[22] && port2dcr_PxSERR[16];
   assign port2ghc_ips_set[9]  = PxIE[23] && port2dcr_PxIS[23];
   assign port2ghc_ips_set[10] = PxIE[24] && port2dcr_PxIS[24];
   assign port2ghc_ips_set[11] = PxIE[26] && port2dcr_PxIS[11];
   assign port2ghc_ips_set[12] = PxIE[27] && port2dcr_PxIS[27];
   assign port2ghc_ips_set[13] = PxIE[30] && port2dcr_PxIS[30];
   assign port2ghc_ips_set[14] = 1'b0;
   assign port2ghc_ips_set[15] = 1'b0;
   /**********************************************************************/
   always @(posedge sys_clk)
     begin
	if (sys_rst ||
	    state == P_Init ||
            state == CFIS_SyncEscape)
	  begin
	     pUpdateSig <= #1 1'b1;
	  end
	else if (state == P_RegFisUpdate ||
	         state == RegFis_SetSig)
	  begin
	     pUpdateSig <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)

   always @(posedge sys_clk)
     begin
	if (sys_rst ||
	    state == P_Init)
	  begin
	     pDevIssue <= #1 5'h0;
	  end
	else if (state == P_SelectCmd && PxCI[pSlotLoc] == 1'b0)
	  begin
	     pDevIssue <= #1 5'h0;
	  end
	else if (state == FB_SelectDevice &&
		 ~(pBsy[pDevIssue] == 1'b0 &&
		   pDrq[pDevIssue] == 1'b0))
	  begin
	     pDevIssue <= #1 pDevIssue + 1'b1;
	  end
     end

   always @(posedge sys_clk)
     begin
	if (sys_rst ||
	    state == P_Init)
	  begin
	     pPmpCur <= #1 5'h0;
	  end
	else if (state == NDR_PmCheck && dcr2port_PxFBS_EN)
	  begin
	     pPmpCur <= #1 ififo2port_fis_hdr[11:8];
	  end
	else if (state == DR_Entry && dcr2port_PxFBS_EN)
	  begin
	     pPmpCur <= #1 rxll2port_fis_hdr[11:8];
	  end
     end // always @ (posedge sys_clk)

   always @(posedge sys_clk)
     begin
	if (sys_rst ||
	    state == P_Init)
	  begin
	     pPMP <= #1 5'h0;
	  end
	else if (state == CFIS_Xmit ||
		 state == DX_Entry)
	  begin
	     pPMP <= #1 cache2ctba_PMP;
	  end
     end // always @ (posedge sys_clk)

   always @(posedge sys_clk)
     begin
	if (sys_rst ||
	    state == P_Init)
	  begin
	     pPioEsts <= #1 8'h0;
	  end
	else if (state == PIO_Entry)
	  begin
	     pPioEsts <= #1 ififo2port_Estatus;
	  end
     end

   always @(posedge sys_clk)
     begin
	if (sys_rst ||
	    state == P_Init)
	  begin
	     pPioErr <= #1 8'h0;
	  end
	else if (state == PIO_Entry)
	  begin
	     pPioErr <= #1 ififo2port_fis_hdr[31:24];
	  end
     end
   always @(posedge sys_clk)
     begin
	if (sys_rst ||
	    state == P_Init)
	  begin
	     pPiolbit <= #1 1'b0;
	  end
	else if (state == PIO_Entry)
	  begin
	     pPiolbit <= #1 ififo2port_fis_hdr[14]; //Ibit
	  end
     end
   always @(posedge sys_clk)
     begin
	if (sys_rst ||
	    state == P_Init)
	  begin
	     pXferAtapi <= #1 1'b0;
	  end
	else if (state == CFIS_Xmit)
	  begin
	     pXferAtapi <= #1 cache2ctba_A;	     
	  end
     end
   always @(posedge sys_clk)
     begin
	if (sys_rst ||
	    state == P_Init)
	  begin
	     pCmdToIssue <= #1 6'h0;
	  end
	else if (state == P_FetchCmd || state == FB_FetchCmd)
	  begin
	     pCmdToIssue <= #1 1'b1;
	  end
	else if (state == CFIS_Success)
	  begin
	     pCmdToIssue <= #1 1'b0;
	  end
     end
   always @(posedge sys_clk)
     begin
	if (sys_rst ||
	    state == P_Init)
	  begin
	     pSActive <= #1 32'h0;
	  end
	else if (state == SDB_Entry && ififo2port_fo_ack)
	  begin
	     pSActive <= #1 ififo2port_SDB_SActive;
	  end
     end
   always @(posedge sys_clk)
     begin
	if (sys_rst ||
	    state == P_Init)
	  begin
	     pSlotLoc <= #1 6'h0;
	  end
	else if ((state == P_SelectCmd ||
		  state == FB_SelectCmd) &&
		 PxCI[pSlotLoc] == 1'b0)
	  begin
	     pSlotLoc <= #1 pSlotLoc + 1'b1;	     
	  end
     end   
   
   genvar i;
   generate
      for (i = 0; i < C_PM; i = i + 1) 
	begin: Array_reg
	   always @(posedge sys_clk)
	     begin
		if (sys_rst ||
		    state == P_Init)
		  begin
		     pBsy[i] <= #1 1'b0;
		  end
		else if (((i == ififo2port_fis_hdr[11:8] && dcr2port_PxFBS_EN) ||
			 ((i == 0 && ~dcr2port_PxFBS_EN)))&& 
			 (state == P_RegFisPostToMem ||
			  state == RegFis_Entry))
		  begin
		     pBsy[i] <= #1 ififo2port_fis_hdr[23];
		  end
		else if (((i == pDevIssue && dcr2port_PxFBS_EN) ||
			 ((i == 0 && ~dcr2port_PxFBS_EN))) &&
			state == CFIS_Xmit)
		  begin
		     pBsy[i] <= #1 1'b1;
		  end
		else if (((i == pDevIssue && dcr2port_PxFBS_EN) ||
			 ((i == 0 && ~dcr2port_PxFBS_EN))) &&
			state == CFIS_ClearCI)
		  begin
		     pBsy[i] <= #1 1'b0;		     
		  end
		else if (((i == ififo2port_fis_hdr[11:8] && dcr2port_PxFBS_EN) ||
			 ((i == 0 && ~dcr2port_PxFBS_EN))) &&
			 state == PIO_Entry)
		  begin
		     pBsy[i] <= #1 ififo2port_fis_hdr[23];
		  end
		else if (((i == pPmpCur && dcr2port_PxFBS_EN) ||
			 ((i == 0 && ~dcr2port_PxFBS_EN))) &&
			state == PIO_Update)
		  begin
		     pBsy[i] <= #1 pPioEsts[7];		     
		  end
		else if ((i == port2dcr_PxFBS_DWE && state == FB_SDE_Cleanup) ||
			 (i == 0 && state == ERR_SyncEscapeRecv))
		  begin
		     pBsy[i] <= #1 1'b0;
		  end
	     end
	   always @(posedge sys_clk)
	     begin
		if (sys_rst ||
		    state == P_Init)
		  begin
		     pDrq[i] <= #1 1'b1;
		  end
		else if (((i == ififo2port_fis_hdr[11:8] && dcr2port_PxFBS_EN) ||
			 (i == 0 && ~dcr2port_PxFBS_EN)) &&
			 (state == P_RegFisPostToMem ||
			  state == RegFis_Entry))
		  begin
		     pDrq[i] <= #1 ififo2port_fis_hdr[19];
		  end
		else if (((i == ififo2port_fis_hdr[11:8] && dcr2port_PxFBS_EN) ||
			  (i == 0 && ~dcr2port_PxFBS_EN)) &&
			 state == PIO_Entry)
		  begin
		     pDrq[i] <= #1 ififo2port_fis_hdr[19];		     
		  end
		else if (((i == pPmpCur && dcr2port_PxFBS_EN) ||
			 ((i == 0 && ~dcr2port_PxFBS_EN))) &&
			 state == PIO_Update)
		  begin
		     pDrq[i] <= #1 pPioEsts[3];
		  end
		else if ((i == port2dcr_PxFBS_DWE && state == FB_SDE_Cleanup) ||
			 (i == 0 && state == ERR_SyncEscapeRecv))
		  begin
		     pDrq[i] <= #1 1'b0;		     
		  end		
	     end // always @ (posedge sys_clk)
	   always @(posedge sys_clk)
	     begin
		if (sys_rst ||
		    state == P_Init)
		  begin
		     pDataSlot[i] <= #1 6'h0;
		  end
		else if (state == CFIS_Xmit && 
			 ((i == pDevIssue && dcr2port_PxFBS_EN) ||
		          (i == 0 && ~dcr2port_PxFBS_EN)))
		  begin
		     pDataSlot[i] <= #1 pIssueSlot[i];
		  end
		else if (state == DmaSet_Entry && 
			 ((i == pPmpCur && dcr2port_PxFBS_EN) ||
			  (i == 0 && ~dcr2port_PxFBS_EN)))
		  begin
		     pDataSlot[i] <= #1 ififo2port_DS_TAG;		     
		  end
	     end
	   always @(posedge sys_clk)
	     begin
		if (sys_rst ||
		    state == P_Init)
		  begin
		     pIssueSlot[i] <= #1 6'd32;
		  end
		else if (i == 0 && state == P_FetchCmd)
		  begin
		     pIssueSlot[i] <= #1 pSlotLoc;
		  end
		else if (i == pDevIssue && state == FB_FetchCmd)
		  begin
		     pIssueSlot[i] <= #1 pSlotLoc;
		  end
		else if (((i == pPmpCur && dcr2port_PxFBS_EN) ||
			  (i == 0 && ~dcr2port_PxFBS_EN)) &&
			 (state == PIO_ClearCI ||
			  state == RegFis_ClearCI ||
		          state == CFIS_ClearCI ||
		          state == ERR_WaitForCLear))
		  begin
		     pIssueSlot[i] <= #1 6'd32;
		  end
	     end
	   always @(posedge sys_clk)
	     begin
		if (sys_rst ||
		    state == P_Init)
		  begin
		     pPioXfer[i] <= #1 1'b0;
		  end
		else if (state == PIO_Entry && 
			 ((i == pPmpCur && dcr2port_PxFBS_EN) ||
		          (i == 0 && ~dcr2port_PxFBS_EN)))
		  begin
		     pPioXfer[i] <= #1 1'b1;		     
		  end
		else if (state == PIO_Update && 
			 ((i == pPmpCur && dcr2port_PxFBS_EN) ||
			  (i == 0 && ~dcr2port_PxFBS_EN)))
		  begin
		     pPioXfer[i] <= #1 1'b0;		     		     
		  end
	     end
	   always @(posedge sys_clk)
	     begin
		if (sys_rst ||
		    state == P_Init)
		  begin
		     pPrdIntr[i] <= #1 1'b0;
		  end
		else if ((state == DX_Entry ||
			  state == DX_PrdSetIs) && 
			 i == pPmpCur)
		  begin
		     pPrdIntr[i] <= #1 1'b0;	     
		  end
	     end // always @ (posedge sys_clk)
	   always @(posedge sys_clk)
	     begin
		if (pBsy[i] == 1'b0 &&
		    pDrq[i] == 1'b0)
		  begin
		     pBsy_pDrq[i] <= #1 1'b0;
		  end
		else
		  begin
		     pBsy_pDrq[i] <= #1 1'b1;		     
		  end
	     end // always @ (posedge sys_clk)
	   always @(posedge sys_clk)
	     begin
		if (sys_rst ||
		    state == P_Init ||
		    state == P_StartBitCleared ||
		    (state == CFIS_Xmit && 
		     ((i == pDevIssue && dcr2port_PxFBS_EN) ||
	              (i == 0 && ~dcr2port_PxFBS_EN))) ||
		    (state == SDB_Entry && 
		     ((i == pPmpCur && dcr2port_PxFBS_EN) ||
	              (i == 0 && ~dcr2port_PxFBS_EN))))
		  begin
		     pDmaXferCnt[i] <= #1 32'h0; 
		  end
		else if (state == PIO_Entry && 
			((i == pPmpCur && dcr2port_PxFBS_EN) ||
		         (i == 0 && ~dcr2port_PxFBS_EN)))
		  begin
		     pDmaXferCnt[i] <= #1 ififo2port_Transfer_Count[15:2];
		  end
		else if (state == DmaSet_Entry && 
			((i == pPmpCur && dcr2port_PxFBS_EN) ||
			 (i == 0 && ~dcr2port_PxFBS_EN)))
		  begin
		     pDmaXferCnt[i] <= #1 ififo2port_DS_Count[31:2];
		  end
		else if (port2cache_PRDBC_incr && pDmaXferCnt[i] != 32'h0 && 
			((i == pPmpCur && dcr2port_PxFBS_EN) ||
		         (i == 0 && ~dcr2port_PxFBS_EN)))
		  begin
		     pDmaXferCnt[i] <= #1 pDmaXferCnt[i] - 1'b1;
		  end
	     end
	end // block: Array_reg
   endgenerate
   /**********************************************************************/
   reg [5:0] pDataSlot_pFisPm;
   wire [3:0] fis_pm;
   assign fis_pm = dcr2port_PxFBS_EN ? rxll2port_fis_hdr[11:8] : 4'h0;
   always @(posedge sys_clk)
     begin
	PxCMD_POD  <= #1 dcr2port_PxCMD_POD;
	PxSCTL_DET <= #1 dcr2port_PxSCTL_DET;
	PxCMD_SUD  <= #1 dcr2port_PxCMD_SUD;
	PxCMD_FRE  <= #1 dcr2port_PxCMD_FRE;
	PxCMD_ST   <= #1 dcr2port_PxCMD_ST;
	pIssueSlot_pDevIssue  <= #1 pIssueSlot[pDevIssue];
	pIssueSlot_pPmpCur    <= #1 pIssueSlot[pPmpCur];
	pIssueSlot_0          <= #1 pIssueSlot[0];
	pDataSlot_pDevIssue   <= #1 pDataSlot[pDevIssue];
	pDataSlot_pPmpCur     <= #1 pDataSlot[pPmpCur];
	pDataSlot_pFisPm      <= #1 pDataSlot[fis_pm];
	pDmaXferCnt_0         <= #1 pDmaXferCnt[0];
	pDmaXferCnt_pDevIssue <= #1 pDmaXferCnt[pDevIssue];
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (state == P_Init)
	  begin
	     port2dcr_PxTFD_STS_we <= #1 1'b1;
	     port2dcr_PxTFD_STS    <= #1 8'h7f;
	  end
	else if ((state == P_RegFisPostToMem ||
		  state == RegFis_Entry ||
		  state == SDB_Entry))
	  begin
	     port2dcr_PxTFD_STS_we <= #1 1'b1;
	     port2dcr_PxTFD_STS    <= #1 ififo2port_fis_hdr[23:16];
	     port2dcr_PxTFD_ERR_we <= #1 1'b1;
	     port2dcr_PxTFD_ERR    <= #1 ififo2port_fis_hdr[31:24];
	  end
	else if (state == CFIS_Xmit)
	  begin
	     port2dcr_PxTFD_STS_we <= #1 1'b1;
	     port2dcr_PxTFD_STS    <= #1 {1'b1, port2dcr_PxTFD_STS[6:0]}; // Set BSY
	  end
	else if (state == CFIS_ClearCI)
	  begin
	     port2dcr_PxTFD_STS_we <= #1 1'b1;
	     port2dcr_PxTFD_STS[7] <= #1 1'b0; // Clear BSY	     
	  end
	else if (state == ERR_SyncEscapeRecv)
	  begin
	     port2dcr_PxTFD_STS_we <= #1 1'b1;
	     port2dcr_PxTFD_STS[7] <= #1 1'b0; // Clear BSY
	     port2dcr_PxTFD_STS[3] <= #1 1'b0; // clear DRQ
	  end
	else if (state == PIO_Entry)
	  begin
	     port2dcr_PxTFD_STS_we <= #1 1'b1;
	     port2dcr_PxTFD_STS    <= #1 ififo2port_fis_hdr[23:16];
	  end
	else if (state == PIO_Update)
	  begin
	     port2dcr_PxTFD_STS_we <= #1 1'b1;
	     port2dcr_PxTFD_STS    <= #1 pPioEsts;
	     port2dcr_PxTFD_ERR_we <= #1 1'b1;
	     port2dcr_PxTFD_ERR    <= #1 pPioErr;	     
	  end
	else
	  begin
	     port2dcr_PxTFD_STS_we <= #1 1'b0;
	     port2dcr_PxTFD_ERR_we <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (state == P_FetchCmd)
	  begin
	     port2dcr_PxCMD_CCS    <= #1 pSlotLoc;
	     port2dcr_PxCMD_CCS_we <= #1 1'b1;
	  end
	else if (state == P_StartBitCleared)
	  begin
	     port2dcr_PxCMD_CCS    <= #1 1'b0;
	     port2dcr_PxCMD_CCS_we <= #1 1'b1;	     
	  end
	else
	  begin
	     port2dcr_PxCMD_CCS_we <= #1 1'b0;	     
	  end
     end
   always @(posedge sys_clk)
     begin
	if (state == P_RegFisUpdate ||
	    state == RegFis_SetSig)
	  begin
	     port2dcr_PxSIG_we <= #1 pUpdateSig;
	  end
	else
	  begin
	     port2dcr_PxSIG_we <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if ((state == CFIS_ClearCI ||
	     state == PIO_ClearCI ||
	     state == RegFis_ClearCI) &&
	    ~dcr2port_PxCI_ack)
	  begin
	     port2dcr_PxCI_clear <= #1 1'b1;
	     port2dcr_PxCI       <= #1 pIssueSlot_pDevIssue;
	  end
	else
	  begin
	     port2dcr_PxCI_clear <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (0)
	  begin			// Cold port detect status
	     port2dcr_PxIS[31] <= #1 1'b1;
	     port2dcr_PxIS_set <= #1 1'b1;
	  end
	else if (state == ERR_FatalTaskFile)
	  begin			// Task File error 
	     port2dcr_PxIS[30] <= #1 1'b1;
	     port2dcr_PxIS_set <= #1 1'b1;	     	     	     	     
	  end
	else if (0)
	  begin			// Host bus fatal error
	     port2dcr_PxIS[29] <= #1 1'b1;
	     port2dcr_PxIS_set <= #1 1'b1;	     	     	     	     	     
	  end
	else if (0)
	  begin			// Host bus data error
	     port2dcr_PxIS[28] <= #1 1'b1;
	     port2dcr_PxIS_set <= #1 1'b1;	     	     	     	     	     
	  end
	else if (state == ERR_SyncEscapeRecv ||
		 state == ERR_Fatal)
	  begin			// Interface fatal error
	     port2dcr_PxIS[27] <= #1 1'b1;
	     port2dcr_PxIS_set <= #1 1'b1;	     	     	     
	  end
	else if (state == ERR_SyncEscapeRecvFbNd ||
		 state == ERR_NotFatal)
	  begin			// Interface non-fatal error
	     port2dcr_PxIS[26] <= #1 1'b1;
	     port2dcr_PxIS_set <= #1 1'b1;	     	     
	  end
	else if (0)
	  begin			// OverFlow status
	     port2dcr_PxIS[24] <= #1 1'b1;
	     port2dcr_PxIS_set <= #1 1'b1;	     	     
	  end
	else if (state == ERR_IPMS)
	  begin
	     port2dcr_PxIS[23] <= #1 1'b1;
	     port2dcr_PxIS_set <= #1 1'b1;	     	     	     
	  end
	// 22 in dcr
	else if (0)
	  begin			// Device Mechanical presence status
	     port2dcr_PxIS[7]  <= #1 1'b1;
	     port2dcr_PxIS_set <= #1 1'b1;	     	     	     	     
	  end
	// 6 in dcr
	else if (0)
	  begin			// DPS
	     port2dcr_PxIS[5]  <= #1 1'b1;
	     port2dcr_PxIS_set <= #1 1'b1;	     	     	     	     	     
	  end
	else if (state == UFIS_Entry)
	  begin
	     port2dcr_PxIS[4]  <= #1 1'b1;
	     port2dcr_PxIS_set <= #1 1'b1;	     
	  end
	else if (state == SDB_SetIntr)
	  begin
	     port2dcr_PxIS[3]  <= #1 1'b1;
	     port2dcr_PxIS_set <= #1 1'b1;	     	     
	  end
	else if (state == DmaSet_SetIntr)
	  begin
	     port2dcr_PxIS[2]  <= #1 1'b1;
	     port2dcr_PxIS_set <= #1 1'b1;	     	     	     
	  end
	else if (state == PIO_SetIntr)
	  begin
	     port2dcr_PxIS[1]  <= #1 1'b1;
	     port2dcr_PxIS_set <= #1 1'b1;
	  end
	else if (state == RegFis_SetIntr)
	  begin
	     port2dcr_PxIS[0]  <= #1 1'b1;
	     port2dcr_PxIS_set <= #1 1'b1;
	  end
	else if (dcr2port_PxIS_ack)
	  begin
	     port2dcr_PxIS     <= #1 32'h0;
	     port2dcr_PxIS_set <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)
   
   always @(posedge sys_clk)
     begin
	if (state == SDB_Entry1 && ~dcr2port_PxSACT_ack)
	  begin
	     port2dcr_PxSACT_clear <= #1 1'b1;
	  end
	else
	  begin
	     port2dcr_PxSACT_clear <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)
   
   reg FB_SingleDeviceErr_reg;
   always @(posedge sys_clk)
     begin
	if (state == FB_Idle)
	  begin
	     FB_SingleDeviceErr_reg<= #1 1'b0;
	  end
	else if (state == FB_SingleDeviceErr && 
		 ~FB_SingleDeviceErr_reg)
	  begin
	     FB_SingleDeviceErr_reg<= #1 1'b1;
	     port2dcr_PxFBS_DWE    <= #1 pDevIssue;
	     port2dcr_PxFBS_DWE_set<= #1 1'b1;
	  end
	else
	  begin
	     port2dcr_PxFBS_DWE_set<= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (state == FB_SDE_Cleanup)
	  begin
	     port2dcr_PxFBS_DWE_clear <= #1 1'b1;
	  end
	else
	  begin
	     port2dcr_PxFBS_DWE_clear <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   reg linkup_reg;
   always @(posedge sys_clk)
     begin
	linkup_reg <= #1 linkup;
     end
   localparam [4:0]
     C_DIAG_F = 5'd25,
     C_DIAG_T = 5'd24,
     C_DIAG_S = 5'd23,
     C_DIAG_H = 5'd22,
     C_DIAG_C = 5'd21,
     C_DIAG_D = 5'd20,
     C_DIAG_B = 5'd19,
     C_DIAG_W = 5'h18,
     C_DIAG_I = 5'h17,
     C_DIAG_N = 5'd16,
     C_ERR_E  = 5'd11,
     C_ERR_P  = 5'd10,
     C_ERR_C  = 5'd9,
     C_ERR_T  = 5'd8,
     C_ERR_M  = 5'd1,
     C_ERR_I  = 5'd0;
   always @(posedge sys_clk)
     begin
	if (state == P_Init)
	  begin
	     port2dcr_PxSERR[31:16]    <= #1 16'h0;
	     port2dcr_PxSERR_DIAG_set  <= #1 1'b0;
	  end
	else if (state == UFIS_Entry)
	  begin			// DIAG F: UFIS
	     port2dcr_PxSERR[C_DIAG_F] <= #1 1'b1;
	     port2dcr_PxSERR_DIAG_set  <= #1 1'b1;	     
	  end
	else if (0)
	  begin			// DIAG T: Transport state transition error
	     port2dcr_PxSERR[C_DIAG_T] <= #1 1'b1;
	     port2dcr_PxSERR_DIAG_set  <= #1 1'b1;
	  end
	else if (0)
	  begin			// DIAG S: Link state transition error
	     port2dcr_PxSERR[C_DIAG_S] <= #1 1'b1;
	     port2dcr_PxSERR_DIAG_set  <= #1 1'b1;
	  end
	else if ((state == CFIS_Xmit_Wait &&
		  ctrl_src_rdy_n == 1'b0 &&
		  ctrl_data == C_R_ERR) ||
		 (state == DX_Transmit2 &&
		  txdma2port_ack &&
		  txdma2port_sts == C_R_ERR))
	  begin			// DIAG H: R_ERR
	     port2dcr_PxSERR[C_DIAG_H] <= #1 1'b1;
	     port2dcr_PxSERR_DIAG_set  <= #1 1'b1;	     	     	     
	  end
	else if (state == NDR_ERR_NotFatal)
	  begin			// DIAG C: CRC
	     port2dcr_PxSERR[C_DIAG_C] <= #1 1'b1;
	     port2dcr_PxSERR_DIAG_set  <= #1 1'b1;	     	     
	  end
	else if (0)
	  begin			// DIAG B: 10B 8B
	     port2dcr_PxSERR[C_DIAG_B] <= #1 1'b1;
	     port2dcr_PxSERR_DIAG_set  <= #1 1'b1;	     	     	     
	  end
	else if (0)
	  begin			// DIAG W: Comm wake
	     port2dcr_PxSERR[C_DIAG_W] <= #1 1'b1;
	     port2dcr_PxSERR_DIAG_set  <= #1 1'b1;	     	     	     
	  end
	else if (0)
	  begin			// DIAG I: Phy internal error
	     port2dcr_PxSERR[C_DIAG_I] <= #1 1'b1;
	     port2dcr_PxSERR_DIAG_set  <= #1 1'b1;	     	     	     
	  end	
	else if (linkup_reg ^ linkup)
	  begin			// DIAG N: PhyRdy changed TODO
	     port2dcr_PxSERR[C_DIAG_N] <= #1 1'b1;
	     port2dcr_PxSERR_DIAG_set  <= #1 1'b1;	     	     	     	     
	  end
	else
	  begin
	     port2dcr_PxSERR[31:16]    <= #1 16'h0;
	     port2dcr_PxSERR_DIAG_set  <= #1 1'b0;	     	     	     	     	     
	  end
     end // always @ (posedge sys_clk)

   always @(posedge sys_clk)
     begin
	if (state == P_Init)
	  begin
	     port2dcr_PxSERR[15:0]   <= #1 16'h0;
	     port2dcr_PxSERR_ERR_set <= #1 1'b0;
	  end
	else if (0)
	  begin			// ERR E: Internal error
	     port2dcr_PxSERR[11]     <= #1 1'b1;
	     port2dcr_PxSERR_ERR_set <= #1 1'b1;	     	     	     	     	     
	  end
	else if (port2dcr_PxSERR_DIAG_set &&
		 (port2dcr_PxSERR[C_DIAG_T] |
		  port2dcr_PxSERR[C_DIAG_F] |
		  port2dcr_PxSERR[C_DIAG_S] |
		  1'b0/* rxfifo overflow */))
	  begin			// ERR P: Protocol error
	     port2dcr_PxSERR[10]     <= #1 1'b1;
	     port2dcr_PxSERR_ERR_set <= #1 1'b1;	     	     	     	     	     
	  end
	else if (0)
	  begin			// ERR C: Persistent commucation error
	     port2dcr_PxSERR[9]      <= #1 1'b1;
	     port2dcr_PxSERR_ERR_set <= #1 1'b1;	     	     	     	     	     
	  end
	else if (port2dcr_PxSERR_DIAG_set &&
		 (port2dcr_PxSERR[C_DIAG_B] |
		  port2dcr_PxSERR[C_DIAG_C] |
		  port2dcr_PxSERR[C_DIAG_D] |
		  port2dcr_PxSERR[C_DIAG_H] |
		  port2dcr_PxSERR[C_DIAG_T] |
		  1'b0/* rxfifo overflow */ |
		  1'b0/* non data fis transmission was not recovered after three retry */))
	  begin			// ERR T: Transient Data integrity error 
	     port2dcr_PxSERR[C_ERR_T]  <= #1 1'b1;
	     port2dcr_PxSERR_ERR_set   <= #1 1'b1;
	  end
	else if (0)
	  begin			// ERR M: Recovered commucation error
	     port2dcr_PxSERR[C_ERR_M]  <= #1 1'b1;
	     port2dcr_PxSERR_ERR_set   <= #1 1'b1;	     	     	     	     	     
	  end
	else if (state == CFIS_Xmit_Wait && 
	         ctrl_src_rdy_n == 1'b0 &&
	         ctrl_data == C_R_ERR)
	  begin			// ERR I: Recovered data integrity error
	     port2dcr_PxSERR[C_ERR_I]  <= #1 1'b1;
	     port2dcr_PxSERR_ERR_set   <= #1 1'b1;	     	     	     	     	     	     
	  end
	else
	  begin
	     port2dcr_PxSERR[15:0]   <= #1 16'h0;	     
	     port2dcr_PxSERR_ERR_set <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if ((state == P_RegFisPostToMem ||
	     state == PIO_Entry ||
	     state == RegFis_Entry ||
	     state == DmaSet_Entry ||
	     state == SDB_Entry ||
	     state == UFIS_Entry ||
	     state == DmaAct_Entry ||
	     state == NDR_ERR_NotFatal ||
	     state == NDR_ERR_Fatal ||
	     state == NDR_ERR_IPMS ||
             state == NDR_Accept_Idle) && 
	    ~ififo2port_fo_ack)
	  begin
	     port2ififo_fo_req <= #1 1'b1;
	  end
	else
	  begin
	     port2ififo_fo_req <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if ((state == P_FetchCmd || 
	     state == FB_FetchCmd) && 
	    ~ctba2port_FetchCmd_ack)
	  begin
	     port2ctba_FetchCmd_req <= #1 1'b1;
	  end
	else
	  begin
	     port2ctba_FetchCmd_req <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)
   assign port2ctba_FetchCmd_addr = {PxCLB[31:10], pSlotLoc, 5'h0};
   assign port2ctba_UpdateBC_addr = {PxCLB[31:10], pDataSlot_pPmpCur[4:0], 5'h0};
   assign port2ctba_FetchCmd_slot = pSlotLoc;
   assign port2cache_PRDBC_incr   = (state == DX_Transmit2 && txll2port_xfer) | 
	                            (state == DR_Receive3  && rxdma2port_xfer);
   assign port2ctba_FetchCFIS_addr= {cache2ctba_CTBA[31:7], 7'h0};
   assign port2ctba_FetchCFIS_len = cache2ctba_CFL;
   assign port2ctba_FetchPRDTL    = cache2ctba_PRDTL;
   assign port2ctba_FetchPRDBC    = cache2ctba_PRDBC;
   assign port2ctba_FetchPRD_cnt  = cache2ctba_PRD_cnt;
   assign port2ctba_FetchPRD_off  = cache2ctba_PRD_off;
   assign port2ctba_FetchPRD_addr = {cache2ctba_CTBA[31:7], 7'h0};
   always @(posedge sys_clk)
     begin
	if (state == CFIS_Xmit_Fetch && ~ctba2port_FetchCFIS_ack)
	  begin
	     port2ctba_FetchCFIS_req <= #1 1'b1;
	  end
	else
	  begin
	     port2ctba_FetchCFIS_req <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (state == DR_Receive3 && ~rxdma2port_ack)
	  begin
	     port2rxdma_req <= #1 1'b1;
	  end
	else
	  begin
	     port2rxdma_req <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if ((state == DR_UpdateByteCount1 ||
	     state == DX_UpdateByteCount1)&& 
	    ~ctba2port_UpdateBC_ack)
	  begin
	     port2ctba_UpdateBC_req <= #1 1'b1;
	  end
	else
	  begin
	     port2ctba_UpdateBC_req <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (state == DX_Transmit2 && ~txdma2port_ack)
	  begin
	     port2txdma_req <= #1 1'b1;
	  end
	else
	  begin
	     port2txdma_req <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if ((state == CFIS_Xmit_Fetch) |
	    (state == CFIS_Xmit_Push && ~txll2port_Push_ack))
	  begin
	     port2txll_Push_req <= #1 1'b1;
	  end
	else
	  begin
	     port2txll_Push_req <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if ((state == CFIS_Xmit_Wait  && ctrl_src_rdy_n == 1'b0 && /* only ack the send information */
	     (ctrl_data == C_R_OK || ctrl_data == C_R_ERR || ctrl_data == C_SYNC)) ||
	    (state == CFIS_Xmit_Abort && ctrl_src_rdy_n == 1'b0 && ctrl_data == C_SRCV) ||
	    (state == DR_Receive4 && ctrl_src_rdy_n == 1'b0) ||
	    (state == DX_Transmit2 && txdma2port_ack))
	  begin
	     ctrl_dst_rdy1 <= #1 1'b1;
	  end
	else
	  begin
	     ctrl_dst_rdy1 <= #1 1'b0;	     
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (state == P_FetchCmd1 ||
	    state == FB_FetchCmd1 &&
	    ~cache2port_ack)
	  begin
	     port2cache_req <= #1 1'b1;
	     port2cache_we  <= #1 1'b0;
	     port2cache_slot<= #1 pSlotLoc;
	  end
	else if (state == CFIS_Xmit &&
		 ~cache2port_ack)
	  begin
	     port2cache_req <= #1 1'b1;
	     port2cache_we  <= #1 1'b0;
	     port2cache_slot<= #1 pIssueSlot_pDevIssue;	     
	  end
	else if (state == DX_Entry)
	  begin
	     port2cache_req <= #1 1'b1;
	     port2cache_we  <= #1 1'b0;
	     port2cache_slot<= #1 pDataSlot_pPmpCur;
	  end
	else if (state == DR_Receive1 &&
		 ~cache2port_ack)
	  begin
	     port2cache_req <= #1 1'b1;
	     port2cache_we  <= #1 1'b0;
	     port2cache_slot<= #1 pDataSlot_pFisPm;	     	     
	  end
	else if (state == DmaSet_AutoActivate1 &&
		 ~cache2port_ack)
	  begin
	     port2cache_req <= #1 1'b1;
	     port2cache_we  <= #1 1'b0;
	     port2cache_slot<= #1 pDataSlot_pPmpCur;	     
	  end
	else if ((state == DR_UpdateByteCount || state == DX_UpdateByteCount) &&
		 ~cache2port_ack)
	  begin
	     port2cache_req <= #1 1'b1;
	     port2cache_we  <= #1 1'b1;
	     port2cache_slot<= #1 pDataSlot_pPmpCur;	     
	  end
	else
	  begin
	     port2cache_we  <= #1 1'b0;
	     port2cache_req <= #1 1'b0;
	     port2cache_slot<= #1 pIssueSlot_pDevIssue;
	  end
     end // always @ (posedge sys_clk)
   assign pDmaXferCnt_ex = {pDmaXferCnt_pDevIssue, 2'b00};
   assign port2txdma_len = pDmaXferCnt_ex > 32'h2000 ? 32'h2000 : pDmaXferCnt_ex;
   always @(posedge sys_clk)
     begin
	if ((state == P_Init && dcr2port_PxCMD_SUD) |
	    (state == P_StartComm))
	  begin
	     StartComm <= #1 1'b1;
	  end
	else
	  begin
	     StartComm <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   // AHCI 9.3.5 Locking the interface
   // 0: DmaActive 
   // 1: PioSetup  with D=0
   // 2: DmaSetup  with A=1
   always @(posedge sys_clk)
     begin
	if (state == P_Init ||
	    state == P_Idle ||
	    state == FB_Idle)
	  begin
	     ctrl_dst_lock <= #1 1'b0;
	  end
	else if (state == DmaAct_Entry ||
		 (state == PIO_Entry &&
		  ififo2port_fis_hdr[13] == 1'b0) || // Dbit
		 (state == DmaSet_Entry && 
		  ififo2port_fis_hdr[15])) // Abit
	  begin
	     ctrl_dst_lock <= #1 dcr2port_PxFBS_EN && PxVS[31];
	  end
     end // always @ (posedge sys_clk)
   // synthesis attribute ASYNC_REG of ctrl_dst_lock is TRUE
   /**********************************************************************/
   assign port2dbg[7:0]  = state;
   assign port2dbg[15]   = sys_rst;
   assign port2dbg[16]   = rxll2port_req;
   assign port2dbg[17]   = ififo2port_empty;
   assign port2dbg[18]   = ctrl_src_rdy_n;
   assign port2dbg[19]   = pCmdToIssue;
   assign port2dbg[23:20]= ctrl_data;
   assign port2dbg[31:24]= pIssueSlot_0;
   assign port2dbg[39:32]= pDataSlot_pPmpCur;
   assign port2dbg[47:40]= pSlotLoc;
   assign port2dbg[48]   = port2ctba_FetchCmd_req;
   assign port2dbg[49]   = ctba2port_FetchCmd_ack;
   assign port2dbg[50]   = port2ctba_FetchCFIS_req;
   assign port2dbg[51]   = ctba2port_FetchCFIS_ack;
   assign port2dbg[52]   = port2ctba_UpdateBC_req;
   assign port2dbg[53]   = ctba2port_UpdateBC_ack;
   assign port2dbg[60:54]= port2cache_slot;
   assign port2dbg[61]   = cache2port_ack;
   assign port2dbg[62]   = port2cache_we;
   assign port2dbg[63]   = port2cache_req;
   assign pBsyDrq[15:0]  = pBsy;
   assign pBsyDrq[31:16] = pDrq;
   assign port_state     = state;
   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     err2dbg        <= #1 32'h0;
	  end
	else if (state == NDR_Entry && 
		 ctrl_src_rdy_n == 1'b0 &&
		 ctrl_data != C_GOOD)
	  begin
	     err2dbg[15:0]  <= #1 state;
	     err2dbg[31:24] <= #1 ctrl_data;	     
	  end
	else if (state == NDR_ERR_Fatal1)
	  begin
	     err2dbg[15:0]  <= #1 state;
	     err2dbg[31:16] <= #1 rxll2port_rxcount;
	  end
	else if (state == NDR_Accept &&
		 (state_ns == P_Idle ||
		  state_ns == UFIS_Entry)) 
	  begin
	     err2dbg[15:0]  <= #1 state;
	     err2dbg[31:16] <= #1 ififo2port_fis_hdr[15:0];
	  end
	else if (state == DR_Receive3 &&
		 rxdma2port_sts != C_R_OK &&
		 rxdma2port_ack)
	  begin
	     err2dbg[15:0]  <= #1 state;
	     err2dbg[31:24] <= #1 ctrl_data;
	     err2dbg[23:16] <= #1 rxdma2port_sts;	     
	  end
	else if (state == DR_Receive4 && 
		 ctrl_data != C_GOOD && 
		 ctrl_src_rdy_n == 1'b0)
	  begin
	     err2dbg[15:0]  <= #1 state;
	     err2dbg[31:24] <= #1 ctrl_data;
	     err2dbg[23:16] <= #1 rxdma2port_sts;
	  end
	else if (state == DX_Transmit2 && 
		 ctrl_src_rdy_n == 1'b0 &&
		 ctrl_data == C_SRCV)
	  begin
	     err2dbg[15:0]  <= #1 state;
	     err2dbg[31]    <= #1 1'b1;
	     err2dbg[30:24] <= #1 ctrl_data;
	     err2dbg[23:16] <= #1 txdma2port_sts;
	  end
	else if (state == DX_Transmit2 && 
		 ctrl_data != C_R_OK &&
	         ctrl_src_rdy_n == 1'b0)
	  begin
	     err2dbg[15:0]  <= #1 state;
	     err2dbg[31:24] <= #1 ctrl_data;
	     err2dbg[23:16] <= #1 txdma2port_sts;
	  end
	else if (state == ERR_SyncEscapeRecv)
	  begin
	     err2dbg[15:0]  <= #1 state;
	     err2dbg[31:16] <= #1 ctrl_data;
	  end
	else if (state == ERR_SyncEscapeRecvFbNd)
	  begin
	     err2dbg[15:0]  <= #1 state;
	     err2dbg[31:16] <= #1 ctrl_data;	     	     	     
	  end
     end // always @ (posedge sys_clk)
   always @(posedge sys_clk)
     begin
	if (sys_rst)
	  begin
	     rx_wip <= #1 1'b0;	     
	  end
	else if (state == CFIS_Xmit_Clear && ctrl_src_rdy_n == 1'b1)
	  begin
	     rx_wip <= #1 1'b1;
	  end
	else if (ctrl_src_rdy_n == 1'b0)
	  begin
	     rx_wip <= #1 1'b0;
	  end
     end // always @ (posedge sys_clk)
   signal 
    trn_tdst_dsc_n_sync (.clkA(phyclk),
	                 .signalIn(trn_tdst_dsc_n),
			 .clkB(sys_clk),
			 .signalOut(trn_tdst_dsc_n_sysclk));
   assign sata_ledA = (|ififo2port_SDB_SActive & rxll2port_fis_hdr[11:8] == 4'h0 & state == SDB_Entry && ififo2port_fo_ack);
   assign sata_ledB = (|ififo2port_SDB_SActive & rxll2port_fis_hdr[11:8] == 4'h1 & state == SDB_Entry && ififo2port_fo_ack);
   /**********************************************************************/
   /*AUTOASCIIENUM("state", "state_ascii", "S_")*/
   // Beginning of automatic ASCII enum decoding
   reg [175:0]		state_ascii;		// Decode of state
   always @(state) begin
      case ({state})
	P_Reset:                state_ascii = "p_reset               ";
	P_Init:                 state_ascii = "p_init                ";
	P_NotRunning:           state_ascii = "p_notrunning          ";
	P_ComInit:              state_ascii = "p_cominit             ";
	P_ComInitSetIs:         state_ascii = "p_cominitsetis        ";
	P_ComInitGenIntr:       state_ascii = "p_cominitgenintr      ";
	P_RegFisUpdate:         state_ascii = "p_regfisupdate        ";
	P_RegFisPostToMem:      state_ascii = "p_regfisposttomem     ";
	P_Offline:              state_ascii = "p_offline             ";
	P_StartBitCleared:      state_ascii = "p_startbitcleared     ";
	P_Idle:                 state_ascii = "p_idle                ";
	P_SelectCmd:            state_ascii = "p_selectcmd           ";
	P_FetchCmd:             state_ascii = "p_fetchcmd            ";
	P_FetchCmd1:            state_ascii = "p_fetchcmd1           ";
	P_StartComm:            state_ascii = "p_startcomm           ";
	P_PowerOn:              state_ascii = "p_poweron             ";
	P_PowerOff:             state_ascii = "p_poweroff            ";
	P_PhyListening:         state_ascii = "p_phylistening        ";
	FB_Idle:                state_ascii = "fb_idle               ";
	FB_SelectDevice:        state_ascii = "fb_selectdevice       ";
	FB_SelectCmd:           state_ascii = "fb_selectcmd          ";
	FB_FetchCmd:            state_ascii = "fb_fetchcmd           ";
	FB_FetchCmd1:           state_ascii = "fb_fetchcmd1          ";
	FB_SingleDeviceErr:     state_ascii = "fb_singledeviceerr    ";
	FB_SDE_Cleanup:         state_ascii = "fb_sde_cleanup        ";
	PM_Aggr:                state_ascii = "pm_aggr               ";
	PM_ICC:                 state_ascii = "pm_icc                ";
	PM_Partial:             state_ascii = "pm_partial            ";
	PM_Slumber:             state_ascii = "pm_slumber            ";
	PM_LowPower:            state_ascii = "pm_lowpower           ";
	PM_WakeLink:            state_ascii = "pm_wakelink           ";
	NDR_Entry:              state_ascii = "ndr_entry             ";
	NDR_Entry1:             state_ascii = "ndr_entry1            ";
	NDR_ERR_NotFatal:       state_ascii = "ndr_err_notfatal      ";
	NDR_ERR_NotFatal1:      state_ascii = "ndr_err_notfatal1     ";
	NDR_ERR_Fatal:          state_ascii = "ndr_err_fatal         ";
	NDR_ERR_Fatal1:         state_ascii = "ndr_err_fatal1        ";
	NDR_ERR_IPMS:           state_ascii = "ndr_err_ipms          ";
	NDR_ERR_IPMS1:          state_ascii = "ndr_err_ipms1         ";
	NDR_PmCheck:            state_ascii = "ndr_pmcheck           ";
	NDR_Accept:             state_ascii = "ndr_accept            ";
	NDR_Accept_Idle:        state_ascii = "ndr_accept_idle       ";
	NDR_Accept_Idle1:       state_ascii = "ndr_accept_idle1      ";
	CFIS_SyncEscape:        state_ascii = "cfisyncescape         ";
	CFIS_Xmit:              state_ascii = "cfixmit               ";
	CFIS_Xmit_Fetch:        state_ascii = "cfixmit_fetch         ";
	CFIS_Xmit_Push:         state_ascii = "cfixmit_push          ";
	CFIS_Xmit_Wait:         state_ascii = "cfixmit_wait          ";
	CFIS_Xmit_Abort:        state_ascii = "cfixmit_abort         ";
	CFIS_Xmit_Clear:        state_ascii = "cfixmit_clear         ";
	CFIS_Success:           state_ascii = "cfisuccess            ";
	CFIS_ClearCI:           state_ascii = "cficlearci            ";
	CFIS_PreFetchACMD:      state_ascii = "cfiprefetchacmd       ";
	CFIS_PreFetchPRD:       state_ascii = "cfiprefetchprd        ";
	CFIS_PreFetchData:      state_ascii = "cfiprefetchdata       ";
	ATAPI_Entry:            state_ascii = "atapi_entry           ";
	RegFis_Entry:           state_ascii = "regfientry            ";
	RegFis_ClearCI:         state_ascii = "regficlearci          ";
	RegFis_Ccc:             state_ascii = "regficcc              ";
	RegFis_SetIntr:         state_ascii = "regfisetintr          ";
	RegFis_SetIs:           state_ascii = "regfisetis            ";
	RegFis_GenIntr:         state_ascii = "regfigenintr          ";
	RegFis_UpdateSig:       state_ascii = "regfiupdatesig        ";
	RegFis_SetSig:          state_ascii = "regfisetsig           ";
	PIO_Entry:              state_ascii = "pio_entry             ";
	PIO_Update:             state_ascii = "pio_update            ";
	PIO_Update1:            state_ascii = "pio_update1           ";
	PIO_ClearCI:            state_ascii = "pio_clearci           ";
	PIO_Ccc:                state_ascii = "pio_ccc               ";
	PIO_SetIntr:            state_ascii = "pio_setintr           ";
	PIO_SetIs:              state_ascii = "pio_setis             ";
	PIO_GenIntr:            state_ascii = "pio_genintr           ";
	DX_Entry:               state_ascii = "dx_entry              ";
	DX_Entry1:              state_ascii = "dx_entry1             ";
	DX_Transmit2:           state_ascii = "dx_transmit2          ";
	DX_Transmit3:           state_ascii = "dx_transmit3          ";
	DX_Transmit:            state_ascii = "dx_transmit           ";
	DX_UpdateByteCount:     state_ascii = "dx_updatebytecount    ";
	DX_UpdateByteCount1:    state_ascii = "dx_updatebytecount1   ";
	DX_PrdSetIntr:          state_ascii = "dx_prdsetintr         ";
	DX_PrdSetIs:            state_ascii = "dx_prdsetis           ";
	DX_PrdGentIntr:         state_ascii = "dx_prdgentintr        ";
	DR_Entry:               state_ascii = "dr_entry              ";
	DR_Receive0:            state_ascii = "dr_receive0           ";
	DR_Receive1:            state_ascii = "dr_receive1           ";
	DR_Receive2:            state_ascii = "dr_receive2           ";
	DR_Receive3:            state_ascii = "dr_receive3           ";
	DR_Receive4:            state_ascii = "dr_receive4           ";
	DR_Receive:             state_ascii = "dr_receive            ";
	DR_UpdateByteCount:     state_ascii = "dr_updatebytecount    ";
	DR_UpdateByteCount1:    state_ascii = "dr_updatebytecount1   ";
	DR_UpdateByteCount2:    state_ascii = "dr_updatebytecount2   ";
	DR_UpdateByteCount3:    state_ascii = "dr_updatebytecount3   ";
	DmaSet_Entry:           state_ascii = "dmaset_entry          ";
	DmaSet_Entry1:          state_ascii = "dmaset_entry1         ";
	DmaSet_SetIntr:         state_ascii = "dmaset_setintr        ";
	DmaSet_SetIs:           state_ascii = "dmaset_setis          ";
	DmaSet_GenIntr:         state_ascii = "dmaset_genintr        ";
	DmaSet_AutoActivate:    state_ascii = "dmaset_autoactivate   ";
	DmaSet_AutoActivate1:   state_ascii = "dmaset_autoactivate1  ";
	DmaSet_AutoActivate2:   state_ascii = "dmaset_autoactivate2  ";
	SDB_Entry:              state_ascii = "sdb_entry             ";
	SDB_Entry1:             state_ascii = "sdb_entry1            ";
	SDB_Notification:       state_ascii = "sdb_notification      ";
	SDB_SetIntr:            state_ascii = "sdb_setintr           ";
	SDB_Ccc:                state_ascii = "sdb_ccc               ";
	SDB_SetIs:              state_ascii = "sdb_setis             ";
	SDB_GenIntr:            state_ascii = "sdb_genintr           ";
	UFIS_Entry:             state_ascii = "ufientry              ";
	UFIS_SetIs:             state_ascii = "ufisetis              ";
	UFIS_GenIntr:           state_ascii = "ufigenintr            ";
	BIST_FarEndLoop:        state_ascii = "bist_farendloop       ";
	BIST_TestOngoing:       state_ascii = "bist_testongoing      ";
	ERR_IPMS:               state_ascii = "err_ipms              ";
	ERR_SyncEscapeRecv:     state_ascii = "err_syncescaperecv    ";
	ERR_SyncEscapeRecvFbNd: state_ascii = "err_syncescaperecvfbnd";
	ERR_Fatal:              state_ascii = "err_fatal             ";
	ERR_NotFatal:           state_ascii = "err_notfatal          ";
	ERR_FatalTaskFile:      state_ascii = "err_fataltaskfile     ";
	ERR_WaitForCLear:       state_ascii = "err_waitforclear      ";
	DmaAct_Entry:           state_ascii = "dmaact_entry          ";
	default:                state_ascii = "%Error                ";
      endcase
   end
   // End of automatics
endmodule
// 
// port.v ends here
