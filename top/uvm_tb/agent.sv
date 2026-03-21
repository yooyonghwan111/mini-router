class fifo_agent extends uvm_agent;
    `uvm_component_utils (fifo_agent)

    function new (string name = "fifo_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    fifo_driver drv;
    fifo_monitor mon;
    fifo_sequencer seqr;


    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        drv = fifo_driver::type_id::create("drv", this);
        mon = fifo_monitor::type_id::create("mon", this);
        seqr = fifo_sequencer::type_id::create("seqr", this);
    endfunction

    virtual function void connect_phase (uvm_phase phase);
        drv.seq_item_port.connect (seqr.seq_item_export);
    endfunction


endclass