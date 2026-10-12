`timescale 1ns / 1ps
// Verify dung chuoi tu ma hash_image.s se ghi (56 tu 64-bit tu ota_demo.bin,
// big-endian per-chunk) - drive thang vao Keccak, doi chieu Python hashlib.
module tb_hash_image_replay;
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
    localparam [255:0] EXPECTED = 256'hfdfdfb15c0436e29646bf1e3d4872826ccb099ecaaf67b7dbb415620e0f7cac9;

    initial begin
        rst = 1; iReady = 0; iLast = 0; iByte_num = 0; iData = 0;
        repeat (5) @(posedge clk);
        rst = 0;
        @(posedge clk);

        send_word(64'hb705004037060044, 1'b0, 3'd0);
        send_word(64'hb7060048370400c0, 1'b0, 3'd0);
        send_word(64'hb7127e2b93826251, 1'b0, 3'd0);
        send_word(64'h23a85500b7d2ae28, 1'b0, 3'd0);
        send_word(64'h9382622a23aa5500, 1'b0, 3'd0);
        send_word(64'hb712f7ab93828258, 1'b0, 3'd0);
        send_word(64'h23ac5500b752cf09, 1'b0, 3'd0);
        send_word(64'h9382c2f323ae5500, 1'b0, 3'd0);
        send_word(64'hb7f2f1f09382322f, 1'b0, 3'd0);
        send_word(64'h23a05504b7f2f5f4, 1'b0, 3'd0);
        send_word(64'h9382726f23a25504, 1'b0, 3'd0);
        send_word(64'hb702faf89382b2af, 1'b0, 3'd0);
        send_word(64'h23a45504b702fefc, 1'b0, 3'd0);
        send_word(64'h9382f2ef23a65504, 1'b0, 3'd0);
        send_word(64'hb7624d8793821219, 1'b0, 3'd0);
        send_word(64'h23a05500b7e220b6, 1'b0, 3'd0);
        send_word(64'h9382623223a25500, 1'b0, 3'd0);
        send_word(64'hb772ef1b93824286, 1'b0, 3'd0);
        send_word(64'h23a45500b7b20d99, 1'b0, 3'd0);
        send_word(64'h9382e26c23a65500, 1'b0, 3'd0);
        send_word(64'h9302500023a05502, 1'b0, 3'd0);
        send_word(64'h83a2450293f21200, 1'b0, 3'd0);
        send_word(64'he38c02fe03aa0503, 1'b0, 3'd0);
        send_word(64'h83aa450303ab8503, 1'b0, 3'd0);
        send_word(64'h83abc50313031000, 1'b0, 3'd0);
        send_word(64'h2320460123225601, 1'b0, 3'd0);
        send_word(64'h2324660023206601, 1'b0, 3'd0);
        send_word(64'h2322760123246600, 1'b0, 3'd0);
        send_word(64'h9303300023200600, 1'b0, 3'd0);
        send_word(64'h2322060023247600, 1'b0, 3'd0);
        send_word(64'h8322c60093f21200, 1'b0, 3'd0);
        send_word(64'he38c02fe032c0601, 1'b0, 3'd0);
        send_word(64'h832c4601334c9c01, 1'b0, 3'd0);
        send_word(64'h832c8601334c9c01, 1'b0, 3'd0);
        send_word(64'h832cc601334c9c01, 1'b0, 3'd0);
        send_word(64'h832c0602334c9c01, 1'b0, 3'd0);
        send_word(64'h832c4602334c9c01, 1'b0, 3'd0);
        send_word(64'h832c8602334c9c01, 1'b0, 3'd0);
        send_word(64'h832cc602334c9c01, 1'b0, 3'd0);
        send_word(64'hb712614a9382f2a6, 1'b0, 3'd0);
        send_word(64'h23a05600b7020100, 1'b0, 3'd0);
        send_word(64'h9382120023a25600, 1'b0, 3'd0);
        send_word(64'hb702e0ff9382f20f, 1'b0, 3'd0);
        send_word(64'h23a45600b702e1c0, 1'b0, 3'd0);
        send_word(64'h9382121023a65600, 1'b0, 3'd0);
        send_word(64'hb7023d4093821220, 1'b0, 3'd0);
        send_word(64'h23a8560013031000, 1'b0, 3'd0);
        send_word(64'h23aa660083a28601, 1'b0, 3'd0);
        send_word(64'h93f21200e38c02fe, 1'b0, 3'd0);
        send_word(64'h83adc60163928d03, 1'b0, 3'd0);
        send_word(64'h2320440123225401, 1'b0, 3'd0);
        send_word(64'h2324640123267401, 1'b0, 3'd0);
        send_word(64'h376e0d60130ede00, 1'b0, 3'd0);
        send_word(64'h2328c4016f000001, 1'b0, 3'd0);
        send_word(64'h37ced0ba130e0ead, 1'b0, 3'd0);
        send_word(64'h2328c4016f000000, 1'b0, 3'd0);
        send_word(64'd0, 1'b1, 3'd0);  // tu rong ket thuc, dung boi so 8

        cyc = 0;
        while (!oReady && cyc < 20000) begin @(posedge clk); cyc = cyc + 1; end
        if (!oReady) begin
            $display("[FAIL] TIMEOUT sau %0d chu ky", cyc);
            errors = errors + 1;
        end else if (oData !== EXPECTED) begin
            $display("[FAIL] oData=%h expected=%h", oData, EXPECTED);
            errors = errors + 1;
        end else begin
            $display("[PASS] hash_image replay oData=%h sau %0d chu ky", oData, cyc);
        end

        if (errors == 0) $display("HASH_IMAGE FIRMWARE SEQUENCE VERIFIED CORRECT");
        else $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
