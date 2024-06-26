/**
* Module Name: GameState
* Function: this module takes input from other modules and then moves to other states
*           for example, it takes the input from collision detector, 
                        if collision_detect == 1, move to Over state
*/
typedef enum logic [2:0] { 
    IDLE = 3'd0, 
    RUN = 3'd1, 
    OVER = 3'd2,
    WIN = 3'd3
} state_t;

module GameState (
  input logic clk,
  input logic reset,
  input logic collision_detect, // comes from collision_detector module
  input logic button_pressed, //comes from ?
  input logic [6:0] score // comes from score_counter module
);

  //internal signals
  state_t state, next_state;

//state transition logic
always_ff @(posedge clk, negedge reset) begin
  if(reset) begin
    state <= IDLE;
  end else begin
    state <= next_state;
  end
end

//next state logic
always_comb begin
  //initialize 
  next_state = state;//default

  case(state)
    IDLE: begin
      if(button_pressed) begin
        next_state = RUN;
      end
    end

    RUN: begin
      if (collision_detect == 1) begin
        next_state = OVER;
      end
    else if (score == 99) begin
      next_state = WIN;
    end
    end
    
    WIN: begin
      //show WIN!!!!
      //sends to LCD and ssdec

      //go back to IDLE state
      if(button_pressed) begin
        next_state = IDLE;
      end
    end
    
    OVER: begin
      //keep showing the score on 7-seg display until user pressed the button
      //sends to LCD
      
      //go back to IDLE state
      if(button_pressed) begin
        next_state = IDLE;
      end
    end
  endcase
end
