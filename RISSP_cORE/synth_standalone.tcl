# Synth từng module ĐỘC LẬP (không qua rissp_top) để có số LUT không lẫn
# hierarchy-attribution/flatten artifact -- mỗi module là 1 top OOC riêng.
set part xc7z020clg484-1

proc synth_one {top files rptname} {
    global part
    read_verilog $files
    synth_design -top $top -part $part -mode out_of_context -directive AreaOptimized_high
    opt_design -directive ExploreArea
    report_utilization -file $rptname
    close_design
}

synth_one register_file_reset_variant {_audit_tmp/register_file_reset_variant.v} util_standalone_register_file_RESET_VARIANT.rpt
synth_one register_file    {register_file.v}    util_standalone_register_file.rpt
synth_one barrel_shifter   {barrel_shifter.v}    util_standalone_barrel_shifter.rpt
synth_one comparator       {comparator.v}        util_standalone_comparator.rpt
synth_one alu_adder        {alu_adder.v}         util_standalone_alu_adder.rpt
synth_one r_type_block     {r_type_block.v}     util_standalone_r_type_block.rpt
synth_one i_type_block     {i_type_block.v}     util_standalone_i_type_block.rpt
synth_one b_type_block     {b_type_block.v}     util_standalone_b_type_block.rpt
synth_one j_type_block     {j_type_block.v}     util_standalone_j_type_block.rpt
synth_one u_type_block     {u_type_block.v}     util_standalone_u_type_block.rpt
synth_one s_type_block     {s_type_block.v}     util_standalone_s_type_block.rpt
synth_one fetch_stage      {fetch_stage.v}      util_standalone_fetch_stage.rpt
synth_one axi_rissp_master {axi_rissp_master.v} util_standalone_axi_rissp_master.rpt

puts "ALL STANDALONE SYNTH DONE"
