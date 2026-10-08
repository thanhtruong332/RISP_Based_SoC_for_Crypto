# run_rv32i_wolfssl_sw.tcl - mo RV32I_software, nap .coe wolfSSL, generate
# output products + export simulation fileset, chay xvlog/xelab/xsim thu cong.
open_project F:/advance_topic/RV32I_software/RV32I_software.xpr
open_bd_design [get_files design_1.bd]

set_property -dict [list CONFIG.Load_Init_File {true} CONFIG.Coe_File {F:/RISSP_cORE/firmware_SW_Crypto/wolfssl_build/rissp_wolfssl.coe}] [get_bd_cells blk_mem_gen_0]
save_bd_design
reset_target simulation [get_files design_1.bd]
generate_target simulation [get_files design_1.bd]

set_property top tb_wolfssl_software [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
add_files -fileset sim_1 -norecurse D:/Viettel_semi/RV32I_FULL/tb_wolfssl_software.v
update_compile_order -fileset sim_1

export_simulation -force -directory F:/RISSP_cORE/firmware_SW_Crypto/_sim_rv32i_wolfssl -simulator xsim -absolute_path

close_project
puts "EXPORT DONE"
