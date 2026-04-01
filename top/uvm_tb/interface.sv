interface router_if #(parameter D_WIDTH=8);

    logic                   clk;
    logic                   rst_n;

    // Slave side (upstream -> mini_router) - 개별 신호
    logic [D_WIDTH-1:0]     s_tdata_0, s_tdata_1, s_tdata_2, s_tdata_3;
    logic [1:0]             s_tid_0,   s_tid_1,   s_tid_2,   s_tid_3;   
    logic                   s_tdest_0, s_tdest_1, s_tdest_2, s_tdest_3; 
    logic                   s_tlast_0, s_tlast_1, s_tlast_2, s_tlast_3; 
    logic                   s_tvalid_0,s_tvalid_1,s_tvalid_2,s_tvalid_3;
    logic                   s_tready_0,s_tready_1,s_tready_2,s_tready_3;

    // Master side (mini_router -> downstream) - 개별 신호
    logic [D_WIDTH-1:0]     m_tdata_0,  m_tdata_1;
    logic [1:0]             m_tid_0,    m_tid_1;                         
    logic                   m_tlast_0,  m_tlast_1;                       
    logic                   m_tvalid_0, m_tvalid_1;                      
    logic                   m_tready_0, m_tready_1;                      

endinterface