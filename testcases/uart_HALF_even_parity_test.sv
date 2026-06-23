class uart_HALF_even_parity_test extends uart_base_test;
	`uvm_component_utils(uart_HALF_even_parity_test)

	uart_sequence lhs_seq, rhs_seq;
	time baud_period;
	int prt_mode[] = '{2'b00, 2'b01, 2'b10};
	int dt_width[] = '{5, 6, 7, 8, 9};
	int stp_bit[] = '{1, 2};
	int bd_rate[] = '{4800, 9600, 19200, 57600, 115200};
	int prt_error[] = '{1'b0, 1'b1};

	function new(string name = "uart_HALF_even_parity_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		lhs_seq = uart_sequence::type_id::create("lhs_seq");
		rhs_seq = uart_sequence::type_id::create("rhs_seq");
		foreach(dt_width[i_dt]) begin
			foreach(stp_bit[i_stp]) begin
				foreach(bd_rate[i_bd]) begin
					foreach(prt_error[i_error]) begin
						$display("============================================================================================================================");
						$display("===============================================  ### LHS = TX, RHS = RX ###  ===============================================");
						$display("============================================================================================================================");
						lhs_seq.seq_dir = uart_transaction::TX;
						rhs_seq.seq_dir = uart_transaction::RX;
						if (cfg_lhs.randomize() with {parity_mode == EVEN; 
			 			                              data_width == dt_width[i_dt];
						                              num_of_stop_bit == stp_bit[i_stp];
						                              baud_rate == bd_rate[i_bd];
						                              parity_error == prt_error[i_error];
						                              uart_mode == HALF;}) begin
							`uvm_info("run_phase", $sformatf("Configuration randomize is: \n%0s", cfg_lhs.sprint()), UVM_LOW);
						end else begin
							`uvm_fatal("run_phase", $sformatf("Randomize failure!"));
						end 
						setup(cfg_lhs);
						lhs_seq.start(env.agt_lhs.seq);
						baud_period = (1000000000 / cfg_lhs.baud_rate) * 1ns;
						#(baud_period * 2);
						
						$display("============================================================================================================================");
						$display("===============================================  ### LHS = RX, RHS = TX ###  ===============================================");
						$display("============================================================================================================================");
						lhs_seq.seq_dir = uart_transaction::RX;
						rhs_seq.seq_dir = uart_transaction::TX;
						if (cfg_lhs.randomize() with {parity_mode == EVEN; 
			 			                              data_width == dt_width[i_dt];
						                              num_of_stop_bit == stp_bit[i_stp];
						                              baud_rate == bd_rate[i_bd];
						                              parity_error == prt_error[i_error];
						                              uart_mode == HALF;}) begin
							`uvm_info("run_phase", $sformatf("Configuration randomize is: \n%0s", cfg_lhs.sprint()), UVM_LOW);
						end else begin
							`uvm_fatal("run_phase", $sformatf("Randomize failure!"));
						end 
						setup(cfg_lhs);
						rhs_seq.start(env.agt_rhs.seq);
						baud_period = (1000000000 / cfg_lhs.baud_rate) * 1ns;
						#(baud_period * 2);
					end
				end
			end
		end
		phase.drop_objection(this);
	endtask: run_phase	

	virtual function void setup(uart_configuration cfg_lhs);
		cfg_rhs.parity_mode = cfg_lhs.parity_mode;
		cfg_rhs.data_width = cfg_lhs.data_width;
		cfg_rhs.num_of_stop_bit = cfg_lhs.num_of_stop_bit;
		cfg_rhs.baud_rate = cfg_lhs.baud_rate;
		cfg_rhs.parity_error = cfg_lhs.parity_error;
		cfg_rhs.uart_mode = cfg_lhs.uart_mode;
	endfunction: setup

endclass: uart_HALF_even_parity_test
