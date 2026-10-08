#!/usr/bin/env python3
"""
gen_rsa2048.py - sinh firmware + testbench cho RSA-2048 (wrapper AXI ban RONG)

Tach rieng khoi gen_all.py vi dung BAN DO THANH GHI KHAC HAN (wrapper moi):
    0x000-0x0FC  W  M [0..63]     0x300  W  E
    0x100-0x1FC  W  N [0..63]     0x304  W  N_INV
    0x200-0x2FC  W  R2[0..63]     0x308  W  CTRL (bit0=start)
    0x400-0x4FC  R  RESULT[0..63] 0x30C  R  STATUS (bit0=done)

Dung lai template/helper cua gen_all.py (TB_HEAD, TB_TAIL, li, wr, poll, build)
nen 2 file luon nhat quan ve cach do va cach bao cao.

CHAY:  python gen_rsa2048.py
RA:    rsa2048.s / .coe / .hex  +  tb_rsa2048.v
"""
import importlib.util, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("gen_all", HERE / "gen_all.py")
G = importlib.util.module_from_spec(spec); spec.loader.exec_module(G)

sys.path.insert(0, str(HERE))
import rsa2048_key as K

RSA_BASE, BRAM = 0x48000000, 0xC0000000
MARKER = "600d0007"
S = 64

# offset trong vung RSA
OFF_M, OFF_N, OFF_R2 = 0x000, 0x100, 0x200
OFF_E, OFF_NINV, OFF_CTRL, OFF_STATUS, OFF_RES = 0x300, 0x304, 0x308, 0x30C, 0x400


def _fold(words):
    f = 0
    for w in words:
        f ^= w
    return f


EXP_FOLD = _fold(K.RSA2048_C)


def gen_asm():
    c = K.RSA2048_C
    body = f"""# CHUC NANG: RSA-2048 verify - tinh C = M^65537 mod N (Montgomery word-serial).
#
# KHAC HAN ban 32-bit cu: moi toan hang la {S} tu 32-bit, nap qua {S} lan ghi
# AXI vao vung dia chi rieng (xem ban do o duoi). Wrapper gom lai thanh 1
# thanh ghi rong {S*32}-bit roi dua vao loi.
#
# BAN DO THANH GHI (wrapper moi, C_S_AXI_ADDR_WIDTH=12):
#   0x000-0x0FC  W  M [0..{S-1}]      0x300  W  E      (65537)
#   0x100-0x1FC  W  N [0..{S-1}]      0x304  W  N_INV  (-N^-1 mod 2^32)
#   0x200-0x2FC  W  R2[0..{S-1}]      0x308  W  CTRL   (bit0 = start)
#   0x400-0x4FC  R  RESULT[0..{S-1}]  0x30C  R  STATUS (bit0 = done)
#
# PHA 1 SETUP nap N, R2, E, N_INV - deu la tham so CUA KHOA, khong doi giua
# cac lan verify -> NGOAI cua so PURE (he that nap 1 lan luc khoi dong).
# PHA 2 OP nap M ({S} tu) + start + poll + doc {S} tu ket qua.
#
# KIEM TRA: thay vi ghi ca {S} tu ra BRAM, firmware tinh XOR-fold cua ca {S}
# tu roi ghi 4 tu dau + 4 tu cuoi + fold. Sai 1 bit bat ky cung lam fold lech.
#
# KET QUA ghi ra BRAM 0xC0000000:
#   0x00-0x0C  RESULT[0..3]   ky vong {' '.join('%08x'%x for x in c[0:4])}
#   0x10-0x1C  RESULT[{S-4}..{S-1}] ky vong {' '.join('%08x'%x for x in c[S-4:S])}
#   0x20       XOR-fold ca {S} tu, ky vong {EXP_FOLD:08x}
#   0x30       marker = 0x{MARKER.upper()}"""

    s = G.BANNER.format(title=f"rsa2048.s - RSA-2048 verify tren SE-RISSP_AES_ULTRA",
                        body=body)
    s += G.li("x13", "48000000") + G.li("x8", "C0000000") + "\n"

    s += f"    # === PHA 1: SETUP - nap KHOA CONG KHAI ({2*S+2} tu, ngoai cua so do) ===\n"
    s += f"    # --- N[0..{S-1}] ---\n"
    for i, w in enumerate(K.RSA2048_N):
        s += G.li("x5", "%08x" % w) + G.wr("x5", OFF_N + i*4, "x13",
                                           f"N[{i}]" if i in (0, S-1) else "")
    s += f"\n    # --- R2[0..{S-1}] ---\n"
    for i, w in enumerate(K.RSA2048_R2):
        s += G.li("x5", "%08x" % w) + G.wr("x5", OFF_R2 + i*4, "x13",
                                           f"R2[{i}]" if i in (0, S-1) else "")
    s += "\n    # --- E, N_INV ---\n"
    s += G.li("x5", "00010001") + G.wr("x5", OFF_E, "x13", "E = 65537")
    s += G.li("x5", "%08x" % K.RSA2048_N0INV) + G.wr("x5", OFF_NINV, "x13", "N_INV")

    s += f"\n    # === PHA 2: OP - nap M ({S} tu) + start + poll + doc (CUA SO PURE) ===\n"
    for i, w in enumerate(K.RSA2048_M):
        s += G.li("x5", "%08x" % w) + G.wr("x5", OFF_M + i*4, "x13",
                                           "M[0] (START pure)" if i == 0 else
                                           (f"M[{S-1}]" if i == S-1 else ""))
    s += "\n    # --- start ---\n"
    s += G.li("x6", "1") + G.wr("x6", OFF_CTRL, "x13", "CTRL: start=1")
    s += "\n    # --- cho modexp xong (poll STATUS) ---\n"
    s += G.poll("poll_rsa", OFF_STATUS, "x13", "done")

    # Cap phat thanh ghi:
    #   x20..x23 GIU C[0..3]        x24..x27 GIU C[60..63]   -> ghi ra BRAM
    #   x30      thanh ghi TAM cho 56 tu giua (chi gop vao fold roi bo)
    #   x28      fold
    # !! Truoc day dung x20 lam ca cho C[0] LAN cho tu tam -> x20 bi ghi de
    #    56 lan, cuoi cung giu C[59] chu khong phai C[0]. Fold van dung nen
    #    loi nay chi lo ra o 1 o. Da tach x30 rieng.
    keep = {0: "x20", 1: "x21", 2: "x22", 3: "x23",
            S-4: "x24", S-3: "x25", S-2: "x26", S-1: "x27"}
    s += f"\n    # --- doc {S} tu ket qua + tinh XOR-fold ---\n"
    s += "    li   x28, 0               # fold = 0\n"
    for i in range(S):
        reg = keep.get(i, "x30")          # x30 = tam, KHONG trung x20..x27
        s += f"    lw   {reg}, 0x{OFF_RES + i*4:03X}(x13)"
        s += f"    # C[{i}] (END pure)\n" if i == S-1 else \
             (f"    # C[{i}] giu lai\n" if i in keep else "\n")
        s += f"    xor  x28, x28, {reg}\n"

    s += "\n    # === PHA 3: STORE - ghi ra BRAM (ngoai cua so PURE) ===\n"
    for j, r in enumerate(["x20", "x21", "x22", "x23"]):
        s += G.wr(r, j*4, "x8", f"RESULT[{j}]" if j == 0 else "")
    for j, r in enumerate(["x24", "x25", "x26", "x27"]):
        s += G.wr(r, 0x10 + j*4, "x8", f"RESULT[{S-4+j}]" if j == 0 else "")
    s += G.wr("x28", 0x20, "x8", "XOR-fold ca 64 tu")
    s += "\n" + G.li("x29", MARKER) + G.wr("x29", 0x30, "x8", "marker: da xong")
    s += "halt:\n    j    halt\n"
    return s


TB_BODY = """
// --- moc cycle tren AXI cua RSA (ban 2048-bit) ---
wire [31:0] aw_addr  = {{20'h0, dut.design_1_i.RSA_mark03_0.s00_axi_awaddr}};
wire        aw_valid = dut.design_1_i.RSA_mark03_0.s00_axi_awvalid;
wire [31:0] ar_addr  = {{20'h0, dut.design_1_i.RSA_mark03_0.s00_axi_araddr}};
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
    $display("\\n================================================");
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
{checks}    $display("------------------------------------------------");
    if (errs==0) $display("  ==> [PASS] RSA-2048 verify DUNG");
    else         $display("  ==> [FAIL] %0d cho SAI", errs);
    $display("================================================\\n");
end
endtask
"""


def gen_tb():
    c = K.RSA2048_C
    ck = ""
    for j in range(4):
        ck += f'    vchk(m[{j}], 32\'h{c[j]:08x}, "C[{j}]   ");\n'
    for j in range(4):
        ck += f'    vchk(m[{4+j}], 32\'h{c[S-4+j]:08x}, "C[{S-4+j}]  ");\n'
    ck += f'    vchk(m[8], 32\'h{EXP_FOLD:08x}, "fold   ");\n'
    head = G.TB_HEAD.format(title="SE-RISSP + RSA-2048 verify - do latency + verify ket qua",
                            tb="tb_rsa2048", coe="rsa2048.coe")
    body = TB_BODY.format(checks=ck)
    # Loi 2048-bit can ~320 000 ck = 8 ms. Timeout tuyet doi phai LON HON:
    # de 20 ms (= 800 000 ck) cho du bien. Ban 1 ms mac dinh cua gen_all.py
    # se cat mo phong o 40 000 ck -> done khong bao gio den.
    tail = G.TB_TAIL.format(mk_idx=12, marker=MARKER, timeout=2000000,
                            abs_ns=20000000, coe="rsa2048.coe")
    return head + body + tail


if __name__ == "__main__":
    n = G.build("rsa2048", gen_asm())
    (HERE / "tb_rsa2048.v").write_text(gen_tb(), encoding="utf-8", newline="\n")
    print(f"  rsa2048 -> rsa2048.coe ({n} tu imem)  +  tb_rsa2048.v")
    print(f"  XOR-fold ky vong: {EXP_FOLD:08x}")
    print(f"  marker: 0x{MARKER}")
