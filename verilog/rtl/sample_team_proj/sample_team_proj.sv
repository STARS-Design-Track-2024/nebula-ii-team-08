// $Id: $
// File name:   sample_team_proj.sv
// Created:     5/23/2024
// Author:      Miguel Isrrael Teran
// Description: Sample Team Project

/*
* This sample project cycles through each of the 34 available GPIO
* pins, setting the pin output high one at a time in sequence.
*
* This output cycling is active when "enable" is high, and ends when
* "stop" is high (stop has priority over start).
*
* The "prescaler" controls the cycling period (i.e., how long the
* output of each GPIO pin stays high). A prescaler value of 1 means
* that each pin is set high for 1 ms.
* 
* "Done" indicates when the last pin output has gone high.
* Is is used as an interrupt to the management core.
* 
*/

`default_nettype none

module sample_team_proj (
    input logic clk, nrst, // clock rate is 10 MHz
    input logic enable, stop, // from logic analyzer - turn cycling on and off
    input logic [13:0] prescaler,  // from Wishbone bus - controls period per pin in the sequence
    output logic done,  // set as interrupt
    output logic [33:0] gpio // breakout board pins (outputs)
);
    // Internal signals
    logic clk_pulse;
    logic [5:0] count;

    // Clock divider
    flex_counter #(.NUM_CNT_BITS(28)) clk_divider (
        .clk(clk),
        .nrst(nrst),
        .count_enable(enable),
        .clear(stop),
        .rollover_val({14'd0, prescaler} * 28'd10000),  // there are 10^4 clock cycles in 1 ms
        .rollover_flag(clk_pulse),
        .count_out()
    );

    // Counter
    flex_counter #(.NUM_CNT_BITS(6)) counter_to_34 (
        .clk(clk),
        .nrst(nrst),
        .count_enable(clk_pulse),
        .clear(stop),
        .rollover_val(6'd34),
        .count_out(count),
        .rollover_flag(done)
    );

    // Decoder instantiation
    decoder_for_GPIO decoder (
        .in(count),
        .out(gpio)
    );

endmodule