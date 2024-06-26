module cactusMove(
input logic clk, nRst, enable, rng, gameclk,
input logic [1:0] rng_input,
output logic [7:0] x_dist, //distance between pixels
output logic [8:0] pixel //cactus1_pos, cactus2_pos,
// //col1, col2,row1,row2, 
// output logic cactus_out, cactus1_active, cactus2_active
);
logic [7:0] x_distance;
logic [8:0] n_pixel;
logic [1:0]  x;
logic slw_clk;
logic [31:0]n_count, count, max_i;
logic atmax;

//assign enable = 1;
assign max_i = 60000;

always_ff @(posedge clk, negedge nRst) begin
  if(!nRst)
    count <= 0;
  else
    count <= n_count;
end

always_comb begin
  n_count = count;
  atmax = 0;
  if (enable) begin
    n_count = count + 1;
   if (count == max_i)
      n_count = 0;
  end
  if (count == max_i) begin
    atmax = 1;
  end else
    atmax = 0;
end
// tracking second cactus 
always_ff @(posedge clk, negedge nRst) begin
  if (!nRst) begin
    pixel <= -190;
end else begin
    pixel <= n_pixel;
end
end

always_comb begin
  n_pixel = pixel;
  if (atmax)
    if (pixel <= 320) begin
    n_pixel = pixel + 1;
    end else begin
    n_pixel = -190;
    end
  
end

// Way to generate the two cacti with random pixel distance between them
// Takes input from game clock so that the speed increments accordingly
// Will give direct call to the draw_box function
//Takes RNG input (0,1,2 or 3) and assigns incriments of distance 10 pixels for each (if 0, distance = 10 pixels, if 1 pixel distance = 20 pixels , etc)

//logic [7:0] x_distance; //distance between pixels
logic [8:0] cactus_w, cactus_h;
logic count2, n_count2;


assign cactus_w = 5;
assign cactus_h = 5;

always_ff @(negedge nRst, posedge gameclk)begin
if (~nRst) begin 
count2 <= 0;
end else begin
  count2 <= n_count2;
end
end
 
    localparam CACTUS_MOVE_DISTANCE = 10; // Default distance between cacti

always_comb begin
  if (pixel == 320) begin
        case (rng_input)
            2'b00: x_distance = 100;  // 10 pixels
            2'b01: x_distance = 130; // 20 pixels
            2'b10: x_distance = 160; // 30 pixels
            2'b11: x_distance = 190; // 40 pixels
            default: x_distance = 100; // Default to 10 pixels 
        endcase
  end
  else 
    x_distance = x_dist;
      //col1 = 300 + cactus_w;
      //row1 = 151 + cactus_h;
      //col2 = col1 + x_distance;
      //row2 = row1;
end

// localparam CACTUS_SCREEN_WIDTH = 320;
//     localparam CACTUS_WIDTH = 20;
// assign CACTUS_MOVE_DISTANCE = x_distance;

always_ff @(posedge clk, negedge nRst) begin
        // if (!nRst) begin
        //     cactus1_pos <= CACTUS_SCREEN_WIDTH - CACTUS_WIDTH; // Start cactus1 at 315 pixels
        //     cactus2_pos <= CACT
        
        //     cactus2_pos <= CACTUS_SCREEN_WIDTH + x_distance;
        if (!nRst) 
          x_dist <= 190;
        else 
          x_dist <= x_distance;
        
    end


endmodule