`timescale 1ms/10ps 
module tb; 
    //test bench for collision_detector
    logic clk;
    logic reset;
    logic [8:0] dinoY;
    logic [6:0] dinoX; //is a fixed value, set at initilization 
    logic [4:0] dinoWidth; //is a fixed value, set at initilization 
    logic [8:0] cactusX;
    logic [8:0] cactusY;
    logic [5:0] cactusHeight;
    logic [5:0] cactusWidth; //fixed value
    logic collision_detect; //true or false 

    //instantiate
    collision_detector uut(
        .clk(clk), .reset(reset), .dinoY(dinoY), .dinoX(dinoX), .dinoWidth(dinoWidth),
        .cactusX(cactusX), .cactusY(cactusY), .cactusHeight(cactusHeight),
        .cactusWidth(cactusWidth), .collision_detect(collision_detect)     
    );

    //generate the clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; //5ms 1/10MHz=1e-7s = 0.0001 ms = 100 ns
    end

initial begin 
    // make sure to dump the signals so we can see them in the waveform 
    $dumpfile("sim.vcd"); 
    $dumpvars(0, tb); 

    //initialization
    reset = 0;
    dinoY = '0;
    dinoX = 7'd50;
    dinoWidth = 5'd20;
    cactusX = '0;
    cactusY = '0;
    cactusHeight = '0;
    cactusWidth = 5'd20; //fixed value
    #10;

    reset = 1;
    //Test cases 1: no collision caz dinoY > cactusY + cactusHeight (1st check condition)
    dinoY = 8'd25;
    cactusX = 8'd10;
    cactusY = 8'd15;
    cactusHeight = 8'd10; //so cactusY + cactusHeight = 20 < dinoY 25 --> No Collision
    cactusWidth = 8'd5; //cactus is 5 * 15 (x, y)
    #10;
    $display("Test Case 1: No collision  collision_detector = %b", collision_detect);

     //Test case 2: collision happened at the left, because dinoY <= cactusY + cactusHeight
                //and (cactusX < dinoWidth+dinoX) &  (dinoWidth + dinoX <= cactusX + cactusWidth)
                //dinoWidth is 20;
                //dinoX is 50;
                //cactusWidth is 20;
    dinoY = 8'd20;
    cactusX = 8'd66; //66 < 70; 70 <= cactusX+cactusWidth = 66+5 = 71 --> Collision happened at the left
    cactusY = 8'd15;
    cactusHeight = 8'd10; //so cactusY + cactusHeight = 20 <= 20 --> Collision
    cactusWidth = 8'd5; //cactus is 5 * 15 (x, y)
    #10;
    $display("Test Case 2: Collided!!!   collision_detector = %b", collision_detect);

    //Test case 3: collision happened at the right, because dinoY <= cactusY + cactusHeight
            //and (cactusX < dinoX) & (dinoX <= cactusX+cactusWidth)
                //dinoWidth is 20;
                //dinoX is 50;
                //cactusWidth is 20;
    dinoY = 8'd20;
    cactusX = 8'd46; //46 < 50; 50 <= cactusX+cactusWidth = 46+5 = 61 --> Collision happened at the right
    cactusY = 8'd15;
    cactusHeight = 8'd10; //so cactusY + cactusHeight = 20 <= 20 --> Collision
    cactusWidth = 8'd5; //cactus is 5 * 15 (x, y)
    #10;
    $display("Test Case 3: Collided!!!   collision_detector = %b", collision_detect);

    $finish;

end 

endmodule 
