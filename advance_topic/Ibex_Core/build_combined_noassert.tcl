# build_combined_noassert.tcl
#
# Goc gay loi packaging IP Ibex vao Vivado: macro `ASSERT/`COVER/`ASSUME
# cua lowRISC (dinh nghia trong prim_assert_dummy_macros.svh) dung THAM SO
# MAC DINH trong `define (vd `clk = `ASSERT_DEFAULT_CLK) - cu phap nay bo
# phan tich cu phap YEU cua IP Packager (khac han xvlog/xelab that - 2 cong
# cu nay hieu hoan toan dung) khong xu ly duoc, gay loi Syntax error day
# chuyen ngay tu loi goi `ASSERT dau tien (da xac nhan bang test doc lap).
#
# O che do SYNTHESIS (luon bat cho project nay), macro `ASSERT/`COVER/
# `ASSUME deu RONG HOAN TOAN (khong lam gi) - da doc truc tiep noi dung
# prim_assert_dummy_macros.svh de xac nhan. Vi vay XOA HOAN TOAN cac loi
# goi nay khoi ban dung de DONG GOI khong doi hanh vi khi SYNTHESIS duoc
# dinh nghia (truong hop duy nhat file nay duoc dung - mo phong/tong hop
# cho SoC, khong dung cho DV/formal that su can assertion).
#
# Ket qua: gop 56 file RTL (dung thu tu tu ibex_compile_order.f) thanh 1
# file DUY NHAT, bo loi goi assert (dung thuat toan can bang ngoac de xu
# ly dung ca truong hop trai nhieu dong - da test voi bo file trong
# firmware_testbench/Ibex_FULL), roi dong
# goi lai IP CUNG VLNV (rissp.local:user:ibex_core:1.0) de Ibex_SoC khong
# can doi tham chieu IP.

set script_dir [file dirname [file normalize [info script]]]
set repo_root  [file normalize [file join $script_dir .. ..]]
set src_dir    [file join $script_dir ip_repo src]
set order_file [file join $repo_root firmware_testbench Ibex_FULL ibex_compile_order.f]
set out_file   [file join $script_dir ibex_axi_top_combined.sv]

set fp [open $order_file r]
set file_list {}
while {[gets $fp l] >= 0} {
    set l [string trim $l]
    if {$l ne ""} { lappend file_list $l }
}
close $fp

# --- gop toan bo noi dung thanh 1 chuoi lon, tach thanh mang dong ---
set all_content {}
foreach fname $file_list {
    lappend all_content "// ===== $fname ====="
    set ffp [open "$src_dir/$fname" r]
    set content [read $ffp]
    close $ffp
    foreach line [split $content "\n"] { lappend all_content $line }
    lappend all_content ""
}

# --- bo loi goi `ASSERT/`COVER/`ASSUME, dung thuat toan can bang ngoac
#     de xu ly dung ca truong hop trai nhieu dong ---
set out {}
set i 0
set n [llength $all_content]
set stripped_count 0
while {$i < $n} {
    set line [lindex $all_content $i]
    if {[regexp {^\s*`(ASSERT|COVER|ASSUME)[A-Za-z_]*\s*\(} $line]} {
        set balance 0
        set j $i
        while {1} {
            set cur [lindex $all_content $j]
            foreach ch [split $cur ""] {
                if {$ch eq "("} { incr balance }
                if {$ch eq ")"} { incr balance -1 }
            }
            if {$balance <= 0} { break }
            incr j
            if {$j >= $n} { break }
        }
        incr stripped_count
        lappend out "// (da bo loi goi \`ASSERT/COVER/ASSUME - rong khi SYNTHESIS)"
        for {set k [expr {$i+1}]} {$k <= $j} {incr k} { lappend out "" }
        set i [expr {$j+1}]
    } else {
        lappend out $line
        incr i
    }
}

set ofp [open $out_file w]
puts $ofp [join $out "\n"]
close $ofp

puts "Da bo $stripped_count loi goi ASSERT/COVER/ASSUME"
puts "Da ghi file gop: $out_file"
puts "So dong: [llength $out]"
