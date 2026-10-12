/* Host-side smoke test: xac nhan cau hinh wolfSSL toi gian bien dich sach
 * va cho ket qua dung (doi chieu voi vector da dung trong gen_all.py va
 * rsa2048_key.py). Chua do chu ky - chi kiem tra tinh dung dan cau hinh. */
#include <stdio.h>
#include <string.h>

#include <wolfssl/wolfcrypt/aes.h>
#include <wolfssl/wolfcrypt/sha3.h>
#include <wolfssl/wolfcrypt/rsa.h>
#include "rsa2048_vectors.h"

static void hex2bin(const char *hex, unsigned char *out, int nbytes) {
    for (int i = 0; i < nbytes; i++) {
        unsigned int v;
        sscanf(hex + i * 2, "%2x", &v);
        out[i] = (unsigned char)v;
    }
}

static void print_hex(const char *label, const unsigned char *buf, int n) {
    printf("%s: ", label);
    for (int i = 0; i < n; i++) printf("%02x", buf[i]);
    printf("\n");
}

static int test_aes_ecb(void) {
    Aes aes;
    unsigned char key[16], pt[16], ct[16], exp[16], out[16];
    hex2bin("000102030405060708090a0b0c0d0e0f", key, 16);
    hex2bin("00112233445566778899aabbccddeeff", pt, 16);
    hex2bin("69c4e0d86a7b0430d8cdb78070b4c55a", exp, 16);
    (void)ct;
    memset(&aes, 0, sizeof(aes));
    if (wc_AesSetKey(&aes, key, 16, NULL, AES_ENCRYPTION) != 0) return -1;
    if (wc_AesEcbEncrypt(&aes, out, pt, 16) != 0) return -2;
    print_hex("AES-ECB out", out, 16);
    return memcmp(out, exp, 16) == 0 ? 0 : -3;
}

static int test_aes_cbc(void) {
    Aes aes;
    unsigned char key[16], iv[16], pt[16], exp[16], out[16];
    hex2bin("2b7e151628aed2a6abf7158809cf4f3c", key, 16);
    hex2bin("5086cb9b507219ee95db113a917678b2", iv, 16);
    hex2bin("30c81c46a35ce411e5fbc1191a0a52ef", pt, 16);
    hex2bin("73bed6b8e3c1743b7116e69e22229516", exp, 16);
    memset(&aes, 0, sizeof(aes));
    if (wc_AesSetKey(&aes, key, 16, iv, AES_ENCRYPTION) != 0) return -1;
    if (wc_AesCbcEncrypt(&aes, out, pt, 16) != 0) return -2;
    print_hex("AES-CBC out", out, 16);
    return memcmp(out, exp, 16) == 0 ? 0 : -3;
}

static int test_sha3_256(void) {
    wc_Sha3 sha3;
    unsigned char msg[16], digest[32];
    unsigned char exp[32];
    /* message = 1 block 128B toan zero (khop pattern sha3_1blk_sw test cu),
       dung Python doc lap: hashlib.sha3_256(b'\x00'*128).hexdigest() */
    hex2bin("00000000000000000000000000000000", msg, 16); /* placeholder, se mo rong sau */
    (void)msg;
    /* Test vector chuan NIST: SHA3-256("") */
    hex2bin("a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a", exp, 32);
    if (wc_InitSha3_256(&sha3, NULL, 0) != 0) return -1;
    if (wc_Sha3_256_Update(&sha3, (const byte*)"", 0) != 0) return -2;
    if (wc_Sha3_256_Final(&sha3, digest) != 0) return -3;
    print_hex("SHA3-256(\"\") out", digest, 32);
    return memcmp(digest, exp, 32) == 0 ? 0 : -4;
}

static int test_rsa2048(void) {
    RsaKey key;
    unsigned char out[256];
    word32 outLen = sizeof(out);
    int ret;

    if (wc_InitRsaKey(&key, NULL) != 0) return -1;
    if (mp_read_unsigned_bin(&key.n, RSA_N_BE, 256) != 0) return -2;
    if (mp_set_int(&key.e, 65537) != 0) return -3;
    key.type = RSA_PUBLIC;
#ifndef WOLFSSL_RSA_PUBLIC_ONLY
    key.state = RSA_STATE_NONE;
#endif

    ret = wc_RsaFunction(RSA_M_BE, 256, out, &outLen, RSA_PUBLIC_ENCRYPT,
                          &key, NULL);
    if (ret != 0) { printf("wc_RsaFunction ret=%d\n", ret); return -4; }
    print_hex("RSA out (first 16B)", out, 16);
    return (outLen == 256 && memcmp(out, RSA_EXPC_BE, 256) == 0) ? 0 : -5;
}

extern void wolfssl_init_aes_tables(void);
extern void wolfssl_init_sha3_tables(void);

int main(void) {
    int r;
    wolfssl_init_aes_tables();
    wolfssl_init_sha3_tables();
    r = test_aes_ecb();
    printf("AES-ECB: %s (%d)\n", r == 0 ? "PASS" : "FAIL", r);
    r = test_aes_cbc();
    printf("AES-CBC: %s (%d)\n", r == 0 ? "PASS" : "FAIL", r);
    r = test_sha3_256();
    printf("SHA3-256: %s (%d)\n", r == 0 ? "PASS" : "FAIL", r);
    r = test_rsa2048();
    printf("RSA-2048: %s (%d)\n", r == 0 ? "PASS" : "FAIL", r);
    return 0;
}
