// Modified by Laurentiu Cristian Duca, 2025/08
// spdx license identifier - apache 2

`include "define.vh"

module m_topsim (
`ifndef ICARUS
    input  wire        clk,
`endif
    // SDRAM
    output wire SDCLK0,
    output wire SDCKE0,
    output wire [1:0]DQM,
    output wire CAS,
    output wire RAS,
    output wire SDWE,
    output wire SDCS0,
    inout [15:0]Data,
    output wire [12:0]Address,
    output wire [1:0]Bank,

    input  wire       i_rx,
    output wire       o_tx,
    output wire [1:0] w_led,
    input  wire       w_btnl,
    input  wire       w_btnr,
    // when sdcard_pwr_n = 0, SDcard power on
    //output wire       sdcard_pwr_n,
    // signals connect to SD bus
    output wire       sdclk,
    inout  wire       sdcmd,
    inout  wire       sddat0,
    //inout  wire       sddat1,
    //inout  wire       sddat2,
    inout  wire       sddat3,
    // display
    output wire       MAX7219_CLK,
    output wire       MAX7219_DATA,
    output wire       MAX7219_LOAD
);

wire sdcard_pwr_n;
wire sddat1, sddat2;

wire pll_clk;
wire clk_sdram;
wire locked;
reg [31:0] cnt=0;
reg rst_n=0;
always@(posedge clk)
        if(cnt < 24) begin
                rst_n <= 0;
                cnt <= cnt + 1;
	end else begin
                rst_n <= 1;
	        if (cnt >= 32'h2220) begin
		`ifdef DUMP_VCD
            		$display("time to finish %d", $time);
            		$finish;
		`endif
        	end else cnt <= cnt + 1;
	end
`ifdef SIM_MODE
assign pll_clk = clk;
assign clk_sdram = clk;
assign locked = rst_n;
`else
artix7_pll
u_pll
(
    .clkref_i(clk)           // 50
    ,.rst(~rst_n)
    ,.locked(locked)
    // Outputs
    ,.clkout0_o(clk_sdram)         // 100
    ,.clkout1_o()     // 400
    ,.clkout2_o()     // 200
    ,.clkout3_o() // 400 (phase 90)
    ,.clkout4_o(pll_clk)
);
`ifdef laur0
mmcmclock mmcmlaur(
    .clk_in(clk),     // 50 MHz input
    .reset(~rst_n),       // active-high reset
    .clk_outsys(pll_clk),
    .clk_out100(clk_sdram),
    .locked(locked)
);
`endif
//assign pll_clk = clk;
`endif
    wire w_rxd = 1;
    wire w_txd, uart_tx;
    assign o_tx = w_init_done ? uart_tx : w_txd;
    wire w_init_done;

    example_soc #(
        .CLK_MHZ   (50)        // For timer timebase
    ) es (
        // System clock + reset
        .clk(pll_clk),
        .rst_n(locked),
	.clk_sdram(clk_sdram),

        // JTAG port to RISC-V JTAG-DTM
        .tck(1'b0),
        .trst_n(1'b0),
        .tms(1'b0),
        .tdi(1'b1),
        .tdo(),

        // IO
        .uart_tx(uart_tx),
        .uart_rx(1'b1),

	                        // SDRAM
                                .SDCLK0(SDCLK0),
                                .SDCKE0(SDCKE0),
                                .DQM(DQM),
                                .CAS(CAS),
                                .RAS(RAS),
                                .SDWE(SDWE),
                                .SDCS0(SDCS0),
                                .Data(Data),
                                .Address(Address),
                                .Bank(Bank),

        .w_rxd(w_rxd),
        .w_txd(w_txd),
        .w_led(w_led),
        .w_btnl(w_btnl),
        .w_btnr(w_btnr),
        // when sdcard_pwr_n = 0, SDcard power on
        .sdcard_pwr_n(sdcard_pwr_n),
        // signals connect to SD bus
        .sdclk(sdclk),
        .sdcmd(sdcmd),
        .sddat0(sddat0),
        .sddat1(sddat1),
        .sddat2(sddat2),
        .sddat3(sddat3),
        .w_init_done(w_init_done),
        // display
        .MAX7219_CLK(MAX7219_CLK),
        .MAX7219_DATA(MAX7219_DATA),
        .MAX7219_LOAD(MAX7219_LOAD)
    );

`ifdef DUMP_VCD
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars();
    end
`endif

endmodule
