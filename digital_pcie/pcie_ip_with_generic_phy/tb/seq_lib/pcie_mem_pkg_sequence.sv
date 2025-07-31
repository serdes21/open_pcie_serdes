`ifndef PCIE_MEM_PKG_SEQUENCE_SV
`define PCIE_MEM_PKG_SEQUENCE_SV

class pcie_mem_pkg_sequence extends uvm_sequence;

    `uvm_object_utils(pcie_mem_pkg_sequence)

    `uvm_declare_p_sequencer(pcie_virtual_sequencer)

    extern task pcie_mem_write(input bit [31:0] addr, input bit [9:0] length,
        input bit [3:0] first_dw_be, input bit [3:0] last_dw_be, input bit [31:0] wr_data[], input bit block=1);
    extern task pcie_mem_read(input bit [31:0] addr, input bit [9:0] length,
        input bit [3:0] first_dw_be, input bit [3:0] last_dw_be, output bit [31:0] rd_data[], input bit block=1);

    extern function new(string name="pcie_mem_pkg_sequence");
    extern task body();
endclass

function pcie_mem_pkg_sequence :: new(string name="pcie_mem_pkg_sequence");
    super.new(name);
endfunction

task pcie_mem_pkg_sequence :: pcie_mem_write(input bit [31:0] addr, input bit [9:0] length,
        input bit [3:0] first_dw_be, input bit [3:0] last_dw_be, input bit [31:0] wr_data[], input bit block=1);

    svt_pcie_driver_app_mem_request_sequence mem_request_seq;
    mem_request_seq = svt_pcie_driver_app_mem_request_sequence :: type_id :: create("mem_request_seq");
    mem_request_seq.transaction_type = svt_pcie_driver_app_transaction::MEM_WR;
    mem_request_seq.ep = 0;
    mem_request_seq.th = 0;
    mem_request_seq.traffic_class = 0;
    mem_request_seq.address_translation = 0;
    mem_request_seq.first_dw_be = first_dw_be;
    mem_request_seq.last_dw_be = last_dw_be;
    mem_request_seq.block = block;
    mem_request_seq.length = length;
    mem_request_seq.address[63:32] = 32'h0;
    mem_request_seq.address[31:0] = addr;

    mem_request_seq.write_payload = new[length];
    foreach(mem_request_seq.write_payload[i])begin
         mem_request_seq.write_payload[i] = wr_data[i];
    end

    mem_request_seq.start(p_sequencer.root_vir_sqr.driver_transaction_seqr[0]);

    `uvm_info("pcie_mem_pkg_sequence", $sformatf("mem write addr:0x%0h, data:%p", addr, wr_data), UVM_LOW)
endtask

task pcie_mem_pkg_sequence :: pcie_mem_read(input bit [31:0] addr, input bit [9:0] length,
        input bit [3:0] first_dw_be, input bit [3:0] last_dw_be, output bit [31:0] rd_data[], input bit block=1);

    svt_pcie_driver_app_mem_request_sequence mem_request_seq;

    mem_request_seq = svt_pcie_driver_app_mem_request_sequence :: type_id :: create("mem_request_seq");
    mem_request_seq.transaction_type = svt_pcie_driver_app_transaction::MEM_RD;
    mem_request_seq.ep = 0;
    mem_request_seq.th = 0;
    mem_request_seq.traffic_class = 0;
    mem_request_seq.address_translation = 0;
    mem_request_seq.first_dw_be = first_dw_be;
    mem_request_seq.last_dw_be = last_dw_be;
    mem_request_seq.block = block;
    mem_request_seq.length = length;
    mem_request_seq.address[63:32] = 32'h0;
    mem_request_seq.address[31:0] = addr;

    mem_request_seq.start(p_sequencer.root_vir_sqr.driver_transaction_seqr[0]);

    rd_data = new[length];
    foreach(rd_data[i]) begin
        rd_data[i] = mem_request_seq.req.payload[i];
    end

    `uvm_info("pcie_mem_pkg_sequence", $sformatf("mem read addr:0x%0h, data:%p", addr, rd_data), UVM_LOW)
endtask




task pcie_mem_pkg_sequence::body();
    //--------------------------------------------------------------------
    // 本地变量
    //--------------------------------------------------------------------
    bit [31:0] wr_vec_a [];            // A 向量（4 DW，每 DW = 4 B）
    bit [31:0] wr_vec_b [];
    bit [31:0] exp_vec_r [4];          // 期望结果
    bit [31:0] rd_vec_r [4];           // 读回的结果
    bit [31:0] tmp_wr [1];             // 单 DW 写缓冲
    bit [31:0] tmp_rd [];              // 读回缓冲（动态）

    //--------------------------------------------------------------------
    // 1) 产生测试数据并计算期望结果
    //--------------------------------------------------------------------
    wr_vec_a = new[4];
    wr_vec_b = new[4];
    for (int w = 0; w < 4; w++) begin
        wr_vec_a[w] = {8'((w*4)+4),  8'((w*4)+3),  8'((w*4)+2),  8'((w*4)+1)};
        wr_vec_b[w] = {8'((w*4)+20), 8'((w*4)+19), 8'((w*4)+18), 8'((w*4)+17)};
        exp_vec_r[w] = wr_vec_a[w] + wr_vec_b[w];   // 低 8 位自然截断
    end

    //--------------------------------------------------------------------
    // 2) 逐 DW 写向量 A（BAR0+0x10），每写完等待 50 周期→读回校验
    //--------------------------------------------------------------------
    tmp_rd = new[1];
    foreach (wr_vec_a[i]) begin
        tmp_wr[0] = wr_vec_a[i];
        pcie_mem_write(`BAR0_START_ADDR + 32'h10 + (i*4), 1,
                       4'hF, 4'h0, tmp_wr);
    end

    //--------------------------------------------------------------------
    // 3) 逐 DW 写向量 B（BAR0+0x20），同样写后等待→读回校验
    //--------------------------------------------------------------------
    foreach (wr_vec_b[i]) begin
        tmp_wr[0] = wr_vec_b[i];
        pcie_mem_write(`BAR0_START_ADDR + 32'h20 + (i*4), 1,
                       4'hF, 4'h0, tmp_wr);



        pcie_mem_read(`BAR0_START_ADDR + 32'h20 + (i*4), 1,
                      4'hF, 4'h0, tmp_rd);
        if (tmp_rd[0] !== wr_vec_b[i]) begin
            `uvm_error("WRCHK",
                       $sformatf("Vector B DW%0d mismatch : exp 0x%08h  got 0x%08h",
                                 i, wr_vec_b[i], tmp_rd[0]));
            return;
        end
    end

    //--------------------------------------------------------------------
    // 4) 写启动寄存器 ctrl[7]=1（BAR0+0x00），同样先等待再确认
    //--------------------------------------------------------------------
    tmp_wr[0] = 32'h8000_0000; // bit7 = 1
    pcie_mem_write(`BAR0_START_ADDR + 32'h00, 1,
                   4'hF, 4'h0, tmp_wr);


    //--------------------------------------------------------------------
    // 5) 轮询 ctrl[7] 直到硬件清零（计算完成）
    //--------------------------------------------------------------------
    do begin
        pcie_mem_read(`BAR0_START_ADDR + 32'h00, 1,
                      4'hF, 4'h0, tmp_rd);
    end while (tmp_rd[0][7]);

    //--------------------------------------------------------------------
    // 6) 逐 DW 读结果向量（BAR0+0x30）
    //--------------------------------------------------------------------
    foreach (rd_vec_r[i]) begin
        pcie_mem_read(`BAR0_START_ADDR + 32'h30 + (i*4), 1,
                      4'hF, 4'h0, tmp_rd);
        rd_vec_r[i] = tmp_rd[0];
    end

    //--------------------------------------------------------------------
    // 7) 比对结果并报 PASS/FAIL
    //--------------------------------------------------------------------
    foreach (rd_vec_r[i]) begin
        if (rd_vec_r[i] !== exp_vec_r[i]) begin
            `uvm_error("VEC_ADD",
                       $sformatf("Mismatch DW%0d : expect 0x%08h  get 0x%08h",
                                 i, exp_vec_r[i], rd_vec_r[i]));
        end
        else begin
            `uvm_info("VEC_ADD",
                      $sformatf("Result DW%0d OK : 0x%08h", i, rd_vec_r[i]),
                      UVM_LOW);
        end
    end
endtask

`endif