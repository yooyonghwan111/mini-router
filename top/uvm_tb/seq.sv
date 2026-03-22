class base_seq extends uvm_sequence #(router_seq_item #());
  `uvm_object_utils(base_seq)

  int unsigned num_pkts = 3;

  function new(string name = "base_seq");
    super.new(name);
  endfunction

  task body();

    for (int i=0; i<num_pkts; i++) begin
      router_seq_item #() item;
      item = router_seq_item #()::type_id::create("item");
      
      start_item(item);  // sequencer에 item 준비 완료를 알림
      if (!item.randomize())  // port_id, data[], tdest를 constraint 기반으로 랜덤 생성
        `uvm_fatal(get_type_name(), "Randomization failed!")
      finish_item(item);  // driver로 item을 전달
    end
    
  endtask

endclass