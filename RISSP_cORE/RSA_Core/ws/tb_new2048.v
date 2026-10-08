`timescale 1ns/1ps
module tb_new2048;
    parameter S=64, W=2048;
    reg clk=0, rst=1, start=0; always #5 clk=~clk;
    reg [31:0] vN[0:S-1], vM[0:S-1], vR2[0:S-1], vC[0:S-1];
    reg [W-1:0] Nw=0, Mw=0, R2w=0, Cexp=0;
    wire [W-1:0] Cout; wire dn;
    reg fdone=0; reg [W-1:0] Cres=0;
    integer i, cyc=0, c0=0, c1=0, errs=0;
    always @(posedge clk) if(!rst) cyc<=cyc+1;

    rsa #(.WIDTH(W),.E_BITS(32),.E_SCAN(17),.CONST_TIME(1)) dut (
        .clk(clk),.rst(rst),.start(start),.M(Mw),.E(32'h00010001),.N(Nw),
        .N_INV({{(W-32){1'b0}},32'hcbbb0d9f}),.R2_MOD_N(R2w),
        .C(Cout),.done(dn));

    always @(posedge clk) if (dn && !fdone) begin fdone<=1; Cres<=Cout; c1<=cyc; end

    initial begin
        $readmemh("rsa2048_N.mem", vN);  $readmemh("rsa2048_M.mem", vM);
        $readmemh("rsa2048_R2.mem", vR2); $readmemh("rsa2048_C.mem", vC);
        for(i=0;i<S;i=i+1) begin
            Nw[i*32 +: 32]=vN[i]; Mw[i*32 +: 32]=vM[i];
            R2w[i*32 +: 32]=vR2[i]; Cexp[i*32 +: 32]=vC[i];
        end
        repeat(4) @(posedge clk); rst=0; @(negedge clk);
        c0=cyc; start=1; @(negedge clk); start=0;
        wait(fdone); repeat(2) @(posedge clk);
        for(i=0;i<S;i=i+1)
            if (Cres[i*32 +: 32] !== vC[i]) begin
                errs=errs+1;
                if (errs<5) $display("  SAI tu[%0d]: %08x ky vong %08x",
                                     i, Cres[i*32 +: 32], vC[i]);
            end
        $display("------------------------------------------------");
        $display("  WIDTH=2048  E_SCAN=17  CONST_TIME=1");
        $display("  Chu ky: %0d   (= %.2f ms @40MHz)", c1-c0, (c1-c0)*25.0/1000000.0);
        if (errs==0) $display("  ==> [PASS] khop pow(M,65537,N) cua Python");
        else         $display("  ==> [FAIL] %0d/%0d tu sai", errs, S);
        $display("------------------------------------------------");
        $finish;
    end
    initial begin #400000000; $display("[TIMEOUT]"); $finish; end
endmodule
