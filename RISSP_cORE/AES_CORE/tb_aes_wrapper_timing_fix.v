`timescale 1ns / 1ps
// Kiem tra hoi quy sau khi them 1 tang thanh ghi pipeline vao KeyExpansion
// (fix timing WNS -7.998ns do trong SE-RISSP_AES_ULTRA). Drive dung
// register map cua aes_wrapper.v (giong het cach aes_axi_slave.v goi) de
// xac nhan ECB van ra dung ciphertext chuan NIST sau khi sua.
module tb_aes_wrapper_timing_fix;

    reg clk = 0;
    reg rst_n = 0;
    reg [31:0] addr, wdata;
    reg [3:0]  wstrb;
    reg        read_en, write_en;
    wire [31:0] rdata;

    integer errors = 0;
    integer cyc;

    always #5 clk = ~clk;

    aes_wrapper dut (
        .clk(clk), .rst_n(rst_n),
        .addr(addr), .wdata(wdata), .wstrb(wstrb),
        .read_en(read_en), .write_en(write_en),
        .rdata(rdata), .ready()
    );

    task wr;
        input [7:0]  off;
        input [31:0] data;
        begin
            @(negedge clk);
            addr = off; wdata = data; wstrb = 4'hF; write_en = 1'b1;
            @(negedge clk);
            write_en = 1'b0;
        end
    endtask

    task rd;
        input  [7:0]  off;
        output [31:0] data;
        begin
            @(negedge clk);
            addr = off; read_en = 1'b1;
            @(negedge clk);
            read_en = 1'b0;
            data = rdata;
        end
    endtask

    reg [31:0] status;
    reg [127:0] digest;

    localparam [127:0] EXP_ECB = 128'h3ad77bb40d7a3660a89ecaf32466ef97;
    localparam [127:0] EXP_CBC = 128'h7649abac8119b246cee98e9b12e9197d;
    localparam [127:0] EXP_CFB = 128'h3b3fd92eb72dad20333449f8e83cfb4a;
    localparam [127:0] EXP_CTR = 128'h874d6191b620e3261bef6864990db6ce;

    task run_case;
        input [31:0] iv0, iv1, iv2, iv3;   // 0 neu mode khong dung IV
        input        load_iv;
        input [31:0] ctrl_val;             // start=1 + mode bits
        input [127:0] expect;
        input [8*4-1:0] name;
        begin
            // reset giua cac case de dam bao trang thai sach (mode_reg/state ve 0)
            rst_n = 0; @(posedge clk); @(posedge clk); rst_n = 1; @(posedge clk);

            wr(8'h10, 32'h2b7e1516);
            wr(8'h14, 32'h28aed2a6);
            wr(8'h18, 32'habf71588);
            wr(8'h1C, 32'h09cf4f3c);
            if (load_iv) begin
                wr(8'h40, iv0); wr(8'h44, iv1); wr(8'h48, iv2); wr(8'h4C, iv3);
            end
            wr(8'h00, 32'h6bc1bee2);
            wr(8'h04, 32'h2e409f96);
            wr(8'h08, 32'he93d7e11);
            wr(8'h0C, 32'h7393172a);
            wr(8'h20, ctrl_val);

            cyc = 0; status = 0;
            while (status[0] !== 1'b1 && cyc < 500) begin
                rd(8'h24, status);
                cyc = cyc + 1;
            end

            if (status[0] !== 1'b1) begin
                $display("[FAIL] %0s TIMEOUT sau %0d lan poll", name, cyc);
                errors = errors + 1;
            end else begin
                rd(8'h30, digest[127:96]);
                rd(8'h34, digest[95:64]);
                rd(8'h38, digest[63:32]);
                rd(8'h3C, digest[31:0]);
                if (digest === expect)
                    $display("[PASS] %0s qua aes_wrapper = %h", name, digest);
                else begin
                    $display("[FAIL] %0s = %h expected %h", name, digest, expect);
                    errors = errors + 1;
                end
            end
        end
    endtask

    initial begin
        addr=0; wdata=0; wstrb=0; read_en=0; write_en=0;
        rst_n = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        // ECB: khong IV, mode=00, start=1 -> ctrl=1
        run_case(0,0,0,0, 1'b0, 32'h1, EXP_ECB, "ECB ");
        // CBC: IV=000102030405060708090a0b0c0d0e0f, mode=01, start=1 -> ctrl=3
        run_case(32'h00010203, 32'h04050607, 32'h08090a0b, 32'h0c0d0e0f, 1'b1, 32'h3, EXP_CBC, "CBC ");
        // CFB: IV giong CBC, mode=11, start=1 -> ctrl=7
        run_case(32'h00010203, 32'h04050607, 32'h08090a0b, 32'h0c0d0e0f, 1'b1, 32'h7, EXP_CFB, "CFB ");
        // CTR: IV=f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff, mode=10, start=1 -> ctrl=5
        run_case(32'hf0f1f2f3, 32'hf4f5f6f7, 32'hf8f9fafb, 32'hfcfdfeff, 1'b1, 32'h5, EXP_CTR, "CTR ");

        if (errors == 0) $display("REGRESSION PASS (4/4 mode) - fix timing khong lam sai chuc nang");
        else $display("%0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
