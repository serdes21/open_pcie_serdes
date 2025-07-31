// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.1 (lin64) Build 3865809 Sun May  7 15:04:56 MDT 2023
// Date        : Wed May 21 14:30:45 2025
// Host        : negoten2-virtual-machine running 64-bit Ubuntu 22.04.5 LTS
// Command     : write_verilog -force -mode synth_stub -rename_top pcie_phy_0 -prefix
//               pcie_phy_0_ pcie_phy_0_stub.v
// Design      : pcie_phy_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xcvu3p-ffvc1517-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "pcie_phy_0_core_top,Vivado 2023.1" *)
module pcie_phy_0(phy_refclk, phy_gtrefclk, phy_rst_n, 
  phy_txdata, phy_txdatak, phy_txdata_valid, phy_txstart_block, phy_txsync_header, phy_rxp, 
  phy_rxn, phy_txdetectrx, phy_txelecidle, phy_txcompliance, phy_rxpolarity, phy_powerdown, 
  phy_rate, phy_txmargin, phy_txswing, phy_txdeemph, phy_txeq_ctrl, phy_txeq_preset, 
  phy_txeq_coeff, phy_rxeq_ctrl, phy_rxeq_txpreset, as_mac_in_detect, as_cdr_hold_req, 
  phy_coreclk, phy_userclk, phy_mcapclk, phy_pclk, phy_txp, phy_txn, phy_rxdata, phy_rxdatak, 
  phy_rxdata_valid, phy_rxstart_block, phy_rxsync_header, phy_rxvalid, phy_phystatus, 
  phy_phystatus_rst, phy_rxelecidle, phy_rxstatus, phy_txeq_fs, phy_txeq_lf, 
  phy_txeq_new_coeff, phy_txeq_done, phy_rxeq_preset_sel, phy_rxeq_new_txcoeff, 
  phy_rxeq_adapt_done, phy_rxeq_done, gt_gtpowergood)
/* synthesis syn_black_box black_box_pad_pin="phy_gtrefclk,phy_rst_n,phy_txdata[63:0],phy_txdatak[1:0],phy_txdata_valid[0:0],phy_txstart_block[0:0],phy_txsync_header[1:0],phy_rxp[0:0],phy_rxn[0:0],phy_txdetectrx,phy_txelecidle[0:0],phy_txcompliance[0:0],phy_rxpolarity[0:0],phy_powerdown[1:0],phy_rate[1:0],phy_txmargin[2:0],phy_txswing,phy_txdeemph,phy_txeq_ctrl[1:0],phy_txeq_preset[3:0],phy_txeq_coeff[5:0],phy_rxeq_ctrl[1:0],phy_rxeq_txpreset[3:0],as_mac_in_detect,as_cdr_hold_req,phy_txp[0:0],phy_txn[0:0],phy_rxdata[63:0],phy_rxdatak[1:0],phy_rxdata_valid[0:0],phy_rxstart_block[1:0],phy_rxsync_header[1:0],phy_rxvalid[0:0],phy_phystatus[0:0],phy_phystatus_rst,phy_rxelecidle[0:0],phy_rxstatus[2:0],phy_txeq_fs[5:0],phy_txeq_lf[5:0],phy_txeq_new_coeff[17:0],phy_txeq_done[0:0],phy_rxeq_preset_sel[0:0],phy_rxeq_new_txcoeff[17:0],phy_rxeq_adapt_done[0:0],phy_rxeq_done[0:0],gt_gtpowergood[0:0]" */
/* synthesis syn_force_seq_prim="phy_refclk" */
/* synthesis syn_force_seq_prim="phy_coreclk" */
/* synthesis syn_force_seq_prim="phy_userclk" */
/* synthesis syn_force_seq_prim="phy_mcapclk" */
/* synthesis syn_force_seq_prim="phy_pclk" */;
  input phy_refclk /* synthesis syn_isclock = 1 */;
  input phy_gtrefclk;
  input phy_rst_n;
  input [63:0]phy_txdata;
  input [1:0]phy_txdatak;
  input [0:0]phy_txdata_valid;
  input [0:0]phy_txstart_block;
  input [1:0]phy_txsync_header;
  input [0:0]phy_rxp;
  input [0:0]phy_rxn;
  input phy_txdetectrx;
  input [0:0]phy_txelecidle;
  input [0:0]phy_txcompliance;
  input [0:0]phy_rxpolarity;
  input [1:0]phy_powerdown;
  input [1:0]phy_rate;
  input [2:0]phy_txmargin;
  input phy_txswing;
  input phy_txdeemph;
  input [1:0]phy_txeq_ctrl;
  input [3:0]phy_txeq_preset;
  input [5:0]phy_txeq_coeff;
  input [1:0]phy_rxeq_ctrl;
  input [3:0]phy_rxeq_txpreset;
  input as_mac_in_detect;
  input as_cdr_hold_req;
  output phy_coreclk /* synthesis syn_isclock = 1 */;
  output phy_userclk /* synthesis syn_isclock = 1 */;
  output phy_mcapclk /* synthesis syn_isclock = 1 */;
  output phy_pclk /* synthesis syn_isclock = 1 */;
  output [0:0]phy_txp;
  output [0:0]phy_txn;
  output [63:0]phy_rxdata;
  output [1:0]phy_rxdatak;
  output [0:0]phy_rxdata_valid;
  output [1:0]phy_rxstart_block;
  output [1:0]phy_rxsync_header;
  output [0:0]phy_rxvalid;
  output [0:0]phy_phystatus;
  output phy_phystatus_rst;
  output [0:0]phy_rxelecidle;
  output [2:0]phy_rxstatus;
  output [5:0]phy_txeq_fs;
  output [5:0]phy_txeq_lf;
  output [17:0]phy_txeq_new_coeff;
  output [0:0]phy_txeq_done;
  output [0:0]phy_rxeq_preset_sel;
  output [17:0]phy_rxeq_new_txcoeff;
  output [0:0]phy_rxeq_adapt_done;
  output [0:0]phy_rxeq_done;
  output [0:0]gt_gtpowergood;
endmodule
