# ota_demo.s - Secure OTA Firmware Update demo tren RISSP SoC
# (SE-RISSP_AES_ULTRA: RISSP + AES + SHA3 + RSA qua AXI4-Lite)
#
# Kich ban: thiet bi bien nhan 1 "OTA blob" da ma hoa AES-CTR, kem 1 chu ky
# RSA cho hash cua payload. Firmware:
#   1. AES (CTR mode) giai ma payload nhan duoc
#   2. SHA3-256 hash payload da giai ma, XOR-fold 8 tu 32-bit thanh 1
#      checksum 32-bit
#   3. RSA verify: tinh sig^E mod N (chi can public key N,E - dung mo hinh
#      verify chuan, khong bao gio giu p,q/d tren thiet bi)
#   4. So sanh ket qua RSA voi checksum SHA3 - khop thi "cai dat" (ghi
#      payload + marker OK ra vung debug 0xC0000000), khong khop thi tu choi
#      (ghi marker BAD)
#
# AES-CTR duoc chon CHU DICH: giai ma CTR = chinh phep ma hoa CTR ap dung
# vao ciphertext (XOR doi xung voi keystream) - nen 1 loi AESEncrypt (chi
# lam chieu ma hoa) dung duoc CA 2 chieu ma hoa/giai ma cho OTA payload,
# khong can datapath giai ma rieng - dung diem manh cua kien truc CTR-mode
# cho thiet bi bien dien tich han che.
#
# Toan bo hang so duoi day da duoc cross-verify bang testbench RTL rieng
# cho tung khoi (AES: AES_CORE/tb_aes_core.v CTR case; SHA3:
# SHA3_Core/tb_sha3_core.v; RSA: RSA_Core/tb_rsa_montgomery.v) truoc khi
# ghep vao firmware nay - xem firmware_OTA/OTA.md muc "Nguon so lieu".

.section .text
.globl _start

_start:
    # ---- Base address 3 peripheral (AXI4-Lite, xem hw_handoff design_1.hwh) ----
    li   x11, 0x40000000      # AES  base
    li   x12, 0x44000000      # SHA3 base
    li   x13, 0x48000000      # RSA  base
    li   x8,  0xC0000000      # vung debug/ket qua (BRAM, giong firmware_Aes)

    # =====================================================================
    # BUOC 1: AES-CTR giai ma OTA payload nhan duoc
    # =====================================================================
    # Key AES-128 chuan FIPS-197 (da provision san tren thiet bi)
    li   x5, 0x2b7e1516
    sw   x5, 0x10(x11)        # REG_KEY_0
    li   x5, 0x28aed2a6
    sw   x5, 0x14(x11)        # REG_KEY_1
    li   x5, 0xabf71588
    sw   x5, 0x18(x11)        # REG_KEY_2
    li   x5, 0x09cf4f3c
    sw   x5, 0x1C(x11)        # REG_KEY_3

    # Initial counter (IV) cho CTR mode - dong bo giua 2 dau (thiet bi + server)
    li   x5, 0xf0f1f2f3
    sw   x5, 0x40(x11)        # REG_IV_0
    li   x5, 0xf4f5f6f7
    sw   x5, 0x44(x11)        # REG_IV_1
    li   x5, 0xf8f9fafb
    sw   x5, 0x48(x11)        # REG_IV_2
    li   x5, 0xfcfdfeff
    sw   x5, 0x4C(x11)        # REG_IV_3

    # OTA ciphertext nhan duoc (16 byte, 1 block demo - firmware that se
    # lap block nay nhieu lan cho payload lon hon, counter tu tang moi block)
    li   x5, 0x874d6191
    sw   x5, 0x00(x11)        # REG_DATA_IN_0
    li   x5, 0xb620e326
    sw   x5, 0x04(x11)        # REG_DATA_IN_1
    li   x5, 0x1bef6864
    sw   x5, 0x08(x11)        # REG_DATA_IN_2
    li   x5, 0x990db6ce
    sw   x5, 0x0C(x11)        # REG_DATA_IN_3

    li   x5, 0x5              # start=1, mode=10 (CTR)
    sw   x5, 0x20(x11)        # REG_CONTROL

poll_aes:
    lw   x5, 0x24(x11)        # REG_STATUS
    andi x5, x5, 1
    beqz x5, poll_aes

    # Doc payload da giai ma - giu lai trong x20-x23 de dung cho SHA3 + ghi ket qua
    lw   x20, 0x30(x11)       # REG_DATA_OUT_0
    lw   x21, 0x34(x11)       # REG_DATA_OUT_1
    lw   x22, 0x38(x11)       # REG_DATA_OUT_2
    lw   x23, 0x3C(x11)       # REG_DATA_OUT_3

    # =====================================================================
    # BUOC 2: SHA3-256 hash payload vua giai ma (16 byte = dung 2 tu 64-bit,
    # ranh gioi block -> can gui them 1 "tu rong" iByte_num=0 de core tu
    # chen padding, dung giao thuc da xac nhan trong SHA3_Core/SHA3.md)
    # =====================================================================
    li   x6, 1                 # control = iReady=1,iLast=0,ibyte=0

    sw   x20, 0x00(x12)        # data_hi = payload[127:96]
    sw   x21, 0x04(x12)        # data_lo = payload[95:64]
    sw   x6,  0x08(x12)        # absorb tu 1/2

    sw   x22, 0x00(x12)        # data_hi = payload[63:32]
    sw   x23, 0x04(x12)        # data_lo = payload[31:0]
    sw   x6,  0x08(x12)        # absorb tu 2/2

    li   x7, 3                 # control = iReady=1,iLast=1,ibyte_num=0
    sw   x0, 0x00(x12)         # tu rong (khong dung du lieu, chi kich padding)
    sw   x0, 0x04(x12)
    sw   x7, 0x08(x12)         # absorb tu dem cuoi (kich padding + permutation)

poll_sha3:
    lw   x5, 0x0C(x12)         # STATUS: bit0 = oReady
    andi x5, x5, 1
    beqz x5, poll_sha3

    # Doc 8 tu digest (0x10..0x2C, MSB truoc) va XOR-fold thanh 1 checksum 32-bit
    lw   x24, 0x10(x12)        # x24 = digest word0 (khoi tao fold)
    lw   x25, 0x14(x12)
    xor  x24, x24, x25
    lw   x25, 0x18(x12)
    xor  x24, x24, x25
    lw   x25, 0x1C(x12)
    xor  x24, x24, x25
    lw   x25, 0x20(x12)
    xor  x24, x24, x25
    lw   x25, 0x24(x12)
    xor  x24, x24, x25
    lw   x25, 0x28(x12)
    xor  x24, x24, x25
    lw   x25, 0x2C(x12)
    xor  x24, x24, x25
    # x24 = checksum SHA3 (fold 256-bit -> 32-bit) cua payload da giai ma

    # =====================================================================
    # BUOC 3: RSA verify chu ky - thiet bi CHI can public key (N,E), khong
    # bao gio giu p,q/d. sig duoc ky OFFLINE (server, dung d bi mat) tu
    # truoc, nap san nhu hang so trong firmware nay.
    # =====================================================================
    li   x5, 0x4a610a6f
    sw   x5, 0x00(x13)         # M = chu ky (signature) nhan kem OTA blob
    li   x5, 0x00010001        # E = 65537 - so mu cong khai chuan cong nghiep
    sw   x5, 0x04(x13)
    li   x5, 0xffe000ff        # N = modulus cong khai (p*q, p,q KHONG luu tren thiet bi)
    sw   x5, 0x08(x13)
    li   x5, 0xc0e10101        # N_INV = -N^-1 mod 2^32 (tinh san offline)
    sw   x5, 0x0C(x13)
    li   x5, 0x403d0201        # R2_MOD_N = 2^64 mod N (tinh san offline)
    sw   x5, 0x10(x13)

    li   x6, 1
    sw   x6, 0x14(x13)         # CTRL: start=1

poll_rsa:
    lw   x5, 0x18(x13)         # STATUS: bit0 = done
    andi x5, x5, 1
    beqz x5, poll_rsa

    lw   x27, 0x1C(x13)        # x27 = RESULT = sig^E mod N

    # =====================================================================
    # BUOC 4: so sanh - khop thi xac thuc thanh cong, "cai dat" firmware
    # =====================================================================
    bne  x27, x24, reject

install:
    sw   x20, 0x00(x8)         # ghi payload da xac thuc ra vung debug/"flash"
    sw   x21, 0x04(x8)
    sw   x22, 0x08(x8)
    sw   x23, 0x0C(x8)
    li   x28, 0x600d600d       # marker: xac thuc THANH CONG
    sw   x28, 0x10(x8)
    j    halt

reject:
    li   x28, 0xbad0bad0       # marker: xac thuc THAT BAI - khong cai dat
    sw   x28, 0x10(x8)

halt:
    j    halt                  # vong lap vo han, dung o day
