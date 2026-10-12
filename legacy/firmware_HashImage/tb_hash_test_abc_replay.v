`timescale 1ns / 1ps
// Verify dung tu ma hash_test_abc.s se ghi (1 tu 64-bit "abc"+padding info,
// big-endian per-chunk, iByte_num=3) - drive thang vao Keccak, doi chieu
// Python hashlib.sha3_256(b"abc"). Cung phong cach tb_hash_image_replay.v.
module tb_hash_test_abc_replay;
    reg clk = 0;
    reg rst = 1;
    reg [63:0] iData;
    reg        iReady, iLast;
    reg [2:0]  iByte_num;
    wire oBuffer_full, f_oAck, oReady;
    wire [255:0] oData;

    always #5 clk = ~clk;

    Keccak #(.b(1600), .nr(24), .Length(4), .lbits(3)) dut (
        .iClk(clk), .iRst(rst), .iData(iData),
        .iReady(iReady), .iLast(iLast), .iByte_num(iByte_num),
        .oBuffer_full(oBuffer_full), .f_oAck(f_oAck),
        .oData(oData), .oReady(oReady)
    );

    task send_word;
        input [63:0] w;
        input is_last;
        input [2:0] byte_num;
        begin
            @(negedge clk);
            while (oBuffer_full) @(negedge clk);
            iData = w; iLast = is_last; iByte_num = byte_num; iReady = 1'b1;
            @(negedge clk);
            iReady = 1'b0; iLast = 1'b0;
        end
    endtask

    integer errors = 0;
    integer cyc;
    // python3 -c "import hashlib; print(hashlib.sha3_256(b'abc').hexdigest())"
    localparam [255:0] EXPECTED = 256'h3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532;

    initial begin
        rst = 1; iReady = 0; iLast = 0; iByte_num = 0; iData = 0;
        repeat (5) @(posedge clk);
        rst = 0;
        @(posedge clk);

        // data_hi=0x61626300 ('a','b','c',dont-care) data_lo=0x00000000
        // dung dung tu hash_test_abc.s se ghi (DATA_HI@0x00, DATA_LO@0x04)
        send_word(64'h6162630000000000, 1'b1, 3'd3);

        cyc = 0;
        while (!oReady && cyc < 20000) begin @(posedge clk); cyc = cyc + 1; end
        if (!oReady) begin
            $display("[FAIL] TIMEOUT sau %0d chu ky", cyc);
            errors = errors + 1;
        end else if (oData !== EXPECTED) begin
            $display("[FAIL] oData=%h expected=%h", oData, EXPECTED);
            errors = errors + 1;
        end else begin
            $display("[PASS] hash_test_abc replay oData=%h sau %0d chu ky", oData, cyc);
        end

        if (errors == 0) $display("HASH_TEST_ABC FIRMWARE SEQUENCE VERIFIED CORRECT");
        else $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
