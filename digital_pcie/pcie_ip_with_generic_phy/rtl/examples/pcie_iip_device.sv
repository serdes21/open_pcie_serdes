
// -------------------------------------------------------------------------
// ---  RCS information:
// ---    $DateTime: 2019/10/17 11:13:56 $
// ---    $Revision: #11 $
// ---    $Id: //dwh/pcie_iip/main/DWC_pcie/DWC_pcie_ctl/examples/pcie_iip_device.sv#11 $
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
 * - @ref parity_check : (optional) ram parity checker
 */
module `SNPS_PCIE_IIP_DEVICE_MODULE #(
   parameter NL                       = `CX_NL,
   parameter PHY_NB                   = `CX_PHY_NB,
  parameter RADM_SBUF_HDRQ_WD         = `CX_RADM_SBUF_HDRQ_WD,
  parameter RADM_SBUF_HDRQ_PW         = `CX_RADM_SBUF_HDRQ_PW,
  parameter RADM_SBUF_DATAQ_RAM_WD        = `CX_RADM_SBUF_DATAQ_RAM_WD,
  parameter RADM_SBUF_DATAQ_PW        = `CX_RADM_SBUF_DATAQ_PW,


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

   // entries in completion lut
   parameter CPL_LUT_DEPTH            = `CX_MAX_TAG +1,

   // TLP prefix parameters
   parameter PRFX_DW                  = `CX_TLP_PREFIX_ENABLE_VALUE ? (32*`CX_NPRFX) + `CX_PRFX_PAR_WD : 32,
   parameter PRFX_W_PAR               = `CX_TLP_PREFIX_ENABLE_VALUE ? `FLT_Q_PRFX_WIDTH : 32,

   // DBI parameter
   parameter DBI_SLV_DATA_WD          = `CC_DBI_SLV_BUS_DATA_WIDTH,
   parameter DBI_SLV_ADDR_WD          = `CC_DBI_SLV_BUS_ADDR_WIDTH,
   parameter DBI_SLV_ID_WD            = `CC_DBI_SLV_ID_WD,
   parameter DBISLV_BURST_LEN_PW      = `CC_DBISLV_BURST_LEN_PW,
   parameter DBI_NUM_MASTERS          = 16,
   parameter DBI_NUM_MSTRS_WD         = 4,


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
   parameter PM_MST_WD        = 5,
   parameter PM_SLV_WD        = 5
 ) (




input                            power_up_rst_n,
input                            button_rst_n,
input                            perst_n,
output                           auxclk,
output                           muxd_aux_clk,
output                           muxd_aux_clk_g,
input                            sys_aux_pwr_det,
input                            app_ltssm_enable,
input                            app_hold_phy_rst,
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










output   [NF-1:0] cfg_hp_slot_ctrl_access,
output   [NF-1:0] cfg_dll_state_chged_en,
output   [NF-1:0] cfg_cmd_cpled_int_en,
output   [NF-1:0] cfg_hp_int_en,
output   [NF-1:0] cfg_pre_det_chged_en,
output   [NF-1:0] cfg_mrl_sensor_chged_en,
output   [NF-1:0] cfg_pwr_fault_det_en,
output   [NF-1:0] cfg_atten_button_pressed_en,

// PHY inside device_top (or inside core), export serial lines, import refclk
input  [NL-1:0]                  rxp,
input  [NL-1:0]                  rxn,
output [NL-1:0]                  txp,
output [NL-1:0]                  txn,
input  [NL-1:0]                  rxpresent,

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










output                              core_clk,
output                              core_rst_n




, output [PM_MST_WD-1:0]            pm_master_state
, output [PM_SLV_WD-1:0]            pm_slave_state

);

// ======================================================================
//                    External RAMs instantiation
// ======================================================================

  // Wire list for RAM instance u_ib_mcpl_sb_ram of model ram_2p_1c_wrapper
  wire [1*12-1:0] ib_mcpl_sb_ram_addra;
  wire [1*12-1:0] ib_mcpl_sb_ram_addrb;
  wire [1*34-1:0] ib_mcpl_sb_ram_dina;
  wire [1-1:0] ib_mcpl_sb_ram_wea;
  wire [1-1:0] ib_mcpl_sb_ram_enb;
  wire [1*34-1:0] ib_mcpl_sb_ram_doutb;
  // Wire list for RAM instance u_ib_rreq_ordr_ram of model ram_2p_1c_wrapper
  wire [1*5-1:0] ib_rreq_ordr_ram_addra;
  wire [1*5-1:0] ib_rreq_ordr_ram_addrb;
  wire [1*99-1:0] ib_rreq_ordr_ram_dina;
  wire [1-1:0] ib_rreq_ordr_ram_wea;
  wire [1-1:0] ib_rreq_ordr_ram_enb;
  wire [1*99-1:0] ib_rreq_ordr_ram_doutb;
  // Wire list for RAM instance u_ob_ccmp_data_ram of model ram_2p_1c_wrapper
  wire [1*6-1:0] ob_ccmp_data_ram_addra;
  wire [1*6-1:0] ob_ccmp_data_ram_addrb;
  wire [1*34-1:0] ob_ccmp_data_ram_dina;
  wire [1-1:0] ob_ccmp_data_ram_wea;
  wire [1-1:0] ob_ccmp_data_ram_enb;
  wire [1*34-1:0] ob_ccmp_data_ram_doutb;
  // Wire list for RAM instance u_ob_npdcmp_ram of model ram_2p_2c_wrapper
  wire [1*1-1:0] ob_npdcmp_ram_addra;
  wire [1*1-1:0] ob_npdcmp_ram_addrb;
  wire [1*105-1:0] ob_npdcmp_ram_dina;
  wire [1-1:0] ob_npdcmp_ram_wea;
  wire [1-1:0] ob_npdcmp_ram_enb;
  wire [1*105-1:0] ob_npdcmp_ram_doutb;
  // Wire list for RAM instance u_slv_npw_sab_ram of model ram_2p_1c_wrapper
  wire [1*1-1:0] slv_npw_sab_ram_addra;
  wire [1*1-1:0] slv_npw_sab_ram_addrb;
  wire [1*90-1:0] slv_npw_sab_ram_dina;
  wire [1-1:0] slv_npw_sab_ram_wea;
  wire [1-1:0] slv_npw_sab_ram_enb;
  wire [1*90-1:0] slv_npw_sab_ram_doutb;
  // Wire list for RAM instance u_ob_pdcmp_data_ram of model ram_2p_2c_wrapper
  wire [1*6-1:0] ob_pdcmp_data_ram_addra;
  wire [1*6-1:0] ob_pdcmp_data_ram_addrb;
  wire [1*32-1:0] ob_pdcmp_data_ram_dina;
  wire [1-1:0] ob_pdcmp_data_ram_wea;
  wire [1-1:0] ob_pdcmp_data_ram_enb;
  wire [1*32-1:0] ob_pdcmp_data_ram_doutb;
  // Wire list for RAM instance u_ob_pdcmp_hdr_ram of model ram_2p_2c_wrapper
  wire [1*4-1:0] ob_pdcmp_hdr_ram_addra;
  wire [1*4-1:0] ob_pdcmp_hdr_ram_addrb;
  wire [1*72-1:0] ob_pdcmp_hdr_ram_dina;
  wire [1-1:0] ob_pdcmp_hdr_ram_wea;
  wire [1-1:0] ob_pdcmp_hdr_ram_enb;
  wire [1*72-1:0] ob_pdcmp_hdr_ram_doutb;
  // Wire list for RAM instance u3_ram_radm_qbuffer_data of model ram_2p_1c_wrapper
  wire [1*9-1:0] p_dataq_addra;
  wire [1*9-1:0] p_dataq_addrb;
  wire [1*33-1:0] p_dataq_datain;
  wire [1-1:0] p_dataq_wea;
  wire [1-1:0] p_dataq_ena;
  wire [1-1:0] p_dataq_enb;
  wire [1*33-1:0] p_dataq_dataout;
  // Wire list for RAM instance u0_ram_radm_qbuffer_hdr of model ram_2p_1c_wrapper
  wire [1*6-1:0] p_hdrq_addra;
  wire [1*6-1:0] p_hdrq_addrb;
  wire [1*103-1:0] p_hdrq_datain;
  wire [1-1:0] p_hdrq_wea;
  wire [1-1:0] p_hdrq_ena;
  wire [1-1:0] p_hdrq_enb;
  wire [1*103-1:0] p_hdrq_dataout;
  // Wire list for RAM instance u_ram_1p_rbuf of model ram_1p_wrapper
  wire [9-1:0] xdlh_retryram_addr;
  wire [1*34-1:0] xdlh_retryram_data;
  wire xdlh_retryram_en;
  wire [1-1:0] xdlh_retryram_we;
  wire [1*34-1:0] retryram_xdlh_data;
  // Wire list for RAM instance u_ram_2p_sotbuf of model ram_2p_1c_wrapper
  wire [1*8-1:0] xdlh_retrysotram_waddr;
  wire [1*8-1:0] xdlh_retrysotram_raddr;
  wire [1*9-1:0] xdlh_retrysotram_data;
  wire [1-1:0] xdlh_retrysotram_we;
  wire [1-1:0] xdlh_retrysotram_en;
  wire [1*9-1:0] retrysotram_xdlh_data;


// ---------------------------------------------------------------------
// RADM Queues
// ----------------------------------------------------------------------

  wire                                 radm_clk_g;
  // These aren't currently used
  wire    [(RADM_SBUF_HDRQ_PW)-1:0]    p_hdrq_depth  = 0;
  wire    [(RADM_SBUF_DATAQ_PW)-1:0]   p_dataq_depth = 0;



wire                  cfg_uncor_internal_err_sts;
wire                  cfg_rcvr_overflow_err_sts;
wire                  cfg_fc_protocol_err_sts;
wire                  cfg_mlf_tlp_err_sts;
wire                  cfg_surprise_down_er_sts;
wire                  cfg_dl_protocol_err_sts;
wire                  cfg_ecrc_err_sts;
wire                  cfg_corrected_internal_err_sts;
wire                  cfg_replay_number_rollover_err_sts;
wire                  cfg_replay_timer_timeout_err_sts;
wire                  cfg_bad_dllp_err_sts;
wire                  cfg_bad_tlp_err_sts;
wire                  cfg_rcvr_err_sts;



/*AUTOREG*/
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
// End of automatics
`SNPS_PCIE_IIP_SUBSYS_MODULE #(
  .NL(NL),
  .NW(NW),
  .NF(NF),
  .PF_WD(PF_WD),
  .DW(DW),
  .NVC(NVC),
  .NHQ(NHQ),
  .NDQ(NDQ)
) u_subsystem(

                          .power_up_rst_n(power_up_rst_n), // input
                          .button_rst_n(button_rst_n), // input
                          .perst_n(perst_n), // input
                          .auxclk(auxclk), // output
                          .muxd_aux_clk(muxd_aux_clk),  // output
                          .muxd_aux_clk_g(muxd_aux_clk_g),  // output
                          .radm_clk_g(radm_clk_g), // output
                          .sys_aux_pwr_det(sys_aux_pwr_det), // input
                          .app_ltssm_enable(app_ltssm_enable), // input
                          .app_hold_phy_rst(app_hold_phy_rst), //input
                          .app_clk_req_n(app_clk_req_n), // input
                          .app_clk_pm_en(app_clk_pm_en), // input
                          .app_init_rst(app_init_rst), // input
                          .app_req_entr_l1(app_req_entr_l1), // input
                          .app_ready_entr_l23(app_ready_entr_l23), // input
                          .app_req_exit_l1(app_req_exit_l1), // input
                          .app_xfer_pending(app_xfer_pending), // input
                          .exp_rom_validation_status_strobe(exp_rom_validation_status_strobe),
                          .exp_rom_validation_status(exp_rom_validation_status),
                          .exp_rom_validation_details_strobe(exp_rom_validation_details_strobe),
                          .exp_rom_validation_details(exp_rom_validation_details),
                          .app_req_retry_en(app_req_retry_en), // input
                          .app_pf_req_retry_en(app_pf_req_retry_en ),

                          .cfg_hp_slot_ctrl_access(cfg_hp_slot_ctrl_access), // output
                          .cfg_dll_state_chged_en(cfg_dll_state_chged_en),  // output
                          .cfg_cmd_cpled_int_en(cfg_cmd_cpled_int_en),  // output
                          .cfg_hp_int_en(cfg_hp_int_en),  // output
                          .cfg_pre_det_chged_en(cfg_pre_det_chged_en),  // output
                          .cfg_mrl_sensor_chged_en(cfg_mrl_sensor_chged_en),  // output
                          .cfg_pwr_fault_det_en(cfg_pwr_fault_det_en),  // output
                          .cfg_atten_button_pressed_en(cfg_atten_button_pressed_en), // output

                          .rxp(rxp), //input
                          .rxn(rxn), //input
                          .txp(txp), // output
                          .txn(txn), // output
                        `ifndef SYNTHESIS
                          .rxpresent(rxpresent), //input
                        `endif // SYNTHESIS
                          .refclk_p(refclk_p), // input
                          .refclk_n(refclk_n), // input
                          .local_ref_clk_req_n(local_ref_clk_req_n),  // output
                          .mstr_awid(mstr_awid), // output
                          .mstr_awvalid(mstr_awvalid),  // output
                          .mstr_awaddr(mstr_awaddr), // output
                          .mstr_awlen(mstr_awlen), // output
                          .mstr_awsize(mstr_awsize), // output
                          .mstr_awburst(mstr_awburst), // output
                          .mstr_awlock(mstr_awlock),  // output
                          .mstr_awqos(mstr_awqos), // output
                          .mstr_awcache(mstr_awcache), // output
                          .mstr_awprot(mstr_awprot), // output
                          .mstr_awmisc_info(mstr_awmisc_info), // output
                          .mstr_awmisc_info_hdr_34dw(mstr_awmisc_info_hdr_34dw), // output
                          .mstr_awmisc_info_ep(mstr_awmisc_info_ep),  // output
                          .mstr_awmisc_info_last_dcmp_tlp(mstr_awmisc_info_last_dcmp_tlp),  // output
                          .mstr_awready(mstr_awready), // input
                          .mstr_wvalid(mstr_wvalid),  // output
                          .mstr_wlast(mstr_wlast),  // output
                          .mstr_wdata(mstr_wdata), // output
                          .mstr_wstrb(mstr_wstrb), // output
                          .mstr_wready(mstr_wready), // input
                          .mstr_bid(mstr_bid), //input
                          .mstr_bvalid(mstr_bvalid), // input
                          .mstr_bresp(mstr_bresp), //input
                          .mstr_bmisc_info_cpl_stat(mstr_bmisc_info_cpl_stat), //input
                          .mstr_bready(mstr_bready),  // output
                          .mstr_arid(mstr_arid), // output
                          .mstr_arvalid(mstr_arvalid),  // output
                          .mstr_araddr(mstr_araddr), // output
                          .mstr_arlen(mstr_arlen), // output
                          .mstr_arsize(mstr_arsize), // output
                          .mstr_arburst(mstr_arburst), // output
                          .mstr_aclk_gated(mstr_aclk_gated),
                          .mstr_arlock(mstr_arlock),  // output
                          .mstr_arqos(mstr_arqos), // output
                          .mstr_arcache(mstr_arcache), // output
                          .mstr_arprot(mstr_arprot), // output
                          .mstr_armisc_info(mstr_armisc_info), // output
                          .mstr_armisc_info_last_dcmp_tlp(mstr_armisc_info_last_dcmp_tlp),  // output
                          .mstr_armisc_info_zeroread(mstr_armisc_info_zeroread), // output
                          .mstr_arready(mstr_arready), // input
                          .mstr_rid(mstr_rid), //input
                          .mstr_rvalid(mstr_rvalid), // input
                          .mstr_rlast(mstr_rlast), // input
                          .mstr_rdata(mstr_rdata), //input
                          .mstr_rresp(mstr_rresp), //input
                          .mstr_rmisc_info(mstr_rmisc_info), //input
                          .mstr_rmisc_info_cpl_stat(mstr_rmisc_info_cpl_stat), //input
                          .mstr_rready(mstr_rready),  // output
                          .mstr_csysreq(mstr_csysreq), // input
                          .mstr_csysack(mstr_csysack),  // output
                          .mstr_cactive(mstr_cactive),  // output
                          .mstr_aclk(mstr_aclk), // input
                          .mstr_aresetn(mstr_aresetn),  // output
                          .slv_aclk_gated(slv_aclk_gated), // output
                          .slv_awid(slv_awid), //input
                          .slv_awaddr(slv_awaddr), //input
                          .slv_awlen(slv_awlen), //input
                          .slv_awsize(slv_awsize), //input
                          .slv_awburst(slv_awburst), //input
                          .slv_awlock(slv_awlock), // input
                          .slv_awqos(slv_awqos), //input
                          .slv_awcache(slv_awcache), //input
                          .slv_awprot(slv_awprot), //input
                          .slv_awvalid(slv_awvalid), // input
                          .slv_awmisc_info(slv_awmisc_info), //input
                          .slv_awmisc_info_hdr_34dw(slv_awmisc_info_hdr_34dw), //input
                          .slv_awmisc_info_p_tag(slv_awmisc_info_p_tag), //input
                          .slv_awready(slv_awready),  // output
                          .slv_wdata(slv_wdata), //input
                          .slv_wstrb(slv_wstrb), //input
                          .slv_wlast(slv_wlast), // input
                          .slv_wvalid(slv_wvalid), // input
                          .slv_wmisc_info_ep(slv_wmisc_info_ep), // input 
                          .slv_wmisc_info_silentDrop(slv_wmisc_info_silentDrop), // input 
                          .slv_wready(slv_wready),  // output
                          .slv_bid(slv_bid), // output
                          .slv_bresp(slv_bresp), // output
                          .slv_bvalid(slv_bvalid),  // output
                          .slv_bmisc_info(slv_bmisc_info), // output
                          .slv_bready(slv_bready), // input
                          .slv_arid(slv_arid), //input
                          .slv_araddr(slv_araddr), //input
                          .slv_arlen(slv_arlen), //input
                          .slv_arsize(slv_arsize), //input
                          .slv_arburst(slv_arburst), //input
                          .slv_arlock(slv_arlock), // input
                          .slv_arqos(slv_arqos), //input
                          .slv_arcache(slv_arcache), //input
                          .slv_arprot(slv_arprot), //input
                          .slv_arvalid(slv_arvalid), // input
                          .slv_armisc_info(slv_armisc_info), //input
                          .slv_arready(slv_arready),  // output
                          .slv_rid(slv_rid), // output
                          .slv_rdata(slv_rdata), // output
                          .slv_rresp(slv_rresp), // output
                          .slv_rlast(slv_rlast),  // output
                          .slv_rvalid(slv_rvalid),  // output
                          .slv_rmisc_info(slv_rmisc_info), // output
                          .slv_rready(slv_rready), // input
                          .slv_csysreq(slv_csysreq), // input
                          .slv_csysack(slv_csysack),  // output
                          .slv_cactive(slv_cactive),  // output
                          .slv_aclk(slv_aclk), // input
                          .slv_aresetn(slv_aresetn),  // output

                          .radm_trgt1_vc(radm_trgt1_vc), //output




                          .app_dbi_ro_wr_disable(app_dbi_ro_wr_disable), //input

                          .dbi_addr(dbi_addr), //input
                          .dbi_din(dbi_din), //input
                          .dbi_cs(dbi_cs), // input
                          .dbi_cs2(dbi_cs2), // input
                          .dbi_wr(dbi_wr), //input
                          .lbc_dbi_ack(lbc_dbi_ack),  // output
                          .lbc_dbi_dout(lbc_dbi_dout), // output
                          .ext_lbc_ack(ext_lbc_ack), //input
                          .ext_lbc_din(ext_lbc_din), //input
                          .lbc_ext_addr(lbc_ext_addr), // output
                          .lbc_ext_dout(lbc_ext_dout), // output
                          .lbc_ext_cs(lbc_ext_cs), // output
                          .lbc_ext_wr(lbc_ext_wr), // output
                          .lbc_ext_rom_access(lbc_ext_rom_access),  // output
                          .lbc_ext_io_access(lbc_ext_io_access),  // output
                          .lbc_ext_bar_num(lbc_ext_bar_num), // output
                          .ven_msi_req(ven_msi_req), // input
                          .ven_msi_func_num(ven_msi_func_num), //input
                          .ven_msi_tc(ven_msi_tc), //input
                          .ven_msi_vector(ven_msi_vector), //input
                          .ven_msi_grant(ven_msi_grant),  // output
                          .cfg_msi_en(cfg_msi_en), // output
                          .ven_msg_fmt(ven_msg_fmt), //input
                          .ven_msg_type(ven_msg_type), //input
                          .ven_msg_tc(ven_msg_tc), //input
                          .ven_msg_td(ven_msg_td), // input
                          .ven_msg_ep(ven_msg_ep), // input
                          .ven_msg_attr(ven_msg_attr), //input
                          .ven_msg_len(ven_msg_len), //input
                          .ven_msg_func_num(ven_msg_func_num), //input
                          .ven_msg_tag(ven_msg_tag), //input
                          .ven_msg_code(ven_msg_code), //input
                          .ven_msg_data(ven_msg_data), //input
                          .ven_msg_req(ven_msg_req), // input
                          .ven_msg_grant(ven_msg_grant),  // output
                          .sys_int(sys_int), //input
                          .apps_pm_xmt_pme(apps_pm_xmt_pme), //input
                          .radm_q_not_empty(radm_q_not_empty), // output
                          .radm_qoverflow(radm_qoverflow), // output
                          .pm_xtlh_block_tlp(pm_xtlh_block_tlp),  // output
                          .cfg_bar0_start(cfg_bar0_start), // output
                          .cfg_bar0_limit(cfg_bar0_limit), // output
                          .cfg_bar1_start(cfg_bar1_start), // output
                          .cfg_bar1_limit(cfg_bar1_limit), // output
                          .cfg_bar2_start(cfg_bar2_start), // output
                          .cfg_bar2_limit(cfg_bar2_limit), // output
                          .cfg_bar3_start(cfg_bar3_start), // output
                          .cfg_bar3_limit(cfg_bar3_limit), // output
                          .cfg_bar4_start(cfg_bar4_start), // output
                          .cfg_bar4_limit(cfg_bar4_limit), // output
                          .cfg_bar5_start(cfg_bar5_start), // output
                          .cfg_bar5_limit(cfg_bar5_limit), // output
                          .cfg_exp_rom_start(cfg_exp_rom_start), // output
                          .cfg_exp_rom_limit(cfg_exp_rom_limit), // output
                          .cfg_bus_master_en(cfg_bus_master_en), // output
                          .cfg_max_payload_size(cfg_max_payload_size), // output
                          .cfg_rcb(cfg_rcb), // output
                          .cfg_mem_space_en(cfg_mem_space_en), // output
                          .cfg_max_rd_req_size(cfg_max_rd_req_size), // output
                          .rdlh_link_up(rdlh_link_up),  // output
                          .smlh_ltssm_state(smlh_ltssm_state), // output
                          .pm_curnt_state(pm_curnt_state), // output
                          .smlh_link_up(smlh_link_up),  // output
                          .smlh_req_rst_not(smlh_req_rst_not),  // output
                          .link_req_rst_not(link_req_rst_not),  // output
                          .brdg_slv_xfer_pending(brdg_slv_xfer_pending),  // output
                          .brdg_dbi_xfer_pending(brdg_dbi_xfer_pending),  // output
                          .radm_xfer_pending(radm_xfer_pending),  // output

                          .cfg_reg_serren(cfg_reg_serren       ),  // output
                          .cfg_cor_err_rpt_en(cfg_cor_err_rpt_en   ),  // output
                          .cfg_nf_err_rpt_en(cfg_nf_err_rpt_en    ),  // output
                          .cfg_f_err_rpt_en(cfg_f_err_rpt_en     ),  // output

                          .cxpl_debug_info(cxpl_debug_info), // output
                          .cxpl_debug_info_ei(cxpl_debug_info_ei), // output
                          .training_rst_n(training_rst_n),  // output
                          .radm_pm_turnoff(radm_pm_turnoff),  // output
                          .radm_msg_unlock(radm_msg_unlock),  // output
                          .outband_pwrup_cmd(outband_pwrup_cmd), //input
                          .pm_dstate(pm_dstate), // output
                          .aux_pm_en(aux_pm_en), // output
                          .pm_pme_en(pm_pme_en), // output
                          .pm_linkst_in_l0s(pm_linkst_in_l0s),  // output
                          .pm_linkst_in_l1(pm_linkst_in_l1),  // output
                          .pm_l1_entry_started(pm_l1_entry_started),
                          .pm_linkst_in_l2(pm_linkst_in_l2),  // output
                          .pm_linkst_l2_exit(pm_linkst_l2_exit),  // output
                          .pm_status(pm_status), // output
                          .cfg_pbus_num(cfg_pbus_num), // output
                          .cfg_pbus_dev_num(cfg_pbus_dev_num), // output
                          .radm_vendor_msg(radm_vendor_msg), // output
                          .radm_msg_payload(radm_msg_payload), // output
                          .wake(wake),  // output
                          .radm_msg_req_id(radm_msg_req_id), // output
                          .trgt_cpl_timeout(trgt_cpl_timeout),  // output
                          .trgt_timeout_cpl_func_num(trgt_timeout_cpl_func_num), // output
                          .trgt_timeout_cpl_tc(trgt_timeout_cpl_tc), // output
                          .trgt_timeout_cpl_attr(trgt_timeout_cpl_attr), // output
                          .trgt_timeout_cpl_len(trgt_timeout_cpl_len), // output
                          .trgt_timeout_lookup_id(trgt_timeout_lookup_id), // output
                          .trgt_lookup_id(trgt_lookup_id), // output
                          .trgt_lookup_empty(trgt_lookup_empty),  // output
                          .radm_cpl_timeout(radm_cpl_timeout),  // output
                          .radm_timeout_func_num(radm_timeout_func_num), // output
                          .radm_timeout_cpl_tc(radm_timeout_cpl_tc), // output
                          .radm_timeout_cpl_attr(radm_timeout_cpl_attr), // output
                          .radm_timeout_cpl_len(radm_timeout_cpl_len), // output
                          .radm_timeout_cpl_tag(radm_timeout_cpl_tag), // output
                          .assert_inta_grt(assert_inta_grt),  // output
                          .assert_intb_grt(assert_intb_grt),  // output
                          .assert_intc_grt(assert_intc_grt),  // output
                          .assert_intd_grt(assert_intd_grt),  // output
                          .deassert_inta_grt(deassert_inta_grt),  // output
                          .deassert_intb_grt(deassert_intb_grt),  // output
                          .deassert_intc_grt(deassert_intc_grt),  // output
                          .deassert_intd_grt(deassert_intd_grt),  // output
                          .cfg_int_pin(cfg_int_pin), // output
                          .cfg_send_cor_err(cfg_send_cor_err), // output
                          .cfg_send_nf_err(cfg_send_nf_err), // output
                          .cfg_send_f_err(cfg_send_f_err), // output
                          .cfg_int_disable(cfg_int_disable), // output
                          .cfg_no_snoop_en(cfg_no_snoop_en), // output
                          .cfg_relax_order_en(cfg_relax_order_en), // output
// Port list for RAM instance u_ib_mcpl_sb_ram of model ram_2p_1c_wrapper
  .ib_mcpl_sb_ram_addra(ib_mcpl_sb_ram_addra),
  .ib_mcpl_sb_ram_addrb(ib_mcpl_sb_ram_addrb),
  .ib_mcpl_sb_ram_dina (ib_mcpl_sb_ram_dina),
  .ib_mcpl_sb_ram_wea  (ib_mcpl_sb_ram_wea),
  .ib_mcpl_sb_ram_enb  (ib_mcpl_sb_ram_enb),
  .ib_mcpl_sb_ram_doutb(ib_mcpl_sb_ram_doutb),
// Port list for RAM instance u_ib_rreq_ordr_ram of model ram_2p_1c_wrapper
  .ib_rreq_ordr_ram_addra(ib_rreq_ordr_ram_addra),
  .ib_rreq_ordr_ram_addrb(ib_rreq_ordr_ram_addrb),
  .ib_rreq_ordr_ram_dina (ib_rreq_ordr_ram_dina),
  .ib_rreq_ordr_ram_wea  (ib_rreq_ordr_ram_wea),
  .ib_rreq_ordr_ram_enb  (ib_rreq_ordr_ram_enb),
  .ib_rreq_ordr_ram_doutb(ib_rreq_ordr_ram_doutb),
// Port list for RAM instance u_ob_ccmp_data_ram of model ram_2p_1c_wrapper
  .ob_ccmp_data_ram_addra(ob_ccmp_data_ram_addra),
  .ob_ccmp_data_ram_addrb(ob_ccmp_data_ram_addrb),
  .ob_ccmp_data_ram_dina (ob_ccmp_data_ram_dina),
  .ob_ccmp_data_ram_wea  (ob_ccmp_data_ram_wea),
  .ob_ccmp_data_ram_enb  (ob_ccmp_data_ram_enb),
  .ob_ccmp_data_ram_doutb(ob_ccmp_data_ram_doutb),
// Port list for RAM instance u_ob_npdcmp_ram of model ram_2p_2c_wrapper
  .ob_npdcmp_ram_addra(ob_npdcmp_ram_addra),
  .ob_npdcmp_ram_addrb(ob_npdcmp_ram_addrb),
  .ob_npdcmp_ram_dina (ob_npdcmp_ram_dina),
  .ob_npdcmp_ram_wea  (ob_npdcmp_ram_wea),
  .ob_npdcmp_ram_enb  (ob_npdcmp_ram_enb),
  .ob_npdcmp_ram_doutb(ob_npdcmp_ram_doutb),
// Port list for RAM instance u_slv_npw_sab_ram of model ram_2p_1c_wrapper
  .slv_npw_sab_ram_addra(slv_npw_sab_ram_addra),
  .slv_npw_sab_ram_addrb(slv_npw_sab_ram_addrb),
  .slv_npw_sab_ram_dina (slv_npw_sab_ram_dina),
  .slv_npw_sab_ram_wea  (slv_npw_sab_ram_wea),
  .slv_npw_sab_ram_enb  (slv_npw_sab_ram_enb),
  .slv_npw_sab_ram_doutb(slv_npw_sab_ram_doutb),
// Port list for RAM instance u_ob_pdcmp_data_ram of model ram_2p_2c_wrapper
  .ob_pdcmp_data_ram_addra(ob_pdcmp_data_ram_addra),
  .ob_pdcmp_data_ram_addrb(ob_pdcmp_data_ram_addrb),
  .ob_pdcmp_data_ram_dina (ob_pdcmp_data_ram_dina),
  .ob_pdcmp_data_ram_wea  (ob_pdcmp_data_ram_wea),
  .ob_pdcmp_data_ram_enb  (ob_pdcmp_data_ram_enb),
  .ob_pdcmp_data_ram_doutb(ob_pdcmp_data_ram_doutb),
// Port list for RAM instance u_ob_pdcmp_hdr_ram of model ram_2p_2c_wrapper
  .ob_pdcmp_hdr_ram_addra(ob_pdcmp_hdr_ram_addra),
  .ob_pdcmp_hdr_ram_addrb(ob_pdcmp_hdr_ram_addrb),
  .ob_pdcmp_hdr_ram_dina (ob_pdcmp_hdr_ram_dina),
  .ob_pdcmp_hdr_ram_wea  (ob_pdcmp_hdr_ram_wea),
  .ob_pdcmp_hdr_ram_enb  (ob_pdcmp_hdr_ram_enb),
  .ob_pdcmp_hdr_ram_doutb(ob_pdcmp_hdr_ram_doutb),
// Port list for RAM instance u3_ram_radm_qbuffer_data of model ram_2p_1c_wrapper
  .p_dataq_addra(p_dataq_addra),
  .p_dataq_addrb(p_dataq_addrb),
  .p_dataq_datain (p_dataq_datain),
  .p_dataq_ena  (p_dataq_ena),
  .p_dataq_enb  (p_dataq_enb),
  .p_dataq_wea  (p_dataq_wea),
  .p_dataq_dataout(p_dataq_dataout),
// Port list for RAM instance u0_ram_radm_qbuffer_hdr of model ram_2p_1c_wrapper
  .p_hdrq_addra(p_hdrq_addra),
  .p_hdrq_addrb(p_hdrq_addrb),
  .p_hdrq_datain (p_hdrq_datain),
  .p_hdrq_ena  (p_hdrq_ena),
  .p_hdrq_enb  (p_hdrq_enb),
  .p_hdrq_wea  (p_hdrq_wea),
  .p_hdrq_dataout(p_hdrq_dataout),
// Port list for RAM instance u_ram_1p_rbuf of model ram_1p_wrapper
  .xdlh_retryram_addr(xdlh_retryram_addr),
  .xdlh_retryram_data (xdlh_retryram_data),
  .xdlh_retryram_en  (xdlh_retryram_en),
  .xdlh_retryram_we  (xdlh_retryram_we),
  .retryram_xdlh_data(retryram_xdlh_data),
// Port list for RAM instance u_ram_2p_sotbuf of model ram_2p_1c_wrapper
  .xdlh_retrysotram_waddr(xdlh_retrysotram_waddr),
  .xdlh_retrysotram_raddr(xdlh_retrysotram_raddr),
  .xdlh_retrysotram_data (xdlh_retrysotram_data),
  .xdlh_retrysotram_we  (xdlh_retrysotram_we),
  .xdlh_retrysotram_en  (xdlh_retrysotram_en),
  .retrysotram_xdlh_data(retrysotram_xdlh_data),

                          .p_hdrq_depth(p_hdrq_depth),
                          .p_dataq_depth(p_dataq_depth),

                          .core_rst_n(core_rst_n),
                          .core_clk(core_clk), // output
                          .pm_master_state(pm_master_state),
                          .pm_slave_state(pm_slave_state)
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


                                 /*AUTOINST*/);


ku5p_pcie_iip_rams external_rams (
// Port list for RAM instance u_ib_mcpl_sb_ram of model ram_2p_1c_wrapper
  .ib_mcpl_sb_ram_addra(ib_mcpl_sb_ram_addra),
  .ib_mcpl_sb_ram_addrb(ib_mcpl_sb_ram_addrb),
  .ib_mcpl_sb_ram_dina (ib_mcpl_sb_ram_dina),
  .ib_mcpl_sb_ram_wea  (ib_mcpl_sb_ram_wea),
  .ib_mcpl_sb_ram_enb  (ib_mcpl_sb_ram_enb),
  .ib_mcpl_sb_ram_doutb(ib_mcpl_sb_ram_doutb),
// Port list for RAM instance u_ib_rreq_ordr_ram of model ram_2p_1c_wrapper
  .ib_rreq_ordr_ram_addra(ib_rreq_ordr_ram_addra),
  .ib_rreq_ordr_ram_addrb(ib_rreq_ordr_ram_addrb),
  .ib_rreq_ordr_ram_dina (ib_rreq_ordr_ram_dina),
  .ib_rreq_ordr_ram_wea  (ib_rreq_ordr_ram_wea),
  .ib_rreq_ordr_ram_enb  (ib_rreq_ordr_ram_enb),
  .ib_rreq_ordr_ram_doutb(ib_rreq_ordr_ram_doutb),
// Port list for RAM instance u_ob_ccmp_data_ram of model ram_2p_1c_wrapper
  .ob_ccmp_data_ram_addra(ob_ccmp_data_ram_addra),
  .ob_ccmp_data_ram_addrb(ob_ccmp_data_ram_addrb),
  .ob_ccmp_data_ram_dina (ob_ccmp_data_ram_dina),
  .ob_ccmp_data_ram_wea  (ob_ccmp_data_ram_wea),
  .ob_ccmp_data_ram_enb  (ob_ccmp_data_ram_enb),
  .ob_ccmp_data_ram_doutb(ob_ccmp_data_ram_doutb),
// Port list for RAM instance u_ob_npdcmp_ram of model ram_2p_2c_wrapper
  .ob_npdcmp_ram_addra(ob_npdcmp_ram_addra),
  .ob_npdcmp_ram_addrb(ob_npdcmp_ram_addrb),
  .ob_npdcmp_ram_dina (ob_npdcmp_ram_dina),
  .ob_npdcmp_ram_wea  (ob_npdcmp_ram_wea),
  .ob_npdcmp_ram_enb  (ob_npdcmp_ram_enb),
  .ob_npdcmp_ram_doutb(ob_npdcmp_ram_doutb),
// Port list for RAM instance u_slv_npw_sab_ram of model ram_2p_1c_wrapper
  .slv_npw_sab_ram_addra(slv_npw_sab_ram_addra),
  .slv_npw_sab_ram_addrb(slv_npw_sab_ram_addrb),
  .slv_npw_sab_ram_dina (slv_npw_sab_ram_dina),
  .slv_npw_sab_ram_wea  (slv_npw_sab_ram_wea),
  .slv_npw_sab_ram_enb  (slv_npw_sab_ram_enb),
  .slv_npw_sab_ram_doutb(slv_npw_sab_ram_doutb),
// Port list for RAM instance u_ob_pdcmp_data_ram of model ram_2p_2c_wrapper
  .ob_pdcmp_data_ram_addra(ob_pdcmp_data_ram_addra),
  .ob_pdcmp_data_ram_addrb(ob_pdcmp_data_ram_addrb),
  .ob_pdcmp_data_ram_dina (ob_pdcmp_data_ram_dina),
  .ob_pdcmp_data_ram_wea  (ob_pdcmp_data_ram_wea),
  .ob_pdcmp_data_ram_enb  (ob_pdcmp_data_ram_enb),
  .ob_pdcmp_data_ram_doutb(ob_pdcmp_data_ram_doutb),
// Port list for RAM instance u_ob_pdcmp_hdr_ram of model ram_2p_2c_wrapper
  .ob_pdcmp_hdr_ram_addra(ob_pdcmp_hdr_ram_addra),
  .ob_pdcmp_hdr_ram_addrb(ob_pdcmp_hdr_ram_addrb),
  .ob_pdcmp_hdr_ram_dina (ob_pdcmp_hdr_ram_dina),
  .ob_pdcmp_hdr_ram_wea  (ob_pdcmp_hdr_ram_wea),
  .ob_pdcmp_hdr_ram_enb  (ob_pdcmp_hdr_ram_enb),
  .ob_pdcmp_hdr_ram_doutb(ob_pdcmp_hdr_ram_doutb),
// Port list for RAM instance u3_ram_radm_qbuffer_data of model ram_2p_1c_wrapper
  .p_dataq_addra(p_dataq_addra),
  .p_dataq_addrb(p_dataq_addrb),
  .p_dataq_datain (p_dataq_datain),
  .p_dataq_ena  (p_dataq_ena),
  .p_dataq_enb  (p_dataq_enb),
  .p_dataq_wea  (p_dataq_wea),
  .p_dataq_dataout(p_dataq_dataout),
// Port list for RAM instance u0_ram_radm_qbuffer_hdr of model ram_2p_1c_wrapper
  .p_hdrq_addra(p_hdrq_addra),
  .p_hdrq_addrb(p_hdrq_addrb),
  .p_hdrq_datain (p_hdrq_datain),
  .p_hdrq_ena  (p_hdrq_ena),
  .p_hdrq_enb  (p_hdrq_enb),
  .p_hdrq_wea  (p_hdrq_wea),
  .p_hdrq_dataout(p_hdrq_dataout),
// Port list for RAM instance u_ram_1p_rbuf of model ram_1p_wrapper
  .xdlh_retryram_addr(xdlh_retryram_addr),
  .xdlh_retryram_data (xdlh_retryram_data),
  .xdlh_retryram_en  (xdlh_retryram_en),
  .xdlh_retryram_we  (xdlh_retryram_we),
  .retryram_xdlh_data(retryram_xdlh_data),
// Port list for RAM instance u_ram_2p_sotbuf of model ram_2p_1c_wrapper
  .xdlh_retrysotram_waddr(xdlh_retrysotram_waddr),
  .xdlh_retrysotram_raddr(xdlh_retrysotram_raddr),
  .xdlh_retrysotram_data (xdlh_retrysotram_data),
  .xdlh_retrysotram_we  (xdlh_retrysotram_we),
  .xdlh_retrysotram_en  (xdlh_retrysotram_en),
  .retrysotram_xdlh_data(retrysotram_xdlh_data),


                              // Clocks
                                .mstr_aclk_gated          (mstr_aclk_gated),
                                .slv_aclk_gated           (slv_aclk_gated),
                                .radm_clk_g               (radm_clk_g),
                                .muxd_aux_clk_g           (muxd_aux_clk_g),
                                .core_clk                 (core_clk)
                               /*AUTOINST*/);



endmodule // : pcie_iip_device
// Local Variables:
// verilog-library-flags:("-y ./")
// End:


