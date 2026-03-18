module tb_crossbar ();
    
	localparam D_WIDTH = 8;

    reg [3:0]               tvalid; 
	reg	[3:0]               tlast;
    reg [(D_WIDTH*4)-1:0]   tdata_in;
	
    reg [3:0]               grant0;
    reg [3:0]               grant1;

    wire                    tvalid0;  
    wire                    tlast0;
    wire [D_WIDTH-1:0]      tdata0;

    wire                    tvalid1;  
    wire                    tlast1; 
    wire [D_WIDTH-1:0]      tdata1;

    
    crossbar #(.D_WIDTH(D_WIDTH)) dut (
        .tvalid(tvalid),
        .tlast(tlast),
        .tdata_in(tdata_in),
        .grant0(grant0),
        .grant1(grant1),
        .tvalid0(tvalid0),
        .tlast0(tlast0),
        .tdata0(tdata0),
        .tvalid1(tvalid1),
        .tlast1(tlast1),
        .tdata1(tdata1)
    );

    integer i;


    initial begin
        $display ("[%0t]grant test", $time);
        $display ("=============================================");
        $display ("[%0t][seq_1] grant0 test", $time);
        tvalid=4'b1111; tlast= 4'b1111; tdata_in = $random; grant0=4'b0000;
        #10;
        $display ("[%0t][seq_1] tvalid=%b, tlast=%b, grant0=%b", $time, tvalid, tlast, grant0);
        for (i=0; i<4; i=i+1) begin
            $display ("--------------------------------------------");
            grant0 = 1 << i;
            #10;
            $display ("[%0t][seq_1] grant0=%b, tdata_in=%h", $time, grant0, tdata_in[D_WIDTH*i +: D_WIDTH]);
            #10;
            if (tdata_in[D_WIDTH*i +: D_WIDTH] == tdata0) $display("[%0t][seq_1] <PASS>  grant0=%b, tdata_in=%h, tdata0=%h", $time, grant0, tdata_in[D_WIDTH*i +: D_WIDTH], tdata0);
            else $error("[%0t][seq_1] <FAIL> grant0=%b, tdata_in=%h, tdata0=%h", $time, grant0, tdata_in[D_WIDTH*i +: D_WIDTH], tdata0);
            grant0=4'b0000;
        end


        $display ("=============================================");
        $display ("[%0t][seq_2] grant1 test", $time);
        tvalid=4'b1111; tlast= 4'b1111; tdata_in = $random; grant1=4'b0000;
        #10;
        $display ("[%0t][seq_2] tvalid=%b, tlast=%b, grant1=%b", $time, tvalid, tlast, grant1);
        for (i=0; i<4; i=i+1) begin
            $display ("--------------------------------------------");
            grant1 = 1 << i;
            #10;
            $display ("[%0t][seq_2] grant1=%b, tdata_in=%h", $time, grant1, tdata_in[D_WIDTH*i +: D_WIDTH]);
            #10;
            if (tdata_in[D_WIDTH*i +: D_WIDTH] == tdata1) $display("[%0t][seq_2] <PASS>  grant1=%b, tdata_in=%h, tdata1=%h", $time, grant1, tdata_in[D_WIDTH*i +: D_WIDTH], tdata1);
            else $error("[%0t][seq_2] <FAIL> grant1=%b, tdata_in=%h, tdata1=%h", $time, grant1, tdata_in[D_WIDTH*i +: D_WIDTH], tdata1);
            grant1=4'b0000;

            
        end

        


        

    end



endmodule 
