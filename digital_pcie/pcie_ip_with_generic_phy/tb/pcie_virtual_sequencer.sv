`ifndef PCIE_VIRTUAL_SEQUENCER
`define PCIE_VIRTUAL_SEQUENCER

class pcie_virtual_sequencer extends uvm_sequencer;

    `uvm_component_utils(pcie_virtual_sequencer)

    svt_pcie_device_virtual_sequencer root_vir_sqr;

    extern function new(string name="pcie_virtual_sequencer", uvm_component parent=null);
endclass

function pcie_virtual_sequencer :: new(string name="pcie_virtual_sequencer", uvm_component parent=null);
    super.new(name, parent);
endfunction

`endif