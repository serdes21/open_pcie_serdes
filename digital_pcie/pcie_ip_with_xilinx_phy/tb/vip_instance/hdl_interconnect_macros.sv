
`ifndef GUARD_HDL_INTERCONNECT_MACROS
 `define GUARD_HDL_INTERCONNECT_MACROS
/**
 * Abstract:
 * Interconnect Macro (ICM) definitions that are used to simplify VIP
 * instance creation, and link formation while testing controller DUT.
 */

/* Unified interface instances can be reset independently using the nodes defined within
   their scope. At power on since all interfaces must be reset we use a common signal
   to trigger the reset. It's logically same as the reset node test_top.sv
 */
tri0 common_pwr_on_reset = reset ? 1'b1 : 1'bz;

/* Multi bit clkreq_n pull ups. One bit for each link */
tri1 [31:0] clkreq_n; 

/* Bit wake_n pull ups. */
tri1 wake_n; 

// The following macros serve as starting point for cutomers to develop their own macro
// for VIP instance creation.
// It is recommended that the default values used for Parameters listed below should be
// in line with the common settings across all/most of their instances. This approach
// will ensure minimum number of lines in topology files invoking these macros.

`define SVT_PCIE_ICM_CREATE_PORT_INST(link_num, port_num) \
  parameter SVT_PCIE_UI_PCIE_SPEC_VER_P``port_num`` = `SVT_PCIE_UI_PCIE_SPEC_VER_3_0; \
  parameter SVT_PCIE_UI_PIPE_SPEC_VER_P``port_num`` = `SVT_PCIE_UI_PIPE_SPEC_VER_4_3; \
  parameter SVT_PCIE_UI_NUM_PHYSICAL_LANES_P``port_num`` = 32; \
  parameter SVT_PCIE_UI_NUM_PMA_INTERFACE_BITS_P``port_num`` = 10; \
`ifdef SVT_PCIE_PIPE_DATA_WIDTH \
  parameter SVT_PCIE_UI_NUM_PIPE_INTERFACE_BITS_P``port_num`` = `SVT_PCIE_PIPE_DATA_WIDTH; \
`else \
  parameter SVT_PCIE_UI_NUM_PIPE_INTERFACE_BITS_P``port_num`` = 32; \
`endif \
  parameter SVT_PCIE_UI_HIERARCHY_NUMBER_P``port_num`` = 0; \
  parameter SVT_PCIE_UI_MPIPE_P``port_num`` = 1;  \
  parameter SVT_PCIE_UI_PHY_INTERFACE_TYPE_P``port_num`` = `SVT_PCIE_UI_PHY_INTERFACE_TYPE_SERDES; \
  parameter SVT_PCIE_UI_MON_PHY_INTERFACE_TYPE_P``port_num`` = `SVT_PCIE_UI_PHY_INTERFACE_TYPE_SERDES; \
  parameter SVT_PCIE_UI_DEVICE_IS_ROOT_P``port_num`` = 1;    /*behave as a root complex  */ \
  parameter SVT_PCIE_UI_ENABLE_SHADOW_MEMORY_CHECKING_P``port_num`` = 0;  /*If set, applications will check memory reads againsshadow memory*/ \
  parameter SVT_PCIE_UI_ENABLE_CFG_BLOCK_P``port_num`` = 1; \
  parameter SVT_PCIE_UI_DUT_IN_V2V_CTL_TB_P``port_num`` = 0;  /*Ignore this parameter, will be deprecated in future */ \
  parameter SVT_PCIE_UI_CONNECT_ACTIVE_VIP_P``port_num`` = 1; \
  parameter SVT_PCIE_UI_PIPE_CLK_FROM_MAC_P``port_num`` = 1'b0; \
  parameter SVT_PCIE_UI_TRANSMIT_BIT_CLOCK_MODE_P``port_num`` = 1'b1; \
  parameter SVT_PCIE_UI_ENABLE_IO_SKEW_P``port_num`` = 1'b0; \
  parameter realtime SVT_PCIE_UI_SETUP_PS_P``port_num`` = 10ps; \
  parameter realtime SVT_PCIE_UI_HOLD_PS_P``port_num`` = 5ps; \
  svt_pcie_if port_if_``port_num``(clkreq_n[link_num], wake_n); \
  svt_pcie_single_port_device_agent_hdl spd_``port_num``(port_if_``port_num``); \
  localparam string port_num_string_``port_num`` = `"port_num`"; \
  defparam spd_``port_num``.SVT_PCIE_UI_DISPLAY_NAME = {"spd_",port_num_string_``port_num``,"."}; \
  defparam spd_``port_num``.SVT_PCIE_UI_ENABLE_CFG_BLOCK = SVT_PCIE_UI_ENABLE_CFG_BLOCK_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_PCIE_SPEC_VER = SVT_PCIE_UI_PCIE_SPEC_VER_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_PIPE_SPEC_VER = SVT_PCIE_UI_PIPE_SPEC_VER_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_NUM_PHYSICAL_LANES = SVT_PCIE_UI_NUM_PHYSICAL_LANES_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_NUM_PMA_INTERFACE_BITS = SVT_PCIE_UI_NUM_PMA_INTERFACE_BITS_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_NUM_PIPE_INTERFACE_BITS = SVT_PCIE_UI_NUM_PIPE_INTERFACE_BITS_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_HIERARCHY_NUMBER = SVT_PCIE_UI_HIERARCHY_NUMBER_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_MPIPE = SVT_PCIE_UI_MPIPE_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_PHY_INTERFACE_TYPE = SVT_PCIE_UI_PHY_INTERFACE_TYPE_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_DEVICE_IS_ROOT = SVT_PCIE_UI_DEVICE_IS_ROOT_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_ENABLE_SHADOW_MEMORY_CHECKING = SVT_PCIE_UI_ENABLE_SHADOW_MEMORY_CHECKING_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_DUT_IN_V2V_CTL_TB = SVT_PCIE_UI_DUT_IN_V2V_CTL_TB_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_CONNECT_ACTIVE_VIP = SVT_PCIE_UI_CONNECT_ACTIVE_VIP_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_PIPE_CLK_FROM_MAC = SVT_PCIE_UI_PIPE_CLK_FROM_MAC_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_TRANSMIT_BIT_CLOCK_MODE = SVT_PCIE_UI_TRANSMIT_BIT_CLOCK_MODE_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_ENABLE_IO_SKEW = SVT_PCIE_UI_ENABLE_IO_SKEW_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_SETUP_PS = SVT_PCIE_UI_SETUP_PS_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_HOLD_PS = SVT_PCIE_UI_HOLD_PS_P``port_num``; \
  defparam spd_``port_num``.SVT_PCIE_UI_MON_PHY_INTERFACE_TYPE = SVT_PCIE_UI_MON_PHY_INTERFACE_TYPE_P``port_num``; \

// The following macro takes care of forming a link using 2 instances of interface objects connected to VIP.
// The link is uniquely identified using link_id argument. It also invokes the  uvm_config_db calls
// (via update_if_variables) to pass the virtual interface handles to the class world.
`ifndef SVT_PCIE_CONFIGURE_DUT_MODEL_RTL
  `define SVT_PCIE_ICM_CREATE_LINK(link_id, spd_a, spd_b) \
    initial begin \
      spd_a.update_if_variables(4'h0, link_id, "uvm_test_top", "uvm_test_top"); \
      spd_b.update_if_variables(4'h1, link_id, "uvm_test_top", "uvm_test_top"); \
    end
`else
  `define SVT_PCIE_ICM_CREATE_LINK(link_id, spd_a) \
    initial begin \
      spd_a.update_if_variables(4'h0, link_id, "uvm_test_top", "uvm_test_top"); \
    end
`endif

`define SVT_PCIE_ICM_DO_CONDITIONAL_INTERCONNECT(spd_a_port_num,spd_a,spd_b_port_num,spd_b) \
  generate begin \
    if (SVT_PCIE_UI_PHY_INTERFACE_TYPE_P``spd_a_port_num`` == PHY_INTERFACE_TYPE_APP) begin  \
     assign spd_a.vip_port_if.app_if.reset     = common_pwr_on_reset; \
     assign spd_a.vip_port_if.app_if.appl_clk  = spd_b.vip_port_if.app_if.appl_clk; \
    end \
    if (SVT_PCIE_UI_PHY_INTERFACE_TYPE_P``spd_b_port_num`` == PHY_INTERFACE_TYPE_APP) begin  \
      assign spd_b.vip_port_if.app_if.reset     = common_pwr_on_reset; \
      assign spd_b.vip_port_if.app_if.appl_clk  = spd_a.vip_port_if.app_if.appl_clk; \
    end \
    if ((SVT_PCIE_UI_PIPE_CLK_FROM_MAC_P``spd_a_port_num`` && SVT_PCIE_UI_MPIPE_P``spd_a_port_num``) || \
        (!SVT_PCIE_UI_PIPE_CLK_FROM_MAC_P``spd_a_port_num`` && !SVT_PCIE_UI_MPIPE_P``spd_a_port_num``)) begin  \
      assign spd_b.vip_port_if.pipe_if.pclk     = spd_a.vip_port_if.pipe_if.pclk; \
    end else begin \
      assign spd_a.vip_port_if.pipe_if.pclk     = spd_b.vip_port_if.pipe_if.pclk; \
    end \
  end endgenerate \
  
  
// The following macro need not be invoked by the user directly as it is used as a building block to cross connenct
// mpipe and spipe individual lane signals.
`define SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spie8_if, mpie8_if, spipe_if, mpipe_if, ln_num) \
  assign spipe_if.rx_eq_in_progress_``ln_num`` =  mpipe_if.rx_eq_in_progress_``ln_num`` ; \
  assign spipe_if.lf_``ln_num`` = mpipe_if.lf_``ln_num``; \
  assign spipe_if.fs_``ln_num`` = mpipe_if.fs_``ln_num``; \
  assign mpipe_if.rx_data_``ln_num`` = spipe_if.rx_data_``ln_num``; \
  assign mpipe_if.rx_data_k_``ln_num`` = spipe_if.rx_data_k_``ln_num``; \
  assign mpipe_if.rx_status_``ln_num`` = spipe_if.rx_status_``ln_num``; \
  assign mpipe_if.rx_valid_``ln_num`` = spipe_if.rx_valid_``ln_num``; \
  assign mpipe_if.rx_data_valid_``ln_num`` = spipe_if.rx_data_valid_``ln_num``; \
  assign mpipe_if.rx_elec_idle_``ln_num`` = spipe_if.rx_elec_idle_``ln_num``; \
  assign mpipe_if.rx_start_block_``ln_num`` = spipe_if.rx_start_block_``ln_num``; \
  assign mpipe_if.rx_sync_header_``ln_num`` = spipe_if.rx_sync_header_``ln_num``; \
  assign mpipe_if.local_tx_preset_coefficients_``ln_num`` = spipe_if.local_tx_preset_coefficients_``ln_num``; \
  assign mpipe_if.link_evaluation_feedback_figure_merit_``ln_num`` = spipe_if.link_evaluation_feedback_figure_merit_``ln_num``; \
  assign mpipe_if.link_evaluation_feedback_direction_change_``ln_num`` = spipe_if.link_evaluation_feedback_direction_change_``ln_num``; \
  assign mpipe_if.local_fs_``ln_num`` = spipe_if.local_fs_``ln_num``; \
  assign mpipe_if.local_lf_``ln_num``  = spipe_if.local_lf_``ln_num``; \
  assign mpipe_if.local_tx_coefficients_valid_``ln_num``  = spipe_if.local_tx_coefficients_valid_``ln_num``; \
  assign mpipe_if.phy_status_``ln_num`` = spipe_if.phy_status_``ln_num`` ; \
  assign mpipe_if.rx_standby_status_``ln_num`` = spipe_if.rx_standby_status_``ln_num`` ; \
  assign spipe_if.rx_polarity_``ln_num`` = mpipe_if.rx_polarity_``ln_num``; \
  assign spipe_if.tx_data_``ln_num`` = mpipe_if.tx_data_``ln_num``; \
  assign spipe_if.tx_data_k_``ln_num`` = mpipe_if.tx_data_k_``ln_num``; \
  assign spipe_if.tx_ei_code_``ln_num`` = mpipe_if.tx_ei_code_``ln_num``; \
  assign spipe_if.tx_compliance_``ln_num`` = mpipe_if.tx_compliance_``ln_num``; \
  assign spipe_if.tx_elec_idle_``ln_num`` = mpipe_if.tx_elec_idle_``ln_num``; \
  assign spipe_if.tx_data_valid_``ln_num`` = mpipe_if.tx_data_valid_``ln_num``; \
  assign spipe_if.tx_start_block_``ln_num`` = mpipe_if.tx_start_block_``ln_num``; \
  assign spipe_if.tx_sync_header_``ln_num`` = mpipe_if.tx_sync_header_``ln_num``; \
  assign spipe_if.tx_deemph_``ln_num`` = mpipe_if.tx_deemph_``ln_num``; \
  assign spipe_if.local_preset_index_``ln_num`` = mpipe_if.local_preset_index_``ln_num``; \
  assign spipe_if.rx_preset_hint_``ln_num`` = mpipe_if.rx_preset_hint_``ln_num``; \
  assign spipe_if.get_local_preset_coefficients_``ln_num`` = mpipe_if.get_local_preset_coefficients_``ln_num``; \
  assign spipe_if.rx_eq_eval_``ln_num`` = mpipe_if.rx_eq_eval_``ln_num``; \
  assign spipe_if.invalid_request_``ln_num`` = mpipe_if.invalid_request_``ln_num``; \
  assign spipe_if.pclk_``ln_num`` = mpipe_if.pclk;  \
  assign spipe_if.rx_standby_``ln_num``  = mpipe_if.rx_standby_``ln_num``; \
  assign spipe_if.m2p_message_bus_``ln_num``  = mpipe_if.m2p_message_bus_``ln_num``; \
  assign spipe_if.phy_mode_``ln_num``  = mpipe_if.phy_mode_``ln_num``; \
  assign spipe_if.sris_enable_``ln_num``  = mpipe_if.sris_enable_``ln_num``; \
  assign mpipe_if.p2m_message_bus_``ln_num``  = spipe_if.p2m_message_bus_``ln_num``; \
  assign spie8_if.mac_data_``ln_num``  = mpie8_if.mac_data_``ln_num``; \
  assign spie8_if.mac_data_en_``ln_num``  = mpie8_if.mac_data_en_``ln_num``; \
  assign mpie8_if.phy_data_``ln_num``  = spie8_if.phy_data_``ln_num``; \
  assign mpie8_if.phy_data_en_``ln_num``  = spie8_if.phy_data_en_``ln_num``; \

// The following macro need not be invoked by the user directly as it is used as a building block to cross connenct
// mpipe and spipe shared signals.
`define SVT_PCIE_ICM_PIPE_PIPE_COMMON_CODE(link_id, spipe_inst, mpipe_inst) \
  assign mpipe_inst.vip_port_if.pipe_if.max_pclk = spipe_inst.vip_port_if.pipe_if.max_pclk; \
  assign mpipe_inst.vip_port_if.pipe_if.reset = common_pwr_on_reset;  \
  assign spipe_inst.vip_port_if.pipe_if.reset = common_pwr_on_reset;  \
  assign spipe_inst.vip_port_if.pipe_if.pclk_change_ack = mpipe_inst.vip_port_if.pipe_if.pclk_change_ack;  \
  assign mpipe_inst.vip_port_if.pipe_if.pclk_change_ok = spipe_inst.vip_port_if.pipe_if.pclk_change_ok;  \
  assign spipe_inst.vip_port_if.pipe_if.pipe_reset_n = mpipe_inst.vip_port_if.pipe_if.pipe_reset_n; \
  assign mpipe_inst.vip_port_if.pipe_if.data_bus_width = spipe_inst.vip_port_if.pipe_if.data_bus_width ;\
  assign spipe_inst.vip_port_if.pipe_if.power_down  = mpipe_inst.vip_port_if.pipe_if.power_down; \
  assign spipe_inst.vip_port_if.pipe_if.rate  = mpipe_inst.vip_port_if.pipe_if.rate; \
  assign spipe_inst.vip_port_if.pipe_if.pclk_rate  = mpipe_inst.vip_port_if.pipe_if.pclk_rate; \
  assign spipe_inst.vip_port_if.pipe_if.tx_detect_rx  = mpipe_inst.vip_port_if.pipe_if.tx_detect_rx; \
  assign spipe_inst.vip_port_if.pipe_if.block_align_control  = mpipe_inst.vip_port_if.pipe_if.block_align_control; \
  assign spipe_inst.vip_port_if.pipe_if.tx_margin  = mpipe_inst.vip_port_if.pipe_if.tx_margin; \
  assign spipe_inst.vip_port_if.pipe_if.tx_swing  = mpipe_inst.vip_port_if.pipe_if.tx_swing; \
  assign spipe_inst.vip_port_if.pipe_if.width  = mpipe_inst.vip_port_if.pipe_if.width; \
  assign spipe_inst.vip_port_if.pipe_if.lf = mpipe_inst.vip_port_if.pipe_if.lf;   \
  assign spipe_inst.vip_port_if.pipe_if.fs = mpipe_inst.vip_port_if.pipe_if.fs; \
  assign spipe_inst.vip_port_if.pipe_if.async_power_change_ack = mpipe_inst.vip_port_if.pipe_if.async_power_change_ack; \
  assign spipe_inst.vip_port_if.pipe_if.rx_eidetect_disable = mpipe_inst.vip_port_if.pipe_if.rx_eidetect_disable; \
  assign spipe_inst.vip_port_if.pipe_if.tx_commonmode_disable = mpipe_inst.vip_port_if.pipe_if.tx_commonmode_disable;

// The following macro need not be invoked by the user directly as it is used as a building block to cross connenct
// Synopsys specific mpipe and spipe shared signals.
`define SVT_PCIE_ICM_SNPS_PIPE_COMMON_CODE(link_id, spipe_if, mpipe_if) \
  assign spipe_if.pclkreq_n = mpipe_if.pclkreq_n; \
  assign mpipe_if.pclkack_n = spipe_if.pclkack_n; \
  assign spipe_if.rxelecidle_disable = mpipe_if.rxelecidle_disable; \
  assign spipe_if.txcommonmode_disable = mpipe_if.txcommonmode_disable;
                              
// The following macro is used by user to cross connect signals of spipe interface
// with that of a mpipe interface
`define SVT_PCIE_ICM_PIPE_PIPE_LINK(link_id, spipe_inst, mpipe_inst) \
  `SVT_PCIE_ICM_PIPE_PIPE_COMMON_CODE(link_id, spipe_inst, mpipe_inst) \
  `SVT_PCIE_ICM_SNPS_PIPE_COMMON_CODE(link_id, spipe_inst.vip_port_if.snps_pipe_if, mpipe_inst.vip_port_if.snps_pipe_if) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 0) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 1) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 2) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 3) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 4) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 5) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 6) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 7) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 8) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 9) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 10) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 11) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 12) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 13) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 14) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 15) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 16) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 17) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 18) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 19) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 20) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 21) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 22) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 23) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 24) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 25) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 26) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 27) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 28) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 29) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 30) \
  `SVT_PCIE_ICM_PIPE_PIPE_PER_LANE_CODE(spipe_inst.vip_port_if.pie8_eq_if, mpipe_inst.vip_port_if.pie8_eq_if, spipe_inst.vip_port_if.pipe_if, mpipe_inst.vip_port_if.pipe_if, 31) \

// The following macro need not be invoked by the user directly as it is used as a building block to cross connenct
// serdes individual lane signals.
`define SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, ln_num) \
  assign ser_inst_a.vip_port_if.ser_if.rx_datap_``ln_num`` = ser_inst_b.vip_port_if.ser_if.tx_datap_``ln_num``; \
  assign ser_inst_a.vip_port_if.ser_if.rx_datan_``ln_num`` = ser_inst_b.vip_port_if.ser_if.tx_datan_``ln_num``; \
  assign ser_inst_a.vip_port_if.ser_if.rx_clk_``ln_num``   = ser_inst_b.vip_port_if.ser_if.active_tx_transmit_clk_``ln_num``; \
  assign ser_inst_a.vip_port_if.ser_if.tx_clk_``ln_num``   = ser_inst_b.vip_port_if.ser_if.active_rx_recovered_clk_``ln_num``; \
  assign ser_inst_b.vip_port_if.ser_if.rx_datap_``ln_num`` = ser_inst_a.vip_port_if.ser_if.tx_datap_``ln_num``; \
  assign ser_inst_b.vip_port_if.ser_if.rx_datan_``ln_num`` = ser_inst_a.vip_port_if.ser_if.tx_datan_``ln_num``; \
  assign ser_inst_b.vip_port_if.ser_if.rx_clk_``ln_num``   = ser_inst_a.vip_port_if.ser_if.active_tx_transmit_clk_``ln_num``; \
  assign ser_inst_b.vip_port_if.ser_if.tx_clk_``ln_num``   = ser_inst_a.vip_port_if.ser_if.active_rx_recovered_clk_``ln_num``;

// The following macro is used by user to cross connect signals of one serdes interface instance
// to another serdes interface instance
`define SVT_PCIE_ICM_SER_SER_LINK(link_id, ser_inst_a, ser_inst_b) \
  assign ser_inst_a.vip_port_if.ser_if.reset = common_pwr_on_reset;  \
  assign ser_inst_b.vip_port_if.ser_if.reset = common_pwr_on_reset;  \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 0) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 1) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 2) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 3) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 4) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 5) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 6) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 7) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 8) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 9) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 10) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 11) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 12) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 13) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 14) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 15) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 16) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 17) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 18) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 19) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 20) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 21) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 22) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 23) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 24) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 25) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 26) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 27) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 28) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 29) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 30) \
  `SVT_PCIE_ICM_SER_SER_IF_PER_LANE_CODE(ser_inst_a, ser_inst_b, 31) \

// The following macro need not be invoked by the user directly as it is used as a building block to cross connenct
// pma interface individual lane signals.
`define SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_if_a, pma_if_b, ln_num) \
  assign pma_if_a.rx_pma_data_``ln_num``  = pma_if_b.tx_pma_data_``ln_num``  ; \
  assign pma_if_a.rx_pma_clk_``ln_num``   = pma_if_b.tx_pma_clk_``ln_num``   ; \
  assign pma_if_a.rx_elec_idle_``ln_num`` = pma_if_b.tx_elec_idle_``ln_num`` ; \
  assign pma_if_b.rx_pma_data_``ln_num``  = pma_if_a.tx_pma_data_``ln_num``  ; \
  assign pma_if_b.rx_pma_clk_``ln_num``   = pma_if_a.tx_pma_clk_``ln_num``   ; \
  assign pma_if_b.rx_elec_idle_``ln_num`` = pma_if_a.tx_elec_idle_``ln_num`` ; \

// The following macro is used by user to cross connect signals of one pma interface instance
// with that of another pma interface instance
`define SVT_PCIE_ICM_PMA_PMA_LINK(link_id, pma_inst_a, pma_inst_b) \
  assign pma_inst_a.vip_port_if.pma_if.reset = common_pwr_on_reset;  \
  assign pma_inst_b.vip_port_if.pma_if.reset = common_pwr_on_reset;  \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 0) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 1) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 2) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 3) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 4) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 5) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 6) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 7) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 8) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 9) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 10) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 11) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 12) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 13) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 14) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 15) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 16) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 17) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 18) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 19) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 20) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 21) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 22) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 23) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 24) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 25) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 26) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 27) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 28) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 29) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 30) \
  `SVT_PCIE_ICM_PMA_PMA_IF_PER_LANE_CODE(pma_inst_a.vip_port_if.pma_if, pma_inst_b.vip_port_if.pma_if, 31) \

//added for gen5 pipe5 support
// The following macro need not be invoked by the user directly as it is used as a building block to cross connenct
// mpipe and spipe shared signals.
`define SVT_PCIE_ICM_PIPE5_PIPE5_COMMON_CODE(spipe_inst,mpipe_inst) \
 assign mpipe_inst.vip_port_if.`SVT_PCIE_PIPE_LPC_IF_INST.max_pclk = spipe_inst.vip_port_if.`SVT_PCIE_PIPE_LPC_IF_INST.max_pclk; \
 assign mpipe_inst.vip_port_if.`SVT_PCIE_PIPE_LPC_IF_INST.reset = common_pwr_on_reset;  \
 assign spipe_inst.vip_port_if.`SVT_PCIE_PIPE_LPC_IF_INST.reset = common_pwr_on_reset;  \
 assign spipe_inst.vip_port_if.`SVT_PCIE_PIPE_LPC_IF_INST.serdes_arch = mpipe_inst.vip_port_if.`SVT_PCIE_PIPE_LPC_IF_INST.serdes_arch; \



// The following macro need not be invoked by the user directly as it is used as a building block to cross connenct
// mpipe and spipe individual lane signals.
`define SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_vip_if,mpipe_vip_if,ln_num,pipe_clk_from_mac) \
   assign mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_data_``ln_num`` = spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_data_``ln_num``; \
   assign mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_data_k_``ln_num`` = spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_data_k_``ln_num``; \
   assign mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_status_``ln_num`` = spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_status_``ln_num``; \
   assign mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_sync_header_``ln_num`` = spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_sync_header_``ln_num``; \
   assign mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.p2m_message_bus_``ln_num`` = spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.p2m_message_bus_``ln_num`` ; \
   assign mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.data_bus_width_``ln_num`` = spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.data_bus_width_``ln_num`` ;\
   always@(*) spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_width_``ln_num``  = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_width_``ln_num``; \
   assign mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.pclk_change_ok_``ln_num`` = spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.pclk_change_ok_``ln_num``;  \
   assign mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_valid_``ln_num`` = spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_valid_``ln_num``; \
   assign mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_data_valid_``ln_num`` = spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_data_valid_``ln_num``; \
   assign mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_elec_idle_``ln_num`` = spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_elec_idle_``ln_num``; \
   assign mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_start_block_``ln_num`` = spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_start_block_``ln_num``; \
   assign mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.phy_status_``ln_num`` = spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.phy_status_``ln_num``; \
   assign mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_standby_status_``ln_num`` = spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_standby_status_``ln_num``; \
   assign mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.refclk_required_n_``ln_num`` = spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.refclk_required_n_``ln_num``; \
   assign mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rxclk_``ln_num`` = spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rxclk_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.tx_data_``ln_num`` = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.tx_data_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.tx_data_k_``ln_num`` = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.tx_data_k_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.tx_elec_idle_``ln_num`` = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.tx_elec_idle_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.tx_sync_header_``ln_num`` = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.tx_sync_header_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.m2p_message_bus_``ln_num``  = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.m2p_message_bus_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.sris_enable_``ln_num``  = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.sris_enable_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.power_down_``ln_num``  = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.power_down_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rate_``ln_num``  = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rate_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.pclk_rate_``ln_num``  = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.pclk_rate_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.width_``ln_num``  = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.width_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.phy_mode_``ln_num``  = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.phy_mode_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.pclk_change_ack_``ln_num`` = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.pclk_change_ack_``ln_num``;  \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.pipe_reset_n_``ln_num`` = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.pipe_reset_n_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_eidetect_disable_``ln_num`` = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_eidetect_disable_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.tx_commonmode_disable_``ln_num`` = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.tx_commonmode_disable_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.txdetectrx_loopback_``ln_num``  = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.txdetectrx_loopback_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.async_power_change_ack_``ln_num`` = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.async_power_change_ack_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.tx_compliance_``ln_num`` = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.tx_compliance_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.tx_data_valid_``ln_num`` = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.tx_data_valid_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.tx_start_block_``ln_num`` = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.tx_start_block_``ln_num``; \
   assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_standby_``ln_num``  = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.rx_standby_``ln_num``; \
   generate begin \
     if (pipe_clk_from_mac == 1) begin \
       assign spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.pclk_``ln_num`` = mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.pclk_``ln_num``;  \
     end \
     else begin \
       assign mpipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.pclk_``ln_num`` = spipe_vip_if.`SVT_PCIE_PIPE_LPC_IF_INST.pclk_``ln_num``;  \
     end \
   end endgenerate \



// The following macro is used by user to cross connect signals of spipe interface
// with that of a mpipe interface
`define SVT_PCIE_ICM_PIPE5_PIPE5_LINK(spipe_inst,mpipe_inst,pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_COMMON_CODE(spipe_inst, mpipe_inst) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 0, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 1, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 2, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 3, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 4, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 5, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 6, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 7, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 8, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 9, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 10, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 11, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 12, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 13, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 14, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 15, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 16, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 17, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 18, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 19, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 20, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 21, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 22, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 23, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 24, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 25, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 26, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 27, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 28, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 29, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 30, pipe_clk_from_mac) \
      `SVT_PCIE_ICM_PIPE5_PIPE5_PER_LANE_CODE(spipe_inst.vip_port_if , mpipe_inst.vip_port_if , 31, pipe_clk_from_mac) \



`endif //  `ifndef GUARD_HDL_INTERCONNECT_MACROS
