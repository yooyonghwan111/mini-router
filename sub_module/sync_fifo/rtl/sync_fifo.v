module sync_fifo #(parameter DEPTH=8 , D_WIDTH=8)(

	input					        clk,
	input						     rst_n,
	input							  wr_en,
	input							  rd_en,
	input			[D_WIDTH-1:0] din,

	output reg	[D_WIDTH-1:0] dout, 

	output						  full,
	output						  empty
);

	localparam P_INDEX = $clog2(DEPTH);

	reg	[D_WIDTH-1:0] fifo	[0:DEPTH-1];

	reg [P_INDEX:0] wptr;
	reg [P_INDEX:0] rptr;



	always @ (posedge clk) begin
		if(!rst_n) begin
			wptr <= 0;
		end

		else begin
			if (wr_en && !full) begin
				fifo[wptr[P_INDEX-1:0]] <= din;
				wptr <= wptr+1'b1;
			end
		end

	end


	always @ (posedge clk) begin
		if(!rst_n) begin
			rptr <=0;
			dout <=0;
		end

		else begin
			if(rd_en && !empty) begin
				dout <= fifo[rptr[P_INDEX-1:0]];
				rptr <= rptr+1'b1;
			end
		end

	end

	assign empty = (wptr == rptr);
	assign full = (wptr[P_INDEX-1:0] == rptr[P_INDEX-1:0]) && (wptr[P_INDEX] != rptr[P_INDEX]);
	

endmodule
