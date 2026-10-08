# sha3_4.s - SHA3-256 4 block (536 byte) tren SE-RISSP_AES_ULTRA
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
# CHUC NANG: SHA3-256 hash 536 byte = 67 tu 64-bit = DUNG 4 rate block.
#
# VI SAO CHON 536 BYTE: so tu = 17N - 1 = 17*4 - 1 = 67, nen message
# + 1 tu padding = 68 tu = DUNG 4 block. Khong co block le lam
# nhieu so do. Dung cung nguyen tac voi ban 128 byte (N=1).
#
# VI SAO DUNG VONG LAP (khac ban 128 byte unroll): unroll 271 tu se ton
# ~1900 lenh, khong vua imem. Vong lap sinh du lieu theo BO DEM nen kich
# thuoc firmware KHONG DOI theo N.
#   tu i = BE(0x6bc1bee2 + i) || BE(0x2e409f96 + i)
# (script tinh digest ky vong bang dung cong thuc nay + hashlib)
#
# KHONG can poll giua cac block: CPU ton ~28 ck/tu -> ~476 ck de nap day
# 1 block (17 tu), trong khi permutation chi 27 ck => permutation LUON
# xong trong luc CPU con dang nap block ke tiep (bien 17x). Neu gia dinh
# nay sai thi digest se SAI RO RANG - testbench bat duoc ngay.
#
#   CTRL (0x08): bit0=iReady, bit1=iLast, bit[4:2]=iByte_num
#     -> 0x1 = absorb 1 tu ; 0x3 = tu cuoi (kich padding + permutation)
#
# KET QUA ghi ra BRAM 0xC0000000:
#   0x00-0x1C  digest 8 tu, ky vong
#              7df3d9cd 8212808e b2a3ac20 38893a49
#              83077e65 7d1b53bb 68c50f77 0cf3fba9
#   0x20       XOR-fold 8 tu digest, ky vong efe1162a
#   0x30       marker = 0x600D0007
.section .text
.globl _start
_start:
    li   x12, 0x44000000
    li   x8, 0xC0000000

    li   x6, 0x1
                       # iReady=1, iLast=0
    li   x5, 0x6bc1bee2
        # data_hi = seed_hi + i
    li   x7, 0x2e409f96
        # data_lo = seed_lo + i
    li   x9, 0                # i = 0
    li   x10, 67              # so tu can nap

    # --- vong lap absorb 67 tu ---
absorb_loop:
    sw   x5, 0x00(x12)    # data_hi
    sw   x7, 0x04(x12)    # data_lo
    sw   x6, 0x08(x12)    # CTRL: absorb
    addi x5, x5, 1
    addi x7, x7, 1
    addi x9, x9, 1
    blt  x9, x10, absorb_loop

    # --- tu rong cuoi: kich padding + permutation ---
    li   x11, 0x3
                      # iReady=1, iLast=1
    sw   x0, 0x00(x12)
    sw   x0, 0x04(x12)
    sw   x11, 0x08(x12)    # CTRL: tu cuoi

    # --- cho permutation xong (poll STATUS) ---
poll_sha3:
    lw   x5, 0x0C(x12)         # STATUS: bit0 = oReady
    andi x5, x5, 1
    beqz x5, poll_sha3

    # --- doc 8 tu digest ---
    lw   x20, 0x10(x12)
    lw   x21, 0x14(x12)
    lw   x22, 0x18(x12)
    lw   x23, 0x1C(x12)
    lw   x24, 0x20(x12)
    lw   x25, 0x24(x12)
    lw   x26, 0x28(x12)
    lw   x27, 0x2C(x12)

    # --- ghi digest ra BRAM ---
    sw   x20, 0x00(x8)
    sw   x21, 0x04(x8)
    sw   x22, 0x08(x8)
    sw   x23, 0x0C(x8)
    sw   x24, 0x10(x8)
    sw   x25, 0x14(x8)
    sw   x26, 0x18(x8)
    sw   x27, 0x1C(x8)

    # --- XOR-fold 8 tu -> 1 checksum 32-bit ---
    xor  x28, x20, x21
    xor  x28, x28, x22
    xor  x28, x28, x23
    xor  x28, x28, x24
    xor  x28, x28, x25
    xor  x28, x28, x26
    xor  x28, x28, x27
    sw   x28, 0x20(x8)    # checksum

    li   x29, 0x600d0007
    sw   x29, 0x30(x8)    # marker: da xong
halt:
    j    halt
