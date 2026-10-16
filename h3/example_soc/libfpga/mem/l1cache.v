`default_nettype none

`include "define.vh"

module l1cache
    # (
    parameter N_SLAVES = 2,
    parameter ADDR_MAP  = 64'h40000000_00000000,
    parameter ADDR_MASK = 64'he0000000_e0000000,
    `include "hazard3_config.vh"
    )(
        .clk          (clk),
        .rst_n        (rst_n),
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


    // Decode AHBL controls
    wire [3:0] wmask_noshift = ~({4{1'b1}} << (1 << ahbls_hsize));
    wire [3:0] wmask = wmask_noshift << ahbls_haddr[1:0];
    wire ahb_read_aphase = ahbls_htrans[1] && ahbls_hready && !ahbls_hwrite;
    wire ahb_write_aphase = ahbls_htrans[1] && ahbls_hready && ahbls_hwrite;
    // AHBL hookup
    assign ahbls_hresp = 1'b0;
    assign ahbls_hready_resp = (state == 0) ? !w_dram_busy :
               (state == 21) ? !w_dram_busy : (state == 31);
    assign ahbls_hrdata = w_dram_odata;
    assign ahbls_hexokay = r_ahbls_hexokay;

    reg [5:0] state;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= 0;
        end else begin
            if(state == 0) begin
                if (ahbls_hexcl) begin
                    // bypass cache
                end
            end 
        end
    end


`else
    // bypass cache
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

/**************************************************************************************************/

/*** dual-port RAM with synchronous read                                                      ***/
module m_bram2 #(
    parameter WIDTH = 32,
    ENTRY = 256
) (
    CLK,
    w_we,
    w_addr,
    w_addr2,
    w_idata,
    r_odata,
    r_odata2
);
    input wire CLK, w_we;
    input wire [$clog2(ENTRY)-1:0] w_addr, w_addr2;
    input wire [WIDTH-1:0] w_idata;
    output reg [WIDTH-1:0] r_odata, r_odata2;

    reg     [WIDTH-1:0] mem[0:ENTRY-1];

    integer             i;
    initial for (i = 0; i < ENTRY; i = i + 1) mem[i] = 0;

    always @(posedge CLK) begin
        if (w_we) begin
            mem[w_addr] <= w_idata;
        end
        r_odata <= mem[w_addr];
        r_odata2 <= mem[w_addr2];
    end

endmodule

/**************************************************************************************************/
/*** Simple Direct Mapped Cache Sync CLK for DRAM                                               ***/
/**************************************************************************************************/
module m_dram_cache #(
    parameter ADDR_WIDTH = 30,
    D_WIDTH = 32,
    ENTRY = 1024
) (
    CLK,
    RST_X,
    w_clr,
    w_we,
    w_addr, w_addr2,
    w_idata,
    w_odata, w_odata2,
    w_oe, w_oe2
);
    input wire CLK, RST_X;
    input wire w_we, w_clr;
    input wire [ADDR_WIDTH-1:0] w_addr, w_addr2;
    input wire [D_WIDTH-1:0] w_idata;
    output wire [D_WIDTH-1:0] w_odata, w_odata2;
    output wire w_oe, w_oe2;

    // index and tag
    reg [               $clog2(ENTRY)-1:0] r_idx, r_idx2;
    reg [(ADDR_WIDTH - $clog2(ENTRY))-1:0] r_tag, r_tag2;

    // index and tag
    wire [$clog2(ENTRY)-1:0] w_idx, w_idx2;
    wire [(ADDR_WIDTH - $clog2(ENTRY))-1:0] w_tag, w_tag2;
    assign {w_tag, w_idx} = w_addr;
    assign {w_tag2, w_idx2} = w_addr2;

    wire w_mwe = w_clr | w_we | !RST_X;
    wire [$clog2(ENTRY)-1:0] w_maddr = w_idx;
    wire [$clog2(ENTRY)-1:0] w_maddr2 = w_idx2;
    wire [ADDR_WIDTH - $clog2(ENTRY) + D_WIDTH:0] 
    w_mwdata = w_we ? {1'b1, w_tag, w_idata} : 
                      {1'b0, {(ADDR_WIDTH - $clog2(ENTRY)) {1'b0}}, {D_WIDTH{1'b0}}};
    wire [ADDR_WIDTH - $clog2(ENTRY) + D_WIDTH:0] w_modata, w_modata2;

    wire w_mvalid, w_mvalid2;
    wire [(ADDR_WIDTH - $clog2(ENTRY))-1:0] w_mtag, w_mtag2;
    wire [D_WIDTH-1:0] w_mdata, w_mdata2;
    assign {w_mvalid, w_mtag, w_mdata} = w_modata;
    assign {w_mvalid2, w_mtag2, w_mdata2} = w_modata2;

    m_bram2 #((ADDR_WIDTH - $clog2(
        ENTRY
    ) + D_WIDTH) + 1, ENTRY) mem (
        CLK,
        w_mwe,
        w_maddr,
        w_maddr2,
        w_mwdata,
        w_modata,
        w_modata2
    );

    assign w_odata = w_mdata;
    assign w_oe    = (w_mvalid && w_mtag == r_tag);
    assign w_odata2= w_mdata2;
    assign w_oe2   = (w_mvalid2 && w_mtag2 == r_tag2);

    always @(posedge CLK or negedge RST_X) begin
      if(!RST_X) begin
        r_tag <= 0;
        r_idx <= 0;
        r_tag2 <= 0;
        r_idx2 <= 0;
      end else
        r_tag <= w_tag;
        r_idx <= w_idx;
        r_tag2 <= w_tag2
        r_idx2 <= w_idx2;
      end
    end
endmodule

