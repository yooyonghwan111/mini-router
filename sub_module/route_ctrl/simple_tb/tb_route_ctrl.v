module tb_route_ctrl ();
    
    reg clk;
    reg rst_n;
    reg [3:0] tvalid;
    reg [3:0] tdest;
    reg [3:0] tlast;
    reg [1:0] tready;
    wire [3:0] grant0;
    wire [3:0] grant1;

    integer i;

    route_ctrl dut (
        .clk(clk),
        .rst_n(rst_n),
        .tvalid(tvalid),
        .tdest(tdest),
        .tlast(tlast),
        .tready(tready),
        .grant0(grant0),
        .grant1(grant1)
    );

    initial begin
      clk=0;
      forever #5 clk = ~clk;
    end

    initial begin
    
    // seq1 : reset test
    $display("========================================================");
    $display("[%0t][Seq_1] reset test", $time);
    rst_n=0; tvalid=0; tdest=0; tlast=0; tready=2'b11;
    $display("[%0t][Seq_1] rst_n=%b, tvalid=%b, tdest=%b, tlast=%b, tready=%b", $time, rst_n, tvalid, tdest, tlast, tready);
    repeat(2) @(posedge clk);
    rst_n=1;
    $display("[%0t][Seq_1] rst_n=%b", $time, rst_n);
    repeat(2) @(posedge clk);
    if (grant0==0 && grant1==0) $display("[%0t][Seq_1] SUCCESS reset test ! grant0=%b, grant1=%b", $time, grant0, grant1);
    else $error("[%0t][Seq_1] FAIL reset test ! grant0=%b, grant1=%b", $time, grant0, grant1);
    $display("========================================================");

    // seq2 : single request routing test
    $display("========================================================");
    $display("[%0t][Seq_2] single request routing test", $time);
    tready=2'b11;

    @(posedge clk);
    for (i=0; i<4; i=i+1) begin
        $display("[%0t][Seq_2] single port %0d test, output port=0", $time, i);
        tvalid = (1 << i);
        tdest = 4'b0000;
        tlast = (1 << i);
        $display("[%0t][Seq_2] tvalid=%b, tdest=%b, tlast=%b, tready=%b", $time, tvalid, tdest, tlast, tready);
        repeat(2) @(posedge clk);
        if (grant0 == (1<<i)) $display("[%0t][Seq_2] SUCCESS single_port_0 test ! grant0=%b, grant1=%b", $time, grant0, grant1);
        else $error("[%0t][Seq_2] FAIL single_port_0 test ! grant0=%b, grant1=%b (exp:%b)", $time, grant0, grant1, (1<<i));
        $display("-----------------------------------------");
    end

    @(posedge clk);
    for (i=0; i<4; i=i+1) begin
        $display("[%0t][Seq_2] single port %0d test, output port=1", $time, i);
        tvalid = (1 << i);
        tdest = 4'b1111;
        tlast = (1 << i);
        $display("[%0t][Seq_2] tvalid=%b, tdest=%b, tlast=%b, tready=%b", $time, tvalid, tdest, tlast, tready);
        repeat(2) @(posedge clk);
        if (grant1 == (1<<i)) $display("[%0t][Seq_2] SUCCESS single_port_1 test ! grant0=%b, grant1=%b", $time, grant0, grant1);
        else $error("[%0t][Seq_2] FAIL single_port_1 test ! grant0=%b, grant1=%b (exp:%b)", $time, grant0, grant1, (1<<i));
        $display("-----------------------------------------");
    end

    $finish;
    end

endmodule
