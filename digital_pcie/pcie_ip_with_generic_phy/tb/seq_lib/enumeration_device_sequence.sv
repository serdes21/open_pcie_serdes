`ifndef ENUMERATION_DEVICE_SEQUENCE_SV
`define ENUMERATION_DEVICE_SEQUENCE_SV


class enumeration_device_sequence extends uvm_sequence;

    `uvm_object_utils(enumeration_device_sequence)

    `uvm_declare_p_sequencer(pcie_virtual_sequencer)

    bit [7:0] bus_num = 0;

    extern function new(string name="enumeration_device_sequence");
    extern task body();

    extern task cfg_reg_write(input bit [11:0] addr, input bit [31:0] wdata);
    extern task cfg_reg_read(input bit [11:0] addr, output bit [31:0] rdata);

    extern task get_pci_capability_base_addr(input PCI_CAP_ID cap_id, output bit [11:0] cap_base_addr);
    extern task get_pcie_extended_capability_base_addr(input PCIE_EXT_CAP_ID cap_id, output bit [11:0] cap_base_addr);

    extern task get_bar_size(input bit [2:0] bar_index, output bit bar_64bit_point, output bit [63:0] bar_size);
    extern task get_bar_addr(input bit [2:0] bar_index, output bit bar_64bit_point, output bit [63:0] bar_addr);

    extern task pcie_bar_cfg(output bar_info_str bar_info[6]);

    extern task enumeration_device();
endclass

function enumeration_device_sequence :: new(string name="enumeration_device_sequence");
    super.new(name);
endfunction

task enumeration_device_sequence::cfg_reg_write
  (input bit [11:0] addr, input bit [31:0] wdata);

   svt_pcie_driver_app_cfg_request_sequence cfg_request_seq;

   assert(addr[1:0] == 2'b00)
     else `uvm_error("cfg_reg_write", $sformatf("unaligned addr 0x%0h", addr));

   cfg_request_seq = svt_pcie_driver_app_cfg_request_sequence
                     ::type_id::create("cfg_request_seq");

   cfg_request_seq.bdf             = {bus_num,5'h0,3'h0};
   cfg_request_seq.register_number = addr[11:2];
   cfg_request_seq.first_dw_be     = 4'hF;
   cfg_request_seq.cfg_type        = 0;
   cfg_request_seq.payload         = wdata;
   cfg_request_seq.block           = 1;
   cfg_request_seq.transaction_type=
        svt_pcie_driver_app_transaction::CFG_WR;

   cfg_request_seq.start
        (p_sequencer.root_vir_sqr.driver_transaction_seqr[0]);

   `uvm_info("cfg_reg_write",
             $sformatf("addr:0x%0h data:0x%0h", addr, wdata), UVM_LOW)
endtask

task enumeration_device_sequence::cfg_reg_read(input bit [11:0] addr, output bit [31:0] rdata);

    svt_pcie_driver_app_cfg_request_sequence cfg_request_seq;

    assert(addr[1:0] == 2'b00)
      else `uvm_error("cfg_reg_read", $sformatf("addr not aligned: 0x%0h", addr));

    cfg_request_seq = svt_pcie_driver_app_cfg_request_sequence::type_id::create("cfg_request_seq");

    cfg_request_seq.bdf              = {bus_num, 5'h0, 3'h0}; // bus 0/dev 0/fn 0
    cfg_request_seq.register_number  = addr[11:2];
    cfg_request_seq.first_dw_be      = 4'b1111;
    cfg_request_seq.cfg_type         = 0;      // type-0
    cfg_request_seq.block            = 1;      // 等待 CplD
    cfg_request_seq.transaction_type = svt_pcie_driver_app_transaction::CFG_RD;

    cfg_request_seq.start(p_sequencer.root_vir_sqr.driver_transaction_seqr[0]);

    rdata = cfg_request_seq.req.payload[0];

    `uvm_info("cfg_reg_read", $sformatf("addr:0x%0h, data:0x%0h", addr, rdata), UVM_LOW)
endtask


task enumeration_device_sequence :: body();

    enumeration_device();

endtask

task enumeration_device_sequence :: get_pci_capability_base_addr(input PCI_CAP_ID cap_id, output bit [11:0] cap_base_addr);
    bit [31:0] data;
    bit [7:0] cap_pointer;
    bit [7:0] get_cap_id;

    cfg_reg_read(`PCI_CAP_PTR_REG, data);
    cap_pointer = data[7:0];

    while(1) begin
        cfg_reg_read(cap_pointer, data);
        get_cap_id = data[7:0];
        if(get_cap_id == cap_id) begin
            cap_base_addr = cap_pointer;
            `uvm_info("get_pci_capability_base_addr", $sformatf("get_cap_id:%s, base_addr:0x%0h", cap_id.name(), cap_pointer), UVM_LOW)
            break ;
        end
        cap_pointer = data[15:8];
        if(cap_pointer == 0)begin
            `uvm_error("get_pci_capability_base_addr", $sformatf("not get cap_id:0x%0h", cap_id))
            break ;
        end
    end


endtask


task enumeration_device_sequence :: get_pcie_extended_capability_base_addr(input PCIE_EXT_CAP_ID cap_id, output bit [11:0] cap_base_addr);
    bit [31:0] data;
    bit [7:0] cap_pointer;
    bit [15:0] get_cap_id;

    cfg_reg_read(`PCI_CAP_PTR_REG, data);
    cap_pointer = data[31:20];

    while(1) begin
        cfg_reg_read(cap_pointer, data);
        get_cap_id = data[15:0];
        if(get_cap_id == cap_id) begin
            cap_base_addr = cap_pointer;
            `uvm_info("get_pcie_extended_capability_base_addr", $sformatf("get_cap_id:%s, base_addr:0x%0h", cap_id.name(), cap_pointer), UVM_LOW)
            break ;
        end
        cap_pointer = data[31:20];
        if(cap_pointer == 0)begin
            `uvm_error("get_pcie_extended_capability_base_addr", $sformatf("not get cap_id:0x%0h", cap_id))
            break ;
        end
    end


endtask



//------------------------------------------------------------------------------
//  根据 bar_index 探测 BAR 类型及大小
//    • bar_index    : 0 ~ 5
//    • bar_64bit_pt : 1 = 64-bit BAR，0 = 32-bit BAR
//    • bar_size     : 返回字节数
//------------------------------------------------------------------------------
task enumeration_device_sequence :: get_bar_size
(
    input  bit [2:0] bar_index,
    output bit       bar_64bit_point,
    output bit [63:0] bar_size
);
    bit [31:0] data_lo, data_hi;     // 读 BAR低/高 32-bit
    bit [63:0] mask64;               // 写1读回后的掩码
    bit [11:0] bar_reg_lo_addr;      // BARn  低32-bit寄存器地址
    bit [11:0] bar_reg_hi_addr;      // BARn+1高32-bit寄存器地址

    // ---------------- ① BAR 寄存器地址计算 ----------------
    // type-0 header 下 BAR0 地址为 0x10，每个 BAR 占 4 Bytes
    bar_reg_lo_addr = `BAR0_REG + (bar_index * 4);
    bar_reg_hi_addr = bar_reg_lo_addr + 4;

    // ---------------- ② 读取 BAR 判定类型 -----------------
    cfg_reg_read(bar_reg_lo_addr, data_lo);

    // 若为 I/O BAR（data_lo[0]==1）此处简单报 Warning；如需支持可再扩展
    if (data_lo[0]) begin
        bar_64bit_point = 0;
        bar_size        = 0;
        `uvm_warning("get_bar_size",
                     $sformatf("BAR%0d is I/O BAR, size detection skipped",
                               bar_index));
        return;
    end

    case (data_lo[2:1])          // 00 = 32-bit Mem，10 = 64-bit Mem
        2'b00 : bar_64bit_point = 0;
        2'b10 : bar_64bit_point = 1;
        default : begin
            `uvm_error("get_bar_size",
                       $sformatf("BAR%0d reports reserved type", bar_index));
            bar_size = 0;
            return;
        end
    endcase

    // ---------------- ③ 写全 1 探测大小 -------------------
    if (bar_64bit_point) begin
        // 写 all-1
        cfg_reg_write(bar_reg_lo_addr, 32'hffff_ffff);
        cfg_reg_write(bar_reg_hi_addr, 32'hffff_ffff);

        // 读回
        cfg_reg_read(bar_reg_lo_addr, data_lo);
        cfg_reg_read(bar_reg_hi_addr, data_hi);

        // 屏蔽低 4bit（Memory BAR）后取 size
        mask64   = {data_hi, data_lo} & 64'hffff_ffff_ffff_f000;
        bar_size = mask64 & (~mask64 + 64'd1);

        // 复原 0
        cfg_reg_write(bar_reg_lo_addr, 32'h0);
        cfg_reg_write(bar_reg_hi_addr, 32'h0);
    end
    else begin
        cfg_reg_write(bar_reg_lo_addr, 32'hffff_ffff);
        cfg_reg_read (bar_reg_lo_addr, data_lo);

        mask64   = {32'd0, (data_lo & 32'hffff_fff0)};
        bar_size = mask64 & (~mask64 + 64'd1);

        cfg_reg_write(bar_reg_lo_addr, 32'h0);
    end

    // ---------------- ④ 日志 ------------------------------
    `uvm_info("get_bar_size",
              $sformatf("BAR%0d is %0s-bit Memory BAR, size = 0x%0h (%0d KiB)",
                        bar_index,
                        bar_64bit_point ? "64" : "32",
                        bar_size, bar_size>>10),
              UVM_LOW)
endtask


//------------------------------------------------------------------------------
//  读取 BAR 基地址（已分配完成后调用）
//    • bar_index       : 0 ~ 5
//    • bar_64bit_point : 1 = 64-bit Memory BAR；0 = 32-bit Memory / I/O BAR
//    • bar_addr        : 返回 BAR 对应的 *PCIe/系统物理地址*
//
//  说明：
//    - 枚举阶段 RC 会把分配好的基地址写入 BAR。本任务仅负责读回并解析。
//    - 若为 I/O BAR，本例简单返回掩掉低 2 位的地址并给出提示。
//------------------------------------------------------------------------------
task enumeration_device_sequence::get_bar_addr
(
    input  bit [2:0]  bar_index,
    output bit        bar_64bit_point,
    output bit [63:0] bar_addr
);
    bit [31:0] data_lo, data_hi;        // BAR 低 / 高 32-bit
    bit [11:0] bar_reg_lo_addr;         // BARn 低 32-bit 配置空间地址
    bit [11:0] bar_reg_hi_addr;         // (仅 64-bit) BARn+1 高 32-bit 地址

    // ---------------- ① 计算 BAR 寄存器地址 ----------------
    bar_reg_lo_addr = `BAR0_REG + (bar_index * 4);
    bar_reg_hi_addr = bar_reg_lo_addr + 4;

    // ---------------- ② 读取 BAR 判定类型 ------------------
    cfg_reg_read(bar_reg_lo_addr, data_lo);

    // ——— I/O BAR -----------------------------------------------------------
    if (data_lo[0]) begin
        bar_64bit_point = 0;
        bar_addr        = {32'd0, (data_lo & 32'hffff_fffc)};   // 屏蔽低 2 位

        `uvm_warning("get_bar_addr",
            $sformatf("BAR%0d is I/O BAR, addr = 0x%0h",
                      bar_index, bar_addr));
        return;
    end

    // ——— Memory BAR --------------------------------------------------------
    unique case (data_lo[2:1])           // 00=32-bit，10=64-bit
        2'b00: begin                     // ---- 32-bit Memory BAR
            bar_64bit_point = 0;
            bar_addr        = {32'd0, (data_lo & 32'hffff_fff0)}; // 屏蔽低 4 位
        end

        2'b10: begin                     // ---- 64-bit Memory BAR
            bar_64bit_point = 1;
            cfg_reg_read(bar_reg_hi_addr, data_hi);

            bar_addr = ({data_hi, data_lo} & 64'hffff_ffff_ffff_f000);
        end

        default: begin                   // ---- 保留类型，报错退出
            bar_64bit_point = 0;
            bar_addr        = 64'd0;

            `uvm_error("get_bar_addr",
                $sformatf("BAR%0d reports reserved type (bits[2:1]=%2b)",
                          bar_index, data_lo[2:1]));
            return;
        end
    endcase

    // ---------------- ③ 打印日志 -------------------------------------------
    `uvm_info("get_bar_addr",
        $sformatf("BAR%0d %0s-bit Memory BAR, addr = 0x%0h",
                  bar_index,
                  bar_64bit_point ? "64" : "32",
                  bar_addr),
        UVM_LOW);
endtask


//------------------------------------------------------------------------------
//  BAR 配置封装 —— 依次探测 6 个 BAR，分配地址并返回信息
//------------------------------------------------------------------------------
task enumeration_device_sequence :: pcie_bar_cfg(output bar_info_str bar_info[6]);
    bit        bar_is_64;          // get_bar_size()  返回：BAR 是否为 64-bit
    bit [63:0] bar_size;           // get_bar_size()  返回：BAR 大小

    bit        addr_is_64;         // get_bar_addr()  返回：BAR 是否为 64-bit
    bit [63:0] bar_addr;           // get_bar_addr()  返回：BAR 基地址

    bit [63:0] next_free_addr;     // RC 侧后续可用的起始地址
    int        i;                  // BAR 索引

    //--------------------------------------------------------------------------
    // ① 初始化输出结构体 & 地址池
    //--------------------------------------------------------------------------
    foreach (bar_info[idx]) begin
        bar_info[idx].enable   = 0;
        bar_info[idx].bar_type = BAR_32BIT;
        bar_info[idx].bar_addr = 64'd0;
        bar_info[idx].bar_size = 64'd0;
    end
    next_free_addr = `BAR0_START_ADDR;

    //--------------------------------------------------------------------------
    // ② 逐个 BAR 探测 &rarr; 分配 &rarr; 读取回显 &rarr; 保存结果
    //--------------------------------------------------------------------------
    for (i = 0; i < 6; i++) begin
        //----------------------------------------------------------------------
        // ②-1 探测 BAR 类型 & 大小
        //----------------------------------------------------------------------
        get_bar_size(i[2:0], bar_is_64, bar_size);

        // size == 0 表示该 BAR 未实现，直接跳过
        if (bar_size == 0) begin
            continue;
        end

        //----------------------------------------------------------------------
        // ②-2 地址分配（按 size 对齐）
        //----------------------------------------------------------------------
        next_free_addr = (next_free_addr + bar_size - 1) & ~(bar_size - 1);

        // 写低 32-bit
        cfg_reg_write(`BAR0_REG + (i*4), next_free_addr[31:0]);

        // 若为 64-bit BAR，还需写高 32-bit，占用两个 BAR 槽
        if (bar_is_64) begin
            cfg_reg_write(`BAR0_REG + ((i+1)*4), next_free_addr[63:32]);
        end

        //----------------------------------------------------------------------
        // ②-3 读取确认
        //----------------------------------------------------------------------
        get_bar_addr(i[2:0], addr_is_64, bar_addr);

        //----------------------------------------------------------------------
        // ②-4 填充输出结构体
        //----------------------------------------------------------------------
        bar_info[i].enable    = 1;
        bar_info[i].bar_type  = bar_is_64 ? BAR_64BIT : BAR_32BIT;
        bar_info[i].bar_addr  = bar_addr;
        bar_info[i].bar_size  = bar_size;

        // 更新下一可用地址
        next_free_addr = next_free_addr + bar_size;

        // 64-bit BAR 占用两条寄存器，跳过高 DW
        if (bar_is_64 && (i < 5)) begin
            bar_info[i+1].enable   = 0;    // 标记高 DW 为空占位
            i++;                          // for-loop 额外跳过
        end
    end

    //--------------------------------------------------------------------------
    // ③ 打印汇总日志
    //--------------------------------------------------------------------------
    for (i = 0; i < 6; i++) begin
        if (bar_info[i].enable) begin
            `uvm_info("pcie_bar_cfg",
                      $sformatf("BAR%0d: %2s-bit, addr = 0x%0h, size = 0x%0h (%0d KiB)",
                                i,
                                (bar_info[i].bar_type == BAR_64BIT) ? "64" : "32",
                                bar_info[i].bar_addr,
                                bar_info[i].bar_size,
                                bar_info[i].bar_size >> 10),
                      UVM_LOW)
        end
        else begin
            `uvm_info("pcie_bar_cfg",
                      $sformatf("BAR%0d: unused / upper DW", i),
                      UVM_LOW)
        end
    end
endtask




//------------------------------------------------------------------------------
// enumeration_device : 确认 type-0 / single-function / PCIe-EP
//------------------------------------------------------------------------------
task enumeration_device_sequence::enumeration_device();
    bit [31:0] data;
    bit [11:0] cap_addr;
    bit [3:0]  port_type;
    bar_info_str bar_info[6];

    //----------------------------------------------------------------------
    // ① 读取 VendorID/DeviceID（可选，便于日志查看）
    //----------------------------------------------------------------------
    cfg_reg_read(`DEVICE_ID_VENDOR_ID_REG, data);
    `uvm_info("enumeration_device",
              $sformatf("DEVICE_ID_VENDOR_ID_REG = 0x%08h", data), UVM_LOW)

    //----------------------------------------------------------------------
    // ② Header Type 与 Multi-Function 判断
    //    地址 0x0C: [23] Multifunction, [22:16] Header Type
    //----------------------------------------------------------------------
    cfg_reg_read(`BIST_HEADER_TYPE_LATENCY_CACHE_LINE_SIZE_REG, data);

    // 2-1) Header Type == 0 &rarr; type-0
    if (data[22:16] != 5'h0) begin
        `uvm_error("enumeration_device",
                   $sformatf("header type error (expect 0, got 0x%0h)",
                             data[22:16]));
        return;
    end
    else begin
        `uvm_info("enumeration_device",
                  "device header type-0 confirmed", UVM_LOW);
    end

    // 2-2) Multi-function 位必须为 0 &rarr; single-function
    if (data[23]) begin
        `uvm_error("enumeration_device",
                   "device reports multi-function, expect single-function");
        return;
    end
    else begin
        `uvm_info("enumeration_device",
                  "device is single-function", UVM_LOW);
    end

    //----------------------------------------------------------------------
    // ③ PCIe Capability 检测：确认为 PCIe 端点
    //    • 先通过链表找到 PCIe Capability 基址
    //    • Port Type 位于 (base + 0x02)[7:4]
    //      0 = Endpoint，其它值 = Root Port / Switch / etc.
    //----------------------------------------------------------------------
    get_pci_capability_base_addr(PCIE_CAP_ID, cap_addr);

    cfg_reg_read(cap_addr, data);   // 读取 16-bit PCIe Capabilities Reg
    port_type = data[23:20];

    if (port_type == 4'h0) begin
        `uvm_info("enumeration_device",
                  "device port type = PCIe Endpoint (0x0)", UVM_LOW);
    end
    else begin
        `uvm_error("enumeration_device",
                   $sformatf("device port type 0x%0h; NOT endpoint", port_type));
    end


    pcie_bar_cfg(bar_info);

    cfg_reg_read(cap_addr + `DEVICE_CAPABILITIES_REG, data);
    `uvm_info("enumeration_device_sequence", $sformatf("max_payload_size_support:max_%0dB_SIZE", (1 << data[2:0]) * 128), UVM_LOW)
    cfg_reg_read(cap_addr + `DEVICE_CONTROL_DEVICE_STATUS, data);
    data[7:5] = 1;  //max payload size
    data[14:12] = 1; // max read request size
    cfg_reg_write(cap_addr+`DEVICE_CONTROL_DEVICE_STATUS, data);
    //enable bus mem io
    cfg_reg_write(`STATUS_COMMAND_REG, 16'h0007);
endtask
`endif