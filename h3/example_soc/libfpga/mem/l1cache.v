`default_nettype none

`include "define.vh"

module l1cache
    # (
    `include "hazard3_config.vh"
    )(

    input wire [ W_ADDR-1:0] d_pc,
    input wire [ W_ADDR-1:0] proc_haddr,
    input wire               proc_hwrite,
    input wire [        1:0] proc_htrans,
    input wire [        2:0] proc_hsize,
    input wire [        2:0] proc_hburst,
    input wire [        3:0] proc_hprot,
    input wire               proc_hmastlock,
    input wire               proc_hexcl,
    output wire              proc_hready,
    output wire              proc_hresp,
    output wire              proc_hexokay,
    input wire [ W_DATA-1:0] proc_hwdata,
    output wire [ W_DATA-1:0] proc_hrdata,
    input wire [ W_DATA-1:0] proc_hmaster,

    output wire [ W_ADDR-1:0] l1d_pc,
    output wire [ W_ADDR-1:0] l1proc_haddr,
    output wire               l1proc_hwrite,
    output wire [        1:0] l1proc_htrans,
    output wire [        2:0] l1proc_hsize,
    output wire [        2:0] l1proc_hburst,
    output wire [        3:0] l1proc_hprot,
    output wire               l1proc_hmastlock,
    output wire               l1proc_hexcl,
    output wire                l1proc_hready,
    output wire                l1proc_hresp,
    output wire                l1proc_hexokay,
    output wire [ W_DATA-1:0] l1proc_hwdata,
    output wire [ W_DATA-1:0]  l1proc_hrdata,
    output wire [ W_DATA-1:0] l1proc_hmaster,    

    input wire              sram0_hready_resp,
    input wire              sram0_hready,
    input wire              sram0_hresp, 
    input wire [W_ADDR-1:0] sram0_haddr,
    input wire              sram0_hwrite,
    input wire [       1:0] sram0_htrans,
    input wire [       2:0] sram0_hsize,
    input wire [       2:0] sram0_hburst,
    input wire [       3:0] sram0_hprot,
    input wire              sram0_hmastlock,
    input wire [W_DATA-1:0] sram0_hwdata,
    input wire [W_DATA-1:0] sram0_hrdata,
    input wire [W_ADDR-1:0] sram0_d_pc,
    // exclusive access signaling
    input wire              sram0_hexcl,
    input wire [W_DATA-1:0] sram0_hmaster,
    input wire              sram0_hexokay
);

    assign l1d_pc = d_pc;
    assign l1proc_haddr = proc_haddr;
    assign l1proc_hwrite = proc_hwrite;
    assign l1proc_htrans = proc_htrans;
    assign l1proc_hsize = proc_hsize;
    assign l1proc_hburst = proc_hburst;
    assign l1proc_hprot = proc_hprot;
    assign l1proc_hmastlock = proc_hmastlock;
    assign l1proc_hexcl = proc_hexcl;
    assign proc_hready = l1proc_hready;
    assign proc_hresp = l1proc_hresp;
    assign proc_hexokay = l1proc_hexokay;
    assign l1proc_hwdata = proc_hwdata;
    assign proc_hrdata = l1proc_hrdata;
    assign l1proc_hmaster = proc_hmaster;

    assign l1proc_hready  = sram0_hready;
    assign l1proc_hready  = sram0_hready_resp;
    assign l1proc_hexokay = sram0_hexokay;
    assign l1proc_hrdata  = sram0_hrdata;

endmodule

