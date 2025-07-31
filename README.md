# open_pcie_serdes

面向 PCIe + 16G NRZ SerDes 的开源工程数字端 PCIe EP、FPGA 原型以及一个简单的Redox OS 驱动。


## PCIe SerDes 全流程实战文章
链接： https://serdes21.github.io/

## Redox PCIe + FPGA实机演示视频
链接： https://www.bilibili.com/video/BV1vK8mzUEhf



## 开源工程内容

### analog_serdes
serdes TX电路 （UMC28nm工艺库未提供）
- 文件：`dealy.va`（延时）、`div.va`（分频）、`parallel_prbs7.va`（PRBS7 发生器）。
- `Half_rate_NRZ_16G.cdl` 为电路级网表，`SerDes_16G_NRZ.zip` 为Cadence virtuoso工程。

### digital_pcie
PCIe Endpoint 数字逻辑与验证环境，分两套（PCIE IP源码未提供）：
- `pcie_ip_with_generic_phy/`：与synopsys generic PHY 版本，含 RTL、TB、VIP、用例与 `sim/Makefile`。
- `pcie_ip_with_xilinx_phy/`：面向 Xilinx PHY的版本，集成 GT Wizard/PHY 行为及仿真模型，同样提供 TB、用例与仿真脚本。

### fpga
用于板级原型验证的 FPGA 工程（PCIE IP源码未提供）。
- `pcie_gpgpu2/Bender.yml` 管理AXI依赖。
- `project_1/` 为示例 Vivado 工程，包含导入的 PCIe/PHY 源文件与约束（`fpga.xdc`、`pcie_phy_0_gt.xci` 等）。

### driver_redox
- `matrix_add.py`：示例用的Redox OS上层驱动。


## 交流
- 有问题/需要虚拟机可以加群1056444998交流
- 同名VX: serdes21
