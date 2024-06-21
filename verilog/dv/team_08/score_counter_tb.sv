`timescale 10ns/1ns 
module score_counter_tb;  //test bench for score counter

    //inputs
    logic clk;
    logic reset;

    //output the score
    logic [6:0] score;
    localparam clk_per = 8;

    //instantiate the score_counter module
    score_counter uut(
        .clk(clk), .reset(reset), .score(score)
    );

    initial begin
        clk = 0;
    //generate the clock
    forever #(clk_per/2) clk = ~clk;
    end

//test cases
initial begin 
    // make sure to dump the signals so we can see them in the waveform 
    $dumpfile("dump.vcd"); 
    $dumpvars(0, score_counter_tb); 
    reset = 1;
    #clk_per;
    reset = 0;
    #clk_per;
    //initializations
    reset = 1;
    
    #clk_per;
    reset = 0;
    

    #20000000000; //200s --> score = 20
    #clk_per;

    //wait for 500s
    #50000000000;

    reset = 1;
    #clk_per;

    #20000000000;
    $display("score = %d", score);
    $finish;

end 

endmodule 
