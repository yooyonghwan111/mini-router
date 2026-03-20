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
