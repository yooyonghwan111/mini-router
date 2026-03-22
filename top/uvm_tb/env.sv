class router_env extends uvm_env;
    `uvm_component_utils (router_env)

    function new (string name = "my_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    active_agent          a_agent;
    passive_agent         p_agent;
    router_scoreboard #() m_scb;

    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        a_agent = active_agent::type_id::create ("a_agent", this);
        p_agent = passive_agent::type_id::create ("p_agent", this);
        m_scb = router_scoreboard #()::type_id::create ("m_scb", this);
    endfunction

    virtual function void connect_phase (uvm_phase phase);
        a_agent.mon.ap_mon.connect (m_scb.ap_input_scb);
        p_agent.mon.ap_mon.connect (m_scb.ap_output_scb);
    endfunction

endclass