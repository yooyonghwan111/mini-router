class fifo_driver extends uvm_driver #(fifo_seq_item);
  
  `uvm_component_utils (fifo_driver)
  
  function new (string name = "fifo_driver", uvm_component parent = null);
    super.new (name, parent);
  endfunction
  
  virtual sync_fifo_if #(.D_WIDTH(8)) vif;
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
      if (!uvm_config_db #(virtual sync_fifo_if #(.D_WIDTH(8)))::get(this, "", "vif", vif)) begin
      
      `uvm_error(get_type_name(), "DUT interface not found")
    end
  endfunction
  
  virtual task run_phase (uvm_phase phase);
    
    fifo_seq_item item;
    
    
    forever begin
      seq_item_port.get_next_item (item);
      
      @(posedge vif.clk);
      vif.wr_en <= item.wr_en; 
      vif.rd_en <= item.rd_en; 
      vif.din <= item.din; 
      
      seq_item_port.item_done();
    end
    
  endtask
  
endclass
