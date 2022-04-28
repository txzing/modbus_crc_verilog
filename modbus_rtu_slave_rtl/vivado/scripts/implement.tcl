set project_path [lindex $argv 0]
set project_name [lindex $argv 1]
set bd_filename [lindex $argv 2]

set BD_name [file rootname [file tail $bd_filename]]

set ip_cache_path [pwd]/ip_cache
 
open_project $project_path/$project_name
 
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
  launch_runs impl_1 -to_step write_bitstream -jobs 20
  wait_on_run impl_1
  open_run impl_1
  report_timing_summary
}

if {[get_property NEEDS_REFRESH [get_runs impl_1]] == 1} {
  reset_run impl_1
  launch_runs impl_1 -to_step write_bitstream -jobs 20
  wait_on_run impl_1
  open_run impl_1
  report_timing_summary
}
 
close_project
