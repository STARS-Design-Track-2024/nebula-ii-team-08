// $Id: $
// File name:   flex_counter.sv
// Created:     5/23/2024
// Author:      Miguel Isrrael Teran
// Description: Flexible counter

module flex_counter # (
    parameter NUM_CNT_BITS = 4
)
(
    input logic clk, nrst,
    input logic count_enable, clear,
    input logic [NUM_CNT_BITS-1] rollover_val,
    input logic [NUM_CNT_BITS-1] count_out,
    output logic rollover_flag
);
    // Internal signals
    logic [NUM_CNT_BITS-1:0] next_count;  // next count
    logic next_flag;  //  next rollover_flag

    // Count and Flag Registers
    always_ff @(posedge clk, negedge nrst) begin
        if (~nrst) begin
            count_out <= '0;
            rollover_flag <= 1'b0;
        end else begin
            count_out <= next_count;
            rollover_flag <= next_flag;
        end
    end

    // Next Count & Next Flag Logic
    always_comb begin
        // Next count logic
        if (clear)
            next_count = '0;
        else if (count_enable) begin
            if (rollover_val == '0) {
                next_count = '0;
            }
            else if (count < rollover_val)
                next_count = count_out + 1;
            else if (count == rollover_val)
                next_count = 1;
        end
        else
            next_count = count;

        // Next flag logic
        if (next_count == rollover_val)
            next_flag = 1'b1;
        else
            next_flag = 1'b0;
    end

endmodule