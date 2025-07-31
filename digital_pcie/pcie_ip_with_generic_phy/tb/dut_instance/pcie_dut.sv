
pcie_ep u_pcie_ep(
    .reset_n          (u_clk_reset_interface.reset_n       ),
    .app_ltssm_enable (u_powerup_interface.app_ltssm_enable ),
    .app_hold_phy_rst (u_powerup_interface.app_hold_phy_rst ),

    .rxp               (u_serdes_interface.rxp              ),
    .rxn              (u_serdes_interface.rxn              ),
    .txp              (u_serdes_interface.txp              ),
    .txn              (u_serdes_interface.txn              ),
    .rxpresent        (u_serdes_interface.rxpresent        ),


    .refclk_p         (u_clk_reset_interface.refclk_p      ),
    .refclk_n         (u_clk_reset_interface.refclk_n      )
);