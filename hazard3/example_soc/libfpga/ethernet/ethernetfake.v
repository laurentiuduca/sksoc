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
