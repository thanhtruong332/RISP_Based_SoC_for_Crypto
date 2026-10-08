/* link_sw.ld - dat chuong trinh tai 0x0 (imem), giong link.ld goc trong
 * D:\Viettel_semi\SE-RISSP_FULL\ - dung chung .coe duoc ca 3 loi
 * (RISSP/RV32I/Ibex boot deu tai word 0 sau khi phan cung da xu ly offset
 * rieng cua Ibex). start.S PHAI la file .o DAU TIEN trong lenh link de
 * _start nam dung tai 0x0.
 */
OUTPUT_ARCH("riscv")
ENTRY(_start)
SECTIONS
{
    . = 0x00000000;
    .text   : { *(.text.start) *(.text) *(.text.*) }

    /* Testbench CO LAP (khong phai SoC that) rut gon dia chi AXI xuong 13
     * bit (m_axi_awaddr[12:2]) khi mo phong dmem/BRAM debug - nghia la MOI
     * dia chi (kfe ca bien toan cuc o day, khong chi 0xC0000000+offset)
     * deu "vong lai" theo modulo 0x2000 (8192). Neu 1 bang/bien lon (vd
     * Tsbox 256B, hash_keccak_r) roi dung o ranh gioi 0x2000/0x4000/...,
     * phan vuot qua se de len vung marker (0x00-0x84) va lam hong ket qua -
     * da gap that (Tsbox tinh co lech dung vao 0x3ff0-0x40f0). Ep .rodata/
     * .data/.bss bat dau tai (boi so 0x2000)+0x200 (qua het vung marker,
     * con du >0x1000 byte truoc khi vong lai bucket ke) de ca khoi khong
     * bao gio vat qua 1 ranh gioi 0x2000 nao - chi la padding trong ROM
     * that (khong anh huong SoC Vivado that, co BRAM/dia chi day du). */
    . = ALIGN(0x2000);
    . = . + 0x200;
    .rodata : { *(.rodata) *(.rodata.*) }
    .data   : { *(.data)   *(.data.*)   }
    .bss    : { *(.bss)    *(.bss.*)    }
}
