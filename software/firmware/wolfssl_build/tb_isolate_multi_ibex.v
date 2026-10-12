`timescale 1ns / 1ps
module tb_isolate_multi_ibex;
    reg clk = 0, rst_n = 0;
    always #12.5 clk = ~clk;

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

    ibex_axi_top dut (
        .clk(clk), .rst_n(rst_n),
        .imem_addr(imem_addr), .imem_rdata(imem_rdata),
        .m_axi_awaddr(m_axi_awaddr), .m_axi_awprot(m_axi_awprot),
        .m_axi_awvalid(m_axi_awvalid), .m_axi_awready(m_axi_awready),
        .m_axi_wdata(m_axi_wdata), .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wvalid(m_axi_wvalid), .m_axi_wready(m_axi_wready),
        .m_axi_bresp(m_axi_bresp), .m_axi_bvalid(m_axi_bvalid), .m_axi_bready(m_axi_bready),
        .m_axi_araddr(m_axi_araddr), .m_axi_arprot(m_axi_arprot),
        .m_axi_arvalid(m_axi_arvalid), .m_axi_arready(m_axi_arready),
        .m_axi_rdata(m_axi_rdata), .m_axi_rresp(m_axi_rresp),
        .m_axi_rvalid(m_axi_rvalid), .m_axi_rready(m_axi_rready)
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
        $readmemh("aes_sha3_multi.hex", imem);
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
    end

    integer cyc=0;
    always @(posedge clk) if (rst_n) cyc=cyc+1;

    reg [31:0] t_cyc [0:13];
    reg [13:0] got;
    integer wi2;
    initial for (wi2=0; wi2<14; wi2=wi2+1) t_cyc[wi2]=0;
    initial got = 14'b0;
    always @(posedge clk) if (rst_n) begin
        if (m_axi_awvalid && m_axi_wvalid && !m_axi_bvalid) begin
            case (m_axi_awaddr[12:2])
                0:  if (!got[0])  begin t_cyc[0]=cyc;  got[0]=1;  end
                4:  if (!got[1])  begin t_cyc[1]=cyc;  got[1]=1;  end
                5:  if (!got[2])  begin t_cyc[2]=cyc;  got[2]=1;  end
                9:  if (!got[3])  begin t_cyc[3]=cyc;  got[3]=1;  end
                10: if (!got[4])  begin t_cyc[4]=cyc;  got[4]=1;  end
                14: if (!got[5])  begin t_cyc[5]=cyc;  got[5]=1;  end
                15: if (!got[6])  begin t_cyc[6]=cyc;  got[6]=1;  end
                19: if (!got[7])  begin t_cyc[7]=cyc;  got[7]=1;  end
                20: if (!got[8])  begin t_cyc[8]=cyc;  got[8]=1;  end
                23: if (!got[9])  begin t_cyc[9]=cyc;  got[9]=1;  end
                24: if (!got[10]) begin t_cyc[10]=cyc; got[10]=1; end
                27: if (!got[11]) begin t_cyc[11]=cyc; got[11]=1; end
                28: if (!got[12]) begin t_cyc[12]=cyc; got[12]=1; end
                31: if (!got[13]) begin t_cyc[13]=cyc; got[13]=1; end
            endcase
        end
    end

    reg fin=0;
    integer errs;
    always @(posedge clk) if (rst_n && !fin) begin
        if (dmem[32] == 32'h600d0001) begin
            fin = 1;
            errs = 0;
            $display("[%0d cyc] DONE (Ibex).", cyc);
            if (dmem[1]!==32'h69c4e0d8) begin errs=errs+1; $display("ECB CT0 FAIL %08x",dmem[1]); end
            if (dmem[4]!==32'h70b4c55a) begin errs=errs+1; $display("ECB CT3 FAIL %08x",dmem[4]); end
            if (dmem[6]!==32'h73bed6b8) begin errs=errs+1; $display("CBC CT0 FAIL %08x",dmem[6]); end
            if (dmem[9]!==32'h22229516) begin errs=errs+1; $display("CBC CT3 FAIL %08x",dmem[9]); end
            if (dmem[11]!==32'hc04b0535) begin errs=errs+1; $display("CFB CT0 FAIL %08x",dmem[11]); end
            if (dmem[14]!==32'h9ff7f2e6) begin errs=errs+1; $display("CFB CT3 FAIL %08x",dmem[14]); end
            if (dmem[16]!==32'h5ae4df3e) begin errs=errs+1; $display("CTR CT0 FAIL %08x",dmem[16]); end
            if (dmem[19]!==32'h0db03eab) begin errs=errs+1; $display("CTR CT3 FAIL %08x",dmem[19]); end
            if (dmem[21]!==32'hfcb6ea73) begin errs=errs+1; $display("SHA1 d03 FAIL %08x",dmem[21]); end
            if (dmem[22]!==32'h88b68266) begin errs=errs+1; $display("SHA1 d47 FAIL %08x",dmem[22]); end
            if (dmem[23]!==32'hc2856911) begin errs=errs+1; $display("SHA1 fold FAIL %08x",dmem[23]); end
            if (dmem[25]!==32'h4ae4cf47) begin errs=errs+1; $display("SHA4 d03 FAIL %08x",dmem[25]); end
            if (dmem[26]!==32'h000fe34a) begin errs=errs+1; $display("SHA4 d47 FAIL %08x",dmem[26]); end
            if (dmem[27]!==32'hfde88f49) begin errs=errs+1; $display("SHA4 fold FAIL %08x",dmem[27]); end
            if (dmem[29]!==32'h8567632f) begin errs=errs+1; $display("SHA16 d03 FAIL %08x",dmem[29]); end
            if (dmem[30]!==32'hf761dfe8) begin errs=errs+1; $display("SHA16 d47 FAIL %08x",dmem[30]); end
            if (dmem[31]!==32'h30242824) begin errs=errs+1; $display("SHA16 fold FAIL %08x",dmem[31]); end
            if (errs==0) $display("===> TAT CA PASS (Ibex, AES 4 mode + SHA3 3 kich thuoc)");
            else $display("===> CO %0d LOI", errs);
            $display("---- PURE cycles (START -> ket qua CUOI) ----");
            $display("AES-ECB PURE = %0d", t_cyc[1]-t_cyc[0]);
            $display("AES-CBC PURE = %0d", t_cyc[3]-t_cyc[2]);
            $display("AES-CFB PURE = %0d", t_cyc[5]-t_cyc[4]);
            $display("AES-CTR PURE = %0d", t_cyc[7]-t_cyc[6]);
            $display("SHA3-1blk  PURE = %0d", t_cyc[9]-t_cyc[8]);
            $display("SHA3-4blk  PURE = %0d", t_cyc[11]-t_cyc[10]);
            $display("SHA3-16blk PURE = %0d", t_cyc[13]-t_cyc[12]);
            $finish;
        end
        if (cyc > 5000000) begin
            $display("[TIMEOUT] cyc=%0d dmem[32]=%08x", cyc, dmem[32]);
            $finish;
        end
    end
endmodule
