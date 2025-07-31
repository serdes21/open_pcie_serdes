// -------------------------------------------------------------------------
// ---  RCS information:
// ---    $DateTime: 2019/10/21 10:26:13 $
// ---    $Revision: #16 $
// ---    $Id: //dwh/pcie_iip/main/DWC_pcie/DWC_pcie_ctl/examples/pcie_iip_subsystem.sv#16 $
// -------------------------------------------------------------------------
// --- Module Description:
// --- Instantiate the Synopsys DWC PCIe core (MAC), the PHY, the clk/rst
// --- management block and external RAMs
// -----------------------------------------------------------------------------

/**
 * The PCIe IIP Device contains an instance of the PCIe DesignWare core (DUT).
 * The DUT is connected to tightly coupled RAMs, conditionally the PCIe
 * PHY, and the clock and reset controller within this module.
 *
 * The PCIe IIP Device instantiates the following components...
 * - DWC_pcie_<ep|rc|dm|sw> : DUT instance. Can be the EP, RC, DM or SW core.
 * - RAMs : Core tightly coupled memories, retry buffer, radm CPL/P/NP buffers, etc
 * - PCIe PHY : Conditional instance of the PHY, PHY module is configurayion dependent
 * - @ref clk_rst : Device specific Clock and reset controller
 *
 * The PCIe IIP Device also contains the following instances...
 * - @ref parity_check : (optional) RAM parity checker
 */
module `SNPS_PCIE_IIP_SUBSYS_MODULE #(
   parameter NL                       = `CX_NL,
   parameter PHY_NB                   = `CX_PHY_NB,
   parameter NW                       = `CX_NW,
   parameter NF                       = `CX_NFUNC,
   parameter PF_WD                    = `CX_NFUNC_WD,
   parameter DW                       = 32*NW,
   parameter NVC                      = `CX_NVC,
   parameter NVC_XALI_EXP             = `CX_NVC_XALI_EXPANSION,
   parameter NHQ                      = `CX_NHQ,
   parameter NDQ                      = `CX_NDQ,

   parameter BUSNUM_WD                = `CX_BUSNUM_WD,
   parameter DEVNUM_WD                = `CX_DEVNUM_WD,

   parameter DATA_PAR_WD              = `TRGT_DATA_PROT_WD,
     parameter RADM_DW                  = DW,
     parameter RADM_AW                  = `FLT_Q_ADDR_WIDTH,
   parameter DW_W_PAR                 = DW + DATA_PAR_WD,
   parameter DW_WO_PAR                = DW,
   parameter TX_HW_W_PAR              = 128 + `CX_RAS_PCIE_HDR_PROT_WD,
   parameter NVF                      = `CX_NVFUNC,
   parameter VFI_WD                   = `CX_LOGBASE2(NVF),
   parameter VF_WD                    = `CX_LOGBASE2(NVF) + 1,

   parameter RX_TLP                   = `CX_RX_TLP,
   parameter RX_NDLLP                 = (NW>>1 == 0) ? 1 : NW>>1,
   parameter LBC_EXT_AW               = `CX_LBC_EXT_AW,
   parameter LBC_NW                   = `CX_LBC_NW,
   parameter ATTR_WD                  = `FLT_Q_ATTR_WIDTH,

   // PIPE parameters
   parameter P_R_WD                   = `PCLK_RATE_WD,
   parameter RATE_WD                  = `CX_PHY_RATE_WD,
   parameter WIDTH_WD                 = `CX_PHY_WIDTH_WD,
   parameter TXDEEMPH_WD              = `CX_PHY_TXDEEMPH_WD,
   parameter TXEI_WD                  = `CX_PHY_TXEI_WD,
   parameter RXSB_WD                  = `CX_PHY_RXSB_WD,
   parameter RXSTATUS_WD              = 3,
   parameter SYNCHDR_WD               = `CX_PHY_RXSH_WD,
   parameter RX_PSET_WD               = 3,
   parameter TX_PSET_WD               = `PSET_ID_WD,
   parameter TX_COEF_WD               = 18,
   parameter TX_CRSR_WD               = 6,
   parameter DIRFEEDBACK_WD           = 6,
   parameter FOMFEEDBACK_WD           = 8,
   parameter FS_LF_WD                 = 6,
   parameter ORIG_DATA_WD             = 8,
   parameter SERDES_DATA_WD           = 10,
   parameter PIPE_DATA_WD             = (`CX_PIPE_SERDES_ARCH_VALUE) ? (SERDES_DATA_WD) : (ORIG_DATA_WD),


   // entries in completion lut
   parameter CPL_LUT_DEPTH            = `CX_MAX_TAG +1,

   // TLP prefix parameters
   parameter PRFX_DW                  = 32*`CX_NPRFX,
   parameter PRFX_W_PAR               = `FLT_Q_PRFX_WIDTH,

   // DBI parameter
   parameter DBI_SLV_DATA_WD          = `CC_DBI_SLV_BUS_DATA_WIDTH,
   parameter DBI_SLV_ADDR_WD          = `CC_DBI_SLV_BUS_ADDR_WIDTH,
   parameter DBI_SLV_ID_WD            = `CC_DBI_SLV_ID_WD,
   parameter DBISLV_BURST_LEN_PW      = `CC_DBISLV_BURST_LEN_PW,
   parameter DBI_NUM_MASTERS          = 16,
   parameter DBI_NUM_MSTRS_WD         = 4,


   parameter RBUF_PW           = `RBUF_PW,
   parameter RBUF_WD           = `RBUF_WIDTH,
   parameter SOTBUF_PW         = `SOTBUF_L2DEPTH,
   parameter DATAQ_WD          = NW+NDQ*(1+1+1+1+1)+DW,
   parameter RADM_PQ_HWD       = `CX_RADM_PQ_HWD,



////////////////AMBA //////////
parameter CC_IB_MCPL_SEG_BUF_RAM_DATA_WD  = `CC_IB_MCPL_SEG_BUF_RAM_DATA_WD,
parameter CC_IB_MCPL_SEG_BUF_RAM_ADDR_WD  = `CC_IB_MCPL_SEG_BUF_RAM_ADDR_WD,
parameter CC_IB_MCPL_SEG_BUF_RAM_DP       = `CC_IB_MCPL_SEG_BUF_RAM_DP,
parameter CC_MSTR_RSP_INTF_WD            = `CC_IB_MCPL_CDC_RAM_DATA_WD,
parameter CC_MCB_A2C_FIFO_ADDR_WD        = `CC_IB_MCPL_CDC_RAM_ADDR_WD,
parameter MSTR_DATA_WD_GT_CORE_DATA_WD   = `CC_MSTR_BUS_DATA_WIDTH > `CC_CORE_DATA_BUS_WD,
parameter TRGT1_DATA_WD                  = MSTR_DATA_WD_GT_CORE_DATA_WD ? `CC_MSTR_BUS_DATA_WIDTH : `CC_CORE_DATA_BUS_WD,
parameter CC_IB_RD_REQ_ORDR_RAM_ADDR_WD  = `CC_IB_RD_REQ_ORDR_RAM_ADDR_WD,
parameter CC_IB_RD_REQ_ORDR_RAM_DATA_WD  = `CC_IB_RD_REQ_ORDR_RAM_DATA_WD,
parameter CC_IB_WR_REQ_CDC_RAM_ADDR_WD   = `CC_IB_WR_REQ_CDC_RAM_ADDR_WD,
parameter CC_IB_RD_REQ_CDC_RAM_ADDR_WD   = `CC_IB_RD_REQ_CDC_RAM_ADDR_WD,
parameter CC_IB_WR_REQ_CDC_RAM_DATA_WD   = `CC_IB_WR_REQ_CDC_RAM_DATA_WD,
parameter CC_IB_RD_REQ_CDC_RAM_DATA_WD   = `CC_IB_RD_REQ_CDC_RAM_DATA_WD,
 // Slave Non-Posted Write Set-Aside RAM
parameter SLV_NPW_SAB_RAM_DATA_WD       = `CC_SLV_NPW_SAB_RAM_DATA_WD,
parameter SLV_NPW_SAB_RAM_DP            = `CC_SLV_NPW_SAB_RAM_DP,
parameter SLV_NPW_SAB_RAM_ADDR_WD       = `CC_SLV_NPW_SAB_RAM_ADDR_WD,
// Decomposed Posted Header RAM
parameter PRF_HDRQ_WD                   = `CC_PRF_HDRQ_WD,
parameter OB_PDCMP_HDR_RAM_DATA_WD      = `CC_OB_PDCMP_HDR_RAM_DATA_WD,
parameter OB_PDCMP_HDR_RAM_DP           = `CC_OB_PDCMP_HDR_RAM_DP,
parameter OB_PDCMP_HDR_RAM_ADDR_WD      = `CC_OB_PDCMP_HDR_RAM_ADDR_WD,
parameter OB_PDCMP_HDR_RAM_PTR_WD       = `CC_OB_PDCMP_HDR_RAM_PTR_WD,
// -------------------------------------------------------------------------------------
// Decomposed Posted Data RAM
parameter OB_PDCMP_DATA_RAM_DATA_WD     = `CC_OB_PDCMP_DATA_RAM_DATA_WD,
parameter OB_PDCMP_DATA_RAM_DP          = `CC_OB_PDCMP_DATA_RAM_DP,
parameter OB_PDCMP_DATA_RAM_ADDR_WD     = `CC_OB_PDCMP_DATA_RAM_ADDR_WD,
parameter OB_PDCMP_DATA_RAM_PTR_WD      = `CC_OB_PDCMP_DATA_RAM_PTR_WD,
// -------------------------------------------------------------------------------------
// Decomposed NonPosted RAM
parameter OB_NPDCMP_RAM_DATA_WD         = `CC_OB_NPDCMP_RAM_DATA_WD,
parameter OB_NPDCMP_RAM_DP              = `CC_OB_NPDCMP_RAM_DP,
parameter OB_NPDCMP_RAM_ADDR_WD         = `CC_OB_NPDCMP_RAM_ADDR_WD,
parameter OB_NPDCMP_RAM_PTR_WD          = `CC_OB_NPDCMP_RAM_PTR_WD,

parameter OB_CCMP_DATA_RAM_ADDR_WD   = `CC_OB_CCMP_DATA_RAM_ADDR_WD,
parameter OB_CCMP_DATA_RAM_DATA_WD   = `CC_OB_CCMP_DATA_RAM_DATA_WD,



  parameter RADM_SBUF_HDRQ_WD         = `CX_RADM_SBUF_HDRQ_WD,
  parameter RADM_SBUF_HDRQ_PW         = `CX_RADM_SBUF_HDRQ_PW,
  parameter RADM_SBUF_DATAQ_RAM_WD    = `CX_RADM_SBUF_DATAQ_RAM_WD,
  parameter RADM_SBUF_DATAQ_PW        = `CX_RADM_SBUF_DATAQ_PW,


  // AMBA-specific parameters
   parameter MSTR_ID_WD               = `CC_MAX_MSTR_TAG_PW,
   parameter MSTR_DATA_WD             = `MASTER_BUS_DATA_WIDTH,
   parameter MSTR_WSTRB_WD            = `CC_MSTR_BUS_WSTRB_WIDTH,
   parameter MSTR_RESP_MISC_INFO_PW   = `MSTR_RESP_MISC_INFO_PW,
   parameter MSTR_ADDR_WD             = `MASTER_BUS_ADDR_WIDTH,
   parameter MSTR_BURST_LEN_PW        = `CC_MSTR_BURST_LEN_PW,
   parameter MSTR_MISC_INFO_PW        = `MSTR_MISC_INFO_PW,

   parameter SLV_ID_WD                = `CC_SLV_BUS_ID_WIDTH,
   parameter SLV_ADDR_WD              = `SLAVE_BUS_ADDR_WIDTH,
   parameter SLV_BURST_LEN_PW         = `CC_SLV_BURST_LEN_PW,
   parameter SLV_MISC_INFO_PW         = `SLV_MISC_INFO_PW,
   parameter SLV_DATA_WD              = `SLAVE_BUS_DATA_WIDTH,
   parameter SLV_WSTRB_WD             = `CC_SLV_BUS_WSTRB_WIDTH,
   parameter SLV_RESP_MISC_INFO_PW    = `SLV_RESP_MISC_INFO_PW,
   parameter SLV_NUM_MASTERS          = 16,
   parameter SLAVE_NUM_MSTRS_WD       = 4,
   parameter CLIENT_HDR_PROT_WD       = `CLIENT_HDR_PROT_WD,
   parameter TRGT_HDR_WD              = `TRGT_HDR_WD,
   parameter TRGT_HDR_PROT_WD         = `TRGT_HDR_PROT_WD,

   parameter ERR_BUS_WD               = 13 + `CX_DPC_ENABLE_VALUE,
   parameter TRGT_DATA_WD             = `TRGT_DATA_WD,

   parameter RADM_RAM_RD_LATENCY      = `CX_RADM_RAM_RD_LATENCY,
   parameter RADM_FORMQ_RAM_RD_LATENCY = `CX_RADM_FORMQ_RAM_RD_LATENCY,
   parameter RETRY_RAM_RD_LATENCY     = `CX_RETRY_RAM_RD_LATENCY,
   parameter RETRY_SOT_RAM_RD_LATENCY = `CX_RETRY_SOT_RAM_RD_LATENCY,

   parameter LOOKUPID_WD              = `CX_REMOTE_LOOKUPID_WD,
   parameter TAG_SIZE                 = `CX_TAG_SIZE,
   parameter HCRD_WD                  = `SCALED_FC_SUPPORTED ? 12 :  8,
   parameter DCRD_WD                  = `SCALED_FC_SUPPORTED ? 16 : 12


   ,
   parameter PM_MST_WD       = 5,
   parameter PM_SLV_WD       = 5
 ) (



input                            power_up_rst_n,
input                            button_rst_n,
input                            perst_n,
output                            auxclk,
output                           muxd_aux_clk,
output                           muxd_aux_clk_g,
output                           radm_clk_g,

input                            sys_aux_pwr_det,
input                            app_clk_req_n,
input                            app_clk_pm_en,
input                            app_init_rst,
input                            app_req_entr_l1,
input                            app_ready_entr_l23,
input                            app_req_exit_l1,
input                            app_xfer_pending,
input [NF-1:0]                   exp_rom_validation_status_strobe,
input [NF*3-1:0]                 exp_rom_validation_status,
input [NF-1:0]                   exp_rom_validation_details_strobe,
input [NF*4-1:0]                 exp_rom_validation_details,
input                            app_req_retry_en,
input   [NF-1:0]                 app_pf_req_retry_en,










output   [NF-1:0]               cfg_hp_slot_ctrl_access,
output   [NF-1:0]               cfg_dll_state_chged_en,
output   [NF-1:0]               cfg_cmd_cpled_int_en,
output   [NF-1:0]               cfg_hp_int_en,
output   [NF-1:0]               cfg_pre_det_chged_en,
output   [NF-1:0]               cfg_mrl_sensor_chged_en,
output   [NF-1:0]               cfg_pwr_fault_det_en,
output   [NF-1:0]               cfg_atten_button_pressed_en,

// PHY inside device_top (or inside core), export serial lines, import refclk
input  [NL-1:0]                  rxp,
input  [NL-1:0]                  rxn,
output [NL-1:0]                  txp,
output [NL-1:0]                  txn,
`ifndef SYNTHESIS
input  [NL-1:0]                  rxpresent,
`endif // SYNTHESIS

input                            refclk_p,
input                            refclk_n,

output                           local_ref_clk_req_n,







// AXI master write request
output  [MSTR_ID_WD-1:0]         mstr_awid,
output                           mstr_awvalid,
output  [MSTR_ADDR_WD-1:0]       mstr_awaddr,
output  [MSTR_BURST_LEN_PW-1:0]  mstr_awlen,
output  [2:0]                    mstr_awsize,
output  [1:0]                    mstr_awburst,
output                           mstr_awlock,
output  [3:0]                    mstr_awqos,
output  [3:0]                    mstr_awcache,
output  [2:0]                    mstr_awprot,
output  [MSTR_MISC_INFO_PW-1:0]  mstr_awmisc_info,
output  [63:0]                   mstr_awmisc_info_hdr_34dw,
output                           mstr_awmisc_info_ep,
output                           mstr_awmisc_info_last_dcmp_tlp,

input                            mstr_awready,

// AXI master write data
output                           mstr_wvalid,
output                           mstr_wlast,
output  [MSTR_DATA_WD-1:0]       mstr_wdata,
output  [MSTR_WSTRB_WD-1:0]      mstr_wstrb,
input                            mstr_wready,
output                           mstr_aclk_gated,

// AXI master write response
input   [MSTR_ID_WD-1:0]         mstr_bid,
input                            mstr_bvalid,
input   [1:0]                    mstr_bresp,
input   [1:0]                    mstr_bmisc_info_cpl_stat,
output                           mstr_bready,

// AXI master read request
output  [MSTR_ID_WD-1:0]         mstr_arid,
output                           mstr_arvalid,
output  [MSTR_ADDR_WD-1:0]       mstr_araddr,
output  [MSTR_BURST_LEN_PW-1:0]  mstr_arlen,
output  [2:0]                    mstr_arsize,
output  [1:0]                    mstr_arburst,
output                           mstr_arlock,
output  [3:0]                    mstr_arqos,
output  [3:0]                    mstr_arcache,
output  [2:0]                    mstr_arprot,
output  [MSTR_MISC_INFO_PW-1:0]  mstr_armisc_info,
output                           mstr_armisc_info_last_dcmp_tlp,
output                           mstr_armisc_info_zeroread,
input                            mstr_arready,

// AXI master read response & read data
input   [MSTR_ID_WD-1:0]         mstr_rid,
input                            mstr_rvalid,
input                            mstr_rlast,
input   [MSTR_DATA_WD-1:0]       mstr_rdata,
input   [1:0]                    mstr_rresp,
input   [MSTR_RESP_MISC_INFO_PW-1:0]  mstr_rmisc_info,
input   [1:0]                    mstr_rmisc_info_cpl_stat,
output                           mstr_rready,

// AXI master low power
input                            mstr_csysreq,
output                           mstr_csysack,
output                           mstr_cactive,
input                            mstr_aclk,
output                           mstr_aresetn,

// AXI slave interface
// AXI slave Write address channel
output                           slv_aclk_gated,
input   [SLV_ID_WD-1:0]          slv_awid,
input   [SLV_ADDR_WD-1:0]        slv_awaddr,
input   [SLV_BURST_LEN_PW-1:0]   slv_awlen,
input   [2:0]                    slv_awsize,
input   [1:0]                    slv_awburst,
input                            slv_awlock,
input   [3:0]                    slv_awqos,
input   [3:0]                    slv_awcache,
input   [2:0]                    slv_awprot,
input                            slv_awvalid,
input   [SLV_MISC_INFO_PW-1:0]   slv_awmisc_info,
input   [63:0]                   slv_awmisc_info_hdr_34dw,
input   [TAG_SIZE-1:0]           slv_awmisc_info_p_tag,

output                           slv_awready,

// AXI slave Write data channel
input   [SLV_DATA_WD-1:0]        slv_wdata,
input   [SLV_WSTRB_WD-1:0]       slv_wstrb,
input                            slv_wlast,
input                            slv_wvalid,
input                            slv_wmisc_info_ep,
input                            slv_wmisc_info_silentDrop,
output                           slv_wready,

// AXI slave Write response channel
output  [SLV_ID_WD-1:0]          slv_bid,
output  [1:0]                    slv_bresp,
output                           slv_bvalid,
output  [SLV_RESP_MISC_INFO_PW-1:0]   slv_bmisc_info,
input                            slv_bready,
// AXI slave Read address channel
input   [SLV_ID_WD-1:0]          slv_arid,
input   [SLV_ADDR_WD-1:0]        slv_araddr,
input   [SLV_BURST_LEN_PW-1:0]   slv_arlen,
input   [2:0]                    slv_arsize,
input   [1:0]                    slv_arburst,
input                            slv_arlock,
input   [3:0]                    slv_arqos,
input   [3:0]                    slv_arcache,
input   [2:0]                    slv_arprot,
input                            slv_arvalid,
input   [SLV_MISC_INFO_PW-1:0]   slv_armisc_info,

output                           slv_arready,
// AXI slave Read data channel
output  [SLV_ID_WD-1:0]          slv_rid,
output  [SLV_DATA_WD-1:0]        slv_rdata,
output  [1:0]                    slv_rresp,
output                           slv_rlast,
output                           slv_rvalid,
output  [SLV_RESP_MISC_INFO_PW-1:0]   slv_rmisc_info,
input                            slv_rready,
// AXI slave Low-power Channel
input                            slv_csysreq,
output                           slv_csysack,
output                           slv_cactive,

// clk_and_reset Signal Descriptions for axi side.
input                            slv_aclk,
output                           slv_aresetn,




output [2:0]                        radm_trgt1_vc,




input                               app_dbi_ro_wr_disable,      // Set dbi_ro_wr_en to 0, disable write to DBI_RO_WR_EN bit

input   [31:0]                      dbi_addr,
input   [31:0]                      dbi_din,
input                               dbi_cs,
input                               dbi_cs2,
input   [3:0]                       dbi_wr,
output                              lbc_dbi_ack,
output  [31:0]                      lbc_dbi_dout,

// START_IO:ELBI Signal Descriptions. EP Mode Only
input   [NF-1:0]                    ext_lbc_ack,
input   [(LBC_NW*32*NF)-1:0]        ext_lbc_din,
output  [LBC_EXT_AW-1:0]            lbc_ext_addr,
output  [(LBC_NW*32)-1:0]           lbc_ext_dout,
output  [NF-1:0]                    lbc_ext_cs,
output  [(4*LBC_NW)-1:0]            lbc_ext_wr,
output                              lbc_ext_rom_access,
output                              lbc_ext_io_access,
output  [2:0]                       lbc_ext_bar_num,
// END_IO:ELBI Signal Descriptions.


input                               ven_msi_req,
input   [PF_WD-1:0]                 ven_msi_func_num,
input   [2:0]                       ven_msi_tc,
input   [4:0]                       ven_msi_vector,
output                              ven_msi_grant,
output  [NF-1:0]                    cfg_msi_en,


// START_IO:VPD Signal Descriptions.
// END_IO:VPD Signal Descriptions.












// START_IO:VMI Signal Descriptions.
input   [1:0]                       ven_msg_fmt,
input   [4:0]                       ven_msg_type,
input   [2:0]                       ven_msg_tc,
input                               ven_msg_td,
input                               ven_msg_ep,
input   [ATTR_WD-1:0]               ven_msg_attr,
input   [9:0]                       ven_msg_len,
input   [PF_WD-1:0]                 ven_msg_func_num,
input   [TAG_SIZE-1:0]              ven_msg_tag,
input   [7:0]                       ven_msg_code,
input   [63:0]                      ven_msg_data,
input                               ven_msg_req,
output                              ven_msg_grant,
// END_IO:VMI Signal Descriptions.

// START_IO:SII Signal Descriptions.

input   [NF-1:0]                    sys_int,
input   [NF-1:0]                    apps_pm_xmt_pme,



output  [NVC-1:0]                   radm_q_not_empty,
output  [NVC-1:0]                   radm_qoverflow,


output                              pm_xtlh_block_tlp,
output  [(64*NF)-1:0]               cfg_bar0_start,
output  [(64*NF)-1:0]               cfg_bar0_limit,
output  [(32*NF)-1:0]               cfg_bar1_start,
output  [(32*NF)-1:0]               cfg_bar1_limit,
output  [(64*NF)-1:0]               cfg_bar2_start,
output  [(64*NF)-1:0]               cfg_bar2_limit,
output  [(32*NF)-1:0]               cfg_bar3_start,
output  [(32*NF)-1:0]               cfg_bar3_limit,
output  [(64*NF)-1:0]               cfg_bar4_start,
output  [(64*NF)-1:0]               cfg_bar4_limit,
output  [(32*NF)-1:0]               cfg_bar5_start,
output  [(32*NF)-1:0]               cfg_bar5_limit,
output  [(32*NF)-1:0]               cfg_exp_rom_start,
output  [(32*NF)-1:0]               cfg_exp_rom_limit,

output  [NF-1:0]                    cfg_bus_master_en,


output  [(3*NF)-1:0]                cfg_max_payload_size,
output  [NF-1:0]                    cfg_rcb,

output  [NF-1:0]                    cfg_mem_space_en,
output  [(3*NF)-1:0]                cfg_max_rd_req_size,


output                              rdlh_link_up,
output  [5:0]                       smlh_ltssm_state,
output  [2:0]                       pm_curnt_state,

output                              smlh_link_up,
output                              smlh_req_rst_not,
output                              link_req_rst_not,
output                              brdg_slv_xfer_pending,
output                              brdg_dbi_xfer_pending,
output                              radm_xfer_pending,

output  [NF-1:0]                    cfg_reg_serren,
output  [NF-1:0]                    cfg_cor_err_rpt_en,
output  [NF-1:0]                    cfg_nf_err_rpt_en,
output  [NF-1:0]                    cfg_f_err_rpt_en,



output  [63:0]                      cxpl_debug_info,
output  [`CX_INFO_EI_WD-1:0]        cxpl_debug_info_ei,

output                              training_rst_n,
output                              radm_pm_turnoff,
output                              radm_msg_unlock,
input [NF-1:0]                      outband_pwrup_cmd,

output [(3*NF)-1:0]                 pm_dstate,
output [NF-1:0]                     aux_pm_en,
output [NF-1:0]                     pm_pme_en,
output                              pm_linkst_in_l0s,
output                              pm_linkst_in_l1,
output                              pm_l1_entry_started,
output                              pm_linkst_in_l2,
output                              pm_linkst_l2_exit,

output  [NF-1:0]                    pm_status,
output  [BUSNUM_WD-1:0]             cfg_pbus_num,
output  [DEVNUM_WD-1:0]             cfg_pbus_dev_num,



output  [RX_TLP-1:0]                radm_vendor_msg,

output  [(RX_TLP*64)-1:0]           radm_msg_payload,
output                              wake,
output  [(RX_TLP*16)-1:0]           radm_msg_req_id,
// END_IO:SII Signal Descriptions.


output                              trgt_cpl_timeout,
output  [PF_WD-1:0]                 trgt_timeout_cpl_func_num,
output  [2:0]                       trgt_timeout_cpl_tc,
output  [1:0]                       trgt_timeout_cpl_attr,
output  [11:0]                      trgt_timeout_cpl_len,
output  [LOOKUPID_WD-1:0]           trgt_timeout_lookup_id,
output  [LOOKUPID_WD-1:0]           trgt_lookup_id,
output                              trgt_lookup_empty,



// completion timeout interface
output                              radm_cpl_timeout,
output  [PF_WD-1:0]                 radm_timeout_func_num,
output  [2:0]                       radm_timeout_cpl_tc,
output  [1:0]                       radm_timeout_cpl_attr,
output  [11:0]                      radm_timeout_cpl_len,
output  [TAG_SIZE-1:0]              radm_timeout_cpl_tag,




output                              assert_inta_grt,
output                              assert_intb_grt,
output                              assert_intc_grt,
output                              assert_intd_grt,
output                              deassert_inta_grt,
output                              deassert_intb_grt,
output                              deassert_intc_grt,
output                              deassert_intd_grt,
output  [(8*NF)-1:0]                cfg_int_pin,

output  [NF-1:0]                    cfg_send_cor_err,
output  [NF-1:0]                    cfg_send_nf_err,
output  [NF-1:0]                    cfg_send_f_err,
output  [NF-1:0]                    cfg_int_disable,
output  [NF-1:0]                    cfg_no_snoop_en,
output  [NF-1:0]                    cfg_relax_order_en,











// ======================================================================
//                    External RAMs Ports
// ======================================================================

// ----------------------------------------------------------------------
// Retry/SOT buffer w/ optional parity
// ----------------------------------------------------------------------

// Retry buffer external RAM interface
output      [RBUF_PW-1:0]  xdlh_retryram_addr,
output      [RBUF_WD-1:0]  xdlh_retryram_data,
output                     xdlh_retryram_we,
output                     xdlh_retryram_en,
input       [RBUF_WD-1:0]  retryram_xdlh_data,

// Retry SOT buffer
output      [SOTBUF_PW-1:0]   xdlh_retrysotram_waddr,
output      [SOTBUF_PW-1:0]   xdlh_retrysotram_raddr,
output      [`SOTBUF_WIDTH -1:0]    xdlh_retrysotram_data,
output                          xdlh_retrysotram_we,
output                          xdlh_retrysotram_en,
input      [`SOTBUF_WIDTH -1:0] retrysotram_xdlh_data,

// ---------------------------------------------------------------------
// RADM Queues
// ----------------------------------------------------------------------


  input    [NHQ*(RADM_SBUF_HDRQ_WD)-1:0]  p_hdrq_dataout,
  output   [NHQ*(RADM_SBUF_HDRQ_PW)-1:0]   p_hdrq_addra,
  output   [NHQ*(RADM_SBUF_HDRQ_PW)-1:0]   p_hdrq_addrb,
  output  [NHQ*(RADM_SBUF_HDRQ_WD)-1:0] p_hdrq_datain,
  output  [NHQ-1:0]                     p_hdrq_ena,
  output  [NHQ-1:0]                     p_hdrq_enb,
  output  [NHQ-1:0]                     p_hdrq_wea,
  input   [NDQ*(RADM_SBUF_DATAQ_RAM_WD)-1:0]  p_dataq_dataout,
  output  [NDQ*(RADM_SBUF_DATAQ_PW)-1:0]  p_dataq_addra,
  output  [NDQ*(RADM_SBUF_DATAQ_PW)-1:0]  p_dataq_addrb,
  output  [NDQ*(RADM_SBUF_DATAQ_RAM_WD)-1:0]  p_dataq_datain,
  output  [NDQ-1:0]                   p_dataq_ena,
  output  [NDQ-1:0]                   p_dataq_enb,
  output  [NDQ-1:0]                   p_dataq_wea,

  // These aren't currently used
  input    [(RADM_SBUF_HDRQ_PW)-1:0]   p_hdrq_depth,
  input    [(RADM_SBUF_DATAQ_PW)-1:0]  p_dataq_depth,







// Master completion buffer segment buffer RAM outputs
output [CC_IB_MCPL_SEG_BUF_RAM_ADDR_WD-1:0]   ib_mcpl_sb_ram_addra,
output                                        ib_mcpl_sb_ram_wea,
output [CC_IB_MCPL_SEG_BUF_RAM_DATA_WD-1:0]   ib_mcpl_sb_ram_dina,
output [CC_IB_MCPL_SEG_BUF_RAM_ADDR_WD-1:0]   ib_mcpl_sb_ram_addrb,
output                                        ib_mcpl_sb_ram_enb,
input [CC_IB_MCPL_SEG_BUF_RAM_DATA_WD-1:0]    ib_mcpl_sb_ram_doutb,


// -------------------------------------------------------------------------------------
// AXI Bridge Inbound Requester (RAM address width)
// -------------------------------------------------------------------------------------

   output [CC_IB_RD_REQ_ORDR_RAM_ADDR_WD-1:0]     ib_rreq_ordr_ram_addra,
   output [CC_IB_RD_REQ_ORDR_RAM_ADDR_WD-1:0]     ib_rreq_ordr_ram_addrb,
   output                                         ib_rreq_ordr_ram_wea,
   output                                         ib_rreq_ordr_ram_enb,
   output [CC_IB_RD_REQ_ORDR_RAM_DATA_WD-1:0]     ib_rreq_ordr_ram_dina,
   input  [CC_IB_RD_REQ_ORDR_RAM_DATA_WD-1:0]     ib_rreq_ordr_ram_doutb,



  // -------------------------------------------------------------------------------------
  // AXI Slave RAMs
  // -------------------------------------------------------------------------------------
 // -------------------------------------------------------------------------------------
  output [SLV_NPW_SAB_RAM_ADDR_WD-1:0]        slv_npw_sab_ram_addra,
  output                                      slv_npw_sab_ram_wea,
  output [SLV_NPW_SAB_RAM_DATA_WD-1:0]        slv_npw_sab_ram_dina,
  output [SLV_NPW_SAB_RAM_ADDR_WD-1:0]        slv_npw_sab_ram_addrb,
  output                                      slv_npw_sab_ram_enb,
  input [SLV_NPW_SAB_RAM_DATA_WD-1:0]         slv_npw_sab_ram_doutb,
  output [OB_PDCMP_HDR_RAM_ADDR_WD-1:0]       ob_pdcmp_hdr_ram_addra,
  output                                      ob_pdcmp_hdr_ram_wea,
  output                                      ob_pdcmp_hdr_ram_enb,
  output [OB_PDCMP_HDR_RAM_DATA_WD-1:0]       ob_pdcmp_hdr_ram_dina,
  output [OB_PDCMP_HDR_RAM_ADDR_WD-1:0]       ob_pdcmp_hdr_ram_addrb,
  input [OB_PDCMP_HDR_RAM_DATA_WD-1:0]        ob_pdcmp_hdr_ram_doutb,
  output [OB_PDCMP_DATA_RAM_ADDR_WD-1:0]      ob_pdcmp_data_ram_addra,
  output                                      ob_pdcmp_data_ram_wea,
  output                                      ob_pdcmp_data_ram_enb,
  output [OB_PDCMP_DATA_RAM_DATA_WD-1:0]      ob_pdcmp_data_ram_dina,
  output [OB_PDCMP_DATA_RAM_ADDR_WD-1:0]      ob_pdcmp_data_ram_addrb,
  input [OB_PDCMP_DATA_RAM_DATA_WD-1:0]       ob_pdcmp_data_ram_doutb,
  output [OB_NPDCMP_RAM_ADDR_WD-1:0]          ob_npdcmp_ram_addra,
  output                                     ob_npdcmp_ram_wea,
  output                                     ob_npdcmp_ram_enb,
  output [OB_NPDCMP_RAM_DATA_WD-1:0]         ob_npdcmp_ram_dina,
  output [OB_NPDCMP_RAM_ADDR_WD-1:0]         ob_npdcmp_ram_addrb,
  input [OB_NPDCMP_RAM_DATA_WD-1:0]             ob_npdcmp_ram_doutb,

// -------------------------------------------------------------------------------------


// --------- [optional] Slave Response Composer Asynchronous Clock Crossing FIFO RAM ------------

// --------- Master Request Decomposer Header Queue RAM ------------




input     [OB_CCMP_DATA_RAM_DATA_WD-1:0]    ob_ccmp_data_ram_doutb,
output    [OB_CCMP_DATA_RAM_ADDR_WD-1:0]    ob_ccmp_data_ram_addra,
output    [OB_CCMP_DATA_RAM_ADDR_WD-1:0]    ob_ccmp_data_ram_addrb,
output    [OB_CCMP_DATA_RAM_DATA_WD-1:0]      ob_ccmp_data_ram_dina,
output                                        ob_ccmp_data_ram_enb,
output                                        ob_ccmp_data_ram_wea,




output                              core_clk,
output                              core_rst_n


,output [PM_MST_WD-1:0]              pm_master_state,
output  [PM_SLV_WD-1:0]              pm_slave_state
,output                           cfg_uncor_internal_err_sts
,output                           cfg_rcvr_overflow_err_sts
,output                           cfg_fc_protocol_err_sts
,output                           cfg_mlf_tlp_err_sts
,output                           cfg_surprise_down_er_sts
,output                           cfg_dl_protocol_err_sts
,output                           cfg_ecrc_err_sts
,output                           cfg_corrected_internal_err_sts
,output                           cfg_replay_number_rollover_err_sts
,output                           cfg_replay_timer_timeout_err_sts
,output                           cfg_bad_dllp_err_sts
,output                           cfg_bad_tlp_err_sts
,output                           cfg_rcvr_err_sts


);

// [新增] 从 "FPGA without AXI" 复制过来的内部信号定义
    wire [NL-1:0]                   phy_mac_rxelecidle;
    wire [31:0]                     cfg_phy_control;
    wire [NL-1:0]                   phy_mac_phystatus;
    wire                            pclk;
    wire                            phy_rst_n;
    wire [NL*PHY_NB*PIPE_DATA_WD-1:0] phy_mac_rxdata;
    wire [(NL*PHY_NB)-1:0]          phy_mac_rxdatak;
    wire [NL-1:0]                   phy_mac_rxvalid;
    wire [(NL*3)-1:0]               phy_mac_rxstatus;
    wire [NL-1:0]                   phy_mac_rxstandbystatus;
    wire                            mac_phy_elasticbuffermode;
    wire [NL-1:0]                   phy_mac_rxdatavalid;
    wire [NL-1:0]                   mac_phy_txdatavalid;
    wire [31:0]                     phy_cfg_status;
    wire [NL*PHY_NB*PIPE_DATA_WD-1:0] mac_phy_txdata;
    wire [(NL*PHY_NB)-1:0]          mac_phy_txdatak;
    wire [NL-1:0]                   mac_phy_txdetectrx_loopback;
    wire [NL-1:0]                   mac_phy_txcompliance;
    wire [NL-1:0]                   mac_phy_rxpolarity;
    wire [P_R_WD-1:0]               mac_phy_pclk_rate;
    wire [NL-1:0]                   mac_phy_rxstandby;
    wire [3:0]                      mac_phy_powerdown;
    wire [NL*TXEI_WD-1:0]           mac_phy_txelecidle;
    wire                            app_ltssm_enable;

    // [新增] IP核内部时钟复位信号
    wire                            core_clk_ug;
    wire                            clkrst_perst_n;
    wire                            pwr_rst_n;
    wire                            sticky_rst_n;
    wire                            non_sticky_rst_n;
    wire                            aux_clk_active;
    wire                            wake_ref_rst_n;
    wire                            en_muxd_aux_clk_g;
    wire                            en_radm_clk_g;
    wire                            radm_idle;
    wire                            phy_ref_clk_req_n;
    wire                            pm_req_sticky_rst;
    wire                            pm_req_core_rst;
    wire                            pm_req_non_sticky_rst;
    wire                            pm_sel_aux_clk;
    wire                            pm_en_core_clk;
    wire                            pm_req_phy_rst;
    wire   [3:0]                    current_data_rate;
    wire                            cfg_pm_no_soft_rst;
    wire                            mstr_aclk_active;
    wire                            slv_aclk_active;

    // [新增] Clocking and Reset Logic for FPGA from the working version
    //----------------------------------------------------------------
    // Clock assignments using pclk from Xilinx PHY
    // pclk (125MHz) is the main clock for the core and AXI interface
    assign core_clk = pclk;
    assign core_clk_ug = pclk;
    assign muxd_aux_clk = pclk;
    assign muxd_aux_clk_g = pclk;
    assign radm_clk_g = pclk;

    // Reset for PHY is driven directly by perst_n
    assign phy_rst_n = perst_n;
    // Tie-off this perst_n to the core, as we will generate a new controlled reset
    assign clkrst_perst_n = perst_n;

    // This is the CRITICAL reset generation logic
    //-------------------------------------------------
    wire phystatus_rst; // This signal comes from the PHY instance below

    // 1. Synchronize the PHY status reset signal to the pclk domain
    wire phystatus_rst_sync;
    rst_sync #(.STAGES(2)) u_sync_phystatus (
       .clk         (pclk),
       .rst_n_async (~phystatus_rst), // PHY uses active-high reset for this status flag
       .rst_n_sync  (phystatus_rst_sync)
    );

    // 2. Generate the controlled reset for the PCIe Core and AXI interfaces
    localparam integer CTRL_RST_CYC = 50;
    reg        ctrl_rst_n   = 1'b0;
    reg [6:0]  ctrl_cnt     = '0;

    always @(posedge pclk) begin
       if (!phystatus_rst_sync) begin // Wait for PHY to be ready
          ctrl_rst_n <= 1'b0;         // Keep core/AXI in reset
          ctrl_cnt   <= '0;
       end
       else if (ctrl_cnt < CTRL_RST_CYC-1) begin // PHY is ready, start counting
          ctrl_cnt   <= ctrl_cnt + 1'b1;
          ctrl_rst_n <= 1'b0;         // Keep core/AXI in reset during countdown
       end
       else begin // Countdown finished
          ctrl_rst_n <= 1'b1;         // Release the reset
       end
    end

    // 3. Drive all core and AXI resets from this controlled signal
    assign core_rst_n        = ctrl_rst_n;
    assign pwr_rst_n         = ctrl_rst_n;
    assign sticky_rst_n      = ctrl_rst_n;
    assign non_sticky_rst_n  = ctrl_rst_n;
    assign mstr_aresetn      = ctrl_rst_n; // [关键] AXI Master 复位由主控制器复位驱动
    assign slv_aresetn       = ctrl_rst_n; // [关键] AXI Slave 复位也一样

    // Tie off unused clock/reset related signals
    assign aux_clk_active = 1'b0;
    assign wake_ref_rst_n = perst_n;
    assign en_muxd_aux_clk_g = 1'b1;
    assign en_radm_clk_g = 1'b1;

    // [新增] Xilinx PHY and Clocking Primitives Instantiation
    //----------------------------------------------------------------
    wire refclk_gt;
    wire refclk_div2;
    wire refclk_bufg;

    IBUFDS_GTE4 #(
        .REFCLK_EN_TX_PATH(1'b0)
    ) u_ibufds_gt (
        .I     (refclk_p),
        .IB    (refclk_n),
        .CEB   (1'b0),
        .O     (refclk_gt),
        .ODIV2 (refclk_div2)
    );

    BUFG_GT u_bufg_refclk (
        .I       (refclk_div2),
        .CE      (1'b1),
        .CEMASK  (1'b0),
        .CLR     (1'b0),
        .CLRMASK (1'b0),
        .DIV     (3'd0),
        .O       (refclk_bufg)
    );

    wire [63:0] phy_rxdata;
    wire [1:0]  phy_rxdatak;
    wire [0:0]  phy_rxdata_valid;
    wire [1:0]  phy_rxstart_block;
    wire [1:0]  phy_rxsync_header;
    wire [0:0]  phy_rxvalid;
    wire [0:0]  phy_phystatus;
    wire [0:0]  phy_rxelecidle;
    wire [2:0]  phy_rxstatus;
    wire gt_gtpowergood;

     pcie_phy_0 u_phy (
        .phy_refclk       (refclk_bufg),
        .phy_gtrefclk     (refclk_gt),
        .phy_rst_n        (phy_rst_n),
        .phy_txdata       ({48'b0, mac_phy_txdata[15:0]}),
        .phy_txdatak      ({6'b0, mac_phy_txdatak[1:0]}),
        .phy_txdata_valid (mac_phy_txdatavalid[0]),
        .phy_txstart_block(1'b0),
        .phy_txsync_header(2'b00),
        .phy_rxp          (rxp[0]),
        .phy_rxn          (rxn[0]),
        .phy_txdetectrx   (mac_phy_txdetectrx_loopback[0]),
        .phy_txelecidle   (mac_phy_txelecidle[0]),
        .phy_txcompliance (mac_phy_txcompliance[0]),
        .phy_rxpolarity   (mac_phy_rxpolarity[0]),
        .phy_powerdown    (mac_phy_powerdown[1:0]),
        .phy_rate         (2'b00),
        .phy_txmargin     (3'b000),
        .phy_txswing      (1'b0),
        .phy_txdeemph     (1'b0),
        // ... (connect other phy ports as in your working reference)
        .phy_pclk         (pclk), // <-- 125MHz pclk output
        .phy_txp          (txp[0]),
        .phy_txn          (txn[0]),
        .phy_rxdata       (phy_rxdata),
        .phy_rxdatak      (phy_rxdatak),
        .phy_rxdata_valid (phy_rxdata_valid),
        .phy_rxvalid      (phy_rxvalid),
        .phy_phystatus    (phy_phystatus),
        .phy_phystatus_rst(phystatus_rst), // <-- This is the key status signal
        .phy_rxelecidle   (phy_rxelecidle),
        .phy_rxstatus     (phy_rxstatus),
        .gt_gtpowergood   (gt_gtpowergood)
        // ... (connect other phy output ports)
    );

    // [新增] PIPE Interface assignments
    assign phy_mac_rxdata        = {{(NL*PHY_NB*PIPE_DATA_WD-16){1'b0}}, phy_rxdata[15:0]};
    assign phy_mac_rxdatak       = phy_rxdatak[1:0];
    assign phy_mac_rxvalid       = phy_rxvalid;
    assign phy_mac_rxstatus      = phy_rxstatus;
    assign phy_mac_phystatus     = phy_phystatus;
    assign phy_mac_rxelecidle    = phy_rxelecidle;
    assign phy_mac_rxdatavalid   = phy_rxdata_valid;
    assign phy_mac_rxstandbystatus = 1'b0;

    // [新增] LTSSM enable generator
    ltssm_en_gen #(
      .DELAY_CYCLES(12_500)
    ) u_ltssm_enable (
      .pclk            (pclk),
      .perst_n         (ctrl_rst_n),
      .app_ltssm_enable(app_ltssm_enable)
    );


// ======================================================================
//            SNPS DWC PCIe IIP core instantiation
// ======================================================================
`SNPS_PCIE_CTL_MODULE u_pcie_core (







    // Master interfaces of AXI
    .mstr_awid                      (mstr_awid),
    .mstr_awvalid                   (mstr_awvalid),
    .mstr_awaddr                    (mstr_awaddr),
    .mstr_awlen                     (mstr_awlen),
    .mstr_awsize                    (mstr_awsize),
    .mstr_awburst                   (mstr_awburst),
    .mstr_awlock                    (mstr_awlock),
    .mstr_awqos                     (mstr_awqos),
    .mstr_awcache                   (mstr_awcache),
    .mstr_awprot                    (mstr_awprot),
    .mstr_awready                   (mstr_awready),
    .mstr_awmisc_info               (mstr_awmisc_info),
    .mstr_awmisc_info_ep            (mstr_awmisc_info_ep),
    .mstr_awmisc_info_last_dcmp_tlp (mstr_awmisc_info_last_dcmp_tlp),
    .mstr_awmisc_info_hdr_34dw      (mstr_awmisc_info_hdr_34dw),

    .mstr_wready                    (mstr_wready),
    .mstr_wdata                     (mstr_wdata),
    .mstr_wstrb                     (mstr_wstrb),
    .mstr_wlast                     (mstr_wlast),
    .mstr_wvalid                    (mstr_wvalid),
    .mstr_bready                    (mstr_bready),
    .mstr_bid                       (mstr_bid),
    .mstr_bvalid                    (mstr_bvalid),
    .mstr_bresp                     (mstr_bresp),
    .mstr_bmisc_info_cpl_stat       (mstr_bmisc_info_cpl_stat),
    .mstr_arid                      (mstr_arid),
    .mstr_arvalid                   (mstr_arvalid),
    .mstr_araddr                    (mstr_araddr),
    .mstr_arlen                     (mstr_arlen),
    .mstr_arsize                    (mstr_arsize),
    .mstr_arburst                   (mstr_arburst),
    .mstr_arlock                    (mstr_arlock),
    .mstr_arqos                     (mstr_arqos),
    .mstr_arcache                   (mstr_arcache),
    .mstr_arprot                    (mstr_arprot),
    .mstr_arready                   (mstr_arready),
    .mstr_armisc_info               (mstr_armisc_info),
    .mstr_armisc_info_last_dcmp_tlp (mstr_armisc_info_last_dcmp_tlp),
    .mstr_armisc_info_zeroread      (mstr_armisc_info_zeroread),


    .mstr_rready                    (mstr_rready),
    .mstr_rid                       (mstr_rid),
    .mstr_rvalid                    (mstr_rvalid),
    .mstr_rlast                     (mstr_rlast),
    .mstr_rdata                     (mstr_rdata),
    .mstr_rresp                     (mstr_rresp),
    .mstr_rmisc_info                (mstr_rmisc_info),
    .mstr_rmisc_info_cpl_stat       (mstr_rmisc_info_cpl_stat),
    .mstr_csysack                   (mstr_csysack),
    .mstr_cactive                   (mstr_cactive),
    .mstr_csysreq                   (mstr_csysreq),
    // Slave interfaces of AXI
    .slv_awid                       (slv_awid),
    .slv_awaddr                     (slv_awaddr),
    .slv_awlen                      (slv_awlen),
    .slv_awsize                     (slv_awsize),
    .slv_awburst                    (slv_awburst),
    .slv_awlock                     (slv_awlock),
    .slv_awqos                      (slv_awqos),
    .slv_awcache                    (slv_awcache),
    .slv_awprot                     (slv_awprot),
    .slv_awvalid                    (slv_awvalid),
    .slv_awready                    (slv_awready),
    .slv_awmisc_info                (slv_awmisc_info),
    .slv_awmisc_info_hdr_34dw       (slv_awmisc_info_hdr_34dw),
    .slv_awmisc_info_p_tag          (slv_awmisc_info_p_tag),


    .slv_wready                     (slv_wready),
    .slv_wdata                      (slv_wdata),
    .slv_wstrb                      (slv_wstrb),
    .slv_wlast                      (slv_wlast),
    .slv_wvalid                     (slv_wvalid),
    .slv_wmisc_info_ep              (slv_wmisc_info_ep),
    .slv_wmisc_info_silentDrop      (slv_wmisc_info_silentDrop),

    .slv_bid                        (slv_bid),
    .slv_bresp                      (slv_bresp),
    .slv_bvalid                     (slv_bvalid),
    .slv_bready                     (slv_bready),
    .slv_bmisc_info                 (slv_bmisc_info),
    .slv_arid                       (slv_arid),
    .slv_araddr                     (slv_araddr),
    .slv_arlen                      (slv_arlen),
    .slv_arsize                     (slv_arsize),
    .slv_arburst                    (slv_arburst),
    .slv_arlock                     (slv_arlock),
    .slv_arqos                      (slv_arqos),
    .slv_arcache                    (slv_arcache),
    .slv_arprot                     (slv_arprot),
    .slv_arvalid                    (slv_arvalid),
    .slv_arready                    (slv_arready),
    .slv_armisc_info                (slv_armisc_info),



    .slv_rid                        (slv_rid),
    .slv_rdata                      (slv_rdata),
    .slv_rresp                      (slv_rresp),
    .slv_rlast                      (slv_rlast),
    .slv_rvalid                     (slv_rvalid),
    .slv_rmisc_info                 (slv_rmisc_info),
    .slv_rready                     (slv_rready),

    .slv_csysreq                    (slv_csysreq),
    .slv_csysack                    (slv_csysack),
    .slv_cactive                    (slv_cactive),

    .mstr_aclk                    (mstr_aclk),
    .mstr_aresetn                 (mstr_aresetn),
    .mstr_aclk_ug                 (mstr_aclk),
    .mstr_aclk_active             (mstr_aclk_active),
    .slv_aclk                     (slv_aclk),
    .slv_aresetn                  (slv_aresetn),
    .slv_aclk_ug                  (slv_aclk),
    .slv_aclk_active              (slv_aclk_active),


  // External RAM Interfaces
  // Inbound
  // Inbound Read Request Order RAM
    .ib_rreq_ordr_ram_addra  (ib_rreq_ordr_ram_addra),
    .ib_rreq_ordr_ram_addrb  (ib_rreq_ordr_ram_addrb),
    .ib_rreq_ordr_ram_wea    (ib_rreq_ordr_ram_wea  ),
    .ib_rreq_ordr_ram_enb    (ib_rreq_ordr_ram_enb  ),
    .ib_rreq_ordr_ram_dina   (ib_rreq_ordr_ram_dina ),
    .ib_rreq_ordr_ram_doutb  (ib_rreq_ordr_ram_doutb),
    // Master completion buffer segment buffer RAM outputs
    .ib_mcpl_sb_ram_addra           (ib_mcpl_sb_ram_addra),
    .ib_mcpl_sb_ram_wea             (ib_mcpl_sb_ram_wea),
    .ib_mcpl_sb_ram_dina            (ib_mcpl_sb_ram_dina),
    .ib_mcpl_sb_ram_addrb           (ib_mcpl_sb_ram_addrb),
    .ib_mcpl_sb_ram_enb             (ib_mcpl_sb_ram_enb),
    .ib_mcpl_sb_ram_doutb           (ib_mcpl_sb_ram_doutb),

   // Outbound
    // Slave Non-Posted Write Set-Aside RAM
    .slv_npw_sab_ram_addra            (slv_npw_sab_ram_addra),
    .slv_npw_sab_ram_wea              (slv_npw_sab_ram_wea),
    .slv_npw_sab_ram_dina             (slv_npw_sab_ram_dina),
    .slv_npw_sab_ram_addrb            (slv_npw_sab_ram_addrb),
    .slv_npw_sab_ram_enb              (slv_npw_sab_ram_enb),
    .slv_npw_sab_ram_doutb            (slv_npw_sab_ram_doutb),
    // Outbound Posted TLP Decomposer Header FIFO RAM
    .ob_pdcmp_hdr_ram_addra           (ob_pdcmp_hdr_ram_addra),
    .ob_pdcmp_hdr_ram_wea             (ob_pdcmp_hdr_ram_wea),
    .ob_pdcmp_hdr_ram_enb             (ob_pdcmp_hdr_ram_enb),
    .ob_pdcmp_hdr_ram_dina            (ob_pdcmp_hdr_ram_dina),
    .ob_pdcmp_hdr_ram_addrb           (ob_pdcmp_hdr_ram_addrb),
    .ob_pdcmp_hdr_ram_doutb           (ob_pdcmp_hdr_ram_doutb),
    // Outbound Posted TLP Decomposer Data FIFO RAM
    .ob_pdcmp_data_ram_addra          (ob_pdcmp_data_ram_addra),
    .ob_pdcmp_data_ram_wea            (ob_pdcmp_data_ram_wea),
    .ob_pdcmp_data_ram_enb            (ob_pdcmp_data_ram_enb),
    .ob_pdcmp_data_ram_dina           (ob_pdcmp_data_ram_dina),
    .ob_pdcmp_data_ram_addrb          (ob_pdcmp_data_ram_addrb),
    .ob_pdcmp_data_ram_doutb          (ob_pdcmp_data_ram_doutb),
    // Outbound Posted TLP Decomposer Data FIFO RAM
    .ob_npdcmp_ram_addra              (ob_npdcmp_ram_addra),
    .ob_npdcmp_ram_wea                (ob_npdcmp_ram_wea),
    .ob_npdcmp_ram_enb                (ob_npdcmp_ram_enb),
    .ob_npdcmp_ram_dina               (ob_npdcmp_ram_dina),
    .ob_npdcmp_ram_addrb              (ob_npdcmp_ram_addrb),
    .ob_npdcmp_ram_doutb              (ob_npdcmp_ram_doutb),
    // Outbound Completion TLP Composer RAM
    .ob_ccmp_data_ram_addra           (ob_ccmp_data_ram_addra),
    .ob_ccmp_data_ram_addrb           (ob_ccmp_data_ram_addrb),
    .ob_ccmp_data_ram_dina            (ob_ccmp_data_ram_dina),
    .ob_ccmp_data_ram_doutb           (ob_ccmp_data_ram_doutb),
    .ob_ccmp_data_ram_enb             (ob_ccmp_data_ram_enb),
    .ob_ccmp_data_ram_wea             (ob_ccmp_data_ram_wea),


    .radm_trgt1_vc                      (radm_trgt1_vc),


    .trgt_cpl_timeout                   (trgt_cpl_timeout),
    .trgt_timeout_cpl_func_num          (trgt_timeout_cpl_func_num),
    .trgt_timeout_cpl_tc                (trgt_timeout_cpl_tc),
    .trgt_timeout_cpl_attr              (trgt_timeout_cpl_attr),
    .trgt_timeout_cpl_len               (trgt_timeout_cpl_len),
    .trgt_timeout_lookup_id             (trgt_timeout_lookup_id),
    .trgt_lookup_id                     (trgt_lookup_id),
    .trgt_lookup_empty                  (trgt_lookup_empty),


    // Phy PIPE interface
    .phy_mac_rxelecidle                 (phy_mac_rxelecidle),
    .phy_mac_phystatus                  (phy_mac_phystatus),
    .phy_mac_rxdata                     (phy_mac_rxdata),
    .phy_mac_rxdatak                    (phy_mac_rxdatak),
    .phy_mac_rxvalid                    (phy_mac_rxvalid),
    .phy_mac_rxstatus                   (phy_mac_rxstatus),
    .phy_mac_rxstandbystatus            (phy_mac_rxstandbystatus),
    .phy_mac_rxdatavalid                (phy_mac_rxdatavalid),
    .phy_cfg_status                     (phy_cfg_status),
    .mac_phy_txdata                     (mac_phy_txdata),
    .mac_phy_txdatak                    (mac_phy_txdatak),
    .mac_phy_txdetectrx_loopback        (mac_phy_txdetectrx_loopback),
    .mac_phy_txelecidle                 (mac_phy_txelecidle),
    .mac_phy_txcompliance               (mac_phy_txcompliance),
    .mac_phy_rxpolarity                 (mac_phy_rxpolarity),
    .mac_phy_width                      (2'b01), // For Gen1/2/3 with 16-bit interface
    .mac_phy_pclk_rate                  (mac_phy_pclk_rate),
    .mac_phy_rxstandby                  (mac_phy_rxstandby),
    .mac_phy_elasticbuffermode          (mac_phy_elasticbuffermode),
    .mac_phy_txdatavalid                (mac_phy_txdatavalid),
    .mac_phy_powerdown                  (mac_phy_powerdown),
    .cfg_phy_control                    (cfg_phy_control),

    .ven_msg_grant                      (ven_msg_grant),
    .ven_msg_fmt                        (ven_msg_fmt),          // Vendor MSG fmt
    .ven_msg_type                       (ven_msg_type),         // Vendor MSG type
    .ven_msg_tc                         (ven_msg_tc),           // Vendor MSG traffic class
    .ven_msg_td                         (ven_msg_td),           // Vendor MSG TLP digest
    .ven_msg_ep                         (ven_msg_ep),           // Vendor MSG EP bit
    .ven_msg_attr                       (ven_msg_attr),         // Vendor MSG attribute
    .ven_msg_len                        (ven_msg_len),          // Vendor MSG length
    .ven_msg_func_num                   (ven_msg_func_num),     // Vendor MSG function number
    .ven_msg_tag                        (ven_msg_tag),          // Vendor MSG tag
    .ven_msg_code                       (ven_msg_code),         // Vendor MSG code
    .ven_msg_data                       (ven_msg_data),         // Vendor MSG data
    .ven_msg_req                        (ven_msg_req),          // Request to send a Vendor MSG
    .pm_xtlh_block_tlp                  (pm_xtlh_block_tlp),    // Block new TLP request, but not the completion

    // ---- MSI  Interface -------------
    .ven_msi_req                        (ven_msi_req),
    .ven_msi_func_num                   (ven_msi_func_num),
    .ven_msi_tc                         (ven_msi_tc),
    .ven_msi_vector                     (ven_msi_vector),

    .ven_msi_grant                      (ven_msi_grant),
    .cfg_msi_en                         (cfg_msi_en),










    .radm_q_not_empty                   (radm_q_not_empty),
    .radm_qoverflow                     (radm_qoverflow),

    .app_dbi_ro_wr_disable              (app_dbi_ro_wr_disable),

    .dbi_wr                             (dbi_wr),
    .dbi_cs                             (dbi_cs),
    .dbi_cs2                            (dbi_cs2),
    .dbi_addr                           (dbi_addr),
    .dbi_din                            (dbi_din),

    .lbc_dbi_ack                        (lbc_dbi_ack),
    .lbc_dbi_dout                       (lbc_dbi_dout),


 // ELBI
    .lbc_ext_addr                       (lbc_ext_addr),
    .lbc_ext_dout                       (lbc_ext_dout),
    .lbc_ext_cs                         (lbc_ext_cs),
    .lbc_ext_wr                         (lbc_ext_wr),
    .lbc_ext_rom_access                 (lbc_ext_rom_access),
    .lbc_ext_io_access                  (lbc_ext_io_access),
    .lbc_ext_bar_num                    (lbc_ext_bar_num),
    .ext_lbc_ack                        (ext_lbc_ack),
    .ext_lbc_din                        (ext_lbc_din),






    .training_rst_n                     (training_rst_n),
    .radm_pm_turnoff                    (radm_pm_turnoff),
    .radm_msg_unlock                    (radm_msg_unlock),
    .outband_pwrup_cmd                  (outband_pwrup_cmd),
    .cfg_pbus_num                       (cfg_pbus_num),
    .cfg_pbus_dev_num                   (cfg_pbus_dev_num),
    .pm_status                          (pm_status),
    .pm_curnt_state                     (pm_curnt_state),
    .cxpl_debug_info                    (cxpl_debug_info),
    .cxpl_debug_info_ei                 (cxpl_debug_info_ei),

    .cfg_bar0_start                     (cfg_bar0_start),
    .cfg_bar0_limit                     (cfg_bar0_limit),
    .cfg_bar1_start                     (cfg_bar1_start),
    .cfg_bar1_limit                     (cfg_bar1_limit),
    .cfg_bar2_start                     (cfg_bar2_start),
    .cfg_bar2_limit                     (cfg_bar2_limit),
    .cfg_bar3_start                     (cfg_bar3_start),
    .cfg_bar3_limit                     (cfg_bar3_limit),
    .cfg_bar4_start                     (cfg_bar4_start),
    .cfg_bar4_limit                     (cfg_bar4_limit),
    .cfg_bar5_start                     (cfg_bar5_start),
    .cfg_bar5_limit                     (cfg_bar5_limit),
    .cfg_exp_rom_start                  (cfg_exp_rom_start),
    .cfg_exp_rom_limit                  (cfg_exp_rom_limit),
    .radm_vendor_msg                    (radm_vendor_msg),
    .radm_msg_payload                   (radm_msg_payload),
    .radm_msg_req_id                    (radm_msg_req_id),



    .radm_cpl_timeout                   (radm_cpl_timeout),
    .radm_timeout_func_num              (radm_timeout_func_num),
    .radm_timeout_cpl_tc                (radm_timeout_cpl_tc),
    .radm_timeout_cpl_attr              (radm_timeout_cpl_attr),
    .radm_timeout_cpl_len               (radm_timeout_cpl_len),
    .radm_timeout_cpl_tag               (radm_timeout_cpl_tag),



    // Retry buffer external RAM interface
    .xdlh_retryram_addr                 (xdlh_retryram_addr),
    .xdlh_retryram_data                 (xdlh_retryram_data),
    .xdlh_retryram_we                   (xdlh_retryram_we),
    .xdlh_retryram_en                   (xdlh_retryram_en),
    .retryram_xdlh_data                 (retryram_xdlh_data),
    .xdlh_retrysotram_waddr             (xdlh_retrysotram_waddr),
    .xdlh_retrysotram_raddr             (xdlh_retrysotram_raddr),
    .xdlh_retrysotram_data              (xdlh_retrysotram_data),
    .xdlh_retrysotram_we                (xdlh_retrysotram_we),
    .xdlh_retrysotram_en                (xdlh_retrysotram_en),
    .retrysotram_xdlh_data              (retrysotram_xdlh_data),
    .p_hdrq_dataout                     (p_hdrq_dataout),
    .p_hdrq_addra                       (p_hdrq_addra),
    .p_hdrq_addrb                       (p_hdrq_addrb),
    .p_hdrq_datain                      (p_hdrq_datain),
    .p_hdrq_ena                         (p_hdrq_ena),
    .p_hdrq_enb                         (p_hdrq_enb),
    .p_hdrq_wea                         (p_hdrq_wea),
    .p_dataq_dataout                    (p_dataq_dataout),
    .p_dataq_addra                      (p_dataq_addra),
    .p_dataq_addrb                      (p_dataq_addrb),
    .p_dataq_datain                     (p_dataq_datain),
    .p_dataq_ena                        (p_dataq_ena),
    .p_dataq_enb                        (p_dataq_enb),
    .p_dataq_wea                        (p_dataq_wea),








    .cfg_reg_serren                     (cfg_reg_serren       ),
    .cfg_cor_err_rpt_en                 (cfg_cor_err_rpt_en   ),
    .cfg_nf_err_rpt_en                  (cfg_nf_err_rpt_en    ),
    .cfg_f_err_rpt_en                   (cfg_f_err_rpt_en     ),

    .core_clk                           (core_clk),
    .core_clk_ug                        (core_clk_ug),
    .aux_clk                            (muxd_aux_clk),
    .aux_clk_g                          (muxd_aux_clk_g),
    .en_aux_clk_g                       (en_muxd_aux_clk_g),
    .radm_clk_g                         (radm_clk_g),
    .en_radm_clk_g                      (en_radm_clk_g),
    .radm_idle                          (radm_idle),
    .pwr_rst_n                          (pwr_rst_n),
    .non_sticky_rst_n                   (non_sticky_rst_n),
    .sticky_rst_n                       (sticky_rst_n),
    .core_rst_n                         (core_rst_n),
    .perst_n                            (clkrst_perst_n),
    .app_clk_req_n                      (app_clk_req_n),
    .phy_clk_req_n                      (phy_ref_clk_req_n),
    .app_init_rst                       (app_init_rst),
    .app_req_entr_l1                    (app_req_entr_l1),
    .app_ready_entr_l23                 (app_ready_entr_l23),
    .app_req_exit_l1                    (app_req_exit_l1),
    .app_xfer_pending                   (app_xfer_pending),
    .exp_rom_validation_status_strobe   (exp_rom_validation_status_strobe ),
    .exp_rom_validation_status          (exp_rom_validation_status        ),
    .exp_rom_validation_details_strobe  (exp_rom_validation_details_strobe),
    .exp_rom_validation_details         (exp_rom_validation_details       ),

    .brdg_slv_xfer_pending              (brdg_slv_xfer_pending ),
    .brdg_dbi_xfer_pending              (brdg_dbi_xfer_pending ),
    .radm_xfer_pending                  (radm_xfer_pending     ),
    .smlh_req_rst_not                   (smlh_req_rst_not),
    .link_req_rst_not                   (link_req_rst_not),
    .smlh_link_up                       (smlh_link_up),
    .rdlh_link_up                       (rdlh_link_up),
    .app_req_retry_en                   (app_req_retry_en),
    .app_pf_req_retry_en                (app_pf_req_retry_en ),
    .wake                               (wake),
    .local_ref_clk_req_n                (local_ref_clk_req_n),
    .cfg_max_rd_req_size                (cfg_max_rd_req_size),
    .cfg_bus_master_en                  (cfg_bus_master_en),
    .cfg_max_payload_size               (cfg_max_payload_size),
    .cfg_rcb                            (cfg_rcb),
    .cfg_mem_space_en                   (cfg_mem_space_en),
    .cfg_pm_no_soft_rst                 (cfg_pm_no_soft_rst  ),
    .smlh_ltssm_state                   (smlh_ltssm_state),
    .pm_dstate                          (pm_dstate),
    .aux_pm_en                          (aux_pm_en),
    .pm_pme_en                          (pm_pme_en),
    .pm_l1_entry_started                (pm_l1_entry_started),
    .pm_linkst_in_l0s                   (pm_linkst_in_l0s),
    .pm_linkst_in_l1                    (pm_linkst_in_l1),
    .pm_linkst_in_l2                    (pm_linkst_in_l2),
    .pm_linkst_l2_exit                  (pm_linkst_l2_exit),
    .pm_req_sticky_rst                  (pm_req_sticky_rst),
    .pm_req_core_rst                    (pm_req_core_rst),
    .pm_req_non_sticky_rst              (pm_req_non_sticky_rst),
    .pm_sel_aux_clk                     (pm_sel_aux_clk),
    .pm_en_core_clk                     (pm_en_core_clk),
    .pm_req_phy_rst                     (pm_req_phy_rst),





    .sys_int                            (sys_int),
    .apps_pm_xmt_pme                    (apps_pm_xmt_pme),
    .sys_aux_pwr_det                    (sys_aux_pwr_det),
    .app_ltssm_enable                   (app_ltssm_enable),
    .app_hold_phy_rst                   (1'b0)

    ,
    .cfg_send_cor_err                   (cfg_send_cor_err),
    .cfg_send_nf_err                    (cfg_send_nf_err),
    .cfg_send_f_err                     (cfg_send_f_err),
    .cfg_int_disable                    (cfg_int_disable),
    .cfg_no_snoop_en                    (cfg_no_snoop_en),
    .cfg_relax_order_en                 (cfg_relax_order_en)

    ,
    .assert_inta_grt                    (assert_inta_grt),
    .assert_intb_grt                    (assert_intb_grt),
    .assert_intc_grt                    (assert_intc_grt),
    .assert_intd_grt                    (assert_intd_grt),
    .deassert_inta_grt                  (deassert_inta_grt),
    .deassert_intb_grt                  (deassert_intb_grt),
    .deassert_intc_grt                  (deassert_intc_grt),
    .deassert_intd_grt                  (deassert_intd_grt),
    .cfg_int_pin                        (cfg_int_pin)













    ,
    .cfg_hp_slot_ctrl_access        (cfg_hp_slot_ctrl_access),
    .cfg_dll_state_chged_en         (cfg_dll_state_chged_en),
    .cfg_cmd_cpled_int_en           (cfg_cmd_cpled_int_en),
    .cfg_hp_int_en                  (cfg_hp_int_en),
    .cfg_pre_det_chged_en           (cfg_pre_det_chged_en),
    .cfg_mrl_sensor_chged_en        (cfg_mrl_sensor_chged_en),
    .cfg_pwr_fault_det_en           (cfg_pwr_fault_det_en),
    .cfg_atten_button_pressed_en    (cfg_atten_button_pressed_en)






    ,
    .pm_master_state                (pm_master_state),
    .pm_slave_state                 (pm_slave_state)

    ,.pm_current_data_rate          (current_data_rate)
    ,
    .cfg_uncor_internal_err_sts         (cfg_uncor_internal_err_sts        ),
    .cfg_rcvr_overflow_err_sts          (cfg_rcvr_overflow_err_sts         ),
    .cfg_fc_protocol_err_sts            (cfg_fc_protocol_err_sts           ),
    .cfg_mlf_tlp_err_sts                (cfg_mlf_tlp_err_sts               ),
    .cfg_surprise_down_er_sts           (cfg_surprise_down_er_sts          ),
    .cfg_dl_protocol_err_sts            (cfg_dl_protocol_err_sts           ),
    .cfg_ecrc_err_sts                   (cfg_ecrc_err_sts                  ),
    .cfg_corrected_internal_err_sts     (cfg_corrected_internal_err_sts    ),
    .cfg_replay_number_rollover_err_sts (cfg_replay_number_rollover_err_sts),
    .cfg_replay_timer_timeout_err_sts   (cfg_replay_timer_timeout_err_sts  ),
    .cfg_bad_dllp_err_sts               (cfg_bad_dllp_err_sts              ),
    .cfg_bad_tlp_err_sts                (cfg_bad_tlp_err_sts               ),
    .cfg_rcvr_err_sts                   (cfg_rcvr_err_sts                  )



); // u_pcie_core

assign axi_parity_errs = 7'd0;





endmodule // : pcie_iip_device
// Local Variables:
// verilog-library-flags:("-y ./")
// End:


