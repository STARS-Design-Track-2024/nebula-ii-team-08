// STARS STUDENTS: DO NOT MODIFY
// $Id: $
// File name:   sample_team_proj_Wrapper.sv
// Created:     05/26/2024
// Author:      Abdulloh Abdubaev
// Description: Sample Team Project Wrapper

module sample_team_proj_Wrapper (
    
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Chip Select (Active Low)
    input wire ncs,

    // Wishbone Slave ports (WB MI A)
    input wire wb_clk_i,
    input wire wb_rst_i,
    input wire wbs_stb_i,
    input wire wbs_cyc_i,
    input wire wbs_we_i,
    input wire [3:0] wbs_sel_i,
    input wire [31:0] wbs_dat_i,
    input wire [31:0] wbs_adr_i,
    output wire wbs_ack_o,
    output wire [31:0] wbs_dat_o,

    // Logic Analyzer - 2 pins used here
    input wire [1:0] la_data_in,
    output wire [1:0] la_data_out,
    input wire [1:0] la_oenb,

    // GPIOs
    input  wire [33:0] gpio_in, // Breakout Board Pins
    output wire [33:0] gpio_out, // Breakout Board Pins
    output wire [33:0] gpio_oeb, // Active Low Output Enable

    // IRQ signal
    output wire irq
);
    // Internal signals
    wire enable;
    wire stop;

    // Interfacing with LA
    assign enable = ~la_oenb[0] & la_data_in[0];
    assign stop = ~la_oenb[1] & la_data_in[1];
    assign la_data_out = '0;

    // Assign gpio_oeb outputs
    assign gpio_oeb = 34'b0;  // using all GPIO pins as outputs

    // Instatiate the "Bus Wrapper" here
    sample_team_proj_WB DESIGN (
    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif
        .ext_clk(),
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
        .enable(enable),
        .stop(stop),
        .gpio(gpio_out)
    );

endmodule