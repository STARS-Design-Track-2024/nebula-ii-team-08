//This is a module to give addresses to gpio configuration registers

//needs a wishbone wrapper
//needs to support alternate function for designs
//needs to support 8 pins per pad


module gpio_control(
    input logic clk,
    input logic nrst,
    input logic [37:0] io_oeb [12:0],  
    input logic [37:0] io_out [12:0],

    //select lines that are being sent from a set of registers
    //the wishbone bus can write to
    input logic [3:0] pin_0to7_sel [7:0],
    input logic [3:0] pin_8to15_sel [7:0],
    input logic [3:0] pin_16to23_sel [7:0], 
    input logic [3:0] pin_24to31_sel [7:0], 
    input logic [3:0] pin_32to37_sel [5:0], 

    //muxxed output to the gpio pins
    output logic [37:0] muxxed_io_oeb,
    output logic [37:0] muxxed_io_out
    
);

integer idx_0to7;
integer idx_8to15;
integer idx_16to23;
integer idx_24to31;
integer idx_32to37;


always_comb begin
    //muxxes for the oeb
    for(idx_0to7 = 0; idx_0to7 <= 7; idx_0to7++) begin
        muxxed_io_oeb[idx_0to7] = io_oeb[pin_0to7_sel[idx_0to7]][idx_0to7];
        muxxed_io_out[idx_0to7] = io_out[pin_0to7_sel[idx_0to7]][idx_0to7];
    end
    for(idx_8to15 = 8; idx_8to15 <= 15; idx_8to15++) begin
        muxxed_io_oeb[idx_8to15] = io_oeb[pin_8to15_sel[idx_8to15 - 8]][idx_8to15];
        muxxed_io_out[idx_8to15] = io_out[pin_8to15_sel[idx_8to15 - 8]][idx_8to15];
    end
    for(idx_16to23 = 16; idx_16to23 <= 23; idx_16to23++) begin
        muxxed_io_oeb[idx_16to23] = io_oeb[pin_16to23_sel[idx_16to23 - 16]][idx_16to23];
        muxxed_io_out[idx_16to23] = io_out[pin_16to23_sel[idx_16to23 - 16]][idx_16to23];
    end
    for(idx_24to31 = 24; idx_24to31 <= 31; idx_24to31++) begin
        muxxed_io_oeb[idx_24to31] = io_oeb[pin_24to31_sel[idx_24to31 - 24]][idx_24to31];
        muxxed_io_out[idx_24to31] = io_out[pin_24to31_sel[idx_24to31 - 24]][idx_24to31];
    end
    for(idx_32to37 = 32; idx_32to37 <= 37; idx_32to37++) begin
        muxxed_io_oeb[idx_32to37] = io_oeb[pin_32to37_sel[idx_32to37 - 32]][idx_32to37];
        muxxed_io_out[idx_32to37] = io_out[pin_32to37_sel[idx_32to37 - 32]][idx_32to37];
    end

end

endmodule