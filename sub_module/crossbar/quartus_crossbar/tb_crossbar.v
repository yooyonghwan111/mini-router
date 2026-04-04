module tb_crossbar ();

    localparam D_WIDTH    = 8;
    localparam FIFO_WIDTH = D_WIDTH + 4; // {tdata[11:4], tid[3:2], tdest[1], tlast[0]}

    reg [FIFO_WIDTH-1:0]    data_in_0, data_in_1, data_in_2, data_in_3;
    reg [3:0]               grant_0, grant_1;
    reg                     s_valid_0, s_valid_1, s_valid_2, s_valid_3;

    wire [D_WIDTH-1:0]      m_tdata_0, m_tdata_1;
    wire [1:0]              m_tid_0,   m_tid_1;
    wire                    m_dest_0,  m_dest_1;
    wire                    m_last_0,  m_last_1;
    wire                    m_valid_0, m_valid_1;

    // data_in slicing wires (wave 확인용)
    wire [D_WIDTH-1:0] data_in_0_tdata = data_in_0[FIFO_WIDTH-1:4];
    wire [1:0]         data_in_0_tid   = data_in_0[3:2];
    wire               data_in_0_tdest = data_in_0[1];
    wire               data_in_0_tlast = data_in_0[0];

    wire [D_WIDTH-1:0] data_in_1_tdata = data_in_1[FIFO_WIDTH-1:4];
    wire [1:0]         data_in_1_tid   = data_in_1[3:2];
    wire               data_in_1_tdest = data_in_1[1];
    wire               data_in_1_tlast = data_in_1[0];

    wire [D_WIDTH-1:0] data_in_2_tdata = data_in_2[FIFO_WIDTH-1:4];
    wire [1:0]         data_in_2_tid   = data_in_2[3:2];
    wire               data_in_2_tdest = data_in_2[1];
    wire               data_in_2_tlast = data_in_2[0];

    wire [D_WIDTH-1:0] data_in_3_tdata = data_in_3[FIFO_WIDTH-1:4];
    wire [1:0]         data_in_3_tid   = data_in_3[3:2];
    wire               data_in_3_tdest = data_in_3[1];
    wire               data_in_3_tlast = data_in_3[0];

    crossbar #(.D_WIDTH(D_WIDTH)) dut (
        .grant_0    (grant_0),   .grant_1    (grant_1),
        .data_in_0  (data_in_0), .data_in_1  (data_in_1),
        .data_in_2  (data_in_2), .data_in_3  (data_in_3),
        .s_valid_0  (s_valid_0), .s_valid_1  (s_valid_1),
        .s_valid_2  (s_valid_2), .s_valid_3  (s_valid_3),
        .m_tdata_0  (m_tdata_0), .m_tdata_1  (m_tdata_1),
        .m_tid_0    (m_tid_0),   .m_tid_1    (m_tid_1),
        .m_valid_0  (m_valid_0), .m_valid_1  (m_valid_1),
        .m_dest_0   (m_dest_0),  .m_dest_1   (m_dest_1),
        .m_last_0   (m_last_0),  .m_last_1   (m_last_1)
    );

    integer i;
    reg [FIFO_WIDTH-1:0] data_arr [0:3];

    initial begin
        // 초기화
        grant_0 = 0; grant_1 = 0;
        s_valid_0 = 1; s_valid_1 = 1; s_valid_2 = 1; s_valid_3 = 1;
        // {tdata(8), tid(2), tdest(1), tlast(1)}
        data_in_0 = {8'hAA, 2'b00, 1'b0, 1'b1};
        data_in_1 = {8'hBB, 2'b01, 1'b1, 1'b0};
        data_in_2 = {8'hCC, 2'b10, 1'b0, 1'b1};
        data_in_3 = {8'hDD, 2'b11, 1'b1, 1'b0};
        data_arr[0] = data_in_0; data_arr[1] = data_in_1;
        data_arr[2] = data_in_2; data_arr[3] = data_in_3;
        $display("[%0t] init: data_in_0=%h | tdata=%h tid=%b tdest=%b tlast=%b",
                 $time, data_in_0, data_in_0[FIFO_WIDTH-1:4], data_in_0[3:2], data_in_0[1], data_in_0[0]);
        $display("[%0t] init: data_in_1=%h | tdata=%h tid=%b tdest=%b tlast=%b",
                 $time, data_in_1, data_in_1[FIFO_WIDTH-1:4], data_in_1[3:2], data_in_1[1], data_in_1[0]);
        $display("[%0t] init: data_in_2=%h | tdata=%h tid=%b tdest=%b tlast=%b",
                 $time, data_in_2, data_in_2[FIFO_WIDTH-1:4], data_in_2[3:2], data_in_2[1], data_in_2[0]);
        $display("[%0t] init: data_in_3=%h | tdata=%h tid=%b tdest=%b tlast=%b",
                 $time, data_in_3, data_in_3[FIFO_WIDTH-1:4], data_in_3[3:2], data_in_3[1], data_in_3[0]);
        $display("[%0t] init: s_valid=1111, grant_0=%b, grant_1=%b", $time, grant_0, grant_1);
        #10;

        // seq_1: grant_0 routing test
        $display("=============================================");
        $display("[%0t][seq_1] grant_0 routing test", $time);
        for (i = 0; i < 4; i = i+1) begin
            $display("--------------------------------------------");
            grant_0 = 4'b0001 << i;
            $display("[%0t][seq_1] drive: grant_0=%b", $time, grant_0);
            #10;
            if (m_tdata_0 == data_arr[i][FIFO_WIDTH-1:4])
                $display("[%0t][seq_1] <PASS> grant_0=%b, m_tdata_0=%h, m_tid_0=%b, m_dest_0=%b, m_last_0=%b, m_valid_0=%b",
                         $time, grant_0, m_tdata_0, m_tid_0, m_dest_0, m_last_0, m_valid_0);
            else
                $error("[%0t][seq_1] <FAIL> grant_0=%b, m_tdata_0=%h (exp=%h)",
                       $time, grant_0, m_tdata_0, data_arr[i][FIFO_WIDTH-1:4]);
            grant_0 = 0;
            $display("[%0t][seq_1] drive: grant_0=%b (deassert)", $time, grant_0);
            #10;
        end

        // seq_2: grant_1 routing test
        $display("=============================================");
        $display("[%0t][seq_2] grant_1 routing test", $time);
        for (i = 0; i < 4; i = i+1) begin
            $display("--------------------------------------------");
            grant_1 = 4'b0001 << i;
            $display("[%0t][seq_2] drive: grant_1=%b", $time, grant_1);
            #10;
            if (m_tdata_1 == data_arr[i][FIFO_WIDTH-1:4])
                $display("[%0t][seq_2] <PASS> grant_1=%b, m_tdata_1=%h, m_tid_1=%b, m_dest_1=%b, m_last_1=%b, m_valid_1=%b",
                         $time, grant_1, m_tdata_1, m_tid_1, m_dest_1, m_last_1, m_valid_1);
            else
                $error("[%0t][seq_2] <FAIL> grant_1=%b, m_tdata_1=%h (exp=%h)",
                       $time, grant_1, m_tdata_1, data_arr[i][FIFO_WIDTH-1:4]);
            grant_1 = 0;
            $display("[%0t][seq_2] drive: grant_1=%b (deassert)", $time, grant_1);
            #10;
        end

        // seq_3: grant=0 default output test
        $display("=============================================");
        $display("[%0t][seq_3] grant=0 default output test", $time);
        grant_0 = 0; grant_1 = 0;
        $display("[%0t][seq_3] drive: grant_0=%b, grant_1=%b", $time, grant_0, grant_1);
        #10;
        if (m_tdata_0 == 0 && m_tid_0 == 0 && m_dest_0 == 0 && m_last_0 == 0 && m_valid_0 == 0)
            $display("[%0t][seq_3] <PASS> grant_0=0, m_tdata_0=%h m_tid_0=%b m_dest_0=%b m_last_0=%b m_valid_0=%b",
                     $time, m_tdata_0, m_tid_0, m_dest_0, m_last_0, m_valid_0);
        else
            $error("[%0t][seq_3] <FAIL> grant_0=0, outputs not zero | m_tdata_0=%h m_tid_0=%b m_dest_0=%b m_last_0=%b m_valid_0=%b",
                   $time, m_tdata_0, m_tid_0, m_dest_0, m_last_0, m_valid_0);
 
        if (m_tdata_1 == 0 && m_tid_1 == 0 && m_dest_1 == 0 && m_last_1 == 0 && m_valid_1 == 0)
            $display("[%0t][seq_3] <PASS> grant_1=0, m_tdata_1=%h m_tid_1=%b m_dest_1=%b m_last_1=%b m_valid_1=%b",
                     $time, m_tdata_1, m_tid_1, m_dest_1, m_last_1, m_valid_1);
        else
            $error("[%0t][seq_3] <FAIL> grant_1=0, outputs not zero | m_tdata_1=%h m_tid_1=%b m_dest_1=%b m_last_1=%b m_valid_1=%b",
                   $time, m_tdata_1, m_tid_1, m_dest_1, m_last_1, m_valid_1);
 
        $display("=============================================");
        $display("[%0t] sim done", $time);
        $finish;
    end

endmodule