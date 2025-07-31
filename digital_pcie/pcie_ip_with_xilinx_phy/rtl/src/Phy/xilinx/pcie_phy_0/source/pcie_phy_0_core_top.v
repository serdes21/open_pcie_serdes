//-----------------------------------------------------------------------------
//
// (c) Copyright 2012-2012 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
//
// Project    : PCIE4 PHY IP Block 
// File       : pcie_phy_0_core_top.v
// Version    : 1.0 
//-----------------------------------------------------------------------------
/*****************************************************************************
** Description:
**    PCIe Gen4 PHY supports:
**       - Gen1: per-lane 16b @ 125MHz
**       - Gen2: per-lane 16b @ 250MHz
**       - Gen3: per-lane 32b @ 250Mhz
**       - Gen4: per-lane 64b @ 250MHz
**
******************************************************************************/
//--------------------------------------------------------------------------------------------------
//  Design :  PHY Wrapper
//  Module :  PHY Wrapper
//--------------------------------------------------------------------------------------------------

`timescale 1ps/1ps

`define AS_PHYREG(clk, reset, q, d, rstval)  \
   always @(posedge clk or posedge reset) begin \
      if (reset) \
         q  <= #(TCQ)   rstval;  \
      else  \
         q  <= #(TCQ)   d; \
   end

`define PHYREG(clk, reset, q, d, rstval)  \
   always @(posedge clk) begin \
      if (reset) \
         q  <= #(TCQ)   rstval;  \
      else  \
         q  <= #(TCQ)   d; \
   end

`define AS_FAST2SLOW(bit_width, rst_val, mod_name, fast_input, fast_clk, enable_input, mask_input, slow_reset, fast_reset, slow_clk, slow_output1, slow_output2)   \
   pcie_phy_0_gen4_fast2slow #(.WIDTH(bit_width), .ASYNC("TRUE"), .RST_1(rst_val), .TCQ(TCQ)) mod_name (.fast_bits(fast_input),  \
                                                                                             .fast_clk_i(fast_clk),   \
                                                                                             .enable_i(enable_input), \
                                                                                             .mask_bits(mask_input),  \
                                                                                             .mgmt_reset_fast_i(fast_reset),  \
                                                                                             .mgmt_reset_slow_i(slow_reset),  \
                                                                                             .slow_clk_i(slow_clk),   \
                                                                                             .slow_bits_ns(slow_output1),   \
                                                                                             .slow_bits_r(slow_output2));

`define FAST2SLOW(bit_width, rst_val, mod_name, fast_input, fast_clk, enable_input, mask_input, slow_reset, fast_reset, slow_clk, slow_output1, slow_output2)   \
   pcie_phy_0_gen4_fast2slow #(.WIDTH(bit_width), .ASYNC("FALSE"), .RST_1(rst_val), .TCQ(TCQ)) mod_name (.fast_bits(fast_input),  \
                                                                                              .fast_clk_i(fast_clk),   \
                                                                                              .enable_i(enable_input), \
                                                                                              .mask_bits(mask_input),  \
                                                                                              .mgmt_reset_fast_i(fast_reset),  \
                                                                                              .mgmt_reset_slow_i(slow_reset),  \
                                                                                              .slow_clk_i(slow_clk),   \
                                                                                              .slow_bits_ns(slow_output1),   \
                                                                                              .slow_bits_r(slow_output2));


module pcie_phy_0_core_top #(
   // MODEL PARAMETERS 
   parameter         COMPONENT_NAME            = "pcie_phy",
   parameter integer PHY_LANE                  = 8,
   parameter integer PL_LINK_CAP_MAX_LINK_WIDTH = PHY_LANE,
   parameter integer PHY_MAX_SPEED             = 3,
   parameter         PHY_REFCLK_FREQ           = 0,
   parameter integer PHY_CORECLK_FREQ          = 2,        // 1 = 250 MHz; 2 = 500 MHz
   parameter integer PHY_USERCLK_FREQ          = 3,        // 1 = 62.5 MHz; 2 = 125 MHz; 3 = 250 MHz; 4 = 500 MHz
   parameter         PLL_TYPE                  = "CPLL",
   parameter         PIPELINE_STAGES           = 0,
   parameter         REFCLK1_LOCATION          = "Bank_124_MGTRECLK0",
   parameter         PHY_ASYNC_EN              = "TRUE",
   parameter         TX_PRESET                 = 4,
   parameter         INS_LOSS_PROFILE          = "TRUE",
   parameter         GT_TYPE                   = "GTH",
   parameter         FPGA_FAMILY               = "US",     // "US" = UltraScale; "USM" = Diablo
   parameter         FPGA_XCVR                 = "H",      // "H" = GTH; "Y" = GTY; "Y64" = GTY-64b
   parameter         SILICON_VER_STR           = "Production",
   parameter         RX_DETECT                 = "DEFAULT",
   parameter         ASPM                      = "No_ASPM",
   parameter         PHY_DATA_WIDTH            = 64,
   parameter         EXT_CH_GT_DRP             = "FALSE",
   // Parameters
   parameter integer SHARED_LOGIC              = 1,
   parameter         GTWIZ_IN_CORE             = 1,
   parameter         GTCOM_IN_CORE             = 1,
   parameter         ULTRASCALE                = "FALSE",
   parameter         ULTRASCALE_PLUS           = "FALSE",
   parameter         VERSAL                    = "FALSE",
   parameter integer DW                        = 64,
   parameter integer PHY_MCAPCLK_FREQ          = 1,        // 1 = 62.5 MHz; 2 = 125 MHz
   parameter         PHY_SIM_EN                = "FALSE",  // "FALSE" = Normal; "TRUE"  = Simulation
   parameter integer PHY_GT_TXPRESET           = 0,        // Valid settings: 0 to 10
   parameter integer PHY_LP_TXPRESET           = TX_PRESET 
)  (                                                         
   // Clock & Reset
   input  wire                         phy_refclk,          
   input  wire                         phy_gtrefclk,     
   input  wire                         phy_rst_n,           
   
   output wire                         phy_coreclk, 
   output wire                         phy_userclk,                          
   output wire                         phy_mcapclk,                          
   output wire                         phy_pclk,  
  
   // TX Data 
   input  wire [(PHY_LANE*DW)-1:0]     phy_txdata,            
   input  wire [(PHY_LANE* 2)-1:0]     phy_txdatak,    
   input  wire [PHY_LANE-1:0]          phy_txdata_valid,
   input  wire [PHY_LANE-1:0]          phy_txstart_block,      
   input  wire [(PHY_LANE* 2)-1:0]     phy_txsync_header,                    

   output wire [PHY_LANE-1:0]          phy_txp,    // Serial Line      
   output wire [PHY_LANE-1:0]          phy_txn,    // Serial Line  

   // RX Data
   input  wire [PHY_LANE-1:0]          phy_rxp,    // Serial Line           
   input  wire [PHY_LANE-1:0]          phy_rxn,    // Serial Line

   output wire [(PHY_LANE*DW)-1:0]     phy_rxdata,            
   output wire [(PHY_LANE* 2)-1:0]     phy_rxdatak,       
   output wire [PHY_LANE-1:0]          phy_rxdata_valid,         
   output wire [(PHY_LANE* 2)-1:0]     phy_rxstart_block,        
   output wire [(PHY_LANE* 2)-1:0]     phy_rxsync_header,        

   // PHY Command
   input  wire                         phy_txdetectrx,        
   input  wire [PHY_LANE-1:0]          phy_txelecidle,        
   input  wire [PHY_LANE-1:0]          phy_txcompliance,      
   input  wire [PHY_LANE-1:0]          phy_rxpolarity,        
   input  wire [1:0]                   phy_powerdown,         
   input  wire [1:0]                   phy_rate,              
    
   // PHY Status
   output wire [PHY_LANE-1:0]          phy_rxvalid,               
   output wire [PHY_LANE-1:0]          phy_phystatus,          
   output wire                         phy_phystatus_rst,         
   output wire [PHY_LANE-1:0]          phy_rxelecidle,         
   output wire [(PHY_LANE*3)-1:0]      phy_rxstatus,                       
    
   // TX Driver
   input  wire [ 2:0]                  phy_txmargin,          
   input  wire                         phy_txswing,           
   input  wire                         phy_txdeemph,    
    
   // TX Equalization (Gen3/4)
   input  wire [(PHY_LANE*2)-1:0]      phy_txeq_ctrl,      
   input  wire [(PHY_LANE*4)-1:0]      phy_txeq_preset,       
   input  wire [(PHY_LANE*6)-1:0]      phy_txeq_coeff,                                                            

   output wire [ 5:0]                  phy_txeq_fs,           
   output wire [ 5:0]                  phy_txeq_lf,           
   output wire [(PHY_LANE*18)-1:0]     phy_txeq_new_coeff,        
   output wire [PHY_LANE-1:0]          phy_txeq_done,         

   // RX Equalization (Gen3/4)
   input  wire [(PHY_LANE*2)-1:0]      phy_rxeq_ctrl,     
   input  wire [(PHY_LANE*4)-1:0]      phy_rxeq_txpreset,      

   output wire [PHY_LANE-1:0]          phy_rxeq_preset_sel,    
   output wire [(PHY_LANE*18)-1:0]     phy_rxeq_new_txcoeff,   
   output wire [PHY_LANE-1:0]          phy_rxeq_adapt_done,     
   output wire [PHY_LANE-1:0]          phy_rxeq_done,
 
   // Assist Signals
   input  wire                         as_mac_in_L0,
   input  wire  [1:0]                  cfg_rx_pm_state,
   
   input  wire                         as_mac_in_detect,
   input  wire                         as_cdr_hold_req,

   
   //  GT Channel DRP Ports 
  
   //input                               gt_drpclk,
   input        [(PHY_LANE*10)-1:0]    gt_drpaddr,
   input        [PHY_LANE-1:0]         gt_drpen,
   input        [PHY_LANE-1:0]         gt_drpwe,
   input        [(PHY_LANE*16)-1:0]    gt_drpdi,

   output       [PHY_LANE-1:0]         gt_drprdy,
   output       [(PHY_LANE*16)-1:0]    gt_drpdo,  

   //---------- External GT COMMON Ports ----------------------
   output       [((PHY_LANE-1)>>2):0]  ext_qpllxrefclk,
   output       [((((PHY_LANE-1)>>2)+1)*3)-1:0] ext_qpllxrate,
   output                              ext_qpllxrcalenb,

   output       [((PHY_LANE-1)>>2):0]  ext_qpll0pd,
   output       [((PHY_LANE-1)>>2):0]  ext_qpll0reset,
   input        [((PHY_LANE-1)>>2):0]  ext_qpll0lock_out,
   input        [((PHY_LANE-1)>>2):0]  ext_qpll0outclk_out,
   input        [((PHY_LANE-1)>>2):0]  ext_qpll0outrefclk_out,
   output       [((PHY_LANE-1)>>2):0]  ext_qpll1pd,
   output       [((PHY_LANE-1)>>2):0]  ext_qpll1reset,
   input        [((PHY_LANE-1)>>2):0]  ext_qpll1lock_out,
   input        [((PHY_LANE-1)>>2):0]  ext_qpll1outclk_out,
   input        [((PHY_LANE-1)>>2):0]  ext_qpll1outrefclk_out,

  //--------------------------------------------------------------------------
  //  GT WIZARD IP is not in the PCIe core : US+
  //--------------------------------------------------------------------------
  output [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0] gtrefclk01_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0] gtrefclk00_usp_in,
  output [((((PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2)+1)*3)-1:0] pcierateqpll0_usp_in,
  output [((((PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2)+1)*3)-1:0] pcierateqpll1_usp_in,
  
  output [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2 : 0]  qpll0pd_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2 : 0]  qpll0reset_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2 : 0]  qpll1pd_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2 : 0]  qpll1reset_usp_in,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0]    qpll0lock_usp_out,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0]    qpll0outclk_usp_out,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0]    qpll0outrefclk_usp_out,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0]    qpll1lock_usp_out,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0]    qpll1outclk_usp_out,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0]    qpll1outrefclk_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         qpll0freqlock_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         qpll1freqlock_usp_in,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH*2)-1:0]     pcierateqpllpd_usp_out,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH*2)-1:0]     pcierateqpllreset_usp_out,

  output [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2 : 0]  rcalenb_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txpisopd_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         bufgtce_usp_out,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]    bufgtcemask_usp_out,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH* 9)-1:0]    bufgtdiv_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         bufgtreset_usp_out,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]    bufgtrstmask_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         cpllfreqlock_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         cplllock_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         cpllpd_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         cpllreset_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         dmonfiforeset_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         dmonitorclk_usp_in,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH*16)-1:0]    dmonitorout_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         eyescanreset_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         gtpowergood_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         gtrefclk0_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         gtrxreset_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         gttxreset_usp_in,
  output gtwiz_reset_rx_done_usp_in,
  output gtwiz_reset_tx_done_usp_in,
  output gtwiz_userclk_rx_active_usp_in,
  output gtwiz_userclk_tx_active_usp_in,

  output [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]  loopback_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       pcieeqrxeqadaptdone_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       pcierategen3_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       pcierateidle_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       pcierstidle_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       pciersttxsyncstart_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       pciesynctxsyncdone_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       pcieusergen3rdy_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       pcieuserphystatusrst_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       pcieuserratedone_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       pcieuserratestart_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       phystatus_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       resetovrd_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rx8b10ben_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxbufreset_usp_in,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH*3)-1:0]     rxbufstatus_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxbyteisaligned_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxbyterealign_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxcdrfreqreset_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxcdrhold_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxcdrlock_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxcdrreset_usp_in,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH * 2)-1 : 0] rxclkcorcnt_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxcommadet_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxcommadeten_usp_in,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH*16)-1:0]    rxctrl0_usp_out,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH*16)-1:0]    rxctrl1_usp_out,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH*8)-1:0]     rxctrl2_usp_out,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH*8)-1:0]     rxctrl3_usp_out,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH*128)-1:0]   rxdata_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfeagchold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfecfokhold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfekhhold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfelfhold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxdfelpmreset_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfetap10hold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfetap11hold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfetap12hold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfetap13hold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfetap14hold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfetap15hold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfetap2hold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfetap3hold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfetap4hold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfetap5hold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfetap6hold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfetap7hold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfetap8hold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfetap9hold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfeuthold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxdfevphold_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxdlysresetdone_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxelecidle_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxlpmen_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxlpmgchold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxlpmhfhold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxlpmlfhold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxlpmoshold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxmcommaalignen_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxoshold_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxoutclk_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxoutclkfabric_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxoutclkpcs_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxpcommaalignen_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxpcsreset_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH* 2)-1:0]    rxpd_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxphaligndone_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxpmareset_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxpmaresetdone_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxpolarity_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxprbscntreset_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxprbserr_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxprbslocked_usp_out,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH* 4)-1:0]    rxprbssel_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxprogdivreset_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]    rxrate_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxratedone_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxrecclkout_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxresetdone_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxslide_usp_in,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]    rxstatus_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxsyncdone_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxtermination_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxuserrdy_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxusrclk2_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxusrclk_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxvalid_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       tx8b10ben_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH*16)-1:0]  txctrl0_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH*16)-1:0]  txctrl1_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH* 8)-1:0]  txctrl2_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH*128)-1:0] txdata_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH* 2)-1:0]  txdeemph_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txdetectrx_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH*5)-1:0]   txdiffctrl_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txdlybypass_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txdlyen_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txdlyhold_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txdlyovrden_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txdlysreset_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txdlysresetdone_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txdlyupdown_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txelecidle_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH* 7)-1:0]  txmaincursor_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]  txmargin_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txoutclk_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txoutclkfabric_usp_out,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txoutclkpcs_usp_out,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]  txoutclksel_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txpcsreset_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH* 2)-1:0]  txpd_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txphalign_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txphaligndone_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txphalignen_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txphdlypd_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txphdlyreset_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txphdlytstclk_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txphinit_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txphinitdone_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txphovrden_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       rxratemode_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txpmareset_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]     txpmaresetdone_usp_out,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH* 5)-1:0]  txpostcursor_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txprbsforceerr_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH* 4)-1:0]  txprbssel_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH* 5)-1:0]  txprecursor_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txprgdivresetdone_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txprogdivreset_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txpdelecidlemode_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]  txrate_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txresetdone_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txswing_usp_in,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH-1) : 0]   txsyncallin_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]     txsyncdone_usp_out,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH-1) : 0]   txsyncin_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txsyncmode_usp_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txsyncout_usp_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txuserrdy_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txusrclk2_usp_in,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]       txusrclk_usp_in,

  output                                           drpclk_usp_in,
  output [((PL_LINK_CAP_MAX_LINK_WIDTH * 10)-1):0] drpaddr_usp_in,
  output [((PL_LINK_CAP_MAX_LINK_WIDTH *  1)-1):0] drpen_usp_in,
  output [((PL_LINK_CAP_MAX_LINK_WIDTH *  1)-1):0] drprst_usp_in,
  output [((PL_LINK_CAP_MAX_LINK_WIDTH *  1)-1):0] drpwe_usp_in,
  output [((PL_LINK_CAP_MAX_LINK_WIDTH * 16)-1):0] drpdi_usp_in,
  input  [((PL_LINK_CAP_MAX_LINK_WIDTH *  1)-1):0] drprdy_usp_out,
  input  [((PL_LINK_CAP_MAX_LINK_WIDTH * 16)-1):0] drpdo_usp_out,

  input        ext_phy_clk_pclk2_gt,
  input        ext_phy_clk_int_clock,
  input        ext_phy_clk_pclk,
  input        ext_phy_clk_phy_pclk2,
  input        ext_phy_clk_phy_coreclk,
  input        ext_phy_clk_phy_userclk,
  input        ext_phy_clk_phy_mcapclk,

  output       ext_phy_clk_bufg_gt_ce,
  output       ext_phy_clk_bufg_gt_reset,
  output       ext_phy_clk_rst_idle,
  output       ext_phy_clk_txoutclk,
  output       ext_phy_clk_bufgtcemask,
  output       ext_phy_clk_gt_bufgtrstmask,
  output [8:0] ext_phy_clk_bufgtdiv,
  
  output  phy_rdy_out,
  input   prst_clk,
 //--------------------------------------------------------------------------
 //  GT WIZARD IP is not in the PCIe core : US
 //--------------------------------------------------------------------------
 input [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]    bufgtce_us_out ,
 input [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]    bufgtcemask_us_out ,
 input [(PL_LINK_CAP_MAX_LINK_WIDTH* 9)-1:0]    bufgtdiv_us_out ,
 input [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]    bufgtreset_us_out ,
 input [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]    bufgtrstmask_us_out ,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         cplllock_us_out,  
 input [(PL_LINK_CAP_MAX_LINK_WIDTH*17)-1:0]    dmonitorout_us_out,
 input [(PL_LINK_CAP_MAX_LINK_WIDTH* 16)-1:0]   drpdo_us_out,
 input [(PL_LINK_CAP_MAX_LINK_WIDTH* 1)-1:0]    drprdy_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         eyescandataerror_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         gthtxn_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         gthtxp_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         gtpowergood_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         pcierategen3_us_out,  
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         pcierateidle_us_out,       
 input [(PL_LINK_CAP_MAX_LINK_WIDTH*2)-1:0]     pcierateqpllpd_us_out,              
 input [(PL_LINK_CAP_MAX_LINK_WIDTH*2)-1:0]     pcierateqpllreset_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         pciesynctxsyncdone_us_out,                      
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         pcieusergen3rdy_us_out, 
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         pcieuserphystatusrst_us_out,  
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         pcieuserratestart_us_out,  
 input [(PL_LINK_CAP_MAX_LINK_WIDTH*12)-1:0]    pcsrsvdout_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         phystatus_us_out,
 input [(PL_LINK_CAP_MAX_LINK_WIDTH*3)-1:0]     rxbufstatus_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxbyteisaligned_us_out, 
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxbyterealign_us_out, 
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxcdrlock_us_out,                                                          
 input [(PL_LINK_CAP_MAX_LINK_WIDTH * 2)-1 : 0] rxclkcorcnt_us_out, 
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxcommadet_us_out,
 input [(PL_LINK_CAP_MAX_LINK_WIDTH*16)-1:0]    rxctrl0_us_out,  
 input [(PL_LINK_CAP_MAX_LINK_WIDTH*16)-1:0]    rxctrl1_us_out,  
 input [(PL_LINK_CAP_MAX_LINK_WIDTH*8)-1:0]     rxctrl2_us_out,  
 input [(PL_LINK_CAP_MAX_LINK_WIDTH*8)-1:0]     rxctrl3_us_out,  
 input [(PL_LINK_CAP_MAX_LINK_WIDTH*128)-1:0]   rxdata_us_out,  

    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfeagchold_us_in ,  
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfecfokhold_us_in, 
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfelfhold_us_in  ,   
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfekhhold_us_in  ,             
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfetap2hold_us_in,        
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfetap3hold_us_in,        
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfetap4hold_us_in,       
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfetap5hold_us_in,           
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfetap6hold_us_in,       
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfetap7hold_us_in,        
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfetap8hold_us_in,       
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfetap9hold_us_in,       
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfetap10hold_us_in,       
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfetap11hold_us_in,       
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfetap12hold_us_in,        
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfetap13hold_us_in,       
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfetap14hold_us_in,       
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfetap15hold_us_in,       
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfeuthold_us_in,             
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxdfevphold_us_in,             
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxoshold_us_in   ,                  
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxlpmgchold_us_in,              
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxlpmhfhold_us_in,            
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxlpmlfhold_us_in,              
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] rxlpmoshold_us_in,  

 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxdlysresetdone_us_out,     
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxelecidle_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       rxoutclk_us_out, 
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxphaligndone_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxpmaresetdone_us_out,           
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxprbserr_us_out,                                        
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxprbslocked_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxprgdivresetdone_us_out,    
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxratedone_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxresetdone_us_out,              
 input [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]    rxstatus_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxsyncdone_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxvalid_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txdlysresetdone_us_out,     
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txoutclk_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txphaligndone_us_out,  
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txphinitdone_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       txpmaresetdone_us_out, 
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txprgdivresetdone_us_out,  
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txresetdone_us_out,
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txsyncout_us_out,  
 input [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       txsyncdone_us_out, 

 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         cpllpd_us_in,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         cpllreset_us_in,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         dmonfiforeset_us_in,
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         dmonitorclk_us_in,
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         drpclk_us_in,
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 9)-1:0]    drpaddr_us_in,
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 16)-1:0]   drpdi_us_in,
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 1)-1:0]    drpen_us_in,
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 1)-1:0]    drpwe_us_in,
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         eyescanreset_us_in,
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         gthrxn_us_in,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         gthrxp_us_in,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         gtrefclk0_us_in,
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         gtrxreset_us_in,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         gttxreset_us_in,                                          
 output                        gtwiz_reset_rx_done_us_in,                                                                                      
 output                        gtwiz_reset_tx_done_us_in,                                                
 output                        gtwiz_userclk_rx_active_us_in ,                                                
 output                        gtwiz_userclk_tx_active_us_in ,                                                
 output                        gtwiz_userclk_tx_reset_us_in,
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]    loopback_us_in,                                               
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         pcieeqrxeqadaptdone_us_in ,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         pcierstidle_us_in,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         pciersttxsyncstart_us_in,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         pcieuserratedone_us_in,                                          
 output [(PL_LINK_CAP_MAX_LINK_WIDTH*16)-1:0]    pcsrsvdin_us_in,
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rx8b10ben_us_in,                                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxbufreset_us_in,                                                
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxcdrhold_us_in,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxcommadeten_us_in,
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxlpmen_us_in,                                                            
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxmcommaalignen_us_in,                                                    
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxpcommaalignen_us_in,                                                    
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 2)-1:0]    rxpd_us_in,                                              
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxpolarity_us_in,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxprbscntreset_us_in, 
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 4)-1:0]    rxprbssel_us_in,                                               
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxprogdivreset_us_in,                                          
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]    rxrate_us_in,
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxratemode_us_in,
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxslide_us_in,                                                
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxuserrdy_us_in,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxusrclk2_us_in,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         rxusrclk_us_in,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         tx8b10ben_us_in,                                                          
 output [(PL_LINK_CAP_MAX_LINK_WIDTH*16)-1:0]    txctrl0_us_in,
 output [(PL_LINK_CAP_MAX_LINK_WIDTH*16)-1:0]    txctrl1_us_in,
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 8)-1:0]    txctrl2_us_in,
 output [(PL_LINK_CAP_MAX_LINK_WIDTH*128)-1:0]   txdata_us_in, 
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txdeemph_us_in,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txdetectrx_us_in,                                          
 output [(PL_LINK_CAP_MAX_LINK_WIDTH*4)-1:0]     txdiffctrl_us_in,
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txdlybypass_us_in,                                                
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txdlyen_us_in,                                                
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txdlyhold_us_in,                                                
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txdlyovrden_us_in,                                                
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txdlysreset_us_in,                                                
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txdlyupdown_us_in,                                                
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txelecidle_us_in,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txinhibit_us_in,                                          
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 7)-1:0]    txmaincursor_us_in,                                               
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]    txmargin_us_in,                                              
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]    txoutclksel_us_in,                                           
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 2)-1:0]    txpd_us_in,                                              
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txphalign_us_in,                                                
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txphalignen_us_in,                                                
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txphdlypd_us_in,                                                
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txphdlyreset_us_in,                                                
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txphdlytstclk_us_in ,                                                
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txphinit_us_in,                                                
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txphovrden_us_in,                                                
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 5)-1:0]    txpostcursor_us_in,                                               
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txprbsforceerr_us_in,                                          
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 4)-1:0]    txprbssel_us_in,                                               
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 5)-1:0]    txprecursor_us_in,                                               
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txprogdivreset_us_in,                                          
 output [(PL_LINK_CAP_MAX_LINK_WIDTH* 3)-1:0]    txrate_us_in,
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txswing_us_in,                                          
 output [(PL_LINK_CAP_MAX_LINK_WIDTH-1) : 0]     txsyncallin_us_in, 
 output [(PL_LINK_CAP_MAX_LINK_WIDTH-1) : 0]     txsyncin_us_in,   
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txsyncmode_us_in,
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txuserrdy_us_in,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txusrclk2_us_in,                                          
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]         txusrclk_us_in,                                          

 output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       qpll0clk_us_in, 
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       qpll0refclk_us_in,
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       qpll1clk_us_in, 
 output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0]       qpll1refclk_us_in,

 output [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0]    gtrefclk01_us_in,
 output [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0]    qpll1pd_us_in,
 output [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0]    qpll1reset_us_in,
 output [((((PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2)+1)* 5)-1:0] qpllrsvd2_us_in,
 output [((((PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2)+1)* 5)-1:0] qpllrsvd3_us_in,
 input [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0]     qpll1lock_us_out,
 input [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0]     qpll1outclk_us_out,
 input [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0]     qpll1outrefclk_us_out,

   //---------------------------------------------------------------------------- 
   output      [PHY_LANE-1:0]          gt_gtpowergood

   );

   localparam  TCQ   = 1;

   wire                          phy_userclk_int;
   wire                          phy_mcapclk_int;
   wire                          phy_pclk2;
   wire  [PHY_LANE-1:0]          phy_rxvalid_pclk2;
   wire  [PHY_LANE-1:0]          phy_phystatus_pclk2;
   wire                          phy_phystatus_rst_pclk2;
   wire  [(PHY_LANE* 3)-1:0]     phy_rxstatus_pclk2;
   wire  [5:0]                   phy_txeq_fs_pclk2;
   wire  [5:0]                   phy_txeq_lf_pclk2;
   wire  [(PHY_LANE* 18)-1:0]    phy_txeq_new_coeff_pclk2;
   wire  [PHY_LANE-1:0]          phy_txeq_done_pclk2;
   wire  [PHY_LANE-1:0]          phy_rxeq_preset_sel_pclk2;
   wire  [(PHY_LANE* 18)-1:0]    phy_rxeq_new_txcoeff_pclk2;
   wire  [PHY_LANE-1:0]          phy_rxeq_done_pclk2;
   wire  [PHY_LANE-1:0]          phy_rxeq_adapt_done_pclk2;

   wire                          phy_txdetectrx_32b;
   wire  [PHY_LANE-1:0]          phy_txelecidle_32b;
   wire  [PHY_LANE-1:0]          phy_txcompliance_32b;
   wire  [PHY_LANE-1:0]          phy_rxpolarity_32b;
   wire  [1:0]                   phy_powerdown_32b;
   wire  [1:0]                   phy_rate_32b;

   wire  [(PHY_LANE*32)-1:0]     phy_txdata_32b;            
   wire  [(PHY_LANE* 2)-1:0]     phy_txdatak_32b;            
   wire  [PHY_LANE-1:0]          phy_txdata_valid_32b;
   wire  [PHY_LANE-1:0]          phy_txstart_block_32b;      
   wire  [(PHY_LANE* 2)-1:0]     phy_txsync_header_32b;  
   wire  [(PHY_LANE*2)-1:0]      phy_txeq_ctrl_pclk2;            
   wire  [(PHY_LANE*4)-1:0]      phy_txeq_preset_pclk2;            
   wire  [(PHY_LANE*6)-1:0]      phy_txeq_coeff_pclk2;

   wire  [(PHY_LANE*64)-1:0]     phy_txdata_64b;            

   wire  [(PHY_LANE*32)-1:0]     phy_rxdata_32b;            
   wire  [(PHY_LANE* 2)-1:0]     phy_rxdatak_32b;            
   wire  [PHY_LANE-1:0]          phy_rxdata_valid_32b;
   wire  [PHY_LANE-1:0]          phy_rxstart_block_32b;      
   wire  [(PHY_LANE* 2)-1:0]     phy_rxsync_header_32b; 

   wire  [(PHY_LANE*64)-1:0]     phy_rxdata_64b;            
   wire  [(PHY_LANE* 2)-1:0]     phy_rxstart_block_64b;      

   wire  [(PHY_LANE*DW)-1:0]     phy_txdata_pl;            
   wire  [(PHY_LANE* 2)-1:0]     phy_txdatak_pl;            
   wire  [PHY_LANE-1:0]          phy_txdata_valid_pl;
   wire  [PHY_LANE-1:0]          phy_txstart_block_pl;      
   wire  [(PHY_LANE* 2)-1:0]     phy_txsync_header_pl;  

   wire  [(PHY_LANE*DW)-1:0]     phy_rxdata_pl;            
   wire  [(PHY_LANE* 2)-1:0]     phy_rxdatak_pl;            
   wire  [PHY_LANE-1:0]          phy_rxdata_valid_pl;
   wire  [(PHY_LANE* 2)-1:0]     phy_rxstart_block_pl;      
   wire  [(PHY_LANE* 2)-1:0]     phy_rxsync_header_pl; 

   wire                          phy_txdetectrx_pl;        
   wire  [PHY_LANE-1:0]          phy_txelecidle_pl;        
   wire  [PHY_LANE-1:0]          phy_txcompliance_pl;      
   wire  [PHY_LANE-1:0]          phy_rxpolarity_pl;        
   wire  [1:0]                   phy_powerdown_pl;         
   wire  [1:0]                   phy_rate_pl;   

   wire  [PHY_LANE-1:0]          phy_rxvalid_pl;               
   wire  [PHY_LANE-1:0]          phy_phystatus_pl;          
   wire  [PHY_LANE-1:0]          phy_rxelecidle_pl;         
   wire  [(PHY_LANE*3)-1:0]      phy_rxstatus_pl;          

   wire  [ 2:0]                  phy_txmargin_pl;          
   wire                          phy_txswing_pl;           
   wire                          phy_txdeemph_pl;  

   wire  [(PHY_LANE*2)-1:0]      phy_txeq_ctrl_pl;      
   wire  [(PHY_LANE*4)-1:0]      phy_txeq_preset_pl;       
   wire  [(PHY_LANE*6)-1:0]      phy_txeq_coeff_pl;                                                            

   wire  [ 5:0]                  phy_txeq_fs_pl;           
   wire  [ 5:0]                  phy_txeq_lf_pl;           
   wire  [(PHY_LANE*18)-1:0]     phy_txeq_new_coeff_pl;        
   wire  [PHY_LANE-1:0]          phy_txeq_done_pl;         

   wire  [(PHY_LANE*2)-1:0]      phy_rxeq_ctrl_pl;     
   wire  [(PHY_LANE*4)-1:0]      phy_rxeq_txpreset_pl;      

   wire  [PHY_LANE-1:0]          phy_rxeq_preset_sel_pl;    
   wire  [(PHY_LANE*18)-1:0]     phy_rxeq_new_txcoeff_pl;   
   wire  [PHY_LANE-1:0]          phy_rxeq_adapt_done_pl;     
   wire  [PHY_LANE-1:0]          phy_rxeq_done_pl;

   wire                          as_mac_in_L0_pl;
   wire  [1:0]                   cfg_rx_pm_state_pl;
   wire                          as_mac_in_detect_pl;
   wire                          as_cdr_hold_req_pl;

   wire  [PHY_LANE-1:0]          com_det_lower;
   wire  [PHY_LANE-1:0]          com_det_upper;
   wire  [PHY_LANE-1:0]          idl_det_lower;
   wire  [PHY_LANE-1:0]          idl_det_upper;
   wire  [PHY_LANE-1:0]          eios_det_c0;
   wire  [PHY_LANE-1:0]          eios_det_c1;
   wire  [PHY_LANE-1:0]          eios_det_c2;
   wire  [PHY_LANE-1:0]          eios_det_c3;
   wire  [(PHY_LANE* 3)-1:0]     phy_rxstatus_raw;

   reg                           phy_rxelecidle_ff;
   reg                           phy_rxelecidle_ff2;
   reg                           phy_rxcdrhold_wire;
   reg                           phy_rxcdrhold_pclk2;

   reg   [PHY_LANE-1:0]          phy_rxstatus_mask_wire, phy_rxstatus_mask;
   reg   [PHY_LANE-1:0]          saved_com_det_lower_wire, saved_com_det_lower;
   reg   [PHY_LANE-1:0]          saved_com_det_upper_wire, saved_com_det_upper;
   reg   [PHY_LANE-1:0]          start_mask_mon_wire;
   reg   [PHY_LANE-1:0]          start_mask_mon;
   
   wire [PHY_LANE*DW -1:0]       phy_rxdata_int; 
   wire [PHY_LANE*2 -1:0]        phy_rxdatak_int; 
   wire [PHY_LANE -1:0]          phy_rxdata_valid_int; 
   wire [PHY_LANE*3 -1:0]        phy_rxstatus_int; 
   wire [PHY_LANE -1:0]          phy_phystatus_int; 
   wire [PHY_LANE -1:0]          phy_rxelecidle_int; 


   //--------------------------------------------------------------------------
   //  Pipeline Stages
   //--------------------------------------------------------------------------        
   (* keep = "true", max_fanout = 500 *) wire   phy_phystatus_rst_int;
   assign phy_phystatus_rst_int  = phy_phystatus_rst;

      // Programmable stages to ease GT lane routing
      pcie_phy_0_phy_pipeline #(
         //  Parameters
         .PIPELINE_STAGES  ( PIPELINE_STAGES ),
         .PHY_LANE         ( PHY_LANE ),
         .DW               ( DW ),
         .TCQ              ( TCQ )
      ) phy_pipeline (                                         
         // Clock & Reset Ports
         .phy_pclk               ( phy_pclk ),  
         .phy_rst                ( phy_phystatus_rst_int ),  

         // TX Data
         .phy_txdata_i           ( phy_txdata ),
         .phy_txdatak_i          ( phy_txdatak ),
         .phy_txdata_valid_i     ( phy_txdata_valid ),
         .phy_txstart_block_i    ( phy_txstart_block ),
         .phy_txsync_header_i    ( phy_txsync_header ),

         .phy_txdata_o           ( phy_txdata_pl ),
         .phy_txdatak_o          ( phy_txdatak_pl ),
         .phy_txdata_valid_o     ( phy_txdata_valid_pl ),
         .phy_txstart_block_o    ( phy_txstart_block_pl ),
         .phy_txsync_header_o    ( phy_txsync_header_pl ),

         // RX Data
         .phy_rxdata_i           ( phy_rxdata_pl ),            
         .phy_rxdatak_i          ( phy_rxdatak_pl ),       
         .phy_rxdata_valid_i     ( phy_rxdata_valid_pl ),         
         .phy_rxstart_block_i    ( phy_rxstart_block_pl ),        
         .phy_rxsync_header_i    ( phy_rxsync_header_pl ),   

         .phy_rxdata_o           ( phy_rxdata_int ),            
         .phy_rxdatak_o          ( phy_rxdatak_int ),       
         .phy_rxdata_valid_o     ( phy_rxdata_valid_int ),         
         .phy_rxstart_block_o    ( phy_rxstart_block ),        
         .phy_rxsync_header_o    ( phy_rxsync_header ),   

         //  PHY Command
         .phy_txdetectrx_i       ( phy_txdetectrx ),  
         .phy_txelecidle_i       ( phy_txelecidle ),                    
         .phy_txcompliance_i     ( phy_txcompliance ), 
         .phy_rxpolarity_i       ( phy_rxpolarity ),
         .phy_powerdown_i        ( phy_powerdown ), 
         .phy_rate_i             ( phy_rate ),

         .phy_txdetectrx_o       ( phy_txdetectrx_pl ),  
         .phy_txelecidle_o       ( phy_txelecidle_pl ),                    
         .phy_txcompliance_o     ( phy_txcompliance_pl ), 
         .phy_rxpolarity_o       ( phy_rxpolarity_pl ),
         .phy_powerdown_o        ( phy_powerdown_pl ), 
         .phy_rate_o             ( phy_rate_pl ),    

         //  PHY Status
         .phy_rxvalid_i          ( phy_rxvalid_pl ),
         .phy_phystatus_i        ( phy_phystatus_pl ),
         .phy_rxelecidle_i       ( phy_rxelecidle_pl ), 
         .phy_rxstatus_i         ( phy_rxstatus_pl ),

         .phy_rxvalid_o          ( phy_rxvalid ),
         .phy_phystatus_o        ( phy_phystatus_int ),
         .phy_rxelecidle_o       ( phy_rxelecidle_int ), 
         .phy_rxstatus_o         ( phy_rxstatus_int ),
        
         //  TX Driver
         .phy_txmargin_i         ( phy_txmargin ),          
         .phy_txswing_i          ( phy_txswing ),           
         .phy_txdeemph_i         ( phy_txdeemph ),   

         .phy_txmargin_o         ( phy_txmargin_pl ),          
         .phy_txswing_o          ( phy_txswing_pl ),           
         .phy_txdeemph_o         ( phy_txdeemph_pl ),        

         //  TX Equalization (Gen3/4)
         .phy_txeq_ctrl_i        ( phy_txeq_ctrl ),
         .phy_txeq_preset_i      ( phy_txeq_preset ),
         .phy_txeq_coeff_i       ( phy_txeq_coeff ), 

         .phy_txeq_ctrl_o        ( phy_txeq_ctrl_pl ),
         .phy_txeq_preset_o      ( phy_txeq_preset_pl ),
         .phy_txeq_coeff_o       ( phy_txeq_coeff_pl ), 

         .phy_txeq_fs_i          ( phy_txeq_fs_pl ),           
         .phy_txeq_lf_i          ( phy_txeq_lf_pl ),           
         .phy_txeq_new_coeff_i   ( phy_txeq_new_coeff_pl ),
         .phy_txeq_done_i        ( phy_txeq_done_pl ),

         .phy_txeq_fs_o          ( phy_txeq_fs ),           
         .phy_txeq_lf_o          ( phy_txeq_lf ),           
         .phy_txeq_new_coeff_o   ( phy_txeq_new_coeff ),
         .phy_txeq_done_o        ( phy_txeq_done ),   

         //  RX Equalization (Gen3/4)
         .phy_rxeq_ctrl_i        ( phy_rxeq_ctrl ), 
         .phy_rxeq_txpreset_i    ( phy_rxeq_txpreset ),

         .phy_rxeq_ctrl_o        ( phy_rxeq_ctrl_pl ), 
         .phy_rxeq_txpreset_o    ( phy_rxeq_txpreset_pl ),

         .phy_rxeq_preset_sel_i  ( phy_rxeq_preset_sel_pl ),
         .phy_rxeq_new_txcoeff_i ( phy_rxeq_new_txcoeff_pl ),
         .phy_rxeq_adapt_done_i  ( phy_rxeq_adapt_done_pl ),
         .phy_rxeq_done_i        ( phy_rxeq_done_pl ),

         .phy_rxeq_preset_sel_o  ( phy_rxeq_preset_sel ),
         .phy_rxeq_new_txcoeff_o ( phy_rxeq_new_txcoeff ),
         .phy_rxeq_adapt_done_o  ( phy_rxeq_adapt_done ),
         .phy_rxeq_done_o        ( phy_rxeq_done ),

         .as_mac_in_L0_i         ( as_mac_in_L0 ),
         .cfg_rx_pm_state_i      ( cfg_rx_pm_state ),
               
         .as_mac_in_L0_o         ( as_mac_in_L0_pl ),
         .cfg_rx_pm_state_o      ( cfg_rx_pm_state_pl ),

         // Assist Signals
         .as_mac_in_detect_i     ( as_mac_in_detect ),
         .as_cdr_hold_req_i      ( as_cdr_hold_req ),

         .as_mac_in_detect_o     ( as_mac_in_detect_pl ),
         .as_cdr_hold_req_o      ( as_cdr_hold_req_pl )
      );


         assign phy_txdetectrx_32b     = phy_txdetectrx_pl;
         assign phy_txelecidle_32b     = phy_txelecidle_pl;
         assign phy_txcompliance_32b   = phy_txcompliance_pl;
         assign phy_rxpolarity_32b     = phy_rxpolarity_pl;
         assign phy_powerdown_32b      = phy_powerdown_pl;
         assign phy_rate_32b           = phy_rate_pl;
         assign phy_txdata_64b         = phy_txdata_pl;
         assign phy_txdatak_32b        = phy_txdatak_pl;
         assign phy_txdata_valid_32b   = phy_txdata_valid_pl;
         assign phy_txstart_block_32b  = phy_txstart_block_pl;
         assign phy_txsync_header_32b  = phy_txsync_header_pl;
         assign phy_txeq_ctrl_pclk2    = phy_txeq_ctrl_pl;
         assign phy_txeq_preset_pclk2  = phy_txeq_preset_pl;
         assign phy_txeq_coeff_pclk2   = phy_txeq_coeff_pl;
         assign PHY_PCLK               = phy_pclk2;
         assign phy_rxdata_pl          = phy_rxdata_64b;          // 64b
         assign phy_rxstart_block_pl   = phy_rxstart_block_64b;   // 2b
         assign phy_rxdatak_pl         = phy_rxdatak_32b;
         assign phy_rxdata_valid_pl    = phy_rxdata_valid_32b;
         assign phy_rxsync_header_pl   = phy_rxsync_header_32b;
         assign phy_rxvalid_pl         = phy_rxvalid_pclk2;
         assign phy_phystatus_pl       = phy_phystatus_pclk2;
         assign phy_phystatus_rst      = phy_phystatus_rst_pclk2;
         assign phy_rxstatus_raw       = phy_rxstatus_pclk2;
         //assign phy_rxstatus_pl        = phy_rxstatus_pclk2;
         assign phy_txeq_fs_pl         = phy_txeq_fs_pclk2;
         assign phy_txeq_lf_pl         = phy_txeq_lf_pclk2;
         assign phy_txeq_new_coeff_pl  = phy_txeq_new_coeff_pclk2;
         assign phy_txeq_done_pl       = phy_txeq_done_pclk2;
         assign phy_rxeq_preset_sel_pl = phy_rxeq_preset_sel_pclk2;
         assign phy_rxeq_new_txcoeff_pl= phy_rxeq_new_txcoeff_pclk2;
         assign phy_rxeq_done_pl       = phy_rxeq_done_pclk2;
         assign phy_rxeq_adapt_done_pl = phy_rxeq_adapt_done_pclk2;

   //--------------------------------------------------------------------------
   //  CDRHOLD Logic
   //--------------------------------------------------------------------------  

   `PHYREG(phy_pclk2, phy_phystatus_rst_pclk2, phy_rxelecidle_ff, phy_rxelecidle_pl[0], 'd1)
   `PHYREG(phy_pclk2, phy_phystatus_rst_pclk2, phy_rxelecidle_ff2, phy_rxelecidle_ff, 'd1)

   always @(*) begin 
      if (as_cdr_hold_req_pl & phy_rxelecidle_pl[0]) begin
         phy_rxcdrhold_wire   = 1'b1;
      end else if (phy_rxelecidle_ff2 & ~phy_rxelecidle_pl[0]) begin
         phy_rxcdrhold_wire   = 1'b0;
      end else begin
         phy_rxcdrhold_wire   = phy_rxcdrhold_pclk2;
      end
   end

   `PHYREG(phy_pclk2, phy_phystatus_rst_pclk2, phy_rxcdrhold_pclk2, phy_rxcdrhold_wire, 'd0)

   //--------------------------------------------------------------------------
   // Mask invalid RXSTATUS for Gen1/2 after EIOS, can be removed once GT fixes it
   //--------------------------------------------------------------------------

   genvar         lane;

   generate
   for (lane = 0; lane < PHY_LANE; lane = lane + 1) begin: per_lane_rxstatus_mask
   assign com_det_lower[lane] = phy_rxdatak_pl[(lane* 2)]   & (phy_rxdata_pl[(lane* 64)+:8]                 == 8'hBC);
   assign idl_det_lower[lane] = phy_rxdatak_pl[(lane* 2)]   & (phy_rxdata_pl[(lane* 64)+:8]                 == 8'h7C);
   assign com_det_upper[lane] = phy_rxdatak_pl[(lane* 2)+1] & (phy_rxdata_pl[(lane* 64)+ 15: (lane* 64)+ 8] == 8'hBC);
   assign idl_det_upper[lane] = phy_rxdatak_pl[(lane* 2)+1] & (phy_rxdata_pl[(lane* 64)+ 15: (lane* 64)+ 8] == 8'h7C);

   assign eios_det_c0[lane]   = com_det_lower[lane] & idl_det_upper[lane];       // {IDL, COM}
   assign eios_det_c1[lane]   = saved_com_det_lower[lane] & idl_det_lower[lane]; // {XXX, COM}, {XXX, IDL}
   assign eios_det_c2[lane]   = saved_com_det_upper[lane] & idl_det_lower[lane]; // {COM, XXX}, {XXX, IDL}
   assign eios_det_c3[lane]   = saved_com_det_upper[lane] & idl_det_upper[lane]; // {COM, XXX}, {IDL, XXX}

    always @(*) begin
      if (phy_rxvalid_pl[lane] & phy_rxelecidle_pl[lane] & ~phy_txdetectrx_pl & ~start_mask_mon[lane]) begin
         phy_rxstatus_mask_wire[lane]     = eios_det_c0[lane] | eios_det_c1[lane] | eios_det_c2[lane]  | eios_det_c3[lane] | phy_rxstatus_mask[lane];
         saved_com_det_lower_wire[lane]   = com_det_lower[lane];
         saved_com_det_upper_wire[lane]   = com_det_upper[lane];
         start_mask_mon_wire[lane]        = 1'b1;
      end else if (start_mask_mon[lane]) begin
         phy_rxstatus_mask_wire[lane]     = eios_det_c0[lane] | eios_det_c1[lane] | eios_det_c2[lane]  | eios_det_c3[lane] | phy_rxstatus_mask[lane];
         saved_com_det_lower_wire[lane]   = com_det_lower[lane];
         saved_com_det_upper_wire[lane]   = com_det_upper[lane];
         start_mask_mon_wire[lane]        = phy_rxvalid_pl[lane];
      end else begin
         phy_rxstatus_mask_wire[lane]     = 1'b0;
         saved_com_det_lower_wire[lane]   = 1'b0;
         saved_com_det_upper_wire[lane]   = 1'b0;
         start_mask_mon_wire[lane]        = 1'b0;
      end
   end
 
   `PHYREG(phy_pclk, phy_phystatus_rst, phy_rxstatus_mask[lane], phy_rxstatus_mask_wire[lane], 1'b0)
   `PHYREG(phy_pclk, phy_phystatus_rst, saved_com_det_lower[lane], saved_com_det_lower_wire[lane], 1'b0)
   `PHYREG(phy_pclk, phy_phystatus_rst, saved_com_det_upper[lane], saved_com_det_upper_wire[lane], 1'b0)
   `PHYREG(phy_pclk, phy_phystatus_rst, start_mask_mon[lane], start_mask_mon_wire[lane], 1'b0)

   assign phy_rxstatus_pl[(lane* 3)+:3]   = (~phy_rate_32b[1] & phy_rxstatus_mask[lane])? 3'd0: phy_rxstatus_raw[(lane* 3)+:3];
   end
   endgenerate


  assign phy_rxdata          = phy_rxdata_int;          
  assign phy_rxdatak         = phy_rxdatak_int;       
  assign phy_rxdata_valid    = phy_rxdata_valid_int;
  assign phy_rxstatus        = phy_rxstatus_int;      
  assign phy_phystatus       = phy_phystatus_int;     
  assign phy_rxelecidle      = phy_rxelecidle_int;    


   //--------------------------------------------------------------------------
   //  UltraScale GTH PHY Wrapper
   //--------------------------------------------------------------------------   

   wire [((((PHY_LANE-1)>>2)+1)*16)-1:0]  gtcom_drpaddr_tie_off   = 'd0;
   wire [(PHY_LANE-1)>>2:0]               gtcom_drpen_tie_off     = 'd0;
   wire [(PHY_LANE-1)>>2:0]               gtcom_drpwe_tie_off     = 'd0;
   wire [((((PHY_LANE-1)>>2)+1)*16)-1:0]  gtcom_drpdi_tie_off     = 'd0;

   assign phy_userclk   = ((PHY_USERCLK_FREQ == 3 && PHY_CORECLK_FREQ == 1) ||
                           (PHY_USERCLK_FREQ == 4 && PHY_CORECLK_FREQ == 2))  ? phy_coreclk : phy_userclk_int;

   assign phy_mcapclk   = phy_mcapclk_int;

//   assign phy_mcapclk   = ((PHY_MCAPCLK_FREQ == 1 && PHY_USERCLK_FREQ == 1) ||
//                           (PHY_MCAPCLK_FREQ == 2 && PHY_USERCLK_FREQ == 2))  ? phy_userclk_int : phy_mcapclk_int;

   generate
      if (FPGA_FAMILY == "USM") begin: diablo_gt
         pcie_phy_0_gt_phy_wrapper #(
            // Parameters
             // synthesis translate_off
             .PHY_SIM_EN       ( "TRUE" ),   
             // synthesis translate_on
            .PHY_GT_XCVR      ( (FPGA_XCVR == "Y")? "GTY": "GTH" ),
            .PHY_REFCLK_MODE  ( (PHY_ASYNC_EN == "FALSE")? 0: 1 ),
            .PHY_LANE         ( PHY_LANE ),   
            .PHY_MAX_SPEED    ( PHY_MAX_SPEED ),                    
            .PHY_REFCLK_FREQ  ( PHY_REFCLK_FREQ ),           
            .PHY_CORECLK_FREQ ( PHY_CORECLK_FREQ ),       
            .PHY_USERCLK_FREQ ( PHY_USERCLK_FREQ ),   
            .PHY_MCAPCLK_FREQ ( PHY_MCAPCLK_FREQ ),
            .PHY_GT_TXPRESET  ( PHY_GT_TXPRESET ),
            .PHY_LP_TXPRESET  ( PHY_LP_TXPRESET )
         ) diablo_gt_phy_wrapper (                                         



            // Clock & Reset Ports
            .PHY_REFCLK             ( phy_refclk ),      
            .PHY_GTREFCLK           ( phy_gtrefclk ),               
            .PHY_RST_N              ( phy_rst_n ),  
      
            .PHY_PCLK               ( phy_pclk2 ),  
            .PHY_PCLK2              ( phy_pclk ),  
            .PHY_CORECLK            ( phy_coreclk ), 
            .PHY_USERCLK            ( phy_userclk_int ),                          
            .PHY_MCAPCLK            ( phy_mcapclk_int ), // New in Diablo
                                                     
            // Serial Line Ports
            .PHY_RXP                ( phy_rxp ),               
            .PHY_RXN                ( phy_rxn ),               
                               
            .PHY_TXP                ( phy_txp ),               
            .PHY_TXN                ( phy_txn ),   
                                                                             
            // TX Data Ports 
            .PHY_TXDATA             ( phy_txdata_64b ),            
            .PHY_TXDATAK            ( phy_txdatak_32b ),                
            .PHY_TXDATA_VALID       ( phy_txdata_valid_32b ),                
            .PHY_TXSTART_BLOCK      ( phy_txstart_block_32b ),                      
            .PHY_TXSYNC_HEADER      ( phy_txsync_header_32b ),                                          
      
            // RX Data Ports 
            .PHY_RXDATA             ( phy_rxdata_64b ),            
            .PHY_RXDATAK            ( phy_rxdatak_32b ),                
            .PHY_RXDATA_VALID       ( phy_rxdata_valid_32b ),                
            .PHY_RXSTART_BLOCK      ( phy_rxstart_block_64b ),                      
            .PHY_RXSYNC_HEADER      ( phy_rxsync_header_32b ),                                          
      
            // PHY Command Port
            .PHY_TXDETECTRX         ( phy_txdetectrx_32b ),
            .PHY_TXELECIDLE         ( phy_txelecidle_32b ),                    
            .PHY_TXCOMPLIANCE       ( phy_txcompliance_32b ),                          
            .PHY_RXPOLARITY         ( phy_rxpolarity_32b ),            
            .PHY_POWERDOWN          ( phy_powerdown_32b ),
            .PHY_RATE               ( phy_rate_32b ),  
            .PHY_RXCDRHOLD          ( phy_rxcdrhold_pclk2 ),
          
            // PHY Status Ports
            .PHY_RXVALID            ( phy_rxvalid_pclk2 ),            
            .PHY_PHYSTATUS          ( phy_phystatus_pclk2 ),            
      
            .PHY_PHYSTATUS_RST      ( phy_phystatus_rst_pclk2 ),
            .PHY_RXELECIDLE         ( phy_rxelecidle_pl ),                    
            .PHY_RXSTATUS           ( phy_rxstatus_pclk2 ),                                            
          
            // TX Driver Ports
            .PHY_TXMARGIN           ( phy_txmargin_pl ),          
            .PHY_TXSWING            ( phy_txswing_pl ),   
            .PHY_TXDEEMPH           ( {1'b0, phy_txdeemph_pl} ),  // 2b in Diablo   
      
            // TX Equalization Ports for Gen3
            .PHY_TXEQ_CTRL          ( phy_txeq_ctrl_pclk2 ),
            .PHY_TXEQ_PRESET        ( phy_txeq_preset_pclk2 ),
            .PHY_TXEQ_COEFF         ( phy_txeq_coeff_pclk2 ),
      
            .PHY_TXEQ_FS            ( phy_txeq_fs_pclk2 ),           
            .PHY_TXEQ_LF            ( phy_txeq_lf_pclk2 ),           
            .PHY_TXEQ_NEW_COEFF     ( phy_txeq_new_coeff_pclk2 ),
            .PHY_TXEQ_DONE          ( phy_txeq_done_pclk2 ),
                                                                       
            // RX Equalization Ports for Gen3
            .PHY_RXEQ_CTRL          ( phy_rxeq_ctrl_pl ), 
            .PHY_RXEQ_PRESET        ( {PHY_LANE{3'b0}} ), 
            .PHY_RXEQ_LFFS          ( {PHY_LANE{6'b0}} ),         
            .PHY_RXEQ_TXPRESET      ( phy_rxeq_txpreset_pl ),
      
            .PHY_RXEQ_LFFS_SEL      ( phy_rxeq_preset_sel_pclk2 ),      
            .PHY_RXEQ_NEW_TXCOEFF   ( phy_rxeq_new_txcoeff_pclk2 ),   
            .PHY_RXEQ_DONE          ( phy_rxeq_done_pclk2 ),        
            .PHY_RXEQ_ADAPT_DONE    ( phy_rxeq_adapt_done_pclk2 ),
      
            // USB Ports
            .USB_TXONESZEROS        ( {PHY_LANE{1'b0}} ),   // New in Diablo
            .USB_RXEQTRAINING       ( {PHY_LANE{1'b0}} ),   // New in Diablo
            .USB_RXTERMINATION      ( {PHY_LANE{1'b0}} ),   // New in Diablo
            .USB_POWERPRESENT       ( ),  // New in Diablo
      
            // GT  DRP Ports *
            //.GT_DRPCLK            ({PHY_LANE{gt_drpclk}}),
            .GT_DRPADDR             ( gt_drpaddr ),
            .GT_DRPEN               ( gt_drpen ),
            .GT_DRPWE               ( gt_drpwe ),
            .GT_DRPDI               ( gt_drpdi ),

            .GT_DRPRDY              ( gt_drprdy ),
            .GT_DRPDO               ( gt_drpdo ),     

            // Common DRP Port
            .GTCOM_DRPCLK           ( phy_refclk ),   // New in Diablo
            .GTCOM_DRPADDR          ( gtcom_drpaddr_tie_off ), // New in Diablo
            .GTCOM_DRPEN            ( gtcom_drpen_tie_off ),   // New in Diablo
            .GTCOM_DRPWE            ( gtcom_drpwe_tie_off ),   // New in Diablo
            .GTCOM_DRPDI            ( gtcom_drpdi_tie_off ),   // New in Diablo
            .GTCOM_DRPRDY           ( ),  // New in Diablo
            .GTCOM_DRPDO            ( ),  // New in Diablo 

            //---------- External GT COMMON Ports ----------------------
            .EXT_QPLLxREFCLK        ( ext_qpllxrefclk ),
            .EXT_QPLLxRATE          ( ext_qpllxrate ),
            .EXT_QPLLxRCALENB       ( ext_qpllxrcalenb ),

            .EXT_QPLL0PD            ( ext_qpll0pd ),
            .EXT_QPLL0RESET         ( ext_qpll0reset ),
            .EXT_QPLL0LOCK_OUT      ( ext_qpll0lock_out ),
            .EXT_QPLL0OUTCLK_OUT    ( ext_qpll0outclk_out ),
            .EXT_QPLL0OUTREFCLK_OUT ( ext_qpll0outrefclk_out ),      
            .EXT_QPLL1PD            ( ext_qpll1pd ),
            .EXT_QPLL1RESET         ( ext_qpll1reset ),
            .EXT_QPLL1LOCK_OUT      ( ext_qpll1lock_out ),
            .EXT_QPLL1OUTCLK_OUT    ( ext_qpll1outclk_out ),
            .EXT_QPLL1OUTREFCLK_OUT ( ext_qpll1outrefclk_out ),                             
 
            // Debug Ports   // Not used
            .DBG_RATE_DONE          ( {PHY_LANE{1'b0}} ),
            .DBG_RATE_START         ( ),  // New in Diablo
            .DBG_RATE_IDLE          ( ),  // New in Diablo
            .DBG_RXCDRLOCK          ( ),  // New in Diablo
            .DBG_GEN34_EIOS_DET     ( ),  // New in Diablo
            .DBG_TXOUTCLK           ( ),  // New in Diablo
            .DBG_RXOUTCLK           ( ),  // New in Diablo
            .DBG_TXOUTCLKFABRIC     ( ),  // New in Diablo
            .DBG_RXOUTCLKFABRIC     ( ),  // New in Diablo
            .DBG_TXOUTCLKPCS        ( ),  // New in Diablo
            .DBG_RXOUTCLKPCS        ( ),  // New in Diablo
            .DBG_RXRECCLKOUT        ( ),  // New in Diablo
            .DBG_TXPMARESET         ( {PHY_LANE{1'b0}} ),   // New in Diablo
            .DBG_RXPMARESET         ( {PHY_LANE{1'b0}} ),   // New in Diablo
            .DBG_TXPCSRESET         ( {PHY_LANE{1'b0}} ),   // New in Diablo
            .DBG_RXPCSRESET         ( {PHY_LANE{1'b0}} ),   // New in Diablo
            .DBG_RXBUFRESET         ( {PHY_LANE{1'b0}} ),   // New in Diablo
            .DBG_RXCDRRESET         ( {PHY_LANE{1'b0}} ),   // New in Diablo
            .DBG_RXDFELPMRESET      ( {PHY_LANE{1'b0}} ),   // New in Diablo
            .DBG_RRST_N             ( ),  // New in Diablo
            .DBG_PRST_N             ( ),  // New in Diablo
            .DBG_GTPOWERGOOD        ( gt_gtpowergood ),     // New in Diablo
            .DBG_CPLLLOCK           ( ),  // New in Diablo
            .DBG_QPLL0LOCK          ( ),  // New in Diablo
            .DBG_QPLL1LOCK          ( ),  // New in Diablo
            .DBG_TXPROGDIVRESETDONE ( ),  // New in Diablo
            .DBG_TXPMARESETDONE     ( ),  // New in Diablo
            .DBG_RXPMARESETDONE     ( ),  // New in Diablo
            .DBG_TXRESETDONE        ( ),  // New in Diablo
            .DBG_RXRESETDONE        ( ),  // New in Diablo
            .DBG_TXSYNCDONE         ( ),  // New in Diablo
            .DBG_RST_IDLE           ( ),  // New in Diablo
      
            // PRBS Debug Ports
            .DBG_LOOPBACK           ( 3'b0 ),   // New in Diablo
            .DBG_PRBSSEL            ( 4'b0 ),   // New in Diablo
            .DBG_TXPRBSFORCEERR     ( 1'b0 ),   // New in Diablo
            .DBG_RXPRBSCNTRESET     ( 1'b0 ),   // New in Diablo
            .DBG_RXPRBSERR          ( ),  // New in Diablo
            .DBG_RXPRBSLOCKED       ( ),  // New in Diablo
            .PHY_PCIE_MAC_IN_DETECT ( as_mac_in_detect_pl ) // New in Diablo
         );
      end 
   endgenerate


endmodule
