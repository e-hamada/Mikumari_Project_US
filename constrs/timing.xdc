set_false_path -through [get_ports {LED[1]}]
set_false_path -through [get_ports {LED[2]}]
set_false_path -through [get_ports {LED[3]}]
set_false_path -through [get_ports {LED[4]}]

##SiTCP################

set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */GMII_RXBUF/cmpWrAddr_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_RXBUF/smpWrStatusAddr_reg*/D}] 8.500
set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */GMII_TXBUF/orRdAct_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_TXBUF/irRdAct_reg*/D}] 8.500
set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */GMII_TXBUF/muxEndTgl_reg/C}] -to [get_pins -hier -filter {name =~ */GMII_TXBUF/rsmpMuxTrnsEnd_reg*/D}] 8.500

set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */SiTCP_INT_REG/regX10Data_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_RXCNT/irMacFlowEnb_reg/D}] 8.500
set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */SiTCP_INT_REG/regX12Data_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_RXCNT/muxMyMac_reg*/D}] 8.500
set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */SiTCP_INT_REG/regX13Data_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_RXCNT/muxMyMac_reg*/D}] 8.500
set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */SiTCP_INT_REG/regX14Data_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_RXCNT/muxMyMac_reg*/D}] 8.500
set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */SiTCP_INT_REG/regX15Data_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_RXCNT/muxMyMac_reg*/D}] 8.500
set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */SiTCP_INT_REG/regX16Data_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_RXCNT/muxMyMac_reg*/D}] 8.500
set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */SiTCP_INT_REG/regX17Data_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_RXCNT/muxMyMac_reg*/D}] 8.500
set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */SiTCP_INT_REG/regX18Data_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_RXCNT/muxMyIp_reg*/D}] 8.500
set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */SiTCP_INT_REG/regX19Data_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_RXCNT/muxMyIp_reg*/D}] 8.500
set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */SiTCP_INT_REG/regX1AData_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_RXCNT/muxMyIp_reg*/D}] 8.500
set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */SiTCP_INT_REG/regX1BData_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_RXCNT/muxMyIp_reg*/D}] 8.500

set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */GMII_TXBUF/dlyBank0LastWrAddr_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_TXBUF/rsmpBank0LastWrAddr_reg*/D}] 8.500
set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */GMII_TXBUF/dlyBank1LastWrAddr_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_TXBUF/rsmpBank1LastWrAddr_reg*/D}] 8.500
set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */GMII_TXBUF/memRdReq_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_TXBUF/irMemRdReq_reg*/D}] 8.500

set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */GMII_RXCNT/orMacTim_reg*/C}] -to [get_pins -hier -filter {name =~ */GMII_TXCNT/irMacPauseTime_reg*/D}] 8.500
set_max_delay -datapath_only -from [get_pins -hier -filter {name =~ */GMII_RXCNT/orMacPause_reg/C}] -to [get_pins -hier -filter {name =~ */GMII_TXCNT/irMacPauseExe_reg[0]/D}] 8.500

set_false_path -from [get_pins -hier -filter {name =~ */SiTCP_INT/SiTCP_RESET_OUT_reg*/C}]


#######################

create_clock -period 8.000 -name sfp_refclk_p -waveform {0.000 4.000} [get_ports sfp_refclk_p]


create_generated_clock -name clk_slow_CLR [get_pins u_mmcm_cdcm/inst/mmcme4_adv_inst/CLKOUT3]
create_generated_clock -name clk_slow [get_pins u_mmcm_cdcm/inst/BUFGCE_DIV_CLK3_inst/O]
create_generated_clock -name clk_fast [get_pins u_mmcm_cdcm/inst/mmcme4_adv_inst/CLKOUT0]

create_generated_clock -name clk_sys [get_pins u_clk_wiz_sys/inst/mmcme4_adv_inst/CLKOUT2]
create_generated_clock -name independent_clock_clk [get_pins u_clk_wiz_sys/inst/mmcme4_adv_inst/CLKOUT1]
create_generated_clock -name clk_idelay_REFCLK [get_pins u_clk_wiz_sys/inst/mmcme4_adv_inst/CLKOUT0]

create_generated_clock -name RXOUTCLK [get_pins {gen_SiTCP[0].u_network_inst/dut/core_support_i/pcs_pma_i/inst/transceiver_inst/gig_ethernet_pcs_pma_SFP2_gt_i/inst/gen_gtwizard_gtye4_top.gig_ethernet_pcs_pma_SFP2_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXOUTCLK}]
create_generated_clock -name TXOUTCLK [get_pins {gen_SiTCP[0].u_network_inst/dut/core_support_i/pcs_pma_i/inst/transceiver_inst/gig_ethernet_pcs_pma_SFP2_gt_i/inst/gen_gtwizard_gtye4_top.gig_ethernet_pcs_pma_SFP2_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]
create_generated_clock -name usrclk_bufg [get_pins {gen_SiTCP[0].u_network_inst/dut/core_support_i/core_clocking_i/usrclk_bufg_inst/O}]

#set_clock_groups -name async_sys_gmii -asynchronous -group clk_sys -group independent_clock_clk -group clk_indep_gtx -group {clk_fast clk_slow clk_slow_CLR} -group RXOUTCLK -group TXOUTCLK -group usrclk_bufg
set_clock_groups -name async_sys_gmii -asynchronous \
  -group [get_clocks clk_sys] \
  -group [get_clocks independent_clock_clk] \
  -group [get_clocks clk_idelay_REFCLK] \
  -group [get_clocks {clk_fast clk_slow clk_slow_CLR}] \
  -group [get_clocks RXOUTCLK] \
  -group [get_clocks TXOUTCLK] \
  -group [get_clocks usrclk_bufg]

set_property CLOCK_DELAY_GROUP group_clk_wiz_1 [get_nets u_mmcm_cdcm/inst/clk_fast_TX]
set_property CLOCK_DELAY_GROUP group_clk_wiz_1 [get_nets u_mmcm_cdcm/inst/clk_fast_RX]
set_property CLOCK_DELAY_GROUP group_clk_wiz_1 [get_nets u_mmcm_cdcm/inst/clk_slow]


#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_cdcm/inst/mmcme4_adv_inst/CLKOUT4]] -to [get_clocks -of_objects [get_pins u_clk_wiz_sys/inst/mmcme4_adv_inst/CLKOUT2]]
#set_false_path -from [get_clocks -of_objects [get_pins u_clk_wiz_sys/inst/mmcme4_adv_inst/CLKOUT2]] -to [get_clocks -of_objects [get_pins u_mmcm_cdcm/inst/BUFGCE_DIV_CLK4_inst/O]]

#set_false_path -from [get_clocks -of_objects [get_pins {gen_SiTCP[0].u_network_inst/dut/core_support_i/pcs_pma_i/inst/transceiver_inst/gig_ethernet_pcs_pma_SFP2_gt_i/inst/gen_gtwizard_gtye4_top.gig_ethernet_pcs_pma_SFP2_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks -of_objects [get_pins u_clk_wiz_sys/inst/mmcme4_adv_inst/CLKOUT1]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_cdcm/inst/BUFGCE_DIV_CLK4_inst/O]] -to [get_clocks -of_objects [get_pins {gen_SiTCP[0].u_network_inst/dut/core_support_i/pcs_pma_i/inst/transceiver_inst/gig_ethernet_pcs_pma_SFP2_gt_i/inst/gen_gtwizard_gtye4_top.gig_ethernet_pcs_pma_SFP2_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
#set_false_path -from [get_clocks -of_objects [get_pins {gen_SiTCP[0].u_network_inst/dut/core_support_i/pcs_pma_i/inst/transceiver_inst/gig_ethernet_pcs_pma_SFP2_gt_i/inst/gen_gtwizard_gtye4_top.gig_ethernet_pcs_pma_SFP2_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -to [get_clocks -of_objects [get_pins u_mmcm_cdcm/inst/BUFGCE_DIV_CLK4_inst/O]]
#set_false_path -from [get_clocks -of_objects [get_pins {gen_SiTCP[0].u_network_inst/dut/core_support_i/pcs_pma_i/inst/transceiver_inst/gig_ethernet_pcs_pma_SFP2_gt_i/inst/gen_gtwizard_gtye4_top.gig_ethernet_pcs_pma_SFP2_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -to [get_clocks -of_objects [get_pins {gen_SiTCP[0].u_network_inst/dut/core_support_i/pcs_pma_i/inst/transceiver_inst/gig_ethernet_pcs_pma_SFP2_gt_i/inst/gen_gtwizard_gtye4_top.gig_ethernet_pcs_pma_SFP2_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXOUTCLK}]]
#set_false_path -from [get_clocks -of_objects [get_pins {gen_SiTCP[0].u_network_inst/dut/core_support_i/core_clocking_i/usrclk_bufg_inst/O}]] -to [get_clocks -of_objects [get_pins {gen_SiTCP[0].u_network_inst/dut/core_support_i/pcs_pma_i/inst/transceiver_inst/gig_ethernet_pcs_pma_SFP2_gt_i/inst/gen_gtwizard_gtye4_top.gig_ethernet_pcs_pma_SFP2_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
#set_false_path -from [get_clocks -of_objects [get_pins {gen_SiTCP[0].u_network_inst/dut/core_support_i/pcs_pma_i/inst/transceiver_inst/gig_ethernet_pcs_pma_SFP2_gt_i/inst/gen_gtwizard_gtye4_top.gig_ethernet_pcs_pma_SFP2_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXOUTCLK}]] -to [get_clocks -of_objects [get_pins {gen_SiTCP[0].u_network_inst/dut/core_support_i/pcs_pma_i/inst/transceiver_inst/gig_ethernet_pcs_pma_SFP2_gt_i/inst/gen_gtwizard_gtye4_top.gig_ethernet_pcs_pma_SFP2_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
