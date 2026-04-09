`uvm_analysis_imp_decl(_input)
`uvm_analysis_imp_decl(_output)

class router_scoreboard #(parameter D_WIDTH=8) extends uvm_scoreboard;

    `uvm_component_utils(router_scoreboard)

    //bit [D_WIDTH-1:0] exp_queue_0[$]; // output port 0 expected
    bit [D_WIDTH-1:0] exp_queue_0[$][$];  // packet 단위 queue

    //bit [D_WIDTH-1:0] exp_queue_1[$]; // output port 1 expected
    bit [D_WIDTH-1:0] exp_queue_1[$][$];  // packet 단위 queue

    
    //bit [D_WIDTH-1:0] exp;
    bit [D_WIDTH-1:0] exp_pkt [$];

    uvm_analysis_imp_input  #(router_seq_item #(), router_scoreboard #()) ap_input_scb;
    uvm_analysis_imp_output #(router_seq_item #(), router_scoreboard #()) ap_output_scb;

    function new(string name = "router_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        ap_input_scb  = new("ap_input_scb",  this);
        ap_output_scb = new("ap_output_scb", this);
    endfunction

    // input monitor → tdest 보고 exp_queue에 push
    virtual function void write_input(router_seq_item #() data);

        if (data.s_tdest == 0) begin
            exp_queue_0.push_back(data.s_pkt_data);
            //`uvm_info(get_type_name(), $sformatf("input0 -> queue0 (data=%0h tid=%0b)", data.s_tdata_0, data.s_tid_0), UVM_LOW)
                
        end 
        else begin // data.s_tdest == 1
            exp_queue_1.push_back(data.s_pkt_data);
            //`uvm_info(get_type_name(), $sformatf("input0 -> queue1 (data=%0h tid=%0b)", data.s_tdata_0, data.s_tid_0), UVM_LOW)
        end

        `uvm_info(get_type_name(), $sformatf("input%0d -> queue%0d: tid=%0b beats=%0d first=%0h",
                                                    data.s_port_id, data.s_tdest, data.s_tid, data.s_pkt_data.size(), data.s_pkt_data[0]), UVM_MEDIUM)
    endfunction



    // output monitor → exp_queue에서 pop해서 비교
    virtual function void write_output(router_seq_item #() data);

        if (data.m_port_id == 0) begin // output 0

            if (exp_queue_0.size() == 0) begin
                `uvm_error(get_type_name(), "exp_queue_0 is empty!")
                return;
            end

            exp_pkt = exp_queue_0.pop_front();
        end 
        

        else begin //data.m_port_id == 1 (output 1)
            if (exp_queue_1.size() == 0) begin
                `uvm_error(get_type_name(), "exp_queue_1 is empty!")
                return;
            end
            exp_pkt = exp_queue_1.pop_front();
        end


        // beat 수 비교
        if (exp_pkt.size() != data.m_pkt_data.size()) begin
            `uvm_error(get_type_name(), $sformatf("[FAIL] port%0d beat count mismatch: exp=%0d actual=%0d",
                                                        data.m_port_id, exp_pkt.size(), data.m_pkt_data.size()))
            return;
        end

        // beat by beat 비교
        foreach (exp_pkt[i]) begin

            if (exp_pkt[i] != data.m_pkt_data[i])
                `uvm_error(get_type_name(), $sformatf("[FAIL] port%0d beat[%0d]: exp=%0h actual=%0h",
                                                                data.m_port_id, i, exp_pkt[i], data.m_pkt_data[i]))
            else
                `uvm_info(get_type_name(), $sformatf("[PASS] port%0d beat[%0d]: exp=%0h actual=%0h",
                                                                data.m_port_id, i, exp_pkt[i], data.m_pkt_data[i]), UVM_MEDIUM)
        end
    endfunction

endclass