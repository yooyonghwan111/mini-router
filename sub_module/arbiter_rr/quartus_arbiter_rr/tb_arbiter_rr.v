module tb_arbiter_rr ();

    reg       			clk;
	reg 				rst_n;
    reg	 [3:0]		    req;
    reg       			ready;
    reg       			last;
	 
    wire [3:0]	        grant;


    reg [3:0] exp_grant ;

    arbiter_rr u0 (
        .clk(clk),
        .rst_n(rst_n),
        .req(req),
        .last(last),
        .ready(ready),
        .grant(grant)
    );

    initial begin 
        clk = 0; 
        forever #5 clk = ~clk; 
    end


    initial begin
        // 1. reset test : check the grant=0 after reset
        $display ("==================================================================================");
        $display("[%0t] 1. reset test : check the grant=0 after reset", $time);
        rst_n=0; req=4'b0000; ready=0; last=0;  
        $display("[%0t] rst_n=%b req=%b last=%b ready=%b", $time, rst_n, req, ready, last);
        repeat(2) @(posedge clk);
        rst_n=1;
        $display("[%0t] rst_n=%b", $time, rst_n);
        repeat(2) @(posedge clk);
        if (grant === 4'b0000) $display("[%0t] [PASS] grant=%b", $time, grant);
        else                   $error  ("[%0t] [FAIL] grant=%b (exp:0000)", $time, grant);


        // Seq2. round-robin test
        $display ("==================================================================================");
        $display("[%0t] 2. round-robin test : verify grant rotates by RR priority ", $time);

        @ (posedge clk);
        req=0101; last=1; ready=1;
        $display("[%0t] req=%b last=%b ready=%b", $time, req, last, ready);

        @(posedge clk); #1;
            if (grant === 4'b0001) $display("[%0t] [PASS] grant=%b", $time, grant);
            else                   $error  ("[%0t] [FAIL] grant=%b (exp:0001)", $time, grant);   
        
        @(posedge clk);
            last=0;    
            $display("[%0t] last=%b", $time, last);

        @(posedge clk);
            last=1;    
            $display("[%0t] last=%b", $time, last);

        @(posedge clk); #1
            if (grant === 4'b0100) $display("[%0t] [PASS] grant=%b", $time, grant);
            else                   $error  ("[%0t] [FAIL] grant=%b (exp:0100)", $time, grant);        

        @(posedge clk);
            last=0;    
            $display("[%0t] last=%b", $time, last);

            
        repeat(2) @(posedge clk);

        // Seq3. stall test
        $display ("==================================================================================");
        $display("[%0t] 3. stall test : verify grant holds when ready=0", $time);
        $display("[%0t] grant=%b", $time, grant);
        last=1; ready=0;
        $display("[%0t] last=%b ready=%b", $time, last, ready);
        
        repeat(3) @(posedge clk);
        $display("[%0t] delay 3 posedge clk", $time);

        if (grant === 4'b0100) $display("[%0t] [PASS] grant=%b (hold)", $time, grant);
        else                   $error  ("[%0t] [FAIL] grant=%b (exp:hold 0100)", $time, grant);

        @(posedge clk);
        ready=1;
        $display("[%0t] ready=%b (resume)", $time, ready);
        
        repeat(2) @(posedge clk);
        if (grant === 4'b0001) $display("[%0t] [PASS] grant=%b (hold)", $time, grant);
        else                   $error  ("[%0t] [FAIL] grant=%b (exp:hold 0001)", $time, grant);

        @(posedge clk);
        ready=0; last=0;
        $display("[%0t] ready=%b, last=%b", $time, ready, last);


        repeat(2) @(posedge clk);

        // 4. no request
        $display ("==================================================================================");
        $display("[%0t] 4. no request test : verify grant holds when req=0 with ready&&last asserted", $time);
        $display("[%0t] grant=%b", $time, grant);
        
        req=4'b0000; ready=1; last=1;
        $display("[%0t] req=%b ready=%b, last=%b", $time, req, ready, last);
        
        exp_grant = grant;

        repeat(2) @(posedge clk);
        if (grant === exp_grant) $display("[%0t] [PASS] grant=%b", $time, grant);
        else                     $error  ("[%0t] [FAIL] grant=%b (exp_grant=%b)", $time, grant, exp_grant);

        $display("[%0t] [DONE]", $time);
        $finish;
    end

endmodule