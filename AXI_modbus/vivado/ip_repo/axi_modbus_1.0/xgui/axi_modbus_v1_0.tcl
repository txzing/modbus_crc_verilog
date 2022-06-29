# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set INTR_CLOCK [ipgui::add_param $IPINST -name "INTR_CLOCK" -parent ${Page_0}]
  set_property tooltip {Intr Clock，指示03更新完后产生中断的维持时钟周期数} ${INTR_CLOCK}


}

proc update_PARAM_VALUE.INTR_CLOCK { PARAM_VALUE.INTR_CLOCK } {
	# Procedure called to update INTR_CLOCK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INTR_CLOCK { PARAM_VALUE.INTR_CLOCK } {
	# Procedure called to validate INTR_CLOCK
	return true
}

proc update_PARAM_VALUE.C_S0_AXI_DATA_WIDTH { PARAM_VALUE.C_S0_AXI_DATA_WIDTH } {
	# Procedure called to update C_S0_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S0_AXI_DATA_WIDTH { PARAM_VALUE.C_S0_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S0_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S0_AXI_ADDR_WIDTH { PARAM_VALUE.C_S0_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S0_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S0_AXI_ADDR_WIDTH { PARAM_VALUE.C_S0_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S0_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S0_AXI_BASEADDR { PARAM_VALUE.C_S0_AXI_BASEADDR } {
	# Procedure called to update C_S0_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S0_AXI_BASEADDR { PARAM_VALUE.C_S0_AXI_BASEADDR } {
	# Procedure called to validate C_S0_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S0_AXI_HIGHADDR { PARAM_VALUE.C_S0_AXI_HIGHADDR } {
	# Procedure called to update C_S0_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S0_AXI_HIGHADDR { PARAM_VALUE.C_S0_AXI_HIGHADDR } {
	# Procedure called to validate C_S0_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.C_S0_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S0_AXI_DATA_WIDTH PARAM_VALUE.C_S0_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S0_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S0_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S0_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S0_AXI_ADDR_WIDTH PARAM_VALUE.C_S0_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S0_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S0_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.INTR_CLOCK { MODELPARAM_VALUE.INTR_CLOCK PARAM_VALUE.INTR_CLOCK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INTR_CLOCK}] ${MODELPARAM_VALUE.INTR_CLOCK}
}

