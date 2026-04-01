class router_input_monitor extends uvm_monitor;
    `uvm_component_utils(router_input_monitor)

    virtual router_if #(.D_WIDTH(8)) vif;
    uvm_analysis_port #(router_seq_item #()) ap_mon;
    router_seq_item #() data_obj;

    function new(string name = "router_input_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_mon = new("ap_mon", this);
        if (!uvm_config_db #(virtual router_if #(.D_WIDTH(8)))::get(this, "", "vif", vif))
            `uvm_error(get_type_name(), "DUT interface not found")
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.clk);

            // port 0 - [변경] 개별 신호 참조 + [추가] tid 샘플링
            if (vif.s_tvalid_0 && vif.s_tready_0) begin

                data_obj = router_seq_item#()::type_id::create("data_obj", this);
                data_obj.port_id  = 0;
                data_obj.s_tdata_0 = vif.s_tdata_0;
                data_obj.s_tid_0   = vif.s_tid_0;    
                data_obj.s_tdest_0 = vif.s_tdest_0;  
                data_obj.s_tlast_0 = vif.s_tlast_0;  
                data_obj.s_tvalid_0= vif.s_tvalid_0; 
                ap_mon.write(data_obj);
            end

            // port 1
            if (vif.s_tvalid_1 && vif.s_tready_1) begin

                data_obj = router_seq_item#()::type_id::create("data_obj", this);
                data_obj.port_id  = 1;
                data_obj.s_tdata_1 = vif.s_tdata_1;
                data_obj.s_tid_1   = vif.s_tid_1;    
                data_obj.s_tdest_1 = vif.s_tdest_1;  
                data_obj.s_tlast_1 = vif.s_tlast_1;  
                data_obj.s_tvalid_1= vif.s_tvalid_1; 
                ap_mon.write(data_obj);
            end

            // port 2
            if (vif.s_tvalid_2 && vif.s_tready_2) begin

                data_obj = router_seq_item#()::type_id::create("data_obj", this);
                data_obj.port_id  = 2;
                data_obj.s_tdata_2 = vif.s_tdata_2;
                data_obj.s_tid_2   = vif.s_tid_2;    
                data_obj.s_tdest_2 = vif.s_tdest_2;  
                data_obj.s_tlast_2 = vif.s_tlast_2;  
                data_obj.s_tvalid_2= vif.s_tvalid_2; 
                ap_mon.write(data_obj);
            end

            // port 3
            if (vif.s_tvalid_3 && vif.s_tready_3 ) begin
                data_obj = router_seq_item#()::type_id::create("data_obj", this);
                data_obj.port_id  = 3;
                data_obj.s_tdata_3 = vif.s_tdata_3;
                data_obj.s_tid_3   = vif.s_tid_3;    
                data_obj.s_tdest_3 = vif.s_tdest_3;  
                data_obj.s_tlast_3 = vif.s_tlast_3;  
                data_obj.s_tvalid_3= vif.s_tvalid_3; 
                ap_mon.write(data_obj);
            end
        end
    endtask

endclass