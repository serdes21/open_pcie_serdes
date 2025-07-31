#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
vec_add_3x3_batch.py
--------------------
 • 1 k × (3×3) uint8 Vec-Add，硬件一次 ≤16 B，循环 1024 次完成
 • 支持 --simulate 仅用 CPU 模拟 FPGA 计算
 • 每 256 张矩阵抽样打印 4 组，格式：CPU | FPGA
"""

import os
import sys
import mmap
import struct
import argparse
import random
from datetime import datetime

# ----------------------------------------------------------------------
# ★ 环境常量（按需修改）
# ----------------------------------------------------------------------
PCI_CH_PATH   = "/scheme/pci/00-04--00.0/channel"
BAR_INDEX     = 0
BAR_BYTES     = 64 * 1024
PHY_MEM_PATH  = "/scheme/memory/physical@uc"

CTRL_REG     = 0x00
DATA_A_BASE  = 0x10
DATA_B_BASE  = 0x20
RESULT_BASE  = 0x30
CTRL_START_MASK = 0x80

# ----------------------------------------------------------------------
# ★ 工具函数
# ----------------------------------------------------------------------
ts = lambda: datetime.now().strftime("%H:%M:%S.%f")[:-3]

def get_bar_phys(pci_ch_path: str, bar_index: int = 0) -> int:
    with open(pci_ch_path, "r+b", buffering=0) as ch:
        ch.write(struct.pack("<IH", 7, 0x10 + bar_index * 4))
        size = struct.unpack("<Q", ch.read(8))[0]
        _, bar_val = struct.unpack("<II", ch.read(size))
        return bar_val & 0xFFFFFFF0

def map_bar(bar_phys: int, length: int) -> mmap.mmap:
    fd = os.open(PHY_MEM_PATH, os.O_RDWR)
    return mmap.mmap(fd, length, mmap.MAP_SHARED,
                     mmap.PROT_READ | mmap.PROT_WRITE,
                     offset=bar_phys)

def wr(mm: mmap.mmap, off: int, data: bytes):  # 写任意长度
    mm[off:off+len(data)] = data

def rd(mm: mmap.mmap, off: int, n: int) -> bytes:
    return mm[off:off+n]

# ----------------------------------------------------------------------
# ★ 主流程
# ----------------------------------------------------------------------
def main(argv=None):
    parser = argparse.ArgumentParser(description="1k×3×3 Vec-Add 批量测试")
    parser.add_argument("-q", "--quiet", action="store_true",
                        help="仅打印 PASS / FAIL 摘要")
    parser.add_argument("--simulate", action="store_true",
                        help="不用 FPGA，完全在 CPU 上模拟")
    args = parser.parse_args(argv)

    NUM_MATS   = 1024          # 1 k
    MAT_ELEMS  = 9             # 3×3
    CHUNK_BYTES = 16           # 单次 ≤16 字节
    TOTAL_ELEMS = NUM_MATS * MAT_ELEMS

    # ---------- 生成随机输入 ----------
    vecA = [random.randint(0, 255) for _ in range(TOTAL_ELEMS)]
    vecB = [random.randint(0, 255) for _ in range(TOTAL_ELEMS)]

    # ---------- CPU 参考 ----------
    expR = [(a + b) & 0xFF for a, b in zip(vecA, vecB)]

    # ---------- 打开 / 映射 BAR ----------
    if not args.simulate:
        try:
            bar_phys = get_bar_phys(PCI_CH_PATH, BAR_INDEX)
            bar_mm   = map_bar(bar_phys, BAR_BYTES)
            if not args.quiet:
                print(f"[INFO] {ts()}  BAR0 phys=0x{bar_phys:08X} map ok")
        except Exception as e:
            print(f"[FATAL] mmap BAR 失败：{e}")
            return 2
    else:
        bar_mm = None  # 占位

    # ---------- FPGA 计算 ----------
    fpgaR = [0] * TOTAL_ELEMS
    for idx in range(NUM_MATS):                   # 共 1024 次
        base    = idx * MAT_ELEMS
        a_slice = bytes(vecA[base:base + MAT_ELEMS] + [0]*(CHUNK_BYTES - MAT_ELEMS))
        b_slice = bytes(vecB[base:base + MAT_ELEMS] + [0]*(CHUNK_BYTES - MAT_ELEMS))

        if not args.simulate:
            # 写 A/B block
            wr(bar_mm, DATA_A_BASE, a_slice)
            wr(bar_mm, DATA_B_BASE, b_slice)
            # 发 start
            wr(bar_mm, CTRL_REG, struct.pack("<B", CTRL_START_MASK))
            # 👉 若 RTL 有 BUSY 位，可轮询；此处假设 1 周期完成
            # 读结果 block
            res_slice = rd(bar_mm, RESULT_BASE, CHUNK_BYTES)
        else:
            # 纯 CPU 模拟
            res_sim = [(a + b) & 0xFF for a, b in zip(a_slice, b_slice)]
            res_slice = bytes(res_sim)

        # 取前 9 个字节写回结果数组
        fpgaR[base:base+MAT_ELEMS] = list(res_slice[:MAT_ELEMS])

    # ---------- 校验 ----------
    first_bad = -1
    for i, (exp, got) in enumerate(zip(expR, fpgaR)):
        if exp != got:
            first_bad = i
            break

    if first_bad == -1:
        print("🎉  ALL PASS – FPGA 结果与 CPU 完全一致")
    else:
        mat_id, elem_id = divmod(first_bad, MAT_ELEMS)
        print(f"❌  Mismatch at matrix #{mat_id}, element {elem_id}: "
              f"exp {expR[first_bad]}, got {fpgaR[first_bad]}")

    # ---------- 抽样打印 ----------
    if not args.quiet:
        print("\n===== Samples every 256 matrices =====\n")
        for sample in range(4):
            midx = sample * 256
            base = midx * MAT_ELEMS
            print(f"--- Matrix #{midx} (CPU | FPGA/GPGPU)---")
            for r in range(3):
                cpu_row  = " ".join(f"{expR[base + r*3 + c]:3d}" for c in range(3))
                fpga_row = " ".join(f"{fpgaR[base + r*3 + c]:3d}" for c in range(3))
                print(f"{cpu_row} | {fpga_row}")
            print()

if __name__ == "__main__":
    sys.exit(main())