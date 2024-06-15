// $Id: $
// File name:   tb_sample_team_proj_Wrapper.sv
// Created:     05/29/2024
// Author:      Miguel Isrrael Teran
// Description: Sample Team Project Wrapper

`timescale		1ns/1ps

`default_nettype	none

`define			WB_AW 16
`define			MS_TB_SIMTIME 1_000_000_000

`include		"include_files/tb_macros.vh"

module tb_sample_team_proj_Wrapper ();
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

	// DUT inputs and outputs
	`TB_WB_SIG
    reg	ncs;
    reg [1:0] la_data_in;
    reg [1:0] la_oenb;
    reg [33:0] gpio_in;
    wire [1:0] la_data_out;
    wire [33:0] gpio_out;
    wire [33:0] gpio_oeb;

    // Test bench signals
	integer tb_test_case_num;
    integer tb_sub_checks;
    integer tb_total_checks;
    integer tb_passed;
    integer i;
	reg [33:0] tb_expected_gpio;

	// Some definitions (look at include file)
    `TB_CLK(clk_i, CLOCK_PERIOD)
	`TB_ESRST(rst_i, 1'b1, clk_i, RESET_DURATION)
	`TB_DUMP("dump.vcd", tb_sample_team_proj_Wrapper, 0)
	`TB_FINISH(`MS_TB_SIMTIME)

	// DUT Portmap
    sample_team_proj_Wrapper DUT (
        .wb_clk_i(clk_i),
        .wb_rst_i(rst_i),
        .wbs_stb_i(stb_i),
        .wbs_cyc_i(cyc_i),
        .wbs_we_i(we_i),
        .wbs_sel_i(sel_i),
        .wbs_dat_i(dat_i),
        .wbs_dat_o(dat_o),
        .wbs_adr_i(adr_i),
        .wbs_ack_o(ack_o),
        .ncs(ncs),
        .la_data_in(la_data_in),
        .la_data_out(la_data_out),
        .la_oenb(la_oenb),
        .gpio_in(gpio_in),
        .gpio_out(gpio_out),
        .gpio_oeb(gpio_oeb),
        .irq(IRQ)
	);

	// Acknowledge Interrupt (as an always block)
	always @(IRQ) begin
		if (IRQ == 1'b1) 
			@(negedge clk_i) ack_irq(IC_REG_OFFSET);
	end

	`include "include_files/wb_tasks.vh"

    // Declare events
    `TB_TEST_EVENT(test1)
	`TB_TEST_EVENT(test2)
	`TB_TEST_EVENT(test3)
	`TB_TEST_EVENT(test4)
	`TB_TEST_EVENT(test5)
	`TB_TEST_EVENT(test6)
	`TB_TEST_EVENT(test7)

    // Main Test Bench Process
    initial begin
		#999 -> e_assert_reset;
		@(e_reset_done);
        tb_test_case_num = 0;
        tb_sub_checks = 0;
        tb_total_checks = 0;
		tb_passed = 0;
        la_data_in = '0;
        la_oenb = '1;
        gpio_in = '0;

		// Perform Test 1
		#1000 -> e_test1_start;
		@(e_test1_done);

		// Perform Test 2
		-> e_test2_start;
		@(e_test2_done);

		// Perform Test 3
		-> e_test3_start;
		@(e_test3_done);

		// // Perform Test 4
		-> e_test4_start;
		@(e_test4_done);

		// Perform Test 5
		-> e_test5_start;
		@(e_test5_done);

		// Perform Test 6
		-> e_test6_start;
		@(e_test6_done);

		// Perform Test 7
		-> e_test7_start;
		@(e_test7_done);

		// Finish the simulation
		$display("\nTest cases passed: %1d/%1d\n", tb_passed, tb_total_checks);
		#1000 $finish();
	end

    // Test 1: Write 1 to Prescaler Register
	`TB_TEST_BEGIN(test1)
		tb_test_case_num++;
		WB_W_WRITE('0, 32'd1);
	`TB_TEST_END(test1);

	// Test 2: Enable interrupt source
	`TB_TEST_BEGIN(test2)
		tb_test_case_num++;
		WB_W_WRITE({16'b0, IM_REG_OFFSET}, 32'd1);
	`TB_TEST_END(test2);

	// Test 3: Testing la_data_in[0] when la_oenb[0] is high
	`TB_TEST_BEGIN(test3)
		tb_test_case_num++;
		@(negedge clk_i) la_data_in[0] = 1'b1;
		#(500)
	`TB_TEST_END(test3)

	// Test 4: Test period of 1 ms
	`TB_TEST_BEGIN(test4)
		tb_test_case_num++;
		la_oenb = '0;
		cycle_all_gpio(14'd1, tb_expected_gpio);
		#(500)
		la_data_in[1] = 1'b0;
		cycle_all_gpio(14'd1, tb_expected_gpio);
		#(500)
		la_data_in = '0;
		la_oenb = '1;
	`TB_TEST_END(test4);

	// Test 5: Testing la_data_in[1] when la_oenb[1] is high/low
	`TB_TEST_BEGIN(test5)
		tb_test_case_num++;
		@(negedge clk_i) la_oenb[0] = 1'b0;
		la_data_in = '1;
		#(10000 * 2 * 100)
		la_oenb[1] = 1'b0;
		#(500)
		la_data_in = '0;
	`TB_TEST_END(test5)

	// Test 6: Write 10 to Prescaler Register
	`TB_TEST_BEGIN(test6)
		tb_test_case_num++;
		WB_W_WRITE('0, 32'd10);
	`TB_TEST_END(test6)

	// Test 7: Test period of 10 ms
	`TB_TEST_BEGIN(test7)
		tb_test_case_num++;
		@(negedge clk_i); la_data_in[0] = 1'b1;
		cycle_all_gpio(14'd10, tb_expected_gpio);
		#(500)
		la_data_in[1] = 1'b0;
		cycle_all_gpio(14'd10, tb_expected_gpio);
		#(500)
		la_data_in = '0;
		la_oenb = '1;
	`TB_TEST_END(test7);

endmodule