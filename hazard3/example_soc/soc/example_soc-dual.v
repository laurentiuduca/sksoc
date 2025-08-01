/*****************************************************************************\
|                      Copyright (C) 2021-2022 Luke Wren                      |
|                     SPDX-License-Identifier: Apache-2.0                     |
\*****************************************************************************/

// Example file integrating a Hazard3 processor, processor JTAG + debug
// components, some memory and a UART.

`default_nettype none

`include "define.vh"

module example_soc #(
	parameter DTM_TYPE   = "JTAG",  // Can be "JTAG" or "ECP5"
	parameter SRAM_DEPTH = 1 << 21, // 2 Mwords x 4 -> 8MB
	parameter CLK_MHZ    = 27,      // For timer timebase
	parameter W_MEMOP   = 5,
	`include "hazard3_config.vh"
) (
	// System clock + reset
	input wire               clk,
	input wire               rst_n,
	input wire		 clk_sdram,

	// JTAG port to RISC-V JTAG-DTM
	input  wire              tck,
	input  wire              trst_n,
	input  wire              tms,
	input  wire              tdi,
	output wire              tdo,

	// IO
	output wire              uart_tx,
	input  wire              uart_rx,

    // tang nano 20k SDRAM
    output wire O_sdram_clk,
    output wire O_sdram_cke,
    output wire O_sdram_cs_n,            // chip select
    output wire O_sdram_cas_n,           // columns addrefoc select
    output wire O_sdram_ras_n,           // row address select
    output wire O_sdram_wen_n,           // write enable
    inout wire [31:0] IO_sdram_dq,       // 32 bit bidirectional data bus
    output wire [10:0] O_sdram_addr,     // 11 bit multiplexed address bus
    output wire [1:0] O_sdram_ba,        // two banks
    output wire [3:0] O_sdram_dqm,       // 32/4

     input  wire        w_rxd,
     output wire        w_txd,
     output wire [5:0] w_led,
     input wire w_btnl,
     input wire w_btnr,
     // when sdcard_pwr_n = 0, SDcard power on
     output wire         sdcard_pwr_n,
     // signals connect to SD bus
     output wire         sdclk,
     inout  wire         sdcmd,
     inout  wire 	 sddat3, sddat2, sddat1, sddat0,
     output wire w_init_done,
     // display
     output wire MAX7219_CLK,
     output wire MAX7219_DATA,
     output wire MAX7219_LOAD
);

//localparam W_ADDR = 32;
//localparam W_DATA = 32;

// ----------------------------------------------------------------------------
// Processor dual core

	wire [W_ADDR-1:0]  i_d_pc, d_d_pc;
        wire [W_ADDR-1:0]  i_haddr, d_haddr;
        wire               i_hwrite, d_hwrite;
        wire [1:0]         i_htrans, d_htrans;
        wire               i_hexcl, d_hexcl; // exclusive access signaling
        wire [2:0]         i_hsize, d_hsize;
        wire [2:0]         i_hburst, d_hburst;
        wire [3:0]         i_hprot, d_hprot;
        wire               i_hmastlock, d_hmastlock;
        wire [7:0]         i_hmaster, d_hmaster; // exclusive access signaling
        wire               i_hready, d_hready;
        wire               i_hresp, d_hresp;
        wire               i_hexokay, d_hexokay; // exclusive access signaling
        wire [W_DATA-1:0]  i_hwdata, d_hwdata;
        wire [W_DATA-1:0]  i_hrdata, d_hrdata;
	// The address phase of an
	// Exclusive Transfer must not be issued while the data phase of an earlier Exclusive Transfer is in progress. This
 	// applies whether the transfers are part of the same Exclusive access sequence or not.
        
	// Level-sensitive interrupt sources
        wire [NUM_IRQS-1:0] irq=0;       // -> mip.meip
        wire [N_HARTS-1:0]          soft_irq;    // -> mip.msip
        wire [N_HARTS-1:0]          timer_irq;   // -> mip.mtip
	wire [N_HARTS-1:0]	    hart_halted;
	wire [N_HARTS*W_DATA-1:0]   hartids;

hazard3_2cpu #(
        // These must have the values given here for you to end up with a useful SoC:
        .RESET_VECTOR    (32'h0000_0000), // 0000_0040
        .MTVEC_INIT      (32'h0000_0000),
        .CSR_M_MANDATORY (1),
        .CSR_M_TRAP      (1),
        .DEBUG_SUPPORT   (1),
        .NUM_IRQS        (1),
        .RESET_REGFILE   (0),
        // Can be overridden from the defaults in hazard3_config.vh during
        // instantiation of example_soc():
        .EXTENSION_A         (EXTENSION_A),
        .EXTENSION_C         (EXTENSION_C),
        .EXTENSION_M         (EXTENSION_M),
        .EXTENSION_ZBA       (EXTENSION_ZBA),
        .EXTENSION_ZBB       (EXTENSION_ZBB),
        .EXTENSION_ZBC       (EXTENSION_ZBC),
        .EXTENSION_ZBS       (EXTENSION_ZBS),
        .EXTENSION_ZBKB      (EXTENSION_ZBKB),
        .EXTENSION_ZIFENCEI  (EXTENSION_ZIFENCEI),
        .EXTENSION_XH3BEXTM  (EXTENSION_XH3BEXTM),
        .EXTENSION_XH3IRQ    (EXTENSION_XH3IRQ),
        .EXTENSION_XH3PMPM   (EXTENSION_XH3PMPM),
        .EXTENSION_XH3POWER  (EXTENSION_XH3POWER),
        .CSR_COUNTER         (1/*CSR_COUNTER*/),
        .U_MODE              (U_MODE),
        .PMP_REGIONS         (PMP_REGIONS),
        .PMP_GRAIN           (PMP_GRAIN),
        .PMP_HARDWIRED       (PMP_HARDWIRED),
        .PMP_HARDWIRED_ADDR  (PMP_HARDWIRED_ADDR),
        .PMP_HARDWIRED_CFG   (PMP_HARDWIRED_CFG),
        .MVENDORID_VAL       (MVENDORID_VAL),
        .BREAKPOINT_TRIGGERS (BREAKPOINT_TRIGGERS),
        .IRQ_PRIORITY_BITS   (IRQ_PRIORITY_BITS),
        .MIMPID_VAL          (MIMPID_VAL),
        .MHARTID_VAL         (MHARTID_VAL),
        .REDUCED_BYPASS      (REDUCED_BYPASS),
        .MULDIV_UNROLL       (MULDIV_UNROLL),
        .MUL_FAST            (MUL_FAST),
        .MUL_FASTER          (MUL_FASTER),
        .MULH_FAST           (MULH_FAST),
        .FAST_BRANCHCMP      (FAST_BRANCHCMP),
        .BRANCH_PREDICTOR    (BRANCH_PREDICTOR),
        .MTVEC_WMASK         (MTVEC_WMASK)
) dualcpu (
        .clk(clk),
        .rst_n(rst_n),

	// JTAG port
    .tck(tck),
    .trst_n(trst_n),
    .tms(tms),
    .tdi(tdi),
    .tdo(tdo),

        // Core 0 bus (named I for consistency with 1-core 2-port tb)
	.i_d_pc(i_d_pc),
        .i_haddr(i_haddr),
        .i_hwrite(i_hwrite),
        .i_htrans(i_htrans),
        .i_hsize(i_hsize),
        .i_hburst(i_hburst),
        .i_hprot(i_hprot),
        .i_hmastlock(i_hmastlock),
        .i_hready(i_hready),
        .i_hresp(i_hresp),
        .i_hwdata(i_hwdata),
        .i_hrdata(i_hrdata),
	// exclusive transfers
	.i_hexcl(i_hexcl),
	.i_hmaster(i_hmaster),
	.i_hexokay(i_hexokay),


        // Core 1 bus (named D for consistency with 1-core 2-port tb)
	.d_d_pc(d_d_pc),
	.d_haddr(d_haddr),
	.d_hwrite(d_hwrite),
	.d_htrans(d_htrans),
	.d_hsize(d_hsize),
	.d_hburst(d_hburst),
	.d_hprot(d_hprot),
	.d_hmastlock(d_hmastlock),
	.d_hready(d_hready),
	.d_hresp(d_hresp),
	.d_hwdata(d_hwdata),
	.d_hrdata(d_hrdata),
        // exclusive transfers
        .d_hexcl(d_hexcl),
        .d_hmaster(d_hmaster),
        .d_hexokay(d_hexokay),

        // Level-sensitive interrupt sources
        .irq(irq),       // -> mip.meip
        .soft_irq(soft_irq),  // -> mip.msip
        .timer_irq(timer_irq),  // -> mip.mtip	
	.hart_halted(hart_halted),
	.hartids(hartids)
);

`ifdef laur0
always @(hartids or bridge_hartid or sram0_hartid) begin
	$display ("hartid=%x {bridge_hartid      , sram0_hartid     }=%x", hartids, {bridge_hartid      , sram0_hartid     });
end
`endif
// ----------------------------------------------------------------------------
// Bus fabric

// - 128 kB SRAM at... 0x0000_0000
// - System timer at.. 0x4000_0000
// - UART at.......... 0x4000_4000

// AHBL layer

wire               sram0_hready_resp;
wire               sram0_hready;
wire               sram0_hresp;
wire [W_ADDR-1:0]  sram0_haddr;
wire               sram0_hwrite;
wire [1:0]         sram0_htrans;
wire [2:0]         sram0_hsize;
wire [2:0]         sram0_hburst;
wire [3:0]         sram0_hprot;
wire               sram0_hmastlock;
wire [W_DATA-1:0]  sram0_hwdata;
wire [W_DATA-1:0]  sram0_hrdata;
wire [W_ADDR-1:0]  sram0_d_pc;
wire [W_DATA-1:0]  sram0_hartid;
// exclusive access signaling
wire               sram0_hexcl;
wire [7:0]         sram0_hmaster;
wire               sram0_hexokay;

wire               bridge_hready_resp;
wire               bridge_hready;
wire               bridge_hresp;
wire [W_ADDR-1:0]  bridge_haddr;
wire               bridge_hwrite;
wire [1:0]         bridge_htrans;
wire [2:0]         bridge_hsize;
wire [2:0]         bridge_hburst;
wire [3:0]         bridge_hprot;
wire               bridge_hmastlock;
wire [W_DATA-1:0]  bridge_hwdata;
wire [W_DATA-1:0]  bridge_hrdata;
wire [W_ADDR-1:0]  bridge_d_pc;
wire [W_DATA-1:0]  bridge_hartid;
// exclusive access signaling
wire               bridge_hexcl;
wire [7:0]         bridge_hmaster;
wire               bridge_hexokay=1;

ahbl_crossbar #(
        .N_MASTERS(N_HARTS),
        .N_SLAVES(2),
        .W_ADDR(32),
        .W_DATA(32),
        .ADDR_MAP    (64'h40000000_00000000),
        .ADDR_MASK   (64'he0000000_e0000000)
) ahbl_crossbar (
        // Global signals
        .clk             (clk),
        .rst_n           (rst_n),

        // From masters; function as slave ports
        .src_hready_resp ({d_hready, i_hready}),
        //.src_hready    ({d_hready, i_hready}),
        .src_hresp       ({d_hresp, i_hresp}),
        .src_haddr       ({d_haddr, i_haddr}),
        .src_hwrite      ({d_hwrite, i_hwrite}),
        .src_htrans      ({d_htrans, i_htrans}),
        .src_hsize       ({d_hsize, i_hsize}),
        .src_hburst      ({d_hburst, i_hburst}),
        .src_hprot       ({d_hprot, i_hprot}),
        .src_hmastlock   ({d_hmastlock, i_hmastlock}),
        .src_hwdata      ({d_hwdata, i_hwdata}),
        .src_hrdata      ({d_hrdata, i_hrdata}),
        .src_d_pc	 ({d_d_pc, i_d_pc}),
	.src_hartid	 (hartids),
        // exclusive access signaling
	.src_hexcl	 ({d_hexcl, i_hexcl}),
        .src_hmaster     ({d_hmaster, i_hmaster}),
        .src_hexokay     ({d_hexokay, i_hexokay}),

        // To slaves; function as master ports
	.dst_hready_resp ({bridge_hready_resp , sram0_hready_resp}),
        .dst_hready      ({bridge_hready      , sram0_hready     }),
        .dst_hresp       ({bridge_hresp       , sram0_hresp      }),
        .dst_haddr       ({bridge_haddr       , sram0_haddr      }),
        .dst_hwrite      ({bridge_hwrite      , sram0_hwrite     }),
        .dst_htrans      ({bridge_htrans      , sram0_htrans     }),
        .dst_hsize       ({bridge_hsize       , sram0_hsize      }),
        .dst_hburst      ({bridge_hburst      , sram0_hburst     }),
        .dst_hprot       ({bridge_hprot       , sram0_hprot      }),
        .dst_hmastlock   ({bridge_hmastlock   , sram0_hmastlock  }),
        .dst_hwdata      ({bridge_hwdata      , sram0_hwdata     }),
        .dst_hrdata      ({bridge_hrdata      , sram0_hrdata     }),
	.dst_d_pc	 ({bridge_d_pc	      , sram0_d_pc	 }),
	.dst_hartid      ({bridge_hartid      , sram0_hartid     }),
        // exclusive access signaling
        .dst_hexcl       ({bridge_hexcl	      , sram0_hexcl}),
        .dst_hmaster     ({bridge_hmaster     , sram0_hmaster}),
        .dst_hexokay     ({bridge_hexokay     , sram0_hexokay})
);

// APB layer

wire        bridge_psel;
wire        bridge_penable;
wire        bridge_pwrite;
wire [15:0] bridge_paddr;
wire [31:0] bridge_pwdata;
wire [31:0] bridge_prdata;
wire        bridge_pready;
wire        bridge_pslverr;

wire        uart_psel;
wire        uart_penable;
wire        uart_pwrite;
wire [15:0] uart_paddr;
wire [31:0] uart_pwdata;
wire [31:0] uart_prdata;
wire        uart_pready;
wire        uart_pslverr;

wire        timer_psel;
wire        timer_penable;
wire        timer_pwrite;
wire [15:0] timer_paddr;
wire [31:0] timer_pwdata;
wire [31:0] timer_prdata;
wire        timer_pready;
wire        timer_pslverr;

wire        sd_psel;    
wire        sd_penable; 
wire        sd_pwrite;
wire [15:0] sd_paddr;
wire [31:0] sd_pwdata;
wire [31:0] sd_prdata;
wire        sd_pready;
wire        sd_pslverr;

ahbl_to_apb apb_bridge_u (
	.clk               (clk),
	.rst_n             (rst_n),

	.ahbls_hready      (bridge_hready),
	.ahbls_hready_resp (bridge_hready_resp),
	.ahbls_hresp       (bridge_hresp),
	.ahbls_haddr       (bridge_haddr),
	.ahbls_hwrite      (bridge_hwrite),
	.ahbls_htrans      (bridge_htrans),
	.ahbls_hsize       (bridge_hsize),
	.ahbls_hburst      (bridge_hburst),
	.ahbls_hprot       (bridge_hprot),
	.ahbls_hmastlock   (bridge_hmastlock),
	.ahbls_hwdata      (bridge_hwdata),
	.ahbls_hrdata      (bridge_hrdata),

	.apbm_paddr        (bridge_paddr),
	.apbm_psel         (bridge_psel),
	.apbm_penable      (bridge_penable),
	.apbm_pwrite       (bridge_pwrite),
	.apbm_pwdata       (bridge_pwdata),
	.apbm_pready       (bridge_pready),
	.apbm_prdata       (bridge_prdata),
	.apbm_pslverr      (bridge_pslverr)
);

apb_splitter #(
	.N_SLAVES   (3),
	// inside devices paddr has 16 bytes
	.ADDR_MAP   ({`SDSPI_DEVADDR, 32'h4000_0000}),
	.ADDR_MASK  (48'hc000_c000_c000)
) inst_apb_splitter (
	.clk (clk),
	.apbs_paddr   (bridge_paddr),
	.apbs_psel    (bridge_psel),
	.apbs_penable (bridge_penable),
	.apbs_pwrite  (bridge_pwrite),
	.apbs_pwdata  (bridge_pwdata),
	.apbs_pready  (bridge_pready),
	.apbs_prdata  (bridge_prdata),
	.apbs_pslverr (bridge_pslverr),

	.apbm_paddr   ({sd_paddr   , uart_paddr  , timer_paddr}),
	.apbm_psel    ({sd_psel    , uart_psel   , timer_psel}),
	.apbm_penable ({sd_penable , uart_penable, timer_penable}),
	.apbm_pwrite  ({sd_pwrite  , uart_pwrite , timer_pwrite}),
	.apbm_pwdata  ({sd_pwdata  , uart_pwdata , timer_pwdata}),
	.apbm_pready  ({sd_pready  , uart_pready , timer_pready}),
	.apbm_prdata  ({sd_prdata  , uart_prdata , timer_prdata}),
	.apbm_pslverr ({sd_pslverr , uart_pslverr, timer_pslverr})
);

// ----------------------------------------------------------------------------
// Memory and peripherals

// No preloaded bootloader -- just use the debugger! (the processor will
// actually enter an infinite crash loop after reset if memory is
// zero-initialised so don't leave the little guy hanging too long)

ahb_sync_sram #(
	.DEPTH (SRAM_DEPTH),
	//.HAS_WRITE_BUFFER (1), // 0 does not work
	.PRELOAD_FILE("init_kernel.txt")
) sram0 (
	.clk               (clk),
	.rst_n             (rst_n),
	.clk_sdram         (clk_sdram),

	.d_pc              (sram0_d_pc),
	.hartid		   (sram0_hartid),
        .w_init_done(w_init_done),

	.ahbls_hready_resp (sram0_hready_resp),
	.ahbls_hready      (sram0_hready),
	.ahbls_hresp       (sram0_hresp),
	.ahbls_haddr       (sram0_haddr),
	.ahbls_hwrite      (sram0_hwrite),
	.ahbls_htrans      (sram0_htrans),
	.ahbls_hsize       (sram0_hsize),	
	.ahbls_hburst      (sram0_hburst),
	.ahbls_hprot       (sram0_hprot),
	.ahbls_hmastlock   (sram0_hmastlock),
	.ahbls_hwdata      (sram0_hwdata),
	.ahbls_hrdata      (sram0_hrdata),
	// exclusive access signaling
	.ahbls_hexcl	   (sram0_hexcl),
	.ahbls_hmaster     (sram0_hmaster),
	.ahbls_hexokay     (sram0_hexokay),

    // tang nano 20k SDRAM
    .O_sdram_clk(O_sdram_clk),
    .O_sdram_cke(O_sdram_cke),
    .O_sdram_cs_n(O_sdram_cs_n),            // chip select
    .O_sdram_cas_n(O_sdram_cas_n),           // columns addrefoc select
    .O_sdram_ras_n(O_sdram_ras_n),           // row address select
    .O_sdram_wen_n(O_sdram_wen_n),           // write enable
    .IO_sdram_dq(IO_sdram_dq),       // 32 bit bidirectional data bus
    .O_sdram_addr(O_sdram_addr),     // 11 bit multiplexed address bus
    .O_sdram_ba(O_sdram_ba),        // two banks
    .O_sdram_dqm(O_sdram_dqm),       // 32/4

                                .w_rxd(w_rxd),
                                .w_txd(w_txd),
                                .w_led(w_led),
                                .w_btnl(w_btnl),
                                .w_btnr(w_btnr),
                                // when sdcard_pwr_n = 0, SDcard power on
                                .sdcard_pwr_n(sdcard_pwr_n),
                                // signals connect to SD controller
				.m_psel(m_psel),
				.m_penable(m_penable),
				.m_pwrite(m_pwrite),
				.m_paddr(m_paddr),
				.m_pwdata(m_pwdata),
				.m_prdata(m_prdata),
				.m_pready(m_pready),
				.m_pslverr(m_pslverr),
				.m_sdsbusy(m_sdsbusy),
				.m_sdspi_status(m_sdspi_status),

                                // display
                                .MAX7219_CLK(MAX7219_CLK),
                                .MAX7219_DATA(MAX7219_DATA),
                                .MAX7219_LOAD(MAX7219_LOAD)

);

wire uart_irq;
uart_mini uart_u (
	.clk          (clk),
	.rst_n        (rst_n),

	.apbs_psel    (uart_psel),
	.apbs_penable (uart_penable),
	.apbs_pwrite  (uart_pwrite),
	.apbs_paddr   (uart_paddr),
	.apbs_pwdata  (uart_pwdata),
	.apbs_prdata  (uart_prdata),
	.apbs_pready  (uart_pready),
	.apbs_pslverr (uart_pslverr),

	.rx           (uart_rx),
	.tx           (uart_tx),
	.cts          (1'b0),
	.rts          (/* unused */),
	.irq          (uart_irq),
	.dreq         (/* unused */)
);

// Microsecond timebase for timer

reg [$clog2(CLK_MHZ)-1:0] timer_tick_ctr;
reg                       timer_tick;

always @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		timer_tick_ctr <= {$clog2(CLK_MHZ){1'b0}};
		timer_tick <= 1'b0;
	end else begin
		if (|timer_tick_ctr) begin
			timer_tick_ctr <= timer_tick_ctr - 1'b1;
		end else begin
			timer_tick_ctr <= CLK_MHZ - 1;
		end
		timer_tick <= ~|timer_tick_ctr;
	end
end

hazard3_riscv_timer timer_u (
	.clk       (clk),
	.rst_n     (rst_n),

	.psel      (timer_psel),
	.penable   (timer_penable),
	.pwrite    (timer_pwrite),
	.paddr     (timer_paddr),
	.pwdata    (timer_pwdata),
	.prdata    (timer_prdata),
	.pready    (timer_pready),
	.pslverr   (timer_pslverr),

	.dbg_halt  (&hart_halted),

	.tick      (timer_tick),

	.soft_irq  (soft_irq),
	.timer_irq (timer_irq)
);

//------------------------------------------------------------

// sd
     // spi
     wire spi_clk, spi_mosi, spi_cs, spi_miso;
     assign sdclk = spi_clk;
     assign sdcmd = spi_mosi;
     assign spi_miso = sddat0;
     assign {sddat3, sddat2, sddat1} = {spi_cs, 2'b11};

	wire        sdspi_psel, m_psel;
	wire        sdspi_penable, m_penable; 
	wire        sdspi_pwrite, m_pwrite;
	wire [15:0] sdspi_paddr, m_paddr;
	wire [31:0] sdspi_pwdata, m_pwdata;
	wire [31:0] sdspi_prdata, m_prdata;
	wire        sdspi_pready, m_pready;
	wire        sdspi_pslverr, m_pslverr;
	wire sdsbusy, m_sdsbusy;
	wire [31:0] sdspi_status, m_sdspi_status;

     assign {sdspi_psel, sdspi_penable, sdspi_pwrite, sdspi_paddr, sdspi_pwdata} = 
	     w_init_done ? {sd_psel, sd_penable, sd_pwrite, sd_paddr, sd_pwdata} :
	     		   {m_psel,  m_penable,  m_pwrite,  m_paddr,  m_pwdata};
     assign {sd_prdata, sd_pready, sd_pslverr} = 
	     {sdspi_prdata, sdspi_pready, sdspi_pslverr};
     assign {m_prdata, m_pready, m_pslverr} =
             {sdspi_prdata, sdspi_pready, sdspi_pslverr};
     assign m_sdsbusy = sdsbusy;
     assign m_sdspi_status = sdspi_status;

hazard3_sd sd(
        .clk       (clk),
        .rst_n     (rst_n),

        .psel      (sdspi_psel),
        .penable   (sdspi_penable),
        .pwrite    (sdspi_pwrite),
        .paddr     (sdspi_paddr),
        .pwdata    (sdspi_pwdata),
        .prdata    (sdspi_prdata),
        .pready    (sdspi_pready),
        .pslverr   (sdspi_pslverr),

        .spi_clk(spi_clk),
        .spi_mosi(spi_mosi),
        .spi_cs(spi_cs),
	.spi_miso(spi_miso),

	.sdsbusy(sdsbusy),
	.sdspi_status(sdspi_status)
);


/*
`ifdef laur0
     // we have 2 sd drivers but only 1 active at a given moment of time
     wire         m_sdclk;
     wire         oc_sdclk;
     assign sdclk = w_init_done ? oc_sdclk : m_sdclk;

     wire sdcmd_oe, oc_sdcmd_oe, m_sdcmd_oe;
     wire o_sdcmd, oc_sdcmd, m_sdcmd;
     assign sdcmd_oe = w_init_done ? oc_sdcmd_oe : m_sdcmd_oe;
     assign o_sdcmd = w_init_done ? oc_sdcmd : m_sdcmd;
     assign sdcmd = sdcmd_oe ? o_sdcmd : 1'bz;

     wire sddat_oe0, sddat_oe321, oc_sddat_oe, m_sddat_oe0, m_sddat_oe321;
     wire [3:0] o_sddat, oc_sddat, m_sddat;
     assign m_sddat[0] = sddat0;
     assign m_sddat_oe0 = 1'b0;
     assign m_sddat_oe321 = 1'b1;
     assign sddat_oe0 = w_init_done ? oc_sddat_oe : m_sddat_oe0;
     assign sddat_oe321 = w_init_done ? oc_sddat_oe : m_sddat_oe321;
     assign o_sddat = w_init_done ? oc_sddat : m_sddat;
     assign {sddat3, sddat2, sddat1} = sddat_oe321 ? o_sddat[3:1] : 3'bzzz;
     assign sddat0 = sddat_oe0 ? o_sddat[0] : 1'bz;
`endif

`ifdef laur0
wire [W_ADDR-1:0] sd_haddr;
wire              sd_hwrite;
wire [1:0]        sd_htrans;
wire [2:0]        sd_hsize;
wire [2:0]        sd_hburst;
wire [3:0]        sd_hprot;
wire              sd_hmastlock;
wire              sd_hexcl;
wire              sd_hready;
wire              sd_hresp;
wire [W_DATA-1:0] sd_hwdata;
wire [W_DATA-1:0] sd_hrdata;
`endif

`ifdef laur0
hazard3_sd #(.DEVADDR(`SDDEVADDR)) sd(
        .clk       (clk),
        .rst_n     (w_init_done),

	`ifdef laur0
        .haddr                      (sd_haddr),
        .hwrite                     (sd_hwrite),
        .htrans                     (sd_htrans),
        .hsize                      (sd_hsize),
        .hburst                     (sd_hburst),
        .hprot                      (sd_hprot),
        .hmastlock                  (sd_hmastlock),
        .hexcl                      (sd_hexcl),
        .hready                     (sd_hready),
        .hresp                      (sd_hresp),
        //.hexokay                    (sd_hexokay),
        .hwdata                     (sd_hwdata),
        .hrdata                     (sd_hrdata),
	`endif

        .psel      (sd_psel),
        .penable   (sd_penable),
        .pwrite    (sd_pwrite),
        .paddr     (sd_paddr),
        .pwdata    (sd_pwdata),
        .prdata    (sd_prdata),
        .pready    (sd_pready),
        .pslverr   (sd_pslverr),
	
	.sd_clk_pad_o(oc_sdclk),
	.sd_cmd(oc_sdcmd),
	.sd_cmd_i(sdcmd),
	.sd_cmd_oe(oc_sdcmd_oe),
	.sd_dat(oc_sddat),
	.sd_dat_oe(oc_sddat_oe),
	.sd_dat_i({sddat3, sddat2, sddat1, sddat0})

);
`endif
*/
endmodule
