module mini_router_top #(
	parameter D_WIDTH = 8,
	parameter DEPTH = 4
)(
    input                   clk,
    input                   rst_n,

    // Slave side (upstream -> mini_router)
    input  [D_WIDTH-1:0]    s_tdata_0,
    input  [D_WIDTH-1:0]    s_tdata_1,
    input  [D_WIDTH-1:0]    s_tdata_2,
    input  [D_WIDTH-1:0]    s_tdata_3,
    input  [3:0]            s_tvalid,
    input  [3:0]            s_tlast,
    input  [3:0]            s_tdest,
    output [3:0]            s_tready,

    // Master side (mini_router -> downstream)
    output [D_WIDTH-1:0]    m_tdata_0,
    output [D_WIDTH-1:0]    m_tdata_1,
    output [1:0]            m_tvalid,
    output [1:0]            m_tlast,
    input  [1:0]            m_tready
);

	// sync_fifo
	wire [3:0] fifo_full;
	wire [3:0] wr__s_tvalid;
	assign wr__s_tvalid = s_tvalid & ~fifo_full;

	wire [3:0] fifo_empty;

	// route_ctrl
	wire [3:0] grant0_o;
	wire [3:0] grant1_o;
	wire [3:0] fifo_rd_en;
	assign fifo_rd_en = grant0_o | grant1_o;

	// crossbar
	wire [D_WIDTH-1:0] data_to_data_0 ;
	wire [D_WIDTH-1:0] data_to_data_1 ;
	wire [D_WIDTH-1:0] data_to_data_2 ;
	wire [D_WIDTH-1:0] data_to_data_3 ;
	wire [(D_WIDTH*4)-1:0] data_to_data;
	
	assign data_to_data = {{data_to_data_3},{data_to_data_2},{data_to_data_1},{data_to_data_0}};

	sync_fifo  #(.D_WIDTH(D_WIDTH), .DEPTH(DEPTH)) u_fifo_0 (
		.clk(clk),
		.rst_n(rst_n),
		.wr_en(wr__s_tvalid[0]),
		.rd_en(fifo_rd_en[0]),
		.din(s_tdata_0),
		.dout(data_to_data_0),
		.full(fifo_full[0]),
		.empty(fifo_empty[0])
	);

	sync_fifo  #(.D_WIDTH(D_WIDTH), .DEPTH(DEPTH)) u_fifo_1 (
		.clk(clk),
		.rst_n(rst_n),
		.wr_en(wr__s_tvalid[1]),
		.rd_en(fifo_rd_en[1]),
		.din(s_tdata_1),
		.dout(data_to_data_1),
		.full(fifo_full[1]),
		.empty(fifo_empty[1])
	);

	sync_fifo  #(.D_WIDTH(D_WIDTH), .DEPTH(DEPTH)) u_fifo_2 (
		.clk(clk),
		.rst_n(rst_n),
		.wr_en(wr__s_tvalid[2]),
		.rd_en(fifo_rd_en[2]),
		.din(s_tdata_2),
		.dout(data_to_data_2),
		.full(fifo_full[2]),
		.empty(fifo_empty[2])
	);

	sync_fifo  #(.D_WIDTH(D_WIDTH), .DEPTH(DEPTH)) u_fifo_3 (
		.clk(clk),
		.rst_n(rst_n),
		.wr_en(wr__s_tvalid[3]),
		.rd_en(fifo_rd_en[3]),
		.din(s_tdata_3),
		.dout(data_to_data_3),
		.full(fifo_full[3]),
		.empty(fifo_empty[3])
	);	
	
	route_ctrl u_route_ctrl (
    	.clk(clk), 
    	.rst_n(rst_n),
    	.tvalid(~fifo_empty),
		.tdest(s_tdest),
		.tlast(s_tlast),
		.tready(m_tready),
		.grant0(grant0_o),
		.grant1(grant1_o)
	);
    
	crossbar #(.D_WIDTH(D_WIDTH)) u_crossbar (
		.tvalid(~fifo_empty),
		.tlast(s_tlast),
		.grant0(grant0_o),
		.grant1(grant1_o),
		.tdata_in(data_to_data), // (D_WIDTH*4) 32bit
		.tvalid0(),
		.tlast0(),
		.tdata0(),
		.tvalid1(),
		.tlast1(),
		.tdata1(),
		
	);




endmodule
