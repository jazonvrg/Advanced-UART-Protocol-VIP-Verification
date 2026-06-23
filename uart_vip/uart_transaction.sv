class uart_transaction extends uvm_sequence_item;

	typedef enum logic {
		TX = 1'b0,
		RX = 1'b1
	} trans_direction;

	rand logic [8:0] data;
	rand trans_direction direction;
		
	`uvm_object_utils_begin (uart_transaction)
		`uvm_field_int (data, UVM_ALL_ON | UVM_BIN)
		`uvm_field_enum (trans_direction, direction, UVM_ALL_ON | UVM_STRING)
	`uvm_object_utils_end

	function new(string name = "uart_transaction");
		super.new(name);
	endfunction: new

endclass: uart_transaction
