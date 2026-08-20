source ../../hardware/tcl/pl/bd.tcl
make_wrapper -files [get_files ../../Projects/pl/pl.srcs/sources_1/bd/design_1/design_1.bd] -top
add_files -norecurse ../../Projects/pl/pl.gen/sources_1/bd/design_1/hdl/design_1_wrapper.vhd
set_property source_mgmt_mode All [current_project]
update_compile_order -fileset simulation
update_compile_order -fileset sources_1
set_property top design_1_wrapper [current_fileset]
