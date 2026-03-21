interface mini_router_if #(parameter D_WIDTH=8)(logic clk, logic rst_n);

	logic  [D_WIDTH-1:0]    s_tdata_0;
    logic  [D_WIDTH-1:0]    s_tdata_1;
    logic  [D_WIDTH-1:0]    s_tdata_2;
    logic  [D_WIDTH-1:0]    s_tdata_3;
    logic  [3:0]            s_tvalid;
    logic  [3:0]            s_tlast;
    logic  [3:0]            s_tdest;
    logic  [3:0]            s_tready;

    // Master side (mini_router -> downstream)
    logic [D_WIDTH-1:0]    m_tdata_0;
    logic [D_WIDTH-1:0]    m_tdata_1;
    logic [1:0]            m_tvalid;
    logic [1:0]            m_tlast;
    logic [1:0]           m_tready;
  
endinterface
