# package_ibex_ip.tcl
# Tao 1 Vivado project (Ibex_Core) tai F:/advance_topic va dong goi
# ibex_axi_top thanh 1 IP tai cho - tuong duong quy trinh GUI da dung cho
# RISSP_CORE, xem Docs/Vivado.md. Chay:
#   vivado -mode batch -source package_ibex_ip.tcl
#
# LUU Y: 2 Verilog define bat buoc (SYNTHESIS, FPGA_XILINX) duoc set o
# fileset cua PROJECT NAY (dung de package) - khi dua IP nay vao 1 SoC
# project khac, PHAI set lai 2 define nay o project do (xem
# IBEX_CORE/README.md muc "Viec con lai" buoc 2). Property verilog_define
# cua fileset khong tu dong di theo IP khi package.

set part      xc7z020clg484-1
set proj_name ibex_core
set proj_dir  F:/advance_topic/Ibex_Core
set rtl_dir   F:/RISSP_cORE/IBEX_CORE/rtl
set filelist  F:/RISSP_cORE/IBEX_CORE/compile_order.f
set ip_root   F:/advance_topic/Ibex_Core/ip_repo

create_project $proj_name $proj_dir -part $part -force

# ---------------------------------------------------------------
# Add TOAN BO file vat ly trong rtl/ (khong chi 111 file trong
# compile_order.f) - QUAN TRONG: prim_assert.sv co `include re nhanh
# theo `ifdef SYNTHESIS (prim_assert_dummy_macros.svh vs
# prim_assert_standard_macros.svh). Neu chi add 111 file roi de Vivado
# tu "do" include dang active luc dong goi, no CHI thay 1 trong 2 nhanh
# (tuy SYNTHESIS co dang bat luc nay hay khong) va KHONG dong goi nhanh
# con lai -> IP thieu file khi dung o 1 fileset khac co define khac (vd
# sim_1 cua project SoC khac khong bat SYNTHESIS). Da gap loi that: IP
# dong lan dau thieu prim_assert_standard_macros.svh, gay ca chuoi loi
# "use of undefined macro ASSERT" + syntax error khi mo phong trong
# project SoC khac. Fix: add toan bo file vat ly bang glob, dam bao ca
# 2 nhanh include deu co mat trong IP bat ke trang thai define luc
# package.
# ---------------------------------------------------------------
set all_rtl_files [glob -nocomplain "$rtl_dir/*.sv" "$rtl_dir/*.v" "$rtl_dir/*.svh"]
add_files -norecurse -fileset sources_1 $all_rtl_files
set_property top ibex_axi_top [get_filesets sources_1]
update_compile_order -fileset sources_1

# rtl_files (danh sach + thu tu compile that su, dung de bao cao cuoi)
set fp [open $filelist r]
set rtl_files {}
while {[gets $fp line] >= 0} {
    set line [string trim $line]
    if {$line ne ""} {
        lappend rtl_files "$rtl_dir/$line"
    }
}
close $fp

# 2 define bat buoc (xem README) - set cho ca 2 fileset trong project nay
set_property verilog_define {SYNTHESIS FPGA_XILINX} [get_filesets sources_1]
set_property verilog_define {SYNTHESIS FPGA_XILINX} [get_filesets sim_1]

# ---------------------------------------------------------------
# Dong goi thanh IP - tuong duong wizard "Package a specified directory"
# ---------------------------------------------------------------
ipx::package_project -root_dir $ip_root -vendor rissp.local -library user \
    -taxonomy /UserIP -import_files -set_current true

set core [ipx::current_core]
set_property name             ibex_core                                    $core
set_property display_name     {Ibex RV32 Core (AXI wrapper)}                $core
set_property version          1.0                                          $core
set_property vendor_display_name {rissp.local}                             $core
set_property description {lowRISC Ibex RV32 core (commit c6edaa4060b1a3cd27fda928058db4f0ee3d24bd, pre-CHERIoT), wrapped by ibex_axi_top.sv. Dung CHUNG axi_rissp_master.v (khong sua) lam cau AXI4-Lite dmem voi rissp_core, de so sanh cong bang 2 loi CPU trong cung 1 SoC. imem_addr/imem_rdata la cong BRAM tho 1-chu-ky (khong phai bus chuan), noi tay vao Block Memory Generator. LUU Y: lenh dau tien fetch tai boot_addr_i+0x80 (reset vector co dinh cua Ibex), KHAC RISSP (boot PC=0) - xem README cua IBEX_CORE trong repo nguon.} $core

set_property supported_families {zynq Production} $core

# ---------------------------------------------------------------
# KIEM TRA con thieu file nao so voi rtl/ khong (ipx::package_project van
# tu cat file "khong dung toi" theo phan tich cua no, KE CA khi da add du
# 119 file vao project truoc do - da xac nhan that, xem README muc "Bug
# thu 4"). Neu con thieu, PHAI tu sua tay: (1) copy file thieu vao
# $ip_root/src/, (2) them 1 khoi <spirit:file> vao component.xml (2 cho,
# khop fileset design+sim) theo dung format cua file .svh ben canh no.
# Script nay KHONG tu sua duoc buoc (2) vi can Tcl API rieng chua kiem
# chung on dinh - chi canh bao ra day de khong bi bo sot.
# ---------------------------------------------------------------
set missing_files {}
foreach f $all_rtl_files {
    set base [file tail $f]
    if {![file exists "$ip_root/src/$base"]} {
        lappend missing_files $base
    }
}
if {[llength $missing_files] > 0} {
    puts "CANH BAO: $ip_root/src/ THIEU [llength $missing_files] file so voi rtl/:"
    foreach f $missing_files { puts "  - $f" }
    puts "==> Phai tu sua tay component.xml (xem README IBEX_CORE muc \"Bug thu 4\")."
}

ipx::save_core $core

puts "===== DONE: IP packaged tai $ip_root ====="
puts "Top module: ibex_axi_top"
puts "So file RTL da add (tat ca, ke ca header): [llength $all_rtl_files]"
puts "So file trong compile_order.f (khong tinh header): [llength $rtl_files]"

close_project
