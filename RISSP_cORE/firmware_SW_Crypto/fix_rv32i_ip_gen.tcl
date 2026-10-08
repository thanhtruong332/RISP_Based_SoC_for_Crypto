open_project F:/advance_topic/RV32I_software/RV32I_software.xpr
open_bd_design [get_files design_1.bd]
generate_target all [get_files design_1.bd]
export_ip_user_files -of_objects [get_files design_1.bd] -no_script -sync -force -quiet
close_project
puts "IP GEN DONE"
