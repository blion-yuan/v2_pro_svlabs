
package div_pkg;
  import rpt_pkg::*;

  typedef struct packed {
    bit[7:0] data;
    bit valid;
  } mon_data_t;
  
  class div_monitor;
    local string name;
    local virtual div_intf intf;
    mailbox #(mon_data_t) mon_mb;
  
    function new(string name="div_monitor");
      this.name = name;
    endfunction
    
    function void set_interface(virtual div_intf intf);
      if(intf == null)
        $error("interface handle is NULL, please check if target interface has been intantiated");
      else
        this.intf = intf;
    endfunction
  
    task run();
      this.mon_trans();
    endtask
  
    task mon_trans();
      mon_data_t m;
      bit [8:0] cnt = 0;
      string s;
      
      forever begin
        @(negedge intf.intf.mon_ck.div_en);//wait(intf.mon_ck.div_en);
        m.valid = 0;
        foreach begin
          @(posedge intf.clk);
          cnt++;
          if(cnt >= 256)begin
            break;
          end
          
          if(intf.mon_ck.div_clk == 'b0)begin
            m.valid = 1;break;
          end
            
        end
        m.data = (cnt << 1);
        mon_mb.put(m);
      end
    endtask
  endclass

  class div_agent;
    local string name;
    div_monitor monitor;
    local virtual div_intf vif;
    
    function new(string name = "fmt_agent");
      this.name = name;
      this.monitor = new({name, ".monitor"});
    endfunction

    function void set_interface(virtual div_intf vif);
      this.vif = vif;
      monitor.set_interface(vif);
    endfunction
    
    task run();
      fork
        monitor.run();
      join
    endtask
  endclass

endpackage
