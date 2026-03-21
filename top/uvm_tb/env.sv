class fifo_env extends uvm_env;
    `uvm_component_utils (fifo_env)

    function new (string name = "my_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    fifo_agent m_agent;
    fifo_scoreboard m_scb;

    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        m_agent = fifo_agent::type_id::create ("m_agent", this);
        m_scb = fifo_scoreboard::type_id::create ("m_scb", this);
    endfunction

    virtual function void connect_phase (uvm_phase phase);
        m_agent.mon.ap_mon.connect (m_scb.ap_scb);
    endfunction

endclass