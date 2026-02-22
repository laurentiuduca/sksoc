
module mmcmclock (
    output wire clk_outsys,   
    output wire clk_out100,   // 100 MHz
    input  wire clk_in,
    input  wire reset,
    output wire locked
);

wire clkfb;
wire clkfb_buf;
wire clk_in_buf;
wire clk_outsys_mmcm, clk_out100_mmcm;

BUFG clkin_buf (
    .I(clk_in),
    .O(clk_in_buf)
);

MMCME2_BASE #(
    .CLKIN1_PERIOD(20.0),        // 50 MHz
    .DIVCLK_DIVIDE(1),
    .CLKFBOUT_MULT_F(20.0),

    .CLKOUT0_DIVIDE_F(20.0),     
    .CLKOUT1_DIVIDE(10),         // 100 MHz

    .CLKOUT0_PHASE(0.0),
    .CLKOUT1_PHASE(0.0),

    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT1_DUTY_CYCLE(0.5)
)
mmcm_inst (
    .CLKIN1(clk_in_buf),
    .CLKFBIN(clkfb_buf),
    .RST(reset),

    .CLKFBOUT(clkfb),
    .CLKOUT0(clk_outsys_mmcm),
    .CLKOUT1(clk_out100_mmcm),

    .LOCKED(locked)
);

BUFG clkout0_buf (.I(clk_outsys_mmcm), .O(clk_outsys));
BUFG clkout1_buf (.I(clk_out100_mmcm), .O(clk_out100));

BUFG clkfb_bufg (
    .I(clkfb),
    .O(clkfb_buf)
);

endmodule

