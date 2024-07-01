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
  score_counter score_counter(
     .clk(hz100), .reset(!pb[0]), .score(right[6:0]));
   
  //internal signals
  logic [6:0] score;
  logic [3:0] tens, unit; 
  //instantiate the score counter
  score_counter score_counter(
    .clk(hz100), .reset(reset), .score(score)
  );
  //instantiate the ssdec
  ssdec ssdec_out0(.score(unit), .enable(1), .out(ss0));
  ssdec ssdec_out1(.score(tens), .enable(1), .out(ss1));
  
  
  logic slow_clock;// 0.1 Hz clock signal from the clock_divider
  // clock_divider clock_div(.clk(hz100), .nRst_i(reset), .slow_clk(slow_clock), .counter());
  clock_divider clock_div(.clk(hz100), .nRst_i(reset), .slow_clk(slow_clock));

  assign ss2 = 8'b00000000;
  assign ss3 = 8'b00000000;
  assign ss4 = 8'b00000000;
  assign ss5 = 8'b00000000;
  assign ss6 = 8'b00000000;
  assign ss7 = 8'b00000000;

 endmodule

//updated score counter for 1 unit increase every 10 seconds
module score_counter (
  input logic clk,
  input logic reset,
  input logic collision_detect, // if collision detected --> stop counting score
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
        if (collision_detect == 1) begin
          score <= score;
          //reset the button
        end
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

 
// score counter for FPGA
// module score_counter ( 
// input logic clk, 
// input logic reset, 
// output logic [6:0] score //7 bit score which can store up to 131071 in max, score goes up to 99999 max 

// ); 

//   //internal signals; 
//   logic slow_clock;// 1 Hz clock signal from the clock_divider 
  
//   //clock divider to generate 1 Hz clock from main block which now assumed to be 100 MHz 
//   //instantiate the clock divider module 
//   clock_divider clock_div(.clk(clk), .nRst_i(reset), .slow_clk(slow_clock)); 
  
//   //score counter logic 
//   always_ff @(posedge slow_clock, posedge reset) begin 
//     if (reset) begin 
//       score <= 0; 
//     end else begin 
//     if (score < 99) begin 
//       score <= score + 1; // increment score by 10 evert second 
//   end 
//   end 
// end 

// endmodule 

// //Clock_divider module  
// module clock_divider (  
//   input logic clk,  
//   input logic nRst_i,  
//   output logic slow_clk  
// );  

//   logic [15:0] counter;//16 bit counter for 100 Hz clock  

//   always_ff @(posedge clk, negedge nRst_i) begin  
//     if(!nRst_i) begin  
//       counter <= 0;  
//       slow_clk <= 0;  
//   end  

//   else if (counter >= 100) begin  
//     counter <= 0; // 100 Hz, 100 cycles = 1 second, 100s = 10000 cycles --> 9999 cycles useless  
//     slow_clk <= 1;  
//     end  
//   else begin  
//     counter <= counter+1;  
//     slow_clk <= 0;  
//   end  
//   end  

// endmodule  
  

// // 8 bits long seven segment module 
// module ssdec( 
// input logic [3:0] score, //input is 4-bit, the score is splited into two part - ten and unit
// input logic enable, //send the enable signal to the common anode 
// output logic [7:0] out //output is 7-bit long for 7 segment 
// ); 

//     //set the outputs 
//     always_comb begin 
//     case(score) 
//       0: out = 8'b00111111;  
//       1: out = 8'b00000110;  
//       2: out = 8'b01011011; 
//       3: out = 8'b01001111; 
//       4: out = 8'b01100110; 
//       5: out = 8'b01101101; 
//       6: out = 8'b01111101; 
//       7: out = 8'b00000111; 
//       8: out = 8'b01111111; 
//       9: out = 8'b01101111; 
//       'hA: out = 8'b01110111; 
//       'hB: out = 8'b01111100; 
//       'hC: out = 8'b00111001; 
//       'hD: out = 8'b01011110; 
//       'hE: out = 8'b01111001; 
//       'hF: out = 8'b01110001; 
//       default: out = 8'b00000000; // all segments off 
//     endcase 
//   end 
// //assign enable = 0; // 00-> enable to disable 

// endmodule 

 