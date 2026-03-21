class fifo_basic_test extends uvm_test;
  `uvm_component_utils(fifo_basic_test)

  fifo_env       m_env;
  fifo_basic_seq basic_seq;

  function new(string name = "fifo_basic_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env     = fifo_env::type_id::create("fifo_env", this);
    basic_seq = fifo_basic_seq::type_id::create("basic_seq");
  endfunction

  virtual task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);

    basic_seq.start(m_env.m_agent.seqr);

    phase.drop_objection(this);
    
  endtask

endclass