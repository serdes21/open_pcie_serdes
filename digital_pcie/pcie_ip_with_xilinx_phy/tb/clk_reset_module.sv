`ifndef CLK_RESET_MODULE_SV
`define CLK_RESET_MODULE_SV


class clk_reset_module extends uvm_component;
    `uvm_component_utils(clk_reset_module)

    virtual interface clk_reset_interface u_clk_reset_interface;

    extern function new(string name="clk_reset_module", uvm_component parent=null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
endclass


function clk_reset_module :: new(string name="clk_reset_module", uvm_component parent=null);
    super.new(name, parent);
endfunction

function void clk_reset_module :: build_phase(uvm_phase phase);
    `uvm_info("build_phase", "Enterned...", UVM_LOW)
    if(!uvm_config_db#(virtual clk_reset_interface)::get(this, "", "clk_reset_interface", u_clk_reset_interface)) begin
        `uvm_fatal("build_phase", "clk_reset_interface not set")
    end


    `uvm_info("build_phase", "Exiting...", UVM_LOW);
endfunction


task clk_reset_module ::  main_phase(uvm_phase phase);
    `uvm_info("main_phase", "Enterned...", UVM_LOW)
    fork
        begin
            forever begin
            u_clk_reset_interface.refclk_p <= 0;
            u_clk_reset_interface.refclk_n <= 1;
            #5;
            u_clk_reset_interface.refclk_p <= 1;
            u_clk_reset_interface.refclk_n <= 0;
            #5;
            end
        end



        begin
             u_clk_reset_interface.reset_n <= 1;
             #10;
             u_clk_reset_interface.reset_n <= 0;
             #150;
             u_clk_reset_interface.reset_n <= 1;
        end
    join

    `uvm_info("main_phase", "Exiting...", UVM_LOW)
endtask


`endif