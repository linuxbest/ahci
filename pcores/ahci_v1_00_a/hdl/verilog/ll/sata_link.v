module sata_link(/*AUTOARG*/
   // Outputs
   trn_rsof_n, trn_reof_n, trn_rd, trn_rsrc_rdy_n, trn_rsrc_dsc_n,
   trn_tdst_rdy_n, trn_tdst_dsc_n, trn_csof_n, trn_ceof_n, trn_cd,
   trn_csrc_rdy_n, trn_csrc_dsc_n, txdata, txdatak, rx_cs2dbg,
   tx_cs2dbg, link_fsm2dbg, cs2dcr_prim, cs2dcr_cnt,
   // Inputs
   phyclk, host_rst, trn_rdst_rdy_n, trn_rdst_dsc_n, trn_tsof_n,
   trn_teof_n, trn_td, trn_tsrc_rdy_n, trn_tsrc_dsc_n, trn_cdst_rdy_n,
   trn_cdst_dsc_n, trn_cdst_lock_n, txdatak_pop, rxdata, rxdatak,
   linkup, plllock, dcr2cs_pop, dcr2cs_clk, port_state, gtx_txdata,
   gtx_txdatak, gtx_rxdata, gtx_rxdatak, gtx_tune
   );
   parameter C_LINKFSM_DEBUG = 0;
`include "sata.v"

   //system signal
   input         phyclk;
   input         host_rst;

   output 	 trn_rsof_n;
   output 	 trn_reof_n;
   output [31:0] trn_rd;
   output 	 trn_rsrc_rdy_n;
   input 	 trn_rdst_rdy_n;
   output 	 trn_rsrc_dsc_n;
   input 	 trn_rdst_dsc_n;
   
   input 	 trn_tsof_n;
   input 	 trn_teof_n;
   input [31:0]  trn_td;
   input 	 trn_tsrc_rdy_n;
   output 	 trn_tdst_rdy_n;
   input 	 trn_tsrc_dsc_n;
   output 	 trn_tdst_dsc_n;
   
   output 	 trn_csof_n;
   output 	 trn_ceof_n;
   output [31:0] trn_cd;
   output 	 trn_csrc_rdy_n;
   input 	 trn_cdst_rdy_n;
   output	 trn_csrc_dsc_n;
   input 	 trn_cdst_dsc_n;
   input 	 trn_cdst_lock_n;
   
   // SATA phy interface
   output [31:0] txdata;
   output        txdatak;
   input         txdatak_pop;

   input [31:0]  rxdata;
   input    	 rxdatak;
   input 	 linkup;
   input 	 plllock;

   output [127:0] rx_cs2dbg;
   output [127:0] tx_cs2dbg;
   output [127:0] link_fsm2dbg;

   output [35:0] cs2dcr_prim;
   output [8:0]  cs2dcr_cnt;
   input         dcr2cs_pop;
   input         dcr2cs_clk;
   input [7:0]   port_state;

   input [31:0] gtx_txdata;
   input [3:0]  gtx_txdatak;
   input [31:0] gtx_rxdata;
   input [3:0]  gtx_rxdatak;

   input [31:0] gtx_tune;
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [31:0]		cs2link_char;		// From rx_cs of rx_cs.v
   wire			cs2link_crc_ok;		// From rx_cs of rx_cs.v
   wire			cs2link_crc_rdy;	// From rx_cs of rx_cs.v
   wire			cs2link_kchar;		// From rx_cs of rx_cs.v
   wire [7:0]		lfsm_state;		// From link_fsm of link_fsm.v
   wire [31:0]		link2cs_char;		// From link_fsm of link_fsm.v
   wire			link2cs_chark;		// From link_fsm of link_fsm.v
   wire			ll2cs_datav;		// From link_fsm of link_fsm.v
   wire			ll2cs_eof;		// From link_fsm of link_fsm.v
   wire			ll2cs_sof;		// From link_fsm of link_fsm.v
   wire			rd_almost_empty;	// From tx_cs of tx_cs.v
   wire			rd_empty;		// From tx_cs of tx_cs.v
   wire			rd_eof;			// From tx_cs of tx_cs.v
   wire			rd_sof;			// From tx_cs of tx_cs.v
   wire			state_idle;		// From link_fsm of link_fsm.v
   wire			trn_tfifo_rst;		// From link_fsm of link_fsm.v
   // End of automatics
   wire [31:0] 	 phy2cs_data;		

   assign               phy2cs_data 	   = rxdata;
   assign               phy2cs_k    	   = rxdatak;
   assign               link_up     	   = linkup;
   link_fsm 
     link_fsm(.clk_75m(phyclk),
	      /*AUTOINST*/
	      // Outputs
	      .link2cs_char		(link2cs_char[31:0]),
	      .link2cs_chark		(link2cs_chark),
	      .trn_tfifo_rst		(trn_tfifo_rst),
	      .ll2cs_sof		(ll2cs_sof),
	      .ll2cs_eof		(ll2cs_eof),
	      .ll2cs_datav		(ll2cs_datav),
	      .trn_csrc_rdy_n		(trn_csrc_rdy_n),
	      .trn_csrc_dsc_n		(trn_csrc_dsc_n),
	      .trn_cd			(trn_cd[31:0]),
	      .trn_csof_n		(trn_csof_n),
	      .trn_ceof_n		(trn_ceof_n),
	      .trn_tdst_dsc_n		(trn_tdst_dsc_n),
	      .state_idle		(state_idle),
	      .lfsm_state		(lfsm_state[7:0]),
	      .link_fsm2dbg		(link_fsm2dbg[127:0]),
	      // Inputs
	      .host_rst			(host_rst),
	      .link_up			(link_up),
	      .rxdata			(rxdata[31:0]),
	      .rxdatak			(rxdatak),
	      .txdata			(txdata[31:0]),
	      .txdatak			(txdatak),
	      .txdatak_pop		(txdatak_pop),
	      .cs2link_crc_ok		(cs2link_crc_ok),
	      .cs2link_crc_rdy		(cs2link_crc_rdy),
	      .cs2link_char		(cs2link_char[31:0]),
	      .cs2link_kchar		(cs2link_kchar),
	      .rd_sof			(rd_sof),
	      .rd_eof			(rd_eof),
	      .rd_empty			(rd_empty),
	      .rd_almost_empty		(rd_almost_empty),
	      .trn_cdst_rdy_n		(trn_cdst_rdy_n),
	      .trn_cdst_dsc_n		(trn_cdst_dsc_n),
	      .trn_cdst_lock_n		(trn_cdst_lock_n),
	      .trn_rsof_n		(trn_rsof_n),
	      .trn_reof_n		(trn_reof_n),
	      .trn_rd			(trn_rd[31:0]),
	      .trn_rsrc_rdy_n		(trn_rsrc_rdy_n),
	      .trn_rsrc_dsc_n		(trn_rsrc_dsc_n),
	      .trn_rdst_rdy_n		(trn_rdst_rdy_n),
	      .trn_rdst_dsc_n		(trn_rdst_dsc_n),
	      .trn_tsof_n		(trn_tsof_n),
	      .trn_teof_n		(trn_teof_n),
	      .trn_td			(trn_td[31:0]),
	      .trn_tsrc_rdy_n		(trn_tsrc_rdy_n),
	      .trn_tsrc_dsc_n		(trn_tsrc_dsc_n),
	      .trn_tdst_rdy_n		(trn_tdst_rdy_n));

   rx_cs #(/*AUTOINSTPARAM*/
	   // Parameters
	   .C_LINKFSM_DEBUG		(C_LINKFSM_DEBUG))
     rx_cs (
	     .clk_75m			(phyclk),
	    /*AUTOINST*/
	    // Outputs
	    .cs2link_char		(cs2link_char[31:0]),
	    .cs2link_kchar		(cs2link_kchar),
	    .cs2link_crc_ok		(cs2link_crc_ok),
	    .cs2link_crc_rdy		(cs2link_crc_rdy),
	    .trn_rsof_n			(trn_rsof_n),
	    .trn_reof_n			(trn_reof_n),
	    .trn_rd			(trn_rd[31:0]),
	    .trn_rsrc_rdy_n		(trn_rsrc_rdy_n),
	    .trn_rsrc_dsc_n		(trn_rsrc_dsc_n),
	    .cs2dcr_prim		(cs2dcr_prim[35:0]),
	    .cs2dcr_cnt			(cs2dcr_cnt[8:0]),
	    .rx_cs2dbg			(rx_cs2dbg[127:0]),
	    // Inputs
	    .host_rst			(host_rst),
	    .phy2cs_k			(phy2cs_k),
	    .phy2cs_data		(phy2cs_data[31:0]),
	    .trn_rdst_rdy_n		(trn_rdst_rdy_n),
	    .trn_rdst_dsc_n		(trn_rdst_dsc_n),
	    .ll2cs_sof			(ll2cs_sof),
	    .ll2cs_eof			(ll2cs_eof),
	    .ll2cs_datav		(ll2cs_datav),
	    .dcr2cs_pop			(dcr2cs_pop),
	    .dcr2cs_clk			(dcr2cs_clk),
	    .txdatak			(txdatak),
	    .txdata			(txdata[31:0]),
	    .state_idle			(state_idle),
	    .lfsm_state			(lfsm_state[7:0]),
	    .port_state			(port_state[7:0]),
	    .gtx_txdata			(gtx_txdata[31:0]),
	    .gtx_txdatak		(gtx_txdatak[3:0]),
	    .gtx_rxdata			(gtx_rxdata[31:0]),
	    .gtx_rxdatak		(gtx_rxdatak[3:0]));

   tx_cs
     tx_cs (
	     .clk_75m			(phyclk),
	    /*AUTOINST*/
	    // Outputs
	    .trn_tdst_rdy_n		(trn_tdst_rdy_n),
	    .txdata			(txdata[31:0]),
	    .txdatak			(txdatak),
	    .rd_sof			(rd_sof),
	    .rd_eof			(rd_eof),
	    .rd_empty			(rd_empty),
	    .rd_almost_empty		(rd_almost_empty),
	    .tx_cs2dbg			(tx_cs2dbg[127:0]),
	    // Inputs
	    .host_rst			(host_rst),
	    .link2cs_char		(link2cs_char[31:0]),
	    .link2cs_chark		(link2cs_chark),
	    .trn_tsof_n			(trn_tsof_n),
	    .trn_teof_n			(trn_teof_n),
	    .trn_td			(trn_td[31:0]),
	    .trn_tsrc_rdy_n		(trn_tsrc_rdy_n),
	    .trn_tsrc_dsc_n		(trn_tsrc_dsc_n),
	    .trn_tdst_dsc_n		(trn_tdst_dsc_n),
	    .trn_tfifo_rst		(trn_tfifo_rst),
	    .txdatak_pop		(txdatak_pop),
	    .gtx_tune			(gtx_tune[31:0]));
endmodule
// Local Variables:
// verilog-library-directories:(".""sata_phy")
// verilog-library-files:(".""sata_phy")
// verilog-library-extensions:(".v" ".h")
// End:
