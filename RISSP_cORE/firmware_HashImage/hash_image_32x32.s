# hash_image_32x32.s - RISSP+SHA3 SoC: hash anh test 1024 byte
# bang SHA3-256, ghi digest ra vung debug 0xC0000000.
#
# Sinh TU DONG boi gen_image_firmware.py - khong sua tay file nay,
# sua script roi chay lai neu can doi anh/kich thuoc.
#
# KHAC hash_image.s ban dau: co POLL oBuffer_full (STATUS bit1)
# TRUOC moi lan ghi tu moi de tranh mat du lieu am tham khi anh
# tran nhieu block SHA3 (xem SHA3_Core/SHA3.md).
#
# Ground truth (Python hashlib.sha3_256, 1024 byte):
#   50c4674596f93c43253ad67fc3f629b5fecffff290a54dd8644dbff876d62505

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
    li   t0, 0x24354657
    li   t1, 0x68798a9b
    sw   t0, 0(a1)             # tu 4: data_hi
    sw   t1, 4(a1)             # tu 4: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_5:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_5
    li   t0, 0xacbdcedf
    li   t1, 0xf0011223
    sw   t0, 0(a1)             # tu 5: data_hi
    sw   t1, 4(a1)             # tu 5: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_6:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_6
    li   t0, 0x34455667
    li   t1, 0x78899aab
    sw   t0, 0(a1)             # tu 6: data_hi
    sw   t1, 4(a1)             # tu 6: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_7:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_7
    li   t0, 0xbccddeef
    li   t1, 0x00112233
    sw   t0, 0(a1)             # tu 7: data_hi
    sw   t1, 4(a1)             # tu 7: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_8:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_8
    li   t0, 0x41526374
    li   t1, 0x8596a7b8
    sw   t0, 0(a1)             # tu 8: data_hi
    sw   t1, 4(a1)             # tu 8: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_9:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_9
    li   t0, 0xc9daebfc
    li   t1, 0x0d1e2f40
    sw   t0, 0(a1)             # tu 9: data_hi
    sw   t1, 4(a1)             # tu 9: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_10:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_10
    li   t0, 0x51627384
    li   t1, 0x95a6b7c8
    sw   t0, 0(a1)             # tu 10: data_hi
    sw   t1, 4(a1)             # tu 10: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_11:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_11
    li   t0, 0xd9eafb0c
    li   t1, 0x1d2e3f50
    sw   t0, 0(a1)             # tu 11: data_hi
    sw   t1, 4(a1)             # tu 11: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_12:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_12
    li   t0, 0x5e6f8091
    li   t1, 0xa2b3c4d5
    sw   t0, 0(a1)             # tu 12: data_hi
    sw   t1, 4(a1)             # tu 12: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_13:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_13
    li   t0, 0xe6f70819
    li   t1, 0x2a3b4c5d
    sw   t0, 0(a1)             # tu 13: data_hi
    sw   t1, 4(a1)             # tu 13: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_14:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_14
    li   t0, 0x6e7f90a1
    li   t1, 0xb2c3d4e5
    sw   t0, 0(a1)             # tu 14: data_hi
    sw   t1, 4(a1)             # tu 14: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_15:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_15
    li   t0, 0xf6071829
    li   t1, 0x3a4b5c6d
    sw   t0, 0(a1)             # tu 15: data_hi
    sw   t1, 4(a1)             # tu 15: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_16:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_16
    li   t0, 0x7b8c9dae
    li   t1, 0xbfd0e1f2
    sw   t0, 0(a1)             # tu 16: data_hi
    sw   t1, 4(a1)             # tu 16: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_17:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_17
    li   t0, 0x03142536
    li   t1, 0x4758697a
    sw   t0, 0(a1)             # tu 17: data_hi
    sw   t1, 4(a1)             # tu 17: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_18:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_18
    li   t0, 0x8b9cadbe
    li   t1, 0xcfe0f102
    sw   t0, 0(a1)             # tu 18: data_hi
    sw   t1, 4(a1)             # tu 18: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_19:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_19
    li   t0, 0x13243546
    li   t1, 0x5768798a
    sw   t0, 0(a1)             # tu 19: data_hi
    sw   t1, 4(a1)             # tu 19: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_20:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_20
    li   t0, 0x98a9bacb
    li   t1, 0xdcedfe0f
    sw   t0, 0(a1)             # tu 20: data_hi
    sw   t1, 4(a1)             # tu 20: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_21:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_21
    li   t0, 0x20314253
    li   t1, 0x64758697
    sw   t0, 0(a1)             # tu 21: data_hi
    sw   t1, 4(a1)             # tu 21: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_22:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_22
    li   t0, 0xa8b9cadb
    li   t1, 0xecfd0e1f
    sw   t0, 0(a1)             # tu 22: data_hi
    sw   t1, 4(a1)             # tu 22: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_23:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_23
    li   t0, 0x30415263
    li   t1, 0x748596a7
    sw   t0, 0(a1)             # tu 23: data_hi
    sw   t1, 4(a1)             # tu 23: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_24:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_24
    li   t0, 0xb5c6d7e8
    li   t1, 0xf90a1b2c
    sw   t0, 0(a1)             # tu 24: data_hi
    sw   t1, 4(a1)             # tu 24: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_25:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_25
    li   t0, 0x3d4e5f70
    li   t1, 0x8192a3b4
    sw   t0, 0(a1)             # tu 25: data_hi
    sw   t1, 4(a1)             # tu 25: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_26:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_26
    li   t0, 0xc5d6e7f8
    li   t1, 0x091a2b3c
    sw   t0, 0(a1)             # tu 26: data_hi
    sw   t1, 4(a1)             # tu 26: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_27:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_27
    li   t0, 0x4d5e6f80
    li   t1, 0x91a2b3c4
    sw   t0, 0(a1)             # tu 27: data_hi
    sw   t1, 4(a1)             # tu 27: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_28:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_28
    li   t0, 0xd2e3f405
    li   t1, 0x16273849
    sw   t0, 0(a1)             # tu 28: data_hi
    sw   t1, 4(a1)             # tu 28: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_29:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_29
    li   t0, 0x5a6b7c8d
    li   t1, 0x9eafc0d1
    sw   t0, 0(a1)             # tu 29: data_hi
    sw   t1, 4(a1)             # tu 29: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_30:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_30
    li   t0, 0xe2f30415
    li   t1, 0x26374859
    sw   t0, 0(a1)             # tu 30: data_hi
    sw   t1, 4(a1)             # tu 30: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_31:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_31
    li   t0, 0x6a7b8c9d
    li   t1, 0xaebfd0e1
    sw   t0, 0(a1)             # tu 31: data_hi
    sw   t1, 4(a1)             # tu 31: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_32:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_32
    li   t0, 0xef001122
    li   t1, 0x33445566
    sw   t0, 0(a1)             # tu 32: data_hi
    sw   t1, 4(a1)             # tu 32: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_33:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_33
    li   t0, 0x778899aa
    li   t1, 0xbbccddee
    sw   t0, 0(a1)             # tu 33: data_hi
    sw   t1, 4(a1)             # tu 33: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_34:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_34
    li   t0, 0xff102132
    li   t1, 0x43546576
    sw   t0, 0(a1)             # tu 34: data_hi
    sw   t1, 4(a1)             # tu 34: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_35:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_35
    li   t0, 0x8798a9ba
    li   t1, 0xcbdcedfe
    sw   t0, 0(a1)             # tu 35: data_hi
    sw   t1, 4(a1)             # tu 35: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_36:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_36
    li   t0, 0x0c1d2e3f
    li   t1, 0x50617283
    sw   t0, 0(a1)             # tu 36: data_hi
    sw   t1, 4(a1)             # tu 36: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_37:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_37
    li   t0, 0x94a5b6c7
    li   t1, 0xd8e9fa0b
    sw   t0, 0(a1)             # tu 37: data_hi
    sw   t1, 4(a1)             # tu 37: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_38:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_38
    li   t0, 0x1c2d3e4f
    li   t1, 0x60718293
    sw   t0, 0(a1)             # tu 38: data_hi
    sw   t1, 4(a1)             # tu 38: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_39:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_39
    li   t0, 0xa4b5c6d7
    li   t1, 0xe8f90a1b
    sw   t0, 0(a1)             # tu 39: data_hi
    sw   t1, 4(a1)             # tu 39: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_40:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_40
    li   t0, 0x293a4b5c
    li   t1, 0x6d7e8fa0
    sw   t0, 0(a1)             # tu 40: data_hi
    sw   t1, 4(a1)             # tu 40: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_41:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_41
    li   t0, 0xb1c2d3e4
    li   t1, 0xf5061728
    sw   t0, 0(a1)             # tu 41: data_hi
    sw   t1, 4(a1)             # tu 41: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_42:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_42
    li   t0, 0x394a5b6c
    li   t1, 0x7d8e9fb0
    sw   t0, 0(a1)             # tu 42: data_hi
    sw   t1, 4(a1)             # tu 42: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_43:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_43
    li   t0, 0xc1d2e3f4
    li   t1, 0x05162738
    sw   t0, 0(a1)             # tu 43: data_hi
    sw   t1, 4(a1)             # tu 43: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_44:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_44
    li   t0, 0x46576879
    li   t1, 0x8a9bacbd
    sw   t0, 0(a1)             # tu 44: data_hi
    sw   t1, 4(a1)             # tu 44: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_45:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_45
    li   t0, 0xcedff001
    li   t1, 0x12233445
    sw   t0, 0(a1)             # tu 45: data_hi
    sw   t1, 4(a1)             # tu 45: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_46:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_46
    li   t0, 0x56677889
    li   t1, 0x9aabbccd
    sw   t0, 0(a1)             # tu 46: data_hi
    sw   t1, 4(a1)             # tu 46: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_47:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_47
    li   t0, 0xdeef0011
    li   t1, 0x22334455
    sw   t0, 0(a1)             # tu 47: data_hi
    sw   t1, 4(a1)             # tu 47: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_48:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_48
    li   t0, 0x63748596
    li   t1, 0xa7b8c9da
    sw   t0, 0(a1)             # tu 48: data_hi
    sw   t1, 4(a1)             # tu 48: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_49:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_49
    li   t0, 0xebfc0d1e
    li   t1, 0x2f405162
    sw   t0, 0(a1)             # tu 49: data_hi
    sw   t1, 4(a1)             # tu 49: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_50:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_50
    li   t0, 0x738495a6
    li   t1, 0xb7c8d9ea
    sw   t0, 0(a1)             # tu 50: data_hi
    sw   t1, 4(a1)             # tu 50: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_51:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_51
    li   t0, 0xfb0c1d2e
    li   t1, 0x3f506172
    sw   t0, 0(a1)             # tu 51: data_hi
    sw   t1, 4(a1)             # tu 51: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_52:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_52
    li   t0, 0x8091a2b3
    li   t1, 0xc4d5e6f7
    sw   t0, 0(a1)             # tu 52: data_hi
    sw   t1, 4(a1)             # tu 52: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_53:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_53
    li   t0, 0x08192a3b
    li   t1, 0x4c5d6e7f
    sw   t0, 0(a1)             # tu 53: data_hi
    sw   t1, 4(a1)             # tu 53: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_54:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_54
    li   t0, 0x90a1b2c3
    li   t1, 0xd4e5f607
    sw   t0, 0(a1)             # tu 54: data_hi
    sw   t1, 4(a1)             # tu 54: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_55:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_55
    li   t0, 0x18293a4b
    li   t1, 0x5c6d7e8f
    sw   t0, 0(a1)             # tu 55: data_hi
    sw   t1, 4(a1)             # tu 55: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_56:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_56
    li   t0, 0x9daebfd0
    li   t1, 0xe1f20314
    sw   t0, 0(a1)             # tu 56: data_hi
    sw   t1, 4(a1)             # tu 56: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_57:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_57
    li   t0, 0x25364758
    li   t1, 0x697a8b9c
    sw   t0, 0(a1)             # tu 57: data_hi
    sw   t1, 4(a1)             # tu 57: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_58:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_58
    li   t0, 0xadbecfe0
    li   t1, 0xf1021324
    sw   t0, 0(a1)             # tu 58: data_hi
    sw   t1, 4(a1)             # tu 58: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_59:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_59
    li   t0, 0x35465768
    li   t1, 0x798a9bac
    sw   t0, 0(a1)             # tu 59: data_hi
    sw   t1, 4(a1)             # tu 59: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_60:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_60
    li   t0, 0xbacbdced
    li   t1, 0xfe0f2031
    sw   t0, 0(a1)             # tu 60: data_hi
    sw   t1, 4(a1)             # tu 60: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_61:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_61
    li   t0, 0x42536475
    li   t1, 0x8697a8b9
    sw   t0, 0(a1)             # tu 61: data_hi
    sw   t1, 4(a1)             # tu 61: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_62:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_62
    li   t0, 0xcadbecfd
    li   t1, 0x0e1f3041
    sw   t0, 0(a1)             # tu 62: data_hi
    sw   t1, 4(a1)             # tu 62: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_63:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_63
    li   t0, 0x52637485
    li   t1, 0x96a7b8c9
    sw   t0, 0(a1)             # tu 63: data_hi
    sw   t1, 4(a1)             # tu 63: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_64:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_64
    li   t0, 0xd7e8f90a
    li   t1, 0x1b2c3d4e
    sw   t0, 0(a1)             # tu 64: data_hi
    sw   t1, 4(a1)             # tu 64: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_65:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_65
    li   t0, 0x5f708192
    li   t1, 0xa3b4c5d6
    sw   t0, 0(a1)             # tu 65: data_hi
    sw   t1, 4(a1)             # tu 65: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_66:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_66
    li   t0, 0xe7f8091a
    li   t1, 0x2b3c4d5e
    sw   t0, 0(a1)             # tu 66: data_hi
    sw   t1, 4(a1)             # tu 66: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_67:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_67
    li   t0, 0x6f8091a2
    li   t1, 0xb3c4d5e6
    sw   t0, 0(a1)             # tu 67: data_hi
    sw   t1, 4(a1)             # tu 67: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_68:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_68
    li   t0, 0xf4051627
    li   t1, 0x38495a6b
    sw   t0, 0(a1)             # tu 68: data_hi
    sw   t1, 4(a1)             # tu 68: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_69:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_69
    li   t0, 0x7c8d9eaf
    li   t1, 0xc0d1e2f3
    sw   t0, 0(a1)             # tu 69: data_hi
    sw   t1, 4(a1)             # tu 69: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_70:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_70
    li   t0, 0x04152637
    li   t1, 0x48596a7b
    sw   t0, 0(a1)             # tu 70: data_hi
    sw   t1, 4(a1)             # tu 70: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_71:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_71
    li   t0, 0x8c9daebf
    li   t1, 0xd0e1f203
    sw   t0, 0(a1)             # tu 71: data_hi
    sw   t1, 4(a1)             # tu 71: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_72:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_72
    li   t0, 0x11223344
    li   t1, 0x55667788
    sw   t0, 0(a1)             # tu 72: data_hi
    sw   t1, 4(a1)             # tu 72: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_73:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_73
    li   t0, 0x99aabbcc
    li   t1, 0xddeeff10
    sw   t0, 0(a1)             # tu 73: data_hi
    sw   t1, 4(a1)             # tu 73: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_74:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_74
    li   t0, 0x21324354
    li   t1, 0x65768798
    sw   t0, 0(a1)             # tu 74: data_hi
    sw   t1, 4(a1)             # tu 74: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_75:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_75
    li   t0, 0xa9bacbdc
    li   t1, 0xedfe0f20
    sw   t0, 0(a1)             # tu 75: data_hi
    sw   t1, 4(a1)             # tu 75: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_76:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_76
    li   t0, 0x2e3f5061
    li   t1, 0x728394a5
    sw   t0, 0(a1)             # tu 76: data_hi
    sw   t1, 4(a1)             # tu 76: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_77:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_77
    li   t0, 0xb6c7d8e9
    li   t1, 0xfa0b1c2d
    sw   t0, 0(a1)             # tu 77: data_hi
    sw   t1, 4(a1)             # tu 77: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_78:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_78
    li   t0, 0x3e4f6071
    li   t1, 0x8293a4b5
    sw   t0, 0(a1)             # tu 78: data_hi
    sw   t1, 4(a1)             # tu 78: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_79:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_79
    li   t0, 0xc6d7e8f9
    li   t1, 0x0a1b2c3d
    sw   t0, 0(a1)             # tu 79: data_hi
    sw   t1, 4(a1)             # tu 79: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_80:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_80
    li   t0, 0x4b5c6d7e
    li   t1, 0x8fa0b1c2
    sw   t0, 0(a1)             # tu 80: data_hi
    sw   t1, 4(a1)             # tu 80: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_81:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_81
    li   t0, 0xd3e4f506
    li   t1, 0x1728394a
    sw   t0, 0(a1)             # tu 81: data_hi
    sw   t1, 4(a1)             # tu 81: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_82:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_82
    li   t0, 0x5b6c7d8e
    li   t1, 0x9fb0c1d2
    sw   t0, 0(a1)             # tu 82: data_hi
    sw   t1, 4(a1)             # tu 82: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_83:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_83
    li   t0, 0xe3f40516
    li   t1, 0x2738495a
    sw   t0, 0(a1)             # tu 83: data_hi
    sw   t1, 4(a1)             # tu 83: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_84:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_84
    li   t0, 0x68798a9b
    li   t1, 0xacbdcedf
    sw   t0, 0(a1)             # tu 84: data_hi
    sw   t1, 4(a1)             # tu 84: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_85:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_85
    li   t0, 0xf0011223
    li   t1, 0x34455667
    sw   t0, 0(a1)             # tu 85: data_hi
    sw   t1, 4(a1)             # tu 85: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_86:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_86
    li   t0, 0x78899aab
    li   t1, 0xbccddeef
    sw   t0, 0(a1)             # tu 86: data_hi
    sw   t1, 4(a1)             # tu 86: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_87:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_87
    li   t0, 0x00112233
    li   t1, 0x44556677
    sw   t0, 0(a1)             # tu 87: data_hi
    sw   t1, 4(a1)             # tu 87: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_88:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_88
    li   t0, 0x8596a7b8
    li   t1, 0xc9daebfc
    sw   t0, 0(a1)             # tu 88: data_hi
    sw   t1, 4(a1)             # tu 88: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_89:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_89
    li   t0, 0x0d1e2f40
    li   t1, 0x51627384
    sw   t0, 0(a1)             # tu 89: data_hi
    sw   t1, 4(a1)             # tu 89: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_90:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_90
    li   t0, 0x95a6b7c8
    li   t1, 0xd9eafb0c
    sw   t0, 0(a1)             # tu 90: data_hi
    sw   t1, 4(a1)             # tu 90: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_91:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_91
    li   t0, 0x1d2e3f50
    li   t1, 0x61728394
    sw   t0, 0(a1)             # tu 91: data_hi
    sw   t1, 4(a1)             # tu 91: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_92:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_92
    li   t0, 0xa2b3c4d5
    li   t1, 0xe6f70819
    sw   t0, 0(a1)             # tu 92: data_hi
    sw   t1, 4(a1)             # tu 92: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_93:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_93
    li   t0, 0x2a3b4c5d
    li   t1, 0x6e7f90a1
    sw   t0, 0(a1)             # tu 93: data_hi
    sw   t1, 4(a1)             # tu 93: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_94:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_94
    li   t0, 0xb2c3d4e5
    li   t1, 0xf6071829
    sw   t0, 0(a1)             # tu 94: data_hi
    sw   t1, 4(a1)             # tu 94: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_95:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_95
    li   t0, 0x3a4b5c6d
    li   t1, 0x7e8fa0b1
    sw   t0, 0(a1)             # tu 95: data_hi
    sw   t1, 4(a1)             # tu 95: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_96:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_96
    li   t0, 0xbfd0e1f2
    li   t1, 0x03142536
    sw   t0, 0(a1)             # tu 96: data_hi
    sw   t1, 4(a1)             # tu 96: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_97:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_97
    li   t0, 0x4758697a
    li   t1, 0x8b9cadbe
    sw   t0, 0(a1)             # tu 97: data_hi
    sw   t1, 4(a1)             # tu 97: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_98:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_98
    li   t0, 0xcfe0f102
    li   t1, 0x13243546
    sw   t0, 0(a1)             # tu 98: data_hi
    sw   t1, 4(a1)             # tu 98: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_99:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_99
    li   t0, 0x5768798a
    li   t1, 0x9bacbdce
    sw   t0, 0(a1)             # tu 99: data_hi
    sw   t1, 4(a1)             # tu 99: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_100:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_100
    li   t0, 0xdcedfe0f
    li   t1, 0x20314253
    sw   t0, 0(a1)             # tu 100: data_hi
    sw   t1, 4(a1)             # tu 100: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_101:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_101
    li   t0, 0x64758697
    li   t1, 0xa8b9cadb
    sw   t0, 0(a1)             # tu 101: data_hi
    sw   t1, 4(a1)             # tu 101: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_102:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_102
    li   t0, 0xecfd0e1f
    li   t1, 0x30415263
    sw   t0, 0(a1)             # tu 102: data_hi
    sw   t1, 4(a1)             # tu 102: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_103:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_103
    li   t0, 0x748596a7
    li   t1, 0xb8c9daeb
    sw   t0, 0(a1)             # tu 103: data_hi
    sw   t1, 4(a1)             # tu 103: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_104:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_104
    li   t0, 0xf90a1b2c
    li   t1, 0x3d4e5f70
    sw   t0, 0(a1)             # tu 104: data_hi
    sw   t1, 4(a1)             # tu 104: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_105:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_105
    li   t0, 0x8192a3b4
    li   t1, 0xc5d6e7f8
    sw   t0, 0(a1)             # tu 105: data_hi
    sw   t1, 4(a1)             # tu 105: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_106:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_106
    li   t0, 0x091a2b3c
    li   t1, 0x4d5e6f80
    sw   t0, 0(a1)             # tu 106: data_hi
    sw   t1, 4(a1)             # tu 106: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_107:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_107
    li   t0, 0x91a2b3c4
    li   t1, 0xd5e6f708
    sw   t0, 0(a1)             # tu 107: data_hi
    sw   t1, 4(a1)             # tu 107: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_108:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_108
    li   t0, 0x16273849
    li   t1, 0x5a6b7c8d
    sw   t0, 0(a1)             # tu 108: data_hi
    sw   t1, 4(a1)             # tu 108: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_109:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_109
    li   t0, 0x9eafc0d1
    li   t1, 0xe2f30415
    sw   t0, 0(a1)             # tu 109: data_hi
    sw   t1, 4(a1)             # tu 109: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_110:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_110
    li   t0, 0x26374859
    li   t1, 0x6a7b8c9d
    sw   t0, 0(a1)             # tu 110: data_hi
    sw   t1, 4(a1)             # tu 110: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_111:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_111
    li   t0, 0xaebfd0e1
    li   t1, 0xf2031425
    sw   t0, 0(a1)             # tu 111: data_hi
    sw   t1, 4(a1)             # tu 111: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_112:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_112
    li   t0, 0x33445566
    li   t1, 0x778899aa
    sw   t0, 0(a1)             # tu 112: data_hi
    sw   t1, 4(a1)             # tu 112: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_113:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_113
    li   t0, 0xbbccddee
    li   t1, 0xff102132
    sw   t0, 0(a1)             # tu 113: data_hi
    sw   t1, 4(a1)             # tu 113: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_114:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_114
    li   t0, 0x43546576
    li   t1, 0x8798a9ba
    sw   t0, 0(a1)             # tu 114: data_hi
    sw   t1, 4(a1)             # tu 114: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_115:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_115
    li   t0, 0xcbdcedfe
    li   t1, 0x0f203142
    sw   t0, 0(a1)             # tu 115: data_hi
    sw   t1, 4(a1)             # tu 115: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_116:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_116
    li   t0, 0x50617283
    li   t1, 0x94a5b6c7
    sw   t0, 0(a1)             # tu 116: data_hi
    sw   t1, 4(a1)             # tu 116: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_117:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_117
    li   t0, 0xd8e9fa0b
    li   t1, 0x1c2d3e4f
    sw   t0, 0(a1)             # tu 117: data_hi
    sw   t1, 4(a1)             # tu 117: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_118:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_118
    li   t0, 0x60718293
    li   t1, 0xa4b5c6d7
    sw   t0, 0(a1)             # tu 118: data_hi
    sw   t1, 4(a1)             # tu 118: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_119:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_119
    li   t0, 0xe8f90a1b
    li   t1, 0x2c3d4e5f
    sw   t0, 0(a1)             # tu 119: data_hi
    sw   t1, 4(a1)             # tu 119: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_120:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_120
    li   t0, 0x6d7e8fa0
    li   t1, 0xb1c2d3e4
    sw   t0, 0(a1)             # tu 120: data_hi
    sw   t1, 4(a1)             # tu 120: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_121:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_121
    li   t0, 0xf5061728
    li   t1, 0x394a5b6c
    sw   t0, 0(a1)             # tu 121: data_hi
    sw   t1, 4(a1)             # tu 121: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_122:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_122
    li   t0, 0x7d8e9fb0
    li   t1, 0xc1d2e3f4
    sw   t0, 0(a1)             # tu 122: data_hi
    sw   t1, 4(a1)             # tu 122: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_123:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_123
    li   t0, 0x05162738
    li   t1, 0x495a6b7c
    sw   t0, 0(a1)             # tu 123: data_hi
    sw   t1, 4(a1)             # tu 123: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_124:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_124
    li   t0, 0x8a9bacbd
    li   t1, 0xcedff001
    sw   t0, 0(a1)             # tu 124: data_hi
    sw   t1, 4(a1)             # tu 124: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_125:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_125
    li   t0, 0x12233445
    li   t1, 0x56677889
    sw   t0, 0(a1)             # tu 125: data_hi
    sw   t1, 4(a1)             # tu 125: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_126:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_126
    li   t0, 0x9aabbccd
    li   t1, 0xdeef0011
    sw   t0, 0(a1)             # tu 126: data_hi
    sw   t1, 4(a1)             # tu 126: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_127:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_127
    li   t0, 0x22334455
    li   t1, 0x66778899
    sw   t0, 0(a1)             # tu 127: data_hi
    sw   t1, 4(a1)             # tu 127: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_128:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_128
    li   t0, 0x00000000
    li   t1, 0x00000000
    li   t3, 0x03                # CTRL: iReady=1,iLast=1,ibyte=0
    sw   t0, 0(a1)             # tu cuoi (128): data_hi
    sw   t1, 4(a1)             # tu cuoi (128): data_lo
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
