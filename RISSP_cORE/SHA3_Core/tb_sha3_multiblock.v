`timescale 1ns / 1ps
// Kiem tra SHA3-256 (Keccak.v) voi message NHIEU HON 1 block (rate=136 byte
// = 17 tu 64-bit cho SHA3-256) - truong hop chua tung duoc test truoc do
// (tb_sha3_core.v cu chi test EMPTY/"abc"/56-byte, deu nam trong 1 block).
// "Hash the image" thuc te chac chan can nhieu block, nen day la khoang
// trong verify quan trong nhat can lap truoc khi tin dung huong nay.
//
// Testbench nay MO PHONG DUNG hanh vi firmware phai lam: kiem tra
// oBuffer_full TRUOC MOI lan ghi tu moi - dung Padder.v thiet ke buffer
// day thi GATE OFF viec nhan du lieu moi (khong bao loi, chi am tham bo
// qua) cho toi khi F_permutation an xong block hien tai (bao qua f_oAck).
module tb_sha3_multiblock;
    reg clk = 0;
    reg rst = 1;
    reg [63:0] iData;
    reg        iReady, iLast;
    reg [2:0]  iByte_num;
    wire oBuffer_full, f_oAck, oReady;
    wire [255:0] oData;

    integer errors = 0;

    always #5 clk = ~clk;

    Keccak #(.b(1600), .nr(24), .Length(4), .lbits(3)) dut (
        .iClk(clk), .iRst(rst), .iData(iData),
        .iReady(iReady), .iLast(iLast), .iByte_num(iByte_num),
        .oBuffer_full(oBuffer_full), .f_oAck(f_oAck),
        .oData(oData), .oReady(oReady)
    );

    // Gui 1 tu 64-bit (8 byte), mo phong dung firmware: cho oBuffer_full
    // ha xuong 0 truoc khi day tu moi vao (bat buoc de khong mat du lieu
    // khi message > 1 block).
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

    task run_case;
        input [8*24-1:0] name;
        input [4095:0] msg;     // buffer lon, dung msg_len de biet do dai that
        input integer msg_len;  // so byte thuc cua msg (msg can trai trai o MSB)
        input [255:0] expected;
        integer nwords, i, rem;
        reg [63:0] w;
        integer cyc;
        begin
            rst = 1; iReady = 0; iLast = 0; iByte_num = 0; iData = 0;
            repeat (5) @(posedge clk);
            rst = 0;
            @(posedge clk);

            nwords = msg_len / 8;   // so tu 8-byte tron
            rem    = msg_len % 8;   // so byte le cuoi (0-7)

            for (i = 0; i < nwords; i = i + 1) begin
                // lay 8 byte tiep theo cua msg (msg can dat o cac bit cao nhat,
                // byte dau tien o [4095:4088], v.v.)
                w = msg[4095 - i*64 -: 64];
                send_word(w, 1'b0, 3'd0);
            end

            if (rem == 0) begin
                // dung ranh gioi 8-byte -> gui them 1 tu rong bao iLast, ibyte=0
                send_word(64'd0, 1'b1, 3'd0);
            end else begin
                w = msg[4095 - nwords*64 -: 64]; // tu cuoi, chi 'rem' byte cao la hop le
                send_word(w, 1'b1, rem[2:0]);
            end

            cyc = 0;
            while (!oReady && cyc < 20000) begin @(posedge clk); cyc = cyc + 1; end
            if (!oReady) begin
                $display("[FAIL] %0s TIMEOUT sau %0d chu ky", name, cyc);
                errors = errors + 1;
            end else if (oData !== expected) begin
                $display("[FAIL] %0s oData=%h expected=%h", name, oData, expected);
                errors = errors + 1;
            end else begin
                $display("[PASS] %0s (%0d byte, %0d tu tron + %0d byte le) oData=%h sau %0d chu ky",
                          name, msg_len, nwords, rem, oData, cyc);
            end
        end
    endtask

    initial begin
        // Case A: 300 byte (khong tron block, 300 = 2*136 + 28 -> can 3 block)
        run_case("300byte_3block", {
            {300{8'h41}}, {(512-300)*8{1'b0}}   // 300 byte 0x41 ('A'), phan con lai padding 0 (khong dung)
        }, 300, 256'h5b0d2e21ce594c6109363eca66d9b679e88fa83b9f0bf6100bdac9723a0e8650);

        // Case B: dung 272 byte = 2*136 (dung ranh gioi 2 block -> can block 3 toan padding)
        run_case("272byte_2block_boundary", {
            {272{8'h42}}, {(512-272)*8{1'b0}}
        }, 272, 256'hbb913bf9c786e016ed2eb23e6c3efb062dcd469c46dd2895bbfe53784e423fc8);

        // Case C: 137 byte (vua qua 1 block 1 byte -> can block 2 chi co 1 byte thuc + padding)
        run_case("137byte_justover1block", {
            {137{8'h43}}, {(512-137)*8{1'b0}}
        }, 137, 256'h843ac6253460bd83c1e5383e1806876a9fdfcc73565cd65c401d1641a71870c0);

        if (errors == 0) $display("ALL MULTIBLOCK SHA3 TESTS PASS");
        else $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
