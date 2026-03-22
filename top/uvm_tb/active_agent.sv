class active_agent extends uvm_agent;
    `uvm_component_utils (active_agent)

    function new (string name = "active_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    router_driver drv;
    router_input_monitor mon;
    router_sequencer seqr;


    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        drv = router_driver::type_id::create("drv", this);
        mon = router_input_monitor::type_id::create("mon", this);
        seqr = router_sequencer::type_id::create("seqr", this);
    endfunction

    virtual function void connect_phase (uvm_phase phase);
        drv.seq_item_port.connect (seqr.seq_item_export);
    endfunction


endclass