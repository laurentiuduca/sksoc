// Modified by Laurentiu Cristian Duca, 2025/08
// spdx license identifier - apache 2

`include "define.vh"

module m_topsim (
`ifndef ICARUS
    input  wire          clk,
`endif
`ifdef WUKONGSDRAM
    output wire          SDCLK0,
    output wire          SDCKE0,
    output wire [   1:0] DQM,
    output wire          CAS,
    output wire          RAS,
    output wire          SDWE,
    output wire          SDCS0,
    inout       [  15:0] Data,
    output wire [  12:0] Address,
    output wire [   1:0] Bank,
`endif
`ifdef WUKONGDDR3
    // DDR3 I/O Interface
    output wire          ddr3_clk_p,
    ddr3_clk_n,
    output wire          ddr3_reset_n,
    output wire          ddr3_cke,      // CKE
    //output wire ddr3_cs_n, // no chip select signal
    output wire          ddr3_ras_n,    // RAS#
    output wire          ddr3_cas_n,    // CAS#
    output wire          ddr3_we_n,     // WE#
    output wire [14-1:0] ddr3_addr,
    output wire [ 3-1:0] ddr3_ba,
    inout  wire [16-1:0] ddr3_dq,
    inout  wire [ 2-1:0] ddr3_dqs_p,
    ddr3_dqs_n,
    output wire [ 2-1:0] ddr3_dm,
    output wire          ddr3_odt,      // on-die termination
`endif

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

`ifdef ICARUS
    reg clk = 0;
    always #5 clk = ~clk;
`endif

    wire pll_clk;
`ifdef WUKONGSDRAM
    wire clk_sdram;
`endif
    wire locked;
    reg [31:0] cnt = 0;
    reg rst_n = 0;
    always @(posedge clk)
        if (cnt < 24) begin
            rst_n <= 0;
            cnt   <= cnt + 1;
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
`ifdef WUKONGSDRAM
    assign clk_sdram = clk;
`endif
`ifdef WUKONGDDR3
    assign i_controller_clk = clk;
    assign i_ddr3_clk = clk;
    assign i_ref_clk = clk;
    assign i_ddr3_clk_90 = clk;
`endif
    assign locked = rst_n;
`else
`ifdef WUKONGSDRAM
`ifdef laur0
    artix7_pll u_pll (
          .clkref_i (clk)        // 50
        , .rst      (~rst_n)
        , .locked   (locked)
        // Outputs
        , .clkout0_o(clk_sdram)  // 100
        , .clkout1_o()           // 400
        , .clkout2_o()           // 200
        , .clkout3_o()           // 400 (phase 90)
        , .clkout4_o(pll_clk)
    );
`endif
    mmcmclock mmcmlaur (
        .clk_in    (clk),        // 50 MHz input
        .reset     (~rst_n),     // active-high reset
        .clk_outsys(pll_clk),
        .clk_out100(clk_sdram),
        .locked    (locked)
    );
    reset_sync rstsdram (
        .clk(clk_sdram),
        .rst_n_in(locked),
        .rst_n_out(rst_n_sdram)
    );
`endif
`endif
`ifdef WUKONGDDR3
    wire i_controller_clk, i_ddr3_clk, i_ref_clk, i_ddr3_clk_90;
`ifndef SIM_MODE
    clk_wiz clk_wiz_inst (
        // Clock out ports
        .clk_out0(i_controller_clk),
        .clk_out1(i_ddr3_clk),
        .clk_out2(i_ref_clk),
        .clk_out3(i_ddr3_clk_90),
        .clk_out4(pll_clk),
        // Status and control signals
        .reset(!rst_n),
        .locked(locked),
        // Clock in ports
        .clk_in(clk)
    );
`endif
    wire rst_n_ddram;
    reset_sync rstddram (
        .clk(i_controller_clk),
        .rst_n_in(locked),
        .rst_n_out(rst_n_ddram)
    );
`endif

    wire rst_n_syst;
    reset_sync rstsyst (
        .clk(pll_clk),
        .rst_n_in(locked),
        .rst_n_out(rst_n_syst)
    );

    wire w_rxd = 1;
    wire w_txd, uart_tx;
    wire w_init_done;
    assign o_tx = w_init_done ? uart_tx : w_txd;

    example_soc #(
        .CLK_MHZ(`FREQ / 1000000)  // For timer timebase
    ) es (
        // System clock + reset
        .clk  (pll_clk),
        .rst_n(rst_n_syst),

        // JTAG port to RISC-V JTAG-DTM
        .tck(1'b0),
        .trst_n(1'b0),
        .tms(1'b0),
        .tdi(1'b1),
        .tdo(),

        // IO
        .uart_tx(uart_tx),
        .uart_rx(1'b1),

`ifdef WUKONGSDRAM
        .clk_sdram(clk_sdram),
        .rst_n_sdram(rst_n_sdram),
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
`endif
`ifdef WUKONGDDR3
        .i_controller_clk(i_controller_clk),
        .i_ddr3_clk(i_ddr3_clk),
        .i_ref_clk(i_ref_clk),
        .i_ddr3_clk_90(i_ddr3_clk_90),
        .rst_n_ddram(rst_n_ddram),
        // DDR3 I/O Interface
        .ddr3_clk_p(ddr3_clk_p),
        .ddr3_clk_n(ddr3_clk_n),
        .ddr3_reset_n(ddr3_reset_n),
        .ddr3_cke(ddr3_cke),  // CKE
        //ddr3_cs_n, // no chip select signal
        .ddr3_ras_n(ddr3_ras_n),  // RAS#
        .ddr3_cas_n(ddr3_cas_n),  // CAS#
        .ddr3_we_n(ddr3_we_n),  // WE#
        .ddr3_addr(ddr3_addr),
        .ddr3_ba(ddr3_ba),
        .ddr3_dq(ddr3_dq),
        .ddr3_dqs_p(ddr3_dqs_p),
        .ddr3_dqs_n(ddr3_dqs_n),
        .ddr3_dm(ddr3_dm),
        .ddr3_odt(ddr3_odt),  // on-die termination
`endif
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
