
package uart_pkg;

	class uart_trans;
		rand bit[7:0] div_factor;
        bit busy;
		constraint cstr {
			soft div_factor inside {[1:255]};
		};
    
		function uart_trans clone();
			uart_trans d = new();
			d.div_factor = this.div_factor;
			return d;
		endfunction
    
		function string sprint();
			string s;
			s = {s, $sformatf("=======================================\n")};
			s = {s, $sformatf("uart_trans object content is as below: \n")};
			s = {s, $sformatf("div_factor = %d: \n", this.div_factor)};
			s = {s, $sformatf("uart_busy = %d: \n", this.busy)};
			s = {s, $sformatf("=======================================\n")};
			return s;
		endfunction

	endclass:uart_trans

	class uart_driver;
		local string name;
		local virtual uart_intf intf;
		mailbox #(uart_trans) req_mb;
		mailbox #(uart_trans) rsp_mb;

		function new(string name = "uart_driver");
			this.name = name;
		endfunction

		function void set_interface(virtual uart_intf intf);
			if(intf == null)
				$error("interface handle is NULL, please check if target interface has been intantiated");
			else
				this.intf = intf;
		endfunction

		task run();
			fork
				this.do_drive();
				this.do_reset();
			join
		endtask

		task do_reset();
            intf.uart_txd <= 1;
			forever begin
				@(negedge intf.rstn);
				intf.uart_txd <= 1;
			end
		endtask

		task do_drive();
			uart_trans req, rsp;
			@(posedge intf.rstn);
			forever begin
				this.req_mb.get(req);
				this.uart_send(req);
				rsp = req.clone();
				rsp.busy = 0;
				this.rsp_mb.put(rsp);
			end
		endtask

		task uart_send(input uart_trans t);
			bit [2:0] cnt [8];
			repeat(434)	@(posedge intf.clk)begin
				intf.uart_txd <= 0;
			end
			foreach(cnt[i])begin
				repeat(434) @(posedge intf.clk)begin
					intf.uart_txd <= t.div_factor[i];
				end
			end
			repeat(434)	@(posedge intf.clk)begin
				intf.uart_txd <= 1;
			end		  
		endtask
	endclass:uart_driver

	class uart_generator;
		rand bit[7:0] div_factor = 0;
        
		mailbox #(uart_trans) req_mb;
		mailbox #(uart_trans) rsp_mb;

		constraint cstr{
			soft div_factor > 0;//== 1;
		}

		function new();
			this.req_mb = new();
			this.rsp_mb = new();
		endfunction


		task start();
			send_trans();
		endtask

		task send_trans();
			uart_trans req, rsp;
			req = new();
            req.busy = 1;
			assert(req.randomize with {local::div_factor > 0 -> div_factor == local::div_factor; 
								   })
				else $fatal("[RNDFAIL] uart packet randomization failure!");
			$display(req.sprint());
			this.req_mb.put(req);
			this.rsp_mb.get(rsp);
			$display(rsp.sprint());
			assert(!rsp.busy)
				else $error("[RSPERR] %0t error response received!", $time);
		endtask

		function string sprint();
			string s;
			s = {s, $sformatf("=======================================\n")};
			s = {s, $sformatf("uart_generator object content is as below: \n")};
			s = {s, $sformatf("div_factor = %0d: \n", this.div_factor)};
			s = {s, $sformatf("=======================================\n")};
			return s;
		endfunction

		function void post_randomize();
			string s;
			s = {"AFTER RANDOMIZATION \n", this.sprint()};
			$display(s);
		endfunction

	endclass
	
	typedef struct packed {
		bit[7:0] tx_data;
	} mon_data_t;
  
	class uart_monitor;
		local string name;
		local virtual uart_intf intf;
		mailbox #(mon_data_t) mon_mb;
		function new(string name="chnl_monitor");
			this.name = name;
		endfunction
		function void set_interface(virtual uart_intf intf);
			if(intf == null)
				$error("interface handle is NULL, please check if target interface has been intantiated");
			else
				this.intf = intf;
		endfunction
		task run();
		  this.mon_trans();
		endtask

		task mon_trans();
          bit [2:0] cnt [8];
		  mon_data_t m;
		  forever begin
            @(posedge intf.mon_ck.uart_txd)
            repeat(300)	@(posedge intf.clk);
            foreach(cnt[i])begin
				repeat(434) @(posedge intf.clk);
                m.tx_data >>= 1;
                if(intf.mon_ck.uart_txd)
                    m.tx_data |= 8'h80;
			end
            repeat(434)	@(posedge intf.clk);
			mon_mb.put(m);
			$display("%0t %s monitored channle data %8x", $time, this.name, m.tx_data);
		  end
		endtask
	endclass
	
	class uart_agent;
		local string name;
		uart_driver driver;
		uart_monitor monitor;
		local virtual uart_intf vif;
		function new(string name = "uart_agent");
			this.name = name;
			this.driver = new({name, ".uart_driver"});
			this.monitor = new({name, ".monitor"});
		endfunction

		function void set_interface(virtual uart_intf vif);
		  this.vif = vif;
		  driver.set_interface(vif);
		  monitor.set_interface(vif);
		endfunction
        
		task run();
		  fork
			driver.run();
			monitor.run();
		  join_any
		endtask
	endclass:uart_agent
endpackage
