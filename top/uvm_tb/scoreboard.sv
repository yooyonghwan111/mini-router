class fifo_scoreboard extends uvm_scoreboard;

    localparam D_WIDTH = 8;

    `uvm_component_utils (fifo_scoreboard)

    bit [D_WIDTH-1:0] exp_value[$];

    function new (string name = "fifo_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    uvm_analysis_imp #(fifo_seq_item, fifo_scoreboard) ap_scb;

    virtual function void build_phase (uvm_phase phase);
        ap_scb = new ("ap_scb", this);
    endfunction
/*
    virtual function void write (fifo_seq_item data);

        if (data.wr_en == 1) begin
            exp_value.push_back(data.din);
          `uvm_info(get_type_name(), $sformatf("WRITE: din=%0h, queue size=%0d", data.din, exp_value.size()), UVM_LOW)
        end
         if (data.rd_en == 1) begin
           `uvm_info(get_type_name(), $sformatf("READ: dout=%0h, expected=%0h", data.dout, exp_value[0]), UVM_LOW)
            if (exp_value.pop_front() != data.dout) begin
                `uvm_error("[SCOREBOARD]", "Read/dout Value Mismatch")
            end
        end
  
    endfunction
*/
  
  bit pending_read;

	virtual function void write(fifo_seq_item data);
      if (data.wr_en == 1) begin
          exp_value.push_back(data.din);
          `uvm_info(get_type_name(), $sformatf("WRITE: din=%0h, queue size=%0d", data.din, exp_value.size()), UVM_LOW)
      end
      if (pending_read) begin
          `uvm_info(get_type_name(), $sformatf("READ: dout=%0h, expected=%0h", data.dout, exp_value[0]), UVM_LOW)
          if (exp_value.pop_front() != data.dout)
              `uvm_error("[SCOREBOARD]", "Mismatch")
          pending_read = 0;
      end
      if (data.rd_en == 1) begin
          pending_read = 1;
      end
	endfunction
endclass


