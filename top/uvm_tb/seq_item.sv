class fifo_seq_item #(parameter D_WIDTH=8)extends uvm_sequence_item;
  
  rand bit               wr_en;
  rand bit               rd_en;
  rand bit [D_WIDTH-1:0] din;

  bit [D_WIDTH-1:0] dout;
  bit full;
  bit empty;
  
  `uvm_object_utils_begin (fifo_seq_item)
    `uvm_field_int(wr_en, UVM_ALL_ON)
    `uvm_field_int(rd_en, UVM_ALL_ON)
  	`uvm_field_int(din, UVM_ALL_ON)

    `uvm_field_int(dout, UVM_ALL_ON)
    `uvm_field_int(empty, UVM_ALL_ON)
    `uvm_field_int(full, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name= "fifo_seq_item");
    super.new(name);
  endfunction
  
endclass