#####################################################################
# KU5P - PCIe Gen1 &times;1  Demo  (top_pcie1_x1)
#####################################################################

############################
# 0. Bit-stream / 配置选项
############################
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN Enable [current_design]

############################
# 1. 100 MHz PCIe REFCLK
############################
# ① 差分管脚
set_property PACKAGE_PIN AB6 [get_ports refclk_n]
set_property PACKAGE_PIN AB7 [get_ports refclk_p]

# ② 根时钟（10 ns）
create_clock -period 10.000 -name clk_ref100 [get_ports refclk_p]


############################
# 5. 不确定度（仅根时钟）
############################
set_clock_uncertainty -setup 0.020 [get_clocks clk_ref100]
set_clock_uncertainty -hold 0.010 [get_clocks clk_ref100]

############################
# 6. reset_n
############################
set_property PACKAGE_PIN T19 [get_ports reset_n]
set_property IOSTANDARD LVCMOS12 [get_ports reset_n]
set_property PULLUP true [get_ports reset_n]
set_false_path -from [get_ports reset_n]
set_input_delay 0.000 [get_ports reset_n]




