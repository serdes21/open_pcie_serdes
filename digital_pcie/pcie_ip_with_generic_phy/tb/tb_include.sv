import uvm_pkg::*;
`include "uvm_macros.svh";

`include "svt.uvm.pkg"
import svt_uvm_pkg::*;
`include "svt_pcie.uvm.pkg"
import svt_pcie_uvm_pkg::*;

`include "svc_util_parms.v"
`include "pciesvc_parms.v"
`include "svt_pcie_defines.svi"


// Interface include files
//`include "./interface/axi_master_interface.sv"
//`include "./interface/axi_slave_interface.sv"
`include "./interface/clk_reset_interface.sv"
// `include "./interface/dbi_interface.sv"
// `include "./interface/dma_interface.sv"
// `include "./interface/elbi_interface.sv"
// `include "./interface/flr_interface.sv"
// `include "./interface/msi_interface.sv"
`include "./interface/powerup_interface.sv"
`include "./interface/serdes_interface.sv"
// `include "./interface/vendor_msg_interface.sv"


`include "./tb/pcie_virtual_sequencer.sv"
`include "./tb/pcie_vip/pcie_env.sv"
`include "./tb/clk_reset_module.sv"
`include "./tb/power_up_module.sv"


`include "./tb/tb_macro.svh"
`include "./tb/seq_lib/pcie_cfg_pkg_sequence.sv"
`include "./tb/seq_lib/enumeration_device_sequence.sv"
`include "./tb/seq_lib/pcie_mem_pkg_sequence.sv"
`include "./tc/pcie_base_test.sv"
`include "./tc/pcie_link_up_test.sv"
`include "./tc/pcie_cfg_pkg_test.sv"
`include "./tc/pcie_enumeration_device_test.sv"
`include "./tc/pcie_mem_pkg_test.sv"
