/* RISSP/RV32I/Ibex: ban thay the memcpy/memset AN TOAN cho RV32I (khong
 * dung lb/lbu/sb - RV32I co bug WSTRB/funct3 khien cac lenh nay hoat dong
 * sai). Xu ly duoc CA con tro khong can chinh 4-byte va do dai bat ky. */
#include <stddef.h>

static unsigned char safe_get(const unsigned char *p) {
    unsigned long addr = (unsigned long)(const void *)p;
    unsigned int shift = (unsigned int)(addr & 3UL) * 8U;
    unsigned long waddr = addr & ~3UL;
    unsigned int wv;
#if defined(__riscv)
    __asm__ volatile ("lw %0, 0(%1)" : "=r"(wv) : "r"(waddr));
#else
    wv = *(const unsigned int *)(const void *)waddr;
#endif
    return (unsigned char)((wv >> shift) & 0xFFU);
}
static void safe_put(unsigned char *p, unsigned char v) {
    unsigned long addr = (unsigned long)(void *)p;
    unsigned int shift = (unsigned int)(addr & 3UL) * 8U;
    unsigned long waddr = addr & ~3UL;
    unsigned int mask = ~(0xFFU << shift);
    unsigned int wv;
#if defined(__riscv)
    __asm__ volatile ("lw %0, 0(%1)" : "=r"(wv) : "r"(waddr));
    wv = (wv & mask) | ((unsigned int)v << shift);
    __asm__ volatile ("sw %0, 0(%1)" : : "r"(wv), "r"(waddr) : "memory");
#else
    wv = *(unsigned int *)(void *)waddr;
    wv = (wv & mask) | ((unsigned int)v << shift);
    *(unsigned int *)(void *)waddr = wv;
#endif
}

/* Dat TEN THAT "memcpy"/"memset" (khong phai ws_memcpy) va xep truoc -lc
 * trong lenh link: linker se dung dinh nghia nay thay vi keo newlib vao,
 * bat ke loi goi la truc tiep memcpy(...)/memset(...) hay do GCC TU SINH
 * cho copy struct/mang lon (khong di qua macro XMEMCPY/XMEMSET). */
void *memcpy(void *dst, const void *src, size_t n) {
    unsigned char *d = (unsigned char *)dst;
    const unsigned char *s = (const unsigned char *)src;
    unsigned long da = (unsigned long)(void *)d, sa = (unsigned long)(const void *)s;
    size_t i = 0;
    /* Neu ca 2 con tro cung can chinh 4-byte VA n la boi so 4: dung lw/sw
     * (nhanh hon nhieu, an toan tuyet doi). */
    if (((da | sa) & 3UL) == 0) {
        unsigned int *dw = (unsigned int *)dst;
        const unsigned int *sw = (const unsigned int *)src;
        size_t nw = n >> 2;
        for (i = 0; i < nw; i++) dw[i] = sw[i];
        i <<= 2;
    }
    for (; i < n; i++) safe_put(d + i, safe_get(s + i));
    return dst;
}

void *memset(void *dst, int val, size_t n) {
    unsigned char *d = (unsigned char *)dst;
    unsigned long da = (unsigned long)(void *)d;
    unsigned char v = (unsigned char)val;
    size_t i = 0;
    if ((da & 3UL) == 0) {
        unsigned int *dw = (unsigned int *)dst;
        unsigned int vw = (unsigned int)v | ((unsigned int)v << 8) |
                           ((unsigned int)v << 16) | ((unsigned int)v << 24);
        size_t nw = n >> 2;
        for (i = 0; i < nw; i++) dw[i] = vw;
        i <<= 2;
    }
    for (; i < n; i++) safe_put(d + i, v);
    return dst;
}
