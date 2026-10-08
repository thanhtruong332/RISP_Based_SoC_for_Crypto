# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "BootAddr" -parent ${Page_0}
  ipgui::add_param $IPINST -name "HartId" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ICache" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MHPMCounterNum" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PMPEnable" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RV32B" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RV32E" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RV32M" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RV32ZC" -parent ${Page_0}


}

proc update_PARAM_VALUE.BootAddr { PARAM_VALUE.BootAddr } {
	# Procedure called to update BootAddr when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BootAddr { PARAM_VALUE.BootAddr } {
	# Procedure called to validate BootAddr
	return true
}

proc update_PARAM_VALUE.HartId { PARAM_VALUE.HartId } {
	# Procedure called to update HartId when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HartId { PARAM_VALUE.HartId } {
	# Procedure called to validate HartId
	return true
}

proc update_PARAM_VALUE.ICache { PARAM_VALUE.ICache } {
	# Procedure called to update ICache when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ICache { PARAM_VALUE.ICache } {
	# Procedure called to validate ICache
	return true
}

proc update_PARAM_VALUE.MHPMCounterNum { PARAM_VALUE.MHPMCounterNum } {
	# Procedure called to update MHPMCounterNum when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MHPMCounterNum { PARAM_VALUE.MHPMCounterNum } {
	# Procedure called to validate MHPMCounterNum
	return true
}

proc update_PARAM_VALUE.PMPEnable { PARAM_VALUE.PMPEnable } {
	# Procedure called to update PMPEnable when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PMPEnable { PARAM_VALUE.PMPEnable } {
	# Procedure called to validate PMPEnable
	return true
}

proc update_PARAM_VALUE.RV32B { PARAM_VALUE.RV32B } {
	# Procedure called to update RV32B when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RV32B { PARAM_VALUE.RV32B } {
	# Procedure called to validate RV32B
	return true
}

proc update_PARAM_VALUE.RV32E { PARAM_VALUE.RV32E } {
	# Procedure called to update RV32E when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RV32E { PARAM_VALUE.RV32E } {
	# Procedure called to validate RV32E
	return true
}

proc update_PARAM_VALUE.RV32M { PARAM_VALUE.RV32M } {
	# Procedure called to update RV32M when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RV32M { PARAM_VALUE.RV32M } {
	# Procedure called to validate RV32M
	return true
}

proc update_PARAM_VALUE.RV32ZC { PARAM_VALUE.RV32ZC } {
	# Procedure called to update RV32ZC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RV32ZC { PARAM_VALUE.RV32ZC } {
	# Procedure called to validate RV32ZC
	return true
}


proc update_MODELPARAM_VALUE.RV32M { MODELPARAM_VALUE.RV32M PARAM_VALUE.RV32M } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RV32M}] ${MODELPARAM_VALUE.RV32M}
}

proc update_MODELPARAM_VALUE.RV32B { MODELPARAM_VALUE.RV32B PARAM_VALUE.RV32B } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RV32B}] ${MODELPARAM_VALUE.RV32B}
}

proc update_MODELPARAM_VALUE.RV32ZC { MODELPARAM_VALUE.RV32ZC PARAM_VALUE.RV32ZC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RV32ZC}] ${MODELPARAM_VALUE.RV32ZC}
}

proc update_MODELPARAM_VALUE.RV32E { MODELPARAM_VALUE.RV32E PARAM_VALUE.RV32E } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RV32E}] ${MODELPARAM_VALUE.RV32E}
}

proc update_MODELPARAM_VALUE.ICache { MODELPARAM_VALUE.ICache PARAM_VALUE.ICache } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ICache}] ${MODELPARAM_VALUE.ICache}
}

proc update_MODELPARAM_VALUE.PMPEnable { MODELPARAM_VALUE.PMPEnable PARAM_VALUE.PMPEnable } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PMPEnable}] ${MODELPARAM_VALUE.PMPEnable}
}

proc update_MODELPARAM_VALUE.MHPMCounterNum { MODELPARAM_VALUE.MHPMCounterNum PARAM_VALUE.MHPMCounterNum } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MHPMCounterNum}] ${MODELPARAM_VALUE.MHPMCounterNum}
}

proc update_MODELPARAM_VALUE.BootAddr { MODELPARAM_VALUE.BootAddr PARAM_VALUE.BootAddr } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BootAddr}] ${MODELPARAM_VALUE.BootAddr}
}

proc update_MODELPARAM_VALUE.HartId { MODELPARAM_VALUE.HartId PARAM_VALUE.HartId } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HartId}] ${MODELPARAM_VALUE.HartId}
}

