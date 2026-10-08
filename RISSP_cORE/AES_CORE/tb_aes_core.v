`timescale 1ns / 1ps
// Testbench doc lap: kiem tra AESEncrypt (khong qua CPU/AXI) voi dung
// key/plaintext/IV ma 4 file firmware (super_rv32i_ecb/cbc/ctr/cfb.coe)
// nap vao AES peripheral, doi chieu voi NIST SP800-38A Appendix F
// (test vector chuan cong nghiep cho AES-128).
module tb_aes_core;

    reg clk = 0;
    reg reset = 1;
    reg enable;
    reg [1:0] mode_sel;
    reg [127:0] data_in, iv_in;
    reg [127:0] key_in;
    wire [1407:0] all_keys;
    wire keys_valid;
    wire [127:0] data_out;
    wire done_tick;

    integer errors = 0;

    always #5 clk = ~clk;

    // KeyExpansion gio pipeline noi bo (can clk/rst_n) - rst_n tach rieng
    // vi 'reset' cua AESEncrypt la active-high, khong dung chung cuc tinh.
    wire rst_n = ~reset;

    KeyExpansion key_exp (
        .clk(clk), .rst_n(rst_n),
        .key_in(key_in), .keys_out(all_keys), .keys_valid(keys_valid)
    );

    AESEncrypt dut (
        .data_in(data_in), .all_keys(all_keys), .keys_valid(keys_valid), .iv_in(iv_in),
        .mode_sel(mode_sel), .data_out(data_out), .done_tick(done_tick),
        .clk(clk), .enable(enable), .reset(reset)
    );

    localparam [127:0] KEY  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
    localparam [127:0] PT1  = 128'h6bc1bee22e409f96e93d7e117393172a;
    localparam [127:0] IV1  = 128'h000102030405060708090a0b0c0d0e0f; // CBC/CFB IV
    localparam [127:0] CTR1 = 128'hf0f1f2f3f4f5f6f7f8f9fafbfcfdfeff; // CTR initial counter

    localparam [127:0] EXP_ECB = 128'h3ad77bb40d7a3660a89ecaf32466ef97;
    localparam [127:0] EXP_CBC = 128'h7649abac8119b246cee98e9b12e9197d;
    localparam [127:0] EXP_CFB = 128'h3b3fd92eb72dad20333449f8e83cfb4a;
    localparam [127:0] EXP_CTR = 128'h874d6191b620e3261bef6864990db6ce;

    task run_case;
        input [127:0] din;
        input [127:0] ivn;
        input [1:0]   msel;
        input [127:0] exp;
        input [8*8-1:0] name;
        begin
            @(negedge clk);
            reset = 1; enable = 0;
            data_in = din; iv_in = ivn; mode_sel = msel;
            @(negedge clk); @(negedge clk);
            reset = 0;
            @(negedge clk);
            enable = 1;
            @(negedge clk);
            enable = 0;
            wait (done_tick == 1);
            @(negedge clk);
            if (data_out === exp) begin
                $display("[PASS] %0s  data_out=%h", name, data_out);
            end else begin
                $display("[FAIL] %0s  data_out=%h expected=%h", name, data_out, exp);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        key_in = KEY;
        data_in = 0; iv_in = 0; mode_sel = 0; enable = 0; reset = 1;

        run_case(PT1, 128'h0,  2'b00, EXP_ECB, "ECB ");
        run_case(PT1, IV1,     2'b01, EXP_CBC, "CBC ");
        run_case(PT1, IV1,     2'b11, EXP_CFB, "CFB ");
        run_case(PT1, CTR1,    2'b10, EXP_CTR, "CTR ");

        if (errors == 0)
            $display("ALL 4 MODES PASS - khop NIST SP800-38A test vector");
        else
            $display("%0d MODE(S) FAILED", errors);

        $finish;
    end

endmodule
