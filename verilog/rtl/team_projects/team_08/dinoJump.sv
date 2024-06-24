module dinoJump( 
  input logic clk, nRst, button, 
  output logic [7:0] dinoY 
); 

  logic [7:0] floorY = 8'd150; 
  logic [7:0] onFloor = 8'd151; 
  logic en; 

  logic [20:0] count, next_count; 
  logic [7:0] v, next_v, next_dinoY;  
  logic at_max, next_en;  

  always_ff @(posedge clk, negedge nRst) begin  
    if (~nRst) begin  
      v <= 8'd10;
      dinoY <= 8'd151;  
    end  

    else begin  
      v <= next_v;
      dinoY <= next_dinoY;  
    end  
  end 

  always_ff @(posedge clk, negedge nRst) begin  
    if (~nRst) begin  
      count <= 0;
    end 

    else begin
      count <= next_count;
    end  
  end  

  always_comb begin 
    if(next_dinoY == onFloor) begin 
      en = 1'b1; 
    end 

    else begin 
      en = 1'b0; 
    end 
  end

  always_comb begin
   
    next_count = 0;  
    at_max = 0;  
    
    if(en && button) begin
      next_count = 0;
    end
    else if (count == 1000000) begin  
      next_count = 0;  
      at_max = 1;  
    end 
    else begin
      next_count = count + 1;  
    end


    if(en && button) begin 
        next_v = 8'd8;
        next_dinoY = dinoY + 10;
    end 
    else if (at_max) begin 
      next_dinoY = dinoY + v; 
    
      if (en && !button) begin 
        next_v = 8'd0; 
      end

      else begin 
        next_v = v - 2; 
      end 
    end

    else begin 
      next_dinoY = dinoY; 
      next_v = v; 
    end

end 

endmodule