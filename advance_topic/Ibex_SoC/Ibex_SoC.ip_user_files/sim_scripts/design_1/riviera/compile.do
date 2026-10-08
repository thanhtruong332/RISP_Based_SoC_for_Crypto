transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/xil_defaultlib
vlib riviera/generic_baseblocks_v2_1_2
vlib riviera/axi_infrastructure_v1_1_0
vlib riviera/axi_register_slice_v2_1_33
vlib riviera/fifo_generator_v13_2_11
vlib riviera/axi_data_fifo_v2_1_32
vlib riviera/axi_crossbar_v2_1_34
vlib riviera/axi_bram_ctrl_v4_1_11
vlib riviera/blk_mem_gen_v8_4_9
vlib riviera/lib_cdc_v1_0_3
vlib riviera/proc_sys_reset_v5_0_16
vlib riviera/xlslice_v1_0_4
vlib riviera/axi_lite_ipif_v3_0_4
vlib riviera/lib_pkg_v1_0_4
vlib riviera/lib_srl_fifo_v1_0_4
vlib riviera/axi_uartlite_v2_0_37
vlib riviera/xbip_utils_v3_0_14
vlib riviera/c_reg_fd_v12_0_10
vlib riviera/xbip_dsp48_wrapper_v3_0_6
vlib riviera/xbip_pipe_v3_0_10
vlib riviera/c_addsub_v12_0_19
vlib riviera/axi_protocol_converter_v2_1_33

vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib
vmap generic_baseblocks_v2_1_2 riviera/generic_baseblocks_v2_1_2
vmap axi_infrastructure_v1_1_0 riviera/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_33 riviera/axi_register_slice_v2_1_33
vmap fifo_generator_v13_2_11 riviera/fifo_generator_v13_2_11
vmap axi_data_fifo_v2_1_32 riviera/axi_data_fifo_v2_1_32
vmap axi_crossbar_v2_1_34 riviera/axi_crossbar_v2_1_34
vmap axi_bram_ctrl_v4_1_11 riviera/axi_bram_ctrl_v4_1_11
vmap blk_mem_gen_v8_4_9 riviera/blk_mem_gen_v8_4_9
vmap lib_cdc_v1_0_3 riviera/lib_cdc_v1_0_3
vmap proc_sys_reset_v5_0_16 riviera/proc_sys_reset_v5_0_16
vmap xlslice_v1_0_4 riviera/xlslice_v1_0_4
vmap axi_lite_ipif_v3_0_4 riviera/axi_lite_ipif_v3_0_4
vmap lib_pkg_v1_0_4 riviera/lib_pkg_v1_0_4
vmap lib_srl_fifo_v1_0_4 riviera/lib_srl_fifo_v1_0_4
vmap axi_uartlite_v2_0_37 riviera/axi_uartlite_v2_0_37
vmap xbip_utils_v3_0_14 riviera/xbip_utils_v3_0_14
vmap c_reg_fd_v12_0_10 riviera/c_reg_fd_v12_0_10
vmap xbip_dsp48_wrapper_v3_0_6 riviera/xbip_dsp48_wrapper_v3_0_6
vmap xbip_pipe_v3_0_10 riviera/xbip_pipe_v3_0_10
vmap c_addsub_v12_0_19 riviera/c_addsub_v12_0_19
vmap axi_protocol_converter_v2_1_33 riviera/axi_protocol_converter_v2_1_33

vlog -work xpm  -incr  +define+FPGA_XILINX=  +define+SYNTHESIS= "+incdir+../../../bd/design_1/ipshared/fab0/src" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3cbc" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/fab0/src" -l xpm -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_bram_ctrl_v4_1_11 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 -l xlslice_v1_0_4 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l axi_uartlite_v2_0_37 -l xbip_utils_v3_0_14 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_19 -l axi_protocol_converter_v2_1_33 \
"F:/vivado/Vivado/2024.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"F:/vivado/Vivado/2024.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  -incr \
"F:/vivado/Vivado/2024.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr  +define+FPGA_XILINX=  +define+SYNTHESIS= "+incdir+../../../bd/design_1/ipshared/fab0/src" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3cbc" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/fab0/src" -l xpm -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_bram_ctrl_v4_1_11 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 -l xlslice_v1_0_4 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l axi_uartlite_v2_0_37 -l xbip_utils_v3_0_14 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_19 -l axi_protocol_converter_v2_1_33 \
"../../../bd/design_1/ipshared/fab0/src/ibex_axi_top_combined.sv" \
"../../../bd/design_1/ip/design_1_ibex_core_0_0/sim/design_1_ibex_core_0_0.sv" \

vlog -work generic_baseblocks_v2_1_2  -incr -v2k5  +define+FPGA_XILINX=  +define+SYNTHESIS= "+incdir+../../../bd/design_1/ipshared/fab0/src" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3cbc" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/fab0/src" -l xpm -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_bram_ctrl_v4_1_11 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 -l xlslice_v1_0_4 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l axi_uartlite_v2_0_37 -l xbip_utils_v3_0_14 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_19 -l axi_protocol_converter_v2_1_33 \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/0c28/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work axi_infrastructure_v1_1_0  -incr -v2k5  +define+FPGA_XILINX=  +define+SYNTHESIS= "+incdir+../../../bd/design_1/ipshared/fab0/src" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3cbc" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/fab0/src" -l xpm -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_bram_ctrl_v4_1_11 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 -l xlslice_v1_0_4 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l axi_uartlite_v2_0_37 -l xbip_utils_v3_0_14 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_19 -l axi_protocol_converter_v2_1_33 \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_33  -incr -v2k5  +define+FPGA_XILINX=  +define+SYNTHESIS= "+incdir+../../../bd/design_1/ipshared/fab0/src" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3cbc" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/fab0/src" -l xpm -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_bram_ctrl_v4_1_11 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 -l xlslice_v1_0_4 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l axi_uartlite_v2_0_37 -l xbip_utils_v3_0_14 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_19 -l axi_protocol_converter_v2_1_33 \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3ee4/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work fifo_generator_v13_2_11  -incr -v2k5  +define+FPGA_XILINX=  +define+SYNTHESIS= "+incdir+../../../bd/design_1/ipshared/fab0/src" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3cbc" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/fab0/src" -l xpm -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_bram_ctrl_v4_1_11 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 -l xlslice_v1_0_4 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l axi_uartlite_v2_0_37 -l xbip_utils_v3_0_14 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_19 -l axi_protocol_converter_v2_1_33 \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/6080/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_11 -93  -incr \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/6080/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_11  -incr -v2k5  +define+FPGA_XILINX=  +define+SYNTHESIS= "+incdir+../../../bd/design_1/ipshared/fab0/src" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3cbc" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/fab0/src" -l xpm -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_bram_ctrl_v4_1_11 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 -l xlslice_v1_0_4 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l axi_uartlite_v2_0_37 -l xbip_utils_v3_0_14 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_19 -l axi_protocol_converter_v2_1_33 \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/6080/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work axi_data_fifo_v2_1_32  -incr -v2k5  +define+FPGA_XILINX=  +define+SYNTHESIS= "+incdir+../../../bd/design_1/ipshared/fab0/src" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3cbc" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/fab0/src" -l xpm -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_bram_ctrl_v4_1_11 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 -l xlslice_v1_0_4 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l axi_uartlite_v2_0_37 -l xbip_utils_v3_0_14 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_19 -l axi_protocol_converter_v2_1_33 \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/65ce/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_34  -incr -v2k5  +define+FPGA_XILINX=  +define+SYNTHESIS= "+incdir+../../../bd/design_1/ipshared/fab0/src" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3cbc" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/fab0/src" -l xpm -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_bram_ctrl_v4_1_11 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 -l xlslice_v1_0_4 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l axi_uartlite_v2_0_37 -l xbip_utils_v3_0_14 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_19 -l axi_protocol_converter_v2_1_33 \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/a7e3/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -v2k5  +define+FPGA_XILINX=  +define+SYNTHESIS= "+incdir+../../../bd/design_1/ipshared/fab0/src" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3cbc" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/fab0/src" -l xpm -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_bram_ctrl_v4_1_11 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 -l xlslice_v1_0_4 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l axi_uartlite_v2_0_37 -l xbip_utils_v3_0_14 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_19 -l axi_protocol_converter_v2_1_33 \
"../../../bd/design_1/ip/design_1_axi_interconnect_0_imp_xbar_0/sim/design_1_axi_interconnect_0_imp_xbar_0.v" \
"../../../bd/design_1/ipshared/5e3a/src/AESEncrypt.v" \
"../../../bd/design_1/ipshared/5e3a/src/AddRoundKey.v" \
"../../../bd/design_1/ipshared/5e3a/src/KeyExpansionRound.v" \
"../../../bd/design_1/ipshared/5e3a/src/MixColumns.v" \
"../../../bd/design_1/ipshared/5e3a/src/ShiftRows.v" \
"../../../bd/design_1/ipshared/5e3a/src/SubBytes.v" \
"../../../bd/design_1/ipshared/5e3a/src/SubTable.v" \
"../../../bd/design_1/ipshared/5e3a/src/aes_wrapper.v" \
"../../../bd/design_1/ipshared/5e3a/src/aes_axi_slave.v" \
"../../../bd/design_1/ip/design_1_aes_axi_slave_0_0/sim/design_1_aes_axi_slave_0_0.v" \
"../../../bd/design_1/ipshared/1fe1/hdl/SHA3_hardware_new_slave_lite_v1_0_S01_AXI.v" \
"../../../bd/design_1/ipshared/1fe1/src/F_permutation.v" \
"../../../bd/design_1/ipshared/1fe1/src/Keccak.v" \
"../../../bd/design_1/ipshared/1fe1/src/Padder.v" \
"../../../bd/design_1/ipshared/1fe1/src/Padder1.v" \
"../../../bd/design_1/ipshared/1fe1/src/rconst2in1.v" \
"../../../bd/design_1/ipshared/1fe1/src/round2in1.v" \
"../../../bd/design_1/ipshared/1fe1/hdl/SHA3_hardware_new.v" \
"../../../bd/design_1/ip/design_1_SHA3_hardware_new_0_0/sim/design_1_SHA3_hardware_new_0_0.v" \
"../../../bd/design_1/ipshared/f662/hdl/RSA_mark03_slave_lite_v1_0_S00_AXI.v" \
"../../../bd/design_1/ipshared/f662/src/RSA_core.v" \
"../../../bd/design_1/ipshared/f662/hdl/RSA_mark03.v" \
"../../../bd/design_1/ip/design_1_RSA_mark03_0_0/sim/design_1_RSA_mark03_0_0.v" \

vcom -work axi_bram_ctrl_v4_1_11 -93  -incr \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/df79/hdl/axi_bram_ctrl_v4_1_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/design_1/ip/design_1_axi_bram_ctrl_0_0/sim/design_1_axi_bram_ctrl_0_0.vhd" \

vlog -work blk_mem_gen_v8_4_9  -incr -v2k5  +define+FPGA_XILINX=  +define+SYNTHESIS= "+incdir+../../../bd/design_1/ipshared/fab0/src" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3cbc" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/fab0/src" -l xpm -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_bram_ctrl_v4_1_11 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 -l xlslice_v1_0_4 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l axi_uartlite_v2_0_37 -l xbip_utils_v3_0_14 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_19 -l axi_protocol_converter_v2_1_33 \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/5ec1/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -incr -v2k5  +define+FPGA_XILINX=  +define+SYNTHESIS= "+incdir+../../../bd/design_1/ipshared/fab0/src" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3cbc" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/fab0/src" -l xpm -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_bram_ctrl_v4_1_11 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 -l xlslice_v1_0_4 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l axi_uartlite_v2_0_37 -l xbip_utils_v3_0_14 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_19 -l axi_protocol_converter_v2_1_33 \
"../../../bd/design_1/ip/design_1_blk_mem_gen_0_0/sim/design_1_blk_mem_gen_0_0.v" \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/design_1_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/design_1/ip/design_1_clk_wiz_0_0/design_1_clk_wiz_0_0.v" \

vcom -work lib_cdc_v1_0_3 -93  -incr \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/2a4f/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work proc_sys_reset_v5_0_16 -93  -incr \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/0831/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/design_1/ip/design_1_proc_sys_reset_0_0/sim/design_1_proc_sys_reset_0_0.vhd" \

vlog -work xlslice_v1_0_4  -incr -v2k5  +define+FPGA_XILINX=  +define+SYNTHESIS= "+incdir+../../../bd/design_1/ipshared/fab0/src" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3cbc" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/fab0/src" -l xpm -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_bram_ctrl_v4_1_11 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 -l xlslice_v1_0_4 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l axi_uartlite_v2_0_37 -l xbip_utils_v3_0_14 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_19 -l axi_protocol_converter_v2_1_33 \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/a97c/hdl/xlslice_v1_0_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -v2k5  +define+FPGA_XILINX=  +define+SYNTHESIS= "+incdir+../../../bd/design_1/ipshared/fab0/src" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3cbc" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/fab0/src" -l xpm -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_bram_ctrl_v4_1_11 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 -l xlslice_v1_0_4 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l axi_uartlite_v2_0_37 -l xbip_utils_v3_0_14 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_19 -l axi_protocol_converter_v2_1_33 \
"../../../bd/design_1/ip/design_1_xlslice_0_0/sim/design_1_xlslice_0_0.v" \
"../../../bd/design_1/ip/design_1_blk_mem_gen_1_0/sim/design_1_blk_mem_gen_1_0.v" \

vcom -work axi_lite_ipif_v3_0_4 -93  -incr \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \

vcom -work lib_pkg_v1_0_4 -93  -incr \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/8c68/hdl/lib_pkg_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_4 -93  -incr \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/1e5a/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work axi_uartlite_v2_0_37 -93  -incr \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/9a87/hdl/axi_uartlite_v2_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/design_1/ip/design_1_axi_uartlite_0_0/sim/design_1_axi_uartlite_0_0.vhd" \

vcom -work xbip_utils_v3_0_14 -93  -incr \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/b27f/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work c_reg_fd_v12_0_10 -93  -incr \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/47fd/hdl/c_reg_fd_v12_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_6 -93  -incr \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/f596/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_10 -93  -incr \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/d531/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work c_addsub_v12_0_19 -93  -incr \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/a1b8/hdl/c_addsub_v12_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/design_1/ip/design_1_addsub_bootoffset_0_0/sim/design_1_addsub_bootoffset_0_0.vhd" \

vlog -work axi_protocol_converter_v2_1_33  -incr -v2k5  +define+FPGA_XILINX=  +define+SYNTHESIS= "+incdir+../../../bd/design_1/ipshared/fab0/src" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3cbc" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/fab0/src" -l xpm -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_bram_ctrl_v4_1_11 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 -l xlslice_v1_0_4 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l axi_uartlite_v2_0_37 -l xbip_utils_v3_0_14 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_19 -l axi_protocol_converter_v2_1_33 \
"../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/27ae/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -v2k5  +define+FPGA_XILINX=  +define+SYNTHESIS= "+incdir+../../../bd/design_1/ipshared/fab0/src" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/3cbc" "+incdir+../../../../Ibex_SoC.gen/sources_1/bd/design_1/ipshared/fab0/src" -l xpm -l xil_defaultlib -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_33 -l fifo_generator_v13_2_11 -l axi_data_fifo_v2_1_32 -l axi_crossbar_v2_1_34 -l axi_bram_ctrl_v4_1_11 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 -l xlslice_v1_0_4 -l axi_lite_ipif_v3_0_4 -l lib_pkg_v1_0_4 -l lib_srl_fifo_v1_0_4 -l axi_uartlite_v2_0_37 -l xbip_utils_v3_0_14 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_19 -l axi_protocol_converter_v2_1_33 \
"../../../bd/design_1/ip/design_1_axi_interconnect_0_imp_auto_pc_0/sim/design_1_axi_interconnect_0_imp_auto_pc_0.v" \
"../../../bd/design_1/sim/design_1.v" \

vlog -work xil_defaultlib \
"glbl.v"

