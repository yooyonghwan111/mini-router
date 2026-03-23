// ============================================================
// mini_router_full.v
// Full RTL for EDA Playground (all modules in one file)
// Hierarchy:
//   mini_router_top
//     sync_fifo x4
//     route_ctrl
//       arbiter_rr x2
//     crossbar
// ============================================================

module arbiter_rr (
    input       clk, rst_n,
    input [3:0] req,
    input       tready,
    input       tlast,
    output reg [3:0] grant
);
    reg [1:0] last_grant;
    reg [3:0] curr_grant;

    // Combinational logic: determine grant based on req and last_grant
    always @(*) begin
        curr_grant = 4'b0000;

            case (last_grant)
                2'd0 : begin
                    if      (req[1]) curr_grant = 4'b0010;
                    else if (req[2]) curr_grant = 4'b0100;
                    else if (req[3]) curr_grant = 4'b1000;
                    else if (req[0]) curr_grant = 4'b0001;
                end
                2'd1 : begin
                    if      (req[2]) curr_grant = 4'b0100;
                    else if (req[3]) curr_grant = 4'b1000;
                    else if (req[0]) curr_grant = 4'b0001;
                    else if (req[1]) curr_grant = 4'b0010;
                end
                2'd2 : begin
                    if      (req[3]) curr_grant = 4'b1000;
                    else if (req[0]) curr_grant = 4'b0001;
                    else if (req[1]) curr_grant = 4'b0010;
                    else if (req[2]) curr_grant = 4'b0100;
                end
                2'd3 : begin
                    if      (req[0]) curr_grant = 4'b0001;
                    else if (req[1]) curr_grant = 4'b0010;
                    else if (req[2]) curr_grant = 4'b0100;
                    else if (req[3]) curr_grant = 4'b1000;
                end
            endcase
    end

    // Sequential logic: update last_grant on grant completion
    always @ (posedge clk) begin
        if (!rst_n) begin
            last_grant <= 0;
        end
        else begin
            if (|curr_grant && tlast && tready) begin
                case (curr_grant) 
                    4'b0001 : last_grant <= 0;
                    4'b0010 : last_grant <= 1;
                    4'b0100 : last_grant <= 2;
                    4'b1000 : last_grant <= 3;
                endcase
            end
        end
    end

    // Grant register: latch curr_grant when downstream is ready
    // tready=1 : update grant with new arbitration result
    // tready=0 : hold current grant (stall)
    always @ (posedge clk) begin
        if(!rst_n) begin
            grant <= 0;
        end
        else begin
            if(tready) begin
                grant <= curr_grant;
            end
        end
    end

endmodule


module sync_fifo #(parameter DEPTH=8, D_WIDTH=8)(
    input                   clk,
    input                   rst_n,
    input                   wr_en,
    input                   rd_en,
    input       [D_WIDTH-1:0] din,
    output reg  [D_WIDTH-1:0] dout,
    output                  full,
    output                  empty
);
    localparam P_INDEX = $clog2(DEPTH);

    reg [D_WIDTH-1:0] fifo [0:DEPTH-1];
    reg [P_INDEX:0] wptr;
    reg [P_INDEX:0] rptr;

    always @ (posedge clk) begin
        if(!rst_n) begin
            wptr <= 0;
        end
        else begin
            if (wr_en && !full) begin
                fifo[wptr[P_INDEX-1:0]] <= din;
                wptr <= wptr + 1'b1;
            end
        end
    end

    always @ (posedge clk) begin
        if(!rst_n) begin
            rptr <= 0;
            dout <= 0;
        end
        else begin
            if(rd_en && !empty) begin
                dout <= fifo[rptr[P_INDEX-1:0]];
                rptr <= rptr + 1'b1;
            end
        end
    end

    assign empty = (wptr == rptr);
    assign full  = (wptr[P_INDEX-1:0] == rptr[P_INDEX-1:0]) && (wptr[P_INDEX] != rptr[P_INDEX]);

endmodule


module route_ctrl(
    input       clk,
    input       rst_n,
    input [3:0] tvalid,
    input [3:0] tdest,
    input [3:0] tlast,
    input [1:0] tready,
    output [3:0] grant0,
    output [3:0] grant1
);
    wire [3:0] req0;
    wire [3:0] req1;
    wire tlast0, tlast1;
    wire [3:0] grant0_w, grant1_w;

    assign req0[0] = tvalid[0] && (tdest[0] == 1'b0);
    assign req0[1] = tvalid[1] && (tdest[1] == 1'b0);
    assign req0[2] = tvalid[2] && (tdest[2] == 1'b0);
    assign req0[3] = tvalid[3] && (tdest[3] == 1'b0);

    assign req1[0] = tvalid[0] && (tdest[0] == 1'b1);
    assign req1[1] = tvalid[1] && (tdest[1] == 1'b1);
    assign req1[2] = tvalid[2] && (tdest[2] == 1'b1);
    assign req1[3] = tvalid[3] && (tdest[3] == 1'b1);

    assign tlast0 = (grant0_w == 4'b0001) ? tlast[0] :
                    (grant0_w == 4'b0010) ? tlast[1] :
                    (grant0_w == 4'b0100) ? tlast[2] :
                    (grant0_w == 4'b1000) ? tlast[3] : 1'b0;

    assign tlast1 = (grant1_w == 4'b0001) ? tlast[0] :
                    (grant1_w == 4'b0010) ? tlast[1] :
                    (grant1_w == 4'b0100) ? tlast[2] :
                    (grant1_w == 4'b1000) ? tlast[3] : 1'b0;

    assign grant0 = grant0_w;
    assign grant1 = grant1_w;

    arbiter_rr u0 (
        .clk(clk),
        .rst_n(rst_n),
        .req(req0),
        .tlast(tlast0),
        .grant(grant0_w),
        .tready(tready[0])
    );

    arbiter_rr u1 (
        .clk(clk),
        .rst_n(rst_n),
        .req(req1),
        .tlast(tlast1),
        .grant(grant1_w),
        .tready(tready[1])
    );

endmodule


module crossbar #(parameter D_WIDTH=8)(
    input  [3:0]             tvalid,
    input  [3:0]             tlast,
    input  [3:0]             grant0,
    input  [3:0]             grant1,
    input  [(D_WIDTH*4)-1:0] tdata_in, // [7:0]=port0,[15:8]=port1,[23:16]=port2,[31:24]=port3
    output                   tvalid0,
    output                   tlast0,
    output [D_WIDTH-1:0]     tdata0,
    output                   tvalid1,
    output                   tlast1,
    output [D_WIDTH-1:0]     tdata1
);
    assign tdata0 = (grant0 == 4'b0001) ? tdata_in[7:0]   :
                    (grant0 == 4'b0010) ? tdata_in[15:8]  :
                    (grant0 == 4'b0100) ? tdata_in[23:16] :
                    (grant0 == 4'b1000) ? tdata_in[31:24] : {D_WIDTH{1'b0}};

    assign tdata1 = (grant1 == 4'b0001) ? tdata_in[7:0]   :
                    (grant1 == 4'b0010) ? tdata_in[15:8]  :
                    (grant1 == 4'b0100) ? tdata_in[23:16] :
                    (grant1 == 4'b1000) ? tdata_in[31:24] : {D_WIDTH{1'b0}};

    assign tvalid0 = (grant0 == 4'b0001) ? tvalid[0] :
                     (grant0 == 4'b0010) ? tvalid[1] :
                     (grant0 == 4'b0100) ? tvalid[2] :
                     (grant0 == 4'b1000) ? tvalid[3] : 1'b0;

    assign tvalid1 = (grant1 == 4'b0001) ? tvalid[0] :
                     (grant1 == 4'b0010) ? tvalid[1] :
                     (grant1 == 4'b0100) ? tvalid[2] :
                     (grant1 == 4'b1000) ? tvalid[3] : 1'b0;

    assign tlast0  = (grant0 == 4'b0001) ? tlast[0] :
                     (grant0 == 4'b0010) ? tlast[1] :
                     (grant0 == 4'b0100) ? tlast[2] :
                     (grant0 == 4'b1000) ? tlast[3] : 1'b0;

    assign tlast1  = (grant1 == 4'b0001) ? tlast[0] :
                     (grant1 == 4'b0010) ? tlast[1] :
                     (grant1 == 4'b0100) ? tlast[2] :
                     (grant1 == 4'b1000) ? tlast[3] : 1'b0;

endmodule


module mini_router_top #(
    parameter D_WIDTH = 8,
    parameter DEPTH   = 4
)(
    input                   clk,
    input                   rst_n,

    // Slave side (upstream -> mini_router)
    input  [D_WIDTH-1:0]    s_tdata_0,
    input  [D_WIDTH-1:0]    s_tdata_1,
    input  [D_WIDTH-1:0]    s_tdata_2,
    input  [D_WIDTH-1:0]    s_tdata_3,
    input  [3:0]            s_tvalid,
    input  [3:0]            s_tlast,
    input  [3:0]            s_tdest,
    output [3:0]            s_tready,

    // Master side (mini_router -> downstream)
    output [D_WIDTH-1:0]    m_tdata_0,
    output [D_WIDTH-1:0]    m_tdata_1,
    output [1:0]            m_tvalid,
    output [1:0]            m_tlast,
    input  [1:0]            m_tready
);

    // sync_fifo
    wire [3:0] fifo_full;
    wire [3:0] fifo_empty;
    wire [3:0] wr__s_tvalid;
    assign wr__s_tvalid = s_tvalid & ~fifo_full;
    assign s_tready     = ~fifo_full;

    // route_ctrl
    wire [3:0] grant0_o;
    wire [3:0] grant1_o;
    wire [3:0] fifo_rd_en;
    assign fifo_rd_en = grant0_o | grant1_o;

    // crossbar input bus
    wire [D_WIDTH-1:0]     data_to_data_0;
    wire [D_WIDTH-1:0]     data_to_data_1;
    wire [D_WIDTH-1:0]     data_to_data_2;
    wire [D_WIDTH-1:0]     data_to_data_3;
    wire [(D_WIDTH*4)-1:0] data_to_data;
    assign data_to_data = {data_to_data_3, data_to_data_2, data_to_data_1, data_to_data_0};

    sync_fifo #(.D_WIDTH(D_WIDTH), .DEPTH(DEPTH)) u_fifo_0 (
        .clk(clk), .rst_n(rst_n),
        .wr_en(wr__s_tvalid[0]), .rd_en(fifo_rd_en[0]),
        .din(s_tdata_0), .dout(data_to_data_0),
        .full(fifo_full[0]), .empty(fifo_empty[0])
    );

    sync_fifo #(.D_WIDTH(D_WIDTH), .DEPTH(DEPTH)) u_fifo_1 (
        .clk(clk), .rst_n(rst_n),
        .wr_en(wr__s_tvalid[1]), .rd_en(fifo_rd_en[1]),
        .din(s_tdata_1), .dout(data_to_data_1),
        .full(fifo_full[1]), .empty(fifo_empty[1])
    );

    sync_fifo #(.D_WIDTH(D_WIDTH), .DEPTH(DEPTH)) u_fifo_2 (
        .clk(clk), .rst_n(rst_n),
        .wr_en(wr__s_tvalid[2]), .rd_en(fifo_rd_en[2]),
        .din(s_tdata_2), .dout(data_to_data_2),
        .full(fifo_full[2]), .empty(fifo_empty[2])
    );

    sync_fifo #(.D_WIDTH(D_WIDTH), .DEPTH(DEPTH)) u_fifo_3 (
        .clk(clk), .rst_n(rst_n),
        .wr_en(wr__s_tvalid[3]), .rd_en(fifo_rd_en[3]),
        .din(s_tdata_3), .dout(data_to_data_3),
        .full(fifo_full[3]), .empty(fifo_empty[3])
    );

    route_ctrl u_route_ctrl (
        .clk(clk), .rst_n(rst_n),
        .tvalid(~fifo_empty),
        .tdest(s_tdest),
        .tlast(s_tlast),
        .tready(m_tready),
        .grant0(grant0_o),
        .grant1(grant1_o)
    );

    crossbar #(.D_WIDTH(D_WIDTH)) u_crossbar (
        .tvalid(~fifo_empty),
        .tlast(s_tlast),
        .grant0(grant0_o),
        .grant1(grant1_o),
        .tdata_in(data_to_data),
        .tvalid0(m_tvalid[0]),
        .tlast0(m_tlast[0]),
        .tdata0(m_tdata_0),
        .tvalid1(m_tvalid[1]),
        .tlast1(m_tlast[1]),
        .tdata1(m_tdata_1)
    );

endmodule
