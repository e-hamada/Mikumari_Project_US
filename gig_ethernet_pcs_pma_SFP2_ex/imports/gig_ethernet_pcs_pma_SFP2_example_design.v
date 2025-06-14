//------------------------------------------------------------------------------
// File       : gig_ethernet_pcs_pma_SFP2_example_design.v
// Author     : Xilinx Inc.
//------------------------------------------------------------------------------
// (c) Copyright 2009 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 
// 
// 
//------------------------------------------------------------------------------
// Description: This is the top level Verilog example design for the
//              Ethernet 1000BASE-X PCS/PMA core.
//
//              This design example instantiates IOB flip-flops
//              and input/output buffers on the GMII.
//
//              A Transmitter Elastic Buffer is instantiated on the Tx
//              GMII path to perform clock compenstation between the
//              core and the external MAC driving the Tx GMII.
//
//              This design example can be synthesised.
//
//
//
//    ----------------------------------------------------------------
//    |                             Example Design                   |
//    |                                                              |
//    |             ----------------------------------------------   |
//    |             |           Core Block (wrapper)             |   |
//    |             |                                            |   |
//    |             |   --------------          --------------   |   |
//    |             |   |    Core    |          | tranceiver |   |   |
//    |             |   |            |          |            |   |   |
//    |  ---------  |   |            |          |            |   |   |
//    |  |       |  |   |            |          |            |   |   |
//    |  |  Tx   |  |   |            |          |            |   |   |
//  ---->|Elastic|----->| GMII       |--------->|        TXP |--------->
//    |  |Buffer |  |   | Tx         |          |        TXN |   |   |
//    |  |       |  |   |            |          |            |   |   |
//    |  ---------  |   |            |tranceiver|            |   |   |
//    | GMII        |   |            |    I/F   |            |   |   |
//    | IOBs        |   |            |          |            |   |   |
//    |             |   |            |          |            |   |   |
//    |             |   | GMII       |          |        RXP |   |   |
//  <-------------------| Rx         |<---------|        RXN |<---------
//    |             |   |            |          |            |   |   |
//    |             |   --------------          --------------   |   |
//    |             |                                            |   |
//    |             ----------------------------------------------   |
//    |                                                              |
//    ----------------------------------------------------------------
//
//



`timescale 1 ps/1 ps
(* DowngradeIPIdentifiedWarnings="yes" *)


//------------------------------------------------------------------------------
// The module declaration for the example design
//------------------------------------------------------------------------------

module gig_ethernet_pcs_pma_SFP2_example_design
   (

      input            independent_clock,
      input            io_refclk,

      // Tranceiver Interface
      //---------------------
      input            gtrefclk_p,            // Differential +ve of reference clock for MGT: very high quality.
      input            gtrefclk_n,            // Differential -ve of reference clock for MGT: very high quality.
      output           rxuserclk2,
      output           txp,                   // Differential +ve of serial transmission from PMA to PMD.
      output           txn,                   // Differential -ve of serial transmission from PMA to PMD.
      input            rxp,                   // Differential +ve for serial reception from PMD to PMA.
      input            rxn,                   // Differential -ve for serial reception from PMD to PMA.

      // GMII Interface (client MAC <=> PCS)
      //------------------------------------
      input            gmii_tx_clk,           // Transmit clock from client MAC.
      output           gmii_rx_clk,           // Receive clock to client MAC.
      input [7:0]      gmii_txd,              // Transmit data from client MAC.
      input            gmii_tx_en,            // Transmit control signal from client MAC.
      input            gmii_tx_er,            // Transmit control signal from client MAC.
      output [7:0]     gmii_rxd,              // Received Data to client MAC.
      output           gmii_rx_dv,            // Received control signal to client MAC.
      output           gmii_rx_er,            // Received control signal to client MAC.
      // Management: MDIO Interface
      //---------------------------

      input            mdc,                   // Management Data Clock
      input            mdio_i,                // Management Data In
      output           mdio_o,                // Management Data Out
      output           mdio_t,                // Management Data Tristate
      input      [4:0] phyaddr,
      input [4:0]      configuration_vector,  // Alternative to MDIO interface.
      input            configuration_valid,   // Validation signal for Config vector

      output           an_interrupt,          // Interrupt to processor to signal that Auto-Negotiation has completed
      input [15:0]     an_adv_config_vector,  // Alternate interface to program REG4 (AN ADV)
      input            an_adv_config_val,     // Validation signal for AN ADV
      input            an_restart_config,     // Alternate signal to modify AN restart bit in REG0


      // General IO's
      //-------------
      output  [15:0]   status_vector,         // Core status.
      input            reset,                 // Asynchronous reset for entire core.
      input            signal_detect,          // Input from PMD to indicate presence of optical input.
      output            resetdone

   );



  //----------------------------------------------------------------------------
  // internal signals used in this top level example design.
  //----------------------------------------------------------------------------

   // clock generation signals for tranceiver
   wire         gtrefclk_bufg_out;
   wire         txoutclk;                 // txoutclk from GT transceiver.
   wire         userclk;                  
   wire         userclk2;                 


   // An independent clock source used as the reference clock for an
   // IDELAYCTRL (if present) and for the main GT transceiver reset logic.
   wire         independent_clock_bufg;
   wire         io_refclk_bufg;
   // Signals used for an IDELAYCTRL
   wire         idelayctrl_reset_sync;    // Used to create a reset pulse in the IDELAYCTRL clock domain.
   reg   [3:0]  idelay_reset_cnt;         // Counter to create a long IDELAYCTRL reset pulse.
   reg          idelayctrl_reset;         // The reset pulse for the IDELAYCTRL.

   // GMII signals
     
   wire         gmii_tx_clk_bufio;        // gmii_tx_clk routed through an BUFIO.
   wire         gmii_tx_clk_bufr;         // gmii_tx_clk_ibuf routed through a BUFR.
   wire  [7:0]  gmii_txd_delay;           // Internal gmii_txd signal after IDELAY.
   wire         gmii_tx_en_delay;         // Internal gmii_tx_en signal after IDELAY.
   wire         gmii_tx_er_delay;         // Internal gmii_tx_er signal after IDELAY.
   wire         gmii_isolate;             // internal gmii_isolate signal.
   reg   [7:0]  gmii_txd_iff;             // gmii_txd signal for input IOB flip-flop.
   reg          gmii_tx_en_iff;           // gmii_tx_en signal for input IOB flip-flop.
   reg          gmii_tx_er_iff;           // gmii_tx_er signal for input IOB flip-flop.
   reg   [7:0]  gmii_txd_reg;             // internal gmii_txd signal.
   reg          gmii_tx_en_reg;           // internal gmii_tx_en signal.
   reg          gmii_tx_er_reg;           // internal gmii_tx_er signal.
   wire  [7:0]  gmii_txd_fifo;            // gmii_txd signal after Tx Elastic Buffer.
   wire         gmii_tx_en_fifo;          // gmii_tx_en signal after Tx Elastic Buffer.
   wire         gmii_tx_er_fifo;          // gmii_tx_er signal after Tx Elastic Buffer.
   wire  [7:0]  gmii_rxd_int;             // internal gmii_rxd signal.
   wire         gmii_rx_dv_int;           // internal gmii_rx_dv signal.
   wire         gmii_rx_er_int;           // internal gmii_rx_er signal.
     
   wire         gmii_rx_clk_obuf;         // gmii_rx_clk  registered in IOBs prior to an OBUF.
   reg   [7:0]  gmii_rxd_obuf;            // gmii_rxd registered in IOBs prior to an OBUF.
   reg          gmii_rx_dv_obuf;          // gmii_rx_dv registered in IOBs prior to an OBUF.
   reg          gmii_rx_er_obuf;          // gmii_rx_er registered in IOBs prior to an OBUF.

   
   // Route independent_clock input through a BUFG
   BUFG  bufg_independent_clock (
      .I         (independent_clock),
      .O         (independent_clock_bufg)
   );

   // Route io_refclk_clock input through a BUFG
   BUFG  bufg_io_refclk (
      .I         (io_refclk),
      .O         (io_refclk_bufg)
   );
  //----------------------------------------------------------------------------
  // Instantiate the Core Block (core wrapper).
  //----------------------------------------------------------------------------
 gig_ethernet_pcs_pma_SFP2_support 
   core_support_i
   (

      .gtrefclk_p              (gtrefclk_p),
      .gtrefclk_n              (gtrefclk_n),
      .gtrefclk_out            (),
      
      .txp                     (txp),
      .txn                     (txn),
      .rxp                     (rxp),
      .rxn                     (rxn),
      .mmcm_locked_out         (),
      .userclk_out             (userclk),
      .userclk2_out            (userclk2),
      .rxuserclk_out           (),
      .rxuserclk2_out          (rxuserclk2),
      .independent_clock_bufg(independent_clock_bufg),
      .pma_reset_out           (),
      .resetdone               (resetdone),
      
      .gmii_txd              (gmii_txd_fifo),
      .gmii_tx_en            (gmii_tx_en_fifo),
      .gmii_tx_er            (gmii_tx_er_fifo),
      .gmii_rxd              (gmii_rxd_int),
      .gmii_rx_dv            (gmii_rx_dv_int),
      .gmii_rx_er            (gmii_rx_er_int),
      .gmii_isolate          (gmii_isolate),
      .mdc                   (mdc),
      .mdio_i                (mdio_i),
      .mdio_o                (mdio_o),
      .mdio_t                (mdio_t),
      .phyaddr               (phyaddr),
      .configuration_vector  (configuration_vector),
      .configuration_valid   (configuration_valid),
      .an_interrupt          (an_interrupt),
      .an_adv_config_vector  (an_adv_config_vector),
      .an_adv_config_val     (an_adv_config_val),
      .an_restart_config     (an_restart_config),
      .status_vector          (status_vector),
      .reset                  (reset),
   

     
      .signal_detect         (signal_detect)
      );




 // Create a synchronous reset in the IDELAYCTRL clock domain.
   gig_ethernet_pcs_pma_SFP2_reset_sync_ex idelayctrl_reset_gen (
      .clk       (io_refclk_bufg),
      .reset_in  (reset),
      .reset_out (idelayctrl_reset_sync)
   );


  // Reset circuitry for the IDELAYCTRL reset.

  // The IDELAYCTRL must experience a pulse which is at least 50 ns in
  // duration.  This is ten clock cycles of the 200MHz independent_clock.
  // Here we drive the reset pulse for 12 clock cycles.
  always @(posedge io_refclk_bufg)
  begin
    if (idelayctrl_reset_sync) begin
      idelay_reset_cnt <= 4'b0000;
      idelayctrl_reset <= 1'b1;
    end

    else begin

      case (idelay_reset_cnt)
        4'b0000 : idelay_reset_cnt <= 4'b0001;
        4'b0001 : idelay_reset_cnt <= 4'b0010;
        4'b0010 : idelay_reset_cnt <= 4'b0011;
        4'b0011 : idelay_reset_cnt <= 4'b0100;
        4'b0100 : idelay_reset_cnt <= 4'b0101;
        4'b0101 : idelay_reset_cnt <= 4'b0110;
        4'b0110 : idelay_reset_cnt <= 4'b0111;
        4'b0111 : idelay_reset_cnt <= 4'b1000;
        4'b1000 : idelay_reset_cnt <= 4'b1001;
        4'b1001 : idelay_reset_cnt <= 4'b1010;
        4'b1010 : idelay_reset_cnt <= 4'b1011;
        4'b1011 : idelay_reset_cnt <= 4'b1100;
        default : idelay_reset_cnt <= 4'b1100;
      endcase

      if (idelay_reset_cnt == 4'b1100) begin
          idelayctrl_reset <= 1'b0;
      end

      else begin
          idelayctrl_reset <= 1'b1;
      end

    end
  end

/*
   IDELAYCTRL 
#(.SIM_DEVICE ("ULTRASCALE"))
   core_idelayctrl_i 
   (
      .RDY       (),
      .REFCLK    (io_refclk_bufg),
      .RST       (idelayctrl_reset)
   );
*/

   //---------------------------------------------------------------------------
   // GMII transmitter clock logic
   //---------------------------------------------------------------------------

     
   // Route gmii_tx_clk from PAD through a BUFIO Buffer
   BUFIO receive_gmii_tx_clk (
      .I   (gmii_tx_clk),
      .O   (gmii_tx_clk_bufio)
   );


   // Route gmii_tx_clk through a BUFR onto regional clock routing
   BUFR drive_tx_clk (
      .I   (gmii_tx_clk),
      .CE  (1'b1),
      .CLR (1'b0),
      .O   (gmii_tx_clk_bufr)
   );


/*
   genvar i;
   generate for (i=0; i<8; i=i+1)
     begin : gmii_data_bus
   IDELAYE3 #(
      .DELAY_TYPE("FIXED"),      
      	.SIM_DEVICE		("ULTRASCALE_PLUS_ES1"),    
      .REFCLK_FREQUENCY(300.0),
      .DELAY_VALUE(0)              
   )
   delay_gmii_txd (
      .CASC_RETURN (1'b0),
      .CASC_IN (1'b0),
      .CASC_OUT (),
      .CNTVALUEOUT(),
      .CLK (io_refclk_bufg),
      .DATAOUT(gmii_txd_delay[i]),         
      .CE(1'b0),                  
      .CNTVALUEIN(9'b0),   
      .DATAIN(1'b0),          
      .IDATAIN(gmii_txd[i]), 
      .INC(1'b0),             
      .RST(1'b0),    
      .LOAD(1'b0), 
      .EN_VTC(1'b1)         
   );

     end
   endgenerate

   IDELAYE3 #(
      .DELAY_TYPE  ("FIXED"),      
      	.SIM_DEVICE		("ULTRASCALE_PLUS_ES1"),    
      .REFCLK_FREQUENCY(300.0),
      .DELAY_VALUE(0)              
   )
   delay_gmii_tx_en (
      .CASC_RETURN (1'b0),
      .CASC_IN (1'b0),
      .CASC_OUT (),
      .CNTVALUEOUT(),
      .CLK (io_refclk_bufg),
      .DATAOUT(gmii_tx_en_delay),         
      .CE(1'b0),                  
      .CNTVALUEIN(9'b0),   
      .DATAIN(1'b0),          
      .IDATAIN(gmii_tx_en), 
      .INC(1'b0),             
      .RST(1'b0),    
      .LOAD(1'b0), 
      .EN_VTC(1'b1)          
   );

   IDELAYE3 #(
      .DELAY_TYPE("FIXED"),      
      	.SIM_DEVICE		("ULTRASCALE_PLUS_ES1"),    
      .REFCLK_FREQUENCY(300.0),
      .DELAY_VALUE(0)              
   )
   delay_gmii_tx_er (
      .CASC_RETURN (1'b0),
      .CASC_IN (1'b0),
      .CASC_OUT (),
      .CNTVALUEOUT(),
      .CLK (io_refclk_bufg),
      .DATAOUT(gmii_tx_er_delay),         
      .CE(1'b0),                  
      .CNTVALUEIN(9'b0),   
      .DATAIN(1'b0),          
      .IDATAIN(gmii_tx_er), 
      .INC(1'b0),             
      .RST(1'b0),    
      .LOAD(1'b0), 
      .EN_VTC(1'b1)         
   );


     
   // Drive input GMII through IOB input flip-flops (inferred).
   always @ (posedge gmii_tx_clk_bufio)
   begin
      gmii_txd_iff   <= gmii_txd_delay;
      gmii_tx_en_iff <= gmii_tx_en_delay;
      gmii_tx_er_iff <= gmii_tx_er_delay;
   end

     
   // Reclock onto regional clock routing
   always @ (posedge gmii_tx_clk_bufr)
   begin
      gmii_txd_reg   <= gmii_txd_iff;
      gmii_tx_en_reg <= gmii_tx_en_iff;
      gmii_tx_er_reg <= gmii_tx_er_iff;
   end

*/

   always @ (posedge gmii_tx_clk)
   begin
      gmii_txd_reg   <= gmii_txd;
      gmii_tx_en_reg <= gmii_tx_en;
      gmii_tx_er_reg <= gmii_tx_er;
   end


   // Component Instantiation for the Transmitter Elastic Buffer
   gig_ethernet_pcs_pma_SFP2_tx_elastic_buffer tx_elastic_buffer_inst
   (
      .reset            (reset),
     
      .gmii_tx_clk_wr   (gmii_tx_clk_bufr),
      .gmii_txd_wr      (gmii_txd_reg),
      .gmii_tx_en_wr    (gmii_tx_en_reg),
      .gmii_tx_er_wr    (gmii_tx_er_reg),
      .gmii_tx_clk_rd   (userclk2),
      .gmii_txd_rd      (gmii_txd_fifo),
      .gmii_tx_en_rd    (gmii_tx_en_fifo),
      .gmii_tx_er_rd    (gmii_tx_er_fifo)
   );



   //---------------------------------------------------------------------------
   // GMII receiver clock logic
   //---------------------------------------------------------------------------

   // This instantiates a DDR output register.  This is a nice way to
   // drive the GMII output clock since the clock-to-PAD delay will the
   // same as that of data driven from an IOB Ouput flip-flop.  This is
   // set to produce an inverted clock w.r.t. userclk2 so that clock
   // rising edge appears in the centre of GMII data.

 

     
     /*
   ODDR # (
       .DDR_CLK_EDGE("SAME_EDGE"), 
       .SRTYPE ("ASYNC")
       )
     rx_clk_ddr_iob 
     (
      .Q  (gmii_rx_clk_obuf),
      .C  (userclk2),
      .D1 (1'b0),
      .D2 (1'b1),
      .CE (1'b1),
      .R  (1'b0),
      .S  (1'b0)
   );


     
   // Finally the clock is driven onto the PAD from an Output Buffer.
   OBUFT drive_gmii_gtx_clk (
      .I  (gmii_rx_clk_obuf),
      .O  (gmii_rx_clk),
      .T  (gmii_isolate)
   );
*/

    BUFG BUFG_gmii_rx_clk(.I(~userclk2), .O(gmii_rx_clk));

   //---------------------------------------------------------------------------
   // GMII receiver data logic
   //---------------------------------------------------------------------------


   // Drive Rx GMII signals through IOB output flip-flops (inferred).
   always @ (posedge userclk2)
   begin
      gmii_rxd_obuf    <= gmii_rxd_int;
      gmii_rx_dv_obuf  <= gmii_rx_dv_int;
      gmii_rx_er_obuf  <= gmii_rx_er_int;
   end

    assign gmii_rx_er = gmii_rx_er_obuf;
    assign gmii_rx_dv = gmii_rx_dv_obuf;
    assign gmii_rxd = gmii_rxd_obuf;

/*
   //  drive GMII Rx signals through output PADS.
   OBUFT rx_data_valid (
      .I  (gmii_rx_dv_obuf),
      .O  (gmii_rx_dv),
      .T  (gmii_isolate)
   );

   OBUFT rx_data_error (
      .I  (gmii_rx_er_obuf),
      .O  (gmii_rx_er),
      .T  (gmii_isolate)
   );

   genvar j;
   generate for (j=0; j<8; j=j+1)
     begin : rx_data_bus

     OBUFT rx_data_bits (
        .I (gmii_rxd_obuf[j]),
        .O (gmii_rxd[j]),
        .T (gmii_isolate));

     end
   endgenerate
*/

endmodule // gig_ethernet_pcs_pma_SFP2_example_design
