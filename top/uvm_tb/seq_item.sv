class router_seq_item #(parameter D_WIDTH=8, DEPTH=4) extends uvm_sequence_item;
  
    // 검증시나리오에서 변화하는 값들만 seq_item에 담음

    // driver
    rand bit  [1:0]                port_id;    
    rand bit  [D_WIDTH-1:0]        data[];     
    rand bit                       tdest;      
    
    // input monitor 
    bit [D_WIDTH-1:0]               s_tdata_0;
    bit [D_WIDTH-1:0]               s_tdata_1;
    bit [D_WIDTH-1:0]               s_tdata_2;
    bit [D_WIDTH-1:0]               s_tdata_3;
    bit [3:0]                       s_tvalid;
    bit [3:0]                       s_tdest;
    bit [3:0]                       s_tlast;


    // output monitor
    bit [D_WIDTH-1:0]               m_tdata_0;
    bit [D_WIDTH-1:0]               m_tdata_1;
    bit [1:0]                       m_tvalid;
    bit [1:0]                       m_tlast;

  
  `uvm_object_utils_begin (router_seq_item)
    `uvm_field_int(port_id, UVM_ALL_ON)
    `uvm_field_int(tdest, UVM_ALL_ON)
    `uvm_field_array_int(data, UVM_ALL_ON) // dynamic array

    `uvm_field_int(s_tdata_0, UVM_ALL_ON)
    `uvm_field_int(s_tdata_1, UVM_ALL_ON)
    `uvm_field_int(s_tdata_2, UVM_ALL_ON)
    `uvm_field_int(s_tdata_3, UVM_ALL_ON)
    `uvm_field_int(s_tvalid, UVM_ALL_ON)
    `uvm_field_int(s_tdest, UVM_ALL_ON)
    `uvm_field_int(s_tlast, UVM_ALL_ON)

    `uvm_field_int(m_tdata_0, UVM_ALL_ON)
    `uvm_field_int(m_tdata_1, UVM_ALL_ON)
    `uvm_field_int(m_tvalid, UVM_ALL_ON)
    `uvm_field_int(m_tlast, UVM_ALL_ON)

  `uvm_object_utils_end

  constraint pkt_len_c {
    data.size() inside {[1:DEPTH]};
  }
  
  function new(string name= "router_seq_item");
    super.new(name);
  endfunction
  

endclass