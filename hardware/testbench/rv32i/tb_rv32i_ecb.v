`timescale 1ns / 1ps
// ================================================================
//  RV32I SoC + AES-128 ECB - do throughput + verify NIST
//
//  SoC: F:\advance_topic\RV32I_soc_ULTRA  (design_1_wrapper)
//       rv32i_fixed_0 + aes_axi_slave_0 + SHA3_hardware_new_0 +
//       RSA_mark03_0 + axi_uartlite_0 + axi_bram_ctrl_0, 40MHz.
//
//  MUC DICH: dem chu ky cua he dung loi RV32I 5 tang, doi chieu truc
//  tiep voi bang so lieu cua he dung RISSP. CO CHE DO GIU NGUYEN 100%
//  so voi tb_aes_ecb.v (cung moc, cung cua so, cung cach chot) - neu
//  doi cach do thi hai bang khong so sanh duoc nua.
//
//  Chay aes_ecb.coe (nap vao blk_mem_gen_0) tren design_1_wrapper THAT:
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
//
//  Ket qua doc bang cach snoop BRAM_PORTA giua axi_bram_ctrl_0 va
//  blk_mem_gen_1 (khong the $readmemh vao blk_mem_gen vi la IP ma hoa).
// ================================================================
module tb_rv32i_ecb;

// POWER_W = 0.438 W: Total On-Chip Power do tu impl_1 cua chinh SoC
// RV32I. (SoC RISSP la 0.407 W - moi ben mot so rieng, nen cac chi so
// nang luong duoi day so sanh duoc truc tiep.)
parameter real POWER_W  = 0.438;   // Total On-Chip Power cua SoC RV32I (impl_1)
parameter real FREQ_MHZ = 40.0;

// Kich thuoc chuong trinh (aes_ecb.coe = 43 tu) -> PC hop le < ~0xAC.
// Dung de chan doan: PC vuot xa nguong nay = CPU chay lac vao vung rac.
parameter integer PROG_BYTES = 43*4;

reg clk_in1_0 = 0, reset_0 = 0;
always #5 clk_in1_0 = ~clk_in1_0;      // 100MHz vao clk_wiz_0

reg soc_clk_drv = 0;
always #12.5 soc_clk_drv = ~soc_clk_drv;   // 40MHz (chu ky 25ns) = clk_out1

// UART_0_rxd noi len 1'b1 (muc nghi cua UART) - de ho se tha 'z' vao
// axi_uartlite_0 va sinh X lan man trong waveform.
design_1_wrapper dut (
    .clk_in1_0 (clk_in1_0),
    .reset_0   (reset_0),
    .UART_0_rxd(1'b1),
    .UART_0_txd()
);

initial begin
    force dut.design_1_i.clk_wiz_0_clk_out1 = soc_clk_drv;  // bo qua MMCM
    force dut.design_1_i.clk_wiz_0.locked   = 1'b1;
    reset_0 = 1;
    repeat (10) @(posedge clk_in1_0);
    reset_0 = 0;
    $display("[%0t] Reset released, CPU RV32I bat dau chay", $time);
end

wire soc_clk = dut.design_1_i.clk_wiz_0_clk_out1;   // doc dung net da ep
integer cyc = 0;
always @(posedge soc_clk) if (!reset_0) cyc = cyc + 1;

// --- theo doi PC de chan doan duong fetch (xlslice_0 -> blk_mem_gen_0) ---
// ----------------------------------------------------------------
//  [2026-08-13] SoC da thay loi rv32i_pure_0 -> rv32i_fixed_0
//  (IP xilinx.com:user:rv32i_fixed:1.0, ban da sua duong fetch).
//  Cac net cua Block Design mang TEN KHOI lam tien to, nen doi khoi
//  la phai doi theo. Neu sau nay khoi doi ten lan nua, chi can thay
//  chuoi 'rv32i_fixed_0' trong file nay bang ten khoi moi.
// ----------------------------------------------------------------
wire [31:0] cpu_pc = dut.design_1_i.rv32i_fixed_0_inst_addr;
reg  [31:0] pc_max = 0;
always @(posedge soc_clk) if (!reset_0 && cpu_pc > pc_max) pc_max <= cpu_pc;

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

// --- moc cycle tren AXI cua AES (instance that: aes_axi_slave_0) ---
wire [31:0] aw_addr  = dut.design_1_i.aes_axi_slave_0.S_AXI_AWADDR;
wire        aw_valid = dut.design_1_i.aes_axi_slave_0.S_AXI_AWVALID;
wire [31:0] wr_data  = dut.design_1_i.aes_axi_slave_0.S_AXI_WDATA;
wire [31:0] ar_addr  = dut.design_1_i.aes_axi_slave_0.S_AXI_ARADDR;
wire        r_valid  = dut.design_1_i.aes_axi_slave_0.S_AXI_RVALID;
wire        aes_done = dut.design_1_i.aes_axi_slave_0.inst.aes_inst.aes_done_latched;

integer t_key=0, t_pt=0, t_ctrl=0, t_done=0, t_ct=0, t_bram=0;
reg f_key=0, f_pt=0, f_ctrl=0, f_done=0, f_ct=0, f_bram=0;
integer bcnt=0;
reg [31:0] ctrl_val = 0;

always @(posedge soc_clk) if (!f_key && aw_valid && aw_addr==32'h40000010)
    begin t_key=cyc; f_key=1; $display("[C%0d] KEY[0] write", cyc); end

always @(posedge soc_clk) if (!f_pt && aw_valid && aw_addr==32'h40000000)
    begin t_pt=cyc; f_pt=1; $display("[C%0d] PT[0] write  (START pure)", cyc); end

always @(posedge soc_clk) if (!f_ctrl && aw_valid && aw_addr==32'h40000020)
    begin t_ctrl=cyc; f_ctrl=1; ctrl_val=wr_data;
          $display("[C%0d] CTRL=0x%0h  (ECB start)", cyc, wr_data); end

always @(posedge soc_clk) if (f_ctrl && !f_done && aes_done)
    begin t_done=cyc; f_done=1; $display("[C%0d] AES done (%0d cyc)", cyc, cyc-t_ctrl); end

// LUU Y 1: aes_axi_slave nhan DIA CHI DAY DU 32-bit (0x400000xx), khong
//   phai offset -> phai so ar_addr[7:0].
// LUU Y 2: chot moc theo DIA CHI TU CUOI (0x3C), khong dem so lan doc -
//   dem so lan se sai neu firmware doc lap dia chi.
always @(posedge soc_clk)
    if (f_done && !f_ct && r_valid && ar_addr[7:0]==8'h3C) begin
        t_ct=cyc; f_ct=1; $display("[C%0d] doc xong CT (END pure)", cyc);
    end

always @(posedge soc_clk)
    if (f_ct && !f_bram && bram_en && bram_we!=4'h0) begin
        bcnt = bcnt + 1;
        if (bcnt==4) begin t_bram=cyc; f_bram=1; $display("[C%0d] ghi xong BRAM (END e2e)", cyc); end
    end

task line;
    input integer cyc_n;
    input [8*30-1:0] nm;
begin
    if (cyc_n > 0) $display("  %0s: %4d cyc -> %8.2f Mbps", nm, cyc_n, 128.0*FREQ_MHZ/cyc_n);
    else           $display("  %0s:  (chua do duoc)", nm);
end
endtask

task report;
    integer c_core, c_pure, c_full, c_e2e;
    real eb;
begin
    c_core = f_done ? t_done-t_ctrl : 0;
    c_pure = f_ct   ? t_ct  -t_pt   : 0;
    c_full = f_ct   ? t_ct  -t_key  : 0;
    c_e2e  = f_bram ? t_bram-t_pt   : 0;
    $display("\n================================================");
    $display("  RV32I SoC + AES-128 ECB   (Freq=%.0f MHz, Power=%.3f W*)", FREQ_MHZ, POWER_W);
    $display("================================================");
    $display("  Moc cycle: KEY=%0d PT=%0d CTRL=%0d done=%0d CT=%0d BRAM=%0d",
             t_key, t_pt, t_ctrl, t_done, t_ct, t_bram);
    $display("------------------------------------------------");
    line(c_core, "[1] Loi AES    (CTRL->done)   ");
    line(c_pure, "[2] PURE       (PT->CT)       ");
    line(c_full, "[3] FULL       (KEY->CT)      ");
    line(c_e2e,  "[4] END-TO-END (PT->BRAM)     ");
    if (c_pure > 0) begin
        eb = POWER_W*(c_pure/(FREQ_MHZ*1.0e6))*1.0e9;
        $display("------------------------------------------------");
        $display("  Energy/block: %.2f nJ    Energy/bit: %.4f nJ/bit", eb, eb/128.0);
        $display("  Throughput/W: %.2f Mbps/W", (128.0*FREQ_MHZ/c_pure)/POWER_W);
        if (c_core > 0)
            $display("  Hieu suat   : %.1f%% (loi AES %0d ck / PURE %0d ck)",
                     100.0*c_core/c_pure, c_core, c_pure);
        $display("  (*) POWER_W=%.3f = Total On-Chip Power do that cua SoC RV32I.", POWER_W);
        $display("      SoC RISSP dung 0.407 W -> hai ben so sanh nang luong duoc.");
    end
    $display("------------------------------------------------");
    $display("  Doi chieu he RISSP (da sua cau AXI, do 2026-08-13): loi=16  PURE=88  FULL=124  E2E=117 ck");
    if (c_pure > 0)
        $display("  Chenh lech PURE: %0d ck so voi RISSP (88)", c_pure-88);
    $display("  PC lon nhat quan sat duoc: 0x%0h (chuong trinh dai %0d byte)", pc_max, PROG_BYTES);
    $display("------------------------------------------------");
    $display("  NIST SP800-38A verify (ciphertext tai BRAM 0xC0000000):");
    vchk(m[0], 32'h69c4e0d8, "CT[0]  ");
    vchk(m[1], 32'h6a7b0430, "CT[1]  ");
    vchk(m[2], 32'hd8cdb780, "CT[2]  ");
    vchk(m[3], 32'h70b4c55a, "CT[3]  ");
    $display("------------------------------------------------");
    if (errs==0) $display("  ==> [PASS] AES-128 ECB DUNG CHUAN NIST tren loi RV32I");
    else         $display("  ==> [FAIL] %0d/4 tu SAI", errs);
    $display("================================================\n");
end
endtask

reg fin = 0;
always @(posedge clk_in1_0) if (!reset_0 && !fin) begin
    if (m[4] == 32'h600d0001) begin fin=1; report; $finish; end
    else if (cyc > 200000) begin
        fin = 1;
        $display("\n[TIMEOUT] cyc=%0d, chua thay marker (m[4]=%08x)", cyc, m[4]);
        $display("  -> kiem tra: blk_mem_gen_0 da nap aes_ecb.coe + Generate");
        $display("     Output Products (phai RESET truoc) chua?");
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
        else if (pc_max > PROG_BYTES*4)
            $display("  -> PC chay lac toi 0x%0h trong khi chuong trinh chi dai %0d byte:",
                     pc_max, PROG_BYTES,
                     "\n     duong fetch SAI. Kiem tra xlslice_0 = [14:2] (13 bit) va",
                     "\n     blk_mem_gen_0 da tat 'Register PortA Output of Memory Primitives'.");
        else
            $display("  -> CPU co chay (PC max = 0x%0h) nhung chua ghi marker:", pc_max,
                     "\n     kiem tra dung file .coe chua.");
        report; $finish;
    end
end

endmodule
