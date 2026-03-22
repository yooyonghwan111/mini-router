// input/output용 monitor port를 구분하기 위해 아래와 같이 imp를 선언
`uvm_analysis_imp_decl(_input)  // write_input() 생성
`uvm_analysis_imp_decl(_output) // write_output() 생성 

class router_scoreboard #(parameter D_WIDTH=8) extends uvm_scoreboard;

    `uvm_component_utils (router_scoreboard)

    bit [D_WIDTH-1:0] exp_queue_0 [$]; // output port 0 expected 
    bit [D_WIDTH-1:0] exp_queue_1 [$]; // output port 1 expected 

    bit [D_WIDTH-1:0] exp;

    function new (string name = "router_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    uvm_analysis_imp_input #(router_seq_item #(), router_scoreboard #()) ap_input_scb; 
    uvm_analysis_imp_output #(router_seq_item #(), router_scoreboard #()) ap_output_scb; 
 

    virtual function void build_phase (uvm_phase phase);
        ap_input_scb = new ("ap_input_scb", this);
        ap_output_scb = new ("ap_output_scb", this);
    endfunction

    // port_id 보고 → 해당 s_tdata_x 읽기
    // tdest 보고 → 0이면 exp_queue_0.push_back, 1이면 exp_queue_1.push_back1
    virtual function void write_input(router_seq_item #() data);
        case (data.port_id)
            2'd0 : begin
                if (data.s_tdest[0] == 0)  
                    exp_queue_0.push_back(data.s_tdata_0);
                else
                    exp_queue_1.push_back(data.s_tdata_0);
            end

           2'd1 : begin
                if (data.s_tdest[1] == 0)  
                    exp_queue_0.push_back(data.s_tdata_1);
                else
                    exp_queue_1.push_back(data.s_tdata_1);            
           end

           2'd2 : begin
                if (data.s_tdest[2] == 0)  
                    exp_queue_0.push_back(data.s_tdata_2);
                else
                    exp_queue_1.push_back(data.s_tdata_2);            
           end

           2'd3 : begin
                if (data.s_tdest[3] == 0)  
                    exp_queue_0.push_back(data.s_tdata_3);
                else
                    exp_queue_1.push_back(data.s_tdata_3);            
           end            

        endcase

    endfunction 


    virtual function void write_output(router_seq_item #() data);

        case (data.port_id)

            2'd0 : begin
                exp = exp_queue_0.pop_front();

                if (exp == data.m_tdata_0)
                    `uvm_info(get_type_name(), $sformatf("PASS: port0 expected=%0h, actual=%0h", exp, data.m_tdata_0), UVM_LOW)
                else
                    `uvm_error(get_type_name(), $sformatf("FAIL: port0 expected=%0h, actual=%0h", exp, data.m_tdata_0))
            end

            2'd1 : begin
                exp = exp_queue_1.pop_front();

                if (exp == data.m_tdata_1)
                    `uvm_info(get_type_name(), $sformatf("PASS: port1 expected=%0h, actual=%0h", exp, data.m_tdata_1), UVM_LOW)
                else
                    `uvm_error(get_type_name(), $sformatf("FAIL: port1 expected=%0h, actual=%0h", exp, data.m_tdata_1))
            end

        endcase

    endfunction 

    




endclass


