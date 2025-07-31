//---------------------------------------------------------
// LTSSM 使能定时器（仅依赖 PERST#）
//---------------------------------------------------------
module ltssm_en_gen #
(
  parameter integer DELAY_CYCLES = 12_500
)
(
  input  wire pclk,          // 125 MHz PIPE 时钟（来自 Xilinx PHY）
  input  wire perst_n,       // 外部 PERST#，低有效
  output reg  app_ltssm_enable
);

  // 计数器位宽
  localparam W = $clog2(DELAY_CYCLES);
  reg [W-1:0] cnt;

  // 双触发器同步 PERST#（防亚稳）
  reg perst_sync1, perst_sync2;
  always @(posedge pclk or negedge perst_n) begin
    if (!perst_n) begin
      perst_sync1 <= 1'b0;
      perst_sync2 <= 1'b0;
    end else begin
      perst_sync1 <= 1'b1;
      perst_sync2 <= perst_sync1;
    end
  end

  // 延时计数 & 产生 app_ltssm_enable
  always @(posedge pclk or negedge perst_n) begin
    if (!perst_n) begin
      cnt               <= {W{1'b0}};
      app_ltssm_enable  <= 1'b0;
    end else if (!perst_sync2) begin     // PERST# 尚未完全同步到时钟域
      cnt               <= {W{1'b0}};
      app_ltssm_enable  <= 1'b0;
    end else if (cnt < DELAY_CYCLES-1) begin
      cnt               <= cnt + 1'b1;
      app_ltssm_enable  <= 1'b0;
    end else begin
      app_ltssm_enable  <= 1'b1;        // 计满后 LTSSM 使能
    end
  end

endmodule