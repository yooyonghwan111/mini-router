module tb_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    initial dut_if1.clk = 0;
    always #10 dut_if1.clk = ~dut_if1.clk;

    // interface 인스턴스화
    router_if #(.D_WIDTH(8)) dut_if1 ();

    // DUT 연결
    mini_router_top #(.DEPTH(4), .D_WIDTH(8)) dut (
        .clk        (dut_if1.clk),
        .rst_n      (dut_if1.rst_n),
        .s_tdata_0  (dut_if1.s_tdata_0),
        .s_tdata_1  (dut_if1.s_tdata_1),
        .s_tdata_2  (dut_if1.s_tdata_2),
        .s_tdata_3  (dut_if1.s_tdata_3),
        .s_tvalid   (dut_if1.s_tvalid),
        .s_tlast    (dut_if1.s_tlast),
        .s_tdest    (dut_if1.s_tdest),
        .s_tready   (dut_if1.s_tready),
        .m_tdata_0  (dut_if1.m_tdata_0),
        .m_tdata_1  (dut_if1.m_tdata_1),
        .m_tvalid   (dut_if1.m_tvalid),
        .m_tlast    (dut_if1.m_tlast),
        .m_tready   (dut_if1.m_tready)
    );


    // // SVA bind
    // bind mini_router_top mini_router_sva_if #(.D_WIDTH(8)) sva_if (
    //     .clk      (clk),
    //     .rst_n    (rst_n),
    //     .s_tvalid (s_tvalid),
    //     .s_tready (s_tready),
    //     .s_tlast  (s_tlast),
    //     .s_tdest  (s_tdest),
    //     .s_tdata_0(s_tdata_0),
    //     .s_tdata_1(s_tdata_1),
    //     .s_tdata_2(s_tdata_2),
    //     .s_tdata_3(s_tdata_3),
    //     .m_tvalid (m_tvalid),
    //     .m_tready (m_tready),
    //     .m_tlast  (m_tlast)
    // );


    initial begin
        dut_if1.rst_n = 0;
        dut_if1.m_tready = 2'b11;
        dut_if1.s_tvalid = 4'b0;
        dut_if1.s_tlast  = 4'b0;
        dut_if1.s_tdest  = 4'b0;    
        #20 dut_if1.rst_n = 1;
    end
  
  	initial begin
      uvm_config_db #(virtual router_if #(.D_WIDTH(8)))::set(null, "uvm_test_top.*", "vif", dut_if1);
      run_test("router_basic_test");

    end


	initial begin
      $dumpfile("dump.vcd");
      $dumpvars(0, tb_top);
	end

endmodule
