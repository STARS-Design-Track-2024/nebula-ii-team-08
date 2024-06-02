// $Id: $
// File name:   team_template.sv
// Created:     MM/DD/YYYY
// Author:      <Full Name>
// Description: <Module Description>

`default_nettype none

module team_template (
    // HW
    input logic clk, nrst,
    
    // GPIOs
    input logic [33:0] gpio_in,
    output logic [33:0] gpio_out,
    
    /*
    * Add other I/O ports that you wish to interface with the
    * Wishbone bus to the management core or logic analyzer (LA).
    */
);

    /*
    * Place code and sub-module instantiations here.
    */

endmodule