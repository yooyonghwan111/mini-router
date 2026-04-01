class router_driver extends uvm_driver #(router_seq_item #());

    `uvm_component_utils(router_driver)

    function new(string name = "router_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual router_if #(.D_WIDTH(8)) vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual router_if #(.D_WIDTH(8)))::get(this, "", "vif", vif))
            `uvm_error(get_type_name(), "DUT interface not found")
    endfunction

    virtual task run_phase(uvm_phase phase);
        router_seq_item item;

        @(posedge vif.clk);
        while (!vif.rst_n) @(posedge vif.clk);

        forever begin
            seq_item_port.get_next_item(item);

            for (int i = 0; i < item.data.size(); i++) begin
                @(posedge vif.clk);
                // tready=0이면 stall
                case (item.port_id)
                    2'd0: while (!vif.s_tready_0) @(posedge vif.clk);
                    2'd1: while (!vif.s_tready_1) @(posedge vif.clk);
                    2'd2: while (!vif.s_tready_2) @(posedge vif.clk);
                    2'd3: while (!vif.s_tready_3) @(posedge vif.clk);
                endcase

                // [변경] 개별 신호로 drive + [추가] tid drive
                case (item.port_id)
                    2'd0: begin
                        vif.s_tdata_0  <= item.data[i];
                        vif.s_tid_0    <= item.tid;                              // [추가]
                        vif.s_tdest_0  <= item.tdest;
                        vif.s_tvalid_0 <= 1;
                        vif.s_tlast_0  <= (i == item.data.size()-1) ? 1 : 0;
                    end
                    2'd1: begin
                        vif.s_tdata_1  <= item.data[i];
                        vif.s_tid_1    <= item.tid;                              // [추가]
                        vif.s_tdest_1  <= item.tdest;
                        vif.s_tvalid_1 <= 1;
                        vif.s_tlast_1  <= (i == item.data.size()-1) ? 1 : 0;
                    end
                    2'd2: begin
                        vif.s_tdata_2  <= item.data[i];
                        vif.s_tid_2    <= item.tid;                              // [추가]
                        vif.s_tdest_2  <= item.tdest;
                        vif.s_tvalid_2 <= 1;
                        vif.s_tlast_2  <= (i == item.data.size()-1) ? 1 : 0;
                    end
                    2'd3: begin
                        vif.s_tdata_3  <= item.data[i];
                        vif.s_tid_3    <= item.tid;                              // [추가]
                        vif.s_tdest_3  <= item.tdest;
                        vif.s_tvalid_3 <= 1;
                        vif.s_tlast_3  <= (i == item.data.size()-1) ? 1 : 0;
                    end
                endcase
            end

            // 패킷 완료 후 valid deassert
            @(posedge vif.clk);
            case (item.port_id)
                2'd0: begin vif.s_tvalid_0 <= 0; vif.s_tlast_0 <= 0; end
                2'd1: begin vif.s_tvalid_1 <= 0; vif.s_tlast_1 <= 0; end
                2'd2: begin vif.s_tvalid_2 <= 0; vif.s_tlast_2 <= 0; end
                2'd3: begin vif.s_tvalid_3 <= 0; vif.s_tlast_3 <= 0; end
            endcase

            seq_item_port.item_done();
        end
    endtask

endclass