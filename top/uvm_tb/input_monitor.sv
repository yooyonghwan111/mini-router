class router_input_monitor extends uvm_monitor;
    `uvm_component_utils(router_input_monitor)

    virtual router_if #(.D_WIDTH(8)) vif;
    uvm_analysis_port #(router_seq_item #()) ap_mon;
    router_seq_item #() data_obj;

    // [추가] input port별 beat 누적 버퍼 => packet단위로 캡쳐하기 위함
    bit [7:0] pkt_buf_1[$];
    bit [7:0] pkt_buf_2[$];
    bit [7:0] pkt_buf_0[$];
    bit [7:0] pkt_buf_3[$];

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

            // port 0 
            if (vif.s_tvalid_0 && vif.s_tready_0) begin 
              pkt_buf_0.push_back(vif.s_tdata_0);       // 개별 beat 누적
              if (vif.s_tlast_0) begin                  // 하나의 packet 완성

                data_obj = router_seq_item#()::type_id::create("data_obj", this);
                // data_obj.port_id  = 0;
                // data_obj.s_tdata_0 = vif.s_tdata_0;
                // data_obj.s_tid_0   = vif.s_tid_0;    
                // data_obj.s_tdest_0 = vif.s_tdest_0;  
                // data_obj.s_tlast_0 = vif.s_tlast_0;  
                // data_obj.s_tvalid_0= vif.s_tvalid_0;

                data_obj.s_port_id  = 0;
                data_obj.s_tid      = vif.s_tid_0;
                data_obj.s_tdest    = vif.s_tdest_0;
              

                data_obj.s_pkt_data = pkt_buf_0; // queue -> queue 직접 대입



                pkt_buf_0.delete();              // 버퍼 초기화 (새로운 packet을 담기위함)
                `uvm_info(get_type_name(), $sformatf("input port0 packet done: tid=%0b dest=%0b beats=%0d", data_obj.s_tid, data_obj.s_tdest, data_obj.s_pkt_data.size()), UVM_LOW)

                ap_mon.write(data_obj); // scoreboard로 캡쳐한 값들 넘김
              end
            end

            // port 1
            if (vif.s_tvalid_1 && vif.s_tready_1) begin 
              pkt_buf_1.push_back(vif.s_tdata_1);       // 개별 beat 누적
              if (vif.s_tlast_1) begin                  // 하나의 packet 완성

                data_obj = router_seq_item#()::type_id::create("data_obj", this);
                // data_obj.port_id  = 1;
                // data_obj.s_tdata_1 = vif.s_tdata_1;
                // data_obj.s_tid_1   = vif.s_tid_1;    
                // data_obj.s_tdest_1 = vif.s_tdest_1;  
                // data_obj.s_tlast_1 = vif.s_tlast_1;  
                // data_obj.s_tvalid_1= vif.s_tvalid_1;

                data_obj.s_port_id  = 1;
                data_obj.s_tid      = vif.s_tid_1;
                data_obj.s_tdest    = vif.s_tdest_1;
                
                data_obj.s_pkt_data = pkt_buf_1; // queue -> queue 직접 대입

                pkt_buf_1.delete();              // 버퍼 초기화 (새로운 packet을 담기위함)

                `uvm_info(get_type_name(), $sformatf("input port1 packet done: tid=%0b dest=%0b beats=%0d", data_obj.s_tid, data_obj.s_tdest, data_obj.s_pkt_data.size()), UVM_LOW)

                ap_mon.write(data_obj); // scoreboard로 캡쳐한 값들 넘김
              end
            end

            // port 2
            if (vif.s_tvalid_2 && vif.s_tready_2) begin 
              pkt_buf_2.push_back(vif.s_tdata_2);       // 개별 beat 누적
              if (vif.s_tlast_2) begin                  // 하나의 packet 완성

                data_obj = router_seq_item#()::type_id::create("data_obj", this);
                // data_obj.port_id  = 2;
                // data_obj.s_tdata_2 = vif.s_tdata_2;
                // data_obj.s_tid_2   = vif.s_tid_2;    
                // data_obj.s_tdest_2 = vif.s_tdest_2;  
                // data_obj.s_tlast_2 = vif.s_tlast_2;  
                // data_obj.s_tvalid_2= vif.s_tvalid_2;

                data_obj.s_port_id  = 2;
                data_obj.s_tid      = vif.s_tid_2;
                data_obj.s_tdest    = vif.s_tdest_2;
                
                data_obj.s_pkt_data = pkt_buf_2; // queue -> queue 직접 대입

                pkt_buf_2.delete();              // 버퍼 초기화 (새로운 packet을 담기위함)

                `uvm_info(get_type_name(), $sformatf("input port2 packet done: tid=%0b dest=%0b beats=%0d", data_obj.s_tid, data_obj.s_tdest, data_obj.s_pkt_data.size()), UVM_LOW)

                ap_mon.write(data_obj); // scoreboard로 캡쳐한 값들 넘김                


              end
            end
            

            // port 3
            if (vif.s_tvalid_3 && vif.s_tready_3) begin 
              pkt_buf_3.push_back(vif.s_tdata_3);       // 개별 beat 누적
              if (vif.s_tlast_3) begin                  // 하나의 packet 완성

                data_obj = router_seq_item#()::type_id::create("data_obj", this);
                // data_obj.port_id  = 3;
                // data_obj.s_tdata_3 = vif.s_tdata_3;
                // data_obj.s_tid_3   = vif.s_tid_3;    
                // data_obj.s_tdest_3 = vif.s_tdest_3;  
                // data_obj.s_tlast_3 = vif.s_tlast_3;  
                // data_obj.s_tvalid_3= vif.s_tvalid_3;

                data_obj.s_port_id  = 3;
                data_obj.s_tid      = vif.s_tid_3;
                data_obj.s_tdest    = vif.s_tdest_3;
                
                data_obj.s_pkt_data = pkt_buf_3; // queue -> queue 직접 대입

                pkt_buf_3.delete();              // 버퍼 초기화 (새로운 packet을 담기위함)

                `uvm_info(get_type_name(), $sformatf("input port3 packet done: tid=%0b dest=%0b beats=%0d", data_obj.s_tid, data_obj.s_tdest, data_obj.s_pkt_data.size()), UVM_LOW)

                ap_mon.write(data_obj); // scoreboard로 캡쳐한 값들 넘김

              end
            end

        end
    endtask

endclass