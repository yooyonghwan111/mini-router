interface mini_router_sva_if #(parameter D_WIDTH=8) (

    input logic clk,
    input logic rst_n,

    // Slave side 
    input logic                 s_tvalid_0, s_tvalid_1, s_tvalid_2, s_tvalid_3,
    input logic                 s_tready_0, s_tready_1, s_tready_2, s_tready_3,
    input logic                 s_tlast_0,  s_tlast_1,  s_tlast_2,  s_tlast_3,
    input logic                 s_tdest_0,  s_tdest_1,  s_tdest_2,  s_tdest_3,
    input logic [D_WIDTH-1:0]   s_tdata_0,  s_tdata_1,  s_tdata_2,  s_tdata_3,

    // Master side 
    input logic                 m_tvalid_0, m_tvalid_1,
    input logic                 m_tready_0, m_tready_1,
    input logic                 m_tlast_0,  m_tlast_1,
    input logic [D_WIDTH-1:0]   m_tdata_0,  m_tdata_1
);

    // Slave/Master signal -> packed 
    logic [3:0] s_tvalid, s_tready, s_tlast, s_tdest;
    logic [1:0] m_tvalid, m_tready, m_tlast;
    logic [D_WIDTH-1:0] s_tdata [0:3];
    logic [D_WIDTH-1:0] m_tdata [0:1];

    assign s_tvalid = {s_tvalid_3, s_tvalid_2, s_tvalid_1, s_tvalid_0};
    assign s_tready = {s_tready_3, s_tready_2, s_tready_1, s_tready_0};
    assign s_tlast  = {s_tlast_3,  s_tlast_2,  s_tlast_1,  s_tlast_0};
    assign s_tdest  = {s_tdest_3,  s_tdest_2,  s_tdest_1,  s_tdest_0};
    assign m_tvalid = {m_tvalid_1, m_tvalid_0};
    assign m_tready = {m_tready_1, m_tready_0};
    assign m_tlast  = {m_tlast_1,  m_tlast_0};

    assign s_tdata[0] = s_tdata_0;
    assign s_tdata[1] = s_tdata_1;
    assign s_tdata[2] = s_tdata_2;
    assign s_tdata[3] = s_tdata_3;

    assign m_tdata[0] = m_tdata_0;
    assign m_tdata[1] = m_tdata_1;


    // 1. Handshake Rules
   

    genvar i;

    generate

        // Slave side (TB driver 검증) 
        for (i = 0; i < 4; i++) begin : gen_slave_assertions

            // [p.2-18] TVALID once asserted, must remain asserted until handshake
            property p_s_tvalid_stable;
                @(posedge clk) disable iff (!rst_n)
                s_tvalid[i] && !s_tready[i] |=> s_tvalid[i];
            endproperty
            assert property (p_s_tvalid_stable)
                else $error("[SVA] s_tvalid deasserted before handshake! port=%0d", i);

            // [p.2-18] TDATA must remain stable while TVALID asserted (no handshake)
            property p_s_tdata_stable;
                @(posedge clk) disable iff (!rst_n)
                s_tvalid[i] && !s_tready[i] |=> $stable(s_tdata[i]);
                // $stable(signal) 현재클럭에서 signal 값이 이전클럭과 동일하면 true를 반환하는 system function
            endproperty
            assert property (p_s_tdata_stable)
                else $error("[SVA] s_tdata changed while TVALID asserted! port=%0d", i);

        end

        // Master side (DUT 검증) 
        for (i = 0; i < 2; i++) begin : gen_master_assertions

            // [p.2-18] TVALID once asserted, must remain asserted until handshake
            property p_m_tvalid_stable;
                @(posedge clk) disable iff (!rst_n)
                m_tvalid[i] && !m_tready[i] |=> m_tvalid[i];
            endproperty
            assert property (p_m_tvalid_stable)
                else $error("[SVA] m_tvalid deasserted before handshake! port=%0d", i);

            // [p.2-18] TDATA must remain stable while TVALID asserted (no handshake)
            property p_m_tdata_stable;
                @(posedge clk) disable iff (!rst_n)
                m_tvalid[i] && !m_tready[i] |=> $stable(m_tdata[i]);
            endproperty
            assert property (p_m_tdata_stable)
                else $error("[SVA] m_tdata changed while TVALID asserted! port=%0d", i);

        end

    endgenerate

 
    // 2. Reset Rules


    // [p.2-28] During reset, slave TVALID must be driven LOW
    property p_s_reset_tvalid;
        @(posedge clk)
        !rst_n |-> s_tvalid == 4'b0;
    endproperty
    assert property (p_s_reset_tvalid)
        else $error("[SVA] s_tvalid not LOW during reset!");

    // [p.2-28] During reset, master TVALID must be driven LOW

    // property p_m_reset_tvalid;
    //     @(posedge clk)
    //     !rst_n |-> m_tvalid == 2'b0;
    // endproperty
    
    //err msg
    // (time 10 NS) Assertion tb_top.sva_if.p_m_reset_tvalid has failed
    // [SVA] m_tvalid not LOW during reset!
    
    // 1. 10~40NS 구간이 reset구간
    // 2. 0~10 사이 첫 posedge clk에서 m_tvalid=X값을 가지기 때문에 SVA err 발생

    property p_m_reset_tvalid;
        @(posedge clk)
        !rst_n && !$isunknown(m_tvalid) |-> m_tvalid == 2'b0;
    endproperty
    // $isunknown(signal) : signal에 X나 Z가 포함되면 1을 반환
    // 즉 reset 이면서 m_tvalid가 X/Z값을 가지지 않는 구간에서 m_tvalid=0을 체크
    assert property (p_m_reset_tvalid)
        else $error("[SVA] m_tvalid not LOW during reset!");

   
    // =====================
    // 3. Packet Rules
    // =====================

    // [p.2-26] TLAST must be preserved
    // input port의 tlast가 발생하면 해당 tdest 방향 output에서 tlast가 나와야 함

    // tlast 신호의 발생가능 최대 delay 시간 계산

    // 1. 내부로직 지연
    //    top input -> route_ctrl(-> arbiter_rr) -> crossbar
    //    arbiter_rr : sequential 로직 (always블록 1개 -> 1clk 지연)
    //    crossbar : combinational 로직 (delay x)
    //    => 최대 1 clk

    // 2. input 경합 지연 
    //    4 ports contention (각 packet=1beat 인 경우)
    //    => 최대 4 clk

    // 3. multi-beat 지연 
    //    1개 port -> 각 packet=4beat인 경우 (FIFO_DEPTH = 4)
    //    => 최대 4 clk

    // 최대 지연 산정값
    // 1clk * 4clk * 4clk = 16
    // ##[1:16]


    generate
        for (i = 0; i < 4; i++) begin : gen_packet_assertions

            property p_tlast_preserved;
                @(posedge clk) disable iff (!rst_n)
                s_tvalid[i] && s_tready[i] && s_tlast[i] |-> ##[1:16] 
                    (s_tdest[i] == 0) ? (m_tvalid[0] && m_tready[0] && m_tlast[0]) : // dest=0 (output0 으로 나오는 경우)
                                        (m_tvalid[1] && m_tready[1] && m_tlast[1]); // dest=1 (output1 로 나오는 경우)
            endproperty
            assert property (p_tlast_preserved)
                else $error("[SVA] TLAST not seen on output! input port=%0d dest=%0d", i, s_tdest[i]);


        end
    endgenerate

endinterface
