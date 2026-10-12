# hash_lena_512x512.s - RISSP+SHA3 SoC: hash anh 262144 byte BANG VONG LAP
# (khong unroll) - doc tu BRAM anh rieng qua axi_bram_ctrl_1.
#
# Sinh TU DONG boi gen_loop_firmware.py - khong sua tay, sua script
# roi chay lai neu doi anh/dia chi.
#
# IMAGE_BASE = 0xc2000000 (axi_bram_ctrl_1, kiem tra lai Address
#   Editor moi lan Validate Design - neu doi, sua hang so duoi va build lai)
# SHA3_BASE  = 0x44a00000
# DEBUG_BRAM = 0xc0000000
#
# Ground truth (Python hashlib.sha3_256, 262144 byte):
#   5ded638095f4c29c78b2c9dd6f44864c7a1963a013de926ab1fe46dd5a4e326c

.section .text
.globl _start

_start:
    li   a0, 0xc2000000       # con tro dau anh (image BRAM)
    li   a2, 0xc2040000       # dia chi cuoi cung TRON 8-byte
    li   a1, 0x44a00000       # SHA3 base
    li   s0, 0xc0000000       # debug BRAM (ghi ket qua)
    li   t2, 1                 # CTRL tu thuong: iReady=1,iLast=0,ibyte=0

loop:
poll_buf_loop:
    lw   t4, 0x0C(a1)          # STATUS
    andi t4, t4, 2             # bit1 = oBuffer_full
    bnez t4, poll_buf_loop
    lw   t0, 0(a0)             # 4 byte dau -> data_hi (da dong goi big-endian trong .coe)
    lw   t1, 4(a0)             # 4 byte sau -> data_lo
    sw   t0, 0(a1)
    sw   t1, 4(a1)
    sw   t2, 8(a1)             # absorb (iReady=1,iLast=0)
    addi a0, a0, 8
    bltu a0, a2, loop

    # ---- Anh la boi so dung cua 8 -> gui 1 tu RONG bao ket thuc ----
poll_buf_final:
    lw   t4, 0x0C(a1)
    andi t4, t4, 2
    bnez t4, poll_buf_final
    li   t3, 3                 # CTRL: iReady=1,iLast=1,ibyte_num=0
    sw   x0, 0(a1)
    sw   x0, 4(a1)
    sw   t3, 8(a1)

poll_sha3:
    lw   t0, 0x0C(a1)          # STATUS: bit0=oReady
    andi t0, t0, 1
    beqz t0, poll_sha3

    # ---- Doc 8 tu digest (0x10..0x2C, MSB truoc), ghi ra debug BRAM ----
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
