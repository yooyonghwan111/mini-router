module route_ctrl(

    input clk, 
    input rst_n,
    
    input valid_0,
    input valid_1,
    input valid_2,
    input valid_3,

    input dest_0,
    input dest_1,
    input dest_2,
    input dest_3,

    input last_0,
    input last_1,

    input ready_0,
    input ready_1,

    output [3:0] grant_0,
    output [3:0] grant_1

);
    // arbiter_0 (grant_0)
    wire [3:0] req_0;

    assign req_0[0] = valid_0 && (dest_0 == 1'b0);
    assign req_0[1] = valid_1 && (dest_1 == 1'b0);
    assign req_0[2] = valid_2 && (dest_2 == 1'b0);
    assign req_0[3] = valid_3 && (dest_3 == 1'b0);


    // arbiter_1 (grant_1)
    wire [3:0] req_1;

    assign req_1[0] = valid_0 && (dest_0 == 1'b1);
    assign req_1[1] = valid_1 && (dest_1 == 1'b1);
    assign req_1[2] = valid_2 && (dest_2 == 1'b1);
    assign req_1[3] = valid_3 && (dest_3 == 1'b1);

    
    arbiter_rr u0 (
        .clk(clk),
        .rst_n(rst_n),
        .req(req_0),
        .ready(ready_0),
        .last(last_0),
        .grant(grant_0)
    );

    arbiter_rr u1 (
        .clk(clk),
        .rst_n(rst_n),
        .req(req_1),
        .ready(ready_1),
        .last(last_1),
        .grant(grant_1)
    );


endmodule