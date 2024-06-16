


// The purpose of this module is to allow the wishbone bus to control which design
// is writing to the GPIO.  Each GPIO Pin will be able to be configured separately
// this will allow for one design to control some GPIO and another design to control
// other gpio

module la_control_wrapper #(
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
    input wire [127:0] designs_la_data_out[NUM_TEAMS:1], // Breakout Board Pins

    output wire [127:0] la_data_out
);
    la_control_WB la_control_WB (
        .ext_clk(wb_clk_i),
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
        .IRQ(),
        .la_dat(designs_la_data_out),
        .muxxed_la_dat(la_data_out)
    );
    //TODO: use buswrap and Matthew's design to wrap the actual controller for the Logic Analyzer

endmodule