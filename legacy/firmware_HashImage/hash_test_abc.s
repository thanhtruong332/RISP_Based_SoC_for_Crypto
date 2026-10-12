# hash_test_abc.s - firmware TEST don gian cho SoC RISSP+SHA3.
#
# Khac voi hash_image.s (448 byte, 56 tu, multi-block) - file nay chi hash
# chuoi "abc" (3 byte), dung 1 tu 64-bit duy nhat, khong tran block (rate
# SHA3-256 = 136 byte/block). Muc dich: firmware NGAN, DE DOC, de test truoc
# toan bo luong RISSP->AXI->SHA3->doc digest->ghi BRAM hoat dong dung, truoc
# khi tin tuong ban 448-byte phuc tap hon.
#
# "abc" la test vector chuan NIST cho SHA3-256, khong phai tu nhon tay -
# de doi chieu doc lap bang bat ky cong cu nao (vd: python3 -c
# "import hashlib; print(hashlib.sha3_256(b'abc').hexdigest())").
#
# Digest ky vong (da tinh bang Python hashlib that, khop dung tb_sha3_core.v
# trong SHA3_Core/ da PASS truoc do):
#   3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532
#
# --- Ma hoa du lieu ---
# Message = "abc" = byte 0x61 0x62 0x63 (3 byte, duoi 8 byte -> 1 tu, KHONG
# can tu rong bao ket thuc rieng, khac voi truong hop hash_image.s ket thuc
# dung ranh gioi 8-byte).
#
# Quy uoc SHA3 core: byte dau tien cua message nam o bit cao nhat cua tu
# 64-bit (big-endian theo tung tu) -> data_hi chua ca 3 byte can thiet:
#   data_hi = 0x61 0x62 0x63 <dont-care> = 0x61626300
#   data_lo = <dont-care, dat 0> = 0x00000000
#   iByte_num = 3 (so byte hop le trong tu nay, dung "SHA3_Core/SHA3.md")
#
# CTRL (offset 0x08) = bit0 iReady | bit1 iLast | bit[4:2] iByte_num
#   = iReady(1) + iLast(1)<<1 + iByte_num(3)<<2 = 1 + 2 + 12 = 15 = 0x0F
# (xac nhan dung tu chinh source AXI wrapper
#  SHA3_hardware_new_slave_lite_v1_0_S01_AXI.v dong 101:
#  core_iready<=wdata_reg[0]; core_ilast<=wdata_reg[1]; core_ibyte<=wdata_reg[4:2];)
#
# Dia chi SHA3 = 0x44A00000 (theo dung Address Editor SoC RISSP+SHA3 hien
# tai - NEU project cua ban dia chi khac, sua lai 2 dong li a1 ben duoi).
# BRAM debug/ket qua = 0xC0000000 (khong doi).

.section .text
.globl _start

_start:
    li   a1, 0x44A00000       # SHA3 base
    li   s0, 0xC0000000       # BRAM debug/ket qua

    # ---- Ghi 1 tu duy nhat: "abc" + iLast + iByte_num=3 ----
    li   t0, 0x61626300       # data_hi = 'a','b','c', byte cuoi dont-care=0
    li   t1, 0x00000000       # data_lo = dont-care
    li   t2, 0x0000000F       # CTRL = iReady=1,iLast=1,iByte_num=3
    sw   t0, 0(a1)             # DATA_HI
    sw   t1, 4(a1)             # DATA_LO
    sw   t2, 8(a1)             # CTRL -> absorb + bao ket thuc luon

poll_sha3:
    lw   t0, 0x0C(a1)          # STATUS: bit0 = oReady
    andi t0, t0, 1
    beqz t0, poll_sha3

    # ---- Doc 8 tu digest (0x10..0x2C, MSB truoc), ghi ra BRAM 0xC0000000 ----
    lw   t0, 0x10(a1)
    sw   t0, 0x00(s0)          # digest word 0 = 0x3a985da7
    lw   t0, 0x14(a1)
    sw   t0, 0x04(s0)          # digest word 1 = 0x4fe225b2
    lw   t0, 0x18(a1)
    sw   t0, 0x08(s0)          # digest word 2 = 0x045c172d
    lw   t0, 0x1C(a1)
    sw   t0, 0x0C(s0)          # digest word 3 = 0x6bd390bd
    lw   t0, 0x20(a1)
    sw   t0, 0x10(s0)          # digest word 4 = 0x855f086e
    lw   t0, 0x24(a1)
    sw   t0, 0x14(s0)          # digest word 5 = 0x3e9d525b
    lw   t0, 0x28(a1)
    sw   t0, 0x18(s0)          # digest word 6 = 0x46bfe245
    lw   t0, 0x2C(a1)
    sw   t0, 0x1C(s0)          # digest word 7 = 0x11431532

    li   t0, 0x600d600d       # marker: hash xong
    sw   t0, 0x20(s0)

halt:
    j    halt
