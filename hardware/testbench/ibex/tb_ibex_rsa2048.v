`timescale 1ns / 1ps
// ================================================================
//  Ibex SoC + RSA-2048 verify - do latency + verify ket qua
//
//  SoC: F:\advance_topic\Ibex_SoC (design_1_wrapper), khoi CPU la
//       ibex_core_0 (RV32M=0). Dia chi AXI giong het SoC RISSP
//       (RSA base 0x48000000, C_S00_AXI_ADDR_WIDTH=12: M 0x000 /
//       N 0x100 / R2 0x200 / E 0x300 / N_INV 0x304 / CTRL 0x308 /
//       STATUS 0x30C / RESULT 0x400).
//
//  ⚠️ BOOT OFFSET 0x80 da xu ly bang phan cung (bo tru hang so
//  addsub_bootoffset_0 chen giua xlslice_0 va blk_mem_gen_0 trong
//  Block Design cua Ibex_SoC) - nap THANG file rsa2048.coe GOC cua
//  SE-RISSP_FULL, khong can sua/dem gi. Nap nham file 32-bit rsa.coe
//  (ban do thanh ghi cu) se ghi/doc sai cho va treo.
//
//  CO CHE DO GIU NGUYEN 100% so voi tb_rsa2048.v (RISSP) /
//  tb_rv32i_rsa2048.v (RV32I).
// ================================================================
module tb_ibex_rsa2048;

parameter real POWER_W  = 0.407;   // TODO: thay bang so Impl that cua Ibex_SoC
parameter real FREQ_MHZ = 40.0;

parameter integer BOOT_OFFSET = 32'h80;
parameter integer PROG_WORDS  = 731;
parameter integer PROG_BYTES  = PROG_WORDS*4;

reg clk_in1_0 = 0, reset_0 = 0;
always #5 clk_in1_0 = ~clk_in1_0;

reg soc_clk_drv = 0;
always #12.5 soc_clk_drv = ~soc_clk_drv;

design_1_wrapper dut (
    .clk_in1_0 (clk_in1_0),
    .reset_0   (reset_0),
    .UART_0_rxd(1'b1),
    .UART_0_txd()
);

initial begin
    force dut.design_1_i.clk_wiz_0_clk_out1 = soc_clk_drv;
    force dut.design_1_i.clk_wiz_0.locked   = 1'b1;
    reset_0 = 1;
    repeat (10) @(posedge clk_in1_0);
    reset_0 = 0;
    $display("[%0t] Reset released, CPU Ibex bat dau chay", $time);
end

wire soc_clk = dut.design_1_i.clk_wiz_0_clk_out1;
integer cyc = 0;
always @(posedge soc_clk) if (!reset_0) cyc = cyc + 1;

wire [31:0] cpu_pc = dut.design_1_i.ibex_core_0_imem_addr;
reg  [31:0] pc_max = 0;
reg         pc_seen_boot = 0;
always @(posedge soc_clk) if (!reset_0) begin
    if (cpu_pc > pc_max) pc_max <= cpu_pc;
    if (cpu_pc == BOOT_OFFSET) pc_seen_boot <= 1'b1;
end

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

always @(posedge soc_clk) if (!f_m && aw_valid && aw_addr[11:0]==12'h000)
    begin t_m=cyc; f_m=1; $display("[C%0d] nap M[0] (START pure)", cyc); end

always @(posedge soc_clk) if (aw_valid && aw_addr[11:8]==4'h0) mcnt = mcnt + 1;

always @(posedge soc_clk) if (!f_start && aw_valid && aw_addr[11:0]==12'h308)
    begin t_start=cyc; f_start=1;
          $display("[C%0d] CTRL start=1 (da nap %0d tu M)", cyc, mcnt); end

always @(posedge soc_clk) if (f_start && !f_done && rsa_done)
    begin t_done=cyc; f_done=1; $display("[C%0d] RSA done (%0d cyc)", cyc, cyc-t_start); end

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
    $display("  Ibex SoC + RSA-2048 verify  (Freq=%.0f MHz, Power=%.3f W*)", FREQ_MHZ, POWER_W);
    $display("================================================");
    $display("  C = M^E mod N   (Montgomery word-serial, E=65537, 2048-bit)");
    $display("  Moc cycle: M=%0d start=%0d done=%0d RESULT=%0d BRAM=%0d",
             t_m, t_start, t_done, t_res, t_bram);
    $display("  So tu M da nap: %0d (ky vong 64)%0s", mcnt,
             (mcnt==64) ? "  OK" : "  <<< SAI!");
    $display("  Boot offset da thay dung 0x%0h: %0s", BOOT_OFFSET,
             pc_seen_boot ? "OK" : "CHUA THAY - kiem tra padding .coe");
    $display("  PC lon nhat quan sat duoc: 0x%0h (chuong trinh dai %0d byte, ky vong <= 0x%0h)",
             pc_max, PROG_BYTES, BOOT_OFFSET+PROG_BYTES);
    $display("  Doi chieu he RISSP (da sua cau AXI): PURE=320972 ck");
    $display("  Doi chieu he RV32I               : PURE=321039 ck");
    if (c_pure > 0)
        $display("  Chenh lech PURE: %0d ck so RISSP (320972) / %0d ck so RV32I (321039)",
                 c_pure-320972, c_pure-321039);
    $display("------------------------------------------------");
    $display("  [1] Loi RSA    (start->done) : %7d cyc = %8.2f us", c_core, us_core);
    $display("  [2] PURE       (M->RESULT)   : %7d cyc = %8.2f us", c_pure, us_pure);
    $display("  [3] END-TO-END (M->BRAM)     : %7d cyc = %8.2f us", c_e2e, c_e2e/FREQ_MHZ);
    $display("------------------------------------------------");
    $display("  CO SO PURE (*POWER_W la so TAM, xem canh bao dau file):");
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
    if (errs==0) $display("  ==> [PASS] RSA-2048 verify DUNG tren loi Ibex");
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
        $display("  -> kiem tra: blk_mem_gen_0 da nap rsa2048.coe (tu SE-RISSP_FULL, file goc");
        $display("     khong sua) + Generate Output Products chua?");
        if (!pc_seen_boot)
            $display("  -> PC chua bao gio dung tai 0x%0h: kiem tra 32 tu dem dau .coe.", BOOT_OFFSET);
        else if (pc_max > BOOT_OFFSET+PROG_BYTES)
            $display("  -> PC chay lac toi 0x%0h vuot qua chuong trinh (ky vong <= 0x%0h).",
                     pc_max, BOOT_OFFSET+PROG_BYTES);
        report; $finish;
    end
end

// LUU Y: gia tri nay PHAI lon hon 320000 chu ky x 25ns (~8ms), neu khong
// no se cat mo phong TRUOC khi CPU chay xong (da dinh loi nay that voi
// RSA-2048 tren SoC RISSP/RV32I: loi can 320000 ck nhung timeout tuyet
// doi de 1ms = 40000 ck).
initial begin
    #20000000;
    if (!fin) begin
        fin = 1;
        $display("\n[TIMEOUT tuyet doi] soc_clk dem duoc %0d chu ky sau 20000000 ns.", cyc);
        if (cyc == 0)
            $display("  -> soc_clk KHONG chay: lenh 'force clk_wiz_0_clk_out1' khong an.");
        else
            $display("  -> CPU co chay nhung chua ghi marker: kiem tra dung file .coe chua.");
        report; $finish;
    end
end

endmodule
