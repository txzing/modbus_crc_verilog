# Configuration - Can be modified by the user
#set xsa_filename [lindex $argv 1]
put [pwd]

set project_path [lindex $argv 0]
#set project_name vivado_proj
set project_name [lindex $argv 1]
#set part name
set part_name [lindex $argv 2]
#set BD_name system
set bd_filename [lindex $argv 3]
#set BD_name [file rootname [lrange [file split $bd_filename] end end]]
set BD_name [file rootname [file tail $bd_filename]]
set xdc_filename [lindex $argv 4]
#set design_name $BD_name
#set ip_repo_path [pwd]/ip_repo
set ip_repo_path [lindex $argv 5]
set ip_cache_path [pwd]/ip_cache
set current_vivado_version [version -short]

# Create a new project
create_project $project_name $project_path -part $part_name
set_property target_language Verilog [current_project]

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}
# Add hdl files
add_files -fileset sources_1 -norecurse -scan_for_includes ./hdl
#add_files -fileset sources_1 -norecurse -scan_for_includes ./hdl/hdmi
#import_files -fileset sources_1 -norecurse ./hdl
#add_files -fileset sources_1 -norecurse ./hdl/ip/clk_200M/clk_200M.xci
#add_files -fileset sources_1 -norecurse ./hdl/ip/clk_94m/clk_94m.xci
#add_files -fileset sources_1 -norecurse ./hdl/ip/clk_pixel/clk_pixel.xci
#add_files -fileset sources_1 -norecurse ./hdl/clk_200M.xcix
#add_files -fileset sources_1 -norecurse ./hdl/clk_94m.xcix
#add_files -fileset sources_1 -norecurse ./hdl/clk_pixel.xcix
#add_files -fileset sources_1 -norecurse ./hdl/ip/mig_7series_0/mig_7series_0.xci

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset -quiet constrs_1
}
# Add constraint files
add_files -fileset constrs_1 -norecurse -scan_for_includes $xdc_filename
import_files -fileset constrs_1 -norecurse $xdc_filename

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}
# Add simulation files
#add_files -fileset sim_1 -norecurse -scan_for_includes ./src/sim
#import_files -fileset sim_1 -norecurse ./src/sim


# Add ip repository
set_property ip_repo_paths $ip_repo_path [current_project]
config_ip_cache -use_cache_location $ip_cache_path
update_ip_catalog

# Build the Block Design
#source ./bd/system.tcl

# Validate the BD
#regenerate_bd_layout
#validate_bd_design 
#save_bd_design

# Create the HDL wrapper
#export_ip_user_files -of_objects [get_files $project_path/$project_name.srcs/sources_1/bd/$BD_name/$BD_name.bd] -sync -no_script -force -quiet
#make_wrapper -files [get_files $project_path/$project_name.srcs/sources_1/bd/$BD_name/$BD_name.bd] -top
#make_wrapper -files [get_files ./$project_name/$project_name.srcs/sources_1/top.v] -top


# Add the wrapper to the fileset
#set obj [get_filesets sources_1]
#if { [string first $current_vivado_version "2020.2 2021.1"] != -1 } {
#    set files [list "[file normalize [glob "$project_path/$project_name.gen/sources_1/bd/$BD_name/hdl/*_wrapper*"]]"]
#} elseif { [string first $current_vivado_version "2018.1 2018.2 2018.3 2019.1 2019.2 2020.1"] != -1 } {
#    set files [list "[file normalize [glob "$project_path/$project_name.srcs/sources_1/bd/$BD_name/hdl/*_wrapper*"]]"]
#}
#set files [list \
#               [file normalize $origin_dir/generated-src/Top.$CONFIG.v] \
#               [file normalize $base_dir/src/main/verilog/chip_top.sv] \
#               [file normalize $base_dir/socip/nasti/channel.sv] \
#               ...
#              ]
#add_files -norecurse -fileset $obj $files

#set_property top image_top [current_fileset]
#set_property top top [get_filesets sources_1]
#set_property top_file {./$project_name/$project_name.srcs/sources_1/led_twinkle.v} [current_fileset]
#set_property top_file {./$project_name/$project_name.srcs/sources_1/led_twinkle.v} [get_filesets sources_1]

#create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
#set_property -dict [list \
#  CONFIG.PRIM_IN_FREQ {50} \
#  CONFIG.CLKOUT2_USED {true} \
#  CONFIG.CLKOUT3_USED {true}  \
#  CONFIG.CLKOUT4_USED {true}  \
#  CONFIG.CLKOUT5_USED {true}  \
#  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {135}  \
#  CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {675}  \
#  CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {675}  \
#  CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {675}  \
#  CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {675}  \
#  CONFIG.CLKOUT2_DRIVES {No_buffer}  \
#  CONFIG.CLKOUT3_DRIVES {No_buffer}  \
#  CONFIG.CLKOUT4_DRIVES {No_buffer}  \
#  CONFIG.CLKOUT5_DRIVES {No_buffer}  \
#  CONFIG.CLKIN1_JITTER_PS {200.0} \
#  CONFIG.MMCM_DIVCLK_DIVIDE {1}  \
#  CONFIG.MMCM_CLKFBOUT_MULT_F {13.500}  \
#  CONFIG.MMCM_CLKOUT0_DIVIDE_F {5.000}  \
#  CONFIG.MMCM_CLKOUT1_DIVIDE {1}  \
#  CONFIG.MMCM_CLKOUT2_DIVIDE {1}  \
#  CONFIG.MMCM_CLKOUT3_DIVIDE {1}  \
#  CONFIG.MMCM_CLKOUT4_DIVIDE {1}  \
#  CONFIG.NUM_OUT_CLKS {5}  \
#  CONFIG.CLKOUT1_JITTER {151.933}  \
#  CONFIG.CLKOUT1_PHASE_ERROR {214.897}  \
#  CONFIG.CLKOUT2_JITTER {125.097}  \
#  CONFIG.CLKOUT2_PHASE_ERROR {214.897}  \
#  CONFIG.CLKOUT3_JITTER {125.097}  \
#  CONFIG.CLKOUT3_PHASE_ERROR {214.897}  \
#  CONFIG.CLKOUT4_JITTER {125.097}  \
#  CONFIG.CLKOUT4_PHASE_ERROR {214.897}  \
#  CONFIG.CLKOUT5_JITTER {125.097}  \
#  CONFIG.CLKOUT5_PHASE_ERROR {214.897}  \
#] [get_ips clk_wiz_0]

#create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_0
#set_property -dict [list \
#  CONFIG.C_PROBE2_WIDTH {24}  \
#  CONFIG.C_NUM_OF_PROBES {6}  \
#] [get_ips ila_0]

#create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_1
#set_property -dict [list \
#  CONFIG.C_PROBE0_WIDTH {4}  \
#  CONFIG.C_PROBE1_WIDTH {9}  \
#  CONFIG.C_PROBE6_WIDTH {9}  \
#  CONFIG.C_PROBE7_WIDTH {2}  \
#  CONFIG.C_PROBE10_WIDTH {8}  \
#  CONFIG.C_PROBE13_WIDTH {8}  \
#  CONFIG.C_NUM_OF_PROBES {14}  \
#] [get_ips ila_1]

#create_ip -name hdmi_trans -vendor xilinx.com -library user -version 1.0 -module_name hdmi_trans_0

update_compile_order -fileset sources_1
#update_compile_order -fileset sim_1

#write_bd_layout -format pdf -orientation portrait -force ./$BD_name.pdf

#set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

######
#exit
######
