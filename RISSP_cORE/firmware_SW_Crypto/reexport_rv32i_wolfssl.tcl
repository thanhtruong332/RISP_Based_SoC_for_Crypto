open_project F:/advance_topic/RV32I_software/RV32I_software.xpr
open_bd_design [get_files design_1.bd]
export_simulation -force -directory F:/RISSP_cORE/firmware_SW_Crypto/_sim_rv32i_wolfssl -simulator xsim -absolute_path
close_project
puts "REEXPORT DONE"
