class router_driver extends uvm_driver #(router_seq_item #());
  
  `uvm_component_utils (router_driver)
  
  function new (string name = "router_driver", uvm_component parent = null);
    super.new (name, parent);
  endfunction
  
  virtual router_if #(.D_WIDTH(8)) vif;
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
      if (!uvm_config_db #(virtual router_if #(.D_WIDTH(8)))::get(this, "", "vif", vif)) begin
      
      `uvm_error(get_type_name(), "DUT interface not found")
    end
  endfunction
  

  virtual task run_phase (uvm_phase phase);
    
    router_seq_item item;
    
    @(posedge vif.clk);
    while (!vif.rst_n) @(posedge vif.clk);
    
    forever begin
      seq_item_port.get_next_item (item);
      
      for(int i=0; i<item.data.size(); i++) begin


        // @(posedge clk) 먼저, 그 다음 tready 체크
        @(posedge vif.clk);
        while (!vif.s_tready[item.port_id]) begin
            @(posedge vif.clk);  // tready=0이면 다음 클럭 기다리기
        end

          case(item.port_id)

            2'd0 : begin
              vif.s_tdata_0 <= item.data[i];
              vif.s_tvalid[0] <= 1;
              vif.s_tdest[0] <= item.tdest;
              vif.s_tlast[0] <= (i == item.data.size()-1) ? 1 : 0;
            end 

            2'd1 : begin
              vif.s_tdata_1 <= item.data[i];
              vif.s_tvalid[1] <= 1;
              vif.s_tdest[1] <= item.tdest;
              vif.s_tlast[1] <= (i == item.data.size()-1) ? 1 : 0;
            end 

            2'd2 : begin
              vif.s_tdata_2 <= item.data[i];
              vif.s_tvalid[2] <= 1;
              vif.s_tdest[2] <= item.tdest;
              vif.s_tlast[2] <= (i == item.data.size()-1) ? 1 : 0;
            end 

            2'd3 : begin
              vif.s_tdata_3 <= item.data[i];
              vif.s_tvalid[3] <= 1;
              vif.s_tdest[3] <= item.tdest;
              vif.s_tlast[3] <= (i == item.data.size()-1) ? 1 : 0;
            end           
          endcase 
        end
        
        // for loop 끝난 후
        @(posedge vif.clk);
        case(item.port_id)
            2'd0: vif.s_tvalid[0] <= 0;
            2'd1: vif.s_tvalid[1] <= 0;
            2'd2: vif.s_tvalid[2] <= 0;
            2'd3: vif.s_tvalid[3] <= 0;
        endcase
      
      seq_item_port.item_done();
    end
    
  endtask
  
endclass
