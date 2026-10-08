/* Firmware kiem tra wolfSSL that tren RTL RISSP (isolated testbench).
 * AES-128-ECB + SHA3-256("") + RSA-2048 cong khai, ghi ket qua ra BRAM
 * debug 0xC0000000 de testbench doc va so sanh. */
#include <wolfssl/wolfcrypt/aes.h>
#include <wolfssl/wolfcrypt/sha3.h>
#include <wolfssl/wolfcrypt/rsa.h>
#include "rsa2048_vectors.h"

#define MMIO32(addr) (*(volatile unsigned int *)(addr))
#define BRAM_BASE 0xC0000000u
#define DONE_MAGIC 0x600d0001u
#define START_MAGIC 0xc0de0002u

extern void wolfssl_init_aes_tables(void);
extern void wolfssl_init_sha3_tables(void);
extern void wolfssl_init_rsa_vectors(void);

static void wr(unsigned int off, unsigned int v) { MMIO32(BRAM_BASE + off) = v; }

/* RV32I: doc tung byte (lbu) tra ve CA TU (bug WSTRB/funct3), nen phai
 * doc bang WORD (lw) qua con tro word32* roi tach byte trong thanh ghi. */
static unsigned int fold_bytes(const unsigned char *b, int n) {
    unsigned int acc = 0;
    const unsigned int *w32 = (const unsigned int *)b;
    int i;
    for (i = 0; i + 3 < n; i += 4) {
        unsigned int le = w32[i >> 2];
        unsigned int be = ((le & 0xFFu) << 24) | ((le & 0xFF00u) << 8) |
                           ((le & 0xFF0000u) >> 8) | ((le >> 24) & 0xFFu);
        acc ^= be;
    }
    return acc;
}

/* Doc 1 tu 32-bit big-endian tu mang byte word-aligned, AN TOAN tren RV32I
 * (chi dung lw qua con tro word32*, khong dung lbu). byteOff PHAI la boi
 * so cua 4. */
static unsigned int read_be32(const unsigned char *b, int byteOff) {
    const unsigned int *w32 = (const unsigned int *)b;
    unsigned int le = w32[byteOff >> 2];
    return ((le & 0xFFu) << 24) | ((le & 0xFF00u) << 8) |
           ((le & 0xFF0000u) >> 8) | ((le >> 24) & 0xFFu);
}

/* Ghi 1 tu 32-bit big-endian vao mang byte word-aligned, AN TOAN tren
 * RV32I (chi dung sw qua con tro word32*, khong dung sb - sb tren RV32I
 * ghi nham ca 4 byte, pha du lieu ben canh). byteOff phai la boi so cua 4. */
static void write_be32(unsigned char *b, int byteOff, unsigned int be) {
    unsigned int *w32 = (unsigned int *)b;
    unsigned int le = ((be & 0xFFu) << 24) | ((be & 0xFF00u) << 8) |
                       ((be & 0xFF0000u) >> 8) | ((be >> 24) & 0xFFu);
    w32[byteOff >> 2] = le;
}

int main(void) {
    wr(0x60, 1u);
    wolfssl_init_aes_tables();
    wr(0x60, 2u);
    wolfssl_init_sha3_tables();
    wr(0x60, 3u);
    wolfssl_init_rsa_vectors();
    wr(0x60, 4u);

    /* PHA 1 SETUP - ngoai cua so PURE. Gan RUNTIME tung phan tu (KHONG
     * dung aggregate initializer) - mang co initializer se nam trong .data,
     * ma SoC nay khong co buoc copy .data tu ROM sang RAM luc boot (xem
     * start.S), nen initializer se khong bao gio duoc nap dung. */
    static Aes aes;
    static unsigned char key[16];
    static unsigned char pt[16];
    static unsigned char ct[16];
    write_be32(key, 0, 0x00010203u); write_be32(key, 4, 0x04050607u);
    write_be32(key, 8, 0x08090a0bu); write_be32(key, 12, 0x0c0d0e0fu);
    write_be32(pt, 0, 0x00112233u);  write_be32(pt, 4, 0x44556677u);
    write_be32(pt, 8, 0x8899aabbu);  write_be32(pt, 12, 0xccddeeffu);
    wr(0x60, 5u);
    wc_AesSetKey(&aes, key, 16, 0, AES_ENCRYPTION);
    wr(0x60, 6u);

    static wc_Sha3 sha3;
    static unsigned char digest[32];

    static RsaKey rkey;
    static unsigned char rsa_out[256];
    unsigned int rsaOutLen = sizeof(rsa_out);
    {
        int r1 = wc_InitRsaKey(&rkey, 0);
        int r1b = mp_init(&rkey.n);
        wr(0x5C, (unsigned int)rkey.n.size);  /* ngay sau mp_init, TRUOC read_bin */
        int r1c = mp_init(&rkey.e);
        int r2 = mp_read_unsigned_bin(&rkey.n, RSA_N_BE, 256);
        int r3 = mp_set_int(&rkey.e, 65537);
        wr(0x40, (unsigned int)r1);
        wr(0x44, (unsigned int)r2);
        wr(0x48, (unsigned int)r3);
        wr(0x4C, (unsigned int)r1b);
        wr(0x50, (unsigned int)r1c);
        wr(0x54, (unsigned int)rkey.n.size);
        wr(0x58, (unsigned int)sizeof(rkey.n.dp) / sizeof(rkey.n.dp[0]));
    }
    wr(0x60, 7u);
    rkey.type = RSA_PUBLIC;

    /* PHA 2 OP - CUA SO PURE */
    wr(0x14, START_MAGIC);

    wc_AesEcbEncrypt(&aes, ct, pt, 16);
    wr(0x60, 8u);

    wc_InitSha3_256(&sha3, 0, 0);
    wr(0x60, 9u);
    wc_Sha3_256_Update(&sha3, 0, 0);  /* len=0 -> con tro khong bao gio duoc doc */
    wr(0x60, 10u);
    wc_Sha3_256_Final(&sha3, digest);
    wr(0x60, 11u);

    {
        int rsa_ret = wc_RsaFunction(RSA_M_BE, 256, rsa_out, &rsaOutLen,
                                      RSA_PUBLIC_ENCRYPT, &rkey, 0);
        wr(0x38, (unsigned int)rsa_ret);
        wr(0x3C, rsaOutLen);
    }
    wr(0x60, 12u);

    /* PHA 3 STORE - ngoai cua so PURE */
    wr(0x00, read_be32(ct, 0));
    wr(0x04, read_be32(ct, 4));
    wr(0x08, read_be32(ct, 8));
    wr(0x0C, read_be32(ct, 12));

    wr(0x20, read_be32(digest, 0));
    wr(0x24, read_be32(digest, 4));
    wr(0x28, fold_bytes(digest, 32));  /* fold toan bo 32 byte de kiem tra nhanh */

    wr(0x30, fold_bytes(rsa_out, 256)); /* fold toan bo 256 byte ket qua RSA */
    wr(0x34, read_be32(rsa_out, 0));

    wr(0x10, DONE_MAGIC);
    while (1) { }
    return 0;
}
