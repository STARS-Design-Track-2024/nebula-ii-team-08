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
    input logic [7:0] pin_0to7_sel [3:0],
    input logic [7:0] pin_8to15_sel [3:0],
    input logic [7:0] pin_16to23_sel [3:0], 
    input logic [7:0] pin_24to31_sel [3:0], 
    input logic [5:0] pin_32to37_sel [3:0], 

    //muxxed output to the gpio pins
    output logic [37:0] muxxed_io_oeb,
    output logic [37:0] muxxed_io_out
    
);

integer 0to7_idx;
integer 8to15_idx;
integer 16to23_idx;
integer 24to31_idx;
integer 32to37_idx;

always_comb begin
    //muxxes for the oeb
    for(0to7_idx = 0; 0to7_idx <= 7; 0to7_idx++) begin
        muxxed_io_oeb[0to7_idx] = io_oeb[0to7_idx][pin_0to7_sel];
        muxxed_io_out[0to7_idx] = io_out[0to7_idx][pin_0to7_sel];
    end
    for(8to15_idx = 8; 8to15_idx <= 15; 8to15_idx++) begin
        muxxed_io_oeb[8to15_idx] = io_oeb[8to15_idx][pin_8to15_sel];
        muxxed_io_out[8to15_idx] = io_out[8to15_idx][pin_8to15_sel];
    end
    for(16to23_idx = 16; 16to23_idx <= 23; 16to23_idx++) begin
        muxxed_io_oeb[16to23_idx] = io_oeb[16to23_idx][pin_16to23_sel];
        muxxed_io_out[16to23_idx] = io_out[16to23_idx][pin_16to23_sel];
    end
    for(24to31_idx = 24; 24to31_idx <= 31; 24to31_idx++) begin
        muxxed_io_oeb[24to31_idx] = io_oeb[24to31_idx][pin_24to31_sel];
        muxxed_io_out[24to31_idx] = io_out[24to31_idx][pin_24to31_sel];
    end
    for(32to37_idx = 32; 32to37_idx <= 37; 32to37_idx++) begin
        muxxed_io_oeb[32to37_idx] = io_oeb[32to37_idx][pin_32to37_sel];
        muxxed_io_out[32to37_idx] = io_out[32to37_idx][pin_32to37_sel];
    end

end

endmodule