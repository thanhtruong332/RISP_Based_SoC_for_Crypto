# sha3.s - SHA3-256 tren SE-RISSP_AES_ULTRA
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
# CHUC NANG: SHA3-256 hash 128 byte = 16 tu 64-bit DAY DU.
#
# VI SAO CHON DO DAI NAY: SHA3-256 co rate 1088 bit (136 byte) - moi
# lan permutation ton ~42 chu ky BAT KE nap vao bao nhieu du lieu.
# Message 128 byte + 8 byte padding = 136 byte = DUNG 1 block,
# tuc khai thac toi da 1 lan permutation. (Ban cu chi hash 16 byte ->
# dung 11,8% nang luc, lam throughput do duoc thap hon that ~8,4 lan.)
# Chon 128 byte (khong phai 135) de moi tu deu DAY 8 byte,
# khong phai xu ly tu le qua iByte_num.
#
# Noi dung: 4 block plaintext NIST SP800-38A lap lai 2 lan.
#   CTRL (0x08): bit0=iReady, bit1=iLast, bit[4:2]=iByte_num
#     -> 0x1 = absorb 1 tu ; 0x3 = tu cuoi (kich padding + permutation)
#
# KET QUA ghi ra BRAM 0xC0000000:
#   0x00-0x1C  digest 8 tu, ky vong
#              d1985c30 73f0ff34 c1717893 0e28f04e
#              ac5d6db5 dd5ff147 bea7b4a7 87176cc7
#   0x20       XOR-fold 8 tu digest, ky vong 25836f4b
#   0x30       marker = 0x600D0005
.section .text
.globl _start
_start:
    li   x12, 0x44000000
    li   x8, 0xC0000000

    li   x6, 0x1
                       # iReady=1, iLast=0

    # --- absorb 16 tu du lieu ---
    li   x5, 0x6bc1bee2
    sw   x5, 0x00(x12)    # tu 0: data_hi
    li   x5, 0x2e409f96
    sw   x5, 0x04(x12)
    sw   x6, 0x08(x12)    # CTRL: absorb
    li   x5, 0xe93d7e11
    sw   x5, 0x00(x12)
    li   x5, 0x7393172a
    sw   x5, 0x04(x12)
    sw   x6, 0x08(x12)    # CTRL: absorb
    li   x5, 0xae2d8a57
    sw   x5, 0x00(x12)
    li   x5, 0x1e03ac9c
    sw   x5, 0x04(x12)
    sw   x6, 0x08(x12)    # CTRL: absorb
    li   x5, 0x9eb76fac
    sw   x5, 0x00(x12)
    li   x5, 0x45af8e51
    sw   x5, 0x04(x12)
    sw   x6, 0x08(x12)    # CTRL: absorb
    li   x5, 0x30c81c46
    sw   x5, 0x00(x12)
    li   x5, 0xa35ce411
    sw   x5, 0x04(x12)
    sw   x6, 0x08(x12)    # CTRL: absorb
    li   x5, 0xe5fbc119
    sw   x5, 0x00(x12)
    li   x5, 0x1a0a52ef
    sw   x5, 0x04(x12)
    sw   x6, 0x08(x12)    # CTRL: absorb
    li   x5, 0xf69f2445
    sw   x5, 0x00(x12)
    li   x5, 0xdf4f9b17
    sw   x5, 0x04(x12)
    sw   x6, 0x08(x12)    # CTRL: absorb
    li   x5, 0xad2b417b
    sw   x5, 0x00(x12)
    li   x5, 0xe66c3710
    sw   x5, 0x04(x12)
    sw   x6, 0x08(x12)    # CTRL: absorb
    li   x5, 0x6bc1bee2
    sw   x5, 0x00(x12)
    li   x5, 0x2e409f96
    sw   x5, 0x04(x12)
    sw   x6, 0x08(x12)    # CTRL: absorb
    li   x5, 0xe93d7e11
    sw   x5, 0x00(x12)
    li   x5, 0x7393172a
    sw   x5, 0x04(x12)
    sw   x6, 0x08(x12)    # CTRL: absorb
    li   x5, 0xae2d8a57
    sw   x5, 0x00(x12)
    li   x5, 0x1e03ac9c
    sw   x5, 0x04(x12)
    sw   x6, 0x08(x12)    # CTRL: absorb
    li   x5, 0x9eb76fac
    sw   x5, 0x00(x12)
    li   x5, 0x45af8e51
    sw   x5, 0x04(x12)
    sw   x6, 0x08(x12)    # CTRL: absorb
    li   x5, 0x30c81c46
    sw   x5, 0x00(x12)
    li   x5, 0xa35ce411
    sw   x5, 0x04(x12)
    sw   x6, 0x08(x12)    # CTRL: absorb
    li   x5, 0xe5fbc119
    sw   x5, 0x00(x12)
    li   x5, 0x1a0a52ef
    sw   x5, 0x04(x12)
    sw   x6, 0x08(x12)    # CTRL: absorb
    li   x5, 0xf69f2445
    sw   x5, 0x00(x12)
    li   x5, 0xdf4f9b17
    sw   x5, 0x04(x12)
    sw   x6, 0x08(x12)    # CTRL: absorb
    li   x5, 0xad2b417b
    sw   x5, 0x00(x12)
    li   x5, 0xe66c3710
    sw   x5, 0x04(x12)
    sw   x6, 0x08(x12)    # CTRL: absorb

    # --- tu rong cuoi: kich padding + permutation ---
    li   x7, 0x3
                       # iReady=1, iLast=1
    sw   x0, 0x00(x12)
    sw   x0, 0x04(x12)
    sw   x7, 0x08(x12)    # CTRL: tu cuoi

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

    # --- XOR-fold 8 tu -> 1 checksum 32-bit (chi dung XOR) ---
    xor  x28, x20, x21
    xor  x28, x28, x22
    xor  x28, x28, x23
    xor  x28, x28, x24
    xor  x28, x28, x25
    xor  x28, x28, x26
    xor  x28, x28, x27
    sw   x28, 0x20(x8)    # checksum

    li   x29, 0x600d0005
    sw   x29, 0x30(x8)    # marker: da xong
halt:
    j    halt
