`timescale 1ns/1ps
module tb_new32;
    reg clk=0, rst=1, start=0; always #5 clk=~clk;
    wire [31:0] C32, C17; wire d32, d17;
    reg  [31:0] R32=0, R17=0; reg f32=0, f17=0;
    integer cyc=0, c0=0, c1=0, c2=0;
    always @(posedge clk) if(!rst) cyc<=cyc+1;
    rsa #(.WIDTH(32),.E_BITS(32)) u32 (
        .clk(clk),.rst(rst),.start(start),.M(32'h0c20ed7d),.E(32'h00010001),
        .N(32'hffe000ff),.N_INV(32'hc0e10101),.R2_MOD_N(32'h403d0201),
        .C(C32),.done(d32));
    rsa #(.WIDTH(32),.E_BITS(32),.E_SCAN(17)) u17 (
        .clk(clk),.rst(rst),.start(start),.M(32'h0c20ed7d),.E(32'h00010001),
        .N(32'hffe000ff),.N_INV(32'hc0e10101),.R2_MOD_N(32'h403d0201),
        .C(C17),.done(d17));
    always @(posedge clk) if (d32 && !f32) begin f32<=1; R32<=C32; c1<=cyc; end
    always @(posedge clk) if (d17 && !f17) begin f17<=1; R17<=C17; c2<=cyc; end
    initial begin
        repeat(4) @(posedge clk); rst=0; @(negedge clk);
        c0=cyc; start=1; @(negedge clk); start=0;
        wait(f32 && f17); repeat(2) @(posedge clk);
        $display("------------------------------------------------");
        $display("  WIDTH=32 - vector DANG CHAY tren SoC that");
        $display("  E_SCAN=32 (drop-in): C=%08x  %0d ck  %s", R32, c1-c0,
                 (R32===32'h25836f4b)?"OK":"SAI");
        $display("  E_SCAN=17 (toi uu) : C=%08x  %0d ck  %s", R17, c2-c0,
                 (R17===32'h25836f4b)?"OK":"SAI");
        $display("  Ban CU: 186 ck");
        $display("------------------------------------------------");
        $finish;
    end
    initial begin #500000; $display("[TIMEOUT] f32=%b f17=%b", f32, f17); $finish; end
endmodule
