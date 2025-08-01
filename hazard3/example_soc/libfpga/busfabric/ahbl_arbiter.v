/**********************************************************************
 * DO WHAT THE FUCK YOU WANT TO AND DON'T BLAME US PUBLIC LICENSE     *
 *                    Version 3, April 2008                           *
 *                                                                    *
 * Copyright (C) 2018 Luke Wren                                       *
 *                                                                    *
 * Everyone is permitted to copy and distribute verbatim or modified  *
 * copies of this license document and accompanying software, and     *
 * changing either is allowed.                                        *
 *                                                                    *
 *   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION  *
 *                                                                    *
 * 0. You just DO WHAT THE FUCK YOU WANT TO.                          *
 * 1. We're NOT RESPONSIBLE WHEN IT DOESN'T FUCKING WORK.             *
 *                                                                    *
 *********************************************************************/
/*
 * Strict-priority N:1 AHBL arbiter
 *
 * Lower port numbers are higher priority.
 * Use concat lists to wire masters in:
 *   .N_PORTS(2)
 *   ...
 *   .src_haddr({mast1_haddr, mast0_haddr})
 *   ...
 * Recommend that wiring up either be scripted, or done by unpaid intern.
 */

// TODO: no burst support!


module ahbl_arbiter #(
	parameter SLAVE_ID = 0,
	parameter N_PORTS = 2,
	//parameter W_ADDR = 32,
	//parameter W_DATA = 32,
	parameter CONN_MASK = {N_PORTS{1'b1}},
	`include "hazard3_config.vh"
) (
	// Global signals
	input wire                       clk,
	input wire                       rst_n,

	// From masters; function as slave ports
	input  wire [N_PORTS*W_ADDR-1:0] src_d_pc,
	input  wire [N_PORTS*W_DATA-1:0] src_hartid,
	input  wire [N_PORTS-1:0]        src_hready,
	output wire [N_PORTS-1:0]        src_hready_resp,
	output wire [N_PORTS-1:0]        src_hresp,
	input  wire [N_PORTS*W_ADDR-1:0] src_haddr,
	input  wire [N_PORTS-1:0]        src_hwrite,
	input  wire [N_PORTS*2-1:0]      src_htrans,
	input  wire [N_PORTS*3-1:0]      src_hsize,
	input  wire [N_PORTS*3-1:0]      src_hburst,
	input  wire [N_PORTS*4-1:0]      src_hprot,
	input  wire [N_PORTS-1:0]        src_hmastlock,
	input  wire [N_PORTS*W_DATA-1:0] src_hwdata,
	output wire [N_PORTS*W_DATA-1:0] src_hrdata,
        // exclusive access signaling
        input  wire [N_PORTS-1:0]       src_hexcl,
        input  wire [N_PORTS*8-1:0]     src_hmaster,
        output wire [N_PORTS-1:0]       src_hexokay,

	// To slave; functions as master port
	output wire [W_ADDR-1:0] 	 dst_d_pc,
	output wire [W_DATA-1:0]         dst_hartid,
	output wire                      dst_hready,
	input  wire                      dst_hready_resp,
	input  wire                      dst_hresp,
	output wire [W_ADDR-1:0]         dst_haddr,
	output wire                      dst_hwrite,
	output wire [1:0]                dst_htrans,
	output wire [2:0]                dst_hsize,
	output wire [2:0]                dst_hburst,
	output wire [3:0]                dst_hprot,
	output wire                      dst_hmastlock,
	output wire [W_DATA-1:0]         dst_hwdata,
	input  wire [W_DATA-1:0]         dst_hrdata,
        // exclusive access signaling   
        output wire        		 dst_hexcl,
        output wire [7:0]     		 dst_hmaster,
        input wire        		 dst_hexokay
);

integer i;

// "actual" is a mux between the buffered signal, if valid, else the live signal on the port

reg [N_PORTS-1:0]        buf_valid;
reg [W_ADDR-1:0]         buf_d_pc       [0:N_PORTS-1];
reg [W_DATA-1:0]         buf_hartid     [0:N_PORTS-1];
reg [W_ADDR-1:0]         buf_haddr      [0:N_PORTS-1];
reg                      buf_hwrite     [0:N_PORTS-1];
reg [W_DATA-1:0]         buf_hwdata     [0:N_PORTS-1];
reg [1:0]                buf_htrans     [0:N_PORTS-1];
reg [2:0]                buf_hsize      [0:N_PORTS-1];
reg [2:0]                buf_hburst     [0:N_PORTS-1];
reg [3:0]                buf_hprot      [0:N_PORTS-1];
reg                      buf_hmastlock  [0:N_PORTS-1];
// exclusive access signaling
reg 			 buf_hexcl	[0:N_PORTS-1];
reg [7:0]     		 buf_hmaster	[0:N_PORTS-1];

reg [N_PORTS*W_ADDR-1:0] actual_d_pc;
reg [N_PORTS*W_DATA-1:0] actual_hartid;
reg [N_PORTS*W_ADDR-1:0] actual_haddr;
reg [N_PORTS-1:0]        actual_hwrite;
reg [N_PORTS*W_DATA-1:0] actual_hwdata;
reg [N_PORTS*2-1:0]      actual_htrans;
reg [N_PORTS*3-1:0]      actual_hsize;
reg [N_PORTS*3-1:0]      actual_hburst;
reg [N_PORTS*4-1:0]      actual_hprot;
reg [N_PORTS-1:0]        actual_hmastlock;
// exclusive access signaling
reg [N_PORTS-1:0]       actual_hexcl;
reg [N_PORTS*8-1:0]     actual_hmaster;

always @ (*) begin
	for (i = 0; i < N_PORTS; i = i + 1) begin
		if (buf_valid[i]) begin
			actual_d_pc      [i * W_ADDR +: W_ADDR] = buf_d_pc      [i];
			actual_hartid    [i * W_DATA +: W_DATA] = buf_hartid    [i];
			actual_haddr     [i * W_ADDR +: W_ADDR] = buf_haddr     [i];
			actual_hwrite    [i]                    = buf_hwrite    [i];
			actual_hwdata    [i * W_DATA +: W_DATA] = buf_hwdata    [i];
			actual_htrans    [i * 2 +: 2]           = buf_htrans    [i];
			actual_hsize     [i * 3 +: 3]           = buf_hsize     [i];
			actual_hburst    [i * 3 +: 3]           = buf_hburst    [i];
			actual_hprot     [i * 4 +: 4]           = buf_hprot     [i];
			actual_hmastlock [i]                    = buf_hmastlock [i];
			actual_hexcl     [i]			= buf_hexcl     [i];
			actual_hmaster   [i * 8 +: 8]		= buf_hmaster	[i];
		end else begin
			actual_d_pc      [i * W_ADDR +: W_ADDR] = src_d_pc      [i * W_ADDR +: W_ADDR];
			actual_hartid    [i * W_DATA +: W_DATA] = src_hartid    [i * W_DATA +: W_DATA];
			actual_haddr     [i * W_ADDR +: W_ADDR] = src_haddr     [i * W_ADDR +: W_ADDR];
			actual_hwrite    [i]                    = src_hwrite    [i];
			actual_hwdata    [i * W_DATA +: W_DATA] = src_hwdata    [i * W_DATA +: W_DATA];
			actual_htrans    [i * 2 +: 2]           = src_htrans    [i * 2 +: 2];
			actual_hsize     [i * 3 +: 3]           = src_hsize     [i * 3 +: 3];
			actual_hburst    [i * 3 +: 3]           = src_hburst    [i * 3 +: 3];
			actual_hprot     [i * 4 +: 4]           = src_hprot     [i * 4 +: 4];
			actual_hmastlock [i]                    = src_hmastlock [i];
                        actual_hexcl     [i]                    = src_hexcl     [i];
                        actual_hmaster   [i * 8 +: 8]           = src_hmaster   [i * 8 +: 8];
		end
	end
end

// Address-phase arbitration

reg  [N_PORTS-1:0] mast_req_a;
wire [N_PORTS-1:0] mast_gnt_a;

always @ (*) begin
	for (i = 0; i < N_PORTS; i = i + 1) begin
		// HTRANS == 2'b10, 2'b11 when active
		mast_req_a[i] = actual_htrans[i * 2 + 1] && CONN_MASK[i];
	end
end

//single_pulse sp(clk, rst_n, dst_hready & dst_hready_resp & !actual_hwrite[actual_hartid+:1], canchange);
wire canchange;
wire iswrite;
assign iswrite = (r_mast_gnt_a == 1) ? actual_hwrite[0] : actual_hwrite[N_PORTS-1];
assign canchange = dst_hready_resp & !iswrite; // & !|buf_wen;

onehot_priority #(
	.W_INPUT(N_PORTS)
) arb_priority (
	.clk(clk),
	.rst_n(rst_n),
	.canchange(canchange),
	.in(mast_req_a),
	.out(mast_gnt_a)
);

//`ifdef laur0
//always @(mast_gnt_a) begin
reg [N_PORTS-1:0] o_mast_gnt_a=0;
integer tcnt=0;
always @(posedge clk) begin
	tcnt = tcnt + 1;
	//if(o_mast_gnt_a != mast_gnt_a) begin // || mast_req_a != mast_gnt_a) begin
	if(actual_hwrite) begin
		o_mast_gnt_a = mast_gnt_a;
		$display("s%1d gnt_a=%x req_a=%x pc0=%x shaddr=%x dhaddr=%x shwr=%2x dhwr=%1x,%x shready_resp=%x dhready_resp=%x dh=%1x dpc=%x",
                        SLAVE_ID, mast_gnt_a, mast_req_a, src_d_pc[31:0], src_haddr[31:0], dst_haddr, src_hwrite, dst_hwrite, dst_hwdata,
                        src_hready_resp, dst_hready_resp, dst_hartid, dst_d_pc);		
		//$display("s%1d gnt_a=%x req_a=%x pc0=%x shaddr=%x pc1=%x shaddr=%x dhaddr=%x shwr=%2x dhwr=%1x shready_resp=%x dhready_resp=%x dh=%1x dpc=%x", 
		//	SLAVE_ID, mast_gnt_a, mast_req_a, src_d_pc[31:0], src_haddr[31:0], src_d_pc[63:32], src_haddr[63:32], dst_haddr, src_hwrite, dst_hwrite,
		//	src_hready_resp, dst_hready_resp, dst_hartid, dst_d_pc);
	end
end
always @(dst_haddr or dst_hwrite or dst_hartid or dst_htrans or dst_hready_resp or dst_hready) begin
	`ifdef laur0
	if((src_d_pc[63:32] >= pc_trace_start && src_d_pc[63:32] <= pc_trace_stop)) begin
		$display("  s%1d pc0=%x pc1=%x dpc=%x dhaddr=%x dhwr=%x dhrd=%x dh=%1x dhtrans=%x dhrdy_resp=%x dhrdy=%x shrdy=%x shrdy_resp=%x req_a=%x gnt_a=%x gnt_d=%x str=%x atr=%x btr=%x t=%8d",
			SLAVE_ID, src_d_pc[31:0], src_d_pc[63:32], dst_d_pc, dst_haddr, dst_hwrite, dst_hrdata, dst_hartid, dst_htrans, dst_hready_resp, dst_hready, src_hready_resp, src_hready, mast_req_a, mast_gnt_a, mast_gnt_d, src_htrans, actual_htrans, buf_htrans, tcnt);
	end
	`endif
	if(dst_hresp) begin
		$display("dst_hresp");
		$finish;
	end
end
//`endif

// AHB State Machine

reg [N_PORTS-1:0] mast_gnt_d, r_mast_gnt_a;
wire force_dst_hready, dst_hready_base;
assign force_dst_hready = canchange && (mast_gnt_a != mast_gnt_d) && mast_gnt_a ? 1'b1 : 1'b0;
assign dst_hready_base = mast_gnt_d ? |(src_hready & mast_gnt_d) : |(src_hready & mast_gnt_a); //1'b1;
assign dst_hready = force_dst_hready | dst_hready_base;

// see spliter
wire [N_PORTS-1:0] mast_aphase_ends = mast_req_a & src_hready;
wire [N_PORTS-1:0] buf_wen = 0; //mast_aphase_ends & ~(mast_gnt_a & {N_PORTS{dst_hready}});

reg wrinst[N_PORTS-1:0];
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		r_mast_gnt_a <= {N_PORTS{1'b0}};
		mast_gnt_d <= {N_PORTS{1'b0}};
		for (i = 0; i < N_PORTS; i = i + 1) begin
			buf_valid[i]     <= 1'b0;
			buf_htrans[i]    <= 2'h0;
			buf_d_pc[i]	 <= {W_ADDR{1'b0}};
			buf_hartid[i]    <= {W_DATA{1'b0}};
			buf_haddr[i]     <= {W_ADDR{1'b0}};
			buf_hwrite[i]    <= 1'b0;
			wrinst[i] 	 <= 1'b0;
			buf_hwdata[i]    <= {W_DATA{1'b0}};
			buf_hsize[i]     <= 3'h0;
			buf_hburst[i]    <= 3'h0;
			buf_hprot[i]     <= 3'h0;
			buf_hmastlock[i] <= 1'b0;
			buf_hexcl[i]     <= 1'b0;
			buf_hmaster[i]   <= 8'd0;
		end
	end else begin
		r_mast_gnt_a <= mast_gnt_a;
		if (dst_hready_base) begin
			mast_gnt_d <= mast_gnt_a;
			buf_valid <= 0; //buf_valid & ~mast_gnt_a;
		end
		for (i = 0; i < N_PORTS; i = i + 1) begin
			if (buf_wen[i]) begin
				if(buf_valid[i]) begin
					$display("buf_wen and buf_valid for i=%d", i);
					$finish;
				end
				//buf_valid    [i] <= 1'b1;
				buf_htrans   [i] <= src_htrans   [i * 2 +: 2];
				buf_d_pc     [i] <= src_d_pc     [i * W_ADDR +: W_ADDR];
				buf_hartid   [i] <= src_hartid   [i * W_DATA +: W_DATA];
				buf_haddr    [i] <= src_haddr    [i * W_ADDR +: W_ADDR];
				buf_hwrite   [i] <= src_hwrite   [i];
				if(src_hwrite[i]) begin
					wrinst[i] <= 1;
				end
				buf_hwdata   [i] <= src_hwdata   [i * W_DATA +: W_DATA];
				buf_hsize    [i] <= src_hsize    [i * 3 +: 3];
				buf_hburst   [i] <= src_hburst   [i * 3 +: 3];
				buf_hprot    [i] <= src_hprot    [i * 4 +: 4];
				buf_hmastlock[i] <= src_hmastlock[i];
                        	buf_hexcl    [i] <= src_hexcl    [i];
                        	buf_hmaster  [i] <= src_hmaster  [i * 8 +: 8];
			end
			if(wrinst[i] && dst_hready) begin
				wrinst[i] <= 0;
				buf_hwdata   [i] <= src_hwdata   [i * W_DATA +: W_DATA];
				if(mast_gnt_d[i+:1]) begin
					$display("wrinst[i] and mast_gnt_d[i+:1] for i=%d", i);
					$finish;
				end
			end
		end
	end
end

// Data-phase signal passthrough

// Master being in dphase with arbiter is separate (looser) condition than arbiter
// being in (that master's) dphase with slave (which is indicated by mast_gnt_d)
wire [N_PORTS-1:0] mast_in_dphase = buf_valid | mast_gnt_d;

// There are two reasons to report ready:
// - the master is currently not in data phase with the arbiter (IDLE)
// - the master is in data phase with both arbiter and slave, and slave is ready
assign src_hready_resp = ~mast_in_dphase ? 
				mast_gnt_a ? mast_gnt_a & {N_PORTS{dst_hready_resp}} : {N_PORTS{1'b1}} :
				(mast_gnt_d & {N_PORTS{dst_hready_resp}}) | (r_mast_gnt_a & {N_PORTS{dst_hready_resp}});
assign src_hresp = mast_gnt_d & {N_PORTS{dst_hresp}};
assign src_hrdata = {N_PORTS{dst_hrdata}};
assign src_hexokay = mast_gnt_d & {N_PORTS{dst_hexokay}};

onehot_mux #(
	.W_INPUT(W_DATA),
	.N_INPUTS(N_PORTS)
) hwdata_mux (
	.in(src_hwdata), 
	.sel(mast_gnt_d),
	.out(dst_hwdata)
);

// Pass through address-phase signals based on grant

onehot_mux #(
        .W_INPUT(W_ADDR),
        .N_INPUTS(N_PORTS)
) mux_dst_d_pc (
        .in(actual_d_pc),
        .sel(mast_gnt_a),
        .out(dst_d_pc)
);

onehot_mux #(
        .W_INPUT(W_DATA),
        .N_INPUTS(N_PORTS)
) mux_dst_hartid (
        .in(actual_hartid),
        .sel(mast_gnt_a),
        .out(dst_hartid)
);

onehot_mux #(
        .W_INPUT(1),
        .N_INPUTS(N_PORTS)
) mux_hexcl (
        .in(actual_hexcl),
        .sel(mast_gnt_a),
        .out(dst_hexcl)
);

onehot_mux #(
        .W_INPUT(8),
        .N_INPUTS(N_PORTS)
) mux_hmaster (
        .in(actual_hmaster),
        .sel(mast_gnt_a),
        .out(dst_hmaster)
);

onehot_mux #(
	.W_INPUT(W_ADDR),
	.N_INPUTS(N_PORTS)
) mux_haddr (
	.in(actual_haddr),
	.sel(mast_gnt_a),
	.out(dst_haddr)
);

onehot_mux #(
	.W_INPUT(1),
	.N_INPUTS(N_PORTS)
) mux_hwrite (
	.in(actual_hwrite),
	.sel(mast_gnt_a),
	.out(dst_hwrite)
);

onehot_mux #(
	.W_INPUT(2),
	.N_INPUTS(N_PORTS)
) mux_hwtrans (
	.in(actual_htrans),
	.sel(mast_gnt_a),
	.out(dst_htrans)
);

onehot_mux #(
	.W_INPUT(3),
	.N_INPUTS(N_PORTS)
) mux_hsize (
	.in(actual_hsize),
	.sel(mast_gnt_a),
	.out(dst_hsize)
);

onehot_mux #(
	.W_INPUT(3),
	.N_INPUTS(N_PORTS)
) mux_hburst (
	.in(actual_hburst),
	.sel(mast_gnt_a),
	.out(dst_hburst)
);

onehot_mux #(
	.W_INPUT(4),
	.N_INPUTS(N_PORTS)
) mux_hprot (
	.in(actual_hprot),
	.sel(mast_gnt_a),
	.out(dst_hprot)
);

onehot_mux #(
	.W_INPUT(1),
	.N_INPUTS(N_PORTS)
) mux_hmastlock (
	.in(actual_hmastlock),
	.sel(mast_gnt_a),
	.out(dst_hmastlock)
);

endmodule

module single_pulse(input wire clk, input wire rstn, input wire in1, output wire out1);

reg [2:0] state;
assign out1 = (state == 0) && in1;
always @(posedge clk or negedge rstn)
begin
	if(!rstn) begin
		state <= 0;
		//out1 <= 0;
	end else begin
		if(state == 0) begin
			if(in1) begin
				//out1 <= 1;
				state <= 1;
			end
		end else if(state == 1) begin
		        if(!in1)
				state <= 0;
			//out1 <= 0;
		end
	end

end



endmodule
