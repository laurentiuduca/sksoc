`default_nettype none

`include "define.vh"

module l1cache
    # (
    parameter N_MASTERS = 2,
    parameter N_SLAVES = 2,
    parameter ADDR_MAP  = 64'h40000000_00000000,
    parameter ADDR_MASK = 64'he0000000_e0000000,
    `include "hazard3_config.vh"
    )(
    input wire clk, rst_n,
    input wire [ W_DATA-1:0] mhartid_val,
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

    output wire               hready,
    output wire [ W_ADDR-1:0] l1d_pc,
    output wire [ W_ADDR-1:0] l1proc_haddr,
    output wire               l1proc_hwrite,
    output wire [        1:0] l1proc_htrans,
    output wire [        2:0] l1proc_hsize,
    output wire [        2:0] l1proc_hburst,
    output wire [        3:0] l1proc_hprot,
    output wire               l1proc_hmastlock,
    output wire               l1proc_hexcl,
    input wire                l1proc_hready_resp,
    input wire                l1proc_hresp,
    input wire                l1proc_hexokay,
    output wire [ W_DATA-1:0] l1proc_hwdata,
    input wire [ W_DATA-1:0]  l1proc_hrdata,
    output wire [ W_DATA-1:0] l1proc_hmaster,    

    input wire [N_HARTS-1:0] mem_mast_gnt_a, peri_mast_gnt_a,
    input wire [N_HARTS-1:0] mem_mast_gnt_d, peri_mast_gnt_d,

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


localparam hprot_instr = {
        2'b00,                  // Noncacheable/nonbufferable
        1'b1,                   // Privileged
        1'b0                    // Instruction access
};
localparam HTRANS_IDLE = 2'b00;
localparam HSIZE_WORD  = 3'd2;

`ifdef usel1cache
    reg               rhready;
    reg [ W_ADDR-1:0] ad_pc;
    reg [ W_ADDR-1:0] aproc_haddr;
    reg               aproc_hwrite;
    reg [        1:0] aproc_htrans;
    reg [        2:0] aproc_hsize;
    reg [        2:0] aproc_hburst;
    reg [        3:0] aproc_hprot;
    reg               aproc_hmastlock;
    reg               aproc_hexcl;
    reg               aproc_hready_resp;
    reg               aproc_hresp;
    reg               aproc_hexokay;
    reg [ W_DATA-1:0] aproc_hwdata;
    reg [ W_DATA-1:0] aproc_hrdata;
    reg [ W_DATA-1:0] aproc_hmaster;

    wire io = proc_htrans[1] && ((proc_haddr[31:28] & ADDR_MASK[63:60]) == ADDR_MAP[63:60]);
    assign hready           = rhready;
    assign l1d_pc           = ad_pc;
    assign l1proc_haddr     = aproc_haddr;
    assign l1proc_hwrite    = aproc_hwrite;
    assign l1proc_htrans    = aproc_htrans; //(state == 2 || state == 12) && l1proc_hready_resp ? HTRANS_IDLE : aproc_htrans;
    assign l1proc_hsize     = aproc_hsize;
    assign l1proc_hburst    = aproc_hburst;
    assign l1proc_hprot     = aproc_hprot;
    assign l1proc_hmastlock = aproc_hmastlock;
    assign l1proc_hexcl     = aproc_hexcl;
    assign proc_hready      = aproc_hready_resp;
    assign proc_hresp       = 1'b0;
    assign proc_hexokay     = aproc_hexokay;
    assign l1proc_hwdata    = aproc_hwdata;
    assign proc_hrdata      = aproc_hrdata;
    assign l1proc_hmaster   = aproc_hmaster;

    integer i;
    reg [N_SLAVES-1:0] slave_sel;
    always @(*) begin
        if (aproc_htrans == HTRANS_IDLE) begin
            slave_sel = {N_SLAVES{1'b0}};
        end else begin
            for (i = 0; i < N_SLAVES; i = i + 1) begin
                slave_sel[i] = ((aproc_haddr & ADDR_MASK[i * W_ADDR +: W_ADDR])
                                == ADDR_MAP[i * W_ADDR +: W_ADDR]);
            end
        end
    end


    // Decode AHBL controls
    //wire [3:0] wmask_noshift = ~({4{1'b1}} << (1 << proc_hsize));
    //wire [3:0] wmask = wmask_noshift << proc_haddr[1:0];
    wire proc_read_aphase = proc_htrans[1] && !proc_hwrite;
    wire proc_write_aphase = proc_htrans[1] && proc_hwrite;


    task preparea;
    rhready <= 1;
    ad_pc           <= d_pc;
    aproc_haddr     <= proc_haddr;
    aproc_hwrite    <= proc_hwrite;
    aproc_htrans    <= proc_htrans;
    aproc_hsize     <= proc_hsize;
    aproc_hburst    <= proc_hburst;
    aproc_hprot     <= proc_hprot;
    aproc_hmastlock <= proc_hmastlock;
    aproc_hexcl     <= proc_hexcl;
    aproc_hwdata    <= proc_hwdata;
    aproc_hmaster   <= proc_hmaster;
    endtask

    reg [5:0] state;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= 0;
            rhready <= 1;
            ad_pc <= 0;
            aproc_haddr <= 0;
            aproc_hwrite <= 0;
            aproc_htrans <= HTRANS_IDLE;
            aproc_hsize <= HSIZE_WORD;
            aproc_hburst <= 0;
            aproc_hprot <= hprot_instr;
            aproc_hmastlock <= 0;
            aproc_hexcl <= 0;
            aproc_hready_resp <= 0;
            aproc_hresp <= 0;
            aproc_hexokay <= 1;
            aproc_hwdata <= 0;
            aproc_hrdata <= 0;
            aproc_hmaster <= mhartid_val;
        end else begin
            if(state == 0) begin
                aproc_hready_resp <= 0;
                if(proc_read_aphase && l1proc_hready_resp) begin
                    preparea;
                    state <= 1;
                end else if(proc_write_aphase && l1proc_hready_resp) begin
                    preparea;
                    state <= 10;
                end 
                //if (proc_hexcl) begin
                    // bypass cache to make reservation
                //end
            end else if(state == 1) begin
                // let splitter get the command
                //if(!l1proc_hready_resp) begin
                if((mem_mast_gnt_d[mhartid_val] && slave_sel[0]) || 
                   (peri_mast_gnt_d[mhartid_val] && slave_sel[1])) begin
                     rhready <= 0;
                     state <= 2;
                end
            end else if(state == 2) begin
                if(l1proc_hready_resp) begin
                    aproc_htrans <= HTRANS_IDLE;
                    aproc_hready_resp <= 1;
                    aproc_hrdata <= l1proc_hrdata;
                    state <= 0;
                end
            end else if(state == 10) begin
                // data phase of wr
                //aproc_hready_resp <= 1;
                aproc_hwdata <= proc_hwdata;
                state <= 11;
            end else if(state == 11) begin
                // let splitter get the command
                //if(!l1proc_hready_resp) begin
                if((mem_mast_gnt_d[mhartid_val] && slave_sel[0]) ||
                   (peri_mast_gnt_d[mhartid_val] && slave_sel[1])) begin

                    rhready <= 0;
                    state <= 12;
                end
            end else if(state == 12) begin
                if(l1proc_hready_resp) begin
                    aproc_htrans <= HTRANS_IDLE;
                    aproc_hready_resp <= 1;
                    state <= 0;
                end
            end else if(state == 20) begin
                aproc_hready_resp <= 0;
                state <= 0;
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
    assign hready = l1proc_hready_resp;
    assign proc_hready = hready;
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
            r_odata <= w_idata;
        end else
            r_odata <= mem[w_addr];
        r_odata2 <= mem[w_addr2];
    end

endmodule

/**************************************************************************************************/
/*** Simple Direct Mapped Cache Sync CLK for DRAM                                               ***/
/**************************************************************************************************/
module m_dram_cache2
#(
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
      end else begin
        r_tag <= w_tag;
        r_idx <= w_idx;
        r_tag2 <= w_tag2;
        r_idx2 <= w_idx2;
      end
    end
endmodule

