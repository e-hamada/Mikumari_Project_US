`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2023 04:18:25 PM
// Design Name: 
// Module Name: TOP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module network(
        // System
        input           sitcp_reset,
        input           SYSCLK,
        input           independent_clock,
        // SFP interface
        input           sfp_refclk_p ,
        input           sfp_refclk_n ,
        output          sfp_tx_p,
        output          sfp_tx_n,
        input           sfp_rx_p,
        input           sfp_rx_n,
        // TCP/IP
        output          sitcp_rst,
        output          tcp_open_ack,
        output          tcp_rx_wr,
        output  [7:0]   tcp_rx_data,
        output          tcp_tx_full,
        input           tcp_tx_wr,
        input   [7:0]   tcp_tx_data,
        // RBCP
        output          rbcp_active,   // RBCP active
        output  [31:0]  rbcp_addr,     // RBCP Address [31:0]
        output  [ 7:0]  rbcp_wd,       // RBCP Data [7:0]
        output          rbcp_we,       // RBCP Write enable
        output          rbcp_re,       // RBCP Read enable
        input           rbcp_ack,      // RBCP Access acknowledge
        input   [ 7:0]  rbcp_rd       // RBCP Read data [7:0]
    );
 
 
//*******************************************************************************
//PCS/PMA
//*******************************************************************************    

    wire rxuserclk2;

    wire           resetdone       ;
    reg            sfp_reset_pulse ;
    wire   [7:0]   gmii_txd        ;
    wire           gmii_tx_en      ;
    wire           gmii_tx_er      ;
    wire   [7:0]   gmii_rxd        ;
    wire           gmii_rx_dv      ;
    wire           gmii_rx_er      ;
    wire           sfp_mdc;
    wire           sfp_mdio_i;
    wire           signal_detect;

    wire           gmii_tx_clk;
    wire           gmii_rx_clk;

    wire debug_reset;
    wire [15:0] status_vector;

   gig_ethernet_pcs_pma_SFP2_example_design dut
     (
      .independent_clock      (independent_clock),
      .io_refclk              (1'b0),
      .gtrefclk_p             (sfp_refclk_p),
      .gtrefclk_n             (sfp_refclk_n),
      .rxuserclk2             (rxuserclk2),
      .txp                    (sfp_tx_p),
      .txn                    (sfp_tx_n),
      .rxp                    (sfp_rx_p),
      .rxn                    (sfp_rx_n),
      .gmii_tx_clk            (gmii_tx_clk),
      .gmii_rx_clk            (gmii_rx_clk),
      .gmii_txd               (gmii_txd),
      .gmii_tx_en             (gmii_tx_en),
      .gmii_tx_er             (gmii_tx_er),
      .gmii_rxd               (gmii_rxd),
      .gmii_rx_dv             (gmii_rx_dv),
      .gmii_rx_er             (gmii_rx_er),
      .mdc                    (mdc),
      .mdio_i                 (mdio_i),
      .mdio_o                 (),
      .mdio_t                 (),
      .phyaddr                (5'b00001),
      .configuration_vector   (5'b00000),
      .configuration_valid    (1'b0),
      .status_vector          (status_vector),
        .an_interrupt(),                                  // Interrupt to processor to signal that Auto-Negotiation has completed
        .an_adv_config_vector(16'b0000_0000_0010_0001),   // Alternate interface to program REG4 (AN ADV)
        .an_adv_config_val(1'b0),                         // Validation signal for AN ADV
        .an_restart_config(1'b0),         
      .reset                  (sfp_reset_pulse),
      //.reset                  (debug_reset),
      .signal_detect          (1'b1),
      .resetdone               (resetdone)
      );

    assign gmii_tx_clk = gmii_rx_clk;


/*
    ila_0 ila_0(
        .clk(SYSCLK),
        .probe0(mmcm_locked_out),
        .probe1(debug_reset)
    );
*/

//---------------------------------------------------------------------    
//delay reset    
//---------------------------------------------------------------------
       wire           sfpFds      ;
       wire   [3:0]   sfpFd       ;
       reg            reset_pulse ;

       FDS SFP_FDS(.Q(sfpFds),   .C(rxuserclk2), .D(1'b0), .S(1'b0));
       FD  SFP_FD0(.Q(sfpFd[0]), .C(rxuserclk2), .D(sfpFds));
       FD  SFP_FD1(.Q(sfpFd[1]), .C(rxuserclk2), .D(sfpFd[0]));
       FD  SFP_FD2(.Q(sfpFd[2]), .C(rxuserclk2), .D(sfpFd[1]));
       FD  SFP_FD3(.Q(sfpFd[3]), .C(rxuserclk2), .D(sfpFd[2]));

       always@(posedge rxuserclk2) begin
          reset_pulse <= (|sfpFd[3:0]) ;
       end

       reg            sfp_reset_enable       ;
       reg    [4:0]   shift_sfp_reset_enable ;
       reg            resetdone_pos          ;

       always@(posedge rxuserclk2) begin
          if (reset_pulse) begin
             sfp_reset_enable <= 1'b0 ;
          end else if (resetdone_pos) begin
             sfp_reset_enable <= 1'b1 ;
          end
       end

       always@(posedge rxuserclk2) begin
          shift_sfp_reset_enable[4:0] <= {shift_sfp_reset_enable[3:0],sfp_reset_enable} ;
       end

       always@(posedge rxuserclk2) begin
          sfp_reset_pulse <= (~shift_sfp_reset_enable[4]) & shift_sfp_reset_enable[0] ;
       end

       reg    [2:0]   dly_resetdone ;

       always@(posedge rxuserclk2) begin
          dly_resetdone[0] <= resetdone        ;
          dly_resetdone[1] <= dly_resetdone[0] ;
          dly_resetdone[2] <= dly_resetdone[1] ;
       end

       always@(posedge rxuserclk2) begin
          resetdone_pos <= (~dly_resetdone[2]) & dly_resetdone[1] ;
       end

//------------------------------------------------------------------
//MII
//------------------------------------------------------------------
       mii_initializer mii_initializer(
          .CLK      (rxuserclk2           ),  // in : system clock (125M)
          .RST      (sfp_reset_pulse   ),  // in : system reset
          .PHYAD    (5'b00001          ),  // in : [4:0] PHY address
          .MDC      (mdc        ),  // out: clock (1/128 system clock)
          .MDIO_OUT (mdio_i     ),  // out: connect this to "PCS/PMA + RocketIO" module .mdio?_i()
          .COMPLETE (                  )   // out: initializing sequence has completed (active H)
       );

    
    //*******************************************************************************
    //                                   SiTCP
    //*******************************************************************************
    wire           tcp_close_req  ;
    wire   [31:0]  SiTCP_IP_ADDR  ;
    
    WRAP_SiTCP_GMII_XCAUP_32K
        #(125) // = System clock frequency(MHz), integer only
    SiTCP(
        .CLK            (SYSCLK            ),  // in  : System Clock >129MHz
        .RST            (sitcp_reset        ),  // in  : System reset (Asynchronous)
        // Configuration parameters
        .FORCE_DEFAULTn (1'b0                 ),  // in  : Load default parameters
        .EXT_IP_ADDR    (SiTCP_IP_ADDR[31:0]  ),
        .EXT_TCP_PORT   (                     ),  // in  : TCP port[15:0]
        .EXT_RBCP_PORT  (                     ),  // in  : RBCP port[15:0]
        .PHY_ADDR       (5'b00001             ),  // in  : PHY-device MIF address[4:0]
        // EEPROM
        .EEPROM_CS      (                     ),  // out : Chip select
        .EEPROM_SK      (                     ),  // out : Serial data clock
        .EEPROM_DI      (                     ),  // out : Serial write data
        .EEPROM_DO      (                     ),  // in  : Serial read data
        // user data, intialial values are stored in the EEPROM, 0xFFFF_FC3C-3F
        .USR_REG_X3C    (                     ),  // out : Stored at 0xFFFF_FF3C
        .USR_REG_X3D    (                     ),  // out : Stored at 0xFFFF_FF3D
        .USR_REG_X3E    (                     ),  // out : Stored at 0xFFFF_FF3E
        .USR_REG_X3F    (                     ),  // out : Stored at 0xFFFF_FF3F
        // MII interface
        .GMII_RSTn      (                     ),  // out : PHY reset
        .GMII_1000M     (1'b1                 ),  // in  : GMII mode (0:MII, 1:GMII)
        // TX
        .GMII_TX_CLK    (gmii_tx_clk              ),  // in  : Tx clock
        .GMII_TX_EN     (gmii_tx_en           ),  // out : Tx enable
        .GMII_TXD       (gmii_txd[7:0]        ),  // out : Tx data[7:0]
        .GMII_TX_ER     (gmii_tx_er           ),  // out : TX error
        // RX
        .GMII_RX_CLK    (gmii_rx_clk              ),  // in  : Rx clock
        .GMII_RX_DV     (gmii_rx_dv           ),  // in  : Rx data valid
        .GMII_RXD       (gmii_rxd[7:0]        ),  // in  : Rx data[7:0]
        .GMII_RX_ER     (gmii_rx_er           ),  // in  : Rx error
        .GMII_CRS       (1'b0                 ),  // in  : Carrier sense
        .GMII_COL       (1'b0                 ),  // in  : Collision detected
        // Management IF
        .GMII_MDC       (                     ),  // out : Clock for MDIO
        .GMII_MDIO_IN   (1'b1                 ),  // in  : Data
        .GMII_MDIO_OUT  (                     ),  // out : Data
        .GMII_MDIO_OE   (                     ),  // out : MDIO output enable
        // User I/F
        .SiTCP_RST      (sitcp_rst          ),  // out : Reset for SiTCP and related circuits
        // TCP connection control
        .TCP_OPEN_REQ   (1'b0                 ),  // in  : Reserved input, shoud be 0
        .TCP_OPEN_ACK   (tcp_open_ack       ),  // out : Acknowledge for open (=Socket busy)
        .TCP_ERROR      (                     ),  // out : TCP error, its active period is equal to MSL
        .TCP_CLOSE_REQ  (tcp_close_req        ),  // out : Connection close request
        .TCP_CLOSE_ACK  (tcp_close_req        ),  // in  : Acknowledge for closing
        // FIFO I/F
        .TCP_RX_WC      (16'd0                ),  // in  : Rx FIFO write count[15:0] (Unused bits should be set 1)
        .TCP_RX_WR      (tcp_rx_wr          ),  // out : Write enable
        .TCP_RX_DATA    (tcp_rx_data[7:0]   ),  // out : Write data[7:0]
        .TCP_TX_FULL    (tcp_tx_full        ),  // out : Almost full flag
        .TCP_TX_WR      (tcp_tx_wr          ),  // in  : Write enable
        .TCP_TX_DATA    (tcp_tx_data[7:0]   ),  // in  : Write data[7:0]
        // RBCP
        .RBCP_ACT       (rbcp_active        ),  // out : RBCP active
        .RBCP_ADDR      (rbcp_addr[31:0]    ),  // out : Address[31:0]
        .RBCP_WD        (rbcp_wd[7:0]       ),  // out : Data[7:0]
        .RBCP_WE        (rbcp_we            ),  // out : Write enable
        .RBCP_RE        (rbcp_re            ),  // out : Read enable
        .RBCP_ACK       (rbcp_ack           ),  // in  : Access acknowledge
        .RBCP_RD        (rbcp_rd[7:0]       )   // in  : Read data[7:0]
    );



    
endmodule
