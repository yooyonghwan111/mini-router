interface mini_router_sva_if #(parameter D_WIDTH=8) (
    
    input logic        clk,
    input logic        rst_n,
    
    // slave side
    input logic [3:0]           s_tvalid,            
    input logic [3:0]           s_tready,            
    input logic [3:0]           s_tlast,             
    input logic [3:0]           s_tdest,             
	input logic [D_WIDTH-1:0]   s_tdata_0, 
    input logic [D_WIDTH-1:0]   s_tdata_1,
    input logic [D_WIDTH-1:0]   s_tdata_2,   
    input logic [D_WIDTH-1:0]   s_tdata_3,           

    // master side
    input logic [1:0]           m_tvalid,            
    input logic [1:0]           m_tready,            
    input logic [1:0]           m_tlast              
);

    // =====================
    // 1. Handshake Rules
    // =====================

    // [p.2-18] TVALID once asserted, must remain asserted until handshake
    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : gen_slave_assertions
            // TVALID stability
            property p_tvalid_stable;
                @(posedge clk) disable iff (!rst_n)
                s_tvalid[i] && !s_tready[i] |=> s_tvalid[i];
            endproperty

            assert property (p_tvalid_stable)
                else $error("TVALID deasserted before handshake! port=%0d", i);

            // [p.2-18] TDATA must remain stable while TVALID is asserted
            property p_tdata_stable;
                @(posedge clk) disable iff (!rst_n)
                s_tvalid[i] && !s_tready[i] |=> 
                    (i == 0) ? $stable(s_tdata_0) :
                    (i == 1) ? $stable(s_tdata_1) :
                    (i == 2) ? $stable(s_tdata_2) :
                               $stable(s_tdata_3);
            endproperty
            assert property (p_tdata_stable)
                else $error("TDATA changed while TVALID asserted! port=%0d", i);
        end
    endgenerate
    // $stable(signal): returns true if signal value is unchanged from previous clock cycle         
 

    // =====================
    // 2. Reset Rules
    // =====================

    // [p.2-28] During reset, TVALID must be driven LOW
    property p_reset_tvalid;
        @(posedge clk)
        !rst_n |-> s_tvalid == 4'b0;
    endproperty
    assert property (p_reset_tvalid)
        else $error("TVALID not LOW during reset!");

    // =====================
    // 3. Packet Rules
    // =====================

    // [p.2-26] TLAST must be preserved (output packet count == input packet count)
    // -- intended to catch last beat miss that scoreboard failed to capture         
    generate
        for (i = 0; i < 4; i++) begin : gen_packet_assertion
            
            property p_tlast_preserved;
                @(posedge clk) disable iff (!rst_n)
                    // FIFO_DEPTH=8
                    s_tvalid[i] && s_tready[i] && s_tlast[i] |-> ##[1:8] 
                    
                        (s_tdest[i] == 0) ? (m_tvalid[0] && m_tready[0] && m_tlast[0]) :
                                            (m_tvalid[1] && m_tready[1] && m_tlast[1]);        
            endproperty
            
            assert property (p_tlast_preserved)
                else $error("TLAST not seen on output after input TLAST!");

        end
    endgenerate

endinterface
