

// The purpose of this module is to allow the wishbone bus to control which design
// is writing to the GPIO.  Each GPIO Pin will be able to be configured separately
// this will allow for one design to control some GPIO and another design to control
// other gpio

module gpio_control_wrapper #(
    parameter NUM_TEAMS = 1
)
(
    
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
    
    // GPIOs
    input wire [33:0] designs_gpio_out[NUM_TEAMS:1], // Breakout Board Pins
    input wire [33:0] designs_gpio_oeb[NUM_TEAMS:1], // Active Low Output Enable

    output wire [33:0] gpio_out,
    output wire [33:0] gpio_oeb
);

    //TODO: use buswrap and Matthew's design to wrap the actual controller for the GPIO

endmodule