`ifndef POWER_UP_MODULE_SV
`define POWER_UP_MODULE_SV

class power_up_module extends uvm_component;

    `uvm_component_utils(power_up_module)

    virtual powerup_interface u_powerup_interface;

    extern function new(string name="power_up_module", uvm_component parent=null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);

endclass


function power_up_module :: new(string name="power_up_module", uvm_component parent=null);
    super.new(name, parent);
endfunction

function void power_up_module :: build_phase(uvm_phase phase);
    `uvm_info("build_phase", "Enterned...", UVM_LOW)
    if(!uvm_config_db#(virtual powerup_interface)::get(this, "", "powerup_interface", u_powerup_interface)) begin
        `uvm_fatal("build_phase", "powerup_interface not set")
    end
    `uvm_info("build_phase", "Exiting...", UVM_LOW);
endfunction


task power_up_module ::  main_phase(uvm_phase phase);
    `uvm_info("main_phase", "Enterned...", UVM_LOW)
    
    @(posedge u_powerup_interface.reset_n);

    u_powerup_interface.app_ltssm_enable <= 0;
    u_powerup_interface.app_hold_phy_rst <= 1;

    repeat (50) @(posedge  u_powerup_interface.core_clk);

    u_powerup_interface.app_hold_phy_rst <= 0;

    repeat (50) @(posedge  u_powerup_interface.core_clk);
    u_powerup_interface.app_ltssm_enable <= 1;
    
    `uvm_info("main_phase", "Exiting...", UVM_LOW)
endtask
`endif