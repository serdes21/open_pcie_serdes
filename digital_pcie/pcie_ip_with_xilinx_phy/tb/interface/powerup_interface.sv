interface powerup_interface #()(
    input reset_n,
    input core_clk
);
    logic app_ltssm_enable;
    logic app_hold_phy_rst;

    modport dut(
        input app_ltssm_enable,
        input app_hold_phy_rst
    );

endinterface