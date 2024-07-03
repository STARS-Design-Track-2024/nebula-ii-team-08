`default_nettype none
// Empty top module
localparam MAX_IDX = 20;
typedef enum logic [3:0] { 
    INIT = 0, 
    SET,
    SEND,
    DONE
} state_t; 

typedef enum logic [3:0] {
    INITI = 0,
    DRAW_OBJECTS = 1,
    CHECK_MOVE = 2,
    ERASE_DINO = 3,
    ERASE_CACTUS_1 = 4,
    ERASE_CACTUS_2 = 5,
    DRAW_DINO = 6,
    DRAW_CACTUS_1 = 7,
    DRAW_CACTUS_2 = 8,
    DONES = 9
} state_d;

module top 
(
  // I/O ports
  input  logic hwclk, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue
);

  //internal signals
      // Signals for initialization module
    logic cs_init, cd_init, wr_init, rd_init;
    logic [7:0] data_init;
    logic init_done;

    // Signals for draw block module
    logic cs_draw, cd_draw, wr_draw, rd_draw;
    logic [7:0] data_draw;
    logic block_done;
    logic [8:0] v, dinoY;
    state_t state;
    logic rst, dinoMove, received;

 
    //assign blue = block_done;//doesn't work
    assign rst = pb[1];

    //logic clk1;
    
    //clkdiv div(.inClk(hwclk), .outClk(clk1));
    
    dinoJump dino( 
    .clk(hwclk), .nRst(rst), .button(pb[0]), 
    .dinoDrawDone(received),
    .dinoY(dinoY),
    .dinoJumpGood(),
    .dinoMove(dinoMove),
    .v(v)
); 
   //instantiate controller
   tft_controller controller(
    .clk(hwclk), .rst(rst), .move_enable({1'b0, dinoMove}), .dinoY(dinoY), .cactusX1(0), 
    .cactusX2(0), .cactusH1(0),.cactusH2(0), .v(v), .cs(ss0[3]), .cd(ss0[2]), .wr(ss0[1]), 
    .rd(ss0[0]), .data(ss1), .received(received), .state(left[3:0])
   );

   assign right = dinoY;
   assign red = dinoMove;
   assign left[7] = received;
endmodule

module tft_controller (
    input logic clk,
    input logic rst,
    input logic [1:0] move_enable, // Enable signals for movement of each object
    input logic [7:0] dinoY,
    input logic [8:0] cactusX1, cactusX2,
    input logic [7:0] cactusH1, cactusH2,
    input logic [7:0] v,
    output logic cs,
    output logic cd,
    output logic wr,
    output logic rd,
    output logic [7:0] data,
    output logic received, //returns to move_enabled sent module
    output state_d state
);

logic init_done;
logic [1:0] current_object;
logic block_done;

logic [7:0] x_start, x_end;
logic [8:0] y_start, y_end;
logic [15:0] color;

logic [7:0] d_x_start, d_x_end;
logic [8:0] d_y_start, d_y_end;
logic [15:0] d_color;

logic [8:0] c1_x_start, c1_x_end;
logic [7:0] c1_y_start, c1_y_end;
logic [15:0] c1_color;

logic [8:0] c2_x_start, c2_x_end;
logic [7:0] c2_y_start, c2_y_end;
logic [15:0] c2_color;

logic cs_init;
logic cd_init;
logic wr_init;
logic rd_init;
logic [7:0] data_init;

logic cs_draw;
logic cd_draw;
logic wr_draw;
logic rd_draw;
logic [7:0] data_draw;

// Instantiate the initialization module
    tft_init init_module (
        .clk(clk),
        .rst(rst),
        .cs(cs_init),
        .cd(cd_init),
        .wr(wr_init),
        .rd(rd_init),
        .data(data_init),
        .init_done(init_done),
        .state()
    );

    // Instantiate the draw block module
    draw_block drawBlock (
        .clk(clk),
        .rst(rst),
        .init_done(init_done),
        .x_start(y_start),
        .x_end(y_end),
        .y_start(x_start),
        .y_end(x_end),
        .color(d_color),
        .cs(cs_draw),
        .cd(cd_draw),
        .wr(wr_draw),
        .rd(rd_draw),
        .data(data_draw),
        .block_done(block_done),
        .state(),
        // .counter(right),
        .idx()
    );

     // Select signals based on init_done status
    assign {cs, cd, wr, rd, data} = init_done ? {cs_draw, cd_draw, wr_draw, rd_draw, data_draw} : 
    {cs_init, cd_init, wr_init, rd_init, data_init};

always_comb begin
    d_x_start = 9'd280;
    d_x_end = 9'd300;
    d_y_start = dinoY;
    d_y_end = dinoY + 8'd40;
    d_color = 16'hF800; // Red block

    c1_x_start = cactusX1;
    c1_x_end = cactusX1 + 9'd20; 
    c1_y_start = 8'd101; 
    c1_y_end = 8'd101 + cactusH1; 
    c1_color= 16'h07E0; // Green block

    c2_x_start = cactusX2;
    c2_x_end = cactusX2 + 9'd20; 
    c2_y_start = 8'd101; 
    c2_y_end = 8'd101 + cactusH2; 
    c2_color= 16'h001F; // Blue block
end

always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
        state <= INITI;
        current_object <= 0;
    end else begin
        state <= state;
        received <= 0;
        case (state)
            INITI: begin
                if (init_done) begin
                    state <= DRAW_OBJECTS;
                    current_object <= 0;
                end
            end

            DRAW_OBJECTS: begin
                if (current_object < 3) begin
                    // Set coordinates and color for the current object
                    if(current_object == 0 && ~block_done) begin
                        x_start <= d_x_start;
                        x_end <= d_x_end;
                        y_start <= d_y_start;
                        y_end <= d_y_end;
                        color <= d_color;
                    end else if (block_done) begin
                        current_object <= current_object + 1;
                    end
                    
                    if(current_object == 1 && ~block_done) begin
                        x_start <= c1_x_start;
                        x_end <= c1_x_end;
                        y_start <= c1_y_start;
                        y_end <= c1_y_end;
                        color <= c1_color;
                    end else if (block_done) begin
                        current_object <= current_object + 1;
                    end
                    
                    if(current_object == 2 && ~block_done) begin
                        x_start <= c2_x_start;
                        x_end <= c2_x_end;
                        y_start <= c2_y_start;
                        y_end <= c2_y_end;
                        color <= c2_color;
                    end else if (block_done) begin
                        current_object <= current_object + 1;
                    end
                    state <= DRAW_OBJECTS;
                    
                end else begin
                    state <= CHECK_MOVE;
                end
            end

            CHECK_MOVE: begin
                if (move_enable[0]) begin
                    current_object <= 0;
                    state <= ERASE_DINO;
                end else if(move_enable[1]) begin
                    current_object <= 1;
                    state <= ERASE_CACTUS_1;
                end else begin
                    state <= CHECK_MOVE;
                end
            end

            ERASE_DINO: begin
                // Erase the current object by drawing over it with the background color (assuming background is black)
                //erase the unnecessary blocks
                if (v >= 0) begin
                    x_start <= d_x_start;
                    x_end <= d_x_end;
                    y_start <= d_y_start - v + 1;
                    y_end <= d_y_start - 1;
                    color <= 16'h1111; // white color
                    
                end else if (v < 0) begin
                    x_start <= d_x_start;
                    x_end <= d_x_end;
                    y_start <= d_y_end + 1;
                    y_end <= d_y_end + v + 2;
                    color <= 16'h1111; // white color
                end 
                
                received <= 1;//detected the move)enable signal
                
                if (block_done) begin
                    state <= DRAW_DINO;
                    current_object <= 0;
                end
            end

            ERASE_CACTUS_1: begin
                // Erase the current object by drawing over it with the background color (assuming background is black)
                x_start <= c1_x_start - 1;
                x_end <= c1_x_start - 1;
                y_start <= c1_y_start;
                y_end <= c1_y_end;
                color <= 16'h1111; // white color
                received <= 1;//detected the move)enable signal

                if (block_done) begin
                    state <= ERASE_CACTUS_2;
                    current_object <= 1;
                end
            end

            ERASE_CACTUS_2: begin
                // Erase the current object by drawing over it with the background color (assuming background is black)
                x_start <= c2_x_start - 1;
                x_end <= c2_x_start - 1;
                y_start <= c2_y_start;
                y_end <= c2_y_end;
                color <= 16'h1111; // white color
                received <= 1;//detected the move)enable signal

                if (block_done) begin
                    state <= DRAW_CACTUS_1;
                    current_object <= 1;
                end
            end

            DRAW_DINO: begin
                // Draw the object at the new position
                // calculate the next position of dino
                x_start <= d_x_start;
                x_end <= d_x_end;
                y_start <= d_y_end;
                y_end <= d_y_end + v + 1;
                color <= d_color;
                
                if (block_done) begin
                    state <= DONES;
                    current_object <= 0;
                end        
            end

            DRAW_CACTUS_1: begin
                x_start <= c1_x_start - 1;
                x_end <= c1_x_start - 1;
                y_start <= c1_y_start;
                y_end <= c1_y_end;
                color <= c1_color; // Black color
                received <= 1;//detected the move)enable signal

                if (block_done) begin
                    state <= DRAW_CACTUS_2;
                    current_object <= 1;
                end     
            end
 
            DRAW_CACTUS_2: begin
                x_start <= c2_x_start - 1;
                x_end <= c2_x_start - 1;
                y_start <= c2_y_start;
                y_end <= c2_y_end;
                color <= 16'h0000; // Black color
                received <= 1;//detected the move enable signal

                if (block_done) begin
                    state <= DONES;
                    current_object <= 2;
                end      
            end

            DONES: begin
                state <= CHECK_MOVE;
            end
        endcase
    end
end

endmodule



module draw_block( 
  input logic clk, 
  input logic rst, 
  input logic init_done,
  input logic [8:0] x_start, x_end, 
  input logic [7:0] y_start, y_end,
  input logic [15:0] color,
  output logic cs, 
  output logic cd, 
  output logic wr, 
  output logic rd, 
  output logic [7:0] data,
  output logic block_done,
  output state_t state,
//   output logic [7:0] counter,
  output logic [4:0] idx
  // output logic [8:0] counter
); 

//state_t state; 
//logic [15:0] color; 
// Declare additional variables for pixel coordinates
logic [20:0] counter;

logic [1:0] pixel_state; // State variable to control pixel write sequence
// logic [4:0] idx;


always_ff @(posedge clk or negedge rst) begin 
    if (!rst) begin 
        state <= INIT; 
        wr <= 1;
        counter <= 0;
        block_done <= 0;
        idx <= 0;
        //counter <= 0;

    end else if (init_done) begin 
        block_done <= 0;
        counter <= counter;
        idx <= idx;
        case (state) 
            INIT: begin 
                state <= SET; 
            end 
            SET:begin
                wr <= 0;
                if (idx <= 12) begin
                    idx <= idx + 1;
                end 
                else if (idx == 13) begin
                    idx <= 12;
                    counter <= counter + 1;
                end
                if (counter == (x_end - x_start + 1) * (y_end - y_start + 1))
                    state <= DONE;
                else
                    state <= SEND;
            end
            SEND: begin
                wr <= 1;
                state <= SET;
            end
            DONE: begin
                block_done <= 1;
                counter <= 0;
                idx <= 0;
                state <= INIT;
            end
        endcase 
    end 
end 


always_comb begin
    cs = 0;
    cd = 0;
    rd = 1;
    data = 8'b0;
    case (idx) 
        default: begin
            cs = 0;
            cd = 0;
            rd = 1;
            data = 8'b0;
        end
        5'd0: begin
            cs = 0; // reset 
            cd = 0;
            rd = 1;
            data = 8'b0;
        end
        5'd1: begin
            cs = 0; // SET_COLUMN_ADDR state
            cd = 0;
            rd = 1;
            data = 8'h2A;
        end
        5'd2: begin
            // SET_COLUMN_DATA
            cd = 1;
            rd = 1;
            data = {7'b0, x_start[8]};
        end
        5'd3: begin
            cd = 1;
            data = x_start[7:0];
        end
        5'd4: begin
            cd = 1;
            data = {7'b0, x_end[8]};
        end
        5'd5: begin
            cd = 1;
            data = x_end[7:0];
        end
        5'd6: begin
            cs = 0; // SET_ROW_ADDR state
            cd = 0;
            rd = 1;
            data = 8'h2B;
        end
        5'd7: begin
            cd = 1;
            rd = 1;
            data = 8'h00;
        end
        5'd8: begin
            cd = 1;
            data = y_start;
        end
        5'd9: begin
            cd = 1;
            data = 8'h00;
        end
        5'd10: begin
            cd = 1;
            data = y_end;
        end
        5'd11: begin
            cs = 0; // MEMORY_WRITE state
            cd = 0;
            rd = 1;
            data = 8'h2C;
        end
        5'd12: begin
            cd = 1;
            rd = 1;
            data = color[15:8]; // High byte of color
        end
        5'd13: begin
            cd = 1;
            data = color[7:0]; // Low byte of color
        end
    endcase
end
endmodule 



module tft_init(
    input logic clk,
    input logic rst,
    output logic cs,
    output logic cd,
    output logic wr,
    output logic rd,
    output logic [7:0] data,
    output logic init_done,
    output state_t state
);


    // state_t state;
    logic [5:0] idx;
    logic [23:0] delay_counter; // Counter for delay

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= INIT;
            wr <= 1;
            delay_counter <= 0;
            init_done <= 0;
            idx <= 0;
        end else begin
            init_done <= 0;
            idx <= idx;
            case (state)
                INIT: begin
                    state <= SET;
                end
                SET: begin
                    wr <= 0;
                    delay_counter <= 0;
                    if (idx == 2 || idx == 6)begin
                        state <= SET;
                        delay_counter <= delay_counter + 1;
                        if (delay_counter >= 24'd200000) begin
                            state <= SEND;
                            idx <= idx + 1;
                        end
                    end
                    else if (idx < 6) begin
                        idx <= idx + 1;
                        state <= SEND;
                    end else begin
                        state <= DONE;
                    end
                end
                SEND: begin
                    wr <= 1;
                    state <= SET;
                end
                DONE: begin
                    init_done <= 1;
                    state <= DONE;
                    idx <= 6;
                end
                default: state <= INIT;
            endcase
        end
    end

    always_comb begin
        cs = 0;
        cd = 0;
        rd = 1;
        data = 8'b0;
        case (idx)
            0: begin
                cs = 0;
                cd = 0; 
                rd = 1;
                data = 8'b0;
            end
            1: begin
                cs = 0;
                cd = 0;
                rd = 1;
                data = 8'h01; // Software Reset command
            end
            2: begin
                cs = 0;
                cd = 0;
                rd = 1;
                data = 8'h28; // Display Off command
            end
            3: begin
                cd = 0;
                rd = 1;
                data = 8'h3A; // COLMOD: Pixel Format Set
            end
            4: begin
                cd = 1;
                data = 8'h55; // Set to 16-bit color mode
            end
            5: begin
                cs = 0;
                cd = 0;
                rd = 1;
                data = 8'h11; // Sleep Out command
            end
            6: begin
                cs = 0;
                cd = 0;
                rd = 1;
                data = 8'h29; // Display On command
            end
            7: begin
              cs = 0;
              cd = 0;
              rd = 1;
              data = 8'b0;
            end
            default: begin
            cs = 0;
            cd = 0;
            rd = 1;
            data = 8'b0;
            end
        endcase
    end
endmodule



module dinoJump( 
  input logic clk, nRst, button, 
  input logic dinoDrawDone,
  output logic [7:0] dinoY,
  output logic dinoJumpGood,
  output logic dinoMove,
  output logic [7:0] v
); 

  logic [7:0] floorY = 8'd100; 
  logic [7:0] onFloor = 8'd101; 
  logic en, en2, n_dinoMove; 

  logic [20:0] count, next_count, dinoDelay, next_dinoDelay; 
  logic [7:0] next_v, next_dinoY;  
  logic at_max, maxdinoDelay;  

  always_ff @(posedge clk, negedge nRst) begin
      if (~nRst) begin
        dinoMove <= 0;
      end
      else begin
        dinoMove <= n_dinoMove;
      end
  end

  always_comb begin
    if (next_dinoY != dinoY) 
      n_dinoMove = 1;
    else if (dinoDrawDone)
      n_dinoMove = 0;
    else
      n_dinoMove = dinoMove;
  end

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

        if(dinoDelay == 300000) begin
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
    else if (count == 400000) begin  
      next_count = 0;  
      at_max = 1;  
    end 
    else begin
      next_count = count + 1;  
    end

    if(en && maxdinoDelay) begin 
        next_v = 8'd10;
        next_dinoY = dinoY + 11;
    end 
    else if (at_max) begin 
      next_dinoY = dinoY + v; 
    
      if (en2 && !maxdinoDelay) begin 
        next_v = 8'd0; 
      end

      else begin 
        next_v = v - 1; 
      end 
    end

    else begin 
      next_dinoY = dinoY; 
      next_v = v; 
    end

end 

endmodule




// `default_nettype none
// // Empty top module

// typedef enum logic [3:0] { 
//     INIT = 0, 
//     SET_COLUMN_ADDR = 1, 
//     SET_COLUMN_DATA = 2, 
//     SET_ROW_ADDR = 3, 
//     SET_ROW_DATA = 4, 
//     MEMORY_WRITE = 5, 
//     WRITE_PIXEL = 6, 
//     DONE = 7 
// } state_t; 

// module top 
// (
//   // I/O ports
//   input  logic hwclk, reset,
//   input  logic [20:0] pb,
//   output logic [7:0] left, right,
//          ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
//   output logic red, green, blue
// );

//   //internal signals
//       // Signals for initialization module
//     logic cs_init, cd_init, wr_init, rd_init;
//     logic [7:0] data_init;
//     logic init_done;
//     logic init_dones;
//     logic check_done; // check draw_block

//     // Signals for draw block module
//     logic cs_draw, cd_draw, wr_draw, rd_draw;
//     logic [7:0] data_draw;
//     logic block_done;
//     logic [8:0] current_i;
//     logic [7:0] current_j;
//     state_t state;

//     assign red = check_done;//doesn't work -- set column address
//     //assign red = init_dones;//works
//     assign blue = block_done;//doesn't work
//     assign reset = pb[1];
    

//     // Instantiate the initialization module
//     tft_init init_module (
//         .clk(hwclk),
//         .rst(reset),
//         .cs(cs_init),
//         .cd(cd_init),
//         .wr(wr_init),
//         .rd(rd_init),
//         .data(data_init),
//         .init_done(init_dones)
//     );

//     // Instantiate the draw block module
//     draw_block drawBlock (
//         .clk(hwclk),
//         .rst(reset),
//         .init_done(init_dones),
//         .x_start(9'b1),
//         .x_end(9'd200),
//         .y_start(8'b1),
//         .y_end(8'd100),
//         .color(16'h0),
//         .cs(cs_draw),
//         .cd(cd_draw),
//         .wr(wr_draw),
//         .rd(rd_draw),
//         .data(data_draw),
//         .block_done(block_done),
//         .current_i(current_i),
//         .current_j(current_j),
//         .state(state),
//         .check_done(check_done)
//     );

//     // Select signals based on init_done status
//     assign ss0 = init_done ? {cs_draw, cd_draw, wr_draw, rd_draw} : {cs_init, cd_init, wr_init, rd_init};
//     assign ss1 = init_done ? data_draw : data_init;
//     assign left[7] = block_done;
//     assign left[3:0] = state;

// endmodule


// module draw_block( 
//   input logic clk, 
//   input logic rst, 
//   input logic init_done,
//   input logic [8:0] x_start, x_end, 
//   input logic [7:0] y_start, y_end,
//   input logic [15:0] color,
//   output logic cs, 
//   output logic cd, 
//   output logic wr, 
//   output logic rd, 
//   output logic [7:0] data,
//   output logic block_done,
//   output logic [8:0] current_i,
//   output logic [7:0] current_j,
//   output state_t state,
//   output logic check_done
//   // output logic [8:0] counter
// ); 

// //state_t state; 
// //logic [15:0] color; 
// // Declare additional variables for pixel coordinates
// //logic [7:0] current_i, current_j;
// logic [1:0] pixel_state; // State variable to control pixel write sequence


// always_ff @(posedge clk or posedge rst) begin 
//     if (rst) begin 
//         state <= INIT; 
//         cs <= 1; 
//         cd <= 1; 
//         wr <= 1; 
//         rd <= 1; 
//         data <= 8'b0; 
//         //new
//         current_i <= x_start;
//         current_j <= y_start;
//         pixel_state <= 2'b00;
//         block_done <= 0;
//         check_done <= 0;
//         //counter <= 0;

//     end else if (init_done) begin 
//         block_done <= 0;
//         case (state) 
//             INIT: begin 
//                 state <= SET_COLUMN_ADDR; 
//             end 

//             SET_COLUMN_ADDR: begin 
//                 cs <= 0; 
//                 cd <= 0; 
//                 wr <= 0; 
//                 rd <= 1; 
//                 data <= 8'h2A; // Column Address Set command 
//                 wr <= 1;
//                 state <= SET_COLUMN_DATA;    
//             end 

//             SET_COLUMN_DATA: begin 
//                 cd <= 1;
//                 wr <= 0;
//                 data <= {7'b0, x_start[8]}; // Start address high byte
//                 wr <= 1;
//                 wr <= 0;
//                 data <= x_start[7:0]; // Start address low byte
//                 wr <= 1;
//                 wr <= 0;
//                 data <= {7'b0, x_end[8]}; // End address high byte
//                 wr <= 1;
//                 wr <= 0;
//                 data <= x_end[7:0]; // End address low byte
//                 wr <= 1;
//                 state <= SET_ROW_ADDR;

//             end 
          

//             SET_ROW_ADDR: begin 

//                 cs <= 1; 
//                 cd <= 0; 
//                 wr <= 0; 
//                 rd <= 1; 
//                 data <= 8'h2B; // Row Address Set command 
//                 wr <= 1;
//                 state <= SET_ROW_DATA;
//             end    

//             SET_ROW_DATA: begin 

//                 cd <= 1;
//                 wr <= 0;
//                 data <= 8'h00; // Start address high byte
//                 wr <= 1;
//                 wr <= 0;
//                 data <= y_start; // Start address low byte
//                 wr <= 1;
//                 wr <= 0;
//                 data <= 8'h00; // End address high byte
//                 wr <= 1;
//                 wr <= 0;
//                 data <= y_end; // End address low byte
//                 wr <= 1;
//                 state <= MEMORY_WRITE;

//             end 

//             MEMORY_WRITE: begin 

//                 cs <= 1; 
//                 cd <= 0; 
//                 wr <= 0; 
//                 rd <= 1; 
//                 data <= 8'h2C; // Memory Write command 
//                 wr <= 1;
//                 state <= WRITE_PIXEL; 

//             end 

//             WRITE_PIXEL: begin
//                 case (pixel_state)
//                     2'b00: begin // Initialize pixel write
//                         cd <= 1;
//                         wr <= 0;
//                         data <= color[15:8]; // High byte of color
//                         wr <= 1;
//                         pixel_state <= 2'b01;
//                         //counter <= counter + 1;//NEW
//                         state <= WRITE_PIXEL;
//                     end
//                     2'b01: begin // Write low byte of color
//                         wr <= 0;
//                         data <= color[7:0]; // Low byte of color
//                         wr <= 1;
//                         pixel_state <= 2'b10;
//                         state <= WRITE_PIXEL;
//                     end
//                     2'b10: begin // Increment current_j and check bounds
//                         if (current_j < y_end) begin
//                             current_j <= current_j + 1;
//                             pixel_state <= 2'b00;
//                         end else begin
//                             current_j <= y_start; // Reset current_j for next row
//                             pixel_state <= 2'b11;
//                         end
//                         state <= WRITE_PIXEL;
//                     end
//                     2'b11: begin // Increment current_i and check bounds
//                         if (current_i < x_end) begin
//                             current_i <= current_i + 1;
//                             pixel_state <= 2'b00; // Return to writing pixel
//                         end else begin
//                             // All pixels written, go to DONE state
//                             pixel_state <= 2'b00;
//                             cs <= 1;
//                             cd <= 1;
//                             wr <= 1;
//                             rd <= 1;
//                             block_done <= 1;
//                             state <= DONE;
//                         end
//                     end
//                 endcase
//             end

//             DONE: begin 

//                 cs <= 1; 
//                 cd <= 1; 
//                 wr <= 1; 
//                 rd <= 1; 
//                 block_done <= 1;
//                 state <= DONE; // Restart the process or move to the next task 

//             end 
//             default: begin
//                 state <= INIT;
//             end
//         endcase 
//     end 
// end 
// endmodule 



// module tft_init(
//     input logic clk,
//     input logic rst,
//     output logic cs,
//     output logic cd,
//     output logic wr,
//     output logic rd,
//     output logic [7:0] data,
//     output logic init_done
// );
//     typedef enum logic [3:0] {
//         INITI = 0, 
//         SOFTWARE_RESET = 1, 
//         WAIT_5MS_1 = 2, 
//         DISPLAY_OFF = 3, 
//         SET_COLOR_MODE = 4, 
//         SLEEP_OUT = 5, 
//         WAIT_5MS_2 = 6, 
//         DISPLAY_ON = 7, 
//         DONES = 8
//     } init_state_t;

//     init_state_t state;

//     logic [15:0] delay_counter; // Counter for delay

//     always_ff @(posedge clk or posedge rst) begin
//         if (rst) begin
//             state <= INITI;
//             cs <= 1;
//             cd <= 1;
//             wr <= 1;
//             rd <= 1;
//             data <= 8'b0;
//             delay_counter <= 0;
//             init_done <= 0;
//         end else begin
//             case (state)
//                 INITI: begin
//                     cs <= 0;
//                     cd <= 0;
//                     wr <= 0;
//                     rd <= 1;
//                     data <= 8'h01; // Software Reset command
//                     wr <= 1;
//                     state <= SOFTWARE_RESET;
//                 end
                
//                 SOFTWARE_RESET: begin
//                     wr <= 0;
//                     delay_counter <= delay_counter + 1;
//                     if (delay_counter >= 16'd250000) begin // Assuming a 50MHz clock, 5ms = 250,000 cycles
//                         delay_counter <= 0;
//                         state <= DISPLAY_OFF;
//                     end
//                 end

//                 DISPLAY_OFF: begin
//                     cs <= 0;
//                     cd <= 0;
//                     wr <= 0;
//                     rd <= 1;
//                     data <= 8'h28; // Display Off command
//                     wr <= 1;
//                     state <= SET_COLOR_MODE;
//                 end

//                 SET_COLOR_MODE: begin
//                     wr <= 0;
//                     cd <= 1;
//                     wr <= 0;
//                     data <= 8'h3A; // COLMOD: Pixel Format Set
//                     wr <= 1;
//                     wr <= 0;
//                     data <= 8'h55; // Set to 16-bit color mode
//                     wr <= 1;
//                     state <= SLEEP_OUT;
//                 end

//                 SLEEP_OUT: begin
//                     cs <= 0;
//                     cd <= 0;
//                     wr <= 0;
//                     rd <= 1;
//                     data <= 8'h11; // Sleep Out command
//                     wr <= 1;
//                     state <= WAIT_5MS_2;
//                 end

//                 WAIT_5MS_2: begin
//                     wr <= 0;
//                     delay_counter <= delay_counter + 1;
//                     if (delay_counter >= 16'd250000) begin // Assuming a 50MHz clock, 5ms = 250,000 cycles
//                         delay_counter <= 0;
//                         state <= DISPLAY_ON;
//                     end

//                 end

//                 DISPLAY_ON: begin
//                     cs <= 0;
//                     cd <= 0;
//                     wr <= 0;
//                     rd <= 1;
//                     data <= 8'h29; // Display On command
//                     wr <= 1;
//                     state <= DONES;

//                 end

//                 DONES: begin
//                     cs <= 1;
//                     cd <= 1;
//                     wr <= 1;
//                     rd <= 1;
//                     init_done <= 1;
                  
//                 end

//                 default: state <= INITI;
//             endcase
//         end
//     end
// endmodule

