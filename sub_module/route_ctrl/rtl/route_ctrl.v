module route_ctrl(
    input clk, 
    input rst_n,
    input [3:0] tvalid,
    input [3:0] tdest,
    input [3:0] tlast,
    output [3:0] grant0,
    output [3:0] grant1
);

    wire [3:0] req0;
    wire [3:0] req1;

    wire tlast0;
    wire tlast1;

    wire [3:0] grant0_w;
    wire [3:0] grant1_w;

    assign req0[0] = tvalid[0] && (tdest[0]==1'b0);
    assign req0[1] = tvalid[1] && (tdest[1]==1'b0);
    assign req0[2] = tvalid[2] && (tdest[2]==1'b0);
    assign req0[3] = tvalid[3] && (tdest[3]==1'b0);

    assign req1[0] = tvalid[0] && (tdest[0]==1'b1);
    assign req1[1] = tvalid[1] && (tdest[1]==1'b1);
    assign req1[2] = tvalid[2] && (tdest[2]==1'b1);
    assign req1[3] = tvalid[3] && (tdest[3]==1'b1);

    assign tlast0 = (grant0_w == 4'b0001) ? tlast[0] : 
                    (grant0_w == 4'b0010) ? tlast[1] : 
                    (grant0_w == 4'b0100) ? tlast[2] : 
                    (grant0_w == 4'b1000) ? tlast[3] : 
                    1'b0;        

    assign tlast1 = (grant1_w == 4'b0001) ? tlast[0] : 
                    (grant1_w == 4'b0010) ? tlast[1] : 
                    (grant1_w == 4'b0100) ? tlast[2] : 
                    (grant1_w == 4'b1000) ? tlast[3] : 
                    1'b0;                            


    assign grant0 = grant0_w;
    assign grant1 = grant1_w;

    arbiter_rr u0 (
        .clk(clk),
        .rst_n(rst_n),
        .req(req0),
        .tlast(tlast0),
        .grant(grant0_w)
    );

    arbiter_rr u1 (
        .clk(clk),
        .rst_n(rst_n),
        .req(req1),
        .tlast(tlast1),
        .grant(grant1_w)
    );

endmodule
