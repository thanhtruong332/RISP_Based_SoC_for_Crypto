`timescale 1ns / 1ps
// ================================================================
//  RV32I_software + wolfSSL THAT (AES-128-ECB + SHA3-256("") + RSA-2048
//  cong khai) - dung CHINH XAC 1 file .coe voi RISSP/Ibex (cong bang).
//  Dung SoC CHINH THUC (design_1_wrapper, blk_mem_gen/axi_bram_ctrl/
//  axi_interconnect That cua Xilinx) thay vi testbench co lap tu viet -
//  do isolated testbench chua bao gio chay xong voi RV32I (nghi ngo mo
//  hinh imem/AXI don gian hoa khong khop dung timing Stall/next_pc ma
//  RV32I da duoc sua rieng cho blk_mem_gen that).
// ================================================================
module tb_wolfssl_software;

parameter real POWER_W  = 0.438;   // Total On-Chip Power SoC RV32I HW cu
parameter real FREQ_MHZ = 40.0;

reg clk_in1_0 = 0, reset_0 = 0;
always #5 clk_in1_0 = ~clk_in1_0;      // 100MHz vao clk_wiz_0

reg soc_clk_drv = 0;
always #12.5 soc_clk_drv = ~soc_clk_drv;   // 40MHz (chu ky 25ns) = clk_out1

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

reg [31:0] m [0:31];
integer k; initial for (k = 0; k < 32; k = k + 1) m[k] = 0;
always @(posedge bram_clk)
    if (bram_en && bram_we != 4'h0 && bram_addr < 13'd128)
        m[bram_addr[6:2]] <= bram_din;

integer errs = 0;
task vchk; input [31:0] g, e; input [8*8-1:0] nm;
begin
    if (g === e) $display("    %0s = %08x   OK", nm, g);
    else begin  $display("    %0s = %08x   FAIL (ky vong %08x)", nm, g, e); errs = errs + 1; end
end
endtask

// moc chu ky: START marker (offset 0x14 = word[5]) -> DONE (offset 0x10 = word[4])
integer t_start=0, t_done=0;
reg f_start=0;

always @(posedge soc_clk)
    if (!f_start && bram_en && (bram_we != 4'h0) && bram_addr == 13'd20) begin
        t_start = cyc; f_start = 1;
        $display("[C%0d] START marker ghi", cyc);
    end

task report;
begin
    $display("\n================================================");
    $display("  RV32I_software + wolfSSL THAT (Freq=%.0f MHz)", FREQ_MHZ);
    $display("================================================");
    $display("  progress_marker(0x60->m[24])=%0d", m[24]);
    $display("------------------------------------------------");
    $display("  AES-128-ECB (FIPS-197 App.C.1):");
    vchk(m[0], 32'h69c4e0d8, "CT[0]  ");
    vchk(m[1], 32'h6a7b0430, "CT[1]  ");
    vchk(m[2], 32'hd8cdb780, "CT[2]  ");
    vchk(m[3], 32'h70b4c55a, "CT[3]  ");
    $display("  SHA3-256(\"\") (hashlib chuan):");
    vchk(m[8],  32'ha7ffc6f8, "DIG[0-3]");
    vchk(m[9],  32'hbf1ed766, "DIG[4-7]");
    vchk(m[10], 32'hfada7f1c, "DIGfold ");
    $display("  RSA-2048 M^65537 mod N (pow() Python):");
    vchk(m[12], 32'h8adddfa5, "RSAfold ");
    vchk(m[13], 32'h3b12b00d, "RSAout0 ");
    $display("  RSA debug: InitRsaKey=%0d mp_read_n=%0d mp_set_e=%0d RsaFunction_ret=%0d",
             $signed(m[16]), $signed(m[17]), $signed(m[18]), $signed(m[14]));
    $display("------------------------------------------------");
    if (errs==0) $display("  ==> [PASS] wolfSSL THAT chay dung tren RV32I_software (SoC chinh thuc)");
    else         $display("  ==> [FAIL] %0d muc SAI", errs);
    $display("================================================\n");
end
endtask

reg fin = 0;
always @(posedge clk_in1_0) if (!reset_0 && !fin) begin
    if (m[4] == 32'h600d0001) begin
        fin=1;
        t_done = cyc;
        $display("[C%0d] DONE marker ghi. PURE (START->DONE) = %0d chu ky", cyc, cyc - t_start);
        report; $finish;
    end
    else if (cyc > 250000000) begin
        fin = 1;
        $display("\n[TIMEOUT] cyc=%0d, chua thay DONE (m[4]=%08x)", cyc, m[4]);
        report; $finish;
    end
end

endmodule
