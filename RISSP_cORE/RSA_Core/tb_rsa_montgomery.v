`timescale 1ns / 1ps
// Verify doc lap module `rsa` (Montgomery, RSA_mark03_1_0/src/RSA_core.v)
// -- day la core THAT duoc AXI wrapper (RSA_mark03_slave_lite_v1_0_S00_AXI.v)
// instantiate, KHAC voi module `control` (Euclid) da audit truoc do trong
// RSA_Core/RSA_core.v cua repo nay. N_INV/R2_MOD_N tinh san bang Python.
module tb_rsa_montgomery;
    reg clk = 0;
    reg rst = 1;
    reg start;
    reg [31:0] M, E, N, N_INV, R2_MOD_N;
    wire [31:0] C;
    wire done;

    integer errors = 0;

    always #12.5 clk = ~clk; // 40MHz

    rsa #(.WIDTH(32), .E_BITS(32)) dut (
        .clk(clk), .rst(rst), .start(start),
        .M(M), .E(E), .N(N), .N_INV(N_INV), .R2_MOD_N(R2_MOD_N),
        .C(C), .done(done)
    );

    task run_case;
        input [31:0] tm, te, tn, tninv, tr2, texpected;
        input [8*20-1:0] name;
        integer cyc;
        begin
            rst = 1; start = 0;
            M = tm; E = te; N = tn; N_INV = tninv; R2_MOD_N = tr2;
            repeat (5) @(posedge clk);
            rst = 0;
            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;
            cyc = 0;
            while (!done && cyc < 10000) begin @(posedge clk); cyc = cyc + 1; end
            if (!done) begin
                $display("[FAIL] %0s TIMEOUT sau %0d chu ky", name, cyc);
                errors = errors + 1;
            end else if (C !== texpected) begin
                $display("[FAIL] %0s C=%0d (0x%h) expected=%0d (0x%h)", name, C, C, texpected, texpected);
                errors = errors + 1;
            end else begin
                $display("[PASS] %0s C=%0d (0x%h) sau %0d chu ky", name, C, C, cyc);
            end
        end
    endtask

    initial begin
        // n=3233 e=17 msg=65 -> C=2790 (dung vi du kinh dien Wikipedia RSA)
        run_case(32'd65, 32'd17, 32'd3233, 32'h669f289f, 32'h000007ed, 32'd2790, "wikipedia_classic");
        // cung n,e nhung msg=3300 > n -> can rut gon dung
        run_case(32'd3300, 32'd17, 32'd3233, 32'h669f289f, 32'h000007ed, 32'd641, "msg_needs_reduce");
        // n lon hon (251*241=60491), e=17
        run_case(32'd12345, 32'd17, 32'd60491, 32'h8db3829d, 32'h00006e15, 32'd41476, "bigger_n");
        // e=65537 CHUAN CONG NGHIEP, n gan day 32-bit (65521*65519)
        run_case(32'd777777, 32'd65537, 32'd4292870399, 32'hc0e10101, 32'h403d0201, 32'd2879956855, "e65537_industry_std");

        if (errors == 0) $display("ALL RSA MONTGOMERY TESTS PASS - khop pow(msg,e,n) Python");
        else $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
