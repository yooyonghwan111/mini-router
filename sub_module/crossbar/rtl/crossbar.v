module crossbar #(parameter D_WIDTH=8)(

	input	[3:0]               tvalid, 
	input	[3:0]               tlast,
    input   [3:0]               grant0,
    input   [3:0]               grant1,
    input   [(D_WIDTH*4)-1:0]   tdata_in, // [7:0]=port0, [15:8]=port1, [23:16]=port2, [31:24]=port3
	
    output                      tvalid0,  
    output                      tlast0,
    output	[D_WIDTH-1:0]       tdata0,

    output                      tvalid1,  
    output                      tlast1, 
    output	[D_WIDTH-1:0]       tdata1


	);

    assign tdata0 = (grant0 == 4'b0001) ? tdata_in [7:0] : 
                    (grant0 == 4'b0010) ? tdata_in [15:8] : 
                    (grant0 == 4'b0100) ? tdata_in [23:16] : 
                    (grant0 == 4'b1000) ? tdata_in [31:24] : 
                    {D_WIDTH{1'b0}};

    assign tdata1 = (grant1 == 4'b0001) ? tdata_in [7:0] : 
                    (grant1 == 4'b0010) ? tdata_in [15:8] : 
                    (grant1 == 4'b0100) ? tdata_in [23:16] : 
                    (grant1 == 4'b1000) ? tdata_in [31:24] : 
                    {D_WIDTH{1'b0}};


    assign tvalid0 = (grant0 == 4'b0001) ? tvalid [0] : 
                     (grant0 == 4'b0010) ? tvalid [1] : 
                     (grant0 == 4'b0100) ? tvalid [2] : 
                     (grant0 == 4'b1000) ? tvalid [3] : 
                     {1'b0};

    assign tvalid1 = (grant1 == 4'b0001) ? tvalid [0] : 
                     (grant1 == 4'b0010) ? tvalid [1] : 
                     (grant1 == 4'b0100) ? tvalid [2] : 
                     (grant1 == 4'b1000) ? tvalid [3] : 
                     {1'b0};

    
    assign tlast0 = (grant0 == 4'b0001) ? tlast [0] : 
                    (grant0 == 4'b0010) ? tlast [1] : 
                    (grant0 == 4'b0100) ? tlast [2] : 
                    (grant0 == 4'b1000) ? tlast [3] : 
                    {1'b0};

    assign tlast1 = (grant1 == 4'b0001) ? tlast [0] : 
                    (grant1 == 4'b0010) ? tlast [1] : 
                    (grant1 == 4'b0100) ? tlast [2] : 
                    (grant1 == 4'b1000) ? tlast [3] : 
                    {1'b0};    
endmodule 
