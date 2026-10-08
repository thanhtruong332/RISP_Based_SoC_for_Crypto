read_verilog rsa_ws.v
synth_design -top rsa_modexp_ws -part xc7z020clg484-1 -mode out_of_context \
             -generic S=64 -generic CONST_TIME=1 -directive AreaOptimized_high
opt_design -directive ExploreArea
report_utilization -file util_rsa2048.rpt
create_clock -name clk -period 25.0 [get_ports clk]
report_timing_summary -file timing_rsa2048.rpt
