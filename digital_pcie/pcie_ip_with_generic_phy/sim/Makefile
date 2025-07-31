
default: compile run

SEED ?= $(shell date "+%m%d%H%M%S")

DUT_DIR = ../rtl
TB_DIR = ../tb
TB_ENV = ..

RTL_LIST = +incdir+$(DUT_DIR) +incdir+$(DUT_DIR)/src +incdir+$(DUT_DIR)/src/include +incdir+$(DUT_DIR)/src/Phy/generic -f $(DUT_DIR)/pcie_rtl.f

TB_LIST= +incdir+$(TB_ENV) +incdir+$(TB_DIR)\
         $(TB_DIR)/tb_top.sv

VERDI ?= 1

PKG_NUM ?= 0

DEBUG_OPT ?= -debug_all

UVM_VERBOSITY ?= UVM_LOW
#UVM_TESTNAME ?= pcie_base_test
UVM_TESTNAME ?= pcie_mem_pkg_test
UVM_TIMEOUT ?= 8000

ifeq ($(VERDI),1)
DEBUG_OPT = -debug_access+all
COMP_OPTS += -lca
#COMP_OPTS += -kdb -lca
endif

UVM_EN ?= 1
ifeq ($(UVM_EN), 1)
COMP_OPTS += -ntb_opts uvm-1.2
endif

PCIE_VIP_PATH ?= /home/jjt/pcie_gen6_cxl_proj/designware_home/pcie_dev
PCIE_VIP ?= 1
ifeq ($(PCIE_VIP), 1)
COMP_OPTS += +incdir+$(PCIE_VIP_PATH)/include/verilog
COMP_OPTS += +incdir+$(PCIE_VIP_PATH)/include/sverilog
COMP_OPTS += +incdir+$(PCIE_VIP_PATH)/src/verilog/vcs
COMP_OPTS += +incdir+$(PCIE_VIP_PATH)/src/sverilog/vcs
COMP_OPTS += -y $(PCIE_VIP_PATH)/src/verilog/vcs
COMP_OPTS += -y $(PCIE_VIP_PATH)/src/sverilog/vcs

COMP_OPTS += +define+UVM_PACKER_MAX_BYTES=8192
COMP_OPTS += +define+SYNOPSYS_SV
COMP_OPTS += +define+SYNOPSYS_TIMESCALE
endif


COMP_OPTS += -Mupdate -sverilog -full64 $(DEBUG_OPT) -top tb_top
COMP_OPTS += +warn=RT-NCMUCS +warn=UII-L +warn=TFIPC
COMP_OPTS += -timescale=1ns/1ps +libext+.v+.sv
COMP_OPTS += +define+RAM_INIT=0


RUN_OPTS += +ntb_random_seed=$(SEED)
RUN_OPTS += +warn=noRT-NCMUCS +warn=noUII-L +warn=noTFIPC

RUN_OPTS += +UVM_VERBOSITY=$(UVM_VERBOSITY)
RUN_OPTS += +UVM_TESTNAME=$(UVM_TESTNAME)
RUN_OPTS += +UVM_TIMEOUT='$(UVM_TIMEOUT),YES'

#vcs -l compil.log $(COMP_OPTS) $(RTL_LIST)
compile:
	vcs -l compil.log $(COMP_OPTS) $(RTL_LIST) $(TB_LIST)

run:
	./simv -l sim.log $(RUN_OPTS)

verdi:
	verdi -sv -nologo $(RTL_LIST) $(TB_LIST) -top tb_top -ssf pcie.fsdb &

clean:
	rm -rf AN.DB DVEfiles csrc *log *.key *.fsdb simv* novas.* verdiLog novas_dump.log ucli.key compile.log sim.log pcie.fsdb vc_hdrs.h