# run_rv32i_wolfssl_sw.tcl - mo RV32I_software, nap .coe wolfSSL, generate
# output products + export simulation fileset, chay xvlog/xelab/xsim thu cong.
set script_dir [file dirname [file normalize [info script]]]
set repo_root [file normalize [file join $script_dir .. ..]]
set project_file [file join $repo_root advance_topic RV32I_software RV32I_software.xpr]
set coe_file [file join $script_dir wolfssl_build rissp_wolfssl.coe]
set tb_file [file join $repo_root firmware_testbench RV32I_FULL tb_wolfssl_software.v]
set sim_dir [file join $script_dir _sim_rv32i_wolfssl]

open_project $project_file
open_bd_design [get_files design_1.bd]

set_property -dict [list CONFIG.Load_Init_File true CONFIG.Coe_File $coe_file] [get_bd_cells blk_mem_gen_0]
save_bd_design
reset_target simulation [get_files design_1.bd]
generate_target simulation [get_files design_1.bd]

set_property top tb_wolfssl_software [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $tb_file
update_compile_order -fileset sim_1

export_simulation -force -directory $sim_dir -simulator xsim -absolute_path

close_project
puts "EXPORT DONE"
