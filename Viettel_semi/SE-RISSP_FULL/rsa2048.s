# rsa2048.s - RSA-2048 verify tren SE-RISSP_AES_ULTRA
# Sinh tu dong boi gen_all.py - KHONG sua tay (sua gen_all.py roi chay lai).
#
# SoC: SE-RISSP_AES_ULTRA  (RISSP + AES + SHA3 + RSA qua AXI4-Lite)
#   AES  @ 0x40000000   SHA3 @ 0x44000000
#   RSA  @ 0x48000000   BRAM debug @ 0xC0000000 (blk_mem_gen_1)
#
# YEU CAU: Block Design phai da BO TICK "Register PortA Output of Memory
# Primitives" tren blk_mem_gen_0 (imem 1 chu ky - dung hop dong cua
# fetch_stage.v). Firmware nay dung vong lap poll (co nhanh re) nen se
# TREO neu imem con 2 chu ky.
#
# Toi uu de so lieu do duoc phan anh dung hieu nang that:
#   - Cho bang POLL STATUS, khong phai NOP padding -> khong tinh du chu ky
#   - KHONG cho sau khi ghi KEY (AESEncrypt tu doi keys_valid qua start_req)
#   - Moi gia tri chi doc 1 lan (bo ky thuat "doc 2 lan" - workaround cu
#     cho imem 2 chu ky, khong con can)
#
# Moi mode test 1 CASE (1 block 128-bit) theo test vector NIST SP800-38A.
#
# ==========================================================================
# HOP DONG "SO SANH CONG BANG" - firmware nay phai chay duoc tren CORE KHAC
# (RV32I chuan / Ibex / CVA6) de so sanh, nen bat buoc tuan thu:
#
#  1. CHI dung RV32I co ban: addi andi beqz blt j li lw nop sw xor.
#     KHONG dung lenh/pseudo-op nao ngoai tap nay. KHONG M/A/F/C extension.
#     (Tien the: RISSP khong ho tro LH/LHU - nhung ta cung khong dung, nen
#      cung 1 file .s chay duoc tren ca hai.)
#  2. KHONG dua vao dac tinh rieng cua RISSP: khong gia dinh single-cycle,
#     khong gia dinh do tre imem, khong dung ky thuat "doc 2 lan".
#     Cho phan cung xong = POLL STATUS, khong dem chu ky bang NOP.
#  3. CUNG MOT CAU TRUC 3 PHA cho ca 3 lo, de cua so PURE co cung y nghia:
#       PHA 1 SETUP  - nap tham so CO DINH (khoa AES, N/E/N_INV/R2 cua RSA).
#                      NGOAI cua so do. He that nap 1 lan luc khoi dong.
#       PHA 2 OP     - nap du lieu BIEN THIEN, start, poll, doc ket qua.
#                      <== DAY LA CUA SO PURE duoc do
#       PHA 3 STORE  - ghi ket qua ra BRAM + marker. NGOAI cua so PURE.
#  4. Moc do nam tren AXI/BRAM (ngoai CPU), KHONG probe tin hieu noi bo CPU
#     -> doi CPU khac van do duoc bang dung testbench, khong sua gi.
#  5. Khong chen NOP padding tuy tien o bat ky dau.
# ==========================================================================
#
# CHUC NANG: RSA-2048 verify - tinh C = M^65537 mod N (Montgomery word-serial).
#
# KHAC HAN ban 32-bit cu: moi toan hang la 64 tu 32-bit, nap qua 64 lan ghi
# AXI vao vung dia chi rieng (xem ban do o duoi). Wrapper gom lai thanh 1
# thanh ghi rong 2048-bit roi dua vao loi.
#
# BAN DO THANH GHI (wrapper moi, C_S_AXI_ADDR_WIDTH=12):
#   0x000-0x0FC  W  M [0..63]      0x300  W  E      (65537)
#   0x100-0x1FC  W  N [0..63]      0x304  W  N_INV  (-N^-1 mod 2^32)
#   0x200-0x2FC  W  R2[0..63]      0x308  W  CTRL   (bit0 = start)
#   0x400-0x4FC  R  RESULT[0..63]  0x30C  R  STATUS (bit0 = done)
#
# PHA 1 SETUP nap N, R2, E, N_INV - deu la tham so CUA KHOA, khong doi giua
# cac lan verify -> NGOAI cua so PURE (he that nap 1 lan luc khoi dong).
# PHA 2 OP nap M (64 tu) + start + poll + doc 64 tu ket qua.
#
# KIEM TRA: thay vi ghi ca 64 tu ra BRAM, firmware tinh XOR-fold cua ca 64
# tu roi ghi 4 tu dau + 4 tu cuoi + fold. Sai 1 bit bat ky cung lam fold lech.
#
# KET QUA ghi ra BRAM 0xC0000000:
#   0x00-0x0C  RESULT[0..3]   ky vong b3bc622e 5476ecf0 0955af40 215a31d3
#   0x10-0x1C  RESULT[60..63] ky vong ccd2ad48 8f5d434e 698827d0 3b12b00d
#   0x20       XOR-fold ca 64 tu, ky vong 8adddfa5
#   0x30       marker = 0x600D0007
.section .text
.globl _start
_start:
    li   x13, 0x48000000
    li   x8, 0xC0000000

    # === PHA 1: SETUP - nap KHOA CONG KHAI (130 tu, ngoai cua so do) ===
    # --- N[0..63] ---
    li   x5, 0xe49f31a1
    sw   x5, 0x100(x13)    # N[0]
    li   x5, 0xff172739
    sw   x5, 0x104(x13)
    li   x5, 0x2d37e0d6
    sw   x5, 0x108(x13)
    li   x5, 0xe7f0d8dc
    sw   x5, 0x10C(x13)
    li   x5, 0x04134fd2
    sw   x5, 0x110(x13)
    li   x5, 0x1fdeec63
    sw   x5, 0x114(x13)
    li   x5, 0x656cc5ee
    sw   x5, 0x118(x13)
    li   x5, 0xd82906b1
    sw   x5, 0x11C(x13)
    li   x5, 0xfa3f48cc
    sw   x5, 0x120(x13)
    li   x5, 0xe7fb49c6
    sw   x5, 0x124(x13)
    li   x5, 0x5be95a03
    sw   x5, 0x128(x13)
    li   x5, 0xf6f0e9e2
    sw   x5, 0x12C(x13)
    li   x5, 0xb8734778
    sw   x5, 0x130(x13)
    li   x5, 0x95adf0a9
    sw   x5, 0x134(x13)
    li   x5, 0x45bd88ed
    sw   x5, 0x138(x13)
    li   x5, 0x9d40a5ea
    sw   x5, 0x13C(x13)
    li   x5, 0x01d3d49a
    sw   x5, 0x140(x13)
    li   x5, 0x7d5c3860
    sw   x5, 0x144(x13)
    li   x5, 0xa5c2a1fa
    sw   x5, 0x148(x13)
    li   x5, 0x1e16e101
    sw   x5, 0x14C(x13)
    li   x5, 0x8ce26826
    sw   x5, 0x150(x13)
    li   x5, 0xcaa4fb2f
    sw   x5, 0x154(x13)
    li   x5, 0x3fd7ae43
    sw   x5, 0x158(x13)
    li   x5, 0x5db8c8a7
    sw   x5, 0x15C(x13)
    li   x5, 0xf1a514e1
    sw   x5, 0x160(x13)
    li   x5, 0x40ef017a
    sw   x5, 0x164(x13)
    li   x5, 0x3f377836
    sw   x5, 0x168(x13)
    li   x5, 0xd3c4c976
    sw   x5, 0x16C(x13)
    li   x5, 0x29a20d2a
    sw   x5, 0x170(x13)
    li   x5, 0xed34ff1c
    sw   x5, 0x174(x13)
    li   x5, 0xe456aae4
    sw   x5, 0x178(x13)
    li   x5, 0xa5dcebbb
    sw   x5, 0x17C(x13)
    li   x5, 0xeb81c194
    sw   x5, 0x180(x13)
    li   x5, 0x3c111d6e
    sw   x5, 0x184(x13)
    li   x5, 0xe0acbbed
    sw   x5, 0x188(x13)
    li   x5, 0x35d26854
    sw   x5, 0x18C(x13)
    li   x5, 0x1a323c73
    sw   x5, 0x190(x13)
    li   x5, 0xd01245af
    sw   x5, 0x194(x13)
    li   x5, 0xd0aa4cef
    sw   x5, 0x198(x13)
    li   x5, 0x776a0851
    sw   x5, 0x19C(x13)
    li   x5, 0xfe2a6820
    sw   x5, 0x1A0(x13)
    li   x5, 0x5755a08c
    sw   x5, 0x1A4(x13)
    li   x5, 0x1e207121
    sw   x5, 0x1A8(x13)
    li   x5, 0x842237c6
    sw   x5, 0x1AC(x13)
    li   x5, 0xc8349bf2
    sw   x5, 0x1B0(x13)
    li   x5, 0x95bfe6c4
    sw   x5, 0x1B4(x13)
    li   x5, 0xd1fc4736
    sw   x5, 0x1B8(x13)
    li   x5, 0xb2fdec41
    sw   x5, 0x1BC(x13)
    li   x5, 0xcfa35862
    sw   x5, 0x1C0(x13)
    li   x5, 0x387b41e1
    sw   x5, 0x1C4(x13)
    li   x5, 0xc477a3b5
    sw   x5, 0x1C8(x13)
    li   x5, 0x5a450d10
    sw   x5, 0x1CC(x13)
    li   x5, 0x19d57e17
    sw   x5, 0x1D0(x13)
    li   x5, 0x0e7dceca
    sw   x5, 0x1D4(x13)
    li   x5, 0xed90e66b
    sw   x5, 0x1D8(x13)
    li   x5, 0x28e28efc
    sw   x5, 0x1DC(x13)
    li   x5, 0x8f787c2e
    sw   x5, 0x1E0(x13)
    li   x5, 0x1ab57137
    sw   x5, 0x1E4(x13)
    li   x5, 0x415e6403
    sw   x5, 0x1E8(x13)
    li   x5, 0x708434fa
    sw   x5, 0x1EC(x13)
    li   x5, 0x88c8773c
    sw   x5, 0x1F0(x13)
    li   x5, 0x0b41376c
    sw   x5, 0x1F4(x13)
    li   x5, 0xd6a308df
    sw   x5, 0x1F8(x13)
    li   x5, 0x85f99c54
    sw   x5, 0x1FC(x13)    # N[63]

    # --- R2[0..63] ---
    li   x5, 0x31c73e34
    sw   x5, 0x200(x13)    # R2[0]
    li   x5, 0x04372344
    sw   x5, 0x204(x13)
    li   x5, 0x0a5a44f7
    sw   x5, 0x208(x13)
    li   x5, 0x00007f93
    sw   x5, 0x20C(x13)
    li   x5, 0x70d2366b
    sw   x5, 0x210(x13)
    li   x5, 0xe6d1d85a
    sw   x5, 0x214(x13)
    li   x5, 0xca6002c5
    sw   x5, 0x218(x13)
    li   x5, 0x5037f102
    sw   x5, 0x21C(x13)
    li   x5, 0x6cb95f0d
    sw   x5, 0x220(x13)
    li   x5, 0xf82edb71
    sw   x5, 0x224(x13)
    li   x5, 0xa684a101
    sw   x5, 0x228(x13)
    li   x5, 0x19a543b0
    sw   x5, 0x22C(x13)
    li   x5, 0x2a52b7eb
    sw   x5, 0x230(x13)
    li   x5, 0xc301ae88
    sw   x5, 0x234(x13)
    li   x5, 0xd9ac6a9e
    sw   x5, 0x238(x13)
    li   x5, 0x25ba9d37
    sw   x5, 0x23C(x13)
    li   x5, 0x7a6b602d
    sw   x5, 0x240(x13)
    li   x5, 0x414d1e67
    sw   x5, 0x244(x13)
    li   x5, 0xc2945574
    sw   x5, 0x248(x13)
    li   x5, 0x65e151f7
    sw   x5, 0x24C(x13)
    li   x5, 0xe50982f1
    sw   x5, 0x250(x13)
    li   x5, 0xf71d0eb4
    sw   x5, 0x254(x13)
    li   x5, 0x0fb673f2
    sw   x5, 0x258(x13)
    li   x5, 0x5fc89530
    sw   x5, 0x25C(x13)
    li   x5, 0xccd22aea
    sw   x5, 0x260(x13)
    li   x5, 0xec5c2f52
    sw   x5, 0x264(x13)
    li   x5, 0xfebeef30
    sw   x5, 0x268(x13)
    li   x5, 0xa2b8acab
    sw   x5, 0x26C(x13)
    li   x5, 0xace8329a
    sw   x5, 0x270(x13)
    li   x5, 0x18ce321e
    sw   x5, 0x274(x13)
    li   x5, 0x7b0b549d
    sw   x5, 0x278(x13)
    li   x5, 0xec157cc7
    sw   x5, 0x27C(x13)
    li   x5, 0x4bcc394a
    sw   x5, 0x280(x13)
    li   x5, 0xb5ac96e5
    sw   x5, 0x284(x13)
    li   x5, 0xc92fe6c3
    sw   x5, 0x288(x13)
    li   x5, 0xbb75d7b8
    sw   x5, 0x28C(x13)
    li   x5, 0xed08252f
    sw   x5, 0x290(x13)
    li   x5, 0x91d2cfe5
    sw   x5, 0x294(x13)
    li   x5, 0x436133fd
    sw   x5, 0x298(x13)
    li   x5, 0x26d31640
    sw   x5, 0x29C(x13)
    li   x5, 0x517f21b0
    sw   x5, 0x2A0(x13)
    li   x5, 0x20ba29a2
    sw   x5, 0x2A4(x13)
    li   x5, 0xbebb49e8
    sw   x5, 0x2A8(x13)
    li   x5, 0x6f6e56e2
    sw   x5, 0x2AC(x13)
    li   x5, 0x21aa9ace
    sw   x5, 0x2B0(x13)
    li   x5, 0x9cb0c624
    sw   x5, 0x2B4(x13)
    li   x5, 0x59107e35
    sw   x5, 0x2B8(x13)
    li   x5, 0x10ea5f5f
    sw   x5, 0x2BC(x13)
    li   x5, 0x3d24c59e
    sw   x5, 0x2C0(x13)
    li   x5, 0x53f0ee37
    sw   x5, 0x2C4(x13)
    li   x5, 0x6a0ab96b
    sw   x5, 0x2C8(x13)
    li   x5, 0xce1f0aae
    sw   x5, 0x2CC(x13)
    li   x5, 0xe0aa85b2
    sw   x5, 0x2D0(x13)
    li   x5, 0xba7ec935
    sw   x5, 0x2D4(x13)
    li   x5, 0x1c2df963
    sw   x5, 0x2D8(x13)
    li   x5, 0xad39a121
    sw   x5, 0x2DC(x13)
    li   x5, 0xc93f2a68
    sw   x5, 0x2E0(x13)
    li   x5, 0xffd7d872
    sw   x5, 0x2E4(x13)
    li   x5, 0xf414d2d5
    sw   x5, 0x2E8(x13)
    li   x5, 0x60c56ca7
    sw   x5, 0x2EC(x13)
    li   x5, 0x8e9033d3
    sw   x5, 0x2F0(x13)
    li   x5, 0xf103dafa
    sw   x5, 0x2F4(x13)
    li   x5, 0x34f68814
    sw   x5, 0x2F8(x13)
    li   x5, 0x7b5443c2
    sw   x5, 0x2FC(x13)    # R2[63]

    # --- E, N_INV ---
    li   x5, 0x00010001
    sw   x5, 0x300(x13)    # E = 65537
    li   x5, 0xcbbb0d9f
    sw   x5, 0x304(x13)    # N_INV

    # === PHA 2: OP - nap M (64 tu) + start + poll + doc (CUA SO PURE) ===
    li   x5, 0x4d1a8fd6
    sw   x5, 0x00(x13)    # M[0] (START pure)
    li   x5, 0x6d1ed78c
    sw   x5, 0x04(x13)
    li   x5, 0x3f0230f2
    sw   x5, 0x08(x13)
    li   x5, 0xbfc14dd0
    sw   x5, 0x0C(x13)
    li   x5, 0x9f2f2523
    sw   x5, 0x10(x13)
    li   x5, 0x1c5fc8b1
    sw   x5, 0x14(x13)
    li   x5, 0xa75bc97e
    sw   x5, 0x18(x13)
    li   x5, 0x677cf065
    sw   x5, 0x1C(x13)
    li   x5, 0xce238195
    sw   x5, 0x20(x13)
    li   x5, 0xe3ef1fc0
    sw   x5, 0x24(x13)
    li   x5, 0xefe218ba
    sw   x5, 0x28(x13)
    li   x5, 0x20bb72ae
    sw   x5, 0x2C(x13)
    li   x5, 0x18ff54e9
    sw   x5, 0x30(x13)
    li   x5, 0x8b9c35be
    sw   x5, 0x34(x13)
    li   x5, 0x59fae17e
    sw   x5, 0x38(x13)
    li   x5, 0x444247a8
    sw   x5, 0x3C(x13)
    li   x5, 0x186cc426
    sw   x5, 0x40(x13)
    li   x5, 0x8c76851a
    sw   x5, 0x44(x13)
    li   x5, 0xa3c34fc5
    sw   x5, 0x48(x13)
    li   x5, 0x05ed0f55
    sw   x5, 0x4C(x13)
    li   x5, 0x31c83dd8
    sw   x5, 0x50(x13)
    li   x5, 0x05d8d42f
    sw   x5, 0x54(x13)
    li   x5, 0xc86ec634
    sw   x5, 0x58(x13)
    li   x5, 0x97fd55f5
    sw   x5, 0x5C(x13)
    li   x5, 0x5b5d76f7
    sw   x5, 0x60(x13)
    li   x5, 0xcd3ee31a
    sw   x5, 0x64(x13)
    li   x5, 0x6d7b9253
    sw   x5, 0x68(x13)
    li   x5, 0x01a56167
    sw   x5, 0x6C(x13)
    li   x5, 0x9a2f67e3
    sw   x5, 0x70(x13)
    li   x5, 0xec03be21
    sw   x5, 0x74(x13)
    li   x5, 0x694a3872
    sw   x5, 0x78(x13)
    li   x5, 0x944416eb
    sw   x5, 0x7C(x13)
    li   x5, 0x398a8f09
    sw   x5, 0x80(x13)
    li   x5, 0x7555987c
    sw   x5, 0x84(x13)
    li   x5, 0x7e7c9cea
    sw   x5, 0x88(x13)
    li   x5, 0xc06bb0fe
    sw   x5, 0x8C(x13)
    li   x5, 0xc55c17db
    sw   x5, 0x90(x13)
    li   x5, 0xa11bfbda
    sw   x5, 0x94(x13)
    li   x5, 0xb32d9707
    sw   x5, 0x98(x13)
    li   x5, 0xb4b32704
    sw   x5, 0x9C(x13)
    li   x5, 0x08301e15
    sw   x5, 0xA0(x13)
    li   x5, 0x2ba78586
    sw   x5, 0xA4(x13)
    li   x5, 0x3c941859
    sw   x5, 0xA8(x13)
    li   x5, 0x1a4f42c6
    sw   x5, 0xAC(x13)
    li   x5, 0x3aaa68e2
    sw   x5, 0xB0(x13)
    li   x5, 0x265265f7
    sw   x5, 0xB4(x13)
    li   x5, 0x3b8b5975
    sw   x5, 0xB8(x13)
    li   x5, 0xb8e856f3
    sw   x5, 0xBC(x13)
    li   x5, 0x3c6d38f7
    sw   x5, 0xC0(x13)
    li   x5, 0x1fba4fad
    sw   x5, 0xC4(x13)
    li   x5, 0xeb24273d
    sw   x5, 0xC8(x13)
    li   x5, 0x62f3012a
    sw   x5, 0xCC(x13)
    li   x5, 0x187d12d0
    sw   x5, 0xD0(x13)
    li   x5, 0xf2fac68b
    sw   x5, 0xD4(x13)
    li   x5, 0x7960d07b
    sw   x5, 0xD8(x13)
    li   x5, 0x50152c63
    sw   x5, 0xDC(x13)
    li   x5, 0x1ee65982
    sw   x5, 0xE0(x13)
    li   x5, 0xd40b21d1
    sw   x5, 0xE4(x13)
    li   x5, 0x29b37a37
    sw   x5, 0xE8(x13)
    li   x5, 0xdb4b9a34
    sw   x5, 0xEC(x13)
    li   x5, 0xf2c13ece
    sw   x5, 0xF0(x13)
    li   x5, 0xec3ac2a4
    sw   x5, 0xF4(x13)
    li   x5, 0x1401b386
    sw   x5, 0xF8(x13)
    li   x5, 0x282cd5d9
    sw   x5, 0xFC(x13)    # M[63]

    # --- start ---
    li   x6, 0x1
    sw   x6, 0x308(x13)    # CTRL: start=1

    # --- cho modexp xong (poll STATUS) ---
poll_rsa:
    lw   x5, 0x30C(x13)         # STATUS: bit0 = done
    andi x5, x5, 1
    beqz x5, poll_rsa

    # --- doc 64 tu ket qua + tinh XOR-fold ---
    li   x28, 0               # fold = 0
    lw   x20, 0x400(x13)    # C[0] giu lai
    xor  x28, x28, x20
    lw   x21, 0x404(x13)    # C[1] giu lai
    xor  x28, x28, x21
    lw   x22, 0x408(x13)    # C[2] giu lai
    xor  x28, x28, x22
    lw   x23, 0x40C(x13)    # C[3] giu lai
    xor  x28, x28, x23
    lw   x30, 0x410(x13)
    xor  x28, x28, x30
    lw   x30, 0x414(x13)
    xor  x28, x28, x30
    lw   x30, 0x418(x13)
    xor  x28, x28, x30
    lw   x30, 0x41C(x13)
    xor  x28, x28, x30
    lw   x30, 0x420(x13)
    xor  x28, x28, x30
    lw   x30, 0x424(x13)
    xor  x28, x28, x30
    lw   x30, 0x428(x13)
    xor  x28, x28, x30
    lw   x30, 0x42C(x13)
    xor  x28, x28, x30
    lw   x30, 0x430(x13)
    xor  x28, x28, x30
    lw   x30, 0x434(x13)
    xor  x28, x28, x30
    lw   x30, 0x438(x13)
    xor  x28, x28, x30
    lw   x30, 0x43C(x13)
    xor  x28, x28, x30
    lw   x30, 0x440(x13)
    xor  x28, x28, x30
    lw   x30, 0x444(x13)
    xor  x28, x28, x30
    lw   x30, 0x448(x13)
    xor  x28, x28, x30
    lw   x30, 0x44C(x13)
    xor  x28, x28, x30
    lw   x30, 0x450(x13)
    xor  x28, x28, x30
    lw   x30, 0x454(x13)
    xor  x28, x28, x30
    lw   x30, 0x458(x13)
    xor  x28, x28, x30
    lw   x30, 0x45C(x13)
    xor  x28, x28, x30
    lw   x30, 0x460(x13)
    xor  x28, x28, x30
    lw   x30, 0x464(x13)
    xor  x28, x28, x30
    lw   x30, 0x468(x13)
    xor  x28, x28, x30
    lw   x30, 0x46C(x13)
    xor  x28, x28, x30
    lw   x30, 0x470(x13)
    xor  x28, x28, x30
    lw   x30, 0x474(x13)
    xor  x28, x28, x30
    lw   x30, 0x478(x13)
    xor  x28, x28, x30
    lw   x30, 0x47C(x13)
    xor  x28, x28, x30
    lw   x30, 0x480(x13)
    xor  x28, x28, x30
    lw   x30, 0x484(x13)
    xor  x28, x28, x30
    lw   x30, 0x488(x13)
    xor  x28, x28, x30
    lw   x30, 0x48C(x13)
    xor  x28, x28, x30
    lw   x30, 0x490(x13)
    xor  x28, x28, x30
    lw   x30, 0x494(x13)
    xor  x28, x28, x30
    lw   x30, 0x498(x13)
    xor  x28, x28, x30
    lw   x30, 0x49C(x13)
    xor  x28, x28, x30
    lw   x30, 0x4A0(x13)
    xor  x28, x28, x30
    lw   x30, 0x4A4(x13)
    xor  x28, x28, x30
    lw   x30, 0x4A8(x13)
    xor  x28, x28, x30
    lw   x30, 0x4AC(x13)
    xor  x28, x28, x30
    lw   x30, 0x4B0(x13)
    xor  x28, x28, x30
    lw   x30, 0x4B4(x13)
    xor  x28, x28, x30
    lw   x30, 0x4B8(x13)
    xor  x28, x28, x30
    lw   x30, 0x4BC(x13)
    xor  x28, x28, x30
    lw   x30, 0x4C0(x13)
    xor  x28, x28, x30
    lw   x30, 0x4C4(x13)
    xor  x28, x28, x30
    lw   x30, 0x4C8(x13)
    xor  x28, x28, x30
    lw   x30, 0x4CC(x13)
    xor  x28, x28, x30
    lw   x30, 0x4D0(x13)
    xor  x28, x28, x30
    lw   x30, 0x4D4(x13)
    xor  x28, x28, x30
    lw   x30, 0x4D8(x13)
    xor  x28, x28, x30
    lw   x30, 0x4DC(x13)
    xor  x28, x28, x30
    lw   x30, 0x4E0(x13)
    xor  x28, x28, x30
    lw   x30, 0x4E4(x13)
    xor  x28, x28, x30
    lw   x30, 0x4E8(x13)
    xor  x28, x28, x30
    lw   x30, 0x4EC(x13)
    xor  x28, x28, x30
    lw   x24, 0x4F0(x13)    # C[60] giu lai
    xor  x28, x28, x24
    lw   x25, 0x4F4(x13)    # C[61] giu lai
    xor  x28, x28, x25
    lw   x26, 0x4F8(x13)    # C[62] giu lai
    xor  x28, x28, x26
    lw   x27, 0x4FC(x13)    # C[63] (END pure)
    xor  x28, x28, x27

    # === PHA 3: STORE - ghi ra BRAM (ngoai cua so PURE) ===
    sw   x20, 0x00(x8)    # RESULT[0]
    sw   x21, 0x04(x8)
    sw   x22, 0x08(x8)
    sw   x23, 0x0C(x8)
    sw   x24, 0x10(x8)    # RESULT[60]
    sw   x25, 0x14(x8)
    sw   x26, 0x18(x8)
    sw   x27, 0x1C(x8)
    sw   x28, 0x20(x8)    # XOR-fold ca 64 tu

    li   x29, 0x600d0007
    sw   x29, 0x30(x8)    # marker: da xong
halt:
    j    halt
