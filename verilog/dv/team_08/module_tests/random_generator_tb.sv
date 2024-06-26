`timescale 10ns/10ps 
module tb;  //test bench for score counter

    //inputs
    logic clk1;
    // logic clk2;
    logic reset;
    //output
    logic [1:0] rnd;
    logic button_pressed;

    localparam clk1_prd = 100;
    //localparam clk2_prd = 15;

    multi_clock_lfsr_2bit uut(.clk(clk1), .rst_n(reset), .button_pressed(button_pressed), .rnd(rnd));
    
    //generate clock
    initial begin
        clk1= 0;
    forever #(clk1_prd / 2) clk1 = ~clk1;
    end

    task press_button ();
        button_pressed = 0;
        #200;
        button_pressed = 1;
        #50;
        button_pressed = 0;
    endtask


    // //generate clock1
    // initial begin
    //     clk1= 0;
    // forever #(clk1_prd / 2) clk1 = ~clk1;
    // end

    // //generate clock2
    // initial begin
    //     clk2 = 0;
    // forever #(clk2_prd / 2) clk2 = ~clk2;
    // end

//test cases
initial begin 
    // make sure to dump the signals so we can see them in the waveform 
    $dumpfile("sim.vcd"); 
    $dumpvars(0, tb); 

    //initialize
    
    reset = 1;
    #(clk1_prd *2);
    reset = 0;
    #(clk1_prd *2);
    reset = 1;
    press_button ();
    //add stimulus here
    #(clk1_prd * 100);
    press_button();
    $display("clock1 clock1 rnd");
    $monitor("%b, %b", clk1, rnd);
    // $monitor("%b, %b  %b", clk1, clk2, rnd);
    $finish;
end 


endmodule 