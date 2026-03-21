module fifo_tb_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    bit clk;
    bit rst_n;

    always #10 clk = ~clk;

    // interface 인스턴스화
    sync_fifo_if #(.D_WIDTH(8)) dut_if1 (clk, rst_n);

    // DUT 연결
    sync_fifo #(.DEPTH(16) ,.D_WIDTH(8)) dut (
        .clk    (dut_if1.clk),
        .rst_n  (dut_if1.rst_n),
        .wr_en  (dut_if1.wr_en),
        .rd_en  (dut_if1.rd_en),
        .din    (dut_if1.din),
        .dout   (dut_if1.dout),
        .full   (dut_if1.full),
        .empty  (dut_if1.empty)
    );

    initial begin
        rst_n = 0;
        #20 rst_n = 1;
    end
  
  	initial begin
      uvm_config_db #(virtual sync_fifo_if #(.D_WIDTH(8)))::set(null, "uvm_test_top.*", "vif", dut_if1);
      run_test("fifo_basic_test");

    end
  
  	
 


	initial begin
      $dumpfile("dump.vcd");
      $dumpvars(0, fifo_tb_top);
	end

endmodule