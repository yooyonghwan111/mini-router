`uvm_analysis_imp_decl(_input)
`uvm_analysis_imp_decl(_output)

class router_scoreboard #(parameter D_WIDTH=8) extends uvm_scoreboard;

    `uvm_component_utils(router_scoreboard)

    bit [D_WIDTH-1:0] exp_queue_0[$]; // output port 0 expected
    bit [D_WIDTH-1:0] exp_queue_1[$]; // output port 1 expected
    bit [D_WIDTH-1:0] exp;

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
    // [변경] packed 배열 인덱스 → 개별 신호 참조
    virtual function void write_input(router_seq_item #() data);
        case (data.port_id)
            2'd0: begin
                if (data.s_tdest_0 == 0) begin
                    exp_queue_0.push_back(data.s_tdata_0);
                    `uvm_info(get_type_name(), $sformatf("input0 -> queue0 (data=%0h tid=%0b)", data.s_tdata_0, data.s_tid_0), UVM_LOW)
                end else begin
                    exp_queue_1.push_back(data.s_tdata_0);
                    `uvm_info(get_type_name(), $sformatf("input0 -> queue1 (data=%0h tid=%0b)", data.s_tdata_0, data.s_tid_0), UVM_LOW)
                end
            end
            2'd1: begin
                if (data.s_tdest_1 == 0) begin
                    exp_queue_0.push_back(data.s_tdata_1);
                    `uvm_info(get_type_name(), $sformatf("input1 -> queue0 (data=%0h tid=%0b)", data.s_tdata_1, data.s_tid_1), UVM_LOW)
                end else begin
                    exp_queue_1.push_back(data.s_tdata_1);
                    `uvm_info(get_type_name(), $sformatf("input1 -> queue1 (data=%0h tid=%0b)", data.s_tdata_1, data.s_tid_1), UVM_LOW)
                end
            end
            2'd2: begin
                if (data.s_tdest_2 == 0) begin
                    exp_queue_0.push_back(data.s_tdata_2);
                    `uvm_info(get_type_name(), $sformatf("input2 -> queue0 (data=%0h tid=%0b)", data.s_tdata_2, data.s_tid_2), UVM_LOW)
                end else begin
                    exp_queue_1.push_back(data.s_tdata_2);
                    `uvm_info(get_type_name(), $sformatf("input2 -> queue1 (data=%0h tid=%0b)", data.s_tdata_2, data.s_tid_2), UVM_LOW)
                end
            end
            2'd3: begin
                if (data.s_tdest_3 == 0) begin
                    exp_queue_0.push_back(data.s_tdata_3);
                    `uvm_info(get_type_name(), $sformatf("input3 -> queue0 (data=%0h tid=%0b)", data.s_tdata_3, data.s_tid_3), UVM_LOW)
                end else begin
                    exp_queue_1.push_back(data.s_tdata_3);
                    `uvm_info(get_type_name(), $sformatf("input3 -> queue1 (data=%0h tid=%0b)", data.s_tdata_3, data.s_tid_3), UVM_LOW)
                end
            end
        endcase
    endfunction

    // output monitor → exp_queue에서 pop해서 비교
    // [변경] packed 배열 인덱스 → 개별 신호 참조
    virtual function void write_output(router_seq_item #() data);
        case (data.port_id)
            2'd0: begin
                if (exp_queue_0.size() == 0) begin
                    `uvm_error(get_type_name(), "exp_queue_0 is empty!")
                    return;
                end
                exp = exp_queue_0.pop_front();
                if (exp == data.m_tdata_0)
                    `uvm_info(get_type_name(), $sformatf("[PASS] output0: exp=%0h actual=%0h tid=%0b", exp, data.m_tdata_0, data.m_tid_0), UVM_LOW)
                else
                    `uvm_error(get_type_name(), $sformatf("[FAIL] output0: exp=%0h actual=%0h tid=%0b", exp, data.m_tdata_0, data.m_tid_0))
            end
            2'd1: begin
                if (exp_queue_1.size() == 0) begin
                    `uvm_error(get_type_name(), "exp_queue_1 is empty!")
                    return;
                end
                exp = exp_queue_1.pop_front();
                if (exp == data.m_tdata_1)
                    `uvm_info(get_type_name(), $sformatf("[PASS] output1: exp=%0h actual=%0h tid=%0b", exp, data.m_tdata_1, data.m_tid_1), UVM_LOW)
                else
                    `uvm_error(get_type_name(), $sformatf("[FAIL] output1: exp=%0h actual=%0h tid=%0b", exp, data.m_tdata_1, data.m_tid_1))
            end
        endcase
    endfunction

endclass