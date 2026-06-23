//=============================================================================
// Project       : UART VIP
//=============================================================================
// Filename      : test_pkg.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 20-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_UART_TEST_PKG__SV
`define GUARD_UART_TEST_PKG__SV

package test_pkg;
	import uvm_pkg::*;
  	import uart_pkg::*;
  	import seq_pkg::*;
  	import env_pkg::*;

  	// Include your file
	`include "uart_base_test.sv"

	// FULL
		// data_width
	`include "uart_FULL_5bit_data_test.sv"
	`include "uart_FULL_6bit_data_test.sv"
	`include "uart_FULL_7bit_data_test.sv"
	`include "uart_FULL_8bit_data_test.sv"
	`include "uart_FULL_9bit_data_test.sv"
		// parity_mode
	`include "uart_FULL_odd_parity_test.sv"
	`include "uart_FULL_even_parity_test.sv"
	`include "uart_FULL_no_parity_test.sv"
		// num_of_stop_bit
	`include "uart_FULL_1_stop_bit_test.sv"
	`include "uart_FULL_2_stop_bit_test.sv"
		// baud_rate
	`include "uart_FULL_4800_baud_test.sv"
	`include "uart_FULL_9600_baud_test.sv"
	`include "uart_FULL_19200_baud_test.sv"
	`include "uart_FULL_57600_baud_test.sv"
	`include "uart_FULL_115200_baud_test.sv"
		// parity_error
	`include "uart_FULL_parity_error_test.sv"
	`include "uart_FULL_parity_normal_test.sv"

	// HALF
		// data_width
	`include "uart_HALF_5bit_data_test.sv"
	`include "uart_HALF_6bit_data_test.sv"
	`include "uart_HALF_7bit_data_test.sv"
	`include "uart_HALF_8bit_data_test.sv"
	`include "uart_HALF_9bit_data_test.sv"
		// parity_mode
	`include "uart_HALF_odd_parity_test.sv"
	`include "uart_HALF_even_parity_test.sv"
	`include "uart_HALF_no_parity_test.sv"
		// num_of_stop_bit
	`include "uart_HALF_1_stop_bit_test.sv"
	`include "uart_HALF_2_stop_bit_test.sv"
		// baud_rate
	`include "uart_HALF_4800_baud_test.sv"
	`include "uart_HALF_9600_baud_test.sv"
	`include "uart_HALF_19200_baud_test.sv"
	`include "uart_HALF_57600_baud_test.sv"
	`include "uart_HALF_115200_baud_test.sv"
		// parity_error
	`include "uart_HALF_parity_error_test.sv"
	`include "uart_HALF_parity_normal_test.sv"

endpackage: test_pkg

`endif


