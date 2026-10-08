`timescale 1ns / 1ps
// ================================================================
//  Ibex SoC + SHA3-256 (1 block, 128 byte) - do throughput + verify digest
//
//  SoC: F:\advance_topic\Ibex_SoC (design_1_wrapper), khoi CPU la
//       ibex_core_0 (RV32M=0). Dia chi AXI giong het SoC RISSP.
//
//  ⚠️ BOOT OFFSET 0x80 da xu ly bang phan cung (bo tru hang so
//  addsub_bootoffset_0 chen giua xlslice_0 va blk_mem_gen_0 trong
//  Block Design cua Ibex_SoC) - nap THANG file sha3.coe GOC cua
//  SE-RISSP_FULL, khong can sua/dem gi.
//
//  CO CHE DO GIU NGUYEN 100% so voi tb_sha3.v (RISSP) / tb_rv32i_sha3.v
//  (RV32I).
// ================================================================
module tb_ibex_sha3;

parameter real POWER_W  = 0.407;   // TODO: thay bang so Impl that cua Ibex_SoC
parameter real FREQ_MHZ = 40.0;

parameter integer BOOT_OFFSET = 32'h80;
parameter integer PROG_WORDS  = 150;
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

wire [31:0] aw_addr  = {24'h0, dut.design_1_i.SHA3_hardware_new_0.s01_axi_awaddr};
wire        aw_valid = dut.design_1_i.SHA3_hardware_new_0.s01_axi_awvalid;
wire [31:0] wr_data  = dut.design_1_i.SHA3_hardware_new_0.s01_axi_wdata;
wire [31:0] ar_addr  = {24'h0, dut.design_1_i.SHA3_hardware_new_0.s01_axi_araddr};
wire        r_valid  = dut.design_1_i.SHA3_hardware_new_0.s01_axi_rvalid;
wire        sha_ready= dut.design_1_i.SHA3_hardware_new_0.inst.SHA3_hardware_new_slave_lite_v1_0_S01_AXI_inst.sha3_oReady;

integer t_first=0, t_last=0, t_done=0, t_dig=0, t_bram=0;
reg f_first=0, f_last=0, f_done=0, f_dig=0, f_bram=0;
integer bcnt=0;

always @(posedge soc_clk)
    if (!f_first && aw_valid && aw_addr[7:0]==8'h08)
        begin t_first=cyc; f_first=1; $display("[C%0d] absorb tu dau tien (START)", cyc); end

always @(posedge soc_clk)
    if (f_first && !f_last && aw_valid && aw_addr[7:0]==8'h08 && wr_data[1])
        begin t_last=cyc; f_last=1; $display("[C%0d] tu cuoi (iLast=1) -> padding+permutation", cyc); end

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
    integer c_core, c_perm, c_pure, c_e2e, n_pad;
    real tp_core, tp_perm, tp_pure, tp_e2e;
    real e_pure, e_e2e, eb_pure, eb_e2e;
begin
    c_core = t_done-t_last;
    c_pure = f_dig  ? t_dig -t_first : 0;
    c_e2e  = f_bram ? t_bram-t_first : 0;
    n_pad  = 17 - 16;
    c_perm = c_core - n_pad;
    tp_core = 1024.0*FREQ_MHZ/c_core;
    tp_perm = 1088.0*FREQ_MHZ/c_perm;
    tp_pure = (c_pure>0) ? 1024.0*FREQ_MHZ/c_pure : 0.0;
    tp_e2e  = (c_e2e >0) ? 1024.0*FREQ_MHZ/c_e2e  : 0.0;
    e_pure  = POWER_W*(c_pure/(FREQ_MHZ*1.0e6))*1.0e9;
    e_e2e   = POWER_W*(c_e2e /(FREQ_MHZ*1.0e6))*1.0e9;
    eb_pure = e_pure/1024.0;
    eb_e2e  = e_e2e /1024.0;
    $display("\n================================================");
    $display("  Ibex SoC + SHA3-256   (Freq=%.0f MHz, Power=%.3f W*)", FREQ_MHZ, POWER_W);
    $display("================================================");
    $display("  Message: 128 byte (1024 bit) - lap 4 block plaintext NIST x2");
    $display("  Moc cycle: absorb1=%0d iLast=%0d oReady=%0d DIGEST=%0d BRAM=%0d",
             t_first, t_last, t_done, t_dig, t_bram);
    $display("  Boot offset da thay dung 0x%0h: %0s", BOOT_OFFSET,
             pc_seen_boot ? "OK" : "CHUA THAY - kiem tra padding .coe");
    $display("  PC lon nhat quan sat duoc: 0x%0h (chuong trinh dai %0d byte, ky vong <= 0x%0h)",
             pc_max, PROG_BYTES, BOOT_OFFSET+PROG_BYTES);
    $display("------------------------------------------------");
    $display("  [1] Loi SHA3   (iLast->oReady): %4d cyc -> %8.2f Mbps", c_core, tp_core);
    $display("      = %0d ck padder dien %0d tu 0 + %0d ck permutation THUAN", n_pad, n_pad, c_perm);
    $display("      => so trich vao paper: permutation %0d ck, peak %.2f Mbps", c_perm, tp_perm);
    $display("  [2] PURE       (absorb1->DIGEST): %4d cyc -> %8.2f Mbps", c_pure, tp_pure);
    $display("  [3] END-TO-END (absorb1->BRAM) : %4d cyc -> %8.2f Mbps", c_e2e, tp_e2e);
    $display("------------------------------------------------");
    $display("  Doi chieu he RISSP (da sua cau AXI): PURE=492 ck");
    $display("  Doi chieu he RV32I               : PURE=500 ck");
    if (c_pure > 0)
        $display("  Chenh lech PURE: %0d ck so RISSP (492) / %0d ck so RV32I (500)", c_pure-492, c_pure-500);
    $display("------------------------------------------------");
    $display("  CO SO PURE (*so nay dung POWER_W tam, xem canh bao dau file):");
    $display("    Energy/hash : %8.2f nJ    Energy/bit  : %.4f nJ/bit", e_pure, eb_pure);
    $display("    Throughput/W: %8.2f Mbps/W", (POWER_W>0.0)? tp_pure/POWER_W : 0.0);
    if (c_pure>0)
      $display("    Hieu suat   : %.1f%% (loi SHA3 %0d ck / PURE %0d ck)",
               100.0*c_core/c_pure, c_core, c_pure);
    else
      $display("    Hieu suat   : N/A - moc DIGEST khong bat duoc (xem canh bao duoi)");
    if (!f_dig)
      $display("  [!] CANH BAO: khong thay lan doc 0x2C -> c_pure=0, moi so PURE vo nghia.");
    $display("------------------------------------------------");
    $display("  Verify digest (doi chieu hashlib.sha3_256):");
    vchk(m[0], 32'hd1985c30, "D[0]   ");
    vchk(m[1], 32'h73f0ff34, "D[1]   ");
    vchk(m[2], 32'hc1717893, "D[2]   ");
    vchk(m[3], 32'h0e28f04e, "D[3]   ");
    vchk(m[4], 32'hac5d6db5, "D[4]   ");
    vchk(m[5], 32'hdd5ff147, "D[5]   ");
    vchk(m[6], 32'hbea7b4a7, "D[6]   ");
    vchk(m[7], 32'h87176cc7, "D[7]   ");
    $display("  Verify XOR-fold (dung cho RSA verify):");
    vchk(m[8], 32'h25836f4b, "fold   ");
    $display("------------------------------------------------");
    if (errs==0) $display("  ==> [PASS] SHA3-256 DUNG CHUAN tren loi Ibex");
    else         $display("  ==> [FAIL] %0d cho SAI", errs);
    $display("================================================\n");
end
endtask

reg fin = 0;
always @(posedge clk_in1_0) if (!reset_0 && !fin) begin
    if (m[12] == 32'h600d0005) begin fin=1; report; $finish; end
    else if (cyc > 200000) begin
        fin = 1;
        $display("\n[TIMEOUT] cyc=%0d, chua thay marker (m[12]=%08x)", cyc, m[12]);
        $display("  -> kiem tra: blk_mem_gen_0 da nap sha3.coe (tu SE-RISSP_FULL, file goc");
        $display("     khong sua) + Generate Output Products chua?");
        if (!pc_seen_boot)
            $display("  -> PC chua bao gio dung tai 0x%0h: kiem tra 32 tu dem dau .coe.", BOOT_OFFSET);
        else if (pc_max > BOOT_OFFSET+PROG_BYTES)
            $display("  -> PC chay lac toi 0x%0h vuot qua chuong trinh (ky vong <= 0x%0h).",
                     pc_max, BOOT_OFFSET+PROG_BYTES);
        report; $finish;
    end
end

initial begin
    #1000000;
    if (!fin) begin
        fin = 1;
        $display("\n[TIMEOUT tuyet doi] soc_clk dem duoc %0d chu ky sau 1ms.", cyc);
        if (cyc == 0)
            $display("  -> soc_clk KHONG chay: lenh 'force clk_wiz_0_clk_out1' khong an.");
        else
            $display("  -> CPU co chay nhung chua ghi marker: kiem tra dung file .coe chua.");
        report; $finish;
    end
end

endmodule
