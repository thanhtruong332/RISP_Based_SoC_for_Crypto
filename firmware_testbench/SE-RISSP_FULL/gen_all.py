#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen_all.py - Sinh toan bo firmware (.s/.coe/.hex) + testbench (.v) cho SoC
             SE-RISSP_AES_ULTRA (RISSP + AES + SHA3 + RSA), MOI CHUC NANG
             MOT BO RIENG:

   aes_ecb / aes_cbc / aes_cfb / aes_ctr / sha3 / rsa

Chay:  python gen_all.py
Yeu cau: toolchain RISC-V tai TOOLS (sua duong dan ben duoi neu may khac).

--------------------------------------------------------------------------
YEU CAU BAT BUOC: imem phai co do tre 1 chu ky
--------------------------------------------------------------------------
Block Design phai da BO TICK "Register PortA Output of Memory Primitives"
tren blk_mem_gen_0. Neu con bat (do tre 2 chu ky) thi vi pham hop dong cua
fetch_stage.v va firmware nay SE TREO (vong lap poll dung lenh nhanh re,
ma imem 2 chu ky lam moi nhanh re tinh sai dia chi dich).

--------------------------------------------------------------------------
3 DIEU CHINH DE SO LIEU DO DUOC PHAN ANH DUNG HIEU NANG THAT
--------------------------------------------------------------------------
Ban truoc bi thoi phong ~2 lan vi 3 nguyen nhan, da sua het:

1. NOP padding -> POLL STATUS
   Truoc: cho AES bang 40 NOP (AES chi can 16 ck) -> 24 ck lang phi nam
   NGAY TRONG cua so do PURE. 44 NOP chiem 37% cua so.
   Nay: poll STATUS, cho dung bang thoi gian loi can, va dung cach
   firmware that van lam -> so lieu dang tin hon khi dua vao paper.

2. Bo 40 NOP cho sau khi ghi KEY
   Khong can: AESEncrypt.v co 'start_req' tu giu yeu cau enable va tu bat
   dau ngay khi keys_valid len (xem AESEncrypt.v, tin hieu start_req).
   40 ck nay truoc day lam xau chi so FULL (KEY->CT).

3. Bo ky thuat "doc 2 lan"
   Do la workaround cho imem 2 chu ky (ket qua 'lw' bi ghi nham vao thanh
   ghi dich cua lenh ke tiep). Block Design da sua nen bo di -> tiet kiem
   4 giao dich AXI (~30 ck) moi block.

So chu ky loi DO THAT tren RTL (de doi chieu):
   AES  : KeyExpansion 11 ck, ma hoa 12 ck
   SHA3 : tu cuoi (iLast) -> oReady 39 ck
   RSA  : start -> done 840 ck (E=65537, loi WORD-SERIAL moi 2026-08-13)
          ban cu (nhan to hop toan dai) la 186 ck - da thay de len duoc
          1024/2048-bit; xem RSA_Core/ws/README.md.
          Neu wrapper dat E_SCAN=17 thi con 462 ck.
          FIRMWARE KHONG DOI: register map va chuoi lenh y het ban cu.
"""

import struct, subprocess, sys, hashlib
from pathlib import Path

HERE  = Path(__file__).resolve().parent
TOOLS = Path(r"F:\xpack-riscv-none-elf-gcc-15.2.0-1\bin")
AS, LD, OC = (TOOLS / f"riscv-none-elf-{t}.exe" for t in ("as", "ld", "objcopy"))

AES, SHA3, RSA, BRAM = 0x40000000, 0x44000000, 0x48000000, 0xC0000000

# ---------------------------------------------------------------- so lieu
KEY = ["2b7e1516", "28aed2a6", "abf71588", "09cf4f3c"]   # FIPS-197
PT  = ["6bc1bee2", "2e409f96", "e93d7e11", "7393172a"]   # NIST SP800-38A (block 1)
# 4 block plaintext chuan NIST SP800-38A - dung cho do throughput DUY TRI
PT4 = [["6bc1bee2", "2e409f96", "e93d7e11", "7393172a"],
       ["ae2d8a57", "1e03ac9c", "9eb76fac", "45af8e51"],
       ["30c81c46", "a35ce411", "e5fbc119", "1a0a52ef"],
       ["f69f2445", "df4f9b17", "ad2b417b", "e66c3710"]]
# ciphertext ky vong 4 block - tinh bang pycryptodome, block 1 da doi chieu
# khop voi ket qua verify tren RTL that
EXP4 = {
 "aes_ecb": [["3ad77bb4","0d7a3660","a89ecaf3","2466ef97"],
             ["f5d3d585","03b9699d","e785895a","96fdbaaf"],
             ["43b1cd7f","598ece23","881b00e3","ed030688"],
             ["7b0c785e","27e8ad3f","82232071","04725dd4"]],
 "aes_cbc": [["7649abac","8119b246","cee98e9b","12e9197d"],
             ["5086cb9b","507219ee","95db113a","917678b2"],
             ["73bed6b8","e3c1743b","7116e69e","22229516"],
             ["3ff1caa1","681fac09","120eca30","7586e1a7"]],
 "aes_cfb": [["3b3fd92e","b72dad20","333449f8","e83cfb4a"],
             ["c8a64537","a0b3a93f","cde3cdad","9f1ce58b"],
             ["26751f67","a3cbb140","b1808cf1","87a4f4df"],
             ["c04b0535","7c5d1c0e","eac4c66f","9ff7f2e6"]],
 "aes_ctr": [["874d6191","b620e326","1bef6864","990db6ce"],
             ["9806f66b","7970fdff","8617187b","b9fffdff"],
             ["5ae4df3e","dbd5d35e","5b4f0902","0db03eab"],
             ["1e031dda","2fbe03d1","792170a0","f3009cee"]]}
IV  = ["00010203", "04050607", "08090a0b", "0c0d0e0f"]   # CBC/CFB IV
CTR = ["f0f1f2f3", "f4f5f6f7", "f8f9fafb", "fcfdfeff"]   # CTR counter

EXP = {
    "aes_ecb": ["3ad77bb4", "0d7a3660", "a89ecaf3", "2466ef97"],
    "aes_cbc": ["7649abac", "8119b246", "cee98e9b", "12e9197d"],
    "aes_cfb": ["3b3fd92e", "b72dad20", "333449f8", "e83cfb4a"],
    "aes_ctr": ["874d6191", "b620e326", "1bef6864", "990db6ce"],
    "sha3":    ["9b4811cb", "a830098a", "1e003726", "088b9a5a",
                "91026b84", "faae5299", "568d77c3", "463a4fdc"],
    "rsa":     ["5ee8b43f"],
}
def _xor_fold(words):
    """XOR 8 tu 32-bit cua digest -> 1 checksum (giong lenh xor trong firmware)"""
    f = 0
    for w in words:
        f ^= int(w, 16)
    return f


# ==========================================================================
# DU LIEU TEST CHO SHA3-256  --  SUA O DAY DE DOI MESSAGE
# ==========================================================================
# SHA3-256 co rate 1088 bit (136 byte): moi lan permutation ton ~42 chu ky
# BAT KE nap vao bao nhieu du lieu. Nen message cang gan 136 byte thi
# throughput do duoc cang phan anh dung nang luc loi.
#   128 byte + 8 byte padding = 136 byte = DUNG 1 block -> 1 permutation.
# Chon 128 (khong phai 135) de moi tu deu day 8 byte, khong phai xu ly tu
# le qua iByte_num.
# Noi dung: 4 block plaintext NIST SP800-38A lap lai 2 lan.
_NIST_P = bytes.fromhex('6bc1bee22e409f96e93d7e117393172a'
                        'ae2d8a571e03ac9c9eb76fac45af8e51'
                        '30c81c46a35ce411e5fbc1191a0a52ef'
                        'f69f2445df4f9b17ad2b417be66c3710')
SHA3_MSG = _NIST_P + _NIST_P          # 128 byte

# digest + XOR-fold TU TINH bang hashlib -> doi SHA3_MSG la tu cap nhat
_d = hashlib.sha3_256(SHA3_MSG).hexdigest()
EXP["sha3"] = [_d[i:i + 8] for i in range(0, 64, 8)]
SHA3_FOLD = "%08x" % _xor_fold(EXP["sha3"])

# --------------------------------------------------------------------------
# BIEN THE NHIEU BLOCK: sha3_4 (4 block) va sha3_16 (16 block)
# --------------------------------------------------------------------------
# Muc dich: dung duong cong throughput theo do dai message. Voi 1 diem do
# khong the tach chi phi CO DINH (1 lan) khoi chi phi MOI BLOCK.
#
# Chon do dai: so tu = 17N - 1  ->  message + 1 tu padding = dung N rate
# block (17 tu/block), khong co block le lam nhieu so do.
#   N=1  ->  16 tu  =  128 byte  (ban goc "sha3")
#   N=4  ->  67 tu  =  536 byte
#   N=16 -> 271 tu  = 2168 byte
#
# Noi dung message sinh THEO BO DEM (khong nhung hang so) de firmware la
# VONG LAP co kich thuoc khong doi - unroll 271 tu se khong vua imem.
#   tu i = big-endian(0x6bc1bee2 + i) || big-endian(0x2e409f96 + i)
# (khoi tao trung 2 tu dau cua plaintext NIST cho lien mach voi ban goc)
SHA3_SEED_HI, SHA3_SEED_LO = 0x6bc1bee2, 0x2e409f96
SHA3_MULTI = {"sha3_4": 4, "sha3_16": 16}
SHA3_MULTI_MARK = {"sha3_4": "600d0007", "sha3_16": "600d0008"}


def sha3_multi_words(nblk):
    return 17 * nblk - 1


def sha3_multi_msg(nblk):
    """Dung lai DUNG chuoi byte ma firmware vong lap se ghi ra SHA3."""
    out = b""
    for i in range(sha3_multi_words(nblk)):
        out += struct.pack(">I", (SHA3_SEED_HI + i) & 0xFFFFFFFF)
        out += struct.pack(">I", (SHA3_SEED_LO + i) & 0xFFFFFFFF)
    return out


SHA3_MULTI_EXP, SHA3_MULTI_FOLD = {}, {}
for _nm, _nb in SHA3_MULTI.items():
    _dm = hashlib.sha3_256(sha3_multi_msg(_nb)).hexdigest()
    SHA3_MULTI_EXP[_nm] = [_dm[i:i + 8] for i in range(0, 64, 8)]
    SHA3_MULTI_FOLD[_nm] = "%08x" % _xor_fold(SHA3_MULTI_EXP[_nm])


# RSA verify: thiet bi chi dung public key (N,E). Chu ky duoc KY OFFLINE
# bang khoa bi mat d - o day tinh luon trong script cho tien demo, thuc te
# viec nay lam o server va thiet bi KHONG BAO GIO giu p,q,d.
_RSA_P, _RSA_Q = 65521, 65519
_RSA_N = _RSA_P * _RSA_Q                       # 0xFFE000FF
_RSA_E = 65537                                 # 0x00010001
_RSA_D = pow(_RSA_E, -1, (_RSA_P - 1) * (_RSA_Q - 1))

# Ky chinh XOR-fold cua SHA3 -> RSA verify se tra ve dung fold do.
# Nho vay doi SHA3_MSG thi chu ky tu ky lai, chuoi SHA3->RSA luon nhat quan.
_RSA_SIG = pow(int(SHA3_FOLD, 16), _RSA_D, _RSA_N)
RSA_PARAM = {"M": "%08x" % _RSA_SIG, "E": "%08x" % _RSA_E, "N": "%08x" % _RSA_N,
             "NINV": "c0e10101", "R2": "403d0201"}
EXP["rsa"] = [SHA3_FOLD]

# ==========================================================================
# DU LIEU TEST CHO 4 MODE AES  --  SUA O DAY DE DOI CASE
# ==========================================================================
# Moi mode dung 1 vector KHAC NHAU (cho phong phu) nhung deu truy vet duoc
# ve chuan, khong phai so tu bia:
#   ECB : FIPS-197 Appendix C.1  (vector chinh thuc cua chuan AES-128)
#   CBC : NIST SP800-38A F.2.1 block 3  (IV = ciphertext block 2)
#   CFB : NIST SP800-38A F.3.13 block 4 (IV = ciphertext block 3)
#   CTR : NIST SP800-38A F.5.1 block 3  (counter ban dau + 2)
#
# MUON DOI SO: sua 'key'/'pt'/'iv' thoai mai roi chay lai gen_all.py.
# Truong 'ct' se duoc TINH LAI TU DONG bang pycryptodome (neu may co cai)
# nen khong bao gio lech - khong phai tra bang tay.
AES_CASE = {
    "aes_ecb": dict(
        key=["00010203", "04050607", "08090a0b", "0c0d0e0f"],
        pt =["00112233", "44556677", "8899aabb", "ccddeeff"],
        iv =None,
        ct =["69c4e0d8", "6a7b0430", "d8cdb780", "70b4c55a"]),
    "aes_cbc": dict(
        key=["2b7e1516", "28aed2a6", "abf71588", "09cf4f3c"],
        pt =["30c81c46", "a35ce411", "e5fbc119", "1a0a52ef"],
        iv =["5086cb9b", "507219ee", "95db113a", "917678b2"],
        ct =["73bed6b8", "e3c1743b", "7116e69e", "22229516"]),
    "aes_cfb": dict(
        key=["2b7e1516", "28aed2a6", "abf71588", "09cf4f3c"],
        pt =["f69f2445", "df4f9b17", "ad2b417b", "e66c3710"],
        iv =["26751f67", "a3cbb140", "b1808cf1", "87a4f4df"],
        ct =["c04b0535", "7c5d1c0e", "eac4c66f", "9ff7f2e6"]),
    "aes_ctr": dict(
        key=["2b7e1516", "28aed2a6", "abf71588", "09cf4f3c"],
        pt =["30c81c46", "a35ce411", "e5fbc119", "1a0a52ef"],
        iv =["f0f1f2f3", "f4f5f6f7", "f8f9fafb", "fcfdff01"],
        ct =["5ae4df3e", "dbd5d35e", "5b4f0902", "0db03eab"]),
}


def refresh_aes_ct():
    """Tinh lai ciphertext ky vong tu key/pt/iv hien tai.

    Nho ham nay ma doi du lieu test chi can sua 'key'/'pt'/'iv' - 'ct' tu
    cap nhat. Neu may khong co pycryptodome thi giu nguyen 'ct' da luu
    (van chay duoc, nhung phai tu dam bao 'ct' dung voi du lieu moi).
    """
    try:
        from Crypto.Cipher import AES as _AES
        from Crypto.Util import Counter as _Counter
    except ImportError:
        print("  [!] khong co pycryptodome -> dung 'ct' da luu san trong AES_CASE")
        print("      (neu vua doi key/pt/iv thi PHAI cai pycryptodome hoac tu sua 'ct')")
        return
    for n, c in AES_CASE.items():
        k = bytes.fromhex("".join(c["key"]))
        p = bytes.fromhex("".join(c["pt"]))
        if c["iv"] is None:
            out = _AES.new(k, _AES.MODE_ECB).encrypt(p)
        else:
            iv = bytes.fromhex("".join(c["iv"]))
            if n == "aes_cbc":
                out = _AES.new(k, _AES.MODE_CBC, iv).encrypt(p)
            elif n == "aes_cfb":
                out = _AES.new(k, _AES.MODE_CFB, iv, segment_size=128).encrypt(p)
            else:   # CTR
                ctr = _Counter.new(128, initial_value=int.from_bytes(iv, "big"))
                out = _AES.new(k, _AES.MODE_CTR, counter=ctr).encrypt(p)
        new = [out[i:i + 4].hex() for i in range(0, 16, 4)]
        if new != c["ct"]:
            print(f"  [i] {n}: ciphertext ky vong da duoc tinh lai -> {' '.join(new)}")
            c["ct"] = new
        EXP[n] = c["ct"]


# CTRL cua AES: bit0=start, bit[2:1]=mode  (doc tu aes_wrapper.v)
AES_MODE = {"aes_ecb": (0x1, "00", "ECB"), "aes_cbc": (0x3, "01", "CBC"),
            "aes_cfb": (0x7, "11", "CFB"), "aes_ctr": (0x5, "10", "CTR")}
MARKER   = {"aes_ecb": "600d0001", "aes_cbc": "600d0002", "aes_cfb": "600d0003",
            "aes_ctr": "600d0004", "sha3": "600d0005", "rsa": "600d0006"}

BANNER = """# {title}
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
{body}
.section .text
.globl _start
_start:
"""


def li(reg, val):
    return f"    li   {reg}, 0x{val}\n"


def nops(n, why):
    return f"    .rept {n}          # {why}\n    nop\n    .endr\n"


def wr(reg, off, base, cmt=""):
    c = f"    # {cmt}" if cmt else ""
    return f"    sw   {reg}, 0x{off:02X}({base}){c}\n"


def store_block(words, off, base, cmt):
    """ghi 4 tu hang so vao peripheral"""
    s = ""
    for i, w in enumerate(words):
        s += li("x5", w) + wr("x5", off + i * 4, base, cmt if i == 0 else "")
    return s


def poll(label, off, base, what):
    """Vong lap poll STATUS - cho DUNG BANG thoi gian loi can, khong hon.

    Truoc day phai cho bang NOP vi imem 2 chu ky lam moi nhanh re tinh sai
    dia chi dich. Block Design da sua (bo tick "Register PortA Output of
    Memory Primitives") nen nhanh re chay dung -> dung lai poll that.
    Uu diem: (1) khong lang phi chu ky nhu NOP padding, (2) dung cach
    firmware that van lam nen so lieu dua vao paper dang tin hon.
    """
    return (f"{label}:\n"
            f"    lw   x5, 0x{off:02X}({base})         # STATUS: bit0 = {what}\n"
            "    andi x5, x5, 1\n"
            f"    beqz x5, {label}\n")


def gen_aes(name):
    ctrl, msel, short = AES_MODE[name]
    case = AES_CASE[name]
    keyw, ptw, ivw = case["key"], case["pt"], case["iv"]
    use_iv = ivw is not None
    ivname = "counter" if name == "aes_ctr" else "IV     "

    body = f"# CHUC NANG: AES-128 {short} ma hoa 1 block 128-bit.\n"
    body += f"#   CTRL = 0x{ctrl:X}  (start=1, mode_sel={msel} = {short})\n"
    body += f"#   key       = {''.join(keyw)}\n"
    body += f"#   plaintext = {''.join(ptw)}\n"
    if use_iv:
        body += f"#   {ivname} = {''.join(ivw)}\n"
    body += "#\n"
    body += "# KET QUA ghi ra BRAM 0xC0000000:\n"
    body += f"#   0x00-0x0C  ciphertext, ky vong {' '.join(case['ct'])}\n"
    body += f"#   0x10       marker = 0x{MARKER[name].upper()}"

    s = BANNER.format(title=f"{name}.s - AES-128 {short} tren SE-RISSP_AES_ULTRA", body=body)
    s += li("x11", "40000000") + li("x8", "C0000000") + "\n"
    s += "    # --- nap KEY (KHONG can cho: AESEncrypt co start_req tu giu yeu\n"
    s += "    #     cau va tu bat dau ngay khi keys_valid len) ---\n"
    s += store_block(keyw, 0x10, "x11", "KEY[0..3]")
    s += "\n    # --- nap PLAINTEXT ---\n"
    s += store_block(ptw, 0x00, "x11", "DATA_IN[0..3]")
    if use_iv:
        s += f"\n    # --- nap {ivname.strip()} ---\n"
        s += store_block(ivw, 0x40, "x11", "IV[0..3]")
    s += f"\n    # --- start {short} ---\n"
    s += li("x5", f"{ctrl:X}") + wr("x5", 0x20, "x11", f"CTRL: start=1, mode={short}")
    s += "\n    # --- cho AES xong (poll STATUS, khong lang phi chu ky) ---\n"
    s += poll("poll_aes", 0x24, "x11", "done")
    s += "\n    # --- doc ciphertext ---\n"
    for i, r in enumerate(["x20", "x21", "x22", "x23"]):
        s += f"    lw   {r}, 0x{0x30 + i*4:02X}(x11)\n"
    s += "\n    # --- ghi ciphertext ra BRAM ---\n"
    for i, r in enumerate(["x20", "x21", "x22", "x23"]):
        s += wr(r, i * 4, "x8")
    s += "\n" + li("x28", MARKER[name]) + wr("x28", 0x10, "x8", "marker: da xong")
    s += "halt:\n    j    halt\n"
    return s


def gen_sha3():
    nw = len(SHA3_MSG) // 8
    body = f"# CHUC NANG: SHA3-256 hash {len(SHA3_MSG)} byte = {nw} tu 64-bit DAY DU.\n"
    body += "#\n"
    body += "# VI SAO CHON DO DAI NAY: SHA3-256 co rate 1088 bit (136 byte) - moi\n"
    body += "# lan permutation ton ~42 chu ky BAT KE nap vao bao nhieu du lieu.\n"
    body += f"# Message {len(SHA3_MSG)} byte + 8 byte padding = 136 byte = DUNG 1 block,\n"
    body += "# tuc khai thac toi da 1 lan permutation. (Ban cu chi hash 16 byte ->\n"
    body += "# dung 11,8% nang luc, lam throughput do duoc thap hon that ~8,4 lan.)\n"
    body += f"# Chon {len(SHA3_MSG)} byte (khong phai 135) de moi tu deu DAY 8 byte,\n"
    body += "# khong phai xu ly tu le qua iByte_num.\n"
    body += "#\n"
    body += "# Noi dung: 4 block plaintext NIST SP800-38A lap lai 2 lan.\n"
    body += "#   CTRL (0x08): bit0=iReady, bit1=iLast, bit[4:2]=iByte_num\n"
    body += "#     -> 0x1 = absorb 1 tu ; 0x3 = tu cuoi (kich padding + permutation)\n"
    body += "#\n"
    body += "# KET QUA ghi ra BRAM 0xC0000000:\n"
    body += "#   0x00-0x1C  digest 8 tu, ky vong\n"
    body += f"#              {' '.join(EXP['sha3'][:4])}\n"
    body += f"#              {' '.join(EXP['sha3'][4:])}\n"
    body += f"#   0x20       XOR-fold 8 tu digest, ky vong {SHA3_FOLD}\n"
    body += f"#   0x30       marker = 0x{MARKER['sha3'].upper()}"

    s = BANNER.format(title="sha3.s - SHA3-256 tren SE-RISSP_AES_ULTRA", body=body)
    s += li("x12", "44000000") + li("x8", "C0000000") + "\n"
    s += li("x6", "1") + "                       # iReady=1, iLast=0\n"

    s += f"\n    # --- absorb {nw} tu du lieu ---\n"
    for i in range(nw):
        hi = SHA3_MSG[i * 8:i * 8 + 4].hex()
        lo = SHA3_MSG[i * 8 + 4:i * 8 + 8].hex()
        s += li("x5", hi) + wr("x5", 0x00, "x12", f"tu {i}: data_hi" if i == 0 else "")
        s += li("x5", lo) + wr("x5", 0x04, "x12")
        s += wr("x6", 0x08, "x12", "CTRL: absorb")

    s += "\n    # --- tu rong cuoi: kich padding + permutation ---\n"
    s += li("x7", "3") + "                       # iReady=1, iLast=1\n"
    s += wr("x0", 0x00, "x12") + wr("x0", 0x04, "x12")
    s += wr("x7", 0x08, "x12", "CTRL: tu cuoi")

    s += "\n    # --- cho permutation xong (poll STATUS) ---\n"
    s += poll("poll_sha3", 0x0C, "x12", "oReady")
    s += "\n    # --- doc 8 tu digest ---\n"
    regs = ["x20", "x21", "x22", "x23", "x24", "x25", "x26", "x27"]
    for i, r in enumerate(regs):
        s += f"    lw   {r}, 0x{0x10 + i*4:02X}(x12)\n"
    s += "\n    # --- ghi digest ra BRAM ---\n"
    for i, r in enumerate(regs):
        s += wr(r, i * 4, "x8")
    s += "\n    # --- XOR-fold 8 tu -> 1 checksum 32-bit (chi dung XOR) ---\n"
    s += "    xor  x28, x20, x21\n"
    for r in regs[2:]:
        s += f"    xor  x28, x28, {r}\n"
    s += wr("x28", 0x20, "x8", "checksum")
    s += "\n" + li("x29", MARKER["sha3"]) + wr("x29", 0x30, "x8", "marker: da xong")
    s += "halt:\n    j    halt\n"
    return s


def gen_sha3_multi(name):
    """Ban NHIEU BLOCK - firmware la VONG LAP, kich thuoc khong doi theo N."""
    nblk = SHA3_MULTI[name]
    nw   = sha3_multi_words(nblk)
    nby  = nw * 8
    exp, fold = SHA3_MULTI_EXP[name], SHA3_MULTI_FOLD[name]

    body  = f"# CHUC NANG: SHA3-256 hash {nby} byte = {nw} tu 64-bit = DUNG {nblk} rate block.\n"
    body += "#\n"
    body += f"# VI SAO CHON {nby} BYTE: so tu = 17N - 1 = 17*{nblk} - 1 = {nw}, nen message\n"
    body += f"# + 1 tu padding = {17*nblk} tu = DUNG {nblk} block. Khong co block le lam\n"
    body += "# nhieu so do. Dung cung nguyen tac voi ban 128 byte (N=1).\n"
    body += "#\n"
    body += "# VI SAO DUNG VONG LAP (khac ban 128 byte unroll): unroll 271 tu se ton\n"
    body += "# ~1900 lenh, khong vua imem. Vong lap sinh du lieu theo BO DEM nen kich\n"
    body += "# thuoc firmware KHONG DOI theo N.\n"
    body += f"#   tu i = BE(0x{SHA3_SEED_HI:08x} + i) || BE(0x{SHA3_SEED_LO:08x} + i)\n"
    body += "# (script tinh digest ky vong bang dung cong thuc nay + hashlib)\n"
    body += "#\n"
    body += "# KHONG can poll giua cac block: CPU ton ~28 ck/tu -> ~476 ck de nap day\n"
    body += "# 1 block (17 tu), trong khi permutation chi 27 ck => permutation LUON\n"
    body += "# xong trong luc CPU con dang nap block ke tiep (bien 17x). Neu gia dinh\n"
    body += "# nay sai thi digest se SAI RO RANG - testbench bat duoc ngay.\n"
    body += "#\n"
    body += "#   CTRL (0x08): bit0=iReady, bit1=iLast, bit[4:2]=iByte_num\n"
    body += "#     -> 0x1 = absorb 1 tu ; 0x3 = tu cuoi (kich padding + permutation)\n"
    body += "#\n"
    body += "# KET QUA ghi ra BRAM 0xC0000000:\n"
    body += "#   0x00-0x1C  digest 8 tu, ky vong\n"
    body += f"#              {' '.join(exp[:4])}\n"
    body += f"#              {' '.join(exp[4:])}\n"
    body += f"#   0x20       XOR-fold 8 tu digest, ky vong {fold}\n"
    body += f"#   0x30       marker = 0x{SHA3_MULTI_MARK[name].upper()}"

    s  = BANNER.format(title=f"{name}.s - SHA3-256 {nblk} block ({nby} byte) tren "
                             "SE-RISSP_AES_ULTRA", body=body)
    s += li("x12", "44000000") + li("x8", "C0000000") + "\n"
    s += li("x6", "1") + "                       # iReady=1, iLast=0\n"
    s += li("x5", "%08x" % SHA3_SEED_HI) + "        # data_hi = seed_hi + i\n"
    s += li("x7", "%08x" % SHA3_SEED_LO) + "        # data_lo = seed_lo + i\n"
    s += f"    li   x9, 0                # i = 0\n"
    s += f"    li   x10, {nw}              # so tu can nap\n"

    s += f"\n    # --- vong lap absorb {nw} tu ---\n"
    s += "absorb_loop:\n"
    s += wr("x5", 0x00, "x12", "data_hi")
    s += wr("x7", 0x04, "x12", "data_lo")
    s += wr("x6", 0x08, "x12", "CTRL: absorb")
    s += "    addi x5, x5, 1\n    addi x7, x7, 1\n    addi x9, x9, 1\n"
    s += "    blt  x9, x10, absorb_loop\n"

    s += "\n    # --- tu rong cuoi: kich padding + permutation ---\n"
    s += li("x11", "3") + "                      # iReady=1, iLast=1\n"
    s += wr("x0", 0x00, "x12") + wr("x0", 0x04, "x12")
    s += wr("x11", 0x08, "x12", "CTRL: tu cuoi")

    s += "\n    # --- cho permutation xong (poll STATUS) ---\n"
    s += poll("poll_sha3", 0x0C, "x12", "oReady")
    s += "\n    # --- doc 8 tu digest ---\n"
    regs = ["x20", "x21", "x22", "x23", "x24", "x25", "x26", "x27"]
    for i, r in enumerate(regs):
        s += f"    lw   {r}, 0x{0x10 + i*4:02X}(x12)\n"
    s += "\n    # --- ghi digest ra BRAM ---\n"
    for i, r in enumerate(regs):
        s += wr(r, i * 4, "x8")
    s += "\n    # --- XOR-fold 8 tu -> 1 checksum 32-bit ---\n"
    s += "    xor  x28, x20, x21\n"
    for r in regs[2:]:
        s += f"    xor  x28, x28, {r}\n"
    s += wr("x28", 0x20, "x8", "checksum")
    s += "\n" + li("x29", SHA3_MULTI_MARK[name]) + wr("x29", 0x30, "x8", "marker: da xong")
    s += "halt:\n    j    halt\n"
    return s


def gen_rsa():
    body = f"""# CHUC NANG: RSA verify chu ky - tinh C = M^E mod N (Montgomery).
#   Thiet bi CHI dung public key (N,E); p,q,d chi ton tai OFFLINE o server.
#   M (signature) = 0x{RSA_PARAM['M']}     E = 0x{RSA_PARAM['E']} (65537, chuan cong nghiep)
#   N             = 0x{RSA_PARAM['N']}     N_INV = 0x{RSA_PARAM['NINV']}  (-N^-1 mod 2^32)
#   R2_MOD_N      = 0x{RSA_PARAM['R2']}  (2^64 mod N)
#
#   Ket qua ky vong 0x{EXP['rsa'][0]} - dung bang XOR-fold cua SHA3-256 digest
#   (xem sha3.s) => chu ky hop le.
#
# KET QUA ghi ra BRAM 0xC0000000:
#   0x00       RESULT, ky vong {EXP['rsa'][0]}
#   0x10       marker = 0x{MARKER['rsa'].upper()}"""

    s = BANNER.format(title="rsa.s - RSA verify tren SE-RISSP_AES_ULTRA", body=body)
    s += li("x13", "48000000") + li("x8", "C0000000") + "\n"
    s += "    # === PHA 1: SETUP - nap KHOA CONG KHAI (co dinh, ngoai cua so do) ===\n"
    s += "    # E/N/N_INV/R2 la tham so cua KHOA, khong doi giua cac lan verify.\n"
    s += "    # He that nap 1 lan luc khoi dong roi verify nhieu chu ky -> phai\n"
    s += "    # de NGOAI cua so PURE, giong het cach AES de KEY ngoai PT->CT.\n"
    for off, k, c in ((0x04, "E", "E = 65537"), (0x08, "N", "N = modulus"),
                      (0x0C, "NINV", "N_INV"), (0x10, "R2", "R2_MOD_N")):
        s += li("x5", RSA_PARAM[k]) + wr("x5", off, "x13", c)
    s += "\n    # === PHA 2: OP - du lieu BIEN THIEN + start + poll + doc (CUA SO PURE) ===\n"
    s += li("x5", RSA_PARAM["M"]) + wr("x5", 0x00, "x13", "M = signature (START pure)")
    s += "\n    # --- start ---\n"
    s += li("x6", "1") + wr("x6", 0x14, "x13", "CTRL: start=1")
    s += "\n    # --- cho modexp xong (poll STATUS) ---\n"
    s += poll("poll_rsa", 0x18, "x13", "done")
    s += "\n    # --- doc ket qua ve CPU (END pure) ---\n"
    s += "    lw   x20, 0x1C(x13)        # RESULT\n"
    s += "\n    # === PHA 3: STORE - ghi ra BRAM (ngoai cua so PURE) ===\n"
    s += wr("x20", 0x00, "x8", "RESULT ra BRAM")
    s += "\n" + li("x28", MARKER["rsa"]) + wr("x28", 0x10, "x8", "marker: da xong")
    s += "halt:\n    j    halt\n"
    return s


LINKER = """/* link.ld - dat chuong trinh tai 0x0 (imem RISSP) */
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
"""

# ============================================================== TESTBENCH
TB_HEAD = """`timescale 1ns / 1ps
// ================================================================
//  {title}
//  Sinh tu dong boi gen_all.py - KHONG sua tay.
//
//  Chay {coe} (da nap vao blk_mem_gen_0) tren design_1_wrapper THAT:
//  dung nguyen axi_interconnect_0 / clk_wiz_0 / proc_sys_reset_0 /
//  axi_bram_ctrl_0 + blk_mem_gen_1 cua Block Design, chi drive 2 port
//  ngoai cung clk_in1_0 (100MHz) + reset_0 (active-high).
//
//  TANG TOC MO PHONG (quan trong): MMCM trong clk_wiz_0 mat khoang 2ms
//  THOI GIAN MO PHONG moi lock xong va bat dau phat clk_out1 - trong khi
//  CPU chi can vai tram chu ky (~10us) de chay xong. Neu de nguyen, hon
//  99% thoi gian mo phong la ngoi cho MMCM => rat lau.
//  Cach xu ly: ep thang xung 40MHz (dung tan so that cua thiet ke, lay tu
//  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ) vao net clock noi bo cua Block
//  Design, va ep luon 'locked'=1 de proc_sys_reset_0 tha reset ngay.
//  Ve chuc nang hoan toan tuong duong - chi bo qua phan mo hinh hoa qua
//  trinh khoi dong MMCM (khong lien quan den thuat toan can verify).
//
//  Ket qua doc bang cach snoop BRAM_PORTA giua axi_bram_ctrl_0 va
//  blk_mem_gen_1 (khong the $readmemh vao blk_mem_gen vi la IP ma hoa).
// ================================================================
module {tb};

parameter real POWER_W  = 0.407;   // Total On-Chip Power (impl_1, do lai 2026-08-12)
parameter real FREQ_MHZ = 40.0;

reg clk_in1_0 = 0, reset_0 = 0;
always #5 clk_in1_0 = ~clk_in1_0;      // 100MHz vao clk_wiz_0

reg soc_clk_drv = 0;
always #12.5 soc_clk_drv = ~soc_clk_drv;   // 40MHz (chu ky 25ns) = clk_out1

design_1_wrapper dut (.clk_in1_0(clk_in1_0), .reset_0(reset_0));

initial begin
    force dut.design_1_i.clk_wiz_0_clk_out1 = soc_clk_drv;  // bo qua MMCM
    force dut.design_1_i.clk_wiz_0.locked   = 1'b1;
    reset_0 = 1;
    repeat (10) @(posedge clk_in1_0);
    reset_0 = 0;
    $display("[%0t] Reset released, CPU bat dau chay", $time);
end

wire soc_clk = dut.design_1_i.clk_wiz_0_clk_out1;   // doc dung net da ep
integer cyc = 0;
always @(posedge soc_clk) if (!reset_0) cyc = cyc + 1;

// --- snoop BRAM debug (axi_bram_ctrl_0 -> blk_mem_gen_1) ---
wire        bram_clk  = dut.design_1_i.axi_bram_ctrl_0_BRAM_PORTA_CLK;
wire        bram_en   = dut.design_1_i.axi_bram_ctrl_0_BRAM_PORTA_EN;
wire [3:0]  bram_we   = dut.design_1_i.axi_bram_ctrl_0_BRAM_PORTA_WE;
wire [12:0] bram_addr = dut.design_1_i.axi_bram_ctrl_0_BRAM_PORTA_ADDR;
wire [31:0] bram_din  = dut.design_1_i.axi_bram_ctrl_0_BRAM_PORTA_DIN;

reg [31:0] m [0:19];
integer k; initial for (k = 0; k < 20; k = k + 1) m[k] = 0;
always @(posedge bram_clk)
    if (bram_en && bram_we != 4'h0 && bram_addr < 13'd80)
        m[bram_addr[6:2]] <= bram_din;

integer errs = 0;
task vchk; input [31:0] g, e; input [8*8-1:0] nm;
begin
    if (g === e) $display("    %0s = %08x   OK", nm, g);
    else begin  $display("    %0s = %08x   FAIL (ky vong %08x)", nm, g, e); errs = errs + 1; end
end
endtask
"""

TB_AES = """
// --- moc cycle tren AXI cua AES (instance that: aes_axi_slave_0) ---
wire [31:0] aw_addr  = dut.design_1_i.aes_axi_slave_0.S_AXI_AWADDR;
wire        aw_valid = dut.design_1_i.aes_axi_slave_0.S_AXI_AWVALID;
wire [31:0] wr_data  = dut.design_1_i.aes_axi_slave_0.S_AXI_WDATA;
wire [31:0] ar_addr  = dut.design_1_i.aes_axi_slave_0.S_AXI_ARADDR;
wire        r_valid  = dut.design_1_i.aes_axi_slave_0.S_AXI_RVALID;
wire        aes_done = dut.design_1_i.aes_axi_slave_0.inst.aes_inst.aes_done_latched;

integer t_key=0, t_pt=0, t_ctrl=0, t_done=0, t_ct=0, t_bram=0;
reg f_key=0, f_pt=0, f_ctrl=0, f_done=0, f_ct=0, f_bram=0;
integer bcnt=0;
reg [31:0] ctrl_val = 0;

always @(posedge soc_clk) if (!f_key && aw_valid && aw_addr==32'h40000010)
    begin t_key=cyc; f_key=1; $display("[C%0d] KEY[0] write", cyc); end

always @(posedge soc_clk) if (!f_pt && aw_valid && aw_addr==32'h40000000)
    begin t_pt=cyc; f_pt=1; $display("[C%0d] PT[0] write  (START pure)", cyc); end

always @(posedge soc_clk) if (!f_ctrl && aw_valid && aw_addr==32'h40000020)
    begin t_ctrl=cyc; f_ctrl=1; ctrl_val=wr_data;
          $display("[C%0d] CTRL=0x%0h  ({mode} start)", cyc, wr_data); end

always @(posedge soc_clk) if (f_ctrl && !f_done && aes_done)
    begin t_done=cyc; f_done=1; $display("[C%0d] AES done (%0d cyc)", cyc, cyc-t_ctrl); end

// LUU Y 1: aes_axi_slave nhan DIA CHI DAY DU 32-bit (0x400000xx), khong
//   phai offset -> phai so ar_addr[7:0].
// LUU Y 2: chot moc theo DIA CHI TU CUOI (0x3C), khong dem so lan doc -
//   dem so lan se sai neu firmware doc lap dia chi.
always @(posedge soc_clk)
    if (f_done && !f_ct && r_valid && ar_addr[7:0]==8'h3C) begin
        t_ct=cyc; f_ct=1; $display("[C%0d] doc xong CT (END pure)", cyc);
    end

always @(posedge soc_clk)
    if (f_ct && !f_bram && bram_en && bram_we!=4'h0) begin
        bcnt = bcnt + 1;
        if (bcnt==4) begin t_bram=cyc; f_bram=1; $display("[C%0d] ghi xong BRAM (END e2e)", cyc); end
    end

task line;
    input integer cyc_n;
    input [8*30-1:0] nm;
begin
    if (cyc_n > 0) $display("  %0s: %4d cyc -> %8.2f Mbps", nm, cyc_n, 128.0*FREQ_MHZ/cyc_n);
    else           $display("  %0s:  (chua do duoc)", nm);
end
endtask

task report;
    integer c_core, c_pure, c_full, c_e2e;
    real eb;
begin
    c_core = f_done ? t_done-t_ctrl : 0;
    c_pure = f_ct   ? t_ct  -t_pt   : 0;
    c_full = f_ct   ? t_ct  -t_key  : 0;
    c_e2e  = f_bram ? t_bram-t_pt   : 0;
    $display("\\n================================================");
    $display("  SE-RISSP + AES-128 {mode}   (Freq=%.0f MHz, Power=%.3f W)", FREQ_MHZ, POWER_W);
    $display("================================================");
    $display("  Moc cycle: KEY=%0d PT=%0d CTRL=%0d done=%0d CT=%0d BRAM=%0d",
             t_key, t_pt, t_ctrl, t_done, t_ct, t_bram);
    $display("------------------------------------------------");
    line(c_core, "[1] Loi AES    (CTRL->done)   ");
    line(c_pure, "[2] PURE       (PT->CT)       ");
    line(c_full, "[3] FULL       (KEY->CT)      ");
    line(c_e2e,  "[4] END-TO-END (PT->BRAM)     ");
    if (c_pure > 0) begin
        eb = POWER_W*(c_pure/(FREQ_MHZ*1.0e6))*1.0e9;
        $display("------------------------------------------------");
        $display("  Energy/block: %.2f nJ    Energy/bit: %.4f nJ/bit", eb, eb/128.0);
        $display("  Throughput/W: %.2f Mbps/W", (128.0*FREQ_MHZ/c_pure)/POWER_W);
        if (c_core > 0)
            $display("  Hieu suat   : %.1f%% (loi AES %0d ck / PURE %0d ck)",
                     100.0*c_core/c_pure, c_core, c_pure);
    end
    $display("------------------------------------------------");
    $display("  NIST SP800-38A verify (ciphertext tai BRAM 0xC0000000):");
{checks}    $display("------------------------------------------------");
    if (errs==0) $display("  ==> [PASS] AES-128 {mode} DUNG CHUAN NIST");
    else         $display("  ==> [FAIL] %0d/4 tu SAI", errs);
    $display("================================================\\n");
end
endtask
"""

TB_SHA3 = """
// --- moc cycle tren AXI cua SHA3 ---
wire [31:0] aw_addr  = {{24'h0, dut.design_1_i.SHA3_hardware_new_0.s01_axi_awaddr}};
wire        aw_valid = dut.design_1_i.SHA3_hardware_new_0.s01_axi_awvalid;
wire [31:0] wr_data  = dut.design_1_i.SHA3_hardware_new_0.s01_axi_wdata;
wire [31:0] ar_addr  = {{24'h0, dut.design_1_i.SHA3_hardware_new_0.s01_axi_araddr}};
wire        r_valid  = dut.design_1_i.SHA3_hardware_new_0.s01_axi_rvalid;
wire        sha_ready= dut.design_1_i.SHA3_hardware_new_0.inst.SHA3_hardware_new_slave_lite_v1_0_S01_AXI_inst.sha3_oReady;

integer t_first=0, t_last=0, t_done=0, t_dig=0, t_bram=0;
reg f_first=0, f_last=0, f_done=0, f_dig=0, f_bram=0;
integer bcnt=0;

always @(posedge soc_clk)
    if (!f_first && aw_valid && aw_addr[7:0]==8'h08)
        begin t_first=cyc; f_first=1; $display("[C%0d] absorb tu dau tien (START)", cyc); end

always @(posedge soc_clk)
    if (f_first && !f_last && aw_valid && aw_addr[7:0]==8'h08 && wr_data[1])
        begin t_last=cyc; f_last=1; $display("[C%0d] tu cuoi (iLast=1) -> padding+permutation", cyc); end

always @(posedge soc_clk) if (f_last && !f_done && sha_ready)
    begin t_done=cyc; f_done=1; $display("[C%0d] digest san sang (%0d cyc sau iLast)", cyc, cyc-t_last); end

// Chot moc DIGEST theo DIA CHI TU CUOI (0x2C) - giong cach tb_aes chot CT.
// KHONG dem so lan doc: truoc do firmware con poll STATUS (0x0C) khong biet
// truoc bao nhieu lan, dem se sai. Digest nam o 0x10..0x2C (8 tu).
always @(posedge soc_clk)
    if (f_done && !f_dig && r_valid && ar_addr[7:0]==8'h2C)
        begin t_dig=cyc; f_dig=1; $display("[C%0d] doc xong 8 tu digest (END pure)", cyc); end

always @(posedge soc_clk)
    if (f_dig && !f_bram && bram_en && bram_we!=4'h0) begin
        bcnt = bcnt + 1;
        if (bcnt==8) begin t_bram=cyc; f_bram=1; $display("[C%0d] ghi xong 8 tu digest ra BRAM", cyc); end
    end

task report;
    integer c_core, c_perm, c_pure, c_e2e, n_pad;
    real tp_core, tp_perm, tp_pure, tp_e2e;
    real e_pure, e_e2e, eb_pure, eb_e2e;
begin
    c_core = t_done-t_last;
    c_pure = f_dig  ? t_dig -t_first : 0;
    c_e2e  = f_bram ? t_bram-t_first : 0;
    // Padder sinh 1 tu padding/chu ky cho du 17 tu (rate 1088 bit), nen
    // cua so iLast->oReady = (17 - so tu message) + permutation THUAN.
    n_pad  = 17 - {msgwords};
    c_perm = c_core - n_pad;
    tp_core = {msgbits}.0*FREQ_MHZ/c_core;   // theo so bit THAT cua message
    tp_perm = 1088.0*FREQ_MHZ/c_perm;        // tran that: 1 block day / perm thuan
    tp_pure = (c_pure>0) ? {msgbits}.0*FREQ_MHZ/c_pure : 0.0;
    tp_e2e  = (c_e2e >0) ? {msgbits}.0*FREQ_MHZ/c_e2e  : 0.0;
    e_pure  = POWER_W*(c_pure/(FREQ_MHZ*1.0e6))*1.0e9;
    e_e2e   = POWER_W*(c_e2e /(FREQ_MHZ*1.0e6))*1.0e9;
    eb_pure = e_pure/{msgbits}.0;
    eb_e2e  = e_e2e /{msgbits}.0;
    $display("\\n================================================");
    $display("  SE-RISSP + SHA3-256   (Freq=%.0f MHz, Power=%.3f W)", FREQ_MHZ, POWER_W);
    $display("================================================");
    $display("  Message: {msgbytes} byte ({msgbits} bit) - lap 4 block plaintext NIST x2");
    $display("  Moc cycle: absorb1=%0d iLast=%0d oReady=%0d DIGEST=%0d BRAM=%0d",
             t_first, t_last, t_done, t_dig, t_bram);
    $display("------------------------------------------------");
    $display("  [1] Loi SHA3   (iLast->oReady): %4d cyc -> %8.2f Mbps", c_core, tp_core);
    $display("      = %0d ck padder dien %0d tu 0 + %0d ck permutation THUAN", n_pad, n_pad, c_perm);
    $display("      => so trich vao paper: permutation %0d ck, peak %.2f Mbps", c_perm, tp_perm);
    $display("      (message %0d bit dung %.1f%% suc chua rate 1088 bit)",
             {msgbits}, 100.0*{msgbits}/1088.0);
    $display("  [2] PURE       (absorb1->DIGEST): %4d cyc -> %8.2f Mbps", c_pure, tp_pure);
    $display("  [3] END-TO-END (absorb1->BRAM) : %4d cyc -> %8.2f Mbps", c_e2e, tp_e2e);
    $display("------------------------------------------------");
    $display("  CO SO PURE (cung co so voi tb_aes - DUNG CAI NAY de so sanh):");
    $display("    Energy/hash : %8.2f nJ    Energy/bit  : %.4f nJ/bit", e_pure, eb_pure);
    $display("    Throughput/W: %8.2f Mbps/W", (POWER_W>0.0)? tp_pure/POWER_W : 0.0);
    if (c_pure>0)
      $display("    Hieu suat   : %.1f%% (loi SHA3 %0d ck / PURE %0d ck)",
               100.0*c_core/c_pure, c_core, c_pure);
    else
      $display("    Hieu suat   : N/A - moc DIGEST khong bat duoc (xem canh bao duoi)");
    $display("  [tham khao] CO SO END-TO-END:");
    $display("    Energy/hash : %8.2f nJ    Energy/bit  : %.4f nJ/bit", e_e2e, eb_e2e);
    $display("    Throughput/W: %8.2f Mbps/W", (POWER_W>0.0)? tp_e2e/POWER_W : 0.0);
    if (!f_dig)
      $display("  [!] CANH BAO: khong thay lan doc 0x2C -> c_pure=0, moi so PURE vo nghia.");
    $display("------------------------------------------------");
    $display("  Verify digest (doi chieu hashlib.sha3_256):");
{checks}    $display("  Verify XOR-fold (dung cho RSA verify):");
    vchk(m[8], 32'h{fold}, "fold   ");
    $display("------------------------------------------------");
    if (errs==0) $display("  ==> [PASS] SHA3-256 DUNG CHUAN");
    else         $display("  ==> [FAIL] %0d cho SAI", errs);
    $display("================================================\\n");
end
endtask
"""

TB_SHA3_MULTI = """
// --- moc cycle tren AXI cua SHA3 (ban {nblk} block) ---
wire [31:0] aw_addr  = {{24'h0, dut.design_1_i.SHA3_hardware_new_0.s01_axi_awaddr}};
wire        aw_valid = dut.design_1_i.SHA3_hardware_new_0.s01_axi_awvalid;
wire [31:0] wr_data  = dut.design_1_i.SHA3_hardware_new_0.s01_axi_wdata;
wire [31:0] ar_addr  = {{24'h0, dut.design_1_i.SHA3_hardware_new_0.s01_axi_araddr}};
wire        r_valid  = dut.design_1_i.SHA3_hardware_new_0.s01_axi_rvalid;
wire        sha_ready= dut.design_1_i.SHA3_hardware_new_0.inst.SHA3_hardware_new_slave_lite_v1_0_S01_AXI_inst.sha3_oReady;

integer t_first=0, t_last=0, t_done=0, t_dig=0, t_bram=0;
reg f_first=0, f_last=0, f_done=0, f_dig=0, f_bram=0;
integer bcnt=0, absorb_cnt=0;

always @(posedge soc_clk)
    if (!f_first && aw_valid && aw_addr[7:0]==8'h08)
        begin t_first=cyc; f_first=1; $display("[C%0d] absorb tu dau tien (START)", cyc); end

// dem so tu da absorb -> kiem tra dung {nwords} tu (bat loi mat tu do backpressure)
always @(posedge soc_clk)
    if (aw_valid && aw_addr[7:0]==8'h08 && !wr_data[1]) absorb_cnt = absorb_cnt + 1;

always @(posedge soc_clk)
    if (f_first && !f_last && aw_valid && aw_addr[7:0]==8'h08 && wr_data[1])
        begin t_last=cyc; f_last=1;
              $display("[C%0d] tu cuoi (iLast=1) sau %0d tu -> padding+permutation",
                       cyc, absorb_cnt); end

always @(posedge soc_clk) if (f_last && !f_done && sha_ready)
    begin t_done=cyc; f_done=1; $display("[C%0d] digest san sang (%0d cyc sau iLast)", cyc, cyc-t_last); end

always @(posedge soc_clk)
    if (f_done && !f_dig && r_valid && ar_addr[7:0]==8'h2C)
        begin t_dig=cyc; f_dig=1; $display("[C%0d] doc xong 8 tu digest (END pure)", cyc); end

always @(posedge soc_clk)
    if (f_dig && !f_bram && bram_en && bram_we!=4'h0) begin
        bcnt = bcnt + 1;
        if (bcnt==8) begin t_bram=cyc; f_bram=1; $display("[C%0d] ghi xong 8 tu digest ra BRAM", cyc); end
    end

task report;
    integer c_core, c_perm, c_pure, c_e2e;
    real tp_perm, tp_pure, tp_e2e;
    real e_pure, e_e2e, eb_pure, eb_e2e;
begin
    c_core = t_done-t_last;
    c_perm = c_core - 1;                     // 1 tu padding (so tu = 17N-1)
    c_pure = f_dig  ? t_dig -t_first : 0;
    c_e2e  = f_bram ? t_bram-t_first : 0;
    tp_perm = 1088.0*FREQ_MHZ/c_perm;
    tp_pure = (c_pure>0) ? {msgbits}.0*FREQ_MHZ/c_pure : 0.0;
    tp_e2e  = (c_e2e >0) ? {msgbits}.0*FREQ_MHZ/c_e2e  : 0.0;
    e_pure  = POWER_W*(c_pure/(FREQ_MHZ*1.0e6))*1.0e9;
    e_e2e   = POWER_W*(c_e2e /(FREQ_MHZ*1.0e6))*1.0e9;
    eb_pure = e_pure/{msgbits}.0;
    eb_e2e  = e_e2e /{msgbits}.0;
    $display("\\n================================================");
    $display("  SE-RISSP + SHA3-256  {nblk} BLOCK  (Freq=%.0f MHz, Power=%.3f W)", FREQ_MHZ, POWER_W);
    $display("================================================");
    $display("  Message: {msgbytes} byte ({msgbits} bit) = {nwords} tu 64-bit = dung {nblk} rate block");
    $display("  Moc cycle: absorb1=%0d iLast=%0d oReady=%0d DIGEST=%0d BRAM=%0d",
             t_first, t_last, t_done, t_dig, t_bram);
    $display("  So tu da absorb: %0d (ky vong {nwords})%0s", absorb_cnt,
             (absorb_cnt=={nwords}) ? "  OK" : "  <<< SAI! mat tu (backpressure?)");
    $display("------------------------------------------------");
    $display("  [1] Permutation CUOI (iLast->oReady): %0d cyc = 1 ck padding + %0d ck perm",
             c_core, c_perm);
    $display("      => peak lo (hang so phan cung): %.2f Mbps (1088 bit / %0d ck)", tp_perm, c_perm);
    $display("      LUU Y: KHONG tinh throughput message tu cua so nay khi N>1 -");
    $display("             {nblk}-1 permutation dau CHONG LAN voi luc CPU nap du lieu,");
    $display("             nen chung khong xuat hien trong bat ky cua so do nao.");
    $display("  [2] PURE       (absorb1->DIGEST): %5d cyc -> %8.2f Mbps", c_pure, tp_pure);
    $display("  [3] END-TO-END (absorb1->BRAM) : %5d cyc -> %8.2f Mbps", c_e2e, tp_e2e);
    $display("------------------------------------------------");
    $display("  CO SO PURE (cung co so voi tb_aes va ban 1-block):");
    $display("    Energy/hash : %9.2f nJ    Energy/bit  : %.4f nJ/bit", e_pure, eb_pure);
    $display("    Throughput/W: %9.2f Mbps/W", (POWER_W>0.0)? tp_pure/POWER_W : 0.0);
    if (c_pure>0)
      $display("    Hieu suat   : %.2f%% (perm {nblk}x%0d = %0d ck / PURE %0d ck)",
               100.0*({nblk}*c_perm)/c_pure, c_perm, {nblk}*c_perm, c_pure);
    $display("  [tham khao] CO SO END-TO-END:");
    $display("    Energy/hash : %9.2f nJ    Energy/bit  : %.4f nJ/bit", e_e2e, eb_e2e);
    $display("    Throughput/W: %9.2f Mbps/W", (POWER_W>0.0)? tp_e2e/POWER_W : 0.0);
    if (c_pure>0)
      $display("    Chi phi moi tu 64-bit: %.2f ck", (c_pure-{nblk}*c_perm)/({nwords}*1.0));
    $display("------------------------------------------------");
    $display("  Verify digest (doi chieu hashlib.sha3_256):");
{checks}    $display("  Verify XOR-fold:");
    vchk(m[8], 32'h{fold}, "fold   ");
    $display("------------------------------------------------");
    if (errs==0) $display("  ==> [PASS] SHA3-256 {nblk} BLOCK DUNG CHUAN");
    else         $display("  ==> [FAIL] %0d cho SAI", errs);
    $display("================================================\\n");
end
endtask
"""

TB_RSA = """
// --- moc cycle tren AXI cua RSA ---
wire [31:0] aw_addr  = {{24'h0, dut.design_1_i.RSA_mark03_0.s00_axi_awaddr}};
wire        aw_valid = dut.design_1_i.RSA_mark03_0.s00_axi_awvalid;
wire [31:0] ar_addr  = {{24'h0, dut.design_1_i.RSA_mark03_0.s00_axi_araddr}};
wire        r_valid  = dut.design_1_i.RSA_mark03_0.s00_axi_rvalid;
wire        rsa_done = dut.design_1_i.RSA_mark03_0.inst.RSA_mark03_slave_lite_v1_0_S00_AXI_inst.done_latch;

integer t_m=0, t_start=0, t_done=0, t_res=0, t_bram=0;
reg f_m=0, f_start=0, f_done=0, f_res=0, f_bram=0;

always @(posedge soc_clk) if (!f_m && aw_valid && aw_addr[7:0]==8'h00)
    begin t_m=cyc; f_m=1; $display("[C%0d] nap M (signature)", cyc); end

always @(posedge soc_clk) if (!f_start && aw_valid && aw_addr[7:0]==8'h14)
    begin t_start=cyc; f_start=1; $display("[C%0d] CTRL start=1 (bat dau modexp)", cyc); end

always @(posedge soc_clk) if (f_start && !f_done && rsa_done)
    begin t_done=cyc; f_done=1; $display("[C%0d] RSA done (%0d cyc)", cyc, cyc-t_start); end

// Chot moc RESULT theo DIA CHI thanh ghi ket qua (0x1C) - giong cach tb_aes
// chot CT (0x3C) va tb_sha3 chot DIGEST (0x2C). KHONG dem so lan doc vi
// truoc do firmware con poll STATUS (0x18) khong biet truoc bao nhieu lan.
always @(posedge soc_clk) if (f_done && !f_res && r_valid && ar_addr[7:0]==8'h1C)
    begin t_res=cyc; f_res=1; $display("[C%0d] doc xong RESULT ve CPU (END pure)", cyc); end

always @(posedge soc_clk) if (f_res && !f_bram && bram_en && bram_we!=4'h0)
    begin t_bram=cyc; f_bram=1; $display("[C%0d] ghi RESULT ra BRAM", cyc); end

task report;
    integer c_core, c_pure, c_e2e;
    real us_core, us_pure, us_e2e, ops, ops_pure, ops_e2e, eb, e_pure, e_e2e;
begin
    c_core = t_done-t_start;
    c_pure = f_res  ? t_res -t_m : 0;
    c_e2e  = f_bram ? t_bram-t_m : 0;
    us_core = c_core/FREQ_MHZ;
    us_pure = c_pure/FREQ_MHZ;
    us_e2e  = c_e2e /FREQ_MHZ;
    ops      = 1.0e6/us_core;
    ops_pure = (c_pure>0) ? 1.0e6/us_pure : 0.0;
    ops_e2e  = (c_e2e >0) ? 1.0e6/us_e2e  : 0.0;
    eb     = POWER_W*(c_core/(FREQ_MHZ*1.0e6))*1.0e9;
    e_pure = POWER_W*(c_pure/(FREQ_MHZ*1.0e6))*1.0e9;
    e_e2e  = POWER_W*(c_e2e /(FREQ_MHZ*1.0e6))*1.0e9;
    $display("\\n================================================");
    $display("  SE-RISSP + RSA verify   (Freq=%.0f MHz, Power=%.3f W)", FREQ_MHZ, POWER_W);
    $display("================================================");
    $display("  C = M^E mod N   (Montgomery, E=65537)");
    $display("  Moc cycle: M=%0d start=%0d done=%0d RESULT=%0d BRAM=%0d",
             t_m, t_start, t_done, t_res, t_bram);
    $display("------------------------------------------------");
    $display("  [1] Loi RSA    (start->done) : %4d cyc = %6.2f us -> %8.0f verify/s", c_core, us_core, ops);
    $display("  [2] PURE       (M->RESULT)   : %4d cyc = %6.2f us -> %8.0f verify/s", c_pure, us_pure, ops_pure);
    $display("  [3] END-TO-END (M->BRAM)     : %4d cyc = %6.2f us -> %8.0f verify/s", c_e2e, us_e2e, ops_e2e);
    $display("------------------------------------------------");
    $display("  CO SO PURE (cung co so voi tb_aes / tb_sha3):");
    $display("    Energy/verify: %9.2f nJ", e_pure);
    $display("    verify/s/W   : %9.0f", (POWER_W>0.0)? ops_pure/POWER_W : 0.0);
    if (c_pure>0)
      $display("    Hieu suat    : %.1f%% (loi RSA %0d ck / PURE %0d ck)",
               100.0*c_core/c_pure, c_core, c_pure);
    else
      $display("    [!] CANH BAO: khong thay lan doc 0x1C -> PURE vo nghia.");
    $display("  [tham khao] loi: %.2f nJ | END-TO-END: %.2f nJ", eb, e_e2e);
    $display("------------------------------------------------");
    $display("  Verify ket qua:");
{checks}    $display("  (bang XOR-fold cua SHA3-256 digest => chu ky HOP LE)");
    $display("------------------------------------------------");
    if (errs==0) $display("  ==> [PASS] RSA verify DUNG");
    else         $display("  ==> [FAIL] ket qua SAI");
    $display("================================================\\n");
end
endtask
"""

TB_TAIL = """
reg fin = 0;
always @(posedge clk_in1_0) if (!reset_0 && !fin) begin
    if (m[{mk_idx}] == 32'h{marker}) begin fin=1; report; $finish; end
    else if (cyc > {timeout}) begin
        fin = 1;
        $display("\\n[TIMEOUT] cyc=%0d, chua thay marker (m[{mk_idx}]=%08x)", cyc, m[{mk_idx}]);
        $display("  -> kiem tra: blk_mem_gen_0 da nap {coe} + Generate Output Products chua?");
        report; $finish;
    end
end

// Chan cuoi cung: neu 'force' o tren khong an (vd elaborate thieu
// -debug typical) thi soc_clk khong chay -> 'cyc' dung yen -> timeout theo
// cyc o tren KHONG BAO GIO xay ra -> mo phong treo vinh vien. Timeout theo
// thoi gian tuyet doi duoi day dam bao luon ket thuc.
// LUU Y: gia tri nay PHAI lon hon {timeout} chu ky x 25ns, neu khong no se
// cat mo phong TRUOC khi CPU chay xong (da dinh loi nay that voi RSA-2048:
// loi can 320000 ck = 8ms nhung timeout tuyet doi de 1ms = 40000 ck).
initial begin
    #{abs_ns};
    if (!fin) begin
        fin = 1;
        $display("\\n[TIMEOUT tuyet doi] soc_clk dem duoc %0d chu ky sau {abs_ns} ns.", cyc);
        if (cyc == 0)
            $display("  -> soc_clk KHONG chay: lenh 'force clk_wiz_0_clk_out1' khong an.",
                     "\\n     Elaborate phai co '-debug typical' (Vivado GUI mac dinh da co).");
        else
            $display("  -> CPU co chay nhung chua ghi marker: kiem tra dung file .coe chua.");
        report; $finish;
    end
end

endmodule
"""


def gen_tb(name):
    tb, coe = f"tb_{name}", f"{name}.coe"
    if name.startswith("aes_"):
        mode = AES_MODE[name][2]
        checks = "".join(f'    vchk(m[{i}], 32\'h{w}, "CT[{i}]  ");\n'
                         for i, w in enumerate(EXP[name]))
        head = TB_HEAD.format(title=f"SE-RISSP + AES-128 {mode} - do throughput + verify NIST",
                              tb=tb, coe=coe)
        body = TB_AES.format(mode=mode, checks=checks)
        tail = TB_TAIL.format(mk_idx=4, marker=MARKER[name], timeout=200000, abs_ns=1000000, coe=coe)
    elif name in SHA3_MULTI:
        nblk = SHA3_MULTI[name]
        nw   = sha3_multi_words(nblk)
        checks = "".join(f'    vchk(m[{i}], 32\'h{w}, "D[{i}]   ");\n'
                         for i, w in enumerate(SHA3_MULTI_EXP[name]))
        head = TB_HEAD.format(title=f"SE-RISSP + SHA3-256 {nblk} block - do throughput "
                                    "+ verify digest", tb=tb, coe=coe)
        body = TB_SHA3_MULTI.format(checks=checks, fold=SHA3_MULTI_FOLD[name],
                                    msgbits=nw*64, msgbytes=nw*8,
                                    nblk=nblk, nwords=nw)
        tail = TB_TAIL.format(mk_idx=12, marker=SHA3_MULTI_MARK[name],
                              timeout=200000, abs_ns=1000000, coe=coe)
    elif name == "sha3":
        checks = "".join(f'    vchk(m[{i}], 32\'h{w}, "D[{i}]   ");\n'
                         for i, w in enumerate(EXP["sha3"]))
        head = TB_HEAD.format(title="SE-RISSP + SHA3-256 - do throughput + verify digest",
                              tb=tb, coe=coe)
        body = TB_SHA3.format(checks=checks, fold=SHA3_FOLD,
                              msgbits=len(SHA3_MSG)*8, msgbytes=len(SHA3_MSG),
                              msgwords=len(SHA3_MSG)//8)
        tail = TB_TAIL.format(mk_idx=12, marker=MARKER[name], timeout=200000, abs_ns=1000000, coe=coe)
    else:
        checks = f'    vchk(m[0], 32\'h{EXP["rsa"][0]}, "RESULT ");\n'
        head = TB_HEAD.format(title="SE-RISSP + RSA verify - do latency + verify ket qua",
                              tb=tb, coe=coe)
        body = TB_RSA.format(checks=checks)
        tail = TB_TAIL.format(mk_idx=4, marker=MARKER[name], timeout=200000, abs_ns=1000000, coe=coe)
    return head + body + tail


def build(name, asm):
    (HERE / f"{name}.s").write_text(asm, encoding="utf-8", newline="\n")
    o, elf, binf = HERE / f"{name}.o", HERE / f"{name}.elf", HERE / f"{name}.bin"
    for cmd in ([str(AS), "-march=rv32i", "-mabi=ilp32", "-o", str(o), str(HERE / f"{name}.s")],
                [str(LD), "-T", str(HERE / "link.ld"), "-o", str(elf), str(o)],
                [str(OC), "-O", "binary", str(elf), str(binf)]):
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode:
            sys.exit(f"LOI build {name}:\n{r.stderr}")
    data = binf.read_bytes()
    w = [struct.unpack("<I", data[i:i + 4])[0] for i in range(0, len(data), 4)]
    L = ["%08X" % x for x in w]
    (HERE / f"{name}.coe").write_text(
        "memory_initialization_radix=16;\nmemory_initialization_vector=\n"
        + ",\n".join(L[:-1]) + ",\n" + L[-1] + ";\n", newline="\n")
    (HERE / f"{name}.hex").write_text("".join("%08x\n" % x for x in w), newline="\n")
    for f in (o, elf, binf):
        f.unlink()
    return len(w)


def main():
    refresh_aes_ct()
    (HERE / "link.ld").write_text(LINKER, newline="\n")
    jobs = ([(n, gen_aes(n)) for n in AES_MODE]
            + [("sha3", gen_sha3())]
            + [(n, gen_sha3_multi(n)) for n in SHA3_MULTI]
            + [("rsa", gen_rsa())])
    for name, asm in jobs:
        n = build(name, asm)
        (HERE / f"tb_{name}.v").write_text(gen_tb(name), encoding="utf-8", newline="\n")
        print(f"  {name:8s} -> {name}.coe ({n:3d} tu)  +  tb_{name}.v")
    print("\nXong. Nap tung .coe vao blk_mem_gen_0 roi chay testbench tuong ung.")


if __name__ == "__main__":
    main()
