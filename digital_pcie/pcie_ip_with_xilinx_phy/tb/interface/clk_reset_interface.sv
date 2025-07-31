interface clk_reset_interface #()();

    logic core_clk;
    logic core_rst_n;

    logic refclk_p;
    logic refclk_n;

    logic reset_n;


    modport dut(
        output core_clk,
        output core_rst_n,

        input refclk_p,
        input refclk_n,

        input reset_n
    );

endinterface