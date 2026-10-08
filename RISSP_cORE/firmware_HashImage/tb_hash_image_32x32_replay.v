`timescale 1ns / 1ps
// Verify dung chuoi tu ma hash_image_32x32.s se ghi (1024 byte, sinh boi
// gen_image_firmware.py) - drive thang vao Keccak, doi chieu Python hashlib.
module tb_hash_image_32x32_replay;
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
    localparam [255:0] EXPECTED = 256'h50c4674596f93c43253ad67fc3f629b5fecffff290a54dd8644dbff876d62505;

    initial begin
        rst = 1; iReady = 0; iLast = 0; iByte_num = 0; iData = 0;
        repeat (5) @(posedge clk);
        rst = 0;
        @(posedge clk);

        send_word(64'h0718293a4b5c6d7e, 1'b0, 3'd0);
        send_word(64'h8fa0b1c2d3e4f506, 1'b0, 3'd0);
        send_word(64'h1728394a5b6c7d8e, 1'b0, 3'd0);
        send_word(64'h9fb0c1d2e3f40516, 1'b0, 3'd0);
        send_word(64'h2435465768798a9b, 1'b0, 3'd0);
        send_word(64'hacbdcedff0011223, 1'b0, 3'd0);
        send_word(64'h3445566778899aab, 1'b0, 3'd0);
        send_word(64'hbccddeef00112233, 1'b0, 3'd0);
        send_word(64'h415263748596a7b8, 1'b0, 3'd0);
        send_word(64'hc9daebfc0d1e2f40, 1'b0, 3'd0);
        send_word(64'h5162738495a6b7c8, 1'b0, 3'd0);
        send_word(64'hd9eafb0c1d2e3f50, 1'b0, 3'd0);
        send_word(64'h5e6f8091a2b3c4d5, 1'b0, 3'd0);
        send_word(64'he6f708192a3b4c5d, 1'b0, 3'd0);
        send_word(64'h6e7f90a1b2c3d4e5, 1'b0, 3'd0);
        send_word(64'hf60718293a4b5c6d, 1'b0, 3'd0);
        send_word(64'h7b8c9daebfd0e1f2, 1'b0, 3'd0);
        send_word(64'h031425364758697a, 1'b0, 3'd0);
        send_word(64'h8b9cadbecfe0f102, 1'b0, 3'd0);
        send_word(64'h132435465768798a, 1'b0, 3'd0);
        send_word(64'h98a9bacbdcedfe0f, 1'b0, 3'd0);
        send_word(64'h2031425364758697, 1'b0, 3'd0);
        send_word(64'ha8b9cadbecfd0e1f, 1'b0, 3'd0);
        send_word(64'h30415263748596a7, 1'b0, 3'd0);
        send_word(64'hb5c6d7e8f90a1b2c, 1'b0, 3'd0);
        send_word(64'h3d4e5f708192a3b4, 1'b0, 3'd0);
        send_word(64'hc5d6e7f8091a2b3c, 1'b0, 3'd0);
        send_word(64'h4d5e6f8091a2b3c4, 1'b0, 3'd0);
        send_word(64'hd2e3f40516273849, 1'b0, 3'd0);
        send_word(64'h5a6b7c8d9eafc0d1, 1'b0, 3'd0);
        send_word(64'he2f3041526374859, 1'b0, 3'd0);
        send_word(64'h6a7b8c9daebfd0e1, 1'b0, 3'd0);
        send_word(64'hef00112233445566, 1'b0, 3'd0);
        send_word(64'h778899aabbccddee, 1'b0, 3'd0);
        send_word(64'hff10213243546576, 1'b0, 3'd0);
        send_word(64'h8798a9bacbdcedfe, 1'b0, 3'd0);
        send_word(64'h0c1d2e3f50617283, 1'b0, 3'd0);
        send_word(64'h94a5b6c7d8e9fa0b, 1'b0, 3'd0);
        send_word(64'h1c2d3e4f60718293, 1'b0, 3'd0);
        send_word(64'ha4b5c6d7e8f90a1b, 1'b0, 3'd0);
        send_word(64'h293a4b5c6d7e8fa0, 1'b0, 3'd0);
        send_word(64'hb1c2d3e4f5061728, 1'b0, 3'd0);
        send_word(64'h394a5b6c7d8e9fb0, 1'b0, 3'd0);
        send_word(64'hc1d2e3f405162738, 1'b0, 3'd0);
        send_word(64'h465768798a9bacbd, 1'b0, 3'd0);
        send_word(64'hcedff00112233445, 1'b0, 3'd0);
        send_word(64'h566778899aabbccd, 1'b0, 3'd0);
        send_word(64'hdeef001122334455, 1'b0, 3'd0);
        send_word(64'h63748596a7b8c9da, 1'b0, 3'd0);
        send_word(64'hebfc0d1e2f405162, 1'b0, 3'd0);
        send_word(64'h738495a6b7c8d9ea, 1'b0, 3'd0);
        send_word(64'hfb0c1d2e3f506172, 1'b0, 3'd0);
        send_word(64'h8091a2b3c4d5e6f7, 1'b0, 3'd0);
        send_word(64'h08192a3b4c5d6e7f, 1'b0, 3'd0);
        send_word(64'h90a1b2c3d4e5f607, 1'b0, 3'd0);
        send_word(64'h18293a4b5c6d7e8f, 1'b0, 3'd0);
        send_word(64'h9daebfd0e1f20314, 1'b0, 3'd0);
        send_word(64'h25364758697a8b9c, 1'b0, 3'd0);
        send_word(64'hadbecfe0f1021324, 1'b0, 3'd0);
        send_word(64'h35465768798a9bac, 1'b0, 3'd0);
        send_word(64'hbacbdcedfe0f2031, 1'b0, 3'd0);
        send_word(64'h425364758697a8b9, 1'b0, 3'd0);
        send_word(64'hcadbecfd0e1f3041, 1'b0, 3'd0);
        send_word(64'h5263748596a7b8c9, 1'b0, 3'd0);
        send_word(64'hd7e8f90a1b2c3d4e, 1'b0, 3'd0);
        send_word(64'h5f708192a3b4c5d6, 1'b0, 3'd0);
        send_word(64'he7f8091a2b3c4d5e, 1'b0, 3'd0);
        send_word(64'h6f8091a2b3c4d5e6, 1'b0, 3'd0);
        send_word(64'hf405162738495a6b, 1'b0, 3'd0);
        send_word(64'h7c8d9eafc0d1e2f3, 1'b0, 3'd0);
        send_word(64'h0415263748596a7b, 1'b0, 3'd0);
        send_word(64'h8c9daebfd0e1f203, 1'b0, 3'd0);
        send_word(64'h1122334455667788, 1'b0, 3'd0);
        send_word(64'h99aabbccddeeff10, 1'b0, 3'd0);
        send_word(64'h2132435465768798, 1'b0, 3'd0);
        send_word(64'ha9bacbdcedfe0f20, 1'b0, 3'd0);
        send_word(64'h2e3f5061728394a5, 1'b0, 3'd0);
        send_word(64'hb6c7d8e9fa0b1c2d, 1'b0, 3'd0);
        send_word(64'h3e4f60718293a4b5, 1'b0, 3'd0);
        send_word(64'hc6d7e8f90a1b2c3d, 1'b0, 3'd0);
        send_word(64'h4b5c6d7e8fa0b1c2, 1'b0, 3'd0);
        send_word(64'hd3e4f5061728394a, 1'b0, 3'd0);
        send_word(64'h5b6c7d8e9fb0c1d2, 1'b0, 3'd0);
        send_word(64'he3f405162738495a, 1'b0, 3'd0);
        send_word(64'h68798a9bacbdcedf, 1'b0, 3'd0);
        send_word(64'hf001122334455667, 1'b0, 3'd0);
        send_word(64'h78899aabbccddeef, 1'b0, 3'd0);
        send_word(64'h0011223344556677, 1'b0, 3'd0);
        send_word(64'h8596a7b8c9daebfc, 1'b0, 3'd0);
        send_word(64'h0d1e2f4051627384, 1'b0, 3'd0);
        send_word(64'h95a6b7c8d9eafb0c, 1'b0, 3'd0);
        send_word(64'h1d2e3f5061728394, 1'b0, 3'd0);
        send_word(64'ha2b3c4d5e6f70819, 1'b0, 3'd0);
        send_word(64'h2a3b4c5d6e7f90a1, 1'b0, 3'd0);
        send_word(64'hb2c3d4e5f6071829, 1'b0, 3'd0);
        send_word(64'h3a4b5c6d7e8fa0b1, 1'b0, 3'd0);
        send_word(64'hbfd0e1f203142536, 1'b0, 3'd0);
        send_word(64'h4758697a8b9cadbe, 1'b0, 3'd0);
        send_word(64'hcfe0f10213243546, 1'b0, 3'd0);
        send_word(64'h5768798a9bacbdce, 1'b0, 3'd0);
        send_word(64'hdcedfe0f20314253, 1'b0, 3'd0);
        send_word(64'h64758697a8b9cadb, 1'b0, 3'd0);
        send_word(64'hecfd0e1f30415263, 1'b0, 3'd0);
        send_word(64'h748596a7b8c9daeb, 1'b0, 3'd0);
        send_word(64'hf90a1b2c3d4e5f70, 1'b0, 3'd0);
        send_word(64'h8192a3b4c5d6e7f8, 1'b0, 3'd0);
        send_word(64'h091a2b3c4d5e6f80, 1'b0, 3'd0);
        send_word(64'h91a2b3c4d5e6f708, 1'b0, 3'd0);
        send_word(64'h162738495a6b7c8d, 1'b0, 3'd0);
        send_word(64'h9eafc0d1e2f30415, 1'b0, 3'd0);
        send_word(64'h263748596a7b8c9d, 1'b0, 3'd0);
        send_word(64'haebfd0e1f2031425, 1'b0, 3'd0);
        send_word(64'h33445566778899aa, 1'b0, 3'd0);
        send_word(64'hbbccddeeff102132, 1'b0, 3'd0);
        send_word(64'h435465768798a9ba, 1'b0, 3'd0);
        send_word(64'hcbdcedfe0f203142, 1'b0, 3'd0);
        send_word(64'h5061728394a5b6c7, 1'b0, 3'd0);
        send_word(64'hd8e9fa0b1c2d3e4f, 1'b0, 3'd0);
        send_word(64'h60718293a4b5c6d7, 1'b0, 3'd0);
        send_word(64'he8f90a1b2c3d4e5f, 1'b0, 3'd0);
        send_word(64'h6d7e8fa0b1c2d3e4, 1'b0, 3'd0);
        send_word(64'hf5061728394a5b6c, 1'b0, 3'd0);
        send_word(64'h7d8e9fb0c1d2e3f4, 1'b0, 3'd0);
        send_word(64'h05162738495a6b7c, 1'b0, 3'd0);
        send_word(64'h8a9bacbdcedff001, 1'b0, 3'd0);
        send_word(64'h1223344556677889, 1'b0, 3'd0);
        send_word(64'h9aabbccddeef0011, 1'b0, 3'd0);
        send_word(64'h2233445566778899, 1'b0, 3'd0);
        send_word(64'h0000000000000000, 1'b1, 3'd0);

        cyc = 0;
        while (!oReady && cyc < 20000) begin @(posedge clk); cyc = cyc + 1; end
        if (!oReady) begin
            $display("[FAIL] TIMEOUT sau %0d chu ky", cyc);
            errors = errors + 1;
        end else if (oData !== EXPECTED) begin
            $display("[FAIL] oData=%h expected=%h", oData, EXPECTED);
            errors = errors + 1;
        end else begin
            $display("[PASS] hash_image_32x32 replay (%0d byte) oData=%h sau %0d chu ky", 1024, oData, cyc);
        end

        if (errors == 0) $display("REPLAY VERIFIED CORRECT");
        else $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
