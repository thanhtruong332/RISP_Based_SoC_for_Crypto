`timescale 1ns / 1ps
// ================================================================
//  SE-RISSP + RSA-2048 verify - do latency + verify ket qua
//  Sinh tu dong boi gen_all.py - KHONG sua tay.
//
//  Chay rsa2048.coe (da nap vao blk_mem_gen_0) tren design_1_wrapper THAT:
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
module tb_rsa2048;

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

// --- moc cycle tren AXI cua RSA (ban 2048-bit) ---
wire [31:0] aw_addr  = {20'h0, dut.design_1_i.RSA_mark03_0.s00_axi_awaddr};
wire        aw_valid = dut.design_1_i.RSA_mark03_0.s00_axi_awvalid;
wire [31:0] ar_addr  = {20'h0, dut.design_1_i.RSA_mark03_0.s00_axi_araddr};
wire        r_valid  = dut.design_1_i.RSA_mark03_0.s00_axi_rvalid;
wire        rsa_done = dut.design_1_i.RSA_mark03_0.inst.RSA_mark03_slave_lite_v1_0_S00_AXI_inst.done_latch;

integer t_m=0, t_start=0, t_done=0, t_res=0, t_bram=0;
reg f_m=0, f_start=0, f_done=0, f_res=0, f_bram=0;
integer bcnt=0, mcnt=0;

// M[0] = 0x000 -> START pure
always @(posedge soc_clk) if (!f_m && aw_valid && aw_addr[11:0]==12'h000)
    begin t_m=cyc; f_m=1; $display("[C%0d] nap M[0] (START pure)", cyc); end

// dem so tu M da ghi (page 0) - phai du 64
always @(posedge soc_clk) if (aw_valid && aw_addr[11:8]==4'h0) mcnt = mcnt + 1;

always @(posedge soc_clk) if (!f_start && aw_valid && aw_addr[11:0]==12'h308)
    begin t_start=cyc; f_start=1;
          $display("[C%0d] CTRL start=1 (da nap %0d tu M)", cyc, mcnt); end

always @(posedge soc_clk) if (f_start && !f_done && rsa_done)
    begin t_done=cyc; f_done=1; $display("[C%0d] RSA done (%0d cyc)", cyc, cyc-t_start); end

// RESULT[63] = 0x4FC -> END pure
always @(posedge soc_clk) if (f_done && !f_res && r_valid && ar_addr[11:0]==12'h4FC)
    begin t_res=cyc; f_res=1; $display("[C%0d] doc xong RESULT[63] (END pure)", cyc); end

always @(posedge soc_clk) if (f_res && !f_bram && bram_en && bram_we!=4'h0) begin
    bcnt = bcnt + 1;
    if (bcnt==9) begin t_bram=cyc; f_bram=1; $display("[C%0d] ghi xong BRAM", cyc); end
end

task report;
    integer c_core, c_pure, c_e2e;
    real us_core, us_pure, e_pure;
begin
    c_core = t_done-t_start;
    c_pure = f_res  ? t_res -t_m : 0;
    c_e2e  = f_bram ? t_bram-t_m : 0;
    us_core = c_core/FREQ_MHZ;
    us_pure = (c_pure>0) ? c_pure/FREQ_MHZ : 0.0;
    e_pure  = POWER_W*(c_pure/(FREQ_MHZ*1.0e6))*1.0e9;
    $display("\n================================================");
    $display("  SE-RISSP + RSA-2048 verify  (Freq=%.0f MHz, Power=%.3f W)", FREQ_MHZ, POWER_W);
    $display("================================================");
    $display("  C = M^E mod N   (Montgomery word-serial, E=65537, 2048-bit)");
    $display("  Moc cycle: M=%0d start=%0d done=%0d RESULT=%0d BRAM=%0d",
             t_m, t_start, t_done, t_res, t_bram);
    $display("  So tu M da nap: %0d (ky vong 64)%0s", mcnt,
             (mcnt==64) ? "  OK" : "  <<< SAI!");
    $display("------------------------------------------------");
    $display("  [1] Loi RSA    (start->done) : %7d cyc = %8.2f us", c_core, us_core);
    $display("  [2] PURE       (M->RESULT)   : %7d cyc = %8.2f us", c_pure, us_pure);
    $display("  [3] END-TO-END (M->BRAM)     : %7d cyc = %8.2f us", c_e2e, c_e2e/FREQ_MHZ);
    $display("------------------------------------------------");
    $display("  CO SO PURE:");
    $display("    Energy/verify: %11.2f nJ", e_pure);
    $display("    verify/s     : %11.1f", (us_pure>0.0)? 1.0e6/us_pure : 0.0);
    if (c_pure>0)
      $display("    Hieu suat    : %.2f%% (loi %0d ck / PURE %0d ck)",
               100.0*c_core/c_pure, c_core, c_pure);
    $display("------------------------------------------------");
    $display("  Verify ket qua (doi chieu pow(M,65537,N) cua Python):");
    vchk(m[0], 32'hb3bc622e, "C[0]   ");
    vchk(m[1], 32'h5476ecf0, "C[1]   ");
    vchk(m[2], 32'h0955af40, "C[2]   ");
    vchk(m[3], 32'h215a31d3, "C[3]   ");
    vchk(m[4], 32'hccd2ad48, "C[60]  ");
    vchk(m[5], 32'h8f5d434e, "C[61]  ");
    vchk(m[6], 32'h698827d0, "C[62]  ");
    vchk(m[7], 32'h3b12b00d, "C[63]  ");
    vchk(m[8], 32'h8adddfa5, "fold   ");
    $display("------------------------------------------------");
    if (errs==0) $display("  ==> [PASS] RSA-2048 verify DUNG");
    else         $display("  ==> [FAIL] %0d cho SAI", errs);
    $display("================================================\n");
end
endtask

reg fin = 0;
always @(posedge clk_in1_0) if (!reset_0 && !fin) begin
    if (m[12] == 32'h600d0007) begin fin=1; report; $finish; end
    else if (cyc > 2000000) begin
        fin = 1;
        $display("\n[TIMEOUT] cyc=%0d, chua thay marker (m[12]=%08x)", cyc, m[12]);
        $display("  -> kiem tra: blk_mem_gen_0 da nap rsa2048.coe + Generate Output Products chua?");
        report; $finish;
    end
end

// Chan cuoi cung: neu 'force' o tren khong an (vd elaborate thieu
// -debug typical) thi soc_clk khong chay -> 'cyc' dung yen -> timeout theo
// cyc o tren KHONG BAO GIO xay ra -> mo phong treo vinh vien. Timeout theo
// thoi gian tuyet doi duoi day dam bao luon ket thuc.
// LUU Y: gia tri nay PHAI lon hon 2000000 chu ky x 25ns, neu khong no se
// cat mo phong TRUOC khi CPU chay xong (da dinh loi nay that voi RSA-2048:
// loi can 320000 ck = 8ms nhung timeout tuyet doi de 1ms = 40000 ck).
initial begin
    #20000000;
    if (!fin) begin
        fin = 1;
        $display("\n[TIMEOUT tuyet doi] soc_clk dem duoc %0d chu ky sau 20000000 ns.", cyc);
        if (cyc == 0)
            $display("  -> soc_clk KHONG chay: lenh 'force clk_wiz_0_clk_out1' khong an.",
                     "\n     Elaborate phai co '-debug typical' (Vivado GUI mac dinh da co).");
        else
            $display("  -> CPU co chay nhung chua ghi marker: kiem tra dung file .coe chua.");
        report; $finish;
    end
end

endmodule
