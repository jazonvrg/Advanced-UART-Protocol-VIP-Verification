`uvm_analysis_imp_decl(_drv_lhs)
`uvm_analysis_imp_decl(_mnt_lhs)
`uvm_analysis_imp_decl(_drv_rhs)
`uvm_analysis_imp_decl(_mnt_rhs)

class uart_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(uart_scoreboard)

	uvm_analysis_imp_drv_lhs #(uart_transaction, uart_scoreboard) uart_drv_lhs_export;
	uvm_analysis_imp_mnt_lhs #(uart_transaction, uart_scoreboard) uart_mnt_lhs_export;
	uvm_analysis_imp_drv_rhs #(uart_transaction, uart_scoreboard) uart_drv_rhs_export;
	uvm_analysis_imp_mnt_rhs #(uart_transaction, uart_scoreboard) uart_mnt_rhs_export;
	uart_transaction q_lhs_tx[$], q_rhs_tx[$];
	uart_transaction exp, act;
	uart_configuration cfg;
	logic [8:0] mask;

	covergroup UART_GROUP;
		uart_mode: coverpoint cfg.uart_mode {
			bins FULL_DUPLEX = {uart_configuration::FULL};
			bins HALF_DUPLEX = {uart_configuration::HALF};
		}
		uart_parity_mode: coverpoint cfg.parity_mode {
			bins ODD_PARITY = {uart_configuration::ODD};
			bins EVEN_PARITY = {uart_configuration::EVEN};
			bins NONE_PARITY = {uart_configuration::NONE};
		}
		uart_data_width: coverpoint cfg.data_width {
			bins LEN_5_BITS = {5};
			bins LEN_6_BITS = {6};
			bins LEN_7_BITS = {7};
			bins LEN_8_BITS = {8};
			bins LEN_9_BITS = {9};
		}
		uart_stop_bit: coverpoint cfg.num_of_stop_bit {
			bins LEN_1_STOP = {1};
			bins LEN_2_STOP = {2};
		}
		uart_baud_rate: coverpoint cfg.baud_rate {
			bins BAUD_4800 = {4800};
			bins BAUD_9600 = {9600};
			bins BAUD_19200 = {19200};
			bins BAUD_57600 = {57600};
			bins BAUD_115200 = {115200};
		}
		uart_parity_error: coverpoint cfg.parity_error {
			bins NORMAL_MODE = {uart_configuration::NORMAL};
			bins ERROR_MODE = {uart_configuration::ERROR};
		}
		uart_config: cross uart_mode, uart_parity_mode, uart_data_width, uart_stop_bit, uart_baud_rate, uart_parity_error;
	endgroup		

	function new(string name = "uart_scoreboard", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("build_phase", "Entered...", UVM_LOW);
		uart_drv_lhs_export = new("uart_drv_lhs_export", this);
		uart_mnt_lhs_export = new("uart_mnt_lhs_export", this);
		uart_drv_rhs_export = new("uart_drv_rhs_export", this);
		uart_mnt_rhs_export = new("uart_mnt_rhs_export", this);
		if (!uvm_config_db#(uart_configuration)::get(this, "", "cfg", cfg)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get cfg_lhs from uvm_config_db"))
		end
		`uvm_info("build_phase", "Exiting...", UVM_LOW);
	endfunction: build_phase

	function void write_drv_lhs(uart_transaction trans);
		`uvm_info("write_drv_lhs", $sformatf("Add LHS's drive trans into queue"), UVM_LOW)
		q_lhs_tx.push_back(trans);
	endfunction: write_drv_lhs
	
	function void write_drv_rhs(uart_transaction trans);
		`uvm_info("write_drv_rhs", $sformatf("Add RHS's drive trans into queue"), UVM_LOW)
		q_rhs_tx.push_back(trans);
	endfunction: write_drv_rhs
	
	function void write_mnt_lhs(uart_transaction act);
		mask = (1 << cfg.data_width) - 1;
		if (act.direction == uart_transaction::TX) begin
			if (q_lhs_tx.size() > 0) begin
				$display("");
				`uvm_info("write_mnt_lhs", $sformatf("SIGNAL COMPARATIVE"), UVM_LOW)
				exp = q_lhs_tx.pop_front();
				$display("============================================================================================================================");
				if ((act.data & mask) == (exp.data & mask)) begin
					`uvm_info(get_type_name(), $sformatf("PASSED! Signal is matching. \nExp: \n%s \nAct: \n%s", exp.sprint(), act.sprint()), UVM_LOW);
//					`uvm_info(get_type_name(), $sformatf("PASSED! Signal matching. \n--->Exp: Data = %0*b, Direction = %s \n--->Act: Data = %0*b, Direction = %s", cfg.data_width, exp.data & mask, exp.direction.name(), cfg.data_width, act.data & mask, act.direction.name()), UVM_LOW);
				end else begin
					`uvm_error(get_type_name(), $sformatf("FAILED! Signal is not matching. \nExp \n%s \nAct: \n%s", exp.sprint(), act.sprint()));
//					`uvm_error(get_type_name(), $sformatf("FAILED! Signal is not matching. \n--->Exp: Data = %0*b, Direction = %s \n--->Act: Data = %0*b, Direction = %s", cfg.data_width, exp.data & mask, exp.direction.name(), cfg.data_width, act.data & mask, act.direction.name()));
				end
				$display("============================================================================================================================");
			end
		end else begin
			if (q_rhs_tx.size() > 0) begin
				$display("");
				`uvm_info("write_mnt_lhs", $sformatf("SIGNAL COMPARATIVE"), UVM_LOW)
				exp = q_rhs_tx.pop_front();
				$display("============================================================================================================================");
				if ((act.data & mask) == (exp.data & mask)) begin
					`uvm_info(get_type_name(), $sformatf("PASSED! Signal is matching. \nExp: \n%s \nAct: \n%s", exp.sprint(), act.sprint()), UVM_LOW);
//					`uvm_info(get_type_name(), $sformatf("PASSED! Signal matching. \n--->Exp: Data = %0*b, Direction = %s \n--->Act: Data = %0*b, Direction = %s", cfg.data_width, exp.data & mask, exp.direction.name(), cfg.data_width, act.data & mask, act.direction.name()), UVM_LOW);
				end else begin
					`uvm_error(get_type_name(), $sformatf("FAILED! Signal is not matching. \nExp \n%s \nAct: \n%s", exp.sprint(), act.sprint()));
//					`uvm_error(get_type_name(), $sformatf("FAILED! Signal is not matching. \n--->Exp: Data = %0*b, Direction = %s \n--->Act: Data = %0*b, Direction = %s", cfg.data_width, exp.data & mask, exp.direction.name(), cfg.data_width, act.data & mask, act.direction.name()));
				end
				$display("============================================================================================================================");
			end
		end
	endfunction: write_mnt_lhs
	function void write_mnt_rhs(uart_transaction act);
		mask = (1 << cfg.data_width) - 1;
		if (act.direction == uart_transaction::TX) begin
			if (q_rhs_tx.size() > 0) begin
				$display("");
				`uvm_info("write_mnt_lhs", $sformatf("SIGNAL COMPARATIVE"), UVM_LOW)
				exp = q_rhs_tx.pop_front();
				$display("============================================================================================================================");
				if ((act.data & mask) == (exp.data & mask)) begin
					`uvm_info(get_type_name(), $sformatf("PASSED! Signal is matching. \nExp: \n%s \nAct: \n%s", exp.sprint(), act.sprint()), UVM_LOW);
//					`uvm_info(get_type_name(), $sformatf("PASSED! Signal matching. \n--->Exp: Data = %0*b, Direction = %s \n--->Act: Data = %0*b, Direction = %s", cfg.data_width, exp.data & mask, exp.direction.name(), cfg.data_width, act.data & mask, act.direction.name()), UVM_LOW);
				end else begin
					`uvm_error(get_type_name(), $sformatf("FAILED! Signal is not matching. \nExp \n%s \nAct: \n%s", exp.sprint(), act.sprint()));
//					`uvm_error(get_type_name(), $sformatf("FAILED! Signal is not matching. \n--->Exp: Data = %0*b, Direction = %s \n--->Act: Data = %0*b, Direction = %s", cfg.data_width, exp.data & mask, exp.direction.name(), cfg.data_width, act.data & mask, act.direction.name()));
				end
				$display("============================================================================================================================");
			end
		end else begin
			if (q_lhs_tx.size() > 0) begin
				$display("");
				`uvm_info("write_mnt_lhs", $sformatf("SIGNAL COMPARATIVE"), UVM_LOW)
				exp = q_lhs_tx.pop_front();
				$display("============================================================================================================================");
				if ((act.data & mask) == (exp.data & mask)) begin
					`uvm_info(get_type_name(), $sformatf("PASSED! Signal is matching. \nExp: \n%s \nAct: \n%s", exp.sprint(), act.sprint()), UVM_LOW);
//					`uvm_info(get_type_name(), $sformatf("PASSED! Signal matching. \n--->Exp: Data = %0*b, Direction = %s \n--->Act: Data = %0*b, Direction = %s", cfg.data_width, exp.data & mask, exp.direction.name(), cfg.data_width, act.data & mask, act.direction.name()), UVM_LOW);
				end else begin
					`uvm_error(get_type_name(), $sformatf("FAILED! Signal is not matching. \nExp \n%s \nAct: \n%s", exp.sprint(), act.sprint()));
//					`uvm_error(get_type_name(), $sformatf("FAILED! Signal is not matching. \n--->Exp: Data = %0*b, Direction = %s \n--->Act: Data = %0*b, Direction = %s", cfg.data_width, exp.data & mask, exp.direction.name(), cfg.data_width, act.data & mask, act.direction.name()));
				end
				$display("============================================================================================================================");
			end
		end
	endfunction: write_mnt_rhs
	
	function void clear();
		q_lhs_tx.delete();
		q_rhs_tx.delete();
		`uvm_info("clear", "Resetting...", UVM_LOW);
	endfunction: clear

endclass: uart_scoreboard
