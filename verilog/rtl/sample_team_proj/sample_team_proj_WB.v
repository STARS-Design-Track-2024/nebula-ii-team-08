/*
	Copyright 2024 Purdue University

	Author: Miguel Isrrael Teran (misrrael@purdue.edu)

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	    http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.

*/

/* THIS FILE IS GENERATED, DO NOT EDIT */

`timescale			1ns/1ps
`default_nettype	none

`define				WB_AW		16

`include			"wb_wrapper.vh"

module sample_team_proj_WB (
	`WB_SLAVE_PORTS,
	input	wire	[1-1:0]	enable,
	input	wire	[1-1:0]	stop,
	output	wire	[34-1:0]	gpio
);

	localparam	PRESCALER_VAL_REG_OFFSET = `WB_AW'h0000;
	localparam	IM_REG_OFFSET = `WB_AW'hFF00;
	localparam	MIS_REG_OFFSET = `WB_AW'hFF04;
	localparam	RIS_REG_OFFSET = `WB_AW'hFF08;
	localparam	IC_REG_OFFSET = `WB_AW'hFF0C;
	wire		clk = clk_i;
	wire		nrst = (~rst_i);


	`WB_CTRL_SIGNALS

	wire [14-1:0]	prescaler;
	wire [1-1:0]	done;

	// Register Definitions
	reg [13:0]	PRESCALER_VAL_REG;
	assign	prescaler = PRESCALER_VAL_REG;
	`WB_REG(PRESCALER_VAL_REG, 0, 14)

	reg [0:0] IM_REG;
	reg [0:0] IC_REG;
	reg [0:0] RIS_REG;

	`WB_MIS_REG(1)
	`WB_REG(IM_REG, 0, 1)
	`WB_IC_REG(1)

	wire [0:0] DONE_ASSERT = done;


	integer _i_;
	`WB_BLOCK(RIS_REG, 0) else begin
		for(_i_ = 0; _i_ < 1; _i_ = _i_ + 1) begin
			if(IC_REG[_i_]) RIS_REG[_i_] <= 1'b0; else if(DONE_ASSERT[_i_ - 0] == 1'b1) RIS_REG[_i_] <= 1'b1;
		end
	end

	assign IRQ = |MIS_REG;

	sample_team_proj instance_to_wrap (
		.clk(clk),
		.nrst(nrst),
		.prescaler(prescaler),
		.done(done),
		.enable(enable),
		.stop(stop),
		.gpio(gpio)
	);

	assign	dat_o = 
			(adr_i[`WB_AW-1:0] == PRESCALER_VAL_REG_OFFSET)	? PRESCALER_VAL_REG :
			(adr_i[`WB_AW-1:0] == IM_REG_OFFSET)	? IM_REG :
			(adr_i[`WB_AW-1:0] == MIS_REG_OFFSET)	? MIS_REG :
			(adr_i[`WB_AW-1:0] == RIS_REG_OFFSET)	? RIS_REG :
			(adr_i[`WB_AW-1:0] == IC_REG_OFFSET)	? IC_REG :
			32'hDEADBEEF;

	always @ (posedge clk_i or posedge rst_i)
		if(rst_i)
			ack_o <= 1'b0;
		else if(wb_valid & ~ack_o)
			ack_o <= 1'b1;
		else
			ack_o <= 1'b0;
endmodule
