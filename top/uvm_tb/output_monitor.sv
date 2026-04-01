class router_output_monitor extends uvm_monitor;
    `uvm_component_utils(router_output_monitor)

    virtual router_if #(.D_WIDTH(8)) vif;
    uvm_analysis_port #(router_seq_item #()) ap_mon;
    router_seq_item #() data_obj;

    function new(string name = "router_output_monitor", uvm_component parent = null);
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
            #1step; // FIFO sequential output 타이밍 보정

            // output port 0 - [변경] 개별 신호 참조 + [추가] tid 샘플링
            if (vif.m_tvalid_0 && vif.m_tready_0 && vif.m_tlast_0) begin
                data_obj = router_seq_item#()::type_id::create("data_obj", this);
                data_obj.port_id  = 0;
                data_obj.m_tdata_0 = vif.m_tdata_0;
                data_obj.m_tid_0   = vif.m_tid_0;    
                data_obj.m_tlast_0 = vif.m_tlast_0;  
                data_obj.m_tvalid_0= vif.m_tvalid_0; 
                ap_mon.write(data_obj);
            end

            // output port 1
            if (vif.m_tvalid_1 && vif.m_tready_1 && vif.m_tlast_1) begin
                data_obj = router_seq_item#()::type_id::create("data_obj", this);
                data_obj.port_id  = 1;
                data_obj.m_tdata_1 = vif.m_tdata_1;
                data_obj.m_tid_1   = vif.m_tid_1;    
                data_obj.m_tlast_1 = vif.m_tlast_1;  
                data_obj.m_tvalid_1= vif.m_tvalid_1; 
                ap_mon.write(data_obj);
            end
        end
    endtask

endclass