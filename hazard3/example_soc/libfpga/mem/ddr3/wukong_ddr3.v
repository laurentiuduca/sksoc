////////////////////////////////////////////////////////////////////////////////
//
// Filename: wukong_ddr3.v
// Project: UberDDR3 - An Open Source DDR3 Controller
//
// Purpose: Example demo of UberDDR3 for QMTech Wukong (xc7a100tfgg676-2). Mechanism:
//          - two LEDs will light up once UberDDR3 is done calibrating
//          - if UART (9600 Baud Rate)receives small letter ASCII (a-z), this value will be written to DDR3 
//          - if UART receives capital letter ASCII (A-Z), the small letter equivalent will be retrieved from DDR3 by doing
//          - a read request, once read data is available this will be sent to UART to be streamed out.
//          THUS:
//          - Sendng "abcdefg" to the UART terminal will store that small latter to DDR3
//          - Then sending "ABCDEFG" to the UART terminal will return the small letter equivalent: "abcdefg"
//
// Engineer: Angelo C. Jacobo
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2023-2025  Angelo Jacobo
// 
//     This program is free software: you can redistribute it and/or modify
//     it under the terms of the GNU General Public License as published by
//     the Free Software Foundation, either version 3 of the License, or
//     (at your option) any later version.
// 
//     This program is distributed in the hope that it will be useful,
//     but WITHOUT ANY WARRANTY; without even the implied warranty of
//     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//     GNU General Public License for more details.
// 
//     You should have received a copy of the GNU General Public License
//     along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////

//`timescale 1ns / 1ps

   module wukong_ddr3
	(
    input wire i_rst_n,
    input  wire i_controller_clk, i_ddr3_clk, i_ref_clk, i_ddr3_clk_90,
    input  wire [31:0] w_addr,
    output wire [31:0] w_odata,
    input  wire        w_we, w_le,
    input  wire [31:0] w_wdata,
    input  wire       [3:0] w_mask,
    output wire             w_stall,

    // DDR3 I/O Interface
    output wire ddr3_clk_p, ddr3_clk_n,
    output wire ddr3_reset_n,
    output wire ddr3_cke, // CKE
    //output wire ddr3_cs_n, // no chip select signal
    output wire ddr3_ras_n, // RAS#
    output wire ddr3_cas_n, // CAS#
    output wire ddr3_we_n, // WE#
    output wire[14-1:0] ddr3_addr,
    output wire[3-1:0] ddr3_ba,
    inout wire[16-1:0] ddr3_dq,
    inout wire[2-1:0] ddr3_dqs_p, ddr3_dqs_n,
    output wire[2-1:0] ddr3_dm,
    output wire ddr3_odt // on-die termination
    );
     
     wire o_wb_ack;
     wire[127:0] o_wb_data;
     wire o_aux;
     wire[7:0] rd_data;
     wire o_wb_stall;
     reg i_wb_stb = 0, i_wb_we;
     wire[31:0] o_debug1;
     reg[127:0] i_wb_data;
     reg[23:0] i_wb_addr;


     reg [7:0] state=0;
     reg rbusy = 0;
     assign w_stall = rbusy;
     reg [15:0] i_wb_sel = 16'hffff;
     reg [31:0] raddr=0;
     reg [31:0] rodata=0;
     wire [8:0] wrefresh_counter;
     `define maxrfr 256
     reg [31:0] rfrcnt=0, rfraddr=0;
     assign w_odata=rodata;
     always @(posedge i_controller_clk) begin
       if(!i_rst_n) begin
		     state <= 0;
		     i_wb_addr <= 0;
		     i_wb_data <= 0;
		     rbusy <= 0;
		     i_wb_sel <= 16'hffff;
		     rodata <= 0;
		     raddr <= 0;
		     rfrcnt <= 0;
		     rfraddr <= 0;
       end else begin
       if(state == 0) begin
	        if(!o_wb_stall && (o_debug1[4:0] == 23)) begin
		    rfrcnt <= rfrcnt + 1;
		    if(w_le) begin
			i_wb_stb <= 1;
                    	i_wb_we <= 0;
			i_wb_addr <= w_addr[31:4];
			raddr <= w_addr;
			i_wb_sel <= 16'hffff;
		        state <= 1;
			rbusy <= 1;
		    end else if(w_we) begin
		        // write
                        i_wb_stb <= 1;
                        i_wb_we <= 1;
			i_wb_addr <= w_addr[31:4];
			i_wb_data <= {96'h0, w_wdata} << {w_addr[3:0], 3'b0};
			i_wb_sel <= {12'h0, w_mask} << w_addr[3:0];
			state <= 10;
			rbusy <= 1;
                    end else if(rfrcnt >= `maxrfr) begin
                        state <= 1;
                        i_wb_stb <= 1;
                        i_wb_we <= 0;
                        i_wb_addr <= rfraddr;
                        rfraddr <= rfraddr + 128;
                    end
		end
        end else if(state == 1) begin
                if(o_wb_stall) begin
                    i_wb_stb <= 0;
                    i_wb_we <= 0;
                    state <= 2;
                end
        end else if(state == 2) begin
		if(o_wb_ack) begin
			// data is right shifted with raddr[3:0] * 8 bits
			if(rfrcnt <= `maxrfr)
				rodata <= o_wb_data >> {raddr[3:0], 3'b0};
                        state <= 3;
		end
	end else if(state == 3) begin
                if(!o_wb_stall) begin
                        state <= 0;
                        rbusy <= 0;
			rfrcnt <= 0;
                end
	end else if(state == 10) begin
		if(o_wb_stall) begin
                    i_wb_stb <= 0;
                    i_wb_we <= 0;			
		    state <= 11;
		end
	end else if(state == 11) begin
                if(o_wb_ack) 
			state <= 12;
	end else if(state == 12) begin
		if(!o_wb_stall) begin
			state <= 0;
			rbusy <= 0;
			rfrcnt <= 0;
		end
	end
     end
     end

    // DDR3 Controller 
    ddr3_top #(
        .CONTROLLER_CLK_PERIOD(10000/*12_000*/), //ps, clock period of the controller interface
        .DDR3_CLK_PERIOD(2500/*3_000*/), //ps, clock period of the DDR3 RAM device (must be 1/4 of the CONTROLLER_CLK_PERIOD) 
        .ROW_BITS(14), //width of row address
        .COL_BITS(10), //width of column address
        .BA_BITS(3), //width of bank address
        .BYTE_LANES(2), //number of DDR3 modules to be controlled
        .AUX_WIDTH(4), //width of aux line (must be >= 4) 
        .WB2_ADDR_BITS(32), //width of 2nd wishbone address bus 
        .WB2_DATA_BITS(32), //width of 2nd wishbone data bus
        .MICRON_SIM(0), //enable faster simulation for micron ddr3 model (shorten POWER_ON_RESET_HIGH and INITIAL_CKE_LOW)
        .ODELAY_SUPPORTED(0), //set to 1 when ODELAYE2 is supported
        .SECOND_WISHBONE(0), //set to 1 if 2nd wishbone is needed 
        .BIST_MODE(0), // 0 = No BIST, 1 = run through all address space ONCE , 2 = run through all address space for every test (burst w/r, random w/r, alternating r/w)
        .SPEED_BIN(1), // 0 = Use top-level parameters , 1 = DDR3-1066 (7-7-7) , 2 = DR3-1333 (9-9-9) , 3 = DDR3-1600 (11-11-11)
	// laur
	.SELF_REFRESH(2'd0)
        ) ddr3_top
        (
            //clock and reset
            .i_controller_clk(i_controller_clk),
            .i_ddr3_clk(i_ddr3_clk), //i_controller_clk has period of CONTROLLER_CLK_PERIOD, i_ddr3_clk has period of DDR3_CLK_PERIOD 
            .i_ref_clk(i_ref_clk),
            .i_ddr3_clk_90(i_ddr3_clk_90),
            .i_rst_n(i_rst_n), 
            // Wishbone inputs
            .i_wb_cyc(1), //bus cycle active (1 = normal operation, 0 = all ongoing transaction are to be cancelled)
            .i_wb_stb(i_wb_stb), //request a transfer
            .i_wb_we(i_wb_we), //write-enable (1 = write, 0 = read)
            .i_wb_addr(i_wb_addr), //burst-addressable {row,bank,col} 
            .i_wb_data(i_wb_data), //write data, for a 4:1 controller data width is 8 times the number of pins on the device
            .i_wb_sel(i_wb_sel), //byte strobe for write (1 = write the byte)
	    .o_wb_err(),
	    .o_calib_complete(),
	    .i_user_self_refresh(0),
	    .refresh_counter(wrefresh_counter),
	    .uart_tx(),
            .i_aux(i_wb_we), //for AXI-interface compatibility (given upon strobe)
            // Wishbone outputs
            .o_wb_stall(o_wb_stall), //1 = busy, cannot accept requests
            .o_wb_ack(o_wb_ack), //1 = read/write request has completed
            .o_wb_data(o_wb_data), //read data, for a 4:1 controller data width is 8 times the number of pins on the device
            .o_aux(o_aux),
            // Wishbone 2 (PHY) inputs
            .i_wb2_cyc(), //bus cycle active (1 = normal operation, 0 = all ongoing transaction are to be cancelled)
            .i_wb2_stb(), //request a transfer
            .i_wb2_we(), //write-enable (1 = write, 0 = read)
            .i_wb2_addr(), //burst-addressable {row,bank,col} 
            .i_wb2_data(), //write data, for a 4:1 controller data width is 8 times the number of pins on the device
            .i_wb2_sel(), //byte strobe for write (1 = write the byte)
            // Wishbone 2 (Controller) outputs
            .o_wb2_stall(), //1 = busy, cannot accept requests
            .o_wb2_ack(), //1 = read/write request has completed
            .o_wb2_data(), //read data, for a 4:1 controller data width is 8 times the number of pins on the device
            // PHY Interface (to be added later)
            // DDR3 I/O Interface
            .o_ddr3_clk_p(ddr3_clk_p),
            .o_ddr3_clk_n(ddr3_clk_n),
            .o_ddr3_reset_n(ddr3_reset_n),
            .o_ddr3_cke(ddr3_cke), // CKE
            .o_ddr3_cs_n(), // chip select signal (controls rank 1 only)
            .o_ddr3_ras_n(ddr3_ras_n), // RAS#
            .o_ddr3_cas_n(ddr3_cas_n), // CAS#
            .o_ddr3_we_n(ddr3_we_n), // WE#
            .o_ddr3_addr(ddr3_addr),
            .o_ddr3_ba_addr(ddr3_ba),
            .io_ddr3_dq(ddr3_dq),
            .io_ddr3_dqs(ddr3_dqs_p),
            .io_ddr3_dqs_n(ddr3_dqs_n),
            .o_ddr3_dm(ddr3_dm),
            .o_ddr3_odt(ddr3_odt), // on-die termination
            .o_debug1(o_debug1)
        );

endmodule

