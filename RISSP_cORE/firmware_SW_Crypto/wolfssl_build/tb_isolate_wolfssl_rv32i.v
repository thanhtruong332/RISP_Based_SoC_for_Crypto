`timescale 1ns / 1ps
// tb_isolate_wolfssl_rv32i.v - kiem tra RTL that (rv32i_ultra) chay CUNG 1
// binary wolfSSL da va cho RISSP (AES-128-ECB + SHA3-256("") + RSA-2048
// cong khai) - dung chung dung .hex, khong build lai firmware.
module tb_isolate_wolfssl_rv32i;
    reg clk = 0, rst_n = 0;
    always #12.5 clk = ~clk;  // 40MHz

    wire [31:0] imem_addr;
    reg  [31:0] imem_rdata;
    reg [31:0] imem [0:8191];

    always @(posedge clk) imem_rdata <= imem[imem_addr[14:2]];

    wire [31:0] m_axi_awaddr, m_axi_wdata, m_axi_araddr;
    wire [2:0] m_axi_awprot, m_axi_arprot;
    wire [3:0] m_axi_wstrb;
    wire m_axi_awvalid, m_axi_wvalid, m_axi_bready, m_axi_arvalid, m_axi_rready;
    reg  m_axi_awready=0, m_axi_wready=0, m_axi_bvalid=0, m_axi_arready=0, m_axi_rvalid=0;
    reg [31:0] m_axi_rdata = 0;
    reg [1:0] m_axi_bresp = 0, m_axi_rresp = 0;

    rv32i_ultra dut (
        .m00_axi_aclk(clk), .m00_axi_aresetn(rst_n), .m00_axi_init_axi_txn(1'b1),
        .inst_addr(imem_addr), .inst_data(imem_rdata),
        .m00_axi_awaddr(m_axi_awaddr), .m00_axi_awprot(m_axi_awprot),
        .m00_axi_awvalid(m_axi_awvalid), .m00_axi_awready(m_axi_awready),
        .m00_axi_wdata(m_axi_wdata), .m00_axi_wstrb(m_axi_wstrb),
        .m00_axi_wvalid(m_axi_wvalid), .m00_axi_wready(m_axi_wready),
        .m00_axi_bresp(m_axi_bresp), .m00_axi_bvalid(m_axi_bvalid), .m00_axi_bready(m_axi_bready),
        .m00_axi_araddr(m_axi_araddr), .m00_axi_arprot(m_axi_arprot),
        .m00_axi_arvalid(m_axi_arvalid), .m00_axi_arready(m_axi_arready),
        .m00_axi_rdata(m_axi_rdata), .m00_axi_rresp(m_axi_rresp),
        .m00_axi_rvalid(m_axi_rvalid), .m00_axi_rready(m_axi_rready)
    );

    reg [31:0] dmem [0:2047];
    integer di;
    initial for (di=0; di<2048; di=di+1) dmem[di] = 32'h0;

    reg [31:0] wr_word_idx;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m_axi_awready<=0; m_axi_wready<=0; m_axi_bvalid<=0;
            m_axi_arready<=0; m_axi_rvalid<=0;
        end else begin
            m_axi_awready <= m_axi_awvalid && m_axi_wvalid && !m_axi_bvalid;
            m_axi_wready  <= m_axi_awvalid && m_axi_wvalid && !m_axi_bvalid;

            if (m_axi_awvalid && m_axi_wvalid && !m_axi_bvalid) begin
                wr_word_idx = m_axi_awaddr[12:2];
                if (m_axi_wstrb[0]) dmem[wr_word_idx][7:0]   <= m_axi_wdata[7:0];
                if (m_axi_wstrb[1]) dmem[wr_word_idx][15:8]  <= m_axi_wdata[15:8];
                if (m_axi_wstrb[2]) dmem[wr_word_idx][23:16] <= m_axi_wdata[23:16];
                if (m_axi_wstrb[3]) dmem[wr_word_idx][31:24] <= m_axi_wdata[31:24];
                m_axi_bvalid <= 1;
            end else if (m_axi_bvalid && m_axi_bready) begin
                m_axi_bvalid <= 0;
            end

            m_axi_arready <= m_axi_arvalid && !m_axi_rvalid;
            if (m_axi_arvalid && !m_axi_rvalid && m_axi_arready) begin
                m_axi_rdata <= dmem[m_axi_araddr[12:2]];
                m_axi_rvalid <= 1;
            end else if (m_axi_rvalid && m_axi_rready) m_axi_rvalid <= 0;
        end
    end

    initial begin
        $readmemh("rissp_wolfssl.hex", imem);
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
    end

    integer cyc=0;
    always @(posedge clk) if (rst_n) cyc=cyc+1;

    reg fin=0;
    integer errs;

    // Debug: theo doi PC MOI CHU KY (khong dieu kien) trong 60 chu ky dau
    always @(posedge clk) if (rst_n && cyc > 0 && cyc <= 60) begin
        $display("[pc-trace cyc=%0d] imem_addr=%08x imem_rdata=%08x", cyc, imem_addr, imem_rdata);
    end

    // Debug: theo doi tung chu ky AXI trong 300 chu ky dau de tim bug bat tay
    always @(posedge clk) if (rst_n && cyc > 0 && cyc < 300) begin
        if (m_axi_awvalid || m_axi_wvalid || m_axi_bvalid || m_axi_arvalid || m_axi_rvalid ||
            m_axi_awready || m_axi_wready)
            $display("[cyc=%0d] AW(v=%b,r=%b,addr=%08x) W(v=%b,r=%b,data=%08x,strb=%b) B(v=%b,r=%b) AR(v=%b,r=%b,addr=%08x) R(v=%b,r=%b,data=%08x) imem_addr=%08x",
                cyc, m_axi_awvalid, m_axi_awready, m_axi_awaddr,
                m_axi_wvalid, m_axi_wready, m_axi_wdata, m_axi_wstrb,
                m_axi_bvalid, m_axi_bready,
                m_axi_arvalid, m_axi_arready, m_axi_araddr,
                m_axi_rvalid, m_axi_rready, m_axi_rdata, imem_addr);
    end

    always @(posedge clk) if (rst_n && !fin) begin
        if (dmem[4] == 32'h600d0001) begin
            fin = 1;
            errs = 0;
            $display("[%0d cyc] DONE (wolfSSL tren RV32I that).", cyc);

            if (dmem[0] !== 32'h69c4e0d8) begin errs=errs+1; $display("  AES CT[0]=%08x FAIL (ky vong 69c4e0d8)", dmem[0]); end
            if (dmem[1] !== 32'h6a7b0430) begin errs=errs+1; $display("  AES CT[1]=%08x FAIL (ky vong 6a7b0430)", dmem[1]); end
            if (dmem[2] !== 32'hd8cdb780) begin errs=errs+1; $display("  AES CT[2]=%08x FAIL (ky vong d8cdb780)", dmem[2]); end
            if (dmem[3] !== 32'h70b4c55a) begin errs=errs+1; $display("  AES CT[3]=%08x FAIL (ky vong 70b4c55a)", dmem[3]); end
            if (dmem[0]===32'h69c4e0d8 && dmem[1]===32'h6a7b0430 && dmem[2]===32'hd8cdb780 && dmem[3]===32'h70b4c55a)
                $display("  ==> [PASS] AES-128-ECB khop FIPS-197 App.C.1");

            if (dmem[8] !== 32'ha7ffc6f8) begin errs=errs+1; $display("  SHA3 digest[0..3]=%08x FAIL (ky vong a7ffc6f8)", dmem[8]); end
            if (dmem[9] !== 32'hbf1ed766) begin errs=errs+1; $display("  SHA3 digest[4..7]=%08x FAIL (ky vong bf1ed766)", dmem[9]); end
            if (dmem[10] !== 32'hfada7f1c) begin errs=errs+1; $display("  SHA3 fold32=%08x FAIL (ky vong fada7f1c)", dmem[10]); end
            if (dmem[8]===32'ha7ffc6f8 && dmem[9]===32'hbf1ed766 && dmem[10]===32'hfada7f1c)
                $display("  ==> [PASS] SHA3-256(\"\") khop hashlib chuan");

            $display("  [debug] InitRsaKey=%0d mp_read_n=%0d mp_set_e=%0d RsaFunction_ret=%0d outLen=%0d mp_init_n=%0d mp_init_e=%0d n.size=%0d dp_digits=%0d",
                     $signed(dmem[16]), $signed(dmem[17]), $signed(dmem[18]), $signed(dmem[14]), dmem[15],
                     $signed(dmem[19]), $signed(dmem[20]), dmem[21], dmem[22]);
            if (dmem[12] !== 32'h8adddfa5) begin errs=errs+1; $display("  RSA fold256=%08x FAIL (ky vong 8adddfa5)", dmem[12]); end
            if (dmem[13] !== 32'h3b12b00d) begin errs=errs+1; $display("  RSA out[0..3]=%08x FAIL (ky vong 3b12b00d)", dmem[13]); end
            if (dmem[12]===32'h8adddfa5 && dmem[13]===32'h3b12b00d)
                $display("  ==> [PASS] RSA-2048 (M^65537 mod N that) khop pow() Python");

            if (errs==0) $display("===> TAT CA PASS: wolfSSL that chay dung tren RTL RV32I that (CUNG 1 binary voi RISSP).");
            else         $display("===> CO %0d LOI.", errs);
            $finish;
        end
        if (cyc > 3000000) begin
            $display("[TIMEOUT] cyc=%0d dmem[4]=%08x (AES ct0=%08x)", cyc, dmem[4], dmem[0]);
            $display("  START marker (0x14->dmem5)=%08x", dmem[5]);
            $display("  RSA debug: InitRsaKey=%0d mp_read_n=%0d mp_set_e=%0d mp_init_n=%0d mp_init_e=%0d n.size=%0d",
                     $signed(dmem[16]), $signed(dmem[17]), $signed(dmem[18]), $signed(dmem[19]), $signed(dmem[20]), dmem[21]);
            $display("  PC-ish: imem_addr=%08x  progress_marker(0x60->dmem24)=%0d", imem_addr, dmem[24]);
            $finish;
        end
    end
endmodule
