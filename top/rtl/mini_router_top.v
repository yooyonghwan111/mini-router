//// mini_router_top.v
//// 4-input, 2-output AXI-Stream NoC Router
//// packed format: {tdata[D_WIDTH+3:4], tid[3:2], tdest[1], tlast[0]}
//
//module mini_router_top #(
//    parameter D_WIDTH   = 8,
//    parameter FIFO_DEPTH = 4,
//    parameter FIFO_WIDTH = D_WIDTH + 4  // {tdata, tid(2), tdest(1), tlast(1)}
//)(
//    input                   clk,
//    input                   rst_n,
//
//    // Slave side (input ports 0~3)
//    input  [D_WIDTH-1:0]    s_tdata_0, s_tdata_1, s_tdata_2, s_tdata_3,
//    input  [1:0]            s_tid_0,   s_tid_1,   s_tid_2,   s_tid_3,
//    input                   s_tdest_0, s_tdest_1, s_tdest_2, s_tdest_3,
//    input                   s_tlast_0, s_tlast_1, s_tlast_2, s_tlast_3,
//    input                   s_tvalid_0,s_tvalid_1,s_tvalid_2,s_tvalid_3,
//    output                  s_tready_0,s_tready_1,s_tready_2,s_tready_3,
//
//    // Master side (output ports 0~1)
//    input                   m_tready_0, m_tready_1,
//    output [D_WIDTH-1:0]    m_tdata_0,  m_tdata_1,
//    output [1:0]            m_tid_0,    m_tid_1,
//
//    output                  m_tlast_0,  m_tlast_1,
//    output                  m_tvalid_0, m_tvalid_1
//);
//
//    // -------------------------
//    // Internal wires
//    // -------------------------
//
//    // FIFO packed input
//    wire [FIFO_WIDTH-1:0] fifo_din_0, fifo_din_1, fifo_din_2, fifo_din_3;
//
//    // FIFO control
//    wire fifo_full_0,  fifo_full_1,  fifo_full_2,  fifo_full_3;
//    wire fifo_empty_0, fifo_empty_1, fifo_empty_2, fifo_empty_3;
//
//    // FIFO output (packed)
//    wire [FIFO_WIDTH-1:0] fifo_dout_0, fifo_dout_1, fifo_dout_2, fifo_dout_3;
//
//    // grant from route_ctrl
//    wire [3:0] grant_0, grant_1;
//
//    // rd_en: grant가 해당 포트를 선택했을 때 && downstream ready
//    wire fifo_rd_en_0, fifo_rd_en_1, fifo_rd_en_2, fifo_rd_en_3;
//
//    // -------------------------
//    // Pack: {tdata, tid, tdest, tlast}
//    // -------------------------
//    assign fifo_din_0 = {s_tdata_0, s_tid_0, s_tdest_0, s_tlast_0};
//    assign fifo_din_1 = {s_tdata_1, s_tid_1, s_tdest_1, s_tlast_1};
//    assign fifo_din_2 = {s_tdata_2, s_tid_2, s_tdest_2, s_tlast_2};
//    assign fifo_din_3 = {s_tdata_3, s_tid_3, s_tdest_3, s_tlast_3};
//
//    // -------------------------
//    // s_tready = ~fifo_full
//    // -------------------------
//    assign s_tready_0 = ~fifo_full_0;
//    assign s_tready_1 = ~fifo_full_1;
//    assign s_tready_2 = ~fifo_full_2;
//    assign s_tready_3 = ~fifo_full_3;
//
//    // -------------------------
//    // rd_en: grant가 해당 포트를 선택 && 해당 output의 m_tready
//    // -------------------------
//    assign fifo_rd_en_0 = ((grant_0[0] && m_tready_0) || (grant_1[0] && m_tready_1));
//    assign fifo_rd_en_1 = ((grant_0[1] && m_tready_0) || (grant_1[1] && m_tready_1));
//    assign fifo_rd_en_2 = ((grant_0[2] && m_tready_0) || (grant_1[2] && m_tready_1));
//    assign fifo_rd_en_3 = ((grant_0[3] && m_tready_0) || (grant_1[3] && m_tready_1));
//
//    // -------------------------
//    // sync_fifo x4
//    // -------------------------
//    sync_fifo #(.DEPTH(FIFO_DEPTH), .D_WIDTH(FIFO_WIDTH)) u_fifo_0 (
//        .clk      (clk),
//        .rst_n    (rst_n),
//        .wr_en    (s_tvalid_0 & s_tready_0),
//        .rd_en    (fifo_rd_en_0),
//        .tdata_in (fifo_din_0),
//        .tdata_out(fifo_dout_0),
//        .full     (fifo_full_0),
//        .empty    (fifo_empty_0)
//    );
//
//    sync_fifo #(.DEPTH(FIFO_DEPTH), .D_WIDTH(FIFO_WIDTH)) u_fifo_1 (
//        .clk      (clk),
//        .rst_n    (rst_n),
//        .wr_en    (s_tvalid_1 & s_tready_1),
//        .rd_en    (fifo_rd_en_1),
//        .tdata_in (fifo_din_1),
//        .tdata_out(fifo_dout_1),
//        .full     (fifo_full_1),
//        .empty    (fifo_empty_1)
//    );
//
//    sync_fifo #(.DEPTH(FIFO_DEPTH), .D_WIDTH(FIFO_WIDTH)) u_fifo_2 (
//        .clk      (clk),
//        .rst_n    (rst_n),
//        .wr_en    (s_tvalid_2 & s_tready_2),
//        .rd_en    (fifo_rd_en_2),
//        .tdata_in (fifo_din_2),
//        .tdata_out(fifo_dout_2),
//        .full     (fifo_full_2),
//        .empty    (fifo_empty_2)
//    );
//
//    sync_fifo #(.DEPTH(FIFO_DEPTH), .D_WIDTH(FIFO_WIDTH)) u_fifo_3 (
//        .clk      (clk),
//        .rst_n    (rst_n),
//        .wr_en    (s_tvalid_3 & s_tready_3),
//        .rd_en    (fifo_rd_en_3),
//        .tdata_in (fifo_din_3),
//        .tdata_out(fifo_dout_3),
//        .full     (fifo_full_3),
//        .empty    (fifo_empty_3)
//    );
//
//    // -------------------------
//    // route_ctrl
//    // -------------------------
//    route_ctrl u_route_ctrl (
//        .clk    (clk),
//        .rst_n  (rst_n),
//        .valid_0(~fifo_empty_0), .valid_1(~fifo_empty_1),
//        .valid_2(~fifo_empty_2), .valid_3(~fifo_empty_3),
//        .dest_0 (fifo_dout_0[1]), .dest_1(fifo_dout_1[1]),
//        .dest_2 (fifo_dout_2[1]), .dest_3(fifo_dout_3[1]),
//        .last_0 (m_tlast_0),  .last_1(m_tlast_1),
//        .ready_0(m_tready_0), .ready_1(m_tready_1),
//        .grant_0(grant_0),
//        .grant_1(grant_1)
//    );
//
//    // -------------------------
//    // crossbar
//    // -------------------------
//    crossbar #(.D_WIDTH(D_WIDTH), .FIFO_WIDTH(FIFO_WIDTH)) u_crossbar (
//        .grant_0   (grant_0),    .grant_1   (grant_1),
//        .data_in_0 (fifo_dout_0),.data_in_1 (fifo_dout_1),
//        .data_in_2 (fifo_dout_2),.data_in_3 (fifo_dout_3),
//        .s_valid_0 (~fifo_empty_0), .s_valid_1 (~fifo_empty_1),
//        .s_valid_2 (~fifo_empty_2), .s_valid_3 (~fifo_empty_3),
//        .m_tdata_0 (m_tdata_0), .m_tdata_1 (m_tdata_1),
//        .m_tid_0   (m_tid_0),   .m_tid_1   (m_tid_1),
//        .m_valid_0 (m_tvalid_0),.m_valid_1 (m_tvalid_1),
//
//        .m_last_0  (m_tlast_0), .m_last_1  (m_tlast_1)
//    );
//
//endmodule

// mini_router_top.v
// 4-input, 2-output AXI-Stream NoC Router
// packed format: {tdata[D_WIDTH+3:4], tid[3:2], tdest[1], tlast[0]}
// mini_router_top.v
// 4-input, 2-output AXI-Stream NoC Router
// packed format: {tdata[D_WIDTH+3:4], tid[3:2], tdest[1], tlast[0]}

module mini_router_top #(
    parameter D_WIDTH    = 8,
    parameter FIFO_DEPTH = 4,
    parameter FIFO_WIDTH = D_WIDTH + 4  // {tdata, tid(2), tdest(1), tlast(1)}
)(
    input                   clk,
    input                   rst_n,

    // Slave side (input ports 0~3)
    input  [D_WIDTH-1:0]    s_tdata_0, s_tdata_1, s_tdata_2, s_tdata_3,
    input  [1:0]            s_tid_0,   s_tid_1,   s_tid_2,   s_tid_3,
    input                   s_tdest_0, s_tdest_1, s_tdest_2, s_tdest_3,
    input                   s_tlast_0, s_tlast_1, s_tlast_2, s_tlast_3,
    input                   s_tvalid_0,s_tvalid_1,s_tvalid_2,s_tvalid_3,
    output                  s_tready_0,s_tready_1,s_tready_2,s_tready_3,

    // Master side (output ports 0~1)
    input                   m_tready_0, m_tready_1,
    output [D_WIDTH-1:0]    m_tdata_0,  m_tdata_1,
    output [1:0]            m_tid_0,    m_tid_1,
    output                  m_tlast_0,  m_tlast_1,
    output                  m_tvalid_0, m_tvalid_1
);

    // -------------------------
    // Internal wires
    // -------------------------
    wire [FIFO_WIDTH-1:0] fifo_din_0,  fifo_din_1,  fifo_din_2,  fifo_din_3;
    wire fifo_full_0,  fifo_full_1,  fifo_full_2,  fifo_full_3;
    wire fifo_empty_0, fifo_empty_1, fifo_empty_2, fifo_empty_3;
    wire [FIFO_WIDTH-1:0] fifo_dout_0, fifo_dout_1, fifo_dout_2, fifo_dout_3;
    wire [3:0] grant_0, grant_1;
    wire fifo_rd_en_0, fifo_rd_en_1, fifo_rd_en_2, fifo_rd_en_3;

    // -------------------------
    // Pack: {tdata, tid, tdest, tlast}
    // -------------------------
    assign fifo_din_0 = {s_tdata_0, s_tid_0, s_tdest_0, s_tlast_0};
    assign fifo_din_1 = {s_tdata_1, s_tid_1, s_tdest_1, s_tlast_1};
    assign fifo_din_2 = {s_tdata_2, s_tid_2, s_tdest_2, s_tlast_2};
    assign fifo_din_3 = {s_tdata_3, s_tid_3, s_tdest_3, s_tlast_3};

    // -------------------------
    // s_tready = ~fifo_full
    // -------------------------
    assign s_tready_0 = ~fifo_full_0;
    assign s_tready_1 = ~fifo_full_1;
    assign s_tready_2 = ~fifo_full_2;
    assign s_tready_3 = ~fifo_full_3;

    // -------------------------
    // rd_en: grant된 포트 && downstream ready (beat 단위)
    // sync_fifo가 FWFT(combinational output)이므로
    // grant && m_tready 조건으로 beat마다 rptr 증가
    // -------------------------
    assign fifo_rd_en_0 = ((grant_0[0] && m_tready_0) || (grant_1[0] && m_tready_1));
    assign fifo_rd_en_1 = ((grant_0[1] && m_tready_0) || (grant_1[1] && m_tready_1));
    assign fifo_rd_en_2 = ((grant_0[2] && m_tready_0) || (grant_1[2] && m_tready_1));
    assign fifo_rd_en_3 = ((grant_0[3] && m_tready_0) || (grant_1[3] && m_tready_1));

    // -------------------------
    // sync_fifo x4
    // -------------------------
    sync_fifo #(.DEPTH(FIFO_DEPTH), .D_WIDTH(FIFO_WIDTH)) u_fifo_0 (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (s_tvalid_0 & s_tready_0),
        .rd_en    (fifo_rd_en_0),
        .tdata_in (fifo_din_0),
        .tdata_out(fifo_dout_0),
        .full     (fifo_full_0),
        .empty    (fifo_empty_0)
    );

    sync_fifo #(.DEPTH(FIFO_DEPTH), .D_WIDTH(FIFO_WIDTH)) u_fifo_1 (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (s_tvalid_1 & s_tready_1),
        .rd_en    (fifo_rd_en_1),
        .tdata_in (fifo_din_1),
        .tdata_out(fifo_dout_1),
        .full     (fifo_full_1),
        .empty    (fifo_empty_1)
    );

    sync_fifo #(.DEPTH(FIFO_DEPTH), .D_WIDTH(FIFO_WIDTH)) u_fifo_2 (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (s_tvalid_2 & s_tready_2),
        .rd_en    (fifo_rd_en_2),
        .tdata_in (fifo_din_2),
        .tdata_out(fifo_dout_2),
        .full     (fifo_full_2),
        .empty    (fifo_empty_2)
    );

    sync_fifo #(.DEPTH(FIFO_DEPTH), .D_WIDTH(FIFO_WIDTH)) u_fifo_3 (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (s_tvalid_3 & s_tready_3),
        .rd_en    (fifo_rd_en_3),
        .tdata_in (fifo_din_3),
        .tdata_out(fifo_dout_3),
        .full     (fifo_full_3),
        .empty    (fifo_empty_3)
    );

    // -------------------------
    // route_ctrl
    // -------------------------
    route_ctrl u_route_ctrl (
        .clk    (clk),
        .rst_n  (rst_n),
        .valid_0(~fifo_empty_0), .valid_1(~fifo_empty_1),
        .valid_2(~fifo_empty_2), .valid_3(~fifo_empty_3),
        .dest_0 (fifo_dout_0[1]), .dest_1(fifo_dout_1[1]),
        .dest_2 (fifo_dout_2[1]), .dest_3(fifo_dout_3[1]),
        .last_0 (m_tlast_0),  .last_1(m_tlast_1),
        .ready_0(m_tready_0), .ready_1(m_tready_1),
        .grant_0(grant_0),
        .grant_1(grant_1)
    );

    // -------------------------
    // crossbar
    // -------------------------
    crossbar #(.D_WIDTH(D_WIDTH), .FIFO_WIDTH(FIFO_WIDTH)) u_crossbar (
        .grant_0   (grant_0),       .grant_1   (grant_1),
        .data_in_0 (fifo_dout_0),   .data_in_1 (fifo_dout_1),
        .data_in_2 (fifo_dout_2),   .data_in_3 (fifo_dout_3),
        .s_valid_0 (~fifo_empty_0), .s_valid_1 (~fifo_empty_1),
        .s_valid_2 (~fifo_empty_2), .s_valid_3 (~fifo_empty_3),
        .m_tdata_0 (m_tdata_0),     .m_tdata_1 (m_tdata_1),
        .m_tid_0   (m_tid_0),       .m_tid_1   (m_tid_1),
        .m_valid_0 (m_tvalid_0),    .m_valid_1 (m_tvalid_1),
        .m_last_0  (m_tlast_0),     .m_last_1  (m_tlast_1)
    );

endmodule