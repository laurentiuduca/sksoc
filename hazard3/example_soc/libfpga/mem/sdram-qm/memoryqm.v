/* author Laurentiu-Cristian Duca, 20240322
// spdx license identifier MIT
 */
/**************************************************************************************************/
/**************************************************************************************************/
`default_nettype none
/**************************************************************************************************/
`include "define.vh"

/**************************************************************************************************/
module DRAM_conRV #(parameter PRELOAD_FILE = "")
    (
     // user interface ports
     input  wire                         i_rd_en,
     input  wire                         i_wr_en,
     input  wire [31:0]                  i_addr,
     input  wire [31:0]                  i_data,
     output wire [31:0]                  o_data,
     output wire                         o_busy,
     input  wire [3:0]                   i_ctrl,
     input  wire [2:0]                   sys_state,
     input  wire [3:0]                   w_bus_cpustate,
     output wire [7:0]                   mem_state,

   `ifdef SIM_MODE
      input wire [31:0] w_mtime,
   `else
    // SDRAM
    output wire SDCLK0,
    output wire SDCKE0,
    output wire [1:0]DQM,
    output wire CAS,
    output wire RAS,
    output wire SDWE,
    output wire SDCS0,
    inout wire [15:0]Data,
    output wire [12:0]Address,
    output wire [1:0]Bank,
    `endif

     input wire clk,
     input wire rst_x,
     input wire clk_sdram
);

    reg         req     = 0;
    reg         r_we    = 0;
    reg         r_rd    = 0;
    wire 	w_busy;
    wire[`winbdatalen-1:0] w_dram_odata1, w_dram_odata0;
    reg [`winbmasklen-1:0] r_mask=0;
    reg [3:0] r_ctrl=0;
    reg [`winbdatalen-1:0] r_dram_odata0 = 0, r_dram_odata1 = 0;
    reg [`winbaddrlen-1:0] r_maddr;
    reg [31:0] r_addr;

    wire[31:0] w_odata = {r_dram_odata1, r_dram_odata0};
    assign o_data = w_odata;
    reg [`winbdatalen-1:0] r_wdata=0;
    reg [31:0] r_wdata_ui=0;

    reg r_stall = 0;
    assign o_busy = r_stall;
    reg [7:0] state = 0, state_next=0;
    assign mem_state = state;
    reg r_refresh = 0;

task prepare_read_base;
begin
	 r_addr <= i_addr;
	 r_maddr <= {i_addr[`winbaddrlen-1:2], 2'b0} >> 1; // data out is 16 bit word
         r_ctrl <= i_ctrl;
         r_stall <= 1;
end
endtask 
task prepare_read_end;
begin
 	 state <= 9;
end
endtask 
task prepare_read;
begin
         prepare_read_base;
         prepare_read_end;

end
endtask 

task prepare_write_base;
begin
	 r_addr <= i_addr;
         r_maddr <= {i_addr[`winbaddrlen-1:2], 2'b0} >> 1; // data in is 16 bit word
         r_wdata_ui <= i_data;
         r_ctrl <= i_ctrl;
         r_stall <= 1;
end
endtask
task prepare_write_end;
begin
	state <= 19;
	state_next <= 23;
end
endtask 
task prepare_write;
begin
         prepare_write_base;
         prepare_write_end;
end
endtask 

    always@(posedge clk) begin
    if(~rst_x) begin
      state <= 0;
      state_next <= 0;
    end else
    case(state)
    8'd0: // idle
      if(i_rd_en && !w_busy) begin
         prepare_read;
      end else if(i_wr_en && !w_busy) begin
         prepare_write;
      end
        8'd09: begin
	       r_rd <= 1;
	       state <= 10;
        end	       
	8'd10: begin //mem read
		if(w_busy) begin
			r_rd <= 0;
                        state <= 11;
		end
        end
	8'd11: begin 
		if(!w_busy) begin
			state <= 12;
		end
	end
	8'd12: begin
			r_dram_odata1 <= w_dram_odata1;
			r_dram_odata0 <= w_dram_odata0;
			if(r_addr[1:0] == 0)
			begin
            			// one read is enough
				state <= 0;
				r_stall <= 0;
			end else begin
				$display("read r_addr=%x", r_addr);
				$finish;
			end
        end
	8'd19: begin // mem_write
		if(r_addr[1:0]) begin
                                $display("write r_addr=%x", r_addr);
                                $finish;
                end
		r_mask <= r_ctrl;
		r_wdata <= r_wdata_ui;
     		state <= 20;
	end
        8'd20: begin // mem_write
                r_we <= 1;
                state <= 21;
        end
	8'd21: begin
		if(w_busy) begin
			r_we <= 0;
			state <= 22;
		end 
	end
	8'd22: begin
		if(!w_busy) begin
			if(state_next == 0)
				r_stall <= 0;
			state <= state_next; 
		end
	end
        8'd23: begin // mem_write
		r_maddr <= r_maddr + 1;
                r_mask <= r_ctrl >> 2;
                r_wdata <= r_wdata_ui >> 16;
                state <= 20;
		state_next <= 0;
        end
	endcase
end

`ifdef SIM_MODE
    m_sdram_sim #(`BIN_SIZE/2) idbmem(.CLK(clk), .w_addr(r_maddr), .w_odata0(w_dram_odata0), .w_odata1(w_dram_odata1),
        .w_we(r_we), .w_le(r_rd), .w_wdata(r_wdata), .w_mask(~r_mask), .w_stall(w_busy), 
        .w_mtime(w_mtime[31:0]),
        .w_refresh(r_refresh)
        );
`else
    wire [6:0] drvstate;
    assign SDCLK0=clk_sdram;
    sdramwinb sdram_instance_name(
        .clk(clk_sdram),
        .rst(rst_x), // active low
        .data(Data),
        .addr(Address),
        .ba(Bank),
        .cke(SDCKE0),
        .cs_n(SDCS0),
        .ras_n(RAS),
        .cas_n(CAS),
        .we_n(SDWE),
        .dqm(DQM),

	.dqmi(~r_mask),
        .busy(w_busy),
        .uaddr(r_maddr),
        .ucmd(r_rd | r_we),
        .uwe(r_we),
        .uwrdata(r_wdata),
        .urddata0(w_dram_odata0),
        .urddata1(w_dram_odata1),
        .state_cnt(drvstate)
);
`endif

/**********************************************************************************************/

`ifdef SIM_MODE
    // LOAD linux
    integer i, j;
    //integer k;
    reg  [7:0] mem_bbl [0:`BBL_SIZE-1];
    initial begin
`ifndef VERILATOR
    $display("VERILATOR NOT DEFINED");
    #1
`endif

        $write("Running %s\n", PRELOAD_FILE);
        $readmemh(PRELOAD_FILE, mem_bbl);
        j=0;

        for(i=0;i<`BBL_SIZE;i=i+2) begin
	    idbmem.idbmem.mem[j][7:0]=mem_bbl[i];
	    idbmem.idbmem.mem[j][15:8]=mem_bbl[i+1];
            j=j+1;
        end
        $write("-------------------------------------------------------------------\n");
    end
`endif
endmodule
/**************************************************************************************************/

