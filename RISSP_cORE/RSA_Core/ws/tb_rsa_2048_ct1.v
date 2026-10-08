`timescale 1ns / 1ps
module tb_rsa_2048_ct1;
    parameter S      = 64;
    parameter integer AWP = (S<=2)?1:$clog2(S);
    parameter CT     = 1;

    reg clk=0, rst=1, start=0, wr_en=0;
    reg [1:0]  wr_sel=0;
    reg [AWP-1:0] wr_addr=0, rd_addr=0;
    reg [31:0] wr_data=0;
    wire [31:0] rd_data;
    wire done;
    always #5 clk=~clk;

    rsa_modexp_ws #(.WORD(32),.S(S),.CONST_TIME(CT)) dut (
        .clk(clk),.rst(rst),.wr_en(wr_en),.wr_sel(wr_sel),.wr_addr(wr_addr),
        .wr_data(wr_data),.n0inv(32'hcbbb0d9f),.e(32'd65537),.e_bits(6'd17),
        .start(start),.done(done),.rd_addr(rd_addr),.rd_data(rd_data));

    reg [31:0] vN[0:S-1], vM[0:S-1], vR2[0:S-1], vC[0:S-1];
    integer i, errs=0, c0, c1, cyc=0;
    always @(posedge clk) if(!rst) cyc<=cyc+1;

    task load; input [1:0] sel; input [31:0] d; input integer a;
    begin @(negedge clk); wr_en=1; wr_sel=sel; wr_addr=a[AWP-1:0]; wr_data=d;
          @(negedge clk); wr_en=0; end
    endtask

    initial begin
        $readmemh("rsa2048_N.mem", vN); $readmemh("rsa2048_M.mem", vM);
        $readmemh("rsa2048_R2.mem", vR2); $readmemh("rsa2048_C.mem", vC);
        repeat(4) @(posedge clk); rst=0; @(negedge clk);
        for(i=0;i<S;i=i+1) load(2'd0, vM[i],  i);
        for(i=0;i<S;i=i+1) load(2'd1, vN[i],  i);
        for(i=0;i<S;i=i+1) load(2'd2, vR2[i], i);
        @(negedge clk); c0=cyc; start=1; @(negedge clk); start=0;
        wait(done); c1=cyc;
        @(negedge clk);
        for(i=0;i<S;i=i+1) begin
            rd_addr=i[AWP-1:0]; #1;
            if (rd_data !== vC[i]) begin
                errs=errs+1;
                if (errs<6) $display("  SAI tu[%0d]: %08x  ky vong %08x", i, rd_data, vC[i]);
            end
        end
        $display("--------------------------------------------------");
        $display("  RSA-%0d bit (S=%0d)  CONST_TIME=%0d", S*32, S, CT);
        $display("  Chu ky luy thua (start->done): %0d", c1-c0);
        $display("  Uoc luong ly thuyet 2*S^2*Nmm : %0d", 2*S*S*(CT?37:20));
        if (errs==0) $display("  ==> [PASS] khop pow(M,65537,N) tinh bang Python");
        else         $display("  ==> [FAIL] %0d/%0d tu sai", errs, S);
        $display("--------------------------------------------------");
        $finish;
    end
    initial begin #200000000; $display("[TIMEOUT]"); $finish; end
endmodule
