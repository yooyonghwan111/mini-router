class router_sequencer extends uvm_sequencer #(router_seq_item #());
  
  `uvm_component_utils (router_sequencer)
  
  function new (string name ="router_sequencer", uvm_component parent);
    super.new (name, parent);
  endfunction

endclass