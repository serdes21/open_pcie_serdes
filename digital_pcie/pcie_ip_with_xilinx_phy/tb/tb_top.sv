`timescale 1ns/1ps
`include "tb_include.sv"

module tb_top;

    bit reset;

    `include "dut_instance/interface.sv";
    `include "dut_instance/pcie_dut.sv";

    `include "vip_instance/hdl_interconnect_macros.sv";
    `include "vip_instance/u_pcie_vip.sv";

    pciesvc_global_shadow #(.DISPLAY_NAME("global_shadow0.")) global_shadow0();

    `define EXPERTIO_PCIESVC_GLOBAL_SHADOW_PATH tb_top.global_shadow0

    initial begin
        reset = 1;
        #200;
        reset = 0;
    end

    initial begin
        repeat (100) #0;
        run_test();
    end



    initial begin
        #1000;
    end



    initial begin
        $fsdbDumpfile("pcie.fsdb");
        $fsdbDumpvars(0, tb_top);
        $fsdbDumpMDA(0, tb_top);
    end

    initial begin
        uvm_config_db#(virtual clk_reset_interface)::set(uvm_root::get(), "uvm_test_top.u_clk_reset_module", "clk_reset_interface", u_clk_reset_interface);
        uvm_config_db#(virtual powerup_interface)::set(uvm_root::get(), "uvm_test_top.u_power_up_module", "powerup_interface", u_powerup_interface);
    end

endmodule
