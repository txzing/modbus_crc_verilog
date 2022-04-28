set project_path [lindex $argv 0]
set project_name [lindex $argv 1]
set bd_filename [lindex $argv 2]

set BD_name [file rootname [file tail $bd_filename]]

set ip_cache_path [pwd]/ip_cache
 
open_project $project_path/$project_name

config_ip_cache -use_cache_location $ip_cache_path
update_ip_catalog

#set_property synth_checkpoint_mode Singular [get_files $project_path/$project_name.srcs/sources_1/bd/$BD_name/$BD_name.bd]
#set_property synth_checkpoint_mode Hierarchical [get_files $project_path/$project_name.srcs/sources_1/bd/$BD_name/$BD_name.bd]
#generate_target all [get_files $project_path/$project_name.srcs/sources_1/bd/$BD_name/$BD_name.bd]

#export_ip_user_files -of_objects [get_files $project_path/$project_name.srcs/sources_1/bd/$BD_name/$BD_name.bd] -no_script -sync -force -quiet
#create_ip_run [get_files -of_objects [get_fileset sources_1] $project_path/$project_name.srcs/sources_1/bd/$BD_name/$BD_name.bd]
#launch_runs system_synth_1 -jobs 2
#if {[get_property PROGRESS [get_runs system_*_synth_1]] != "100%"} {
#    launch_runs system_*_synth_1 -jobs 2
#    wait_on_run system_*_synth_1
#}

if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    launch_runs synth_1 -jobs 8
    wait_on_run synth_1
    open_run synth_1
    report_timing_summary
}

if {[get_property NEEDS_REFRESH [get_runs synth_1]] == 1} {
    reset_run synth_1
    launch_runs synth_1 -jobs 8
    wait_on_run synth_1
    open_run synth_1
    report_timing_summary
}

close_project

