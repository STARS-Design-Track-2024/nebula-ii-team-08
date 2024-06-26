`timescale 1ms/10ps 
module tb; 
//test bench for gameState

    // Inputs 
    logic clk; 
    logic reset; 
    logic collision_detect; 
    logic button_pressed; 
    logic [6:0] score; 

    // Instantiate the GameState module 
    GameState uut ( 
        .clk(clk), 
        .reset(reset), 
        .collision_detect(collision_detect), 
        .button_pressed(button_pressed), 
        .score(score) 
    ); 
  // Generate clock signal 
  initial begin 
    clk = 0; 
    forever #5 clk = ~clk;  
  end 

//test bench logic
initial begin 
    // make sure to dump the signals so we can see them in the waveform 
    $dumpfile("sim.vcd"); 
    $dumpvars(0, tb); 

    //initialize
    reset = 1;
    collision_detect = 0;
    button_pressed = 0;
    score = 0;

    //  reset 
    #10 reset = 0; 

    // Test IDLE to RUN transition 
    #10 button_pressed = 1; 
    #10 button_pressed = 0; 

    // Test RUN to OVER transition due to collision 
    #50 collision_detect = 1; 
    #10 collision_detect = 0; 

    // Test OVER to IDLE transition 
    #20 button_pressed = 1; 
    #10 button_pressed = 0; 

    // Test IDLE to RUN transition again 
    #10 button_pressed = 1; 
    #10 button_pressed = 0; 

    // Test RUN to WIN transition due to score 
    #50 score = 99; 
    #10 score = 0; 

    // Test WIN to IDLE transition 
    #20 button_pressed = 1; 
    #10 button_pressed = 0; 

    #100;
    $monitor("At time %0t: state = %0d, next_state = %0d, collision_detect = %b, button_pressed = %b, score = %0d", 
    $time, uut.state, uut.next_state, collision_detect, button_pressed, score); 
    
    $finish; 

end 


endmodule 