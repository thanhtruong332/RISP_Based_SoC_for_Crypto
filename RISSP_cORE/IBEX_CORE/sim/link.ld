/* link.ld: 
 * Place program at offset 0x80 (Ibex hardware reset vector).
 * Note: With boot_addr_i=0, the first instruction fetch occurs at 0x80. 
 * Refer to test_prog.s for details. 
 */
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
