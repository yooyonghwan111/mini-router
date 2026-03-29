module tb_route_ctrl ();
    
    // reg clk;
    // reg rst_n;
    
    // reg valid_0;
    // reg valid_1;
    // reg valid_2;
    // reg valid_3;

    // reg dest_0;
    // reg dest_1;
    // reg dest_2;
    // reg dest_3;

    // reg last_0;
    // reg last_1;

    // reg ready_0;
    // reg ready_1;

    // wire [3:0] grant_0;
    // wire [3:0] grant_1;

    reg clk;
    reg rst_n;
    
    reg [3:0] valid;
    reg [3:0] dest;
    reg [1:0] last;
    reg [1:0] ready;

    wire [3:0] grant_0;
    wire [3:0] grant_1;

    integer i, j;

    route_ctrl dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_0(valid[0]),
        .valid_1(valid[1]),
        .valid_2(valid[2]),
        .valid_3(valid[3]),
        .dest_0(dest[0]),
        .dest_1(dest[1]),
        .dest_2(dest[2]),
        .dest_3(dest[3]),
        .last_0(last[0]),
        .last_1(last[1]),
        .ready_0(ready[0]),
        .ready_1(ready[1]),
        .grant_0(grant_0),
        .grant_1(grant_1)
    );


    initial begin
      clk=0;
      forever #5 clk = ~clk;
    end

    initial begin
    
        // // 1. reset
        // $display("========================================================");
        // $display("[%0t] 1. reset", $time);
        // rst_n=0;
        // valid=0; valid_1=0; valid_2=0; valid_3=0; 
        // dest_0=0; dest_1=0; dest_2=0; dest_3=0;
        // last_0=0; last_1=0;
        // ready_0=0; ready_1=0;

        // $display("[%0t] rst_n=%b", $time, rst_n);
        // $display("[%0t] valid_0=%b, valid_1=%b, valid_2=%b, valid_3=%b", $time, valid_0, valid_1, valid_2, valid_3);
        // $display("[%0t] dest_0=%b, dest_1=%b, dest_2=%b, dest_3=%b", $time, dest_0, dest_1, dest_2, dest_3);
        // $display("[%0t] last_0=%b, last_1=%b", $time, last_0, last_1);
        // $display("[%0t] ready_0=%b, ready_1=%b", $time, ready_0, ready_1);

        // 1. reset
        $display("========================================================");
        $display("[%0t] 1. reset", $time);
        rst_n=0; valid=0; dest=0; last=0; ready=0;
        

        $display("[%0t] rst_n=%b", $time, rst_n);
        $display("[%0t] valid0=%b, dest=%b, last=%b, ready=%b", $time, valid, dest, last, ready);
        
    
        repeat(2) @(posedge clk);
        rst_n=1;
        $display("[%0t] rst_n=%b", $time, rst_n);



        // 2. routing test
        $display("========================================================");
        $display("[%0t] 2. routing test", $time);

        last=2'b11; ready=2'b11;
        $display("[%0t] last=%b, ready=%b", $time, last, ready);
        
        repeat(2) @ (posedge clk);
        
        for (i=0; i<4; i=i+1) begin
            @(posedge clk);
            valid[i]=1; 
            $display("[%0t] valid[%0d]=%b, (input %0d)", $time, i, valid[i], i);

					 @(posedge clk);
                for(j=0; j<2; j=j+1) begin
                    //@(posedge clk);
                    dest[i]=j; 
                    $display("[%0t] dest[%0d]=%b, (output %0d)", $time, i, dest[i], j);
						
						  repeat(2) @(posedge clk);
                    if (j==0) begin // grant_0
                        if(grant_0[i] == 1) $display("[%0t][PASS] input %0d -> grant_0=%b (expected grant_0[%0d]=1)", $time, i, grant_0, i);
                        else $error("[%0t][FAIL] input %0d -> grant_0=%b (expected grant_0[%0d]=1)", $time, i, grant_0, i);
                    end
						  
                    else begin // grant_1
                        if(grant_1[i] == 1) $display("[%0t][PASS] input %0d -> grant_1=%b (expected grant_1[%0d]=1)", $time, i, grant_1, i);
                        else $error("[%0t][FAIL] input %0d -> grant_1=%b (expected grant_1[%0d]=1)", $time, i, grant_1, i);
                    end
                end
            valid[i]=0;
            $display("[%0t] valid[%0d]=%b, (input %0d)", $time, i, valid[i], i);
				$display("------------------------------------------------------");
				
        end
	 repeat(2) @(posedge clk);
    $finish;
    end

endmodule