# start.S - entry point toi gian cho firmware phan mem thuan (khong OS).
# CHI dung LUI/ADDI (qua pseudo-op 'li') va JAL - ca 2 deu trong 35 lenh
# RISSP ho tro. sp tro vao DINH vung BRAM debug 8KB (0xC0000000-0xC0001FFF)
# vi day la vung nho doc/ghi DUY NHAT co that trong SoC (khong co dmem
# rieng) - xem sw_common.h.
.section .text.start
.global _start
_start:
    li   sp, 0xC0002000
    jal  ra, main
halt:
    j    halt
