module arbiter_rr (
    input clk, rst_n,
    input [3:0] req,
    input tlast,
    output reg [3:0] grant
);
    reg [1:0] last_grant;

    // Sequential logic: update last_grant on grant completion
    always @ (posedge clk) begin
        if (!rst_n) begin
            last_grant <= 0;
        end
        else begin
            if (|grant && tlast) begin
                case (grant) 
                    4'b0001 : last_grant <= 0;
                    4'b0010 : last_grant <= 1;
                    4'b0100 : last_grant <= 2;
                    4'b1000 : last_grant <= 3;
                endcase
            end
        end
    end

    // Combinational logic: determine grant based on req and last_grant
    always @(*) begin
        grant = 4'b0000;
        
        case (last_grant)
            2'd0 : begin
                if      (req[1]) grant = 4'b0010;
                else if (req[2]) grant = 4'b0100;
                else if (req[3]) grant = 4'b1000;
                else if (req[0]) grant = 4'b0001;
            end
            2'd1 : begin
                if      (req[2]) grant = 4'b0100;
                else if (req[3]) grant = 4'b1000;
                else if (req[0]) grant = 4'b0001;
                else if (req[1]) grant = 4'b0010;
            end
            2'd2 : begin
                if      (req[3]) grant = 4'b1000;
                else if (req[0]) grant = 4'b0001;
                else if (req[1]) grant = 4'b0010;
                else if (req[2]) grant = 4'b0100;
            end
            2'd3 : begin
                if      (req[0]) grant = 4'b0001;
                else if (req[1]) grant = 4'b0010;
                else if (req[2]) grant = 4'b0100;
                else if (req[3]) grant = 4'b1000;
            end
        endcase
    end
endmodule
