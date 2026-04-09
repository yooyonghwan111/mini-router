class upstream_bp_test extends uvm_test;
  `uvm_component_utils(upstream_bp_test)

  router_env            m_env;
  upstream_bp_seq       m_seq;


  virtual router_if #(.D_WIDTH(8)) vif; 

  function new(string name = "upstream_bp_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env = router_env::type_id::create("router_env", this);
    m_seq = upstream_bp_seq::type_id::create("upstream_bp_seq");

    if (!uvm_config_db #(virtual router_if #(.D_WIDTH(8)))::get(this, "uvm_test_top", "vif", vif)) 
    `uvm_fatal(get_type_name(), "VIF not found")
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);


        // m_tready=0으로 downstream 막기
        vif.m_tready_0 = 0;
        //vif.m_tready_1 = 0;
        
        m_seq.start(m_env.a_agent.seqr);

        // m_tready=1로 풀기
        vif.m_tready_0 = 1;
        //vif.m_tready_1 = 1;

    #2000;
    phase.drop_objection(this);
  endtask

endclass