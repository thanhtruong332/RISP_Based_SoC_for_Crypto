
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2024.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg484-1
   set_property BOARD_PART digilentinc.com:zedboard:part0:1.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
rissp.local:user:ibex_core:1.0\
xilinx.com:user:aes_axi_slave:1.0\
xilinx.com:user:SHA3_hardware_new:1.0\
xilinx.com:user:RSA_mark03:1.0\
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:xlslice:1.0\
xilinx.com:ip:axi_uartlite:2.0\
xilinx.com:ip:c_addsub:12.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set UART_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART_0 ]


  # Create ports
  set clk_in1_0 [ create_bd_port -dir I -type clk clk_in1_0 ]
  set reset_0 [ create_bd_port -dir I -type rst reset_0 ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $reset_0

  # Create instance: ibex_core_0, and set properties
  set ibex_core_0 [ create_bd_cell -type ip -vlnv rissp.local:user:ibex_core:1.0 ibex_core_0 ]
  set_property CONFIG.RV32M {0} $ibex_core_0


  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [list \
    CONFIG.ENABLE_ADVANCED_OPTIONS {0} \
    CONFIG.ENABLE_PROTOCOL_CHECKERS {0} \
    CONFIG.M00_HAS_DATA_FIFO {0} \
    CONFIG.M00_HAS_REGSLICE {0} \
    CONFIG.M00_ISSUANCE {0} \
    CONFIG.M00_SECURE {0} \
    CONFIG.M01_HAS_DATA_FIFO {0} \
    CONFIG.M01_HAS_REGSLICE {0} \
    CONFIG.M01_ISSUANCE {0} \
    CONFIG.M01_SECURE {0} \
    CONFIG.M02_HAS_DATA_FIFO {0} \
    CONFIG.M02_HAS_REGSLICE {0} \
    CONFIG.M02_ISSUANCE {0} \
    CONFIG.M02_SECURE {0} \
    CONFIG.M03_HAS_DATA_FIFO {0} \
    CONFIG.M03_HAS_REGSLICE {0} \
    CONFIG.M03_ISSUANCE {0} \
    CONFIG.M03_SECURE {0} \
    CONFIG.M04_HAS_DATA_FIFO {0} \
    CONFIG.M04_HAS_REGSLICE {0} \
    CONFIG.M04_ISSUANCE {0} \
    CONFIG.M04_SECURE {0} \
    CONFIG.M05_HAS_DATA_FIFO {0} \
    CONFIG.M05_HAS_REGSLICE {0} \
    CONFIG.M05_ISSUANCE {0} \
    CONFIG.M05_SECURE {0} \
    CONFIG.M06_HAS_DATA_FIFO {0} \
    CONFIG.M06_HAS_REGSLICE {0} \
    CONFIG.M06_ISSUANCE {0} \
    CONFIG.M06_SECURE {0} \
    CONFIG.M07_HAS_DATA_FIFO {0} \
    CONFIG.M07_HAS_REGSLICE {0} \
    CONFIG.M07_ISSUANCE {0} \
    CONFIG.M07_SECURE {0} \
    CONFIG.M08_HAS_DATA_FIFO {0} \
    CONFIG.M08_HAS_REGSLICE {0} \
    CONFIG.M08_ISSUANCE {0} \
    CONFIG.M08_SECURE {0} \
    CONFIG.M09_HAS_DATA_FIFO {0} \
    CONFIG.M09_HAS_REGSLICE {0} \
    CONFIG.M09_ISSUANCE {0} \
    CONFIG.M09_SECURE {0} \
    CONFIG.M10_HAS_DATA_FIFO {0} \
    CONFIG.M10_HAS_REGSLICE {0} \
    CONFIG.M10_ISSUANCE {0} \
    CONFIG.M10_SECURE {0} \
    CONFIG.M11_HAS_DATA_FIFO {0} \
    CONFIG.M11_HAS_REGSLICE {0} \
    CONFIG.M11_ISSUANCE {0} \
    CONFIG.M11_SECURE {0} \
    CONFIG.M12_HAS_DATA_FIFO {0} \
    CONFIG.M12_HAS_REGSLICE {0} \
    CONFIG.M12_ISSUANCE {0} \
    CONFIG.M12_SECURE {0} \
    CONFIG.M13_HAS_DATA_FIFO {0} \
    CONFIG.M13_HAS_REGSLICE {0} \
    CONFIG.M13_ISSUANCE {0} \
    CONFIG.M13_SECURE {0} \
    CONFIG.M14_HAS_DATA_FIFO {0} \
    CONFIG.M14_HAS_REGSLICE {0} \
    CONFIG.M14_ISSUANCE {0} \
    CONFIG.M14_SECURE {0} \
    CONFIG.M15_HAS_DATA_FIFO {0} \
    CONFIG.M15_HAS_REGSLICE {0} \
    CONFIG.M15_ISSUANCE {0} \
    CONFIG.M15_SECURE {0} \
    CONFIG.M16_HAS_DATA_FIFO {0} \
    CONFIG.M16_HAS_REGSLICE {0} \
    CONFIG.M16_ISSUANCE {0} \
    CONFIG.M16_SECURE {0} \
    CONFIG.M17_HAS_DATA_FIFO {0} \
    CONFIG.M17_HAS_REGSLICE {0} \
    CONFIG.M17_ISSUANCE {0} \
    CONFIG.M17_SECURE {0} \
    CONFIG.M18_HAS_DATA_FIFO {0} \
    CONFIG.M18_HAS_REGSLICE {0} \
    CONFIG.M18_ISSUANCE {0} \
    CONFIG.M18_SECURE {0} \
    CONFIG.M19_HAS_DATA_FIFO {0} \
    CONFIG.M19_HAS_REGSLICE {0} \
    CONFIG.M19_ISSUANCE {0} \
    CONFIG.M19_SECURE {0} \
    CONFIG.M20_HAS_DATA_FIFO {0} \
    CONFIG.M20_HAS_REGSLICE {0} \
    CONFIG.M20_ISSUANCE {0} \
    CONFIG.M20_SECURE {0} \
    CONFIG.M21_HAS_DATA_FIFO {0} \
    CONFIG.M21_HAS_REGSLICE {0} \
    CONFIG.M21_ISSUANCE {0} \
    CONFIG.M21_SECURE {0} \
    CONFIG.M22_HAS_DATA_FIFO {0} \
    CONFIG.M22_HAS_REGSLICE {0} \
    CONFIG.M22_ISSUANCE {0} \
    CONFIG.M22_SECURE {0} \
    CONFIG.M23_HAS_DATA_FIFO {0} \
    CONFIG.M23_HAS_REGSLICE {0} \
    CONFIG.M23_ISSUANCE {0} \
    CONFIG.M23_SECURE {0} \
    CONFIG.M24_HAS_DATA_FIFO {0} \
    CONFIG.M24_HAS_REGSLICE {0} \
    CONFIG.M24_ISSUANCE {0} \
    CONFIG.M24_SECURE {0} \
    CONFIG.M25_HAS_DATA_FIFO {0} \
    CONFIG.M25_HAS_REGSLICE {0} \
    CONFIG.M25_ISSUANCE {0} \
    CONFIG.M25_SECURE {0} \
    CONFIG.M26_HAS_DATA_FIFO {0} \
    CONFIG.M26_HAS_REGSLICE {0} \
    CONFIG.M26_ISSUANCE {0} \
    CONFIG.M26_SECURE {0} \
    CONFIG.M27_HAS_DATA_FIFO {0} \
    CONFIG.M27_HAS_REGSLICE {0} \
    CONFIG.M27_ISSUANCE {0} \
    CONFIG.M27_SECURE {0} \
    CONFIG.M28_HAS_DATA_FIFO {0} \
    CONFIG.M28_HAS_REGSLICE {0} \
    CONFIG.M28_ISSUANCE {0} \
    CONFIG.M28_SECURE {0} \
    CONFIG.M29_HAS_DATA_FIFO {0} \
    CONFIG.M29_HAS_REGSLICE {0} \
    CONFIG.M29_ISSUANCE {0} \
    CONFIG.M29_SECURE {0} \
    CONFIG.M30_HAS_DATA_FIFO {0} \
    CONFIG.M30_HAS_REGSLICE {0} \
    CONFIG.M30_ISSUANCE {0} \
    CONFIG.M30_SECURE {0} \
    CONFIG.M31_HAS_DATA_FIFO {0} \
    CONFIG.M31_HAS_REGSLICE {0} \
    CONFIG.M31_ISSUANCE {0} \
    CONFIG.M31_SECURE {0} \
    CONFIG.M32_HAS_DATA_FIFO {0} \
    CONFIG.M32_HAS_REGSLICE {0} \
    CONFIG.M32_ISSUANCE {0} \
    CONFIG.M32_SECURE {0} \
    CONFIG.M33_HAS_DATA_FIFO {0} \
    CONFIG.M33_HAS_REGSLICE {0} \
    CONFIG.M33_ISSUANCE {0} \
    CONFIG.M33_SECURE {0} \
    CONFIG.M34_HAS_DATA_FIFO {0} \
    CONFIG.M34_HAS_REGSLICE {0} \
    CONFIG.M34_ISSUANCE {0} \
    CONFIG.M34_SECURE {0} \
    CONFIG.M35_HAS_DATA_FIFO {0} \
    CONFIG.M35_HAS_REGSLICE {0} \
    CONFIG.M35_ISSUANCE {0} \
    CONFIG.M35_SECURE {0} \
    CONFIG.M36_HAS_DATA_FIFO {0} \
    CONFIG.M36_HAS_REGSLICE {0} \
    CONFIG.M36_ISSUANCE {0} \
    CONFIG.M36_SECURE {0} \
    CONFIG.M37_HAS_DATA_FIFO {0} \
    CONFIG.M37_HAS_REGSLICE {0} \
    CONFIG.M37_ISSUANCE {0} \
    CONFIG.M37_SECURE {0} \
    CONFIG.M38_HAS_DATA_FIFO {0} \
    CONFIG.M38_HAS_REGSLICE {0} \
    CONFIG.M38_ISSUANCE {0} \
    CONFIG.M38_SECURE {0} \
    CONFIG.M39_HAS_DATA_FIFO {0} \
    CONFIG.M39_HAS_REGSLICE {0} \
    CONFIG.M39_ISSUANCE {0} \
    CONFIG.M39_SECURE {0} \
    CONFIG.M40_HAS_DATA_FIFO {0} \
    CONFIG.M40_HAS_REGSLICE {0} \
    CONFIG.M40_ISSUANCE {0} \
    CONFIG.M40_SECURE {0} \
    CONFIG.M41_HAS_DATA_FIFO {0} \
    CONFIG.M41_HAS_REGSLICE {0} \
    CONFIG.M41_ISSUANCE {0} \
    CONFIG.M41_SECURE {0} \
    CONFIG.M42_HAS_DATA_FIFO {0} \
    CONFIG.M42_HAS_REGSLICE {0} \
    CONFIG.M42_ISSUANCE {0} \
    CONFIG.M42_SECURE {0} \
    CONFIG.M43_HAS_DATA_FIFO {0} \
    CONFIG.M43_HAS_REGSLICE {0} \
    CONFIG.M43_ISSUANCE {0} \
    CONFIG.M43_SECURE {0} \
    CONFIG.M44_HAS_DATA_FIFO {0} \
    CONFIG.M44_HAS_REGSLICE {0} \
    CONFIG.M44_ISSUANCE {0} \
    CONFIG.M44_SECURE {0} \
    CONFIG.M45_HAS_DATA_FIFO {0} \
    CONFIG.M45_HAS_REGSLICE {0} \
    CONFIG.M45_ISSUANCE {0} \
    CONFIG.M45_SECURE {0} \
    CONFIG.M46_HAS_DATA_FIFO {0} \
    CONFIG.M46_HAS_REGSLICE {0} \
    CONFIG.M46_ISSUANCE {0} \
    CONFIG.M46_SECURE {0} \
    CONFIG.M47_HAS_DATA_FIFO {0} \
    CONFIG.M47_HAS_REGSLICE {0} \
    CONFIG.M47_ISSUANCE {0} \
    CONFIG.M47_SECURE {0} \
    CONFIG.M48_HAS_DATA_FIFO {0} \
    CONFIG.M48_HAS_REGSLICE {0} \
    CONFIG.M48_ISSUANCE {0} \
    CONFIG.M48_SECURE {0} \
    CONFIG.M49_HAS_DATA_FIFO {0} \
    CONFIG.M49_HAS_REGSLICE {0} \
    CONFIG.M49_ISSUANCE {0} \
    CONFIG.M49_SECURE {0} \
    CONFIG.M50_HAS_DATA_FIFO {0} \
    CONFIG.M50_HAS_REGSLICE {0} \
    CONFIG.M50_ISSUANCE {0} \
    CONFIG.M50_SECURE {0} \
    CONFIG.M51_HAS_DATA_FIFO {0} \
    CONFIG.M51_HAS_REGSLICE {0} \
    CONFIG.M51_ISSUANCE {0} \
    CONFIG.M51_SECURE {0} \
    CONFIG.M52_HAS_DATA_FIFO {0} \
    CONFIG.M52_HAS_REGSLICE {0} \
    CONFIG.M52_ISSUANCE {0} \
    CONFIG.M52_SECURE {0} \
    CONFIG.M53_HAS_DATA_FIFO {0} \
    CONFIG.M53_HAS_REGSLICE {0} \
    CONFIG.M53_ISSUANCE {0} \
    CONFIG.M53_SECURE {0} \
    CONFIG.M54_HAS_DATA_FIFO {0} \
    CONFIG.M54_HAS_REGSLICE {0} \
    CONFIG.M54_ISSUANCE {0} \
    CONFIG.M54_SECURE {0} \
    CONFIG.M55_HAS_DATA_FIFO {0} \
    CONFIG.M55_HAS_REGSLICE {0} \
    CONFIG.M55_ISSUANCE {0} \
    CONFIG.M55_SECURE {0} \
    CONFIG.M56_HAS_DATA_FIFO {0} \
    CONFIG.M56_HAS_REGSLICE {0} \
    CONFIG.M56_ISSUANCE {0} \
    CONFIG.M56_SECURE {0} \
    CONFIG.M57_HAS_DATA_FIFO {0} \
    CONFIG.M57_HAS_REGSLICE {0} \
    CONFIG.M57_ISSUANCE {0} \
    CONFIG.M57_SECURE {0} \
    CONFIG.M58_HAS_DATA_FIFO {0} \
    CONFIG.M58_HAS_REGSLICE {0} \
    CONFIG.M58_ISSUANCE {0} \
    CONFIG.M58_SECURE {0} \
    CONFIG.M59_HAS_DATA_FIFO {0} \
    CONFIG.M59_HAS_REGSLICE {0} \
    CONFIG.M59_ISSUANCE {0} \
    CONFIG.M59_SECURE {0} \
    CONFIG.M60_HAS_DATA_FIFO {0} \
    CONFIG.M60_HAS_REGSLICE {0} \
    CONFIG.M60_ISSUANCE {0} \
    CONFIG.M60_SECURE {0} \
    CONFIG.M61_HAS_DATA_FIFO {0} \
    CONFIG.M61_HAS_REGSLICE {0} \
    CONFIG.M61_ISSUANCE {0} \
    CONFIG.M61_SECURE {0} \
    CONFIG.M62_HAS_DATA_FIFO {0} \
    CONFIG.M62_HAS_REGSLICE {0} \
    CONFIG.M62_ISSUANCE {0} \
    CONFIG.M62_SECURE {0} \
    CONFIG.M63_HAS_DATA_FIFO {0} \
    CONFIG.M63_HAS_REGSLICE {0} \
    CONFIG.M63_ISSUANCE {0} \
    CONFIG.M63_SECURE {0} \
    CONFIG.NUM_MI {5} \
    CONFIG.NUM_SI {1} \
    CONFIG.PCHK_MAX_RD_BURSTS {2} \
    CONFIG.PCHK_MAX_WR_BURSTS {2} \
    CONFIG.PCHK_WAITS {0} \
    CONFIG.S00_ARB_PRIORITY {0} \
    CONFIG.S00_HAS_DATA_FIFO {0} \
    CONFIG.S00_HAS_REGSLICE {0} \
    CONFIG.S01_ARB_PRIORITY {0} \
    CONFIG.S01_HAS_DATA_FIFO {0} \
    CONFIG.S01_HAS_REGSLICE {0} \
    CONFIG.S02_ARB_PRIORITY {0} \
    CONFIG.S02_HAS_DATA_FIFO {0} \
    CONFIG.S02_HAS_REGSLICE {0} \
    CONFIG.S03_ARB_PRIORITY {0} \
    CONFIG.S03_HAS_DATA_FIFO {0} \
    CONFIG.S03_HAS_REGSLICE {0} \
    CONFIG.S04_ARB_PRIORITY {0} \
    CONFIG.S04_HAS_DATA_FIFO {0} \
    CONFIG.S04_HAS_REGSLICE {0} \
    CONFIG.S05_ARB_PRIORITY {0} \
    CONFIG.S05_HAS_DATA_FIFO {0} \
    CONFIG.S05_HAS_REGSLICE {0} \
    CONFIG.S06_ARB_PRIORITY {0} \
    CONFIG.S06_HAS_DATA_FIFO {0} \
    CONFIG.S06_HAS_REGSLICE {0} \
    CONFIG.S07_ARB_PRIORITY {0} \
    CONFIG.S07_HAS_DATA_FIFO {0} \
    CONFIG.S07_HAS_REGSLICE {0} \
    CONFIG.S08_ARB_PRIORITY {0} \
    CONFIG.S08_HAS_DATA_FIFO {0} \
    CONFIG.S08_HAS_REGSLICE {0} \
    CONFIG.S09_ARB_PRIORITY {0} \
    CONFIG.S09_HAS_DATA_FIFO {0} \
    CONFIG.S09_HAS_REGSLICE {0} \
    CONFIG.S10_ARB_PRIORITY {0} \
    CONFIG.S10_HAS_DATA_FIFO {0} \
    CONFIG.S10_HAS_REGSLICE {0} \
    CONFIG.S11_ARB_PRIORITY {0} \
    CONFIG.S11_HAS_DATA_FIFO {0} \
    CONFIG.S11_HAS_REGSLICE {0} \
    CONFIG.S12_ARB_PRIORITY {0} \
    CONFIG.S12_HAS_DATA_FIFO {0} \
    CONFIG.S12_HAS_REGSLICE {0} \
    CONFIG.S13_ARB_PRIORITY {0} \
    CONFIG.S13_HAS_DATA_FIFO {0} \
    CONFIG.S13_HAS_REGSLICE {0} \
    CONFIG.S14_ARB_PRIORITY {0} \
    CONFIG.S14_HAS_DATA_FIFO {0} \
    CONFIG.S14_HAS_REGSLICE {0} \
    CONFIG.S15_ARB_PRIORITY {0} \
    CONFIG.S15_HAS_DATA_FIFO {0} \
    CONFIG.S15_HAS_REGSLICE {0} \
    CONFIG.STRATEGY {0} \
    CONFIG.SYNCHRONIZATION_STAGES {3} \
    CONFIG.XBAR_DATA_WIDTH {32} \
  ] $axi_interconnect_0


  # Create instance: aes_axi_slave_0, and set properties
  set aes_axi_slave_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:aes_axi_slave:1.0 aes_axi_slave_0 ]

  # Create instance: SHA3_hardware_new_0, and set properties
  set SHA3_hardware_new_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:SHA3_hardware_new:1.0 SHA3_hardware_new_0 ]

  # Create instance: RSA_mark03_0, and set properties
  set RSA_mark03_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:RSA_mark03:1.0 RSA_mark03_0 ]

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.PROTOCOL {AXI4} \
    CONFIG.RD_CMD_OPTIMIZATION {0} \
    CONFIG.READ_LATENCY {1} \
    CONFIG.SINGLE_PORT_BRAM {1} \
    CONFIG.SUPPORTS_NARROW_BURST {0} \
    CONFIG.USE_ECC {0} \
  ] $axi_bram_ctrl_0


  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property -dict [list \
    CONFIG.AXI_Slave_Type {Memory_Slave} \
    CONFIG.AXI_Type {AXI4_Full} \
    CONFIG.Additional_Inputs_for_Power_Estimation {false} \
    CONFIG.Algorithm {Minimum_Area} \
    CONFIG.CTRL_ECC_ALGO {NONE} \
    CONFIG.Coe_File {d:/Viettel_semi/SE-RISSP_FULL/sha3_16.coe} \
    CONFIG.Disable_Collision_Warnings {false} \
    CONFIG.Disable_Out_of_Range_Warnings {false} \
    CONFIG.EN_SLEEP_PIN {false} \
    CONFIG.Enable_32bit_Address {false} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Fill_Remaining_Memory_Locations {true} \
    CONFIG.Interface_Type {Native} \
    CONFIG.Load_Init_File {true} \
    CONFIG.Memory_Type {Single_Port_ROM} \
    CONFIG.Port_A_Clock {100} \
    CONFIG.Port_A_Enable_Rate {100} \
    CONFIG.Port_A_Write_Rate {0} \
    CONFIG.Port_B_Clock {0} \
    CONFIG.Port_B_Enable_Rate {0} \
    CONFIG.Port_B_Write_Rate {0} \
    CONFIG.Register_PortA_Output_of_Memory_Core {false} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Remaining_Memory_Locations {0} \
    CONFIG.Use_RSTA_Pin {false} \
    CONFIG.Write_Depth_A {8192} \
    CONFIG.Write_Width_A {32} \
    CONFIG.use_bram_block {Stand_Alone} \
  ] $blk_mem_gen_0


  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [list \
    CONFIG.AUTO_PRIMITIVE {MMCM} \
    CONFIG.AXI_DRP {false} \
    CONFIG.CALC_DONE {empty} \
    CONFIG.CDDCDONE_PORT {cddcdone} \
    CONFIG.CDDCREQ_PORT {cddcreq} \
    CONFIG.CLKFB_IN_N_PORT {clkfb_in_n} \
    CONFIG.CLKFB_IN_PORT {clkfb_in} \
    CONFIG.CLKFB_IN_P_PORT {clkfb_in_p} \
    CONFIG.CLKFB_IN_SIGNALING {SINGLE} \
    CONFIG.CLKFB_OUT_N_PORT {clkfb_out_n} \
    CONFIG.CLKFB_OUT_PORT {clkfb_out} \
    CONFIG.CLKFB_OUT_P_PORT {clkfb_out_p} \
    CONFIG.CLKFB_STOPPED_PORT {clkfb_stopped} \
    CONFIG.CLKIN1_JITTER_PS {100.0} \
    CONFIG.CLKIN1_UI_JITTER {0.010} \
    CONFIG.CLKIN2_JITTER_PS {100.0} \
    CONFIG.CLKIN2_UI_JITTER {0.010} \
    CONFIG.CLKOUT1_DRIVES {BUFG} \
    CONFIG.CLKOUT1_JITTER {159.371} \
    CONFIG.CLKOUT1_MATCHED_ROUTING {false} \
    CONFIG.CLKOUT1_PHASE_ERROR {98.575} \
    CONFIG.CLKOUT1_REQUESTED_DUTY_CYCLE {50.000} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {40.000} \
    CONFIG.CLKOUT1_REQUESTED_PHASE {0.000} \
    CONFIG.CLKOUT1_SEQUENCE_NUMBER {1} \
    CONFIG.CLKOUT1_USED {true} \
    CONFIG.CLKOUT2_DRIVES {BUFG} \
    CONFIG.CLKOUT2_JITTER {0.0} \
    CONFIG.CLKOUT2_MATCHED_ROUTING {false} \
    CONFIG.CLKOUT2_PHASE_ERROR {0.0} \
    CONFIG.CLKOUT2_REQUESTED_DUTY_CYCLE {50.000} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {100.000} \
    CONFIG.CLKOUT2_REQUESTED_PHASE {0.000} \
    CONFIG.CLKOUT2_SEQUENCE_NUMBER {1} \
    CONFIG.CLKOUT2_USED {false} \
    CONFIG.CLKOUT3_DRIVES {BUFG} \
    CONFIG.CLKOUT3_JITTER {0.0} \
    CONFIG.CLKOUT3_MATCHED_ROUTING {false} \
    CONFIG.CLKOUT3_PHASE_ERROR {0.0} \
    CONFIG.CLKOUT3_REQUESTED_DUTY_CYCLE {50.000} \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {100.000} \
    CONFIG.CLKOUT3_REQUESTED_PHASE {0.000} \
    CONFIG.CLKOUT3_SEQUENCE_NUMBER {1} \
    CONFIG.CLKOUT3_USED {false} \
    CONFIG.CLKOUT4_DRIVES {BUFG} \
    CONFIG.CLKOUT4_JITTER {0.0} \
    CONFIG.CLKOUT4_MATCHED_ROUTING {false} \
    CONFIG.CLKOUT4_PHASE_ERROR {0.0} \
    CONFIG.CLKOUT4_REQUESTED_DUTY_CYCLE {50.000} \
    CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {100.000} \
    CONFIG.CLKOUT4_REQUESTED_PHASE {0.000} \
    CONFIG.CLKOUT4_SEQUENCE_NUMBER {1} \
    CONFIG.CLKOUT4_USED {false} \
    CONFIG.CLKOUT5_DRIVES {BUFG} \
    CONFIG.CLKOUT5_JITTER {0.0} \
    CONFIG.CLKOUT5_MATCHED_ROUTING {false} \
    CONFIG.CLKOUT5_PHASE_ERROR {0.0} \
    CONFIG.CLKOUT5_REQUESTED_DUTY_CYCLE {50.000} \
    CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {100.000} \
    CONFIG.CLKOUT5_REQUESTED_PHASE {0.000} \
    CONFIG.CLKOUT5_SEQUENCE_NUMBER {1} \
    CONFIG.CLKOUT5_USED {false} \
    CONFIG.CLKOUT6_DRIVES {BUFG} \
    CONFIG.CLKOUT6_JITTER {0.0} \
    CONFIG.CLKOUT6_MATCHED_ROUTING {false} \
    CONFIG.CLKOUT6_PHASE_ERROR {0.0} \
    CONFIG.CLKOUT6_REQUESTED_DUTY_CYCLE {50.000} \
    CONFIG.CLKOUT6_REQUESTED_OUT_FREQ {100.000} \
    CONFIG.CLKOUT6_REQUESTED_PHASE {0.000} \
    CONFIG.CLKOUT6_SEQUENCE_NUMBER {1} \
    CONFIG.CLKOUT6_USED {false} \
    CONFIG.CLKOUT7_DRIVES {BUFG} \
    CONFIG.CLKOUT7_JITTER {0.0} \
    CONFIG.CLKOUT7_MATCHED_ROUTING {false} \
    CONFIG.CLKOUT7_PHASE_ERROR {0.0} \
    CONFIG.CLKOUT7_REQUESTED_DUTY_CYCLE {50.000} \
    CONFIG.CLKOUT7_REQUESTED_OUT_FREQ {100.000} \
    CONFIG.CLKOUT7_REQUESTED_PHASE {0.000} \
    CONFIG.CLKOUT7_SEQUENCE_NUMBER {1} \
    CONFIG.CLKOUT7_USED {false} \
    CONFIG.CLKOUTPHY_REQUESTED_FREQ {600.000} \
    CONFIG.CLK_IN1_BOARD_INTERFACE {Custom} \
    CONFIG.CLK_IN2_BOARD_INTERFACE {Custom} \
    CONFIG.CLK_IN_SEL_PORT {clk_in_sel} \
    CONFIG.CLK_OUT1_PORT {clk_out1} \
    CONFIG.CLK_OUT1_USE_FINE_PS_GUI {false} \
    CONFIG.CLK_OUT2_PORT {clk_out2} \
    CONFIG.CLK_OUT2_USE_FINE_PS_GUI {false} \
    CONFIG.CLK_OUT3_PORT {clk_out3} \
    CONFIG.CLK_OUT3_USE_FINE_PS_GUI {false} \
    CONFIG.CLK_OUT4_PORT {clk_out4} \
    CONFIG.CLK_OUT4_USE_FINE_PS_GUI {false} \
    CONFIG.CLK_OUT5_PORT {clk_out5} \
    CONFIG.CLK_OUT5_USE_FINE_PS_GUI {false} \
    CONFIG.CLK_OUT6_PORT {clk_out6} \
    CONFIG.CLK_OUT6_USE_FINE_PS_GUI {false} \
    CONFIG.CLK_OUT7_PORT {clk_out7} \
    CONFIG.CLK_OUT7_USE_FINE_PS_GUI {false} \
    CONFIG.CLK_VALID_PORT {CLK_VALID} \
    CONFIG.CLOCK_MGR_TYPE {auto} \
    CONFIG.DADDR_PORT {daddr} \
    CONFIG.DCLK_PORT {dclk} \
    CONFIG.DEN_PORT {den} \
    CONFIG.DIFF_CLK_IN1_BOARD_INTERFACE {Custom} \
    CONFIG.DIFF_CLK_IN2_BOARD_INTERFACE {Custom} \
    CONFIG.DIN_PORT {din} \
    CONFIG.DOUT_PORT {dout} \
    CONFIG.DRDY_PORT {drdy} \
    CONFIG.DWE_PORT {dwe} \
    CONFIG.ENABLE_CDDC {false} \
    CONFIG.ENABLE_CLKOUTPHY {false} \
    CONFIG.ENABLE_CLOCK_MONITOR {false} \
    CONFIG.ENABLE_USER_CLOCK0 {false} \
    CONFIG.ENABLE_USER_CLOCK1 {false} \
    CONFIG.ENABLE_USER_CLOCK2 {false} \
    CONFIG.ENABLE_USER_CLOCK3 {false} \
    CONFIG.Enable_PLL0 {false} \
    CONFIG.Enable_PLL1 {false} \
    CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
    CONFIG.INPUT_CLK_STOPPED_PORT {input_clk_stopped} \
    CONFIG.INPUT_MODE {frequency} \
    CONFIG.INTERFACE_SELECTION {Enable_AXI} \
    CONFIG.IN_FREQ_UNITS {Units_MHz} \
    CONFIG.IN_JITTER_UNITS {Units_UI} \
    CONFIG.JITTER_OPTIONS {UI} \
    CONFIG.JITTER_SEL {No_Jitter} \
    CONFIG.LOCKED_PORT {locked} \
    CONFIG.MMCM_BANDWIDTH {OPTIMIZED} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {10.000} \
    CONFIG.MMCM_CLKFBOUT_PHASE {0.000} \
    CONFIG.MMCM_CLKFBOUT_USE_FINE_PS {false} \
    CONFIG.MMCM_CLKIN1_PERIOD {10.000} \
    CONFIG.MMCM_CLKIN2_PERIOD {10.000} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {25.000} \
    CONFIG.MMCM_CLKOUT0_DUTY_CYCLE {0.500} \
    CONFIG.MMCM_CLKOUT0_PHASE {0.000} \
    CONFIG.MMCM_CLKOUT0_USE_FINE_PS {false} \
    CONFIG.MMCM_CLKOUT1_DIVIDE {1} \
    CONFIG.MMCM_CLKOUT1_DUTY_CYCLE {0.500} \
    CONFIG.MMCM_CLKOUT1_PHASE {0.000} \
    CONFIG.MMCM_CLKOUT1_USE_FINE_PS {false} \
    CONFIG.MMCM_CLKOUT2_DIVIDE {1} \
    CONFIG.MMCM_CLKOUT2_DUTY_CYCLE {0.500} \
    CONFIG.MMCM_CLKOUT2_PHASE {0.000} \
    CONFIG.MMCM_CLKOUT2_USE_FINE_PS {false} \
    CONFIG.MMCM_CLKOUT3_DIVIDE {1} \
    CONFIG.MMCM_CLKOUT3_DUTY_CYCLE {0.500} \
    CONFIG.MMCM_CLKOUT3_PHASE {0.000} \
    CONFIG.MMCM_CLKOUT3_USE_FINE_PS {false} \
    CONFIG.MMCM_CLKOUT4_CASCADE {false} \
    CONFIG.MMCM_CLKOUT4_DIVIDE {1} \
    CONFIG.MMCM_CLKOUT4_DUTY_CYCLE {0.500} \
    CONFIG.MMCM_CLKOUT4_PHASE {0.000} \
    CONFIG.MMCM_CLKOUT4_USE_FINE_PS {false} \
    CONFIG.MMCM_CLKOUT5_DIVIDE {1} \
    CONFIG.MMCM_CLKOUT5_DUTY_CYCLE {0.500} \
    CONFIG.MMCM_CLKOUT5_PHASE {0.000} \
    CONFIG.MMCM_CLKOUT5_USE_FINE_PS {false} \
    CONFIG.MMCM_CLKOUT6_DIVIDE {1} \
    CONFIG.MMCM_CLKOUT6_DUTY_CYCLE {0.500} \
    CONFIG.MMCM_CLKOUT6_PHASE {0.000} \
    CONFIG.MMCM_CLKOUT6_USE_FINE_PS {false} \
    CONFIG.MMCM_CLOCK_HOLD {false} \
    CONFIG.MMCM_COMPENSATION {ZHOLD} \
    CONFIG.MMCM_DIVCLK_DIVIDE {1} \
    CONFIG.MMCM_NOTES {None} \
    CONFIG.MMCM_REF_JITTER1 {0.010} \
    CONFIG.MMCM_REF_JITTER2 {0.010} \
    CONFIG.MMCM_STARTUP_WAIT {false} \
    CONFIG.NUM_OUT_CLKS {1} \
    CONFIG.OPTIMIZE_CLOCKING_STRUCTURE_EN {false} \
    CONFIG.OVERRIDE_MMCM {false} \
    CONFIG.OVERRIDE_PLL {false} \
    CONFIG.PHASESHIFT_MODE {WAVEFORM} \
    CONFIG.PHASE_DUTY_CONFIG {false} \
    CONFIG.PLATFORM {UNKNOWN} \
    CONFIG.PLL_BANDWIDTH {OPTIMIZED} \
    CONFIG.PLL_CLKFBOUT_MULT {4} \
    CONFIG.PLL_CLKFBOUT_PHASE {0.000} \
    CONFIG.PLL_CLKIN_PERIOD {10.000} \
    CONFIG.PLL_CLKOUT0_DIVIDE {1} \
    CONFIG.PLL_CLKOUT0_DUTY_CYCLE {0.500} \
    CONFIG.PLL_CLKOUT0_PHASE {0.000} \
    CONFIG.PLL_CLKOUT1_DIVIDE {1} \
    CONFIG.PLL_CLKOUT1_DUTY_CYCLE {0.500} \
    CONFIG.PLL_CLKOUT1_PHASE {0.000} \
    CONFIG.PLL_CLKOUT2_DIVIDE {1} \
    CONFIG.PLL_CLKOUT2_DUTY_CYCLE {0.500} \
    CONFIG.PLL_CLKOUT2_PHASE {0.000} \
    CONFIG.PLL_CLKOUT3_DIVIDE {1} \
    CONFIG.PLL_CLKOUT3_DUTY_CYCLE {0.500} \
    CONFIG.PLL_CLKOUT3_PHASE {0.000} \
    CONFIG.PLL_CLKOUT4_DIVIDE {1} \
    CONFIG.PLL_CLKOUT4_DUTY_CYCLE {0.500} \
    CONFIG.PLL_CLKOUT4_PHASE {0.000} \
    CONFIG.PLL_CLKOUT5_DIVIDE {1} \
    CONFIG.PLL_CLKOUT5_DUTY_CYCLE {0.500} \
    CONFIG.PLL_CLKOUT5_PHASE {0.000} \
    CONFIG.PLL_CLK_FEEDBACK {CLKFBOUT} \
    CONFIG.PLL_COMPENSATION {SYSTEM_SYNCHRONOUS} \
    CONFIG.PLL_DIVCLK_DIVIDE {1} \
    CONFIG.PLL_NOTES {None} \
    CONFIG.PLL_REF_JITTER {0.010} \
    CONFIG.POWER_DOWN_PORT {power_down} \
    CONFIG.PRECISION {1} \
    CONFIG.PRIMARY_PORT {clk_in1} \
    CONFIG.PRIMITIVE {MMCM} \
    CONFIG.PRIMTYPE_SEL {mmcm_adv} \
    CONFIG.PRIM_IN_FREQ {100.000} \
    CONFIG.PRIM_IN_JITTER {0.010} \
    CONFIG.PRIM_IN_TIMEPERIOD {10.000} \
    CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} \
    CONFIG.PSCLK_PORT {psclk} \
    CONFIG.PSDONE_PORT {psdone} \
    CONFIG.PSEN_PORT {psen} \
    CONFIG.PSINCDEC_PORT {psincdec} \
    CONFIG.REF_CLK_FREQ {100.0} \
    CONFIG.RELATIVE_INCLK {REL_PRIMARY} \
    CONFIG.RESET_BOARD_INTERFACE {Custom} \
    CONFIG.RESET_PORT {reset} \
    CONFIG.RESET_TYPE {ACTIVE_HIGH} \
    CONFIG.SECONDARY_IN_FREQ {100.000} \
    CONFIG.SECONDARY_IN_JITTER {0.010} \
    CONFIG.SECONDARY_IN_TIMEPERIOD {10.000} \
    CONFIG.SECONDARY_PORT {clk_in2} \
    CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin} \
    CONFIG.SS_MODE {CENTER_HIGH} \
    CONFIG.SS_MOD_FREQ {250} \
    CONFIG.SS_MOD_TIME {0.004} \
    CONFIG.STATUS_PORT {STATUS} \
    CONFIG.SUMMARY_STRINGS {empty} \
    CONFIG.USER_CLK_FREQ0 {100.0} \
    CONFIG.USER_CLK_FREQ1 {100.0} \
    CONFIG.USER_CLK_FREQ2 {100.0} \
    CONFIG.USER_CLK_FREQ3 {100.0} \
    CONFIG.USE_BOARD_FLOW {false} \
    CONFIG.USE_CLKFB_STOPPED {false} \
    CONFIG.USE_CLK_VALID {false} \
    CONFIG.USE_CLOCK_SEQUENCING {false} \
    CONFIG.USE_DYN_PHASE_SHIFT {false} \
    CONFIG.USE_DYN_RECONFIG {false} \
    CONFIG.USE_FREEZE {false} \
    CONFIG.USE_FREQ_SYNTH {true} \
    CONFIG.USE_INCLK_STOPPED {false} \
    CONFIG.USE_INCLK_SWITCHOVER {false} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_MAX_I_JITTER {false} \
    CONFIG.USE_MIN_O_JITTER {false} \
    CONFIG.USE_MIN_POWER {false} \
    CONFIG.USE_PHASE_ALIGNMENT {true} \
    CONFIG.USE_POWER_DOWN {false} \
    CONFIG.USE_RESET {true} \
    CONFIG.USE_SAFE_CLOCK_STARTUP {false} \
    CONFIG.USE_SPREAD_SPECTRUM {false} \
    CONFIG.USE_STATUS {false} \
  ] $clk_wiz_0


  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]
  set_property -dict [list \
    CONFIG.C_AUX_RESET_HIGH {0} \
    CONFIG.C_AUX_RST_WIDTH {4} \
    CONFIG.C_EXT_RST_WIDTH {4} \
    CONFIG.C_NUM_BUS_RST {1} \
    CONFIG.C_NUM_INTERCONNECT_ARESETN {1} \
    CONFIG.C_NUM_PERP_ARESETN {1} \
    CONFIG.C_NUM_PERP_RST {1} \
    CONFIG.RESET_BOARD_INTERFACE {Custom} \
    CONFIG.USE_BOARD_FLOW {false} \
  ] $proc_sys_reset_0


  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {14} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {32} \
    CONFIG.DOUT_WIDTH {13} \
  ] $xlslice_0


  # Create instance: blk_mem_gen_1, and set properties
  set blk_mem_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_1 ]
  set_property -dict [list \
    CONFIG.AXI_Slave_Type {Memory_Slave} \
    CONFIG.AXI_Type {AXI4_Full} \
    CONFIG.Additional_Inputs_for_Power_Estimation {false} \
    CONFIG.CTRL_ECC_ALGO {NONE} \
    CONFIG.EN_SAFETY_CKT {true} \
    CONFIG.EN_SLEEP_PIN {false} \
    CONFIG.Enable_32bit_Address {true} \
    CONFIG.Interface_Type {Native} \
    CONFIG.MEM_FILE {NONE} \
    CONFIG.Memory_Type {Single_Port_RAM} \
    CONFIG.Operating_Mode_A {WRITE_FIRST} \
    CONFIG.Output_Reset_Value_A {0} \
    CONFIG.PRIM_type_to_Implement {BRAM} \
    CONFIG.Port_A_Clock {100} \
    CONFIG.Port_A_Enable_Rate {100} \
    CONFIG.Port_A_Write_Rate {50} \
    CONFIG.Port_B_Clock {0} \
    CONFIG.Port_B_Enable_Rate {0} \
    CONFIG.Port_B_Write_Rate {0} \
    CONFIG.Read_Width_A {32} \
    CONFIG.Register_PortA_Output_of_Memory_Core {false} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Use_RSTA_Pin {true} \
    CONFIG.Write_Width_A {32} \
    CONFIG.use_bram_block {BRAM_Controller} \
  ] $blk_mem_gen_1


  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0 ]
  set_property -dict [list \
    CONFIG.C_BAUDRATE {9600} \
    CONFIG.C_DATA_BITS {8} \
    CONFIG.C_ODD_PARITY {0} \
    CONFIG.C_S_AXI_ACLK_FREQ_HZ {40000000} \
    CONFIG.C_S_AXI_ACLK_FREQ_HZ_d {40.0} \
    CONFIG.C_USE_PARITY {0} \
    CONFIG.PARITY {No_Parity} \
    CONFIG.UARTLITE_BOARD_INTERFACE {Custom} \
    CONFIG.USE_BOARD_FLOW {false} \
  ] $axi_uartlite_0


  # Create instance: addsub_bootoffset_0, and set properties
  set addsub_bootoffset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_addsub:12.0 addsub_bootoffset_0 ]
  set_property -dict [list \
    CONFIG.A_Type {Unsigned} \
    CONFIG.A_Width {13} \
    CONFIG.Add_Mode {Subtract} \
    CONFIG.B_Constant {true} \
    CONFIG.B_Type {Unsigned} \
    CONFIG.B_Value {0000000100000} \
    CONFIG.B_Width {13} \
    CONFIG.CE {false} \
    CONFIG.Latency {0} \
    CONFIG.Latency_Configuration {Manual} \
    CONFIG.Out_Width {13} \
  ] $addsub_bootoffset_0


  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_1/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins aes_axi_slave_0/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins SHA3_hardware_new_0/S01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M02_AXI [get_bd_intf_pins RSA_mark03_0/S00_AXI] [get_bd_intf_pins axi_interconnect_0/M02_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M03_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M03_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M04_AXI [get_bd_intf_pins axi_interconnect_0/M04_AXI] [get_bd_intf_pins axi_uartlite_0/S_AXI]
  connect_bd_intf_net -intf_net axi_uartlite_0_UART [get_bd_intf_ports UART_0] [get_bd_intf_pins axi_uartlite_0/UART]
  connect_bd_intf_net -intf_net ibex_core_0_m_axi [get_bd_intf_pins ibex_core_0/m_axi] [get_bd_intf_pins axi_interconnect_0/S00_AXI]

  # Create port connections
  connect_bd_net -net addsub_bootoffset_0_S  [get_bd_pins addsub_bootoffset_0/S] \
  [get_bd_pins blk_mem_gen_0/addra]
  connect_bd_net -net blk_mem_gen_0_douta  [get_bd_pins blk_mem_gen_0/douta] \
  [get_bd_pins ibex_core_0/imem_rdata]
  connect_bd_net -net clk_in1_0_1  [get_bd_ports clk_in1_0] \
  [get_bd_pins clk_wiz_0/clk_in1]
  connect_bd_net -net clk_wiz_0_clk_out1  [get_bd_pins clk_wiz_0/clk_out1] \
  [get_bd_pins proc_sys_reset_0/slowest_sync_clk] \
  [get_bd_pins axi_interconnect_0/ACLK] \
  [get_bd_pins axi_interconnect_0/S00_ACLK] \
  [get_bd_pins axi_interconnect_0/M00_ACLK] \
  [get_bd_pins axi_interconnect_0/M01_ACLK] \
  [get_bd_pins axi_interconnect_0/M02_ACLK] \
  [get_bd_pins axi_interconnect_0/M03_ACLK] \
  [get_bd_pins axi_interconnect_0/M04_ACLK] \
  [get_bd_pins SHA3_hardware_new_0/s01_axi_aclk] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] \
  [get_bd_pins blk_mem_gen_0/clka] \
  [get_bd_pins aes_axi_slave_0/S_AXI_ACLK] \
  [get_bd_pins axi_uartlite_0/s_axi_aclk] \
  [get_bd_pins RSA_mark03_0/s00_axi_aclk] \
  [get_bd_pins ibex_core_0/clk]
  connect_bd_net -net clk_wiz_0_locked  [get_bd_pins clk_wiz_0/locked] \
  [get_bd_pins proc_sys_reset_0/dcm_locked]
  connect_bd_net -net ibex_core_0_imem_addr  [get_bd_pins ibex_core_0/imem_addr] \
  [get_bd_pins xlslice_0/Din]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins proc_sys_reset_0/peripheral_aresetn] \
  [get_bd_pins axi_interconnect_0/ARESETN] \
  [get_bd_pins axi_interconnect_0/S00_ARESETN] \
  [get_bd_pins axi_interconnect_0/M00_ARESETN] \
  [get_bd_pins axi_interconnect_0/M01_ARESETN] \
  [get_bd_pins axi_interconnect_0/M02_ARESETN] \
  [get_bd_pins axi_interconnect_0/M03_ARESETN] \
  [get_bd_pins axi_interconnect_0/M04_ARESETN] \
  [get_bd_pins SHA3_hardware_new_0/s01_axi_aresetn] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] \
  [get_bd_pins aes_axi_slave_0/S_AXI_ARESETN] \
  [get_bd_pins axi_uartlite_0/s_axi_aresetn] \
  [get_bd_pins RSA_mark03_0/s00_axi_aresetn] \
  [get_bd_pins ibex_core_0/rst_n]
  connect_bd_net -net reset_0_1  [get_bd_ports reset_0] \
  [get_bd_pins clk_wiz_0/reset] \
  [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net xlslice_0_Dout  [get_bd_pins xlslice_0/Dout] \
  [get_bd_pins addsub_bootoffset_0/A]

  # Create address segments
  assign_bd_address -offset 0x48000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ibex_core_0/m_axi] [get_bd_addr_segs RSA_mark03_0/S00_AXI/S00_AXI_reg] -force
  assign_bd_address -offset 0x44000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ibex_core_0/m_axi] [get_bd_addr_segs SHA3_hardware_new_0/S01_AXI/S01_AXI_reg] -force
  assign_bd_address -offset 0x40000000 -range 0x00004000 -target_address_space [get_bd_addr_spaces ibex_core_0/m_axi] [get_bd_addr_segs aes_axi_slave_0/S_AXI/reg0] -force
  assign_bd_address -offset 0xC0000000 -range 0x00002000 -target_address_space [get_bd_addr_spaces ibex_core_0/m_axi] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x40600000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ibex_core_0/m_axi] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


