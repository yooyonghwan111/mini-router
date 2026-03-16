
module tb_sync_fifo ();

	parameter DEPTH = 8;
	parameter D_WIDTH = 8;

	reg	clk, rst_n; 
	reg	wr_en, rd_en;
	reg	[D_WIDTH-1:0] din;
	
	wire	[D_WIDTH-1:0] dout; 
	wire	full;
	wire	empty;
	
	reg	[D_WIDTH-1:0] wdata [0:DEPTH-1];
	reg [$clog2(DEPTH):0] wptr_before;
	reg [$clog2(DEPTH):0] rptr_before;

	integer i;
	
	
	sync_fifo #(.DEPTH(DEPTH), .D_WIDTH(D_WIDTH)) u0 
	(
		.clk(clk),
		.rst_n(rst_n),
		.wr_en(wr_en),
		.rd_en(rd_en),
		.din(din),
		.dout(dout),
		.full(full),
		.empty(empty)
	);
	
	


	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
	
	
	initial begin
	
		//1. reset test : check the empty=1, full=0
		$display("==============================================================");
		$display("[%0t] 1. reset test : check the empty=1, full=0", $time);
		
		rst_n=0; wr_en=0; rd_en=0; din=0; 
		$display("[%0t]  rst_n=%b; wr_en=%b; rd_en=%b; din=%d", $time, rst_n, wr_en, rd_en, din); 
		
		#15 rst_n = 1;
		$display("[%0t] rst_n=%b", $time, rst_n); 

		@(posedge clk) 
		if (empty==1 && full==0) $display("[%0t][SUCCESS] empty=%d, full=%d", $time, empty, full);
		else $error ("[%0t][FAIL] empty=%d, full=%d",  $time, empty, full);
		
		
		
		//2. compare write/read value
		$display("==============================================================");
		$display("[%0t] 2. compare write/read value ", $time);
		$display("[%0t] 2-1. [%0d] WRITE  ", $time, DEPTH);

		for (i=0; i<DEPTH; i=i+1) begin
			@(posedge clk) 
			wr_en = 1; din=$random; wdata[i]=din;
			$display("[%0t][WRITE] wr_en=%b, wr_val=%d", $time, wr_en, wdata[i]);
		end
			@(posedge clk) 
			wr_en = 0;
			$display("[%0t] wr_en=%b", $time, wr_en);

		
		@(posedge clk) 
		$display("[%0t] 2-2. [%0d] READ  ", $time, DEPTH);	
		rd_en = 1;
		$display("[%0t] rd_en=%b", $time, rd_en);

		@(posedge clk)
		for (i=0; i<DEPTH; i=i+1) begin	
			
			@(posedge clk) 
			$display("[%0t][READ] rd_en=%b, rd_val=%d", $time, rd_en, dout);
			if(dout == wdata[i]) $display("[%0t][WRITE/READ Value Matched !] wr_val=%d, rd_val=%d", $time, wdata[i], dout);
			else $error("[%0t][WRITE/READ Value MisMatched !] wr_val=%d, rd_val=%d", $time, wdata[i], dout);
			
		end
			@(posedge clk) 
			rd_en = 0;
			$display("[%0t] rd_en=%b", $time, rd_en);

		//3. full/empty check
		$display("==============================================================");
		$display("[%0t] 3. full/empty check ", $time);
		$display("[%0t] 3-1. full check ", $time);
		for (i=0; i<DEPTH; i=i+1) begin
			@(posedge clk) 
			wr_en = 1; din=$random; wdata[i]=din;
			$display("[%0t][WRITE] wr_en=%b, wr_val=%d", $time, wr_en, wdata[i]);
		end
			repeat(2) @(posedge clk);
			if(full) $display("[%0t][full is asserted] full=%d, empty=%d", $time, full, empty);
			else $error("[%0t][full is not asserted] full=%d, empty=%d", $time, full, empty);
			
			repeat(2) @(posedge clk);
			wr_en = 0;
			$display("[%0t] wr_en=%b", $time, wr_en);

			
		@(posedge clk) 
		$display("[%0t] 3-2. empty check ", $time);
		rd_en = 1; 
		$display("[%0t] rd_en=%b", $time, rd_en);

		@(posedge clk)
		for (i=0; i<DEPTH; i=i+1) begin	
			
			@(posedge clk) 
			$display("[%0t][READ] rd_en=%b, rd_val=%d", $time, rd_en, dout);		
		end
		 @(posedge clk)
		 rd_en=0; 
		 $display("[%0t] rd_en=%b", $time, rd_en);
		 if(empty) $display("[%0t][empty is asserted] full=%d, empty=%d", $time, full, empty);
		 else $error("[%0t][empty is not asserted] full=%d, empty=%d", $time, full, empty);
		 

		$display("==============================================================");
		//4. full/empty overflow check
		$display("[%0t] 4. full/empty overflow check ", $time);
		$display("[%0t] 4-1. full overflow check (9 write) ", $time);

		$display("[%0t][RESET] reset ptr before test_seq 4", $time);
		
		rst_n = 0; 
		$display("[%0t] rst_n=%b,", $time, rst_n);

		repeat(3) @(posedge clk);
		rst_n = 1; 
		wptr_before = u0.wptr; 
		rptr_before = u0.rptr; 

		@(posedge clk);
		$display("[%0t] wptr_before=%b, wptr=%b", $time, wptr_before, u0.wptr);
		$display("[%0t] rptr_before=%b, rptr=%b", $time, rptr_before, u0.rptr);

		for (i=0; i<DEPTH; i=i+1) begin
			@(posedge clk) 
			wr_en = 1; din=$random; wdata[i]=din;
			@(posedge clk) 
			$display("[%0t][%0d][WRITE] wr_en=%b, wr_val=%d, wptr_before=%b, wptr=%b", $time, i+1, wr_en, wdata[i], wptr_before, u0.wptr);
		end
			repeat(2) @(posedge clk);
			wptr_before = u0.wptr; 
			@(posedge clk)
			wr_en = 1; din=$random; wdata[i]=din;
			@(posedge clk)
			$display("[%0t][%0d][WRITE] wr_en=%b, wr_val=%d, wptr_before=%b, wptr=%b", $time, i+1, wr_en, din, wptr_before, u0.wptr);

			@(posedge clk) 
			wr_en = 0;
			if(u0.wptr == wptr_before) $display("[%0t][SUCCESS] overflow blocked, wptr_before=%b, wptr=%b", $time, wptr_before, u0.wptr);
			else $error("[%0t][FAIL] overflow occurred, wptr_before=%b, wptr=%b", $time, wptr_before, u0.wptr);


		repeat(2) @(posedge clk);
		rd_en = 1;
		$display("[%0t] rd_en=%b", $time, rd_en);
		
		@(posedge clk)
		$display("4-2. empty overflow check (9 write) ");

		for (i=0; i<DEPTH; i=i+1) begin
			@(posedge clk) 
			$display("[%0t][%0d][READ] rd_en=%b, rd_val=%d, rptr_before=%b, rptr=%b", $time, i+1, rd_en, dout, rptr_before, u0.rptr);
		end
			rptr_before = u0.rptr;
			@(posedge clk) 
			$display("[%0t][%0d][READ] rd_en=%b, rd_val=%d, rptr_before=%b, rptr=%b", $time, i+1, rd_en, dout, rptr_before, u0.rptr);

			@(posedge clk) 
			rd_en = 0;
			$display("[%0t] rd_en=%b", $time, rd_en);
			
			if(u0.rptr == rptr_before) $display("[%0t][SUCCESS] overflow blocked, rptr_before=%b, rptr=%b", $time, rptr_before, u0.rptr);
			else $error("[%0t][FAIL] overflow occurred, rptr_before=%b, rptr=%b", $time, rptr_before, u0.rptr);
		$finish;
	end
	
endmodule
