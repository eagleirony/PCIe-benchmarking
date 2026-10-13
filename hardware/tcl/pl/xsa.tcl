# Check if project name argument is provided
if { $argc < 1 } {
    puts "Error: Please provide the output file."
    exit 1
}

set project_file "./Projects/pl/pl.xpr"
set output_xsa   [lindex $argv 0]

# Execute the workflow
open_project $project_file
open_run impl_1
write_hw_platform -fixed -force -include_bit -file $output_xsa
close_project
