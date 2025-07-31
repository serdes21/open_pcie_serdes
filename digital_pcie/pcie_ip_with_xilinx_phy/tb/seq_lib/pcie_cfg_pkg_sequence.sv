`ifndef PCIE_CFG_PKG_SEQUENCE_SV
`define PCIE_CFG_PKG_SEQUENCE_SV

class pcie_cfg_pkg_sequence extends uvm_sequence;

    `uvm_object_utils(pcie_cfg_pkg_sequence)

    `uvm_declare_p_sequencer(pcie_virtual_sequencer)

    svt_pcie_driver_app_cfg_request_sequence cfg_request_seq;

    extern function new(string name="pcie_cfg_pkg_sequence");
    extern task body();
endclass

function pcie_cfg_pkg_sequence :: new(string name="pcie_cfg_pkg_sequence");
    super.new(name);
endfunction

task pcie_cfg_pkg_sequence :: body();

    bit [31:0] addr;
    bit [31:0] data;
    bit [7:0] bus_num;
    bit [4:0] device_num;
    bit [2:0] function_num;

    cfg_request_seq = svt_pcie_driver_app_cfg_request_sequence :: type_id :: create("cfg_request_seq");
    bus_num = $urandom_range(1, 10);
    device_num = 0;
    function_num = 0;

    cfg_request_seq.bdf = { bus_num, device_num, function_num };
    cfg_request_seq.register_number = addr[11:2];
    cfg_request_seq.first_dw_be = 4'b111;
    cfg_request_seq.cfg_type = 0;
    cfg_request_seq.block = 1;
    cfg_request_seq.transaction_type = svt_pcie_driver_app_transaction::CFG_RD;

    cfg_request_seq.start(p_sequencer.root_vir_sqr.driver_transaction_seqr[0]);

    data = cfg_request_seq.req.payload[0];
    `uvm_info("pcie_cfg_pkg_sequence", $sformatf("addr:0x%0h, data:0x%0h", addr, data), UVM_LOW)
endtask


`endif