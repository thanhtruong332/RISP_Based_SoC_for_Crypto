`timescale 1ns / 1ps
// RV32I_software + wolfSSL AES-128 4 mode + SHA3-256 3 kich thuoc (KHONG RSA)
module tb_aes_sha3_multi;

parameter real FREQ_MHZ = 40.0;

reg clk_in1_0 = 0, reset_0 = 0;
always #5 clk_in1_0 = ~clk_in1_0;

reg soc_clk_drv = 0;
always #12.5 soc_clk_drv = ~soc_clk_drv;

design_1_wrapper dut (.clk_in1_0(clk_in1_0), .reset_0(reset_0));

initial begin
    force dut.design_1_i.clk_wiz_0_clk_out1 = soc_clk_drv;
    force dut.design_1_i.clk_wiz_0.locked   = 1'b1;
    reset_0 = 1;
    repeat (10) @(posedge clk_in1_0);
    reset_0 = 0;
    repeat (5) @(posedge clk_in1_0);
    force dut.design_1_i.proc_sys_reset_0_peripheral_aresetn = 1'b1;
    $display("[%0t] Reset released, CPU bat dau chay", $time);
end

wire soc_clk = dut.design_1_i.clk_wiz_0_clk_out1;
integer cyc = 0;
always @(posedge soc_clk) if (!reset_0) cyc = cyc + 1;

wire        bram_clk  = dut.design_1_i.axi_bram_ctrl_0_BRAM_PORTA_CLK;
wire        bram_en   = dut.design_1_i.axi_bram_ctrl_0_BRAM_PORTA_EN;
wire [3:0]  bram_we   = dut.design_1_i.axi_bram_ctrl_0_BRAM_PORTA_WE;
wire [12:0] bram_addr = dut.design_1_i.axi_bram_ctrl_0_BRAM_PORTA_ADDR;
wire [31:0] bram_din  = dut.design_1_i.axi_bram_ctrl_0_BRAM_PORTA_DIN;

reg [31:0] m [0:33];
integer k; initial for (k = 0; k < 34; k = k + 1) m[k] = 0;
always @(posedge bram_clk)
    if (bram_en && bram_we != 4'h0 && bram_addr < 13'd136)
        m[bram_addr[7:2]] <= bram_din;

// Bat moc chu ky PURE cho 7 phep toan
reg [31:0] t_cyc [0:13];
reg [13:0] got;
integer wi2; initial for (wi2=0; wi2<14; wi2=wi2+1) t_cyc[wi2]=0;
initial got = 14'b0;
// bram_addr[7:2] (6 bit, khong phai [6:2] 5 bit) - dung [6:2] se khien dia
// chi 0x80 (DONE, index 32) vong lai trung index 0 (ECB START), ghi de
// mat marker that. Da bat qua debug: idx0 bi DONE (cyc=852379) ghi de len
// gia tri that (cyc=4213) vi day chinh la bug nay.
always @(posedge bram_clk) if (bram_en && bram_we != 4'h0 && bram_addr < 13'd136) begin
    case (bram_addr[7:2])
        0:  begin t_cyc[0]=cyc;  got[0]=1;  end
        4:  begin t_cyc[1]=cyc;  got[1]=1;  end
        5:  begin t_cyc[2]=cyc;  got[2]=1;  end
        9:  begin t_cyc[3]=cyc;  got[3]=1;  end
        10: begin t_cyc[4]=cyc;  got[4]=1;  end
        14: begin t_cyc[5]=cyc;  got[5]=1;  end
        15: begin t_cyc[6]=cyc;  got[6]=1;  end
        19: begin t_cyc[7]=cyc;  got[7]=1;  end
        20: begin t_cyc[8]=cyc;  got[8]=1;  end
        23: begin t_cyc[9]=cyc;  got[9]=1;  end
        24: begin t_cyc[10]=cyc; got[10]=1; end
        27: begin t_cyc[11]=cyc; got[11]=1; end
        28: begin t_cyc[12]=cyc; got[12]=1; end
        31: begin t_cyc[13]=cyc; got[13]=1; end
    endcase
end

integer errs = 0;
task vchk; input [31:0] g, e; input [8*8-1:0] nm;
begin
    if (g === e) $display("    %0s = %08x   OK", nm, g);
    else begin  $display("    %0s = %08x   FAIL (ky vong %08x)", nm, g, e); errs = errs + 1; end
end
endtask

task report;
begin
    $display("\n================================================");
    $display("  RV32I_software + wolfSSL AES 4 mode + SHA3 3 kich thuoc (Freq=%.0f MHz)", FREQ_MHZ);
    $display("================================================");
    vchk(m[1], 32'h69c4e0d8, "ECB CT0 ");
    vchk(m[4], 32'h70b4c55a, "ECB CT3 ");
    vchk(m[6], 32'h73bed6b8, "CBC CT0 ");
    vchk(m[9], 32'h22229516, "CBC CT3 ");
    vchk(m[11],32'hc04b0535, "CFB CT0 ");
    vchk(m[14],32'h9ff7f2e6, "CFB CT3 ");
    vchk(m[16],32'h5ae4df3e, "CTR CT0 ");
    vchk(m[19],32'h0db03eab,"CTR CT3 ");
    vchk(m[21],32'hfcb6ea73, "SHA1 d03");
    vchk(m[22],32'h88b68266, "SHA1 d47");
    vchk(m[23],32'hc2856911,"SHA1 fold");
    vchk(m[25],32'h4ae4cf47, "SHA4 d03");
    vchk(m[26],32'h000fe34a, "SHA4 d47");
    vchk(m[27],32'hfde88f49,"SHA4 fold");
    vchk(m[29],32'h8567632f, "SHA16 d03");
    vchk(m[30],32'hf761dfe8, "SHA16 d47");
    vchk(m[31],32'h30242824,"SHA16 fold");
    $display("------------------------------------------------");
    if (errs==0) $display("  ==> [PASS] TAT CA (AES 4 mode + SHA3 3 kich thuoc) tren RV32I_software that");
    else         $display("  ==> [FAIL] %0d muc SAI", errs);
    $display("---- PURE cycles (START -> ket qua CUOI) ----");
    $display("  AES-ECB PURE = %0d", t_cyc[1]-t_cyc[0]);
    $display("  AES-CBC PURE = %0d", t_cyc[3]-t_cyc[2]);
    $display("  AES-CFB PURE = %0d", t_cyc[5]-t_cyc[4]);
    $display("  AES-CTR PURE = %0d", t_cyc[7]-t_cyc[6]);
    $display("  SHA3-1blk  PURE = %0d", t_cyc[9]-t_cyc[8]);
    $display("  SHA3-4blk  PURE = %0d", t_cyc[11]-t_cyc[10]);
    $display("  SHA3-16blk PURE = %0d", t_cyc[13]-t_cyc[12]);
    $display("================================================\n");
end
endtask

reg fin = 0;
always @(posedge clk_in1_0) if (!reset_0 && !fin) begin
    if (m[32] == 32'h600d0001) begin fin=1; report; $finish; end
    else if (cyc > 2000000) begin
        fin = 1;
        $display("\n[TIMEOUT] cyc=%0d, chua thay marker (m[32]=%08x)", cyc, m[32]);
        report; $finish;
    end
end

endmodule
