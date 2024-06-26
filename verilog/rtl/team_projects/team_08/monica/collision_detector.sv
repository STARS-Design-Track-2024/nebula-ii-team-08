`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);
  //internal signals
 

  //instantiate the floor generator

endmodule

/**
* Implement collision detector
* function: to detect if there is a collision between the dino and the cactus
*           we need to detect x and y coordinates 
*           y: if dinoY <= cactusY + cactusHeight --> then check x 
*           x: if (cactusX < dinoWidth + dinoX) & (dinoWidth + dinoX <= cactusX + cactusWidth)
              cactusX is a variable from cactusGenerator
              cactusWidth is a variable from cactusGenerator
              dinoWidth is the width of dinosaur, x coordinates of [right leg - left leg]
              dinoX is a fixed position, the left corner/leg of the dinosaur, so we need add dinoWidth to get its x coordinates of dino's left leg
              dinoY and dinoWidth are variables from dinoBodyController
* Implementation: 
*           input: clk, reset, dinoY, cactusX, cactusHeight, cactusWidth
                    max x is 320 -- 9 bits;
                    max y is 280 -- 9 bits
                    max height, width: <= 50 pixels, so 6 bits
*           output: collision_detect (0 or 1)
*/
module collision_detector (
  input logic clk,
  input logic reset,
  input logic [8:0] dinoY, 
  input logic [6:0] dinoX, //is a fixed value,
  input logic [4:0] dinoWidth, //fixed value
  input logic [8:0] cactusX,
  input logic [8:0] cactusY, //different cactusY for different types of cactus
  input logic [5:0] cactusHeight,
  input logic [5:0] cactusWidth,//fixed value
  output logic collision_detect //true or false 
);

  // //internal signals
  // logic [6:0] score;
  // //instantite the score counter to show the score for GameOver state
  // score_counter score_counter_inst (
  //   .clk(clk), .reset(reset), .score(score)
  //   );

  always_comb begin
    if (dinoY <= cactusY + cactusHeight) begin
      //check when the dino is at the left side of cactus
      if((cactusX < dinoWidth+dinoX) &  (dinoWidth + dinoX <= cactusX + cactusWidth)) begin
        //collision is detected
        //if we detect the collision, we need to end the game, move to GameOver state, clear the screen, show the score, the user can press the button to move to gameStart state
                                      //show the score in 7-seg display, call score_counter
        //GameOver state logic: 
        collision_detect = 1;

      end 
      //check when the dino is at the right side of cactus
      else if ( (cactusX < dinoX) & (dinoX <= cactusX+cactusWidth)) begin
        //moves to GameOver state
        collision_detect = 1;
        
      end
      else begin
        //collision is NOT detected
        collision_detect = 0;
      end
    end

  else begin
      //collision is NOT detected
      collision_detect = 0;
    end
    
  end
  
endmodule
