# hash_image_11x11.s - RISSP+SHA3 SoC: hash anh test 121 byte
# bang SHA3-256, ghi digest ra vung debug 0xC0000000.
#
# Sinh TU DONG boi gen_image_firmware.py - khong sua tay file nay,
# sua script roi chay lai neu can doi anh/kich thuoc.
#
# KHAC hash_image.s ban dau: co POLL oBuffer_full (STATUS bit1)
# TRUOC moi lan ghi tu moi de tranh mat du lieu am tham khi anh
# tran nhieu block SHA3 (xem SHA3_Core/SHA3.md).
#
# Ground truth (Python hashlib.sha3_256, 121 byte):
#   ec43eb22febee4b3341afc250498943ce37c787700585527dd5cfe288259c3cb

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
    li   t0, 0x8fa0b124
    li   t1, 0x35465768
    sw   t0, 0(a1)             # tu 1: data_hi
    sw   t1, 4(a1)             # tu 1: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_2:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_2
    li   t0, 0x798a9bac
    li   t1, 0xbdce4152
    sw   t0, 0(a1)             # tu 2: data_hi
    sw   t1, 4(a1)             # tu 2: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_3:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_3
    li   t0, 0x63748596
    li   t1, 0xa7b8c9da
    sw   t0, 0(a1)             # tu 3: data_hi
    sw   t1, 4(a1)             # tu 3: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_4:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_4
    li   t0, 0xeb5e6f80
    li   t1, 0x91a2b3c4
    sw   t0, 0(a1)             # tu 4: data_hi
    sw   t1, 4(a1)             # tu 4: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_5:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_5
    li   t0, 0xd5e6f708
    li   t1, 0x7b8c9dae
    sw   t0, 0(a1)             # tu 5: data_hi
    sw   t1, 4(a1)             # tu 5: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_6:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_6
    li   t0, 0xbfd0e1f2
    li   t1, 0x03142598
    sw   t0, 0(a1)             # tu 6: data_hi
    sw   t1, 4(a1)             # tu 6: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_7:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_7
    li   t0, 0xa9bacbdc
    li   t1, 0xedfe0f20
    sw   t0, 0(a1)             # tu 7: data_hi
    sw   t1, 4(a1)             # tu 7: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_8:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_8
    li   t0, 0x3142b5c6
    li   t1, 0xd7e8f90a
    sw   t0, 0(a1)             # tu 8: data_hi
    sw   t1, 4(a1)             # tu 8: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_9:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_9
    li   t0, 0x1b2c3d4e
    li   t1, 0x5fd2e3f4
    sw   t0, 0(a1)             # tu 9: data_hi
    sw   t1, 4(a1)             # tu 9: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_10:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_10
    li   t0, 0x05162738
    li   t1, 0x495a6b7c
    sw   t0, 0(a1)             # tu 10: data_hi
    sw   t1, 4(a1)             # tu 10: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_11:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_11
    li   t0, 0xef001122
    li   t1, 0x33445566
    sw   t0, 0(a1)             # tu 11: data_hi
    sw   t1, 4(a1)             # tu 11: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_12:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_12
    li   t0, 0x7788990c
    li   t1, 0x1d2e3f50
    sw   t0, 0(a1)             # tu 12: data_hi
    sw   t1, 4(a1)             # tu 12: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_13:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_13
    li   t0, 0x61728394
    li   t1, 0xa5b6293a
    sw   t0, 0(a1)             # tu 13: data_hi
    sw   t1, 4(a1)             # tu 13: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_14:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_14
    li   t0, 0x4b5c6d7e
    li   t1, 0x8fa0b1c2
    sw   t0, 0(a1)             # tu 14: data_hi
    sw   t1, 4(a1)             # tu 14: data_lo
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)

poll_buf_15:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_15
    li   t0, 0xd3000000
    li   t1, 0x00000000
    li   t3, 0x07                # CTRL: iReady=1,iLast=1,ibyte=1
    sw   t0, 0(a1)             # tu cuoi (15): data_hi
    sw   t1, 4(a1)             # tu cuoi (15): data_lo
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
