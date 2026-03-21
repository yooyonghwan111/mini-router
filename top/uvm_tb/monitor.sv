class fifo_monitor extends uvm_monitor;
  `uvm_component_utils (fifo_monitor)
  
  //virtual sync_fifo_if vif;
  virtual sync_fifo_if #(.D_WIDTH(8)) vif;
  bit                  enable_check = 1;

  uvm_analysis_port #(fifo_seq_item #()) ap_mon;
  
  fifo_seq_item #() data_obj;

  
  function new (string name = "fifo_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
    ap_mon = new ("ap_mon", this);
    data_obj = fifo_seq_item#()::type_id::create("data_obj", this);

    if (!uvm_config_db #(virtual sync_fifo_if #(.D_WIDTH(8)))::get(this, "", "vif", vif)) begin

      `uvm_error (get_type_name (), "DUT interface not found")
    end

  endfunction

  virtual task run_phase (uvm_phase phase);

//    data_obj = fifo_seq_item#()::type_id::create("data_obj", this);

    forever begin
      @ (posedge vif.clk);
      data_obj.wr_en = vif.wr_en;
      data_obj.rd_en = vif.rd_en;
      data_obj.din = vif.din;
      data_obj.dout = vif.dout;
      data_obj.empty = vif.empty;
      data_obj.full = vif.full;

      if (enable_check)
        check_protocol();

      ap_mon.write (data_obj);
      
    end
    
  endtask

  
  virtual function void check_protocol ();
    
    if (data_obj.full && data_obj.wr_en) begin
      `uvm_error (get_type_name (), "sync fifo protocol error")
    end

    if (data_obj.empty && data_obj.rd_en) begin
      `uvm_error (get_type_name (), "sync fifo protocol error")
    end

  endfunction


  
endclass
