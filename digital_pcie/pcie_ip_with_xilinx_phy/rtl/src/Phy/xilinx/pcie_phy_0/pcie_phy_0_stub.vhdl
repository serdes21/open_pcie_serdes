-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2023.1 (lin64) Build 3865809 Sun May  7 15:04:56 MDT 2023
-- Date        : Wed May 21 14:30:45 2025
-- Host        : negoten2-virtual-machine running 64-bit Ubuntu 22.04.5 LTS
-- Command     : write_vhdl -force -mode synth_stub -rename_top pcie_phy_0 -prefix
--               pcie_phy_0_ pcie_phy_0_stub.vhdl
-- Design      : pcie_phy_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcvu3p-ffvc1517-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pcie_phy_0 is
  Port ( 
    phy_refclk : in STD_LOGIC;
    phy_gtrefclk : in STD_LOGIC;
    phy_rst_n : in STD_LOGIC;
    phy_txdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    phy_txdatak : in STD_LOGIC_VECTOR ( 1 downto 0 );
    phy_txdata_valid : in STD_LOGIC_VECTOR ( 0 to 0 );
    phy_txstart_block : in STD_LOGIC_VECTOR ( 0 to 0 );
    phy_txsync_header : in STD_LOGIC_VECTOR ( 1 downto 0 );
    phy_rxp : in STD_LOGIC_VECTOR ( 0 to 0 );
    phy_rxn : in STD_LOGIC_VECTOR ( 0 to 0 );
    phy_txdetectrx : in STD_LOGIC;
    phy_txelecidle : in STD_LOGIC_VECTOR ( 0 to 0 );
    phy_txcompliance : in STD_LOGIC_VECTOR ( 0 to 0 );
    phy_rxpolarity : in STD_LOGIC_VECTOR ( 0 to 0 );
    phy_powerdown : in STD_LOGIC_VECTOR ( 1 downto 0 );
    phy_rate : in STD_LOGIC_VECTOR ( 1 downto 0 );
    phy_txmargin : in STD_LOGIC_VECTOR ( 2 downto 0 );
    phy_txswing : in STD_LOGIC;
    phy_txdeemph : in STD_LOGIC;
    phy_txeq_ctrl : in STD_LOGIC_VECTOR ( 1 downto 0 );
    phy_txeq_preset : in STD_LOGIC_VECTOR ( 3 downto 0 );
    phy_txeq_coeff : in STD_LOGIC_VECTOR ( 5 downto 0 );
    phy_rxeq_ctrl : in STD_LOGIC_VECTOR ( 1 downto 0 );
    phy_rxeq_txpreset : in STD_LOGIC_VECTOR ( 3 downto 0 );
    as_mac_in_detect : in STD_LOGIC;
    as_cdr_hold_req : in STD_LOGIC;
    phy_coreclk : out STD_LOGIC;
    phy_userclk : out STD_LOGIC;
    phy_mcapclk : out STD_LOGIC;
    phy_pclk : out STD_LOGIC;
    phy_txp : out STD_LOGIC_VECTOR ( 0 to 0 );
    phy_txn : out STD_LOGIC_VECTOR ( 0 to 0 );
    phy_rxdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    phy_rxdatak : out STD_LOGIC_VECTOR ( 1 downto 0 );
    phy_rxdata_valid : out STD_LOGIC_VECTOR ( 0 to 0 );
    phy_rxstart_block : out STD_LOGIC_VECTOR ( 1 downto 0 );
    phy_rxsync_header : out STD_LOGIC_VECTOR ( 1 downto 0 );
    phy_rxvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    phy_phystatus : out STD_LOGIC_VECTOR ( 0 to 0 );
    phy_phystatus_rst : out STD_LOGIC;
    phy_rxelecidle : out STD_LOGIC_VECTOR ( 0 to 0 );
    phy_rxstatus : out STD_LOGIC_VECTOR ( 2 downto 0 );
    phy_txeq_fs : out STD_LOGIC_VECTOR ( 5 downto 0 );
    phy_txeq_lf : out STD_LOGIC_VECTOR ( 5 downto 0 );
    phy_txeq_new_coeff : out STD_LOGIC_VECTOR ( 17 downto 0 );
    phy_txeq_done : out STD_LOGIC_VECTOR ( 0 to 0 );
    phy_rxeq_preset_sel : out STD_LOGIC_VECTOR ( 0 to 0 );
    phy_rxeq_new_txcoeff : out STD_LOGIC_VECTOR ( 17 downto 0 );
    phy_rxeq_adapt_done : out STD_LOGIC_VECTOR ( 0 to 0 );
    phy_rxeq_done : out STD_LOGIC_VECTOR ( 0 to 0 );
    gt_gtpowergood : out STD_LOGIC_VECTOR ( 0 to 0 )
  );

end pcie_phy_0;

architecture stub of pcie_phy_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "phy_refclk,phy_gtrefclk,phy_rst_n,phy_txdata[63:0],phy_txdatak[1:0],phy_txdata_valid[0:0],phy_txstart_block[0:0],phy_txsync_header[1:0],phy_rxp[0:0],phy_rxn[0:0],phy_txdetectrx,phy_txelecidle[0:0],phy_txcompliance[0:0],phy_rxpolarity[0:0],phy_powerdown[1:0],phy_rate[1:0],phy_txmargin[2:0],phy_txswing,phy_txdeemph,phy_txeq_ctrl[1:0],phy_txeq_preset[3:0],phy_txeq_coeff[5:0],phy_rxeq_ctrl[1:0],phy_rxeq_txpreset[3:0],as_mac_in_detect,as_cdr_hold_req,phy_coreclk,phy_userclk,phy_mcapclk,phy_pclk,phy_txp[0:0],phy_txn[0:0],phy_rxdata[63:0],phy_rxdatak[1:0],phy_rxdata_valid[0:0],phy_rxstart_block[1:0],phy_rxsync_header[1:0],phy_rxvalid[0:0],phy_phystatus[0:0],phy_phystatus_rst,phy_rxelecidle[0:0],phy_rxstatus[2:0],phy_txeq_fs[5:0],phy_txeq_lf[5:0],phy_txeq_new_coeff[17:0],phy_txeq_done[0:0],phy_rxeq_preset_sel[0:0],phy_rxeq_new_txcoeff[17:0],phy_rxeq_adapt_done[0:0],phy_rxeq_done[0:0],gt_gtpowergood[0:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "pcie_phy_0_core_top,Vivado 2023.1";
begin
end;
