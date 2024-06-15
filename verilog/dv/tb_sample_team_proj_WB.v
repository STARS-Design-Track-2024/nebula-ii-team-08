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

/* THIS FILE IS GENERATED, edit it to complete the testbench */

`timescale		1ns/1ps

`default_nettype	none

`define			WB_AW			16
`define			MS_TB_SIMTIME		1_000_000_000

`include		"include_files/tb_macros.vh"

module tb_sample_team_proj_WB;

	// Change the following parameters as desired
	parameter real CLOCK_PERIOD = 100.0;
	parameter real RESET_DURATION = 999.0;
	reg [31:0] data_out;

	// DON NOT Change the following parameters
	localparam [`WB_AW-1:0]
			PRESCALER_VAL_REG_OFFSET =	`WB_AW'h0000,
			IM_REG_OFFSET =		`WB_AW'hff00,
			IC_REG_OFFSET =		`WB_AW'hff0c,
			RIS_REG_OFFSET =	`WB_AW'hff08,
			MIS_REG_OFFSET =	`WB_AW'hff04;

	// Test bench signals
	`TB_WB_SIG
	integer tb_test_case_num;
    integer tb_sub_checks;
    integer tb_total_checks;
    integer tb_passed;
    integer i;
	reg [33:0] tb_expected_gpio;

	reg	[0:0]	enable;
	reg	[0:0]	stop;
	wire	[33:0]	gpio;

	`TB_CLK(clk_i, CLOCK_PERIOD)
	`TB_ESRST(rst_i, 1'b1, clk_i, RESET_DURATION)
	`TB_DUMP("WB_sample_team_proj_tb.vcd", tb_sample_team_proj_WB, 0)
	`TB_FINISH(`MS_TB_SIMTIME)

	sample_team_proj_WB DUV (
		`TB_WB_SLAVE_CONN,
		.ext_clk(),
		.enable(enable),
		.stop(stop),
		.gpio(gpio)
	);

	// Acknowledge Interrupt
	always @(IRQ) begin
		if (IRQ == 1'b1) 
			@(negedge clk_i) ack_irq(IC_REG_OFFSET);
	end

	`include "include_files/wb_tasks.vh"

	`TB_TEST_EVENT(test1)
	`TB_TEST_EVENT(test2)
	`TB_TEST_EVENT(test3)
	`TB_TEST_EVENT(test4)
	`TB_TEST_EVENT(test5)

	initial begin
		#999 -> e_assert_reset;
		@(e_reset_done);

		// Perform Test 1
		#1000 -> e_test1_start;
		@(e_test1_done);

		// Perform Test 2
		-> e_test2_start;
		@(e_test2_done);

		// Perform Test 3
		-> e_test3_start;
		@(e_test3_done);

		// Perform Test 4
		-> e_test4_start;
		@(e_test4_done);

		// Perform Test 5
		-> e_test5_start;
		@(e_test5_done);

		// Finish the simulation
		$display("\nTest cases passed: %1d/%1d\n", tb_passed, tb_total_checks);
		#1000 $finish();
	end


	// Test 1: Write 1 to Prescaler Register
	`TB_TEST_BEGIN(test1)
		tb_test_case_num = 1;
        tb_sub_checks = 0;
        tb_total_checks = 0;
        tb_passed = 0;
		enable = 0;
		stop = 0;
		WB_W_WRITE('0, 32'd1);
	`TB_TEST_END(test1)

	// Test 2: Enable interrupt source
	`TB_TEST_BEGIN(test2)
	tb_test_case_num++;
		WB_W_WRITE({16'b0, IM_REG_OFFSET}, 32'd1);
	`TB_TEST_END(test2);

	// Test 3: Test period of 1 ms
	`TB_TEST_BEGIN(test3)
		tb_test_case_num++;
		@(negedge clk_i);
		enable = 1'b1;
		cycle_all_gpio(14'd1, tb_expected_gpio);
		#(500)
		stop = 1'b0;
		cycle_all_gpio(14'd1, tb_expected_gpio);
		#(500)
		enable = 1'b0;
		stop = 1'b0;
	`TB_TEST_END(test3);

	// Test 4: Write 1 to Prescaler Register
	`TB_TEST_BEGIN(test4)
		WB_W_WRITE('0, 32'd10);
	`TB_TEST_END(test4)

	// Test 5: Test period of 10 ms
	`TB_TEST_BEGIN(test5)
		tb_test_case_num++;
		@(negedge clk_i);
		enable = 1'b1;
		cycle_all_gpio(14'd10, tb_expected_gpio);
		#(500)
		stop = 1'b0;
		cycle_all_gpio(14'd10, tb_expected_gpio);
	`TB_TEST_END(test5);

endmodule