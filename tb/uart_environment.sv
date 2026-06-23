class uart_environment extends uvm_env;
	`uvm_component_utils(uart_environment)

	virtual uart_if uart_vif_lhs, uart_vif_rhs;
	uart_configuration cfg_lhs, cfg_rhs;
	uart_agent agt_lhs, agt_rhs;
	uart_scoreboard scb;

	function new(string name = "uart_environment", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("build phase", "Entered...", UVM_HIGH)
		if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif_lhs", uart_vif_lhs)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_vif_lhs from uvm_config_db"))
		end
		if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif_rhs", uart_vif_rhs)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_vif_rhs from uvm_config_db"))
		end
		if (!uvm_config_db#(uart_configuration)::get(this, "", "cfg_lhs", cfg_lhs)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get cfg_lhs from uvm_config_db"))
		end
		if (!uvm_config_db#(uart_configuration)::get(this, "", "cfg_rhs", cfg_rhs)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get cfg_rhs from uvm_config_db"))
		end
		agt_lhs = uart_agent::type_id::create("agt_lhs", this);
		agt_rhs = uart_agent::type_id::create("agt_rhs", this);
		scb = uart_scoreboard::type_id::create("scb", this);
		uvm_config_db#(virtual uart_if)::set(this, "agt_lhs", "uart_vif", uart_vif_lhs);
		uvm_config_db#(virtual uart_if)::set(this, "agt_rhs", "uart_vif", uart_vif_rhs);
		uvm_config_db#(uart_configuration)::set(this, "agt_lhs", "cfg", cfg_lhs);
		uvm_config_db#(uart_configuration)::set(this, "agt_rhs", "cfg", cfg_rhs);
		uvm_config_db#(uart_configuration)::set(this, "scb", "cfg", cfg_rhs);
		`uvm_info("build_phase", "Exiting...", UVM_HIGH)
	endfunction: build_phase

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		// LHS
		agt_lhs.drv.item_observed_port.connect(scb.uart_drv_lhs_export);
		agt_lhs.mnt.item_observed_port.connect(scb.uart_mnt_lhs_export);
		// RHS	
		agt_rhs.drv.item_observed_port.connect(scb.uart_drv_rhs_export);
		agt_rhs.mnt.item_observed_port.connect(scb.uart_mnt_rhs_export);
	endfunction: connect_phase

endclass: uart_environment
