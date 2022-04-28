set project_path [lindex $argv 0]
set project_name [lindex $argv 1]
set bd_filename [lindex $argv 2]
 
set BD_name [file rootname [file tail $bd_filename]]

 
open_project $project_path/$project_name
 
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
  launch_runs impl_1 -to_step write_bitstream -jobs 20
  wait_on_run impl_1
  open_run impl_1
  report_timing_summary
}
 
open_run [get_runs impl_1]

write_debug_probes -force ${BD_name}_wrapper.ltx
write_hw_platform -verbose -fixed -include_bit -force -file ${BD_name}_wrapper.xsa
 
close_project
