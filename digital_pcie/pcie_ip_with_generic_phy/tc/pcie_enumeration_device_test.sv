`ifndef PCIE_ENUMERATION_DEVICE_TEST_SV
`define PCIE_ENUMERATION_DEVICE_TEST_SV

class pcie_enumeration_device_test extends pcie_base_test;

    `uvm_component_utils(pcie_enumeration_device_test)



    extern function new(string name="pcie_enumeration_device_test", uvm_component parent=null);
    extern task main_phase(uvm_phase phase);

endclass

function pcie_enumeration_device_test :: new(string name="pcie_enumeration_device_test", uvm_component parent=null);
    super.new(name, parent);
endfunction


task pcie_enumeration_device_test ::  main_phase(uvm_phase phase);
    svt_pcie_dl_service_set_link_en_sequence link_en_seq;
    enumeration_device_sequence u_enumeration_device_sequence;

    `uvm_info("main_phase", "Enterned...", UVM_LOW)

    phase.raise_objection(this);

    link_en_seq = new();
    link_en_seq.enable = 1;
    link_en_seq.start(u_pcie_virtual_sequencer.root_vir_sqr.pcie_virt_seqr.dl_seqr);

    wait (u_pcie_env.root.status.pcie_status.pl_status.link_up == 1'b1);

    wait (u_pcie_env.root.status.pcie_status.pl_status.ltssm_state == svt_pcie_types::L0);

    wait (u_pcie_env.root.status.pcie_status.pl_status.current_speed == svt_pcie_pl_status::SPEED_2_5G);

    wait (u_pcie_env.root.status.pcie_status.dl_status.dl_link_up == 1'b1);

    $display("=================================");
    `uvm_info("main_phase", "pcie vip link ip", UVM_LOW)
    $display("=================================");

    u_enumeration_device_sequence = new();
    u_enumeration_device_sequence.start(u_pcie_virtual_sequencer);


    phase.drop_objection(this);

    `uvm_info("main_phase", "Exiting...", UVM_LOW)
endtask
`endif