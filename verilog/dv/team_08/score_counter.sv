module score_counter (
  input logic clk,
  input logic reset,
  output logic [6:0] score //7 bit score which can store up to 127 in max, score goes up to 99 max
);

  //internal signals;
  logic slow_clock;// 0.1 Hz clock signal from the clock_divider
  //clock divider to generate 1 Hz clock from main block which now assumed to be 12 MHz
  
  //instantiate the clock divider module
  clock_divider clock_div(.clk(clk), .nRst_i(reset), .slow_clk(slow_clock));
  
  //score counter logic
  always_ff @(posedge slow_clock, negedge reset) begin
    if (!reset) begin
      score <= 0;
    end else begin
      if (score < 99) begin
        score <= score + 1; // increment score by 1 every 10 seconds
      end
    end
  end


endmodule


//updated Clock_divider module 
module clock_divider ( 
  input logic clk, 
  input logic nRst_i, 
  output logic slow_clk 
  // output logic [23:0] counter
); 

  logic [23:0] counter;//24 bit counter for 12 MHz clock 

always_ff @(posedge clk, negedge nRst_i) begin 

    if(!nRst_i) begin  
      counter <= 0; 
      slow_clk <= 0; 
    end 
    else if (counter >= 10 - 1) begin 
      counter <= 0; // 12 MHz, 100 cycles = 1 second, 100s = 10000 cycles --> 9999 cycles useless 
                    //12 MHz * 10 seconds = 1,000,000,000 cycles 
      // slow_clk <= ~slow_clk; 
      slow_clk <= 1; 
    end 
    else begin 
      counter <= counter + 1; 
      slow_clk <= 0; 
      // slow_clk <= slow_clk; 
    end 

end 

endmodule 

