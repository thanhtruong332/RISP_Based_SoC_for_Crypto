read_verilog [list \
    barrel_shifter.v \
    comparator.v \
    alu_adder.v \
    r_type_block.v \
    i_type_block.v \
    b_type_block.v \
    j_type_block.v \
    u_type_block.v \
    s_type_block.v \
    modular_ex.v \
    register_file.v \
    fetch_stage.v \
    axi_rissp_master.v \
    rissp_top.v \
]

synth_design -top rissp_top -part xc7z020clg484-1 -mode out_of_context -directive AreaOptimized_high

report_utilization -file util_after.rpt
report_utilization -hierarchical -hierarchical_depth 3 -file util_hier_after.rpt

opt_design -directive ExploreArea
report_utilization -file util_after_opt.rpt

write_checkpoint -force post_synth_after.dcp
