module testbench;  
	import uvm_pkg::*;
  	import uart_pkg::*;
  	import test_pkg::*;

  	/** Instantiate UART Interface */
  	uart_if uart_if_lhs();
  	uart_if uart_if_rhs();

  	/** Interconnect */
  	uart_dut dut(.tx_lhs(uart_if_lhs.rx),
  	             .rx_lhs(uart_if_lhs.tx),
  	             .tx_rhs(uart_if_rhs.rx),
  	             .rx_rhs(uart_if_rhs.tx)
 	             );

 	 /** Set the VIP interface on the environment */
 	 initial begin
    		uvm_config_db#(virtual uart_if)::set(uvm_root::get(),"uvm_test_top","uart_vif_lhs",uart_if_lhs);
    		uvm_config_db#(virtual uart_if)::set(uvm_root::get(),"uvm_test_top","uart_vif_rhs",uart_if_rhs);

    		/** Start the UVM test */
    		run_test();
  	end

endmodule


