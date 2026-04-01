class router_basic_test extends uvm_test;
  `uvm_component_utils(router_basic_test)

  router_env       m_env;
  base_seq basic_seq;

  function new(string name = "router_basic_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env     = router_env::type_id::create("router_env", this);
    basic_seq = base_seq::type_id::create("basic_seq");
  endfunction

  virtual task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);

    basic_seq.start(m_env.a_agent.seqr);
   
    // Wait for last packet to propagate through DUT to output
  #600;

    phase.drop_objection(this);
    
  endtask

endclass