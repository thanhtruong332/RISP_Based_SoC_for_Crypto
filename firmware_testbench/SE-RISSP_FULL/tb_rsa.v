`timescale 1ns / 1ps
// ================================================================
//  SE-RISSP + RSA verify - do latency + verify ket qua
//  Sinh tu dong boi gen_all.py - KHONG sua tay.
//
//  Chay rsa.coe (da nap vao blk_mem_gen_0) tren design_1_wrapper THAT:
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
module tb_rsa;

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

// --- moc cycle tren AXI cua RSA ---
wire [31:0] aw_addr  = {24'h0, dut.design_1_i.RSA_mark03_0.s00_axi_awaddr};
wire        aw_valid = dut.design_1_i.RSA_mark03_0.s00_axi_awvalid;
wire [31:0] ar_addr  = {24'h0, dut.design_1_i.RSA_mark03_0.s00_axi_araddr};
wire        r_valid  = dut.design_1_i.RSA_mark03_0.s00_axi_rvalid;
wire        rsa_done = dut.design_1_i.RSA_mark03_0.inst.RSA_mark03_slave_lite_v1_0_S00_AXI_inst.done_latch;

integer t_m=0, t_start=0, t_done=0, t_res=0, t_bram=0;
reg f_m=0, f_start=0, f_done=0, f_res=0, f_bram=0;

always @(posedge soc_clk) if (!f_m && aw_valid && aw_addr[7:0]==8'h00)
    begin t_m=cyc; f_m=1; $display("[C%0d] nap M (signature)", cyc); end

always @(posedge soc_clk) if (!f_start && aw_valid && aw_addr[7:0]==8'h14)
    begin t_start=cyc; f_start=1; $display("[C%0d] CTRL start=1 (bat dau modexp)", cyc); end

always @(posedge soc_clk) if (f_start && !f_done && rsa_done)
    begin t_done=cyc; f_done=1; $display("[C%0d] RSA done (%0d cyc)", cyc, cyc-t_start); end

// Chot moc RESULT theo DIA CHI thanh ghi ket qua (0x1C) - giong cach tb_aes
// chot CT (0x3C) va tb_sha3 chot DIGEST (0x2C). KHONG dem so lan doc vi
// truoc do firmware con poll STATUS (0x18) khong biet truoc bao nhieu lan.
always @(posedge soc_clk) if (f_done && !f_res && r_valid && ar_addr[7:0]==8'h1C)
    begin t_res=cyc; f_res=1; $display("[C%0d] doc xong RESULT ve CPU (END pure)", cyc); end

always @(posedge soc_clk) if (f_res && !f_bram && bram_en && bram_we!=4'h0)
    begin t_bram=cyc; f_bram=1; $display("[C%0d] ghi RESULT ra BRAM", cyc); end

task report;
    integer c_core, c_pure, c_e2e;
    real us_core, us_pure, us_e2e, ops, ops_pure, ops_e2e, eb, e_pure, e_e2e;
begin
    c_core = t_done-t_start;
    c_pure = f_res  ? t_res -t_m : 0;
    c_e2e  = f_bram ? t_bram-t_m : 0;
    us_core = c_core/FREQ_MHZ;
    us_pure = c_pure/FREQ_MHZ;
    us_e2e  = c_e2e /FREQ_MHZ;
    ops      = 1.0e6/us_core;
    ops_pure = (c_pure>0) ? 1.0e6/us_pure : 0.0;
    ops_e2e  = (c_e2e >0) ? 1.0e6/us_e2e  : 0.0;
    eb     = POWER_W*(c_core/(FREQ_MHZ*1.0e6))*1.0e9;
    e_pure = POWER_W*(c_pure/(FREQ_MHZ*1.0e6))*1.0e9;
    e_e2e  = POWER_W*(c_e2e /(FREQ_MHZ*1.0e6))*1.0e9;
    $display("\n================================================");
    $display("  SE-RISSP + RSA verify   (Freq=%.0f MHz, Power=%.3f W)", FREQ_MHZ, POWER_W);
    $display("================================================");
    $display("  C = M^E mod N   (Montgomery, E=65537)");
    $display("  Moc cycle: M=%0d start=%0d done=%0d RESULT=%0d BRAM=%0d",
             t_m, t_start, t_done, t_res, t_bram);
    $display("------------------------------------------------");
    $display("  [1] Loi RSA    (start->done) : %4d cyc = %6.2f us -> %8.0f verify/s", c_core, us_core, ops);
    $display("  [2] PURE       (M->RESULT)   : %4d cyc = %6.2f us -> %8.0f verify/s", c_pure, us_pure, ops_pure);
    $display("  [3] END-TO-END (M->BRAM)     : %4d cyc = %6.2f us -> %8.0f verify/s", c_e2e, us_e2e, ops_e2e);
    $display("------------------------------------------------");
    $display("  CO SO PURE (cung co so voi tb_aes / tb_sha3):");
    $display("    Energy/verify: %9.2f nJ", e_pure);
    $display("    verify/s/W   : %9.0f", (POWER_W>0.0)? ops_pure/POWER_W : 0.0);
    if (c_pure>0)
      $display("    Hieu suat    : %.1f%% (loi RSA %0d ck / PURE %0d ck)",
               100.0*c_core/c_pure, c_core, c_pure);
    else
      $display("    [!] CANH BAO: khong thay lan doc 0x1C -> PURE vo nghia.");
    $display("  [tham khao] loi: %.2f nJ | END-TO-END: %.2f nJ", eb, e_e2e);
    $display("------------------------------------------------");
    $display("  Verify ket qua:");
    vchk(m[0], 32'h25836f4b, "RESULT ");
    $display("  (bang XOR-fold cua SHA3-256 digest => chu ky HOP LE)");
    $display("------------------------------------------------");
    if (errs==0) $display("  ==> [PASS] RSA verify DUNG");
    else         $display("  ==> [FAIL] ket qua SAI");
    $display("================================================\n");
end
endtask

reg fin = 0;
always @(posedge clk_in1_0) if (!reset_0 && !fin) begin
    if (m[4] == 32'h600d0006) begin fin=1; report; $finish; end
    else if (cyc > 200000) begin
        fin = 1;
        $display("\n[TIMEOUT] cyc=%0d, chua thay marker (m[4]=%08x)", cyc, m[4]);
        $display("  -> kiem tra: blk_mem_gen_0 da nap rsa.coe + Generate Output Products chua?");
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
