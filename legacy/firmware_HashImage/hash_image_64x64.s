# hash_image_64x64.s - RISSP+SHA3 SoC: hash anh test 4096 byte
# bang SHA3-256, ghi digest ra vung debug 0xC0000000.
#
# Sinh TU DONG boi gen_image_firmware.py - khong sua tay file nay,
# sua script roi chay lai neu can doi anh/kich thuoc.
#
# KHAC hash_image.s ban dau: co POLL oBuffer_full (STATUS bit1)
# TRUOC moi lan ghi tu moi de tranh mat du lieu am tham khi anh
# tran nhieu block SHA3 (xem SHA3_Core/SHA3.md).
#
# Ground truth (Python hashlib.sha3_256, 4096 byte):
#   d280d0b835bdae3748d8c9aa145f7a2115391d339736e0a67ea11728a5d03fc9

.section .text
.globl _start

_start:
    li   a1, 0x44a00000       # SHA3 base
    li   s0, 0xc0000000       # vung debug/ket qua (BRAM)
    li   t2, 1                 # CTRL tu thuong: iReady=1,iLast=0,ibyte=0

poll_buf_0:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_0
    li   t0, 0x0718293a
    li   t1, 0x4b5c6d7e
    sw   t0, 0(a1)             # tu 0: data_hi
    sw   t1, 4(a1)             # tu 0: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_1:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_1
    li   t0, 0x8fa0b1c2
    li   t1, 0xd3e4f506
    sw   t0, 0(a1)             # tu 1: data_hi
    sw   t1, 4(a1)             # tu 1: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_2:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_2
    li   t0, 0x1728394a
    li   t1, 0x5b6c7d8e
    sw   t0, 0(a1)             # tu 2: data_hi
    sw   t1, 4(a1)             # tu 2: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_3:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_3
    li   t0, 0x9fb0c1d2
    li   t1, 0xe3f40516
    sw   t0, 0(a1)             # tu 3: data_hi
    sw   t1, 4(a1)             # tu 3: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_4:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_4
    li   t0, 0x2738495a
    li   t1, 0x6b7c8d9e
    sw   t0, 0(a1)             # tu 4: data_hi
    sw   t1, 4(a1)             # tu 4: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_5:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_5
    li   t0, 0xafc0d1e2
    li   t1, 0xf3041526
    sw   t0, 0(a1)             # tu 5: data_hi
    sw   t1, 4(a1)             # tu 5: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_6:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_6
    li   t0, 0x3748596a
    li   t1, 0x7b8c9dae
    sw   t0, 0(a1)             # tu 6: data_hi
    sw   t1, 4(a1)             # tu 6: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_7:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_7
    li   t0, 0xbfd0e1f2
    li   t1, 0x03142536
    sw   t0, 0(a1)             # tu 7: data_hi
    sw   t1, 4(a1)             # tu 7: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_8:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_8
    li   t0, 0x24354657
    li   t1, 0x68798a9b
    sw   t0, 0(a1)             # tu 8: data_hi
    sw   t1, 4(a1)             # tu 8: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_9:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_9
    li   t0, 0xacbdcedf
    li   t1, 0xf0011223
    sw   t0, 0(a1)             # tu 9: data_hi
    sw   t1, 4(a1)             # tu 9: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_10:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_10
    li   t0, 0x34455667
    li   t1, 0x78899aab
    sw   t0, 0(a1)             # tu 10: data_hi
    sw   t1, 4(a1)             # tu 10: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_11:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_11
    li   t0, 0xbccddeef
    li   t1, 0x00112233
    sw   t0, 0(a1)             # tu 11: data_hi
    sw   t1, 4(a1)             # tu 11: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_12:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_12
    li   t0, 0x44556677
    li   t1, 0x8899aabb
    sw   t0, 0(a1)             # tu 12: data_hi
    sw   t1, 4(a1)             # tu 12: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_13:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_13
    li   t0, 0xccddeeff
    li   t1, 0x10213243
    sw   t0, 0(a1)             # tu 13: data_hi
    sw   t1, 4(a1)             # tu 13: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_14:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_14
    li   t0, 0x54657687
    li   t1, 0x98a9bacb
    sw   t0, 0(a1)             # tu 14: data_hi
    sw   t1, 4(a1)             # tu 14: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_15:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_15
    li   t0, 0xdcedfe0f
    li   t1, 0x20314253
    sw   t0, 0(a1)             # tu 15: data_hi
    sw   t1, 4(a1)             # tu 15: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_16:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_16
    li   t0, 0x41526374
    li   t1, 0x8596a7b8
    sw   t0, 0(a1)             # tu 16: data_hi
    sw   t1, 4(a1)             # tu 16: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_17:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_17
    li   t0, 0xc9daebfc
    li   t1, 0x0d1e2f40
    sw   t0, 0(a1)             # tu 17: data_hi
    sw   t1, 4(a1)             # tu 17: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_18:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_18
    li   t0, 0x51627384
    li   t1, 0x95a6b7c8
    sw   t0, 0(a1)             # tu 18: data_hi
    sw   t1, 4(a1)             # tu 18: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_19:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_19
    li   t0, 0xd9eafb0c
    li   t1, 0x1d2e3f50
    sw   t0, 0(a1)             # tu 19: data_hi
    sw   t1, 4(a1)             # tu 19: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_20:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_20
    li   t0, 0x61728394
    li   t1, 0xa5b6c7d8
    sw   t0, 0(a1)             # tu 20: data_hi
    sw   t1, 4(a1)             # tu 20: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_21:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_21
    li   t0, 0xe9fa0b1c
    li   t1, 0x2d3e4f60
    sw   t0, 0(a1)             # tu 21: data_hi
    sw   t1, 4(a1)             # tu 21: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_22:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_22
    li   t0, 0x718293a4
    li   t1, 0xb5c6d7e8
    sw   t0, 0(a1)             # tu 22: data_hi
    sw   t1, 4(a1)             # tu 22: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_23:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_23
    li   t0, 0xf90a1b2c
    li   t1, 0x3d4e5f70
    sw   t0, 0(a1)             # tu 23: data_hi
    sw   t1, 4(a1)             # tu 23: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_24:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_24
    li   t0, 0x5e6f8091
    li   t1, 0xa2b3c4d5
    sw   t0, 0(a1)             # tu 24: data_hi
    sw   t1, 4(a1)             # tu 24: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_25:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_25
    li   t0, 0xe6f70819
    li   t1, 0x2a3b4c5d
    sw   t0, 0(a1)             # tu 25: data_hi
    sw   t1, 4(a1)             # tu 25: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_26:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_26
    li   t0, 0x6e7f90a1
    li   t1, 0xb2c3d4e5
    sw   t0, 0(a1)             # tu 26: data_hi
    sw   t1, 4(a1)             # tu 26: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_27:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_27
    li   t0, 0xf6071829
    li   t1, 0x3a4b5c6d
    sw   t0, 0(a1)             # tu 27: data_hi
    sw   t1, 4(a1)             # tu 27: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_28:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_28
    li   t0, 0x7e8fa0b1
    li   t1, 0xc2d3e4f5
    sw   t0, 0(a1)             # tu 28: data_hi
    sw   t1, 4(a1)             # tu 28: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_29:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_29
    li   t0, 0x06172839
    li   t1, 0x4a5b6c7d
    sw   t0, 0(a1)             # tu 29: data_hi
    sw   t1, 4(a1)             # tu 29: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_30:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_30
    li   t0, 0x8e9fb0c1
    li   t1, 0xd2e3f405
    sw   t0, 0(a1)             # tu 30: data_hi
    sw   t1, 4(a1)             # tu 30: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_31:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_31
    li   t0, 0x16273849
    li   t1, 0x5a6b7c8d
    sw   t0, 0(a1)             # tu 31: data_hi
    sw   t1, 4(a1)             # tu 31: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_32:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_32
    li   t0, 0x7b8c9dae
    li   t1, 0xbfd0e1f2
    sw   t0, 0(a1)             # tu 32: data_hi
    sw   t1, 4(a1)             # tu 32: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_33:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_33
    li   t0, 0x03142536
    li   t1, 0x4758697a
    sw   t0, 0(a1)             # tu 33: data_hi
    sw   t1, 4(a1)             # tu 33: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_34:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_34
    li   t0, 0x8b9cadbe
    li   t1, 0xcfe0f102
    sw   t0, 0(a1)             # tu 34: data_hi
    sw   t1, 4(a1)             # tu 34: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_35:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_35
    li   t0, 0x13243546
    li   t1, 0x5768798a
    sw   t0, 0(a1)             # tu 35: data_hi
    sw   t1, 4(a1)             # tu 35: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_36:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_36
    li   t0, 0x9bacbdce
    li   t1, 0xdff00112
    sw   t0, 0(a1)             # tu 36: data_hi
    sw   t1, 4(a1)             # tu 36: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_37:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_37
    li   t0, 0x23344556
    li   t1, 0x6778899a
    sw   t0, 0(a1)             # tu 37: data_hi
    sw   t1, 4(a1)             # tu 37: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_38:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_38
    li   t0, 0xabbccdde
    li   t1, 0xef001122
    sw   t0, 0(a1)             # tu 38: data_hi
    sw   t1, 4(a1)             # tu 38: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_39:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_39
    li   t0, 0x33445566
    li   t1, 0x778899aa
    sw   t0, 0(a1)             # tu 39: data_hi
    sw   t1, 4(a1)             # tu 39: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_40:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_40
    li   t0, 0x98a9bacb
    li   t1, 0xdcedfe0f
    sw   t0, 0(a1)             # tu 40: data_hi
    sw   t1, 4(a1)             # tu 40: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_41:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_41
    li   t0, 0x20314253
    li   t1, 0x64758697
    sw   t0, 0(a1)             # tu 41: data_hi
    sw   t1, 4(a1)             # tu 41: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_42:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_42
    li   t0, 0xa8b9cadb
    li   t1, 0xecfd0e1f
    sw   t0, 0(a1)             # tu 42: data_hi
    sw   t1, 4(a1)             # tu 42: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_43:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_43
    li   t0, 0x30415263
    li   t1, 0x748596a7
    sw   t0, 0(a1)             # tu 43: data_hi
    sw   t1, 4(a1)             # tu 43: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_44:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_44
    li   t0, 0xb8c9daeb
    li   t1, 0xfc0d1e2f
    sw   t0, 0(a1)             # tu 44: data_hi
    sw   t1, 4(a1)             # tu 44: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_45:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_45
    li   t0, 0x40516273
    li   t1, 0x8495a6b7
    sw   t0, 0(a1)             # tu 45: data_hi
    sw   t1, 4(a1)             # tu 45: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_46:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_46
    li   t0, 0xc8d9eafb
    li   t1, 0x0c1d2e3f
    sw   t0, 0(a1)             # tu 46: data_hi
    sw   t1, 4(a1)             # tu 46: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_47:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_47
    li   t0, 0x50617283
    li   t1, 0x94a5b6c7
    sw   t0, 0(a1)             # tu 47: data_hi
    sw   t1, 4(a1)             # tu 47: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_48:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_48
    li   t0, 0xb5c6d7e8
    li   t1, 0xf90a1b2c
    sw   t0, 0(a1)             # tu 48: data_hi
    sw   t1, 4(a1)             # tu 48: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_49:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_49
    li   t0, 0x3d4e5f70
    li   t1, 0x8192a3b4
    sw   t0, 0(a1)             # tu 49: data_hi
    sw   t1, 4(a1)             # tu 49: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_50:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_50
    li   t0, 0xc5d6e7f8
    li   t1, 0x091a2b3c
    sw   t0, 0(a1)             # tu 50: data_hi
    sw   t1, 4(a1)             # tu 50: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_51:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_51
    li   t0, 0x4d5e6f80
    li   t1, 0x91a2b3c4
    sw   t0, 0(a1)             # tu 51: data_hi
    sw   t1, 4(a1)             # tu 51: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_52:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_52
    li   t0, 0xd5e6f708
    li   t1, 0x192a3b4c
    sw   t0, 0(a1)             # tu 52: data_hi
    sw   t1, 4(a1)             # tu 52: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_53:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_53
    li   t0, 0x5d6e7f90
    li   t1, 0xa1b2c3d4
    sw   t0, 0(a1)             # tu 53: data_hi
    sw   t1, 4(a1)             # tu 53: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_54:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_54
    li   t0, 0xe5f60718
    li   t1, 0x293a4b5c
    sw   t0, 0(a1)             # tu 54: data_hi
    sw   t1, 4(a1)             # tu 54: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_55:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_55
    li   t0, 0x6d7e8fa0
    li   t1, 0xb1c2d3e4
    sw   t0, 0(a1)             # tu 55: data_hi
    sw   t1, 4(a1)             # tu 55: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_56:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_56
    li   t0, 0xd2e3f405
    li   t1, 0x16273849
    sw   t0, 0(a1)             # tu 56: data_hi
    sw   t1, 4(a1)             # tu 56: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_57:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_57
    li   t0, 0x5a6b7c8d
    li   t1, 0x9eafc0d1
    sw   t0, 0(a1)             # tu 57: data_hi
    sw   t1, 4(a1)             # tu 57: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_58:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_58
    li   t0, 0xe2f30415
    li   t1, 0x26374859
    sw   t0, 0(a1)             # tu 58: data_hi
    sw   t1, 4(a1)             # tu 58: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_59:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_59
    li   t0, 0x6a7b8c9d
    li   t1, 0xaebfd0e1
    sw   t0, 0(a1)             # tu 59: data_hi
    sw   t1, 4(a1)             # tu 59: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_60:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_60
    li   t0, 0xf2031425
    li   t1, 0x36475869
    sw   t0, 0(a1)             # tu 60: data_hi
    sw   t1, 4(a1)             # tu 60: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_61:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_61
    li   t0, 0x7a8b9cad
    li   t1, 0xbecfe0f1
    sw   t0, 0(a1)             # tu 61: data_hi
    sw   t1, 4(a1)             # tu 61: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_62:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_62
    li   t0, 0x02132435
    li   t1, 0x46576879
    sw   t0, 0(a1)             # tu 62: data_hi
    sw   t1, 4(a1)             # tu 62: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_63:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_63
    li   t0, 0x8a9bacbd
    li   t1, 0xcedff001
    sw   t0, 0(a1)             # tu 63: data_hi
    sw   t1, 4(a1)             # tu 63: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_64:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_64
    li   t0, 0xef001122
    li   t1, 0x33445566
    sw   t0, 0(a1)             # tu 64: data_hi
    sw   t1, 4(a1)             # tu 64: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_65:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_65
    li   t0, 0x778899aa
    li   t1, 0xbbccddee
    sw   t0, 0(a1)             # tu 65: data_hi
    sw   t1, 4(a1)             # tu 65: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_66:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_66
    li   t0, 0xff102132
    li   t1, 0x43546576
    sw   t0, 0(a1)             # tu 66: data_hi
    sw   t1, 4(a1)             # tu 66: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_67:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_67
    li   t0, 0x8798a9ba
    li   t1, 0xcbdcedfe
    sw   t0, 0(a1)             # tu 67: data_hi
    sw   t1, 4(a1)             # tu 67: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_68:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_68
    li   t0, 0x0f203142
    li   t1, 0x53647586
    sw   t0, 0(a1)             # tu 68: data_hi
    sw   t1, 4(a1)             # tu 68: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_69:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_69
    li   t0, 0x97a8b9ca
    li   t1, 0xdbecfd0e
    sw   t0, 0(a1)             # tu 69: data_hi
    sw   t1, 4(a1)             # tu 69: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_70:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_70
    li   t0, 0x1f304152
    li   t1, 0x63748596
    sw   t0, 0(a1)             # tu 70: data_hi
    sw   t1, 4(a1)             # tu 70: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_71:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_71
    li   t0, 0xa7b8c9da
    li   t1, 0xebfc0d1e
    sw   t0, 0(a1)             # tu 71: data_hi
    sw   t1, 4(a1)             # tu 71: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_72:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_72
    li   t0, 0x0c1d2e3f
    li   t1, 0x50617283
    sw   t0, 0(a1)             # tu 72: data_hi
    sw   t1, 4(a1)             # tu 72: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_73:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_73
    li   t0, 0x94a5b6c7
    li   t1, 0xd8e9fa0b
    sw   t0, 0(a1)             # tu 73: data_hi
    sw   t1, 4(a1)             # tu 73: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_74:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_74
    li   t0, 0x1c2d3e4f
    li   t1, 0x60718293
    sw   t0, 0(a1)             # tu 74: data_hi
    sw   t1, 4(a1)             # tu 74: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_75:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_75
    li   t0, 0xa4b5c6d7
    li   t1, 0xe8f90a1b
    sw   t0, 0(a1)             # tu 75: data_hi
    sw   t1, 4(a1)             # tu 75: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_76:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_76
    li   t0, 0x2c3d4e5f
    li   t1, 0x708192a3
    sw   t0, 0(a1)             # tu 76: data_hi
    sw   t1, 4(a1)             # tu 76: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_77:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_77
    li   t0, 0xb4c5d6e7
    li   t1, 0xf8091a2b
    sw   t0, 0(a1)             # tu 77: data_hi
    sw   t1, 4(a1)             # tu 77: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_78:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_78
    li   t0, 0x3c4d5e6f
    li   t1, 0x8091a2b3
    sw   t0, 0(a1)             # tu 78: data_hi
    sw   t1, 4(a1)             # tu 78: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_79:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_79
    li   t0, 0xc4d5e6f7
    li   t1, 0x08192a3b
    sw   t0, 0(a1)             # tu 79: data_hi
    sw   t1, 4(a1)             # tu 79: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_80:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_80
    li   t0, 0x293a4b5c
    li   t1, 0x6d7e8fa0
    sw   t0, 0(a1)             # tu 80: data_hi
    sw   t1, 4(a1)             # tu 80: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_81:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_81
    li   t0, 0xb1c2d3e4
    li   t1, 0xf5061728
    sw   t0, 0(a1)             # tu 81: data_hi
    sw   t1, 4(a1)             # tu 81: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_82:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_82
    li   t0, 0x394a5b6c
    li   t1, 0x7d8e9fb0
    sw   t0, 0(a1)             # tu 82: data_hi
    sw   t1, 4(a1)             # tu 82: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_83:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_83
    li   t0, 0xc1d2e3f4
    li   t1, 0x05162738
    sw   t0, 0(a1)             # tu 83: data_hi
    sw   t1, 4(a1)             # tu 83: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_84:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_84
    li   t0, 0x495a6b7c
    li   t1, 0x8d9eafc0
    sw   t0, 0(a1)             # tu 84: data_hi
    sw   t1, 4(a1)             # tu 84: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_85:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_85
    li   t0, 0xd1e2f304
    li   t1, 0x15263748
    sw   t0, 0(a1)             # tu 85: data_hi
    sw   t1, 4(a1)             # tu 85: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_86:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_86
    li   t0, 0x596a7b8c
    li   t1, 0x9daebfd0
    sw   t0, 0(a1)             # tu 86: data_hi
    sw   t1, 4(a1)             # tu 86: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_87:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_87
    li   t0, 0xe1f20314
    li   t1, 0x25364758
    sw   t0, 0(a1)             # tu 87: data_hi
    sw   t1, 4(a1)             # tu 87: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_88:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_88
    li   t0, 0x46576879
    li   t1, 0x8a9bacbd
    sw   t0, 0(a1)             # tu 88: data_hi
    sw   t1, 4(a1)             # tu 88: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_89:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_89
    li   t0, 0xcedff001
    li   t1, 0x12233445
    sw   t0, 0(a1)             # tu 89: data_hi
    sw   t1, 4(a1)             # tu 89: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_90:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_90
    li   t0, 0x56677889
    li   t1, 0x9aabbccd
    sw   t0, 0(a1)             # tu 90: data_hi
    sw   t1, 4(a1)             # tu 90: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_91:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_91
    li   t0, 0xdeef0011
    li   t1, 0x22334455
    sw   t0, 0(a1)             # tu 91: data_hi
    sw   t1, 4(a1)             # tu 91: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_92:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_92
    li   t0, 0x66778899
    li   t1, 0xaabbccdd
    sw   t0, 0(a1)             # tu 92: data_hi
    sw   t1, 4(a1)             # tu 92: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_93:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_93
    li   t0, 0xeeff1021
    li   t1, 0x32435465
    sw   t0, 0(a1)             # tu 93: data_hi
    sw   t1, 4(a1)             # tu 93: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_94:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_94
    li   t0, 0x768798a9
    li   t1, 0xbacbdced
    sw   t0, 0(a1)             # tu 94: data_hi
    sw   t1, 4(a1)             # tu 94: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_95:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_95
    li   t0, 0xfe0f2031
    li   t1, 0x42536475
    sw   t0, 0(a1)             # tu 95: data_hi
    sw   t1, 4(a1)             # tu 95: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_96:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_96
    li   t0, 0x63748596
    li   t1, 0xa7b8c9da
    sw   t0, 0(a1)             # tu 96: data_hi
    sw   t1, 4(a1)             # tu 96: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_97:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_97
    li   t0, 0xebfc0d1e
    li   t1, 0x2f405162
    sw   t0, 0(a1)             # tu 97: data_hi
    sw   t1, 4(a1)             # tu 97: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_98:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_98
    li   t0, 0x738495a6
    li   t1, 0xb7c8d9ea
    sw   t0, 0(a1)             # tu 98: data_hi
    sw   t1, 4(a1)             # tu 98: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_99:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_99
    li   t0, 0xfb0c1d2e
    li   t1, 0x3f506172
    sw   t0, 0(a1)             # tu 99: data_hi
    sw   t1, 4(a1)             # tu 99: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_100:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_100
    li   t0, 0x8394a5b6
    li   t1, 0xc7d8e9fa
    sw   t0, 0(a1)             # tu 100: data_hi
    sw   t1, 4(a1)             # tu 100: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_101:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_101
    li   t0, 0x0b1c2d3e
    li   t1, 0x4f607182
    sw   t0, 0(a1)             # tu 101: data_hi
    sw   t1, 4(a1)             # tu 101: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_102:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_102
    li   t0, 0x93a4b5c6
    li   t1, 0xd7e8f90a
    sw   t0, 0(a1)             # tu 102: data_hi
    sw   t1, 4(a1)             # tu 102: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_103:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_103
    li   t0, 0x1b2c3d4e
    li   t1, 0x5f708192
    sw   t0, 0(a1)             # tu 103: data_hi
    sw   t1, 4(a1)             # tu 103: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_104:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_104
    li   t0, 0x8091a2b3
    li   t1, 0xc4d5e6f7
    sw   t0, 0(a1)             # tu 104: data_hi
    sw   t1, 4(a1)             # tu 104: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_105:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_105
    li   t0, 0x08192a3b
    li   t1, 0x4c5d6e7f
    sw   t0, 0(a1)             # tu 105: data_hi
    sw   t1, 4(a1)             # tu 105: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_106:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_106
    li   t0, 0x90a1b2c3
    li   t1, 0xd4e5f607
    sw   t0, 0(a1)             # tu 106: data_hi
    sw   t1, 4(a1)             # tu 106: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_107:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_107
    li   t0, 0x18293a4b
    li   t1, 0x5c6d7e8f
    sw   t0, 0(a1)             # tu 107: data_hi
    sw   t1, 4(a1)             # tu 107: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_108:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_108
    li   t0, 0xa0b1c2d3
    li   t1, 0xe4f50617
    sw   t0, 0(a1)             # tu 108: data_hi
    sw   t1, 4(a1)             # tu 108: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_109:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_109
    li   t0, 0x28394a5b
    li   t1, 0x6c7d8e9f
    sw   t0, 0(a1)             # tu 109: data_hi
    sw   t1, 4(a1)             # tu 109: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_110:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_110
    li   t0, 0xb0c1d2e3
    li   t1, 0xf4051627
    sw   t0, 0(a1)             # tu 110: data_hi
    sw   t1, 4(a1)             # tu 110: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_111:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_111
    li   t0, 0x38495a6b
    li   t1, 0x7c8d9eaf
    sw   t0, 0(a1)             # tu 111: data_hi
    sw   t1, 4(a1)             # tu 111: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_112:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_112
    li   t0, 0x9daebfd0
    li   t1, 0xe1f20314
    sw   t0, 0(a1)             # tu 112: data_hi
    sw   t1, 4(a1)             # tu 112: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_113:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_113
    li   t0, 0x25364758
    li   t1, 0x697a8b9c
    sw   t0, 0(a1)             # tu 113: data_hi
    sw   t1, 4(a1)             # tu 113: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_114:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_114
    li   t0, 0xadbecfe0
    li   t1, 0xf1021324
    sw   t0, 0(a1)             # tu 114: data_hi
    sw   t1, 4(a1)             # tu 114: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_115:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_115
    li   t0, 0x35465768
    li   t1, 0x798a9bac
    sw   t0, 0(a1)             # tu 115: data_hi
    sw   t1, 4(a1)             # tu 115: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_116:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_116
    li   t0, 0xbdcedff0
    li   t1, 0x01122334
    sw   t0, 0(a1)             # tu 116: data_hi
    sw   t1, 4(a1)             # tu 116: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_117:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_117
    li   t0, 0x45566778
    li   t1, 0x899aabbc
    sw   t0, 0(a1)             # tu 117: data_hi
    sw   t1, 4(a1)             # tu 117: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_118:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_118
    li   t0, 0xcddeef00
    li   t1, 0x11223344
    sw   t0, 0(a1)             # tu 118: data_hi
    sw   t1, 4(a1)             # tu 118: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_119:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_119
    li   t0, 0x55667788
    li   t1, 0x99aabbcc
    sw   t0, 0(a1)             # tu 119: data_hi
    sw   t1, 4(a1)             # tu 119: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_120:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_120
    li   t0, 0xbacbdced
    li   t1, 0xfe0f2031
    sw   t0, 0(a1)             # tu 120: data_hi
    sw   t1, 4(a1)             # tu 120: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_121:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_121
    li   t0, 0x42536475
    li   t1, 0x8697a8b9
    sw   t0, 0(a1)             # tu 121: data_hi
    sw   t1, 4(a1)             # tu 121: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_122:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_122
    li   t0, 0xcadbecfd
    li   t1, 0x0e1f3041
    sw   t0, 0(a1)             # tu 122: data_hi
    sw   t1, 4(a1)             # tu 122: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_123:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_123
    li   t0, 0x52637485
    li   t1, 0x96a7b8c9
    sw   t0, 0(a1)             # tu 123: data_hi
    sw   t1, 4(a1)             # tu 123: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_124:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_124
    li   t0, 0xdaebfc0d
    li   t1, 0x1e2f4051
    sw   t0, 0(a1)             # tu 124: data_hi
    sw   t1, 4(a1)             # tu 124: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_125:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_125
    li   t0, 0x62738495
    li   t1, 0xa6b7c8d9
    sw   t0, 0(a1)             # tu 125: data_hi
    sw   t1, 4(a1)             # tu 125: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_126:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_126
    li   t0, 0xeafb0c1d
    li   t1, 0x2e3f5061
    sw   t0, 0(a1)             # tu 126: data_hi
    sw   t1, 4(a1)             # tu 126: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_127:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_127
    li   t0, 0x728394a5
    li   t1, 0xb6c7d8e9
    sw   t0, 0(a1)             # tu 127: data_hi
    sw   t1, 4(a1)             # tu 127: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_128:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_128
    li   t0, 0xd7e8f90a
    li   t1, 0x1b2c3d4e
    sw   t0, 0(a1)             # tu 128: data_hi
    sw   t1, 4(a1)             # tu 128: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_129:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_129
    li   t0, 0x5f708192
    li   t1, 0xa3b4c5d6
    sw   t0, 0(a1)             # tu 129: data_hi
    sw   t1, 4(a1)             # tu 129: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_130:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_130
    li   t0, 0xe7f8091a
    li   t1, 0x2b3c4d5e
    sw   t0, 0(a1)             # tu 130: data_hi
    sw   t1, 4(a1)             # tu 130: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_131:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_131
    li   t0, 0x6f8091a2
    li   t1, 0xb3c4d5e6
    sw   t0, 0(a1)             # tu 131: data_hi
    sw   t1, 4(a1)             # tu 131: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_132:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_132
    li   t0, 0xf708192a
    li   t1, 0x3b4c5d6e
    sw   t0, 0(a1)             # tu 132: data_hi
    sw   t1, 4(a1)             # tu 132: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_133:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_133
    li   t0, 0x7f90a1b2
    li   t1, 0xc3d4e5f6
    sw   t0, 0(a1)             # tu 133: data_hi
    sw   t1, 4(a1)             # tu 133: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_134:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_134
    li   t0, 0x0718293a
    li   t1, 0x4b5c6d7e
    sw   t0, 0(a1)             # tu 134: data_hi
    sw   t1, 4(a1)             # tu 134: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_135:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_135
    li   t0, 0x8fa0b1c2
    li   t1, 0xd3e4f506
    sw   t0, 0(a1)             # tu 135: data_hi
    sw   t1, 4(a1)             # tu 135: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_136:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_136
    li   t0, 0xf4051627
    li   t1, 0x38495a6b
    sw   t0, 0(a1)             # tu 136: data_hi
    sw   t1, 4(a1)             # tu 136: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_137:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_137
    li   t0, 0x7c8d9eaf
    li   t1, 0xc0d1e2f3
    sw   t0, 0(a1)             # tu 137: data_hi
    sw   t1, 4(a1)             # tu 137: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_138:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_138
    li   t0, 0x04152637
    li   t1, 0x48596a7b
    sw   t0, 0(a1)             # tu 138: data_hi
    sw   t1, 4(a1)             # tu 138: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_139:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_139
    li   t0, 0x8c9daebf
    li   t1, 0xd0e1f203
    sw   t0, 0(a1)             # tu 139: data_hi
    sw   t1, 4(a1)             # tu 139: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_140:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_140
    li   t0, 0x14253647
    li   t1, 0x58697a8b
    sw   t0, 0(a1)             # tu 140: data_hi
    sw   t1, 4(a1)             # tu 140: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_141:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_141
    li   t0, 0x9cadbecf
    li   t1, 0xe0f10213
    sw   t0, 0(a1)             # tu 141: data_hi
    sw   t1, 4(a1)             # tu 141: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_142:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_142
    li   t0, 0x24354657
    li   t1, 0x68798a9b
    sw   t0, 0(a1)             # tu 142: data_hi
    sw   t1, 4(a1)             # tu 142: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_143:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_143
    li   t0, 0xacbdcedf
    li   t1, 0xf0011223
    sw   t0, 0(a1)             # tu 143: data_hi
    sw   t1, 4(a1)             # tu 143: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_144:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_144
    li   t0, 0x11223344
    li   t1, 0x55667788
    sw   t0, 0(a1)             # tu 144: data_hi
    sw   t1, 4(a1)             # tu 144: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_145:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_145
    li   t0, 0x99aabbcc
    li   t1, 0xddeeff10
    sw   t0, 0(a1)             # tu 145: data_hi
    sw   t1, 4(a1)             # tu 145: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_146:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_146
    li   t0, 0x21324354
    li   t1, 0x65768798
    sw   t0, 0(a1)             # tu 146: data_hi
    sw   t1, 4(a1)             # tu 146: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_147:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_147
    li   t0, 0xa9bacbdc
    li   t1, 0xedfe0f20
    sw   t0, 0(a1)             # tu 147: data_hi
    sw   t1, 4(a1)             # tu 147: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_148:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_148
    li   t0, 0x31425364
    li   t1, 0x758697a8
    sw   t0, 0(a1)             # tu 148: data_hi
    sw   t1, 4(a1)             # tu 148: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_149:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_149
    li   t0, 0xb9cadbec
    li   t1, 0xfd0e1f30
    sw   t0, 0(a1)             # tu 149: data_hi
    sw   t1, 4(a1)             # tu 149: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_150:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_150
    li   t0, 0x41526374
    li   t1, 0x8596a7b8
    sw   t0, 0(a1)             # tu 150: data_hi
    sw   t1, 4(a1)             # tu 150: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_151:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_151
    li   t0, 0xc9daebfc
    li   t1, 0x0d1e2f40
    sw   t0, 0(a1)             # tu 151: data_hi
    sw   t1, 4(a1)             # tu 151: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_152:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_152
    li   t0, 0x2e3f5061
    li   t1, 0x728394a5
    sw   t0, 0(a1)             # tu 152: data_hi
    sw   t1, 4(a1)             # tu 152: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_153:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_153
    li   t0, 0xb6c7d8e9
    li   t1, 0xfa0b1c2d
    sw   t0, 0(a1)             # tu 153: data_hi
    sw   t1, 4(a1)             # tu 153: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_154:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_154
    li   t0, 0x3e4f6071
    li   t1, 0x8293a4b5
    sw   t0, 0(a1)             # tu 154: data_hi
    sw   t1, 4(a1)             # tu 154: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_155:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_155
    li   t0, 0xc6d7e8f9
    li   t1, 0x0a1b2c3d
    sw   t0, 0(a1)             # tu 155: data_hi
    sw   t1, 4(a1)             # tu 155: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_156:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_156
    li   t0, 0x4e5f7081
    li   t1, 0x92a3b4c5
    sw   t0, 0(a1)             # tu 156: data_hi
    sw   t1, 4(a1)             # tu 156: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_157:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_157
    li   t0, 0xd6e7f809
    li   t1, 0x1a2b3c4d
    sw   t0, 0(a1)             # tu 157: data_hi
    sw   t1, 4(a1)             # tu 157: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_158:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_158
    li   t0, 0x5e6f8091
    li   t1, 0xa2b3c4d5
    sw   t0, 0(a1)             # tu 158: data_hi
    sw   t1, 4(a1)             # tu 158: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_159:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_159
    li   t0, 0xe6f70819
    li   t1, 0x2a3b4c5d
    sw   t0, 0(a1)             # tu 159: data_hi
    sw   t1, 4(a1)             # tu 159: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_160:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_160
    li   t0, 0x4b5c6d7e
    li   t1, 0x8fa0b1c2
    sw   t0, 0(a1)             # tu 160: data_hi
    sw   t1, 4(a1)             # tu 160: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_161:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_161
    li   t0, 0xd3e4f506
    li   t1, 0x1728394a
    sw   t0, 0(a1)             # tu 161: data_hi
    sw   t1, 4(a1)             # tu 161: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_162:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_162
    li   t0, 0x5b6c7d8e
    li   t1, 0x9fb0c1d2
    sw   t0, 0(a1)             # tu 162: data_hi
    sw   t1, 4(a1)             # tu 162: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_163:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_163
    li   t0, 0xe3f40516
    li   t1, 0x2738495a
    sw   t0, 0(a1)             # tu 163: data_hi
    sw   t1, 4(a1)             # tu 163: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_164:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_164
    li   t0, 0x6b7c8d9e
    li   t1, 0xafc0d1e2
    sw   t0, 0(a1)             # tu 164: data_hi
    sw   t1, 4(a1)             # tu 164: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_165:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_165
    li   t0, 0xf3041526
    li   t1, 0x3748596a
    sw   t0, 0(a1)             # tu 165: data_hi
    sw   t1, 4(a1)             # tu 165: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_166:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_166
    li   t0, 0x7b8c9dae
    li   t1, 0xbfd0e1f2
    sw   t0, 0(a1)             # tu 166: data_hi
    sw   t1, 4(a1)             # tu 166: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_167:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_167
    li   t0, 0x03142536
    li   t1, 0x4758697a
    sw   t0, 0(a1)             # tu 167: data_hi
    sw   t1, 4(a1)             # tu 167: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_168:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_168
    li   t0, 0x68798a9b
    li   t1, 0xacbdcedf
    sw   t0, 0(a1)             # tu 168: data_hi
    sw   t1, 4(a1)             # tu 168: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_169:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_169
    li   t0, 0xf0011223
    li   t1, 0x34455667
    sw   t0, 0(a1)             # tu 169: data_hi
    sw   t1, 4(a1)             # tu 169: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_170:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_170
    li   t0, 0x78899aab
    li   t1, 0xbccddeef
    sw   t0, 0(a1)             # tu 170: data_hi
    sw   t1, 4(a1)             # tu 170: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_171:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_171
    li   t0, 0x00112233
    li   t1, 0x44556677
    sw   t0, 0(a1)             # tu 171: data_hi
    sw   t1, 4(a1)             # tu 171: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_172:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_172
    li   t0, 0x8899aabb
    li   t1, 0xccddeeff
    sw   t0, 0(a1)             # tu 172: data_hi
    sw   t1, 4(a1)             # tu 172: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_173:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_173
    li   t0, 0x10213243
    li   t1, 0x54657687
    sw   t0, 0(a1)             # tu 173: data_hi
    sw   t1, 4(a1)             # tu 173: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_174:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_174
    li   t0, 0x98a9bacb
    li   t1, 0xdcedfe0f
    sw   t0, 0(a1)             # tu 174: data_hi
    sw   t1, 4(a1)             # tu 174: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_175:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_175
    li   t0, 0x20314253
    li   t1, 0x64758697
    sw   t0, 0(a1)             # tu 175: data_hi
    sw   t1, 4(a1)             # tu 175: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_176:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_176
    li   t0, 0x8596a7b8
    li   t1, 0xc9daebfc
    sw   t0, 0(a1)             # tu 176: data_hi
    sw   t1, 4(a1)             # tu 176: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_177:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_177
    li   t0, 0x0d1e2f40
    li   t1, 0x51627384
    sw   t0, 0(a1)             # tu 177: data_hi
    sw   t1, 4(a1)             # tu 177: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_178:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_178
    li   t0, 0x95a6b7c8
    li   t1, 0xd9eafb0c
    sw   t0, 0(a1)             # tu 178: data_hi
    sw   t1, 4(a1)             # tu 178: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_179:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_179
    li   t0, 0x1d2e3f50
    li   t1, 0x61728394
    sw   t0, 0(a1)             # tu 179: data_hi
    sw   t1, 4(a1)             # tu 179: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_180:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_180
    li   t0, 0xa5b6c7d8
    li   t1, 0xe9fa0b1c
    sw   t0, 0(a1)             # tu 180: data_hi
    sw   t1, 4(a1)             # tu 180: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_181:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_181
    li   t0, 0x2d3e4f60
    li   t1, 0x718293a4
    sw   t0, 0(a1)             # tu 181: data_hi
    sw   t1, 4(a1)             # tu 181: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_182:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_182
    li   t0, 0xb5c6d7e8
    li   t1, 0xf90a1b2c
    sw   t0, 0(a1)             # tu 182: data_hi
    sw   t1, 4(a1)             # tu 182: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_183:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_183
    li   t0, 0x3d4e5f70
    li   t1, 0x8192a3b4
    sw   t0, 0(a1)             # tu 183: data_hi
    sw   t1, 4(a1)             # tu 183: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_184:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_184
    li   t0, 0xa2b3c4d5
    li   t1, 0xe6f70819
    sw   t0, 0(a1)             # tu 184: data_hi
    sw   t1, 4(a1)             # tu 184: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_185:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_185
    li   t0, 0x2a3b4c5d
    li   t1, 0x6e7f90a1
    sw   t0, 0(a1)             # tu 185: data_hi
    sw   t1, 4(a1)             # tu 185: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_186:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_186
    li   t0, 0xb2c3d4e5
    li   t1, 0xf6071829
    sw   t0, 0(a1)             # tu 186: data_hi
    sw   t1, 4(a1)             # tu 186: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_187:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_187
    li   t0, 0x3a4b5c6d
    li   t1, 0x7e8fa0b1
    sw   t0, 0(a1)             # tu 187: data_hi
    sw   t1, 4(a1)             # tu 187: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_188:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_188
    li   t0, 0xc2d3e4f5
    li   t1, 0x06172839
    sw   t0, 0(a1)             # tu 188: data_hi
    sw   t1, 4(a1)             # tu 188: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_189:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_189
    li   t0, 0x4a5b6c7d
    li   t1, 0x8e9fb0c1
    sw   t0, 0(a1)             # tu 189: data_hi
    sw   t1, 4(a1)             # tu 189: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_190:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_190
    li   t0, 0xd2e3f405
    li   t1, 0x16273849
    sw   t0, 0(a1)             # tu 190: data_hi
    sw   t1, 4(a1)             # tu 190: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_191:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_191
    li   t0, 0x5a6b7c8d
    li   t1, 0x9eafc0d1
    sw   t0, 0(a1)             # tu 191: data_hi
    sw   t1, 4(a1)             # tu 191: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_192:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_192
    li   t0, 0xbfd0e1f2
    li   t1, 0x03142536
    sw   t0, 0(a1)             # tu 192: data_hi
    sw   t1, 4(a1)             # tu 192: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_193:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_193
    li   t0, 0x4758697a
    li   t1, 0x8b9cadbe
    sw   t0, 0(a1)             # tu 193: data_hi
    sw   t1, 4(a1)             # tu 193: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_194:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_194
    li   t0, 0xcfe0f102
    li   t1, 0x13243546
    sw   t0, 0(a1)             # tu 194: data_hi
    sw   t1, 4(a1)             # tu 194: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_195:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_195
    li   t0, 0x5768798a
    li   t1, 0x9bacbdce
    sw   t0, 0(a1)             # tu 195: data_hi
    sw   t1, 4(a1)             # tu 195: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_196:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_196
    li   t0, 0xdff00112
    li   t1, 0x23344556
    sw   t0, 0(a1)             # tu 196: data_hi
    sw   t1, 4(a1)             # tu 196: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_197:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_197
    li   t0, 0x6778899a
    li   t1, 0xabbccdde
    sw   t0, 0(a1)             # tu 197: data_hi
    sw   t1, 4(a1)             # tu 197: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_198:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_198
    li   t0, 0xef001122
    li   t1, 0x33445566
    sw   t0, 0(a1)             # tu 198: data_hi
    sw   t1, 4(a1)             # tu 198: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_199:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_199
    li   t0, 0x778899aa
    li   t1, 0xbbccddee
    sw   t0, 0(a1)             # tu 199: data_hi
    sw   t1, 4(a1)             # tu 199: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_200:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_200
    li   t0, 0xdcedfe0f
    li   t1, 0x20314253
    sw   t0, 0(a1)             # tu 200: data_hi
    sw   t1, 4(a1)             # tu 200: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_201:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_201
    li   t0, 0x64758697
    li   t1, 0xa8b9cadb
    sw   t0, 0(a1)             # tu 201: data_hi
    sw   t1, 4(a1)             # tu 201: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_202:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_202
    li   t0, 0xecfd0e1f
    li   t1, 0x30415263
    sw   t0, 0(a1)             # tu 202: data_hi
    sw   t1, 4(a1)             # tu 202: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_203:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_203
    li   t0, 0x748596a7
    li   t1, 0xb8c9daeb
    sw   t0, 0(a1)             # tu 203: data_hi
    sw   t1, 4(a1)             # tu 203: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_204:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_204
    li   t0, 0xfc0d1e2f
    li   t1, 0x40516273
    sw   t0, 0(a1)             # tu 204: data_hi
    sw   t1, 4(a1)             # tu 204: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_205:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_205
    li   t0, 0x8495a6b7
    li   t1, 0xc8d9eafb
    sw   t0, 0(a1)             # tu 205: data_hi
    sw   t1, 4(a1)             # tu 205: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_206:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_206
    li   t0, 0x0c1d2e3f
    li   t1, 0x50617283
    sw   t0, 0(a1)             # tu 206: data_hi
    sw   t1, 4(a1)             # tu 206: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_207:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_207
    li   t0, 0x94a5b6c7
    li   t1, 0xd8e9fa0b
    sw   t0, 0(a1)             # tu 207: data_hi
    sw   t1, 4(a1)             # tu 207: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_208:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_208
    li   t0, 0xf90a1b2c
    li   t1, 0x3d4e5f70
    sw   t0, 0(a1)             # tu 208: data_hi
    sw   t1, 4(a1)             # tu 208: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_209:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_209
    li   t0, 0x8192a3b4
    li   t1, 0xc5d6e7f8
    sw   t0, 0(a1)             # tu 209: data_hi
    sw   t1, 4(a1)             # tu 209: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_210:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_210
    li   t0, 0x091a2b3c
    li   t1, 0x4d5e6f80
    sw   t0, 0(a1)             # tu 210: data_hi
    sw   t1, 4(a1)             # tu 210: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_211:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_211
    li   t0, 0x91a2b3c4
    li   t1, 0xd5e6f708
    sw   t0, 0(a1)             # tu 211: data_hi
    sw   t1, 4(a1)             # tu 211: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_212:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_212
    li   t0, 0x192a3b4c
    li   t1, 0x5d6e7f90
    sw   t0, 0(a1)             # tu 212: data_hi
    sw   t1, 4(a1)             # tu 212: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_213:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_213
    li   t0, 0xa1b2c3d4
    li   t1, 0xe5f60718
    sw   t0, 0(a1)             # tu 213: data_hi
    sw   t1, 4(a1)             # tu 213: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_214:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_214
    li   t0, 0x293a4b5c
    li   t1, 0x6d7e8fa0
    sw   t0, 0(a1)             # tu 214: data_hi
    sw   t1, 4(a1)             # tu 214: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_215:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_215
    li   t0, 0xb1c2d3e4
    li   t1, 0xf5061728
    sw   t0, 0(a1)             # tu 215: data_hi
    sw   t1, 4(a1)             # tu 215: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_216:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_216
    li   t0, 0x16273849
    li   t1, 0x5a6b7c8d
    sw   t0, 0(a1)             # tu 216: data_hi
    sw   t1, 4(a1)             # tu 216: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_217:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_217
    li   t0, 0x9eafc0d1
    li   t1, 0xe2f30415
    sw   t0, 0(a1)             # tu 217: data_hi
    sw   t1, 4(a1)             # tu 217: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_218:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_218
    li   t0, 0x26374859
    li   t1, 0x6a7b8c9d
    sw   t0, 0(a1)             # tu 218: data_hi
    sw   t1, 4(a1)             # tu 218: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_219:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_219
    li   t0, 0xaebfd0e1
    li   t1, 0xf2031425
    sw   t0, 0(a1)             # tu 219: data_hi
    sw   t1, 4(a1)             # tu 219: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_220:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_220
    li   t0, 0x36475869
    li   t1, 0x7a8b9cad
    sw   t0, 0(a1)             # tu 220: data_hi
    sw   t1, 4(a1)             # tu 220: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_221:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_221
    li   t0, 0xbecfe0f1
    li   t1, 0x02132435
    sw   t0, 0(a1)             # tu 221: data_hi
    sw   t1, 4(a1)             # tu 221: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_222:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_222
    li   t0, 0x46576879
    li   t1, 0x8a9bacbd
    sw   t0, 0(a1)             # tu 222: data_hi
    sw   t1, 4(a1)             # tu 222: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_223:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_223
    li   t0, 0xcedff001
    li   t1, 0x12233445
    sw   t0, 0(a1)             # tu 223: data_hi
    sw   t1, 4(a1)             # tu 223: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_224:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_224
    li   t0, 0x33445566
    li   t1, 0x778899aa
    sw   t0, 0(a1)             # tu 224: data_hi
    sw   t1, 4(a1)             # tu 224: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_225:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_225
    li   t0, 0xbbccddee
    li   t1, 0xff102132
    sw   t0, 0(a1)             # tu 225: data_hi
    sw   t1, 4(a1)             # tu 225: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_226:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_226
    li   t0, 0x43546576
    li   t1, 0x8798a9ba
    sw   t0, 0(a1)             # tu 226: data_hi
    sw   t1, 4(a1)             # tu 226: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_227:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_227
    li   t0, 0xcbdcedfe
    li   t1, 0x0f203142
    sw   t0, 0(a1)             # tu 227: data_hi
    sw   t1, 4(a1)             # tu 227: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_228:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_228
    li   t0, 0x53647586
    li   t1, 0x97a8b9ca
    sw   t0, 0(a1)             # tu 228: data_hi
    sw   t1, 4(a1)             # tu 228: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_229:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_229
    li   t0, 0xdbecfd0e
    li   t1, 0x1f304152
    sw   t0, 0(a1)             # tu 229: data_hi
    sw   t1, 4(a1)             # tu 229: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_230:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_230
    li   t0, 0x63748596
    li   t1, 0xa7b8c9da
    sw   t0, 0(a1)             # tu 230: data_hi
    sw   t1, 4(a1)             # tu 230: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_231:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_231
    li   t0, 0xebfc0d1e
    li   t1, 0x2f405162
    sw   t0, 0(a1)             # tu 231: data_hi
    sw   t1, 4(a1)             # tu 231: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_232:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_232
    li   t0, 0x50617283
    li   t1, 0x94a5b6c7
    sw   t0, 0(a1)             # tu 232: data_hi
    sw   t1, 4(a1)             # tu 232: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_233:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_233
    li   t0, 0xd8e9fa0b
    li   t1, 0x1c2d3e4f
    sw   t0, 0(a1)             # tu 233: data_hi
    sw   t1, 4(a1)             # tu 233: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_234:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_234
    li   t0, 0x60718293
    li   t1, 0xa4b5c6d7
    sw   t0, 0(a1)             # tu 234: data_hi
    sw   t1, 4(a1)             # tu 234: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_235:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_235
    li   t0, 0xe8f90a1b
    li   t1, 0x2c3d4e5f
    sw   t0, 0(a1)             # tu 235: data_hi
    sw   t1, 4(a1)             # tu 235: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_236:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_236
    li   t0, 0x708192a3
    li   t1, 0xb4c5d6e7
    sw   t0, 0(a1)             # tu 236: data_hi
    sw   t1, 4(a1)             # tu 236: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_237:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_237
    li   t0, 0xf8091a2b
    li   t1, 0x3c4d5e6f
    sw   t0, 0(a1)             # tu 237: data_hi
    sw   t1, 4(a1)             # tu 237: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_238:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_238
    li   t0, 0x8091a2b3
    li   t1, 0xc4d5e6f7
    sw   t0, 0(a1)             # tu 238: data_hi
    sw   t1, 4(a1)             # tu 238: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_239:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_239
    li   t0, 0x08192a3b
    li   t1, 0x4c5d6e7f
    sw   t0, 0(a1)             # tu 239: data_hi
    sw   t1, 4(a1)             # tu 239: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_240:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_240
    li   t0, 0x6d7e8fa0
    li   t1, 0xb1c2d3e4
    sw   t0, 0(a1)             # tu 240: data_hi
    sw   t1, 4(a1)             # tu 240: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_241:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_241
    li   t0, 0xf5061728
    li   t1, 0x394a5b6c
    sw   t0, 0(a1)             # tu 241: data_hi
    sw   t1, 4(a1)             # tu 241: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_242:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_242
    li   t0, 0x7d8e9fb0
    li   t1, 0xc1d2e3f4
    sw   t0, 0(a1)             # tu 242: data_hi
    sw   t1, 4(a1)             # tu 242: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_243:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_243
    li   t0, 0x05162738
    li   t1, 0x495a6b7c
    sw   t0, 0(a1)             # tu 243: data_hi
    sw   t1, 4(a1)             # tu 243: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_244:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_244
    li   t0, 0x8d9eafc0
    li   t1, 0xd1e2f304
    sw   t0, 0(a1)             # tu 244: data_hi
    sw   t1, 4(a1)             # tu 244: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_245:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_245
    li   t0, 0x15263748
    li   t1, 0x596a7b8c
    sw   t0, 0(a1)             # tu 245: data_hi
    sw   t1, 4(a1)             # tu 245: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_246:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_246
    li   t0, 0x9daebfd0
    li   t1, 0xe1f20314
    sw   t0, 0(a1)             # tu 246: data_hi
    sw   t1, 4(a1)             # tu 246: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_247:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_247
    li   t0, 0x25364758
    li   t1, 0x697a8b9c
    sw   t0, 0(a1)             # tu 247: data_hi
    sw   t1, 4(a1)             # tu 247: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_248:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_248
    li   t0, 0x8a9bacbd
    li   t1, 0xcedff001
    sw   t0, 0(a1)             # tu 248: data_hi
    sw   t1, 4(a1)             # tu 248: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_249:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_249
    li   t0, 0x12233445
    li   t1, 0x56677889
    sw   t0, 0(a1)             # tu 249: data_hi
    sw   t1, 4(a1)             # tu 249: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_250:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_250
    li   t0, 0x9aabbccd
    li   t1, 0xdeef0011
    sw   t0, 0(a1)             # tu 250: data_hi
    sw   t1, 4(a1)             # tu 250: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_251:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_251
    li   t0, 0x22334455
    li   t1, 0x66778899
    sw   t0, 0(a1)             # tu 251: data_hi
    sw   t1, 4(a1)             # tu 251: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_252:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_252
    li   t0, 0xaabbccdd
    li   t1, 0xeeff1021
    sw   t0, 0(a1)             # tu 252: data_hi
    sw   t1, 4(a1)             # tu 252: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_253:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_253
    li   t0, 0x32435465
    li   t1, 0x768798a9
    sw   t0, 0(a1)             # tu 253: data_hi
    sw   t1, 4(a1)             # tu 253: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_254:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_254
    li   t0, 0xbacbdced
    li   t1, 0xfe0f2031
    sw   t0, 0(a1)             # tu 254: data_hi
    sw   t1, 4(a1)             # tu 254: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_255:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_255
    li   t0, 0x42536475
    li   t1, 0x8697a8b9
    sw   t0, 0(a1)             # tu 255: data_hi
    sw   t1, 4(a1)             # tu 255: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_256:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_256
    li   t0, 0xa7b8c9da
    li   t1, 0xebfc0d1e
    sw   t0, 0(a1)             # tu 256: data_hi
    sw   t1, 4(a1)             # tu 256: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_257:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_257
    li   t0, 0x2f405162
    li   t1, 0x738495a6
    sw   t0, 0(a1)             # tu 257: data_hi
    sw   t1, 4(a1)             # tu 257: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_258:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_258
    li   t0, 0xb7c8d9ea
    li   t1, 0xfb0c1d2e
    sw   t0, 0(a1)             # tu 258: data_hi
    sw   t1, 4(a1)             # tu 258: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_259:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_259
    li   t0, 0x3f506172
    li   t1, 0x8394a5b6
    sw   t0, 0(a1)             # tu 259: data_hi
    sw   t1, 4(a1)             # tu 259: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_260:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_260
    li   t0, 0xc7d8e9fa
    li   t1, 0x0b1c2d3e
    sw   t0, 0(a1)             # tu 260: data_hi
    sw   t1, 4(a1)             # tu 260: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_261:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_261
    li   t0, 0x4f607182
    li   t1, 0x93a4b5c6
    sw   t0, 0(a1)             # tu 261: data_hi
    sw   t1, 4(a1)             # tu 261: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_262:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_262
    li   t0, 0xd7e8f90a
    li   t1, 0x1b2c3d4e
    sw   t0, 0(a1)             # tu 262: data_hi
    sw   t1, 4(a1)             # tu 262: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_263:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_263
    li   t0, 0x5f708192
    li   t1, 0xa3b4c5d6
    sw   t0, 0(a1)             # tu 263: data_hi
    sw   t1, 4(a1)             # tu 263: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_264:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_264
    li   t0, 0xc4d5e6f7
    li   t1, 0x08192a3b
    sw   t0, 0(a1)             # tu 264: data_hi
    sw   t1, 4(a1)             # tu 264: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_265:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_265
    li   t0, 0x4c5d6e7f
    li   t1, 0x90a1b2c3
    sw   t0, 0(a1)             # tu 265: data_hi
    sw   t1, 4(a1)             # tu 265: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_266:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_266
    li   t0, 0xd4e5f607
    li   t1, 0x18293a4b
    sw   t0, 0(a1)             # tu 266: data_hi
    sw   t1, 4(a1)             # tu 266: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_267:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_267
    li   t0, 0x5c6d7e8f
    li   t1, 0xa0b1c2d3
    sw   t0, 0(a1)             # tu 267: data_hi
    sw   t1, 4(a1)             # tu 267: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_268:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_268
    li   t0, 0xe4f50617
    li   t1, 0x28394a5b
    sw   t0, 0(a1)             # tu 268: data_hi
    sw   t1, 4(a1)             # tu 268: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_269:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_269
    li   t0, 0x6c7d8e9f
    li   t1, 0xb0c1d2e3
    sw   t0, 0(a1)             # tu 269: data_hi
    sw   t1, 4(a1)             # tu 269: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_270:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_270
    li   t0, 0xf4051627
    li   t1, 0x38495a6b
    sw   t0, 0(a1)             # tu 270: data_hi
    sw   t1, 4(a1)             # tu 270: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_271:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_271
    li   t0, 0x7c8d9eaf
    li   t1, 0xc0d1e2f3
    sw   t0, 0(a1)             # tu 271: data_hi
    sw   t1, 4(a1)             # tu 271: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_272:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_272
    li   t0, 0xe1f20314
    li   t1, 0x25364758
    sw   t0, 0(a1)             # tu 272: data_hi
    sw   t1, 4(a1)             # tu 272: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_273:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_273
    li   t0, 0x697a8b9c
    li   t1, 0xadbecfe0
    sw   t0, 0(a1)             # tu 273: data_hi
    sw   t1, 4(a1)             # tu 273: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_274:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_274
    li   t0, 0xf1021324
    li   t1, 0x35465768
    sw   t0, 0(a1)             # tu 274: data_hi
    sw   t1, 4(a1)             # tu 274: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_275:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_275
    li   t0, 0x798a9bac
    li   t1, 0xbdcedff0
    sw   t0, 0(a1)             # tu 275: data_hi
    sw   t1, 4(a1)             # tu 275: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_276:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_276
    li   t0, 0x01122334
    li   t1, 0x45566778
    sw   t0, 0(a1)             # tu 276: data_hi
    sw   t1, 4(a1)             # tu 276: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_277:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_277
    li   t0, 0x899aabbc
    li   t1, 0xcddeef00
    sw   t0, 0(a1)             # tu 277: data_hi
    sw   t1, 4(a1)             # tu 277: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_278:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_278
    li   t0, 0x11223344
    li   t1, 0x55667788
    sw   t0, 0(a1)             # tu 278: data_hi
    sw   t1, 4(a1)             # tu 278: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_279:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_279
    li   t0, 0x99aabbcc
    li   t1, 0xddeeff10
    sw   t0, 0(a1)             # tu 279: data_hi
    sw   t1, 4(a1)             # tu 279: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_280:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_280
    li   t0, 0xfe0f2031
    li   t1, 0x42536475
    sw   t0, 0(a1)             # tu 280: data_hi
    sw   t1, 4(a1)             # tu 280: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_281:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_281
    li   t0, 0x8697a8b9
    li   t1, 0xcadbecfd
    sw   t0, 0(a1)             # tu 281: data_hi
    sw   t1, 4(a1)             # tu 281: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_282:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_282
    li   t0, 0x0e1f3041
    li   t1, 0x52637485
    sw   t0, 0(a1)             # tu 282: data_hi
    sw   t1, 4(a1)             # tu 282: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_283:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_283
    li   t0, 0x96a7b8c9
    li   t1, 0xdaebfc0d
    sw   t0, 0(a1)             # tu 283: data_hi
    sw   t1, 4(a1)             # tu 283: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_284:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_284
    li   t0, 0x1e2f4051
    li   t1, 0x62738495
    sw   t0, 0(a1)             # tu 284: data_hi
    sw   t1, 4(a1)             # tu 284: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_285:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_285
    li   t0, 0xa6b7c8d9
    li   t1, 0xeafb0c1d
    sw   t0, 0(a1)             # tu 285: data_hi
    sw   t1, 4(a1)             # tu 285: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_286:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_286
    li   t0, 0x2e3f5061
    li   t1, 0x728394a5
    sw   t0, 0(a1)             # tu 286: data_hi
    sw   t1, 4(a1)             # tu 286: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_287:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_287
    li   t0, 0xb6c7d8e9
    li   t1, 0xfa0b1c2d
    sw   t0, 0(a1)             # tu 287: data_hi
    sw   t1, 4(a1)             # tu 287: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_288:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_288
    li   t0, 0x1b2c3d4e
    li   t1, 0x5f708192
    sw   t0, 0(a1)             # tu 288: data_hi
    sw   t1, 4(a1)             # tu 288: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_289:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_289
    li   t0, 0xa3b4c5d6
    li   t1, 0xe7f8091a
    sw   t0, 0(a1)             # tu 289: data_hi
    sw   t1, 4(a1)             # tu 289: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_290:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_290
    li   t0, 0x2b3c4d5e
    li   t1, 0x6f8091a2
    sw   t0, 0(a1)             # tu 290: data_hi
    sw   t1, 4(a1)             # tu 290: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_291:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_291
    li   t0, 0xb3c4d5e6
    li   t1, 0xf708192a
    sw   t0, 0(a1)             # tu 291: data_hi
    sw   t1, 4(a1)             # tu 291: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_292:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_292
    li   t0, 0x3b4c5d6e
    li   t1, 0x7f90a1b2
    sw   t0, 0(a1)             # tu 292: data_hi
    sw   t1, 4(a1)             # tu 292: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_293:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_293
    li   t0, 0xc3d4e5f6
    li   t1, 0x0718293a
    sw   t0, 0(a1)             # tu 293: data_hi
    sw   t1, 4(a1)             # tu 293: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_294:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_294
    li   t0, 0x4b5c6d7e
    li   t1, 0x8fa0b1c2
    sw   t0, 0(a1)             # tu 294: data_hi
    sw   t1, 4(a1)             # tu 294: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_295:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_295
    li   t0, 0xd3e4f506
    li   t1, 0x1728394a
    sw   t0, 0(a1)             # tu 295: data_hi
    sw   t1, 4(a1)             # tu 295: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_296:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_296
    li   t0, 0x38495a6b
    li   t1, 0x7c8d9eaf
    sw   t0, 0(a1)             # tu 296: data_hi
    sw   t1, 4(a1)             # tu 296: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_297:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_297
    li   t0, 0xc0d1e2f3
    li   t1, 0x04152637
    sw   t0, 0(a1)             # tu 297: data_hi
    sw   t1, 4(a1)             # tu 297: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_298:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_298
    li   t0, 0x48596a7b
    li   t1, 0x8c9daebf
    sw   t0, 0(a1)             # tu 298: data_hi
    sw   t1, 4(a1)             # tu 298: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_299:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_299
    li   t0, 0xd0e1f203
    li   t1, 0x14253647
    sw   t0, 0(a1)             # tu 299: data_hi
    sw   t1, 4(a1)             # tu 299: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_300:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_300
    li   t0, 0x58697a8b
    li   t1, 0x9cadbecf
    sw   t0, 0(a1)             # tu 300: data_hi
    sw   t1, 4(a1)             # tu 300: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_301:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_301
    li   t0, 0xe0f10213
    li   t1, 0x24354657
    sw   t0, 0(a1)             # tu 301: data_hi
    sw   t1, 4(a1)             # tu 301: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_302:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_302
    li   t0, 0x68798a9b
    li   t1, 0xacbdcedf
    sw   t0, 0(a1)             # tu 302: data_hi
    sw   t1, 4(a1)             # tu 302: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_303:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_303
    li   t0, 0xf0011223
    li   t1, 0x34455667
    sw   t0, 0(a1)             # tu 303: data_hi
    sw   t1, 4(a1)             # tu 303: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_304:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_304
    li   t0, 0x55667788
    li   t1, 0x99aabbcc
    sw   t0, 0(a1)             # tu 304: data_hi
    sw   t1, 4(a1)             # tu 304: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_305:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_305
    li   t0, 0xddeeff10
    li   t1, 0x21324354
    sw   t0, 0(a1)             # tu 305: data_hi
    sw   t1, 4(a1)             # tu 305: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_306:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_306
    li   t0, 0x65768798
    li   t1, 0xa9bacbdc
    sw   t0, 0(a1)             # tu 306: data_hi
    sw   t1, 4(a1)             # tu 306: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_307:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_307
    li   t0, 0xedfe0f20
    li   t1, 0x31425364
    sw   t0, 0(a1)             # tu 307: data_hi
    sw   t1, 4(a1)             # tu 307: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_308:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_308
    li   t0, 0x758697a8
    li   t1, 0xb9cadbec
    sw   t0, 0(a1)             # tu 308: data_hi
    sw   t1, 4(a1)             # tu 308: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_309:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_309
    li   t0, 0xfd0e1f30
    li   t1, 0x41526374
    sw   t0, 0(a1)             # tu 309: data_hi
    sw   t1, 4(a1)             # tu 309: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_310:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_310
    li   t0, 0x8596a7b8
    li   t1, 0xc9daebfc
    sw   t0, 0(a1)             # tu 310: data_hi
    sw   t1, 4(a1)             # tu 310: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_311:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_311
    li   t0, 0x0d1e2f40
    li   t1, 0x51627384
    sw   t0, 0(a1)             # tu 311: data_hi
    sw   t1, 4(a1)             # tu 311: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_312:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_312
    li   t0, 0x728394a5
    li   t1, 0xb6c7d8e9
    sw   t0, 0(a1)             # tu 312: data_hi
    sw   t1, 4(a1)             # tu 312: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_313:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_313
    li   t0, 0xfa0b1c2d
    li   t1, 0x3e4f6071
    sw   t0, 0(a1)             # tu 313: data_hi
    sw   t1, 4(a1)             # tu 313: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_314:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_314
    li   t0, 0x8293a4b5
    li   t1, 0xc6d7e8f9
    sw   t0, 0(a1)             # tu 314: data_hi
    sw   t1, 4(a1)             # tu 314: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_315:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_315
    li   t0, 0x0a1b2c3d
    li   t1, 0x4e5f7081
    sw   t0, 0(a1)             # tu 315: data_hi
    sw   t1, 4(a1)             # tu 315: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_316:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_316
    li   t0, 0x92a3b4c5
    li   t1, 0xd6e7f809
    sw   t0, 0(a1)             # tu 316: data_hi
    sw   t1, 4(a1)             # tu 316: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_317:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_317
    li   t0, 0x1a2b3c4d
    li   t1, 0x5e6f8091
    sw   t0, 0(a1)             # tu 317: data_hi
    sw   t1, 4(a1)             # tu 317: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_318:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_318
    li   t0, 0xa2b3c4d5
    li   t1, 0xe6f70819
    sw   t0, 0(a1)             # tu 318: data_hi
    sw   t1, 4(a1)             # tu 318: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_319:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_319
    li   t0, 0x2a3b4c5d
    li   t1, 0x6e7f90a1
    sw   t0, 0(a1)             # tu 319: data_hi
    sw   t1, 4(a1)             # tu 319: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_320:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_320
    li   t0, 0x8fa0b1c2
    li   t1, 0xd3e4f506
    sw   t0, 0(a1)             # tu 320: data_hi
    sw   t1, 4(a1)             # tu 320: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_321:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_321
    li   t0, 0x1728394a
    li   t1, 0x5b6c7d8e
    sw   t0, 0(a1)             # tu 321: data_hi
    sw   t1, 4(a1)             # tu 321: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_322:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_322
    li   t0, 0x9fb0c1d2
    li   t1, 0xe3f40516
    sw   t0, 0(a1)             # tu 322: data_hi
    sw   t1, 4(a1)             # tu 322: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_323:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_323
    li   t0, 0x2738495a
    li   t1, 0x6b7c8d9e
    sw   t0, 0(a1)             # tu 323: data_hi
    sw   t1, 4(a1)             # tu 323: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_324:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_324
    li   t0, 0xafc0d1e2
    li   t1, 0xf3041526
    sw   t0, 0(a1)             # tu 324: data_hi
    sw   t1, 4(a1)             # tu 324: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_325:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_325
    li   t0, 0x3748596a
    li   t1, 0x7b8c9dae
    sw   t0, 0(a1)             # tu 325: data_hi
    sw   t1, 4(a1)             # tu 325: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_326:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_326
    li   t0, 0xbfd0e1f2
    li   t1, 0x03142536
    sw   t0, 0(a1)             # tu 326: data_hi
    sw   t1, 4(a1)             # tu 326: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_327:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_327
    li   t0, 0x4758697a
    li   t1, 0x8b9cadbe
    sw   t0, 0(a1)             # tu 327: data_hi
    sw   t1, 4(a1)             # tu 327: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_328:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_328
    li   t0, 0xacbdcedf
    li   t1, 0xf0011223
    sw   t0, 0(a1)             # tu 328: data_hi
    sw   t1, 4(a1)             # tu 328: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_329:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_329
    li   t0, 0x34455667
    li   t1, 0x78899aab
    sw   t0, 0(a1)             # tu 329: data_hi
    sw   t1, 4(a1)             # tu 329: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_330:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_330
    li   t0, 0xbccddeef
    li   t1, 0x00112233
    sw   t0, 0(a1)             # tu 330: data_hi
    sw   t1, 4(a1)             # tu 330: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_331:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_331
    li   t0, 0x44556677
    li   t1, 0x8899aabb
    sw   t0, 0(a1)             # tu 331: data_hi
    sw   t1, 4(a1)             # tu 331: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_332:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_332
    li   t0, 0xccddeeff
    li   t1, 0x10213243
    sw   t0, 0(a1)             # tu 332: data_hi
    sw   t1, 4(a1)             # tu 332: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_333:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_333
    li   t0, 0x54657687
    li   t1, 0x98a9bacb
    sw   t0, 0(a1)             # tu 333: data_hi
    sw   t1, 4(a1)             # tu 333: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_334:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_334
    li   t0, 0xdcedfe0f
    li   t1, 0x20314253
    sw   t0, 0(a1)             # tu 334: data_hi
    sw   t1, 4(a1)             # tu 334: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_335:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_335
    li   t0, 0x64758697
    li   t1, 0xa8b9cadb
    sw   t0, 0(a1)             # tu 335: data_hi
    sw   t1, 4(a1)             # tu 335: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_336:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_336
    li   t0, 0xc9daebfc
    li   t1, 0x0d1e2f40
    sw   t0, 0(a1)             # tu 336: data_hi
    sw   t1, 4(a1)             # tu 336: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_337:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_337
    li   t0, 0x51627384
    li   t1, 0x95a6b7c8
    sw   t0, 0(a1)             # tu 337: data_hi
    sw   t1, 4(a1)             # tu 337: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_338:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_338
    li   t0, 0xd9eafb0c
    li   t1, 0x1d2e3f50
    sw   t0, 0(a1)             # tu 338: data_hi
    sw   t1, 4(a1)             # tu 338: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_339:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_339
    li   t0, 0x61728394
    li   t1, 0xa5b6c7d8
    sw   t0, 0(a1)             # tu 339: data_hi
    sw   t1, 4(a1)             # tu 339: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_340:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_340
    li   t0, 0xe9fa0b1c
    li   t1, 0x2d3e4f60
    sw   t0, 0(a1)             # tu 340: data_hi
    sw   t1, 4(a1)             # tu 340: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_341:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_341
    li   t0, 0x718293a4
    li   t1, 0xb5c6d7e8
    sw   t0, 0(a1)             # tu 341: data_hi
    sw   t1, 4(a1)             # tu 341: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_342:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_342
    li   t0, 0xf90a1b2c
    li   t1, 0x3d4e5f70
    sw   t0, 0(a1)             # tu 342: data_hi
    sw   t1, 4(a1)             # tu 342: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_343:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_343
    li   t0, 0x8192a3b4
    li   t1, 0xc5d6e7f8
    sw   t0, 0(a1)             # tu 343: data_hi
    sw   t1, 4(a1)             # tu 343: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_344:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_344
    li   t0, 0xe6f70819
    li   t1, 0x2a3b4c5d
    sw   t0, 0(a1)             # tu 344: data_hi
    sw   t1, 4(a1)             # tu 344: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_345:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_345
    li   t0, 0x6e7f90a1
    li   t1, 0xb2c3d4e5
    sw   t0, 0(a1)             # tu 345: data_hi
    sw   t1, 4(a1)             # tu 345: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_346:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_346
    li   t0, 0xf6071829
    li   t1, 0x3a4b5c6d
    sw   t0, 0(a1)             # tu 346: data_hi
    sw   t1, 4(a1)             # tu 346: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_347:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_347
    li   t0, 0x7e8fa0b1
    li   t1, 0xc2d3e4f5
    sw   t0, 0(a1)             # tu 347: data_hi
    sw   t1, 4(a1)             # tu 347: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_348:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_348
    li   t0, 0x06172839
    li   t1, 0x4a5b6c7d
    sw   t0, 0(a1)             # tu 348: data_hi
    sw   t1, 4(a1)             # tu 348: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_349:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_349
    li   t0, 0x8e9fb0c1
    li   t1, 0xd2e3f405
    sw   t0, 0(a1)             # tu 349: data_hi
    sw   t1, 4(a1)             # tu 349: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_350:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_350
    li   t0, 0x16273849
    li   t1, 0x5a6b7c8d
    sw   t0, 0(a1)             # tu 350: data_hi
    sw   t1, 4(a1)             # tu 350: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_351:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_351
    li   t0, 0x9eafc0d1
    li   t1, 0xe2f30415
    sw   t0, 0(a1)             # tu 351: data_hi
    sw   t1, 4(a1)             # tu 351: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_352:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_352
    li   t0, 0x03142536
    li   t1, 0x4758697a
    sw   t0, 0(a1)             # tu 352: data_hi
    sw   t1, 4(a1)             # tu 352: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_353:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_353
    li   t0, 0x8b9cadbe
    li   t1, 0xcfe0f102
    sw   t0, 0(a1)             # tu 353: data_hi
    sw   t1, 4(a1)             # tu 353: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_354:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_354
    li   t0, 0x13243546
    li   t1, 0x5768798a
    sw   t0, 0(a1)             # tu 354: data_hi
    sw   t1, 4(a1)             # tu 354: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_355:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_355
    li   t0, 0x9bacbdce
    li   t1, 0xdff00112
    sw   t0, 0(a1)             # tu 355: data_hi
    sw   t1, 4(a1)             # tu 355: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_356:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_356
    li   t0, 0x23344556
    li   t1, 0x6778899a
    sw   t0, 0(a1)             # tu 356: data_hi
    sw   t1, 4(a1)             # tu 356: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_357:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_357
    li   t0, 0xabbccdde
    li   t1, 0xef001122
    sw   t0, 0(a1)             # tu 357: data_hi
    sw   t1, 4(a1)             # tu 357: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_358:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_358
    li   t0, 0x33445566
    li   t1, 0x778899aa
    sw   t0, 0(a1)             # tu 358: data_hi
    sw   t1, 4(a1)             # tu 358: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_359:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_359
    li   t0, 0xbbccddee
    li   t1, 0xff102132
    sw   t0, 0(a1)             # tu 359: data_hi
    sw   t1, 4(a1)             # tu 359: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_360:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_360
    li   t0, 0x20314253
    li   t1, 0x64758697
    sw   t0, 0(a1)             # tu 360: data_hi
    sw   t1, 4(a1)             # tu 360: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_361:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_361
    li   t0, 0xa8b9cadb
    li   t1, 0xecfd0e1f
    sw   t0, 0(a1)             # tu 361: data_hi
    sw   t1, 4(a1)             # tu 361: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_362:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_362
    li   t0, 0x30415263
    li   t1, 0x748596a7
    sw   t0, 0(a1)             # tu 362: data_hi
    sw   t1, 4(a1)             # tu 362: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_363:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_363
    li   t0, 0xb8c9daeb
    li   t1, 0xfc0d1e2f
    sw   t0, 0(a1)             # tu 363: data_hi
    sw   t1, 4(a1)             # tu 363: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_364:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_364
    li   t0, 0x40516273
    li   t1, 0x8495a6b7
    sw   t0, 0(a1)             # tu 364: data_hi
    sw   t1, 4(a1)             # tu 364: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_365:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_365
    li   t0, 0xc8d9eafb
    li   t1, 0x0c1d2e3f
    sw   t0, 0(a1)             # tu 365: data_hi
    sw   t1, 4(a1)             # tu 365: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_366:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_366
    li   t0, 0x50617283
    li   t1, 0x94a5b6c7
    sw   t0, 0(a1)             # tu 366: data_hi
    sw   t1, 4(a1)             # tu 366: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_367:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_367
    li   t0, 0xd8e9fa0b
    li   t1, 0x1c2d3e4f
    sw   t0, 0(a1)             # tu 367: data_hi
    sw   t1, 4(a1)             # tu 367: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_368:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_368
    li   t0, 0x3d4e5f70
    li   t1, 0x8192a3b4
    sw   t0, 0(a1)             # tu 368: data_hi
    sw   t1, 4(a1)             # tu 368: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_369:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_369
    li   t0, 0xc5d6e7f8
    li   t1, 0x091a2b3c
    sw   t0, 0(a1)             # tu 369: data_hi
    sw   t1, 4(a1)             # tu 369: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_370:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_370
    li   t0, 0x4d5e6f80
    li   t1, 0x91a2b3c4
    sw   t0, 0(a1)             # tu 370: data_hi
    sw   t1, 4(a1)             # tu 370: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_371:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_371
    li   t0, 0xd5e6f708
    li   t1, 0x192a3b4c
    sw   t0, 0(a1)             # tu 371: data_hi
    sw   t1, 4(a1)             # tu 371: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_372:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_372
    li   t0, 0x5d6e7f90
    li   t1, 0xa1b2c3d4
    sw   t0, 0(a1)             # tu 372: data_hi
    sw   t1, 4(a1)             # tu 372: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_373:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_373
    li   t0, 0xe5f60718
    li   t1, 0x293a4b5c
    sw   t0, 0(a1)             # tu 373: data_hi
    sw   t1, 4(a1)             # tu 373: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_374:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_374
    li   t0, 0x6d7e8fa0
    li   t1, 0xb1c2d3e4
    sw   t0, 0(a1)             # tu 374: data_hi
    sw   t1, 4(a1)             # tu 374: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_375:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_375
    li   t0, 0xf5061728
    li   t1, 0x394a5b6c
    sw   t0, 0(a1)             # tu 375: data_hi
    sw   t1, 4(a1)             # tu 375: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_376:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_376
    li   t0, 0x5a6b7c8d
    li   t1, 0x9eafc0d1
    sw   t0, 0(a1)             # tu 376: data_hi
    sw   t1, 4(a1)             # tu 376: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_377:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_377
    li   t0, 0xe2f30415
    li   t1, 0x26374859
    sw   t0, 0(a1)             # tu 377: data_hi
    sw   t1, 4(a1)             # tu 377: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_378:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_378
    li   t0, 0x6a7b8c9d
    li   t1, 0xaebfd0e1
    sw   t0, 0(a1)             # tu 378: data_hi
    sw   t1, 4(a1)             # tu 378: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_379:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_379
    li   t0, 0xf2031425
    li   t1, 0x36475869
    sw   t0, 0(a1)             # tu 379: data_hi
    sw   t1, 4(a1)             # tu 379: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_380:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_380
    li   t0, 0x7a8b9cad
    li   t1, 0xbecfe0f1
    sw   t0, 0(a1)             # tu 380: data_hi
    sw   t1, 4(a1)             # tu 380: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_381:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_381
    li   t0, 0x02132435
    li   t1, 0x46576879
    sw   t0, 0(a1)             # tu 381: data_hi
    sw   t1, 4(a1)             # tu 381: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_382:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_382
    li   t0, 0x8a9bacbd
    li   t1, 0xcedff001
    sw   t0, 0(a1)             # tu 382: data_hi
    sw   t1, 4(a1)             # tu 382: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_383:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_383
    li   t0, 0x12233445
    li   t1, 0x56677889
    sw   t0, 0(a1)             # tu 383: data_hi
    sw   t1, 4(a1)             # tu 383: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_384:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_384
    li   t0, 0x778899aa
    li   t1, 0xbbccddee
    sw   t0, 0(a1)             # tu 384: data_hi
    sw   t1, 4(a1)             # tu 384: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_385:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_385
    li   t0, 0xff102132
    li   t1, 0x43546576
    sw   t0, 0(a1)             # tu 385: data_hi
    sw   t1, 4(a1)             # tu 385: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_386:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_386
    li   t0, 0x8798a9ba
    li   t1, 0xcbdcedfe
    sw   t0, 0(a1)             # tu 386: data_hi
    sw   t1, 4(a1)             # tu 386: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_387:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_387
    li   t0, 0x0f203142
    li   t1, 0x53647586
    sw   t0, 0(a1)             # tu 387: data_hi
    sw   t1, 4(a1)             # tu 387: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_388:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_388
    li   t0, 0x97a8b9ca
    li   t1, 0xdbecfd0e
    sw   t0, 0(a1)             # tu 388: data_hi
    sw   t1, 4(a1)             # tu 388: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_389:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_389
    li   t0, 0x1f304152
    li   t1, 0x63748596
    sw   t0, 0(a1)             # tu 389: data_hi
    sw   t1, 4(a1)             # tu 389: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_390:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_390
    li   t0, 0xa7b8c9da
    li   t1, 0xebfc0d1e
    sw   t0, 0(a1)             # tu 390: data_hi
    sw   t1, 4(a1)             # tu 390: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_391:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_391
    li   t0, 0x2f405162
    li   t1, 0x738495a6
    sw   t0, 0(a1)             # tu 391: data_hi
    sw   t1, 4(a1)             # tu 391: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_392:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_392
    li   t0, 0x94a5b6c7
    li   t1, 0xd8e9fa0b
    sw   t0, 0(a1)             # tu 392: data_hi
    sw   t1, 4(a1)             # tu 392: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_393:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_393
    li   t0, 0x1c2d3e4f
    li   t1, 0x60718293
    sw   t0, 0(a1)             # tu 393: data_hi
    sw   t1, 4(a1)             # tu 393: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_394:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_394
    li   t0, 0xa4b5c6d7
    li   t1, 0xe8f90a1b
    sw   t0, 0(a1)             # tu 394: data_hi
    sw   t1, 4(a1)             # tu 394: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_395:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_395
    li   t0, 0x2c3d4e5f
    li   t1, 0x708192a3
    sw   t0, 0(a1)             # tu 395: data_hi
    sw   t1, 4(a1)             # tu 395: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_396:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_396
    li   t0, 0xb4c5d6e7
    li   t1, 0xf8091a2b
    sw   t0, 0(a1)             # tu 396: data_hi
    sw   t1, 4(a1)             # tu 396: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_397:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_397
    li   t0, 0x3c4d5e6f
    li   t1, 0x8091a2b3
    sw   t0, 0(a1)             # tu 397: data_hi
    sw   t1, 4(a1)             # tu 397: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_398:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_398
    li   t0, 0xc4d5e6f7
    li   t1, 0x08192a3b
    sw   t0, 0(a1)             # tu 398: data_hi
    sw   t1, 4(a1)             # tu 398: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_399:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_399
    li   t0, 0x4c5d6e7f
    li   t1, 0x90a1b2c3
    sw   t0, 0(a1)             # tu 399: data_hi
    sw   t1, 4(a1)             # tu 399: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_400:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_400
    li   t0, 0xb1c2d3e4
    li   t1, 0xf5061728
    sw   t0, 0(a1)             # tu 400: data_hi
    sw   t1, 4(a1)             # tu 400: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_401:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_401
    li   t0, 0x394a5b6c
    li   t1, 0x7d8e9fb0
    sw   t0, 0(a1)             # tu 401: data_hi
    sw   t1, 4(a1)             # tu 401: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_402:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_402
    li   t0, 0xc1d2e3f4
    li   t1, 0x05162738
    sw   t0, 0(a1)             # tu 402: data_hi
    sw   t1, 4(a1)             # tu 402: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_403:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_403
    li   t0, 0x495a6b7c
    li   t1, 0x8d9eafc0
    sw   t0, 0(a1)             # tu 403: data_hi
    sw   t1, 4(a1)             # tu 403: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_404:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_404
    li   t0, 0xd1e2f304
    li   t1, 0x15263748
    sw   t0, 0(a1)             # tu 404: data_hi
    sw   t1, 4(a1)             # tu 404: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_405:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_405
    li   t0, 0x596a7b8c
    li   t1, 0x9daebfd0
    sw   t0, 0(a1)             # tu 405: data_hi
    sw   t1, 4(a1)             # tu 405: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_406:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_406
    li   t0, 0xe1f20314
    li   t1, 0x25364758
    sw   t0, 0(a1)             # tu 406: data_hi
    sw   t1, 4(a1)             # tu 406: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_407:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_407
    li   t0, 0x697a8b9c
    li   t1, 0xadbecfe0
    sw   t0, 0(a1)             # tu 407: data_hi
    sw   t1, 4(a1)             # tu 407: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_408:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_408
    li   t0, 0xcedff001
    li   t1, 0x12233445
    sw   t0, 0(a1)             # tu 408: data_hi
    sw   t1, 4(a1)             # tu 408: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_409:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_409
    li   t0, 0x56677889
    li   t1, 0x9aabbccd
    sw   t0, 0(a1)             # tu 409: data_hi
    sw   t1, 4(a1)             # tu 409: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_410:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_410
    li   t0, 0xdeef0011
    li   t1, 0x22334455
    sw   t0, 0(a1)             # tu 410: data_hi
    sw   t1, 4(a1)             # tu 410: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_411:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_411
    li   t0, 0x66778899
    li   t1, 0xaabbccdd
    sw   t0, 0(a1)             # tu 411: data_hi
    sw   t1, 4(a1)             # tu 411: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_412:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_412
    li   t0, 0xeeff1021
    li   t1, 0x32435465
    sw   t0, 0(a1)             # tu 412: data_hi
    sw   t1, 4(a1)             # tu 412: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_413:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_413
    li   t0, 0x768798a9
    li   t1, 0xbacbdced
    sw   t0, 0(a1)             # tu 413: data_hi
    sw   t1, 4(a1)             # tu 413: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_414:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_414
    li   t0, 0xfe0f2031
    li   t1, 0x42536475
    sw   t0, 0(a1)             # tu 414: data_hi
    sw   t1, 4(a1)             # tu 414: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_415:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_415
    li   t0, 0x8697a8b9
    li   t1, 0xcadbecfd
    sw   t0, 0(a1)             # tu 415: data_hi
    sw   t1, 4(a1)             # tu 415: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_416:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_416
    li   t0, 0xebfc0d1e
    li   t1, 0x2f405162
    sw   t0, 0(a1)             # tu 416: data_hi
    sw   t1, 4(a1)             # tu 416: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_417:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_417
    li   t0, 0x738495a6
    li   t1, 0xb7c8d9ea
    sw   t0, 0(a1)             # tu 417: data_hi
    sw   t1, 4(a1)             # tu 417: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_418:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_418
    li   t0, 0xfb0c1d2e
    li   t1, 0x3f506172
    sw   t0, 0(a1)             # tu 418: data_hi
    sw   t1, 4(a1)             # tu 418: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_419:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_419
    li   t0, 0x8394a5b6
    li   t1, 0xc7d8e9fa
    sw   t0, 0(a1)             # tu 419: data_hi
    sw   t1, 4(a1)             # tu 419: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_420:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_420
    li   t0, 0x0b1c2d3e
    li   t1, 0x4f607182
    sw   t0, 0(a1)             # tu 420: data_hi
    sw   t1, 4(a1)             # tu 420: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_421:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_421
    li   t0, 0x93a4b5c6
    li   t1, 0xd7e8f90a
    sw   t0, 0(a1)             # tu 421: data_hi
    sw   t1, 4(a1)             # tu 421: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_422:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_422
    li   t0, 0x1b2c3d4e
    li   t1, 0x5f708192
    sw   t0, 0(a1)             # tu 422: data_hi
    sw   t1, 4(a1)             # tu 422: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_423:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_423
    li   t0, 0xa3b4c5d6
    li   t1, 0xe7f8091a
    sw   t0, 0(a1)             # tu 423: data_hi
    sw   t1, 4(a1)             # tu 423: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_424:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_424
    li   t0, 0x08192a3b
    li   t1, 0x4c5d6e7f
    sw   t0, 0(a1)             # tu 424: data_hi
    sw   t1, 4(a1)             # tu 424: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_425:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_425
    li   t0, 0x90a1b2c3
    li   t1, 0xd4e5f607
    sw   t0, 0(a1)             # tu 425: data_hi
    sw   t1, 4(a1)             # tu 425: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_426:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_426
    li   t0, 0x18293a4b
    li   t1, 0x5c6d7e8f
    sw   t0, 0(a1)             # tu 426: data_hi
    sw   t1, 4(a1)             # tu 426: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_427:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_427
    li   t0, 0xa0b1c2d3
    li   t1, 0xe4f50617
    sw   t0, 0(a1)             # tu 427: data_hi
    sw   t1, 4(a1)             # tu 427: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_428:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_428
    li   t0, 0x28394a5b
    li   t1, 0x6c7d8e9f
    sw   t0, 0(a1)             # tu 428: data_hi
    sw   t1, 4(a1)             # tu 428: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_429:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_429
    li   t0, 0xb0c1d2e3
    li   t1, 0xf4051627
    sw   t0, 0(a1)             # tu 429: data_hi
    sw   t1, 4(a1)             # tu 429: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_430:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_430
    li   t0, 0x38495a6b
    li   t1, 0x7c8d9eaf
    sw   t0, 0(a1)             # tu 430: data_hi
    sw   t1, 4(a1)             # tu 430: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_431:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_431
    li   t0, 0xc0d1e2f3
    li   t1, 0x04152637
    sw   t0, 0(a1)             # tu 431: data_hi
    sw   t1, 4(a1)             # tu 431: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_432:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_432
    li   t0, 0x25364758
    li   t1, 0x697a8b9c
    sw   t0, 0(a1)             # tu 432: data_hi
    sw   t1, 4(a1)             # tu 432: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_433:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_433
    li   t0, 0xadbecfe0
    li   t1, 0xf1021324
    sw   t0, 0(a1)             # tu 433: data_hi
    sw   t1, 4(a1)             # tu 433: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_434:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_434
    li   t0, 0x35465768
    li   t1, 0x798a9bac
    sw   t0, 0(a1)             # tu 434: data_hi
    sw   t1, 4(a1)             # tu 434: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_435:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_435
    li   t0, 0xbdcedff0
    li   t1, 0x01122334
    sw   t0, 0(a1)             # tu 435: data_hi
    sw   t1, 4(a1)             # tu 435: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_436:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_436
    li   t0, 0x45566778
    li   t1, 0x899aabbc
    sw   t0, 0(a1)             # tu 436: data_hi
    sw   t1, 4(a1)             # tu 436: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_437:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_437
    li   t0, 0xcddeef00
    li   t1, 0x11223344
    sw   t0, 0(a1)             # tu 437: data_hi
    sw   t1, 4(a1)             # tu 437: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_438:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_438
    li   t0, 0x55667788
    li   t1, 0x99aabbcc
    sw   t0, 0(a1)             # tu 438: data_hi
    sw   t1, 4(a1)             # tu 438: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_439:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_439
    li   t0, 0xddeeff10
    li   t1, 0x21324354
    sw   t0, 0(a1)             # tu 439: data_hi
    sw   t1, 4(a1)             # tu 439: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_440:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_440
    li   t0, 0x42536475
    li   t1, 0x8697a8b9
    sw   t0, 0(a1)             # tu 440: data_hi
    sw   t1, 4(a1)             # tu 440: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_441:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_441
    li   t0, 0xcadbecfd
    li   t1, 0x0e1f3041
    sw   t0, 0(a1)             # tu 441: data_hi
    sw   t1, 4(a1)             # tu 441: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_442:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_442
    li   t0, 0x52637485
    li   t1, 0x96a7b8c9
    sw   t0, 0(a1)             # tu 442: data_hi
    sw   t1, 4(a1)             # tu 442: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_443:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_443
    li   t0, 0xdaebfc0d
    li   t1, 0x1e2f4051
    sw   t0, 0(a1)             # tu 443: data_hi
    sw   t1, 4(a1)             # tu 443: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_444:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_444
    li   t0, 0x62738495
    li   t1, 0xa6b7c8d9
    sw   t0, 0(a1)             # tu 444: data_hi
    sw   t1, 4(a1)             # tu 444: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_445:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_445
    li   t0, 0xeafb0c1d
    li   t1, 0x2e3f5061
    sw   t0, 0(a1)             # tu 445: data_hi
    sw   t1, 4(a1)             # tu 445: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_446:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_446
    li   t0, 0x728394a5
    li   t1, 0xb6c7d8e9
    sw   t0, 0(a1)             # tu 446: data_hi
    sw   t1, 4(a1)             # tu 446: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_447:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_447
    li   t0, 0xfa0b1c2d
    li   t1, 0x3e4f6071
    sw   t0, 0(a1)             # tu 447: data_hi
    sw   t1, 4(a1)             # tu 447: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_448:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_448
    li   t0, 0x5f708192
    li   t1, 0xa3b4c5d6
    sw   t0, 0(a1)             # tu 448: data_hi
    sw   t1, 4(a1)             # tu 448: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_449:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_449
    li   t0, 0xe7f8091a
    li   t1, 0x2b3c4d5e
    sw   t0, 0(a1)             # tu 449: data_hi
    sw   t1, 4(a1)             # tu 449: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_450:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_450
    li   t0, 0x6f8091a2
    li   t1, 0xb3c4d5e6
    sw   t0, 0(a1)             # tu 450: data_hi
    sw   t1, 4(a1)             # tu 450: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_451:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_451
    li   t0, 0xf708192a
    li   t1, 0x3b4c5d6e
    sw   t0, 0(a1)             # tu 451: data_hi
    sw   t1, 4(a1)             # tu 451: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_452:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_452
    li   t0, 0x7f90a1b2
    li   t1, 0xc3d4e5f6
    sw   t0, 0(a1)             # tu 452: data_hi
    sw   t1, 4(a1)             # tu 452: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_453:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_453
    li   t0, 0x0718293a
    li   t1, 0x4b5c6d7e
    sw   t0, 0(a1)             # tu 453: data_hi
    sw   t1, 4(a1)             # tu 453: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_454:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_454
    li   t0, 0x8fa0b1c2
    li   t1, 0xd3e4f506
    sw   t0, 0(a1)             # tu 454: data_hi
    sw   t1, 4(a1)             # tu 454: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_455:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_455
    li   t0, 0x1728394a
    li   t1, 0x5b6c7d8e
    sw   t0, 0(a1)             # tu 455: data_hi
    sw   t1, 4(a1)             # tu 455: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_456:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_456
    li   t0, 0x7c8d9eaf
    li   t1, 0xc0d1e2f3
    sw   t0, 0(a1)             # tu 456: data_hi
    sw   t1, 4(a1)             # tu 456: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_457:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_457
    li   t0, 0x04152637
    li   t1, 0x48596a7b
    sw   t0, 0(a1)             # tu 457: data_hi
    sw   t1, 4(a1)             # tu 457: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_458:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_458
    li   t0, 0x8c9daebf
    li   t1, 0xd0e1f203
    sw   t0, 0(a1)             # tu 458: data_hi
    sw   t1, 4(a1)             # tu 458: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_459:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_459
    li   t0, 0x14253647
    li   t1, 0x58697a8b
    sw   t0, 0(a1)             # tu 459: data_hi
    sw   t1, 4(a1)             # tu 459: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_460:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_460
    li   t0, 0x9cadbecf
    li   t1, 0xe0f10213
    sw   t0, 0(a1)             # tu 460: data_hi
    sw   t1, 4(a1)             # tu 460: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_461:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_461
    li   t0, 0x24354657
    li   t1, 0x68798a9b
    sw   t0, 0(a1)             # tu 461: data_hi
    sw   t1, 4(a1)             # tu 461: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_462:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_462
    li   t0, 0xacbdcedf
    li   t1, 0xf0011223
    sw   t0, 0(a1)             # tu 462: data_hi
    sw   t1, 4(a1)             # tu 462: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_463:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_463
    li   t0, 0x34455667
    li   t1, 0x78899aab
    sw   t0, 0(a1)             # tu 463: data_hi
    sw   t1, 4(a1)             # tu 463: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_464:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_464
    li   t0, 0x99aabbcc
    li   t1, 0xddeeff10
    sw   t0, 0(a1)             # tu 464: data_hi
    sw   t1, 4(a1)             # tu 464: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_465:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_465
    li   t0, 0x21324354
    li   t1, 0x65768798
    sw   t0, 0(a1)             # tu 465: data_hi
    sw   t1, 4(a1)             # tu 465: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_466:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_466
    li   t0, 0xa9bacbdc
    li   t1, 0xedfe0f20
    sw   t0, 0(a1)             # tu 466: data_hi
    sw   t1, 4(a1)             # tu 466: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_467:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_467
    li   t0, 0x31425364
    li   t1, 0x758697a8
    sw   t0, 0(a1)             # tu 467: data_hi
    sw   t1, 4(a1)             # tu 467: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_468:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_468
    li   t0, 0xb9cadbec
    li   t1, 0xfd0e1f30
    sw   t0, 0(a1)             # tu 468: data_hi
    sw   t1, 4(a1)             # tu 468: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_469:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_469
    li   t0, 0x41526374
    li   t1, 0x8596a7b8
    sw   t0, 0(a1)             # tu 469: data_hi
    sw   t1, 4(a1)             # tu 469: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_470:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_470
    li   t0, 0xc9daebfc
    li   t1, 0x0d1e2f40
    sw   t0, 0(a1)             # tu 470: data_hi
    sw   t1, 4(a1)             # tu 470: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_471:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_471
    li   t0, 0x51627384
    li   t1, 0x95a6b7c8
    sw   t0, 0(a1)             # tu 471: data_hi
    sw   t1, 4(a1)             # tu 471: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_472:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_472
    li   t0, 0xb6c7d8e9
    li   t1, 0xfa0b1c2d
    sw   t0, 0(a1)             # tu 472: data_hi
    sw   t1, 4(a1)             # tu 472: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_473:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_473
    li   t0, 0x3e4f6071
    li   t1, 0x8293a4b5
    sw   t0, 0(a1)             # tu 473: data_hi
    sw   t1, 4(a1)             # tu 473: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_474:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_474
    li   t0, 0xc6d7e8f9
    li   t1, 0x0a1b2c3d
    sw   t0, 0(a1)             # tu 474: data_hi
    sw   t1, 4(a1)             # tu 474: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_475:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_475
    li   t0, 0x4e5f7081
    li   t1, 0x92a3b4c5
    sw   t0, 0(a1)             # tu 475: data_hi
    sw   t1, 4(a1)             # tu 475: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_476:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_476
    li   t0, 0xd6e7f809
    li   t1, 0x1a2b3c4d
    sw   t0, 0(a1)             # tu 476: data_hi
    sw   t1, 4(a1)             # tu 476: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_477:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_477
    li   t0, 0x5e6f8091
    li   t1, 0xa2b3c4d5
    sw   t0, 0(a1)             # tu 477: data_hi
    sw   t1, 4(a1)             # tu 477: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_478:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_478
    li   t0, 0xe6f70819
    li   t1, 0x2a3b4c5d
    sw   t0, 0(a1)             # tu 478: data_hi
    sw   t1, 4(a1)             # tu 478: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_479:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_479
    li   t0, 0x6e7f90a1
    li   t1, 0xb2c3d4e5
    sw   t0, 0(a1)             # tu 479: data_hi
    sw   t1, 4(a1)             # tu 479: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_480:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_480
    li   t0, 0xd3e4f506
    li   t1, 0x1728394a
    sw   t0, 0(a1)             # tu 480: data_hi
    sw   t1, 4(a1)             # tu 480: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_481:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_481
    li   t0, 0x5b6c7d8e
    li   t1, 0x9fb0c1d2
    sw   t0, 0(a1)             # tu 481: data_hi
    sw   t1, 4(a1)             # tu 481: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_482:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_482
    li   t0, 0xe3f40516
    li   t1, 0x2738495a
    sw   t0, 0(a1)             # tu 482: data_hi
    sw   t1, 4(a1)             # tu 482: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_483:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_483
    li   t0, 0x6b7c8d9e
    li   t1, 0xafc0d1e2
    sw   t0, 0(a1)             # tu 483: data_hi
    sw   t1, 4(a1)             # tu 483: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_484:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_484
    li   t0, 0xf3041526
    li   t1, 0x3748596a
    sw   t0, 0(a1)             # tu 484: data_hi
    sw   t1, 4(a1)             # tu 484: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_485:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_485
    li   t0, 0x7b8c9dae
    li   t1, 0xbfd0e1f2
    sw   t0, 0(a1)             # tu 485: data_hi
    sw   t1, 4(a1)             # tu 485: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_486:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_486
    li   t0, 0x03142536
    li   t1, 0x4758697a
    sw   t0, 0(a1)             # tu 486: data_hi
    sw   t1, 4(a1)             # tu 486: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_487:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_487
    li   t0, 0x8b9cadbe
    li   t1, 0xcfe0f102
    sw   t0, 0(a1)             # tu 487: data_hi
    sw   t1, 4(a1)             # tu 487: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_488:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_488
    li   t0, 0xf0011223
    li   t1, 0x34455667
    sw   t0, 0(a1)             # tu 488: data_hi
    sw   t1, 4(a1)             # tu 488: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_489:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_489
    li   t0, 0x78899aab
    li   t1, 0xbccddeef
    sw   t0, 0(a1)             # tu 489: data_hi
    sw   t1, 4(a1)             # tu 489: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_490:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_490
    li   t0, 0x00112233
    li   t1, 0x44556677
    sw   t0, 0(a1)             # tu 490: data_hi
    sw   t1, 4(a1)             # tu 490: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_491:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_491
    li   t0, 0x8899aabb
    li   t1, 0xccddeeff
    sw   t0, 0(a1)             # tu 491: data_hi
    sw   t1, 4(a1)             # tu 491: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_492:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_492
    li   t0, 0x10213243
    li   t1, 0x54657687
    sw   t0, 0(a1)             # tu 492: data_hi
    sw   t1, 4(a1)             # tu 492: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_493:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_493
    li   t0, 0x98a9bacb
    li   t1, 0xdcedfe0f
    sw   t0, 0(a1)             # tu 493: data_hi
    sw   t1, 4(a1)             # tu 493: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_494:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_494
    li   t0, 0x20314253
    li   t1, 0x64758697
    sw   t0, 0(a1)             # tu 494: data_hi
    sw   t1, 4(a1)             # tu 494: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_495:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_495
    li   t0, 0xa8b9cadb
    li   t1, 0xecfd0e1f
    sw   t0, 0(a1)             # tu 495: data_hi
    sw   t1, 4(a1)             # tu 495: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_496:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_496
    li   t0, 0x0d1e2f40
    li   t1, 0x51627384
    sw   t0, 0(a1)             # tu 496: data_hi
    sw   t1, 4(a1)             # tu 496: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_497:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_497
    li   t0, 0x95a6b7c8
    li   t1, 0xd9eafb0c
    sw   t0, 0(a1)             # tu 497: data_hi
    sw   t1, 4(a1)             # tu 497: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_498:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_498
    li   t0, 0x1d2e3f50
    li   t1, 0x61728394
    sw   t0, 0(a1)             # tu 498: data_hi
    sw   t1, 4(a1)             # tu 498: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_499:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_499
    li   t0, 0xa5b6c7d8
    li   t1, 0xe9fa0b1c
    sw   t0, 0(a1)             # tu 499: data_hi
    sw   t1, 4(a1)             # tu 499: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_500:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_500
    li   t0, 0x2d3e4f60
    li   t1, 0x718293a4
    sw   t0, 0(a1)             # tu 500: data_hi
    sw   t1, 4(a1)             # tu 500: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_501:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_501
    li   t0, 0xb5c6d7e8
    li   t1, 0xf90a1b2c
    sw   t0, 0(a1)             # tu 501: data_hi
    sw   t1, 4(a1)             # tu 501: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_502:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_502
    li   t0, 0x3d4e5f70
    li   t1, 0x8192a3b4
    sw   t0, 0(a1)             # tu 502: data_hi
    sw   t1, 4(a1)             # tu 502: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_503:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_503
    li   t0, 0xc5d6e7f8
    li   t1, 0x091a2b3c
    sw   t0, 0(a1)             # tu 503: data_hi
    sw   t1, 4(a1)             # tu 503: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_504:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_504
    li   t0, 0x2a3b4c5d
    li   t1, 0x6e7f90a1
    sw   t0, 0(a1)             # tu 504: data_hi
    sw   t1, 4(a1)             # tu 504: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_505:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_505
    li   t0, 0xb2c3d4e5
    li   t1, 0xf6071829
    sw   t0, 0(a1)             # tu 505: data_hi
    sw   t1, 4(a1)             # tu 505: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_506:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_506
    li   t0, 0x3a4b5c6d
    li   t1, 0x7e8fa0b1
    sw   t0, 0(a1)             # tu 506: data_hi
    sw   t1, 4(a1)             # tu 506: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_507:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_507
    li   t0, 0xc2d3e4f5
    li   t1, 0x06172839
    sw   t0, 0(a1)             # tu 507: data_hi
    sw   t1, 4(a1)             # tu 507: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_508:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_508
    li   t0, 0x4a5b6c7d
    li   t1, 0x8e9fb0c1
    sw   t0, 0(a1)             # tu 508: data_hi
    sw   t1, 4(a1)             # tu 508: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_509:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_509
    li   t0, 0xd2e3f405
    li   t1, 0x16273849
    sw   t0, 0(a1)             # tu 509: data_hi
    sw   t1, 4(a1)             # tu 509: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_510:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_510
    li   t0, 0x5a6b7c8d
    li   t1, 0x9eafc0d1
    sw   t0, 0(a1)             # tu 510: data_hi
    sw   t1, 4(a1)             # tu 510: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_511:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_511
    li   t0, 0xe2f30415
    li   t1, 0x26374859
    sw   t0, 0(a1)             # tu 511: data_hi
    sw   t1, 4(a1)             # tu 511: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_512:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_512
    li   t0, 0x00000000
    li   t1, 0x00000000
    li   t3, 0x03                # CTRL: iReady=1,iLast=1,ibyte=0
    sw   t0, 0(a1)             # tu cuoi (512): data_hi
    sw   t1, 4(a1)             # tu cuoi (512): data_lo
    sw   t3, 8(a1)             # absorb + bao ket thuc

poll_sha3:
    lw   t0, 0x0C(a1)          # STATUS: bit0=oReady
    andi t0, t0, 1
    beqz t0, poll_sha3

    # ---- Doc 8 tu digest (0x10..0x2C, MSB truoc), ghi ra BRAM ----
    lw   t0, 0x10(a1)
    sw   t0, 0x00(s0)          # digest word 0
    lw   t0, 0x14(a1)
    sw   t0, 0x04(s0)          # digest word 1
    lw   t0, 0x18(a1)
    sw   t0, 0x08(s0)          # digest word 2
    lw   t0, 0x1c(a1)
    sw   t0, 0x0c(s0)          # digest word 3
    lw   t0, 0x20(a1)
    sw   t0, 0x10(s0)          # digest word 4
    lw   t0, 0x24(a1)
    sw   t0, 0x14(s0)          # digest word 5
    lw   t0, 0x28(a1)
    sw   t0, 0x18(s0)          # digest word 6
    lw   t0, 0x2c(a1)
    sw   t0, 0x1c(s0)          # digest word 7

    li   t0, 0x600d600d       # marker: hash xong
    sw   t0, 0x20(s0)

halt:
    j    halt
