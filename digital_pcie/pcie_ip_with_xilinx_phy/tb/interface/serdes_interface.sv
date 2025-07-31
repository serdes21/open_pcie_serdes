// --------------------------------------------
// serdes_interface.sv
// 通用 SERDES 物理层引脚封装（PCIe PIPE/SerDes 版）
// --------------------------------------------
interface serdes_interface #(
  parameter int NL = 1       // 物理 Lane 数；和 DUT/VIP 保持一致
)();

  // -------- 可综合信号 --------
  logic [NL-1:0] rxp;        // 物理接收差分 +
  logic [NL-1:0] rxn;        // 物理接收差分 –
  logic [NL-1:0] txp;        // 物理发送差分 +
  logic [NL-1:0] txn;        // 物理发送差分 –
  logic [NL-1:0] rxpresent;  // 对端检测（通常由 PHY 上拉）

  // -------- Modports --------
  // DUT 看到的方向：rx 为输入；tx 为输出
  modport dut (
    input  rxp, rxn, rxpresent,
    output txp, txn
  );

  // VIP 作为“对端”看到的方向正好相反
  modport vip (
    output rxp, rxn, rxpresent,
    input  txp, txn
  );

endinterface