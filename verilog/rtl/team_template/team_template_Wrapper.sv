// $Id: $
// File name:   team_template_Wrapper.sv
// Created:     MM/DD/YYYY
// Author:      <Full Name>
// Description: <Module Description>

module team_template_Wrapper (

`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Chip Select (Active Low)
    input wire ncs,

    /*
    *--------------------------------------------------------------
    * NOTE: You may not need to include all of these.
    *
    * Your team will decide if/how you want to use the Wishbone
    * bus, the LA, or the GPIOs to interface with the chip's
    * management core and off-chip hardware.
    *--------------------------------------------------------------
    */

    // Wishbone Slave ports (WB MI A)
    input wire wb_clk_i,  // DO INCLUDE! - this is your clock signal
    input wire wb_rst_i,  // DO INCLUDE! - this is your reset signal
    input wire wbs_stb_i,
    input wire wbs_cyc_i,
    input wire wbs_we_i,
    input wire [3:0] wbs_sel_i,
    input wire [31:0] wbs_dat_i,
    input wire [31:0] wbs_adr_i,
    output wire wbs_ack_o,
    output wire [31:0] wbs_dat_o,

    // Logic Analyzer (LA)
    input wire [123:0] la_data_in,
    output wire [123:0] la_data_out,
    input wire [123:0] la_oenb,

    // GPIOs
    // (most likely you'll use these)
    input  wire [33:0] gpio_in,
    output wire [33:0] gpio_out,
    output wire [33:0] gpio_oeb,

    // IRQ
    output wire [2:0] irq
);
    /*
    * Declare internal signals here.
    * Assign unused outputs to a default value.
    * Insert additional code, if necessary.
    */

    /*
    *--------------------------------------------------------------
    * IMPORTANT INFO:
    *
    * If your design makes use of the Wishbone bus, please ask
    * your peer mentor to create a "Bus Wrapper" for your top
    * level module. The Bus Wrapper wraps your top level module
    * with the Wishbone slave ports, adds necessary destination
    * and source registers, and handles all the logic for
    * handling Wishbone specifications.
    *
    * Instantiate the Bus Wrapper module (team_template_WB) below.
    * If your design doesn't interface with the Wishbone bus,
    * instantiate your top level module instead (team_template).
    *--------------------------------------------------------------
    */

    // Instantiate Bus Wrapper module here
    team_template_WB DESIGN (
    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(wbs_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i),
        .stb_i(wbs_stb_i),
        .ack_o(wbs_ack_o),
        .we_i(wbs_we_i),
        .IRQ(irq),
        /*
        * Place remaining port connections here.
        */
    );

endmodule