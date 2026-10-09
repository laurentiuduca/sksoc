# Project F: FPGA Pong - Vivado Build Script (XC7 VGA)
# (C)2023 Will Green, open source hardware released under the MIT License
# Learn more at https://projectf.io/posts/fpga-pong/

# Using this script:
#   1. Add Vivado env to shell: . /opt/Xilinx/Vivado/2022.2/settings64.sh
#   2. Run build script: vivado -mode batch -nolog -nojournal -source build.tcl
#   3. Program board: openFPGALoader -b arty ../pong.bit

# build settings
set design_name "m_topsim"
set arch "xc7"
#set board_name "arty"
set fpga_part "xc7a100tfgg676-1"

create_project proj . -part ${fpga_part} -force
read_edif ${design_name}.edf

# read constraints
read_xdc "qmtechv3.xdc"
link_design -top "${design_name}"

# place and route
opt_design
place_design
route_design
write_checkpoint -force route.dcp
report_timing_summary -file routetiming.rpt
report_utilization -file routeutil.rpt

# write bitstream
write_bitstream -force "top.bit"
