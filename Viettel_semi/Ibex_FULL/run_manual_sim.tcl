# run_manual_sim.tcl
#
# CHAY MO PHONG THAY THE nut "Run Simulation" cua Vivado GUI - da xac nhan
# GUI bi 1 gioi han that (xem README.md muc "Vivado GUI Run Simulation bi
# loi"): khong tu liet ke du 56 file .sv cua ibex_core_0 vao danh sach bien
# dich, chi vi trung ten module voi ban IP tu quan ly (Vivado tu dong
# IS_AUTO_DISABLED chung, khong sua duoc tu phia project/fileset).
#
# Script nay goi thang xvlog/xvhdl/xelab/xsim voi dung danh sach file (da
# xac nhan bien dich + elaborate + chay PASS that, 2026-08-14).
#
# CACH DUNG:
#   vivado -mode batch -source run_manual_sim.tcl -tclargs <ten_testbench> <ten_file_coe>
#
# Vi du (AES ECB):
#   ... -tclargs tb_ibex_ecb aes_ecb
# Vi du (SHA3 16 block):
#   ... -tclargs tb_ibex_sha3_16 sha3_16
#
# YEU CAU TRUOC: Ibex_SoC.xpr da Create HDL Wrapper + Generate Output
# Products it nhat 1 lan (de co san design_1.v/design_1_wrapper.v/ipshared).
# KHONG can nap .coe qua GUI truoc - script tu doi tu SE-RISSP_FULL/<coe>.coe
# vao dung vi tri blk_mem_gen_0 doc luc mo phong (xem buoc buoc MIF).

if {$argc < 2} {
    puts "Thieu tham so. Dung: -tclargs <ten_testbench> <ten_file_coe (khong duoi .coe)>"
    puts "Vi du: -tclargs tb_ibex_ecb aes_ecb"
    exit 1
}
set tb_name  [lindex $argv 0]
set coe_name [lindex $argv 1]

set here       [file normalize [file dirname [info script]]]
set repo_root  [file normalize "$here/../.."]
set soc_root   "$repo_root/advance_topic/Ibex_SoC"
set ibex_repo  "$repo_root/advance_topic/Ibex_Core"
set ibex_dir   "$ibex_repo/ip_repo/src"
set full_dir   $here
set coe_src    "$repo_root/Viettel_semi/SE-RISSP_FULL/$coe_name.coe"

# --- Thu tu compile dung cho 56 file ibex, doc tu ibex_compile_order.f
#     (da loc tu IBEX_CORE/compile_order.f, chi giu file thuc su co trong
#     ip_repo/src - KHONG go tay o day de tranh thieu sot). ---
set order_fp [open "$full_dir/ibex_compile_order.f" r]
set ibex_files {}
while {[gets $order_fp l] >= 0} {
    set l [string trim $l]
    if {$l ne ""} { lappend ibex_files "$ibex_dir/$l" }
}
close $order_fp
# IP Ibex da dong goi lai thanh 1 file gop (ibex_axi_top_combined.sv) -> 56 file le khong con trong ip_repo/src
if {[file exists "$ibex_dir/ibex_axi_top_combined.sv"]} { set ibex_files [list "$ibex_dir/ibex_axi_top_combined.sv"] }

# --- 34 file con lai (AES/SHA3/RSA/interconnect/BD flatten/wrapper), duong
#     dan tuyet doi trong Ibex_SoC.ip_user_files / .gen (khong doi qua cac
#     lan chay, chi thay doi khi Block Design bi sua lai) ---
set rest_files {
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ip/design_1_axi_interconnect_0_imp_xbar_0/sim/design_1_axi_interconnect_0_imp_xbar_0.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ip/design_1_axi_interconnect_0_imp_auto_pc_0/sim/design_1_axi_interconnect_0_imp_auto_pc_0.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/5e3a/src/AESEncrypt.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/5e3a/src/AddRoundKey.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/5e3a/src/KeyExpansionRound.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/5e3a/src/MixColumns.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/5e3a/src/ShiftRows.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/5e3a/src/SubBytes.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/5e3a/src/SubTable.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/5e3a/src/aes_wrapper.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/5e3a/src/aes_axi_slave.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ip/design_1_aes_axi_slave_0_0/sim/design_1_aes_axi_slave_0_0.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/1fe1/hdl/SHA3_hardware_new_slave_lite_v1_0_S01_AXI.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/1fe1/src/F_permutation.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/1fe1/src/Keccak.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/1fe1/src/Padder.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/1fe1/src/Padder1.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/1fe1/src/rconst2in1.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/1fe1/src/round2in1.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/1fe1/hdl/SHA3_hardware_new.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ip/design_1_SHA3_hardware_new_0_0/sim/design_1_SHA3_hardware_new_0_0.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/f662/hdl/RSA_mark03_slave_lite_v1_0_S00_AXI.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/f662/src/RSA_core.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ipshared/f662/hdl/RSA_mark03.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ip/design_1_RSA_mark03_0_0/sim/design_1_RSA_mark03_0_0.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ip/design_1_blk_mem_gen_0_0/sim/design_1_blk_mem_gen_0_0.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ip/design_1_clk_wiz_0_0/design_1_clk_wiz_0_0_clk_wiz.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ip/design_1_clk_wiz_0_0/design_1_clk_wiz_0_0.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ip/design_1_xlslice_0_0/sim/design_1_xlslice_0_0.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ip/design_1_blk_mem_gen_1_0/sim/design_1_blk_mem_gen_1_0.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/sim/design_1.v
F:/advance_topic/Ibex_SoC/Ibex_SoC.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v
}
set rest_files [string map [list F:/advance_topic/Ibex_SoC $soc_root] $rest_files]
set stub_file "$soc_root/Ibex_SoC.ip_user_files/bd/design_1/ip/design_1_ibex_core_0_0/sim/design_1_ibex_core_0_0.sv"

set vhdl_files {
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ip/design_1_axi_bram_ctrl_0_0/sim/design_1_axi_bram_ctrl_0_0.vhd
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ip/design_1_proc_sys_reset_0_0/sim/design_1_proc_sys_reset_0_0.vhd
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ip/design_1_axi_uartlite_0_0/sim/design_1_axi_uartlite_0_0.vhd
F:/advance_topic/Ibex_SoC/Ibex_SoC.ip_user_files/bd/design_1/ip/design_1_addsub_bootoffset_0_0/sim/design_1_addsub_bootoffset_0_0.vhd
}

set vhdl_files [string map [list F:/advance_topic/Ibex_SoC $soc_root] $vhdl_files]
set tb_file "$full_dir/$tb_name.v"
set glbl    "$::env(XILINX_VIVADO)/data/verilog/src/glbl.v"

set workdir "$full_dir/_sim_run"
file mkdir $workdir
cd $workdir
set ::env(PATH) "$::env(XILINX_VIVADO)/tps/mingw/10.0.0/win64.o/nt/bin;$::env(PATH)"
catch {file delete -force xsim.dir}

set xvlog "$::env(XILINX_VIVADO)/bin/xvlog.bat"
set xvhdl "$::env(XILINX_VIVADO)/bin/xvhdl.bat"
set xelab "$::env(XILINX_VIVADO)/bin/xelab.bat"
set xsim  "$::env(XILINX_VIVADO)/bin/xsim.bat"

puts "\n===== buoc MIF chuyen $coe_name.coe -> .mif de blk_mem_gen doc luc mo phong ====="
# blk_mem_gen doc file .mif (khong phai .coe truc tiep) khi elaborate; Vivado
# tu convert luc Generate Output Products - vi day la chay tay nen tu convert:
# doc .coe (radix=16, cac tu cach nhau bang dau phay) -> ghi .mif (1 tu/dong,
# khong dau phay, ket thuc file khong co dong trong).
set coe_fp [open $coe_src r]
set coe_data [read $coe_fp]
close $coe_fp
regexp {memory_initialization_vector=\s*(.*)} $coe_data -> vec
set words [regexp -all -inline {[0-9A-Fa-f]+} $vec]
set mif_path "$workdir/design_1_blk_mem_gen_0_0.mif"
set mif_fp [open $mif_path w]
foreach w $words {
    # .mif cua blk_mem_gen can NHI PHAN 32-bit/dong (khong phai hex nhu .coe)
    set dec [scan $w %x]
    set binstr ""
    for {set i 31} {$i >= 0} {incr i -1} {
        append binstr [expr {($dec >> $i) & 1}]
    }
    puts $mif_fp $binstr
}
close $mif_fp
puts "Da ghi [llength $words] tu vao $mif_path"

puts "\n===== buoc 1 xvlog -sv: 56 file ibex ====="
set cmd [concat $xvlog -sv -d SYNTHESIS -d FPGA_XILINX -i $ibex_dir $ibex_files]
if {[catch {exec {*}$cmd} out]} { puts $out; puts "THAT BAI buoc 1"; exit 1 }

puts "===== buoc 2 xvlog: stub ibex_core_0 ====="
if {[catch {exec $xvlog -sv -d SYNTHESIS -d FPGA_XILINX $stub_file} out]} { puts $out; puts "THAT BAI buoc 2"; exit 1 }

puts "===== buoc 3 xvlog: 32 file con lai ====="
set cmd [concat $xvlog -sv -d SYNTHESIS -d FPGA_XILINX $rest_files]
if {[catch {exec {*}$cmd} out]} { puts $out; puts "THAT BAI buoc 3"; exit 1 }

puts "===== buoc 4 xvhdl: 4 file VHDL ====="
set cmd [concat $xvhdl $vhdl_files]
if {[catch {exec {*}$cmd} out]} { puts $out; puts "THAT BAI buoc 4"; exit 1 }

puts "===== buoc 5 xvlog: testbench ($tb_name) + glbl ====="
if {[catch {exec $xvlog $tb_file} out]} { puts $out; puts "THAT BAI buoc 5"; exit 1 }
if {[catch {exec $xvlog $glbl} out]} { puts $out; puts "THAT BAI buoc 5b"; exit 1 }

puts "===== buoc 6 xelab ====="
set libs {xil_defaultlib generic_baseblocks_v2_1_2 axi_infrastructure_v1_1_0 axi_register_slice_v2_1_33 fifo_generator_v13_2_11 axi_data_fifo_v2_1_32 axi_crossbar_v2_1_34 axi_protocol_converter_v2_1_33 axi_bram_ctrl_v4_1_11 blk_mem_gen_v8_4_9 lib_cdc_v1_0_3 proc_sys_reset_v5_0_16 xlslice_v1_0_4 axi_lite_ipif_v3_0_4 lib_pkg_v1_0_4 lib_srl_fifo_v1_0_4 axi_uartlite_v2_0_37 xbip_utils_v3_0_14 c_reg_fd_v12_0_10 xbip_dsp48_wrapper_v3_0_6 xbip_pipe_v3_0_10 c_addsub_v12_0_19 uvm unisims_ver unimacro_ver secureip xpm}
set largs {}
foreach l $libs { lappend largs "-L" $l }
set snap "${tb_name}_snap"
set cmd [concat $xelab --incr --debug all --relax {*}$largs --snapshot $snap work.$tb_name work.glbl -timescale 1ns/1ps]
if {[catch {exec {*}$cmd} out]} { puts $out; puts "THAT BAI buoc 6 xelab"; exit 1 }
puts "xelab OK"

puts "\n===== buoc 7 xsim: chay + ghi waveform (.wdb) ====="
# --debug all (thay vi typical) de thay duoc toan bo tin hieu noi bo khi
# mo waveform - typical se an bot tin hieu bi toi uu.
set wdb_path "$workdir/${tb_name}.wdb"
set runner_path "$workdir/_runner.tcl"
set runner_fp [open $runner_path w]
puts $runner_fp "log_wave -recursive *"
puts $runner_fp "run -all"
puts $runner_fp "close_wave_config"
close $runner_fp

if {[catch {exec $xsim $snap -wdb $wdb_path -t $runner_path} out]} {
    puts $out
} else {
    puts $out
}
puts "\n>>> Waveform da ghi ra: $wdb_path"
puts ">>> Mo trong Vivado: File > Open Waveform Database... chon file .wdb o tren"
puts ">>> (hoac keo tha file .wdb vao cua so Vivado dang mo)"
puts "\n===== HET ====="
