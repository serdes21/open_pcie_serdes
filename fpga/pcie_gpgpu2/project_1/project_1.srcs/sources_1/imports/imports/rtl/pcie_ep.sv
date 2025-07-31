`timescale 1ns/1ps
`ifndef PCIE_EP_SV
`define PCIE_EP_SV





module pcie_ep #(
  parameter int NL = 1,     // lane count (test-bench中为 1)
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

  input  wire [NL-1:0]            rxp,
  input  wire [NL-1:0]            rxn,
  output wire [NL-1:0]            txp,
  output wire [NL-1:0]            txn,

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

  // 未导出的"低功耗"/"misc"信号用哑线吸收
  wire         unused_mstr_csysack, unused_mstr_cactive;
  wire         unused_slv_csysack,  unused_slv_cactive;

  // 打包成一条 AXI4 总线：PCIe-EP 作为 Master，转换器作为 Slave
  //------------------------------------------------------------------
  AXI_BUS #(
    .AXI_ADDR_WIDTH ( MSTR_ADDR_WD  ),
    .AXI_DATA_WIDTH ( MSTR_DATA_WD  ),
    .AXI_ID_WIDTH   ( MSTR_ID_WD    ),
    .AXI_USER_WIDTH ( 1             )   // 无 user，可占位 1
  ) m_axi ();

// ----------------------------------------------------------------------------
// Default-drive optional AXI side-band that the PCIe IP 不关心
// ----------------------------------------------------------------------------
assign m_axi.aw_region = 4'd0;
assign m_axi.ar_region = 4'd0;

// USER 信号因为 AXI_CHANNEL 不同，最好全部置 0
assign m_axi.aw_user = '0;
assign m_axi.w_user  = '0;
assign m_axi.aw_atop = '0;

  // AXI clock/reset for master path (use auxclk for simplicity)
  wire auxclk;                  // 由 core 输出，仅低功耗模式使用
  wire core_clk;                // 从 u_pcie_iip_device 引出的 125MHz PCLK
  wire axi_clk        = core_clk;
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

    // 串行收发
    .rxp                       (rxp),
    .rxn                       (rxn),
    .txp                       (txp),
    .txn                       (txn),
    .rxpresent                 (1'b1),


    // 参考时钟
    .refclk_p                  (refclk_p),
    .refclk_n                  (refclk_n),

    .core_clk                (core_clk),

    // 其余输入全部 tie-off
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
    .mstr_awid                 (m_axi.aw_id     ),
    .mstr_awvalid              (m_axi.aw_valid  ),
    .mstr_awaddr               (m_axi.aw_addr   ),
    .mstr_awlen                (m_axi.aw_len    ),
    .mstr_awsize               (m_axi.aw_size   ),
    .mstr_awburst              (m_axi.aw_burst  ),
    .mstr_awlock               (m_axi.aw_lock   ),
    .mstr_awcache              (m_axi.aw_cache  ),
    .mstr_awprot               (m_axi.aw_prot   ),
    .mstr_awqos                (m_axi.aw_qos ),
    .mstr_awmisc_info          (    ),
    .mstr_awready              (m_axi.aw_ready  ),

    .mstr_wvalid               (m_axi.w_valid   ),
    .mstr_wlast                (m_axi.w_last    ),
    .mstr_wdata                (m_axi.w_data    ),
    .mstr_wstrb                (m_axi.w_strb    ),
    .mstr_wready               (m_axi.w_ready   ),

    .mstr_bid                  (m_axi.b_id      ),
    .mstr_bvalid               (m_axi.b_valid   ),
    .mstr_bresp                (m_axi.b_resp    ),
    .mstr_bready               (m_axi.b_ready   ),
    .mstr_bmisc_info_cpl_stat  (V0_CPL_STAT     ),

    .mstr_arid                 (m_axi.ar_id     ),
    .mstr_arvalid              (m_axi.ar_valid  ),
    .mstr_araddr               (m_axi.ar_addr   ),
    .mstr_arlen                (m_axi.ar_len    ),
    .mstr_arsize               (m_axi.ar_size   ),
    .mstr_arburst              (m_axi.ar_burst  ),
    .mstr_arlock               (m_axi.ar_lock   ),
    .mstr_arcache              (m_axi.ar_cache    ),
    .mstr_arprot               (m_axi.ar_prot   ),
    .mstr_arqos                (m_axi.ar_qos     ),
    .mstr_armisc_info          (    ),
    .mstr_arready              (m_axi.ar_ready  ),

    .mstr_rid                  (m_axi.r_id      ),
    .mstr_rvalid               (m_axi.r_valid   ),
    .mstr_rlast                (m_axi.r_last    ),
    .mstr_rdata                (m_axi.r_data    ),
    .mstr_rresp                (m_axi.r_resp    ),
    .mstr_rready               (m_axi.r_ready   ),
    .mstr_rmisc_info           (V0_MSTR_RESP_MISC),
    .mstr_rmisc_info_cpl_stat  (V0_CPL_STAT     ),

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


// 32-bit AXI-Lite 总线（16 位地址即可覆盖 64 B 的寄存器空间）
AXI_LITE #(
  .AXI_ADDR_WIDTH (32),
  .AXI_DATA_WIDTH (32)
) axi_lite_m ();

  // ① AXI-Full → AXI-Lite
axi_to_axi_lite_intf #(
    .AXI_ADDR_WIDTH     ( MSTR_ADDR_WD  ),
    .AXI_DATA_WIDTH     ( MSTR_DATA_WD  ),
    .AXI_ID_WIDTH       ( MSTR_ID_WD    ),
    .AXI_USER_WIDTH     ( 1             ),   // 无 user 信号可设 1
    .AXI_MAX_WRITE_TXNS ( 8             ),
    .AXI_MAX_READ_TXNS  ( 8             )
) i_axi2lite (
    .clk_i       ( axi_clk ),
    .rst_ni      ( mstr_aresetn ),
    .testmode_i  ( 1'b0 ),
    .slv         ( m_axi ),
    .mst         ( axi_lite_m.Master )            // AXI-Lite master 信号
);

// ② 寄存器 + 计算单元（AXI-Lite 从机）
vec8x16_add_regs_intf #(
    .AXI_ADDR_WIDTH ( 32 ),   //
    .AXI_DATA_WIDTH ( 32 )
) i_vec_add (
    .clk_i ( axi_clk ),
    .rst_ni( mstr_aresetn ),
    .slv   ( axi_lite_m.Slave )     // 与转换器 master 直连
);


endmodule : pcie_ep



module vec8x16_add_regs_intf #(
  parameter int unsigned AXI_ADDR_WIDTH = 32,   // ≥ 6bit 即可覆盖 64B
  parameter int unsigned AXI_DATA_WIDTH = 32
)(
  input  logic clk_i,
  input  logic rst_ni,
  AXI_LITE.Slave slv          // AXI-Lite slave 端口（来自 axi_to_axi_lite_intf）
);

  // -------------------------------------------------------------------------
  // 参数与常量
  // -------------------------------------------------------------------------
  localparam int unsigned REG_NUM_BYTES = 64;   // 0x00  ~ 0x3F
  localparam int unsigned VEC_LEN       = 16;   // 16 × 8bit

  // 地址映射（与旧版本保持一致，便于软件无缝迁移）
  localparam int unsigned CTRL_OFF   = 'h00;          // [7]=start(W) [6]=busy(R)
  localparam int unsigned A_OFF      = 'h10;          // A[0] … A[15]
  localparam int unsigned B_OFF      = 'h20;          // B[0] … B[15]
  localparam int unsigned R_OFF      = 'h30;          // Result[0] … Result[15]

  // -------------------------------------------------------------------------
  // ①  AXI-Lite ⇄ 寄存器阵列：实例化开源通用模块 axi_lite_regs_intf
  // -------------------------------------------------------------------------
  // - A/B/CTRL 区域可写；Result 区域只读
  // - busy 位由硬件写；start 位由软件写
  // - 结果写回通过 reg_load_i 脉冲完成；无需软件关心
  // -------------------------------------------------------------------------
  typedef logic [7:0] byte_t;

  // 实际寄存器存储
  byte_t [REG_NUM_BYTES-1:0] reg_d_i;
  byte_t [REG_NUM_BYTES-1:0] reg_q;
  logic  [REG_NUM_BYTES-1:0] reg_load;
  logic  wr_act, rd_act;    // 未用，可留给调试

  axi_lite_regs_intf #(
    .byte_t          ( byte_t           ),
    .REG_NUM_BYTES   ( REG_NUM_BYTES    ),
    .AXI_ADDR_WIDTH  ( AXI_ADDR_WIDTH   ),
    .AXI_DATA_WIDTH  ( AXI_DATA_WIDTH   )
  ) i_regs (
    .clk_i   ( clk_i  ),
    .rst_ni  ( rst_ni ),
    .slv     ( slv    ),
    .wr_active_o ( /* 未用 */ ),
    .rd_active_o ( /* 未用 */ ),
    .reg_d_i     ( reg_d_i  ),
    .reg_load_i  ( reg_load ),
    .reg_q_o     ( reg_q    )
  );

  // -------------------------------------------------------------------------
  // ② 计算状态机：发现 start=1 → busy=1 → 1 个时钟周期完成加法 → busy=0
  // -------------------------------------------------------------------------
  typedef enum logic {IDLE, BUSY} state_e;
  state_e state_q, state_d;

  // 将数组 A/B/R 从寄存器视图映射到易读的向量
  byte_t vec_a [VEC_LEN-1:0];
  byte_t vec_b [VEC_LEN-1:0];

  // combinational read
  always_comb begin
    for (int i=0;i<VEC_LEN;++i) begin
      vec_a[i] = reg_q[A_OFF+i];
      vec_b[i] = reg_q[B_OFF+i];
    end
  end

  // next-state & write-back logic
  always_comb begin
    // 默认：不写任何寄存器
    for (int i=0;i<REG_NUM_BYTES;++i) begin
      reg_load[i] = 1'b0;
      reg_d_i [i] = '0;
    end
    state_d = state_q;

    // busy 位（CTRL[6]）缺省为 0
    reg_d_i[CTRL_OFF] = reg_q[CTRL_OFF] & 8'h80; // 仅保留 start 位
    // 当 state=BUSY 时硬件置 busy=1
    if (state_q == BUSY)
      reg_d_i[CTRL_OFF][6] = 1'b1;

    // ---------------- FSM 行为 ----------------
    unique case (state_q)

      IDLE: begin
        // 软件把 CTRL[7] 写 1 → 启动
        if (reg_q[CTRL_OFF][7]) begin
          state_d           = BUSY;
          reg_d_i[CTRL_OFF] = 8'h40;   // busy=1,start=0  (写回)
          reg_load[CTRL_OFF]= 1'b1;
        end
      end

      BUSY: begin
        // 当帧尾一个周期完成所有加法
        for (int i=0;i<VEC_LEN;++i) begin
          reg_d_i[R_OFF+i]   = vec_a[i] + vec_b[i];
          reg_load [R_OFF+i] = 1'b1;          // 把结果写到只读寄存器
        end
        // busy 清零
        reg_d_i[CTRL_OFF]  = 8'h00;
        reg_load[CTRL_OFF] = 1'b1;
        state_d            = IDLE;
      end

    endcase
  end

  // 状态寄存
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) state_q <= IDLE;
    else         state_q <= state_d;
  end

endmodule

`endif  // PCIE_EP_SV