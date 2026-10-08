# test_prog.s - smoke test cho ibex_axi_top (RV32I thuan, khong C/M)
# Muc dich: di qua het cac duong du lieu quan trong cua wrapper trong 1 lan
# chay: fetch (imem shim) -> decode/execute -> LSU qua AXI shim (dmem) ->
# branch resolution -> jump. Ket qua ghi ra 3 o nho AXI de testbench tu
# doi chieu (khong doc mat).
#
# QUAN TRONG: Ibex fetch lenh dau tien tai boot_addr_i + 0x80 (reset vector
# co dinh cua Ibex, xem ibex_if_stage.sv dong 218: "PC_BOOT: fetch_addr_n =
# {boot_addr_i[31:8], 8'h80}"), KHAC voi RISSP (boot thang tai PC=0). Vi
# vay chuong trinh nay duoc link de dat tai 0x80 (xem link.ld).

.section .text
.global _start
_start:
    li   x1, 5
    li   x2, 10
    add  x3, x1, x2        # x3 = 15

    li   x10, 0x100        # dia chi co so vung nho test (qua AXI dmem)
    sw   x3, 0(x10)        # mem[0x100] = 15
    lw   x4, 0(x10)        # doc lai, x4 = 15
    addi x5, x4, 100       # x5 = 115
    sw   x5, 4(x10)        # mem[0x104] = 115

    li   x6, 0
    li   x7, 5
loop:
    addi x6, x6, 1
    bne  x6, x7, loop       # lap 5 lan -> x6 = 5
    sw   x6, 8(x10)         # mem[0x108] = 5

done:
    j    done               # dung lai, testbench tu kiem tra dmem sau day
