interface router_if #(parameter D_WIDTH=8);
    
    logic                   clk;
    logic                   rst_n;

    // Slave side (upstream -> mini_router)
	logic  [D_WIDTH-1:0]    s_tdata_0;  //input
    logic  [D_WIDTH-1:0]    s_tdata_1;  //input
    logic  [D_WIDTH-1:0]    s_tdata_2;  //input 
    logic  [D_WIDTH-1:0]    s_tdata_3;  //input
    logic  [3:0]            s_tvalid;   //input
    logic  [3:0]            s_tlast;    //input
    logic  [3:0]            s_tdest;    //input
    logic  [3:0]            s_tready;   //output

    // Master side (mini_router -> downstream)
    logic [D_WIDTH-1:0]    m_tdata_0;   //output
    logic [D_WIDTH-1:0]    m_tdata_1;   //output
    logic [1:0]            m_tvalid;    //output
    logic [1:0]            m_tlast;    //output
    logic [1:0]            m_tready;    //input
  
endinterface
    