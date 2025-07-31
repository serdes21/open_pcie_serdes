
pcie_ep u_pcie_ep(
    .reset_n          (u_clk_reset_interface.reset_n       ),

    .rxp               (u_serdes_interface.rxp              ),
    .rxn              (u_serdes_interface.rxn              ),
    .txp              (u_serdes_interface.txp              ),
    .txn              (u_serdes_interface.txn              ),


    .refclk_p         (u_clk_reset_interface.refclk_p      ),
    .refclk_n         (u_clk_reset_interface.refclk_n      )
);