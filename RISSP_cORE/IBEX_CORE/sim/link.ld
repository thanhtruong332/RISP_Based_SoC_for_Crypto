/* link.ld - dat chuong trinh tai 0x80 = reset vector that su cua Ibex
   (boot_addr_i=0 -> fetch dau tien tai 0x80, xem ghi chu trong test_prog.s) */
OUTPUT_ARCH("riscv")
ENTRY(_start)

SECTIONS
{
    . = 0x00000080;

    .text : {
        *(.text)
        *(.text.*)
    }

    .rodata : {
        *(.rodata)
        *(.rodata.*)
    }

    .data : {
        *(.data)
        *(.data.*)
    }

    .bss : {
        *(.bss)
        *(.bss.*)
    }
}
