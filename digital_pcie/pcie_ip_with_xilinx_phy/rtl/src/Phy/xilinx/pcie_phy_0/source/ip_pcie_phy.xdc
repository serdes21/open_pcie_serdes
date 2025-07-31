##-----------------------------------------------------------------------------
##
## (c) Copyright 2012-2012 Xilinx, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of Xilinx, Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## Xilinx, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) Xilinx shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or Xilinx had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## Xilinx products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of Xilinx products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.
##
##-----------------------------------------------------------------------------
##
## Project    : PCIE4 PHY IP Block 
## File       : ip_pcie_phy.xdc
## Version    : 1.0 
##-----------------------------------------------------------------------------
#################################################
# gui_cfg                              - X1G1_250M
# pl_link_cap_max_link_width_int       - 1
# axisten_if_freq_int                  - 2
# pl_link_cap_max_link_speed_int       - 1
# ultrascale_device                    - FALSE
# uscaleplus_device                    - TRUE
# shared_logic_int                     - 2
# gtcom_in_core_int                    - 2
# gtwiz_in_core_int                    - 1
# coreclk_freq_int                     - 1
# c_fpga_family                        - USM
#################################################
#################################################
####    IP Level XDC file for PCIE4 PHY IP   ####
#################################################
#
create_clock -name intclk -period 1000 [get_pins  -filter {REF_PIN_NAME=~ O} -of_objects [get_cells  -hierarchical -filter {NAME =~ */diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_intclk}]]

# TXOUTCLKSEL switches during reset. Set the tool to analyze timing with TXOUTCLKSEL set to 'b101.
set_case_analysis 1 [get_pins  -filter {REF_PIN_NAME=~TXOUTCLKSEL[2]} -of_objects [get_cells  -hierarchical -filter {NAME =~ *}]]
set_case_analysis 0 [get_pins  -filter {REF_PIN_NAME=~TXOUTCLKSEL[1]} -of_objects [get_cells  -hierarchical -filter {NAME =~ *}]]
set_case_analysis 1 [get_pins  -filter {REF_PIN_NAME=~TXOUTCLKSEL[0]} -of_objects [get_cells  -hierarchical -filter {NAME =~ *}]]

set_case_analysis 1 [get_pins  -filter {REF_PIN_NAME=~DIV[0]} -of_objects [get_cells  -hierarchical -filter {NAME =~ *diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk}]]
set_case_analysis 0 [get_pins  -filter {REF_PIN_NAME=~DIV[1]} -of_objects [get_cells  -hierarchical -filter {NAME =~ *diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk}]]
set_case_analysis 0 [get_pins  -filter {REF_PIN_NAME=~DIV[2]} -of_objects [get_cells  -hierarchical -filter {NAME =~ *diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk}]]
#
#
set_case_analysis 0 [get_pins -filter {REF_PIN_NAME=~TXRATE[0]} -of_objects [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ ADVANCED.GT.* }]]
set_case_analysis 0 [get_pins -filter {REF_PIN_NAME=~RXRATE[0]} -of_objects [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ ADVANCED.GT.* }]]
set_case_analysis 0 [get_pins -filter {REF_PIN_NAME=~TXRATE[1]} -of_objects [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ ADVANCED.GT.* }]]
set_case_analysis 0 [get_pins -filter {REF_PIN_NAME=~RXRATE[1]} -of_objects [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ ADVANCED.GT.* }]]
set_case_analysis 0 [get_pins -filter {REF_PIN_NAME=~TXRATE[2]} -of_objects [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ ADVANCED.GT.* }]]
set_case_analysis 0 [get_pins -filter {REF_PIN_NAME=~RXRATE[2]} -of_objects [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ ADVANCED.GT.* }]]
#





