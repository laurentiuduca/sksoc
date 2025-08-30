// Modified by Laurentiu Cristian Duca, 2025/08
// spdx license identifier - apache 2

module ahbl_to_apb #(
	parameter W_HADDR = 32,
	parameter W_PADDR = 16,
	parameter W_DATA = 32
) (
	input wire clk,
	input wire rst_n,

	input  wire               ahbls_hready,
	output wire               ahbls_hready_resp,
	output wire               ahbls_hresp,
	input  wire [W_HADDR-1:0] ahbls_haddr,
	input  wire               ahbls_hwrite,
	input  wire [1:0]         ahbls_htrans,
	input  wire [2:0]         ahbls_hsize,
	input  wire [2:0]         ahbls_hburst,
	input  wire [3:0]         ahbls_hprot,
	input  wire               ahbls_hmastlock,
	input  wire [W_DATA-1:0]  ahbls_hwdata,
	output reg  [W_DATA-1:0]  ahbls_hrdata,
	input wire  [W_DATA-1:0]  ahbls_hartid,
	input  wire [W_HADDR-1:0] ahbls_hd_pc,

	output reg  [W_PADDR-1:0] apbm_paddr,
	output reg                apbm_psel,
	output reg                apbm_penable,
	output reg                apbm_pwrite,
	output reg  [W_DATA-1:0]  apbm_pwdata,
	input wire                apbm_pready,
	input wire  [W_DATA-1:0]  apbm_prdata,
	input wire                apbm_pslverr,
	output reg  [W_DATA-1:0]  apbm_phartid,
	output wire [W_PADDR-1:0] apbm_pd_pc
);

// Transfer state machine

localparam W_APB_STATE = 4;
localparam S_IDLE  = 4'd0; // Idle upstream dataphase
localparam S_RD0   = 4'd1; // Downstream setup phase (cannot stall)
localparam S_RD1   = 4'd2; // Downstream access phase (may stall or error)
localparam S_RD2   = 4'd3; // Return data, capture next address phase
localparam S_WR0   = 4'd4; // Sample hwdata
localparam S_WR1   = 4'd5; // Downstream setup phase (cannot stall)
localparam S_WR2   = 4'd6; // Downstream access phase (may stall or error)
localparam S_WR3   = 4'd7; // Report success, capture next address phase
localparam S_ERR0  = 4'd8; // AHBL error response, first cycle
localparam S_ERR1  = 4'd9; // AHBL error response, and accept new address phase if not deasserted.

reg [W_APB_STATE-1:0] apb_state;

wire [W_APB_STATE-1:0] aphase_to_dphase =
	ahbls_htrans[1] &&  ahbls_hwrite && ahbls_hready ? S_WR0 :
	ahbls_htrans[1] && !ahbls_hwrite && ahbls_hready ? S_RD0 : S_IDLE;
assign apbm_pd_pc = ahbls_hd_pc;

always @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		apb_state <= S_IDLE;
	end else case (apb_state)
		S_IDLE: if (ahbls_hready) begin 
			apb_state <= aphase_to_dphase;
			apbm_phartid <= ahbls_hartid;
		end
		S_WR0:                    apb_state <= S_WR1;
		S_WR1:                    apb_state <= S_WR2;
		S_WR2:  if (apbm_pready)  apb_state <= apbm_pslverr ? S_ERR0 : S_WR3;
		S_WR3:  begin
      			apb_state <= aphase_to_dphase;
			apbm_phartid <= ahbls_hartid;
		end
		S_RD0:                    apb_state <= S_RD1;
		S_RD1:  if (apbm_pready)  apb_state <= apbm_pslverr ? S_ERR0 : S_RD2;
		S_RD2:  begin
			apb_state <= aphase_to_dphase;
			apbm_phartid <= ahbls_hartid;
		end
		S_ERR0:                   apb_state <= S_ERR1;
		S_ERR1: begin
      			apb_state <= aphase_to_dphase;
			apbm_phartid <= ahbls_hartid;
		end
	endcase
end

// Downstream request

always @ (*) begin
	case (apb_state)
		S_RD0:   {apbm_psel, apbm_penable, apbm_pwrite} = 3'b100;
		S_RD1:   {apbm_psel, apbm_penable, apbm_pwrite} = 3'b110;
		S_WR1:   {apbm_psel, apbm_penable, apbm_pwrite} = 3'b111; //3'b101
		//S_WR2:   {apbm_psel, apbm_penable, apbm_pwrite} = 3'b111;
		default: {apbm_psel, apbm_penable, apbm_pwrite} = 3'b000;
	endcase
end

always @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		apbm_paddr <= {W_PADDR{1'b0}};
		apbm_pwdata <= {W_DATA{1'b0}};
		apbm_phartid <= 0;
	end else begin
		if (ahbls_htrans[1] && ahbls_hready)
			apbm_paddr <= ahbls_haddr[W_PADDR-1:0];
		if (apb_state == S_WR0) begin
			`ifdef dbgsclr
			$display("apb_state == S_WR0 prev=%x ahbls_hwdata=%x %d", $past(apb_state), ahbls_hwdata, $time);
			`endif
			apbm_pwdata <= ahbls_hwdata;
		end
	end
end

// Upstream response

assign ahbls_hready_resp =
	apb_state == S_IDLE ||
	apb_state == S_RD2  ||
	apb_state == S_WR3  ||
	apb_state == S_ERR1;

assign ahbls_hresp =
	apb_state == S_ERR0 ||
	apb_state == S_ERR1;

//assign apbm_phartid=ahbls_hartid;

always @ (posedge clk or negedge rst_n)
	if (!rst_n)
		ahbls_hrdata <= {W_DATA{1'b0}};
	else if (apb_state == S_RD1 && apbm_pready)
		ahbls_hrdata <= apbm_prdata;

endmodule
