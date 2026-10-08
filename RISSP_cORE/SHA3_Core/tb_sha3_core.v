`timescale 1ns / 1ps
// Testbench doc lap cho loi Keccak (SHA3-256, Length=4) - drive truc tiep
// khong qua AXI, doi chieu voi digest chuan tinh boi Python hashlib.sha3_256
// (khong dung test vector nho tu tri nho, tranh loi go tay nhu vu AES truoc).
module tb_sha3_core;

    reg clk = 0;
    reg iRst = 1;
    reg [63:0] iData;
    reg iReady, iLast;
    reg [2:0] iByte_num;
    wire oBuffer_full, f_oAck;
    wire [255:0] oData;
    wire oReady;

    integer errors = 0;
    integer timeout;

    always #5 clk = ~clk;

    Keccak #(.b(1600), .nr(24), .Length(4), .lbits(3)) dut (
        .iClk(clk), .iRst(iRst),
        .iData(iData), .iReady(iReady), .iLast(iLast), .iByte_num(iByte_num),
        .oBuffer_full(oBuffer_full), .f_oAck(f_oAck),
        .oData(oData), .oReady(oReady)
    );

    task drive_chunk;
        input [63:0] data;
        input        last;
        input [2:0]  bnum;
        begin
            @(negedge clk);
            iData = data; iReady = 1'b1; iLast = last; iByte_num = bnum;
            @(negedge clk);
            // Deassert ngay trong task, khong de iReady=1 "tran" sang khe
            // ho truoc khi task tiep theo gan gia tri moi (gay shift 2 lan
            // cho cung 1 tu du lieu - da bat qua debug trace cua dut.padder_.i).
            iReady = 1'b0; iLast = 1'b0; iByte_num = 3'b0;
        end
    endtask

    task idle_cycle;
        begin
            @(negedge clk);
            iReady = 1'b0; iLast = 1'b0; iByte_num = 3'b0;
        end
    endtask

    task check_result;
        input [255:0] expect;
        input [8*8-1:0] name;
        begin
            timeout = 0;
            while (!oReady && timeout < 500) begin
                @(negedge clk);
                timeout = timeout + 1;
            end
            if (!oReady) begin
                $display("[FAIL] %0s  TIMEOUT (oReady chua len sau 500 chu ky)", name);
                errors = errors + 1;
            end else if (oData === expect) begin
                $display("[PASS] %0s  oData=%h", name, oData);
            end else begin
                $display("[FAIL] %0s  oData=%h expected=%h", name, oData, expect);
                errors = errors + 1;
            end
        end
    endtask

    task do_reset;
        begin
            @(negedge clk);
            iRst = 1; iReady = 0; iLast = 0; iByte_num = 0; iData = 0;
            @(negedge clk); @(negedge clk);
            iRst = 0;
        end
    endtask

    // Python hashlib.sha3_256 (ground truth, khong go tay tu tri nho):
    localparam [255:0] EXP_EMPTY = 256'ha7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a;
    localparam [255:0] EXP_ABC   = 256'h3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532;
    localparam [255:0] EXP_MSG56 = 256'h41c0dba2a9d6240849100376a8235e2c82e1b9998a999e21db32dd97496d3376;

    initial begin
        // --- Case 1: message rong "" ---
        do_reset;
        drive_chunk(64'h0, 1'b1, 3'd0);   // iLast=1, 0 byte valid -> pure padding word
        idle_cycle;
        check_result(EXP_EMPTY, "EMPTY");

        // --- Case 2: "abc" (3 byte: 0x61 0x62 0x63) ---
        do_reset;
        drive_chunk(64'h6162630000000000, 1'b1, 3'd3);
        idle_cycle;
        check_result(EXP_ABC, "ABC ");

        // --- Case 3: 56 byte "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" ---
        do_reset;
        drive_chunk(64'h6162636462636465, 1'b0, 3'd0);
        drive_chunk(64'h6364656664656667, 1'b0, 3'd0);
        drive_chunk(64'h6566676866676869, 1'b0, 3'd0);
        drive_chunk(64'h6768696a68696a6b, 1'b0, 3'd0);
        drive_chunk(64'h696a6b6c6a6b6c6d, 1'b0, 3'd0);
        drive_chunk(64'h6b6c6d6e6c6d6e6f, 1'b0, 3'd0);
        drive_chunk(64'h6d6e6f706e6f7071, 1'b0, 3'd0);
        drive_chunk(64'h0, 1'b1, 3'd0);   // khong con byte thuc, chi con padding
        idle_cycle;
        check_result(EXP_MSG56, "MSG56");

        if (errors == 0)
            $display("ALL 3 SHA3-256 TEST VECTORS PASS - khop hashlib.sha3_256");
        else
            $display("%0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
