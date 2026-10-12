/* link.ld - dat chuong trinh tai 0x0 (imem RISSP) */
OUTPUT_ARCH("riscv")
ENTRY(_start)
SECTIONS
{
    . = 0x00000000;
    .text   : { *(.text)   *(.text.*)   }
    .rodata : { *(.rodata) *(.rodata.*) }
    .data   : { *(.data)   *(.data.*)   }
    .bss    : { *(.bss)    *(.bss.*)    }
}
