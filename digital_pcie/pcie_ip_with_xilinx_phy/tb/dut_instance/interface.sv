
wire reset_n;

clk_reset_interface u_clk_reset_interface();

powerup_interface     u_powerup_interface     (.reset_n(reset_n),  .core_clk(u_clk_reset_interface.refclk_p));
serdes_interface      u_serdes_interface    ();




assign   reset_n   = u_clk_reset_interface.reset_n;

