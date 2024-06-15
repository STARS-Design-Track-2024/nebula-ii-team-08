// STARS STUDENTS: ADD YOUR DESIGN HERE
// $Id: $
// File name:   sample_team_proj.sv
// Created:     5/23/2024
// Author:      Miguel Isrrael Teran
// Description: Sample Team Project

/*
* This sample project consists of a design that cycles through each of the
* 34 available GPIO pins, setting the pin output on and off, one at
* a time, in sequence.
*
* This output cycling is active when "enable" is high, and stops when
* "stop" is high (stop has priority over enable). The LA probes are
* used to supply these 2 signals.
*
* The "prescaler" value controls the cycling period (i.e., how long the
* output of each GPIO pin stays high). This value is programmed
* through the wishbone bus. A prescaler value of 1 means that each pin
* is set high for 1 ms. Similarly, a prescaler value of 1000 means that
* each pin is set high for 1 s.
* 
* "Done" goes high after the last pin output turns off.
* It is used as an interrupt to the management core. Each pin
* should have gone high for the same amount of time
* (one after the other) before the interrupt is raised.
* 
*/

`default_nettype none

module sample_team_proj (
    input logic clk, nrst, // clock rate is 10 MHz
    input logic enable, stop, // from Logic Analyzer (LA) - active/deactivate cycling
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
    flex_counter #(.NUM_CNT_BITS(6)) counter_to_35 (
        .clk(clk),
        .nrst(nrst),
        .count_enable(clk_pulse),
        .clear(stop),
        .rollover_val(6'd35),  // interrupt is raised when count is 35
        .count_out(count),
        .rollover_flag(done)
    );

    // Decoder instantiation
    decoder_for_GPIO decoder (
        .in(count),
        .out(gpio)
    );

endmodule