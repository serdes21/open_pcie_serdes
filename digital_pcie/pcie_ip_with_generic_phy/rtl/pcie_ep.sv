`timescale 1ns/1ps
`ifndef PCIE_EP_SV
`define PCIE_EP_SV



module pcie_ep #(
  parameter int NL = 1,     // lane count (test‑bench中为 1)
  parameter int NF = 1,      // PF 数，用来生成零向量常量

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
   parameter TAG_SIZE                 = `CX_TAG_SIZE
)(
  //------------------------------------------------------------------
  //  仅对外暴露的信号
  //------------------------------------------------------------------
  input  wire                     reset_n,
  input  wire                     app_ltssm_enable,
  input  wire                     app_hold_phy_rst,

  input  wire [NL-1:0]            rxp,
  input  wire [NL-1:0]            rxn,
  output wire [NL-1:0]            txp,
  output wire [NL-1:0]            txn,
  input  wire [NL-1:0]            rxpresent,

  input  wire                     refclk_p,
  input  wire                     refclk_n
);

  wire power_up_rst_n = reset_n;
  wire button_rst_n   = reset_n;
  wire perst_n        = reset_n;
 // wire mstr_aresetn       = reset_n;
  wire slv_aresetn        = reset_n;

  //------------------------------------------------------------------
  // 内部 tie-off 常量
  //------------------------------------------------------------------
  localparam bit C0 = 1'b0, C1 = 1'b1;
  wire [3:0]                V0_4  = '0;
  wire [MSTR_MISC_INFO_PW-1:0] V0_MSTR_MISC = '0;
  wire [SLV_MISC_INFO_PW -1:0] V0_SLV_MISC  = '0;
  wire [TAG_SIZE-1:0]          V0_TAG       = '0;
  wire [MSTR_RESP_MISC_INFO_PW-1:0] V0_MSTR_RESP_MISC = '0;   // 读数据 sideband
    wire [1:0]                        V0_CPL_STAT       = 2'b00;// CPL stat

  // 未导出的“低功耗”/“misc”信号用哑线吸收
  wire         unused_mstr_csysack, unused_mstr_cactive;
  wire         unused_slv_csysack,  unused_slv_cactive;

   //------------------------------------------------------------------
  // Internal AXI-Master <--> vec8x16_add_axi_slave wires
  //------------------------------------------------------------------
  // Write-addr
  wire [MSTR_ID_WD-1:0]          m_awid;
  wire                            m_awvalid;
  wire [MSTR_ADDR_WD-1:0]        m_awaddr;
  wire [MSTR_BURST_LEN_PW-1:0]   m_awlen;
  wire [2:0]                     m_awsize;
  wire [1:0]                     m_awburst;
  wire                            m_awlock;
  wire [3:0]                     m_awcache;
  wire [2:0]                     m_awprot;
  wire                            m_awready;
  // Write-data
  wire                            m_wvalid;
  wire                            m_wlast;
  wire [MSTR_DATA_WD-1:0]        m_wdata;
  wire [MSTR_WSTRB_WD-1:0]       m_wstrb;
  wire                            m_wready;
  // Write-resp
  wire [MSTR_ID_WD-1:0]          m_bid;
  wire                            m_bvalid;
  wire [1:0]                     m_bresp;
  wire                            m_bready;
  // Read-addr
  wire [MSTR_ID_WD-1:0]          m_arid;
  wire                            m_arvalid;
  wire [MSTR_ADDR_WD-1:0]        m_araddr;
  wire [MSTR_BURST_LEN_PW-1:0]   m_arlen;
  wire [2:0]                     m_arsize;
  wire [1:0]                     m_arburst;
  wire                            m_arlock;
  wire [3:0]                     m_arcache;
  wire [2:0]                     m_arprot;
  wire                            m_arready;
  // Read-data
  wire [MSTR_ID_WD-1:0]          m_rid;
  wire                            m_rvalid;
  wire                            m_rlast;
  wire [MSTR_DATA_WD-1:0]        m_rdata;
  wire [1:0]                     m_rresp;
  wire                            m_rready;

  // AXI clock/reset for master path (use auxclk for simplicity)
  wire auxclk;
  wire axi_clk        = auxclk;
  wire mstr_aresetn;

  //------------------------------------------------------------------
  //  设备实例
  //------------------------------------------------------------------
  ku5p_pcie_iip_device #(
    .NL (NL)        // 仅传递 lane 宽度；其余参数保持默认
  ) u_pcie_iip_device (
    // 基本时钟/复位和 LTSSM 控制
    .power_up_rst_n            (power_up_rst_n),
    .button_rst_n              (button_rst_n),
    .perst_n                   (perst_n),
    .auxclk                    (auxclk),
    .sys_aux_pwr_det           (C1),                // 始终认为有辅助电源
    .app_ltssm_enable          (app_ltssm_enable),
    .app_hold_phy_rst          (app_hold_phy_rst),

    // 串行收发
    .rxp                       (rxp),
    .rxn                       (rxn),
    .txp                       (txp),
    .txn                       (txn),
    .rxpresent                 (rxpresent),

    // 参考时钟
    .refclk_p                  (refclk_p),
    .refclk_n                  (refclk_n),

    // 其余输入全部 tie‑off
    .app_clk_req_n           (C0),
    .app_clk_pm_en           (C0),
    .app_init_rst            (C0),
    .app_req_entr_l1         (C0),
    .app_ready_entr_l23      (C0),
    .app_req_exit_l1         (C0),
    .app_xfer_pending        (C0),
    .exp_rom_validation_status_strobe ('0),
    .exp_rom_validation_status        ('0),
    .exp_rom_validation_details_strobe('0),
    .exp_rom_validation_details       ('0),
    .app_req_retry_en        (C0),
    .app_pf_req_retry_en     ('0),

    // ================= AXI-MASTER (connected below) =================
    .mstr_awid                 (m_awid),
    .mstr_awvalid              (m_awvalid),
    .mstr_awaddr               (m_awaddr),
    .mstr_awlen                (m_awlen),
    .mstr_awsize               (m_awsize),
    .mstr_awburst              (m_awburst),
    .mstr_awlock               (m_awlock),
    .mstr_awcache              (m_awcache),
    .mstr_awprot               (m_awprot),
    .mstr_awqos                (V0_4),
    .mstr_awmisc_info          (V0_MSTR_MISC),
    .mstr_awready              (m_awready),

    .mstr_wvalid               (m_wvalid),
    .mstr_wlast                (m_wlast),
    .mstr_wdata                (m_wdata),
    .mstr_wstrb                (m_wstrb),
    .mstr_wready               (m_wready),

    .mstr_bid                  (m_bid),
    .mstr_bvalid               (m_bvalid),
    .mstr_bresp                (m_bresp),
    .mstr_bready               (m_bready),
    .mstr_bmisc_info_cpl_stat (V0_CPL_STAT),

    .mstr_arid                 (m_arid),
    .mstr_arvalid              (m_arvalid),
    .mstr_araddr               (m_araddr),
    .mstr_arlen                (m_arlen),
    .mstr_arsize               (m_arsize),
    .mstr_arburst              (m_arburst),
    .mstr_arlock               (m_arlock),
    .mstr_arcache              (m_arcache),
    .mstr_arprot               (m_arprot),
    .mstr_arqos                (V0_4),
    .mstr_armisc_info          (V0_MSTR_MISC),
    .mstr_arready              (m_arready),

    .mstr_rid                  (m_rid),
    .mstr_rvalid               (m_rvalid),
    .mstr_rlast                (m_rlast),
    .mstr_rdata                (m_rdata),
    .mstr_rresp                (m_rresp),
    .mstr_rready               (m_rready),
    .mstr_rmisc_info          (V0_MSTR_RESP_MISC),
    .mstr_rmisc_info_cpl_stat (V0_CPL_STAT),

    .mstr_csysreq              (C0),
    .mstr_csysack              (unused_mstr_csysack),
    .mstr_cactive              (unused_mstr_cactive),
    .mstr_aclk                 (axi_clk),
    .mstr_aresetn              (mstr_aresetn),

    // ================= AXI-SLAVE 端口全部停用 =================
    .slv_awid                  ('0),
    .slv_awaddr                ('0),
    .slv_awlen                 ('0),
    .slv_awsize                ('0),
    .slv_awburst               ('0),
    .slv_awlock                (C0),
    .slv_awqos                 (V0_4),
    .slv_awcache               ('0),
    .slv_awprot                ('0),
    .slv_awvalid               (C0),
    .slv_awmisc_info           ('0),
    .slv_awmisc_info_hdr_34dw  ('0),
    .slv_awmisc_info_p_tag     (V0_TAG),
    .slv_awready               (/* 未用 */),

    .slv_wdata                 ('0),
    .slv_wstrb                 ('0),
    .slv_wlast                 (C0),
    .slv_wvalid                (C0),
    .slv_wmisc_info_ep         (C0),
    .slv_wmisc_info_silentDrop (C0),
    .slv_wready                (/* 未用 */),

    .slv_bid                   (),
    .slv_bresp                 (),
    .slv_bvalid                (),
    .slv_bmisc_info            (),
    .slv_bready                (C0),

    .slv_arid                  ('0),
    .slv_araddr                ('0),
    .slv_arlen                 ('0),
    .slv_arsize                ('0),
    .slv_arburst               ('0),
    .slv_arlock                (C0),
    .slv_arqos                 (V0_4),
    .slv_arcache               ('0),
    .slv_arprot                ('0),
    .slv_arvalid               (C0),
    .slv_armisc_info           ('0),
    .slv_arready               (/* 未用 */),

    .slv_rid                   (),
    .slv_rdata                 (),
    .slv_rresp                 (),
    .slv_rlast                 (),
    .slv_rvalid                (),
    .slv_rmisc_info            (),
    .slv_rready                (C0),

    .slv_csysreq               (C0),
    .slv_csysack               (),
    .slv_cactive               (),
    .slv_aclk                  (axi_clk),
    .slv_aresetn               ()
  );

  vec8x16_add_axi_slave #(
    .C_S_AXI_ID_WIDTH   (MSTR_ID_WD),
    .C_S_AXI_DATA_WIDTH (MSTR_DATA_WD),
    .C_S_AXI_ADDR_WIDTH (MSTR_ADDR_WD)
  ) u_vec8x16_add_axi_slave (
    // ----- Global -----
    .S_AXI_ACLK         (axi_clk),
    .S_AXI_ARESETN      (mstr_aresetn),

    // ----- 写地址 -----
    .S_AXI_AWID         (m_awid),
    .S_AXI_AWADDR       (m_awaddr),
    .S_AXI_AWLEN        (m_awlen[MSTR_BURST_LEN_PW-1:0]),
    .S_AXI_AWSIZE       (m_awsize),
    .S_AXI_AWBURST      (m_awburst),
    .S_AXI_AWLOCK       (m_awlock),
    .S_AXI_AWCACHE      (m_awcache),
    .S_AXI_AWPROT       (m_awprot),
    .S_AXI_AWQOS        (4'b0),
    .S_AXI_AWREGION     (4'b0),
    .S_AXI_AWUSER       (),
    .S_AXI_AWVALID      (m_awvalid),
    .S_AXI_AWREADY      (m_awready),

    // ----- 写数据 -----
    .S_AXI_WDATA        (m_wdata),
    .S_AXI_WSTRB        (m_wstrb),
    .S_AXI_WLAST        (m_wlast),
    .S_AXI_WUSER        (),
    .S_AXI_WVALID       (m_wvalid),
    .S_AXI_WREADY       (m_wready),

    // ----- 写应答 -----
    .S_AXI_BID          (m_bid),
    .S_AXI_BRESP        (m_bresp),
    .S_AXI_BUSER        (),
    .S_AXI_BVALID       (m_bvalid),
    .S_AXI_BREADY       (m_bready),

    // ----- 读地址 -----
    .S_AXI_ARID         (m_arid),
    .S_AXI_ARADDR       (m_araddr),
    .S_AXI_ARLEN        (m_arlen[MSTR_BURST_LEN_PW-1:0]),
    .S_AXI_ARSIZE       (m_arsize),
    .S_AXI_ARBURST      (m_arburst),
    .S_AXI_ARLOCK       (m_arlock),
    .S_AXI_ARCACHE      (m_arcache),
    .S_AXI_ARPROT       (m_arprot),
    .S_AXI_ARQOS        (4'b0),
    .S_AXI_ARREGION     (4'b0),
    .S_AXI_ARUSER       (),
    .S_AXI_ARVALID      (m_arvalid),
    .S_AXI_ARREADY      (m_arready),

    // ----- 读数据 -----
    .S_AXI_RID          (m_rid),
    .S_AXI_RDATA        (m_rdata),
    .S_AXI_RRESP        (m_rresp),
    .S_AXI_RLAST        (m_rlast),
    .S_AXI_RUSER        (),
    .S_AXI_RVALID       (m_rvalid),
    .S_AXI_RREADY       (m_rready)
  );


endmodule : pcie_ep




module vec8x16_add_axi_slave #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of ID for for write address, write data, read address and read data
		parameter integer C_S_AXI_ID_WIDTH	= 5,
		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 32,
		// Width of optional user defined signal in write address channel
		parameter integer C_S_AXI_AWUSER_WIDTH	= 0,
		// Width of optional user defined signal in read address channel
		parameter integer C_S_AXI_ARUSER_WIDTH	= 0,
		// Width of optional user defined signal in write data channel
		parameter integer C_S_AXI_WUSER_WIDTH	= 0,
		// Width of optional user defined signal in read data channel
		parameter integer C_S_AXI_RUSER_WIDTH	= 0,
		// Width of optional user defined signal in write response channel
		parameter integer C_S_AXI_BUSER_WIDTH	= 0
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write Address ID
		input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_AWID,
		// Write address
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		input wire [7 : 0] S_AXI_AWLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		input wire [2 : 0] S_AXI_AWSIZE,
		// Burst type. The burst type and the size information,
    // determine how the address for each transfer within the burst is calculated.
		input wire [1 : 0] S_AXI_AWBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		input wire  S_AXI_AWLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		input wire [3 : 0] S_AXI_AWCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Quality of Service, QoS identifier sent for each
    // write transaction.
		input wire [3 : 0] S_AXI_AWQOS,
		// Region identifier. Permits a single physical interface
    // on a slave to be used for multiple logical interfaces.
		input wire [3 : 0] S_AXI_AWREGION,
		// Optional User-defined signal in the write address channel.
		input wire [C_S_AXI_AWUSER_WIDTH-1 : 0] S_AXI_AWUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid write address and
    // control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that
    // the slave is ready to accept an address and associated
    // control signals.
		output wire  S_AXI_AWREADY,
		// Write Data
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte
    // lanes hold valid data. There is one write strobe
    // bit for each eight bits of the write data bus.
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write last. This signal indicates the last transfer
    // in a write burst.
		input wire  S_AXI_WLAST,
		// Optional User-defined signal in the write data channel.
		input wire [C_S_AXI_WUSER_WIDTH-1 : 0] S_AXI_WUSER,
		// Write valid. This signal indicates that valid write
    // data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    // can accept the write data.
		output wire  S_AXI_WREADY,
		// Response ID tag. This signal is the ID tag of the
    // write response.
		output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_BID,
		// Write response. This signal indicates the status
    // of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Optional User-defined signal in the write response channel.
		output wire [C_S_AXI_BUSER_WIDTH-1 : 0] S_AXI_BUSER,
		// Write response valid. This signal indicates that the
    // channel is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    // can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address ID. This signal is the identification
    // tag for the read address group of signals.
		input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_ARID,
		// Read address. This signal indicates the initial
    // address of a read burst transaction.
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		input wire [7 : 0] S_AXI_ARLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		input wire [2 : 0] S_AXI_ARSIZE,
		// Burst type. The burst type and the size information,
    // determine how the address for each transfer within the burst is calculated.
		input wire [1 : 0] S_AXI_ARBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		input wire  S_AXI_ARLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		input wire [3 : 0] S_AXI_ARCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Quality of Service, QoS identifier sent for each
    // read transaction.
		input wire [3 : 0] S_AXI_ARQOS,
		// Region identifier. Permits a single physical interface
    // on a slave to be used for multiple logical interfaces.
		input wire [3 : 0] S_AXI_ARREGION,
		// Optional User-defined signal in the read address channel.
		input wire [C_S_AXI_ARUSER_WIDTH-1 : 0] S_AXI_ARUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid read address and
    // control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that
    // the slave is ready to accept an address and associated
    // control signals.
		output wire  S_AXI_ARREADY,
		// Read ID tag. This signal is the identification tag
    // for the read data group of signals generated by the slave.
		output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_RID,
		// Read Data
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of
    // the read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read last. This signal indicates the last transfer
    // in a read burst.
		output wire  S_AXI_RLAST,
		// Optional User-defined signal in the read address channel.
		output wire [C_S_AXI_RUSER_WIDTH-1 : 0] S_AXI_RUSER,
		// Read valid. This signal indicates that the channel
    // is signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    // accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4FULL signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [C_S_AXI_ID_WIDTH-1 : 0] 	axi_bid;
	reg [1 : 0] 	axi_bresp;
	reg [C_S_AXI_BUSER_WIDTH-1 : 0] 	axi_buser;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_ID_WIDTH-1 : 0] 	axi_rid;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rlast;
	reg [C_S_AXI_RUSER_WIDTH-1 : 0] 	axi_ruser;
	reg  	axi_rvalid;
	// aw_wrap_en determines wrap boundary and enables wrapping
	wire aw_wrap_en;
	// ar_wrap_en determines wrap boundary and enables wrapping
	wire ar_wrap_en;
	// aw_wrap_size is the size of the write transfer, the
	// write address wraps to a lower address if upper address
	// limit is reached
	wire [31:0]  aw_wrap_size ;
	// ar_wrap_size is the size of the read transfer, the
	// read address wraps to a lower address if upper address
	// limit is reached
	wire [31:0]  ar_wrap_size ;
	// The axi_awlen_cntr internal write address counter to keep track of beats in a burst transaction
	reg [7:0] axi_awlen_cntr;
	//The axi_arlen_cntr internal read address counter to keep track of beats in a burst transaction
	reg [7:0] axi_arlen_cntr;
	reg [1:0] axi_arburst;
	reg [1:0] axi_awburst;
	reg [7:0] axi_arlen;
	reg [7:0] axi_awlen;
	//local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	//ADDR_LSB is used for addressing 32/64 bit registers/memories
	//ADDR_LSB = 2 for 32 bits (n downto 2)
	//ADDR_LSB = 3 for 64 bits (n downto 3)

	//ADDR_LSB = 4 for 128 bits (n downto 4)

	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32)+ 1;
	localparam integer OPT_MEM_ADDR_BITS = 7;
	localparam integer USER_NUM_MEM = 1;

	//----------------------------------------------
	//-- Signals for user logic memory space example
	//------------------------------------------------
	wire [OPT_MEM_ADDR_BITS:0] mem_address_read;
	wire [OPT_MEM_ADDR_BITS:0] mem_address_write;
	wire [C_S_AXI_DATA_WIDTH-1:0] mem_data_out[0 : USER_NUM_MEM-1];



	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BUSER	= axi_buser;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RLAST	= axi_rlast;
	assign S_AXI_RUSER	= axi_ruser;
	assign S_AXI_RVALID	= axi_rvalid;
	assign S_AXI_BID = axi_bid;
	assign S_AXI_RID = axi_rid;
	//assign S_AXI_RDATA = mem_data_out[0];
	assign  aw_wrap_size = (C_S_AXI_DATA_WIDTH/8 * (axi_awlen));
	assign  ar_wrap_size = (C_S_AXI_DATA_WIDTH/8 * (axi_arlen));
	assign  aw_wrap_en = ((axi_awaddr & aw_wrap_size) == aw_wrap_size)? 1'b1: 1'b0;
	assign  ar_wrap_en = ((axi_araddr & ar_wrap_size) == ar_wrap_size)? 1'b1: 1'b0;

	//Implement Write state machine
	//Outstanding write transactions are not supported by the slave i.e., master should assert bready to receive response on or before it starts sending the new transaction
	 //state machines local parameters
	 localparam Idle = 2'b00,Raddr = 2'b10,Rdata = 2'b11 ,Waddr = 2'b10,Wdata = 2'b11;
	 //state_machine variables
	 reg [1:0] state_read;
	 reg [1:0] state_write;
	 always @(posedge S_AXI_ACLK)
	   begin
	     if (S_AXI_ARESETN == 1'b0)
	       begin
	        // asserting initial values to all 0's during reset
	        axi_awready <= 0;
	        axi_wready <= 0;
	        axi_bvalid <= 0;
	        axi_buser <= 0;
	        axi_awburst <= 0;
	        axi_bid <= 0;
	        axi_awlen <= 0;
	        axi_bresp <= 0;
	        state_write <= Idle;
	       end
	     else
	       begin
	         case(state_write)
	           Idle:     //Initial state inidicating reset is done and ready to receive read/write transactions
	             begin
	               if(S_AXI_ARESETN == 1'b1)
	                 begin
	                   axi_awready <= 1'b1;
	                   axi_wready <= 1'b1;
	                   state_write <= Waddr;
	                 end
	               else state_write <= state_write;
	             end
	           Waddr:        //At this state, slave is ready to receive address along with corresponding control signals and first data packet. Response valid is also handled at this state
	             begin
	               if (S_AXI_AWVALID && axi_awready)
	                 begin
	                   if (S_AXI_WVALID && S_AXI_WLAST)
	                     begin
	                       axi_bvalid <= 1'b1;
	                       axi_awready <= 1'b1;
	                       state_write <= Waddr;
	                     end
	                   else
	                     begin
	                       if (S_AXI_BREADY && axi_bvalid) axi_bvalid <= 1'b0;
	                       state_write <= Wdata;
	                       axi_awready <= 1'b0;
	                      end
	                    axi_awburst <= S_AXI_AWBURST;
	                    axi_awlen <= S_AXI_AWLEN;
	                    axi_bid <= S_AXI_AWID;
	                 end
	               else
	                 begin
	                  state_write <= state_write;
	                  if (S_AXI_BREADY && axi_bvalid) axi_bvalid <= 1'b0;
	                 end
	             end
	           Wdata:        //At this state, slave is ready to receive the data packets until the number of transfers is equal to burst length
	             begin
	               if (S_AXI_WVALID && S_AXI_WLAST)
	                 begin
	                   state_write <= Waddr;
	                   axi_bvalid <= 1'b1;
	                   axi_awready <= 1'b1;
	                 end
	               else state_write <= state_write;
	             end
	          endcase
	        end
	     end
	//Implement Read state machine
	//Outstanding read transactions are not supported by the slave

	  always @(posedge S_AXI_ACLK)
	    begin
	      if (S_AXI_ARESETN == 1'b0)
	        begin
	       // asserting initial values to all 0's during reset
	         axi_arready <= 1'b0;
	         axi_arburst <= 1'b0;
	         axi_arlen <= 1'b0;
	         axi_rid <= 1'b0;
	         axi_rlast <= 1'b0;
	         axi_ruser <= 1'b0;
	         axi_rvalid <= 1'b0;
	         axi_rresp <= 1'b0;
	         state_read <= Idle;
	       end
	     else
	       begin
	         case(state_read)
	           Idle:     //Initial state inidicating reset is done and ready to receive read/write transactions
	             begin
	               if (S_AXI_ARESETN == 1'b1)
	                 begin
	                   state_read <= Raddr;
	                   axi_arready <= 1'b1;
	                 end
	               else state_read <= state_read;
	             end
	           Raddr:        //At this state, slave is ready to receive address and corresponding control signals
	             begin
	               if (S_AXI_ARVALID && axi_arready)
	                 begin
	                   state_read <= Rdata;
	                   axi_rvalid <= 1'b1;
	                   axi_arready <= 1'b0;
	                   axi_rid <= S_AXI_ARID;
	                   if (S_AXI_ARLEN == 1'b0) axi_rlast <= 1'b1;
	                   axi_arburst <= S_AXI_ARBURST;
	                   axi_arlen <= S_AXI_ARLEN;
	                 end
	               else state_read <= state_read;
	             end
	           Rdata:        //At this state, slave is ready to send the data packets until the number of transfers is equal to burst length
	             begin
	              if ((axi_arlen_cntr == axi_arlen-1) && ~axi_rlast && S_AXI_RREADY) axi_rlast <= 1'b1;
	              if (axi_rvalid && S_AXI_RREADY && axi_rlast)
	                begin
	                  axi_rvalid <= 1'b0;
	                  axi_arready <= 1'b1;
	                  axi_rlast <= 1'b0;
	                  state_read <= Raddr;
	                end
	              else state_read <= state_read;
	             end
	           endcase
	         end
	    end
	//This always block handles the write address increment
	  always @(posedge S_AXI_ACLK)
	    begin
	      if (S_AXI_ARESETN == 1'b0)
	        begin
	          //both axi_awlen_cntr and axi_awaddr will increment after each successfull data received until the number of the transfers is equal to burst length
	          axi_awlen_cntr <= 0;
	          axi_awaddr <= 0;
	        end
	      else
	        begin
	          if (S_AXI_AWVALID && axi_awready)
	            begin
	              if (S_AXI_WVALID)
	                begin
	                  axi_awlen_cntr <= 1;
	                  if ((S_AXI_AWBURST == 2'b01) || ((S_AXI_AWBURST == 2'b10) && (S_AXI_AWLEN != 0)) )
	                    begin
	                      axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= S_AXI_AWADDR[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                    end
	                  else
	                    begin
	                      axi_awaddr <= axi_awaddr;
	                    end
	                 end
	               else
	                 begin
	                   axi_awlen_cntr <= 0;
	                   axi_awaddr <= S_AXI_AWADDR[C_S_AXI_ADDR_WIDTH - 1:0];
	                 end
	              end
	        else if((axi_awlen_cntr < axi_awlen) && S_AXI_WVALID)
	          begin
	            axi_awlen_cntr <= axi_awlen_cntr + 1;
	            case (axi_awburst)
	              2'b00: // fixed burst
	                // The write address for all the beats in the transaction are fixed
	                begin
	                  axi_awaddr <= axi_awaddr;
	                  //for awsize = 4 bytes (010)
	                end
	              2'b01: //incremental burst
	              // The write address for all the beats in the transaction are increments by awsize
	                begin
	                  axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                  //awaddr aligned to 4 byte boundary
	                  axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};
	                  //for awsize = 4 bytes (010)
	                end
	              2'b10: //Wrapping burst
	                // The write address wraps when the address reaches wrap boundary
	                if (aw_wrap_en)
	                  begin
	                    axi_awaddr <= (axi_awaddr - aw_wrap_size);
	                  end
	                else
	                  begin
	                    axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                    axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};
	                  end
	              default: //reserved (incremental burst for example)
	                begin
	                  axi_awaddr <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                  //for awsize = 4 bytes (010)
	                end
	             endcase
	           end
	         end
	     end
	//This always block handles the read address increment
	 always @(posedge S_AXI_ACLK)
	   begin
	     if (S_AXI_ARESETN == 1'b0)
	       begin
	        //both axi_arlen_cntr and axi_araddr will increment after each successfull data sent until the number of the transfers is equal to burst length
	        axi_arlen_cntr <= 0;
	        axi_araddr <= 0;
	      end
	    else
	      begin
	        if (S_AXI_ARVALID && axi_arready)
	          begin
	            axi_arlen_cntr <= 0;
	            axi_araddr <= S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH - 1:0];
	          end
	        else if((axi_arlen_cntr <= axi_arlen) && axi_rvalid && S_AXI_RREADY)
	          begin
	            axi_arlen_cntr <= axi_arlen_cntr + 1;
	            case (axi_arburst)
	               2'b00: // fixed burst
	                // The read address for all the beats in the transaction are fixed
	                 begin
	                   axi_araddr       <= axi_araddr;
	                   //for arsize = 4 bytes (010)
	                 end
	               2'b01: //incremental burst
	                // The read address for all the beats in the transaction are increments by awsize
	                 begin
	                   axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                   //araddr aligned to 4 byte boundary
	                   axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};
	                   //for awsize = 4 bytes (010)
	                 end
	               2'b10: //Wrapping burst
	                // The read address wraps when the address reaches wrap boundary
	                 if (ar_wrap_en)
	                   begin
	                     axi_araddr <= (axi_araddr - ar_wrap_size);
	                   end
	                 else
	                   begin
	                     axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                     //araddr aligned to 4 byte boundary
	                     axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};
	                   end
	               default: //reserved (incremental burst for example)
	                 begin
	                   axi_araddr <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB]+1;
	                   //for arsize = 4 bytes (010)
	                 end
	             endcase
	           end
	       end
	   end
	//-- ------------------------------------------
	//-- -- Example code to access user logic memory region
	//-- ------------------------------------------
/* ==================================================================== */
/* =======================  用户逻辑开始 ============================== */
/* ==================================================================== */

localparam [7:0] CTRL_ADDR   = 8'h00;
localparam [7:0] DATA_A_BASE = 8'h10;
localparam [7:0] DATA_B_BASE = 8'h20;
localparam [7:0] RESULT_BASE = 8'h30;

/* --------------------------- 寄存器 --------------------------------- */
reg  [7:0] ctrl_reg;          // bit7=start(写) bit6=busy(只读)
reg  [7:0] vec_a [0:15];
reg  [7:0] vec_b [0:15];
reg  [7:0] vec_r [0:15];
reg        busy;
reg        start_d;

/* --------------------------- 写通路 --------------------------------- */
wire       w_hs   = axi_wready && S_AXI_WVALID;
wire [7:0] w_addr = S_AXI_AWVALID ? S_AXI_AWADDR[7:0] : axi_awaddr[7:0];

/* ctrl_reg・vec_a・vec_b 统一在一个 always 驱动 ----------------------- */
always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        ctrl_reg <= 8'h00;
        for (int i=0; i<16; i++) begin
            vec_a[i] <= '0;
            vec_b[i] <= '0;
        end
    end
    else begin
        /* ---------------- busy / start 位维护 ---------------------- */
        start_d <= ctrl_reg[7];              // 记录上一拍
        busy    <=  ctrl_reg[7] & ~start_d;  // busy 维持 1clk，可自行拉长
        ctrl_reg[6] <= busy;                 // busy 只读位

        /* ---------------- RC 写 start 位 (具有更高优先级) -------------------------- */
        if (w_hs && w_addr==CTRL_ADDR && S_AXI_WSTRB[0]) begin
            ctrl_reg[7] <= S_AXI_WDATA[7];
        end
        // 否则，当计算不“忙”时，自动清零start位
        else if (!busy) begin
            ctrl_reg[7] <= 1'b0;
        end

        /* ---------------- 写向量 A -------------------------------- */
        if (w_hs && w_addr>=DATA_A_BASE && w_addr<DATA_A_BASE+8'd16) begin
            int base;
            base = w_addr - DATA_A_BASE;
            for (int b=0; b<4; b++)
                if (S_AXI_WSTRB[b] && (base+b)<16)
                    vec_a[base+b] <= S_AXI_WDATA[8*b +:8];
        end

        /* ---------------- 写向量 B -------------------------------- */
        if (w_hs && w_addr>=DATA_B_BASE && w_addr<DATA_B_BASE+8'd16) begin
            int base;
            base = w_addr - DATA_B_BASE;
            for (int b=0; b<4; b++)
                if (S_AXI_WSTRB[b] && (base+b)<16)
                    vec_b[base+b] <= S_AXI_WDATA[8*b +:8];
        end
    end
end

/* --------------------------- 计算逻辑 ------------------------------ */
always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        for (int i=0;i<16;i++) vec_r[i] <= '0;
    end
    else if (ctrl_reg[7] & ~start_d) begin  // start 上升沿
        for (int i=0;i<16;i++) vec_r[i] <= vec_a[i] + vec_b[i]; // 低8位自然截断
    end
end

/* ----------------------------- 读通路 ------------------------------ */
wire [7:0]  r_addr = axi_araddr[7:0];
reg  [31:0] r_data;

always @(*) begin
    r_data = 32'h0;
    if (r_addr == CTRL_ADDR) begin
        r_data[7:0] = {ctrl_reg[7], ctrl_reg[6], 6'b0};
    end
    else if (r_addr >= DATA_A_BASE   && r_addr < DATA_A_BASE+8'd16) begin
        int base;
        base = r_addr - DATA_A_BASE;
        for (int b=0;b<4;b++) if (base+b<16) r_data[8*b +:8] = vec_a[base+b];
    end
    else if (r_addr >= DATA_B_BASE   && r_addr < DATA_B_BASE+8'd16) begin
        int base;
        base = r_addr - DATA_B_BASE;
        for (int b=0;b<4;b++) if (base+b<16) r_data[8*b +:8] = vec_b[base+b];
    end
    else if (r_addr >= RESULT_BASE   && r_addr < RESULT_BASE+8'd16) begin
        int base;
        base = r_addr - RESULT_BASE;
        for (int b=0;b<4;b++) if (base+b<16) r_data[8*b +:8] = vec_r[base+b];
    end
end

assign S_AXI_RDATA = r_data;

/* ==================================================================== */
/* =======================  用户逻辑结束 ============================== */
/* ==================================================================== */


	// Add user logic here



 	// User logic ends


	// Add user logic here

	// User logic ends

	endmodule

`endif  // PCIE_EP_SV