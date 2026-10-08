# rsa.s - RSA verify tren SE-RISSP_AES_ULTRA
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
# CHUC NANG: RSA verify chu ky - tinh C = M^E mod N (Montgomery).
#   Thiet bi CHI dung public key (N,E); p,q,d chi ton tai OFFLINE o server.
#   M (signature) = 0x0c20ed7d     E = 0x00010001 (65537, chuan cong nghiep)
#   N             = 0xffe000ff     N_INV = 0xc0e10101  (-N^-1 mod 2^32)
#   R2_MOD_N      = 0x403d0201  (2^64 mod N)
#
#   Ket qua ky vong 0x25836f4b - dung bang XOR-fold cua SHA3-256 digest
#   (xem sha3.s) => chu ky hop le.
#
# KET QUA ghi ra BRAM 0xC0000000:
#   0x00       RESULT, ky vong 25836f4b
#   0x10       marker = 0x600D0006
.section .text
.globl _start
_start:
    li   x13, 0x48000000
    li   x8, 0xC0000000

    # === PHA 1: SETUP - nap KHOA CONG KHAI (co dinh, ngoai cua so do) ===
    # E/N/N_INV/R2 la tham so cua KHOA, khong doi giua cac lan verify.
    # He that nap 1 lan luc khoi dong roi verify nhieu chu ky -> phai
    # de NGOAI cua so PURE, giong het cach AES de KEY ngoai PT->CT.
    li   x5, 0x00010001
    sw   x5, 0x04(x13)    # E = 65537
    li   x5, 0xffe000ff
    sw   x5, 0x08(x13)    # N = modulus
    li   x5, 0xc0e10101
    sw   x5, 0x0C(x13)    # N_INV
    li   x5, 0x403d0201
    sw   x5, 0x10(x13)    # R2_MOD_N

    # === PHA 2: OP - du lieu BIEN THIEN + start + poll + doc (CUA SO PURE) ===
    li   x5, 0x0c20ed7d
    sw   x5, 0x00(x13)    # M = signature (START pure)

    # --- start ---
    li   x6, 0x1
    sw   x6, 0x14(x13)    # CTRL: start=1

    # --- cho modexp xong (poll STATUS) ---
poll_rsa:
    lw   x5, 0x18(x13)         # STATUS: bit0 = done
    andi x5, x5, 1
    beqz x5, poll_rsa

    # --- doc ket qua ve CPU (END pure) ---
    lw   x20, 0x1C(x13)        # RESULT

    # === PHA 3: STORE - ghi ra BRAM (ngoai cua so PURE) ===
    sw   x20, 0x00(x8)    # RESULT ra BRAM

    li   x28, 0x600d0006
    sw   x28, 0x10(x8)    # marker: da xong
halt:
    j    halt
