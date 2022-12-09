
package uart_pkg;

  class uart_trans;
    randc bit[7:0] div_factor;
    rand bit[9:0] div_node;
    
    constraint cstr {
      soft div_factor inside {[1:255]};
      soft div_node inside {[div_factor *2 : div_factor * 3]};
    };
    
    function uart_trans clone();
      uart_trans d = new();
      d.div_factor = this.div_factor;
      d.div_node = this.div_node;
      return d;
    endfunction
    
    function string sprint();
      string s;
      s = {s, $sformatf("=======================================\n")};
      s = {s, $sformatf("uart_trans object content is as below: \n")};
      s = {s, $sformatf("div_data = %2x: \n", this.div_data)};
      s = {s, $sformatf("div_node = %2x: \n", this.div_node)};
      s = {s, $sformatf("=======================================\n")};
      return s;
    endfunction
      
  endclass

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
      forever begin
        @(negedge intf.rstn);
        intf.txd <= 1;
      end
    endtask
    
    task do_drive();
      uart_trans req, rsp;
      @(posedge intf.rstn);
      forever begin
        this.req_mb.get(req);
        this.uart_send(req);
        rsp = req.clone();
        rsp.rsp = 1;
        this.rsp_mb.put(rsp);
      end
    endtask
    
    task uart_send(input uart_trans t);
      
    endtask
    
    
  endclass

  class uart_generator;
    randc bit[7:0] div_factor = -1;
	rand bit[9:0] div_node = -1;
    
    mailbox #(uart_trans) req_mb;
    mailbox #(uart_trans) rsp_mb;
    
    constraint cstr{
      soft div_factor == -1;
      soft div_node == 0;
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
      assert(req.randomize with {local::div_factor >= 0 -> div_factor == local::div_factor; 
                                 local::div_node >= 0 -> div_node == local::div_node;
                               })
        else $fatal("[RNDFAIL] uart packet randomization failure!");
      $display(req.sprint());
      this.req_mb.put(req);
      this.rsp_mb.get(rsp);
      $display(rsp.sprint());
      assert(rsp.rsp)
        else $error("[RSPERR] %0t error response received!", $time);
    endtask
    
    function string sprint();
      string s;
      s = {s, $sformatf("=======================================\n")};
      s = {s, $sformatf("uart_generator object content is as below: \n")};
      s = {s, $sformatf("div_factor = %0d: \n", this.div_factor)};
      s = {s, $sformatf("div_node = %0d: \n", this.div_node)};
      s = {s, $sformatf("=======================================\n")};
      return s;
    endfunction
    
    function void post_randomize();
      string s;
      s = {"AFTER RANDOMIZATION \n", this.sprint()};
      $display(s);
    endfunction
	
  endclass

  class uart_monitor;
    // ... ignored
  endclass

  class uart_agent;
    // ... ignored
  endclass
endpackage
