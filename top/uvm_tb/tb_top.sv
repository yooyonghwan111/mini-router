module tb_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    initial dut_if1.clk = 0;
    always #10 dut_if1.clk = ~dut_if1.clk;

    router_if #(.D_WIDTH(8)) dut_if1 ();

    // [변경] DUT 포트 개별 신호로 연결 + tid 추가, parameter FIFO_DEPTH로 수정
    mini_router_top #(.D_WIDTH(8), .FIFO_DEPTH(4)) dut (
        .clk        (dut_if1.clk),
        .rst_n      (dut_if1.rst_n),

        .s_tdata_0  (dut_if1.s_tdata_0),  .s_tdata_1  (dut_if1.s_tdata_1),
        .s_tdata_2  (dut_if1.s_tdata_2),  .s_tdata_3  (dut_if1.s_tdata_3),
        .s_tid_0    (dut_if1.s_tid_0),    .s_tid_1    (dut_if1.s_tid_1),    
        .s_tid_2    (dut_if1.s_tid_2),    .s_tid_3    (dut_if1.s_tid_3),    
        .s_tdest_0  (dut_if1.s_tdest_0),  .s_tdest_1  (dut_if1.s_tdest_1),
        .s_tdest_2  (dut_if1.s_tdest_2),  .s_tdest_3  (dut_if1.s_tdest_3),
        .s_tlast_0  (dut_if1.s_tlast_0),  .s_tlast_1  (dut_if1.s_tlast_1),
        .s_tlast_2  (dut_if1.s_tlast_2),  .s_tlast_3  (dut_if1.s_tlast_3),
        .s_tvalid_0 (dut_if1.s_tvalid_0), .s_tvalid_1 (dut_if1.s_tvalid_1),
        .s_tvalid_2 (dut_if1.s_tvalid_2), .s_tvalid_3 (dut_if1.s_tvalid_3),
        .s_tready_0 (dut_if1.s_tready_0), .s_tready_1 (dut_if1.s_tready_1),
        .s_tready_2 (dut_if1.s_tready_2), .s_tready_3 (dut_if1.s_tready_3),

        .m_tready_0 (dut_if1.m_tready_0), .m_tready_1 (dut_if1.m_tready_1),
        .m_tdata_0  (dut_if1.m_tdata_0),  .m_tdata_1  (dut_if1.m_tdata_1),
        .m_tid_0    (dut_if1.m_tid_0),    .m_tid_1    (dut_if1.m_tid_1),    
        .m_tlast_0  (dut_if1.m_tlast_0),  .m_tlast_1  (dut_if1.m_tlast_1),
        .m_tvalid_0 (dut_if1.m_tvalid_0), .m_tvalid_1 (dut_if1.m_tvalid_1)
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
        dut_if1.rst_n    = 0;
        // [변경] 개별 신호로 초기화
        dut_if1.m_tready_0 = 1; dut_if1.m_tready_1 = 1;
        dut_if1.s_tvalid_0 = 0; dut_if1.s_tvalid_1 = 0;
        dut_if1.s_tvalid_2 = 0; dut_if1.s_tvalid_3 = 0;
        dut_if1.s_tlast_0  = 0; dut_if1.s_tlast_1  = 0;
        dut_if1.s_tlast_2  = 0; dut_if1.s_tlast_3  = 0;
        dut_if1.s_tdest_0  = 0; dut_if1.s_tdest_1  = 0;
        dut_if1.s_tdest_2  = 0; dut_if1.s_tdest_3  = 0;
        dut_if1.s_tid_0    = 0; dut_if1.s_tid_1    = 0; 
        dut_if1.s_tid_2    = 0; dut_if1.s_tid_3    = 0; 
        #40 dut_if1.rst_n = 1;
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
