// tb 스켈레톤 socreboarding 안정화
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


// 테스트 시나리오 base_seq
class tc_base_seq extends uvm_sequence #(router_seq_item #());
  `uvm_object_utils(tc_base_seq)

  function new(string name = "tc_base_seq");
    super.new(name);
  endfunction

  // 공통 send_packet task - 모든 TC에서 재사용
  //task send_packet(int unsigned p, bit dest, int unsigned n_beats);
  task send_packet(int unsigned p, bit dest);
    router_seq_item #() item;
    item = router_seq_item #()::type_id::create("item");
    start_item(item);

    if (!item.randomize() with { 
      port_id == p; 
      tdest   == dest;
      //data.size() == n_beats;
    })
      `uvm_fatal(get_type_name(), "Randomization failed!")
    finish_item(item);
  endtask
endclass


class normal_routing_seq extends tc_base_seq;
  `uvm_object_utils(normal_routing_seq)

  function new(string name = "normal_routing_seq");
    super.new(name);
  endfunction

  task body();
    // TC001: 모든 input 포트 -> tdest=0
    for (int p = 0; p < 4; p++)
      //send_packet(p, 0, 1);
      send_packet(p, 0);



    // TC002: 모든 input 포트 -> tdest=1
    for (int p = 0; p < 4; p++)
      //send_packet(p, 1, 1);
      send_packet(p, 1);

  endtask

endclass





