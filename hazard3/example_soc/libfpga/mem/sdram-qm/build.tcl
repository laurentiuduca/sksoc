# Project F: FPGA Pong - Vivado Build Script (XC7 VGA)
# (C)2023 Will Green, open source hardware released under the MIT License
# Learn more at https://projectf.io/posts/fpga-pong/

# Using this script:
#   1. Add Vivado env to shell: . /opt/Xilinx/Vivado/2022.2/settings64.sh
#   2. Run build script: vivado -mode batch -nolog -nojournal -source build.tcl
#   3. Program board: openFPGALoader -b arty ../pong.bit

# build settings
set design_name "ktest"
set arch "xc7"
#set board_name "arty"
set fpga_part "xc7a100tfgg676-1"

# set reference directories for source files
#set lib_dir [file normalize "./"]
#set origin_dir [file normalize "./"]

# read design sources
read_verilog -sv "clkdivider.v"
read_verilog -sv "max7219.v"
read_verilog -sv "ktest.v"
read_verilog -sv "mmcmlaur.v"
read_verilog -sv "test.v"

# read constraints
read_xdc "led.xdc"

# synth
synth_design -top "${design_name}" -part ${fpga_part}

# place and route
opt_design
place_design
route_design

# write bitstream
write_bitstream -force "top.bit"
