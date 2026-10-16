`default_nettype none

`include "define.vh"

module l1cache
    # (
    parameter N_SLAVES = 2,
    parameter ADDR_MAP  = 64'h40000000_00000000,
    parameter ADDR_MASK = 64'he0000000_e0000000,
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
    input wire                l1proc_hready,
    input wire                l1proc_hresp,
    input wire                l1proc_hexokay,
    output wire [ W_DATA-1:0] l1proc_hwdata,
    input wire [ W_DATA-1:0]  l1proc_hrdata,
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

//`define usel1cache
`ifdef usel1cache
    reg [ W_ADDR-1:0] ad_pc;
    reg [ W_ADDR-1:0] aproc_haddr;
    reg               aproc_hwrite;
    reg [        1:0] aproc_htrans;
    reg [        2:0] aproc_hsize;
    reg [        2:0] aproc_hburst;
    reg [        3:0] aproc_hprot;
    reg               aproc_hmastlock;
    reg               aproc_hexcl;
    reg               aproc_hready;
    reg               aproc_hresp;
    reg               aproc_hexokay;
    reg [ W_DATA-1:0] aproc_hwdata;
    reg [ W_DATA-1:0] aproc_hrdata;
    reg [ W_DATA-1:0] aproc_hmaster;

    wire weio = (proc_haddr >= (ADDR_MAP >> 32)) || proc_hwrite;
    assign l1d_pc           = weio ? d_pc : ad_pc;
    assign l1proc_haddr     = weio ? proc_haddr : aproc_haddr;
    assign l1proc_hwrite    = weio ? proc_hwrite : aproc_hwrite;
    assign l1proc_htrans    = weio ? proc_htrans : aproc_htrans;
    assign l1proc_hsize     = weio ? proc_hsize : aproc_hsize;
    assign l1proc_hburst    = weio ? proc_hburst : aproc_hburst;
    assign l1proc_hprot     = weio ? proc_hprot : aproc_hprot;
    assign l1proc_hmastlock = weio ? proc_hmastlock : aproc_hmastlock;
    assign l1proc_hexcl     = weio ? proc_hexcl : aproc_hexcl;
    assign proc_hready      = weio ? l1proc_hready : aproc_hready;
    assign proc_hresp       = weio ? l1proc_hresp : aproc_hresp;
    assign proc_hexokay     = weio ? l1proc_hexokay : aproc_hexokay;
    assign l1proc_hwdata    = weio ? proc_hwdata : aproc_hwdata;
    assign proc_hrdata      = weio ? l1proc_hrdata : aproc_hrdata;
    assign l1proc_hmaster   = weio ? proc_hmaster : aproc_hmaster;
`else
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
`endif
endmodule

