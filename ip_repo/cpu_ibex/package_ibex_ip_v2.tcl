# package_ibex_ip_v2.tcl
#
# Dong goi lai IP Ibex, sua loi khien Vivado khong the tu dò du file mo
# phong khi dat trong Block Design (xem build_combined_noassert.tcl de
# biet nguyen nhan goc: macro `ASSERT dung tham so mac dinh lam IP
# Packager parse loi). Dung 1 file DUY NHAT (da gop + bo assert calls)
# thay vi 63 file rieng le nhu ban cu - da test doc lap xac nhan Vivado
# tu nhan dien du file trong compile_order khi dung cach nay.
#
# GIU NGUYEN VLNV (rissp.local:user:ibex_core:1.0) de Ibex_SoC khong can
# doi tham chieu IP trong Block Design - chi can Refresh/Upgrade IP.
#
# Chay: vivado -mode batch -source package_ibex_ip_v2.tcl

set part      xc7z020clg484-1
set proj_name ibex_core_v2
set proj_dir  F:/advance_topic/Ibex_Core/_pkg_v2_proj
set combined  F:/advance_topic/Ibex_Core/ibex_axi_top_combined.sv
set src_dir   F:/advance_topic/Ibex_Core/ip_repo/src
set ip_root   F:/advance_topic/Ibex_Core/ip_repo

set include_only_files [list \
    "$src_dir/prim_assert.sv" \
    "$src_dir/prim_assert_dummy_macros.svh" \
    "$src_dir/prim_assert_standard_macros.svh" \
    "$src_dir/prim_assert_sec_cm.svh" \
    "$src_dir/prim_flop_macros.sv" \
    "$src_dir/dv_fcov_macros.svh" \
]

create_project $proj_name $proj_dir -part $part -force

add_files -norecurse -fileset sources_1 $combined
add_files -norecurse -fileset sources_1 $include_only_files
set_property top ibex_axi_top [get_filesets sources_1]
set_property verilog_define {SYNTHESIS FPGA_XILINX} [get_filesets sources_1]
set_property verilog_define {SYNTHESIS FPGA_XILINX} [get_filesets sim_1]
set_property include_dirs $src_dir [get_filesets sources_1]
update_compile_order -fileset sources_1

ipx::package_project -root_dir $ip_root -vendor rissp.local -library user \
    -taxonomy /UserIP -import_files -set_current true

set core [ipx::current_core]
set_property name             ibex_core                                    $core
set_property display_name     {Ibex RV32 Core (AXI wrapper)}                $core
set_property version          1.0                                          $core
set_property vendor_display_name {rissp.local}                             $core
set_property description {lowRISC Ibex RV32 core (commit c6edaa4060b1a3cd27fda928058db4f0ee3d24bd, pre-CHERIoT), wrapped by ibex_axi_top.sv. Dung CHUNG axi_rissp_master.v (khong sua) lam cau AXI4-Lite dmem voi rissp_core, de so sanh cong bang 2 loi CPU trong cung 1 SoC. imem_addr/imem_rdata la cong BRAM tho 1-chu-ky (khong phai bus chuan), noi tay vao Block Memory Generator. LUU Y: lenh dau tien fetch tai boot_addr_i+0x80 (reset vector co dinh cua Ibex), KHAC RISSP (boot PC=0). Ban v2 (2026-08-14): gop 56 file RTL thanh 1 file + bo loi goi `ASSERT/COVER/ASSUME (rong khi SYNTHESIS) de sua loi Vivado khong tu do du file mo phong trong Block Design.} $core

set_property supported_families {zynq Production} $core

# Cac tham so RV32M/RV32B/RV32ZC/RV32E/ICache/PMPEnable/MHPMCounterNum/
# BootAddr/HartId duoc TU DONG suy luan tu khai bao "parameter" trong
# module header cua ibex_axi_top (giong het ban goc) - khong can set tay,
# set_property CONFIG.* truc tiep tren core se loi "Unknown property" vi
# GUI parameter chua duoc tao o buoc nay.

ipx::save_core $core

puts "\n===== KIEM TRA file trong ip_repo/src sau dong goi ====="
puts [exec cmd /c dir /b "$ip_root/src"]

close_project

puts "\n===== DONE: IP v2 dong goi tai $ip_root ====="
