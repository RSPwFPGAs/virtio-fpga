
################################################################
# This is a generated script based on design: shell_region
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
set scripts_vivado_version 2018.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   common::send_msg_id "BD_TCL-1002" "WARNING" "This script was generated using Vivado <$scripts_vivado_version> without IP versions in the create_bd_cell commands, but is now being run in <$current_vivado_version> of Vivado. There may have been major IP version changes between Vivado <$scripts_vivado_version> and <$current_vivado_version>, which could impact the parameter settings of the IPs."

}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source shell_region_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# virtio_csr

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcku040-ffva1156-2-e
   set_property BOARD_PART xilinx.com:kcu105:part0:1.5 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name shell_region

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
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

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

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_vip:*\
xilinx.com:ip:jtag_axi:*\
xilinx.com:ip:axi_bram_ctrl:*\
COMPAS:COMPAS:QEMUPCIeBridge:*\
xilinx.com:ip:util_ds_buf:*\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
virtio_csr\
"

   set list_mods_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_msg_id "BD_TCL-008" "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: pcie_axi_bridge
proc create_hier_cell_pcie_axi_bridge { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_pcie_axi_bridge() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pci_express
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk

  # Create pins
  create_bd_pin -dir O -type clk axi_aclk_port_data
  create_bd_pin -dir O -from 0 -to 0 -type rst axi_aresetn_port_data
  create_bd_pin -dir I -type rst pcie_perstn

  # Create instance: QEMUPCIeBridge_0, and set properties
  set QEMUPCIeBridge_0 [ create_bd_cell -type ip -vlnv COMPAS:COMPAS:QEMUPCIeBridge QEMUPCIeBridge_0 ]
  set_property -dict [ list \
   CONFIG.ADRW {64} \
 ] $QEMUPCIeBridge_0

  # Create instance: util_ds_buf, and set properties
  set util_ds_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {IBUFDSGTE} \
   CONFIG.DIFF_CLK_IN_BOARD_INTERFACE {pcie_refclk} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $util_ds_buf

  # Create interface connections
  connect_bd_intf_net -intf_net QEMUPCIeBridge_0_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins QEMUPCIeBridge_0/M_AXI]
  connect_bd_intf_net -intf_net QEMUPCIeBridge_0_pcie_7x_mgt [get_bd_intf_pins pci_express] [get_bd_intf_pins QEMUPCIeBridge_0/pcie_7x_mgt]
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins QEMUPCIeBridge_0/S_AXI]
  connect_bd_intf_net -intf_net pcie_refclk_1 [get_bd_intf_pins pcie_refclk] [get_bd_intf_pins util_ds_buf/CLK_IN_D]

  # Create port connections
  connect_bd_net -net QEMUPCIeBridge_0_o_axi_aclk [get_bd_pins axi_aclk_port_data] [get_bd_pins QEMUPCIeBridge_0/i_axi_ctl_aclk] [get_bd_pins QEMUPCIeBridge_0/o_axi_aclk]
  connect_bd_net -net QEMUPCIeBridge_0_o_axi_aresetn [get_bd_pins axi_aresetn_port_data] [get_bd_pins QEMUPCIeBridge_0/o_axi_aresetn]
  connect_bd_net -net pcie_perstn_1 [get_bd_pins pcie_perstn] [get_bd_pins QEMUPCIeBridge_0/i_sys_rst_n]
  connect_bd_net -net util_ds_buf_IBUF_DS_ODIV2 [get_bd_pins QEMUPCIeBridge_0/i_refclk] [get_bd_pins util_ds_buf/IBUF_DS_ODIV2]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: feature_ram
proc create_hier_cell_feature_ram { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_feature_ram() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  # Create pins
  create_bd_pin -dir I -type clk axi_aclk_role_ctrl
  create_bd_pin -dir I -type rst axi_aresetn_role_ctrl

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl axi_bram_ctrl_0 ]
  set_property -dict [ list \
   CONFIG.ECC_TYPE {0} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_0

  # Create instance: virtio_csr_0, and set properties
  set block_name virtio_csr
  set block_cell_name virtio_csr_0
  if { [catch {set virtio_csr_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $virtio_csr_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins virtio_csr_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_interconnect_1_M00_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]

  # Create port connections
  connect_bd_net -net qdma_0_axi_aclk [get_bd_pins axi_aclk_role_ctrl] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk]
  connect_bd_net -net qdma_0_axi_aresetn [get_bd_pins axi_aresetn_role_ctrl] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: FIU
proc create_hier_cell_FIU { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_FIU() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pci_express
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk

  # Create pins
  create_bd_pin -dir O -type clk axi_aclk_port_data
  create_bd_pin -dir O -from 0 -to 0 -type rst axi_aresetn_port_data
  create_bd_pin -dir I -type rst pcie_perstn

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {2} \
   CONFIG.STRATEGY {1} \
 ] $axi_interconnect_0

  # Create instance: axi_interconnect_1, and set properties
  set axi_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect axi_interconnect_1 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {7} \
   CONFIG.S00_HAS_DATA_FIFO {2} \
   CONFIG.S01_HAS_DATA_FIFO {2} \
   CONFIG.S02_HAS_DATA_FIFO {2} \
   CONFIG.S03_HAS_DATA_FIFO {2} \
   CONFIG.S04_HAS_DATA_FIFO {2} \
   CONFIG.S05_HAS_DATA_FIFO {2} \
   CONFIG.S06_HAS_DATA_FIFO {2} \
   CONFIG.STRATEGY {2} \
 ] $axi_interconnect_1

  # Create instance: axi_vip_0, and set properties
  set axi_vip_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_0 ]

  # Create instance: axi_vip_null00, and set properties
  set axi_vip_null00 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_null00 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.INTERFACE_MODE {MASTER} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
 ] $axi_vip_null00

  # Create instance: axi_vip_null01, and set properties
  set axi_vip_null01 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_null01 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.INTERFACE_MODE {MASTER} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
 ] $axi_vip_null01

  # Create instance: axi_vip_null02, and set properties
  set axi_vip_null02 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_null02 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.INTERFACE_MODE {MASTER} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
 ] $axi_vip_null02

  # Create instance: axi_vip_null03, and set properties
  set axi_vip_null03 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_null03 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.INTERFACE_MODE {MASTER} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
 ] $axi_vip_null03

  # Create instance: axi_vip_null04, and set properties
  set axi_vip_null04 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_null04 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.INTERFACE_MODE {MASTER} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
 ] $axi_vip_null04

  # Create instance: axi_vip_null05, and set properties
  set axi_vip_null05 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_null05 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.INTERFACE_MODE {MASTER} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
 ] $axi_vip_null05

  # Create instance: axi_vip_null06, and set properties
  set axi_vip_null06 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_null06 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.INTERFACE_MODE {MASTER} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
 ] $axi_vip_null06

  # Create instance: axi_vip_thread00, and set properties
  set axi_vip_thread00 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_thread00 ]
  set_property -dict [ list \
   CONFIG.INTERFACE_MODE {PASS_THROUGH} \
   CONFIG.DATA_WIDTH {32} \
 ] $axi_vip_thread00

  # Create instance: axi_vip_thread01, and set properties
  set axi_vip_thread01 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_thread01 ]
  set_property -dict [ list \
   CONFIG.INTERFACE_MODE {PASS_THROUGH} \
   CONFIG.DATA_WIDTH {32} \
 ] $axi_vip_thread01

  # Create instance: axi_vip_thread02, and set properties
  set axi_vip_thread02 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_thread02 ]
  set_property -dict [ list \
   CONFIG.INTERFACE_MODE {PASS_THROUGH} \
   CONFIG.DATA_WIDTH {32} \
 ] $axi_vip_thread02

  # Create instance: axi_vip_thread03, and set properties
  set axi_vip_thread03 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_thread03 ]
  set_property -dict [ list \
   CONFIG.INTERFACE_MODE {PASS_THROUGH} \
   CONFIG.DATA_WIDTH {128} \
 ] $axi_vip_thread03

  # Create instance: axi_vip_thread04, and set properties
  set axi_vip_thread04 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_thread04 ]
  set_property -dict [ list \
   CONFIG.INTERFACE_MODE {PASS_THROUGH} \
   CONFIG.DATA_WIDTH {256} \
 ] $axi_vip_thread04

  # Create instance: axi_vip_thread05, and set properties
  set axi_vip_thread05 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_thread05 ]
  set_property -dict [ list \
   CONFIG.INTERFACE_MODE {PASS_THROUGH} \
   CONFIG.DATA_WIDTH {64} \
 ] $axi_vip_thread05

  # Create instance: axi_vip_thread06, and set properties
  set axi_vip_thread06 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip axi_vip_thread06 ]
  set_property -dict [ list \
   CONFIG.INTERFACE_MODE {PASS_THROUGH} \
   CONFIG.DATA_WIDTH {32} \
 ] $axi_vip_thread06

  # Create instance: feature_ram
  create_hier_cell_feature_ram $hier_obj feature_ram

  # Create instance: jtag_axi_0, and set properties
  set jtag_axi_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:jtag_axi jtag_axi_0 ]
  set_property -dict [ list \
   CONFIG.M_AXI_ADDR_WIDTH {32} \
 ] $jtag_axi_0

  # Create instance: pcie_axi_bridge
  create_hier_cell_pcie_axi_bridge $hier_obj pcie_axi_bridge

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins axi_interconnect_1/M00_AXI] [get_bd_intf_pins pcie_axi_bridge/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins feature_ram/S_AXI]
  connect_bd_intf_net -intf_net axi_vip_0_M_AXI [get_bd_intf_pins axi_interconnect_0/S01_AXI] [get_bd_intf_pins axi_vip_0/M_AXI]
  connect_bd_intf_net -intf_net axi_vip_1_M_AXI [get_bd_intf_pins axi_vip_null05/M_AXI] [get_bd_intf_pins axi_vip_thread05/S_AXI]
  connect_bd_intf_net -intf_net axi_vip_2_M_AXI [get_bd_intf_pins axi_vip_null06/M_AXI] [get_bd_intf_pins axi_vip_thread06/S_AXI]
  connect_bd_intf_net -intf_net axi_vip_3_M_AXI [get_bd_intf_pins axi_vip_null04/M_AXI] [get_bd_intf_pins axi_vip_thread04/S_AXI]
  connect_bd_intf_net -intf_net axi_vip_4_M_AXI [get_bd_intf_pins axi_vip_null03/M_AXI] [get_bd_intf_pins axi_vip_thread03/S_AXI]
  connect_bd_intf_net -intf_net axi_vip_5_M_AXI [get_bd_intf_pins axi_vip_null02/M_AXI] [get_bd_intf_pins axi_vip_thread02/S_AXI]
  connect_bd_intf_net -intf_net axi_vip_6_M_AXI [get_bd_intf_pins axi_vip_null01/M_AXI] [get_bd_intf_pins axi_vip_thread01/S_AXI]
  connect_bd_intf_net -intf_net axi_vip_7_M_AXI [get_bd_intf_pins axi_vip_null00/M_AXI] [get_bd_intf_pins axi_vip_thread00/S_AXI]
  connect_bd_intf_net -intf_net axi_vip_thread01_M_AXI [get_bd_intf_pins axi_interconnect_1/S01_AXI] [get_bd_intf_pins axi_vip_thread01/M_AXI]
  connect_bd_intf_net -intf_net axi_vip_thread02_M_AXI [get_bd_intf_pins axi_interconnect_1/S02_AXI] [get_bd_intf_pins axi_vip_thread02/M_AXI]
  connect_bd_intf_net -intf_net axi_vip_thread03_M_AXI [get_bd_intf_pins axi_interconnect_1/S03_AXI] [get_bd_intf_pins axi_vip_thread03/M_AXI]
  connect_bd_intf_net -intf_net axi_vip_thread04_M_AXI [get_bd_intf_pins axi_interconnect_1/S04_AXI] [get_bd_intf_pins axi_vip_thread04/M_AXI]
  connect_bd_intf_net -intf_net axi_vip_thread05_M_AXI [get_bd_intf_pins axi_interconnect_1/S05_AXI] [get_bd_intf_pins axi_vip_thread05/M_AXI]
  connect_bd_intf_net -intf_net axi_vip_thread06_M_AXI [get_bd_intf_pins axi_interconnect_1/S06_AXI] [get_bd_intf_pins axi_vip_thread06/M_AXI]
  connect_bd_intf_net -intf_net axi_vip_thread0_M_AXI [get_bd_intf_pins axi_interconnect_1/S00_AXI] [get_bd_intf_pins axi_vip_thread00/M_AXI]
  connect_bd_intf_net -intf_net jtag_axi_0_M_AXI [get_bd_intf_pins axi_vip_0/S_AXI] [get_bd_intf_pins jtag_axi_0/M_AXI]
  connect_bd_intf_net -intf_net pcie3_ultrascale_0_pcie_7x_mgt [get_bd_intf_pins pci_express] [get_bd_intf_pins pcie_axi_bridge/pci_express]
  connect_bd_intf_net -intf_net pcie_2_axilite_0_m_axi_1 [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins pcie_axi_bridge/M_AXI]
  connect_bd_intf_net -intf_net pcie_refclk_1 [get_bd_intf_pins pcie_refclk] [get_bd_intf_pins pcie_axi_bridge/pcie_refclk]

  # Create port connections
  connect_bd_net -net qdma_0_axi_aclk [get_bd_pins axi_aclk_port_data] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins axi_interconnect_1/S00_ACLK] [get_bd_pins axi_interconnect_1/S01_ACLK] [get_bd_pins axi_interconnect_1/S02_ACLK] [get_bd_pins axi_interconnect_1/S03_ACLK] [get_bd_pins axi_interconnect_1/S04_ACLK] [get_bd_pins axi_interconnect_1/S05_ACLK] [get_bd_pins axi_interconnect_1/S06_ACLK] [get_bd_pins axi_vip_0/aclk] [get_bd_pins axi_vip_null00/aclk] [get_bd_pins axi_vip_null01/aclk] [get_bd_pins axi_vip_null02/aclk] [get_bd_pins axi_vip_null03/aclk] [get_bd_pins axi_vip_null04/aclk] [get_bd_pins axi_vip_null05/aclk] [get_bd_pins axi_vip_null06/aclk] [get_bd_pins axi_vip_thread00/aclk] [get_bd_pins axi_vip_thread01/aclk] [get_bd_pins axi_vip_thread02/aclk] [get_bd_pins axi_vip_thread03/aclk] [get_bd_pins axi_vip_thread04/aclk] [get_bd_pins axi_vip_thread05/aclk] [get_bd_pins axi_vip_thread06/aclk] [get_bd_pins feature_ram/axi_aclk_role_ctrl] [get_bd_pins jtag_axi_0/aclk] [get_bd_pins pcie_axi_bridge/axi_aclk_port_data]
  connect_bd_net -net qdma_0_axi_aresetn [get_bd_pins axi_aresetn_port_data] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins axi_interconnect_1/S00_ARESETN] [get_bd_pins axi_interconnect_1/S01_ARESETN] [get_bd_pins axi_interconnect_1/S02_ARESETN] [get_bd_pins axi_interconnect_1/S03_ARESETN] [get_bd_pins axi_interconnect_1/S04_ARESETN] [get_bd_pins axi_interconnect_1/S05_ARESETN] [get_bd_pins axi_interconnect_1/S06_ARESETN] [get_bd_pins axi_vip_0/aresetn] [get_bd_pins axi_vip_null00/aresetn] [get_bd_pins axi_vip_null01/aresetn] [get_bd_pins axi_vip_null02/aresetn] [get_bd_pins axi_vip_null03/aresetn] [get_bd_pins axi_vip_null04/aresetn] [get_bd_pins axi_vip_null05/aresetn] [get_bd_pins axi_vip_null06/aresetn] [get_bd_pins axi_vip_thread00/aresetn] [get_bd_pins axi_vip_thread01/aresetn] [get_bd_pins axi_vip_thread02/aresetn] [get_bd_pins axi_vip_thread03/aresetn] [get_bd_pins axi_vip_thread04/aresetn] [get_bd_pins axi_vip_thread05/aresetn] [get_bd_pins axi_vip_thread06/aresetn] [get_bd_pins feature_ram/axi_aresetn_role_ctrl] [get_bd_pins jtag_axi_0/aresetn] [get_bd_pins pcie_axi_bridge/axi_aresetn_port_data]
  connect_bd_net -net sys_reset_0_1 [get_bd_pins pcie_perstn] [get_bd_pins pcie_axi_bridge/pcie_perstn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: FIM
proc create_hier_cell_FIM { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_FIM() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pci_express
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk

  # Create pins
  create_bd_pin -dir O -type clk axi_aclk_ctrl_port
  create_bd_pin -dir O -type clk axi_aclk_data_port
  create_bd_pin -dir O -from 0 -to 0 -type rst axi_aresetn_ctrl_port
  create_bd_pin -dir O -from 0 -to 0 -type rst axi_aresetn_data_port
  create_bd_pin -dir I -type rst pcie_perstn

  # Create instance: FIU
  create_hier_cell_FIU $hier_obj FIU

  # Create interface connections
  connect_bd_intf_net -intf_net pcie_refclk_1 [get_bd_intf_pins pcie_refclk] [get_bd_intf_pins FIU/pcie_refclk]
  connect_bd_intf_net -intf_net qdma_0_pcie_mgt [get_bd_intf_pins pci_express] [get_bd_intf_pins FIU/pci_express]

  # Create port connections
  connect_bd_net -net shell_core_axi_aclk [get_bd_pins axi_aclk_ctrl_port] [get_bd_pins axi_aclk_data_port] [get_bd_pins FIU/axi_aclk_port_data]
  connect_bd_net -net shell_core_axi_aresetn [get_bd_pins axi_aresetn_ctrl_port] [get_bd_pins axi_aresetn_data_port] [get_bd_pins FIU/axi_aresetn_port_data]
  connect_bd_net -net sys_reset_0_1 [get_bd_pins pcie_perstn] [get_bd_pins FIU/pcie_perstn]

  # Restore current instance
  current_bd_instance $oldCurInst
}


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
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set pci_express [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pci_express ]
  set pcie_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   ] $pcie_refclk

  # Create ports
  set pcie_perstn [ create_bd_port -dir I -type rst pcie_perstn ]

  # Create instance: FIM
  create_hier_cell_FIM [current_bd_instance .] FIM

  # Create interface connections
  connect_bd_intf_net -intf_net pcie_refclk_1 [get_bd_intf_ports pcie_refclk] [get_bd_intf_pins FIM/pcie_refclk]
  connect_bd_intf_net -intf_net qdma_0_pcie_mgt [get_bd_intf_ports pci_express] [get_bd_intf_pins FIM/pci_express]

  # Create port connections
  connect_bd_net -net sys_reset_0_1 [get_bd_ports pcie_perstn] [get_bd_pins FIM/pcie_perstn]

  # Create address segments
  create_bd_addr_seg -range 0x00010000000000000000 -offset 0x00000000 [get_bd_addr_spaces FIM/FIU/axi_vip_null00/Master_AXI] [get_bd_addr_segs FIM/FIU/pcie_axi_bridge/QEMUPCIeBridge_0/S_AXI/BAR0] SEG_QEMUPCIeBridge_0_BAR0
  create_bd_addr_seg -range 0x00010000000000000000 -offset 0x00000000 [get_bd_addr_spaces FIM/FIU/axi_vip_null01/Master_AXI] [get_bd_addr_segs FIM/FIU/pcie_axi_bridge/QEMUPCIeBridge_0/S_AXI/BAR0] SEG_QEMUPCIeBridge_0_BAR0
  create_bd_addr_seg -range 0x00010000000000000000 -offset 0x00000000 [get_bd_addr_spaces FIM/FIU/axi_vip_null02/Master_AXI] [get_bd_addr_segs FIM/FIU/pcie_axi_bridge/QEMUPCIeBridge_0/S_AXI/BAR0] SEG_QEMUPCIeBridge_0_BAR0
  create_bd_addr_seg -range 0x00010000000000000000 -offset 0x00000000 [get_bd_addr_spaces FIM/FIU/axi_vip_null03/Master_AXI] [get_bd_addr_segs FIM/FIU/pcie_axi_bridge/QEMUPCIeBridge_0/S_AXI/BAR0] SEG_QEMUPCIeBridge_0_BAR0
  create_bd_addr_seg -range 0x00010000000000000000 -offset 0x00000000 [get_bd_addr_spaces FIM/FIU/axi_vip_null04/Master_AXI] [get_bd_addr_segs FIM/FIU/pcie_axi_bridge/QEMUPCIeBridge_0/S_AXI/BAR0] SEG_QEMUPCIeBridge_0_BAR0
  create_bd_addr_seg -range 0x00010000000000000000 -offset 0x00000000 [get_bd_addr_spaces FIM/FIU/axi_vip_null05/Master_AXI] [get_bd_addr_segs FIM/FIU/pcie_axi_bridge/QEMUPCIeBridge_0/S_AXI/BAR0] SEG_QEMUPCIeBridge_0_BAR0
  create_bd_addr_seg -range 0x00010000000000000000 -offset 0x00000000 [get_bd_addr_spaces FIM/FIU/axi_vip_null06/Master_AXI] [get_bd_addr_segs FIM/FIU/pcie_axi_bridge/QEMUPCIeBridge_0/S_AXI/BAR0] SEG_QEMUPCIeBridge_0_BAR0
  create_bd_addr_seg -range 0x00001000 -offset 0x00000000 [get_bd_addr_spaces FIM/FIU/jtag_axi_0/Data] [get_bd_addr_segs FIM/FIU/feature_ram/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x00001000 -offset 0x00000000 [get_bd_addr_spaces FIM/FIU/pcie_axi_bridge/QEMUPCIeBridge_0/M_AXI] [get_bd_addr_segs FIM/FIU/feature_ram/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0


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


