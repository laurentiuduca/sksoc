// modified by L.-C. Duca  2026-04
// spdx license identifier MIT

`include "define.vh"

module membram #(parameter MEM_SIZE = `BIN_SIZE)(
    input wire clk,
    input wire [31:0] maddr,
    input wire [15:0] midata,
    input wire mw,
    output reg [15:0] mout
);

    reg [15:0] mem[0:MEM_SIZE-1];
    integer i;
    //initial for (i = 0; i < MEM_SIZE; i = i + 1) m[i] <= 0;
    always @(posedge clk) begin
        if (mw) mem[maddr] <= midata;
        mout <= mem[maddr];
    end
    //assign mout = mem[maddr];
endmodule

module m_sbu_memimp #(parameter MEM_SIZE = `BIN_SIZE)
            (CLK, w_addr, w_odata, w_we, w_le, w_wdata, w_mask, w_stall, w_mtime, w_refresh);
    input  wire             CLK;
    input  wire [31:0] w_addr;
    output wire [31:0] w_odata;
    input  wire             w_we, w_le;
    input  wire [31:0] w_wdata; 
    input  wire       [3:0] w_mask;
    output wire             w_stall;
    input  wire [31:0]      w_mtime;
    input  wire             w_refresh;

    reg   [3:0] r_mask  = 0;
    reg  [31:0] r_cnt   = 0;

    reg [31:0] r_odata=0;

    assign w_odata = r_odata;
    reg waswrite=0;
    reg [7:0] r_refresh_cnt=0;
    reg r_stall=0;
    assign w_stall = r_stall;
    reg [`winbaddrlen-1:0] r_maddr=0;
    reg [31:0] r_wdata=0;

    reg [31:0] mbmaddr=0;
    wire [15:0] mbmout;
    reg mbmw=0;
    reg [15:0] mbmidata=0;
    membram #(MEM_SIZE) mb(CLK, mbmaddr, mbmidata, mbmw, mbmout);

    reg [7:0] state = 0;
    always@(posedge CLK) begin
        case(state)
        8'd0: begin // idle
                if(w_le) begin
                        state <= 10;
                        r_stall <= 1;
                        r_maddr <= w_addr >> 1;
			mbmaddr <= w_addr >> 1;
                        r_mask <= w_mask;
                end else if(w_we) begin
                        state <= 20;
                        r_stall <= 1;
                        r_maddr <= w_addr >> 1;
			mbmaddr <= w_addr >> 1;
                        r_wdata <= w_wdata;
                        r_mask <= w_mask;
                end else if(w_refresh) begin
                        state <= 3;
                        r_stall <= 1;
                        r_refresh_cnt <= 0;
                end
        end
        8'd10: begin // read
		mbmaddr <= r_maddr+1;
                state <= 11;
        end
	8'd11: begin 
                r_odata <= {16'h0, mbmout};
                state <= 12;
        end	
        8'd12: begin 
                r_odata <= {mbmout, r_odata[15:0]};
                state <= 0;
                r_stall <= 0;
        end
        8'd20: begin
		// let mem read first
                state <= 21;
        end	
        8'd21: begin // write
                if(!r_mask[0])
                        mbmidata[7:0] <= r_wdata[7:0];
		else
			mbmidata[7:0] <= mbmout[7:0];
                if(!r_mask[1])
                        mbmidata[15:8] <= r_wdata[15:8];
		else
                        mbmidata[15:8] <= mbmout[15:8];
		mbmw <= 1;
		state <= 22;
	end
	8'd22: begin 
		mbmaddr <= r_maddr + 1;
		mbmw <= 0;
		state <= 23;
	end
        8'd23: begin
                state <= 24;
        end
	8'd24: begin 
                if(!r_mask[2])
                        mbmidata[7:0] <= r_wdata[23:16];
		else
                        mbmidata[7:0] <= mbmout[7:0];
                if(!r_mask[3])
                        mbmidata[15:8] <= r_wdata[31:24];
		else
                        mbmidata[15:8] <= mbmout[15:8];
		mbmw <= 1;
		state <= 25;
	end
	8'd25: begin
		mbmw <= 0;
                state <= 0;
                r_stall <= 0;
                waswrite <= 1;
		//if(!waswrite)
                //	$display("write r_maddr=%x r_wdata=%x r_mask=%x", r_maddr, r_wdata, r_mask);
        end
        8'd3: begin
                if(r_refresh_cnt >= 3) begin
                        // refresh done
                        state <= 0;
                        r_stall <= 0;
                end else
                        r_refresh_cnt <= r_refresh_cnt + 1;
        end
        endcase
    end
endmodule

module m_sbu_memsim #(parameter MEM_SIZE = `BIN_SIZE)
            (CLK, w_addr, w_odata, w_we, w_le, w_wdata, w_mask, w_stall, w_mtime, w_refresh);
    input  wire             CLK;
    input  wire [31:0] w_addr;
    output wire [31:0] w_odata;
    input  wire             w_we, w_le;
    input  wire [31:0] w_wdata;
    input  wire       [3:0] w_mask;
    output wire             w_stall;
    input  wire [31:0]      w_mtime;
    input  wire             w_refresh;
    
    reg   [3:0] r_mask  = 0;
    reg  [31:0] r_cnt   = 0;

    reg   [15:0] mem [0:MEM_SIZE-1];
    reg [31:0] r_odata=0;

    assign w_odata = r_odata;
    reg waswrite=0;
    reg [7:0] r_refresh_cnt=0;
    reg r_stall=0;
    assign w_stall = r_stall;
    reg [`winbaddrlen-1:0] r_maddr=0;
    reg [31:0] r_wdata=0;
    reg [7:0] state = 0;
    always@(posedge CLK) begin
        case(state)
	8'd0: begin // idle
                if(w_le) begin
                        state <= 1;
                        r_stall <= 1;
                        r_maddr <= w_addr >> 1;
			r_mask <= w_mask;
                end else if(w_we) begin
                        state <= 2;
                        r_stall <= 1;
                        r_maddr <= w_addr >> 1;
                        r_wdata <= w_wdata;
                        r_mask <= w_mask;
                end else if(w_refresh) begin
                        state <= 3;
                        r_stall <= 1;
                        r_refresh_cnt <= 0;
                end
	end
        8'd1: begin // mem read
		r_odata <= {mem[r_maddr+1], mem[r_maddr+0]};
		state <= 0;
                r_stall <= 0;
	end 
	8'd2: begin // mem write
		// active 0
		if(!r_mask[0])
                        mem[r_maddr+0][7:0] <= r_wdata[7:0];
                if(!r_mask[1])
                        mem[r_maddr+0][15:8] <= r_wdata[15:8];
                if(!r_mask[2])
                        mem[r_maddr+1][7:0] <= r_wdata[23:16];
                if(!r_mask[3])
                        mem[r_maddr+1][15:8] <= r_wdata[31:24];		
		state <= 0;
                r_stall <= 0;
		waswrite <= 1;
		//$display("write r_maddr=%x r_wdata=%x r_mask=%x", r_maddr, r_wdata, r_mask);
	end
        8'd3: begin
                if(r_refresh_cnt >= 3) begin
                        // refresh done
                        state <= 0;
                        r_stall <= 0;
                end else
                        r_refresh_cnt <= r_refresh_cnt + 1;
        end
        endcase
    end
endmodule

module m_sdram_sim#(parameter MEM_SIZE = `BIN_SIZE)
            (CLK, w_addr, w_odata, w_we, w_le, w_wdata, w_mask, w_stall, w_mtime, w_refresh);
    input  wire             CLK;
    input  wire [31:0] w_addr;
    output wire [31:0] w_odata;
    input  wire             w_we, w_le;
    input  wire [31:0] w_wdata;
    input  wire       [3:0] w_mask;
    output wire             w_stall;
    input  wire      [31:0] w_mtime;
    input  wire             w_refresh;

    `ifdef BRAM_IMP
    m_sbu_memimp#(MEM_SIZE) idbmem(CLK, w_addr, w_odata,
                                w_we, w_le, w_wdata, w_mask, w_stall, w_mtime, w_refresh);
    `else
    m_sbu_memsim#(MEM_SIZE) idbmem(CLK, w_addr, w_odata,
                                w_we, w_le, w_wdata, w_mask, w_stall, w_mtime, w_refresh);
    `endif

endmodule


