`ifndef PCIE_BASE_TEST
`define PCIE_BASE_TEST


class pcie_base_test extends uvm_test;

    `uvm_component_utils(pcie_base_test)

    pcie_env u_pcie_env;
    pcie_virtual_sequencer u_pcie_virtual_sequencer;
    clk_reset_module u_clk_reset_module;
    power_up_module u_power_up_module;



    extern function new(string name="pcie_base_test", uvm_component parent=null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void final_phase(uvm_phase phase);

endclass

function pcie_base_test :: new(string name="pcie_base_test", uvm_component parent=null);
    super.new(name, parent);
endfunction

function void pcie_base_test :: build_phase(uvm_phase phase);
    `uvm_info("build_phase", "Entered...", UVM_LOW);
    super.build_phase(phase);

    u_pcie_env = pcie_env :: type_id :: create("u_pcie_env", this);
    u_pcie_virtual_sequencer = pcie_virtual_sequencer :: type_id :: create("u_pcie_virtual_sequencer", this);
    u_clk_reset_module = clk_reset_module :: type_id :: create("u_clk_reset_module", this);
    u_power_up_module = power_up_module :: type_id :: create("u_power_up_module", this);

    uvm_top.set_timeout(30ms);

    `uvm_info("build_phase", "Exiting...", UVM_LOW);
endfunction

function void pcie_base_test :: connect_phase(uvm_phase phase);
    `uvm_info("connect_phase", "Entered...", UVM_LOW);

    u_pcie_virtual_sequencer.root_vir_sqr = u_pcie_env.root.virt_seqr;

    `uvm_info("connect_phase", "Exiting...", UVM_LOW);
endfunction


function void pcie_base_test :: end_of_elaboration_phase(uvm_phase phase);
    `uvm_info("end_of_elaboration_phase", "Entered...", UVM_LOW);
    uvm_top.print_topology();
    `uvm_info("end_of_elaboration_phase", "Exiting...", UVM_LOW);
endfunction


function void pcie_base_test :: final_phase(uvm_phase phase);
    uvm_report_server svr;
    `uvm_info("final_phase", "Entered...",UVM_LOW)

    super.final_phase(phase);

    svr = uvm_report_server::get_server();

    if((svr.get_severity_count(UVM_FATAL) +
        svr.get_severity_count(UVM_ERROR) == 0))
      `uvm_info("final_phase", "\nSvtTestEpilog: Passed\n", UVM_LOW)
    else
      `uvm_info("final_phase", "\nSvtTestEpilog: Failed\n", UVM_LOW)

    `uvm_info("final_phase", "Exiting...", UVM_LOW)
  endfunction: final_phase


`endif