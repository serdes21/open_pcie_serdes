`ifndef U_PCIE_VIP_SV
`define U_PCIE_VIP_SV

    `SVT_PCIE_ICM_CREATE_PORT_INST(0, 0)

    initial begin
      spd_0.update_if_variables(4'h0, 0, "uvm_test_top", "uvm_test_top");
    end

    defparam SVT_PCIE_UI_PHY_INTERFACE_TYPE_P0 = `SVT_PCIE_UI_PHY_INTERFACE_TYPE_SERDES;
    defparam SVT_PCIE_UI_DEVICE_IS_ROOT_P0 = 1;
    defparam SVT_PCIE_UI_NUM_PHYSICAL_LANES_P0   = 1;

  // ----------- RX：VIP <- SERDES (对端 TX) -----------
  assign spd_0.vip_port_if.ser_if.rx_datap_0  = u_serdes_interface.txp[0];
  assign spd_0.vip_port_if.ser_if.rx_datan_0  = u_serdes_interface.txn[0];


  // ----------- TX：VIP -> SERDES (对端 RX) -----------
  assign u_serdes_interface.rxp[0] = spd_0.vip_port_if.ser_if.tx_datap_0;
  assign u_serdes_interface.rxn[0] = spd_0.vip_port_if.ser_if.tx_datan_0;

  assign u_serdes_interface.rxpresent = 1'b1;


  assign spd_0.vip_port_if.ser_if.reset = common_pwr_on_reset;

`endif