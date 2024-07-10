// This is just the sample project right now
// When testing your design, please replace it with your design's instance

module nebula_ii (
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // User clk, rst
    input wb_clk_i,
    input wb_rst_i,

    // Wishbone Slave ports (WB MI A)
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs, give all here, the wrapper will default 1:4 to unused (to make it easier for teams to change)
    input  [37:0] io_in,
    output [37:0] io_out,
    output [37:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    
    // Number of teams (only sample project for now)
    // Replace sample project with your design for testing
    localparam NUM_TEAMS = 1;

    // LA outputs from all designs
    wire [127:0] designs_la_data_out [NUM_TEAMS:0];

    // GPIO outputs from all designs
    wire [37:0] designs_gpio_out [NUM_TEAMS:0]; // Breakout Board Pins
    wire [37:0] designs_gpio_oeb [NUM_TEAMS:0]; // Active Low Output Enable

    // IRQ from all designs
    // (not used unless a team wants to)
    // wire [2:0] designs_irq [NUM_TEAMS:0];
    assign irq = 3'b0; // Default of 0

    //to arbitrator
    wire        wbs_ack_o_m;
    wire [31:0] wbs_dat_o_m;
    //from arbitrator
    wire        wbs_cyc_i_m;
    wire        wbs_stb_i_m;
    wire        wbs_we_i_m;
    wire [31:0] wbs_adr_i_m;
    wire [31:0] wbs_dat_i_m;
    wire [3:0]  wbs_sel_i_m;

    wire        wbs_ack_i_samp, wbs_ack_i_gpio, wbs_ack_i_la, wbs_ack_i_sram;
    wire [31:0] wbs_dat_i_samp, wbs_dat_i_gpio, wbs_dat_i_la, wbs_dat_i_sram;

    wire        wbs_cyc_o_samp, wbs_cyc_o_gpio, wbs_cyc_o_la, wbs_cyc_o_sram;
    wire        wbs_stb_o_samp, wbs_stb_o_gpio, wbs_stb_o_la, wbs_stb_o_sram;
    wire        wbs_we_o_samp, wbs_we_o_gpio, wbs_we_o_la, wbs_we_o_sram;
    wire [31:0] wbs_adr_o_samp, wbs_adr_o_gpio, wbs_adr_o_la, wbs_adr_o_sram;
    wire [31:0] wbs_dat_o_samp, wbs_dat_o_gpio, wbs_dat_o_la, wbs_dat_o_sram;
    wire [3:0]  wbs_sel_o_samp, wbs_sel_o_gpio, wbs_sel_o_la, wbs_sel_o_sram;
    
    // Assign default values to index 0 of output arrays
    assign designs_la_data_out[0] = 'b0;
    assign designs_gpio_out[0] = 'b0;
    assign designs_gpio_oeb[0] = '1;

    // Sample Project Instance
    // (replace this with your team design instance when testing)
    sample_team_proj_Wrapper sample_team_proj_Wrapper (
    `ifdef USE_POWER_PINS
            .vccd1(vccd1),	// User area 1 1.8V power
            .vssd1(vssd1),	// User area 1 digital ground
    `endif
        //Wishbone Slave and user clk, rst
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),
        .wbs_stb_i(wbs_stb_o_samp),
        .wbs_cyc_i(wbs_cyc_o_samp),
        .wbs_we_i(wbs_we_o_samp),
        .wbs_sel_i(wbs_sel_o_samp),
        .wbs_dat_i(wbs_dat_o_samp),
        .wbs_adr_i(wbs_adr_o_samp),
        .wbs_ack_o(wbs_ack_i_samp),
        .wbs_dat_o(wbs_dat_i_samp),

        // Logic Analyzer
        .la_data_in(la_data_in),
        .la_data_out(designs_la_data_out[1]),
        .la_oenb(la_oenb),

        // GPIOs
        .gpio_in(io_in), // Breakout Board Pins
        .gpio_out(designs_gpio_out[1]), // Breakout Board Pins
        .gpio_oeb(designs_gpio_oeb[1]) // Active Low Output Enable
    );

    // Flattened GPIO outputs
    reg [38*(NUM_TEAMS+1)-1:0] designs_gpio_out_flat;
    reg [38*(NUM_TEAMS+1)-1:0] designs_gpio_oeb_flat;

    // Flattening of GPIO outputs
    integer i1;
    always @* begin
        for (i1 = 0; i1 <= NUM_TEAMS; i1 = i1 + 1) begin
            designs_gpio_out_flat[i1*38 +: 38] = designs_gpio_out[i1];//[38i:38(i+1)-1]
            designs_gpio_oeb_flat[i1*38 +: 38] = designs_gpio_oeb[i1];//[38i:38(i+1)-1]
        end
    end

    // GPIO Control
    gpio_control_Wrapper #(
        .NUM_TEAMS(NUM_TEAMS)
    ) gpio_control_wrapper (
        // Wishbone Slave ports (WB MI A)
    `ifdef USE_POWER_PINS
            .vccd1(vccd1),	// User area 1 1.8V power
            .vssd1(vssd1),	// User area 1 digital ground
    `endif
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),
        .wbs_stb_i(wbs_stb_o_gpio),
        .wbs_cyc_i(wbs_cyc_o_gpio),
        .wbs_we_i(wbs_we_o_gpio),
        .wbs_sel_i(wbs_sel_o_gpio),
        .wbs_dat_i(wbs_dat_o_gpio),
        .wbs_adr_i(wbs_adr_o_gpio),
        .wbs_ack_o(wbs_ack_i_gpio),
        .wbs_dat_o(wbs_dat_i_gpio),
        
        // GPIOs
        .designs_gpio_out_flat(designs_gpio_out_flat),
        .designs_gpio_oeb_flat(designs_gpio_oeb_flat),
        .gpio_out(io_out),
        .gpio_oeb(io_oeb)
    );

    // Flattened LA outputs
    reg [128*(NUM_TEAMS+1)-1:0] designs_la_data_out_flat;

    // Flattening of LA outputs
    integer i2;
    always @* begin
        for (i2 = 0; i2 <= NUM_TEAMS; i2 = i2 + 1) begin
            designs_la_data_out_flat[i2*128 +: 128] = designs_la_data_out[i2];//[38i:38(i+1)-1]
        end
    end

    // LA Control
    la_control_Wrapper #(
        .NUM_TEAMS(NUM_TEAMS)
    ) la_control_wrapper (
    `ifdef USE_POWER_PINS
            .vccd1(vccd1),	// User area 1 1.8V power
            .vssd1(vssd1),	// User area 1 digital ground
    `endif
        // Wishbone Slave ports (WB MI A)
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),
        .wbs_stb_i(wbs_stb_o_la),
        .wbs_cyc_i(wbs_cyc_o_la),
        .wbs_we_i(wbs_we_o_la),
        .wbs_sel_i(wbs_sel_o_la),
        .wbs_dat_i(wbs_dat_o_la),
        .wbs_adr_i(wbs_adr_o_la),
        .wbs_ack_o(wbs_ack_i_la),
        .wbs_dat_o(wbs_dat_i_la),
        
        // LA
        .designs_la_data_out_flat(designs_la_data_out_flat),
        .la_data_out(la_data_out)
    );

    // Wishbone Arbitrator
    // everywhere with squigly brackets is where more manager signals can be concatinated!!!
    wishbone_arbitrator #(
        .NUM_MANAGERS(1)
    ) wb_arbitrator (
        
    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif

        .CLK(wb_clk_i),
        .nRST(~wb_rst_i),

        //manager to arbitrator, input
        .A_ADR_I({wbs_adr_i}),
        .A_DAT_I({wbs_dat_i}),
        .A_SEL_I({wbs_sel_i}),
        .A_WE_I({wbs_we_i}),
        .A_STB_I({wbs_stb_i}),
        .A_CYC_I({wbs_cyc_i}),

        //arbitrator to manager, output
        .A_DAT_O({wbs_dat_o}),
        .A_ACK_O({wbs_ack_o}),

        //arbitrator to peripheral, input
        .DAT_I(wbs_dat_o_m),
        .ACK_I(wbs_ack_o_m),

        //arbitrator to peripheral, output
        .ADR_O(wbs_adr_i_m),
        .DAT_O(wbs_dat_i_m),
        .SEL_O(wbs_sel_i_m),
        .WE_O(wbs_we_i_m),
        .STB_O(wbs_stb_i_m),
        .CYC_O(wbs_cyc_i_m)
    );

    wishbone_decoder #(
        .NUM_TEAMS(NUM_TEAMS)
    ) wb_decoder (

    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif

        .CLK(wb_clk_i),
        .nRST(~wb_rst_i),

        //muxxing signals that go to manager
        .wbs_ack_i_periph({wbs_ack_i_samp, wbs_ack_i_la, wbs_ack_i_gpio, wbs_ack_i_sram}),
        .wbs_dat_i_periph({wbs_dat_i_samp, wbs_dat_i_la, wbs_dat_i_gpio, wbs_dat_i_sram}),

        .wbs_ack_o_m(wbs_ack_o_m),
        .wbs_dat_o_m(wbs_dat_o_m),

        //muxxing signals that come from manager
        .wbs_cyc_i_m(wbs_cyc_i_m),
        .wbs_stb_i_m(wbs_stb_i_m),
        .wbs_we_i_m(wbs_we_i_m),
        .wbs_adr_i_m(wbs_adr_i_m),
        .wbs_dat_i_m(wbs_dat_i_m),
        .wbs_sel_i_m(wbs_sel_i_m),

        .wbs_cyc_o_periph({wbs_cyc_o_samp, wbs_cyc_o_la, wbs_cyc_o_gpio, wbs_cyc_o_sram}),
        .wbs_stb_o_periph({wbs_stb_o_samp, wbs_stb_o_la, wbs_stb_o_gpio, wbs_stb_o_sram}),
        .wbs_we_o_periph({wbs_we_o_samp, wbs_we_o_la, wbs_we_o_gpio, wbs_we_o_sram}),
        .wbs_adr_o_periph({wbs_adr_o_samp, wbs_adr_o_la, wbs_adr_o_gpio, wbs_adr_o_sram}),
        .wbs_dat_o_periph({wbs_dat_o_samp, wbs_dat_o_la, wbs_dat_o_gpio, wbs_dat_o_sram}),
        .wbs_sel_o_periph({wbs_sel_o_samp, wbs_sel_o_la, wbs_sel_o_gpio, wbs_sel_o_sram})
    );

    // SRAM
    SRAM_1024x32 sram (
    `ifdef USE_POWER_PINS
        .VPWR(vccd1),	// User area 1 1.8V power
        .VGND(vssd1),	// User area 1 digital ground
    `endif

        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),

        // MGMT SoC Wishbone Slave

        .wbs_stb_i(wbs_stb_o_sram),
        .wbs_cyc_i(wbs_cyc_o_sram),
        .wbs_we_i(wbs_we_o_sram),
        .wbs_sel_i(wbs_sel_o_sram),
        .wbs_dat_i(wbs_dat_o_sram),
        .wbs_adr_i(wbs_adr_o_sram),
        .wbs_ack_o(wbs_ack_i_sram),
        .wbs_dat_o(wbs_dat_i_sram)
    );
endmodule

`default_nettype wire