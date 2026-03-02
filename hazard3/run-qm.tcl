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

# set reference directories for source files
#set lib_dir [file normalize "./"]
#set origin_dir [file normalize "./"]

# read design sources
read_verilog -sv "example_soc/define.vh"
read_verilog -sv "hdl/hazard3_config.vh"
read_verilog -sv "example_soc/m_topsim.v"
read_verilog -sv "example_soc/soc/example_soc-dual.v"
read_verilog -sv "example_soc/libfpga/common/reset_sync.v"
read_verilog -sv "example_soc/libfpga/common/fpga_reset.v" 
read_verilog -sv "example_soc/libfpga/common/activity_led.v" 
read_verilog -sv "hdl/hazard3_core.v" 
read_verilog -sv "hdl/hazard3_cpu_1port.v"
read_verilog -sv "hdl/hazard3_2cpu.v"
read_verilog -sv "hdl/arith/hazard3_alu.v" 
read_verilog -sv "hdl/arith/hazard3_branchcmp.v" 
read_verilog -sv "hdl/arith/hazard3_mul_fast.v" 
read_verilog -sv "hdl/arith/hazard3_muldiv_seq.v" 
read_verilog -sv "hdl/arith/hazard3_onehot_encode.v" 
read_verilog -sv "hdl/arith/hazard3_onehot_priority.v" 
read_verilog -sv "hdl/arith/hazard3_onehot_priority_dynamic.v" 
read_verilog -sv "hdl/arith/hazard3_priority_encode.v" 
read_verilog -sv "hdl/arith/hazard3_shift_barrel.v" 
read_verilog -sv "hdl/hazard3_csr.v" 
read_verilog -sv "hdl/hazard3_decode.v" 
read_verilog -sv "hdl/hazard3_frontend.v" 
read_verilog -sv "hdl/hazard3_instr_decompress.v" 
read_verilog -sv "hdl/hazard3_irq_ctrl.v" 
read_verilog -sv "hdl/hazard3_pmp.v" 
read_verilog -sv "hdl/hazard3_power_ctrl.v" 
read_verilog -sv "hdl/hazard3_regfile_1w2r.v" 
read_verilog -sv "hdl/hazard3_triggers.v" 
read_verilog -sv "hdl/debug/dtm/hazard3_jtag_dtm.v" 
read_verilog -sv "hdl/debug/dtm/hazard3_jtag_dtm_core.v" 
read_verilog -sv "hdl/debug/cdc/hazard3_apb_async_bridge.v" 
read_verilog -sv "hdl/debug/cdc/hazard3_sync_1bit.v"
read_verilog -sv "hdl/debug/cdc/hazard3_reset_sync.v" 
read_verilog -sv "hdl/debug/dm/hazard3_dm.v"
read_verilog -sv "example_soc/soc/peri/hazard3_riscv_timer.v"
read_verilog -sv "example_soc/libfpga/peris/spi_03h_xip/spi_03h_xip.v" 
read_verilog -sv "example_soc/libfpga/peris/spi_03h_xip/spi_03h_xip_regs.v" 
read_verilog -sv "example_soc/libfpga/mem/ahb_cache_readonly.v" 
read_verilog -sv "example_soc/libfpga/mem/ahb_cache_writeback.v" 
read_verilog -sv "example_soc/libfpga/mem/cache_mem_set_associative.v" 
read_verilog -sv "example_soc/libfpga/busfabric/ahbl_crossbar.v" 
read_verilog -sv "example_soc/libfpga/busfabric/ahbl_splitter.v" 
read_verilog -sv "example_soc/libfpga/busfabric/ahbl_arbiter.v" 
read_verilog -sv "example_soc/libfpga/common/onehot_mux.v" 
read_verilog -sv "example_soc/libfpga/common/onehot_priority.v" 
read_verilog -sv "example_soc/libfpga/busfabric/ahbl_to_apb.v" 
read_verilog -sv "example_soc/libfpga/busfabric/apb_splitter.v" 
read_verilog -sv "example_soc/libfpga/mem/ahb_laur_mem.v" 
read_verilog -sv "example_soc/libfpga/mem/cache_laurwt.v"
read_verilog -sv "example_soc/libfpga/mem/maintn.v"
read_verilog -sv "example_soc/libfpga/mem/sdram-qm/memoryqm.v"  
#read_verilog -sv "example_soc/libfpga/mem/sdram-qm/mmcmclock.v"
read_verilog -sv "example_soc/libfpga/mem/sdram-qm/artix7_pll.v"
read_verilog -sv "example_soc/libfpga/mem/sdram-qm/sdramwinb.v"

read_verilog -sv "example_soc/libfpga/cdc/af.v"
read_verilog -sv "example_soc/libfpga/peris/uart/uart_mini.v"

read_verilog -sv "example_soc/libfpga/mem/max7219.v"
read_verilog -sv "example_soc/libfpga/mem/clkdivider.v"

#read_verilog -sv "example_soc/libfpga/mem/sd_loader.v"
#read_verilog -sv "example_soc/libfpga/mem/sd_file_loader.v"
#read_verilog -sv "example_soc/libfpga/mem/sd_file_reader.v"
#read_verilog -sv "example_soc/libfpga/mem/sd_reader.v"
#read_verilog -sv "example_soc/libfpga/mem/sdcmd_ctrl.v"

read_verilog -sv "example_soc/libfpga/sd/sd.v"
#read_verilog -sv "example_soc/libfpga/sd/sd_spi.v"
read_vhdl "example_soc/libfpga/sd/sd_spi.vhd"
read_verilog -sv "example_soc/libfpga/sd/sdspi_file_reader.v"
read_verilog -sv "example_soc/libfpga/sd/sdspi_reader.v"
read_verilog -sv "example_soc/libfpga/sd/sdspi_loader.v"

# read constraints
read_xdc "qmtechv3.xdc"

# synth
synth_design -top "${design_name}" -part ${fpga_part}
write_checkpoint -force synth.dcp
report_timing_summary -file synthtiming.rpt
report_utilization -file synthutil.rpt

# place and route
opt_design
place_design
route_design
write_checkpoint -force route.dcp
report_timing_summary -file routetiming.rpt
report_utilization -file routeutil.rpt

report_timing_summary

# write bitstream
write_bitstream -force "top.bit"
