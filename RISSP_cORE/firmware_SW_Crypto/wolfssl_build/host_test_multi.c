#include <stdio.h>
#include <string.h>
#include <wolfssl/wolfcrypt/aes.h>
#include <wolfssl/wolfcrypt/sha3.h>

extern void wolfssl_init_aes_tables(void);
extern void wolfssl_init_sha3_tables(void);

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

static Aes g_aes;
static unsigned char g_key[16], g_iv[16], g_pt[16], g_ct[16];

static void do_aes(unsigned int keyw0, unsigned int keyw1, unsigned int keyw2, unsigned int keyw3,
                    const unsigned int *ivw,
                    unsigned int ptw0, unsigned int ptw1, unsigned int ptw2, unsigned int ptw3,
                    int mode, const char *label) {
    write_be32(g_key, 0, keyw0); write_be32(g_key, 4, keyw1);
    write_be32(g_key, 8, keyw2); write_be32(g_key, 12, keyw3);
    if (ivw) {
        write_be32(g_iv, 0, ivw[0]); write_be32(g_iv, 4, ivw[1]);
        write_be32(g_iv, 8, ivw[2]); write_be32(g_iv, 12, ivw[3]);
    }
    write_be32(g_pt, 0, ptw0); write_be32(g_pt, 4, ptw1);
    write_be32(g_pt, 8, ptw2); write_be32(g_pt, 12, ptw3);
    int r1 = wc_AesSetKey(&g_aes, g_key, 16, ivw ? g_iv : 0, AES_ENCRYPTION);
    int r2 = 0;
    if (mode == 0) r2=wc_AesEcbEncrypt(&g_aes, g_ct, g_pt, 16);
    else if (mode == 1) r2=wc_AesCbcEncrypt(&g_aes, g_ct, g_pt, 16);
    else if (mode == 2) r2=wc_AesCfbEncrypt(&g_aes, g_ct, g_pt, 16);
    else r2=wc_AesCtrEncrypt(&g_aes, g_ct, g_pt, 16);
    printf("%s: setkey=%d enc=%d CT=%08x%08x%08x%08x\n", label, r1, r2,
           read_be32(g_ct,0), read_be32(g_ct,4), read_be32(g_ct,8), read_be32(g_ct,12));
}

int main(void) {
    wolfssl_init_aes_tables();
    wolfssl_init_sha3_tables();

    do_aes(0x00010203u, 0x04050607u, 0x08090a0bu, 0x0c0d0e0fu, 0,
           0x00112233u, 0x44556677u, 0x8899aabbu, 0xccddeeffu,
           0, "ECB (exp 69c4e0d86a7b0430d8cdb78070b4c55a)");

    unsigned int iv1[4]; iv1[0]=0x5086cb9bu; iv1[1]=0x507219eeu; iv1[2]=0x95db113au; iv1[3]=0x917678b2u;
    do_aes(0x2b7e1516u,0x28aed2a6u,0xabf71588u,0x09cf4f3cu, iv1,
           0x30c81c46u,0xa35ce411u,0xe5fbc119u,0x1a0a52efu,
           1, "CBC (exp 73bed6b8e3c1743b7116e69e22229516)");

    unsigned int iv2[4]; iv2[0]=0x26751f67u; iv2[1]=0xa3cbb140u; iv2[2]=0xb1808cf1u; iv2[3]=0x87a4f4dfu;
    do_aes(0x2b7e1516u,0x28aed2a6u,0xabf71588u,0x09cf4f3cu, iv2,
           0xf69f2445u,0xdf4f9b17u,0xad2b417bu,0xe66c3710u,
           2, "CFB (exp c04b05357c5d1c0eeac4c66f9ff7f2e6)");

    unsigned int iv3[4]; iv3[0]=0xf0f1f2f3u; iv3[1]=0xf4f5f6f7u; iv3[2]=0xf8f9fafbu; iv3[3]=0xfcfdff01u;
    do_aes(0x2b7e1516u,0x28aed2a6u,0xabf71588u,0x09cf4f3cu, iv3,
           0x30c81c46u,0xa35ce411u,0xe5fbc119u,0x1a0a52efu,
           3, "CTR (exp 5ae4df3edbd5d35e5b4f09020db03eab)");
    return 0;
}
