.section .text
.global _start
_start:
    li   x1, 5
    li   x2, 10
    add  x3, x1, x2        # x3 = 15

    li   x10, 0x100        # Test memory base address (via AXI dmem)
    sw   x3, 0(x10)        # mem[0x100] = 15
    lw   x4, 0(x10)        # doc lai, x4 = 15
    addi x5, x4, 100       # x5 = 115
    sw   x5, 4(x10)        # mem[0x104] = 115

    li   x6, 0
    li   x7, 5
loop:
    addi x6, x6, 1
    bne  x6, x7, loop       # loop 5 times -> x6 = 5
    sw   x6, 8(x10)         # mem[0x108] = 5

done:
    j    done               # ending, DMEM self-checking verification block
