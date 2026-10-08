`timescale 1ns / 1ps
module tb_rsa;
    reg  [31:0] p, q, msg_in;
    reg         clk, reset;
    wire [63:0] msg_out;
    wire        done;

    control #(.WIDTH(32)) dut (
        .p(p), .q(q), .clk(clk), .reset(reset),
        .msg_in(msg_in), .msg_out(msg_out), .mod_exp_finish(done)
    );

    always #12.5 clk = ~clk;   // 40 MHz

    // ---- reference: msg^e mod n, dung 128-bit trung gian ----
    function [63:0] pow_mod;
        input [63:0] base_i, exp_i, n_i;
        reg [127:0] acc, b;
        reg [63:0]  e;
        begin
            acc = 1; b = base_i % n_i; e = exp_i;
            while (e != 0) begin
                if (e[0]) acc = (acc * b) % n_i;
                b = (b * b) % n_i;
                e = e >> 1;
            end
            pow_mod = acc[63:0];
        end
    endfunction

    // ---- reference: gcd ----
    function [63:0] gcd;
        input [63:0] a_i, b_i;
        reg [63:0] a, b, t;
        begin
            a = a_i; b = b_i;
            while (b != 0) begin t = b; b = a % b; a = t; end
            gcd = a;
        end
    endfunction

    integer errors;
    reg [63:0] n, tot, e_hw, expected;

    task run_case;
        input [31:0] tp, tq, tmsg;
        integer cyc;
        begin
            p = tp; q = tq; msg_in = tmsg;
            reset = 1;
            repeat (20) @(posedge clk);   // CPU giu reset qua nhieu AXI write
            reset = 0;
            cyc = 0;
            while (!done && cyc < 3_000_000) begin @(posedge clk); cyc = cyc + 1; end
            n   = tp * tq;
            tot = (tp-1) * (tq-1);
            e_hw = dut.i_inst.e_reg;
            if (!done) begin
                $display("FAIL p=%0d q=%0d msg=%0d : TIMEOUT", tp, tq, tmsg);
                errors = errors + 1;
            end else begin
                expected = pow_mod({32'b0, tmsg}, e_hw, n);
                if (msg_out !== expected || gcd(e_hw, tot) != 1) begin
                    $display("FAIL p=%0d q=%0d msg=%0d : e=%0d out=%0d expected=%0d gcd=%0d",
                             tp, tq, tmsg, e_hw, msg_out, expected, gcd(e_hw, tot));
                    errors = errors + 1;
                end else begin
                    $display("PASS p=%0d q=%0d msg=%0d : n=%0d e=%0d cipher=%0d (%0d cycles, %0d us @40MHz)",
                             tp, tq, tmsg, n, e_hw, msg_out, cyc, (cyc*25)/1000);
                end
            end
        end
    endtask

    initial begin
        clk = 0; reset = 1; errors = 0;
        run_case(32'd61,    32'd53,    32'd65);        // RSA kinh dien n=3233
        run_case(32'd61,    32'd53,    32'd3300);      // msg > n -> can rut gon
        run_case(32'd251,   32'd241,   32'd12345);
        run_case(32'd65521, 32'd65519, 32'd777777);    // prime 16-bit lon
        run_case(32'd104729,32'd104723,32'd42);        // prime 17-bit, n ~ 2^34
        if (errors == 0) $display("== ALL TESTS PASSED ==");
        else             $display("== %0d TEST(S) FAILED ==", errors);
        $finish;
    end
endmodule