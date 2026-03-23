class router_output_monitor extends uvm_monitor;
  `uvm_component_utils (router_output_monitor)
  
  virtual router_if #(.D_WIDTH(8)) vif;

  uvm_analysis_port #(router_seq_item #()) ap_mon;
  
  router_seq_item #() data_obj;

  
  function new (string name = "router_output_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);

    ap_mon = new ("ap_mon", this);

    if (!uvm_config_db #(virtual router_if #(.D_WIDTH(8)))::get(this, "", "vif", vif)) begin
      `uvm_error (get_type_name (), "DUT interface not found")
    end

  endfunction


  virtual task run_phase (uvm_phase phase);

    forever begin
      
      @ (posedge vif.clk);
        //if (vif.m_tvalid[0] && vif.m_tready[0] && vif.m_tlast[0]) begin
        if (vif.m_tvalid[0] && vif.m_tready[0]) begin

            data_obj = router_seq_item#()::type_id::create("data_obj", this);

            data_obj.port_id = 0; 
            data_obj.m_tdata_0 = vif.m_tdata_0;
            data_obj.m_tvalid  = vif.m_tvalid;
            data_obj.m_tlast   = vif.m_tlast;

            ap_mon.write(data_obj); // valid transfer인 경우만 scoreboard에게 넘겨줌
        end

        //if (vif.m_tvalid[1] && vif.m_tready[1] && vif.m_tlast[1]) begin
        if (vif.m_tvalid[1] && vif.m_tready[1]) begin

            data_obj = router_seq_item#()::type_id::create("data_obj", this);

            data_obj.port_id = 1; 
            data_obj.m_tdata_1 = vif.m_tdata_1;
            data_obj.m_tvalid  = vif.m_tvalid;
            data_obj.m_tlast   = vif.m_tlast;

            ap_mon.write(data_obj); // valid transfer인 경우만 scoreboard에게 넘겨줌
        end

    
        end

    
    
  endtask

  


  
endclass
