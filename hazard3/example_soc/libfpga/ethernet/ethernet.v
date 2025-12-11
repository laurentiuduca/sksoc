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
    output wire irqtx, irqrx
);

    reg [7:0] ctrlstate, rxstate, txstate;

    wire bus_write = pwrite && psel && penable;
    wire bus_read = !pwrite && psel && penable;

    assign pslverr = 0;

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
    reg receiving=0, rxenableirq, txenableirq, acktxirq;
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
	$display("rxgotnew discard %d bytes", nbytes);
      end else begin
	$display("start receiving %d bytes", nbytes);
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
	//$display("brrx.m[rxcnt] = %2x", b);
	brrx.m[rxcnt] = b;
	//$write("rx[%d]=%2x ", rxcnt, brrx.m[rxcnt]);
	if(rxcnt == (rxsize-1)) begin
	  receiving = 0;
          rxcnt = 0;
	  rxwrote = rxwrote + 1;
	  $display("");
	end else
          rxcnt = rxcnt + 1;
      end
    endtask
    initial begin
            ret = ethdpiinit();
    end
    `endif

    `define CTRLSTATE_SENDPACKET 7
    `define REGETH_TXSIZE_W       (`ETHERNET_DEVADDR + `ETHERNET_MTU+0)
    `define REGETH_RXREAD_W       (`ETHERNET_DEVADDR + `ETHERNET_MTU+4)
    `define REGETH_SENDPACKET_W   (`ETHERNET_DEVADDR + `ETHERNET_MTU+8)
    `define REGETH_TXENABLEIRQ_W  (`ETHERNET_DEVADDR + `ETHERNET_MTU+24)
    `define REGETH_RXENABLEIRQ_W  (`ETHERNET_DEVADDR + `ETHERNET_MTU+28)
    `define REGETH_ACKTXIRQ_W     (`ETHERNET_DEVADDR + `ETHERNET_MTU+32)
    `define REGETH_ADDTOPACKET_W  (`ETHERNET_DEVADDR + `ETHERNET_MTU)
    `define REGETH_TXSTATE_R      (`ETHERNET_DEVADDR + `ETHERNET_MTU+12)
    `define REGETH_RXSIZE_R       (`ETHERNET_DEVADDR + `ETHERNET_MTU+16)
    `define REGETH_RXWRITE_R      (`ETHERNET_DEVADDR + `ETHERNET_MTU+36)
    `define REGETH_RDFROMPACKET_R (`ETHERNET_DEVADDR + `ETHERNET_MTU)
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
	    txenableirq <= 0;
	    rxenableirq <= 0;
	    acktxirq <= 0;
        end else if (ctrlstate == 0) begin
            pready <= 0;
            if (bus_write && pready == 0) begin
                //$display("bus w paddr=%x pwdata=%x pready=%x", paddr, pwdata, pready);
                if(paddr == `REGETH_TXSIZE_W) begin
			txsize <= pwdata[15:0];
			pready <= 1;
		end else if(paddr == `REGETH_RXREAD_W) begin
			if(!receiving) begin
			    rxread <= rxwrote;
			end
                        pready <= 1;
		end else if (paddr == `REGETH_SENDPACKET_W) begin
                        // send packet
                        ctrlstate <= `CTRLSTATE_SENDPACKET;
			pready <= 0;
		end else if (paddr == `REGETH_RXENABLEIRQ_W) begin
			$display("rxenableirq <= %x (rxwrote != rxread)=%x", pwdata, (rxwrote != rxread));
                        rxenableirq <= pwdata;
                        pready <= 1;
		end else if (paddr == `REGETH_TXENABLEIRQ_W) begin
                        $display("txenableirq <= %x r_irqtx=%x", pwdata, r_irqtx);
                        txenableirq <= pwdata;
                        pready <= 1;
		end else if (paddr == `REGETH_ACKTXIRQ_W) begin
                        acktxirq <= pwdata;
                        pready <= 1;
		end else if(paddr < `REGETH_ADDTOPACKET_W) begin
                    // write to our block mem
                    ctrlstate <= 5;
                    auxdata <= pwdata;
                    midata1 <= pwdata[7:0];
                    maddr1 <= {16'h0, (paddr-`ETHERNET_DEVADDR)};
                    mw1 <= 1;
                    mcnt <= 0;
                end
           end else if(bus_read && pready == 0) begin
                   if(paddr == `REGETH_TXSTATE_R) begin
		       prdata <= txstate;
		       pready <= 1;
                   end else if(paddr == `REGETH_RXSIZE_R) begin
		       prdata <= rxsize;
                       pready <= 1;
		   end else if(paddr == `REGETH_RXWRITE_R) begin
                       prdata <= {rxread, rxwrote};
                       pready <= 1;
                   end else if(paddr < `REGETH_RDFROMPACKET_R) begin
		       if(!receiving) begin
  		         // read from rx packet
		         mcnt <= 0;
		         ctrlstate <= 10;
		         rxmaddrb <= paddr-`ETHERNET_DEVADDR;
			 //$display("read from rxmaddrb %x", paddr-`ETHERNET_DEVADDR);
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
                ctrlstate <= 6;
                mw1 <= 0;
            end
        end else if (ctrlstate == 6) begin
            pready <= 1;
            ctrlstate <= 0;
        end else if (ctrlstate == `CTRLSTATE_SENDPACKET) begin
	    // send packet
	    pready <= 1;
            ctrlstate <= 0;
        end else if (ctrlstate == 10) begin
	    `ifndef rxrealread
	    prdata <= {brrx.m[rxmaddrb+3], brrx.m[rxmaddrb+2], brrx.m[rxmaddrb+1], brrx.m[rxmaddrb+0]};
	    ctrlstate <= 6;
            `else
	    // read word from rxbuffer
	    prdata <= {prdata[23:0], rxmout};
	    mcnt <= mcnt + 1;
            rxmaddrb <= rxmaddrb + 1;
            if (mcnt == 3) begin
                ctrlstate <= 6;
            end
           `endif
        end
    end


    // tx
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            txstate <= 0; 
	    r_irqtx <= 0;
        end else if (txstate == 0) begin
            if(ctrlstate == `CTRLSTATE_SENDPACKET)
		txstate <= 1;
	end else if (txstate == 1) begin
            // write packet command
            `ifndef txrealsend
		$display("sending %d-", txsize);
                for(i=0; i<txsize; i=i+1) begin
                  ret = addbytetotxframe(brtx.m[i]);
		  if(ret != 0)
		  $write("%x ", brtx.m[i]);
		end
                ret = sendtxframe();
                txstate <= 2;
		r_irqtx <= 1;
		$display("packet sent");
		//$finish;
            `endif
        end else if (txstate == 2) begin
		if(acktxirq) begin
                        r_irqtx <= 0;
			txstate <= 3;
		end
        end else if (txstate == 3) begin
                if(!acktxirq) begin
                        txstate <= 0;
                end
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

    reg r_irqtx;
    assign irqtx = txenableirq && r_irqtx;
    assign irqrx = rxenableirq && (rxwrote != rxread);

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
