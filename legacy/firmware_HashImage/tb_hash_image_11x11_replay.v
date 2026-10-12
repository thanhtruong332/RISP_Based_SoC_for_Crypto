`timescale 1ns / 1ps
// Verify dung chuoi tu ma hash_image_11x11.s se ghi (121 byte, sinh boi
// gen_image_firmware.py) - drive thang vao Keccak, doi chieu Python hashlib.
module tb_hash_image_11x11_replay;
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
    localparam [255:0] EXPECTED = 256'hec43eb22febee4b3341afc250498943ce37c787700585527dd5cfe288259c3cb;

    initial begin
        rst = 1; iReady = 0; iLast = 0; iByte_num = 0; iData = 0;
        repeat (5) @(posedge clk);
        rst = 0;
        @(posedge clk);

        send_word(64'h0718293a4b5c6d7e, 1'b0, 3'd0);
        send_word(64'h8fa0b12435465768, 1'b0, 3'd0);
        send_word(64'h798a9bacbdce4152, 1'b0, 3'd0);
        send_word(64'h63748596a7b8c9da, 1'b0, 3'd0);
        send_word(64'heb5e6f8091a2b3c4, 1'b0, 3'd0);
        send_word(64'hd5e6f7087b8c9dae, 1'b0, 3'd0);
        send_word(64'hbfd0e1f203142598, 1'b0, 3'd0);
        send_word(64'ha9bacbdcedfe0f20, 1'b0, 3'd0);
        send_word(64'h3142b5c6d7e8f90a, 1'b0, 3'd0);
        send_word(64'h1b2c3d4e5fd2e3f4, 1'b0, 3'd0);
        send_word(64'h05162738495a6b7c, 1'b0, 3'd0);
        send_word(64'hef00112233445566, 1'b0, 3'd0);
        send_word(64'h7788990c1d2e3f50, 1'b0, 3'd0);
        send_word(64'h61728394a5b6293a, 1'b0, 3'd0);
        send_word(64'h4b5c6d7e8fa0b1c2, 1'b0, 3'd0);
        send_word(64'hd300000000000000, 1'b1, 3'd1);

        cyc = 0;
        while (!oReady && cyc < 20000) begin @(posedge clk); cyc = cyc + 1; end
        if (!oReady) begin
            $display("[FAIL] TIMEOUT sau %0d chu ky", cyc);
            errors = errors + 1;
        end else if (oData !== EXPECTED) begin
            $display("[FAIL] oData=%h expected=%h", oData, EXPECTED);
            errors = errors + 1;
        end else begin
            $display("[PASS] hash_image_11x11 replay (%0d byte) oData=%h sau %0d chu ky", 121, oData, cyc);
        end

        if (errors == 0) $display("REPLAY VERIFIED CORRECT");
        else $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
