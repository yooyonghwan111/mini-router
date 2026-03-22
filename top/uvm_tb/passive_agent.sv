class passive_agent extends uvm_agent;
    `uvm_component_utils (passive_agent)

    function new (string name = "passive_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    router_output_monitor mon;

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        mon = router_output_monitor::type_id::create("mon", this);
 
    endfunction

endclass