`timescale 1ns / 1ps
// ================================================================
//  SE-RISSP + SHA3-256 4 block - do throughput + verify digest
//  Sinh tu dong boi gen_all.py - KHONG sua tay.
//
//  Chay sha3_4.coe (da nap vao blk_mem_gen_0) tren design_1_wrapper THAT:
//  dung nguyen axi_interconnect_0 / clk_wiz_0 / proc_sys_reset_0 /
//  axi_bram_ctrl_0 + blk_mem_gen_1 cua Block Design, chi drive 2 port
//  ngoai cung clk_in1_0 (100MHz) + reset_0 (active-high).
//
//  TANG TOC MO PHONG (quan trong): MMCM trong clk_wiz_0 mat khoang 2ms
//  THOI GIAN MO PHONG moi lock xong va bat dau phat clk_out1 - trong khi
//  CPU chi can vai tram chu ky (~10us) de chay xong. Neu de nguyen, hon
//  99% thoi gian mo phong la ngoi cho MMCM => rat lau.
//  Cach xu ly: ep thang xung 40MHz (dung tan so that cua thiet ke, lay tu
//  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ) vao net clock noi bo cua Block
//  Design, va ep luon 'locked'=1 de proc_sys_reset_0 tha reset ngay.
//  Ve chuc nang hoan toan tuong duong - chi bo qua phan mo hinh hoa qua
//  trinh khoi dong MMCM (khong lien quan den thuat toan can verify).
//
//  Ket qua doc bang cach snoop BRAM_PORTA giua axi_bram_ctrl_0 va
//  blk_mem_gen_1 (khong the $readmemh vao blk_mem_gen vi la IP ma hoa).
// ================================================================
module tb_sha3_4;

parameter real POWER_W  = 0.407;   // Total On-Chip Power SoC RISSP (impl_1, do lai 2026-08-14)
parameter real FREQ_MHZ = 40.0;

reg clk_in1_0 = 0, reset_0 = 0;
always #5 clk_in1_0 = ~clk_in1_0;      // 100MHz vao clk_wiz_0

reg soc_clk_drv = 0;
always #12.5 soc_clk_drv = ~soc_clk_drv;   // 40MHz (chu ky 25ns) = clk_out1

design_1_wrapper dut (.clk_in1_0(clk_in1_0), .reset_0(reset_0));

initial begin
    force dut.design_1_i.clk_wiz_0_clk_out1 = soc_clk_drv;  // bo qua MMCM
    force dut.design_1_i.clk_wiz_0.locked   = 1'b1;
    reset_0 = 1;
    repeat (10) @(posedge clk_in1_0);
    reset_0 = 0;
    $display("[%0t] Reset released, CPU bat dau chay", $time);
end

wire soc_clk = dut.design_1_i.clk_wiz_0_clk_out1;   // doc dung net da ep
integer cyc = 0;
always @(posedge soc_clk) if (!reset_0) cyc = cyc + 1;

// --- snoop BRAM debug (axi_bram_ctrl_0 -> blk_mem_gen_1) ---
wire        bram_clk  = dut.design_1_i.axi_bram_ctrl_0_BRAM_PORTA_CLK;
wire        bram_en   = dut.design_1_i.axi_bram_ctrl_0_BRAM_PORTA_EN;
wire [3:0]  bram_we   = dut.design_1_i.axi_bram_ctrl_0_BRAM_PORTA_WE;
wire [12:0] bram_addr = dut.design_1_i.axi_bram_ctrl_0_BRAM_PORTA_ADDR;
wire [31:0] bram_din  = dut.design_1_i.axi_bram_ctrl_0_BRAM_PORTA_DIN;

reg [31:0] m [0:19];
integer k; initial for (k = 0; k < 20; k = k + 1) m[k] = 0;
always @(posedge bram_clk)
    if (bram_en && bram_we != 4'h0 && bram_addr < 13'd80)
        m[bram_addr[6:2]] <= bram_din;

integer errs = 0;
task vchk; input [31:0] g, e; input [8*8-1:0] nm;
begin
    if (g === e) $display("    %0s = %08x   OK", nm, g);
    else begin  $display("    %0s = %08x   FAIL (ky vong %08x)", nm, g, e); errs = errs + 1; end
end
endtask

// --- moc cycle tren AXI cua SHA3 (ban 4 block) ---
wire [31:0] aw_addr  = {24'h0, dut.design_1_i.SHA3_hardware_new_0.s01_axi_awaddr};
wire        aw_valid = dut.design_1_i.SHA3_hardware_new_0.s01_axi_awvalid;
wire [31:0] wr_data  = dut.design_1_i.SHA3_hardware_new_0.s01_axi_wdata;
wire [31:0] ar_addr  = {24'h0, dut.design_1_i.SHA3_hardware_new_0.s01_axi_araddr};
wire        r_valid  = dut.design_1_i.SHA3_hardware_new_0.s01_axi_rvalid;
wire        sha_ready= dut.design_1_i.SHA3_hardware_new_0.inst.SHA3_hardware_new_slave_lite_v1_0_S01_AXI_inst.sha3_oReady;

integer t_first=0, t_last=0, t_done=0, t_dig=0, t_bram=0;
reg f_first=0, f_last=0, f_done=0, f_dig=0, f_bram=0;
integer bcnt=0, absorb_cnt=0;

always @(posedge soc_clk)
    if (!f_first && aw_valid && aw_addr[7:0]==8'h08)
        begin t_first=cyc; f_first=1; $display("[C%0d] absorb tu dau tien (START)", cyc); end

// dem so tu da absorb -> kiem tra dung 67 tu (bat loi mat tu do backpressure)
always @(posedge soc_clk)
    if (aw_valid && aw_addr[7:0]==8'h08 && !wr_data[1]) absorb_cnt = absorb_cnt + 1;

always @(posedge soc_clk)
    if (f_first && !f_last && aw_valid && aw_addr[7:0]==8'h08 && wr_data[1])
        begin t_last=cyc; f_last=1;
              $display("[C%0d] tu cuoi (iLast=1) sau %0d tu -> padding+permutation",
                       cyc, absorb_cnt); end

always @(posedge soc_clk) if (f_last && !f_done && sha_ready)
    begin t_done=cyc; f_done=1; $display("[C%0d] digest san sang (%0d cyc sau iLast)", cyc, cyc-t_last); end

always @(posedge soc_clk)
    if (f_done && !f_dig && r_valid && ar_addr[7:0]==8'h2C)
        begin t_dig=cyc; f_dig=1; $display("[C%0d] doc xong 8 tu digest (END pure)", cyc); end

always @(posedge soc_clk)
    if (f_dig && !f_bram && bram_en && bram_we!=4'h0) begin
        bcnt = bcnt + 1;
        if (bcnt==8) begin t_bram=cyc; f_bram=1; $display("[C%0d] ghi xong 8 tu digest ra BRAM", cyc); end
    end

task report;
    integer c_core, c_perm, c_pure, c_e2e;
    real tp_perm, tp_pure, tp_e2e;
    real e_pure, e_e2e, eb_pure, eb_e2e;
begin
    c_core = t_done-t_last;
    c_perm = c_core - 1;                     // 1 tu padding (so tu = 17N-1)
    c_pure = f_dig  ? t_dig -t_first : 0;
    c_e2e  = f_bram ? t_bram-t_first : 0;
    tp_perm = 1088.0*FREQ_MHZ/c_perm;
    tp_pure = (c_pure>0) ? 4288.0*FREQ_MHZ/c_pure : 0.0;
    tp_e2e  = (c_e2e >0) ? 4288.0*FREQ_MHZ/c_e2e  : 0.0;
    e_pure  = POWER_W*(c_pure/(FREQ_MHZ*1.0e6))*1.0e9;
    e_e2e   = POWER_W*(c_e2e /(FREQ_MHZ*1.0e6))*1.0e9;
    eb_pure = e_pure/4288.0;
    eb_e2e  = e_e2e /4288.0;
    $display("\n================================================");
    $display("  SE-RISSP + SHA3-256  4 BLOCK  (Freq=%.0f MHz, Power=%.3f W)", FREQ_MHZ, POWER_W);
    $display("================================================");
    $display("  Message: 536 byte (4288 bit) = 67 tu 64-bit = dung 4 rate block");
    $display("  Moc cycle: absorb1=%0d iLast=%0d oReady=%0d DIGEST=%0d BRAM=%0d",
             t_first, t_last, t_done, t_dig, t_bram);
    $display("  So tu da absorb: %0d (ky vong 67)%0s", absorb_cnt,
             (absorb_cnt==67) ? "  OK" : "  <<< SAI! mat tu (backpressure?)");
    $display("------------------------------------------------");
    $display("  [1] Permutation CUOI (iLast->oReady): %0d cyc = 1 ck padding + %0d ck perm",
             c_core, c_perm);
    $display("      => peak lo (hang so phan cung): %.2f Mbps (1088 bit / %0d ck)", tp_perm, c_perm);
    $display("      LUU Y: KHONG tinh throughput message tu cua so nay khi N>1 -");
    $display("             4-1 permutation dau CHONG LAN voi luc CPU nap du lieu,");
    $display("             nen chung khong xuat hien trong bat ky cua so do nao.");
    $display("  [2] PURE       (absorb1->DIGEST): %5d cyc -> %8.2f Mbps", c_pure, tp_pure);
    $display("  [3] END-TO-END (absorb1->BRAM) : %5d cyc -> %8.2f Mbps", c_e2e, tp_e2e);
    $display("------------------------------------------------");
    $display("  CO SO PURE (cung co so voi tb_aes va ban 1-block):");
    $display("    Energy/hash : %9.2f nJ    Energy/bit  : %.4f nJ/bit", e_pure, eb_pure);
    $display("    Throughput/W: %9.2f Mbps/W", (POWER_W>0.0)? tp_pure/POWER_W : 0.0);
    if (c_pure>0)
      $display("    Hieu suat   : %.2f%% (perm 4x%0d = %0d ck / PURE %0d ck)",
               100.0*(4*c_perm)/c_pure, c_perm, 4*c_perm, c_pure);
    $display("  [tham khao] CO SO END-TO-END:");
    $display("    Energy/hash : %9.2f nJ    Energy/bit  : %.4f nJ/bit", e_e2e, eb_e2e);
    $display("    Throughput/W: %9.2f Mbps/W", (POWER_W>0.0)? tp_e2e/POWER_W : 0.0);
    if (c_pure>0)
      $display("    Chi phi moi tu 64-bit: %.2f ck", (c_pure-4*c_perm)/(67*1.0));
    $display("------------------------------------------------");
    $display("  Verify digest (doi chieu hashlib.sha3_256):");
    vchk(m[0], 32'h7df3d9cd, "D[0]   ");
    vchk(m[1], 32'h8212808e, "D[1]   ");
    vchk(m[2], 32'hb2a3ac20, "D[2]   ");
    vchk(m[3], 32'h38893a49, "D[3]   ");
    vchk(m[4], 32'h83077e65, "D[4]   ");
    vchk(m[5], 32'h7d1b53bb, "D[5]   ");
    vchk(m[6], 32'h68c50f77, "D[6]   ");
    vchk(m[7], 32'h0cf3fba9, "D[7]   ");
    $display("  Verify XOR-fold:");
    vchk(m[8], 32'hefe1162a, "fold   ");
    $display("------------------------------------------------");
    if (errs==0) $display("  ==> [PASS] SHA3-256 4 BLOCK DUNG CHUAN");
    else         $display("  ==> [FAIL] %0d cho SAI", errs);
    $display("================================================\n");
end
endtask

reg fin = 0;
always @(posedge clk_in1_0) if (!reset_0 && !fin) begin
    if (m[12] == 32'h600d0007) begin fin=1; report; $finish; end
    else if (cyc > 200000) begin
        fin = 1;
        $display("\n[TIMEOUT] cyc=%0d, chua thay marker (m[12]=%08x)", cyc, m[12]);
        $display("  -> kiem tra: blk_mem_gen_0 da nap sha3_4.coe + Generate Output Products chua?");
        report; $finish;
    end
end

// Chan cuoi cung: neu 'force' o tren khong an (vd elaborate thieu
// -debug typical) thi soc_clk khong chay -> 'cyc' dung yen -> timeout theo
// cyc o tren KHONG BAO GIO xay ra -> mo phong treo vinh vien. Timeout theo
// thoi gian tuyet doi duoi day dam bao luon ket thuc.
initial begin
    #1000000;                       // 1 ms (CPU chi can ~10 us)
    if (!fin) begin
        fin = 1;
        $display("\n[TIMEOUT tuyet doi] soc_clk dem duoc %0d chu ky sau 1ms.", cyc);
        if (cyc == 0)
            $display("  -> soc_clk KHONG chay: lenh 'force clk_wiz_0_clk_out1' khong an.",
                     "\n     Elaborate phai co '-debug typical' (Vivado GUI mac dinh da co).");
        else
            $display("  -> CPU co chay nhung chua ghi marker: kiem tra dung file .coe chua.");
        report; $finish;
    end
end

endmodule
