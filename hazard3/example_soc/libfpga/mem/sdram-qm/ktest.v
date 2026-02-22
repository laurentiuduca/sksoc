`timescale 1ns / 1ps

module ktest(
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

    //input sys_rst_n,
    input clk50min,	 
	output reg led_1, led_2,
    output wire MAX7219_CLK, MAX7219_DATA, MAX7219_LOAD,

    output wire uart_XMIT_dataH, input wire uart_REC_dataH
    );

//-----------------------------------------------------------------
// PLL
//-----------------------------------------------------------------
reg [31:0] cnt=0;
reg sys_rst_n=0;
always@(posedge clk50min)
	if(cnt < 24) begin
		sys_rst_n <= 0; 
		cnt <= cnt + 1;
	end else
		sys_rst_n <= 1;

wire locked;
wire clk;
clk_mmcm_example mmcmlaur(
    .clk_in(clk50min),     // 50 MHz input
    .reset(~sys_rst_n),       // active-high reset
    .clk_out(clk),     // 100MHz output
    .locked(locked)
);

assign SDCLK0=clk;

wire [15:0 ]   urddata0, urddata1;
reg           req, we;
reg [15:0]    uwrdata, rdd0=0, rdd1=0;
reg [6:0] drvstate;
reg [23:0] addr;
wire busy;
test_inst sdram_instance_name
(
        .clk(SDCLK0),
        .rst(locked),
        .data(Data),
        .addr(Address),
        .ba(Bank),
        .cke(SDCKE0),
        .cs_n(SDCS0),
        .ras_n(RAS),
        .cas_n(CAS),
        .we_n(SDWE),
        .dqm(DQM),

	.busy(busy),
        .uaddr(addr),
	.ucmd(req),
	.uwe(we),
	.uwrdata(uwrdata),
        .urddata0(urddata0),
	.urddata1(urddata1),
	.state_cnt(drvstate)
);

`define urdatarstval 16'h0000
reg [7:0] state=0;
always @(posedge clk) begin
	if(!locked) begin
		state <= 0;
		addr <= 0;
		uwrdata <= `urdatarstval;
		led_2 <= 0;
		led_1 <= 1;
	end else if(state == 0) begin
		req <= 1;
		we <= 1; // write
		state <= 1;
	end else if(state == 1) begin
		if(busy) begin
	                req <= 0;
        	        we <= 0;
			state <= 10;
		end
	end else if(state == 10) begin
		if(!busy) begin
			if((addr + 1) < 'hfffffe) begin
				state <= 0;
				addr <= addr + 1;
				uwrdata <= uwrdata + 1;
			end else begin
				addr <= 0;
				uwrdata <= `urdatarstval;
				state <= 2;
			end
		end
        end else if(state == 2) begin
                req <= 1;
                we <= 0; // read
                state <= 3;
        end else if(state == 3) begin
		if(busy) begin
                	req <= 0;
			we <= 0;
	                state <= 4;
		end
        end else if(state == 4) begin
                if(!busy) begin
                        req <= 0;
                        we <= 0;
			rdd0 <= urddata0;
			rdd1 <= urddata1;
			if((urddata0 == uwrdata) && (urddata1 == (uwrdata+1))) begin
                          if((addr + 2) < 'hfffffe) begin
                                state <= 2;
                                addr <= addr + 2;
                                uwrdata <= uwrdata + 2;
                          end else
                                state <= 5;
			end else begin
			  state <= 6;
			  led_2 <= 1;
			end
                end
        end
end

// VeriFLA
top_of_verifla verifla (.clk(clk), .rst_l(locked), .sys_run(1'b1),
                                .data_in({we, req, Data}),
                                // Transceiver
                                .uart_XMIT_dataH(uart_XMIT_dataH), .uart_REC_dataH(uart_REC_dataH));
// display
wire clkdiv;
wire [31:0] dv= {state[7:0], {1'b0, drvstate}, rdd1};
max7219 m(.clk(clk50min), .clkdiv(clkdiv), .reset_n(locked), .data_vector(dv),
            .clk_out(MAX7219_CLK),
            .data_out(MAX7219_DATA),
            .load_out(MAX7219_LOAD)
        );

clkdivider cd(.clk(clk50min), .reset_n(), .n(2000), .clkdiv(clkdiv));

endmodule
