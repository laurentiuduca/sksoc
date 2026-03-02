// laur
`define SIM_MODE

//`define DUMP_VCD
// dbgstart may be defined in hazard3_config.vh, not here
//`define dbgsclr
//`define dbgdhrystone
//`define dbghexcl

//`define TN_DRAM_REFRESH // for tang nano
`define SIM_TNSRAM // tang nano not only sim ram
`define frdiv 40
`define FREQ (1000 / `frdiv) * 1_000_000
/*
CLK
mmcm
uart define.vh:`define SERIAL_WCNT (FREQ/115200)
sd v and vhdl
eth
example_soc #( 
        .CLK_MHZ   (40)        // For timer timebase
sdram clk
    ) 
define.vh `define SDCARD_CLK_DIV 3 // clk is 50mhz
*/

`define ethon
//`define ethirqon
`define ETHERNET_DEVADDR 16'hc000
`define ETHERNET_MTU 16'd1500

`define SDSPI
`define SDSPI_DEVADDR 16'h8000
`define SDSPI_BLOCKSIZE 16'd512
`define SDSPI_BLOCKADDR (`SDSPI_DEVADDR + `SDSPI_BLOCKSIZE)
`define SDSPI_ADDRUH 16'h4000
//`define simsdspi
`define SDCARD_CLK_DIV 3 // clk is 50mhz
`define FAT32_SD

`define CACHE_SIZE (32*1024)

`ifdef SIM_MODE
`define SERIAL_WCNT 2
`else
`define SERIAL_WCNT (`FREQ / 115200)
`endif

`define XLEN    32
`define LATENCY 0

`ifndef SIM_MODE
	`define LAUR_MEM_RB // mem read-back after writing it with BBL
	`define LAUR_MEM_RB_ONLY_CHECK
`endif

`define MEM_SIZE (8*1024*1024)
`define BBL_SIZE (1024*1024) // initmem.bin
`define BIN_BBL_SIZE   `BBL_SIZE
`define BIN_DISK_SIZE 0
`define BIN_SIZE       (`BIN_BBL_SIZE + `BIN_DISK_SIZE)

// simulate sdram winbond
`define winbaddrlen 24
`define winbdatalen 16
`define winbmasklen 2
