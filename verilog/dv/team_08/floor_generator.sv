`default_nettype none

module floor_generator (
  input logic clk,
  input logic reset,
  output logic [8:0] x, //x-coordinates on the LCD screen which is 320(x) x 240(y)
  output logic [7:0] y, // output the y coordinates (floor position) to other modules (collision detector) 
                      // to detect if the dinosaur hits the ground, if yes, the dinosaur can jump again, 
                      // if not, we check if the dinosaur collides with cactus ...
  output logic [7:0] segments

);

  always_ff @(posedge clk, posedge reset)
  begin
    if (reset) begin
      x <= 0;
      y <= 8'b01100100; //240 pixels in total on y direction, set the floor height = 100 pixels
    end else begin
      x <= x;
      y <= y;
    end

  end

  always_comb begin
          segments = 8'b00000000;
    if (x <= 0 & y == 8'b01100100) begin
      //enable the pixels on the LCD screen
      //the floor is rectangular shape 
      //x is from 0 to 320, y starts from 0 to 100. 
      //configure the display
      //enable is the configuration of the display
      segments = 8'b00001000;
    end
  
  end
endmodule
