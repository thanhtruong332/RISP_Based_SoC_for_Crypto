/* Do chu ky wolfSSL that: AES-128 4 mode (ECB/CBC/CFB/CTR) + SHA3-256
 * 3 kich thuoc message (1/4/16 block). KHONG co RSA (do rieng, chay song
 * song voi RSA dang chay). Tat ca ghi/doc chi dung lw/sw (an toan RV32I). */
#include <wolfssl/wolfcrypt/aes.h>
#include <wolfssl/wolfcrypt/sha3.h>

#define MMIO32(addr) (*(volatile unsigned int *)(addr))
#define BRAM_BASE 0xC0000000u
#define DONE_MAGIC 0x600d0001u
#define START_MAGIC 0xc0de0002u

extern void wolfssl_init_aes_tables(void);
extern void wolfssl_init_sha3_tables(void);

static void wr(unsigned int off, unsigned int v) { MMIO32(BRAM_BASE + off) = v; }

static void write_be32(unsigned char *b, int byteOff, unsigned int be) {
    unsigned int *w32 = (unsigned int *)b;
    unsigned int le = ((be & 0xFFu) << 24) | ((be & 0xFF00u) << 8) |
                       ((be & 0xFF0000u) >> 8) | ((be >> 24) & 0xFFu);
    w32[byteOff >> 2] = le;
}
static unsigned int read_be32(const unsigned char *b, int byteOff) {
    const unsigned int *w32 = (const unsigned int *)b;
    unsigned int le = w32[byteOff >> 2];
    return ((le & 0xFFu) << 24) | ((le & 0xFF00u) << 8) |
           ((le & 0xFF0000u) >> 8) | ((le >> 24) & 0xFFu);
}
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

/* Sinh 1 CHUNK cua message[i]=(i*7+3)&0xFF, bat dau tu byte offset baseI,
 * ghi WORD-SAFE. Dung buffer NHO co dinh (khong dung 1 buffer lon dung het
 * message - buffer lon co the nam tran qua vung dia chi debug BRAM trong
 * mo hinh testbench co lap, gay ghi de ket qua - xem CLAUDE.md). */
static void gen_msg_chunk(unsigned char *buf, int baseI, int nbytes) {
    unsigned int *w32 = (unsigned int *)buf;
    int k;
    for (k = 0; k * 4 < nbytes; k++) {
        int i0 = baseI + k * 4, i1 = i0 + 1, i2 = i0 + 2, i3 = i0 + 3;
        unsigned int b0 = (unsigned int)((i0 * 7 + 3) & 0xFF);
        unsigned int b1 = (unsigned int)((i1 * 7 + 3) & 0xFF);
        unsigned int b2 = (unsigned int)((i2 * 7 + 3) & 0xFF);
        unsigned int b3 = (unsigned int)((i3 * 7 + 3) & 0xFF);
        w32[k] = b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
    }
}

#define CHUNK_SZ 136  /* boi so cua 4, <= SHA3-256 rate (136B) */
static unsigned char g_chunk[CHUNK_SZ];

static void do_sha3(int n, unsigned int startOff, unsigned int outOff) {
    static wc_Sha3 sha3;
    static unsigned char digest[32];
    int off;
    wr(startOff, START_MAGIC);
    wc_InitSha3_256(&sha3, 0, 0);
    for (off = 0; off < n; off += CHUNK_SZ) {
        int this_n = (n - off < CHUNK_SZ) ? (n - off) : CHUNK_SZ;
        gen_msg_chunk(g_chunk, off, this_n);
        wc_Sha3_256_Update(&sha3, g_chunk, (unsigned int)this_n);
    }
    wc_Sha3_256_Final(&sha3, digest);
    wr(outOff + 0, read_be32(digest, 0));
    wr(outOff + 4, read_be32(digest, 4));
    wr(outOff + 8, fold_bytes(digest, 32));
}

static Aes g_aes;
static unsigned char g_key[16], g_iv[16], g_pt[16], g_ct[16];

/* keyw/ptw: mang 4 phan tu (word32) do CALLER dung sẵn - giam so tham so
 * xuong <=8 (RV32I chi co 8 thanh ghi truyen tham so a0-a7, nghi ngo bug
 * lien quan stack-passed argument voi ham >8 tham so). */
static void do_aes(const unsigned int *keyw, const unsigned int *ivw /* NULL cho ECB */,
                    const unsigned int *ptw,
                    int mode /* 0=ECB 1=CBC 2=CFB 3=CTR */,
                    unsigned int startOff, unsigned int outOff) {
    write_be32(g_key, 0, keyw[0]); write_be32(g_key, 4, keyw[1]);
    write_be32(g_key, 8, keyw[2]); write_be32(g_key, 12, keyw[3]);
    if (ivw) {
        write_be32(g_iv, 0, ivw[0]); write_be32(g_iv, 4, ivw[1]);
        write_be32(g_iv, 8, ivw[2]); write_be32(g_iv, 12, ivw[3]);
    }
    write_be32(g_pt, 0, ptw[0]); write_be32(g_pt, 4, ptw[1]);
    write_be32(g_pt, 8, ptw[2]); write_be32(g_pt, 12, ptw[3]);
    wc_AesSetKey(&g_aes, g_key, 16, ivw ? g_iv : 0, AES_ENCRYPTION);
    wr(startOff, START_MAGIC);
    if (mode == 0) wc_AesEcbEncrypt(&g_aes, g_ct, g_pt, 16);
    else if (mode == 1) wc_AesCbcEncrypt(&g_aes, g_ct, g_pt, 16);
    else if (mode == 2) wc_AesCfbEncrypt(&g_aes, g_ct, g_pt, 16);
    else wc_AesCtrEncrypt(&g_aes, g_ct, g_pt, 16);
    wr(outOff + 0, read_be32(g_ct, 0));  wr(outOff + 4, read_be32(g_ct, 4));
    wr(outOff + 8, read_be32(g_ct, 8));  wr(outOff + 12, read_be32(g_ct, 12));
}

int main(void) {
    wolfssl_init_aes_tables();
    wolfssl_init_sha3_tables();

    /* ---- AES-128-ECB (FIPS-197 App.C.1) ---- */
    {
        unsigned int key[4], pt[4];
        key[0]=0x00010203u; key[1]=0x04050607u; key[2]=0x08090a0bu; key[3]=0x0c0d0e0fu;
        pt[0]=0x00112233u;  pt[1]=0x44556677u;  pt[2]=0x8899aabbu;  pt[3]=0xccddeeffu;
        do_aes(key, 0, pt, 0, 0x00, 0x04);
    }

    /* ---- AES-128-CBC (SP800-38A F.2.1) ---- */
    {
        unsigned int key[4], iv[4], pt[4];
        key[0]=0x2b7e1516u; key[1]=0x28aed2a6u; key[2]=0xabf71588u; key[3]=0x09cf4f3cu;
        iv[0]=0x5086cb9bu; iv[1]=0x507219eeu; iv[2]=0x95db113au; iv[3]=0x917678b2u;
        pt[0]=0x30c81c46u; pt[1]=0xa35ce411u; pt[2]=0xe5fbc119u; pt[3]=0x1a0a52efu;
        do_aes(key, iv, pt, 1, 0x14, 0x18);
    }

    /* ---- AES-128-CFB (SP800-38A F.3.13) ---- */
    {
        unsigned int key[4], iv[4], pt[4];
        key[0]=0x2b7e1516u; key[1]=0x28aed2a6u; key[2]=0xabf71588u; key[3]=0x09cf4f3cu;
        iv[0]=0x26751f67u; iv[1]=0xa3cbb140u; iv[2]=0xb1808cf1u; iv[3]=0x87a4f4dfu;
        pt[0]=0xf69f2445u; pt[1]=0xdf4f9b17u; pt[2]=0xad2b417bu; pt[3]=0xe66c3710u;
        do_aes(key, iv, pt, 2, 0x28, 0x2C);
    }

    /* ---- AES-128-CTR (SP800-38A F.5.1) ---- */
    {
        unsigned int key[4], iv[4], pt[4];
        key[0]=0x2b7e1516u; key[1]=0x28aed2a6u; key[2]=0xabf71588u; key[3]=0x09cf4f3cu;
        iv[0]=0xf0f1f2f3u; iv[1]=0xf4f5f6f7u; iv[2]=0xf8f9fafbu; iv[3]=0xfcfdff01u;
        pt[0]=0x30c81c46u; pt[1]=0xa35ce411u; pt[2]=0xe5fbc119u; pt[3]=0x1a0a52efu;
        do_aes(key, iv, pt, 3, 0x3C, 0x40);
    }

    /* ---- SHA3-256, message[i]=(i*7+3)&0xFF, 3 kich thuoc (streaming) ---- */
    do_sha3(128, 0x50, 0x54);
    do_sha3(536, 0x60, 0x64);
    do_sha3(2168, 0x70, 0x74);

    wr(0x80, DONE_MAGIC);
    while (1) { }
    return 0;
}
