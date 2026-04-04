module arbiter_rr (
    input       		clk,
	input 				rst_n,
    input       [3:0]	req,
    input       		ready,
    input       		last,
    output reg  [3:0]   grant
);
    reg [3:0] last_grant;

    // Update last_grant
    always @ (posedge clk) begin
        if (!rst_n) begin
            last_grant <= 4'b0000;
        end
        else begin
            if (last && ready) begin
                last_grant <= grant;
            end
        end
    end

    //Update grant
    always @ (posedge clk) begin
        if (!rst_n) begin
            grant <= 4'b0000;
        end

        else begin
            if ((grant==4'b0000) && |req) begin // first arriving request
                if      (req[0]) grant <= 4'b0001;
                else if (req[1]) grant <= 4'b0010;
                else if (req[2]) grant <= 4'b0100;
                else if (req[3]) grant <= 4'b1000;

            end

            else if (ready && last) begin // select next grant by round-robin
                case (last_grant)
                    4'b0001 : begin
                        if      (req[1]) grant <= 4'b0010;
                        else if (req[2]) grant <= 4'b0100;
                        else if (req[3]) grant <= 4'b1000;
                        else if (req[0]) grant <= 4'b0001;
                    end

                    4'b0010 : begin
                        if      (req[2]) grant <= 4'b0100;
                        else if (req[3]) grant <= 4'b1000;
                        else if (req[0]) grant <= 4'b0001;
                        else if (req[1]) grant <= 4'b0010;
                    end
                    
                    4'b0100 : begin
                        if      (req[3]) grant <= 4'b1000;
                        else if (req[0]) grant <= 4'b0001;
                        else if (req[1]) grant <= 4'b0010;
                        else if (req[2]) grant <= 4'b0100;
                    end

                    4'b1000 : begin
                        if      (req[0]) grant <= 4'b0001;
                        else if (req[1]) grant <= 4'b0010;
                        else if (req[2]) grant <= 4'b0100;
                        else if (req[3]) grant <= 4'b1000;
                    end                                              
                             
                endcase
            end
        end
    end

endmodule