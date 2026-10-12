# build_combined_noassert.tcl
#
# Vivado's IP Packager cannot parse lowRISC's `ASSERT/`COVER/`ASSUME macros
# (prim_assert_dummy_macros.svh), which use default macro arguments
# (e.g. `clk = `ASSERT_DEFAULT_CLK); xvlog/xelab accept them. With SYNTHESIS
# defined (always the case for this project) these macros expand to nothing,
# so removing the calls does not change behaviour.
#
# This script concatenates the 56 RTL files (in ibex_compile_order.f order)
# into a single file, strips the assertion calls (bracket matching handles
# multi-line calls) and repackages the IP with the same VLNV
# (rissp.local:user:ibex_core:1.0), so Ibex_SoC keeps its IP reference.

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
