class uart_driver extends uvm_driver #(uart_transaction);
	`uvm_component_utils(uart_driver)

	uart_configuration cfg;
	virtual uart_if uart_vif;
	int cnt_HIGH;
	uart_transaction trans;
	time baud_period;
	uvm_analysis_port #(uart_transaction) item_observed_port;

	function new(string name = "uart_driver", uvm_component parent);
		super.new(name, parent);
		item_observed_port = new("item_observed_port", this);
	endfunction: new
		
	virtual function void build_phase(uvm_phase phase);
		`uvm_info("build_phase", "Entered...", UVM_LOW)
		super.build_phase(phase);
		if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", uart_vif)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_if from uvm_config_db"));	
		end
		if (!uvm_config_db#(uart_configuration)::get(this, "", "cfg", cfg)) begin
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_configuration from uvm_config_db"));	
		end
		`uvm_info("build_phase", "Exiting...", UVM_LOW)
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		`uvm_info("run_phase", "Entered...", UVM_LOW)
		// IDLE
		uart_vif.tx = 1'b1;
		forever begin
			seq_item_port.get_next_item(req);
			item_observed_port.write(req);
			if (req.direction == uart_transaction::TX) begin
				drive();
			end
			seq_item_port.item_done();
		end
		`uvm_info("run_phase", "Exiting...", UVM_LOW)
	endtask: run_phase

	virtual task drive();
		// SETUP
		cnt_HIGH = 0;
		baud_period = (1000000000 / cfg.baud_rate) * 1ns;
		
		// START
		uart_vif.tx = 1'b0;
		#baud_period;
		// DATA
		for(int i = 0; i < cfg.data_width; i = i + 1) begin
			uart_vif.tx = req.data[i];
			if (req.data[i]) begin
				cnt_HIGH = cnt_HIGH + 1;
			end
//			$display("%t: [uart_driver] i = %0d, uart_vif.tx = %0b", $time, i, uart_vif.tx);
			#baud_period;
		end
		// PARITY
		`uvm_info(get_type_name(), $sformatf("%0d", cnt_HIGH), UVM_LOW);
		case (cfg.parity_mode)
			uart_configuration::ODD: begin
				if (cnt_HIGH % 2 == 0) begin
					uart_vif.tx = 1'b1;
				end else begin
					uart_vif.tx = 1'b0;
				end
			end
			uart_configuration::EVEN: begin
				if (cnt_HIGH % 2 == 0) begin
					uart_vif.tx = 1'b0;
				end else begin
					uart_vif.tx = 1'b1;
				end
			end
			default: begin
			end
		endcase	
		if (cfg.parity_mode != uart_configuration::NONE) begin
			if (cfg.parity_error == uart_configuration::ERROR) begin
				$display("------------------------> uart_vif.tx = %1b", uart_vif.tx);
				uart_vif.tx = ~uart_vif.tx;
				$display("------------------------> uart_vif.tx = %1b", uart_vif.tx);
			end
			#baud_period;
		end
		// STOP
		for(int i = 0; i < cfg.num_of_stop_bit; i = i + 1) begin 
			uart_vif.tx = 1'b1;
			#baud_period;
		end
	endtask: drive
	
endclass: uart_driver
