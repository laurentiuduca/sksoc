// author laurentiu cristian duca
// spdx license identifier apache
// sd driver

`include "define.vh"

module hazard3_ethernet #(
    parameter W_ADDR = 32,
    parameter W_DATA = 32
) (
    input wire clk,
    input wire rst_n,

    // APB Port
    input wire psel,
    input wire penable,
    input wire pwrite,
    input wire [15:0] paddr,
    input wire [31:0] pwdata,
    output reg [31:0] prdata,
    output reg pready,
    output wire pslverr,

    // ethernet signals
    input wire tx_clk, rx_clk
);

    reg [7:0] ctrlstate;

    wire bus_write = pwrite && psel && penable;
    wire bus_read = !pwrite && psel && penable;

    assign pslverr = 0;
    wire txbusy, rxbusy;
    assign txbusy = !|ctrlstate;

    reg [31:0] auxdata;
    reg [ 3:0] mcnt = 0;
    reg mr1 = 0, mw1 = 0;
    reg [7:0] midata1 = 0;
    wire [7:0] midata;
    wire [7:0] mout;
    reg [31:0] maddr1;
    wire [31:0] maddr;
    assign maddr = maddr1;
    wire mw;
    assign mw = mw1;
    assign midata = midata1;

    txbram brtx (
        .clk(clk),
        .maddr(maddr),
        .midata(midata),
        .mw(mw),
        .mout(mout)
    );
    reg [15:0] txsize;

    integer ret;
    import "DPI-C" function int ethdpiinit();
    import "DPI-C" function int addbytetotxframe(input byte data);
    import "DPI-C" function int sendtxframe();
    initial begin
            ret = ethdpiinit();
    end

    // tx ctrl state machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ctrlstate <= 0;
            pready <= 0;
            midata1 <= 0;
            maddr1 <= 0;
            mw1 <= 0;
            mr1 <= 0;
            mcnt <= 0;
            prdata <= 0;
            pready <= 0;
            txsize <= 0;
        end else if (ctrlstate == 0) begin
            pready <= 0;
            if (bus_write && pready == 0) begin
                //$display("bus w paddr=%x pwdata=%x pready=%x", paddr, pwdata, pready);
                if(paddr == (`ETHERNET_MTU+4)) begin
			txsize <= pwdata[15:0];
			pready <= 1;
		end else if (paddr >= `ETHERNET_MTU) begin
                        // write block;
                        ctrlstate <= 7;
			pready <= 1;
                        mr1 <= 1; 
                        maddr1 <= 0;
		end else begin
                    // write to our block mem
                    ctrlstate <= 5;
                    auxdata <= pwdata;
                    midata1 <= pwdata[7:0];
                    maddr1 <= {16'h0, paddr};
                    mw1 <= 1;
                    mcnt <= 0;
                end
           end else if(bus_read && pready == 0) begin
                   if(paddr == (`ETHERNET_MTU+4)) begin
		       prdata <= txbusy;
		       pready <= 1;
		   end
	   end
        end else if (ctrlstate == 5) begin
            // write to mem
            mcnt <= mcnt + 1;
            auxdata <= {8'h0, auxdata[31:8]};
            midata1 <= auxdata[15:8];
            maddr1 <= maddr1 + 1;
            if (mcnt == 3) begin
                //if(midata1)
                //	$display("\tbus w addr=%x data=%x", maddr1, midata1);
                ctrlstate <= 6;
                mw1 <= 0;
            end
        end else if (ctrlstate == 6) begin
            pready <= 1;
            ctrlstate <= 0;
        end else if (ctrlstate == 7) begin
            // write packet command
            `ifndef txrealsend
		ret = addbytetotxframe(mout);
                if(maddr1 >= txsize-1) begin
		    ctrlstate <= 9;
		    ret = sendtxframe();
		    mr1 <= 0;
		end else  
                    maddr1 <= maddr1 + 1;
    	    `endif
        end else if (ctrlstate == 9) begin
            ctrlstate <= 0;
            pready <= 1;
        end
    end

endmodule

module txbram (
    input wire clk,
    input wire [31:0] maddr,
    input wire [7:0] midata,
    input wire mw,
    output reg [7:0] mout
);

    reg [7:0] m[0:`ETHERNET_MTU-1];
    integer i;
    initial for (i = 0; i < `ETHERNET_MTU; i = i + 1) m[i] <= 0;
    always @(posedge clk) begin
        if (mw) m[maddr] <= midata;
        mout <= m[maddr];
    end
    //assign mout = m[maddr];
endmodule
