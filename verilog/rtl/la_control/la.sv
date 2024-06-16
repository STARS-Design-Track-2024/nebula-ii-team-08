


//this
//is
//just
//a
//mux
module la(
    input logic clk,
    input logic nrst,

    //sel lines and lines to be selected between
    input logic [3:0] la_sel,
    input logic [127:0] la_dat [12:0],

    //muxxed output
    output logic [127:0] muxxed_la_dat
);

always_comb begin : just_a_mux
    muxxed_la_dat = la_dat[la_sel];
end


//assign muxxed_la_dat = la_dat[la_sel];


endmodule