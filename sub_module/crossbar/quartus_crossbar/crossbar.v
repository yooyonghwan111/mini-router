module crossbar #(
    parameter D_WIDTH    = 8,
    parameter FIFO_WIDTH = D_WIDTH + 4
    )(

    input   [3:0]               grant_0,
    input   [3:0]               grant_1,
    
    input   [FIFO_WIDTH-1:0]    data_in_0,
    input   [FIFO_WIDTH-1:0]    data_in_1,
    input   [FIFO_WIDTH-1:0]    data_in_2,
    input   [FIFO_WIDTH-1:0]    data_in_3,
    
    input                       s_valid_0,
    input                       s_valid_1,
    input                       s_valid_2,
    input                       s_valid_3,
    
    output  [1:0]               m_tid_0,
    output  [1:0]               m_tid_1,


    output  [D_WIDTH-1:0]       m_tdata_0,
    output  [D_WIDTH-1:0]       m_tdata_1,

    output                      m_valid_0,
    output                      m_valid_1,

    output                      m_dest_0,
    output                      m_dest_1,

    output                      m_last_0,
    output                      m_last_1

    );

    // packed -> {tdata[FIFO_WIDTH-1:4], tid[3:2], tdest[1], tlast[0]}

    assign m_tdata_0 = (grant_0 == 4'b0001) ? data_in_0[FIFO_WIDTH-1:4] :
                       (grant_0 == 4'b0010) ? data_in_1[FIFO_WIDTH-1:4] :
                       (grant_0 == 4'b0100) ? data_in_2[FIFO_WIDTH-1:4] :
                       (grant_0 == 4'b1000) ? data_in_3[FIFO_WIDTH-1:4] :
                       {D_WIDTH{1'b0}};

    assign m_tdata_1 = (grant_1 == 4'b0001) ? data_in_0[FIFO_WIDTH-1:4] :
                       (grant_1 == 4'b0010) ? data_in_1[FIFO_WIDTH-1:4] :
                       (grant_1 == 4'b0100) ? data_in_2[FIFO_WIDTH-1:4] :
                       (grant_1 == 4'b1000) ? data_in_3[FIFO_WIDTH-1:4] :
                       {D_WIDTH{1'b0}};

    // bit slicing (m_last_0/1)
    assign m_last_0 = (grant_0 == 4'b0001) ? data_in_0[0] : 
                      (grant_0 == 4'b0010) ? data_in_1[0] :
                      (grant_0 == 4'b0100) ? data_in_2[0] :
                      (grant_0 == 4'b1000) ? data_in_3[0] :
                      1'b0;

    assign m_last_1 = (grant_1 == 4'b0001) ? data_in_0[0] : 
                      (grant_1 == 4'b0010) ? data_in_1[0] :
                      (grant_1 == 4'b0100) ? data_in_2[0] :
                      (grant_1 == 4'b1000) ? data_in_3[0] :
                      1'b0;

    // bit slicing (m_dest_0/1)
    assign m_dest_0 = (grant_0 == 4'b0001) ? data_in_0[1] : 
                      (grant_0 == 4'b0010) ? data_in_1[1] :
                      (grant_0 == 4'b0100) ? data_in_2[1] :
                      (grant_0 == 4'b1000) ? data_in_3[1] :
                      1'b0;

    assign m_dest_1 = (grant_1 == 4'b0001) ? data_in_0[1] : 
                      (grant_1 == 4'b0010) ? data_in_1[1] :
                      (grant_1 == 4'b0100) ? data_in_2[1] :
                      (grant_1 == 4'b1000) ? data_in_3[1] :
                      1'b0;

    // bit slicing (m_tid_0/1)
    assign m_tid_0 = (grant_0 == 4'b0001) ? data_in_0[3:2] : 
                     (grant_0 == 4'b0010) ? data_in_1[3:2] :
                     (grant_0 == 4'b0100) ? data_in_2[3:2] :
                     (grant_0 == 4'b1000) ? data_in_3[3:2] :
                     2'b00;

    assign m_tid_1 = (grant_1 == 4'b0001) ? data_in_0[3:2] : 
                     (grant_1 == 4'b0010) ? data_in_1[3:2] :
                     (grant_1 == 4'b0100) ? data_in_2[3:2] :
                     (grant_1 == 4'b1000) ? data_in_3[3:2] :
                     2'b00;

    // [추가] m_valid: s_valid에서 grant 기준으로 선택 (packed 데이터와 무관)
    assign m_valid_0 = (grant_0 == 4'b0001) ? s_valid_0 :
                       (grant_0 == 4'b0010) ? s_valid_1 :
                       (grant_0 == 4'b0100) ? s_valid_2 :
                       (grant_0 == 4'b1000) ? s_valid_3 :
                       1'b0;

    assign m_valid_1 = (grant_1 == 4'b0001) ? s_valid_0 :
                       (grant_1 == 4'b0010) ? s_valid_1 :
                       (grant_1 == 4'b0100) ? s_valid_2 :
                       (grant_1 == 4'b1000) ? s_valid_3 :
                       1'b0;

endmodule