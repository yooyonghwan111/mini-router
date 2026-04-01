// =============================================================
// mini_router_all.v
// EDA Playground용 통합 파일
// 모듈 순서: sync_fifo → arbiter_rr → route_ctrl → crossbar → mini_router_top
// packed format: {tdata[D_WIDTH+3:4], tid[3:2], tdest[1], tlast[0]}
// =============================================================


// =============================================================
// sync_fifo (FWFT: combinational output)
// =============================================================
module sync_fifo #(parameter DEPTH=4, D_WIDTH=8)(
    input                   clk,
    input                   rst_n,
    input                   wr_en,
    input                   rd_en,
    input  [D_WIDTH-1:0]    tdata_in,
    output [D_WIDTH-1:0]    tdata_out,  // FWFT: combinational
    output                  full,
    output                  empty
);
    localparam P_INDEX = $clog2(DEPTH);

    reg [D_WIDTH-1:0] fifo [0:DEPTH-1];
    reg [P_INDEX:0]   wptr;
    reg [P_INDEX:0]   rptr;

    // write
    always @(posedge clk) begin
        if (!rst_n) begin
            wptr <= 0;
        end else begin
            if (wr_en && !full) begin
                fifo[wptr[P_INDEX-1:0]] <= tdata_in;
                wptr <= wptr + 1'b1;
            end
        end
    end

    // read: rptr만 업데이트
    always @(posedge clk) begin
        if (!rst_n) begin
            rptr <= 0;
        end else begin
            if (rd_en && !empty) begin
                rptr <= rptr + 1'b1;
            end
        end
    end

    // FWFT combinational output
    assign tdata_out = fifo[rptr[P_INDEX-1:0]];
    assign empty     = (wptr == rptr);
    assign full      = (wptr[P_INDEX-1:0] == rptr[P_INDEX-1:0]) &&
                       (wptr[P_INDEX] != rptr[P_INDEX]);

endmodule


// =============================================================
// arbiter_rr (round-robin, one-hot grant)
// fix: case(grant) 직접 참조, req 없을 때 grant=0 리셋
// =============================================================
module arbiter_rr (
    input           clk,
    input           rst_n,
    input  [3:0]    req,
    input           ready,
    input           last,
    output reg [3:0] grant
);

    always @(posedge clk) begin
        if (!rst_n) begin
            grant <= 4'b0000;
        end else begin
            // 첫 번째 req 도착
            if ((grant == 4'b0000) && |req) begin
                if      (req[0]) grant <= 4'b0001;
                else if (req[1]) grant <= 4'b0010;
                else if (req[2]) grant <= 4'b0100;
                else if (req[3]) grant <= 4'b1000;
                else             grant <= 4'b0000;

            // 패킷 끝: round-robin으로 next grant 선택
            end else if (ready && last) begin
                case (grant)  // last_grant 대신 grant 직접 참조 (NB 타이밍 문제 방지)
                    4'b0001: begin
                        if      (req[1]) grant <= 4'b0010;
                        else if (req[2]) grant <= 4'b0100;
                        else if (req[3]) grant <= 4'b1000;
                        else if (req[0]) grant <= 4'b0001;
                        else             grant <= 4'b0000;
                    end
                    4'b0010: begin
                        if      (req[2]) grant <= 4'b0100;
                        else if (req[3]) grant <= 4'b1000;
                        else if (req[0]) grant <= 4'b0001;
                        else if (req[1]) grant <= 4'b0010;
                        else             grant <= 4'b0000;
                    end
                    4'b0100: begin
                        if      (req[3]) grant <= 4'b1000;
                        else if (req[0]) grant <= 4'b0001;
                        else if (req[1]) grant <= 4'b0010;
                        else if (req[2]) grant <= 4'b0100;
                        else             grant <= 4'b0000;
                    end
                    4'b1000: begin
                        if      (req[0]) grant <= 4'b0001;
                        else if (req[1]) grant <= 4'b0010;
                        else if (req[2]) grant <= 4'b0100;
                        else if (req[3]) grant <= 4'b1000;
                        else             grant <= 4'b0000;
                    end
                    default: grant <= 4'b0000;
                endcase
            end
        end
    end

endmodule


// =============================================================
// route_ctrl
// =============================================================
module route_ctrl (
    input       clk,
    input       rst_n,

    input       valid_0, valid_1, valid_2, valid_3,
    input       dest_0,  dest_1,  dest_2,  dest_3,
    input       last_0,  last_1,
    input       ready_0, ready_1,

    output [3:0] grant_0,
    output [3:0] grant_1
);
    wire [3:0] req_0, req_1;

    assign req_0[0] = valid_0 && (dest_0 == 1'b0);
    assign req_0[1] = valid_1 && (dest_1 == 1'b0);
    assign req_0[2] = valid_2 && (dest_2 == 1'b0);
    assign req_0[3] = valid_3 && (dest_3 == 1'b0);

    assign req_1[0] = valid_0 && (dest_0 == 1'b1);
    assign req_1[1] = valid_1 && (dest_1 == 1'b1);
    assign req_1[2] = valid_2 && (dest_2 == 1'b1);
    assign req_1[3] = valid_3 && (dest_3 == 1'b1);

    arbiter_rr u0 (
        .clk(clk), .rst_n(rst_n),
        .req(req_0), .ready(ready_0), .last(last_0),
        .grant(grant_0)
    );

    arbiter_rr u1 (
        .clk(clk), .rst_n(rst_n),
        .req(req_1), .ready(ready_1), .last(last_1),
        .grant(grant_1)
    );

endmodule


// =============================================================
// crossbar (pure combinational)
// =============================================================
module crossbar #(
    parameter D_WIDTH    = 8,
    parameter FIFO_WIDTH = D_WIDTH + 4
)(
    input  [3:0]            grant_0,  grant_1,
    input  [FIFO_WIDTH-1:0] data_in_0, data_in_1, data_in_2, data_in_3,
    input                   s_valid_0, s_valid_1, s_valid_2, s_valid_3,

    output [D_WIDTH-1:0]    m_tdata_0, m_tdata_1,
    output [1:0]            m_tid_0,   m_tid_1,
    output                  m_valid_0, m_valid_1,
    output                  m_dest_0,  m_dest_1,
    output                  m_last_0,  m_last_1
);
    // tdata: [FIFO_WIDTH-1:4]
    assign m_tdata_0 = (grant_0 == 4'b0001) ? data_in_0[FIFO_WIDTH-1:4] :
                       (grant_0 == 4'b0010) ? data_in_1[FIFO_WIDTH-1:4] :
                       (grant_0 == 4'b0100) ? data_in_2[FIFO_WIDTH-1:4] :
                       (grant_0 == 4'b1000) ? data_in_3[FIFO_WIDTH-1:4] :
                       {D_WIDTH{1'b0}};

    assign m_tdata_1 = (grant_1 == 4'b0001) ? data_in_0[FIFO_WIDTH-1:4] :
                       (grant_1 == 4'b0010) ? data_in_1[FIFO_WIDTH-1:4] :
                       (grant_1 == 4'b0100) ? data_in_2[FIFO_WIDTH-1:4] :
                       (grant_1 == 4'b1000) ? data_in_3[FIFO_WIDTH-1:4] :
                       {D_WIDTH{1'b0}};

    // tlast: [0]
    assign m_last_0 = (grant_0 == 4'b0001) ? data_in_0[0] :
                      (grant_0 == 4'b0010) ? data_in_1[0] :
                      (grant_0 == 4'b0100) ? data_in_2[0] :
                      (grant_0 == 4'b1000) ? data_in_3[0] : 1'b0;

    assign m_last_1 = (grant_1 == 4'b0001) ? data_in_0[0] :
                      (grant_1 == 4'b0010) ? data_in_1[0] :
                      (grant_1 == 4'b0100) ? data_in_2[0] :
                      (grant_1 == 4'b1000) ? data_in_3[0] : 1'b0;

    // tdest: [1]
    assign m_dest_0 = (grant_0 == 4'b0001) ? data_in_0[1] :
                      (grant_0 == 4'b0010) ? data_in_1[1] :
                      (grant_0 == 4'b0100) ? data_in_2[1] :
                      (grant_0 == 4'b1000) ? data_in_3[1] : 1'b0;

    assign m_dest_1 = (grant_1 == 4'b0001) ? data_in_0[1] :
                      (grant_1 == 4'b0010) ? data_in_1[1] :
                      (grant_1 == 4'b0100) ? data_in_2[1] :
                      (grant_1 == 4'b1000) ? data_in_3[1] : 1'b0;

    // tid: [3:2]
    assign m_tid_0 = (grant_0 == 4'b0001) ? data_in_0[3:2] :
                     (grant_0 == 4'b0010) ? data_in_1[3:2] :
                     (grant_0 == 4'b0100) ? data_in_2[3:2] :
                     (grant_0 == 4'b1000) ? data_in_3[3:2] : 2'b00;

    assign m_tid_1 = (grant_1 == 4'b0001) ? data_in_0[3:2] :
                     (grant_1 == 4'b0010) ? data_in_1[3:2] :
                     (grant_1 == 4'b0100) ? data_in_2[3:2] :
                     (grant_1 == 4'b1000) ? data_in_3[3:2] : 2'b00;

    // valid
    assign m_valid_0 = (grant_0 == 4'b0001) ? s_valid_0 :
                       (grant_0 == 4'b0010) ? s_valid_1 :
                       (grant_0 == 4'b0100) ? s_valid_2 :
                       (grant_0 == 4'b1000) ? s_valid_3 : 1'b0;

    assign m_valid_1 = (grant_1 == 4'b0001) ? s_valid_0 :
                       (grant_1 == 4'b0010) ? s_valid_1 :
                       (grant_1 == 4'b0100) ? s_valid_2 :
                       (grant_1 == 4'b1000) ? s_valid_3 : 1'b0;

endmodule


// =============================================================
// mini_router_top
// 4-input × 2-output AXI-Stream NoC Router
// =============================================================
module mini_router_top #(
    parameter D_WIDTH    = 8,
    parameter FIFO_DEPTH = 4,
    parameter FIFO_WIDTH = D_WIDTH + 4  // {tdata(8), tid(2), tdest(1), tlast(1)}
)(
    input                   clk,
    input                   rst_n,

    // Slave side (input ports 0~3)
    input  [D_WIDTH-1:0]    s_tdata_0,  s_tdata_1,  s_tdata_2,  s_tdata_3,
    input  [1:0]            s_tid_0,    s_tid_1,    s_tid_2,    s_tid_3,
    input                   s_tdest_0,  s_tdest_1,  s_tdest_2,  s_tdest_3,
    input                   s_tlast_0,  s_tlast_1,  s_tlast_2,  s_tlast_3,
    input                   s_tvalid_0, s_tvalid_1, s_tvalid_2, s_tvalid_3,
    output                  s_tready_0, s_tready_1, s_tready_2, s_tready_3,

    // Master side (output ports 0~1)
    input                   m_tready_0, m_tready_1,
    output [D_WIDTH-1:0]    m_tdata_0,  m_tdata_1,
    output [1:0]            m_tid_0,    m_tid_1,
    output                  m_tlast_0,  m_tlast_1,
    output                  m_tvalid_0, m_tvalid_1
);

    wire [FIFO_WIDTH-1:0] fifo_din_0,  fifo_din_1,  fifo_din_2,  fifo_din_3;
    wire [FIFO_WIDTH-1:0] fifo_dout_0, fifo_dout_1, fifo_dout_2, fifo_dout_3;
    wire fifo_full_0,  fifo_full_1,  fifo_full_2,  fifo_full_3;
    wire fifo_empty_0, fifo_empty_1, fifo_empty_2, fifo_empty_3;
    wire [3:0] grant_0, grant_1;
    wire fifo_rd_en_0, fifo_rd_en_1, fifo_rd_en_2, fifo_rd_en_3;

    // Pack: {tdata, tid, tdest, tlast}
    assign fifo_din_0 = {s_tdata_0, s_tid_0, s_tdest_0, s_tlast_0};
    assign fifo_din_1 = {s_tdata_1, s_tid_1, s_tdest_1, s_tlast_1};
    assign fifo_din_2 = {s_tdata_2, s_tid_2, s_tdest_2, s_tlast_2};
    assign fifo_din_3 = {s_tdata_3, s_tid_3, s_tdest_3, s_tlast_3};

    // s_tready = ~fifo_full
    assign s_tready_0 = ~fifo_full_0;
    assign s_tready_1 = ~fifo_full_1;
    assign s_tready_2 = ~fifo_full_2;
    assign s_tready_3 = ~fifo_full_3;

    // rd_en: grant된 port && downstream ready (beat 단위)
    assign fifo_rd_en_0 = (grant_0[0] && m_tready_0) || (grant_1[0] && m_tready_1);
    assign fifo_rd_en_1 = (grant_0[1] && m_tready_0) || (grant_1[1] && m_tready_1);
    assign fifo_rd_en_2 = (grant_0[2] && m_tready_0) || (grant_1[2] && m_tready_1);
    assign fifo_rd_en_3 = (grant_0[3] && m_tready_0) || (grant_1[3] && m_tready_1);

    sync_fifo #(.DEPTH(FIFO_DEPTH), .D_WIDTH(FIFO_WIDTH)) u_fifo_0 (
        .clk(clk), .rst_n(rst_n),
        .wr_en(s_tvalid_0 & s_tready_0), .rd_en(fifo_rd_en_0),
        .tdata_in(fifo_din_0), .tdata_out(fifo_dout_0),
        .full(fifo_full_0), .empty(fifo_empty_0)
    );
    sync_fifo #(.DEPTH(FIFO_DEPTH), .D_WIDTH(FIFO_WIDTH)) u_fifo_1 (
        .clk(clk), .rst_n(rst_n),
        .wr_en(s_tvalid_1 & s_tready_1), .rd_en(fifo_rd_en_1),
        .tdata_in(fifo_din_1), .tdata_out(fifo_dout_1),
        .full(fifo_full_1), .empty(fifo_empty_1)
    );
    sync_fifo #(.DEPTH(FIFO_DEPTH), .D_WIDTH(FIFO_WIDTH)) u_fifo_2 (
        .clk(clk), .rst_n(rst_n),
        .wr_en(s_tvalid_2 & s_tready_2), .rd_en(fifo_rd_en_2),
        .tdata_in(fifo_din_2), .tdata_out(fifo_dout_2),
        .full(fifo_full_2), .empty(fifo_empty_2)
    );
    sync_fifo #(.DEPTH(FIFO_DEPTH), .D_WIDTH(FIFO_WIDTH)) u_fifo_3 (
        .clk(clk), .rst_n(rst_n),
        .wr_en(s_tvalid_3 & s_tready_3), .rd_en(fifo_rd_en_3),
        .tdata_in(fifo_din_3), .tdata_out(fifo_dout_3),
        .full(fifo_full_3), .empty(fifo_empty_3)
    );

    route_ctrl u_route_ctrl (
        .clk(clk), .rst_n(rst_n),
        .valid_0(~fifo_empty_0), .valid_1(~fifo_empty_1),
        .valid_2(~fifo_empty_2), .valid_3(~fifo_empty_3),
        .dest_0(fifo_dout_0[1]), .dest_1(fifo_dout_1[1]),
        .dest_2(fifo_dout_2[1]), .dest_3(fifo_dout_3[1]),
        .last_0(m_tlast_0),  .last_1(m_tlast_1),
        .ready_0(m_tready_0), .ready_1(m_tready_1),
        .grant_0(grant_0), .grant_1(grant_1)
    );

    crossbar #(.D_WIDTH(D_WIDTH), .FIFO_WIDTH(FIFO_WIDTH)) u_crossbar (
        .grant_0(grant_0),       .grant_1(grant_1),
        .data_in_0(fifo_dout_0), .data_in_1(fifo_dout_1),
        .data_in_2(fifo_dout_2), .data_in_3(fifo_dout_3),
        .s_valid_0(~fifo_empty_0), .s_valid_1(~fifo_empty_1),
        .s_valid_2(~fifo_empty_2), .s_valid_3(~fifo_empty_3),
        .m_tdata_0(m_tdata_0),  .m_tdata_1(m_tdata_1),
        .m_tid_0(m_tid_0),      .m_tid_1(m_tid_1),
        .m_valid_0(m_tvalid_0), .m_valid_1(m_tvalid_1),
        .m_last_0(m_tlast_0),   .m_last_1(m_tlast_1)
    );

endmodule
