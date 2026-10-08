# aes_cfb.s - AES-128 CFB tren SE-RISSP_AES_ULTRA
# Sinh tu dong boi gen_all.py - KHONG sua tay (sua gen_all.py roi chay lai).
#
# SoC: SE-RISSP_AES_ULTRA  (RISSP + AES + SHA3 + RSA qua AXI4-Lite)
#   AES  @ 0x40000000   SHA3 @ 0x44000000
#   RSA  @ 0x48000000   BRAM debug @ 0xC0000000 (blk_mem_gen_1)
#
# YEU CAU: Block Design phai da BO TICK "Register PortA Output of Memory
# Primitives" tren blk_mem_gen_0 (imem 1 chu ky - dung hop dong cua
# fetch_stage.v). Firmware nay dung vong lap poll (co nhanh re) nen se
# TREO neu imem con 2 chu ky.
#
# Toi uu de so lieu do duoc phan anh dung hieu nang that:
#   - Cho bang POLL STATUS, khong phai NOP padding -> khong tinh du chu ky
#   - KHONG cho sau khi ghi KEY (AESEncrypt tu doi keys_valid qua start_req)
#   - Moi gia tri chi doc 1 lan (bo ky thuat "doc 2 lan" - workaround cu
#     cho imem 2 chu ky, khong con can)
#
# Moi mode test 1 CASE (1 block 128-bit) theo test vector NIST SP800-38A.
#
# ==========================================================================
# HOP DONG "SO SANH CONG BANG" - firmware nay phai chay duoc tren CORE KHAC
# (RV32I chuan / Ibex / CVA6) de so sanh, nen bat buoc tuan thu:
#
#  1. CHI dung RV32I co ban: addi andi beqz blt j li lw nop sw xor.
#     KHONG dung lenh/pseudo-op nao ngoai tap nay. KHONG M/A/F/C extension.
#     (Tien the: RISSP khong ho tro LH/LHU - nhung ta cung khong dung, nen
#      cung 1 file .s chay duoc tren ca hai.)
#  2. KHONG dua vao dac tinh rieng cua RISSP: khong gia dinh single-cycle,
#     khong gia dinh do tre imem, khong dung ky thuat "doc 2 lan".
#     Cho phan cung xong = POLL STATUS, khong dem chu ky bang NOP.
#  3. CUNG MOT CAU TRUC 3 PHA cho ca 3 lo, de cua so PURE co cung y nghia:
#       PHA 1 SETUP  - nap tham so CO DINH (khoa AES, N/E/N_INV/R2 cua RSA).
#                      NGOAI cua so do. He that nap 1 lan luc khoi dong.
#       PHA 2 OP     - nap du lieu BIEN THIEN, start, poll, doc ket qua.
#                      <== DAY LA CUA SO PURE duoc do
#       PHA 3 STORE  - ghi ket qua ra BRAM + marker. NGOAI cua so PURE.
#  4. Moc do nam tren AXI/BRAM (ngoai CPU), KHONG probe tin hieu noi bo CPU
#     -> doi CPU khac van do duoc bang dung testbench, khong sua gi.
#  5. Khong chen NOP padding tuy tien o bat ky dau.
# ==========================================================================
#
# CHUC NANG: AES-128 CFB ma hoa 1 block 128-bit.
#   CTRL = 0x7  (start=1, mode_sel=11 = CFB)
#   key       = 2b7e151628aed2a6abf7158809cf4f3c
#   plaintext = f69f2445df4f9b17ad2b417be66c3710
#   IV      = 26751f67a3cbb140b1808cf187a4f4df
#
# KET QUA ghi ra BRAM 0xC0000000:
#   0x00-0x0C  ciphertext, ky vong c04b0535 7c5d1c0e eac4c66f 9ff7f2e6
#   0x10       marker = 0x600D0003
.section .text
.globl _start
_start:
    li   x11, 0x40000000
    li   x8, 0xC0000000

    # --- nap KEY (KHONG can cho: AESEncrypt co start_req tu giu yeu
    #     cau va tu bat dau ngay khi keys_valid len) ---
    li   x5, 0x2b7e1516
    sw   x5, 0x10(x11)    # KEY[0..3]
    li   x5, 0x28aed2a6
    sw   x5, 0x14(x11)
    li   x5, 0xabf71588
    sw   x5, 0x18(x11)
    li   x5, 0x09cf4f3c
    sw   x5, 0x1C(x11)

    # --- nap PLAINTEXT ---
    li   x5, 0xf69f2445
    sw   x5, 0x00(x11)    # DATA_IN[0..3]
    li   x5, 0xdf4f9b17
    sw   x5, 0x04(x11)
    li   x5, 0xad2b417b
    sw   x5, 0x08(x11)
    li   x5, 0xe66c3710
    sw   x5, 0x0C(x11)

    # --- nap IV ---
    li   x5, 0x26751f67
    sw   x5, 0x40(x11)    # IV[0..3]
    li   x5, 0xa3cbb140
    sw   x5, 0x44(x11)
    li   x5, 0xb1808cf1
    sw   x5, 0x48(x11)
    li   x5, 0x87a4f4df
    sw   x5, 0x4C(x11)

    # --- start CFB ---
    li   x5, 0x7
    sw   x5, 0x20(x11)    # CTRL: start=1, mode=CFB

    # --- cho AES xong (poll STATUS, khong lang phi chu ky) ---
poll_aes:
    lw   x5, 0x24(x11)         # STATUS: bit0 = done
    andi x5, x5, 1
    beqz x5, poll_aes

    # --- doc ciphertext ---
    lw   x20, 0x30(x11)
    lw   x21, 0x34(x11)
    lw   x22, 0x38(x11)
    lw   x23, 0x3C(x11)

    # --- ghi ciphertext ra BRAM ---
    sw   x20, 0x00(x8)
    sw   x21, 0x04(x8)
    sw   x22, 0x08(x8)
    sw   x23, 0x0C(x8)

    li   x28, 0x600d0003
    sw   x28, 0x10(x8)    # marker: da xong
halt:
    j    halt
