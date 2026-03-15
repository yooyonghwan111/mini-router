module tb_arbiter_rr ();
    reg clk, rst_n;
    reg [3:0] req;
    reg tlast;
    wire [3:0] grant;

    arbiter_rr u0 (
        .clk(clk),
        .rst_n(rst_n),
        .req(req),
        .tlast(tlast),
        .grant(grant)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // 1. Check last_grant is initialized to 0 on reset
        req=4'b0000; tlast=0; rst_n=0;
        #15;
        rst_n=1;

        // 2. Check grant is 1-hot when all ports request simultaneously
        #20;
        req=4'b1111; tlast=1;
        #10;
        tlast=0;
		  
		  // 4. Check grant is 0 when no request
		  #10; tlast =1; // exp : grant = 0010
		  #10; tlast =0;

		  #10; tlast =1; // exp : grant = 0100
		  #10; tlast =0;

		  #10; tlast =1; // exp : grant = 1000
		  #10; tlast =0;
		  
		  #10; tlast =1; // exp : grant = 0001
		  #10; tlast =0;
		  
		  
		  // 4.
		  #10; req=4'b0000;

    end

endmodule
