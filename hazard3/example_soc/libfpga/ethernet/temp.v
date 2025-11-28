`timescale 1ns/1ps

//
// tb_eth_mac_mii_phy.v
// Testbench: eth_mac_mii + realistic-ish MII PHY emulator (capture & re-emit)
// Sends one AXI-Stream frame into the MAC, loops it back via PHY emulator,
// and checks RX AXI-Stream bytes match TX bytes.
//
// Note: Assumes eth_mac_mii ports similar to Alex Forencich examples:
//   tx_axis_tdata, tx_axis_tvalid, tx_axis_tready, tx_axis_tlast
//   rx_axis_tdata, rx_axis_tvalid, rx_axis_tlast
//   tx_clk, rx_clk, tx_rst, rx_rst
//   mii_txd[3:0], mii_tx_en
//   mii_rxd[3:0], mii_rx_dv
//

import "DPI-C" function int ethdpimain();
import "DPI-C" function int addbytetotxframe(input byte data);
import "DPI-C" function int sendtxframe();

module top (
	`ifndef ICARUS
	input clk
	`endif
	);

    wire tx_clk, rx_clk;

    // reset
    wire tx_rst;
    wire rx_rst;
    reg rst=1;
    reg [7:0] k=0;

	reg mii_tx_clk=0, mii_rx_clk=0;

    always @(posedge clk) begin
	k <= k+1;
	if(k == 5) begin
		rst <= 0;
		//tx_rst <= 0;
		//rx_rst <= 0;
	end
	if(k == 19) begin
                mii_tx_clk=~mii_tx_clk;
                mii_rx_clk=~mii_rx_clk;		
		k = 0;
    	end
    end
    // ---------------------------------------------------------
    // AXI-Stream TX inputs (into MAC)
    // ---------------------------------------------------------
    reg  [7:0] tx_axis_tdata = 0;
    reg        tx_axis_tvalid = 0;
    wire       tx_axis_tready;
    reg        tx_axis_tlast  = 0;

    // AXI-Stream RX outputs (from MAC)
    wire [7:0] rx_axis_tdata;
    wire       rx_axis_tvalid;
    wire       rx_axis_tlast;

    // MII pins (MAC -> PHY)
    wire [3:0] mii_txd;
    wire       mii_tx_en;

    // MII pins (PHY -> MAC)
    wire [3:0] mii_rxd;
    wire       mii_rx_dv;

    // speed/duplex static config (100 Mbps full duplex)
    wire [2:0] mac_tx_state_reg;

    // ---------------------------------------------------------
    // Instantiate DUT: eth_mac_mii
    // (adjust instance name/params if your checkout differs)
    // ---------------------------------------------------------
    eth_mac_mii #(
        .TARGET("GENERIC"),
        .ENABLE_PADDING(1),
        .MIN_FRAME_LENGTH(64)
    ) dut (
        // clocks / resets
	.rst(rst),
        .rx_clk(rx_clk),
        .rx_rst(rx_rst),
        .tx_clk(tx_clk),
        .tx_rst(tx_rst),

        // AXI-Stream TX (into MAC)
        .tx_axis_tdata(tx_axis_tdata),
        .tx_axis_tvalid(tx_axis_tvalid),
        .tx_axis_tready(tx_axis_tready),
        .tx_axis_tlast(tx_axis_tlast),
	.tx_axis_tuser(0),

        // AXI-Stream RX (out of MAC)
        .rx_axis_tdata(rx_axis_tdata),
        .rx_axis_tvalid(rx_axis_tvalid),
        .rx_axis_tlast(rx_axis_tlast),
        .rx_axis_tuser(), // unused here

        // MII TX -> PHY
        .mii_txd(mii_txd),
        .mii_tx_en(mii_tx_en),
        .mii_tx_er(),     // tie off
	.mii_tx_clk(mii_tx_clk),

	// MII RX <- PHY
        .mii_rxd(mii_rxd),
        .mii_rx_dv(mii_rx_dv),
        .mii_rx_er(1'b0),
	.mii_rx_clk(mii_rx_clk),

	.mac_tx_state_reg(mac_tx_state_reg),

    .cfg_ifg(8'd12),
    .cfg_tx_enable(1'b1),
    .cfg_rx_enable(1'b1),

    .tx_error_underflow(),
    .rx_error_bad_frame(),
    .rx_error_bad_fcs(),
    .tx_start_packet(),
    .rx_start_packet()
    );

    // ---------------------------------------------------------
    // Small test frame to send (Destination/Src/Type + payload)
    // ---------------------------------------------------------
    reg [7:0] tx_frame[0:63]; // 64 bytes
    integer tx_len = 64;
    integer i;
    initial begin
        // build 64 byte test frame: DA(6)=FF.., SA(6)=02:11:22.., Ethertype 0x0800, payload increasing
        tx_frame[0] = 8'hFF; tx_frame[1] = 8'hFF; tx_frame[2] = 8'hFF;
        tx_frame[3] = 8'hFF; tx_frame[4] = 8'hFF; tx_frame[5] = 8'hFF;
        tx_frame[6] = 8'h02; tx_frame[7] = 8'h11; tx_frame[8] = 8'h22;
        tx_frame[9] = 8'h33; tx_frame[10] = 8'h44; tx_frame[11] = 8'h55;
        tx_frame[12] = 8'h08; tx_frame[13] = 8'h00;
        for (i = 14; i < tx_len; i = i + 1) tx_frame[i] = i & 8'hFF;
    end

    // ---------------------------------------------------------
    // Drive AXI-Stream TX: send frame when tready asserted
    // ---------------------------------------------------------
    //always @(*) 
    //    $display("!tx_axis_tready rx_rst=%x tx_rst=%x rx_clk=%x tx_clk=%x", rx_rst, tx_rst, rx_clk, tx_clk);


    reg [7:0] txstate;
    reg [11:0] cnt;
    `ifndef realsend
    integer ret=0;
    initial begin
	    ret = ethdpimain();
    end
    always @(posedge tx_clk or negedge rst) begin
            if(rst) begin
                txstate <= 0;
                cnt <= 0;
                tx_axis_tvalid <= 0;
            end else if(txstate == 0) begin
		if(cnt < tx_len) begin
                  ret = addbytetotxframe(tx_frame[cnt]);
                  cnt <= cnt + 1;
  	   	end else begin
		  ret = sendtxframe();
		  txstate <= 1;
           	end
	    end
    end
    `else
    always @(posedge tx_clk or negedge rst) begin
	    if(rst) begin
		txstate <= 0;
		cnt <= 0;
		tx_axis_tvalid <= 0;
	    end else if(txstate == 0) begin
		// get out from idle
		tx_axis_tvalid <= 1'b1;
		tx_axis_tdata <= tx_frame[cnt];
		cnt <= cnt + 1;
		txstate <= 10;
	    end if(txstate == 10) begin
		// now it sends preamble
                tx_axis_tvalid <= 1'b0;
		txstate <= 1;
	    end else if(txstate == 1) begin
                if(tx_axis_tready) begin
                    $display("tx_axis_tready cnt=%d tx_frame[i]=%x mac_tx_state_reg=%d", cnt, tx_frame[cnt], mac_tx_state_reg);
		    tx_axis_tdata <= tx_frame[cnt];
                    tx_axis_tvalid <= 1'b1;
                    tx_axis_tlast  <= (cnt == tx_len-1);
		    cnt <= cnt + 1;
		    // mii on gbe
		    txstate <= 2;
		end
	    end else if(txstate == 2) begin
		    if(cnt < tx_len)
	                    txstate <= 1;
		    else begin
			    $display("TB: TX injection complete");
			    tx_axis_tvalid <= 0;
			    tx_axis_tlast  <= 0;
			    cnt <= 0;
			    txstate <= 3;
		    end
	    end else if(txstate == 3) begin
	    end
    end
    `endif

    // ---------------------------------------------------------
    // MII PHY emulator:
    // - captures MAC MII TX nibble stream (low-nibble then high-nibble)
    // - reconstructs bytes into an internal buffer
    // - after a programmable delay, replays the captured bytes to MII RX
    // This simulates: "frame left MAC -> PHY -> back to MAC RX"
    // ---------------------------------------------------------
    reg [7:0] phy_buf[0:2047];
    integer phy_len = 0;
    reg capturing = 0;
    reg [3:0] tmp_nibble;
    reg have_low = 0;
    reg [7:0] cur_byte;

    // capture at tx_clk (MAC driving)
    always @(posedge tx_clk) begin
        if (mii_tx_en) begin
            // nibble arrives one-per-clock: low nibble first, then high nibble
            if (!have_low) begin
                tmp_nibble = mii_txd;
                have_low = 1;
            end else begin
                // got high nibble: assemble byte
                cur_byte = { mii_txd, tmp_nibble }; // high: mii_txd, low: tmp_nibble
                phy_buf[phy_len] = cur_byte;
		$display("cur_byte=%x", cur_byte);
                phy_len = phy_len + 1;
                have_low = 0;
            end
            capturing = 1;
        end else begin
            // end of TX frame: if we were in middle of nibble, drop (shouldn't happen)
            have_low = 0;
            if (capturing) begin
                $display("PHY: captured %0d bytes from MAC at time %0t", phy_len, $time);
                capturing = 0;
                // schedule replay after small gap
                //fork
                //    begin : DELAY_REPLAY
                        // wait some RX clock cycles then replay
                        repeat(50) @(posedge rx_clk);
                        phy_replay();
                //    end
                //join_none
            end
        end
    end

    // replay procedure (task) — emits phy_buf[0..phy_len-1] onto MII RX
    task phy_replay;
        integer j;
        begin
            $display("PHY: replaying %0d bytes back to MAC RX at time %0t", phy_len, $time);
            // preamble+SFD are included in captured stream from MAC, so just re-drive bytes as captured
            // Drive nibbles: low nibble first, then high nibble, as MII expects
            for (j = 0; j < phy_len; j = j + 1) begin
                // low nibble
                @(posedge rx_clk);
                drive_rx_nibble(phy_buf[j][3:0]);
		$display("rx state_reg=%d rxd=%x phy_buf[3:0]=%x", dut.eth_mac_1g_inst.axis_gmii_rx_inst.state_reg,
                        dut.eth_mac_1g_inst.axis_gmii_rx_inst.gmii_rxd_d4, phy_buf[j][3:0]);
                // high nibble
                @(posedge rx_clk);
                drive_rx_nibble(phy_buf[j][7:4]);
		$display("rx state_reg=%d rxd=%x phy_buf[7:4]=%x", dut.eth_mac_1g_inst.axis_gmii_rx_inst.state_reg,
                        dut.eth_mac_1g_inst.axis_gmii_rx_inst.gmii_rxd_d4, phy_buf[j][7:4]);
            end
            // end frame: deassert rx dv on next clock
            @(posedge rx_clk);
            drive_rx_idle();
            $display("PHY: replay finished at time %0t", $time);
        end
    endtask

    // helpers to drive rx nibble and idle
    reg [3:0] mii_rxd_reg = 4'h0;
    reg       mii_rx_dv_reg = 1'b0;
    assign mii_rxd = mii_rxd_reg;
    assign mii_rx_dv = mii_rx_dv_reg;

    task drive_rx_nibble(input [3:0] nib);
        begin
            mii_rxd_reg   <= nib;
            mii_rx_dv_reg <= 1'b1;
        end
    endtask

    task drive_rx_idle;
        begin
            mii_rxd_reg   <= 4'h0;
            mii_rx_dv_reg <= 1'b0;
        end
    endtask

    // initialize rx idle
    initial begin
        mii_rxd_reg <= 4'h0;
        mii_rx_dv_reg <= 1'b0;
    end

    // ---------------------------------------------------------
    // AXI-Stream RX monitor: capture received bytes and compare
    // ---------------------------------------------------------
    reg [7:0] rx_buf[0:2047];
    integer rx_len = 0;
    reg receiving = 0;

    always @(posedge rx_clk) begin
        if (rx_axis_tvalid) begin
            // rx_axis_tdata is valid on rx_axis_tvalid — sample at rx clock edge
            rx_buf[rx_len] = rx_axis_tdata;
            rx_len = rx_len + 1;
            if (rx_axis_tlast) begin
                $display("TB: received AXI-Stream frame of %0d bytes at time %0t", rx_len, $time);
                // compare to original frame (frame length tx_len)
                compare_frames();
            end
        end
    end

    task compare_frames;
        integer k;
        integer mismatch;
        begin
            mismatch = 0;
            $display("TB: comparing first %0d bytes (tx_len=%0d, rx_len=%0d)", tx_len, tx_len, rx_len);
            for (k = 0; k < tx_len && k < rx_len; k = k + 1) begin
                if (rx_buf[k] !== tx_frame[k]) begin
                    $display("Mismatch at byte %0d: tx=%02x rx=%02x phy_buf=%02x", k, tx_frame[k], rx_buf[k], phy_buf[k+7]);
                    mismatch = mismatch + 1;
                end
            end
            if (mismatch == 0 && rx_len == tx_len) begin
                $display("TEST PASSED: received frame equals transmitted frame at time %0t", $time);
            end else begin
                $display("TEST FAILED: mismatches=%0d tx_len=%0d rx_len=%0d", mismatch, tx_len, rx_len);
            end
            // finish simulation
            #1000;
            $finish;
        end
    endtask

    // ---------------------------------------------------------
    // Simple debug monitor: print MII TX nibbles (optional)
    // ---------------------------------------------------------
    always @(posedge tx_clk) begin
        if (mii_tx_en) begin
            $display("MTX nibble @%0t : %x", $time, mii_txd);
        end
    end

endmodule

