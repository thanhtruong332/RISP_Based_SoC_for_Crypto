/* user_settings.h — cau hinh toi gian cho RISSP/RV32I/Ibex bare-metal
 * Chi bat: AES (ECB/CBC/CFB/CTR/DIRECT) + SHA3-256 + RSA (raw modexp).
 * Tat ca TLS/ECC/DH/Curve25519/certs/filesystem/RNG-that deu tat. */
#ifndef WOLFSSL_USER_SETTINGS_H
#define WOLFSSL_USER_SETTINGS_H

#ifdef __cplusplus
extern "C" {
#endif

#define WOLFSSL_GENERAL_ALIGNMENT   4
#define SINGLE_THREADED
#define WOLFSSL_USER_IO
#define NO_INLINE   /* misc.c compiled rieng, khong inline (de kiem soat) */

/* ---- Math: dung Single Precision, ban SMALL (portable C, khong asm) ---- */
#define SIZEOF_LONG_LONG 8
#define WOLFSSL_SP
#define WOLFSSL_SP_SMALL
#define SP_WORD_SIZE 32
#define WOLFSSL_SP_MATH
#define WOLFSSL_SP_NO_MALLOC   /* dung stack, khong can heap cho SP math */

/* ---- RSA ---- */
#undef NO_RSA
#define WOLFSSL_HAVE_SP_RSA
#define WC_RSA_BLINDING_OFF   /* khong dung, xem WC_NO_HARDEN duoi */
#define WC_NO_HARDEN          /* bo blinding -> khong can RNG that cho RSA cong khai */
#define WOLFSSL_RSA_PUBLIC_ONLY /* chi can wc_RsaFunction ham cong khai (M^e mod N) */
#define FP_MAX_BITS (2048*2)
#define WC_NO_RSA_OAEP   /* khong dung OAEP/PSS -> khong can RsaMGF1/hash phu */
#define WOLFSSL_SP_NO_3072  /* chi can 2048-bit, bo code sp_c32.c cho 3072 */
#define WOLFSSL_SP_NO_4096
#define SP_INT_BITS 2080    /* du bien cho 2048-bit N (tranh loi bien MP_VAL) */

/* ---- Tat ECC/DH/Curve25519 ---- */
#define NO_DH
#define NO_ECC_KEY
#define HAVE_NO_ECC
#define NO_ECC
#undef HAVE_ECC

/* ---- AES ---- */
#undef NO_AES
#define NO_AES_DECRYPT   /* mode nao cung chi ma hoa, khong can Td/Td4 (4KB rodata) */
#define WOLFSSL_AES_SMALL_TABLES /* Sbox 256B thay vi Te[4][256]=4KB -> it code khoi tao hon nhieu */
#define WC_NO_CACHE_RESISTANT /* tat "touch all cache lines" - khong can chong timing-attack
                                 trong mo phong RTL, va giu GetTable8 don gian de va (1 doc/1 vi tri
                                 thay vi 16) */
#define HAVE_AES_ECB
#define HAVE_AES_CBC
#define WOLFSSL_AES_DIRECT
#define WOLFSSL_AES_COUNTER
#define WOLFSSL_AES_CFB
#undef HAVE_AESGCM
#undef HAVE_AESCCM

/* ---- SHA3 ---- */
#undef WOLFSSL_SHA3
#define WOLFSSL_SHA3
#define WOLFSSL_NOSHA3_224
#define WOLFSSL_NOSHA3_384
#define WOLFSSL_NOSHA3_512

/* ---- Tat cac thuat toan khong dung ---- */
#define NO_MD5
#define NO_SHA
#define NO_SHA256   /* SP RSA co the can SHA256 cho 1 so path; bat lai neu loi link */
#define NO_DES3
#define NO_RC4
#define NO_PSK
#define NO_PWDBASED
#define NO_DSA
#define NO_MD4
#define WOLFCRYPT_ONLY
#define NO_WOLFSSL_SERVER
#define NO_WOLFSSL_CLIENT
#define NO_CRYPT_TEST
#define NO_CRYPT_BENCHMARK
#define NO_SESSION_CACHE
#define NO_FILESYSTEM
#define NO_WRITEV
#define NO_MAIN_DRIVER
#define NO_DEV_RANDOM
#define NO_ASN_TIME
#define NO_CERTS
#define NO_SIG_WRAPPER
#define NO_CODING       /* khong can base64 */
#define WOLFSSL_NO_ASM

/* ---- Bo nho: khong dung malloc chuan (bare-metal), tu cap phat tinh ---- */
#define XMALLOC_OVERRIDE
#include <stddef.h>
extern void *ws_malloc(size_t n);
extern void ws_free(void *p);
#define XMALLOC(n, h, t)     ws_malloc(n)
#define XFREE(p, h, t)       ws_free(p)
#define XREALLOC(p, n, h, t) ((void)0)  /* khong dung realloc */

/* RV32I: memcpy/memset cua newlib co the sinh lb/lbu/sb cho phan du. Thay
 * vi chi doi ten qua macro XMEMCPY/XMEMSET (khong bat duoc loi goi GCC TU
 * SINH cho copy struct/mang lon), dinh nghia LAI CHINH "memcpy"/"memset"
 * (xem ws_memops.c) va xep TRUOC -lc trong lenh link de linker uu tien
 * ban nay, bat ke loi goi tu dau. XMEMCPY/XMEMSET giu mac dinh = memcpy/
 * memset (se tu tro ve ham cua chung ta). */

/* ---- RNG: khong can that (chi dung RSA cong khai, khong blinding) ---- */
#define WC_NO_RNG
#define WC_NO_HASHDRBG

/* RISSP/RV32I/Ibex: ca 3 loi KHONG ho tro lenh FENCE. ForceZero() dung
 * XFENCE() ("fence" tren RISC-V) chi de chong compiler toi uu mat lenh xoa -
 * khong can thiet cho build do luong hieu nang nay (single-thread, khong
 * ngat). WOLFSSL_NO_FENCE ep XFENCE() thanh no-op. (Lan dau bat macro nay
 * tuong nham la nguyen nhan treo may tren RISSP - hoa ra do 1 bug KHAC
 * (Tsbox vat ranh gioi 0x2000 trong testbench co lap, da sua o link_sw.ld);
 * WOLFSSL_NO_FENCE tu no vo hai, bat lai o day.) */
#define WOLFSSL_NO_FENCE

/* ---- Debug/logging: tat het cho gon code ---- */
#define NO_ERROR_STRINGS
#define WOLFSSL_NO_ASM

#ifdef __cplusplus
}
#endif

#endif /* WOLFSSL_USER_SETTINGS_H */
