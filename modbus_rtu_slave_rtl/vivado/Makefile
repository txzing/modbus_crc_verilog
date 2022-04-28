#*******************************************************************************
#
#   FILENAME: Makefile
#   AUTHOR: Greg Taylor      CREATION DATE: 17 Oct 2014
#
#   DESCRIPTION: 
#	Run 'make sim-debug' to debug the design in the Modelsim GUI
#
#	Run 'make bitstream' to build the entire design (synthesis, P&R, bitstream)
#
#	Run 'make program' to program the FPGA (may have to modify script for your
#	setup)
#
#   CHANGE HISTORY:
#   17 Oct 2014        Greg Taylor
#       Initial version
#
#   Copyright (C) 2014 Greg Taylor <gtaylor@sonic.net>
#    
#   This file is part of imx219_to_mpsoc_displayport FPGA.
#    
#   imx219_to_mpsoc_displayport FPGA is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#   
#   imx219_to_mpsoc_displayport FPGA is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Lesser General Public License for more details.
#   
#   You should have received a copy of the GNU Lesser General Public License
#   along with imx219_to_mpsoc_displayport FPGA.  If not, see <http://www.gnu.org/licenses/>.
#   
#******************************************************************************
#uname_O := $(shell sh -c 'uname -o 2>/dev/null || echo not')

RTL_SRC ?= 
BD_SRC ?= 
XDC_SRC ?= xdc/top.xdc
IP_SRC ?= ip_repo
PROJ_NAME ?= vivado_proj
PROJ_PATH ?= $(PROJ_NAME)
PART ?= xczu2cg-sfvc784-1-e

BOARD ?= 
SIM_SRC ?= 
INC_DIR0 ?= 
SIM_LIB ?= 	

#ifeq (${BOARD}, ACQ_V2)
#    BD_SRC = \
#    	bd/system.tcl
#    	
#    XDC_SRC = \
#    	constraints/system.xdc
#endif
	

#compile: compile_sim_lib
#	test -e work || vlib work
#	vlog -incr $(SIM_SRC) $(RTL_SRC) +define+SIM +incdir+$(INC_DIR0)
	
#compile_sim_lib:
#	test -e sim_lib || (vlib sim_lib && vlog -work sim_lib -incr $(SIM_LIB))	
		 
#sim: compile-eval
#	vsim -L sim_lib -c system_tb glbl -do "run -a"
	
# Launch the Modelsim GUI for debugging design		
#sim-debug: compile
#ifneq (, $(findstring Cygwin, $(uname_O)))
#	cygstart vsim -L sim_lib system_tb glbl -voptargs=+acc
#else
#	vsim -L sim_lib system_tb glbl -voptargs=+acc
#endif

project: $(BD_SRC) $(XDC_SRC)
#	@ test -a ip_cache && echo exist || echo not exist
#	@ [ -a ./ip_cache ] && echo exists || echo not exists
#	@ if [ -a ./ip_cache ]; then echo exists; else echo not exists; fi;
#	@ if ! [ -a ./ip_cache ]; then echo not exists; else echo exists; fi;
	@ if ! [ -a ip_cache ]; then echo ip_cache does not exists; mkdir ip_cache; touch ip_cache/.gitkeep; else echo ip_cache does exist; fi;
	@ if [ -a $(PROJ_PATH) ]; then echo -e project folder does exist; else \
	vivado -mode batch -source scripts/create_proj.tcl -tclargs "$(PROJ_PATH)" "$(PROJ_NAME)" "$(PART)" "$(BD_SRC)" "$(XDC_SRC)" "$(IP_SRC)" \
	"$(RTL_SRC)" "$(INC_DIR0)"  "${BOARD}"; rm -rf *.jou .Xil *.log; \
	fi;

project_clean:
	@ rm -rf $(PROJ_PATH) vivado_pid*
	@ rm -rf *.jou .Xil *.log .hbs
	
	
syn: project
	@ if ! [ -a ip_cache ]; then echo ip_cache does not exists; mkdir ip_cache; touch ip_cache/.gitkeep; else echo ip_cache does exist; fi;
	vivado -mode batch -source scripts/synthesis.tcl -tclargs "$(PROJ_PATH)" "$(PROJ_NAME)" "$(BD_SRC)"
	@ rm -rf *.jou .Xil *.log .hbs

syn_clean: implement_clean
	@ rm -rf $(PROJ_PATH)/$(PROJ_NAME).runs/synth_1/
	@ rm -rf *.jou .Xil *.log .hbs

implement: syn
	vivado -mode batch -source scripts/implement.tcl -tclargs "$(PROJ_PATH)" "$(PROJ_NAME)" "$(BD_SRC)"
	@ rm -rf *.jou .Xil *.log .hbs

implement_clean:
	@ rm -rf $(PROJ_PATH)/$(PROJ_NAME).runs/impl_1/
	@ rm -rf *.jou .Xil *.log .hbs

bitstream: implement
	#vivado -mode batch -source scripts/gen_xsa.tcl -tclargs "$(PROJ_PATH)" "$(PROJ_NAME)" "$(BD_SRC)"
	vivado -mode batch -source scripts/gen_xsa.tcl -tclargs "$(PROJ_PATH)" "$(PROJ_NAME)" "top"
	@ rm -rf *.jou .Xil *.log .hbs

clean:
	@ rm -rf *.jou .Xil *.log .hbs
	
dist_clean: project_clean
	@ rm -rf $(PROJ_PATH)/$(PROJ_NAME).runs/synth_1/
	@ rm -rf $(PROJ_PATH)/$(PROJ_NAME).runs/impl_1/
	@ rm -rf *.jou .Xil *.log  .hbs
	@ rm -rf ip_cache/*


