module dinoJump( 
  input logic clk, nRst, button, 
  output logic [7:0] dinoY,
  output logic dinoJumpGood 
); 

  logic [7:0] floorY = 8'd100; 
  logic [7:0] onFloor = 8'd101; 
  logic en, en2; 

  logic [20:0] count, next_count, dinoDelay, next_dinoDelay; 
  logic [7:0] v, next_v, next_dinoY;  
  logic at_max, maxdinoDelay;  

  always_ff @(posedge clk, negedge nRst) begin  
    if (~nRst) begin  
      v <= 8'd0;
      dinoY <= 8'd101;  
    end  

    else begin  
      v <= next_v;
      dinoY <= next_dinoY;  
    end  
  end 

  always_ff @(posedge clk, negedge nRst) begin  
    if (~nRst) begin  
      count <= 0;
      dinoDelay <= 0;
    end 

    else begin
      count <= next_count;
      dinoDelay <= next_dinoDelay;
    end  
  end  

  always_comb begin 
    if(dinoY == onFloor) begin 
      en = 1'b1; 
    end 
    else begin 
      en = 1'b0; 

    end 
    if(next_dinoY == onFloor) begin 
      en2 = 1'b1; 
    end 
    else begin 
      en2 = 1'b0; 

    end 
  end

//counter for at max 2 based on button
always_comb begin
    maxdinoDelay = 0;

    if(!button) begin
      next_dinoDelay = 0;
      maxdinoDelay = 0;
    end

    else begin
      if(button) begin
        next_dinoDelay = dinoDelay + 1;

        if(dinoDelay == 750000) begin
          next_dinoDelay = 0;
          maxdinoDelay = 1;
        end

        else if(at_max) begin
          next_dinoDelay = 0;
        end

        else begin
          maxdinoDelay = 0;
        end
      end

      else begin
        next_dinoDelay = dinoDelay;
        maxdinoDelay = maxdinoDelay;
      end
    end 

end

assign dinoJumpGood = en && maxdinoDelay;

always_comb begin   
    next_count = 0;  
    at_max = 0;  
    
    if(en && maxdinoDelay) begin
      next_count = 0;
    end
    else if (count == 750000) begin  
      next_count = 0;  
      at_max = 1;  
    end 
    else begin
      next_count = count + 1;  
    end

    if(en && maxdinoDelay) begin 
        next_v = 8'd16;
        next_dinoY = dinoY + 20;
    end 
    else if (at_max) begin 
      next_dinoY = dinoY + v; 
    
      if (en2 && !maxdinoDelay) begin 
        next_v = 8'd0; 
      end

      else begin 
        next_v = v - 4; 
      end 
    end

    else begin 
      next_dinoY = dinoY; 
      next_v = v; 
    end

end 

endmodule