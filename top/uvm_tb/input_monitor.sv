class router_input_monitor extends uvm_monitor;
  `uvm_component_utils (router_input_monitor)
  
  virtual router_if #(.D_WIDTH(8)) vif;

  uvm_analysis_port #(router_seq_item #()) ap_mon;
  
  router_seq_item #() data_obj;

  
  function new (string name = "router_input_monitor", uvm_component parent = null);
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

        //port 0
        if (vif.s_tvalid[0] && vif.s_tready[0] && vif.s_tlast[0]) begin

            data_obj = router_seq_item#()::type_id::create("data_obj", this);

            data_obj.port_id = 0; 
            data_obj.s_tdata_0 = vif.s_tdata_0;
            data_obj.s_tvalid[0] = vif.s_tvalid[0];
            data_obj.s_tlast[0] = vif.s_tlast[0];
            data_obj.s_tdest[0] = vif.s_tdest[0];

            ap_mon.write(data_obj); // valid transfer인 경우만 scoreboard에게 넘겨줌
        end

        //port 1
        if (vif.s_tvalid[1] && vif.s_tready[1] && vif.s_tlast[1]) begin

            data_obj = router_seq_item#()::type_id::create("data_obj", this);

            data_obj.port_id = 1; 
            data_obj.s_tdata_1 = vif.s_tdata_1;
            data_obj.s_tvalid[1] = vif.s_tvalid[1];
            data_obj.s_tlast[1] = vif.s_tlast[1];
            data_obj.s_tdest[1] = vif.s_tdest[1];

            ap_mon.write(data_obj); // valid transfer인 경우만 scoreboard에게 넘겨줌
        end

        //port 2
        if (vif.s_tvalid[2] && vif.s_tready[2] && vif.s_tlast[2]) begin

            data_obj = router_seq_item#()::type_id::create("data_obj", this);

            data_obj.port_id = 2; 
            data_obj.s_tdata_2 = vif.s_tdata_2;
            data_obj.s_tvalid[2] = vif.s_tvalid[2];
            data_obj.s_tlast[2] = vif.s_tlast[2];
            data_obj.s_tdest[2] = vif.s_tdest[2];

            ap_mon.write(data_obj); // valid transfer인 경우만 scoreboard에게 넘겨줌
        end

        //port 3
        if (vif.s_tvalid[3] && vif.s_tready[3] && vif.s_tlast[3]) begin

            data_obj = router_seq_item#()::type_id::create("data_obj", this);

            data_obj.port_id = 3; 
            data_obj.s_tdata_3 = vif.s_tdata_3;
            data_obj.s_tvalid[3] = vif.s_tvalid[3];
            data_obj.s_tlast[3] = vif.s_tlast[3];
            data_obj.s_tdest[3] = vif.s_tdest[3];

            ap_mon.write(data_obj); // valid transfer인 경우만 scoreboard에게 넘겨줌
        end        
    
        end

    
    
  endtask

  


  
endclass
