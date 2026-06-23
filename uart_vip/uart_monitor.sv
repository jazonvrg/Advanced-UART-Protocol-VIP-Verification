class uart_monitor extends uvm_monitor;
	`uvm_component_utils(uart_monitor)

	virtual uart_if uart_vif;
	uart_configuration cfg;
	time baud_period;
	uart_transaction tx, rx;
	uvm_analysis_port #(uart_transaction) item_observed_port;
	int cnt_HIGH_tx, cnt_HIGH_rx;
	logic act, exp;

	function new(string name = "uart_monitor", uvm_component parent);
		super.new(name, parent);
		item_observed_port = new("item_observed_port", this);
	endfunction: new

	function void build_phase(uvm_phase phase);
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
		fork
			forever begin
				thread_tx();
			end
			forever begin
				thread_rx();
			end
		join
		`uvm_info("run_phase", "Exiting...", UVM_LOW)
	endtask: run_phase

	virtual task thread_tx();
		// SETUP
		tx = uart_transaction::type_id::create("tx");
		cnt_HIGH_tx = 0;
		// START
		@(negedge uart_vif.tx);
		baud_period = (1000000000 / cfg.baud_rate) * 1ns;
		#(baud_period / 2 + baud_period);
		// DATA	
		for(int i = 0; i < cfg.data_width; i = i + 1) begin
			tx.data[i] = uart_vif.tx;
			if (uart_vif.tx) begin
				cnt_HIGH_tx = cnt_HIGH_tx + 1;
			end
//			$display("%t: [thread_tx] i = %0d, uart_vif.tx = %0b", $time, i, uart_vif.tx);
			#baud_period;
		end
		// PARITY
		`uvm_info(get_type_name(), $sformatf("%0d", cnt_HIGH_tx), UVM_LOW);
		case (cfg.parity_mode)
			uart_configuration::ODD: begin
				if (cnt_HIGH_tx % 2 == 0) begin
					exp = 1'b1;
				end else begin
					exp = 1'b0;
				end
			end
			uart_configuration::EVEN: begin
				if (cnt_HIGH_tx % 2 == 0) begin
					exp = 1'b0;
				end else begin
					exp = 1'b1;
				end
			end
			default: begin
			end
		endcase	
		if (cfg.parity_mode != uart_configuration::NONE) begin
			act = uart_vif.tx;
			$display("");
			`uvm_info("thread_tx", $sformatf("PARITY COMPARATIVE"), UVM_LOW)
			$display("============================================================================================================================");
			if (cfg.parity_error == uart_configuration::ERROR) begin
				if (act != exp) begin
					`uvm_info("thread_tx", $sformatf("PASSED! Parity is not matching. Exp: %0b, Act: %0b", exp, act), UVM_LOW);
				end else begin
					`uvm_error("thread_tx", $sformatf("FAILED! Parity is matching. Exp: %0b, Act: %0b", exp, act));
				end
//				`uvm_info("thread_tx ERROR", $sformatf("%s", cfg.parity_error.name()), UVM_LOW); 
			end else begin
				if (act == exp) begin
					`uvm_info("thread_tx", $sformatf("PASSED! Parity is matching. Exp: %0b, Act: %0b", exp, act), UVM_LOW);
				end else begin
					`uvm_error("thread_tx", $sformatf("FAILED! Parity is not matching. Exp: %0b, Act: %0b", exp, act));
				end
//				`uvm_info("thread_tx NORMAL", $sformatf("%s", cfg.parity_error.name()), UVM_LOW); 
			end
			$display("============================================================================================================================");
			#baud_period;
		end
		// STOP
		for(int i = 0; i < cfg.num_of_stop_bit; i = i + 1) begin 
			#baud_period;
		end
		tx.direction = uart_transaction::TX;
		item_observed_port.write(tx);
	endtask: thread_tx
	
	virtual task thread_rx();
		// SETUP
		rx = uart_transaction::type_id::create("rx");
		cnt_HIGH_rx = 0;
		// START
		@(negedge uart_vif.rx);
		baud_period = (1000000000 / cfg.baud_rate) * 1ns;
		#(baud_period / 2 + baud_period);
		// DATA	
		for(int i = 0; i < cfg.data_width; i = i + 1) begin
			rx.data[i] = uart_vif.rx;
			if (uart_vif.rx) begin
				cnt_HIGH_rx = cnt_HIGH_rx + 1;
			end
//			$display("%t: [thread_rx] i = %0d, uart_vif.tx = %0b", $time, i, uart_vif.tx);
			#baud_period;
		end
		// PARITY
		`uvm_info(get_type_name(), $sformatf("%0d", cnt_HIGH_rx), UVM_LOW);
		case (cfg.parity_mode)
			uart_configuration::ODD: begin
				if (cnt_HIGH_rx % 2 == 0) begin
					exp = 1'b1;
				end else begin
					exp = 1'b0;
				end
			end
			uart_configuration::EVEN: begin
				if (cnt_HIGH_rx % 2 == 0) begin
					exp = 1'b0;
				end else begin
					exp = 1'b1;
				end
			end
			default: begin
			end
		endcase	
		if (cfg.parity_mode != uart_configuration::NONE) begin
			act = uart_vif.rx;
			$display("");
			`uvm_info("thread_rx", $sformatf("PARITY COMPARATIVE"), UVM_LOW)
			$display("============================================================================================================================");
			if (cfg.parity_error == uart_configuration::ERROR) begin
				if (act != exp) begin
					`uvm_info("thread_rx", $sformatf("PASSED! Parity is not matching. Exp: %0b, Act: %0b", exp, act), UVM_LOW);
				end else begin
					`uvm_error("thread_rx", $sformatf("FAILED! Parity is matching. Exp: %0b, Act: %0b", exp, act));
				end
//				`uvm_info("thread_rx ERROR", $sformatf("%s", cfg.parity_error.name()), UVM_LOW); 
			end else begin
				if (act == exp) begin
					`uvm_info("thread_rx", $sformatf("PASSED! Parity is matching. Exp: %0b, Act: %0b", exp, act), UVM_LOW);
				end else begin
					`uvm_error("thread_rx", $sformatf("FAILED! Parity is not matching. Exp: %0b, Act: %0b", exp, act));
				end
//				`uvm_info("thread_rx NORMAL", $sformatf("%s", cfg.parity_error.name()), UVM_LOW); 
			end
			$display("============================================================================================================================");
			#baud_period;
		end
		// STOP
		for(int i = 0; i < cfg.num_of_stop_bit; i = i + 1) begin 
			#baud_period;
		end
		rx.direction = uart_transaction::RX;
		item_observed_port.write(rx);
	endtask: thread_rx

endclass: uart_monitor
