class uart_base_test extends uvm_test;
	`uvm_component_utils(uart_base_test)

	virtual uart_if uart_vif_lhs, uart_vif_rhs;
	uart_configuration cfg_lhs, cfg_rhs;
	uart_environment env;
	uart_error_catcher err_catcher;

	function new(string name = "uart_base_test", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("build_phase", "Entered...", UVM_HIGH)
		if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif_lhs", uart_vif_lhs)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_vif_lhs from uvm_config_db"))
		end
		if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif_rhs", uart_vif_rhs)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_vif_rhs from uvm_config_db"))
		end
		env = uart_environment::type_id::create("env", this);
		cfg_lhs = uart_configuration::type_id::create("cfg_lhs");
		cfg_rhs = uart_configuration::type_id::create("cfg_rhs");
		err_catcher = uart_error_catcher::type_id::create("err_catcher");
		uvm_report_cb::add(null, err_catcher);
		uvm_config_db#(virtual uart_if)::set(this, "env", "uart_vif_lhs", uart_vif_lhs);
		uvm_config_db#(virtual uart_if)::set(this, "env", "uart_vif_rhs", uart_vif_rhs);
		uvm_config_db#(uart_configuration)::set(this, "env", "cfg_lhs", cfg_lhs);
		uvm_config_db#(uart_configuration)::set(this, "env", "cfg_rhs", cfg_rhs);
		`uvm_info("build_phase", "Exiting...", UVM_HIGH)
	endfunction: build_phase

	virtual function void start_of_simulation_phase(uvm_phase phase);
		`uvm_info("start_of_simulation_phase", "Entered...", UVM_HIGH)
		uvm_top.print_topology();
		`uvm_info("start_of_simulation_phase", "Exiting...", UVM_HIGH)
	endfunction: start_of_simulation_phase

	virtual function void final_phase(uvm_phase phase);
		uvm_report_server svr;
		super.final_phase(phase);
		`uvm_info("final_phase", "Entered...", UVM_HIGH)
		svr = uvm_report_server::get_server();
		if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) > 0) begin
			$display("\n=====================================================");
			$display("            #### Status: TEST FAILED ####              ");
			$display("\n=====================================================");
		end else begin
			$display("\n=====================================================");
			$display("            #### Status: TEST PASSED ####              ");
			$display("\n=====================================================");
		end
		`uvm_info("final_phase", "Exiting...", UVM_HIGH)
	endfunction: final_phase

endclass: uart_base_test
