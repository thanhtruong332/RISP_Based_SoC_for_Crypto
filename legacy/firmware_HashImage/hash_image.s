# hash_image.s - RISSP+SHA3 SoC: hash toan bo noi dung ota_demo.bin (448 byte)
# bang SHA3-256, ghi digest ra vung debug 0xC0000000.
#
# "Image" = chinh file ota_demo.bin da build o phien truoc (448 byte, dung lam
# vi du firmware image that thay vi anh chup - khop narrative secure boot).
# Nhung thang unroll (li+sw cho tung tu) vi RISSP LW/SW khong doc duoc tu imem.
#
# QUAN TRONG: data_hi/data_lo la BIG-ENDIAN cua tung 4-byte chunk (byte dau
# tien cua message nam o bit[31:24]) - dung chuan "doc tu nhien" ma SHA3 core
# yeu cau (xem SHA3_Core/SHA3.md), KHAC voi little-endian dung khi doc file .bin
# de tai dung lai lenh may. Da tu bat loi nay truoc khi chot (xem hash_image.md).
#
# Dia chi SHA3 = 0x44A00000 (theo dung Address Editor SoC RISSP+SHA3 hien tai,
# KHONG con la 0x44000000 cua ban AES_ULTRA cu).
#
# Ket qua ky vong (Python hashlib.sha3_256 tren dung 448 byte file goc):
#   fdfdfb15c0436e29646bf1e3d4872826ccb099ecaaf67b7dbb415620e0f7cac9

.section .text
.globl _start

_start:
    li   a1, 0x44A00000       # SHA3 base (Address Editor)
    li   s0, 0xC0000000       # vung debug/ket qua (BRAM)
    li   t2, 1                # control: iReady=1,iLast=0,ibyte=0 (dung lai)

    # ---- Nhung 448 byte cua ota_demo.bin (56 tu 64-bit, big-endian), hash toan bo ----
    li   t0, 0xb7050040
    li   t1, 0x37060044
    sw   t0, 0(a1)             # tu 0: data_hi
    sw   t1, 4(a1)             # tu 0: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0xb7060048
    li   t1, 0x370400c0
    sw   t0, 0(a1)             # tu 1: data_hi
    sw   t1, 4(a1)             # tu 1: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0xb7127e2b
    li   t1, 0x93826251
    sw   t0, 0(a1)             # tu 2: data_hi
    sw   t1, 4(a1)             # tu 2: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x23a85500
    li   t1, 0xb7d2ae28
    sw   t0, 0(a1)             # tu 3: data_hi
    sw   t1, 4(a1)             # tu 3: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x9382622a
    li   t1, 0x23aa5500
    sw   t0, 0(a1)             # tu 4: data_hi
    sw   t1, 4(a1)             # tu 4: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0xb712f7ab
    li   t1, 0x93828258
    sw   t0, 0(a1)             # tu 5: data_hi
    sw   t1, 4(a1)             # tu 5: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x23ac5500
    li   t1, 0xb752cf09
    sw   t0, 0(a1)             # tu 6: data_hi
    sw   t1, 4(a1)             # tu 6: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x9382c2f3
    li   t1, 0x23ae5500
    sw   t0, 0(a1)             # tu 7: data_hi
    sw   t1, 4(a1)             # tu 7: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0xb7f2f1f0
    li   t1, 0x9382322f
    sw   t0, 0(a1)             # tu 8: data_hi
    sw   t1, 4(a1)             # tu 8: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x23a05504
    li   t1, 0xb7f2f5f4
    sw   t0, 0(a1)             # tu 9: data_hi
    sw   t1, 4(a1)             # tu 9: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x9382726f
    li   t1, 0x23a25504
    sw   t0, 0(a1)             # tu 10: data_hi
    sw   t1, 4(a1)             # tu 10: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0xb702faf8
    li   t1, 0x9382b2af
    sw   t0, 0(a1)             # tu 11: data_hi
    sw   t1, 4(a1)             # tu 11: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x23a45504
    li   t1, 0xb702fefc
    sw   t0, 0(a1)             # tu 12: data_hi
    sw   t1, 4(a1)             # tu 12: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x9382f2ef
    li   t1, 0x23a65504
    sw   t0, 0(a1)             # tu 13: data_hi
    sw   t1, 4(a1)             # tu 13: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0xb7624d87
    li   t1, 0x93821219
    sw   t0, 0(a1)             # tu 14: data_hi
    sw   t1, 4(a1)             # tu 14: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x23a05500
    li   t1, 0xb7e220b6
    sw   t0, 0(a1)             # tu 15: data_hi
    sw   t1, 4(a1)             # tu 15: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x93826232
    li   t1, 0x23a25500
    sw   t0, 0(a1)             # tu 16: data_hi
    sw   t1, 4(a1)             # tu 16: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0xb772ef1b
    li   t1, 0x93824286
    sw   t0, 0(a1)             # tu 17: data_hi
    sw   t1, 4(a1)             # tu 17: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x23a45500
    li   t1, 0xb7b20d99
    sw   t0, 0(a1)             # tu 18: data_hi
    sw   t1, 4(a1)             # tu 18: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x9382e26c
    li   t1, 0x23a65500
    sw   t0, 0(a1)             # tu 19: data_hi
    sw   t1, 4(a1)             # tu 19: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x93025000
    li   t1, 0x23a05502
    sw   t0, 0(a1)             # tu 20: data_hi
    sw   t1, 4(a1)             # tu 20: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x83a24502
    li   t1, 0x93f21200
    sw   t0, 0(a1)             # tu 21: data_hi
    sw   t1, 4(a1)             # tu 21: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0xe38c02fe
    li   t1, 0x03aa0503
    sw   t0, 0(a1)             # tu 22: data_hi
    sw   t1, 4(a1)             # tu 22: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x83aa4503
    li   t1, 0x03ab8503
    sw   t0, 0(a1)             # tu 23: data_hi
    sw   t1, 4(a1)             # tu 23: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x83abc503
    li   t1, 0x13031000
    sw   t0, 0(a1)             # tu 24: data_hi
    sw   t1, 4(a1)             # tu 24: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x23204601
    li   t1, 0x23225601
    sw   t0, 0(a1)             # tu 25: data_hi
    sw   t1, 4(a1)             # tu 25: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x23246600
    li   t1, 0x23206601
    sw   t0, 0(a1)             # tu 26: data_hi
    sw   t1, 4(a1)             # tu 26: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x23227601
    li   t1, 0x23246600
    sw   t0, 0(a1)             # tu 27: data_hi
    sw   t1, 4(a1)             # tu 27: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x93033000
    li   t1, 0x23200600
    sw   t0, 0(a1)             # tu 28: data_hi
    sw   t1, 4(a1)             # tu 28: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x23220600
    li   t1, 0x23247600
    sw   t0, 0(a1)             # tu 29: data_hi
    sw   t1, 4(a1)             # tu 29: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x8322c600
    li   t1, 0x93f21200
    sw   t0, 0(a1)             # tu 30: data_hi
    sw   t1, 4(a1)             # tu 30: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0xe38c02fe
    li   t1, 0x032c0601
    sw   t0, 0(a1)             # tu 31: data_hi
    sw   t1, 4(a1)             # tu 31: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x832c4601
    li   t1, 0x334c9c01
    sw   t0, 0(a1)             # tu 32: data_hi
    sw   t1, 4(a1)             # tu 32: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x832c8601
    li   t1, 0x334c9c01
    sw   t0, 0(a1)             # tu 33: data_hi
    sw   t1, 4(a1)             # tu 33: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x832cc601
    li   t1, 0x334c9c01
    sw   t0, 0(a1)             # tu 34: data_hi
    sw   t1, 4(a1)             # tu 34: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x832c0602
    li   t1, 0x334c9c01
    sw   t0, 0(a1)             # tu 35: data_hi
    sw   t1, 4(a1)             # tu 35: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x832c4602
    li   t1, 0x334c9c01
    sw   t0, 0(a1)             # tu 36: data_hi
    sw   t1, 4(a1)             # tu 36: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x832c8602
    li   t1, 0x334c9c01
    sw   t0, 0(a1)             # tu 37: data_hi
    sw   t1, 4(a1)             # tu 37: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x832cc602
    li   t1, 0x334c9c01
    sw   t0, 0(a1)             # tu 38: data_hi
    sw   t1, 4(a1)             # tu 38: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0xb712614a
    li   t1, 0x9382f2a6
    sw   t0, 0(a1)             # tu 39: data_hi
    sw   t1, 4(a1)             # tu 39: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x23a05600
    li   t1, 0xb7020100
    sw   t0, 0(a1)             # tu 40: data_hi
    sw   t1, 4(a1)             # tu 40: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x93821200
    li   t1, 0x23a25600
    sw   t0, 0(a1)             # tu 41: data_hi
    sw   t1, 4(a1)             # tu 41: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0xb702e0ff
    li   t1, 0x9382f20f
    sw   t0, 0(a1)             # tu 42: data_hi
    sw   t1, 4(a1)             # tu 42: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x23a45600
    li   t1, 0xb702e1c0
    sw   t0, 0(a1)             # tu 43: data_hi
    sw   t1, 4(a1)             # tu 43: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x93821210
    li   t1, 0x23a65600
    sw   t0, 0(a1)             # tu 44: data_hi
    sw   t1, 4(a1)             # tu 44: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0xb7023d40
    li   t1, 0x93821220
    sw   t0, 0(a1)             # tu 45: data_hi
    sw   t1, 4(a1)             # tu 45: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x23a85600
    li   t1, 0x13031000
    sw   t0, 0(a1)             # tu 46: data_hi
    sw   t1, 4(a1)             # tu 46: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x23aa6600
    li   t1, 0x83a28601
    sw   t0, 0(a1)             # tu 47: data_hi
    sw   t1, 4(a1)             # tu 47: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x93f21200
    li   t1, 0xe38c02fe
    sw   t0, 0(a1)             # tu 48: data_hi
    sw   t1, 4(a1)             # tu 48: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x83adc601
    li   t1, 0x63928d03
    sw   t0, 0(a1)             # tu 49: data_hi
    sw   t1, 4(a1)             # tu 49: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x23204401
    li   t1, 0x23225401
    sw   t0, 0(a1)             # tu 50: data_hi
    sw   t1, 4(a1)             # tu 50: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x23246401
    li   t1, 0x23267401
    sw   t0, 0(a1)             # tu 51: data_hi
    sw   t1, 4(a1)             # tu 51: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x376e0d60
    li   t1, 0x130ede00
    sw   t0, 0(a1)             # tu 52: data_hi
    sw   t1, 4(a1)             # tu 52: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x2328c401
    li   t1, 0x6f000001
    sw   t0, 0(a1)             # tu 53: data_hi
    sw   t1, 4(a1)             # tu 53: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x37ced0ba
    li   t1, 0x130e0ead
    sw   t0, 0(a1)             # tu 54: data_hi
    sw   t1, 4(a1)             # tu 54: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    li   t0, 0x2328c401
    li   t1, 0x6f000000
    sw   t0, 0(a1)             # tu 55: data_hi
    sw   t1, 4(a1)             # tu 55: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

    # ---- Tu rong bao ket thuc (448 byte = dung boi so 8, can tu dem rieng) ----
    li   t3, 3                # control: iReady=1,iLast=1,ibyte_num=0
    sw   x0, 0(a1)
    sw   x0, 4(a1)
    sw   t3, 8(a1)

poll_sha3:
    lw   t0, 0x0C(a1)          # STATUS: bit0=oReady
    andi t0, t0, 1
    beqz t0, poll_sha3

    # ---- Doc 8 tu digest (0x10..0x2C, MSB truoc), ghi ra BRAM 0xC0000000 ----
    lw   t0, 0x10(a1)
    sw   t0, 0x00(s0)          # digest word 0
    lw   t0, 0x14(a1)
    sw   t0, 0x04(s0)          # digest word 1
    lw   t0, 0x18(a1)
    sw   t0, 0x08(s0)          # digest word 2
    lw   t0, 0x1C(a1)
    sw   t0, 0x0C(s0)          # digest word 3
    lw   t0, 0x20(a1)
    sw   t0, 0x10(s0)          # digest word 4
    lw   t0, 0x24(a1)
    sw   t0, 0x14(s0)          # digest word 5
    lw   t0, 0x28(a1)
    sw   t0, 0x18(s0)          # digest word 6
    lw   t0, 0x2C(a1)
    sw   t0, 0x1C(s0)          # digest word 7

    li   t0, 0x600d600d       # marker: hash xong
    sw   t0, 0x20(s0)

halt:
    j    halt

