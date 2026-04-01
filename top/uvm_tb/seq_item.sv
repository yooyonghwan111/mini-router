class router_seq_item #(parameter D_WIDTH=8, DEPTH=4) extends uvm_sequence_item;

    // driver 제어용
    rand bit [1:0]          port_id;
    rand bit [D_WIDTH-1:0]  data[];
    rand bit                tdest;
    rand bit [1:0]          tid;       

    // input monitor 샘플링 요소 (beat 단위)
    // bit [D_WIDTH-1:0]       s_tdata_0, s_tdata_1, s_tdata_2, s_tdata_3;
    // bit [1:0]               s_tid_0,   s_tid_1,   s_tid_2,   s_tid_3;   
    // bit                     s_tdest_0, s_tdest_1, s_tdest_2, s_tdest_3; 
    // bit                     s_tlast_0, s_tlast_1, s_tlast_2, s_tlast_3; 
    // bit                     s_tvalid_0,s_tvalid_1,s_tvalid_2,s_tvalid_3;

    // input monitor 샘플링 요소 (packet 단위)
    bit [D_WIDTH-1:0]       s_pkt_data[$];   // 누적된 beats (tlast까지)
    bit [1:0]               s_tid;          // packet의 tid
    bit                     s_tdest;        // packet의 dest
    bit [1:0]               s_port_id;      // 어느 input port에서 왔는지


    // output monitor 샘플링 요소 (beat 단위)
    // bit [D_WIDTH-1:0]       m_tdata_0,  m_tdata_1;
    // bit [1:0]               m_tid_0,    m_tid_1;                         
    // bit                     m_tlast_0,  m_tlast_1;                       
    // bit                     m_tvalid_0, m_tvalid_1;              

    // output monitor 샘플링 요소 (packet 단위)
    bit [D_WIDTH-1:0]       m_pkt_data[$];   // 누적된 beats (tlast까지)
    bit [1:0]               m_tid;          // packet의 tid
    bit [1:0]               m_port_id;      // 어느 output port에서 나왔는지
        

    // `uvm_object_utils_begin(router_seq_item)
    //     `uvm_field_int(port_id,   UVM_ALL_ON)
    //     `uvm_field_int(tdest,     UVM_ALL_ON)
    //     `uvm_field_int(tid,       UVM_ALL_ON)  
    //     `uvm_field_array_int(data, UVM_ALL_ON)

    //     `uvm_field_int(s_tdata_0, UVM_ALL_ON)
    //     `uvm_field_int(s_tdata_1, UVM_ALL_ON)
    //     `uvm_field_int(s_tdata_2, UVM_ALL_ON)
    //     `uvm_field_int(s_tdata_3, UVM_ALL_ON)
    //     `uvm_field_int(s_tid_0,   UVM_ALL_ON)  
    //     `uvm_field_int(s_tid_1,   UVM_ALL_ON)  
    //     `uvm_field_int(s_tid_2,   UVM_ALL_ON)  
    //     `uvm_field_int(s_tid_3,   UVM_ALL_ON)  
    //     `uvm_field_int(s_tdest_0, UVM_ALL_ON)  
    //     `uvm_field_int(s_tdest_1, UVM_ALL_ON)  
    //     `uvm_field_int(s_tdest_2, UVM_ALL_ON)  
    //     `uvm_field_int(s_tdest_3, UVM_ALL_ON)  
    //     `uvm_field_int(s_tlast_0, UVM_ALL_ON)  
    //     `uvm_field_int(s_tlast_1, UVM_ALL_ON)  
    //     `uvm_field_int(s_tlast_2, UVM_ALL_ON)  
    //     `uvm_field_int(s_tlast_3, UVM_ALL_ON)  

    //     `uvm_field_int(m_tdata_0, UVM_ALL_ON)
    //     `uvm_field_int(m_tdata_1, UVM_ALL_ON)
    //     `uvm_field_int(m_tid_0,   UVM_ALL_ON)  
    //     `uvm_field_int(m_tid_1,   UVM_ALL_ON)  
    //     `uvm_field_int(m_tlast_0, UVM_ALL_ON)  
    //     `uvm_field_int(m_tlast_1, UVM_ALL_ON)  
    //     `uvm_field_int(m_tvalid_0,UVM_ALL_ON)  
    //     `uvm_field_int(m_tvalid_1,UVM_ALL_ON)  
    // `uvm_object_utils_end


    `uvm_object_utils_begin(router_seq_item)
        // driver용
        `uvm_field_int(port_id,          UVM_ALL_ON)
        `uvm_field_int(tdest,            UVM_ALL_ON)
        `uvm_field_int(tid,              UVM_ALL_ON)
        `uvm_field_array_int(data,       UVM_ALL_ON)
 
        // input monitor용
        //`uvm_field_array_int(s_pkt_data, UVM_ALL_ON)
        `uvm_field_queue_int(s_pkt_data, UVM_ALL_ON)
        `uvm_field_int(s_tid,            UVM_ALL_ON)
        `uvm_field_int(s_tdest,          UVM_ALL_ON)
        `uvm_field_int(s_port_id,        UVM_ALL_ON)
 
        // output monitor용
        //`uvm_field_array_int(m_pkt_data, UVM_ALL_ON)
        `uvm_field_queue_int(m_pkt_data, UVM_ALL_ON)
        `uvm_field_int(m_tid,            UVM_ALL_ON)
        `uvm_field_int(m_port_id,        UVM_ALL_ON)
    `uvm_object_utils_end


    constraint pkt_len_c {
        data.size() inside {[1:DEPTH]};
    }

    // tid를 port_id와 동일하게 고정 (각 port의 고유 식별자)
    constraint tid_c {
        tid == port_id;
    }

    function new(string name = "router_seq_item");
        super.new(name);
    endfunction

endclass