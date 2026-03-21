interface sync_fifo_if #(parameter D_WIDTH=4)(input clk, input rst_n);

	logic wr_en;
	logic rd_en;
	logic [D_WIDTH-1:0] din;
	logic [D_WIDTH-1:0] dout; 
	logic full;
	logic empty;
  
endinterface