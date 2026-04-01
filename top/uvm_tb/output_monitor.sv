class router_output_monitor extends uvm_monitor;
    `uvm_component_utils(router_output_monitor)

    virtual router_if #(.D_WIDTH(8)) vif;
    uvm_analysis_port #(router_seq_item #()) ap_mon;
    router_seq_item #() data_obj;

    // [추가] output port별 beat 누적 버퍼 => packet단위로 캡쳐하기 위함
    bit [7:0] pkt_buf_0[$];
    bit [7:0] pkt_buf_1[$];
    

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


            // port 0 
            if (vif.m_tvalid_0 && vif.m_tready_0) begin 
              pkt_buf_0.push_back(vif.m_tdata_0);       // 개별 beat 누적
              if (vif.m_tlast_0) begin                  // 하나의 packet 완성

                data_obj = router_seq_item#()::type_id::create("data_obj", this);
                // data_obj.port_id  = 0;
                // data_obj.m_tdata_0 = vif.m_tdata_0;
                // data_obj.m_tid_0   = vif.m_tid_0;    
                // data_obj.m_tlast_0 = vif.m_tlast_0;  
                // data_obj.m_tvalid_0= vif.m_tvalid_0; 

                data_obj.m_port_id  = 0;
                data_obj.m_tid      = vif.m_tid_0;

                
                data_obj.m_pkt_data = pkt_buf_0;

                pkt_buf_0.delete();              // 버퍼 초기화 (새로운 packet을 담기위함)
                `uvm_info(get_type_name(), $sformatf("output port0 packet done: tid=%0b beats=%0d", data_obj.m_tid, data_obj.m_pkt_data.size()), UVM_LOW)

                ap_mon.write(data_obj); // scoreboard로 캡쳐한 값들 넘김
              end
            end

            // port 1 
            if (vif.m_tvalid_1 && vif.m_tready_1) begin 
              pkt_buf_1.push_back(vif.m_tdata_1);       // 개별 beat 누적
              if (vif.m_tlast_1) begin                  // 하나의 packet 완성

                data_obj = router_seq_item#()::type_id::create("data_obj", this);
                // data_obj.port_id  = 1;
                // data_obj.m_tdata_1 = vif.m_tdata_1;
                // data_obj.m_tid_1   = vif.m_tid_1;    
                // data_obj.m_tlast_1 = vif.m_tlast_1;  
                // data_obj.m_tvalid_1= vif.m_tvalid_1; 

                data_obj.m_port_id  = 1;
                data_obj.m_tid      = vif.m_tid_1;

                
                data_obj.m_pkt_data = pkt_buf_1;

                pkt_buf_1.delete();              // 버퍼 초기화 (새로운 packet을 담기위함)
                `uvm_info(get_type_name(), $sformatf("output port1 packet done: tid=%0b beats=%0d", data_obj.m_tid, data_obj.m_pkt_data.size()), UVM_LOW)

                ap_mon.write(data_obj); // scoreboard로 캡쳐한 값들 넘김
              end
            end
   
        end
    endtask

endclass