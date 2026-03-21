class fifo_basic_seq extends uvm_sequence #(fifo_seq_item #());
  `uvm_object_utils(fifo_basic_seq)

  rand bit wr_en_val;
  rand bit rd_en_val;

  function new(string name = "fifo_basic_seq");
    super.new(name);
  endfunction

  task body();
    fifo_seq_item #() item;

    
    // 8 write
    for(int i = 0; i < 8; i++) begin
      item = fifo_seq_item #()::type_id::create("item");
      start_item(item);
      	if(!item.randomize() with {wr_en==1; rd_en==0;}) begin
  			`uvm_fatal(get_type_name(), "Randomization failed!")
		end
      finish_item(item);
    end

    // 8 read
    for(int i = 0; i < 8; i++) begin
      item = fifo_seq_item #()::type_id::create("item");
      start_item(item);
      if(!item.randomize() with {wr_en==0; rd_en==1;}) begin
  			`uvm_fatal(get_type_name(), "Randomization failed!")
		end
      finish_item(item);
    end
    
  endtask

endclass