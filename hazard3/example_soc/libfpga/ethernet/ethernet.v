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
    input wire tx_clk, rx_clk,
    output wire irq
);

    reg [7:0] ctrlstate, rxstate, txstate;

    wire bus_write = pwrite && psel && penable;
    wire bus_read = !pwrite && psel && penable;

    assign pslverr = 0;
    wire txbusy;
    assign txbusy = !|ctrlstate;

    reg [31:0] auxdata;
    reg [ 3:0] mcnt = 0;
    // tx
    reg mw1 = 0;
    reg [7:0] midata1 = 0;
    wire [7:0] midata;
    wire [7:0] mout;
    reg [31:0] maddr1;
    wire [31:0] maddr;
    assign maddr = maddr1;
    wire mw;
    assign mw = mw1;
    assign midata = midata1;
    // rx
    reg rxmw1 = 0;
    reg [7:0] rxmidata1 = 0;
    wire [7:0] rxmidata;
    reg [31:0] rxmaddra, rxmaddrb;
    wire [7:0] rxmouta, rxmoutb;
    wire rxmw;
    assign rxmw = rxmw1;
    assign rxmidata = rxmidata1;

    ethbram brtx (
        .clk(clk),
        .maddr(maddr),
        .midata(midata),
        .mw(mw),
        .mout(mout)
    );
    ethbram2 brrx (
        .clk(clk), 
        .maddra(rxmaddra),
	.maddrb(rxmaddrb),
        .midata(rxmidata),
        .mw(rxmw),
        .mouta(rxmouta),
        .moutb(rxmoutb)	
    );    

    reg [15:0] txsize=0, rxsize=0, rxcnt=0, ndiscarded=0, rxdiscard=0, rxread=0, rxwrote=0;
    reg hostrx=0, receiving=0, enableirq, zerotxirq;
    `ifndef realeth
    integer ret, i;
    import "DPI-C" function int ethdpiinit();
    import "DPI-C" function int addbytetotxframe(input byte data);
    import "DPI-C" function int sendtxframe();
    import "DPI-C" function int checkrx();
    export "DPI-C" task rxgotnew;
    export "DPI-C" task rxoctet;
    reg posclk, pm=0;
    task rxgotnew(input int nbytes);
      if(rxread != rxwrote) begin 
	rxdiscard = nbytes;
	$display("rxgotnew discard");
      end else begin
	rxdiscard = 0;
	rxsize = nbytes;
	receiving = 1;
	rxcnt = 0;
      end
    endtask
    task rxoctet(input int b);
      //$display("rxoctet b=%x", b);
      if(rxdiscard) begin
	if(rxdiscard == 1)
	  ndiscarded = ndiscarded + 1;
        rxdiscard = rxdiscard - 1;
      end else begin
	//$display("brrx.m[rxcnt] = %x", b);
	brrx.m[rxcnt] = b;
	if(rxcnt == (rxsize-1)) begin
	  receiving = 0;
          rxcnt = 0;
	  rxwrote = rxwrote + 1;
	end else
          rxcnt = rxcnt + 1;
      end
    endtask
    initial begin
            ret = ethdpiinit();
    end
    `endif

    // ctrl state machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ctrlstate <= 0;
            pready <= 0;
            midata1 <= 0;
            maddr1 <= 0;
            mw1 <= 0;
            mcnt <= 0;
            prdata <= 0;
            pready <= 0;
            txsize <= 0;
	    hostrx <= 0;
	    enableirq <= 0;
	    zerotxirq <= 0;
        end else if (ctrlstate == 0) begin
            pready <= 0;
            if (bus_write && pready == 0) begin
                $display("bus w paddr=%x pwdata=%x pready=%x", paddr, pwdata, pready);
                if(paddr == (`ETHERNET_DEVADDR + `ETHERNET_MTU+0)) begin
			txsize <= pwdata[15:0];
			pready <= 1;
		end else if(paddr == (`ETHERNET_DEVADDR + `ETHERNET_MTU+4)) begin
			if(!receiving) begin
			    rxread <= rxwrote;
			end
                        pready <= 1;
		end else if (paddr == (`ETHERNET_DEVADDR + `ETHERNET_MTU+8)) begin
                        // send packet
                        ctrlstate <= 7;
			pready <= 0;
		end else if (paddr == (`ETHERNET_DEVADDR + `ETHERNET_MTU+28)) begin
			$display("enableirq");
                        enableirq <= pwdata;
                        pready <= 1;
		end else if (paddr == (`ETHERNET_DEVADDR + `ETHERNET_MTU+32)) begin
                        zerotxirq <= pwdata;
                        pready <= 1;
		end else if(paddr < `ETHERNET_DEVADDR + `ETHERNET_MTU) begin
                    // write to our block mem
                    ctrlstate <= 5;
                    auxdata <= pwdata;
                    midata1 <= pwdata[7:0];
                    maddr1 <= {16'h0, paddr};
                    mw1 <= 1;
                    mcnt <= 0;
                end
           end else if(bus_read && pready == 0) begin
                   if(paddr == (`ETHERNET_DEVADDR + `ETHERNET_MTU+12)) begin
		       prdata <= txbusy;
		       pready <= 1;
                   end else if(paddr == (`ETHERNET_DEVADDR + `ETHERNET_MTU+16)) begin
		       prdata <= rxsize;
                       pready <= 1;
		   end else if(paddr == (`ETHERNET_DEVADDR + `ETHERNET_MTU+20)) begin
                       prdata <= hostrx;
		       pready <= 1;
		   end else if(paddr == (`ETHERNET_DEVADDR + `ETHERNET_MTU+24)) begin
                       prdata <= txstate;
                       pready <= 1;
		   end else if(paddr == (`ETHERNET_DEVADDR + `ETHERNET_MTU+32)) begin
                       prdata <= {rxread, rxwrote};
                       pready <= 1;
                   end else if(paddr < `ETHERNET_DEVADDR + `ETHERNET_MTU) begin
		       if(!receiving) begin
  		         // read from rx packet
		         mcnt <= 0;
		         ctrlstate <= 10;
		         rxmaddrb <= paddr;
		       end
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
	    // send packet
	    pready <= 1;
            ctrlstate <= 0;
        end else if (ctrlstate == 10) begin
	    `ifndef rxrealread
	    prdata <= {brrx.m[rxmaddrb], brrx.m[rxmaddrb+1], brrx.m[rxmaddrb+2], brrx.m[rxmaddrb+3]};
	    ctrlstate <= 6;
            `else
	    // read word from rxbuffer
	    prdata <= {prdata[23:0], rxmout};
	    mcnt <= mcnt + 1;
            rxmaddrb <= rxmaddrb + 1;
            if (mcnt == 3) begin
                //if(midata1)
                //      $display("\tbus w addr=%x data=%x", maddr1, midata1);
                ctrlstate <= 6;
            end
           `endif
        end
    end


    // tx
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            txstate <= 0; 
	    irqtx <= 0;
        end else if (txstate == 0) begin
		if(ctrlstate == 7)
			txstate <= 1;
		if(zerotxirq)
			irqtx <= 0;
	end else if (txstate == 1) begin
            // write packet command
            `ifndef txrealsend
                for(i=0; i<txsize; i=i+1)
                        ret = addbytetotxframe(brtx.m[i]);
                ret = sendtxframe();
                txstate <= 0;
		irqtx <= 1;
            `endif
        end
    end

    // rx
    reg [15:0] rxcnt2;
    always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        rxstate <= 0;
	rxcnt2 <= 0;
      end else if(rxstate == 0) begin
	if(rxcnt2 < 1000)
		rxcnt2 <= rxcnt2 + 1;
	else begin
		rxcnt2 <= 0;
		ret = checkrx();
	end
      end
    end

    wire irqrx;
    reg irqtx;
    assign irqrx = rxwrote != rxread;
    assign irq=enableirq && (irqrx | irqtx);

endmodule

module ethbram (
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
endmodule

module ethbram2 (
    input wire clk,
    input wire [31:0] maddra,
    input wire [31:0] maddrb,
    input wire [7:0] midata,
    input wire mw,
    output reg [7:0] mouta,
    output reg [7:0] moutb
);

    reg [7:0] m[0:`ETHERNET_MTU-1];
    integer i;
    initial for (i = 0; i < `ETHERNET_MTU; i = i + 1) m[i] <= 0;
    always @(posedge clk) begin
        if (mw) m[maddra] <= midata;
        mouta <= m[maddra];
        moutb <= m[maddrb];
    end
endmodule
