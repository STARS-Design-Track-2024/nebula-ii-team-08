

`timescale 1ns/10ps
module gpio_pad_tb();
    logic CLK_PERIOD = 100;
    logic tb_clk;
    logic tb_nrst;

    logic [37:0] tb_io_oeb [12:0];
    logic [37:0] tb_io_out [12:0];
    logic [37:0] tb_muxxed_io_oeb;
    logic [37:0] tb_muxxed_io_out;

gpio_pad DUT (
    .clk(tb_clk),
    .nrst(tb_nrst),
    .io_oeb(tb_io_oeb),
    .io_out(tb_io_out),
    .muxxed_io_oeb(tb_muxxed_io_oeb),
    .muxxed_io_out(tb_muxxed_io_out)
    );

//clock gen
always begin
    tb_clk = 1'b0;
    #(CLK_PERIOD/2);
    tb_clk = 1'b1;
end


task power_on_reset();
    tb_nrst = 1'b1;
    @(posedge tb_clk)
    @(posedge tb_clk)
    tb_nrst = 1'b0;
    @(posedge tb_clk)
    @(posedge tb_clk)
    tb_nrst = 1'b1;
endtask

initial begin
    tb_clk  = 1'b0;
    tb_nrst = 1'b1;
    tb_io_oeb = '0;
    tb_io_out = '0;

//test cases:
    @(negedge tb_clk)

    power_on_reset();

    #(CLK_PERIOD * 2);

    $stop;
end


endmodule

