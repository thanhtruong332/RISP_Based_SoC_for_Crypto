# refresh_rv32i_ip.tcl - sau khi sua ALU.v (bug SRA) trong rv32i_fixed IP
# repo va bump coreRevision, force RV32I_software nhan dien va dung ban moi.
open_project F:/advance_topic/RV32I_software/RV32I_software.xpr

update_ip_catalog -rebuild

open_bd_design [get_files design_1.bd]
upgrade_ip [get_ips -all -filter {IPDEF =~ "*rv32i_fixed*"}]
validate_bd_design
save_bd_design

reset_target all [get_files design_1.bd]
generate_target all [get_files design_1.bd]
export_ip_user_files -of_objects [get_files design_1.bd] -no_script -sync -force -quiet

reset_target simulation [get_files design_1.bd]
generate_target simulation [get_files design_1.bd]

export_simulation -force -directory F:/RISSP_cORE/firmware_SW_Crypto/_sim_rv32i_aes_sha3 -simulator xsim -absolute_path

close_project
puts "REFRESH DONE"
