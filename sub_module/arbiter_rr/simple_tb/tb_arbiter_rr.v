module tb_arbiter_rr ();
    reg clk, rst_n;
    reg [3:0] req;
    reg tlast;
    reg tready;
    wire [3:0] grant;

    arbiter_rr u0 (
        .clk(clk),
        .rst_n(rst_n),
        .req(req),
        .tlast(tlast),
        .tready(tready),
        .grant(grant)
    );

    initial begin 
        clk = 0; 
        forever #5 clk = ~clk; 
    end

    initial begin
        // Seq1. reset
        $display ("==================================================================================");
        req=4'b0000; tlast=0; tready=0; rst_n=0;
        $display("[%0t] [Seq1] rst_n=%b req=%b tlast=%b tready=%b", $time, rst_n, req, tlast, tready);
        repeat(2) @(posedge clk);
        rst_n=1;
        $display("[%0t] [Seq1] rst_n=%b", $time, rst_n);
        repeat(2) @(posedge clk);
        if (grant === 4'b0000) $display("[%0t] [PASS] grant=%b", $time, grant);
        else                   $error  ("[%0t] [FAIL] grant=%b (exp:0000)", $time, grant);


        // Seq2. round-robin tready=1
        $display ("==================================================================================");
        req=4'b0101; tlast=1; tready=1;
        $display("[%0t] [Seq2] req=%b tlast=%b tready=%b", $time, req, tlast, tready);
        @(posedge clk);
        #1
        if (grant === 4'b0100) $display("[%0t] [PASS] grant=%b", $time, grant);
        else                   $error  ("[%0t] [FAIL] grant=%b (exp:0100)", $time, grant);        

        @(posedge clk); 
        #1
        if (grant === 4'b0001) $display("[%0t] [PASS] grant=%b", $time, grant);
        else                   $error  ("[%0t] [FAIL] grant=%b (exp:0001)", $time, grant);        
        $display ("----------------------------------------------------------------------------------");


        // Seq3. tready=0 stall
        $display ("==================================================================================");
        tready=0;
        $display("[%0t] [Seq3] tready=%b (stall)", $time, tready);
        #1
        @(posedge clk);
        if (grant === 4'b0001) $display("[%0t] [PASS] grant=%b (hold)", $time, grant);
        else                   $error  ("[%0t] [FAIL] grant=%b (exp:hold 0001)", $time, grant);
        tready=1;
        $display("[%0t] [Seq3] tready=%b (resume)", $time, tready);

        // Seq4. no request
        $display ("==================================================================================");
        req=4'b0000; tlast=0;
        $display("[%0t] [Seq4] req=%b tlast=%b", $time, req, tlast);
        repeat(2) @(posedge clk);
        if (grant === 4'b0000) $display("[%0t] [PASS] grant=%b", $time, grant);
        else                   $error  ("[%0t] [FAIL] grant=%b (exp:0000)", $time, grant);

        $display("[%0t] [DONE]", $time);
        $finish;
    end

endmodule
